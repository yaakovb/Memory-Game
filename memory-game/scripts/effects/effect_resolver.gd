class_name EffectResolver
extends Node

const ATTACK_DAMAGE := 3
const HEAL_AMOUNT := 4

var _combat: Combat

func setup(combat: Combat) -> void:
	_combat = combat

func apply(pair_id: int) -> void:
	match pair_id:
		0, 1, 2:
			_combat.damage_enemy(ATTACK_DAMAGE)
		3, 4:
			_combat.heal_player(HEAL_AMOUNT)
		_:
			pass  # Step 6
