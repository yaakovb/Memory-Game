class_name DummyPlayer
extends Node
## Rule-based bot for balance runs. Calls Board APIs — same resolve path as a human.
## Enable from Main (`enable_dummy_player`) or ProjectSettings `memory_arena/dummy_player`.

@export var think_delay := 0.08
@export var max_matches := 100
@export var restart_delay := 0.35

var _board: Board
var _combat: Combat
var _enabled := false
var _restarting := false
## Perfect memory of every tile ever revealed this deal: grid_pos -> Vector2i(effect, color)
var _memory: Dictionary = {}
var _think_timer := 0.0


func setup(board: Board, combat: Combat, enabled: bool) -> void:
	_board = board
	_combat = combat
	_enabled = enabled
	if not _enabled:
		return

	_board.board_dealt.connect(_on_board_dealt)
	DebugLog.info("dummy", "enabled — max_matches=%d think_delay=%.2f" % [max_matches, think_delay])
	_on_board_dealt()


func request_restart_after_battle() -> void:
	if not _enabled or _restarting:
		return
	if DebugLog.session_matches >= max_matches:
		DebugLog.info("dummy", "batch complete — stopping auto-restart at %d matches" % max_matches)
		return

	_restarting = true
	DebugLog.info("dummy", "restarting in %.2fs (%d/%d)" % [
		restart_delay, DebugLog.session_matches, max_matches
	])
	await get_tree().create_timer(restart_delay).timeout
	get_tree().reload_current_scene()


func _process(delta: float) -> void:
	if not _enabled or _restarting:
		return
	if _board == null or _board.is_input_blocked():
		return

	_think_timer -= delta
	if _think_timer > 0.0:
		return

	_think_timer = think_delay
	_take_action()


func _take_action() -> void:
	_prune_stale_memory()

	var pick := _choose_reveal_target()
	if pick.x < 0:
		return

	var revealed := _board.try_reveal_at(pick)
	if not revealed:
		return

	var tile := _board.get_tile_at(pick)
	if tile != null:
		_memory[pick] = Vector2i(tile.pair_effect_id, tile.pair_color_id)


func _choose_reveal_target() -> Vector2i:
	## 1) Finish a known true pair when one tile is already selected.
	var known_match := _find_known_true_pair()
	if known_match.x >= 0:
		return known_match

	## 2) Otherwise flip a random unknown hidden tile (explore).
	var unknown: Array[Vector2i] = []
	var known_hidden: Array[Vector2i] = []
	for pos in _board.get_all_grid_positions():
		var tile := _board.get_tile_at(pos)
		if tile == null or not tile.is_hidden():
			continue
		if _memory.has(pos):
			known_hidden.append(pos)
		else:
			unknown.append(pos)

	if not unknown.is_empty():
		return unknown[randi() % unknown.size()]
	if not known_hidden.is_empty():
		return known_hidden[randi() % known_hidden.size()]
	return Vector2i(-1, -1)


func _find_known_true_pair() -> Vector2i:
	var first_pos := _board.get_first_selected_grid_pos()
	if first_pos.x >= 0 and _memory.has(first_pos):
		var want: Vector2i = _memory[first_pos]
		for pos in _memory.keys():
			if pos == first_pos:
				continue
			var tile := _board.get_tile_at(pos)
			if tile == null or not tile.is_hidden():
				continue
			if _memory[pos] == want:
				return pos

	## Idle: start any remembered true pair that is still hidden.
	var seen: Dictionary = {} # signature -> first grid pos
	for pos in _memory.keys():
		var tile := _board.get_tile_at(pos)
		if tile == null or not tile.is_hidden():
			continue
		var sig: Vector2i = _memory[pos]
		if seen.has(sig):
			return seen[sig]
		seen[sig] = pos
	return Vector2i(-1, -1)


func _prune_stale_memory() -> void:
	var stale: Array = []
	for pos in _memory.keys():
		var tile := _board.get_tile_at(pos)
		if tile == null or tile.is_empty():
			stale.append(pos)
	for pos in stale:
		_memory.erase(pos)


func _on_board_dealt() -> void:
	_memory.clear()
	_think_timer = think_delay
