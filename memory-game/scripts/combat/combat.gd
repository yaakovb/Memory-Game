class_name Combat
extends Node

signal hp_changed(player_hp: int, enemy_hp: int)
signal player_defeated
signal enemy_defeated

@export var player_max_hp := 20
@export var enemy_max_hp := 30
@export var enemy_damage := 2
@export var enemy_interval := 4.0

var player_hp: int
var enemy_hp: int
var _timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_hp = player_max_hp
	enemy_hp = enemy_max_hp
	hp_changed.emit(player_hp, enemy_hp)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_timer += delta
	if _timer >= enemy_interval:
		_timer = 0.0
		damage_player(enemy_damage)
	
	
func damage_player(amount: int) -> void:
	player_hp = maxi(player_hp - amount, 0)
	hp_changed.emit(player_hp, enemy_hp)
	if player_hp <= 0:
		player_defeated.emit()
		return

func damage_enemy(amount: int) -> void:
	enemy_hp = maxi(enemy_hp - amount, 0)
	hp_changed.emit(player_hp, enemy_hp)
	if enemy_hp <= 0:
		enemy_defeated.emit()
		return
	
func heal_player(amount: int) -> void:
	player_hp = mini(player_hp + amount, player_max_hp)
	hp_changed.emit(player_hp, enemy_hp)

func heal_enemy(amount: int) -> void:
	enemy_hp = mini(enemy_hp + amount, enemy_max_hp)
	hp_changed.emit(player_hp, enemy_hp)
