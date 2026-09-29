extends Control
## Pantalla principal: punto de entrada del juego.

@onready var start_btn: Button = %StartBtn
@onready var options_btn: Button = %OptionsBtn
@onready var quit_btn: Button = %QuitBtn


func _ready() -> void:
	start_btn.pressed.connect(_on_start_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	_focus_after_frame(start_btn)


func _on_start_pressed() -> void:
	SceneRouter.navigate(&"category_selection")


func _on_options_pressed() -> void:
	SceneRouter.navigate(&"options")


func _on_quit_pressed() -> void:
	SceneRouter.quit_game()


## El foco se asigna tras el primer frame, cuando la pantalla ya es visible.
func _focus_after_frame(control: Control) -> void:
	await get_tree().process_frame
	if control != null and is_instance_valid(control) and control.is_visible_in_tree():
		control.grab_focus()