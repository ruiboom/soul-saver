extends Node2D
class_name Elite
## Node-based rich enemy: Shrinekeepers guard vestiges, Bell Heralds hunt at each toll.
## There are never more than a handful alive — they can afford real behaviour.

var max_hp := 400.0
var hp := 400.0
var speed := 120.0
var dmg := 18.0
var radius := 60.0
var pattern: StringName = &"charge"
var display_name := "Shrinekeeper"
var shrine_index := -1            # -1 = herald
var run

var sprite: Sprite2D
var _flash := 0.0
var _pattern_t := 3.0
var _charge_state := 0            # 0 idle, 1 telegraph, 2 dashing
var _charge_dir := Vector2.ZERO
var _charge_t := 0.0
var _contact_cd := 0.0

func setup(cfg: Dictionary) -> void:
	max_hp = cfg.get("hp", 400.0)
	hp = max_hp
	pattern = cfg.get("pattern", &"charge")
	display_name = cfg.get("name", "Herald of the Bell")
	shrine_index = cfg.get("shrine_index", -1)
	speed = cfg.get("speed", 120.0)
	dmg = cfg.get("dmg", 18.0)
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/sprites/elite_keeper.svg")
	sprite.scale = Vector2.ONE * 0.55 * float(cfg.get("scale", 1.0))
	sprite.offset = Vector2(0, -110)
	sprite.modulate = cfg.get("tint", Color(1, 1, 1))
	add_child(sprite)
	radius = 62.0 * float(cfg.get("scale", 1.0))
	z_index = 6

func damage(amount: float, _tags: Array = []) -> bool:
	hp -= amount
	_flash = 1.0
	if hp <= 0.0:
		run.on_elite_death(self)
		return true
	return false

func tick(dt: float) -> void:
	var ppos: Vector2 = run.player.global_position
	var to := ppos - global_position
	var dist := to.length()
	var dir := to / maxf(dist, 0.01)
	_flash = maxf(0.0, _flash - dt * 5.0)
	sprite.self_modulate = Color(1, 1, 1).lerp(Color(3.0, 2.8, 2.4), _flash)
	sprite.flip_h = dir.x < 0.0
	var bob := sin(Time.get_ticks_msec() * 0.006 + float(get_instance_id() % 97)) * 4.0
	sprite.offset.y = -110.0 + bob

	match _charge_state:
		0:
			if dist > radius + 30.0:
				global_position += dir * speed * dt
			_pattern_t -= dt
			if _pattern_t <= 0.0:
				_start_pattern(dir)
		1:
			_charge_t -= dt
			if _charge_t <= 0.0:
				_charge_state = 2
				_charge_t = 0.55
				AudioDirector.play(&"roar", -8.0, 0.2)
		2:
			global_position += _charge_dir * speed * 3.6 * dt
			_charge_t -= dt
			if _charge_t <= 0.0:
				_charge_state = 0
				_pattern_t = randf_range(2.6, 4.0)
	queue_redraw()

	# contact damage
	_contact_cd = maxf(0.0, _contact_cd - dt)
	if dist < radius + 30.0 and _contact_cd <= 0.0:
		if RunState.damage_player(dmg):
			_contact_cd = 0.8

func _start_pattern(dir: Vector2) -> void:
	match pattern:
		&"charge":
			_charge_state = 1
			_charge_t = 0.65
			_charge_dir = dir
		&"spit":
			var n := 10
			for k in n:
				var a := TAU * float(k) / float(n) + randf() * 0.3
				run.projectiles.fire(&"spit", global_position, Vector2.from_angle(a), {
					"speed": 300.0, "dmg": dmg * 0.7, "life": 3.0, "vis_scale": 1.4})
			AudioDirector.play(&"spit", -6.0)
			_pattern_t = randf_range(2.8, 3.6)
		&"summon":
			var scaling := Data.enemy_scaling(RunState.time, RunState.bell)
			for k in 7:
				var a := TAU * float(k) / 7.0
				var tid: int = run.horde.type_index(&"ashimp")
				run.horde.spawn(tid, global_position + Vector2.from_angle(a) * 130.0, scaling)
			AudioDirector.play(&"roar", -12.0, 0.3)
			_pattern_t = randf_range(4.0, 5.5)

func _draw() -> void:
	# telegraph for charge
	if _charge_state == 1:
		var endp := to_local(global_position + _charge_dir * 620.0)
		draw_line(Vector2.ZERO, endp, Color(1.3, 0.35, 0.2, 0.5), 26.0)
		draw_line(Vector2.ZERO, endp, Color(1.6, 0.6, 0.3, 0.8), 4.0)
	# health bar
	var w := 130.0
	var frac := clampf(hp / max_hp, 0.0, 1.0)
	var y := -230.0 * sprite.scale.y / 0.55
	draw_rect(Rect2(-w / 2.0, y, w, 10.0), Color(0.05, 0.03, 0.06, 0.8))
	draw_rect(Rect2(-w / 2.0, y, w * frac, 10.0), Color(0.85, 0.2, 0.25))
	draw_rect(Rect2(-w / 2.0, y, w * frac, 3.0), Color(1.2, 0.5, 0.4))
