# Agent Handoff — Memory Arena (Balance Tools → MVP 2)

Context for the next Cursor agent (or human). Mentor mode: teach and guide; do not dump large unsolicited rewrites. See `.cursor/rules/godot-mentor.mdc`.

**Godot project root:** `memory-game/`

**Active docs:**
- [GAME_DESIGN.md](GAME_DESIGN.md) — battle rules (6×6, icon+color, mana, multi-enemy)
- [ARCHITECTURE.md](ARCHITECTURE.md) — scenes, signals, ownership + **Balance tools (planned)**
- [WORK_PLAN.md](WORK_PLAN.md) — MVP 2 steps + **Balance Tools milestone (docs only)**
- [GAME_PROGRESSION_ELEMENTS_DESIGN.md](GAME_PROGRESSION_ELEMENTS_DESIGN.md) — toy-land playmat run + explicit forget (design only until battles are fun)

**Frozen MVP 1 docs:** [archive/MVP_1/](archive/MVP_1/)

---

## Current code reality

**Milestone order:** MVP 1 (done) → **Balance Tools (planned next)** → resume MVP 2 Step 8+.

MVP 2 **Steps 1–7 done** (PR #1 merged):

- 6×6; `STARTING_PAIRS`; four-way resolve; color-match lockouts; mana + autofire bonus
- `Enemy` roster on `Combat`; HUD rows spawned from `enemies` array
- Win on `all_enemies_defeated`; per-kill `enemy_defeated(enemy)` exists but unused
- Balance still rough (enemies can overwhelm); tune with Balance Tools → Step 10
- **No money yet** (Step 8 paused)

**Balance Tools:** documented only (BT-0). **No DebugLog / DummyPlayer code in the tree.** An earlier implementation PR was reverted on purpose — implement when the owner starts this milestone.

**Next:** Implement BT-1 (Debug Log) then BT-2 (Dummy Player) per Work Plan / Architecture; then BT-3 batch read. Open PR #4 (gold / specials) can wait or rebase after Balance Tools if still needed.

GitHub: `https://github.com/yaakovb/Memory-Game` (`origin` / `main`).

---

## Locked design decisions (do not quietly reverse)

1. **True pair** = same icon + same color → effect + remove.  
2. **Color match** = same color, different icons → mana up; **longer** grey/fade; hurry enemies.  
3. **Same icon, different color** = no reward for now (possible XP later).  
4. **Bonus attack** autofires when mana full; key-spend later.  
5. **No targeting yet** — default target = first living enemy.  
6. **Duplicates allowed** on `(icon, color)`.  
7. Map = toy-land **playmat** (always visible, no line-graph) + explicit forget; simple shop/fight economy — after fight loop is good. Deeper map-memory rules later.  
8. **Starting composition** locked in GDD / `Board.STARTING_PAIRS` (color totals 6 Blue / 5 Purple / 4 Orange / 3 Yellow). Later MVP may key better effects to rarer colors.  
9. **Non-pair lockout totals:** miss/icon-only 2.0 s; color-match 3.5 s (includes 0.35 s reveal hold).  
10. **Mana:** 100 max, +25 per color match; bonus damage = player attack damage; reset to 0 on fire.  
11. **Roster:** HUD is data-driven from `Combat.enemies` — change the list only to try 2 tanks / 3 enemies.  
12. **Balance Tools** sit after MVP 1 and before MVP 2 money/content — measure before adding systems.

---

## Suggested next implementation slice

Start **Balance Tools BT-1** when asked: Autoload `DebugLog`, wire Board/Combat/Main events, print battle + session summaries. Then BT-2 DummyPlayer via `Board.try_reveal_at`. Do not dump large unrelated rewrites.

---

## Key files

| Path | Role |
|------|------|
| `scripts/main/main.gd` | Wiring |
| `scripts/board/board.gd` | Grid + selection + four-way resolve + deal |
| `scripts/tile/tile.gd` | Visual states, hold + fade durations |
| `scripts/combat/combat.gd` | Player + enemy roster + mana |
| `scripts/combat/enemy.gd` | Per-enemy HP/timer/damage |
| `scripts/effects/effect_resolver.gd` | effect_id `0..4` → effect |
| `scripts/ui/hud.gd` | Display; dynamic enemy rows |
| `scripts/ui/enemy_hud_row.gd` | One enemy HUD row |
| `scripts/debug/*` | **Planned** — DebugLog + DummyPlayer (not present yet) |

---

*Update this handoff when a milestone lands or a decision changes.*
