class_name Enemy
extends RefCounted

## One combatant. Combat owns the roster and applies the player's slow to attack speed.

var display_name: String
var max_hp: int
var hp: int
var damage: int
var interval: float
var timer: float = 0.0

## Chance to gain armor when this enemy attacks. 0 = never.
var armor_chance := 0.0
var armor_duration := 0.0
var armor_timer := 0.0

## 0 heal_amount means this enemy never heals.
var heal_amount := 0
var heal_interval := 0.0
var heal_timer := 0.0


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


func is_alive() -> bool:
	return hp > 0


func is_armored() -> bool:
	return armor_timer > 0.0


func get_attack_interval(slow_multiplier: float) -> float:
	return interval * slow_multiplier


func get_attack_progress(slow_multiplier: float) -> float:
	var attack_interval := get_attack_interval(slow_multiplier)
	if attack_interval <= 0.0:
		return 0.0
	return clampf(timer / attack_interval, 0.0, 1.0)


## One frame of this enemy's own timers.
## attack: swing is ready. armor: this swing raised armor. heal: amount to give an ally.
func advance(delta: float, slow_multiplier: float) -> Dictionary:
	var result := {"attack": false, "armor": false, "heal": 0}
	if not is_alive():
		return result

	if armor_timer > 0.0:
		armor_timer = maxf(armor_timer - delta, 0.0)

	timer += delta
	if timer >= get_attack_interval(slow_multiplier):
		timer = 0.0
		result.attack = true
		if armor_chance > 0.0 and randf() < armor_chance:
			armor_timer = armor_duration
			result.armor = true

	if heal_amount > 0 and heal_interval > 0.0:
		heal_timer += delta
		if heal_timer >= heal_interval:
			heal_timer = 0.0
			result.heal = heal_amount

	return result


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
