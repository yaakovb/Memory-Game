class_name EnemyHudRow
extends VBoxContainer

@onready var _name_label: Label = $NameLabel
@onready var _hp_bar: ProgressBar = $HPBar
@onready var _attack_label: Label = $AttackLabel
@onready var _attack_bar: ProgressBar = $AttackBar

var _enemy: Enemy


func setup(enemy: Enemy) -> void:
	_enemy = enemy
	if is_node_ready():
		_apply_setup()
	else:
		# setup() may run before @onready if called before entering the tree.
		ready.connect(_apply_setup, CONNECT_ONE_SHOT)


func _apply_setup() -> void:
	if _enemy == null:
		return
	_hp_bar.max_value = _enemy.max_hp
	_attack_label.text = "Next Attack"
	_attack_bar.max_value = 100.0
	_attack_bar.value = 0.0
	refresh_hp()


func refresh_hp() -> void:
	if _enemy == null or not is_node_ready():
		return
	var armor := "  Armor" if _enemy.is_armored() else ""
	_name_label.text = "%s: %d / %d%s" % [_enemy.display_name, _enemy.hp, _enemy.max_hp, armor]
	_hp_bar.value = _enemy.hp
	modulate.a = 1.0 if _enemy.is_alive() else 0.45


func update_attack_progress(slow_multiplier: float) -> void:
	if _enemy == null or not is_node_ready():
		return
	if not _enemy.is_alive():
		_attack_bar.value = 0.0
		return
	_attack_bar.value = _enemy.get_attack_progress(slow_multiplier) * 100.0
	_attack_label.text = "Special" if _enemy.is_charging_special() else "Next Attack"
	var armor := "  Armor" if _enemy.is_armored() else ""
	_name_label.text = "%s: %d / %d%s" % [_enemy.display_name, _enemy.hp, _enemy.max_hp, armor]


func clear_attack_bar() -> void:
	if is_node_ready():
		_attack_bar.value = 0.0
