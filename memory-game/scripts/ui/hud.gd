class_name HUD
extends CanvasLayer

@export var enemy_row_scene: PackedScene = preload("res://scenes/ui/enemy_hud_row.tscn")

@onready var _player_hp_label: Label = $VBoxContainer/PlayerHPLabel
@onready var _player_hp_bar: ProgressBar = $VBoxContainer/PlayerHPBar
@onready var _money_label: Label = $VBoxContainer/MoneyLabel
@onready var _enemy_list: VBoxContainer = $VBoxContainer/EnemyList

@onready var _slow_label: Label = $VBoxContainer/BuffRow/SlowLabel
@onready var _speed_label: Label = $VBoxContainer/BuffRow/SpeedLabel
@onready var _attack_label: Label = $VBoxContainer/BuffRow/AttackLabel
@onready var _effects_label: Label = $VBoxContainer/LastEffectLabel

@onready var _end_overlay: Control = $EndOverlay
@onready var _end_label: Label = $EndOverlay/CenterContainer/VBoxContainer/EndLabel

@onready var _mana_bar: ProgressBar = $VBoxContainer/ManaProgressBar

var _combat: Combat
var _selector: Selector
var _enemy_rows: Array[EnemyHudRow] = []


func setup(combat: Combat, selector: Selector) -> void:
	_combat = combat
	_selector = selector
	_player_hp_bar.max_value = combat.player_max_hp
	_mana_bar.max_value = Combat.MANA_MAX
	_rebuild_enemy_rows()
	refresh_hp()
	set_money(combat.money)


func _rebuild_enemy_rows() -> void:
	_enemy_rows.clear()
	while _enemy_list.get_child_count() > 0:
		var child := _enemy_list.get_child(0)
		_enemy_list.remove_child(child)
		child.free()

	for enemy in _combat.enemies:
		var row: EnemyHudRow = enemy_row_scene.instantiate()
		_enemy_list.add_child(row)
		row.setup(enemy)
		_enemy_rows.append(row)


func refresh_hp() -> void:
	if _combat == null:
		return
	_player_hp_label.text = "Player: %d / %d" % [_combat.player_hp, _combat.player_max_hp]
	_player_hp_bar.value = _combat.player_hp
	for row in _enemy_rows:
		row.refresh_hp()


func update_mana(mana: float, _maximum: float) -> void:
	_mana_bar.value = mana


func set_money(money: int) -> void:
	_money_label.text = "Gold: %d" % money


func set_last_effect(description: String) -> void:
	_effects_label.text = "Last: %s" % description


func show_battle_end(message: String) -> void:
	_end_label.text = message
	_end_overlay.visible = true
	for row in _enemy_rows:
		row.clear_attack_bar()
	set_process(false)


func _process(_delta: float) -> void:
	if _combat == null:
		return
	var slow_mult := _combat.get_slow_multiplier()
	var target := _combat.get_default_target()
	for row in _enemy_rows:
		row.set_is_target(row.tracks(target))
		row.update_attack_progress(slow_mult)
	_slow_label.text = "Slow: %d" % _combat.get_slow_stacks()
	_speed_label.text = "Speed: %d" % _selector.get_speed_stacks()
	_attack_label.text = "Attack: %d" % _combat.get_player_attack_damage()
