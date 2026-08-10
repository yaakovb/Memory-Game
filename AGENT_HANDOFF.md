# Agent Handoff — Memory Arena (MVP 2)

Context for the next Cursor agent (or human). Mentor mode: teach and guide; do not dump large unsolicited rewrites. See `.cursor/rules/godot-mentor.mdc`.

**Godot project root:** `memory-game/`

**Active docs:**
- [GAME_DESIGN.md](GAME_DESIGN.md) — battle rules (6×6, icon+color, mana, multi-enemy)
- [ARCHITECTURE.md](ARCHITECTURE.md) — scenes, signals, ownership
- [WORK_PLAN.md](WORK_PLAN.md) — MVP 2 steps
- [GAME_PROGRESSION_ELEMENTS_DESIGN.md](GAME_PROGRESSION_ELEMENTS_DESIGN.md) — toy-land playmat run + explicit forget (design only until battles are fun)

**Frozen MVP 1 docs:** [archive/MVP_1/](archive/MVP_1/)

---

## Current code reality

MVP 2 **Steps 1–4 done** in scripts:

- 6×6; `STARTING_PAIRS` deal; match on effect+color
- Four-way classify in `Board._resolve_pair`: true pair pops; color match emits `color_matched` + grey; icon-only / full miss grey via `_resolve_mismatch`
- Main: `color_matched` → hurry + HUD “mana stub”; `pair_mismatched` not wired to hurry
- Fade duration still the same for all non-pairs (`Tile.MISMATCH_FADE_DURATION`)
- Single `Combat` enemy; no real mana bar yet

**Next:** Step 5 — longer grey/fade on color match only (hurry already on color match).

GitHub: `https://github.com/yaakovb/Memory-Game` (`origin` / `main`).

---

## Locked design decisions (do not quietly reverse)

1. **True pair** = same icon + same color → effect + remove.  
2. **Color match** = same color, different icons → mana up; **longer** grey/fade; hurry enemies.  
3. **Same icon, different color** = no reward for now (possible XP later).  
4. **Bonus attack** autofires when mana full; key-spend later.  
5. **No targeting yet** — default target policy.  
6. **Duplicates allowed** on `(icon, color)`.  
7. Map = toy-land **playmat** (always visible, no line-graph) + explicit forget; simple shop/fight economy — after fight loop is good. Deeper map-memory rules later.  
8. **Starting composition** locked in GDD / `Board.STARTING_PAIRS` (color totals 6 Blue / 5 Purple / 4 Orange / 3 Yellow). Later MVP may key better effects to rarer colors.

---

## Suggested next implementation slice

Work Plan **Step 5**: `Tile.grey_and_fade(duration)` (or two helpers); Board passes long duration on color match, short on icon-only/full miss. GDD placeholders: ~2.5 s miss, ~4.0 s color match. Keep mentor pace.

---

## Key files

| Path | Role |
|------|------|
| `scripts/main/main.gd` | Wiring |
| `scripts/board/board.gd` | Grid + selection + four-way resolve + deal |
| `scripts/tile/tile.gd` | Visual states, fade durations |
| `scripts/combat/combat.gd` | Single-enemy HP/timer |
| `scripts/effects/effect_resolver.gd` | effect_id `0..4` → effect |
| `scripts/ui/hud.gd` | Display |

---

*Update this handoff when a milestone lands or a decision changes.*
