# SOUL SAVER — Architecture & Code Specification

---

## 1. Engine & Cross-Platform Strategy

### 1.1 Decision: Godot 4.x (GDScript)

**Requirements:** run locally on macOS now; later ship mobile (iOS/Android) and ideally
console; one central codebase; open source; zero licensing cost; must render 500+ moving
enemies at 60 fps; "high-quality mobile/console" presentation.

| Option | Verdict |
|---|---|
| **Godot 4.x** ✅ | MIT license, $0 forever, no revenue share. Native macOS editor; run-on-save iteration. First-class 2D renderer (Vulkan/Metal via MoltenVK). One project exports to macOS, Windows, Linux, iOS, Android, Web with a click. Huge survivors-like community precedent. Console: no open-source path exists *on any engine* (console SDKs are NDA'd), but Godot has established porting partners (e.g. W4 Games) when that day comes — code carries over. |
| Unity | Technically fine, but license fees/Runtime-fee history, closed source — fails the brief. |
| Web stack (TypeScript + Phaser/Pixi, wrapped in Tauri desktop / Capacitor mobile) | Genuinely viable (Vampire Survivors itself began as Phaser). Rejected as primary because: perf ceiling for 500+ enemies + lighting is lower and less predictable across mobile WebViews; "wrapper per platform" is three build systems vs Godot's one; no console story at all. Keep as fallback only. |
| Bevy / raw SDL / MonoGame | Powerful but you hand-build editors, particle tools, UI systems and export pipelines Godot ships with. Wrong trade for a content-heavy game. |

**Version pin:** latest stable Godot 4.x at project start (4.3+). Renderer: **Forward+**
on desktop, **Mobile** renderer for iOS/Android exports — test on both from week 1, since
the whole point is cross-platform.

**Language:** GDScript throughout. It's fast enough when the hot paths use the server
APIs and typed arrays (see §6); if a profiled hot spot ever demands it, Godot allows
surgical C++ via GDExtension without touching the rest of the codebase. Avoid C#: it
complicates iOS/Web export for little gain here.

### 1.2 Platform rollout plan

1. **Now — macOS local:** develop and run natively in the Godot editor. `godot --path .`
   or editor F5. Distribute test builds to yourself as .app via one-click export.
2. **Continuous — Web build:** keep an HTML5 export working from early on; it's the
   cheapest cross-platform canary (if it runs in a browser at 60 fps, phones will cope)
   and makes playtest sharing trivial (itch.io).
3. **Beta — Windows/Linux:** free wins from the same export dialog; test via CI artifacts.
4. **Mobile:** iOS export needs a Mac + Xcode (you have one); Android needs the SDK.
   Touch controls (virtual joystick) are built from day 1 behind an input-abstraction
   autoload, not bolted on later.
5. **Console (future):** via porting partner. Architectural prep costs us nothing:
   controller-first UI navigation, no OS-specific calls outside one `Platform.gd` shim,
   16:9-safe UI with overscan margins.

---

## 2. Project Structure

```
soul-saver/
├── project.godot
├── addons/                      # editor plugins only (nothing runtime-critical)
├── assets/                      # see asset spec doc for internal layout
│   ├── sprites/  ├── vfx/  ├── audio/  ├── fonts/  └── shaders/
├── data/                        # ALL balance/content as .tres Resources
│   ├── weapons/                 #   one WeaponData per relic (+ per-level tables)
│   ├── passives/
│   ├── enemies/                 #   one EnemyData per demon type
│   ├── waves/                   #   spawn tables per Bell
│   ├── characters/              #   playable character defs
│   ├── pickups/
│   └── meta/                    #   blessing costs, XP curve, rarity weights
├── src/
│   ├── autoload/                # singletons (registered in project settings)
│   │   ├── Game.gd              #   run state machine, pause, scene flow
│   │   ├── RunState.gd          #   current-run stats, timer, vestige count
│   │   ├── MetaSave.gd          #   persistent save (marks, unlocks, settings)
│   │   ├── AudioDirector.gd     #   music layers, SFX pooling, bus control
│   │   ├── Rng.gd               #   seeded RNG streams (draft/spawn/loot separate)
│   │   └── Platform.gd          #   input mode, safe-area, per-OS shims
│   ├── player/
│   │   ├── player.tscn/.gd      #   movement, stats, i-frames, magnet
│   │   └── stats.gd             #   StatBlock resource (modifier stacking)
│   ├── weapons/
│   │   ├── weapon_manager.gd    #   owns slots, cooldown ticks, level-ups
│   │   ├── weapon_base.gd       #   behaviour contract
│   │   └── behaviors/           #   one script per archetype (orbit, lob, beam,
│   │                            #   swing, homing, ricochet, aura, wall, line)
│   ├── enemies/
│   │   ├── spawn_director.gd    #   the composer of the horde (§4.6)
│   │   ├── horde.gd             #   THE hot path: pooled enemy sim (§6)
│   │   └── elites/              #   scene-based bosses & shrinekeepers (few, rich)
│   ├── pickups/                 #   pooled embers & item drops
│   ├── map/
│   │   ├── stage.tscn           #   tilemap chunks, landmarks, shrine placement
│   │   └── shrine.gd            #   vestige interaction + keeper trigger
│   ├── ui/
│   │   ├── hud.tscn             #   bars, timer, bell icons, thread-of-rosary arrow
│   │   ├── draft_screen.tscn    #   the level-up draft (pauses tree)
│   │   ├── chapel.tscn          #   meta hub between runs
│   │   └── vignette.tscn        #   Lucia memory beats
│   └── systems/
│       ├── damage.gd            #   damage events, crits, armour, DoT ticks
│       ├── loot.gd              #   drop rolls
│       └── director_events.gd   #   timeline (bells, heralds, surge, warden)
└── tests/                       # GUT unit tests for pure-logic systems
```

**Rule:** `data/` is designers' territory, `src/` is engineers'. A new weapon or enemy
must be addable by creating `.tres` files + sprites, choosing an existing behaviour
script, and *never* editing a system file.

## 3. Scene/State Flow

```
Boot ─► Chapel (meta hub) ─► Character/loadout select ─► Run
Run:  Stage loads ─► intro apparition ─► SURVIVE loop ─► Warden ─► Ending / Death
        └─ level-up ─► DraftScreen (tree paused) ─► resume
Ending/Death ─► Run Summary (marks banked) ─► Chapel
```

`Game.gd` owns this as an explicit state machine (`enum GameState`), and all transitions
emit signals. Nothing reaches across scenes directly; UI listens to signals from
`RunState`/`WeaponManager` (`grace_changed`, `leveled_up`, `vestige_claimed`,
`bell_tolled`...). This keeps HUD, audio and game logic decoupled — essential once
platform-specific UIs appear.

## 4. Core Systems

### 4.1 Player
`CharacterBody2D`, 8-directional analog movement, `move_and_slide` against map collision
only (enemy contact is resolved by the horde sim, not physics — §6). Handles: stat block,
contact damage intake with 0.5 s i-frames, magnet field (Area2D), interact prompt.

### 4.2 StatBlock
A `Resource` holding base stats + an array of `StatModifier {stat, add, mult, source}`.
Weapons/passives/blessings apply modifiers with a `source` tag so they can be recomputed
or removed cleanly. Final values cached, recomputed only on change (signal
`stats_dirty`). Unit-tested — this is where balance bugs breed.

### 4.3 WeaponManager & behaviours
- Holds up to 6 `WeaponInstance {data: WeaponData, level, cooldown_left}`.
- Ticks cooldowns each frame; on fire, calls the archetype behaviour with resolved stats
  (base × player might/area/haste/amount/duration).
- **Archetype scripts** (~9 of them) cover all 12 weapons; a `WeaponData.tres` picks an
  archetype + parameters (projectile scene, counts, arcs, element tags, per-level table
  as `Array[Dictionary]`). Exaltations are just a second `WeaponData` referenced by the
  base one plus an unlock condition — no special-case code.
- All projectiles/effects come from **pools** (§6.2).

### 4.4 Damage system
Single choke point: `Damage.apply(target_id, amount, tags)` → handles armour, resist/
immune tags (e.g. Pyre-wights ignore `fire`), crits, DoT registration, kill credit,
lifesteal hooks. Emits `enemy_killed(id, pos, enemy_data)` which loot & grace systems
consume. Damage numbers are a pooled label ring buffer, capped per frame (readability
and perf).

### 4.5 Draft system
On `leveled_up`: build the offer set — eligible pool filtered by owned/slot state, weight
by rarity × luck, draw 3–4 without replacement via `Rng.draft` stream (seeded per run →
reproducible runs for debugging & future daily-challenge mode). Pure logic, no scene
access → unit-tested exhaustively (dupes, full-slot cases, banish/reroll interactions).

### 4.6 Spawn Director
The horde composer. Reads `data/waves/bell_N.tres` tables:
`{enemy, weight, min_time, max_time, pack_size, pack_shape}`.
- Maintains a **live-enemy budget** curve over time (e.g. 80 @ min 1 → 500 @ min 22).
- Spawns just outside the camera rect (ring sampling), despawns/teleports-ahead enemies
  that fall > 1.5 screens behind (the genre's standard invisible recycling).
- Pack shapes: trickle, ring-around-player, wall-from-direction, ambush-at-landmark.
- Timeline events (bells, heralds, surge, Warden) are `director_events.gd` — a sorted
  list of `{time, event}` from data, not hardcoded.

### 4.7 Map & shrines
Hand-authored `TileMapLayer` chunks; landmarks as placed scenes. Shrines hold their
Vestige id, spawn their Shrinekeeper on proximity, and emit `vestige_claimed`. The
Thread-of-the-Rosary guide is a shader-driven ground ribbon fed the nearest-unclaimed-
shrine position — no pathfinding needed (map is mostly open; the thread points as the
crow flies and bends around fire rivers via 4–5 authored waypoints per shrine).

### 4.8 Save system
`MetaSave.gd` → `user://save.json` (Godot maps this correctly per platform, including
iOS/Android sandboxes). Content: ossuary marks, blessings bought, characters/stages
unlocked, vestige book, settings, stats. Versioned (`save_version`) with tiny migration
functions from day 1. Atomic write (write temp, rename). **No mid-run saving in v1**
(runs are 25 min; mobile suspend → Godot pauses the tree; process-death mid-run loses
the run — acceptable for v1, revisit for mobile launch with a periodic run-snapshot).

## 5. Data-Driven Content (the contract)

Example — `data/weapons/thurible.tres` (a `WeaponData` resource):

```gdscript
class_name WeaponData extends Resource
@export var id: StringName            # &"thurible"
@export var display_name: String      # "The Thurible"
@export var flavor: String            # draft-card flavour text
@export var archetype: StringName     # &"swing_arc"
@export var rarity: int               # 0..3
@export var tags: Array[StringName]   # [&"fire", &"melee"]
@export var icon: Texture2D
@export var projectile_scene: PackedScene
@export var levels: Array[Dictionary] # [{dmg:12, arc:100, cd:1.4}, ... x8]
@export var exalts_into: WeaponData   # null or the exaltation
@export var exalt_requires: StringName# passive id
```

`EnemyData`, `PassiveData`, `CharacterData`, `WaveTable`, `BlessingData` follow the same
pattern. Everything balance-tunable lives in `levels`/curve arrays. This is the single
most important architectural decision: **content velocity without code risk.**

## 6. Performance Plan (the 500-enemy problem)

The one hard technical problem in this genre. Plan, in order of importance:

1. **Enemies are not Nodes.** The horde lives in `horde.gd` as struct-of-arrays
   (`PackedVector2Array` positions/velocities, `PackedFloat32Array` hp, `PackedInt32Array`
   type ids, state flags). Rendering via **`MultiMeshInstance2D`** (one per enemy
   sprite-sheet, per-instance custom data selects animation frame in a shader). No
   physics bodies, no per-enemy scripts. This is the difference between 150 and 1000+
   enemies at 60 fps, and it must be built this way from the first prototype — it does
   not retrofit.
2. **Spatial hash grid** (cell ≈ max enemy radius ×2) rebuilt each frame for:
   enemy↔player contact, enemy↔enemy soft separation (sampled — each enemy resolves
   against ≤3 neighbours per frame, alternating frames), and weapon hit queries.
3. **Movement:** default chase = normalize(player − pos) × speed + separation push;
   special movers (Wailers' drift, Furies' dive) are per-type velocity functions in the
   same sim, switch on type id. No A*; obstacles are sparse and handled by slide-along-
   collision sampling of the map's collision bitmap.
4. **Pooling everything transient:** projectiles, embers, damage numbers, hit-flashes,
   audio players. Zero `instantiate()` in the combat loop after warm-up.
5. **Frame budgets:** sim ≤ 4 ms, weapons+damage ≤ 2 ms, render prep ≤ 2 ms on the Mac;
   ×2.5 headroom rule for mobile. Profile from week 2 with a debug overlay (enemy count,
   frame ms, pool stats) toggled by hotkey.
6. **Elites/bosses are ordinary Nodes** (there are ≤ 8 alive ever) — they get real
   AnimationPlayers, hitbox shapes and behavior trees. Two-tier enemy architecture:
   cheap masses + rich few.

## 7. Testing & Tooling

- **GUT** (Godot Unit Test, MIT) for pure logic: StatBlock stacking, draft eligibility,
  XP curve, loot rolls, save migration. These are the systems where silent bugs ruin
  balance.
- **Sim harness:** a headless "auto-play" scene (bot walks in circles, weapons max level)
  run via `godot --headless` in CI to smoke-test perf counters and crash-freedom for a
  full 25-min run at 8× time scale.
- **CI (GitHub Actions):** on push — GUT tests, headless sim, export macOS/Windows/Linux/
  Web artifacts. Free runners cover all of it; Mac runner does the .app export.
- **Debug cheats** behind `OS.is_debug_build()`: give-weapon, time-skip, spawn-wave,
  god-mode, show-spatial-grid.

## 8. Coding Conventions

- Static typing everywhere (`var hp: float`), `class_name` on shared types, signals over
  node-path reaching, autoloads only for the six listed (resist singleton creep).
- IDs are `StringName`s defined once in the data files; no magic strings in code.
- One scene = one responsibility; scene inheritance only for elites.
- Frame-rate independence: all gameplay in `_physics_process` at fixed 60 Hz tick;
  rendering interpolation on (Godot 4.3+ physics interpolation) so 120 Hz displays are
  smooth and slow devices degrade gracefully.
