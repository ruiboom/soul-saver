# SOUL SAVER — Implementation Notes (v1 build)

*What was actually built, where it deviates from the spec docs, and what to do next.*

## Status

The game is **built and playable** (`/Applications/Godot.app/Contents/MacOS/Godot --path .`).
Verified by automated integration tests (bot plays a full 19-minute run at 8× time scale):

- Full loop: title/chapel → run → bells I–V → heralds → 7 Shrinekeepers → 7 vestige
  vignettes → Warden at 18:00 → **both endings reached** (true & survivor), death flow too.
- Meta persistence: Ossuary Marks, blessings, Vestige Book, best time (`user://soulsaver_save.json`).
- Performance: **400+ live enemies at 140+ fps** on this Mac (M-series), including at 8× sim speed.
  The horde is a struct-of-arrays sim + MultiMesh, exactly as architecture doc §6 demanded.

## Deviations from spec (deliberate, v1 scope)

| Spec | Built | Why |
|---|---|---|
| Content as `.tres` resources | One declarative module `src/data.gd` | Same data-driven contract, far faster to author/tune; migrate to `.tres` when a non-coder needs to edit balance |
| 12 weapons + 12 exaltations | 9 weapons, each with an Exaltation (generic transfiguration: +60% dmg, −20% cd + behaviour/visual change for thurible/rosary/sword/bell/crown) | Coverage of all 9 archetypes mattered more than count; the 3 cut (Chotki, Icon wall, Reliquary bones) slot into existing archetypes later |
| 15 swarm enemy types | 8 types (all five roles + phase/dive/burst/steal/tank/fire-immune specials) | One per behaviour archetype; more are palette+stat rows in `data.gd` |
| 25-minute run, bells each 5 min | 21-minute run, bells each 4 min, Warden 18:00 | Tighter session; trivial to retune in `data.gd` |
| Hand-authored 128×128 tile map | Procedural Ashen Reaches: world-space shader ground (ash, ember veins, 4 meandering lava rivers with 2 bone bridges, boundary lake of fire), scattered props, shrine ring at 4100 px | No tile art needed; looks better under bloom; lava collision math mirrored CPU-side (`map.gd::lava_at`) |
| Waystation chests | Herald kills open a bonus draft; bone piles drop pickups | Same reward cadence, fewer systems |
| Characters beyond Anselm | Not in v1 | Architecture supports it (stats & starting weapon are data) |
| Commissioned art | 46 hand-authored SVGs + shader/particle VFX; all audio synthesized procedurally (17 WAVs incl. layered drone + chant that swells with danger) | Zero licensing cost, coherent style; swap files in `assets/` to upgrade |

## Known rough edges (good next tasks)

1. **Balance is first-pass human-tuned.** After initial playtests: spawn budget opens at
   ~12 demons (was 56) ramping to 520; enemy HP/dmg per-bell scaling softened ~30%;
   thurible buffed (17 dmg / 1.3 s / 140°); XP curve `20 + 8n + n²`; kill feedback added
   (gold soul-release pop + knockback on every hit); Wrath of the Lamb is walk-over-only
   with a screen flash; the Warden's effective HP was halved (~7.5 k at 18:00), its
   damage softened, and it sheds grace embers per 10% health lost. Keep iterating with
   real runs — every number lives in `data.gd` / `boss.gd`.
2. Enemies path straight through landmark sprites (genre-standard, but the Gate steps look odd).
3. Damage numbers overlap at high density (capped at 10/frame, still stacks visually).
4. Malacoda apparition is announce-text + ghost sprite; a portrait dialogue box would land harder.
5. No touch controls yet (mobile milestone M4 in the roadmap); input abstraction is in place.
6. WAV music loops are seamless but simple; commissioned plainchant stems would elevate it.
7. `ERROR: N resources still in use at exit` — benign Godot cleanup noise from quitting
   mid-scene; harmless, silence by freeing the run scene before quit if it bothers CI.

## Test harness

- `SOULSAVER_AUTOTEST=1` — bot circles and fights, auto-picks drafts, screenshots to
  `SOULSAVER_SHOT_DIR`, quits after `SOULSAVER_QUIT_AFTER` sim-seconds.
- `SOULSAVER_QUEST=1` — bot walks the full vestige circuit (integration test of shrines,
  keepers, vignettes, Warden, endings). Combine with `SOULSAVER_TIMESCALE=8`.
- `SOULSAVER_MORTAL=1` — disables the bot's god mode (tests the death/revive flow).
- `SOULSAVER_TITLE_SHOT=/path.png` — screenshot the chapel screen and quit.
- Headless smoke: add `--headless` (no screenshots, checks scripts/logic/no-crash).
