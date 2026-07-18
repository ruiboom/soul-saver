# SOUL SAVER — Build Plan & Milestones

*Ordered so every milestone ends with something playable on the Mac. Estimates assume
part-time solo dev with AI pair-programming; treat as relative sizes, not promises.*

---

## M0 — Toy That's Fun (playable in days)
**Goal: the core loop feels good with rectangles.**
- Godot project, autoloads, fixed-tick config.
- Player movement + camera on a flat test map.
- **Horde sim built the real way from day one** (MultiMesh + spatial hash + pooling —
  architecture doc §6; do NOT prototype with nodes and "fix later").
- One enemy (Ash-imp placeholder), spawn director with a single trickle table.
- Thurible (swing arc archetype) + damage pipeline + grace embers + XP + a draft screen
  offering 3 dummy upgrades (damage/speed/cooldown).
- Debug overlay (fps, enemy count, pools).
- ✅ Exit test: 300 enemies at 60 fps on the Mac; you voluntarily play it for 10 minutes.

## M1 — Vertical Slice (the game in miniature)
**Goal: minutes 0–10 of a real run, ugly-but-true.**
- 5 weapons (Thurible, Holy Water, Rosary, Psalter, Sanctus Bell) via 5 archetype
  scripts; 4 passives; real draft/rarity/luck logic (unit-tested).
- Bell I + II bestiary (6 enemy types incl. Wailer phasing and Spitting Idol ranged).
- Bell-toll event + first Herald elite (node-based elite architecture proven).
- Real map chunk (quarter-size) with 2 shrines, 1 Shrinekeeper, Vestige pickup +
  vignette screen, thread-of-rosary guide.
- HUD v1, pause, run summary, death flow. First music layers + ~15 SFX.
- Web export smoke test + headless sim in CI.
- ✅ Exit test: a stranger plays 10 minutes unprompted and asks to go again.

## M2 — Content Complete (systems locked)
- All 12 weapons + 12 exaltations, all 14 passives, all 15 swarm enemies, 7
  Shrinekeepers, 5 Heralds, full 128×128 map with all landmarks.
- The Warden fight + both endings.
- Meta layer: chapel hub, Ossuary Marks, blessings wall, Vestige Book, unlocks,
  save/versioning.
- Touch controls + controller-complete UI (tested on a phone via Android/iOS dev build).
- ✅ Exit test: full 25-min run → true ending achievable; second character unlockable.

## M3 — Beauty & Balance
- Final art lands (priority: player → Bell I–II enemies → weapon VFX → UI → the rest).
- Lighting, bloom, screenshake, hit-stop tuning; full audio mix with dynamic chant.
- Balance pass driven by the headless sim (auto-runs sweeping builds × difficulty,
  outputs survival curves) + human playtests. Meta power cap enforced (≤ +40%).
- Perf pass on weakest target device (500 enemies @ 60 fps mobile renderer).
- ✅ Exit test: screenshots look like a store page; playtesters' deaths feel fair.

## M4 — Ship-Ready (per platform)
- macOS: notarised .app. Windows/Linux: CI artifacts → itch.io/Steam depots.
- Web: itch.io playable demo build (marketing).
- Mobile: safe-area UI audit, suspend/resume, battery/thermal check, store packaging.
- Accessibility pass: remappable input, screen-flash reduction toggle, colour-blind
  check on the gold/green/orange language, text scale option.
- Console: no work now — architecture already conforms (controller-first, Platform.gd
  shim, 16:9 safe UI); engage a porting partner when there's traction.

---

## Standing risks & mitigations

| Risk | Mitigation |
|---|---|
| Horde perf on mobile | Built correctly at M0; tested on-device from M2, not M4 |
| Content balance sprawl (12×8-level weapons) | Data-driven tables + sim harness sweeps, not hand-testing every combo |
| Art cost/consistency | Whole game runs on placeholders until M3; single-artist or single-pack strategy |
| Religious-theme missteps | Tone rules in design doc §1.4; demons-only violence; review pass at M3 |
| Scope creep (2nd stage, more characters) | Everything post-v1 is drafted in docs but gated behind shipping M4 |

## Suggested first session in this repo
1. `brew install godot` (or download Godot 4.x .dmg), create project here.
2. Build M0 exactly in the order listed — horde sim before any content.
3. Commit `project.godot` + `src/` early; add `art-src/`, exports and `.godot/` to
   `.gitignore`.
