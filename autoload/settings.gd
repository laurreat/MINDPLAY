extends Node
## Autoload "Settings": preferencias (música/sfx), persistencia simple en user://
## y audio procedural (loop ambiental + click) sin assets externos.

const SAVE_PATH := "user://mindplay_settings.cfg"
const SAMPLE_RATE := 22050

var music_on := true
var sfx_on := true

var _music: AudioStreamPlayer
var _click: AudioStreamWAV


func _ready() -> void:
	_load_prefs()
	_music = AudioStreamPlayer.new()
	_music.stream = _make_music_loop()
	_music.volume_db = -12.0
	add_child(_music)
	_click = _make_click()
	if music_on:
		_music.play()
	var router := get_node_or_null("/root/SceneRouter")
	if router != null:
		router.scene_changed.connect(_on_scene_changed)


func is_music_on() -> bool:
	return music_on


func is_sfx_on() -> bool:
	return sfx_on


func set_music_on(value: bool) -> void:
	music_on = value
	if music_on:
		_music.play()
	else:
		_music.stop()
	_save_prefs()
	play_click()


func set_sfx_on(value: bool) -> void:
	sfx_on = value
	_save_prefs()
	play_click()


func play_click() -> void:
	if not sfx_on or _click == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = _click
	p.volume_db = -8.0
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()


func _on_scene_changed(_route: StringName) -> void:
	play_click()


func _load_prefs() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		music_on = bool(cfg.get_value("settings", "music", true))
		sfx_on = bool(cfg.get_value("settings", "sfx", true))


func _save_prefs() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("settings", "music", music_on)
	cfg.set_value("settings", "sfx", sfx_on)
	cfg.save(SAVE_PATH)


## Pad ambiental de 16s (4 acordes de 4s) con envolvente a cero en los bordes,
## así el loop es continuo sin clicks. Frecuencias reales, volumen bajo.
func _make_music_loop() -> AudioStreamWAV:
	var chord_len := 4.0
	var chords: Array = [
		[110.0, 130.81, 164.81],
		[87.31, 110.0, 130.81],
		[98.0, 130.81, 164.81],
		[98.0, 123.47, 146.83],
	]
	var total := chord_len * float(chords.size())
	var count := int(SAMPLE_RATE * total)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var ci := int(t / chord_len) % chords.size()
		var lt := t - float(ci) * chord_len
		var env := _pad_env(lt / chord_len)
		var s := 0.0
		for f in chords[ci]:
			s += sin(TAU * float(f) * t)
		s = s * env * 0.12
		data.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = count
	return stream


func _pad_env(x: float) -> float:
	if x < 0.35:
		var u := x / 0.35
		return u * u * (3.0 - 2.0 * u)
	if x > 0.65:
		var u := (1.0 - x) / 0.35
		return u * u * (3.0 - 2.0 * u)
	return 1.0


## Blip corto para feedback de UI.
func _make_click() -> AudioStreamWAV:
	var dur := 0.09
	var count := int(SAMPLE_RATE * dur)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in count:
		var t := float(i) / float(SAMPLE_RATE)
		var s := sin(TAU * 740.0 * t) * exp(-t * 45.0) * 0.5
		data.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.data = data
	return stream
