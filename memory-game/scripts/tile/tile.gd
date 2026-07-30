class_name Tile
extends Node2D

enum State { HIDDEN, REVEALED, GREYED, EMPTY }

const HIDDEN_COLOR := Color(0.23, 0.23, 0.23)
const MISMATCH_FADE_DURATION := 2.5
const PAIR_COLORS := [
	Color(0.9, 0.3, 0.3),   # pair 0 — Attack
	Color(0.3, 0.8, 0.4),   # pair 1 — Attack
	Color(0.3, 0.6, 0.95),  # pair 2 — Attack
	Color(0.95, 0.85, 0.2), # pair 3 — Heal
	Color(0.8, 0.4, 0.9),   # pair 4 — Heal
	Color(0.95, 0.5, 0.2),  # pair 5 — Slow
	Color(0.2, 0.85, 0.85), # pair 6 — Speed
	Color(0.95, 0.4, 0.7),  # pair 7 — Upgrade
]

@onready var _face: ColorRect = $Face
@onready var _cover: ColorRect = $Cover
@onready var _selection_outline: Line2D = $SelectionOutline

var pair_id: int = -1
var _state := State.HIDDEN


func setup(id: int) -> void:
	pair_id = id
	_reset_visuals()


func reveal() -> void:
	if _state == State.EMPTY:
		return
	_state = State.REVEALED
	_face.visible = true
	_face.modulate = Color.WHITE
	_face.color = PAIR_COLORS[pair_id % PAIR_COLORS.size()]
	_cover.modulate.a = 0.0


func conceal() -> void:
	if _state == State.EMPTY:
		return
	_state = State.HIDDEN
	_reset_visuals()


func make_empty() -> void:
	_state = State.EMPTY
	_face.visible = false
	_cover.modulate.a = 0.0
	_selection_outline.visible = false


func grey_and_fade() -> void:
	if _state != State.REVEALED:
		return
	_state = State.GREYED
	_face.modulate = Color(0.55, 0.55, 0.55, 1.0)
	_cover.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(_cover, "modulate:a", 1.0, MISMATCH_FADE_DURATION)
	tween.tween_callback(conceal)


func is_hidden() -> bool:
	return _state == State.HIDDEN


func set_selected_outline(show_outline: bool) -> void:
	_selection_outline.visible = show_outline


func _reset_visuals() -> void:
	_face.visible = true
	_face.modulate = Color.WHITE
	_face.color = HIDDEN_COLOR
	_cover.modulate.a = 0.0
	_selection_outline.visible = false
