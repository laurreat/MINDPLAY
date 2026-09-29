extends Node
## Única autoridad para cambiar de escena en MINDPLAY (autoload "SceneRouter").
## Mantiene el mapa central de rutas y protege contra transiciones dobles.

const ROUTES: Dictionary = {
	&"main_menu": "res://scenes/main/MainMenu.tscn",
	&"category_selection": "res://scenes/quiz/CategorySelection.tscn",
	&"quiz": "res://scenes/quiz/Quiz.tscn",
	&"quiz_setup": "res://scenes/quiz/QuizSetup.tscn",
	&"results": "res://scenes/quiz/Results.tscn",
	&"options": "res://scenes/options/Options.tscn",
	&"instructions": "res://scenes/quiz/Instructions.tscn",
}

signal scene_changed(route: StringName)

var _switching := false


func navigate(route: StringName) -> void:
	if not ROUTES.has(route):
		push_error("SceneRouter: ruta desconocida '%s'. Válidas: %s" % [route, str(ROUTES.keys())])
		return
	if _switching:
		push_warning("SceneRouter: transición en curso, se ignora '%s'." % route)
		return
	_switching = true
	var err := get_tree().change_scene_to_file(str(ROUTES[route]))
	if err != OK:
		push_error("SceneRouter: falló al cargar '%s' (error %d)." % [str(ROUTES[route]), err])
		_switching = false
		return
	scene_changed.emit(route)
	# change_scene_to_file es diferido: se libera el bloqueo tras el siguiente frame.
	await get_tree().process_frame
	_switching = false


func quit_game() -> void:
	get_tree().quit()