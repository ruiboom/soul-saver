extends Node2D
## The run orchestrator: builds the world, owns the update order, runs the timeline
## (bells → heralds → Warden → endings), and is the single damage/loot choke point.

var map: AshenReaches
var player: Player
var horde: Horde
var embers: Embers
var projectiles: Projectiles
var zones: Zones
var weapons: Weapons
var vfx: Vfx
var spawner: SpawnDirector
var camera: GameCamera
var hud: Hud
var draft: Draft
var overlays: Overlays
var warden: Warden = null

var elites: Array[Elite] = []
var _pending_drafts := 0
var _shrine_keeper_active: Array = [false, false, false, false, false, false, false]
var _gate_prompt: Label = null
var _ended := false
var _autotest := false
var _autotest_t := 0.0
var _ambient: GPUParticles2D

var _quest := false
func _ready() -> void:
	_autotest = OS.get_environment("SOULSAVER_AUTOTEST") == "1"
	_quest = OS.get_environment("SOULSAVER_QUEST") == "1"
	var ts := OS.get_environment("SOULSAVER_TIMESCALE")
	if ts != "":
		Engine.time_scale = ts.to_float()
	_build_world()
	_connect_signals()
	AudioDirector.music_start()
	AudioDirector.set_intensity(0.1)
	hud.announce("Bell I — Vespers. Find her, Father.", Data.GOLD)
	_malacoda_apparition()
	if _autotest:
		player.auto_move = true
		overlays.autotest_autoclose = true

func _build_world() -> void:
	# environment: darkness + bloom
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.55
	env.glow_strength = 1.03
	env.glow_bloom = 0.1
	env.glow_hdr_threshold = 1.05
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)
	var cm := CanvasModulate.new()
	cm.color = Color(0.58, 0.53, 0.63)
	add_child(cm)

	map = AshenReaches.new()
	map.run = self
	add_child(map)

	zones = Zones.new()
	zones.z_index = 1
	add_child(zones)

	embers = Embers.new()
	embers.z_index = 4
	add_child(embers)

	horde = Horde.new()
	horde.z_index = 5
	add_child(horde)

	projectiles = Projectiles.new()
	projectiles.z_index = 8
	add_child(projectiles)

	player = Player.new()
	player.global_position = Vector2(0, 260)
	add_child(player)

	weapons = Weapons.new()
	weapons.z_index = 9
	add_child(weapons)

	vfx = Vfx.new()
	vfx.z_index = 12
	add_child(vfx)

	camera = GameCamera.new()
	camera.target = player
	add_child(camera)
	camera.make_current()

	_ambient = _make_ash_particles()
	camera.add_child(_ambient)

	# wire references
	map.player = player
	map.camera = camera
	player.map = map
	horde.player = player
	horde.on_death = _on_enemy_death
	horde.on_contact = _on_enemy_contact
	embers.player = player
	projectiles.horde = horde
	projectiles.player = player
	projectiles.run = self
	zones.horde = horde
	zones.player = player
	zones.run = self
	weapons.horde = horde
	weapons.player = player
	weapons.zones = zones
	weapons.projectiles = projectiles
	weapons.run = self
	spawner = SpawnDirector.new()
	spawner.horde = horde
	spawner.player = player
	add_child(spawner)

	# UI
	var ui := CanvasLayer.new()
	ui.layer = 10
	add_child(ui)
	hud = Hud.new()
	hud.run = self
	ui.add_child(hud)
	draft = Draft.new()
	draft.run = self
	add_child(draft)
	draft.closed.connect(_on_draft_closed)
	overlays = Overlays.new()
	overlays.run = self
	add_child(overlays)

	# starting weapon: the Thurible
	weapons.add_weapon(&"thurible")

func _malacoda_apparition() -> void:
	# the Clerk himself, come to gloat — an ink-ghost by the Gate
	var m := Sprite2D.new()
	m.texture = load("res://assets/sprites/enemy_scribe.svg")
	m.scale = Vector2.ONE * 1.6
	m.global_position = Vector2(240, 120)
	m.modulate = Color(0.7, 0.8, 1.4, 0.0)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	m.material = mat
	m.z_index = 9
	add_child(m)
	var tw := create_tween()
	tw.tween_property(m, "modulate:a", 0.75, 1.2)
	tw.tween_interval(1.0)
	tw.tween_callback(func() -> void:
		hud.announce("“One fragment, priest. Take one and go.\nShe won't miss her name.”  — Malacoda", Color(0.7, 0.8, 1.2)))
	tw.tween_property(m, "position:y", 60.0, 4.0)
	tw.tween_property(m, "modulate:a", 0.0, 1.4)
	tw.tween_callback(m.queue_free)

func _make_ash_particles() -> GPUParticles2D:
	var p := GPUParticles2D.new()
	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(1100, 640, 0)
	mat.direction = Vector3(-0.3, 0.5, 0)
	mat.spread = 20.0
	mat.initial_velocity_min = 12.0
	mat.initial_velocity_max = 42.0
	mat.gravity = Vector3(0, 8, 0)
	mat.scale_min = 1.2
	mat.scale_max = 3.4
	mat.color = Color(0.55, 0.5, 0.55, 0.35)
	p.process_material = mat
	p.amount = 140
	p.lifetime = 9.0
	p.preprocess = 9.0
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	img.fill(Color(1, 1, 1, 0.5))
	p.texture = ImageTexture.create_from_image(img)
	p.local_coords = false
	return p

func _connect_signals() -> void:
	RunState.leveled_up.connect(_on_leveled_up)

# ---------------------------------------------------------------- main loop
func _physics_process(delta: float) -> void:
	if _ended:
		return
	var dt := delta
	RunState.time += dt
	vfx.begin_frame()
	player.tick(dt)
	horde.tick(dt, embers)
	for e in elites:
		e.tick(dt)
	if warden and warden.alive:
		warden.tick(dt)
	spawner.tick(dt)
	projectiles.tick(dt)
	zones.tick(dt)
	weapons.tick(dt)
	embers.tick(dt)   # after all weapons: kills this frame render their pill this frame
	map.tick(dt)
	_timeline(dt)
	_shrine_logic()
	_death_check()
	_update_music()
	if _autotest:
		_autotest_tick(dt)

func _timeline(_dt: float) -> void:
	var t := RunState.time
	# bell advance
	var next_bell := RunState.bell + 1
	if next_bell < Data.BELLS.size() and t >= float(Data.BELLS[next_bell]["time"]):
		RunState.bell = next_bell
		RunState.bell_tolled.emit(next_bell)
		AudioDirector.bell()
		camera.shake(7.0)
		hud.announce("Bell %s — %s" % [hud._roman(next_bell + 1), Data.BELLS[next_bell]["name"]], Color(1.0, 0.55, 0.3))
		_spawn_herald()
	# the Warden
	if not RunState.warden_spawned and t >= Data.WARDEN_TIME:
		RunState.warden_spawned = true
		_spawn_warden()
	# survivor ending
	if RunState.warden_spawned and warden and warden.alive and t >= Data.SURVIVOR_TIME:
		_finish(&"survivor")

func _spawn_herald() -> void:
	var e := Elite.new()
	e.run = self
	var patterns: Array = [&"charge", &"spit", &"summon"]
	e.setup({
		"hp": 260.0 + RunState.bell * 220.0,
		"pattern": patterns[RunState.bell % 3],
		"name": "Herald of Bell %s" % hud._roman(RunState.bell + 1),
		"speed": 135.0, "dmg": 16.0 + RunState.bell * 4.0,
		"tint": Color(1.15, 0.75, 0.6), "scale": 0.85,
	})
	e.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * 1000.0
	add_child(e)
	elites.append(e)
	AudioDirector.play(&"roar", -6.0)

func _spawn_warden() -> void:
	warden = Warden.new()
	warden.run = self
	warden.global_position = player.global_position + Vector2.from_angle(randf() * TAU) * 900.0
	add_child(warden)
	hud.announce("THE WARDEN RISES", Color(1.2, 0.4, 0.25))
	camera.shake(14.0)
	AudioDirector.bell()
	AudioDirector.set_intensity(1.0)
	# if the vestiges are gathered, the Gate begins to wake
	if RunState.vestige_count() == 7:
		_open_gate_delayed()

func _open_gate_delayed() -> void:
	var tw := create_tween()
	tw.tween_interval(90.0)
	tw.tween_callback(_open_gate)

func _open_gate() -> void:
	if _ended:
		return
	map.gate_open = true
	AudioDirector.play(&"gate_open", 0.0, 0.0)
	hud.announce("THE GATE OF DAWN OPENS", Data.HALO)
	hud.set_arrow_target(Vector2.ZERO)

# ---------------------------------------------------------------- shrines & gate
func _shrine_logic() -> void:
	var nearest_unclaimed := Vector2.INF
	var best_d := 1e18
	for sh in map.shrines:
		var i := sh.index
		var d := player.global_position.distance_squared_to(sh.global_position)
		if sh.state != Shrine.State.CLAIMED and d < best_d:
			best_d = d
			nearest_unclaimed = sh.global_position
		match sh.state:
			Shrine.State.LOCKED:
				if d < 640.0 * 640.0 and not _shrine_keeper_active[i]:
					_shrine_keeper_active[i] = true
					sh.state = Shrine.State.FIGHTING
					_spawn_keeper(sh)
			Shrine.State.CLAIMABLE:
				if d < 230.0 * 230.0 and (Input.is_action_just_pressed(&"interact") or _autotest):
					_claim_vestige(sh)
	if map.gate_open:
		nearest_unclaimed = Vector2.ZERO
		if player.global_position.length() < 240.0:
			_finish(&"true")
	hud.set_arrow_target(nearest_unclaimed)

func _spawn_keeper(sh: Shrine) -> void:
	var cfg: Dictionary = (Data.KEEPERS[sh.index] as Dictionary).duplicate()
	cfg["shrine_index"] = sh.index
	cfg["hp"] = float(cfg["hp"]) * (1.0 + RunState.bell * 0.35)
	cfg["speed"] = 110.0
	cfg["dmg"] = 20.0
	var e := Elite.new()
	e.run = self
	e.setup(cfg)
	e.global_position = sh.global_position + Vector2(0, 140)
	add_child(e)
	elites.append(e)
	hud.announce(String(cfg["name"]), Color(0.85, 0.6, 1.0))
	AudioDirector.play(&"roar", -4.0)

func _claim_vestige(sh: Shrine) -> void:
	sh.state = Shrine.State.CLAIMED
	RunState.claim_vestige(sh.index)
	RunState.add_marks(8)
	overlays.show_vignette(sh.index, func() -> void:
		if RunState.vestige_count() == 7:
			hud.announce("All seven. Now — survive until matins.", Data.GRACE)
			if RunState.warden_spawned:
				_open_gate()
	)

# ---------------------------------------------------------------- damage choke points
func hit_enemy(idx: int, dmg: float, tags: Array, at: Vector2, show_number: bool = true) -> bool:
	if idx < 0 or idx >= horde.count:
		return false
	var epos := horde.pos[idx]
	var died := horde.damage(idx, dmg, tags, at)
	if not died and show_number:
		vfx.damage_number(epos, dmg)
		vfx.hit_spark(epos)
	return died

func hit_others_at(at: Vector2, radius: float, dmg: float, tags: Array) -> bool:
	## Elites, the Warden and bone piles share one path so every weapon hits them.
	var any := false
	for e in elites:
		if e.global_position.distance_to(at) < radius + e.radius:
			e.damage(dmg, tags)
			vfx.damage_number(e.global_position, dmg)
			vfx.hit_spark(e.global_position)
			any = true
	if warden and warden.alive and warden.global_position.distance_to(at) < radius + 150.0:
		warden.damage(dmg, tags)
		vfx.damage_number(warden.global_position + Vector2(0, -120), dmg)
		any = true
	map.hit_bone_piles(at, radius, dmg)
	return any

func hit_elites_at(at: Vector2, radius: float, dmg: float, tags: Array) -> bool:
	return hit_others_at(at, radius, dmg, tags)

func _on_enemy_death(at: Vector2, type_name: StringName, xp: int, stolen: float) -> void:
	RunState.kills += 1
	embers.spawn(at, float(xp) + stolen * 2.0)
	vfx.enemy_death(at, xp >= 4)
	AudioDirector.play(&"death_puff", -10.0, 0.25, 50)
	if type_name == &"bloatgrub":
		zones.add_zone(&"acid", at, 85.0, 8.0, 3.0)
	elif type_name == &"scribe" and stolen <= 0.0:
		RunState.add_marks(1)

func _on_enemy_contact(idx: int) -> void:
	weapons.crown_retaliate(idx)
	camera.shake(2.5)

func on_elite_death(e: Elite) -> void:
	var at := e.global_position
	vfx.enemy_death(at, true)
	vfx.holy_flash(at, 20)
	AudioDirector.play(&"fanfare", -6.0)
	camera.shake(5.0)
	embers.spawn(at, 40.0)
	RunState.add_marks(6 if e.shrine_index < 0 else 12)
	if e.shrine_index >= 0:
		var sh := map.shrines[e.shrine_index]
		sh.state = Shrine.State.CLAIMABLE
		hud.announce("The shrine lies open. Take her back.", Data.GRACE)
	else:
		map.drop_item(at, &"chrism" if randf() < 0.5 else &"wrath")
		_pending_drafts += 1
		_try_open_draft(true)
	elites.erase(e)
	e.queue_free()

func on_warden_death() -> void:
	vfx.holy_flash(warden.global_position, 60)
	camera.shake(18.0)
	AudioDirector.play(&"roar", 2.0, 0.0)
	AudioDirector.bell()
	embers.spawn(warden.global_position, 300.0)
	RunState.add_marks(40)
	warden.visible = false
	if RunState.vestige_count() == 7:
		_open_gate()
	else:
		_finish(&"survivor")

# ---------------------------------------------------------------- drafts / items / endings
func _on_leveled_up() -> void:
	_pending_drafts += 1
	_try_open_draft(false)

var _draft_free := false
func _try_open_draft(free_pick: bool) -> void:
	if draft.visible or overlays.visible or _pending_drafts <= 0:
		return
	_pending_drafts -= 1
	_draft_free = free_pick
	if _autotest:
		_autotest_pick_draft()
		return
	draft.open("The Reliquary Opens" if free_pick else "A relic stirs in the ash", free_pick)

func _on_draft_closed() -> void:
	if _pending_drafts > 0:
		_try_open_draft(false)

func apply_item(type: StringName, at: Vector2) -> void:
	match type:
		&"bread":
			RunState.heal(30.0)
			vfx.holy_flash(at, 6)
			AudioDirector.play(&"pickup", -6.0)
		&"chrism":
			embers.vacuum_all()
			vfx.holy_flash(player.global_position, 16)
			hud.announce("VIAL OF CHRISM — grace gathers to you", Data.GRACE)
			AudioDirector.play(&"levelup", -8.0)
		&"wrath":
			var hits := horde.query_circle(player.global_position, 1300.0)
			var slain := hits.size()
			for k in range(hits.size() - 1, -1, -1):   # back-to-front: swap-remove safe
				hit_enemy(hits[k], 220.0, [&"holy"], player.global_position, false)
			vfx.holy_flash(player.global_position, 60)
			hud.flash_white()
			hud.announce("WRATH OF THE LAMB — %d demons purged" % slain, Data.HALO)
			camera.shake(10.0)
			AudioDirector.play(&"shockwave", 0.0)
			AudioDirector.play(&"gate_open", -8.0)
		&"mark":
			RunState.add_marks(3)
			AudioDirector.play(&"pickup", -4.0)

func _death_check() -> void:
	if RunState.hp > 0.0 or _ended:
		return
	if RunState.revives > 0:
		RunState.revives -= 1
		RunState.passives.erase(&"palm")
		RunState.recompute()
		RunState.hp = RunState.maxhp * 0.5
		RunState.invuln = 2.0
		vfx.holy_flash(player.global_position, 40)
		hud.announce("The Martyr's Palm burns away — rise, Father.", Data.HALO)
		var hits := horde.query_circle(player.global_position, 500.0)
		for idx in hits:
			horde.apply_stagger(idx, 2.0)
		return
	_finish(&"death")

func _finish(kind: StringName) -> void:
	if _ended:
		return
	_ended = true
	RunState.over = true
	if kind == &"true":
		AudioDirector.play(&"gate_open", 0.0, 0.0)
	overlays.show_summary(kind)

func _update_music() -> void:
	var pressure := clampf(float(horde.count) / 420.0, 0.0, 0.85)
	if RunState.warden_spawned:
		pressure = 1.0
	AudioDirector.set_intensity(pressure + 0.12 * RunState.bell)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") and not draft.visible and not overlays.visible and not _ended:
		overlays.show_pause()
	if OS.is_debug_build() and event is InputEventKey and event.pressed:
		match (event as InputEventKey).physical_keycode:
			KEY_F2: RunState.add_grace(200.0)
			KEY_F3: RunState.time += 60.0
			KEY_F4: _spawn_herald()
			KEY_F6: RunState.god = not RunState.god
			KEY_F7: Engine.time_scale = 4.0 if Engine.time_scale == 1.0 else 1.0

# ---------------------------------------------------------------- autotest harness
var _shots_taken := 0
var _draft_shown := false
func _autotest_tick(dt: float) -> void:
	_autotest_t += dt
	RunState.god = OS.get_environment("SOULSAVER_MORTAL") != "1"
	if _quest:
		# walk the vestige circuit: nearest unclaimed shrine, then the open Gate
		var target := Vector2.ZERO
		var best := 1e18
		for sh in map.shrines:
			if sh.state != Shrine.State.CLAIMED:
				var d := player.global_position.distance_squared_to(sh.global_position)
				if d < best:
					best = d
					target = sh.global_position
		if map.gate_open or best == 1e18:
			target = Vector2.ZERO
		var to := target - player.global_position
		player.move_dir = to.normalized().rotated(sin(_autotest_t * 1.7) * 0.35) if to.length() > 90.0 else Vector2.ZERO
	else:
		# tight circle: stays inside the horde so screenshots show combat
		player.move_dir = Vector2.from_angle(_autotest_t * 0.9 + PI / 2.0)
		if _autotest_t > 8.0 and not _draft_shown:
			_draft_shown = true
			draft.open("A relic stirs in the ash", false)
			get_tree().paused = false   # keep the bot moving behind the cards
		elif _autotest_t > 11.5 and draft.visible:
			draft._close()
	if not draft.visible:
		_try_open_draft(false)
	var shot_times := [4.0, 10.0, 18.0, 26.0] if not _quest else [30.0, 120.0, 300.0, 500.0, 750.0, 960.0, 1085.0, 1170.0, 1230.0]
	if _shots_taken < shot_times.size() and _autotest_t >= float(shot_times[_shots_taken]):
		_shots_taken += 1
		_save_screenshot("shot_%d" % _shots_taken)
	var quit_after := float(OS.get_environment("SOULSAVER_QUIT_AFTER").to_float()) if OS.get_environment("SOULSAVER_QUIT_AFTER") != "" else 30.0
	if _autotest_t > quit_after:
		print("[autotest] done: enemies=%d fps=%d kills=%d level=%d" % [horde.count, Engine.get_frames_per_second(), RunState.kills, RunState.level])
		get_tree().quit()

func _save_screenshot(name: String) -> void:
	var dir := OS.get_environment("SOULSAVER_SHOT_DIR")
	if dir == "":
		return
	var img := get_viewport().get_texture().get_image()
	img.save_png(dir.path_join(name + ".png"))
	print("[autotest] shot %s enemies=%d fps=%d" % [name, horde.count, Engine.get_frames_per_second()])

func _autotest_pick_draft() -> void:
	var offers := draft._draw_offers(3)
	if offers.is_empty():
		return
	draft._pick(offers[Rngs.draft.randi_range(0, offers.size() - 1)])
	get_tree().paused = false
	draft.visible = false
