extends Node
## Scene flow + shared UI theme.

var last_result: Dictionary = {}
var theme: Theme
var font_display: FontFile
var font_body: FontFile

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_theme()

func _build_theme() -> void:
	font_display = load("res://assets/fonts/GrenzeGotisch.ttf")
	font_body = load("res://assets/fonts/Alegreya.ttf")
	theme = Theme.new()
	if font_body:
		theme.default_font = font_body
	theme.default_font_size = 26

func start_run() -> void:
	Rngs.reseed(randi())
	RunState.reset()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/run/run.tscn")

func goto_title() -> void:
	get_tree().paused = false
	AudioDirector.set_intensity(0.0)
	get_tree().change_scene_to_file("res://src/ui/title.tscn")

func end_run(result: Dictionary) -> void:
	last_result = result
	MetaSave.record_run(result)

# ---------------- shared UI construction helpers ----------------

func make_label(text: String, size: int, color: Color = Color.WHITE, display := false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override(&"font_size", size)
	l.add_theme_color_override(&"font_color", color)
	var f := font_display if display else font_body
	if f:
		l.add_theme_font_override(&"font", f)
	return l

func make_panel_style(border_color: Color = Data.GOLD, bg := Color(0.06, 0.05, 0.09, 0.92)) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border_color
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(6)
	sb.set_content_margin_all(18)
	return sb

func make_button(text: String, size: int = 30) -> Button:
	var b := Button.new()
	b.text = text
	if font_display:
		b.add_theme_font_override(&"font", font_display)
	b.add_theme_font_size_override(&"font_size", size)
	b.add_theme_color_override(&"font_color", Color(0.86, 0.8, 0.62))
	b.add_theme_color_override(&"font_hover_color", Data.HALO)
	b.add_theme_color_override(&"font_focus_color", Data.HALO)
	var normal := make_panel_style(Color(0.45, 0.36, 0.18), Color(0.09, 0.07, 0.12, 0.9))
	normal.set_content_margin_all(10)
	normal.content_margin_left = 26
	normal.content_margin_right = 26
	var hover := make_panel_style(Data.GOLD, Color(0.13, 0.1, 0.16, 0.95))
	hover.set_content_margin_all(10)
	hover.content_margin_left = 26
	hover.content_margin_right = 26
	b.add_theme_stylebox_override(&"normal", normal)
	b.add_theme_stylebox_override(&"hover", hover)
	b.add_theme_stylebox_override(&"focus", hover)
	b.add_theme_stylebox_override(&"pressed", hover)
	b.focus_mode = Control.FOCUS_ALL
	b.mouse_entered.connect(func() -> void: AudioDirector.play(&"ui_select", -14.0))
	return b
