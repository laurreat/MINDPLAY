extends Control
## Pantalla de juego: presenta la pregunta dominante en su tarjeta,
## evalúa con GameSession y muestra feedback breve (dual) antes de continuar.
## Ritmo: pregunta -> respuestas -> feedback -> Continuar (sin auto-avance).

const MARK_CORRECT := "✔ "
const MARK_WRONG := "✖ "
const CORRECT_COLOR := Color(0.35, 0.85, 0.45)
const WRONG_COLOR := Color(1.0, 0.55, 0.55)

@onready var question_manager: QuestionManager = %QuestionManager
@onready var round_label: Label = %RoundLabel
@onready var score_label: Label = %ScoreLabel
@onready var streak_label: Label = %StreakLabel
@onready var combo_label: Label = %ComboLabel
@onready var question_label: Label = %QuestionLabel
@onready var answers_container: VBoxContainer = %AnswersContainer
@onready var overlay: Control = %FeedbackOverlay
@onready var feedback_title: Label = %FeedbackTitle
@onready var feedback_text: Label = %FeedbackText
@onready var points_label: Label = %PointsLabel
@onready var next_btn: Button = %NextBtn

var _answer_buttons: Array[Button] = []
var _current_q: Dictionary = {}
var _locked := false


func _ready() -> void:
	question_manager.setup(GameSession.get_quiz_questions())
	next_btn.pressed.connect(_on_next_pressed)
	_build_answer_buttons()
	_update_hud()
	present_next()


func _build_answer_buttons() -> void:
	_answer_buttons.clear()
	for child in answers_container.get_children():
		if child is Button:
			_answer_buttons.append(child as Button)
	for index in _answer_buttons.size():
		_answer_buttons[index].pressed.connect(_on_answer_pressed.bind(index))


func present_next() -> void:
	if not question_manager.has_next():
		GameSession.finish()
		SceneRouter.navigate(&"results")
		return
	_current_q = question_manager.next()
	_locked = false
	overlay.visible = false
	question_label.text = str(_current_q["question"])
	for index in _answer_buttons.size():
		var btn := _answer_buttons[index]
		btn.text = str(_current_q["answers"][index])
		btn.disabled = false
		btn.modulate = Color.WHITE
	_update_hud()
	if not _answer_buttons.is_empty():
		_focus_after_frame(_answer_buttons[0])


func _on_answer_pressed(index: int) -> void:
	if _locked:
		return
	_locked = true
	var correct := index == int(_current_q["correct_index"])
	var points := GameSession.submit_answer(correct, _current_q, index)
	_update_hud()
	_highlight_answer(index, correct)
	_show_feedback(correct, points)


func _highlight_answer(selected_index: int, correct: bool) -> void:
	var correct_index := int(_current_q["correct_index"])
	for i in _answer_buttons.size():
		var btn := _answer_buttons[i]
		btn.disabled = true
		if i == correct_index:
			btn.text = MARK_CORRECT + btn.text
			btn.modulate = CORRECT_COLOR
		elif i == selected_index and not correct:
			btn.text = MARK_WRONG + btn.text
			btn.modulate = WRONG_COLOR


func _show_feedback(correct: bool, points: int) -> void:
	overlay.visible = true
	if correct:
		feedback_title.text = "¡Correcto!"
		feedback_title.modulate = CORRECT_COLOR
		feedback_text.text = str(_current_q.get("feedback_correct", ""))
	else:
		feedback_title.text = "Respuesta incorrecta"
		feedback_title.modulate = WRONG_COLOR
		feedback_text.text = str(_current_q.get("feedback_incorrect", ""))
	points_label.text = "+%d puntos" % points
	next_btn.text = "Continuar"
	_focus_after_frame(next_btn)


func _on_next_pressed() -> void:
	present_next()


func _update_hud() -> void:
	round_label.text = "%d / %d" % [question_manager.current_index() + 1, question_manager.total()]
	score_label.text = "%d pts" % GameSession.score
	streak_label.text = "Racha: %s" % GameSession.get_current_multiplier_string()
	combo_label.text = GameSession.get_combo_string()


func _focus_after_frame(control: Control) -> void:
	await get_tree().process_frame
	if control != null and is_instance_valid(control) and control.is_visible_in_tree():
		control.grab_focus()
