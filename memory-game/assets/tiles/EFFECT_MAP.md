# Tile filenames ↔ game effects

| Filename stem | `pair_effect_id` | Effect |
|---------------|------------------|--------|
| `sword` | 0 | Attack |
| `medicine` | 1 | Heal |
| `slow` | 2 | Slow (snail) |
| `haste` | 3 | Speed (winged shoe) |
| `hammer` | 4 | Upgrade |

Lookup pattern: `res://assets/tiles/{blue,yellow,purple,orange}-{stem}.png`

Each affiliation uses a **unique drawing** of that effect, not a recolor.