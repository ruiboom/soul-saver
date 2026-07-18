extends Node
## Seeded RNG streams — draft, spawn, loot, world are independent so debugging one
## doesn't shift the others.

var draft := RandomNumberGenerator.new()
var spawn := RandomNumberGenerator.new()
var loot := RandomNumberGenerator.new()
var world := RandomNumberGenerator.new()

func reseed(run_seed: int) -> void:
	draft.seed = run_seed
	spawn.seed = run_seed + 101
	loot.seed = run_seed + 202
	world.seed = run_seed + 303
