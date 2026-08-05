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

MVP 2 **Steps 1–2 done** in scripts:

- 6×6 grid; HUD offset clear of board
- Tile stores `pair_id`, `pair_color_id`, `pair_effect_id` (5 icons, 4 affiliation colors on reveal)
- Board still deals unique `pair_id` 0..17 with temporary `color = id % 4`, `effect = id % 5`
- Match still by `pair_id`; EffectResolver takes effect id `0..4`
- Single `Combat` enemy (unchanged)

**Next:** Step 3 — deal 18 pairs with duplicate `(effect, color)` signatures allowed.

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

---

## Suggested next implementation slice

Work Plan **Step 3**: replace unique-`pair_id` deal with explicit `(effect_id, color_id)` pair list (duplicates OK). Matching can stay on `pair_id` *or* move to signature equality — prefer signature so Step 4’s true-pair check is natural. Keep mentor pace.

---

## Key files

| Path | Role |
|------|------|
| `scripts/main/main.gd` | Wiring |
| `scripts/board/board.gd` | Grid + selection + match + deal |
| `scripts/tile/tile.gd` | Visual states, color + effect |
| `scripts/combat/combat.gd` | Single-enemy HP/timer |
| `scripts/effects/effect_resolver.gd` | effect_id `0..4` → effect |
| `scripts/ui/hud.gd` | Display |

---

*Update this handoff when a milestone lands or a decision changes.*
