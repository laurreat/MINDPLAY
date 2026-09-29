extends Control
## Configura la partida: muestra la categoría en staging y deja elegir
## público + dificultad (grupos exclusivos). La partida arranca recién
## con "¡Comenzar!" vía GameSession.start_new_game().

@onready var back_btn: Button = %BackBtn
@onready var category_label: Label = %CategoryLabel
@onready var aud_jovenes: Button = %AudJovenes
@onready var dif_facil: Button = %DifFacil
@onready var error_label: Label = %ErrorLabel
@onready var start_btn: Button = %StartBtn


func _ready() -> void:
	var cat := GameSession.get_staged_category()
	if cat.is_empty():
		SceneRouter.navigate(&"category_selection")
		return
	category_label.text = "Categoría: %s" % cat
	# Defaults explícitos en código (el tscn solo los sugiere): Jóvenes + Fácil.
	aud_jovenes.button_pressed = true
	dif_facil.button_pressed = true
	back_btn.pressed.connect(_on_back_pressed)
	start_btn.pressed.connect(_on_start_pressed)
	_focus_after_frame(aud_jovenes)


func _on_start_pressed() -> void:
	var cat := GameSession.get_staged_category()
	if cat.is_empty():
		_show_error("Volvé y elegí una categoría.")
		return
	var audience := _group_text(aud_jovenes.button_group, "Jóvenes")
	var difficulty := _group_text(dif_facil.button_group, "Fácil")
	if GameSession.start_new_game(cat, audience, difficulty):
		SceneRouter.navigate(&"quiz")
	else:
		_show_error("No hay preguntas para esta combinación.")


func _on_back_pressed() -> void:
	SceneRouter.navigate(&"category_selection")


func _group_text(group: ButtonGroup, fallback: String) -> String:
	if group == null:
		return fallback
	var pressed := group.get_pressed_button()
	if pressed == null:
		return fallback
	return pressed.text


func _show_error(message: String) -> void:
	error_label.text = message
	error_label.visible = true


func _focus_after_frame(control: Control) -> void:
	await get_tree().process_frame
	if control != null and is_instance_valid(control) and control.is_visible_in_tree():
		control.grab_focus()
