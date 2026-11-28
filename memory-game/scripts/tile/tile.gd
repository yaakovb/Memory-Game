class_name Tile
extends Node2D

enum State { HIDDEN, REVEALED, GREYED, EMPTY }

const REVEAL_HOLD_DURATION := 0.35  # tune: time to actually see the second tile
const MISMATCH_FADE_DURATION := 1.65
const COLOR_MATCH_FADE_DURATION := 3.15
const TILE_SIZE := 128.0
const MATCH_POP_DURATION := 0.18

const CARD_BACK := preload("res://assets/tiles/card-back.png")

## Key is Vector2i(effect_id, color_id).
## effect: 0 sword, 1 medicine, 2 slow, 3 haste, 4 hammer
## color:  0 blue, 1 yellow, 2 purple, 3 orange
const TILE_ART := {
	Vector2i(0, 0): preload("res://assets/tiles/blue-sword.png"),
	Vector2i(0, 1): preload("res://assets/tiles/yellow-sword.png"),
	Vector2i(0, 2): preload("res://assets/tiles/purple-sword.png"),
	Vector2i(0, 3): preload("res://assets/tiles/orange-sword.png"),
	Vector2i(1, 0): preload("res://assets/tiles/blue-medicine.png"),
	Vector2i(1, 1): preload("res://assets/tiles/yellow-medicine.png"),
	Vector2i(1, 2): preload("res://assets/tiles/purple-medicine.png"),
	Vector2i(1, 3): preload("res://assets/tiles/orange-medicine.png"),
	Vector2i(2, 0): preload("res://assets/tiles/blue-slow.png"),
	Vector2i(2, 1): preload("res://assets/tiles/yellow-slow.png"),
	Vector2i(2, 2): preload("res://assets/tiles/purple-slow.png"),
	Vector2i(2, 3): preload("res://assets/tiles/orange-slow.png"),
	Vector2i(3, 0): preload("res://assets/tiles/blue-haste.png"),
	Vector2i(3, 1): preload("res://assets/tiles/yellow-haste.png"),
	Vector2i(3, 2): preload("res://assets/tiles/purple-haste.png"),
	Vector2i(3, 3): preload("res://assets/tiles/orange-haste.png"),
	Vector2i(4, 0): preload("res://assets/tiles/blue-hammer.png"),
	Vector2i(4, 1): preload("res://assets/tiles/yellow-hammer.png"),
	Vector2i(4, 2): preload("res://assets/tiles/purple-hammer.png"),
	Vector2i(4, 3): preload("res://assets/tiles/orange-hammer.png"),
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
	_face.visible = false
	_icon.modulate = Color.WHITE
	_icon.texture = TILE_ART[Vector2i(pair_effect_id, pair_color_id)]
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
	# Hold the full-color art, then grey it before the cover fades in.
	_cover.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_interval(REVEAL_HOLD_DURATION)
	tween.tween_callback(func() -> void:
		_icon.modulate = Color(0.55, 0.55, 0.55, 1.0)
	)
	tween.tween_property(_cover, "modulate:a", 1.0, duration)
	tween.tween_callback(conceal)


func is_hidden() -> bool:
	return _state == State.HIDDEN


func is_empty() -> bool:
	return _state == State.EMPTY


func set_selected_outline(show_outline: bool) -> void:
	_selection_outline.visible = show_outline


func _reset_visuals() -> void:
	_kill_juice_tween()
	_restore_transform()
	_face.visible = false
	_icon.modulate = Color.WHITE
	_icon.texture = CARD_BACK
	_icon.visible = true
	_cover.modulate.a = 0.0
	_selection_outline.visible = false


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
