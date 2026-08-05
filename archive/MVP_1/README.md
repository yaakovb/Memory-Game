# MVP 1 archive

Frozen docs for the **first playable single-battle loop** (Steps 1–12). Do not edit these as living design — they are historical reference.

## What MVP 1 was

- 4×4 board, **8 pairs** (`pair_id` 0–7)
- Match by **`pair_id` only** (one true pair per id)
- Shared **effect icons** (e.g. all attacks use the same swords); unique **background color** per pair
- One enemy, real-time attack timer
- Effects: attack, heal, slow, speed, upgrade
- Mismatch: no freeze; 2.5s fade; −0.5s enemy attack hurry
- Juice: match pop only (reveal punch was rejected)

## Files in this folder

| File | Role at end of MVP 1 |
|------|----------------------|
| `GAME_DESIGN.md` | Battle rules / numbers |
| `ARCHITECTURE.md` | Scene tree, signals, ownership |
| `WORK_PLAN.md` | Steps 1–12 checklist (complete) |
| `AGENT_HANDOFF.md` | Handoff written when MVP 1 shipped |

## Active docs (MVP 2 — repo root)

| File | Role |
|------|------|
| [`GAME_DESIGN.md`](../../GAME_DESIGN.md) | **Battle** rules for MVP 2 (6×6, color+icon, multi-enemy, …) |
| [`ARCHITECTURE.md`](../../ARCHITECTURE.md) | Technical structure for MVP 2 |
| [`WORK_PLAN.md`](../../WORK_PLAN.md) | Implementation checklist for MVP 2 |
| [`GAME_PROGRESSION_ELEMENTS_DESIGN.md`](../../GAME_PROGRESSION_ELEMENTS_DESIGN.md) | **Run / map** design (toy-land playmat, shops, loadout) — **not implemented yet** |
| [`AGENT_HANDOFF.md`](../../AGENT_HANDOFF.md) | May still describe MVP 1 until updated for MVP 2 |

Godot project remains: `memory-game/`.
