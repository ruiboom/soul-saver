class_name Data
## All game content tables. Balance lives here, systems live elsewhere.

const GOLD := Color(0.910, 0.714, 0.298)
const HALO := Color(1.0, 0.953, 0.839)
const GRACE := Color(0.812, 0.902, 1.0)
const EMBER := Color(1.0, 0.42, 0.17)
const SICK := Color(0.498, 0.682, 0.243)

# ---------------------------------------------------------------- WEAPONS
# base: level-1 numbers. grow: per-level multiplier on dmg. milestones: level -> extras.
const WEAPONS := {
	&"thurible": {
		"name": "The Thurible", "icon": "res://assets/icons/weap_thurible.svg",
		"flavor": "Anselm's own censer. It has swung at worse than demons.",
		"pair": &"coal", "exalt_name": "Censer of the Seraphim",
		"base": {"cd": 1.3, "dmg": 17.0, "range": 200.0, "arc": 140.0, "smoke_dmg": 4.0, "smoke_dur": 2.2, "amount": 1},
		"grow": {"dmg": 0.30, "range": 0.05, "arc": 0.06},
		"milestones": {3: {"amount": 1}, 6: {"smoke_dur": 1.2}},
		"tags": [&"fire"],
	},
	&"holy_water": {
		"name": "Holy Water", "icon": "res://assets/icons/weap_holywater.svg",
		"flavor": "Blessed in San Rocco. Burns what baptism cannot reach.",
		"pair": &"chalice", "exalt_name": "The Baptismal Flood",
		"base": {"cd": 2.6, "dmg": 8.0, "pool_r": 110.0, "pool_dur": 3.2, "amount": 1},
		"grow": {"dmg": 0.28, "pool_r": 0.07},
		"milestones": {3: {"amount": 1}, 5: {"amount": 1}, 7: {"pool_dur": 1.5}},
		"tags": [&"holy"],
	},
	&"rosary": {
		"name": "The Rosary", "icon": "res://assets/icons/weap_rosary.svg",
		"flavor": "Fifty-nine beads. Each one a small, hard prayer.",
		"pair": &"ring", "exalt_name": "The Sorrowful Mysteries",
		"base": {"dmg": 10.0, "orbit_r": 140.0, "orbit_speed": 2.4, "amount": 3, "cd": 0.0},
		"grow": {"dmg": 0.30, "orbit_r": 0.05},
		"milestones": {2: {"amount": 1}, 4: {"amount": 1}, 6: {"amount": 1}, 8: {"amount": 1}},
		"tags": [&"holy"],
	},
	&"psalter": {
		"name": "Psalter of War", "icon": "res://assets/icons/weap_psalter.svg",
		"flavor": "The verses fly out like sparrows with knives.",
		"pair": &"manuscript", "exalt_name": "The Last Word",
		"base": {"cd": 1.1, "dmg": 12.0, "speed": 700.0, "pierce": 1, "amount": 2},
		"grow": {"dmg": 0.26, "speed": 0.04},
		"milestones": {3: {"amount": 1}, 5: {"pierce": 1}, 7: {"amount": 1}},
		"tags": [&"holy"],
	},
	&"paten": {
		"name": "Communion Paten", "icon": "res://assets/icons/weap_paten.svg",
		"flavor": "The golden dish returns. It always returns.",
		"pair": &"chalice", "exalt_name": "The Unbroken Host",
		"base": {"cd": 2.0, "dmg": 16.0, "speed": 620.0, "amount": 1, "flight": 0.55},
		"grow": {"dmg": 0.32, "speed": 0.05},
		"milestones": {3: {"amount": 1}, 6: {"amount": 1}},
		"tags": [&"holy"],
	},
	&"bell": {
		"name": "Sanctus Bell", "icon": "res://assets/icons/weap_bell.svg",
		"flavor": "At its voice, even the damned stand still.",
		"pair": &"stole", "exalt_name": "The Bell of Matins",
		"base": {"cd": 3.4, "dmg": 12.0, "radius": 260.0, "stun": 0.8},
		"grow": {"dmg": 0.28, "radius": 0.08},
		"milestones": {4: {"stun": 0.4}, 7: {"stun": 0.4}},
		"tags": [&"holy"],
	},
	&"pillar": {
		"name": "Pillar of the Choir", "icon": "res://assets/icons/weap_pillar.svg",
		"flavor": "Somewhere above, someone is still singing.",
		"pair": &"candle", "exalt_name": "The Cherubim Descend",
		"base": {"cd": 2.2, "dmg": 24.0, "radius": 95.0, "amount": 1},
		"grow": {"dmg": 0.34, "radius": 0.05},
		"milestones": {3: {"amount": 1}, 5: {"amount": 1}, 7: {"amount": 1}},
		"tags": [&"holy"],
	},
	&"crown": {
		"name": "Crown of Thorns", "icon": "res://assets/icons/weap_crown.svg",
		"flavor": "Worn, not wielded. Grief with a sharp edge.",
		"pair": &"palm", "exalt_name": "The Passion",
		"base": {"cd": 0.5, "dmg": 5.0, "radius": 150.0},
		"grow": {"dmg": 0.34, "radius": 0.07},
		"milestones": {},
		"tags": [&"holy"],
	},
	&"sword": {
		"name": "Sword of St. Michael", "icon": "res://assets/icons/weap_sword.svg",
		"flavor": "He will not miss it. He has another.",
		"pair": &"medal", "exalt_name": "The Prince of the Host",
		"base": {"cd": 4.0, "dmg": 46.0, "radius": 230.0},
		"grow": {"dmg": 0.36, "radius": 0.05},
		"milestones": {5: {"cd_mult": 0.85}},
		"tags": [&"holy"],
	},
}
const MAX_WEAPON_LEVEL := 8
const WEAPON_SLOTS := 6
const PASSIVE_SLOTS := 6

# ---------------------------------------------------------------- PASSIVES
const PASSIVES := {
	&"coal": {"name": "Embered Coal", "icon": "res://assets/icons/pass_coal.svg", "max": 5,
		"stat": &"might", "per_level": 0.08, "desc": "+8% Might per level. A live coal from a censer that never went out."},
	&"chalice": {"name": "Sacramental Wine", "icon": "res://assets/icons/pass_chalice.svg", "max": 5,
		"stat": &"maxhp", "per_level": 15.0, "desc": "+15 Consecration per level. Strength for the road."},
	&"stole": {"name": "Deacon's Stole", "icon": "res://assets/icons/pass_stole.svg", "max": 5,
		"stat": &"haste", "per_level": 0.06, "desc": "Relics act 6% sooner per level."},
	&"medal": {"name": "St. Christopher Medal", "icon": "res://assets/icons/pass_medal.svg", "max": 3,
		"stat": &"speed", "per_level": 0.08, "desc": "+8% move speed per level. Patron of travellers, even here."},
	&"candle": {"name": "Candle of the Vigil", "icon": "res://assets/icons/pass_candle.svg", "max": 4,
		"stat": &"magnet", "per_level": 0.25, "desc": "+25% grace-gathering radius per level. And a little more light."},
	&"manuscript": {"name": "Illuminated Manuscript", "icon": "res://assets/icons/pass_manuscript.svg", "max": 4,
		"stat": &"grace_gain", "per_level": 0.10, "desc": "+10% Grace gained per level."},
	&"palm": {"name": "Martyr's Palm", "icon": "res://assets/icons/pass_palm.svg", "max": 1,
		"stat": &"revive", "per_level": 1.0, "desc": "Rise once from death with half your Consecration."},
	&"ring": {"name": "Bishop's Ring", "icon": "res://assets/icons/pass_ring.svg", "max": 4,
		"stat": &"area", "per_level": 0.08, "desc": "+8% Area per level. Authority has reach."},
}

# ---------------------------------------------------------------- ENEMIES
# radius = collision radius px. scale = sprite scale. special in:
#   phase (drifts, no separation), dive (speed bursts), burst (acid pool on death),
#   tank (knockback/stagger resist), steal (hunts grace embers), fire_immune
const ENEMIES := {
	&"ashimp": {"name": "Ash-imp", "sprite": "res://assets/sprites/enemy_ashimp.svg",
		"hp": 12.0, "speed": 105.0, "dmg": 6.0, "radius": 26.0, "xp": 1, "scale": 0.55, "special": &"", "tint": Color(1,1,1)},
	&"gnasher": {"name": "Gnasher", "sprite": "res://assets/sprites/enemy_gnasher.svg",
		"hp": 9.0, "speed": 195.0, "dmg": 7.0, "radius": 26.0, "xp": 1, "scale": 0.6, "special": &"dive", "tint": Color(1,1,1)},
	&"bloatgrub": {"name": "Bloatgrub", "sprite": "res://assets/sprites/enemy_bloatgrub.svg",
		"hp": 30.0, "speed": 55.0, "dmg": 8.0, "radius": 32.0, "xp": 2, "scale": 0.62, "special": &"burst", "tint": Color(1,1,1)},
	&"wailer": {"name": "Wailer", "sprite": "res://assets/sprites/enemy_wailer.svg",
		"hp": 18.0, "speed": 80.0, "dmg": 9.0, "radius": 26.0, "xp": 2, "scale": 0.62, "special": &"phase", "tint": Color(1,1,1)},
	&"chainbrute": {"name": "Chain-brute", "sprite": "res://assets/sprites/enemy_chainbrute.svg",
		"hp": 90.0, "speed": 62.0, "dmg": 14.0, "radius": 42.0, "xp": 4, "scale": 0.62, "special": &"tank", "tint": Color(1,1,1)},
	&"fury": {"name": "Fury", "sprite": "res://assets/sprites/enemy_fury.svg",
		"hp": 22.0, "speed": 150.0, "dmg": 10.0, "radius": 27.0, "xp": 3, "scale": 0.62, "special": &"dive", "tint": Color(1,1,1)},
	&"pyrewight": {"name": "Pyre-wight", "sprite": "res://assets/sprites/enemy_pyrewight.svg",
		"hp": 45.0, "speed": 95.0, "dmg": 12.0, "radius": 27.0, "xp": 3, "scale": 0.62, "special": &"fire_immune", "tint": Color(1,1,1)},
	&"scribe": {"name": "Ledger-scribe", "sprite": "res://assets/sprites/enemy_scribe.svg",
		"hp": 40.0, "speed": 160.0, "dmg": 5.0, "radius": 26.0, "xp": 6, "scale": 0.6, "special": &"steal", "tint": Color(1,1,1)},
}

# Wave tables layered in per bell (minute*60). {id, weight}
const BELLS := [
	{"time": 0.0,   "name": "Vespers",  "waves": [{"id": &"ashimp", "w": 10.0}, {"id": &"gnasher", "w": 2.0}]},
	{"time": 240.0, "name": "Compline", "waves": [{"id": &"ashimp", "w": 7.0}, {"id": &"gnasher", "w": 4.0}, {"id": &"bloatgrub", "w": 3.0}, {"id": &"wailer", "w": 2.5}]},
	{"time": 480.0, "name": "Nocturns", "waves": [{"id": &"ashimp", "w": 5.0}, {"id": &"gnasher", "w": 4.0}, {"id": &"wailer", "w": 3.0}, {"id": &"chainbrute", "w": 2.0}, {"id": &"fury", "w": 3.0}]},
	{"time": 720.0, "name": "Lauds",    "waves": [{"id": &"gnasher", "w": 4.0}, {"id": &"bloatgrub", "w": 3.0}, {"id": &"fury", "w": 4.0}, {"id": &"pyrewight", "w": 3.5}, {"id": &"chainbrute", "w": 2.5}, {"id": &"scribe", "w": 1.2}]},
	{"time": 960.0, "name": "Matins",   "waves": [{"id": &"wailer", "w": 4.0}, {"id": &"fury", "w": 4.0}, {"id": &"pyrewight", "w": 4.0}, {"id": &"chainbrute", "w": 3.5}, {"id": &"scribe", "w": 1.5}, {"id": &"gnasher", "w": 3.0}]},
]
const WARDEN_TIME := 1080.0      # 18:00 — the Warden rises
const SURVIVOR_TIME := 1260.0    # 21:00 — outlast it and the night ends

# ---------------------------------------------------------------- SHRINEKEEPERS & VESTIGES
const KEEPERS := [
	{"name": "Gullet, Keeper of the Name", "tint": Color(0.75, 0.9, 0.55), "hp": 380.0, "pattern": &"summon", "scale": 1.0},
	{"name": "Mirrorface, Keeper of the Face", "tint": Color(0.7, 0.85, 1.1), "hp": 420.0, "pattern": &"spit", "scale": 0.95},
	{"name": "Hollow-Bell, Keeper of the Voice", "tint": Color(1.05, 0.8, 0.5), "hp": 460.0, "pattern": &"charge", "scale": 1.05},
	{"name": "The Middenwife, Keeper of the Laugh", "tint": Color(1.0, 0.6, 0.6), "hp": 520.0, "pattern": &"summon", "scale": 1.1},
	{"name": "Rust-Sexton, Keeper of the Fear", "tint": Color(0.85, 0.7, 1.0), "hp": 560.0, "pattern": &"spit", "scale": 1.05},
	{"name": "The Unlit, Keeper of the Sea", "tint": Color(0.6, 0.75, 1.0), "hp": 620.0, "pattern": &"charge", "scale": 1.15},
	{"name": "Ledger-Warden, Keeper of the Heart", "tint": Color(1.1, 0.9, 0.55), "hp": 700.0, "pattern": &"summon", "scale": 1.2},
]

const VIGNETTES := [
	{"title": "The First Vestige — Her Name", "lines": ["\"Lucia.\" The wisp says it like a bell struck once, far away.", "\"Lucia Ferro. Nine years old. Write it down, priest —\"", "\"— they tried to cross it out.\""]},
	{"title": "The Second Vestige — Her Face", "lines": ["A gap-toothed grin, freckles, one scraped cheek from the fig tree.", "Anselm has buried many faces. This one he will carry back up."]},
	{"title": "The Third Vestige — Her Voice", "lines": ["\"Father, if God is everywhere, is he HERE?\"", "Anselm looks at the burning horizon. \"He is now,\" he says."]},
	{"title": "The Fourth Vestige — Her Laugh", "lines": ["It escapes the shrine like a bird from a cellar.", "For three full seconds, nothing in Hell dares make a sound."]},
	{"title": "The Fifth Vestige — Her Fear", "lines": ["\"I wasn't scared of dying,\" the wisp whispers.", "\"I was scared no one would come.\"", "\"Someone came,\" says Anselm. \"Hold still.\""]},
	{"title": "The Sixth Vestige — The Sea", "lines": ["One afternoon at Rimini, the whole family, gulls, salt, and sunburn.", "The demons kept this one on display. Even they missed the sun."]},
	{"title": "The Seventh Vestige — Her Heart", "lines": ["It is very small and impossibly heavy, like all hearts.", "\"Now,\" says Anselm, tucking it into the crucifix, \"we go home.\"", "Every bell in the Black Cathedral begins to scream."]},
]

# ---------------------------------------------------------------- META BLESSINGS
const BLESSINGS := {
	&"fervor": {"name": "Blessing of Fervor", "desc": "+6% Might per rank.", "max": 5, "cost": [15, 30, 60, 100, 160], "stat": &"might", "per": 0.06},
	&"vigor": {"name": "Blessing of Vigor", "desc": "+12 Consecration per rank.", "max": 5, "cost": [10, 25, 50, 85, 140], "stat": &"maxhp", "per": 12.0},
	&"alacrity": {"name": "Blessing of Alacrity", "desc": "+4% speed per rank.", "max": 3, "cost": [20, 45, 90], "stat": &"speed", "per": 0.04},
	&"providence": {"name": "Blessing of Providence", "desc": "+1 draft reroll per rank.", "max": 2, "cost": [30, 80], "stat": &"reroll", "per": 1.0},
}

# ---------------------------------------------------------------- helpers
static func weapon_params(id: StringName, level: int, exalted: bool) -> Dictionary:
	var w: Dictionary = WEAPONS[id]
	var p: Dictionary = (w["base"] as Dictionary).duplicate()
	var grow: Dictionary = w["grow"]
	for k in grow.keys():
		p[k] = p[k] * (1.0 + float(grow[k]) * float(level - 1))
	for ml in (w["milestones"] as Dictionary).keys():
		if level >= int(ml):
			var extra: Dictionary = w["milestones"][ml]
			for k in extra.keys():
				if k == "cd_mult":
					p["cd"] = p["cd"] * float(extra[k])
				else:
					p[k] = p.get(k, 0) + extra[k]
	if exalted:
		p["dmg"] = p["dmg"] * 1.6
		if p.has("cd"):
			p["cd"] = p["cd"] * 0.8
	return p

static func xp_for_level(n: int) -> float:
	return 20.0 + 8.0 * n + 1.0 * n * n

static func enemy_scaling(t: float, bell: int) -> Dictionary:
	return {
		"hp": 1.0 + t / 60.0 * 0.10 + bell * 0.38,
		"dmg": 1.0 + t / 60.0 * 0.04 + bell * 0.18,
		"speed": 1.0 + minf(0.35, t / 60.0 * 0.016),
	}

static func spawn_budget(t: float) -> int:
	# gentle open (~12 demons), full boil by the late bells
	return mini(520, int(12.0 + t * 0.5))
