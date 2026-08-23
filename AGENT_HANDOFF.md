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

MVP 2 **Steps 1–6 done** in scripts:

- 6×6; `STARTING_PAIRS`; four-way resolve; color-match lockouts 2.0 s / 3.5 s
- Mana on `Combat` (25 per color match → 100); HUD mana bar; autofire bonus attack at single enemy
- Still **one** enemy in `Combat` (HP/timer/damage/slow) — not a roster yet

**Next:** Step 7 — evolve toward CombatDirector + 2 enemies (tank + assassin style).

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
9. **Non-pair lockout totals:** miss/icon-only 2.0 s; color-match 3.5 s (includes 0.35 s reveal hold).  
10. **Mana:** 100 max, +25 per color match; bonus damage = player attack damage; reset to 0 on fire.

---

## Suggested next implementation slice

Work Plan **Step 7**: introduce an `Enemy` data object (hp, interval, damage, timer); `Combat` becomes a small director over a list; win when all dead; slow/hurry all living; default target = first living. HUD: two enemy HP/timer rows. Keep mentor pace — design first, then extract without rewriting Board.

---

## Key files

| Path | Role |
|------|------|
| `scripts/main/main.gd` | Wiring |
| `scripts/board/board.gd` | Grid + selection + four-way resolve + deal |
| `scripts/tile/tile.gd` | Visual states, hold + fade durations |
| `scripts/combat/combat.gd` | Player + single enemy + mana (→ director) |
| `scripts/effects/effect_resolver.gd` | effect_id `0..4` → effect |
| `scripts/ui/hud.gd` | Display |

---

*Update this handoff when a milestone lands or a decision changes.*
