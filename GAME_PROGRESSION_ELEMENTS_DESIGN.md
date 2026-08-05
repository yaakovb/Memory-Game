# Game Progression Elements Design — Memory Arena

Companion to [GAME_DESIGN.md](GAME_DESIGN.md). Battle rules stay there; **this file** is run progression: toy-land map, rewards, loadout.

**Status:** Design target for the **first map MVP**. Not built until the battle loop (6×6, multi-enemy, mana) feels good. Deeper map-memory systems can wait for later milestones.

---

## Vision (locked for map MVP)

**Theme:** memory and games — a **toy land**; enemies are toys.

**Progression rules:** simple and readable (Slay the Spire–like room rewards: fight → shop → rest → boss), **not** FTL resource management (no fuel, scrap-as-survival, pursuit meters).

**Map presentation:** a **small playmat always visible** on screen — not a tall graph of rooms connected by spiderweb **lines**. Spots sit on a compact board/shelf; movement uses **adjacency** (or light borders), not route-line UI.

**Rhythm (from FTL, lightly):** plan on the map → drop into **real-time** memory combat → return to the playmat.

**Signature twist:** memory **fading is explicit**. Spots don’t vanish for lack of resources; they become clearly **forgotten** (face-down / erased / blank toy silhouette). The map should rhyme with the combat board: reveal → remember → act before it fades.

**Later milestones (out of first map MVP):** richer forget rules, blind entry vs recall-gated entry, keepsakes that “remember” a spot, multi-act playmats, etc. Explore those after the basic playmat + simple nodes ship.

---

## Fantasy loop

Between fights the player moves a token on the **toy playmat**:

- Land on fights → earn **money** (toys defeated)
- Visit shops / smiths → **equipment** (base attack, move speed, max HP, heal power, …)
- Find caches → **new pair types** or more copies of strong `(icon, color)` cards
- Learn **player powers** that suit the current deck
- Optional events with risk/reward
- Watch some known spots **flip to forgotten** if left alone too long (explicit visual)

The battle board is dealt from the player’s **pair pool / loadout**. Playmat choices change what you can draw and how strong baseline stats are.

---

## Playmat map (presentation)

| Rule | Map MVP |
|------|---------|
| Visibility | Entire act/playmat fits on screen; always visible while on the map |
| Layout | Compact grid or shelf of **spots** (toy pads) |
| Connections | Adjacency / neighbors — **no** classic node-link line graph |
| Memory | Known spots can become **explicitly forgotten** (face-down card / erased label) |
| Scope | One small playmat per act stub first; branching complexity later |

### Forget (first pass — keep light)

- Player **sees** a spot type (e.g. Shop), then after a tunable number of moves or fights it may **flip forgotten**.
- Forgotten = unmistakable blank/face-down state — not soft fog.
- **Map MVP default:** forgotten spots remain **enterable blind** (you land and discover what it still is / was). Recall-gated blocking is a **later** milestone if we want sharper memory pressure.

---

## Spot types (simple progression)

| Spot | Player choice | Outcome |
|------|---------------|---------|
| Battle | Enter fight | Money; possible pair drop |
| Elite / hard battle | Higher risk | Better rewards |
| Shop | Pay money | Gear or pairs |
| Cache / free pair | Take or skip | Add to pair pool |
| Event | Risk/reward | Mixed |
| Rest / repair | Heal or buff | Limited uses per run |
| Boss | End of act stub | Major reward / win act |

First stub can be a **small fixed playmat** (e.g. 3×3 or a short shelf) with a mix of the above — not a generated mega-map.

---

## Resources

| Resource | Gained from | Spent on |
|----------|-------------|----------|
| Money | Enemy kills (and some events) | Shop gear, pairs, maybe powers |
| Pair pool | Caches, shops, rewards | Appears when boards are dealt |
| Equipment | Smith / shop | Passive battle stats |
| Powers | Training / elite rewards | Active or passive battle modifiers |

No FTL-style fuel. Economy stays shop-and-upgrade simple.

Exact prices and drop tables: tune after battles exist.

---

## Loadout → battle bridge

Before a battle starts, the run layer passes:

- Player baseline stats (HP, attack, move cooldown, heal power, …)
- Pair pool used to build the 18 pairs (respecting 4 colors + effect mix rules)
- Unlocked powers

Battle systems should **not** hardcode map UI; they receive a simple config/resource.

---

## Difficulty ramp

Playmat depth / later acts increase:

- Enemy count and kits (tank + assassin, then healers)
- Harder pair compositions (fewer duplicates, nastier colors)
- Elite modifiers (faster enemy timers, less mana per color match)
- Faster or harsher **forget** on the playmat (later tuning)

---

## Implementation gate

Do **not** build the playmat until:

1. 6×6 + color/icon resolve feels good  
2. Multi-enemy + mana bonus attack feels good  
3. Money exists as a number the player cares about  

Then, **map MVP slice:**

1. Small always-visible playmat + move to adjacent spots  
2. Spot types: battle / shop / rest (minimum)  
3. Launch battle with config → return with money/HP  
4. One explicit **forget** visual on a spot type  

Deeper memory-map design → later milestones.

---

*When this doc conflicts with GAME_DESIGN.md on in-fight rules, GAME_DESIGN.md wins.*
