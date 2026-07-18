extends Node
class_name SpawnDirector
## Composes the horde: keeps live-enemy count at the time-driven budget,
## drawing types from the current bell's wave table. Occasional pack events.

var horde: Horde
var player: Node2D
var _accum := 0.0
var _pack_timer := 25.0

func tick(dt: float) -> void:
	if RunState.warden_spawned:
		return   # the Warden fights alone
	var t := RunState.time
	var budget := Data.spawn_budget(t)
	var deficit := budget - horde.count
	if deficit > 0:
		_accum += dt * clampf(float(deficit) * 0.6, 2.0, 40.0)
		while _accum >= 1.0 and horde.count < budget:
			_accum -= 1.0
			_spawn_one()
	_pack_timer -= dt
	if _pack_timer <= 0.0:
		_pack_timer = randf_range(20.0, 32.0)
		_spawn_pack()

func _current_waves() -> Array:
	return Data.BELLS[RunState.bell]["waves"]

func _pick_type() -> StringName:
	var waves := _current_waves()
	var total := 0.0
	for w in waves:
		total += float(w["w"])
	var roll := Rngs.spawn.randf() * total
	for w in waves:
		roll -= float(w["w"])
		if roll <= 0.0:
			return w["id"]
	return waves[0]["id"]

func _ring_pos() -> Vector2:
	var ang: float
	var pl := player as Player
	# half the spawns land ahead of the player's movement so kiting never fully escapes
	if pl and pl.move_dir.length_squared() > 0.01 and Rngs.spawn.randf() < 0.5:
		ang = pl.move_dir.angle() + Rngs.spawn.randf_range(-1.0, 1.0)
	else:
		ang = Rngs.spawn.randf() * TAU
	return player.global_position + Vector2.from_angle(ang) * Rngs.spawn.randf_range(1150.0, 1400.0)

func _spawn_one() -> void:
	var id := _pick_type()
	var tid := horde.type_index(id)
	horde.spawn(tid, _ring_pos(), Data.enemy_scaling(RunState.time, RunState.bell))

func _spawn_pack() -> void:
	# a wall or ring of one type, from one direction — composable dread
	var id := _pick_type()
	var tid := horde.type_index(id)
	var scaling := Data.enemy_scaling(RunState.time, RunState.bell)
	var n := 10 + RunState.bell * 4
	var mode := Rngs.spawn.randi_range(0, 1)
	if mode == 0:  # wall
		var ang := Rngs.spawn.randf() * TAU
		var center := player.global_position + Vector2.from_angle(ang) * 1250.0
		var perp := Vector2.from_angle(ang + PI / 2.0)
		for k in n:
			horde.spawn(tid, center + perp * (float(k) - n / 2.0) * 70.0, scaling)
	else:          # ring
		for k in n:
			var a := TAU * float(k) / float(n)
			horde.spawn(tid, player.global_position + Vector2.from_angle(a) * 1250.0, scaling)
