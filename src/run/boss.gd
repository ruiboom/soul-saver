extends Node2D
class_name Warden
## The Warden of the Gate — Hell's immune response. Three phases:
##   1. chain sweeps (rotating telegraphed lines)
##   2. furnace breath (advancing lanes of hellfire)
##   3. the cage (a shrinking ring of fire + summons)
## Survive it — or, with all seven Vestiges, open the Gate mid-fight.

var max_hp := 7000.0
var hp := 7000.0
var speed := 70.0
var run

var sprite: Sprite2D
var light: PointLight2D
var _flash := 0.0
var _attack_t := 3.0
var _sweep: Dictionary = {}       # {angle, t}
var _contact_cd := 0.0
var alive := true

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/sprites/boss_warden.svg")
	sprite.scale = Vector2.ONE * 0.9
	sprite.offset = Vector2(0, -280)
	add_child(sprite)
	light = PointLight2D.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.4, 0.15, 1.0))
	grad.set_color(1, Color(1.0, 0.4, 0.15, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad; gt.fill = GradientTexture2D.FILL_RADIAL
	gt.width = 1024; gt.height = 1024
	gt.fill_from = Vector2(0.5, 0.5); gt.fill_to = Vector2(0.5, 0.0)
	light.texture = gt
	light.energy = 1.6
	light.texture_scale = 2.6
	light.position = Vector2(0, -200)
	add_child(light)
	z_index = 7
	var s := Data.enemy_scaling(RunState.time, RunState.bell)
	max_hp = 4200.0 * (0.5 + 0.3 * float(s["hp"]))
	hp = max_hp
	AudioDirector.play(&"roar", 0.0, 0.0)

func phase() -> int:
	if hp > max_hp * 0.66:
		return 1
	elif hp > max_hp * 0.33:
		return 2
	return 3

var _next_shed := 0.9
func damage(amount: float, _tags: Array = []) -> bool:
	if not alive:
		return false
	hp -= amount
	_flash = 1.0
	# the Warden bleeds stolen grace — wounding it fuels the priest
	if hp / max_hp < _next_shed:
		_next_shed -= 0.1
		run.embers.spawn(global_position + Vector2(randf_range(-80, 80), randf_range(-40, 40)), 14.0)
		run.vfx.holy_flash(global_position, 8)
		if absf(_next_shed - 0.4) < 0.01:
			run.map.drop_item(global_position + Vector2(0, 160), &"bread")
	if hp <= 0.0:
		alive = false
		run.on_warden_death()
		return true
	return false

func tick(dt: float) -> void:
	if not alive:
		return
	var ppos: Vector2 = run.player.global_position
	var to := ppos - global_position
	var dist := to.length()
	var dir := to / maxf(dist, 0.01)
	_flash = maxf(0.0, _flash - dt * 4.0)
	sprite.self_modulate = Color(1, 1, 1).lerp(Color(2.6, 2.4, 2.2), _flash)
	sprite.flip_h = dir.x < 0.0
	light.energy = 1.5 + sin(Time.get_ticks_msec() * 0.003) * 0.3 + _flash

	if dist > 250.0:
		global_position += dir * speed * (0.8 + 0.25 * float(phase())) * dt

	_attack_t -= dt
	if _attack_t <= 0.0:
		_do_attack(ppos)
	_tick_sweep(dt, ppos)
	queue_redraw()

	_contact_cd = maxf(0.0, _contact_cd - dt)
	if dist < 160.0 and _contact_cd <= 0.0:
		if RunState.damage_player(20.0):
			_contact_cd = 0.8

func _do_attack(ppos: Vector2) -> void:
	match phase():
		1:
			_sweep = {"angle": (ppos - global_position).angle() - 0.9, "t": 0.0}
			_attack_t = 4.2
			AudioDirector.play(&"roar", -6.0, 0.2)
		2:
			# furnace breath: lanes of hellfire marching toward the player
			var base := (ppos - global_position).angle()
			for lane in 3:
				var a := base + (float(lane) - 1.0) * 0.35
				for step in 6:
					var at := global_position + Vector2.from_angle(a) * (220.0 + 170.0 * float(step))
					run.zones.add_zone(&"hellfire", at, 90.0, 8.0, 2.0 + float(step) * 0.12)
			_attack_t = 4.2
			AudioDirector.play(&"roar", -4.0, 0.1)
			run.camera.shake(6.0)
		3:
			# the cage: ring of fire around the player + a summoned cohort
			for k in 12:
				var a := TAU * float(k) / 12.0
				run.zones.add_zone(&"hellfire", ppos + Vector2.from_angle(a) * 360.0, 85.0, 9.0, 2.6)
			var scaling := Data.enemy_scaling(RunState.time, RunState.bell)
			for k in 4:
				var tid: int = run.horde.type_index(&"fury")
				run.horde.spawn(tid, global_position + Vector2.from_angle(TAU * float(k) / 4.0) * 200.0, scaling)
			_attack_t = 6.5
			AudioDirector.play(&"roar", -2.0, 0.0)
			run.camera.shake(9.0)

func _tick_sweep(dt: float, _ppos: Vector2) -> void:
	if _sweep.is_empty():
		return
	_sweep["t"] = float(_sweep["t"]) + dt
	var t := float(_sweep["t"])
	if t < 0.8:
		pass  # telegraph only
	elif t < 2.2:
		_sweep["angle"] = float(_sweep["angle"]) + dt * 1.35
		# damage along the chain line
		var a := float(_sweep["angle"])
		var pp: Vector2 = run.player.global_position
		var rel := pp - global_position
		var along := rel.dot(Vector2.from_angle(a))
		var across := absf(rel.dot(Vector2.from_angle(a + PI / 2.0)))
		if along > 60.0 and along < 900.0 and across < 55.0:
			RunState.damage_player(16.0)
	else:
		_sweep = {}

func _draw() -> void:
	if not _sweep.is_empty():
		var t := float(_sweep["t"])
		var a := float(_sweep["angle"])
		var endp := Vector2.from_angle(a) * 900.0
		if t < 0.8:
			draw_line(Vector2.ZERO, endp, Color(1.4, 0.4, 0.2, 0.35 + 0.3 * sin(t * 20.0)), 40.0)
		else:
			draw_line(Vector2.ZERO, endp, Color(1.8, 0.7, 0.25, 0.9), 26.0)
			draw_line(Vector2.ZERO, endp, Color(2.2, 1.4, 0.6, 0.9), 8.0)
