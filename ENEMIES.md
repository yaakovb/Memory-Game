# Enemies

A battle shuffles **Tank**, **Cleric**, and **Assassin** and keeps **two**. The same profile does not appear twice.

Numbers live in `memory-game/scripts/combat/combat.gd`. A player hit is 3 damage before Upgrade. Killing an enemy grants 10 gold.

A special replaces the normal swing. It does not deal damage. Its cooldown is its own timer, rolled as **3, 4, or 5** times that enemy's attack interval, then rolled again.

| Name | Health | Attack | Special |
|---|---:|---|---|
| Tank | 16 | 1 damage every 5s | Armor for 6s. Incoming damage is halved, and at least 1 still gets through. |
| Cleric | 10 | 1 damage every 6.5s | Heals the most wounded living ally for 3, including itself. |
| Assassin | 8 | 1 damage every 2.5s | None. |

Player slow stretches both the attack timer and the special timer. A color-match hurry pushes both timers forward.
