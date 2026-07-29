class_name Combat
extends Node

signal hp_changed(player_hp: int, enemy_hp: int)
signal player_defeated
signal enemy_defeated

@export var player_max_hp := 20
@export var enemy_max_hp := 30
@export var enemy_damage := 2
@export var enemy_interval := 4.0

const MAX_SLOW_STACKS := 3
const SLOW_DURATION := 10.0
const SLOW_PER_STACK := 0.25
const BASE_ATTACK_DAMAGE := 3
const MISMATCH_ATTACK_HURRY := 0.5

var player_hp: int
var enemy_hp: int
## Public — EffectResolver reads this when resolving attack matches.
var attack_bonus := 0
var _battle_ended := false

var _timer := 0.0
var _slow_stacks := 0
var _slow_timer := 0.0


func _ready() -> void:
	player_hp = player_max_hp
	enemy_hp = enemy_max_hp
	hp_changed.emit(player_hp, enemy_hp)


func _process(delta: float) -> void:
	if _battle_ended == true:
		return
	_timer += delta
	if _timer >= get_attack_interval():
		_timer = 0.0
		damage_player(enemy_damage)
		
	if _slow_timer > 0.0:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			_slow_stacks = 0


func damage_player(amount: int) -> void:
	player_hp = maxi(player_hp - amount, 0)
	hp_changed.emit(player_hp, enemy_hp)
	if player_hp <= 0:
		player_defeated.emit()


func damage_enemy() -> int:
	var amount = BASE_ATTACK_DAMAGE + attack_bonus
	enemy_hp = maxi(enemy_hp - amount, 0)
	hp_changed.emit(player_hp, enemy_hp)
	if enemy_hp <= 0:
		enemy_defeated.emit()
	return amount;


func heal_player(amount: int) -> void:
	player_hp = mini(player_hp + amount, player_max_hp)
	hp_changed.emit(player_hp, enemy_hp)


func heal_enemy(amount: int) -> void:
	enemy_hp = mini(enemy_hp + amount, enemy_max_hp)
	hp_changed.emit(player_hp, enemy_hp)


func add_attack_bonus(amount: int) -> void:
	attack_bonus += amount

func apply_slow() -> void:
	_slow_stacks = mini(_slow_stacks + 1, MAX_SLOW_STACKS)
	_slow_timer = SLOW_DURATION

func get_attack_interval() -> float:
	return enemy_interval*(1.0 + _slow_stacks*SLOW_PER_STACK)

func get_slow_stacks() -> int:
	return _slow_stacks

func get_attack_progress() -> float:
	var interval = get_attack_interval()
	if interval <= 0.0:
		return 0.0
	return clampf(_timer / interval, 0.0, 1.0)

func set_battle_ended(value: bool) -> void:
	_battle_ended = value

func get_player_attack_damage() -> int:
	return BASE_ATTACK_DAMAGE + attack_bonus


func hurry_next_attack(amount: float = MISMATCH_ATTACK_HURRY) -> void:
	if _battle_ended:
		return
	_timer = minf(_timer + amount, get_attack_interval())
