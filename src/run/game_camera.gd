extends Camera2D
class_name GameCamera

var target: Node2D
var _shake := 0.0

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = 6.0

func shake(amount: float) -> void:
	_shake = maxf(_shake, amount)

func _process(delta: float) -> void:
	if target:
		var lookahead := Vector2.ZERO
		if target is Player:
			lookahead = (target as Player).move_dir * 70.0
		global_position = target.global_position + lookahead
	if _shake > 0.01:
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
		_shake = lerpf(_shake, 0.0, delta * 7.0)
	else:
		offset = Vector2.ZERO
