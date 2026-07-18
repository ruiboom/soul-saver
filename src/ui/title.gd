extends Control
## The Chapel of San Rocco: title, blessings wall, the way down.

var marks_label: Label
var blessings_box: VBoxContainer

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	# backdrop: candle-lit dark
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.045, 0.035, 0.06)
	add_child(bg)
	var glow := TextureRect.new()
	glow.texture = _radial_tex(Color(0.55, 0.38, 0.18, 0.5))
	glow.set_anchors_preset(Control.PRESET_FULL_RECT)
	glow.stretch_mode = TextureRect.STRETCH_SCALE
	add_child(glow)
	var gate := TextureRect.new()
	gate.texture = load("res://assets/env/gate.svg")
	gate.modulate = Color(0.5, 0.42, 0.42, 0.55)
	gate.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	gate.offset_left = -384; gate.offset_right = 384
	gate.offset_top = -600; gate.offset_bottom = 40
	add_child(gate)

	var root := HBoxContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override(&"separation", 40)
	add_child(root)

	# left spacer / main column / right blessings
	var left := VBoxContainer.new()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	left.add_theme_constant_override(&"separation", 18)
	root.add_child(left)

	var title := Game.make_label("SOUL SAVER", 110, Data.GOLD, true)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(title)
	var sub := Game.make_label("A priest. All of Hell. One innocent soul.", 28, Color(0.75, 0.7, 0.62))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(sub)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	left.add_child(spacer)

	var begin := Game.make_button("Begin the Descent", 36)
	begin.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	begin.pressed.connect(func() -> void: Game.start_run())
	left.add_child(begin)

	var howto := Game.make_label("Move: WASD / stick.  Relics act on their own.  Interact: Space.\nFollow the gold thread to Lucia's seven Vestiges. Survive the bells.", 22, Color(0.6, 0.56, 0.5))
	howto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(howto)

	var stats_text := "Runs: %d   ·   Souls freed: %d   ·   Best: %02d:%02d" % [
		MetaSave.runs_played, MetaSave.total_kills, int(MetaSave.best_time) / 60, int(MetaSave.best_time) % 60]
	if MetaSave.true_ending_seen:
		stats_text += "   ·   ✝ Lucia saved"
	var stats := Game.make_label(stats_text, 20, Color(0.5, 0.47, 0.42))
	stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(stats)

	var quit := Game.make_button("Leave the Chapel", 24)
	quit.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	quit.pressed.connect(func() -> void: get_tree().quit())
	left.add_child(quit)

	# blessings wall
	var right := PanelContainer.new()
	right.size_flags_horizontal = Control.SIZE_SHRINK_END
	right.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	right.custom_minimum_size = Vector2(460, 0)
	right.add_theme_stylebox_override(&"panel", Game.make_panel_style())
	root.add_child(right)
	var rv := VBoxContainer.new()
	rv.add_theme_constant_override(&"separation", 12)
	right.add_child(rv)
	var bt := Game.make_label("The Reliquary Wall", 34, Data.GOLD, true)
	rv.add_child(bt)
	marks_label = Game.make_label("", 24, Color(0.85, 0.8, 0.66))
	rv.add_child(marks_label)
	blessings_box = VBoxContainer.new()
	blessings_box.add_theme_constant_override(&"separation", 10)
	rv.add_child(blessings_box)
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(40, 0)
	root.add_child(pad)
	_refresh_blessings()
	begin.grab_focus.call_deferred()
	AudioDirector.music_start()
	AudioDirector.set_intensity(0.0)
	if OS.get_environment("SOULSAVER_TITLE_SHOT") != "":
		var tw := create_tween()
		tw.tween_interval(1.2)
		tw.tween_callback(func() -> void:
			var img := get_viewport().get_texture().get_image()
			img.save_png(OS.get_environment("SOULSAVER_TITLE_SHOT"))
			get_tree().quit())
	elif OS.get_environment("SOULSAVER_AUTOTEST") == "1":
		Game.start_run.call_deferred()

func _radial_tex(c: Color) -> GradientTexture2D:
	var grad := Gradient.new()
	grad.set_color(0, c)
	grad.set_color(1, Color(c.r, c.g, c.b, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.width = 512; gt.height = 512
	gt.fill_from = Vector2(0.5, 0.75); gt.fill_to = Vector2(0.5, 0.1)
	return gt

func _refresh_blessings() -> void:
	marks_label.text = "%d Ossuary Marks" % MetaSave.marks
	for c in blessings_box.get_children():
		c.queue_free()
	for id: StringName in Data.BLESSINGS.keys():
		var b: Dictionary = Data.BLESSINGS[id]
		var rank := MetaSave.blessing_rank(id)
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", 12)
		var info := Game.make_label("%s  %d/%d\n%s" % [b["name"], rank, b["max"], b["desc"]], 19, Color(0.78, 0.74, 0.66))
		info.custom_minimum_size = Vector2(280, 0)
		info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		row.add_child(info)
		if rank < int(b["max"]):
			var cost: int = (b["cost"] as Array)[rank]
			var buy := Game.make_button("%d ✠" % cost, 20)
			buy.disabled = MetaSave.marks < cost
			buy.pressed.connect(func() -> void:
				if MetaSave.try_buy_blessing(id):
					AudioDirector.play(&"fanfare", -8.0)
					_refresh_blessings())
			row.add_child(buy)
		else:
			row.add_child(Game.make_label("complete", 18, Data.GOLD))
		blessings_box.add_child(row)
