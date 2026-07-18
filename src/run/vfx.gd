extends Node2D
class_name Vfx
## Shared particle systems (emit_particle into pooled GPUParticles2D) + damage numbers.

var death_burst: GPUParticles2D
var gold_sparks: GPUParticles2D
var soul_rise: GPUParticles2D

var _labels: Array[Label] = []
var _label_i := 0
const LABEL_POOL := 40
var _spawned_this_frame := 0

func _ready() -> void:
	death_burst = _make_particles(Color(1.0, 0.45, 0.18), 2.4, 0.55, 190.0)
	gold_sparks = _make_particles(Color(1.6, 1.3, 0.7), 1.3, 0.4, 260.0)
	soul_rise = _make_particles(Color(1.3, 1.5, 1.9), 2.8, 1.3, 60.0)
	soul_rise.process_material.gravity = Vector3(0, -160, 0)
	for i in LABEL_POOL:
		var l := Label.new()
		l.visible = false
		l.z_index = 50
		if Game.font_body:
			l.add_theme_font_override(&"font", Game.font_body)
		l.add_theme_font_size_override(&"font_size", 22)
		l.add_theme_color_override(&"font_outline_color", Color(0.05, 0.03, 0.08, 0.9))
		l.add_theme_constant_override(&"outline_size", 6)
		add_child(l)
		_labels.append(l)

func _make_particles(color: Color, size: float, life: float, vel: float) -> GPUParticles2D:
	var p := GPUParticles2D.new()
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 0, 0)
	mat.spread = 180.0
	mat.initial_velocity_min = vel * 0.4
	mat.initial_velocity_max = vel
	mat.gravity = Vector3(0, 30, 0)
	mat.damping_min = vel * 0.6
	mat.damping_max = vel * 1.1
	mat.scale_min = size * 0.5
	mat.scale_max = size
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1)); curve.add_point(Vector2(1, 0))
	var ct := CurveTexture.new(); ct.curve = curve
	mat.scale_curve = ct
	mat.color = color
	p.process_material = mat
	p.amount = 512
	p.lifetime = life
	p.one_shot = false
	p.explosiveness = 0.0
	p.emitting = false
	p.local_coords = false
	var im := ImageTexture.create_from_image(_soft_dot())
	p.texture = im
	var cm := CanvasItemMaterial.new()
	cm.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	p.material = cm
	add_child(p)
	return p

func _soft_dot() -> Image:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	for y in 16:
		for x in 16:
			var d := Vector2(x - 7.5, y - 7.5).length() / 7.5
			var a := clampf(1.0 - d, 0.0, 1.0)
			img.set_pixel(x, y, Color(1, 1, 1, a * a))
	return img

func _burst(p: GPUParticles2D, at: Vector2, n: int, color: Color = Color.WHITE, extra_vel := Vector2.ZERO) -> void:
	p.emitting = true
	var xf := Transform2D(0.0, at)
	for i in n:
		p.emit_particle(xf, Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(60, 240) + extra_vel,
			color, Color(1, 1, 1, 1),
			GPUParticles2D.EMIT_FLAG_POSITION | GPUParticles2D.EMIT_FLAG_VELOCITY | GPUParticles2D.EMIT_FLAG_COLOR)

func enemy_death(at: Vector2, big: bool = false) -> void:
	# two-tone kill pop: dark cinders + a gold soul-release flash, so every kill reads
	_burst(death_burst, at, 9 if big else 6, Color(1.4, 0.55, 0.2, 1.0))
	_burst(gold_sparks, at, 6 if big else 3, Color(1.9, 1.65, 1.0, 1.0))
	if big or randf() < 0.35:
		_burst(soul_rise, at, 3 if big else 1, Color(1.2, 1.4, 1.8, 0.8), Vector2(0, -80))

func hit_spark(at: Vector2) -> void:
	_burst(gold_sparks, at, 3, Color(1.7, 1.4, 0.75, 1.0))

func holy_flash(at: Vector2, n: int = 14) -> void:
	_burst(gold_sparks, at, n, Color(1.9, 1.7, 1.1, 1.0))

func begin_frame() -> void:
	_spawned_this_frame = 0

func damage_number(at: Vector2, amount: float) -> void:
	if _spawned_this_frame >= 10 or amount < 1.0:
		return
	_spawned_this_frame += 1
	var l := _labels[_label_i]
	_label_i = (_label_i + 1) % LABEL_POOL
	l.text = str(int(round(amount)))
	var big := amount >= 40.0
	l.add_theme_font_size_override(&"font_size", 30 if big else 21)
	l.add_theme_color_override(&"font_color", Color(1.5, 1.3, 0.8) if big else Color(1.0, 0.96, 0.88, 0.9))
	l.global_position = at + Vector2(randf_range(-18, 18), -30)
	l.visible = true
	l.scale = Vector2.ONE
	l.modulate = Color(1, 1, 1, 1)
	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(l, "global_position:y", l.global_position.y - 46.0, 0.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
	tw.chain().tween_callback(func() -> void: l.visible = false)
