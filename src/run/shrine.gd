extends Node2D
class_name Shrine
## A Profane Shrine holding one Vestige of Lucia's soul.

enum State { LOCKED, FIGHTING, CLAIMABLE, CLAIMED }

var index := 0
var state := State.LOCKED
var wisp: Sprite2D
var light: PointLight2D
var _t := 0.0

func _ready() -> void:
	var s := Sprite2D.new()
	s.texture = load("res://assets/env/shrine.svg")
	s.scale = Vector2.ONE * 0.85
	s.offset = Vector2(0, -180)
	add_child(s)
	wisp = Sprite2D.new()
	wisp.texture = load("res://assets/sprites/lucia_wisp.svg")
	wisp.position = Vector2(0, -160)
	wisp.scale = Vector2.ONE * 0.9
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	wisp.material = mat
	add_child(wisp)
	light = PointLight2D.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(0.55, 0.75, 0.35, 1.0))
	grad.set_color(1, Color(0.55, 0.75, 0.35, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.width = 512; gt.height = 512
	gt.fill_from = Vector2(0.5, 0.5); gt.fill_to = Vector2(0.5, 0.0)
	light.texture = gt
	light.energy = 1.0
	light.texture_scale = 2.2
	light.position = Vector2(0, -120)
	add_child(light)
	z_index = 3

func _process(delta: float) -> void:
	_t += delta
	wisp.position.y = -160.0 + sin(_t * 2.0) * 8.0
	match state:
		State.LOCKED:
			wisp.modulate = Color(0.8, 1.0, 0.7, 0.75 + sin(_t * 3.0) * 0.15)
		State.FIGHTING:
			wisp.modulate = Color(1.2, 0.9, 0.6, 0.9)
			light.color = Color(1.0, 0.6, 0.3)
		State.CLAIMABLE:
			wisp.modulate = Color(1.5, 1.6, 1.9, 0.95 + sin(_t * 5.0) * 0.05)
			light.color = Color(0.75, 0.85, 1.0)
			light.energy = 1.6 + sin(_t * 4.0) * 0.3
		State.CLAIMED:
			wisp.visible = false
			light.energy = maxf(0.0, light.energy - delta * 0.5)
