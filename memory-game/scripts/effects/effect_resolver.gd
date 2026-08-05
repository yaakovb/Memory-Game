class_name EffectResolver
extends Node

const HEAL_AMOUNT := 4
const ATTACK_BONUS := 1

signal effect_applied(description: String)

var _combat: Combat
var _selector: Selector


func setup(combat: Combat, selector: Selector) -> void:
	_combat = combat
	_selector = selector


func apply(pair_id: int) -> void:
	match pair_id:
		0:
			var damage := _combat.get_player_attack_damage()
			_combat.damage_enemy(damage)
			effect_applied.emit("Attack %d" % damage)
		1:
			_combat.heal_player(HEAL_AMOUNT)
			effect_applied.emit("Heal +%d" % HEAL_AMOUNT)
		2:
			_combat.apply_slow()
			effect_applied.emit("Slow")
		3:
			_selector.apply_speed()
			effect_applied.emit("Speed")
		4:
			_combat.add_attack_bonus(ATTACK_BONUS)
			effect_applied.emit("Upgrade +%d" % ATTACK_BONUS)
