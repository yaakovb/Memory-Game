extends Node2D


var _battle_ended := false

@onready var _board: Board = $Board
@onready var _selector: Selector = $Selector
@onready var _combat: Combat = $Combat
@onready var _effect_resolver: EffectResolver = $EffectResolver

@onready var _player_hp_label: Label = $HUD/VBoxContainer/PlayerHPLabel
@onready var _enemy_hp_label: Label = $HUD/VBoxContainer/EnemyHPLabel
@onready var _player_hp_bar: ProgressBar = $HUD/VBoxContainer/PlayerHPBar
@onready var _enemy_hp_bar: ProgressBar = $HUD/VBoxContainer/EnemyHPBar
@onready var _attack_progress: ProgressBar = $HUD/VBoxContainer/EnemyAttackBar

@onready var _end_overlay: Control = $HUD/EndOverlay
@onready var _end_label: Label = $HUD/EndOverlay/CenterContainer/VBoxContainer/EndLabel

@onready var _slow_label: Label = $HUD/VBoxContainer/BuffRow/SlowLabel
@onready var _speed_label: Label = $HUD/VBoxContainer/BuffRow/SpeedLabel
@onready var _attack_label: Label = $HUD/VBoxContainer/BuffRow/AttackLabel

@onready var _effects_label: Label = $HUD/VBoxContainer/LastEffectLabel

func _ready() -> void:
	_selector.setup(_board)
	_board.setup(_selector)
	_combat.hp_changed.connect(_on_hp_changed)
	_effect_resolver.setup(_combat, _selector)
	_effect_resolver.effect_applied.connect(_on_effect_applied)
	_board.pair_matched.connect(_effect_resolver.apply)
	_board.pair_mismatched.connect(_combat.hurry_next_attack)
	_combat.player_defeated.connect(_on_player_defeated)
	_combat.enemy_defeated.connect(_on_enemy_defeated)
	_player_hp_bar.max_value = _combat.player_max_hp
	_enemy_hp_bar.max_value = _combat.enemy_max_hp
	_attack_progress.max_value = 100.0
	_on_hp_changed(_combat.player_hp, _combat.enemy_hp)
	_update_buff_row()

func _on_hp_changed(player_hp: int, enemy_hp: int) -> void:
	_player_hp_label.text = "Player: %d / %d" % [player_hp, _combat.player_max_hp]
	_enemy_hp_label.text = "Enemy: %d / %d" % [enemy_hp, _combat.enemy_max_hp]
	_player_hp_bar.value = player_hp
	_enemy_hp_bar.value = enemy_hp

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

func _input(event: InputEvent) -> void:
	if not _battle_ended:
		return
	if event.is_echo():
		return
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _process(delta: float) -> void:
	if _battle_ended:
		_attack_progress.value = 0.0;
		return
	_attack_progress.value = _combat.get_attack_progress() * 100.0
	_update_buff_row()

func _update_buff_row() -> void:
	_slow_label.text = "Slow: %d" % _combat.get_slow_stacks()
	_speed_label.text = "Speed: %d" % _selector.get_speed_stacks()
	_attack_label.text = "Attack: %d" % _combat.get_player_attack_damage()

func _on_effect_applied(description: String) -> void:
	_effects_label.text = "Last: %s" % description