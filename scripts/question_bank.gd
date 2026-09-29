class_name QuestionBank
extends RefCounted
## Carga y valida data/questions.json (schema rev2: category + audience + difficulty,
## feedback_correct / feedback_incorrect en vez de explanation).
## Inmutable por diseño: nunca devuelve referencias a los datos internos,
## siempre copias profundas barajadas (ver get_questions_filtered).

const MIN_ANSWERS := 4
const EXPECTED_PER_COMBO := 3

const REQUIRED_FIELDS: Array[StringName] = [
	&"id",
	&"category",
	&"audience",
	&"difficulty",
	&"question",
	&"answers",
	&"correct_index",
	&"feedback_correct",
	&"feedback_incorrect",
]

const CATEGORIES: Array[String] = ["Diseño", "Tecnología", "Videojuegos", "Cultura Digital"]
const AUDIENCES: Array[String] = ["Jóvenes", "Adultos"]
const DIFFICULTIES: Array[String] = ["Fácil", "Normal", "Difícil"]

var _questions: Array[Dictionary] = []
var _categories: Array[String] = []
var _valid := false


static func load_from_file(path: String) -> QuestionBank:
	var bank := QuestionBank.new()
	bank._load(path)
	return bank


func _load(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("QuestionBank: no se pudo abrir '%s'." % path)
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed == null or not parsed is Array:
		push_error("QuestionBank: '%s' no contiene un array JSON válido." % path)
		return
	var errors: Array[String] = []
	var valid_questions: Array[Dictionary] = []
	for raw in parsed:
		if not raw is Dictionary:
			errors.append("elemento no es un objeto JSON, se omite.")
			continue
		var question := raw as Dictionary
		var question_errors := _validate(question)
		if question_errors.is_empty():
			valid_questions.append(question.duplicate(true))
		else:
			errors.append_array(question_errors)
	# La completitud solo se revisa si todas las filas son válidas,
	# para no reportar 24 combinaciones rotas por culpa de filas inválidas.
	if errors.is_empty():
		errors.append_array(_check_completeness(valid_questions))
	if errors.is_empty():
		_questions = valid_questions
		_categories = _collect_categories()
		_valid = true
	else:
		for error in errors:
			push_error("QuestionBank: " + error)


## Valida una pregunta y devuelve la lista de problemas (vacía = válida).
## No aborta en el primer error: acumula todos para reportarlos juntos.
func _validate(question: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var qid := str(question.get("id", "?"))
	for field in REQUIRED_FIELDS:
		if not question.has(field):
			errors.append("falta el campo '%s' en '%s'." % [field, qid])
	if not errors.is_empty():
		return errors
	for field in [&"id", &"question"]:
		if not question[field] is String or (question[field] as String).is_empty():
			errors.append("'%s' debe ser texto no vacío en '%s'." % [field, qid])
	if not CATEGORIES.has(str(question["category"])):
		errors.append("category '%s' inválida en '%s'. Válidas: %s." % [str(question["category"]), qid, str(CATEGORIES)])
	if not AUDIENCES.has(str(question["audience"])):
		errors.append("audience '%s' inválido en '%s'. Válidos: %s." % [str(question["audience"]), qid, str(AUDIENCES)])
	if not DIFFICULTIES.has(str(question["difficulty"])):
		errors.append("difficulty '%s' inválido en '%s'. Válidos: %s." % [str(question["difficulty"]), qid, str(DIFFICULTIES)])
	var answers: Variant = question.get("answers")
	if not answers is Array or (answers as Array).size() != MIN_ANSWERS:
		errors.append("'answers' debe tener %d opciones en '%s'." % [MIN_ANSWERS, qid])
	else:
		for answer in answers:
			if not answer is String or (answer as String).is_empty():
				errors.append("cada respuesta debe ser texto no vacío en '%s'." % qid)
				break
	var ci_value: Variant = question.get("correct_index")
	if not (ci_value is int or ci_value is float):
		errors.append("'correct_index' debe ser un número entero en '%s'." % qid)
	else:
		var ci := int(ci_value)
		if float(ci_value) != float(ci):
			errors.append("'correct_index' no es un entero válido en '%s'." % qid)
		elif ci < 0 or ci >= MIN_ANSWERS:
			errors.append("'correct_index' fuera de rango en '%s'." % qid)
	for field in [&"feedback_correct", &"feedback_incorrect"]:
		if not question[field] is String or (question[field] as String).is_empty():
			errors.append("'%s' es obligatorio (feedback educativo) en '%s'." % [field, qid])
	return errors


## Verifica que cada combinación category × audience × difficulty
## tenga exactamente EXPECTED_PER_COMBO preguntas.
func _check_completeness(questions: Array[Dictionary]) -> Array[String]:
	var errors: Array[String] = []
	var counts: Dictionary = {}
	for question in questions:
		var key := "%s | %s | %s" % [str(question["category"]), str(question["audience"]), str(question["difficulty"])]
		counts[key] = int(counts.get(key, 0)) + 1
	for category in CATEGORIES:
		for audience in AUDIENCES:
			for difficulty in DIFFICULTIES:
				var combo := "%s | %s | %s" % [category, audience, difficulty]
				var found := int(counts.get(combo, 0))
				if found != EXPECTED_PER_COMBO:
					errors.append("combinación '%s' tiene %d preguntas, se esperaban %d." % [combo, found, EXPECTED_PER_COMBO])
	return errors


func _collect_categories() -> Array[String]:
	var seen: Dictionary = {}
	for question in _questions:
		seen[str(question["category"])] = true
	var categories: Array[String] = []
	for key in seen.keys():
		categories.append(str(key))
	categories.sort()
	return categories


func is_valid() -> bool:
	return _valid


func get_categories() -> Array[String]:
	return _categories.duplicate()


## Devuelve copias profundas de las preguntas de una combinación, barajadas.
## El banco interno nunca se modifica: el shuffle corre sobre las copias.
func get_questions_filtered(p_category: String, p_audience: String, p_difficulty: String) -> Array[Dictionary]:
	var pool: Array[Dictionary] = []
	for question in _questions:
		if str(question["category"]) == p_category and str(question["audience"]) == p_audience and str(question["difficulty"]) == p_difficulty:
			pool.append(question.duplicate(true))
	pool.shuffle()
	return pool
