class_name Tile
extends Node2D

enum State { HIDDEN, REVEALED, GREYED, EMPTY }

const HIDDEN_COLOR := Color(0.23, 0.23, 0.23)
const REVEAL_HOLD_DURATION := 0.35  # tune: time to actually see the second tile
const MISMATCH_FADE_DURATION := 1.65
const COLOR_MATCH_FADE_DURATION := 3.15
const TILE_SIZE := 64.0
const MATCH_POP_DURATION := 0.18
const AFFILIATION_COLORS := [
	Color.BLUE,
	Color.YELLOW,
	Color.PURPLE,
	Color.ORANGE
]

const EFFECT_ICONS := {
	0: preload("res://assets/icons/attack.svg"),
	1: preload("res://assets/icons/heal.svg"),
	2: preload("res://assets/icons/slow.svg"),
	3: preload("res://assets/icons/speed.svg"),
	4: preload("res://assets/icons/upgrade.svg"),
}

@onready var _face: ColorRect = $Face
@onready var _cover: ColorRect = $Cover
@onready var _icon: TextureRect = $Icon
@onready var _selection_outline: Line2D = $SelectionOutline

var pair_id: int = -1
var pair_color_id: int = -1
var pair_effect_id: int = -1
var _state := State.HIDDEN
var _juice_tween: Tween
## Grid position from Board — juice tweens temporarily move `position`, then restore this.
var _grid_position := Vector2.ZERO


func setup(id: int, color_id: int, effect_id: int) -> void:
	pair_id = id
	pair_color_id = color_id
	pair_effect_id = effect_id
	_grid_position = position
	_reset_visuals()


func reveal() -> void:
	if _state == State.EMPTY:
		return
	_state = State.REVEALED
	_face.visible = true
	_face.modulate = Color.WHITE
	_face.color = AFFILIATION_COLORS[pair_color_id % AFFILIATION_COLORS.size()]
	_icon.texture = EFFECT_ICONS[pair_effect_id % EFFECT_ICONS.size()]
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


func grey_and_fade(duration: float = MISMATCH_FADE_DURATION) -> void:
	if _state != State.REVEALED:
		return
	_kill_juice_tween()
	_restore_transform()
	_state = State.GREYED
	# Do NOT grey the face yet — hold first
	_cover.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_interval(REVEAL_HOLD_DURATION)
	tween.tween_callback(func() -> void:
		_face.modulate = Color(0.55, 0.55, 0.55, 1.0)
	)
	tween.tween_property(_cover, "modulate:a", 1.0, duration)
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
