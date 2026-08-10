class_name Board
extends Node2D

const GRID_SIZE := 6
const CELL_SIZE := 64
const TILE_GAP := 6
const BOARD_MARGIN := 3

## One entry per pair: Vector2i(effect_id, color_id).
## effect: 0 Attack, 1 Heal, 2 Slow, 3 Speed, 4 Upgrade
## color:  0 Blue, 1 Yellow, 2 Purple, 3 Orange
## Totals: 6 Blue, 5 Purple, 4 Orange, 3 Yellow — duplicates allowed.
const STARTING_PAIRS: Array[Vector2i] = [
	# Attack ×10
	Vector2i(0, 0), Vector2i(0, 0), Vector2i(0, 0), # Blue ×3
	Vector2i(0, 2), Vector2i(0, 2), Vector2i(0, 2), # Purple ×3
	Vector2i(0, 1), Vector2i(0, 1), # Yellow ×2
	Vector2i(0, 3), Vector2i(0, 3), # Orange ×2
	# Heal ×3
	Vector2i(1, 0), # Blue
	Vector2i(1, 2), # Purple
	Vector2i(1, 3), # Orange
	# Slow ×2
	Vector2i(2, 0), # Blue
	Vector2i(2, 1), # Yellow
	# Speed ×2
	Vector2i(3, 0), # Blue
	Vector2i(3, 2), # Purple
	# Upgrade ×1
	Vector2i(4, 3), # Orange
]

@export var tile_scene: PackedScene = preload("res://scenes/board/Tile.tscn")

enum SelectionState { IDLE, ONE_SELECTED, RESOLVING }

signal pair_matched(effect_id: int)       # keep
signal color_matched(color_id: int)       # new — mana stub + hurry
signal icon_only_matched                  # new — optional; or fold into mismatch
signal pair_mismatched                    # full miss only
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
	var signatures := _generate_shuffled_pair_signatures()
	var index := 0
	_pairs_remaining = signatures.size() / 2

	for y in GRID_SIZE:
		for x in GRID_SIZE:
			var tile: Tile = tile_scene.instantiate()
			tile.position = grid_to_world(Vector2i(x, y))
			add_child(tile)
			var sig: Vector2i = signatures[index]
			tile.setup(-1, sig.y, sig.x)
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


func _generate_shuffled_pair_signatures() -> Array[Vector2i]:
	assert(STARTING_PAIRS.size() == (GRID_SIZE * GRID_SIZE) / 2)
	var entries: Array[Vector2i] = []
	for sig in STARTING_PAIRS:
		entries.append(sig)
		entries.append(sig)
	entries.shuffle()
	return entries


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

	var same_effect := first.pair_effect_id == second.pair_effect_id
	var same_color := first.pair_color_id == second.pair_color_id

	if same_effect and same_color:
		first.play_match_pop()
		second.play_match_pop()
		pair_matched.emit(first.pair_effect_id)
		_pairs_remaining -= 1
		if _pairs_remaining <= 0:
			# Let the pop finish before freeing tiles for a new board.
			await get_tree().create_timer(Tile.MATCH_POP_DURATION).timeout
			board_cleared.emit()
			_deal_new_board()
	elif same_effect:
		_resolve_mismatch(first, second)
	elif same_color:
		color_matched.emit(first.pair_color_id)
		first.grey_and_fade(Tile.COLOR_MATCH_FADE_DURATION)
		second.grey_and_fade(Tile.COLOR_MATCH_FADE_DURATION)
	else:
		_resolve_mismatch(first, second)


func _resolve_mismatch(first: Tile, second: Tile) -> void:
	pair_mismatched.emit()
	first.grey_and_fade(Tile.MISMATCH_FADE_DURATION)
	second.grey_and_fade(Tile.MISMATCH_FADE_DURATION)


func _update_selector_outline() -> void:
	if _selector == null:
		return
	var hide_on_first_pick := (
		_selection_state == SelectionState.ONE_SELECTED
		and _selector.grid_position == _first_tile_grid_pos
	)
	_selector.set_outline_visible(not hide_on_first_pick)
