# Agent Handoff — Memory Arena

Context for the next Cursor agent (or human) continuing this Godot 4 + GDScript project.

**Owner profile:** Experienced C# developer, learning Godot/GDScript. Prefer **teaching and guiding** over dumping large unsolicited code. See `.cursor/rules/godot-mentor.mdc`.

**Godot project root:** `memory-game/` (not the repo root).

**Docs of record:**
- [GAME_DESIGN.md](GAME_DESIGN.md) — rules, numbers, feel
- [ARCHITECTURE.md](ARCHITECTURE.md) — scene tree, signals, ownership
- [WORK_PLAN.md](WORK_PLAN.md) — step checklist (Steps 1–12 **done**)

---

## MVP status: COMPLETE

Playable loop: move selector → reveal pairs → effects → enemy attacks in real time → win/lose overlay → **R** restarts.

| Area | State |
|------|--------|
| 4×4 board, 8 pairs | Done |
| Match / mismatch | Done (no input freeze on mismatch) |
| Combat + buffs | Done |
| Full HUD | Done (`HUD.tscn` + `hud.gd`) |
| Effect icons | Done (shared icon per effect, unique color per pair) |
| Match juice | Done (`play_match_pop`) |
| Reveal punch | **Removed** — player disliked it; keep reveal instant |
| SFX | Skipped intentionally |
| Enemy types / 6×6 | Not started |

---

## How systems connect

```
Main (orchestrator)
├── Board          — grid, selection FSM, match/mismatch
├── Selector       — WASD + speed stacks
├── Combat         — HP, enemy timer, slow, attack bonus
├── EffectResolver — pair_id → effect
└── HUD            — display only (setup + push updates)
```

**Main owns:** signal wiring, battle-end flags on Board/Combat, restart input.  
**HUD owns:** bars, labels, end overlay, `_process` for attack bar + buffs after `setup(combat, selector)`.  
**Do not** put game rules in HUD.

### Important signals

| Signal | From | To |
|--------|------|-----|
| `pair_matched(pair_id)` | Board | EffectResolver.apply |
| `pair_mismatched` | Board | Combat.hurry_next_attack |
| `hp_changed` | Combat | Main → HUD.update_hp |
| `effect_applied(text)` | EffectResolver | Main → HUD.set_last_effect |
| `player_defeated` / `enemy_defeated` | Combat | Main.handle_battle_ended |

---

## Design decisions to respect

1. **Mismatch:** No freeze. Grey + 2.5s cover fade; **−0.5s** on enemy attack timer (`MISMATCH_ATTACK_HURRY`).
2. **Tiles:** Same effect → same icon; each `pair_id` → unique `PAIR_COLORS` background. Icons: `memory-game/assets/icons/` ([game-icons.net](https://game-icons.net/), CC BY 3.0 — credit in `ATTRIBUTION.md`).
3. **`damage_enemy(amount)`** takes an amount; EffectResolver calls `get_player_attack_damage()` then damages. Keep Combat = HP math, EffectResolver = “what effect.”
4. **TextureRect icons:** Expand Mode = **Ignore Size** or they overflow the tile.
5. **Node2D scale** is from top-left; match pop adjusts `position` around center then restores `_grid_position`.
6. **No git remote** was configured last time push was attempted — check `git remote -v` before pushing.

---

## Key files

| Path | Role |
|------|------|
| `memory-game/scripts/main/main.gd` | Wiring only (~60 lines) |
| `memory-game/scripts/board/board.gd` | Grid + selection + match |
| `memory-game/scripts/tile/tile.gd` | Visual states + icons + match pop |
| `memory-game/scripts/combat/combat.gd` | HP / timer / buffs |
| `memory-game/scripts/effects/effect_resolver.gd` | Pair → effect |
| `memory-game/scripts/selector/selector.gd` | Movement + speed |
| `memory-game/scripts/ui/hud.gd` | All HUD display |
| `memory-game/scenes/ui/hud.tscn` | HUD scene |
| `memory-game/scenes/board/Tile.tscn` | Face → Icon → Cover → Outline |

### Input Map (`project.godot`)

`move_*`, `reveal` (Space), `restart` (**R** — must have a key binding; empty events broke restart once).

### Tunables (Combat `@export` / constants)

Often tweaked for balance: `player_max_hp`, `enemy_max_hp`, `enemy_damage`, `enemy_interval`, `MISMATCH_ATTACK_HURRY`, heal/attack amounts in EffectResolver, `MISMATCH_FADE_DURATION` on Tile.

---

## Known gotchas (already hit in this project)

- Call `add_child(tile)` **before** `tile.setup()` so `@onready` exists.
- Don’t name methods `hide()` / params `visible` — shadow `CanvasItem`.
- Set ProgressBar `max_value` **before** `value` on startup.
- Preload textures as `res://…/file.svg`, **not** `.svg.import`.
- `pair_mismatched` → `hurry_next_attack` works with default arg (signal has no payload).

---

## Suggested next work (post-MVP)

Pick with the user; don’t assume:

| Direction | Ideas |
|-----------|--------|
| **Feel** | Mismatch shake; HP bar flash on hit; SFX (Kenney); soft reveal (not punch) |
| **Balance** | Playtest HP/interval/hurry/damage |
| **Content** | Enemy Resource (HP, interval, damage); difficulty tiers |
| **Scale** | Configurable grid (6×6) without hardcoding `GRID_SIZE` everywhere |
| **Structure** | Title/menu scene; `Battle.tscn` if Main grows |
| **Polish** | Better tile back art; unique attack-pair variants if memory feels too easy |

**Explicitly deferred by owner:** SFX (for now), enemy types (when last asked), reveal punch (rolled back).

---

## How to work with this owner

- Prefer **guide → small steps → they implement** unless they ask you to implement.
- Explain Godot concepts the first time (signals, `@onready`, Control vs Node2D, tweens).
- Keep diffs focused; update GAME_DESIGN / ARCHITECTURE / WORK_PLAN when rules or structure change.
- Commit when asked; don’t push without a remote + request.

---

## Quick verify after changes

1. Run main scene from Godot.
2. Reveal → icon + unique color; match → pop + effect text; mismatch → fade + attack bar jumps.
3. Die / win → overlay + **R** reloads.
4. Clear board → new deal, fight continues.

---

*Generated at MVP completion (Steps 1–12). Update this file when major direction changes.*
