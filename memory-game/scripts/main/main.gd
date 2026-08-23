extends Node2D

var _battle_ended := false

@onready var _board: Board = $Board
@onready var _selector: Selector = $Selector
@onready var _combat: Combat = $Combat
@onready var _effect_resolver: EffectResolver = $EffectResolver
@onready var _hud: HUD = $HUD


func _ready() -> void:
	_selector.setup(_board)
	_board.setup(_selector)
	_hud.setup(_combat, _selector)
	_combat.hp_changed.connect(_on_hp_changed)
	_effect_resolver.setup(_combat, _selector)
	_effect_resolver.effect_applied.connect(_on_effect_applied)
	_board.pair_matched.connect(_effect_resolver.apply)
	_board.color_matched.connect(_on_color_matched)
	_combat.player_defeated.connect(_on_player_defeated)
	_combat.all_enemies_defeated.connect(_on_all_enemies_defeated)
	_combat.enemy_defeated.connect(_on_enemy_defeated)
	_combat.bonus_attack_fired.connect(_on_bonus_attack_fired)
	_combat.money_changed.connect(_hud.update_money)
	_on_hp_changed()
	_hud.update_money(_combat.money)


func _on_hp_changed() -> void:
	_hud.refresh_hp()


func _on_player_defeated() -> void:
	handle_battle_ended("You Lose")


func _on_all_enemies_defeated() -> void:
	handle_battle_ended("You Win Hurray Hurray")


func _on_enemy_defeated(enemy: Enemy) -> void:
	_hud.set_last_effect("+%d (%s)" % [Combat.MONEY_PER_KILL, enemy.display_name])


func handle_battle_ended(message: String) -> void:
	if _battle_ended:
		return

	_board.set_battle_ended(true)
	_combat.set_battle_ended(true)
	_battle_ended = true
	_hud.show_battle_end(message)


func _input(event: InputEvent) -> void:
	if not _battle_ended:
		return
	if event.is_echo():
		return
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_effect_applied(description: String) -> void:
	_hud.set_last_effect(description)


func _on_color_matched(_color_id: int) -> void:
	_combat.hurry_next_attack()
	_hud.set_last_effect("Color match +%.0f mana" % Combat.MANA_PER_COLOR_MATCH)
	_combat.add_mana(Combat.MANA_PER_COLOR_MATCH)
	_hud.update_mana(_combat.mana, Combat.MANA_MAX)


func _on_bonus_attack_fired(damage: int) -> void:
	_hud.set_last_effect("Bonus attack: %d damage" % damage)
