extends CanvasLayer
class_name Overlays
## Vignettes (Lucia's memories), pause menu, and the run-ending screens.

var run
var _root: Control
var _mode := &""            # vignette | pause | summary
var _continue_cb := Callable()
var autotest_autoclose := false
var _auto_t := 0.0

func _process(delta: float) -> void:
	if visible and autotest_autoclose and _mode == &"vignette":
		_auto_t += delta
		if _auto_t > 2.5:
			_auto_t = 0.0
			var cb := _continue_cb
			hide_overlay()
			if cb.is_valid():
				cb.call()
	elif visible and autotest_autoclose and _mode == &"summary":
		_auto_t += delta
		if _auto_t > 4.0:
			print("[autotest] SUMMARY reached: kills=%d level=%d vestiges=%d time=%.0f" % [
				RunState.kills, RunState.level, RunState.vestige_count(), RunState.time])
			get_tree().quit()
	else:
		_auto_t = 0.0

func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_root = Control.new()
	_root.position = Vector2.ZERO
	_root.size = Vector2(1920, 1080)
	add_child(_root)
	visible = false

func _clear() -> void:
	for c in _root.get_children():
		c.queue_free()

func _dim(alpha := 0.86) -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.01, 0.005, 0.03, alpha)
	dim.position = Vector2.ZERO
	dim.size = Vector2(1920, 1080)
	_root.add_child(dim)

func _center_box() -> VBoxContainer:
	var v := VBoxContainer.new()
	v.position = Vector2(460, 240)
	v.size = Vector2(1000, 600)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override(&"separation", 22)
	_root.add_child(v)
	return v

# ---------------------------------------------------------------- vignette
func show_vignette(index: int, on_done: Callable) -> void:
	_mode = &"vignette"
	_continue_cb = on_done
	_clear()
	_dim(0.9)
	var v := _center_box()
	var wisp := TextureRect.new()
	wisp.texture = load("res://assets/sprites/lucia_wisp.svg")
	wisp.custom_minimum_size = Vector2(140, 140)
	wisp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wisp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	wisp.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	wisp.modulate = Color(1.3, 1.4, 1.8)
	v.add_child(wisp)
	var data: Dictionary = Data.VIGNETTES[index]
	var title := Game.make_label(data["title"], 44, Data.GRACE, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	for line: String in data["lines"]:
		var l := Game.make_label(line, 27, Color(0.88, 0.85, 0.8))
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(900, 0)
		v.add_child(l)
	var hint := Game.make_label("— press Interact —", 20, Color(0.55, 0.5, 0.45))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(hint)
	# gentle fade-in of lines
	var idx := 0
	for c in v.get_children():
		if c is Label:
			c.modulate.a = 0.0
			var tw := create_tween()
			tw.tween_interval(0.25 * idx)
			tw.tween_property(c, "modulate:a", 1.0, 0.6)
			idx += 1
	visible = true
	get_tree().paused = true
	AudioDirector.play(&"vestige", -2.0)

# ---------------------------------------------------------------- pause
func show_pause() -> void:
	_mode = &"pause"
	_clear()
	_dim(0.75)
	var v := _center_box()
	var title := Game.make_label("The Descent Pauses", 56, Data.GOLD, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var stats := Game.make_label(_loadout_text(), 22, Color(0.75, 0.72, 0.66))
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats.custom_minimum_size = Vector2(880, 0)
	v.add_child(stats)
	var resume := Game.make_button("Resume")
	resume.pressed.connect(hide_overlay)
	v.add_child(resume)
	var abandon := Game.make_button("Abandon the Soul (quit to chapel)")
	abandon.pressed.connect(func() -> void:
		Game.end_run(RunState.summary())
		Game.goto_title())
	v.add_child(abandon)
	resume.grab_focus.call_deferred()
	visible = true
	get_tree().paused = true

func _loadout_text() -> String:
	var parts: Array[String] = []
	for id in RunState.weapons.keys():
		var w: Dictionary = Data.WEAPONS[id]
		var tag: String = w["exalt_name"] if RunState.is_exalted(id) else "%s %d" % [w["name"], RunState.weapon_level(id)]
		parts.append(tag)
	for id in RunState.passives.keys():
		parts.append("%s %d" % [Data.PASSIVES[id]["name"], RunState.passives[id]])
	return " · ".join(parts) if parts.size() > 0 else "Only the thurible and his conviction."

# ---------------------------------------------------------------- endings
func show_summary(kind: StringName) -> void:
	_mode = &"summary"
	_clear()
	_dim(0.94)
	var v := _center_box()
	var title_text := ""
	var sub := ""
	var col := Data.GOLD
	match kind:
		&"true":
			title_text = "THE GATE OPENS"
			sub = "Anselm walks out of Hell with a whole child's soul held against his chest.\nSomewhere above, a fever breaks. Somewhere below, a ledger burns."
			col = Data.HALO
		&"survivor":
			title_text = "DAWN, WITHOUT HER"
			sub = "The bells fall silent. Anselm lives — and Lucia remains below.\nHe will rest. He will pray. He will come back down."
			col = Color(0.85, 0.75, 0.55)
		&"death":
			title_text = "HELL KEEPS HIM"
			sub = "The ash takes another name into its ledger.\nBut ledgers, as Malacoda knows, can be amended…"
			col = Color(0.9, 0.35, 0.3)
	var title := Game.make_label(title_text, 64, col, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title)
	var subl := Game.make_label(sub, 26, Color(0.8, 0.77, 0.72))
	subl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subl.custom_minimum_size = Vector2(900, 0)
	v.add_child(subl)
	var s := RunState.summary()
	var stats_text := "Survived %02d:%02d   ·   Grace %d   ·   %d souls freed   ·   %d / 7 vestiges   ·   +%d Ossuary Marks" % [
		int(RunState.time) / 60, int(RunState.time) % 60, RunState.level, RunState.kills,
		RunState.vestige_count(), RunState.marks_earned]
	var stats := Game.make_label(stats_text, 24, Color(0.75, 0.7, 0.6))
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(stats)
	var cont := Game.make_button("Return to the Chapel")
	cont.pressed.connect(func() -> void:
		Game.goto_title())
	v.add_child(cont)
	cont.grab_focus.call_deferred()
	Game.end_run(s)
	visible = true
	get_tree().paused = true

func hide_overlay() -> void:
	visible = false
	_mode = &""
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if _mode == &"vignette" and (event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_accept")):
		var cb := _continue_cb
		hide_overlay()
		if cb.is_valid():
			cb.call()
	elif _mode == &"pause" and event.is_action_pressed(&"pause"):
		hide_overlay()
