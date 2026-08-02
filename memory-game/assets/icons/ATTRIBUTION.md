# Tile Icons — Attribution

Icons from [game-icons.net](https://game-icons.net/), licensed under **CC BY 3.0**.

White-on-transparent **SVG** files (best for overlaying on colored tile backgrounds).

| File | Icon | Author | Page |
|------|------|--------|------|
| `attack.svg` | Crossed swords | Lorc | https://game-icons.net/1x1/lorc/crossed-swords.html |
| `heal.svg` | Health increase | sbed | https://game-icons.net/1x1/sbed/health-increase.html |
| `slow.svg` | Snail | Lorc | https://game-icons.net/1x1/lorc/snail.html |
| `speed.svg` | Wingfoot | Lorc | https://game-icons.net/1x1/lorc/wingfoot.html |
| `upgrade.svg` | Upgrade | Delapouite | https://game-icons.net/1x1/delapouite/upgrade.html |

**Credit (required by license):**  
Icons made by Lorc, sbed, and Delapouite. Available on https://game-icons.net

## Design decision (MVP)

- **Same icon per effect type** — all Attack pairs share `attack.svg`, both Heals share `heal.svg`, etc.
- **Unique background color per `pair_id` (0–7)** — memory challenge stays about matching tint + location; icon tells you the effect when revealed.
