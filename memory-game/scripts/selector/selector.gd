class_name Selector
extends Node2D

const BASE_MOVE_COOLDOWN := 0.4
const MIN_MOVE_COOLDOWN := 0.1
const SPEED_PER_STACK := 0.05
const MAX_SPEED_STACKS := 3
const SPEED_DURATION := 10.0

@onready var _outline: Line2D = $Outline

var grid_position := Vector2i.ZERO
var _move_timer := 0.0
var _speed_stacks := 0
var _speed_timer := 0.0
var _board: Board


func setup(board: Board) -> void:
	_board = board
	grid_position = Vector2i.ZERO
	_sync_position()


func set_grid_position(new_pos: Vector2i) -> void:
	grid_position = new_pos
	_sync_position()


func set_outline_visible(show_outline: bool) -> void:
	_outline.visible = show_outline


func _sync_position() -> void:
	if _board:
		position = _board.grid_to_world(grid_position)
		_board.notify_selector_moved()


func _process(delta: float) -> void:
	if _move_timer > 0.0:
		_move_timer = maxf(_move_timer - delta, 0.0)
	if _speed_timer > 0.0:
		_speed_timer -= delta
		if _speed_timer <= 0.0:
			_speed_stacks = 0


func _input(event: InputEvent) -> void:
	if _board and _board.is_input_blocked():
		return
	if _move_timer > 0.0:
		return
	if event.is_echo():
		return

	if event.is_action_pressed("move_left"):
		_move_to_position(Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		_move_to_position(Vector2i.RIGHT)
	elif event.is_action_pressed("move_up"):
		_move_to_position(Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		_move_to_position(Vector2i.DOWN)


func _move_to_position(direction: Vector2i) -> void:
	var target := _board.clamp_grid_position(grid_position + direction)
	if target == grid_position:
		return
	set_grid_position(target)
	_move_timer = get_move_cooldown()


func apply_speed() -> void:
	_speed_stacks = mini(_speed_stacks + 1, MAX_SPEED_STACKS)
	_speed_timer = SPEED_DURATION


func get_move_cooldown() -> float:
	return maxf(BASE_MOVE_COOLDOWN - _speed_stacks * SPEED_PER_STACK, MIN_MOVE_COOLDOWN)

func get_speed_stacks() -> int:
	return _speed_stacks
