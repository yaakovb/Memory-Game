# Memory Arena — Work Plan

Living checklist for MVP implementation. Gameplay rules: [GAME_DESIGN.md](GAME_DESIGN.md). Technical structure: [ARCHITECTURE.md](ARCHITECTURE.md).

Godot project lives in `memory-game/`.

**Last updated:** Step 3 complete — ready for Step 4.

---

## Progress overview

| Step | Focus | Status |
|------|-------|--------|
| 1 | Grid + selector movement | **Done** |
| 2 | Reveal + two-tile selection | **Done** |
| 3 | Match / mismatch + tile states | **Done** |
| 4 | Combat — HP + enemy timer | **Next** |
| 5 | Effects — attack + heal | Not started |
| 6 | Effects — slow, speed, upgrade | Not started |
| 7 | Board refresh when cleared | Not started |
| 8 | Win / lose + battle end | Not started |

---

## What's implemented (summary)

| System | Done |
|--------|------|
| Scenes | `Main`, `Board`, `Selector`, `Tile` |
| Movement | WASD, 0.25s cooldown, grid clamping |
| Input | `move_*` actions, `reveal` (Space) |
| Board | 4×4 spawn, shuffled pair ids (0–7), tile lookup |
| Selection FSM | `IDLE` → `ONE_SELECTED` → resolve |
| Match | Same `pair_id` → `make_empty()` (holes) |
| Mismatch | Grey face, 1s freeze, 4s cover fade → `conceal()` |
| Tile states | `HIDDEN`, `REVEALED`, `GREYED`, `EMPTY` |
| Pair colors | 0–2 Attack, 3–4 Heal, 5 Slow, 6 Speed, 7 Upgrade |

**Not yet:** combat, effects on match, new board when cleared, win/lose.

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

### Step 4 — Combat — HP + enemy timer

Add `Combat` (and minimal HUD labels). Player and enemy have HP. Enemy attacks on a fixed timer while the player plays — the game never pauses.

**Validates:** real-time pressure, combat running independently of board selection.

---

### Step 5 — Effects — attack + heal

Wire match results to combat. Attack pairs damage the enemy; heal pairs restore player HP. Introduce `EffectResolver` (or equivalent) so Board announces matches without knowing HP math.

**Validates:** signal-style decoupling, first real gameplay consequences.

---

### Step 6 — Effects — slow, speed, upgrade

Add remaining pair types from the GDD:

- **Slow** — enemy attacks less often (timed buff, stacks up to 3)
- **Speed** — faster selector movement (timed buff, stacks up to 3)
- **Upgrade** — +1 attack damage for rest of battle

**Validates:** buff timers, stacking, selector move cooldown modification.

---

### Step 7 — Board refresh when cleared

When all pairs on the current board are removed, deal a new shuffled board. Battle continues until win or lose — clearing a board alone does not end the fight.

**Validates:** `board_cleared` / `board_dealt` flow, multi-board fights.

---

### Step 8 — Win / lose + battle end

Win when enemy HP ≤ 0. Lose when player HP ≤ 0. Stop input, end battle state. MVP loop is playable start to finish.

**Validates:** full single-battle loop, `ENDED` input gate.

---

## After MVP

- 6×6 board scaling
- Art, animation, audio
- Progression, save system
- More enemy types, endless mode, multiplayer (see GDD future features)

---

*Update the status column as steps are completed.*
