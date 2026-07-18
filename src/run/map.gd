extends Node2D
class_name AshenReaches
## World layout: infinite-looking ash ground (shader), the Gate of Dawn, seven shrines
## on a ring, scattered props, destructible bone piles, ground pickups, lava collision.

const WORLD_RADIUS := 5800.0
const SHRINE_RING := 4100.0
const RIVER_HALF_WIDTH := 95.0

var ground: MeshInstance2D
var camera: Camera2D
var player: Node2D
var run

var shrines: Array[Shrine] = []
var gate: Sprite2D
var gate_light: PointLight2D
var gate_open := false

var obstacles: Array = []       # {pos, r}
var bone_piles: Array = []      # {pos, hp, node}
var items: Array = []           # {pos, type, node}
var _lava_tick := 0.0

func _ready() -> void:
	ground = MeshInstance2D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(2600, 1600)
	ground.mesh = quad
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/ground.gdshader")
	mat.set_shader_parameter("world_radius", WORLD_RADIUS)
	mat.set_shader_parameter("river_half_width", RIVER_HALF_WIDTH)
	ground.material = mat
	ground.z_index = -10
	add_child(ground)
	_build_gate()
	_build_shrines()
	_scatter_props()

func _build_gate() -> void:
	gate = Sprite2D.new()
	gate.texture = load("res://assets/env/gate.svg")
	gate.scale = Vector2.ONE * 0.85
	gate.offset = Vector2(0, -230)
	gate.position = Vector2.ZERO
	gate.z_index = 2
	add_child(gate)
	gate_light = PointLight2D.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.92, 0.7, 1.0))
	grad.set_color(1, Color(1.0, 0.92, 0.7, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad; gt.fill = GradientTexture2D.FILL_RADIAL
	gt.width = 1024; gt.height = 1024
	gt.fill_from = Vector2(0.5, 0.5); gt.fill_to = Vector2(0.5, 0.0)
	gate_light.texture = gt
	gate_light.energy = 0.9
	gate_light.texture_scale = 2.0
	gate_light.position = Vector2(0, -180)
	add_child(gate_light)
	obstacles.append({"pos": Vector2(0, -140), "r": 240.0})

func _build_shrines() -> void:
	for i in 7:
		var ang := TAU * float(i) / 7.0 - PI / 2.0 + 0.22
		var pos := Vector2.from_angle(ang) * SHRINE_RING
		# nudge off lava
		var tries := 0
		while lava_at(pos) and tries < 20:
			pos = pos.rotated(0.04)
			tries += 1
		var sh := Shrine.new()
		sh.index = i
		sh.position = pos
		add_child(sh)
		shrines.append(sh)
		obstacles.append({"pos": pos + Vector2(0, -60), "r": 150.0})

func _scatter_props() -> void:
	var rng := Rngs.world
	var textures := {
		"rock": load("res://assets/env/rock.svg"),
		"gibbet": load("res://assets/env/gibbet.svg"),
	}
	for i in 90:
		var pos := _random_clear_pos(rng, 600.0)
		if pos == Vector2.INF:
			continue
		var kind := "rock" if rng.randf() < 0.62 else "gibbet"
		var s := Sprite2D.new()
		s.texture = textures[kind]
		var sc := rng.randf_range(0.5, 1.0)
		s.scale = Vector2.ONE * sc
		s.position = pos
		s.offset = Vector2(0, -80) if kind == "rock" else Vector2(0, -170)
		s.flip_h = rng.randf() < 0.5
		s.z_index = 2
		s.modulate = Color(0.62, 0.6, 0.7).lerp(Color(0.85, 0.82, 0.9), rng.randf())
		add_child(s)
		if kind == "rock":
			obstacles.append({"pos": pos, "r": 85.0 * sc})
	var bone_tex: Texture2D = load("res://assets/env/bonepile.svg")
	for i in 46:
		var pos := _random_clear_pos(rng, 500.0)
		if pos == Vector2.INF:
			continue
		var s := Sprite2D.new()
		s.texture = bone_tex
		s.scale = Vector2.ONE * rng.randf_range(0.4, 0.65)
		s.position = pos
		s.offset = Vector2(0, -40)
		s.flip_h = rng.randf() < 0.5
		s.z_index = 1
		s.modulate = Color(0.75, 0.72, 0.68)
		add_child(s)
		bone_piles.append({"pos": pos, "hp": 20.0, "node": s})

func _random_clear_pos(rng: RandomNumberGenerator, min_from_center: float) -> Vector2:
	for attempt in 24:
		var pos := Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(min_from_center, WORLD_RADIUS - 400.0)
		if lava_at(pos):
			continue
		var clear := true
		for sh in shrines:
			if sh.position.distance_to(pos) < 420.0:
				clear = false
				break
		if pos.length() < 500.0:
			clear = false
		if clear:
			return pos
	return Vector2.INF

# ---------------------------------------------------------------- lava (mirror of ground.gdshader)
func lava_at(p: Vector2) -> bool:
	var r := p.length()
	if r > WORLD_RADIUS - 140.0:
		return true
	if r < 950.0:
		return false
	var ang := p.angle()
	for k in 4:
		var base_a := TAU * float(k) / 4.0 + 0.7
		var da := ang - base_a
		da = atan2(sin(da), cos(da))
		var across_px := da * maxf(r, 1.0) - sin(r * 0.004 + float(k) * 2.1) * 240.0
		var river := RIVER_HALF_WIDTH - absf(across_px)
		river -= maxf(0.0, 950.0 - r) * 0.8
		river -= maxf(0.0, 140.0 - absf(r - 1600.0)) * 0.9
		river -= maxf(0.0, 140.0 - absf(r - 3450.0)) * 0.9
		if river > 0.0:
			return true
	return false

func resolve_collisions(pos: Vector2, radius: float) -> Vector2:
	# world edge
	var r := pos.length()
	var limit := WORLD_RADIUS - 200.0
	if r > limit:
		pos = pos / r * limit
	# obstacle circles
	for ob in obstacles:
		var away: Vector2 = pos - ob["pos"]
		var d := away.length()
		var min_d: float = ob["r"] + radius
		if d < min_d and d > 0.01:
			pos = ob["pos"] + away / d * min_d
	return pos

# ---------------------------------------------------------------- pickups
func drop_item(at: Vector2, type: StringName) -> void:
	var icons := {
		&"bread": "res://assets/icons/pick_bread.svg",
		&"chrism": "res://assets/icons/pick_chrism.svg",
		&"wrath": "res://assets/icons/pick_wrath.svg",
		&"mark": "res://assets/icons/pick_mark.svg",
	}
	var s := Sprite2D.new()
	s.texture = load(icons[type])
	s.scale = Vector2.ONE * 0.42
	s.position = at
	s.z_index = 4
	add_child(s)
	items.append({"pos": at, "type": type, "node": s, "t": randf() * TAU})

func hit_bone_piles(at: Vector2, radius: float, dmg: float) -> void:
	var i := 0
	while i < bone_piles.size():
		var bp: Dictionary = bone_piles[i]
		if Vector2(bp["pos"]).distance_to(at) < radius + 60.0:
			bp["hp"] = float(bp["hp"]) - dmg
			(bp["node"] as Sprite2D).modulate = Color(1.6, 1.5, 1.3)
			if float(bp["hp"]) <= 0.0:
				(bp["node"] as Sprite2D).queue_free()
				var roll := Rngs.loot.randf()
				var type: StringName = &"bread"
				if roll < 0.14: type = &"wrath"
				elif roll < 0.38: type = &"chrism"
				elif roll < 0.58: type = &"mark"
				drop_item(bp["pos"], type)
				run.vfx.holy_flash(bp["pos"], 8)
				bone_piles.remove_at(i)
				continue
		i += 1

func tick(dt: float) -> void:
	ground.global_position = camera.get_screen_center_position()
	# bone pile flash decay
	for bp in bone_piles:
		var n: Sprite2D = bp["node"]
		n.modulate = n.modulate.lerp(Color(1, 1, 1), dt * 8.0)
	# item bobbing + pickup
	var i := 0
	while i < items.size():
		var it: Dictionary = items[i]
		it["t"] = float(it["t"]) + dt * 3.0
		var n: Sprite2D = it["node"]
		n.position.y = Vector2(it["pos"]).y + sin(float(it["t"])) * 6.0
		# the Wrath is deliberate — you must step onto it, it never auto-triggers
		var reach := 80.0 if it["type"] == &"wrath" else RunState.magnet * 0.7 + 40.0
		if player.global_position.distance_to(it["pos"]) < reach:
			run.apply_item(it["type"], it["pos"])
			n.queue_free()
			items.remove_at(i)
			continue
		i += 1
	# standing in lava hurts
	_lava_tick -= dt
	if _lava_tick <= 0.0:
		_lava_tick = 0.5
		if lava_at(player.global_position):
			RunState.damage_player(10.0)
	# gate beacon breathes brighter once open
	if gate_open:
		gate_light.energy = 2.6 + sin(Time.get_ticks_msec() * 0.004) * 0.5
		gate_light.texture_scale = 3.2
