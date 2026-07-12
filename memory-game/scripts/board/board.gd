class_name Board
extends Node2D

const GRID_SIZE := 4
const CELL_SIZE := 64
const FREEZE_DURATION := 1.0

@export var tile_scene: PackedScene = preload("res://scenes/board/Tile.tscn")

enum SelectionState { IDLE, ONE_SELECTED, RESOLVING }
signal pair_matched(pair_id: int)

var _tiles: Dictionary = {}
var _selection_state := SelectionState.IDLE
var _first_tile: Tile = null
var _second_tile: Tile = null
var _selector: Selector = null
var _input_frozen := false


func setup(selector: Selector) -> void:
	_selector = selector


func is_input_blocked() -> bool:
	return _input_frozen


func _ready() -> void:
	_spawn_grid()


func _spawn_grid() -> void:
	var pair_ids := _generate_shuffled_pair_ids()
	var index := 0

	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var tile: Tile = tile_scene.instantiate()
			tile.position = grid_to_world(Vector2i(x, y))
			add_child(tile)
			tile.setup(pair_ids[index])
			index += 1
			_tiles[Vector2i(x, y)] = tile


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
		grid_pos.x * (CELL_SIZE + 6) + 3,
		grid_pos.y * (CELL_SIZE + 6) + 3
	)


func clamp_grid_position(pos: Vector2i) -> Vector2i:
	return Vector2i(
		clampi(pos.x, 0, GRID_SIZE - 1),
		clampi(pos.y, 0, GRID_SIZE - 1)
	)


func get_tile_at(grid_pos: Vector2i) -> Tile:
	return _tiles.get(grid_pos)


func _unhandled_input(event: InputEvent) -> void:
	if _input_frozen:
		return
	if not event.is_action_pressed("reveal"):
		return
	if event.is_echo():
		return

	_try_reveal_selected_tile()


func _try_reveal_selected_tile() -> void:
	if _selection_state == SelectionState.RESOLVING:
		return

	var tile := get_tile_at(_selector.grid_position)
	if _selector == null or tile == null or not tile.is_hidden():
		return

	tile.reveal()

	match _selection_state:
		SelectionState.IDLE:
			_selection_state = SelectionState.ONE_SELECTED
			_first_tile = tile
		SelectionState.ONE_SELECTED:
			if _first_tile == tile:
				return
			_selection_state = SelectionState.RESOLVING
			_second_tile = tile
			_resolve_pair()


func _resolve_pair() -> void:
	var first := _first_tile
	var second := _second_tile
	_first_tile = null
	_second_tile = null
	_selection_state = SelectionState.IDLE

	if first.pair_id == second.pair_id:
		first.make_empty()
		second.make_empty()
		pair_matched.emit(first.pair_id)
	else:
		_resolve_mismatch(first, second)


func _resolve_mismatch(first: Tile, second: Tile) -> void:
	_input_frozen = true
	first.grey_and_fade()
	second.grey_and_fade()
	await get_tree().create_timer(FREEZE_DURATION).timeout
	_input_frozen = false
