extends Node
## Estado de la partida MINDPLAY (autoload "GameSession").
## Su lifetime cruza los cambios de escena (Quiz -> Results), por eso es autoload.
## No retiene nodos: solo almacena datos planos y el banco de preguntas.
##
## Flujo rev2: CategorySelection deja la categoría en staging (sin iniciar nada)
## y QuizSetup inicia la partida con start_new_game(category, audience, difficulty).
## Sin señales públicas: nadie las usa (verificado en T4), todo es llamada directa.

const POINTS_PER_CORRECT: int = 100
const STREAK_MULTIPLIERS: Array[float] = [1.0, 1.5, 2.0, 2.5]
const QUESTIONS_PATH: String = "res://data/questions.json"

var _bank: QuestionBank = null
var _current_questions: Array[Dictionary] = []
var _staged_category: String = ""

var category: String = ""
var audience: String = ""
var difficulty: String = ""
var score: int = 0
var streak: int = 0
var max_streak: int = 0
var total_questions: int = 0
var answered: int = 0
var correct_answers: int = 0
var answers_log: Array[Dictionary] = []


func _ready() -> void:
	_bank = QuestionBank.load_from_file(QUESTIONS_PATH)
	if _bank == null or not _bank.is_valid():
		push_error("GameSession: no se pudo cargar el banco '%s'. Revisa la consola." % QUESTIONS_PATH)


## Guarda la categoría elegida SIN iniciar partida. La partida arranca recién
## en start_new_game() cuando ya están categoría + público + dificultad.
func stage_category(p_category: String) -> void:
	_staged_category = p_category


func get_staged_category() -> String:
	return _staged_category


func start_new_game(p_category: String, p_audience: String, p_difficulty: String) -> bool:
	if _bank == null or not _bank.is_valid():
		push_error("GameSession: banco no disponible, no se puede iniciar partida.")
		return false
	var pool := _bank.get_questions_filtered(p_category, p_audience, p_difficulty)
	if pool.is_empty():
		push_error("GameSession: combinación sin preguntas ('%s' | '%s' | '%s'), partida no iniciada." % [p_category, p_audience, p_difficulty])
		return false
	category = p_category
	audience = p_audience
	difficulty = p_difficulty
	score = 0
	streak = 0
	max_streak = 0
	answered = 0
	correct_answers = 0
	answers_log.clear()
	_current_questions = pool
	total_questions = _current_questions.size()
	_staged_category = ""
	return true


func get_categories() -> Array[String]:
	if _bank == null:
		return []
	return _bank.get_categories()


## Devuelve las preguntas de la partida actual (copias barajadas al iniciar).
func get_quiz_questions() -> Array[Dictionary]:
	return _current_questions.duplicate(true)


func get_combo_string() -> String:
	return "%s · %s · %s" % [category, audience, difficulty]


## Registra una respuesta y devuelve los puntos ganados (0 si es incorrecta).
## p_question / p_selected son opcionales para no romper al Quiz actual (T6 los pasará):
## si no vienen, la pregunta se deduce del pool en orden y selected queda en -1.
func submit_answer(correct: bool, p_question: Dictionary = {}, p_selected: int = -1) -> int:
	var snapshot := p_question.duplicate(true)
	if snapshot.is_empty() and answered < _current_questions.size():
		snapshot = _current_questions[answered].duplicate(true)
	var points := 0
	if correct:
		streak += 1
		max_streak = maxi(max_streak, streak)
		points = POINTS_PER_CORRECT * multiplier()
		score += points
		correct_answers += 1
	else:
		streak = 0
	answered += 1
	answers_log.append({
		"question": str(snapshot.get("question", "")),
		"selected_index": p_selected,
		"correct_index": int(snapshot.get("correct_index", -1)),
		"correct": correct,
		"points": points,
		"multiplier": multiplier(),
		"category": category,
		"audience": audience,
		"difficulty": difficulty,
	})
	return points


func multiplier() -> float:
	if streak <= 0:
		return 1.0
	var index := clampi(streak - 1, 0, STREAK_MULTIPLIERS.size() - 1)
	return STREAK_MULTIPLIERS[index]


func get_current_multiplier_string() -> String:
	return "x%.1f" % multiplier()


## Fin de partida: sin persistencia en v1 (hook futuro).
func finish() -> void:
	pass


func get_results() -> Dictionary:
	var answered_den := answered if answered > 0 else 1
	var precision := float(correct_answers) / float(answered_den) * 100.0
	return {
		"category": category,
		"audience": audience,
		"difficulty": difficulty,
		"score": score,
		"answered": answered,
		"total": total_questions,
		"correct": correct_answers,
		"incorrect": answered - correct_answers,
		"max_streak": max_streak,
		"accuracy": precision,
	}
