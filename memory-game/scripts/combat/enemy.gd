class_name Enemy
extends RefCounted

## One combatant. Combat owns the roster and applies the player's slow to attack speed.

var display_name: String
var max_hp: int
var hp: int
var damage: int
var interval: float
var timer: float = 0.0

enum Special { NONE, ARMOR, HEAL, STRIKE }

## After this many normal swings, the special timer starts. Rolled as 3, 4, or 5.
var special := Special.NONE
var attacks_until_special := 0
var _attacks_since_special := 0
var _charging_special := false
var special_damage := 0
var armor_duration := 0.0
var armor_timer := 0.0
var heal_amount := 0


func _init(
	p_name: String,
	p_max_hp: int,
	p_damage: int,
	p_interval: float
) -> void:
	display_name = p_name
	max_hp = p_max_hp
	hp = p_max_hp
	damage = p_damage
	interval = p_interval
	_roll_special_gap()


func is_alive() -> bool:
	return hp > 0


func is_armored() -> bool:
	return armor_timer > 0.0


func get_attack_interval(slow_multiplier: float) -> float:
	return interval * slow_multiplier


func is_charging_special() -> bool:
	return _charging_special


func _roll_special_gap() -> void:
	_attacks_since_special = 0
	_charging_special = false
	if special == Special.NONE:
		attacks_until_special = 0
		return
	attacks_until_special = randi_range(3, 5)


func get_attack_progress(slow_multiplier: float) -> float:
	var attack_interval := get_attack_interval(slow_multiplier)
	if attack_interval <= 0.0:
		return 0.0
	return clampf(timer / attack_interval, 0.0, 1.0)


## One frame. After enough swings, the special timer starts at zero and fills like an attack.
## The special fires when that timer finishes, and it does not also swing.
func advance(delta: float, slow_multiplier: float) -> Dictionary:
	var result := {"attack": false, "armor": false, "heal": 0, "special_damage": 0}
	if not is_alive():
		return result

	if armor_timer > 0.0:
		armor_timer = maxf(armor_timer - delta, 0.0)

	timer += delta
	if timer < get_attack_interval(slow_multiplier):
		return result

	timer = 0.0
	if _charging_special:
		_apply_special(result)
		_roll_special_gap()
		return result

	result.attack = true
	if special == Special.NONE:
		return result

	_attacks_since_special += 1
	if _attacks_since_special >= attacks_until_special:
		_charging_special = true
	return result


func _apply_special(result: Dictionary) -> void:
	match special:
		Special.ARMOR:
			armor_timer = armor_duration
			result.armor = true
		Special.HEAL:
			result.heal = heal_amount
		Special.STRIKE:
			result.special_damage = special_damage


func take_damage(amount: int) -> void:
	var dealt := amount
	if is_armored() and dealt > 0:
		dealt = maxi(1, dealt / 2)
	hp = maxi(hp - dealt, 0)


func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)


func hurry(amount: float, slow_multiplier: float) -> void:
	if not is_alive():
		return
	timer = minf(timer + amount, get_attack_interval(slow_multiplier))
