extends Node
## Persistent save: Ossuary Marks, blessings, the Vestige Book, unlocks, settings.

const SAVE_PATH := "user://soulsaver_save.json"
const SAVE_VERSION := 1

var marks: int = 0
var blessings: Dictionary = {}          # id -> rank
var vestige_book: Array = [false, false, false, false, false, false, false]
var best_time: float = 0.0
var true_ending_seen: bool = false
var runs_played: int = 0
var total_kills: int = 0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

func _ready() -> void:
	load_save()

func blessing_rank(id: StringName) -> int:
	return int(blessings.get(String(id), 0))

func blessing_stat_bonus(stat: StringName) -> float:
	var total := 0.0
	for id in Data.BLESSINGS.keys():
		var b: Dictionary = Data.BLESSINGS[id]
		if b["stat"] == stat:
			total += float(b["per"]) * blessing_rank(id)
	return total

func try_buy_blessing(id: StringName) -> bool:
	var b: Dictionary = Data.BLESSINGS[id]
	var rank := blessing_rank(id)
	if rank >= int(b["max"]):
		return false
	var cost: int = (b["cost"] as Array)[rank]
	if marks < cost:
		return false
	marks -= cost
	blessings[String(id)] = rank + 1
	save()
	return true

func record_run(result: Dictionary) -> void:
	runs_played += 1
	marks += int(result.get("marks", 0))
	total_kills += int(result.get("kills", 0))
	best_time = maxf(best_time, float(result.get("time", 0.0)))
	if result.get("true_ending", false):
		true_ending_seen = true
	var claimed: Array = result.get("vestiges", [])
	for i in mini(claimed.size(), 7):
		if claimed[i]:
			vestige_book[i] = true
	save()

func save() -> void:
	var data := {
		"version": SAVE_VERSION, "marks": marks, "blessings": blessings,
		"vestige_book": vestige_book, "best_time": best_time,
		"true_ending_seen": true_ending_seen, "runs_played": runs_played,
		"total_kills": total_kills, "music_volume": music_volume, "sfx_volume": sfx_volume,
	}
	var tmp := SAVE_PATH + ".tmp"
	var f := FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data))
	f.close()
	DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp), ProjectSettings.globalize_path(SAVE_PATH))

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	marks = int(d.get("marks", 0))
	blessings = d.get("blessings", {})
	var vb: Array = d.get("vestige_book", [])
	for i in mini(vb.size(), 7):
		vestige_book[i] = bool(vb[i])
	best_time = float(d.get("best_time", 0.0))
	true_ending_seen = bool(d.get("true_ending_seen", false))
	runs_played = int(d.get("runs_played", 0))
	total_kills = int(d.get("total_kills", 0))
	music_volume = float(d.get("music_volume", 1.0))
	sfx_volume = float(d.get("sfx_volume", 1.0))
