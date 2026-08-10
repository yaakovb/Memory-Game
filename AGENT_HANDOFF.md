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

MVP 2 **Steps 1–5 done** in scripts:

- 6×6; `STARTING_PAIRS`; four-way resolve; color match → hurry + HUD stub
- Tile lockout: hold 0.35 s then fade — miss/icon-only **2.0 s** total, color-match **3.5 s** total
- No real mana bar / bonus attack autofire yet
- Single `Combat` enemy

**Next:** Step 6 — mana on `Combat`, HUD bar, autofire bonus attack at default (only) enemy when full.

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

---

## Suggested next implementation slice

Work Plan **Step 6**: add mana 0..max on `Combat`; `add_mana` from `color_matched`; ProgressBar on HUD; when full, autofire bonus damage at enemy and reset mana. Keep mentor pace — propose placeholder numbers (e.g. 25% per color match, bonus damage = player attack or fixed).

---

## Key files

| Path | Role |
|------|------|
| `scripts/main/main.gd` | Wiring |
| `scripts/board/board.gd` | Grid + selection + four-way resolve + deal |
| `scripts/tile/tile.gd` | Visual states, hold + fade durations |
| `scripts/combat/combat.gd` | Single-enemy HP/timer (+ mana next) |
| `scripts/effects/effect_resolver.gd` | effect_id `0..4` → effect |
| `scripts/ui/hud.gd` | Display |

---

*Update this handoff when a milestone lands or a decision changes.*
