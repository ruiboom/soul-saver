extends Node
## All mutable state for the current run + the stat pipeline.

signal grace_changed
signal leveled_up
signal hp_changed
signal vestige_claimed(index: int)
signal bell_tolled(bell: int)
signal marks_changed

# --- timeline
var time := 0.0
var bell := 0                      # index into Data.BELLS reached so far
var warden_spawned := false
var over := false

# --- player condition
var hp := 100.0
var invuln := 0.0
var god := false

# --- progression
var level := 1
var grace := 0.0
var grace_needed := Data.xp_for_level(1)
var kills := 0
var marks_earned := 0
var vestiges: Array = [false, false, false, false, false, false, false]
var rerolls := 0
var weapons: Dictionary = {}       # id -> {"level": int, "exalted": bool}
var passives: Dictionary = {}      # id -> level

# --- computed stats
var might := 1.0
var area := 1.0
var haste := 1.0
var speed_mult := 1.0
var magnet := 90.0
var grace_gain := 1.0
var maxhp := 100.0
var armor := 0.0
var revives := 0

func vestige_count() -> int:
	var n := 0
	for v in vestiges:
		if v: n += 1
	return n

func reset() -> void:
	time = 0.0; bell = 0; warden_spawned = false; over = false
	level = 1; grace = 0.0; grace_needed = Data.xp_for_level(1)
	kills = 0; marks_earned = 0
	vestiges = [false, false, false, false, false, false, false]
	weapons = {}; passives = {}
	invuln = 0.0; god = false
	rerolls = int(MetaSave.blessing_stat_bonus(&"reroll"))
	recompute()
	hp = maxhp

func recompute() -> void:
	might = 1.0 + MetaSave.blessing_stat_bonus(&"might")
	area = 1.0
	haste = 1.0
	speed_mult = 1.0 + MetaSave.blessing_stat_bonus(&"speed")
	magnet = 90.0
	grace_gain = 1.0
	maxhp = 100.0 + MetaSave.blessing_stat_bonus(&"maxhp")
	armor = 0.0
	revives = 0
	for id in passives.keys():
		var p: Dictionary = Data.PASSIVES[id]
		var lvl: int = passives[id]
		var amt: float = float(p["per_level"]) * lvl
		match p["stat"]:
			&"might": might += amt
			&"maxhp": maxhp += amt
			&"haste": haste += amt
			&"speed": speed_mult += amt
			&"magnet": magnet *= (1.0 + amt)
			&"grace_gain": grace_gain += amt
			&"revive": revives += int(amt)
			&"area": area += amt
	hp = minf(hp, maxhp)
	hp_changed.emit()

func add_grace(v: float) -> void:
	grace += v * grace_gain
	var leveled := false
	while grace >= grace_needed:
		grace -= grace_needed
		level += 1
		grace_needed = Data.xp_for_level(level)
		leveled = true
	grace_changed.emit()
	if leveled:
		leveled_up.emit()

func damage_player(amount: float) -> bool:
	## Returns true if the hit landed (not i-framed / god / dead).
	if over or god or invuln > 0.0 or hp <= 0.0:
		return false
	var final := maxf(1.0, amount - armor)
	hp -= final
	invuln = 0.6
	hp_changed.emit()
	AudioDirector.play(&"hurt", -4.0)
	return true

func heal(amount: float) -> void:
	hp = minf(maxhp, hp + amount)
	hp_changed.emit()

func add_marks(n: int) -> void:
	marks_earned += n
	marks_changed.emit()

func claim_vestige(i: int) -> void:
	vestiges[i] = true
	vestige_claimed.emit(i)

func weapon_level(id: StringName) -> int:
	return int(weapons.get(id, {}).get("level", 0))

func is_exalted(id: StringName) -> bool:
	return bool(weapons.get(id, {}).get("exalted", false))

func summary() -> Dictionary:
	return {
		"time": time, "kills": kills, "marks": marks_earned, "level": level,
		"vestiges": vestiges.duplicate(), "true_ending": vestige_count() == 7 and over,
	}
