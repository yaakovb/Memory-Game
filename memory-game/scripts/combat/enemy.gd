class_name Enemy
extends RefCounted

## One combatant in the roster. Combat (director) owns the list and applies slow/hurry.

var display_name: String
var max_hp: int
var hp: int
var damage: int
var interval: float
var timer: float = 0.0


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
	timer = 0.0


func is_alive() -> bool:
	return hp > 0


## Baseline interval scaled by Combat's slow multiplier (1.0 = no slow).
func get_attack_interval(slow_multiplier: float) -> float:
	return interval * slow_multiplier


func get_attack_progress(slow_multiplier: float) -> float:
	var attack_interval := get_attack_interval(slow_multiplier)
	if attack_interval <= 0.0:
		return 0.0
	return clampf(timer / attack_interval, 0.0, 1.0)


## Returns true when this enemy should deal `damage` to the player.
func tick(delta: float, slow_multiplier: float) -> bool:
	if not is_alive():
		return false
	timer += delta
	var attack_interval := get_attack_interval(slow_multiplier)
	if timer >= attack_interval:
		timer = 0.0
		return true
	return false


func take_damage(amount: int) -> void:
	hp = maxi(hp - amount, 0)


func heal(amount: int) -> void:
	hp = mini(hp + amount, max_hp)


func hurry(amount: float, slow_multiplier: float) -> void:
	if not is_alive():
		return
	timer = minf(timer + amount, get_attack_interval(slow_multiplier))
