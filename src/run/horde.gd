extends Node2D
class_name Horde
## The horde: hundreds of demons as struct-of-arrays + MultiMesh rendering.
## No nodes, no physics bodies — this is the whole reason the game runs at 60fps.

const CAP := 900
const TYPE_CAP := 700            # max rendered instances per enemy type
const CELL := 128.0
const GRID_HALF := 24            # grid covers player ± 24 cells (±3072 px)
const GRID_W := GRID_HALF * 2    # 48
const CELL_CAP := 28
const DESPAWN_R := 2500.0
const RESPAWN_MIN := 1250.0
const RESPAWN_MAX := 1450.0

# --- SoA state
var pos := PackedVector2Array()
var vel := PackedVector2Array()
var hp := PackedFloat32Array()
var max_hp := PackedFloat32Array()
var type_id := PackedInt32Array()
var flash := PackedFloat32Array()
var stagger := PackedFloat32Array()
var special_t := PackedFloat32Array()   # per-special timer
var special_v := PackedFloat32Array()   # per-special value (dive state / carried grace)
var dmg_mult := PackedFloat32Array()    # per-enemy scaling snapshot
var hp_scale_at_spawn := PackedFloat32Array()
var count := 0

# --- per-type constants
var type_names: Array[StringName] = []
var t_hp := PackedFloat32Array()
var t_speed := PackedFloat32Array()
var t_dmg := PackedFloat32Array()
var t_radius := PackedFloat32Array()
var t_xp := PackedInt32Array()
var t_special: Array[StringName] = []

# --- rendering
var mm_nodes: Array[MultiMeshInstance2D] = []
var mm_buffers: Array[PackedFloat32Array] = []
var mm_counts := PackedInt32Array()
var t_scale := PackedFloat32Array()

# --- spatial grid (flat, player-centred)
var grid_count := PackedInt32Array()
var grid_items := PackedInt32Array()
var grid_origin := Vector2.ZERO

# --- hooks (set by run.gd)
var player: Node2D
var on_death: Callable          # (world_pos, type_name, xp, special_v)
var on_contact: Callable        # (enemy_index) — crown retaliation etc.
var frame := 0

func _ready() -> void:
	var shader := load("res://assets/shaders/horde.gdshader") as Shader
	var i := 0
	for id: StringName in Data.ENEMIES.keys():
		var e: Dictionary = Data.ENEMIES[id]
		type_names.append(id)
		t_hp.append(e["hp"]); t_speed.append(e["speed"]); t_dmg.append(e["dmg"])
		t_radius.append(e["radius"]); t_xp.append(e["xp"]); t_special.append(e["special"])
		t_scale.append(e["scale"])
		var tex: Texture2D = load(e["sprite"])
		var mmi := MultiMeshInstance2D.new()
		var mm := MultiMesh.new()
		mm.transform_format = MultiMesh.TRANSFORM_2D
		mm.use_custom_data = true
		var quad := QuadMesh.new()
		quad.size = Vector2(tex.get_width(), tex.get_height()) * float(e["scale"])
		mm.mesh = quad
		mm.instance_count = TYPE_CAP
		mm.visible_instance_count = 0
		mmi.multimesh = mm
		mmi.texture = tex
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mmi.material = mat
		add_child(mmi)
		mm_nodes.append(mmi)
		var buf := PackedFloat32Array()
		buf.resize(TYPE_CAP * 12)
		mm_buffers.append(buf)
		i += 1
	mm_counts.resize(type_names.size())
	pos.resize(CAP); vel.resize(CAP); hp.resize(CAP); max_hp.resize(CAP)
	type_id.resize(CAP); flash.resize(CAP); stagger.resize(CAP)
	special_t.resize(CAP); special_v.resize(CAP); dmg_mult.resize(CAP)
	hp_scale_at_spawn.resize(CAP)
	grid_count.resize(GRID_W * GRID_W)
	grid_items.resize(GRID_W * GRID_W * CELL_CAP)

func type_index(id: StringName) -> int:
	return type_names.find(id)

func spawn(tid: int, at: Vector2, scaling: Dictionary) -> int:
	if count >= CAP:
		return -1
	var i := count
	count += 1
	pos[i] = at
	vel[i] = Vector2.ZERO
	var s: float = scaling["hp"]
	hp[i] = t_hp[tid] * s
	max_hp[i] = hp[i]
	hp_scale_at_spawn[i] = s
	type_id[i] = tid
	flash[i] = 0.0
	stagger[i] = 0.0
	special_t[i] = randf() * 2.0
	special_v[i] = 0.0
	dmg_mult[i] = scaling["dmg"]
	return i

func _remove(i: int) -> void:
	count -= 1
	if i != count:
		pos[i] = pos[count]; vel[i] = vel[count]; hp[i] = hp[count]; max_hp[i] = max_hp[count]
		type_id[i] = type_id[count]; flash[i] = flash[count]; stagger[i] = stagger[count]
		special_t[i] = special_t[count]; special_v[i] = special_v[count]
		dmg_mult[i] = dmg_mult[count]; hp_scale_at_spawn[i] = hp_scale_at_spawn[count]

func damage(i: int, amount: float, tags: Array = [], from: Vector2 = Vector2.INF) -> bool:
	## Returns true if the demon was destroyed.
	if i < 0 or i >= count:
		return false
	var special := t_special[type_id[i]]
	if special == &"fire_immune" and tags.has(&"fire"):
		return false
	hp[i] -= amount
	flash[i] = 1.0
	# knockback: holy force is visible force
	if from != Vector2.INF:
		var away := pos[i] - from
		var d := away.length()
		if d > 0.01:
			var resist := 0.25 if special == &"tank" else 1.0
			vel[i] += away / d * 230.0 * resist
	if hp[i] <= 0.0:
		var p := pos[i]
		var tname := type_names[type_id[i]]
		var xp := int(round(t_xp[type_id[i]] * (1.0 + (hp_scale_at_spawn[i] - 1.0) * 0.35)))
		var sv := special_v[i]
		_remove(i)
		if on_death.is_valid():
			on_death.call(p, tname, xp, sv)
		return true
	return false

func apply_stagger(i: int, seconds: float) -> void:
	if i < 0 or i >= count:
		return
	var mult := 0.3 if t_special[type_id[i]] == &"tank" else 1.0
	stagger[i] = maxf(stagger[i], seconds * mult)

# ---------------------------------------------------------------- queries
func _cell_of(p: Vector2) -> int:
	var cx := clampi(int((p.x - grid_origin.x) / CELL), 0, GRID_W - 1)
	var cy := clampi(int((p.y - grid_origin.y) / CELL), 0, GRID_W - 1)
	return cy * GRID_W + cx

func query_circle(center: Vector2, radius: float) -> PackedInt32Array:
	var out := PackedInt32Array()
	var cx0 := clampi(int((center.x - radius - grid_origin.x) / CELL), 0, GRID_W - 1)
	var cx1 := clampi(int((center.x + radius - grid_origin.x) / CELL), 0, GRID_W - 1)
	var cy0 := clampi(int((center.y - radius - grid_origin.y) / CELL), 0, GRID_W - 1)
	var cy1 := clampi(int((center.y + radius - grid_origin.y) / CELL), 0, GRID_W - 1)
	var r2 := radius * radius
	for cy in range(cy0, cy1 + 1):
		for cx in range(cx0, cx1 + 1):
			var c := cy * GRID_W + cx
			var n := grid_count[c]
			var base := c * CELL_CAP
			for k in n:
				var idx := grid_items[base + k]
				if idx < count and pos[idx].distance_squared_to(center) <= r2:
					out.append(idx)
	return out

func query_arc(center: Vector2, dir: Vector2, radius: float, half_angle_rad: float) -> PackedInt32Array:
	var circle := query_circle(center, radius)
	var out := PackedInt32Array()
	for idx in circle:
		var to := pos[idx] - center
		if to.length_squared() < 100.0 or absf(dir.angle_to(to)) <= half_angle_rad:
			out.append(idx)
	return out

func nearest(from: Vector2, max_r: float, exclude_first: int = -1) -> int:
	var best := -1
	var best_d := max_r * max_r
	var found := query_circle(from, max_r)
	for idx in found:
		if idx == exclude_first:
			continue
		var d := pos[idx].distance_squared_to(from)
		if d < best_d:
			best_d = d
			best = idx
	return best

func nearest_n(from: Vector2, max_r: float, n: int) -> PackedInt32Array:
	var found := query_circle(from, max_r)
	var pairs: Array = []
	for idx in found:
		pairs.append(Vector2(pos[idx].distance_squared_to(from), float(idx)))
	pairs.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)
	var out := PackedInt32Array()
	for k in mini(n, pairs.size()):
		out.append(int(pairs[k].y))
	return out

# ---------------------------------------------------------------- simulation
func tick(dt: float, embers: Node) -> void:
	frame += 1
	var ppos := player.global_position
	grid_origin = ppos - Vector2(GRID_HALF * CELL, GRID_HALF * CELL)
	grid_count.fill(0)

	# pass 1: build grid
	for i in count:
		var c := _cell_of(pos[i])
		var n := grid_count[c]
		if n < CELL_CAP:
			grid_items[c * CELL_CAP + n] = i
			grid_count[c] = n + 1

	var player_r := 26.0
	var contact_r2: float
	var t := RunState.time

	# pass 2: move + contact
	var i := 0
	while i < count:
		var tid := type_id[i]
		var special := t_special[tid]
		var p := pos[i]
		var to_player := ppos - p
		var dist := to_player.length()

		# recycle far-behind enemies to fresh ambush positions
		if dist > DESPAWN_R:
			if special == &"steal" and special_v[i] > 0.0:
				_remove(i)   # the scribe escapes with stolen grace
				continue
			var ang := randf() * TAU
			pos[i] = ppos + Vector2.from_angle(ang) * randf_range(RESPAWN_MIN, RESPAWN_MAX)
			i += 1
			continue

		var spd := t_speed[tid]
		var desired: Vector2
		if special == &"steal":
			desired = _scribe_ai(i, ppos, spd, embers)
		else:
			var dir := to_player / maxf(dist, 0.001)
			if special == &"dive":
				special_t[i] -= dt
				if special_t[i] <= 0.0:
					special_t[i] = randf_range(2.0, 3.2)
					special_v[i] = 0.55       # dive time remaining
				if special_v[i] > 0.0:
					special_v[i] -= dt
					spd *= 2.3
			elif special == &"phase":
				var wob := sin(t * 1.7 + float(i) * 0.7) * 0.6
				dir = dir.rotated(wob)
			desired = dir * spd

		if stagger[i] > 0.0:
			stagger[i] -= dt
			desired *= 0.1

		# soft separation vs one grid neighbour (skip phasing wraiths)
		if special != &"phase":
			var c := _cell_of(p)
			var n := grid_count[c]
			if n > 1:
				var other := grid_items[c * CELL_CAP + ((i + frame) % n)]
				if other != i and other < count:
					var away := p - pos[other]
					var d2 := away.length_squared()
					var min_d := t_radius[tid] * 1.6
					if d2 < min_d * min_d and d2 > 0.01:
						desired += away * (60.0 / maxf(8.0, sqrt(d2)))

		vel[i] = vel[i].lerp(desired, minf(1.0, dt * 6.0))
		pos[i] = p + vel[i] * dt
		if flash[i] > 0.0:
			flash[i] = maxf(0.0, flash[i] - dt * 5.0)

		# contact damage
		contact_r2 = (t_radius[tid] + player_r) * (t_radius[tid] + player_r)
		if pos[i].distance_squared_to(ppos) < contact_r2:
			if RunState.damage_player(t_dmg[tid] * dmg_mult[i]):
				if on_contact.is_valid():
					on_contact.call(i)
		i += 1

	_render()

func _scribe_ai(i: int, ppos: Vector2, spd: float, embers: Node) -> Vector2:
	if special_v[i] > 0.0:   # carrying stolen grace: flee the priest
		return (pos[i] - ppos).normalized() * spd * 1.15
	var target: Vector2 = embers.nearest_ember(pos[i], 900.0)
	if target != Vector2.INF:
		var to := target - pos[i]
		if to.length() < 30.0:
			special_v[i] = embers.steal_at(pos[i], 40.0)
			flash[i] = 0.6
		return to.normalized() * spd
	return (ppos - pos[i]).normalized() * spd * 0.6

func _render() -> void:
	for k in mm_counts.size():
		mm_counts[k] = 0
	var half := 0.5
	for i in count:
		var tid := type_id[i]
		var n := mm_counts[tid]
		if n >= TYPE_CAP:
			continue
		mm_counts[tid] = n + 1
		var b := mm_buffers[tid]
		var o := n * 12
		var s := 1.0
		var face := -1.0 if vel[i].x < 0.0 else 1.0
		# 2D transform rows: [xx, yx, 0, ox, xy, yy, 0, oy]
		b[o] = s * face; b[o + 1] = 0.0; b[o + 2] = 0.0; b[o + 3] = pos[i].x
		b[o + 4] = 0.0; b[o + 5] = s; b[o + 6] = 0.0; b[o + 7] = pos[i].y
		# custom: flash, phase, stagger flag, unused
		b[o + 8] = flash[i]
		b[o + 9] = float(i % 32) / 32.0
		b[o + 10] = 1.0 if stagger[i] > 0.0 else 0.0
		b[o + 11] = 0.0
	for tid in mm_nodes.size():
		var mm := mm_nodes[tid].multimesh
		mm.visible_instance_count = mm_counts[tid]
		if mm_counts[tid] > 0:
			mm.buffer = mm_buffers[tid]
