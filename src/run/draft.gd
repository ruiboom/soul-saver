extends CanvasLayer
class_name Draft
## The level-up draft: relics stirring in the ash. Pauses the tree while open.

signal closed

var run
var _panel: Control
var _cards_box: HBoxContainer
var _title: Label
var _sub: Label
var _footer: HBoxContainer
var _current_offers: Array = []
var _free_pick := false

const RARITY_COLORS := {
	0: Color(0.62, 0.58, 0.5),      # common — worn silver
	1: Color(0.55, 0.68, 0.95),     # blessed — grace blue
	2: Color(0.75, 0.5, 0.95),      # venerated — violet
	3: Color(1.0, 0.8, 0.35),       # sanctified — gold
}

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = Control.new()
	_panel.position = Vector2.ZERO
	_panel.size = Vector2(1920, 1080)
	add_child(_panel)
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.01, 0.04, 0.82)
	dim.position = Vector2.ZERO
	dim.size = Vector2(1920, 1080)
	_panel.add_child(dim)
	var v := VBoxContainer.new()
	v.position = Vector2(400, 200)
	v.size = Vector2(1120, 680)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override(&"separation", 26)
	_panel.add_child(v)
	_title = Game.make_label("A relic stirs in the ash", 52, Data.GOLD, true)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_title)
	_sub = Game.make_label("Choose what wakes", 24, Color(0.7, 0.65, 0.55))
	_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(_sub)
	_cards_box = HBoxContainer.new()
	_cards_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_cards_box.add_theme_constant_override(&"separation", 30)
	v.add_child(_cards_box)
	_footer = HBoxContainer.new()
	_footer.alignment = BoxContainer.ALIGNMENT_CENTER
	_footer.add_theme_constant_override(&"separation", 24)
	v.add_child(_footer)
	visible = false

# ---------------------------------------------------------------- offer building
func _eligible_offers() -> Array:
	var offers: Array = []
	var owned_weapons := RunState.weapons.keys()
	var owned_passives := RunState.passives.keys()
	# exaltations first — if eligible, they appear
	for id in owned_weapons:
		var w: Dictionary = Data.WEAPONS[id]
		if RunState.weapon_level(id) >= Data.MAX_WEAPON_LEVEL and not RunState.is_exalted(id) \
				and int(RunState.passives.get(w["pair"], 0)) >= 3:
			offers.append({"kind": &"exalt", "id": id, "weight": 100.0, "rarity": 3})
	for id in Data.WEAPONS.keys():
		if owned_weapons.has(id):
			if RunState.weapon_level(id) < Data.MAX_WEAPON_LEVEL:
				offers.append({"kind": &"weapon_up", "id": id, "weight": 3.0, "rarity": 1})
		elif owned_weapons.size() < Data.WEAPON_SLOTS:
			offers.append({"kind": &"weapon_new", "id": id, "weight": 2.0, "rarity": 2 if id == &"sword" else 1})
	for id in Data.PASSIVES.keys():
		var p: Dictionary = Data.PASSIVES[id]
		if owned_passives.has(id):
			if int(RunState.passives[id]) < int(p["max"]):
				offers.append({"kind": &"passive_up", "id": id, "weight": 3.0, "rarity": 0})
		elif owned_passives.size() < Data.PASSIVE_SLOTS:
			offers.append({"kind": &"passive_new", "id": id, "weight": 2.0, "rarity": 0})
	return offers

func _draw_offers(n: int) -> Array:
	var pool := _eligible_offers()
	var out: Array = []
	while out.size() < n and not pool.is_empty():
		var total := 0.0
		for o in pool:
			total += float(o["weight"])
		var roll := Rngs.draft.randf() * total
		for i in pool.size():
			roll -= float(pool[i]["weight"])
			if roll <= 0.0:
				out.append(pool[i])
				pool.remove_at(i)
				break
	return out

# ---------------------------------------------------------------- display
func open(title: String = "A relic stirs in the ash", free_pick: bool = false) -> void:
	_free_pick = free_pick
	_title.text = title
	_current_offers = _draw_offers(3)
	if _current_offers.is_empty():
		# nothing left to offer — a mouthful of grace instead
		RunState.heal(20.0)
		return
	_rebuild_cards()
	visible = true
	get_tree().paused = true
	AudioDirector.play(&"levelup" if not free_pick else &"fanfare", -4.0)

func _rebuild_cards() -> void:
	for c in _cards_box.get_children():
		c.queue_free()
	for f in _footer.get_children():
		f.queue_free()
	var first_btn: Button = null
	for o in _current_offers:
		var card := _make_card(o)
		_cards_box.add_child(card)
		if first_btn == null:
			first_btn = card
	if RunState.rerolls > 0 and not _free_pick:
		var rr := Game.make_button("Reroll (%d)" % RunState.rerolls, 22)
		rr.pressed.connect(func() -> void:
			RunState.rerolls -= 1
			_current_offers = _draw_offers(3)
			_rebuild_cards())
		_footer.add_child(rr)
	var skip := Game.make_button("Let them sleep  (+15 grace)", 22)
	skip.pressed.connect(func() -> void:
		_close()
		RunState.add_grace(15.0))
	_footer.add_child(skip)
	if first_btn:
		first_btn.grab_focus.call_deferred()

func _offer_text(o: Dictionary) -> Array:
	var kind: StringName = o["kind"]
	var id: StringName = o["id"]
	match kind:
		&"exalt":
			var w: Dictionary = Data.WEAPONS[id]
			return ["EXALTATION — %s" % w["exalt_name"], "The relic transfigures. Its true nature wakes.", w["icon"]]
		&"weapon_new":
			var w: Dictionary = Data.WEAPONS[id]
			return [w["name"], w["flavor"], w["icon"]]
		&"weapon_up":
			var w: Dictionary = Data.WEAPONS[id]
			var lvl := RunState.weapon_level(id) + 1
			return ["%s  •  Level %d" % [w["name"], lvl], "The relic burns brighter.", w["icon"]]
		&"passive_new":
			var p: Dictionary = Data.PASSIVES[id]
			return [p["name"], p["desc"], p["icon"]]
		&"passive_up":
			var p: Dictionary = Data.PASSIVES[id]
			var lvl := int(RunState.passives[id]) + 1
			return ["%s  •  Rank %d" % [p["name"], lvl], p["desc"], p["icon"]]
	return ["?", "?", ""]

func _make_card(o: Dictionary) -> Button:
	var texts := _offer_text(o)
	var rarity_col: Color = RARITY_COLORS[int(o["rarity"])]
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(330, 380)
	var sb := Game.make_panel_style(rarity_col, Color(0.07, 0.055, 0.1, 0.96))
	sb.set_border_width_all(3)
	var sb_hover: StyleBoxFlat = sb.duplicate()
	sb_hover.bg_color = Color(0.12, 0.09, 0.16, 0.98)
	sb_hover.border_color = Data.HALO
	btn.add_theme_stylebox_override(&"normal", sb)
	btn.add_theme_stylebox_override(&"hover", sb_hover)
	btn.add_theme_stylebox_override(&"focus", sb_hover)
	btn.add_theme_stylebox_override(&"pressed", sb_hover)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override(&"separation", 14)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	btn.add_child(v)
	var icon := TextureRect.new()
	icon.texture = load(texts[2])
	icon.custom_minimum_size = Vector2(120, 120)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(icon)
	var name_l := Game.make_label(texts[0], 26, rarity_col.lightened(0.3), true)
	name_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_l.custom_minimum_size = Vector2(290, 0)
	v.add_child(name_l)
	var desc_l := Game.make_label(texts[1], 20, Color(0.78, 0.74, 0.68))
	desc_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_l.custom_minimum_size = Vector2(290, 0)
	v.add_child(desc_l)
	btn.pressed.connect(func() -> void: _pick(o))
	btn.mouse_entered.connect(func() -> void: AudioDirector.play(&"ui_select", -16.0))
	return btn

func _pick(o: Dictionary) -> void:
	var kind: StringName = o["kind"]
	var id: StringName = o["id"]
	match kind:
		&"exalt": run.weapons.exalt_weapon(id)
		&"weapon_new", &"weapon_up": run.weapons.add_weapon(id)
		&"passive_new": RunState.passives[id] = 1
		&"passive_up": RunState.passives[id] = int(RunState.passives[id]) + 1
	RunState.recompute()
	AudioDirector.play(&"ui_select", -6.0)
	_close()

func _close() -> void:
	visible = false
	get_tree().paused = false
	closed.emit()
