class_name EnemyHudRow
extends PanelContainer

@onready var _name_label: Label = $Body/NameLabel
@onready var _hp_bar: ProgressBar = $Body/HPBar
@onready var _attack_label: Label = $Body/AttackLabel
@onready var _attack_bar: ProgressBar = $Body/AttackBar
@onready var _special_label: Label = $Body/SpecialLabel
@onready var _special_bar: ProgressBar = $Body/SpecialBar

var _enemy: Enemy
var _is_target := false


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
	_special_bar.max_value = 100.0
	_special_bar.value = 0.0
	refresh_hp()


func refresh_hp() -> void:
	if _enemy == null or not is_node_ready():
		return
	var armor := "  Armor" if _enemy.is_armored() else ""
	var target := "  (target)" if _is_target else ""
	_name_label.text = "%s: %d / %d%s%s" % [_enemy.display_name, _enemy.hp, _enemy.max_hp, armor, target]
	_hp_bar.value = _enemy.hp
	modulate.a = 1.0 if _enemy.is_alive() else 0.45


func tracks(enemy: Enemy) -> bool:
	return _enemy == enemy


func set_is_target(is_target: bool) -> void:
	_is_target = is_target


func update_attack_progress(slow_multiplier: float) -> void:
	if _enemy == null or not is_node_ready():
		return
	if not _enemy.is_alive():
		_attack_bar.value = 0.0
		_special_bar.value = 0.0
		return
	var filling_special := _enemy.is_charging_special()
	_attack_bar.value = 0.0 if filling_special else _enemy.get_attack_progress(slow_multiplier) * 100.0
	_attack_label.text = "Attack"
	_special_bar.value = _enemy.get_attack_progress(slow_multiplier) * 100.0 if filling_special else 0.0
	if _enemy.special_name() == "":
		_special_label.text = ""
	elif filling_special:
		_special_label.text = _enemy.special_name()
	else:
		_special_label.text = "%s after %d" % [_enemy.special_name(), _enemy.attacks_before_special()]
	var armor := "  Armor" if _enemy.is_armored() else ""
	var target := "  (target)" if _is_target else ""
	_name_label.text = "%s: %d / %d%s%s" % [_enemy.display_name, _enemy.hp, _enemy.max_hp, armor, target]


func clear_attack_bar() -> void:
	if is_node_ready():
		_attack_bar.value = 0.0
		_special_bar.value = 0.0
