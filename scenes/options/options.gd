extends Control
## Opciones: toggles de música/sonido (vía Settings, con persistencia),
## idioma visual (Español, único por ahora) y acceso a Cómo jugar.

@onready var back_btn: Button = %BackBtn
@onready var music_toggle: Button = %MusicToggle
@onready var sfx_toggle: Button = %SfxToggle
@onready var lang_option: OptionButton = %LangOption
@onready var howto_btn: Button = %HowToBtn


func _ready() -> void:
	lang_option.add_item("Español")
	lang_option.selected = 0
	music_toggle.button_pressed = Settings.is_music_on()
	sfx_toggle.button_pressed = Settings.is_sfx_on()
	_sync_toggle_text(music_toggle)
	_sync_toggle_text(sfx_toggle)
	music_toggle.toggled.connect(_on_music_toggled)
	sfx_toggle.toggled.connect(_on_sfx_toggled)
	lang_option.item_selected.connect(_on_lang_selected)
	howto_btn.pressed.connect(_on_howto_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	_focus_after_frame(music_toggle)


func _on_music_toggled(value: bool) -> void:
	Settings.set_music_on(value)
	_sync_toggle_text(music_toggle)


func _on_sfx_toggled(value: bool) -> void:
	Settings.set_sfx_on(value)
	_sync_toggle_text(sfx_toggle)


func _on_lang_selected(_index: int) -> void:
	Settings.play_click()


func _on_howto_pressed() -> void:
	SceneRouter.navigate(&"instructions")


func _on_back_pressed() -> void:
	SceneRouter.navigate(&"main_menu")


func _sync_toggle_text(btn: Button) -> void:
	btn.text = "ON" if btn.button_pressed else "OFF"


func _focus_after_frame(control: Control) -> void:
	await get_tree().process_frame
	if control != null and is_instance_valid(control) and control.is_visible_in_tree():
		control.grab_focus()
