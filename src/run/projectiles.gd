extends Node2D
class_name Projectiles
## Pooled projectile system. Holy projectiles hit the horde; hostile ones hit the player.
## Types: verse (homing dart), paten (boomerang disc), vial (lobbed), spit (hostile).

var horde: Horde
var player: Node2D
var run
var live: Array[Dictionary] = []
var _pools: Dictionary = {}          # tex_path -> Array[Sprite2D]

func _get_sprite(tex_path: String, additive: bool = false) -> Sprite2D:
	var pool: Array = _pools.get_or_add(tex_path, [])
	var s: Sprite2D
	if pool.is_empty():
		s = Sprite2D.new()
		s.texture = load(tex_path)
		if additive:
			var mat := CanvasItemMaterial.new()
			mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			s.material = mat
		add_child(s)
	else:
		s = pool.pop_back()
	s.visible = true
	return s

func _free_sprite(p: Dictionary) -> void:
	var s: Sprite2D = p["sprite"]
	s.visible = false
	(_pools[p["tex"]] as Array).append(s)

func fire(type: StringName, from: Vector2, dir: Vector2, params: Dictionary) -> void:
	var tex := ""
	var additive := false
	match type:
		&"verse": tex = "res://assets/proj/verse.svg"; additive = true
		&"paten": tex = "res://assets/proj/paten.svg"
		&"vial": tex = "res://assets/proj/vial.svg"
		&"spit": tex = "res://assets/proj/spit.svg"; additive = true
	var s := _get_sprite(tex, additive)
	s.global_position = from
	s.rotation = dir.angle()
	s.scale = Vector2.ONE * float(params.get("vis_scale", 1.0))
	s.modulate = params.get("tint", Color(1.4, 1.3, 1.1) if type != &"spit" else Color(1.3, 1.5, 0.9))
	live.append({
		"type": type, "tex": tex, "sprite": s, "pos": from,
		"vel": dir * float(params.get("speed", 600.0)),
		"t": 0.0, "dmg": float(params.get("dmg", 10.0)),
		"pierce": int(params.get("pierce", 0)),
		"life": float(params.get("life", 2.2)),
		"target": params.get("target", Vector2.INF),
		"phase": 0, "hit_cd": 0.0,
		"on_land": params.get("on_land", Callable()),
		"radius": float(params.get("radius", 22.0)),
	})

func tick(dt: float) -> void:
	var i := 0
	while i < live.size():
		var p := live[i]
		p["t"] = float(p["t"]) + dt
		p["hit_cd"] = maxf(0.0, float(p["hit_cd"]) - dt)
		var done := false
		match p["type"]:
			&"verse": done = _tick_verse(p, dt)
			&"paten": done = _tick_paten(p, dt)
			&"vial": done = _tick_vial(p, dt)
			&"spit": done = _tick_spit(p, dt)
		var s: Sprite2D = p["sprite"]
		s.global_position = p["pos"]
		if done or float(p["t"]) > float(p["life"]):
			_free_sprite(p)
			live.remove_at(i)
		else:
			i += 1

func _damage_hits(p: Dictionary, radius: float, tags: Array = []) -> bool:
	## Damage everything near the projectile; returns true when pierce is spent.
	var hits := horde.query_circle(p["pos"], radius)
	var spent := false
	for idx in hits:
		run.hit_enemy(idx, float(p["dmg"]), tags, p["pos"])
		p["pierce"] = int(p["pierce"]) - 1
		if int(p["pierce"]) < 0:
			spent = true
			break
	if not hits.is_empty():
		run.hit_elites_at(p["pos"], radius, float(p["dmg"]), tags)
	else:
		if run.hit_elites_at(p["pos"], radius, float(p["dmg"]), tags):
			p["pierce"] = int(p["pierce"]) - 1
			if int(p["pierce"]) < 0:
				spent = true
	return spent

func _tick_verse(p: Dictionary, dt: float) -> bool:
	# gentle homing toward nearest demon ahead
	var tgt := horde.nearest(p["pos"], 420.0)
	var vel: Vector2 = p["vel"]
	if tgt >= 0:
		var to := (horde.pos[tgt] - Vector2(p["pos"])).normalized()
		vel = vel.lerp(to * vel.length(), minf(1.0, dt * 6.0))
		p["vel"] = vel
	p["pos"] = Vector2(p["pos"]) + vel * dt
	(p["sprite"] as Sprite2D).rotation = vel.angle()
	if float(p["hit_cd"]) <= 0.0:
		if _damage_hits(p, 30.0):
			return true
		p["hit_cd"] = 0.1
	return false

func _tick_paten(p: Dictionary, dt: float) -> bool:
	var vel: Vector2 = p["vel"]
	if int(p["phase"]) == 0 and float(p["t"]) > float(p["life"]) * 0.4:
		p["phase"] = 1
	if int(p["phase"]) == 1:
		var to := player.global_position - Vector2(p["pos"])
		if to.length() < 46.0:
			return true
		vel = vel.lerp(to.normalized() * vel.length() * 1.25, minf(1.0, dt * 5.0))
		p["vel"] = vel
	p["pos"] = Vector2(p["pos"]) + vel * dt
	var s: Sprite2D = p["sprite"]
	s.rotation += dt * 14.0
	if float(p["hit_cd"]) <= 0.0:
		_damage_hits(p, 34.0)      # patens never stop
		p["pierce"] = 999
		p["hit_cd"] = 0.12
	return false

func _tick_vial(p: Dictionary, dt: float) -> bool:
	# lobbed arc: fake height via scale
	var s: Sprite2D = p["sprite"]
	var progress := float(p["t"]) / float(p["life"])
	s.scale = Vector2.ONE * (1.0 + sin(progress * PI) * 0.9)
	s.rotation += dt * 6.0
	p["pos"] = Vector2(p["pos"]) + Vector2(p["vel"]) * dt
	if progress >= 1.0 or Vector2(p["pos"]).distance_to(p["target"]) < 24.0:
		var cb: Callable = p["on_land"]
		if cb.is_valid():
			cb.call(Vector2(p["pos"]))
		return true
	return false

func _tick_spit(p: Dictionary, dt: float) -> bool:
	p["pos"] = Vector2(p["pos"]) + Vector2(p["vel"]) * dt
	if Vector2(p["pos"]).distance_to(player.global_position) < 30.0:
		RunState.damage_player(float(p["dmg"]))
		return true
	return false

func clear_hostile() -> void:
	var i := 0
	while i < live.size():
		if live[i]["type"] == &"spit":
			_free_sprite(live[i])
			live.remove_at(i)
		else:
			i += 1
