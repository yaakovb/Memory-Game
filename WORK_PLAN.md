# Memory Arena — Work Plan

Living checklist for MVP implementation. Gameplay rules: [GAME_DESIGN.md](GAME_DESIGN.md). Technical structure: [ARCHITECTURE.md](ARCHITECTURE.md).

Godot project lives in `memory-game/`.

**Last updated:** Step 10 complete — HUD extracted to `HUD.tscn` + `hud.gd`.

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
| 8 | Win / lose + battle end | **Done** |
| 9 | Richer HUD | **Done** |
| 10 | Extract HUD to own scene | **Done** |

---

## What's implemented (summary)

| System | Done |
|--------|------|
| Scenes | `Main`, `Board`, `Selector`, `Tile`, `Combat`, `HUD` (`HUD.tscn`), `EffectResolver` |
| Movement | WASD, base 0.25s cooldown, grid clamping, speed stacks |
| Input | `move_*` actions, `reveal` (Space), `restart` (R) |
| Board | 4×4 spawn, shuffled pair ids (0–7), `pair_matched` / `pair_mismatched` signals |
| Selection FSM | `IDLE` → `ONE_SELECTED` → resolve |
| Match | Same `pair_id` → `make_empty()` + emit |
| Mismatch | Grey face, 4s cover fade → `conceal()`; **−0.5s to enemy attack timer**; **no input freeze** |
| Tile states | `HIDDEN`, `REVEALED`, `GREYED`, `EMPTY` |
| Pair ids | 0–2 Attack, 3–4 Heal, 5 Slow, 6 Speed, 7 Upgrade |
| Combat | HP, enemy timer, heal/damage, slow stacks, attack bonus |
| HUD | HP labels + bars, enemy attack bar, buff row, last effect, end overlay + restart hint |
| Effects | Full pair table via EffectResolver; `effect_applied` signal |
| Board refresh | Clear all pairs → new shuffled board (`board_cleared` / `board_dealt`) |
| Battle end | `player_defeated` / `enemy_defeated` → stop input + combat; R reloads scene |

---

## Effect reference (current numbers)

| pair_id | Effect | Implementation |
|---------|--------|----------------|
| 0–2 | Attack | `damage_enemy()` → `3 + attack_bonus` |
| 3–4 | Heal | `heal_player(4)` |
| 5 | Slow | Combat: stacks 1–3, +25% enemy interval each, 10s refresh |
| 6 | Speed | Selector: stacks 1–3, −0.05s cooldown each (min 0.1), 10s refresh |
| 7 | Upgrade | Combat: `attack_bonus += 1` for rest of battle |

---

## Step details

### Step 1 — Grid + selector movement ✅

Build a 4×4 board of placeholder tiles and a selector highlight. WASD moves the selector on a discrete grid with a 0.25s cooldown. Positions are clamped so the selector cannot leave the board.

**Key files:** `Tile.tscn`, `Board.tscn`, `Selector.tscn`, `Main.tscn`, `board.gd`, `selector.gd`, `main.gd`.

---

### Step 2 — Reveal + two-tile selection ✅

Press Space to reveal the tile under the selector. Board tracks selection state (`IDLE` → `ONE_SELECTED`).

**Key files:** `tile.gd`, `board.gd`, Input Map action `reveal`.

---

### Step 3 — Match / mismatch + tile states ✅

- **Match** → empty holes + `pair_matched`
- **Mismatch** → grey, 4s fade, attack hurry; emits `pair_mismatched`; player keeps moving

**Key files:** `tile.gd`, `Tile.tscn`, `board.gd`, `selector.gd`.

---

### Step 4 — Combat — HP + enemy timer ✅

**Key files:** `combat.gd`, `Main.tscn`, `main.gd`.

---

### Step 5 — Effects — attack + heal ✅

**Key files:** `board.gd`, `effect_resolver.gd`, `main.gd`.

---

### Step 6 — Effects — slow, speed, upgrade ✅

**Key files:** `effect_resolver.gd`, `combat.gd`, `selector.gd`, `main.gd`.

---

### Step 7 — Board refresh when cleared ✅

**Key files:** `board.gd` (`board_cleared`, `board_dealt`, `_deal_new_board`).

---

### Step 8 — Win / lose + battle end ✅

- Defeat signals → `Main.handle_battle_ended()`
- Input + combat stop; dim overlay; **R** reloads scene
- End overlay shows **"Press R to restart"**

**Key files:** `main.gd`, `main.tscn`, `board.gd`, `combat.gd`, `project.godot`.

---

### Step 9 — Richer HUD ✅

**Implemented:**

| UI piece | Data source | Notes |
|----------|-------------|-------|
| HP bars | `Combat` HP + max HP | `ProgressBar`; max set before value in `_ready` |
| Enemy attack bar | `Combat.get_attack_progress()` | Fills over interval; orange fill; updates in `_process` |
| Buff row | Slow / speed stacks, attack damage | `HBoxContainer`; getters on Combat + Selector |
| Last effect | `EffectResolver.effect_applied` | Label updates on match |

Main wires signals; **`hud.gd`** owns display logic and `_process` for attack bar + buffs. Panel to the right of the board (~x=300).

**Key files:** `scenes/ui/HUD.tscn`, `scripts/ui/hud.gd`, `main.gd`.

---

## Post-MVP gameplay tweak ✅

**Mismatch attack hurry:** On wrong pair, `Board` emits `pair_mismatched` → `Combat.hurry_next_attack(0.5)` advances the enemy attack timer by 0.5 s (visible on the attack bar). No direct HP loss.

**Key files:** `board.gd`, `combat.gd`, `main.gd`, [GAME_DESIGN.md](GAME_DESIGN.md).

---

## Step 10 — Extract HUD to own scene ✅

**Decision:** Push updates from Main for signal-driven UI (HP, last effect, battle end). HUD owns `_process` for attack bar + buff row after `setup(combat, selector)`.

See [ARCHITECTURE.md](ARCHITECTURE.md) — **HUD extraction** for full API and phase list.

| Phase | Task | Status |
|-------|------|--------|
| 1 | Create `HUD.tscn`, move nodes from Main, instance in Main | Done |
| 2 | Add `hud.gd`, move display logic from `main.gd` | Done |
| 3 | Slim `main.gd` to wiring only | Done |

**Key files:** `scenes/ui/HUD.tscn`, `scripts/ui/hud.gd`, `scenes/main/main.tscn`, `scripts/main/main.gd`.

---

## After MVP

- 6×6 board scaling
- Art, animation, audio
- Progression, save system
- More enemy types, endless mode, multiplayer (see GDD future features)

---

*Update the status column as steps are completed.*
