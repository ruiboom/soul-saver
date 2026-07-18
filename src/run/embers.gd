extends Node2D
class_name Embers
## Grace embers released by slain demons. MultiMesh-rendered point sim.

const CAP := 1400
const LIFETIME := 60.0
const MERGE_R := 46.0        # embers landing near a recent one merge into it

var pos := PackedVector2Array()
var val := PackedFloat32Array()
var age := PackedFloat32Array()
var pulling := PackedInt32Array()   # 0 idle, 1 flying to player
var count := 0

var player: Node2D
var mmi: MultiMeshInstance2D
var buf := PackedFloat32Array()

func _ready() -> void:
	pos.resize(CAP); val.resize(CAP); age.resize(CAP); pulling.resize(CAP)
	mmi = MultiMeshInstance2D.new()
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_custom_data = true
	var quad := QuadMesh.new()
	quad.size = Vector2(26, 26)
	mm.mesh = quad
	mm.instance_count = CAP
	mm.visible_instance_count = 0
	mmi.multimesh = mm
	mmi.texture = load("res://assets/proj/ember.svg")
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/ember.gdshader")
	mmi.material = mat
	add_child(mmi)
	buf.resize(CAP * 12)

func spawn(at: Vector2, value: float) -> void:
	# merge with a recently-spawned neighbour (same burst → one fatter pill,
	# still exactly at the kill site — keeps the field readable and under cap)
	var m2 := MERGE_R * MERGE_R
	for k in range(count - 1, maxi(0, count - 64) - 1, -1):
		if pulling[k] == 0 and age[k] < 3.0 and pos[k].distance_squared_to(at) < m2:
			val[k] += value
			return
	if count >= CAP:
		# field saturated: fold into the nearest existing ember (sampled)
		var best := -1
		var best_d := 1e12
		for s in 64:
			var i := randi_range(0, count - 1)
			var d := pos[i].distance_squared_to(at)
			if d < best_d:
				best_d = d; best = i
		if best >= 0:
			val[best] += value
		return
	pos[count] = at + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	val[count] = value
	age[count] = 0.0
	pulling[count] = 0
	count += 1

func _remove(i: int) -> void:
	count -= 1
	if i != count:
		pos[i] = pos[count]; val[i] = val[count]; age[i] = age[count]; pulling[i] = pulling[count]

func nearest_ember(from: Vector2, max_r: float) -> Vector2:
	var best := Vector2.INF
	var best_d := max_r * max_r
	for i in count:
		if pulling[i] == 1:
			continue
		var d := pos[i].distance_squared_to(from)
		if d < best_d:
			best_d = d; best = pos[i]
	return best

func steal_at(at: Vector2, radius: float) -> float:
	var taken := 0.0
	var i := 0
	while i < count:
		if pulling[i] == 0 and pos[i].distance_squared_to(at) < radius * radius:
			taken += val[i]
			_remove(i)
		else:
			i += 1
	return taken

func vacuum_all() -> void:
	for i in count:
		pulling[i] = 1

func tick(dt: float) -> void:
	var ppos := player.global_position
	var magnet_r: float = RunState.magnet
	var m2 := magnet_r * magnet_r
	var i := 0
	while i < count:
		age[i] += dt
		if age[i] > LIFETIME:
			_remove(i)
			continue
		var d2 := pos[i].distance_squared_to(ppos)
		if pulling[i] == 0 and d2 < m2:
			pulling[i] = 1
		if pulling[i] == 1:
			var to := ppos - pos[i]
			var d := to.length()
			if d < 30.0:
				RunState.add_grace(val[i])
				AudioDirector.play(&"pickup", -16.0, 0.15, 70)
				_remove(i)
				continue
			pos[i] += to / d * (520.0 + 900.0 / maxf(1.0, d * 0.02)) * dt
		i += 1
	_render()

func _render() -> void:
	var n := mini(count, CAP)
	for i in n:
		var o := i * 12
		var tier := 0.0
		if val[i] >= 100.0: tier = 3.0
		elif val[i] >= 20.0: tier = 2.0
		elif val[i] >= 5.0: tier = 1.0
		# pop-in: newborn pills scale up over ~0.2s with a slight overshoot
		var pop := minf(age[i] * 5.0, 1.0)
		var s := (1.0 + tier * 0.35) * pop * (1.0 + 0.35 * (1.0 - pop))
		buf[o] = s; buf[o + 1] = 0.0; buf[o + 2] = 0.0; buf[o + 3] = pos[i].x
		buf[o + 4] = 0.0; buf[o + 5] = s; buf[o + 6] = 0.0; buf[o + 7] = pos[i].y
		buf[o + 8] = tier
		buf[o + 9] = float(i % 16) / 16.0
		buf[o + 10] = 0.0; buf[o + 11] = 0.0
	mmi.multimesh.visible_instance_count = n
	if n > 0:
		mmi.multimesh.buffer = buf
