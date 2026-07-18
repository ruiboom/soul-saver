extends Node
## Pooled SFX + two-layer dynamic music (drone always, chant swells with danger).

const STREAMS := {
	&"bell_toll": "res://assets/audio/bell_toll.wav",
	&"bell_small": "res://assets/audio/bell_small.wav",
	&"levelup": "res://assets/audio/levelup.wav",
	&"pickup": "res://assets/audio/pickup.wav",
	&"ui_select": "res://assets/audio/ui_select.wav",
	&"hurt": "res://assets/audio/hurt.wav",
	&"death_puff": "res://assets/audio/death_puff.wav",
	&"whoosh": "res://assets/audio/whoosh.wav",
	&"holy_impact": "res://assets/audio/holy_impact.wav",
	&"shockwave": "res://assets/audio/shockwave.wav",
	&"roar": "res://assets/audio/roar.wav",
	&"vestige": "res://assets/audio/vestige.wav",
	&"gate_open": "res://assets/audio/gate_open.wav",
	&"fanfare": "res://assets/audio/fanfare.wav",
	&"spit": "res://assets/audio/spit.wav",
}

const POOL_SIZE := 24
var _pool: Array[AudioStreamPlayer] = []
var _pool_i := 0
var _streams: Dictionary = {}
var _last_played: Dictionary = {}   # throttle spammy sounds

var _drone: AudioStreamPlayer
var _chant: AudioStreamPlayer
var _intensity := 0.0
var _target_intensity := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for key in STREAMS.keys():
		_streams[key] = load(STREAMS[key])
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = &"Master"
		add_child(p)
		_pool.append(p)
	_drone = AudioStreamPlayer.new()
	_drone.stream = _make_loop(load("res://assets/audio/music_drone.wav"))
	add_child(_drone)
	_chant = AudioStreamPlayer.new()
	_chant.stream = _make_loop(load("res://assets/audio/music_chant.wav"))
	add_child(_chant)

func _make_loop(s: AudioStreamWAV) -> AudioStreamWAV:
	var dup: AudioStreamWAV = s.duplicate()
	dup.loop_mode = AudioStreamWAV.LOOP_FORWARD
	dup.loop_begin = 0
	dup.loop_end = dup.data.size() / 2   # 16-bit mono frames
	return dup

func music_start() -> void:
	if not _drone.playing:
		_drone.volume_db = linear_to_db(0.8 * MetaSave.music_volume)
		_drone.play()
	if not _chant.playing:
		_chant.volume_db = -60.0
		_chant.play()

func music_stop() -> void:
	_drone.stop()
	_chant.stop()

func set_intensity(v: float) -> void:
	_target_intensity = clampf(v, 0.0, 1.0)

func _process(delta: float) -> void:
	_intensity = lerpf(_intensity, _target_intensity, delta * 0.5)
	if _chant.playing:
		var vol := 0.75 * _intensity * MetaSave.music_volume
		_chant.volume_db = linear_to_db(maxf(0.001, vol))
	if _drone.playing:
		_drone.volume_db = linear_to_db(maxf(0.001, (0.7 + 0.2 * _intensity) * MetaSave.music_volume))

func play(id: StringName, vol_db: float = 0.0, pitch_var: float = 0.06, throttle_ms: int = 40) -> void:
	var now := Time.get_ticks_msec()
	if _last_played.has(id) and now - int(_last_played[id]) < throttle_ms:
		return
	_last_played[id] = now
	var p := _pool[_pool_i]
	_pool_i = (_pool_i + 1) % POOL_SIZE
	p.stream = _streams[id]
	p.volume_db = vol_db + linear_to_db(maxf(0.001, MetaSave.sfx_volume))
	p.pitch_scale = 1.0 + randf_range(-pitch_var, pitch_var)
	p.play()

func bell() -> void:
	play(&"bell_toll", -2.0, 0.0)
