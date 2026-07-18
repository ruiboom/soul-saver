extends Node2D
class_name Weapons
## The relics act of their own sanctity. Anselm just carries them.
## One handler per relic; persistent visuals (rosary beads, orbiting censer) live here.

var horde: Horde
var player: Player
var zones: Zones
var projectiles: Projectiles
var run

var slots: Array[Dictionary] = []      # {id, cd}  (level/exalted live in RunState)
var surge_t := 0.0                     # Censer Coal: cooldowns twice as fast

# persistent visuals
var _beads: Array[Sprite2D] = []
var _bead_angle := 0.0
var _censers: Array[Sprite2D] = []     # swing visuals pool
var _orbit_censer: Sprite2D = null
var _orbit_angle := 0.0
var _sword_sprite: Sprite2D = null
var _sword_t := -1.0
var _sword_orbit_angle := 0.0
var _rings: Array[Dictionary] = []     # bell shockwaves {pos, r, max_r, t}
var _pillars: Array[Dictionary] = []   # {pos, t, r}  t<0 telegraph
var _crown_angle := 0.0
var _rosary_hit_cd := 0.0
var _smoke_drop_cd := 0.0

func has_weapon(id: StringName) -> bool:
	for s in slots:
		if s["id"] == id:
			return true
	return false

func add_weapon(id: StringName) -> void:
	if has_weapon(id):
		var cur: Dictionary = RunState.weapons[id]
		cur["level"] = mini(Data.MAX_WEAPON_LEVEL, int(cur["level"]) + 1)
	else:
		RunState.weapons[id] = {"level": 1, "exalted": false}
		slots.append({"id": id, "cd": 0.3})
	_refresh_persistent()

func exalt_weapon(id: StringName) -> void:
	if RunState.weapons.has(id):
		RunState.weapons[id]["exalted"] = true
	_refresh_persistent()
	run.vfx.holy_flash(player.global_position, 30)
	AudioDirector.play(&"fanfare", -2.0)

func _params(id: StringName) -> Dictionary:
	var p := Data.weapon_params(id, RunState.weapon_level(id), RunState.is_exalted(id))
	p["dmg"] = float(p["dmg"]) * RunState.might
	for k in ["range", "radius", "orbit_r", "pool_r", "arc"]:
		if p.has(k):
			p[k] = float(p[k]) * RunState.area
	return p

func tick(dt: float) -> void:
	surge_t = maxf(0.0, surge_t - dt)
	var cd_rate := (2.0 if surge_t > 0.0 else 1.0) * RunState.haste
	for s in slots:
		s["cd"] = float(s["cd"]) - dt * cd_rate
		var id: StringName = s["id"]
		var p := _params(id)
		if float(s["cd"]) <= 0.0:
			var refire := _fire(id, p)
			s["cd"] = float(p.get("cd", 1.0)) if refire else 0.25
	_tick_persistent(dt)
	queue_redraw()

func _fire(id: StringName, p: Dictionary) -> bool:
	match id:
		&"thurible": return _fire_thurible(p)
		&"holy_water": return _fire_holy_water(p)
		&"psalter": return _fire_psalter(p)
		&"paten": return _fire_paten(p)
		&"bell": return _fire_bell(p)
		&"pillar": return _fire_pillar(p)
		&"crown": return _fire_crown(p)
		&"sword": return _fire_sword(p)
		&"rosary": return true   # persistent — no discrete fire
	return true

# ---------------------------------------------------------------- THURIBLE
func _fire_thurible(p: Dictionary) -> bool:
	if RunState.is_exalted(&"thurible"):
		return true   # handled continuously in _tick_persistent
	var ppos := player.global_position
	var dir := Vector2(player.facing, 0.0)
	var amount := int(p.get("amount", 1))
	for k in amount:
		var d := dir if k == 0 else -dir
		var hits := horde.query_arc(ppos, d, float(p["range"]), deg_to_rad(float(p["arc"]) / 2.0))
		for hk in range(hits.size() - 1, -1, -1):   # descending: swap-remove safe
			run.hit_enemy(hits[hk], float(p["dmg"]), [&"fire"], ppos)
		var mid := ppos + d * float(p["range"]) * 0.6
		run.hit_others_at(mid, float(p["range"]) * 0.5, float(p["dmg"]), [&"fire"])
		zones.add_zone(&"smoke", mid, float(p["range"]) * 0.42, float(p["smoke_dmg"]) * RunState.might, float(p["smoke_dur"]))
		_swing_visual(d, float(p["range"]))
	AudioDirector.play(&"whoosh", -8.0)
	return true

func _swing_visual(dir: Vector2, range_px: float) -> void:
	var c: Sprite2D = null
	for s in _censers:
		if not s.visible:
			c = s
			break
	if c == null:
		c = Sprite2D.new()
		c.texture = load("res://assets/proj/censer.svg")
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		c.material = mat
		add_child(c)
		_censers.append(c)
	c.visible = true
	c.modulate = Color(1.6, 1.4, 1.0, 1.0)
	var base_a := dir.angle()
	var tw := create_tween()
	var from_a := base_a - 1.2
	var dur := 0.34
	tw.tween_method(func(t: float) -> void:
		var a := lerpf(from_a, base_a + 1.2, t)
		c.global_position = player.global_position + Vector2.from_angle(a) * range_px * 0.72
		c.rotation = a + PI / 2.0
	, 0.0, 1.0, dur)
	tw.parallel().tween_property(c, "modulate:a", 0.0, dur).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void: c.visible = false)

# ---------------------------------------------------------------- HOLY WATER
func _fire_holy_water(p: Dictionary) -> bool:
	var ppos := player.global_position
	for k in int(p.get("amount", 1)):
		var target: Vector2
		var idx := horde.nearest(ppos, 640.0)
		if idx >= 0:
			target = horde.pos[idx] + Vector2(randf_range(-60, 60), randf_range(-60, 60))
		else:
			target = ppos + Vector2.from_angle(randf() * TAU) * randf_range(180, 420)
		var dir := (target - ppos).normalized()
		var dist := ppos.distance_to(target)
		var flight := 0.55
		var pr := float(p["pool_r"]) * (1.3 if RunState.is_exalted(&"holy_water") else 1.0)
		var pdur := float(p["pool_dur"])
		var pdmg := float(p["dmg"])
		projectiles.fire(&"vial", ppos, dir, {
			"speed": dist / flight, "life": flight, "target": target, "vis_scale": 1.3,
			"on_land": func(at: Vector2) -> void:
				zones.add_zone(&"pool", at, pr, pdmg, pdur)
				run.vfx.holy_flash(at, 6)
				AudioDirector.play(&"holy_impact", -10.0),
		})
	return true

# ---------------------------------------------------------------- PSALTER
func _fire_psalter(p: Dictionary) -> bool:
	var ppos := player.global_position
	var n := int(p.get("amount", 1))
	var targets := horde.nearest_n(ppos, 760.0, n)
	for k in n:
		var dir: Vector2
		if k < targets.size():
			dir = (horde.pos[targets[k]] - ppos).normalized()
		else:
			dir = Vector2.from_angle(randf() * TAU)
		projectiles.fire(&"verse", ppos + dir * 30.0, dir, {
			"speed": float(p["speed"]), "dmg": float(p["dmg"]), "pierce": int(p["pierce"]),
			"life": 1.6, "vis_scale": 1.1,
		})
	AudioDirector.play(&"holy_impact", -14.0, 0.1)
	return true

# ---------------------------------------------------------------- PATEN
func _fire_paten(p: Dictionary) -> bool:
	var ppos := player.global_position
	var n := int(p.get("amount", 1))
	var base := Vector2(player.facing, 0.0).angle()
	var nearest := horde.nearest(ppos, 700.0)
	if nearest >= 0:
		base = (horde.pos[nearest] - ppos).angle()
	for k in n:
		var a := base + (float(k) - float(n - 1) / 2.0) * 0.5
		projectiles.fire(&"paten", ppos, Vector2.from_angle(a), {
			"speed": float(p["speed"]), "dmg": float(p["dmg"]), "pierce": 999,
			"life": 1.7, "vis_scale": 1.15,
		})
	AudioDirector.play(&"whoosh", -10.0, 0.1)
	return true

# ---------------------------------------------------------------- BELL
func _fire_bell(p: Dictionary) -> bool:
	var ppos := player.global_position
	var r := float(p["radius"])
	var hits := horde.query_circle(ppos, r)
	var stun := float(p["stun"]) * (1.5 if RunState.is_exalted(&"bell") else 1.0)
	for k in range(hits.size() - 1, -1, -1):
		var idx := hits[k]
		if not run.hit_enemy(idx, float(p["dmg"]), [&"holy"], ppos, false):
			horde.apply_stagger(idx, stun)
	run.hit_others_at(ppos, r, float(p["dmg"]), [&"holy"])
	_rings.append({"pos": ppos, "r": 30.0, "max_r": r, "t": 0.0})
	AudioDirector.play(&"shockwave", -6.0)
	run.camera.shake(4.0)
	return true

# ---------------------------------------------------------------- PILLAR
func _fire_pillar(p: Dictionary) -> bool:
	var ppos := player.global_position
	var n := int(p.get("amount", 1))
	var found := horde.query_circle(ppos, 680.0)
	for k in n:
		var at: Vector2
		if found.size() > 0:
			at = horde.pos[found[Rngs.spawn.randi_range(0, found.size() - 1)]]
		else:
			at = ppos + Vector2.from_angle(randf() * TAU) * randf_range(140, 420)
		_pillars.append({"pos": at, "t": -0.38, "r": float(p["radius"]), "dmg": float(p["dmg"])})
	return true

# ---------------------------------------------------------------- CROWN
func _fire_crown(p: Dictionary) -> bool:
	var ppos := player.global_position
	var r := float(p["radius"])
	var hits := horde.query_circle(ppos, r)
	var exalted := RunState.is_exalted(&"crown")
	for k in range(hits.size() - 1, -1, -1):
		var died: bool = run.hit_enemy(hits[k], float(p["dmg"]), [&"holy"], ppos, false)
		if died and exalted:
			RunState.heal(1.0)
	run.hit_others_at(ppos, r, float(p["dmg"]), [&"holy"])
	return true

func crown_retaliate(enemy_idx: int) -> void:
	if not has_weapon(&"crown"):
		return
	var p := _params(&"crown")
	run.hit_enemy(enemy_idx, float(p["dmg"]) * 3.0, [&"holy"], player.global_position)

# ---------------------------------------------------------------- SWORD
func _fire_sword(p: Dictionary) -> bool:
	if RunState.is_exalted(&"sword"):
		return true   # persistent orbit handled in _tick_persistent
	var ppos := player.global_position
	var r := float(p["radius"])
	var hits := horde.query_circle(ppos, r)
	for k in range(hits.size() - 1, -1, -1):
		run.hit_enemy(hits[k], float(p["dmg"]), [&"holy"], ppos)
	run.hit_others_at(ppos, r, float(p["dmg"]), [&"holy"])
	_sword_t = 0.0
	_ensure_sword(r)
	AudioDirector.play(&"whoosh", -4.0, 0.05)
	run.camera.shake(3.0)
	return true

func _ensure_sword(r: float) -> void:
	if _sword_sprite == null:
		_sword_sprite = Sprite2D.new()
		_sword_sprite.texture = load("res://assets/proj/sword.svg")
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_sword_sprite.material = mat
		_sword_sprite.modulate = Color(1.5, 1.5, 1.4)
		add_child(_sword_sprite)
	_sword_sprite.visible = true
	_sword_sprite.scale = Vector2.ONE * (r / 190.0)

# ---------------------------------------------------------------- persistent visuals & effects
func _refresh_persistent() -> void:
	# rosary beads
	if has_weapon(&"rosary"):
		var p := _params(&"rosary")
		var want := int(p.get("amount", 3)) * (2 if RunState.is_exalted(&"rosary") else 1)
		while _beads.size() < want:
			var b := Sprite2D.new()
			b.texture = load("res://assets/proj/bead.svg")
			b.scale = Vector2.ONE * 1.15
			var mat := CanvasItemMaterial.new()
			mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			b.material = mat
			b.modulate = Color(1.5, 1.35, 1.0)
			add_child(b)
			_beads.append(b)
		while _beads.size() > want:
			_beads.pop_back().queue_free()
	# exalted thurible orbiter
	if RunState.is_exalted(&"thurible") and _orbit_censer == null:
		_orbit_censer = Sprite2D.new()
		_orbit_censer.texture = load("res://assets/proj/censer.svg")
		var mat := CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_orbit_censer.material = mat
		_orbit_censer.modulate = Color(1.7, 1.5, 1.1)
		_orbit_censer.scale = Vector2.ONE * 1.2
		add_child(_orbit_censer)
	if RunState.is_exalted(&"sword"):
		_ensure_sword(float(_params(&"sword")["radius"]))

func _tick_persistent(dt: float) -> void:
	var ppos := player.global_position
	# rosary orbit
	if has_weapon(&"rosary") and _beads.size() > 0:
		var p := _params(&"rosary")
		_bead_angle += dt * float(p["orbit_speed"])
		var r := float(p["orbit_r"])
		var exalted := RunState.is_exalted(&"rosary")
		var half := _beads.size() / 2 if exalted else _beads.size()
		for i in _beads.size():
			var ring2 := exalted and i >= half
			var n := (half if not ring2 else _beads.size() - half)
			var local_i := i if not ring2 else i - half
			var a := TAU * float(local_i) / maxf(1.0, float(n)) + (_bead_angle if not ring2 else -_bead_angle * 1.3)
			var rr := r if not ring2 else r * 1.45
			_beads[i].global_position = ppos + Vector2.from_angle(a) * rr
		_rosary_hit_cd -= dt
		if _rosary_hit_cd <= 0.0:
			_rosary_hit_cd = 0.14
			for b in _beads:
				var hits := horde.query_circle(b.global_position, 30.0)
				for k in range(hits.size() - 1, -1, -1):
					run.hit_enemy(hits[k], float(p["dmg"]), [&"holy"], b.global_position, false)
				run.hit_others_at(b.global_position, 30.0, float(p["dmg"]) * 0.5, [&"holy"])
	# exalted thurible orbit + smoke trail
	if _orbit_censer != null:
		var p := _params(&"thurible")
		_orbit_angle += dt * 3.4
		var opos := ppos + Vector2.from_angle(_orbit_angle) * float(p["range"]) * 0.9
		_orbit_censer.global_position = opos
		_orbit_censer.rotation = _orbit_angle + PI / 2.0
		var hits := horde.query_circle(opos, 46.0)
		for k in range(hits.size() - 1, -1, -1):
			run.hit_enemy(hits[k], float(p["dmg"]) * 0.35, [&"fire"], opos, false)
		_smoke_drop_cd -= dt
		if _smoke_drop_cd <= 0.0:
			_smoke_drop_cd = 0.55
			zones.add_zone(&"smoke", opos, 80.0, float(p["smoke_dmg"]) * RunState.might, 1.6)
	# sword sweep animation / exalted orbit
	if _sword_sprite != null:
		if RunState.is_exalted(&"sword"):
			var p := _params(&"sword")
			_sword_orbit_angle += dt * 1.6
			var r := float(p["radius"]) * 0.8
			var bpos := ppos + Vector2.from_angle(_sword_orbit_angle) * r
			_sword_sprite.global_position = bpos
			_sword_sprite.rotation = _sword_orbit_angle + PI
			_sword_sprite.visible = true
			for step in 3:
				var sp := ppos + Vector2.from_angle(_sword_orbit_angle) * r * (0.55 + 0.3 * float(step))
				var hits := horde.query_circle(sp, 50.0)
				for k in range(hits.size() - 1, -1, -1):
					run.hit_enemy(hits[k], float(p["dmg"]) * 0.12, [&"holy"], sp, false)
		elif _sword_t >= 0.0:
			_sword_t += dt
			var dur := 0.5
			if _sword_t >= dur:
				_sword_t = -1.0
				_sword_sprite.visible = false
			else:
				var a := TAU * (_sword_t / dur) - PI / 2.0
				var p := _params(&"sword")
				_sword_sprite.global_position = ppos + Vector2.from_angle(a) * float(p["radius"]) * 0.62
				_sword_sprite.rotation = a + PI
				_sword_sprite.modulate.a = 1.0 - _sword_t / dur * 0.5
	# bell rings
	var i := 0
	while i < _rings.size():
		var ring := _rings[i]
		ring["t"] = float(ring["t"]) + dt
		ring["r"] = lerpf(float(ring["r"]), float(ring["max_r"]) * 1.15, dt * 9.0)
		if float(ring["t"]) > 0.55:
			_rings.remove_at(i)
		else:
			i += 1
	# pillars
	i = 0
	while i < _pillars.size():
		var pl := _pillars[i]
		pl["t"] = float(pl["t"]) + dt
		var t := float(pl["t"])
		if t >= 0.0 and not pl.has("struck"):
			pl["struck"] = true
			var at: Vector2 = pl["pos"]
			var hits := horde.query_circle(at, float(pl["r"]))
			for k in range(hits.size() - 1, -1, -1):
				run.hit_enemy(hits[k], float(pl["dmg"]), [&"holy"], at)
			run.hit_others_at(at, float(pl["r"]), float(pl["dmg"]), [&"holy"])
			zones.add_zone(&"pillar", at, float(pl["r"]) * 0.8, float(pl["dmg"]) * 0.15, 0.8)
			run.vfx.holy_flash(at, 12)
			AudioDirector.play(&"holy_impact", -6.0, 0.12)
		if t > 0.30:
			_pillars.remove_at(i)
		else:
			i += 1
	# crown ring rotates
	_crown_angle += dt * 0.8

func _draw() -> void:
	var ppos := to_local(player.global_position)
	# bell shockwaves
	for ring in _rings:
		var alpha: float = clampf(1.0 - float(ring["t"]) / 0.55, 0.0, 1.0)
		var at := to_local(ring["pos"])
		draw_arc(at, float(ring["r"]), 0, TAU, 64, Color(1.8, 1.6, 1.1, 0.55 * alpha), 10.0 * alpha + 2.0)
		draw_arc(at, float(ring["r"]) * 0.86, 0, TAU, 64, Color(1.3, 1.2, 0.9, 0.3 * alpha), 4.0)
	# pillar telegraphs + beams
	for pl in _pillars:
		var t := float(pl["t"])
		var at := to_local(pl["pos"])
		var r := float(pl["r"])
		if t < 0.0:
			var prog := 1.0 + t / 0.38
			draw_arc(at, r * prog, 0, TAU, 48, Color(1.6, 1.4, 0.9, 0.5), 3.0)
			draw_circle(at, r * prog * 0.4, Color(1.4, 1.3, 0.9, 0.12))
		else:
			var fade := 1.0 - t / 0.30
			for step in 4:
				var w := r * (0.9 - 0.2 * float(step))
				draw_rect(Rect2(at.x - w / 2.0, at.y - 900.0, w, 900.0), Color(1.9, 1.75, 1.3, 0.16 * fade))
			draw_circle(at, r * fade, Color(2.0, 1.8, 1.3, 0.4 * fade))
	# crown of thorns aura
	if has_weapon(&"crown"):
		var p := _params(&"crown")
		var r := float(p["radius"])
		var exalted := RunState.is_exalted(&"crown")
		var col := Color(1.5, 1.3, 0.8, 0.30) if exalted else Color(0.9, 0.75, 0.5, 0.22)
		draw_arc(ppos, r, 0, TAU, 48, col, 5.0)
		for k in 10:
			var a := _crown_angle + TAU * float(k) / 10.0
			var tip := ppos + Vector2.from_angle(a) * r
			draw_line(tip - Vector2.from_angle(a) * 14.0, tip + Vector2.from_angle(a) * 6.0, Color(1.2, 1.0, 0.6, 0.5), 3.0)
