class_name Board
extends Node2D

const GRID_SIZE := 4
const CELL_SIZE := 64
const TILE_GAP := 6
const BOARD_MARGIN := 3

@export var tile_scene: PackedScene = preload("res://scenes/board/Tile.tscn")

enum SelectionState { IDLE, ONE_SELECTED, RESOLVING }

signal pair_matched(pair_id: int)
signal pair_mismatched
signal board_cleared
signal board_dealt

var _tiles: Dictionary = {}
var _selection_state := SelectionState.IDLE
var _first_tile: Tile = null
var _second_tile: Tile = null
var _selector: Selector = null
var _pairs_remaining := 0
var _first_tile_grid_pos := Vector2i(-1, -1)
var _battle_ended := false


func set_battle_ended(value: bool) -> void:
	_battle_ended = value


func setup(selector: Selector) -> void:
	_selector = selector


func is_input_blocked() -> bool:
	return _battle_ended


func notify_selector_moved() -> void:
	_update_selector_outline()


func _ready() -> void:
	_spawn_grid()


func _spawn_grid() -> void:
	var pair_ids := _generate_shuffled_pair_ids()
	var index := 0
	_pairs_remaining = pair_ids.size() / 2

	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var tile: Tile = tile_scene.instantiate()
			tile.position = grid_to_world(Vector2i(x, y))
			add_child(tile)
			tile.setup(pair_ids[index])
			index += 1
			_tiles[Vector2i(x, y)] = tile

	board_dealt.emit()


func _clear_tiles() -> void:
	for tile in _tiles.values():
		if is_instance_valid(tile):
			tile.queue_free()
	_tiles.clear()


func _deal_new_board() -> void:
	_selection_state = SelectionState.IDLE
	_first_tile = null
	_second_tile = null
	_first_tile_grid_pos = Vector2i(-1, -1)
	_clear_tiles()
	await get_tree().process_frame
	_spawn_grid()
	_update_selector_outline()


func _generate_shuffled_pair_ids() -> Array:
	var ids: Array = []
	var pair_count := (GRID_SIZE * GRID_SIZE) / 2
	for i in pair_count:
		ids.append(i)
		ids.append(i)
	ids.shuffle()
	return ids


func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * (CELL_SIZE + TILE_GAP) + BOARD_MARGIN,
		grid_pos.y * (CELL_SIZE + TILE_GAP) + BOARD_MARGIN
	)


func clamp_grid_position(pos: Vector2i) -> Vector2i:
	return Vector2i(
		clampi(pos.x, 0, GRID_SIZE - 1),
		clampi(pos.y, 0, GRID_SIZE - 1)
	)


func get_tile_at(grid_pos: Vector2i) -> Tile:
	return _tiles.get(grid_pos)


func _unhandled_input(event: InputEvent) -> void:
	if _battle_ended:
		return
	if not event.is_action_pressed("reveal"):
		return
	if event.is_echo():
		return

	_try_reveal_selected_tile()


func _try_reveal_selected_tile() -> void:
	if _selection_state == SelectionState.RESOLVING:
		return
	if _selector == null:
		return

	var tile := get_tile_at(_selector.grid_position)
	if tile == null or not tile.is_hidden():
		return

	tile.reveal()

	match _selection_state:
		SelectionState.IDLE:
			_selection_state = SelectionState.ONE_SELECTED
			_first_tile = tile
			_first_tile_grid_pos = _selector.grid_position
			tile.set_selected_outline(true)
			_update_selector_outline()
		SelectionState.ONE_SELECTED:
			_selection_state = SelectionState.RESOLVING
			_second_tile = tile
			_resolve_pair()


func _resolve_pair() -> void:
	var first := _first_tile
	var second := _second_tile
	_first_tile = null
	_second_tile = null
	_selection_state = SelectionState.IDLE
	_first_tile_grid_pos = Vector2i(-1, -1)

	first.set_selected_outline(false)
	_update_selector_outline()

	if first.pair_id == second.pair_id:
		first.make_empty()
		second.make_empty()
		pair_matched.emit(first.pair_id)
		_pairs_remaining -= 1
		if _pairs_remaining <= 0:
			board_cleared.emit()
			_deal_new_board()
	else:
		_resolve_mismatch(first, second)


func _resolve_mismatch(first: Tile, second: Tile) -> void:
	pair_mismatched.emit()
	first.grey_and_fade()
	second.grey_and_fade()


func _update_selector_outline() -> void:
	if _selector == null:
		return
	var hide_on_first_pick := (
		_selection_state == SelectionState.ONE_SELECTED
		and _selector.grid_position == _first_tile_grid_pos
	)
	_selector.set_outline_visible(not hide_on_first_pick)
