extends Node2D

@onready var board: Board = $Board
@onready var selector: Selector = $Selector

func _ready() -> void:
	selector.setup(board)
	board.setup(selector)
