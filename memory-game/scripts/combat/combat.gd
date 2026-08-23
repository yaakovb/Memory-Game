class_name Combat
extends Node

signal hp_changed
signal player_defeated
signal enemy_defeated(enemy: Enemy)
signal all_enemies_defeated
signal mana_changed(current: float, maximum: float)
signal bonus_attack_fired(damage: int)

@export var player_max_hp := 20

const MAX_SLOW_STACKS := 3
const SLOW_DURATION := 10.0
const SLOW_PER_STACK := 0.25
const BASE_ATTACK_DAMAGE := 3
const MISMATCH_ATTACK_HURRY := 0.5
const MANA_MAX := 100.0
const MANA_PER_COLOR_MATCH := 25.0

## Placeholder roster — tune in Step 10 / GDD Values.
const TANK_MAX_HP := 20
const TANK_DAMAGE := 1
const TANK_INTERVAL := 3.0
const ASSASSIN_MAX_HP := 10
const ASSASSIN_DAMAGE := 4
const ASSASSIN_INTERVAL := 8.0

var player_hp: int
## Public — EffectResolver / HUD read this for display and upgrades.
var attack_bonus := 0
var mana := 0.0
var enemies: Array[Enemy] = []

var _battle_ended := false
var _slow_stacks := 0
var _slow_timer := 0.0


## Placeholder roster — change this list only (HUD builds one row per entry).
## Examples: two tanks, or append a third Enemy.new(...) for a 3-enemy fight.
func _ready() -> void:
	player_hp = player_max_hp
	enemies = [
		Enemy.new("Tank", TANK_MAX_HP, TANK_DAMAGE, TANK_INTERVAL),
		Enemy.new("Assassin", ASSASSIN_MAX_HP, ASSASSIN_DAMAGE, ASSASSIN_INTERVAL),
		# Enemy.new("Tank 2", TANK_MAX_HP, TANK_DAMAGE, TANK_INTERVAL),
	]
	hp_changed.emit()


func _process(delta: float) -> void:
	if _battle_ended:
		return

	var slow_mult := get_slow_multiplier()
	for enemy in enemies:
		if enemy.tick(delta, slow_mult):
			damage_player(enemy.damage)

	if _slow_timer > 0.0:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			_slow_stacks = 0


func damage_player(amount: int) -> void:
	player_hp = maxi(player_hp - amount, 0)
	hp_changed.emit()
	if player_hp <= 0:
		player_defeated.emit()


## Damages the default target (first living enemy).
func damage_enemy(amount: int) -> void:
	var target := get_default_target()
	if target == null:
		return
	target.take_damage(amount)
	hp_changed.emit()
	if not target.is_alive():
		enemy_defeated.emit(target)
		if not has_living_enemies():
			all_enemies_defeated.emit()


func heal_player(amount: int) -> void:
	player_hp = mini(player_hp + amount, player_max_hp)
	hp_changed.emit()


func heal_enemy(amount: int) -> void:
	var target := get_default_target()
	if target == null:
		return
	target.heal(amount)
	hp_changed.emit()


func add_attack_bonus(amount: int) -> void:
	attack_bonus += amount


func apply_slow() -> void:
	_slow_stacks = mini(_slow_stacks + 1, MAX_SLOW_STACKS)
	_slow_timer = SLOW_DURATION


func get_slow_stacks() -> int:
	return _slow_stacks


func get_slow_multiplier() -> float:
	return 1.0 + _slow_stacks * SLOW_PER_STACK


func get_default_target() -> Enemy:
	for enemy in enemies:
		if enemy.is_alive():
			return enemy
	return null


func has_living_enemies() -> bool:
	return get_default_target() != null


func set_battle_ended(value: bool) -> void:
	_battle_ended = value


func get_player_attack_damage() -> int:
	return BASE_ATTACK_DAMAGE + attack_bonus


func hurry_next_attack(amount: float = MISMATCH_ATTACK_HURRY) -> void:
	if _battle_ended:
		return
	var slow_mult := get_slow_multiplier()
	for enemy in enemies:
		enemy.hurry(amount, slow_mult)


func add_mana(amount: float) -> void:
	if _battle_ended:
		return
	mana = minf(mana + amount, MANA_MAX)
	mana_changed.emit(mana, MANA_MAX)
	if mana >= MANA_MAX:
		mana = MANA_MAX
		_fire_bonus_attack()


func _fire_bonus_attack() -> void:
	mana = 0.0
	mana_changed.emit(mana, MANA_MAX)
	var damage := get_player_attack_damage()
	damage_enemy(damage)
	bonus_attack_fired.emit(damage)
