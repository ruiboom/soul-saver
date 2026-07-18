# SOUL SAVER — Asset Specification

*Art direction, technical specs, and the full inventory of sprites, VFX, audio and fonts.*

---

## 1. Art Direction — "Illuminated Inferno"

**One line:** *an illuminated manuscript dropped into a furnace* — gold leaf, vellum
tones and sacred geometry against char-black, ash-grey and ember-orange.

- **Style:** high-resolution painted 2D with strong dark outlines and woodcut-style
  hatching in shadows. NOT pixel art — the brief is premium mobile/console feel; the
  reference bar is *Blasphemous* / *Darkest Dungeon* art confidence with *Hades*-grade
  readability. Clean silhouettes first, texture second.
- **Palette discipline (readability under 500 sprites):**
  - Environment: desaturated — ash greys `#3a3a40–#6b6660`, char black `#17151a`,
    distant fire `#8a2f1d`.
  - Enemies: mid-saturation warm darks — rust, bruise-purple, bone `#c9bfa8`. Enemies
    NEVER use gold or white-gold.
  - Player + everything holy (weapons, VFX, pickups, UI): reserved colours — gold
    `#e8b64c`, halo white `#fff3d6`, grace blue-white `#cfe6ff`. **Rule: if it glows
    gold, it's yours or it helps you.** This single rule keeps the screen readable at
    max density.
  - Damage/threat telegraphs: sickly green `#7fae3e` and hellfire orange `#ff6b2b` only.
- **Light:** the world is dark; a warm light radius surrounds the player (Godot 2D
  point light + canvas modulate). Weapon VFX are the fireworks. Bloom on, subtle.
- **Camera scale:** ~1080p shows ≈ 15 × 8.5 world metres. **1 world metre = 128 px.**

## 2. Technical Specs

| Property | Spec |
|---|---|
| Working resolution | Author at 2× final ("4K-ready"), export at 1× (128 px/m) with mipmaps off, filter on |
| Player sprite | 256×256 canvas (character ≈ 170 px tall), pivot at feet |
| Swarm enemy sprites | 128×128 canvas (small), 192×192 (medium), 256×256 (large) |
| Elite/Shrinekeeper | 384×384 · Warden: 1024×1024 multi-part rig |
| Animation format | Sprite-sheet strips, uniform cells, ordered L→R (MultiMesh shader indexes frames — swarm enemies MUST be single-sheet) |
| Swarm anim sets | walk 8f, death 6f, spawn 4f @ 12 fps. That's ALL — no idle/attack for swarm (attack = contact) |
| Player anim set | idle 6f, walk 8f ×4 directions (S/N/E; W = flip), hurt 3f, death 10f, victory 12f @ 12 fps |
| Elite anim sets | idle 6f, walk 8f, attack(s) 8–12f, telegraph 6f, death 12f |
| Facing | Side-view sprites flipped for L/R; N/S only for the player (swarm enemies: single side view flipped — saves 60% of sheet cost, standard for the genre) |
| Tiles | 128 px tilemap, ~3 terrain sets (ash / burnt rock / glass waste) with 47-tile autotile masks, + fire river animated strip (8f) |
| Props/landmarks | Free-placed sprites: shrines ~512×768, Gate of Dawn 2048×1536, waystation kit ~6 pieces, bone piles 3 sizes ×3 variants (with 4f burst anim) |
| File format | PNG source; Godot imports to lossless WebP. Naming: `enemy_ashimp_walk_8f.png`, `weap_thurible_icon.png` |
| VFX | Prefer shader + Godot GPUParticles over frame anims; sprite-based only for signature effects (exaltation bursts, bell ring, vestige claim) |
| UI | 9-patch panels in "manuscript frame" style (gold rule lines, corner flourishes on vellum-dark); icon canvas 128×128; safe-area aware; controller focus ring = gold halo |

## 3. Asset Inventory (v1 complete list)

### 3.1 Characters
| Asset | Sheets |
|---|---|
| Father Anselm | full anim set (§2) + chapel idle + 3 portrait expressions (draft screen / vignette / death) |
| Malacoda apparition | idle 8f loop + appear/vanish 6f + 2 portraits |
| Lucia (vignettes/ending only) | 3 illustrated stills + Vestige wisp 6f loop ×7 tints |

### 3.2 Bestiary (per §5 of design doc)
15 swarm types × (walk+death+spawn) + 7 Shrinekeepers + 5 Heralds (reuse Shrinekeeper
rigs with palette/part swaps where honest) + Warden multi-part rig.
Priority order for prototyping: Ash-imp, Gnasher, Bloatgrub first (Bell I is the
vertical slice).

### 3.3 Weapons & effects (12 relics + 12 exaltations)
Each relic needs: **draft icon** (128), **in-world effect** (projectile sprite or
particle material + optional impact 4–6f), **exalted variant** (recolour/embellish, gold
intensified). Signature bespoke VFX budget (fully animated): Thurible smoke ribbons,
Sanctus Bell ring distortion (shader), Pillar of the Choir lightfall, Sword of St.
Michael sweep, Icon light-wall. Everything else = particles + shader glow.

### 3.4 Pickups & UI
Grace embers ×4 tiers (6f shimmer loop), 7 pickup icons, reliquary chest (closed/open
8f + burst), Ossuary Mark, draft cards (3 rarity frame tiers + sanctified animated
border), HUD set (consecration bar in reliquary frame, XP rosary-bead bar, bell-count
iconography, thread-of-rosary ribbon shader, boss health bar), chapel hub screen
(single large illustrated scene with 5 hotspots), run-summary parchment, 30-ish
blessing icons, vignette frame, settings/pause panels.

### 3.5 Environment
3 autotile terrain sets, fire river strip, 8 landmark sprite sets (§2 table in design
doc), 12 scatter props (gibbet, bone piles, ruined pew, broken bell, censer stand...),
parallax skybox: starless vault + distant Black Cathedral (2 layers), ambient particle
sheets (drifting ash, ember motes).

**Total rough count: ~140 sprite sheets, ~60 icons, ~15 shaders/particle materials.**

## 4. Audio Spec

### 4.1 Music — *interactive layers* (this sells the whole fantasy)
- Base score: dark drone + low strings + distant bells. **Plainchant layer** (male
  choir, latin liturgy fragments) fades in as intensity rises — mixed via `AudioDirector`
  reading live enemy density and bell count. Stems at 48 kHz, loop-pointed OGG.
- Cues: chapel theme (calm, single organ), 5 bell-toll stingers (escalating), Vestige
  vignette theme (music box + choir, Lucia's motif), Warden theme (full percussion +
  chant), true-ending hymn, death lament (~10 pieces/stems total).
- Sourcing: commission or CC0/CC-BY plainchant recordings + original composition;
  budget alternative for prototype: royalty-free dark-ambient + free chant recordings
  (many authentic recordings are public domain).

### 4.2 SFX (pooled, pitch-randomised ±5%)
Per-weapon fire + impact (24), exaltation fanfare, level-up chime (small bell),
draft-card select (page turn + choir hit), ember pickup (soft chime, pitch rises with
combo), player hurt (cloth + gasp) / death (bell toll + silence), 15 enemy death
categories (shared across families: cinder-burst, wet burst, chain drop, wraith sigh...),
elite roars ×8, bell tolls ×5 (THE signature sound — huge, dread-inducing, ducks the
mix), vestige claim (child's laugh, one note, reverb), chest fanfare, UI set (~8).
Target ~70 SFX files. Hard cap: 32 simultaneous voices, priority system in AudioDirector.

### 4.3 Voice
Anselm barks: ~25 short lines. Text-first with a "murmured latin" placeholder VO
(2–3 breathy syllables, pitch-shifted) — real VO is a post-v1 luxury.

## 5. Fonts
- **Display** (titles, draft cards): a blackletter-adjacent serif that stays legible —
  e.g. *Grenze Gotisch* (SIL OFL, free). Never for body text.
- **Body/UI:** high-legibility humanist serif — *Alegreya* (SIL OFL) with *Alegreya SC*
  for labels. Numerals (damage): *Alegreya Sans* bold, gold with dark outline.
- All SIL Open Font License = zero cost, all platforms, embeddable.

## 6. Production Notes
- **Placeholder pipeline first:** the whole game is built and tuned with flat-colour
  silhouette placeholders (auto-generated shapes per size class) so code never waits on
  art. Real art lands per the milestone plan (doc 04).
- Sourcing strategy: commission a single artist for characters/enemies (style
  consistency is the product), self-produce environment tiles and UI from the spec,
  particles/shaders in-engine. If commissioning is out of scope: license a coherent
  premium 2D pack and heavily palette-shift to spec §1 — coherence beats bespoke.
- Every asset checked into `assets/` with source (`.psd`/`.ase`/`.krita`) in a parallel
  `art-src/` folder kept out of export presets.
