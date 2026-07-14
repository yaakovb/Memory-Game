class_name EffectResolver
extends Node

const ATTACK_DAMAGE := 3
const HEAL_AMOUNT := 4
const ATTACK_BONUS := 1

var _combat: Combat
var _selector: Selector

func setup(combat: Combat, selector: Selector) -> void:
	_combat = combat
	_selector = selector


func apply(pair_id: int) -> void:
	match pair_id:
		0, 1, 2:
			_combat.damage_enemy(ATTACK_DAMAGE + _combat.attack_bonus)
		3, 4:
			_combat.heal_player(HEAL_AMOUNT)
		5:
			_combat.apply_slow()
		6:
			_selector.apply_speed()
		7:
			_combat.add_attack_bonus(ATTACK_BONUS)
		_:
			pass
