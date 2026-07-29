class_name EffectResolver
extends Node

const HEAL_AMOUNT := 4
const ATTACK_BONUS := 1

var _combat: Combat
var _selector: Selector

signal effect_applied(description: String)

func setup(combat: Combat, selector: Selector) -> void:
	_combat = combat
	_selector = selector


func apply(pair_id: int) -> void:
	match pair_id:
		0, 1, 2:
			var damage = _combat.damage_enemy()
			effect_applied.emit("Attack - %d" % damage)
		3, 4:
			_combat.heal_player(HEAL_AMOUNT)
			effect_applied.emit("Heal - %d" % HEAL_AMOUNT)
		5:
			_combat.apply_slow()
			effect_applied.emit("Slow")
		6:
			_selector.apply_speed()
			effect_applied.emit("Speed")
		7:
			_combat.add_attack_bonus(ATTACK_BONUS)
			effect_applied.emit("Upgrade +%d" % ATTACK_BONUS)
		_:
			pass
