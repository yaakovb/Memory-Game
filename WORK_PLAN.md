# Memory Arena — Work Plan

Living checklist for MVP implementation. Gameplay rules: [GAME_DESIGN.md](GAME_DESIGN.md). Technical structure: [ARCHITECTURE.md](ARCHITECTURE.md).

Godot project lives in `memory-game/`.

---

## Progress overview

| Step | Focus | Status |
|------|-------|--------|
| 1 | Grid + selector movement | **Done** |
| 2 | Reveal + two-tile selection | **Done** |
| 3 | Match / mismatch + tile states | **Done** |
| 4 | Combat — HP + enemy timer | Not started |
| 5 | Effects — attack + heal | Not started |
| 6 | Effects — slow, speed, upgrade | Not started |
| 7 | Board refresh when cleared | Not started |
| 8 | Win / lose + battle end | Not started |

---

## Step details

### Step 1 — Grid + selector movement ✅

Build a 4×4 board of placeholder tiles and a selector highlight. WASD moves the selector on a discrete grid with a 0.25s cooldown. Positions are clamped so the selector cannot leave the board.

**Validates:** coordinate system, scene instancing, input, Board ↔ Selector wiring via `Main`.

**Key files:** `Tile.tscn`, `Board.tscn`, `Selector.tscn`, `Main.tscn`, `board.gd`, `selector.gd`, `main.gd`.

---

### Step 2 — Reveal + two-tile selection ✅

Press Space to reveal the tile under the selector. Board tracks selection state (`IDLE` → `ONE_SELECTED` → `RESOLVING`). After the second pick, wait 2 seconds, then conceal both tiles and reset to `IDLE`.

**Validates:** tile `reveal()` / `conceal()`, Board selection FSM, tile lookup by grid position, `await` timer.

**Key files:** `tile.gd`, `board.gd`, Input Map action `reveal`.

**Note:** Step 2 uses a temporary rule (always conceal after 2s). Step 3 replaces this with real match/mismatch behavior.

---

### Step 3 — Match / mismatch + tile states

Assign a **pair id** (effect type) to each tile when the board is dealt. On second reveal, compare ids:

- **Match** → remove both tiles (empty holes); selector can still move through them
- **Mismatch** → grey both tiles, 1s input freeze, 4s cover fade back to concealed

Add tile states `GREYED` and `EMPTY`. Greyed tiles cannot be selected during fade.

**Validates:** tile FSM, tweens, pair assignment/shuffle, real memory-game core loop.

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
