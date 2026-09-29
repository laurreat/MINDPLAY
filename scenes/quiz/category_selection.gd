extends Control
## Muestra las categorías del banco como cards. Al elegir una categoría
## solo la deja en staging y navega a QuizSetup (la partida NO arranca acá).

const CARD_MIN_SIZE := Vector2(170, 190)
const CARD_RADIUS := 22
# Ancho mínimo de la lista para 4 cards en fila: 4×170 + 3×20.
const WIDE_THRESHOLD := 740.0
# Mapa VISUAL (no es fuente de datos): la categoría real siempre viene del banco.
const CARD_BG := {
	"Diseño": Color(0.82, 0.78, 1.0),
	"Tecnología": Color(0.75, 0.88, 1.0),
	"Videojuegos": Color(1.0, 0.9, 0.65),
	"Cultura Digital": Color(0.7, 0.95, 0.8),
}
const CARD_BG_FALLBACK := Color(0.2, 0.21, 0.38)
const CARD_FONT := Color(0.13, 0.14, 0.3)
const CARD_FONT_FALLBACK := Color(0.92, 0.93, 0.98)

@onready var back_btn: Button = %BackBtn
@onready var categories_list: HFlowContainer = %CategoriesList

var _first_button: Button = null
var _wide_layout := false


func _ready() -> void:
	back_btn.pressed.connect(_on_back_pressed)
	_populate_categories()
	categories_list.resized.connect(_on_list_resized)
	_apply_card_layout.call_deferred()


## En angosto, las cards crecen a media fila y el flow las deja en 2x2.
## Solo se reaplica al cruzar el umbral (sin bucles de resized).
func _on_list_resized() -> void:
	_apply_card_layout()


func _apply_card_layout() -> void:
	var w := categories_list.size.x
	if w <= 0.0:
		return
	var wide := w >= WIDE_THRESHOLD
	if wide == _wide_layout and _first_button != null:
		return
	_wide_layout = wide
	for child in categories_list.get_children():
		if child is Button:
			var card := child as Button
			var cs := card.custom_minimum_size
			if wide:
				cs.x = CARD_MIN_SIZE.x
			else:
				cs.x = maxf((w - 20.0) / 2.0, 120.0)
			card.custom_minimum_size = cs


func _populate_categories() -> void:
	for child in categories_list.get_children():
		categories_list.remove_child(child)
		child.queue_free()

	var categories: Array[String] = GameSession.get_categories()
	if categories.is_empty():
		var notice := Label.new()
		notice.text = "No hay categorías disponibles en data/questions.json."
		notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		categories_list.add_child(notice)
		return

	_first_button = null
	for category in categories:
		var btn := _make_card(category)
		categories_list.add_child(btn)
		if _first_button == null:
			_first_button = btn

	if _first_button != null:
		_focus_after_frame(_first_button)


func _make_card(category: String) -> Button:
	var bg: Color = CARD_BG.get(category, CARD_BG_FALLBACK)
	var font_color: Color = CARD_FONT if CARD_BG.has(category) else CARD_FONT_FALLBACK
	var btn := Button.new()
	btn.text = category
	btn.custom_minimum_size = CARD_MIN_SIZE
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.clip_text = true
	btn.add_theme_font_size_override("font_size", 22)
	# El Button usa un color por estado: fijarlos todos o el texto
	# se vuelve ilegible al hover/press/focus (blanco sobre pastel).
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_disabled_color", "font_focus_color"]:
		btn.add_theme_color_override(state, font_color)
	btn.add_theme_stylebox_override("normal", _card_style(bg))
	btn.add_theme_stylebox_override("hover", _card_style(bg.lightened(0.08)))
	btn.add_theme_stylebox_override("pressed", _card_style(bg.darkened(0.1)))
	btn.add_theme_stylebox_override("focus", _card_focus_style(bg))
	btn.pressed.connect(_on_category_pressed.bind(category))
	return btn


func _card_style(bg: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.set_corner_radius_all(CARD_RADIUS)
	sb.content_margin_left = 12.0
	sb.content_margin_top = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_bottom = 12.0
	return sb


func _card_focus_style(bg: Color) -> StyleBoxFlat:
	var sb := _card_style(bg.lightened(0.08))
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.border_color = Color(1, 1, 1, 0.9)
	return sb


func _on_category_pressed(category: String) -> void:
	GameSession.stage_category(category)
	SceneRouter.navigate(&"quiz_setup")


func _on_back_pressed() -> void:
	SceneRouter.navigate(&"main_menu")


func _focus_after_frame(control: Control) -> void:
	await get_tree().process_frame
	if control != null and is_instance_valid(control) and control.is_visible_in_tree():
		control.grab_focus()
