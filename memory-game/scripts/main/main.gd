extends Node2D


var _battle_ended := false

@onready var _board: Board = $Board
@onready var _selector: Selector = $Selector
@onready var _combat: Combat = $Combat
@onready var _player_hp_label: Label = $HUD/VBoxContainer/PlayerHPLabel
@onready var _enemy_hp_label: Label = $HUD/VBoxContainer/EnemyHPLabel
@onready var _effect_resolver: EffectResolver = $EffectResolver
@onready var _end_overlay: Control = $HUD/EndOverlay
@onready var _end_label: Label = $HUD/EndOverlay/CenterContainer/EndLabel

func _ready() -> void:
	_selector.setup(_board)
	_board.setup(_selector)
	_combat.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(_combat.player_hp, _combat.enemy_hp)
	_effect_resolver.setup(_combat, _selector)
	_board.pair_matched.connect(_effect_resolver.apply)
	_combat.player_defeated.connect(_on_player_defeated)
	_combat.enemy_defeated.connect(_on_enemy_defeated)

func _on_hp_changed(player_hp: int, enemy_hp: int) -> void:
	_player_hp_label.text = "Player: %d" % player_hp
	_enemy_hp_label.text = "Enemy: %d" % enemy_hp

func _on_player_defeated() -> void:
	handle_battle_ended("You Lose")

func _on_enemy_defeated() -> void:
	handle_battle_ended("You Win Hurray Hurray")

func handle_battle_ended(message: String) -> void:
	if _battle_ended:
		return
	
	_board.set_battle_ended(true)
	_combat.set_battle_ended(true)
	_battle_ended = true

	_end_label.text = message
	_end_overlay.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if _battle_ended and event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
