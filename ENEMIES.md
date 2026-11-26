# Enemies

A battle shuffles **Tank**, **Cleric**, and **Assassin** and keeps **two**. The same profile does not appear twice.

Numbers live in `memory-game/scripts/combat/combat.gd`. A player hit is 3 damage before Upgrade. Killing an enemy grants 10 gold.

After a fixed number of normal attacks, that enemy's special timer starts at empty. It fills like an attack bar, using the same interval as that enemy's swing. The special fires when the bar fills. It does not also make a normal attack.

| Name | Health | Attack | Special |
|---|---:|---|---|
| Tank | 16 | 1 damage every 5s | Armor for 6s, frequency 4. Incoming damage is halved, and at least 1 still gets through. |
| Cleric | 10 | 1 damage every 5.5s | Heals the most wounded living ally for 3, frequency 3. |
| Assassin | 8 | 1 damage every 4s | A strike for 4 damage, frequency 5. |

While the special bar is filling, the HUD label reads **Special**. Player slow stretches the active timer. A color-match hurry pushes that same timer forward.
