extends Node2D
class_name Zones
## Lingering ground effects: incense smoke, holy pools, light pillars, demon acid.
## Each zone is drawn procedurally (soft radial discs) and ticks damage twice a second.

var horde: Horde
var player: Node2D
var run
var zones: Array[Dictionary] = []

const TICK := 0.45

func add_zone(type: StringName, at: Vector2, radius: float, dmg: float, duration: float) -> void:
	zones.append({"type": type, "pos": at, "r": radius, "dmg": dmg, "dur": duration, "t": 0.0, "tick": randf() * TICK})
	queue_redraw()

func tick(dt: float) -> void:
	var i := 0
	while i < zones.size():
		var z := zones[i]
		z["t"] = float(z["t"]) + dt
		z["tick"] = float(z["tick"]) - dt
		if float(z["tick"]) <= 0.0:
			z["tick"] = TICK
			_apply(z)
		if float(z["t"]) >= float(z["dur"]):
			zones.remove_at(i)
		else:
			i += 1
	queue_redraw()

func _apply(z: Dictionary) -> void:
	var type: StringName = z["type"]
	if type == &"acid" or type == &"hellfire":
		if player.global_position.distance_to(z["pos"]) < float(z["r"]) + 20.0:
			RunState.damage_player(float(z["dmg"]))
		return
	var tags: Array = [&"fire"] if type == &"smoke" else [&"holy"]
	var hits := horde.query_circle(z["pos"], float(z["r"]))
	for idx in hits:
		run.hit_enemy(idx, float(z["dmg"]), tags, z["pos"], false)
	run.hit_elites_at(z["pos"], float(z["r"]), float(z["dmg"]), tags)

func _draw() -> void:
	for z in zones:
		var type: StringName = z["type"]
		var t := float(z["t"])
		var dur := float(z["dur"])
		var fade := clampf(minf(t * 3.0, (dur - t) * 1.5), 0.0, 1.0)
		var p: Vector2 = z["pos"]
		var r := float(z["r"])
		match type:
			&"smoke":
				var pulse := 1.0 + 0.06 * sin(t * 5.0)
				draw_circle(p, r * pulse, Color(0.85, 0.75, 0.55, 0.10 * fade))
				draw_circle(p, r * 0.62 * pulse, Color(1.0, 0.85, 0.55, 0.13 * fade))
				draw_circle(p, r * 0.3, Color(1.35, 1.1, 0.7, 0.16 * fade))
			&"pool":
				draw_circle(p, r, Color(0.5, 0.75, 1.2, 0.14 * fade))
				draw_circle(p, r * 0.7, Color(0.7, 0.9, 1.5, 0.15 * fade))
				var shimmer := 0.5 + 0.5 * sin(t * 6.0)
				draw_arc(p, r * 0.92, 0, TAU, 40, Color(1.2, 1.4, 1.9, (0.12 + 0.1 * shimmer) * fade), 3.0)
			&"pillar":
				draw_circle(p, r, Color(1.5, 1.35, 0.95, 0.20 * fade))
				draw_circle(p, r * 0.5, Color(1.9, 1.7, 1.3, 0.28 * fade))
			&"acid":
				draw_circle(p, r, Color(0.45, 0.62, 0.2, 0.30 * fade))
				draw_circle(p, r * 0.6, Color(0.62, 0.83, 0.3, 0.25 * fade))
			&"hellfire":
				draw_circle(p, r, Color(1.2, 0.45, 0.15, 0.25 * fade))
				draw_circle(p, r * 0.55, Color(1.6, 0.8, 0.3, 0.22 * fade))
