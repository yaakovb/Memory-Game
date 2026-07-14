# Memory Arena — Architecture

Technical blueprint for Godot 4 implementation. Gameplay rules live in [GAME_DESIGN.md](GAME_DESIGN.md).

This document covers:
- Core Godot concepts used in this project
- Scene tree (what exists, who owns what)
- State lists (modes and transitions)
- Signals (events, who emits, who listens)

---

## Godot Concepts (Quick Reference)

### Scene tree

In Godot, the running game is a hierarchy of **nodes** (parent → children). A **scene** (`.tscn`) is a saved piece of that tree you can reuse and instance — similar to a prefab in Unity.

The **scene tree design** is our plan for which nodes exist, how they nest, and what each one is responsible for. Define this before coding so logic does not end up in one giant script.

### State list

A **state** is a label for how something behaves *right now* (e.g. tile is hidden, selector is frozen). A **state list** documents every mode an object can be in and how it moves between them — a simple finite state machine (FSM). Often an `enum` plus `match` in GDScript.

**States** answer: *What am I allowed to do now?*  
**Signals** answer: *What just happened?*

### Signals

Godot **signals** are events. One node **emits**; others **connect** and react. Similar to C# `event` / `Action`.

We use signals so systems stay decoupled: the Board announces `pair_matched` without knowing enemy HP; Combat listens and applies damage.

---

## Scene Tree

### Overview

```
Main (Node2D)                        ← project entry; wires systems (MVP orchestrator)
├── Board (Node2D)                   ← grid, tile spawning, match logic
│   └── Tile (×16)                   ← instanced from scenes/board/Tile.tscn
├── Selector (Node2D)                ← grid position, movement cooldown, visuals
├── Combat (Node)                    ← HP, enemy attack timer, slow stacks, attack bonus
├── EffectResolver (Node)            ← pair_id → combat/selector actions
└── HUD (CanvasLayer)                ← HP labels (MVP: minimal)
    └── VBoxContainer
        ├── PlayerHPLabel
        └── EnemyHPLabel
```

**Note:** A separate `Battle` scene was planned; MVP uses `Main` as the orchestrator. Introduce `Battle.tscn` later if Main grows (win/lose, multi-board) and you want a cleaner entry scene.

### Scene files (current / planned)

| File | Root type | Purpose |
|------|-----------|---------|
| `scenes/main/main.tscn` | `Node2D` | Entry + wiring (current) |
| `scenes/battle/Battle.tscn` | `Node` | Optional later — battle orchestration |
| `scenes/board/Board.tscn` | `Node2D` | Grid layout and tile container |
| `scenes/board/Tile.tscn` | `Node2D` | Single cell (face + cover) |
| `scenes/selector/selector.tscn` | `Node2D` | Cursor highlight on grid |

### Responsibilities

| Node | Owns | Does NOT own |
|------|------|----------------|
| **Main** | Wiring (setup/connect), HUD text from `hp_changed` | Match rules, damage formulas |
| **Board** | Grid size, tile positions, spawn/clear tiles, pick-two logic, match/mismatch | Player HP, enemy timer |
| **Tile** | Visual state (hidden/revealed/greyed/empty), fade tween, `pair_id` | Whether two tiles match globally |
| **Selector** | Grid coordinates, move cooldown, **speed stacks/timer** | Reading match rules |
| **Combat** | Player/enemy HP, enemy attack timer, **slow stacks/timer**, **attack_bonus** | Which pair id means what |
| **EffectResolver** | Map `pair_id` → method calls on Combat/Selector | Stack storage, HP math internals |
| **HUD** | Display HP (optional: buff labels later) | Game rules |

### Input ownership (MVP decision)

| Input | Handled by | Notes |
|-------|------------|-------|
| WASD | **Selector** | Only when Battle input state is `PLAYING` |
| Space | **Board** (via Battle routing) | Reveal tile at selector grid position |

**Battle** checks input state before forwarding. Selector asks Battle `can_accept_input()` or Battle sets a flag on Selector. Either pattern works; pick one when implementing — default recommendation: **Battle gates, Selector moves, Board reveals**.

### Coordinate model

- Grid is **4×4**, indices `(0,0)` top-left through `(3,3)` bottom-right.
- **Selector** stores `grid_position: Vector2i`.
- **Board** maps `Vector2i` → tile instance and world position.
- **Empty holes** still occupy grid cells; selector moves through them; Space does nothing useful on `EMPTY`.

---

## State Lists

### 1. Tile (`Tile.gd`)

Each cell on the board.

| State | Meaning | Space allowed? | Visible |
|-------|---------|----------------|---------|
| `HIDDEN` | Face-down, playable | Yes (reveal) | Back / cover |
| `REVEALED` | Face-up, part of active selection | No (already picked) | Icon |
| `GREYED` | Face-up after mismatch, fading to hidden | No | Greyed icon → cover fades in |
| `EMPTY` | Matched and removed | No | Empty / hole |

**Transitions:**

```
HIDDEN ──[selected for reveal]──► REVEALED
REVEALED ──[match resolved]──► EMPTY
REVEALED ──[mismatch resolved]──► GREYED
GREYED ──[fade complete, 4s]──► HIDDEN
```

**Notes:**
- Cap **2 active greyed pairs** (4 tiles in `GREYED`) — if a third mismatch occurs, define policy at implementation (recommended: still grey both; oldest pair continues fading).
- Greyed tiles are not valid selection targets.

---

### 2. Board selection (`Board.gd`)

Tracks the two-tile pick flow. Separate from tile visual state.

| State | Meaning |
|-------|---------|
| `IDLE` | Waiting for first tile selection |
| `ONE_SELECTED` | First tile revealed; waiting for second |

**Transitions:**

```
IDLE ──[valid reveal on HIDDEN tile]──► ONE_SELECTED
ONE_SELECTED ──[valid reveal on second HIDDEN tile]──► resolve pair ──► IDLE
ONE_SELECTED ──[reveal invalid: EMPTY, GREYED, REVEALED, or same tile]──► ignore (stay ONE_SELECTED)
```

After resolve: emit `pair_matched` or `pair_mismatched`; both tiles updated; selection returns to `IDLE`.

---

### 3. Input gate (`Battle.gd`)

Controls whether the player can act. Distinct from selector movement cooldown.

| State | Meaning | Move | Space |
|-------|---------|------|-------|
| `PLAYING` | Normal play | Yes* | Yes |
| `FROZEN` | After mismatch | No | No |
| `ENDED` | Win or lose | No | No |

\*Move only when selector move cooldown allows.

**Transitions:**

```
PLAYING ──[pair_mismatched]──► FROZEN
FROZEN ──[1s timer]──► PLAYING
PLAYING ──[battle_ended]──► ENDED
FROZEN ──[battle_ended]──► ENDED   (edge case: kill enemy during freeze)
```

---

### 4. Battle flow (`Battle.gd`)

High-level fight lifecycle.

| State | Meaning |
|-------|---------|
| `IN_PROGRESS` | Fight active |
| `ENDED` | Win or lose; input off |

**Transitions:**

```
IN_PROGRESS ──[player HP ≤ 0]──► ENDED (lost)
IN_PROGRESS ──[enemy HP ≤ 0]──► ENDED (won)
```

`ENDED` aligns with input gate `ENDED`; can be one enum or two linked flags — implementation choice.

---

### 5. Buff stacks (implemented ownership)

Buff **state** lives on the system it affects. EffectResolver only **applies**.

| Buff | Owner | Fields | Rules |
|------|-------|--------|-------|
| **Slow** | `Combat` | `_slow_stacks` (0–3), `_slow_timer` | +25% attack interval per stack; 10s refreshed on reapply |
| **Speed** | `Selector` | `_speed_stacks` (0–3), `_speed_timer` | −0.05s move cooldown per stack (min 0.1); 10s refreshed on reapply |
| **Upgrade** | `Combat` | `attack_bonus` (int) | Permanent for battle; +1 per upgrade match |

Decay: when timer hits 0, reset that buff’s stacks to 0.

---

## Signals

### What each signal means

| Signal | When it fires | Payload |
|--------|---------------|---------|
| `pair_matched` | Two revealed tiles match | `effect_id` |
| `pair_mismatched` | Two revealed tiles do not match | none |
| `board_cleared` | All pairs removed; only empty holes remain | none |
| `board_dealt` | New 4×4 board placed and ready | none |
| `effect_applied` | Effect logic finished applying | `effect_id` |
| `battle_ended` | Win or lose | `won: bool` |

### Emitter → listener map

| Signal | Emitter | Listeners (connect in Battle setup) |
|--------|---------|-------------------------------------|
| `pair_matched` | **Board** | Battle → EffectResolver; Battle handles tile removal side effects if needed |
| `pair_mismatched` | **Board** | Battle (start freeze) |
| `board_cleared` | **Board** | Battle (deal new board) |
| `board_dealt` | **Board** | Battle, HUD (optional reset UI) |
| `effect_applied` | **EffectResolver** | Combat (HP changes), Selector (speed), HUD |
| `battle_ended` | **Battle** | HUD, Board/Selector (stop input) |

Combat may also emit internal signals or call Battle directly when HP hits zero — either `player_died` / `enemy_died` internally, then Battle emits `battle_ended`.

### Suggested flow (match)

```
1. Board: second tile revealed → match → emit pair_matched(effect_id)
2. Board: set both tiles EMPTY
3. Battle: forward to EffectResolver
4. EffectResolver: apply effect, emit effect_applied(effect_id)
5. Combat: update HP; if enemy HP ≤ 0 → Battle ends fight
6. Board: if no HIDDEN/GREYED/REVEALED tiles with content → emit board_cleared
7. Battle: on board_cleared → Board.deal_board() → emit board_dealt
```

### Suggested flow (mismatch)

```
1. Board: no match → emit pair_mismatched
2. Battle: input gate → FROZEN; start 1s timer
3. Board: both tiles → GREYED; start 4s fade tween each
4. Battle: after 1s → PLAYING
5. Tile: after 4s fade → HIDDEN
```

---

## Build Order (maps to scene tree)

Status tracked in [WORK_PLAN.md](WORK_PLAN.md). Each step should be playable before the next.

| Step | What to build | Status |
|------|---------------|--------|
| 1 | `Board` + `Tile` + `Selector` — grid, WASD, highlight | Done |
| 2 | Reveal + selection FSM | Done |
| 3 | Match / mismatch + tile states + grey fade | Done |
| 4 | `Combat` — HP labels, enemy timer | Done |
| 5 | `EffectResolver` — attack + heal | Done |
| 6 | Slow / speed / upgrade buffs | Done |
| 7 | `board_cleared` / `board_dealt` | Done |
| 8 | Win / lose + `ENDED` + clearer HUD | Next |

---

## Folder structure (current)

```
Memory-Game/
├── GAME_DESIGN.md
├── ARCHITECTURE.md
├── WORK_PLAN.md
└── memory-game/                 ← Godot project root
    ├── project.godot
    ├── scenes/
    │   ├── main/
    │   ├── board/
    │   └── selector/
    └── scripts/
        ├── main/
        ├── board/
        ├── tile/
        ├── selector/
        ├── combat/
        └── effects/
```

---

## Open implementation choices (decide when coding)

| Topic | Options | Recommendation |
|-------|---------|----------------|
| Input gate API | Battle polls vs Selector asks Battle | Battle owns gate; Selector checks before move |
| `board_cleared` detection | Board counts EMPTY vs Board tracks pairs_remaining | `pairs_remaining` counter decremented on match |
| Tile root type | `Node2D` vs `Control` | `Control` if UI-style tiles; `Node2D` if world-space — either works for MVP |
| EffectResolver location | Sibling of Combat vs child of Battle | Sibling under Battle (as in tree above) |

---

*Companion to [GAME_DESIGN.md](GAME_DESIGN.md). Update this file when structure changes; update GDD when rules change.*
