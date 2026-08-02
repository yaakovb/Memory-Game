class_name Tile
extends Node2D

enum State { HIDDEN, REVEALED, GREYED, EMPTY }

const HIDDEN_COLOR := Color(0.23, 0.23, 0.23)
const MISMATCH_FADE_DURATION := 2.5
const TILE_SIZE := 64.0
const MATCH_POP_DURATION := 0.18
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

const EFFECT_ICONS := {
	0: preload("res://assets/icons/attack.svg"),
	1: preload("res://assets/icons/attack.svg"),
	2: preload("res://assets/icons/attack.svg"),
	3: preload("res://assets/icons/heal.svg"),
	4: preload("res://assets/icons/heal.svg"),
	5: preload("res://assets/icons/slow.svg"),
	6: preload("res://assets/icons/speed.svg"),
	7: preload("res://assets/icons/upgrade.svg"),
}

@onready var _face: ColorRect = $Face
@onready var _cover: ColorRect = $Cover
@onready var _icon: TextureRect = $Icon
@onready var _selection_outline: Line2D = $SelectionOutline

var pair_id: int = -1
var _state := State.HIDDEN
var _juice_tween: Tween
## Grid position from Board — juice tweens temporarily move `position`, then restore this.
var _grid_position := Vector2.ZERO


func setup(id: int) -> void:
	pair_id = id
	_grid_position = position
	_reset_visuals()


func reveal() -> void:
	if _state == State.EMPTY:
		return
	_state = State.REVEALED
	_face.visible = true
	_face.modulate = Color.WHITE
	_face.color = PAIR_COLORS[pair_id % PAIR_COLORS.size()]
	_icon.texture = EFFECT_ICONS[pair_id]
	_icon.visible = true
	_cover.modulate.a = 0.0


func conceal() -> void:
	if _state == State.EMPTY:
		return
	_state = State.HIDDEN
	_reset_visuals()


func make_empty() -> void:
	_kill_juice_tween()
	_state = State.EMPTY
	_restore_transform()
	_face.visible = false
	_icon.visible = false
	_cover.modulate.a = 0.0
	_selection_outline.visible = false


## Scale-up + fade out. Board emits match effects immediately; this is visual only.
func play_match_pop() -> void:
	_kill_juice_tween()
	_state = State.EMPTY
	_selection_outline.visible = false
	_grid_position = position
	var half := Vector2(TILE_SIZE * 0.5, TILE_SIZE * 0.5)
	_juice_tween = create_tween()
	_juice_tween.set_parallel(true)
	_juice_tween.tween_method(_apply_centered_scale.bind(_grid_position, half), 1.0, 1.25, MATCH_POP_DURATION)
	_juice_tween.tween_property(self, "modulate:a", 0.0, MATCH_POP_DURATION)
	_juice_tween.chain().tween_callback(_finish_match_pop)


func grey_and_fade() -> void:
	if _state != State.REVEALED:
		return
	_kill_juice_tween()
	_restore_transform()
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
	_kill_juice_tween()
	_restore_transform()
	_face.visible = true
	_face.modulate = Color.WHITE
	_face.color = HIDDEN_COLOR
	_cover.modulate.a = 0.0
	_selection_outline.visible = false
	_icon.visible = false


## Node2D scales from top-left — nudge position so the pop looks centered.
func _apply_centered_scale(s: float, origin: Vector2, half: Vector2) -> void:
	scale = Vector2(s, s)
	position = origin + half * (1.0 - s)


func _finish_match_pop() -> void:
	_restore_transform()
	_face.visible = false
	_icon.visible = false
	_cover.modulate.a = 0.0
	_selection_outline.visible = false


func _restore_transform() -> void:
	scale = Vector2.ONE
	modulate = Color.WHITE
	position = _grid_position


func _kill_juice_tween() -> void:
	if _juice_tween != null and _juice_tween.is_valid():
		_juice_tween.kill()
	_juice_tween = null
	scale = Vector2.ONE
	modulate = Color.WHITE
	position = _grid_position
