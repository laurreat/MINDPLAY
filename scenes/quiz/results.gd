extends Control
## Pantalla de resultados: muestra el resultado de la partida actual
## usando únicamente GameSession.get_results(). Sin persistencia ni récords.

@onready var score_value: Label = %ScoreValue
@onready var correct_label: Label = %CorrectLabel
@onready var wrong_label: Label = %WrongLabel
@onready var combo_label: Label = %ComboLabel
@onready var play_again_btn: Button = %PlayAgainBtn
@onready var menu_btn: Button = %MenuBtn


func _ready() -> void:
	_display_results()
	play_again_btn.pressed.connect(_on_play_again_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	_focus_after_frame(play_again_btn)


func _display_results() -> void:
	var r := GameSession.get_results()
	score_value.text = str(int(r["score"]))
	correct_label.text = "✓ Correctas: %d / %d" % [int(r["correct"]), int(r["total"])]
	wrong_label.text = "✗ Incorrectas: %d / %d" % [int(r["incorrect"]), int(r["total"])]
	combo_label.text = "%s · %s · %s" % [str(r["category"]), str(r["audience"]), str(r["difficulty"])]


func _on_play_again_pressed() -> void:
	SceneRouter.navigate(&"category_selection")


func _on_menu_pressed() -> void:
	SceneRouter.navigate(&"main_menu")


func _focus_after_frame(control: Control) -> void:
	await get_tree().process_frame
	if control != null and is_instance_valid(control) and control.is_visible_in_tree():
		control.grab_focus()
