class_name Enemy
extends RefCounted

## One combatant. Combat owns the roster and applies the player's slow to attack speed.

var display_name: String
var max_hp: int
var hp: int
var damage: int
var interval: float
var timer: float = 0.0

enum Special { NONE, ARMOR, HEAL }

## Specials replace a normal swing. The gap is rolled as 3, 4, or 5 attack intervals.
var special := Special.NONE
var special_every := 0
var special_timer := 0.0
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


func get_special_interval(slow_multiplier: float) -> float:
	return interval * float(special_every) * slow_multiplier


func _roll_special_gap() -> void:
	if special == Special.NONE:
		special_every = 0
		special_timer = 0.0
		return
	special_every = randi_range(3, 5)
	special_timer = 0.0


func get_attack_progress(slow_multiplier: float) -> float:
	var attack_interval := get_attack_interval(slow_multiplier)
	if attack_interval <= 0.0:
		return 0.0
	return clampf(timer / attack_interval, 0.0, 1.0)


## One frame. A ready special replaces the swing: no damage, attack timer restarts.
func advance(delta: float, slow_multiplier: float) -> Dictionary:
	var result := {"attack": false, "armor": false, "heal": 0}
	if not is_alive():
		return result

	if armor_timer > 0.0:
		armor_timer = maxf(armor_timer - delta, 0.0)

	var special_ready := false
	if special != Special.NONE:
		special_timer += delta
		special_ready = special_timer >= get_special_interval(slow_multiplier)

	timer += delta
	var attack_ready := timer >= get_attack_interval(slow_multiplier)

	if special_ready:
		timer = 0.0
		_apply_special(result)
		_roll_special_gap()
	elif attack_ready:
		timer = 0.0
		result.attack = true

	return result


func _apply_special(result: Dictionary) -> void:
	match special:
		Special.ARMOR:
			armor_timer = armor_duration
			result.armor = true
		Special.HEAL:
			result.heal = heal_amount


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
	if special != Special.NONE:
		special_timer = minf(special_timer + amount, get_special_interval(slow_multiplier))
