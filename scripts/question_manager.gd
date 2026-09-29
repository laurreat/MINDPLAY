class_name QuestionManager
extends Node
## Turna las preguntas de una partida dentro de Quiz.tscn.
## Trabaja con copias profundas: nunca modifica los datos del banco original.

var _questions: Array[Dictionary] = []
var _index := -1


func setup(questions: Array[Dictionary]) -> void:
	_questions = questions.duplicate(true)
	_index = -1


func total() -> int:
	return _questions.size()


func has_next() -> bool:
	return _index + 1 < _questions.size()


func next() -> Dictionary:
	if not has_next():
		return {}
	_index += 1
	return _questions[_index].duplicate(true)


func current() -> Dictionary:
	if _index < 0 or _index >= _questions.size():
		return {}
	return _questions[_index].duplicate(true)


func current_index() -> int:
	return _index