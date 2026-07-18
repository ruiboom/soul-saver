# SOUL SAVER

*A survivors-like action roguelite. One priest. All of Hell. A soul that doesn't belong there.*

---

## What this is

**Soul Saver** is a top-down auto-battler survival game in the style of *Vampire Survivors*:
the player moves; weapons fire automatically; enemies swarm in ever-growing waves; kills
grant Grace (XP); levelling up offers a random draft of new weapons, upgrades and boosts;
the player snowballs in power while the horde snowballs in number and strength.

Two win conditions per run:

1. **Survive** the run timer (escalating waves, timed elites and bosses).
2. **Recover the Seven Vestiges** — fragments of an innocent soul, scattered across the
   map — and carry them to the Gate of Dawn.

No vampires. No zombies. The setting is **Hell itself**, the enemies are its demons and
damned beasts, the hero is a **priest who has descended voluntarily** to retrieve a soul
condemned by mistake, and every weapon and upgrade is a **Christian religious artefact** —
thuribles, holy water, reliquaries, psalters, bells.

## Documents

| Doc | Contents |
|-----|----------|
| [docs/06-user-guide.md](docs/06-user-guide.md) | **Start here to play** — install, run, controls, saves, troubleshooting |
| [docs/07-gameplay-guide.md](docs/07-gameplay-guide.md) | **How to win** — relics, exaltations, bestiary, run strategy, endings |
| [docs/01-game-design.md](docs/01-game-design.md) | Setting, narrative, characters, the map, enemy bestiary, full weapon/upgrade/evolution pools, run structure, difficulty curve |
| [docs/02-architecture.md](docs/02-architecture.md) | Engine choice & cross-platform strategy, project structure, core systems design, data-driven content, performance plan, save system |
| [docs/03-asset-spec.md](docs/03-asset-spec.md) | Art direction, technical sprite/animation specs, full asset inventory, VFX, audio & music spec, fonts, naming conventions |
| [docs/04-milestones.md](docs/04-milestones.md) | Build plan: playable-in-days prototype → vertical slice → content-complete → polish |
| [docs/05-implementation-notes.md](docs/05-implementation-notes.md) | What was built vs the spec, verification results, known rough edges, test harness |

## Headline decisions

- **Engine: Godot 4.x** (GDScript). MIT-licensed, zero cost, single codebase.
- **Primary dev target: macOS** (native editor + instant run). Export targets from the
  same project: Windows, Linux, iOS, Android, Web. Console later via porting partners.
- **Art: high-resolution stylised 2D** ("painted gothic woodcut" direction) — reads as a
  premium mobile/console title, not retro pixel art. Full spec in doc 03.
- **Content is data-driven**: weapons, enemies, waves and upgrades are Godot Resource
  files (`.tres`), so balancing and new content never touch engine code.
- **Performance budget: 500+ live enemies at 60 fps** on a mid-range phone, via pooling,
  spatial hashing, flow-field movement and batched rendering (techniques in doc 02).

## Running the game

The game is built and playable — Godot 4.x project in this folder.

```sh
brew install --cask godot        # once
/Applications/Godot.app/Contents/MacOS/Godot --path .        # play
```

Or open the folder in the Godot editor and press ▶. Controls: **WASD/arrows/left-stick** to move,
**Space/E** to interact at shrines and the Gate, **Esc** to pause. Relics fire on their own —
your job is to walk, pray, and not die.

Debug keys (debug builds): `F2` +grace, `F3` +60 s, `F4` spawn herald, `F6` god mode, `F7` 4× speed.

Regenerate procedural assets after editing the generators:

```sh
python3 tools/gen_audio.py       # WAV synthesis
python3 tools/gen_svg.py         # sprite SVGs
```

Automated smoke test (bot plays, screenshots, quits):

```sh
SOULSAVER_AUTOTEST=1 SOULSAVER_QUIT_AFTER=30 \
SOULSAVER_SHOT_DIR=/tmp/shots /Applications/Godot.app/Contents/MacOS/Godot --path .
# full-run integration test at 8x: add SOULSAVER_QUEST=1 SOULSAVER_TIMESCALE=8 SOULSAVER_QUIT_AFTER=1300
```

## Elevator pitch

> Father Anselm has committed the one sin his order cannot forgive: he opened the way to
> Hell on purpose. A child from his parish — Lucia, nine years old, guilty of nothing —
> was taken below when a demon falsified the ledger of her soul. Heaven's bureaucracy
> will take a century to correct the error. Anselm has one night.
>
> Armed at first with nothing but a swinging censer and his conviction, he walks into the
> Ashen Reaches. Every demon he destroys releases a spark of stolen grace — and grace, in
> Hell, is power. The relics of dead saints half-buried in the ash answer his touch. The
> deeper he goes, the stronger he becomes; and the more Hell notices him.
>
> Find the seven scattered Vestiges of Lucia's soul. Reach the Gate of Dawn before the
> bells of the Black Cathedral toll matins. Save her — or be added to the ledger himself.
