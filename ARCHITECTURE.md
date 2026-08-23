# Memory Arena — Architecture (MVP 2)

Technical blueprint for Godot 4. Battle rules: [GAME_DESIGN.md](GAME_DESIGN.md). Run/map: [GAME_PROGRESSION_ELEMENTS_DESIGN.md](GAME_PROGRESSION_ELEMENTS_DESIGN.md). Build order: [WORK_PLAN.md](WORK_PLAN.md).

**MVP 1 reference:** [archive/MVP_1/ARCHITECTURE.md](archive/MVP_1/ARCHITECTURE.md).

---

## Design shifts from MVP 1

| MVP 1 | MVP 2 |
|-------|-------|
| 4×4, match by unique `pair_id` | 6×6, match by **icon + color**; duplicates allowed |
| One `Combat` enemy | **Enemy roster** — each unit has HP, timer, damage, actions |
| Mismatch only | Four resolve outcomes (true pair / color match / icon-only / full miss) |
| — | **Mana bar** → autofire bonus attack |
| Main = single battle only | Later: Run owns map; Battle receives loadout config |

---

## Godot concepts (short)

- **Scene tree** — nodes and ownership
- **States** — what am I allowed to do now? (`enum` + `match`)
- **Signals** — what just happened? (decouple Board from Combat)

Prefer composition: e.g. `Enemy` data + behavior, managed by a combat director — not one giant script.

---

## Target scene tree (battle)

```
Main / BattleRoot (Node)           ← wires systems; later instanced by Run
├── Board (Node2D)                 ← 6×6 grid, deal, reveal FSM, resolve
│   └── Tile (×36)                 ← icon + color visuals + states
├── Selector (Node2D)              ← grid cursor, move cooldown, speed stacks
├── CombatDirector (Node)          ← player HP, mana, enemy list, win/lose
│   └── Enemy (×N)                 ← or plain RefCounted/resources driven by director
├── EffectResolver (Node)          ← effect_id → apply to player / enemies
└── HUD (CanvasLayer)              ← HP, enemy rows, mana, buffs, end overlay
```

**MVP 1 note:** Today `Combat` is a single-enemy node. MVP 2 should evolve it into a **director + per-enemy state** without rewriting Board/Selector from scratch.

### Responsibilities

| Node | Owns | Does not own |
|------|------|----------------|
| **Board** | Grid, deal pool, selection FSM, resolve outcome, tile lockouts | Player HP, mana math, enemy timers |
| **Tile** | Visual state, `effect_id`, `color_id`, fade tweens | Global match rules |
| **Selector** | Grid position, move CD, speed stacks | Reveal rules |
| **CombatDirector** | Player HP, mana bar, bonus attack fire, enemy roster, money reward hook | Pair icon meanings |
| **Enemy** | Own HP, cooldown, damage, action type | Board |
| **EffectResolver** | Map effect → calls on director/selector/enemies | Stack storage internals |
| **HUD** | Display only | Game rules |
| **Run** (later) | Map, loadout, shop | Tile matching |

---

## Tile & match data

```gdscript
# Conceptual — not mandated API
effect_id: int   # icon / what it does
color_id: int    # 0..3 affiliation
```

**True pair:** `a.effect_id == b.effect_id and a.color_id == b.color_id`  
Duplicates on the board: several tiles may share the same pair signature; any two that match the test form a pair.

Optional internal `instance_id` / unused `pair_id` is fine for debugging; **do not** use it as the player match key.

**Deal:** `Board.STARTING_PAIRS` is the locked 18-pair composition (`Vector2i(effect_id, color_id)`). Deal duplicates each entry, shuffles, spawns. Composition table lives in [GAME_DESIGN.md](GAME_DESIGN.md).

---

## Board selection states

Unchanged idea from MVP 1:

```
IDLE → ONE_SELECTED → resolve → IDLE
```

### Resolve signal proposal

Prefer one rich signal (or a small enum) so Main/Director stay tidy:

| Outcome | Board emits (proposal) | Listeners |
|---------|------------------------|-----------|
| True pair | `pair_matched(effect_id, color_id)` | EffectResolver; Board removes tiles |
| Color match | `color_matched(color_id)` | CombatDirector (mana + hurry); Board long grey |
| Icon-only | `reveal_noop()` or `icon_only_matched` | Board short grey; no mana |
| Full miss | `pair_mismatched` | Board short grey |

Names can vary; keep **one place** that classifies the four outcomes.

---

## CombatDirector & enemies

### Player

- HP / max HP
- Mana 0..max → on full, **autofire** `bonus_attack` at **default target**
- Attack bonus (from Upgrade pairs), heal power, etc.

### Default target (MVP 2)

Pick one policy and document it in code comments + GDD Values:

- Recommendation: **first living enemy in list**, or **lowest HP living**  
- Explicit targeting = later milestone

### Enemy unit

| Field | Role |
|-------|------|
| `hp` / `max_hp` | |
| `attack_interval` | Baseline seconds |
| `attack_damage` | |
| `timer` | Counts up/down to next action |
| `action_kind` | `DAMAGE` first; later `HEAL_ALLY`, `DEBUFF_PLAYER`, … |

Director ticks all living enemies each frame; on death emit `enemy_defeated(enemy_id)` → money; when none left → `battle_won`.

### Slow buff

MVP 2 proposal: Slow applies to **all living enemies** (readable). Revisit with targeting.

---

## Mana

| Event | Mana |
|-------|------|
| Color match | += tuned amount |
| Bar full | Autofire bonus attack; reset bar to 0 (or remainder — prefer reset for simplicity) |

HUD reads mana via director getters (same push/`_process` pattern as MVP 1 attack bar).

**Current code (Step 6):** mana still lives on `Combat` until Step 7 extracts a director + enemy roster. Behavior matches this table.

---

## Signals (battle)

| Signal | Emitter | Typical listeners |
|--------|---------|-------------------|
| `pair_matched(effect_id, color_id)` | Board | EffectResolver |
| `color_matched(color_id)` | Board | CombatDirector |
| `reveal_resolved(outcome)` | Board | Optional umbrella |
| `board_cleared` / `board_dealt` | Board | Board redeal / HUD |
| `mana_changed` | CombatDirector | HUD |
| `bonus_attack_fired` | CombatDirector | HUD / juice |
| `enemy_hp_changed` | CombatDirector | HUD |
| `enemy_defeated` | CombatDirector | Money / HUD |
| `player_defeated` / `battle_won` | CombatDirector | Main end overlay |

---

## Run layer (later)

```
Run (Node)
├── MapView
├── Loadout / PairPool
└── Battle instance (packed scene) with BattleConfig
```

BattleRoot accepts a `BattleConfig` (player stats, enemy roster, pair pool). Do not entangle map UI into Board.

---

## Folder structure (evolve toward)

```
Memory-Game/
├── GAME_DESIGN.md
├── ARCHITECTURE.md
├── WORK_PLAN.md
├── GAME_PROGRESSION_ELEMENTS_DESIGN.md
├── archive/MVP_1/
└── memory-game/
    ├── scenes/
    │   ├── main/          ← battle entry for now
    │   ├── board/
    │   ├── selector/
    │   ├── ui/
    │   ├── combat/        ← enemy scenes if needed
    │   └── run/           ← later
    └── scripts/
        ├── board/
        ├── tile/
        ├── combat/        ← director + enemy
        ├── effects/
        ├── run/           ← later
        └── ui/
```

---

## Open choices (decide when coding)

| Topic | Options | Lean |
|-------|---------|------|
| Enemy representation | Child nodes vs RefCounted list in director | RefCounted/resources first — less scene spam |
| Color-match hurry | All enemies vs default only | All living |
| Icon-only / miss hurry | None vs light | None until playtest says otherwise |
| Deal algorithm | Weighted table vs scripted compositions | Data table in one script/resource |

---

*Update with structure changes. Rules changes go in GAME_DESIGN.md / GAME_PROGRESSION_ELEMENTS_DESIGN.md.*
