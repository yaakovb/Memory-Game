# Game Design Document

## Working Title
Memory Arena

---

## High Concept

Memory Arena is a fast-paced real-time PvE game where the player fights enemies by discovering matching pairs on a hidden board.

The game combines:
- Memory
- Fast decision making
- Keyboard movement
- Combat

The goal is to create a game that is easy to learn, difficult to master, and satisfying to replay.

**Core tension:** The game never pauses. While the player searches for matches, enemies continue attacking. The player must balance remembering tile locations, moving efficiently, reacting to enemy attacks, and choosing which matches to pursue.

---

## Player Goals

The player should constantly be making decisions:

- Do I finish a pair I already know?
- Do I search for a stronger effect?
- Do I heal now or risk taking more damage?
- Is it worth crossing the board for a powerful match?
- Do I match slow/speed now before the buff wears off?

Memory should be important but should not be the only skill.

---

## Controls

Keyboard only. Mouse support is not required.

| Input | Action |
|-------|--------|
| W / A / S / D | Move selector on grid (discrete steps) |
| Space | Reveal / select tile under cursor |

### Movement
- Base rate: **one step every 0.25 seconds** (move cooldown)
- **Speed buff** reduces move cooldown (see Effects)
- Movement is discrete grid-based, not smooth physics

---

## Board

### Grid (MVP)
| Property | Value |
|----------|-------|
| Size | **4×4** (16 cells) |
| Pairs | **8** (board starts full) |
| Future target | 6×6 |

### Pair distribution (8 pairs)

| Effect | Pairs | On match |
|--------|------:|----------|
| Attack | 3 | Damage enemy |
| Heal | 2 | Restore player HP |
| Slow enemy | 1 | Timed debuff on enemy attack rate |
| Speed selector | 1 | Timed buff on move cooldown |
| Upgrade attack | 1 | +1 attack damage for rest of battle |

Pair types are **shuffled** each time a board is dealt.

**Visuals (current):**
- Each **pair id** has a unique background color (`PAIR_COLORS`)
- Each **effect type** shares one icon (Attack / Heal / Slow / Speed / Upgrade) from `assets/icons/` ([game-icons.net](https://game-icons.net/), CC BY 3.0)
- Hidden tiles show a neutral grey face with no icon

---

## Tile Lifecycle

### Hidden (face-down)
- Default state
- Selectable with Space

### Revealed (selection)
- Player selects a first tile, then a second
- Both tiles remain visible while match/mismatch is resolved

### Matched
- Both tiles are **removed**, leaving **empty holes**
- Empty cells remain on the grid; the **selector can move through them**
- The pair's effect fires immediately

### Mismatched
1. Both tiles stay **face up** and enter a **greyed-out** state
2. Over **2.5 seconds**, a **cover fades in** until icons are fully hidden (face-down again)
3. Fade starts **immediately** at mismatch
4. **Greyed tiles cannot be selected** during the fade
5. **Player can keep moving and revealing** other tiles — no input freeze
6. **Enemy attack pressure:** time until the next enemy attack is reduced by **0.5 s** (attack bar jumps forward; no direct HP loss)

### Stacking mismatches
- Each mismatched pair fades **independently**
- Recommended cap: **2 active greyed pairs** (4 tiles) to avoid visual clutter

---

## Board Refresh

There is **no** mid-battle partial refill (e.g. returning pairs every N clears).

When **all pairs on the current board are cleared** (board is empty — all holes):
- **Deal a new full board** (same 8-pair composition, new shuffle)
- Battle continues until win or lose
- The enemy may still be alive when a new board is dealt

---

## Combat

### Win / Lose

| Outcome | Condition |
|---------|-----------|
| **Win** | Enemy HP ≤ 0 |
| **Lose** | Player HP ≤ 0 |

Clearing the board does **not** end the battle by itself. The player may clear multiple boards in a single fight.

### Enemy
- Attacks on a **timer** (exact interval and damage — tune in play)
- **Slow** stacks increase the interval between attacks

### Player
- Has HP; **heal** pairs restore HP
- **Attack** pairs damage the enemy; damage is modified by **upgrade attack**

---

## Effects

### Attack (3 pairs)
- Deals base damage to the enemy
- Damage value is tunable (config)

### Heal (2 pairs)
- Restores player HP
- Heal value is tunable (config)

### Upgrade attack (1 pair)
- **+1 damage to all future attacks for the rest of the battle**
- One pair on the board → typically one upgrade per board cycle

### Slow enemy (1 pair)
- **Timed debuff: 10 seconds per match**
- **Stacks up to 3 times**
- Each stack **increases enemy attack interval** (slower attacks)
- Exact % per stack — tune in play (e.g. +25% interval per stack)
- **MVP timer rule:** one timer; re-applying refreshes duration to 10s and adds a stack (up to max)

### Speed selector (1 pair)
- **Timed buff: 10 seconds per match**
- **Stacks up to 3 times**
- Each stack **reduces move cooldown** (faster steps)
- Minimum move cooldown cap — tune in play so movement stays readable
- **MVP timer rule:** one timer; re-applying refreshes duration to 10s and adds a stack (up to max)

---

## Input & Player States

| State | Move | Reveal (Space) |
|-------|------|----------------|
| Normal | Yes (when move cooldown ready) | Yes |
| Battle ended | No | No |

---

## Game Loop (Single Battle)

```
1. Start battle — player HP, enemy HP, first board dealt
2. Enemy attack timer runs (always)
3. Player moves selector, reveals two tiles
4. Match → effect applied, tiles removed (empty holes)
5. Mismatch → grey/fade over 2.5s + enemy attack hurry (0.5s) → face-down again; play continues
6. If board fully cleared → deal new board (return to step 3)
7. If enemy HP = 0 → win
8. If player HP = 0 → lose
```

---

## MVP Scope

The first playable version includes:

- One player
- One enemy
- 4×4 board, 8 pairs (composition above)
- Cursor movement with cooldown
- Tile reveal and matching logic
- Mismatch grey/fade behavior and enemy attack hurry (no input freeze)
- Empty holes; selector moves through them
- New board when current board is fully cleared
- Health system
- All five effect types (attack, heal, slow, speed, upgrade)
- Win/lose conditions

**Excluded from MVP:**
- Animations (beyond basic tile fade/cover)
- Sound
- Progression
- Save system
- 6×6 board
- Mid-battle partial refill
- Additional effect types (return pairs, reduce freeze, etc.)

---

## Future Features

Possible additions (out of scope for MVP):

- 6×6 board and larger pair pools
- More enemy types and boss fights
- Multiple board layouts
- Additional status effects and items
- Passive abilities and character classes
- Steam achievements
- Endless mode
- Local and online multiplayer

---

## Design Principles

Every mechanic should satisfy at least one of these goals:

- Increase interesting decisions
- Reward player skill
- Be easy to understand
- Create memorable moments
- Encourage replayability

If a feature does not improve the game, it should be removed.

---

## Technical Philosophy

- Gameplay comes before presentation
- Develop in small, testable increments
- Every new mechanic should be playable before moving to the next
- Code should remain simple, modular, and maintainable
- Prefer composition over inheritance
- Avoid overengineering
- Finish features before adding new ones

---

## Values To Tune (Config)

These are placeholders — adjust during playtesting without restructuring systems.

| Parameter | Current MVP value | Notes |
|-----------|-------------------|-------|
| Base attack damage | `3` | EffectResolver `ATTACK_DAMAGE` |
| Attack bonus per upgrade | `+1` | Combat `attack_bonus` |
| Heal amount | `4` | EffectResolver `HEAL_AMOUNT` |
| Player max HP | `20` | Combat export |
| Enemy max HP | `30` | Combat export |
| Enemy hit damage | `2` | Combat export |
| Enemy attack interval | `4.0` s | Baseline before slow |
| Slow % per stack | `+25%` interval | Max 3 stacks |
| Speed reduction per stack | `−0.05` s | Max 3 stacks |
| Minimum move cooldown | `0.1` s | Floor for speed stacks |
| Base move cooldown | `0.25` s | Selector |
| Mismatch fade duration | `2.5` s | Cover tween |
| Mismatch attack hurry | `0.5` s | Subtract from time until next enemy attack |
| Buff duration | `10` s | Slow / speed refresh on reapply |

---

## Architecture

Scene tree, state machines, signals, and implementation order are documented in **[ARCHITECTURE.md](ARCHITECTURE.md)**.

---

*Gameplay rules: this file. Technical structure: ARCHITECTURE.md.*
