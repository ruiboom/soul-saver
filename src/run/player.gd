extends Node2D
class_name Player
## Father Anselm. Movement is the entire moment-to-moment input.

const BASE_SPEED := 300.0
const RADIUS := 26.0

var sprite: Sprite2D
var halo_light: PointLight2D
var facing := 1.0
var map                       # set by run.gd — obstacle circles + lava query
var move_dir := Vector2.ZERO  # autotest can drive this
var auto_move := false
var _bob := 0.0

func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/sprites/player_priest.svg")
	sprite.scale = Vector2.ONE * 0.62
	sprite.offset = Vector2(0, -70)
	add_child(sprite)

	halo_light = PointLight2D.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.88, 0.66, 1.0))
	grad.set_color(1, Color(1.0, 0.88, 0.66, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.width = 1024; gt.height = 1024
	gt.fill_from = Vector2(0.5, 0.5); gt.fill_to = Vector2(0.5, 0.0)
	halo_light.texture = gt
	halo_light.energy = 1.5
	halo_light.texture_scale = 1.9
	halo_light.shadow_enabled = false
	add_child(halo_light)
	z_index = 10

func tick(dt: float) -> void:
	if not auto_move:
		move_dir = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var speed := BASE_SPEED * RunState.speed_mult
	if move_dir.length_squared() > 0.01:
		global_position += move_dir * speed * dt
		facing = -1.0 if move_dir.x < -0.05 else (1.0 if move_dir.x > 0.05 else facing)
		_bob += dt * 9.0
		sprite.rotation = sin(_bob) * 0.045
		sprite.offset.y = -70.0 + absf(sin(_bob)) * -4.0
	else:
		sprite.rotation = lerpf(sprite.rotation, 0.0, dt * 8.0)
	sprite.flip_h = facing < 0.0

	if map:
		global_position = map.resolve_collisions(global_position, RADIUS)

	RunState.invuln = maxf(0.0, RunState.invuln - dt)
	# hurt feedback: red-white flicker during i-frames
	if RunState.invuln > 0.35:
		sprite.modulate = Color(2.0, 1.2, 1.2) if int(RunState.invuln * 20.0) % 2 == 0 else Color(1, 1, 1)
	else:
		sprite.modulate = sprite.modulate.lerp(Color(1, 1, 1), dt * 10.0)
	# candle-breath on the halo light
	halo_light.energy = 1.3 + sin(Time.get_ticks_msec() * 0.002) * 0.08 + RunState.magnet * 0.0006
