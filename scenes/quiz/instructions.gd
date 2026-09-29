extends Control
## Cómo jugar: 4 pasos + comienzo. Se entra desde Opciones, se vuelve a Opciones.

@onready var back_btn: Button = %BackBtn
@onready var start_btn: Button = %StartBtn


func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	start_btn.pressed.connect(_on_start_pressed)
	_focus_after_frame(start_btn)


func _on_start_pressed() -> void:
	SceneRouter.navigate(&"category_selection")


func _on_back_pressed() -> void:
	SceneRouter.navigate(&"options")


func _focus_after_frame(control: Control) -> void:
	await get_tree().process_frame
	if control != null and is_instance_valid(control) and control.is_visible_in_tree():
		control.grab_focus()
