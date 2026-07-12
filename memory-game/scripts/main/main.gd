extends Node2D

@onready var board: Board = $Board
@onready var selector: Selector = $Selector
@onready var combat: Combat = $Combat
@onready var player_hp_label: Label = $HUD/VBoxContainer/PlayerHPLabel
@onready var enemy_hp_label: Label = $HUD/VBoxContainer/EnemyHPLabel
@onready var effect_resolver: EffectResolver = $EffectResolver

func _ready() -> void:
	selector.setup(board)
	board.setup(selector)
	combat.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(combat.player_hp, combat.enemy_hp)
	effect_resolver.setup(combat)
	board.pair_matched.connect(effect_resolver.apply)


func _on_hp_changed(player_hp: int, enemy_hp: int) -> void:
	player_hp_label.text = "Player: %d" % player_hp
	enemy_hp_label.text = "Enemy: %d" % enemy_hp
