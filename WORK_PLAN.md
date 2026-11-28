# Memory Arena — Work Plan

Living checklist. Rules: [GAME_DESIGN.md](GAME_DESIGN.md). Structure: [ARCHITECTURE.md](ARCHITECTURE.md). Run/map: [GAME_PROGRESSION_ELEMENTS_DESIGN.md](GAME_PROGRESSION_ELEMENTS_DESIGN.md).

**Godot project:** `memory-game/`  
**MVP 1 archive:** [archive/MVP_1/](archive/MVP_1/) (Steps 1–12 complete — single enemy, 4×4 unique pairs).

**Last updated:** Balance Tools BT-1/BT-2 landed (Debug Log + Dummy Player). Next: BT-3 batch read, then resume MVP 2 Step 8+.

---

## Milestone order

| Milestone | Focus | Status |
| --------- | ----- | ------ |
| **MVP 1** | Single-enemy 4×4 match battle | **Done** (archived) |
| **Balance Tools** | Debug Log + Dummy Player for data-driven tuning | **In progress** |
| **MVP 2** | 6×6, colors, mana, multi-enemy, money, … | Steps 1–7 **Done**; **8+ paused** until Balance Tools land |
| **Run / playmat** | See Game Progression Elements Design | After battle loop feels good |

---

## Balance Tools (after MVP 1, before MVP 2 Step 8+)

Goal: measure the current fight with logs and a rule-based bot so Step 10 tuning (and any interim nerfs) are driven by data, not vibes.

| Step | Focus | Status |
| ---- | ----- | ------ |
| BT-0 | Docs — insert this milestone; wire into Architecture / Handoff | **Done** |
| BT-1 | **Debug Log** (Autoload) — structured events + battle/session summary | **Done** |
| BT-2 | **Dummy Player** — memory bot via Board APIs; optional batch restart | **Done** |
| BT-3 | Run a short batch; note win rate / death causes; decide next tune | Pending |

### BT-1 — Debug Log

- Autoload `DebugLog` so counters survive `reload_current_scene()` during batch runs.
- Record: true pair / color match / icon-only / miss, damage dealt/taken, heals, bonus attacks, kills, win/lose.
- Print to Godot Output; keep a per-battle dict + session win/loss totals.

**Key files:** `scripts/debug/debug_log.gd`, wiring in `main.gd` / `combat.gd`.

### BT-2 — Dummy Player

- Rule bot with **perfect memory** of revealed tiles: finish known true pairs, else explore.
- Calls `Board.try_reveal_at` (same resolve path as Space) — no fake InputEvents.
- Off by default. Enable: Main inspector `enable_dummy_player`, or ProjectSettings `memory_arena/dummy_player`.
- Auto-restarts until `dummy_max_matches` (default 100).

**Key files:** `scripts/debug/dummy_player.gd`, `Board.try_reveal_at`, `main.gd`.

### BT-3 — First balance read

Play (or batch) and capture: session win %, common loss pattern (e.g. Assassin chip), color-match frequency vs true pairs. Feed Step 10.

---

## MVP 2 progress overview

| Step | Focus                                                    | Status                           |
| ---- | -------------------------------------------------------- | -------------------------------- |
| 0    | Docs (GDD / Architecture / Work plan / Progression)      | **Done**                         |
| 1    | 6×6 grid + selector clamp                                | **Done**                         |
| 2    | Tile `effect_id` + `color_id` visuals (4 colors)         | **Done**                         |
| 3    | Deal 18 pairs with **duplicate** signatures allowed      | **Done**                         |
| 4    | Resolve: true pair / color match / icon-only / full miss | **Done**                         |
| 5    | Color-match longer fade + enemy hurry                    | **Done**                         |
| 6    | Mana bar + autofire bonus attack (default target)        | **Done**                         |
| 7    | CombatDirector + **2 enemies** (own HP/timer/damage)     | **Done**                         |
| 8    | Money on kill (HUD stub)                                 | **Paused** — after Balance Tools |
| 9    | One non-damage enemy action (optional stretch)           | Pending                          |
| 10   | Pair composition tuning pass                             | Pending (uses Balance Tools)     |
| —    | Playmat map stub (see Game Progression Elements Design)  | **After** battle steps feel good |

---

## Step details

### Step 0 — Docs ✅

Root docs describe MVP 2; MVP 1 frozen under `archive/MVP_1/`.

---

### Step 1 — 6×6 grid + selector ✅

Grow board from 4×4 to 6×6. Selector clamps to new bounds. Empty layout playable with placeholder tiles.

**Done:** `GRID_SIZE := 6`; HUD moved clear of board; deal/reveal bandage so ids stay within known icons.

**Key files:** `board.gd`, `Board.tscn`, `selector.gd`, `main.tscn` (camera/HUD layout may need space).

---

### Step 2 — Icon + color on tiles ✅

Each tile stores and shows:

- **Icon** = effect (reuse MVP 1 SVGs)
- **Color** = affiliation (4 tint / face colors — distinct from MVP 1’s per-`pair_id` palette)

Hidden face stays neutral.

**Done:** Tile holds `pair_id` + `pair_color_id` + `pair_effect_id`; reveal uses 4 affiliation colors and 5 effect icons; Board temporary `id % 4` / `id % 5` glue; EffectResolver maps `0..4`. Matching still by `pair_id` until Step 4.

**Key files:** `tile.gd`, `Tile.tscn`.

---

### Step 3 — Deal with duplicates ✅

Deal 18 pairs into 36 cells. Allow multiple pairs with the same `(effect_id, color_id)`.

Replace “unique pair_id match” mental model with signature match.

**Done:** `STARTING_PAIRS` composition table (10 Attack / 3 Heal / 2 Slow / 2 Speed / 1 Upgrade; color totals 6B / 5P / 4O / 3Y); deal duplicates each signature then shuffle; true-pair match on effect+color. Full four-way resolve still Step 4.

**Key files:** `board.gd` deal logic. Composition also documented in [GAME_DESIGN.md](GAME_DESIGN.md).

---

### Step 4 — Four-way resolve ✅

| Outcome     | Gameplay                    |
| ----------- | --------------------------- |
| True pair   | Effect + remove             |
| Color match | Mana fill signal; long grey |
| Icon-only   | No reward; short grey       |
| Full miss   | No reward; short grey       |

**Done:** Board classifies by effect/color; true pair pops; all non-pairs grey+fade. `color_matched` → hurry + HUD mana stub. Icon-only / full miss use `_resolve_mismatch` (no hurry). Fade durations still equal — longer color-match fade is Step 5.

**Key files:** `board.gd`, wiring in `main.gd`.

---

### Step 5 — Color-match cost ✅

Longer fade duration than miss/icon-only; hurry living enemy timers on color match.

**Done:** `REVEAL_HOLD_DURATION` (0.35 s) then grey+fade; miss/icon-only total lockout **2.0 s** (fade 1.65); color-match total **3.5 s** (fade 3.15). Hurry already on `color_matched` from Step 4.

**Key files:** `tile.gd`, combat/enemy timers.

---

### Step 6 — Mana + bonus attack ✅

CombatDirector (or evolved Combat) tracks mana; HUD bar; autofire damage at default target when full.

**Done:** Mana on `Combat` (`MANA_MAX` 100, `MANA_PER_COLOR_MATCH` 25); HUD `ManaProgressBar`; color match fills mana + hurry; at full, autofire bonus damage (= player attack) at the single enemy and reset mana. Last-effect shows bonus when it fires (set color-match text before `add_mana`).

**Key files:** combat scripts, `hud.gd`, `HUD.tscn`.

---

### Step 7 — Two enemies ✅

Split single-enemy Combat into roster. Example: tank + assassin with different interval/damage. Win = all dead. Slow policy: all living (per GDD).

**Done:** `Enemy` RefCounted; `Combat` roster (tank + assassin placeholders; assassin dmg 4); default target = first living; `all_enemies_defeated` for win; `enemy_defeated(enemy)` for per-kill hooks. HUD `EnemyList` + `EnemyHudRow` spawned from `enemies` array (N enemies / duplicate types OK). Merged via PR #1.

**Key files:** `enemy.gd`, `combat.gd`, `enemy_hud_row.*`, `hud.gd` / `hud.tscn`.

---

### Step 8 — Money stub *(paused — after Balance Tools)*

On `enemy_defeated`, add money; show on HUD. No shop yet.

---

### Step 9 — Stretch: non-damage action

One enemy heals ally or debuffs selector speed. Only after Step 7 is fun.

---

### Step 10 — Tuning

Lock first pair composition table and placeholder numbers in GDD Values. **Use Balance Tools (Debug Log + Dummy batches) as the measurement loop.**

---

## After battle MVP 2

Follow [GAME_PROGRESSION_ELEMENTS_DESIGN.md](GAME_PROGRESSION_ELEMENTS_DESIGN.md):

1. `BattleConfig` in / out  
2. Small always-visible playmat stub (battle / shop / rest)  
3. Equipment + pair pool  
4. Explicit forget visual on spots (deeper memory-map rules later)  

---

## Definition of done (battle MVP 2)

- [x] 6×6 playable with 18 pairs and 4 colors  
- [x] Duplicates can true-pair  
- [x] Color match fills mana and hurts (long lockout + hurry)  
- [x] Bonus attack autofires  
- [x] At least two simultaneous enemies with distinct timings  
- [x] Win/lose + restart still work  
- [ ] Money visible after a kill  
- [ ] Balance Tools available (Debug Log + Dummy Player) for Step 10  

---

*Update status as steps complete. Prefer small playable PR-sized slices.*
