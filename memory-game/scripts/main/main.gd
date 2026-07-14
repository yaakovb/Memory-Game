extends Node2D

@onready var _board: Board = $Board
@onready var _selector: Selector = $Selector
@onready var _combat: Combat = $Combat
@onready var _player_hp_label: Label = $HUD/VBoxContainer/PlayerHPLabel
@onready var _enemy_hp_label: Label = $HUD/VBoxContainer/EnemyHPLabel
@onready var _effect_resolver: EffectResolver = $EffectResolver


func _ready() -> void:
	_selector.setup(_board)
	_board.setup(_selector)
	_combat.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(_combat.player_hp, _combat.enemy_hp)
	_effect_resolver.setup(_combat, _selector)
	_board.pair_matched.connect(_effect_resolver.apply)


func _on_hp_changed(player_hp: int, enemy_hp: int) -> void:
	_player_hp_label.text = "Player: %d" % player_hp
	_enemy_hp_label.text = "Enemy: %d" % enemy_hp
