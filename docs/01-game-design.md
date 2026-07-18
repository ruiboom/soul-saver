# SOUL SAVER — Game Design Document

*Genre: survivors-like (horde-survival action roguelite) · View: top-down · Session: 25–30 min runs*

---

## 1. Setting & Narrative

### 1.1 Premise

Hell keeps a ledger. Every soul that arrives is recorded, weighed and assigned. The system
is ancient, meticulous — and corruptible.

**Lucia Ferro**, nine years old, died of fever in the parish of San Rocco. Her soul was
bound for light. But a ledger-demon named **Malacoda the Clerk** has discovered a
profitable fraud: innocent souls burn brighter than damned ones, and brightness is Hell's
rarest currency. Malacoda falsified Lucia's record — a forged sin, a doctored weight — and
her soul was taken below, where it was **shattered into seven Vestiges** to be sold off
piecemeal to Hell's princes.

Heaven knows. Heaven is *processing the appeal*. Estimated resolution: one hundred years.

**Father Anselm**, the priest who baptised Lucia and buried her, will not wait. Using a
forbidden rite preserved in his order's archive — the *Descensus*, written by a saint who
went below once before and returned wrong — he opens the way and walks into Hell alive.

A living body in Hell is an outrage. A living body in a state of grace is an *invasion*.
Everything in the Ashen Reaches will converge on him, endlessly, in growing numbers, until
he leaves or dies.

### 1.2 The rules of the world (mechanics ↔ fiction)

Every core mechanic has a fiction reason. This keeps the game coherent and gives UI/VFX a
consistent language:

| Mechanic | Fiction |
|---|---|
| Enemies swarm the player endlessly | A living soul in grace is a beacon; Hell's creatures are starving for it |
| Kills drop XP pickups ("**Grace embers**") | Every demon has swallowed stolen grace; destroying it releases the spark, which flows to Anselm |
| Level-ups offer random weapons/upgrades | The ash of Hell is full of relics of saints and martyrs who fell here or were carried here as plunder; as Anselm's grace grows, more of them *wake* and answer him. The draft is him sensing which relics have stirred |
| Weapons fire automatically | Relics act of their own sanctity; Anselm doesn't wield them so much as *carry* them. His job is to walk, pray, and not die |
| Difficulty scales with time | The bells of the Black Cathedral toll each canonical hour; each toll wakes a deeper order of demon |
| Health / damage | Anselm's body is protected by consecration, which the demons erode. At zero, Hell claims him |
| Quest items on the map | The seven Vestiges of Lucia's soul, held at seven Profane Shrines across the Reaches |
| Run timer / final event | At the last bell (matins) the **Warden of the Gate** rises. Survive it — or if all Vestiges are gathered, the Gate of Dawn opens during the fight |
| Meta-progression between runs | Anselm returns to the chapel of San Rocco between descents. Relic fragments ("**Ossuary Marks**") persist and buy permanent blessings. Fiction: each descent leaves the way slightly more worn, and Anselm slightly more prepared — and slightly more marked |

### 1.3 Characters

**Father Anselm** (player character)
- ~60, heavyset, iron-grey beard, black cassock with a violet stole (violet = penance).
  Carries a thurible on a chain — his starting weapon — and Lucia's small wooden crucifix
  tucked into his cincture.
- Personality: calm, dry, unshockable. He is not a warrior and never becomes one; he is a
  *parish priest*, and he treats Hell like a difficult parish. Barks (short voice/text
  lines) are weary, kind, occasionally darkly funny: on level-up, *"Still with me. Good."*;
  on taking damage, *"I've had worse from the vestry committee."*; on finding a Vestige,
  *"There you are, little one."*
- He is committing a transgression and knows it. The rite he used is forbidden; the game's
  ending acknowledges that saving Lucia may cost him standing in both worlds. (Sequel hook.)

**Lucia Ferro** (the objective)
- Present only as the seven Vestiges: glowing childlike wisps, each carrying one fragment
  of her — her laugh, her name, her fear, her memory of the sea, etc. Each pickup plays a
  2–3 line memory vignette (text over a dimmed screen, skippable). These are the game's
  emotional beats and the reward for map exploration.

**Malacoda the Clerk** (antagonist, narrative)
- The fraudster. A hunched, ink-stained demon of ledgers and seals. Not a combat boss in
  v1 — he appears at run start and at each Vestige shrine as a taunting apparition, trying
  to negotiate ("*One fragment, priest. Take one and go. She won't miss her name.*").
  Killing him is the sequel/expansion hook; this run is about the rescue, not revenge.

**The Warden of the Gate** (final boss)
- Hell's immune response made flesh: a colossal blind jailer of chain and furnace-iron
  that rises at matins. It does not speak. Fight spec in §6.4.

**Unlockable characters** (post-v1, drafted now for architecture's sake — the character
system must support multiple playables from day one):
- **Sister Beatriz** — a Carmelite nun; starts with the Sanctus Bell, higher move speed,
  lower max consecration.
- **Brother Crispin** — a disgraced exorcist; starts with Holy Water, +1 draft choice,
  cannot take armour passives.
- **The Penitent** — a damned soul in chains who has repented; starts weak with huge
  late-game scaling. Unlocked by winning a run.

### 1.4 Tone

Solemn but not grim; the darkness of Hell against the warmth of grace. Think *illuminated
manuscript meets inferno*: gold leaf against char. Violence is against demons only —
stylised, incandescent, no human gore. Religious content is treated with respect and a
light touch of dry humour carried by Anselm; the theme is mercy defeating bureaucracy,
which keeps it universal.

---

## 2. The Map — The Ashen Reaches

One large hand-authored map per stage (v1 ships one stage; the layout system supports
more). The Reaches are Hell's border-marches: an endless plain of grey ash under a
starless vault, lit by rivers of fire and the distant glow of the Black Cathedral.

- **Size:** 128 × 128 tiles of 128 px → 16,384 × 16,384 px world (~40 screens across).
  Open plain with landmark density every 1–2 screens; no dead ends, light maze walls
  (rock spurs, fire rivers with crossing points) to make routing decisions matter.
- **Camera:** centered on player, slight look-ahead in movement direction, screenshake
  budget small (mobile-friendly).
- **The seven Profane Shrines** are placed at fixed landmark sites roughly on a ring at
  60–80% of map radius, so collecting all seven forces a full circuit while the horde
  escalates. Each shrine is guarded by a **Shrinekeeper elite** (see bestiary). A faint
  gold thread on the ground (toggleable) points to the nearest unclaimed Vestige — the
  *Thread of the Rosary*, so navigation never needs a minimap on small screens (a minimap
  is still available on desktop).
- **The Gate of Dawn** stands at map center, sealed, and doubles as the run's starting
  point — so "return to the gate" is a natural endgame homing beacon.

### Landmark set (also serves as the asset list's environment section)

| Landmark | Role |
|---|---|
| Gate of Dawn | Start point, extraction point; a vast sealed arch of white stone, the one clean thing in Hell |
| Black Cathedral (skybox/parallax only) | Distant doom-clock; its bells drive the difficulty timeline; visibly *nearer* in later stages |
| 7 Profane Shrines | Vestige sites; inverted chapels of black basalt, each themed to the fragment it holds |
| Rivers of fire | Impassable except at bridges of fused bone; route shapers |
| The Ossuary Fields | Bone-heap region; destructible bone piles drop pickups (the genre's "braziers/candelabra") |
| Gibbet Groves | "Trees" of iron gibbets; dense-cover region, ambush spawns |
| The Glass Waste | Ash fused to black mirror; enemies visible at long range, no cover — risk/reward speed lanes |
| Ruined waystations of St. Brendan | 3–4 small ruined chapels; safe-ish rooms containing a guaranteed chest ("reliquary") |

---

## 3. Player Systems

### 3.1 Controls

- **Move:** WASD / arrows / left stick / touch — floating virtual joystick. Movement is
  the *entire* moment-to-moment input.
- **No aim, no fire button.** All weapons auto-trigger on their own cooldowns with
  per-weapon targeting rules (nearest, random, orbit, facing, retaliation).
- **One context action** (Space / A / tap button): interact — claim Vestige, open
  reliquary chest, confirm at Gate. Also usable to skip vignettes.
- **Pause** anytime; the draft screen auto-pauses.

### 3.2 Core stats

| Stat | Base | Notes |
|---|---|---|
| Consecration (HP) | 100 | Regeneration only via passives/pickups |
| Move speed | 300 px/s | |
| Might (damage mult) | 1.0 | |
| Area (AoE size mult) | 1.0 | |
| Haste (cooldown mult) | 1.0 | |
| Amount (extra projectiles) | +0 | |
| Duration (effect length mult) | 1.0 | |
| Magnet (pickup radius) | 60 px | |
| Luck (rarity weighting) | 1.0 | |
| Armour (flat dmg reduction) | 0 | |
| Revival | 0 | "Martyr's Palm" grants 1 |

### 3.3 Grace, levels, drafts

- Enemies drop **Grace embers** (small/medium/large/prismatic). Embers fly to the player
  inside magnet radius; uncollected embers persist for 60 s then sink into the ash.
- XP curve: level *n* requires `20 + 8·n + 0.9·n²` grace (tunable in one data file).
  Target pacing: level ~8 by minute 5, ~20 by minute 15, ~30 by run end.
- On level-up: **draft of 3** (4 with luck/character bonuses) drawn from: new weapons
  (if slots free), upgrades to owned weapons, new passives, upgrades to owned passives.
  Weighted by rarity (common/blessed/venerated/sanctified) and luck. One **reroll** and
  one **banish** per run from meta unlocks; **skip** always available (grants small grace).
- **Slots:** 6 weapon slots, 6 passive slots (genre standard; supports deep builds).

### 3.4 Pickups (world drops)

| Pickup | Source | Effect |
|---|---|---|
| Grace ember | any kill | XP |
| Bread of the Pilgrim | bone piles, rare drop | heal 30 |
| Vial of Chrism | elites | full magnet — vacuum all embers on map |
| Censer Coal | elites | 10 s: all weapon cooldowns −50% |
| Wrath of the Lamb | rare elite drop | screen-clear smite (the genre's "rosary/bomb" — here it's actually thematic!) |
| Ossuary Mark | elites, shrines, bosses | meta-currency, persists after death |
| Reliquary (chest) | Shrinekeepers, waystations | 1/3/5-item jackpot draft with fanfare |

---

## 4. Arsenal — Weapons (relics that act)

All weapons are **relics of saints and martyrs** that fell or were carried into Hell.
Each has 8 levels; level 8 + a specific passive + a reliquary chest = **Exaltation**
(evolution) into a transfigured form. Damage numbers below are level-1 baselines;
per-level tables live in the data files (see architecture doc §5).

### Starting weapon

**1. The Thurible** *(Anselm's own censer)*
- Swings in a widening arc in the facing direction, trailing incense that lingers as a
  damaging cloud. Melee-arc + short DoT zone. The signature weapon.
- Levels add: arc width, a second back-swing (covers rear), smoke duration, damage.
- **Exaltation — "Censer of the Seraphim"** (requires passive: *Embered Coal*): the
  thurible orbits continuously at range, wreathing the player in a burning incense ring.

### Weapon pool

**2. Holy Water** — lobbed vials shatter into burning pools of blessed water (area denial).
Exaltation **"The Baptismal Flood"** (*Pilgrim's Flask*): pools merge, flow, and follow the player.

**3. The Rosary** — glowing beads orbit the player, damaging on contact; beads shatter
after N hits then the decade recharges. Exaltation **"The Sorrowful Mysteries"**
(*Bishop's Ring*): two counter-rotating decades, beads explode on shatter.

**4. Psalter of War** — the book flies open and fires **verses** — lines of burning
scripture — as homing projectiles at the nearest enemies. Exaltation **"The Last Word"**
(*Illuminated Manuscript*): verses pierce and chain, leaving burning words hanging in the air.

**5. Communion Paten** — the golden dish is hurled like a discus: pierces, ricochets off
map edges, returns. Exaltation **"The Unbroken Host"** (*Sacramental Wine*): splits into
three patens with independent ricochet.

**6. Sanctus Bell** — periodic radial shockwave that damages and briefly **staggers**
(interrupts) all enemies in radius. The crowd-control anchor. Exaltation **"The Bell of
Matins"** (*Deacon's Stole*): shockwave leaves a slowing field; every 4th ring is doubled.

**7. Reliquary of St. Adaucus** — the little casket rattles and launches **knuckle-bones**
that bounce between enemies (bouncing projectile). Exaltation **"The Glorious Company"**
(*Saint's Fingerbone*): bones raise brief spectral saints where they land, who strike once.

**8. Pillar of the Choir** — a shaft of light falls from the vault onto a random nearby
enemy (the "lightning" archetype); brief lingering column. Exaltation **"The Cherubim
Descend"** (*Candle of the Vigil*): columns fall in threes and sweep short lines.

**9. Crown of Thorns** — worn, not thrown: a retaliation aura; enemies that strike Anselm
take heavy damage and bleed light (tank archetype, anti-swarm-contact). Exaltation
**"The Passion"** (*Martyr's Palm*): retaliation triggers on *proximity*, not just contact —
becomes a proper damage aura, and heals 1 per demon slain within it.

**10. Sword of St. Michael** — rare relic (weighted low, or shrine-locked): a greatsword
of white flame sweeps a full circle every few seconds; huge damage, long cooldown.
Exaltation **"The Prince of the Host"** (*Scapular of the Vanguard*): the Archangel's own
blade — the sweep becomes a slow orbiting blade that never stops.

**11. Icon of the Theotokos** — projected forward as a moving wall of light that pushes
enemies back and damages them (the "knockback lane-clearer"). Exaltation **"Our Lady of
Victory"** (*Silver Oklad*): the wall becomes a full protective ring that pulses outward.

**12. Chotki of the Desert Fathers** — a prayer-rope that lashes out at the *farthest*
targeted enemy in range like a whip-line, hitting everything along the line. Exaltation
**"The Unceasing Prayer"** (*Hermit's Girdle*): fires continuously in a slow rotation.

*(Pool of 12 gives strong draft variety; 6 slots from 12 weapons ≈ 924 base combinations.)*

### 4.1 Passives (relics that strengthen)

| Passive | Effect / level (5 levels) | Enables Exaltation of |
|---|---|---|
| Embered Coal | +8% might | Thurible |
| Pilgrim's Flask | +10% duration | Holy Water |
| Bishop's Ring | +6% area | Rosary |
| Illuminated Manuscript | +8% grace gained | Psalter |
| Sacramental Wine | +10 max consecration | Communion Paten |
| Deacon's Stole | −5% cooldowns | Sanctus Bell |
| Saint's Fingerbone | +1 amount at lv 3 & 5 | Reliquary |
| Candle of the Vigil | +12% magnet radius, +vision in dark zones | Pillar of the Choir |
| Martyr's Palm | +1 revival at lv 1; +heal on revive | Crown of Thorns |
| Scapular of the Vanguard | +5% move speed | Sword of St. Michael |
| Silver Oklad | +1 armour | Icon of the Theotokos |
| Hermit's Girdle | +5% might at full HP ×level | Chotki |
| St. Christopher Medal | +8% move speed | — (pure boost) |
| Alms Purse | +10% Ossuary Marks found | — (meta greed) |

---

## 5. Bestiary — The Hosts of the Reaches

Enemies are organised by **Bell** (the doom-clock): each canonical hour tolls a deeper
order awake. Within an order: **grunt / fast / tank / ranged / elite** roles so wave
design is composable. All stats data-driven.

### Bell I — Vespers (min 0–5) · *The Hungry*
- **Ash-imps** — the basic swarm; shambling handfuls of cinder with teeth. Slow, weak, endless.
- **Gnashers** — hairless hound-things, fast, lunge in packs (the "bat" role).
- **Bloatgrubs** — slow fat larvae; burst into a small acid pool on death (teaches positioning).

### Bell II — Compline (min 5–10) · *The Sorrowful*
- **Wailers** — drifting shrouded wraiths; phase slowly *through* obstacles, forcing movement.
- **Chain-brutes** — hulking damned in fused chains; tanky, knockback-resistant.
- **Spitting Idols** — stationary defiled statues that wake when approached; ranged bile arcs (first ranged threat).

### Bell III — Nocturns (min 10–15) · *The Wrathful*
- **Furies** — winged shrikes that circle then dive across the screen (crossing threat).
- **Pyre-wights** — burning revenants; leave fire trails, immune to fire-type relic damage (build-check).
- **Legion cells** — clumps of fused bodies that split twice when destroyed (7→3→1).

### Bell IV — Lauds (min 15–20) · *The Proud*
- **Fallen Sentinels** — corrupted angelic statues, animated; slow, huge, soak damage, aura-buff nearby demons.
- **Ledger-scribes** — Malacoda's clerks; *steal grace embers* off the ground and flee — kill to reclaim double (anti-greed pressure and comedy).
- **The Faceless Choir** — robed ranks that advance in synchronised walls (formation threat).

### Bell V — Matins (min 20–25) · *The Abyssal*
- **Behemoth calves** — mini-boss-scale chargers that plough furrows through the ash.
- **Seraph-husks** — six-winged burnt-out shells; teleport short distances; fast, elite-tier.
- Density of all previous bells maxes out; the horde becomes the terrain.

### Elites & bosses
- **Shrinekeepers (×7)** — one guarding each Vestige, each a named demon themed to its
  shrine (e.g. **Gullet**, keeper of the Shrine of the Name, a toad-mound that must be
  burst open; **Mirrorface**, keeper of the Shrine of the Face, who spawns copies of the
  player's weapon effects in hostile colours). Mini-boss health bars, unique attack
  pattern each, guaranteed Reliquary + Ossuary Marks + the Vestige.
- **Bell-tower Heralds** — at each bell toll (every 5 min), a timed elite spawns and
  hunts the player (the "reaper pressure" mechanic, but killable with effort; big reward).
- **The Warden of the Gate** — final boss at minute 25. Screen-dominating; three phases
  (chain sweeps → furnace breath lanes → summoned cage walls that shrink the arena).
  If the player holds all 7 Vestiges, the Gate opens mid-fight after 90 s survived:
  **true ending**. If not: survive the full fight for the **survivor ending** (Anselm
  escapes alive, Lucia still below — "the next descent" hook, i.e. next run).

### Global scaling
Every enemy's HP/damage/speed multiplies by a time-indexed curve *and* a per-run
difficulty tier (meta unlockable "Deeper Bells" = the genre's hyper/inverse modes).
Spawn director details in architecture doc §4.6.

---

## 6. Run Structure & Difficulty Timeline

| Minute | Event |
|---|---|
| 0:00 | Spawn at Gate of Dawn; Malacoda apparition taunt; Bell I wave tables |
| 5:00 | **Bell II** toll — Herald elite spawns; new wave tables layered in |
| 10:00 | **Bell III** toll — Herald; fire-river bridges now contested by Spitting Idols |
| 12:30 | Grace surge event: prismatic ember rain for 30 s (risk/reward scramble) |
| 15:00 | **Bell IV** toll — Herald; Ledger-scribes begin stealing |
| 20:00 | **Bell V** toll — Herald; max density ramp begins |
| 25:00 | **The Warden rises.** All ordinary spawns stop; arena fight at wherever the player stands |
| ~27:00 | Gate opens (if 7/7 Vestiges) → true ending · or Warden despawns at 30:00 → survivor ending |
| any | Death → run summary, Ossuary Marks banked, Malacoda gets a gloat line |

Vestige collection is *optional pressure*: a pure-survival build can ignore shrines, but
the true ending — and the best Ossuary Mark income — demands the circuit. Shrinekeeper
difficulty scales with the bell count, so early shrine runs are the aggressive-skill play.

## 7. Meta-progression (between runs, at the Chapel of San Rocco)

- **Ossuary Marks** buy permanent blessings at the chapel's reliquary wall: +might,
  +consecration, +luck, +starting reroll/banish/skip, unlock characters, unlock "Deeper
  Bells" difficulty tiers, unlock the (post-v1) second stage.
- **The Vestige Book**: each *distinct* Vestige ever recovered fills an illuminated page
  (Lucia vignette gallery). Collecting all 7 across any runs unlocks the Penitent.
- Design guard-rail: meta buffs cap at ~+40% power so skill stays primary (avoid the
  genre's "meta trivialises runs" failure mode).

## 8. Look & Feel bar

Reference quality tier: *Hades* UI clarity, *Vampire Survivors* readability under 500
enemies, *Blasphemous* art-direction confidence (without its gore). Every draft screen,
bell toll and Vestige vignette should feel *liturgical*: gold on black, plainchant swells,
illuminated-manuscript framing. Detail in the asset spec (doc 03).
