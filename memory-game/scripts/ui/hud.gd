class_name HUD
extends CanvasLayer

@onready var _player_hp_label: Label = $VBoxContainer/PlayerHPLabel
@onready var _enemy_hp_label: Label = $VBoxContainer/EnemyHPLabel
@onready var _player_hp_bar: ProgressBar = $VBoxContainer/PlayerHPBar
@onready var _enemy_hp_bar: ProgressBar = $VBoxContainer/EnemyHPBar
@onready var _attack_progress: ProgressBar = $VBoxContainer/EnemyAttackBar

@onready var _slow_label: Label = $VBoxContainer/BuffRow/SlowLabel
@onready var _speed_label: Label = $VBoxContainer/BuffRow/SpeedLabel
@onready var _attack_label: Label = $VBoxContainer/BuffRow/AttackLabel
@onready var _effects_label: Label = $VBoxContainer/LastEffectLabel

@onready var _end_overlay: Control = $EndOverlay
@onready var _end_label: Label = $EndOverlay/CenterContainer/VBoxContainer/EndLabel

@onready var _mana_bar: ProgressBar = $VBoxContainer/ManaProgressBar

var _combat: Combat
var _selector: Selector


func setup(combat: Combat, selector: Selector) -> void:
	_combat = combat
	_selector = selector
	_player_hp_bar.max_value = combat.player_max_hp
	_enemy_hp_bar.max_value = combat.enemy_max_hp
	_attack_progress.max_value = 100.0
	_mana_bar.max_value = Combat.MANA_MAX


func update_hp(player_hp: int, player_max: int, enemy_hp: int, enemy_max: int) -> void:
	_player_hp_label.text = "Player: %d / %d" % [player_hp, player_max]
	_enemy_hp_label.text = "Enemy: %d / %d" % [enemy_hp, enemy_max]
	_player_hp_bar.value = player_hp
	_enemy_hp_bar.value = enemy_hp

func update_mana(mana: float, maximum: float) -> void:
	_mana_bar.value = mana


func set_last_effect(description: String) -> void:
	_effects_label.text = "Last: %s" % description


func show_battle_end(message: String) -> void:
	_end_label.text = message
	_end_overlay.visible = true
	_attack_progress.value = 0.0
	set_process(false)


func _process(_delta: float) -> void:
	_attack_progress.value = _combat.get_attack_progress() * 100.0
	_slow_label.text = "Slow: %d" % _combat.get_slow_stacks()
	_speed_label.text = "Speed: %d" % _selector.get_speed_stacks()
	_attack_label.text = "Attack: %d" % _combat.get_player_attack_damage()
