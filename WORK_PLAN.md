# Memory Arena — Work Plan

Living checklist for MVP implementation. Gameplay rules: [GAME_DESIGN.md](GAME_DESIGN.md). Technical structure: [ARCHITECTURE.md](ARCHITECTURE.md).

Godot project lives in `memory-game/`.

**Last updated:** Step 7 complete — ready for Step 8.

---

## Progress overview

| Step | Focus | Status |
|------|-------|--------|
| 1 | Grid + selector movement | **Done** |
| 2 | Reveal + two-tile selection | **Done** |
| 3 | Match / mismatch + tile states | **Done** |
| 4 | Combat — HP + enemy timer | **Done** |
| 5 | Effects — attack + heal | **Done** |
| 6 | Effects — slow, speed, upgrade | **Done** |
| 7 | Board refresh when cleared | **Done** |
| 8 | Win / lose + battle end | **Next** |

---

## What's implemented (summary)

| System | Done |
|--------|------|
| Scenes | `Main` (orchestrator), `Board`, `Selector`, `Tile`, `Combat`, `HUD`, `EffectResolver` |
| Movement | WASD, base 0.25s cooldown, grid clamping, speed stacks |
| Input | `move_*` actions, `reveal` (Space) |
| Board | 4×4 spawn, shuffled pair ids (0–7), `pair_matched` signal |
| Selection FSM | `IDLE` → `ONE_SELECTED` → resolve |
| Match | Same `pair_id` → `make_empty()` + emit |
| Mismatch | Grey face, 1s freeze, 4s cover fade → `conceal()` |
| Tile states | `HIDDEN`, `REVEALED`, `GREYED`, `EMPTY` |
| Pair ids | 0–2 Attack, 3–4 Heal, 5 Slow, 6 Speed, 7 Upgrade |
| Combat | HP, enemy timer, heal/damage, slow stacks, attack bonus |
| HUD | HP labels via `hp_changed` |
| Effects | Full pair table via EffectResolver |
| Board refresh | Clear all pairs → new shuffled board (`board_cleared` / `board_dealt`) |

**Not yet:** win/lose UI / end battle.

---

## Effect reference (current numbers)

| pair_id | Effect | Implementation |
|---------|--------|----------------|
| 0–2 | Attack | `damage_enemy(3 + attack_bonus)` |
| 3–4 | Heal | `heal_player(4)` |
| 5 | Slow | Combat: stacks 1–3, +25% enemy interval each, 10s refresh |
| 6 | Speed | Selector: stacks 1–3, −0.05s cooldown each (min 0.1), 10s refresh |
| 7 | Upgrade | Combat: `attack_bonus += 1` for rest of battle |

---

## Step details

### Step 1 — Grid + selector movement ✅

Build a 4×4 board of placeholder tiles and a selector highlight. WASD moves the selector on a discrete grid with a 0.25s cooldown. Positions are clamped so the selector cannot leave the board.

**Validates:** coordinate system, scene instancing, input, Board ↔ Selector wiring via `Main`.

**Key files:** `Tile.tscn`, `Board.tscn`, `Selector.tscn`, `Main.tscn`, `board.gd`, `selector.gd`, `main.gd`.

---

### Step 2 — Reveal + two-tile selection ✅

Press Space to reveal the tile under the selector. Board tracks selection state (`IDLE` → `ONE_SELECTED`). Two-tile pick flow wired to Board.

**Validates:** tile `reveal()` / `conceal()`, Board selection FSM, tile lookup by grid position.

**Key files:** `tile.gd`, `board.gd`, Input Map action `reveal`.

**Note:** Temporary 2s auto-conceal was replaced in Step 3.

---

### Step 3 — Match / mismatch + tile states ✅

Assign a **pair id** (0–7) to each tile when the board is dealt. On second reveal, compare ids:

- **Match** → remove both tiles (empty holes); selector can move through them
- **Mismatch** → grey both tiles, 1s input freeze, 4s cover fade back to concealed

Tile uses `Face` + `Cover` layers. States: `GREYED`, `EMPTY` added. Greyed tiles not selectable (`is_hidden()` only true when face-down).

**Validates:** tile FSM, tweens, pair shuffle, memory-game core loop.

**Key files:** `tile.gd`, `Tile.tscn`, `board.gd`, `selector.gd` (`is_input_blocked()`).

**Gotcha fixed:** call `add_child(tile)` before `tile.setup()` so `@onready` nodes exist.

---

### Step 4 — Combat — HP + enemy timer ✅

`Combat` owns player/enemy HP and an enemy attack timer (default: every 4s, 2 damage). HUD labels update via `hp_changed`. Board play continues while combat runs.

**Validates:** real-time pressure, combat independent of board selection, signal → HUD.

**Key files:** `combat.gd`, `Main.tscn` (`Combat`, `HUD`), `main.gd`.

---

### Step 5 — Effects — attack + heal ✅

Board emits `pair_matched(pair_id)`. EffectResolver maps ids 0–2 → `damage_enemy(3)`, ids 3–4 → `heal_player(4)`.

**Validates:** Board decoupled from Combat; first real match consequences.

**Key files:** `board.gd`, `scripts/effects/effect_resolver.gd`, `main.gd`.

---

### Step 6 — Effects — slow, speed, upgrade ✅

Full pair table wired through EffectResolver:

- **Slow (5)** — `Combat.apply_slow()`; stacks ≤ 3; interval via `get_attack_interval()`; 10s expiry
- **Speed (6)** — `Selector.apply_speed()`; stacks ≤ 3; move cooldown via `get_move_cooldown()`; 10s expiry
- **Upgrade (7)** — `Combat.add_attack_bonus(1)`; permanent for battle; attacks use `ATTACK_DAMAGE + attack_bonus`

Buff state lives where it affects gameplay: **Combat** (slow, upgrade), **Selector** (speed). EffectResolver only dispatches.

**Validates:** buff timers, stacking, move cooldown modification, attack scaling.

**Key files:** `effect_resolver.gd`, `combat.gd`, `selector.gd`, `main.gd` (`setup(combat, selector)`).

---

### Step 7 — Board refresh when cleared ✅

Tracks `_pairs_remaining`. On match, decrement. When 0: emit `board_cleared`, free tiles, wait one frame, `_spawn_grid()` (new shuffle), emit `board_dealt`. Fight continues; clearing a board alone does not end battle.

**Validates:** multi-board fights without restarting the scene.

**Key files:** `board.gd` (`board_cleared`, `board_dealt`, `_deal_new_board`).

---

### Step 8 — Win / lose + battle end

Win when enemy HP ≤ 0. Lose when player HP ≤ 0. Stop input, end battle state. MVP loop is playable start to finish.

Also improve feedback UI so HP, buffs, and battle result are easy to read (see discussion in chat).

**Validates:** full single-battle loop, `ENDED` input gate.

---

## After MVP

- 6×6 board scaling
- Art, animation, audio
- Progression, save system
- More enemy types, endless mode, multiplayer (see GDD future features)

---

*Update the status column as steps are completed.*
