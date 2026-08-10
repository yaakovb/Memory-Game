# Game Design Document — MVP 2

## Working Title
Memory Arena

**Previous version:** [archive/MVP_1/](archive/MVP_1/) (4×4 unique pairs, one enemy).

---

## High Concept

Memory Arena is a fast-paced real-time PvE game where the player fights **one or more enemies** by revealing tiles on a hidden board.

Tiles have two layers:
- **Icon (symbol)** — what the card *does* (attack, heal, slow, …)
- **Color (affiliation)** — which group the tile belongs to (4 colors)

The game never pauses. While the player searches, every living enemy runs its own attack timer.

**Core tensions:**
- Finish known pairs vs explore
- True pairs (icon + color) vs color-only matches that feed a **bonus attack** but punish with longer lockout and faster enemies
- Which threat to answer first when multiple enemies tick independently (targeting comes in a later milestone)

Run / map progression (toy-land playmat, shops, loadout) is specified in **[GAME_PROGRESSION_ELEMENTS_DESIGN.md](GAME_PROGRESSION_ELEMENTS_DESIGN.md)**. This file is the **battle rules** doc.

---

## Controls

Keyboard only (MVP 2).

| Input | Action |
|-------|--------|
| W / A / S / D | Move selector (discrete grid steps) |
| Space | Reveal / select tile under cursor |
| R | Restart battle / run stub (as implemented) |

### Movement
- Base move cooldown: **0.25 s** (tunable)
- **Speed** buff reduces cooldown (floor applies)

---

## Board

| Property | MVP 2 |
|----------|-------|
| Size | **6×6** (36 cells) |
| Pairs | **18** |
| Colors | **4** affiliations |
| Duplicates | Allowed — more than one pair may share the same `(icon, color)` |

Empty holes remain after matches; the selector may move through them.

### Tile identity

| Field | Player-facing meaning | Used for |
|-------|----------------------|----------|
| `effect_id` / icon | What the pair does | Effect on **true pair** |
| `color_id` | Affiliation | Matching + color-match mana |
| Internal instance id (optional) | Debugging / bookkeeping | Not required for `is_match` |

**Match test (true pair):** same icon **and** same color.

Pair composition is **tunable config** in `Board.STARTING_PAIRS`. First locked table (MVP 2 Step 3):

### Starting pair composition (18 pairs)

| Effect | Count | Colors |
|--------|------:|--------|
| Attack | 10 | Blue ×3, Purple ×3, Yellow ×2, Orange ×2 |
| Heal | 3 | Blue, Purple, Orange |
| Slow | 2 | Blue, Yellow |
| Speed (haste) | 2 | Blue, Purple |
| Upgrade | 1 | Orange |

**Color totals:** Blue 6 · Purple 5 · Orange 4 · Yellow 3.

Duplicates allowed (e.g. three identical Blue Attack pairs). Later MVP may key stronger effects to rarer colors (Yellow scarcest today). Expect reshuffles while playtesting.

---

## Reveal resolution

Player reveals two tiles. Resolve in this order of checks:

| # | Icons | Colors | Outcome | Name |
|---|-------|--------|---------|------|
| 1 | Same | Same | Fire effect, remove both tiles | **True pair** |
| 2 | Different | Same | Fill bonus-attack (mana) bar a little; tiles grey + **long** fade; hurry enemies | **Color match** |
| 3 | Same | Different | No effect, no mana | **Icon-only** (noop reward) |
| 4 | Different | Different | No effect, no mana | **Full miss** |

### Tile behavior after non-pairs (2–4)

- Tiles go **greyed**, cover fades in, then return to **hidden** (same idea as MVP 1 mismatch).
- Before greying, tiles **hold** fully revealed briefly so the second tile’s color/icon is readable (`REVEAL_HOLD_DURATION`).
- Player can keep moving and revealing other tiles (no global input freeze).
- **Color match** uses a **longer** grey/fade duration than icon-only / full miss, so farming mana is costly in time and board lockout.
- Exact durations: see Values table (total lockout = hold + fade).

### Enemy hurry

- **Color match:** accelerate living enemies’ attack timers (placeholder: same spirit as MVP 1’s −0.5 s; may apply per enemy).
- **Icon-only / full miss:** decide in playtest — default proposal: **light or no hurry** so the main anti-farm pressure sits on color matches. Document the chosen numbers in the Values table when locked.

### Icon-only (milestone note)

Same icon + different color currently grants **nothing**. A later milestone may award XP toward action upgrades. Do not implement XP yet.

---

## Bonus attack (mana)

- Color matches add progress to a **mana / energy bar**.
- When the bar reaches full, the **bonus attack autofires** (MVP 2 — keep simple).
- Later milestone: spend mana with a key instead of autofire.
- **Targeting (MVP 2):** hit a **default** target (recommendation: highest threat or first alive — pick one in implementation and document it). Explicit targeting is a later milestone (“assassin” focus, etc.).

Damage and mana-per-color-match are tunable.

---

## Effects (true pairs)

Carry forward MVP 1 effect set unless composition changes:

| Effect | Role |
|--------|------|
| Attack | Damage default (or later: chosen) enemy |
| Heal | Restore player HP |
| Slow | Timed debuff — lengthen enemy attack intervals |
| Speed | Timed buff — shorten selector move cooldown |
| Upgrade | Permanent-for-battle +attack bonus |

Multi-enemy note: **Slow** may apply to all enemies or only the default target — **default proposal: all living enemies** for MVP 2 readability. Revisit when targeting exists.

---

## Combat — multiple enemies

A battle can include **N ≥ 1** enemies. Each enemy has its own:

| Property | Meaning |
|----------|---------|
| Max / current HP | Independent |
| Attack cooldown / timer | Independent |
| Attack damage | Independent |
| Action kit | At minimum: deal damage; later: heal ally, debuff player, etc. |

**Example:** tank (1 damage / 3 s) + assassin (8 damage / 8 s).

### Win / lose

| Outcome | Condition |
|---------|-----------|
| **Win** | All enemies HP ≤ 0 |
| **Lose** | Player HP ≤ 0 |

Defeating an enemy grants **money** (economy used by the run layer — see GAME_PROGRESSION_ELEMENTS_DESIGN.md). MVP 2 may only show money in the HUD / log until the map exists.

### Enemy actions beyond damage (soon after multi-enemy)

Candidates (not all required at once):

- Heal an ally
- Debuff player (slower selector, weaker heals)
- Hurry / scramble pressure beyond the color-match rule

Add one non-damage action only after 2-enemy damage fights feel stable.

---

## Game loop (single battle)

```
1. Start battle — player stats, enemy roster, deal 6×6 board
2. Each living enemy ticks its own timer
3. Player moves, reveals two tiles
4. Resolve: true pair / color match / icon-only / full miss
5. If mana full → autofire bonus attack at default target
6. If board fully cleared → deal a new full board (battle continues)
7. On enemy death → award money; remove that enemy
8. All enemies dead → win
9. Player HP ≤ 0 → lose
```

---

## MVP 2 scope

**In:**
- 6×6, 18 pairs, 4 colors, duplicate `(icon, color)` allowed
- True pair vs color match vs icon-only vs full miss
- Longer lockout on color match; mana bar; autofire bonus attack
- Multiple enemies (start with 2), per-enemy HP/timer/damage
- Money on kill (can be stubbed in UI)
- Board refresh when cleared

**Out (later):**
- Explicit targeting
- Key-activated mana spend
- Icon-only → XP / upgrades
- Map / shops / loadout (GAME_PROGRESSION_ELEMENTS_DESIGN.md)
- Rich enemy AI kits beyond one extra action type
- Sound, full art pass

---

## Values to tune (placeholders)

| Parameter | Placeholder | Notes |
|-----------|-------------|-------|
| Grid | 6×6 / 18 pairs | |
| Colors | 4 | Blue / Yellow / Purple / Orange |
| Color density | 6 / 3 / 5 / 4 | Blue / Yellow / Purple / Orange |
| Starting composition | See table above | `Board.STARTING_PAIRS` |
| Base move cooldown | 0.25 s | |
| Reveal hold (before grey) | 0.35 s | Both tiles stay fully colored |
| Miss / icon-only lockout | **2.0 s** | hold 0.35 + fade 1.65 |
| Color-match lockout | **3.5 s** | hold 0.35 + fade 3.15 |
| Color-match hurry | −0.5 s / enemy | Tune |
| Mana per color match | 25% of bar | 4 color matches → full (tune) |
| Mana max | 100 | Unitless progress |
| Bonus attack damage | = player attack damage | Same as Attack pair for now |
| Player max HP | TBD | Scale vs multi-enemy |
| Enemy definitions | Data-driven | Tank / assassin examples |

---

## Design principles

- Every rule should create a decision or a readable cost
- Prefer a few sharp systems over many weak ones
- Battle doc stays about the fight; run fantasy lives in GAME_PROGRESSION_ELEMENTS_DESIGN.md
- Finish a playable slice before adding map nodes

---

*Battle rules: this file. Run/map: GAME_PROGRESSION_ELEMENTS_DESIGN.md. Technical structure: ARCHITECTURE.md. Build order: WORK_PLAN.md.*
