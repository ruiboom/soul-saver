extends Control
class_name Hud
## In-run HUD: consecration bar, grace bar, timer/bell, vestige tally, guide thread arrow.

var run
var hp_bar: ProgressBar
var hp_label: Label
var xp_bar: ProgressBar
var level_label: Label
var timer_label: Label
var bell_label: Label
var kills_label: Label
var marks_label: Label
var vestige_row: HBoxContainer
var vestige_icons: Array[TextureRect] = []
var boss_bar: ProgressBar
var boss_label: Label
var _arrow_target := Vector2.INF
var announce_label: Label
var _announce_tw: Tween
var _danger: TextureRect

const DESIGN := Vector2(1920, 1080)

func _ready() -> void:
	# NOTE: Controls under a CanvasLayer don't auto-size from anchors — size explicitly.
	position = Vector2.ZERO
	size = DESIGN
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# --- grace (XP) bar: full-width sliver at very top
	xp_bar = ProgressBar.new()
	xp_bar.position = Vector2.ZERO
	xp_bar.size = Vector2(DESIGN.x, 9)
	xp_bar.custom_minimum_size = Vector2(0, 9)
	xp_bar.show_percentage = false
	_style_bar(xp_bar, Color(0.42, 0.52, 0.78, 0.85), Color(0.07, 0.06, 0.11, 0.7))
	add_child(xp_bar)

	# --- top-left: consecration
	var tl := VBoxContainer.new()
	tl.position = Vector2(24, 30)
	add_child(tl)
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(340, 26)
	hp_bar.show_percentage = false
	_style_bar(hp_bar, Color(0.75, 0.16, 0.2), Color(0.10, 0.05, 0.08, 0.85))
	tl.add_child(hp_bar)
	hp_label = Game.make_label("100 / 100", 18, Color(1, 0.9, 0.85))
	hp_label.position = Vector2(8, 2)
	hp_bar.add_child(hp_label)
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 18)
	tl.add_child(row)
	level_label = Game.make_label("Grace I", 22, Data.GOLD, true)
	row.add_child(level_label)
	kills_label = Game.make_label("0 souls freed", 20, Color(0.75, 0.72, 0.68))
	row.add_child(kills_label)
	marks_label = Game.make_label("0 marks", 20, Color(0.8, 0.76, 0.62))
	row.add_child(marks_label)

	# --- top-center: the hour
	var tc := VBoxContainer.new()
	tc.position = Vector2(DESIGN.x / 2.0 - 220, 26)
	tc.custom_minimum_size = Vector2(440, 0)
	tc.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(tc)
	timer_label = Game.make_label("00:00", 44, Data.HALO, true)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tc.add_child(timer_label)
	bell_label = Game.make_label("Vespers", 22, Color(0.72, 0.6, 0.42), true)
	bell_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tc.add_child(bell_label)

	# --- top-right: vestiges
	var tr := VBoxContainer.new()
	tr.position = Vector2(DESIGN.x - 380, 30)
	tr.custom_minimum_size = Vector2(356, 0)
	add_child(tr)
	var vlabel := Game.make_label("Vestiges of Lucia", 20, Color(0.78, 0.85, 1.0), true)
	tr.add_child(vlabel)
	vestige_row = HBoxContainer.new()
	vestige_row.add_theme_constant_override(&"separation", 8)
	tr.add_child(vestige_row)
	var wisp_tex: Texture2D = load("res://assets/sprites/lucia_wisp.svg")
	for i in 7:
		var icon := TextureRect.new()
		icon.texture = wisp_tex
		icon.custom_minimum_size = Vector2(40, 40)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_SCALE
		icon.modulate = Color(0.55, 0.6, 0.75, 0.9)
		vestige_row.add_child(icon)
		vestige_icons.append(icon)

	# --- boss bar (hidden until the Warden)
	var bc := VBoxContainer.new()
	bc.position = Vector2(DESIGN.x / 2.0 - 330, DESIGN.y - 130)
	bc.custom_minimum_size = Vector2(660, 0)
	add_child(bc)
	boss_label = Game.make_label("THE WARDEN OF THE GATE", 26, Color(1.0, 0.45, 0.3), true)
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.custom_minimum_size = Vector2(660, 0)
	bc.add_child(boss_label)
	boss_bar = ProgressBar.new()
	boss_bar.custom_minimum_size = Vector2(660, 20)
	boss_bar.show_percentage = false
	_style_bar(boss_bar, Color(0.9, 0.3, 0.15), Color(0.08, 0.04, 0.06, 0.9))
	bc.add_child(boss_bar)
	boss_label.visible = false
	boss_bar.visible = false

	# --- announcements (bell tolls etc.)
	announce_label = Game.make_label("", 54, Data.GOLD, true)
	announce_label.position = Vector2(DESIGN.x / 2.0 - 500, DESIGN.y / 2.0 - 280)
	announce_label.custom_minimum_size = Vector2(1000, 90)
	announce_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	announce_label.modulate.a = 0.0
	add_child(announce_label)

	# low-consecration warning vignette
	_danger = TextureRect.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(0.5, 0.02, 0.02, 0.0))
	grad.set_color(1, Color(0.5, 0.02, 0.02, 0.55))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill = GradientTexture2D.FILL_RADIAL
	gt.width = 512; gt.height = 512
	gt.fill_from = Vector2(0.5, 0.5); gt.fill_to = Vector2(0.5, 0.0)
	_danger.texture = gt
	_danger.position = Vector2.ZERO
	_danger.size = DESIGN
	_danger.stretch_mode = TextureRect.STRETCH_SCALE
	_danger.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_danger.modulate.a = 0.0
	add_child(_danger)
	move_child(_danger, 0)

	RunState.hp_changed.connect(_on_hp)
	RunState.grace_changed.connect(_on_grace)
	RunState.vestige_claimed.connect(_on_vestige)
	RunState.marks_changed.connect(_on_marks)
	_on_hp(); _on_grace(); _on_marks()

func _style_bar(bar: ProgressBar, fill: Color, bg: Color) -> void:
	var sb_bg := StyleBoxFlat.new()
	sb_bg.bg_color = bg
	sb_bg.border_color = Color(0.45, 0.36, 0.18)
	sb_bg.set_border_width_all(1)
	sb_bg.set_corner_radius_all(3)
	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = fill
	sb_fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override(&"background", sb_bg)
	bar.add_theme_stylebox_override(&"fill", sb_fill)

func _on_hp() -> void:
	hp_bar.max_value = RunState.maxhp
	hp_bar.value = RunState.hp
	hp_label.text = "%d / %d" % [int(RunState.hp), int(RunState.maxhp)]

func _on_grace() -> void:
	xp_bar.max_value = RunState.grace_needed
	xp_bar.value = RunState.grace
	level_label.text = "Grace %s" % _roman(RunState.level)

func _on_marks() -> void:
	marks_label.text = "%d marks" % RunState.marks_earned

func _on_vestige(i: int) -> void:
	vestige_icons[i].modulate = Color(1.4, 1.5, 1.9, 1.0)

var _flash_rect: ColorRect
func flash_white() -> void:
	if _flash_rect == null:
		_flash_rect = ColorRect.new()
		_flash_rect.position = Vector2.ZERO
		_flash_rect.size = DESIGN
		_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_flash_rect)
	_flash_rect.color = Color(1.0, 0.97, 0.88, 0.85)
	var tw := create_tween()
	tw.tween_property(_flash_rect, "color:a", 0.0, 0.5).set_ease(Tween.EASE_OUT)

func announce(text: String, color: Color = Data.GOLD) -> void:
	announce_label.text = text
	announce_label.add_theme_color_override(&"font_color", color)
	if _announce_tw:
		_announce_tw.kill()
	announce_label.modulate.a = 0.0
	_announce_tw = create_tween()
	_announce_tw.tween_property(announce_label, "modulate:a", 1.0, 0.5)
	_announce_tw.tween_interval(2.2)
	_announce_tw.tween_property(announce_label, "modulate:a", 0.0, 1.0)

func _roman(n: int) -> String:
	var vals := [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1]
	var syms := ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"]
	var out := ""
	var x := n
	for i in vals.size():
		while x >= vals[i]:
			out += syms[i]
			x -= vals[i]
	return out

func _process(_delta: float) -> void:
	var t := RunState.time
	timer_label.text = "%02d:%02d" % [int(t) / 60, int(t) % 60]
	bell_label.text = "Bell %s — %s" % [_roman(RunState.bell + 1), Data.BELLS[RunState.bell]["name"]]
	kills_label.text = "%d souls freed" % RunState.kills
	var danger := 1.0 - clampf(RunState.hp / maxf(1.0, RunState.maxhp) / 0.35, 0.0, 1.0)
	_danger.modulate.a = danger * (0.75 + 0.25 * sin(Time.get_ticks_msec() * 0.006))
	if run and run.warden and run.warden.alive:
		boss_label.visible = true
		boss_bar.visible = true
		boss_bar.max_value = run.warden.max_hp
		boss_bar.value = run.warden.hp
	else:
		boss_label.visible = false
		boss_bar.visible = false
	queue_redraw()

func set_arrow_target(world_pos: Vector2) -> void:
	_arrow_target = world_pos

func _draw() -> void:
	# Thread of the Rosary: a gold chevron pointing at the nearest unclaimed vestige
	if _arrow_target == Vector2.INF or run == null:
		return
	var cam: Camera2D = run.camera
	var center := get_viewport_rect().size / 2.0
	var to := _arrow_target - cam.get_screen_center_position()
	if to.length() < 520.0:
		return
	var dir := to.normalized()
	var at := center + dir * 240.0
	var a := dir.angle()
	var pulse := 0.65 + 0.3 * sin(Time.get_ticks_msec() * 0.005)
	var col := Color(1.35, 1.15, 0.6, pulse)
	var p1 := at + Vector2.from_angle(a) * 22.0
	var p2 := at + Vector2.from_angle(a + 2.6) * 16.0
	var p3 := at + Vector2.from_angle(a - 2.6) * 16.0
	draw_colored_polygon(PackedVector2Array([p1, p2, p3]), col)
	draw_arc(at - dir * 6.0, 30.0, a - 0.7, a + 0.7, 16, col * Color(1, 1, 1, 0.5), 2.0)
