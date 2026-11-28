extends Node2D

## Balance tools — off for normal play. Flip in the inspector or ProjectSettings.
@export var enable_dummy_player := false
@export var dummy_max_matches := 100

var _battle_ended := false

@onready var _board: Board = $Board
@onready var _selector: Selector = $Selector
@onready var _combat: Combat = $Combat
@onready var _effect_resolver: EffectResolver = $EffectResolver
@onready var _hud: HUD = $HUD

var _dummy: DummyPlayer


func _ready() -> void:
	_selector.setup(_board)
	_board.setup(_selector)
	_hud.setup(_combat, _selector)
	_combat.hp_changed.connect(_on_hp_changed)
	_effect_resolver.setup(_combat, _selector)
	_effect_resolver.effect_applied.connect(_on_effect_applied)
	_board.pair_matched.connect(_effect_resolver.apply)
	_board.pair_matched.connect(_on_pair_matched_logged)
	_board.color_matched.connect(_on_color_matched)
	_board.icon_only_matched.connect(_on_icon_only_matched)
	_board.pair_mismatched.connect(_on_pair_mismatched)
	_combat.player_defeated.connect(_on_player_defeated)
	_combat.all_enemies_defeated.connect(_on_all_enemies_defeated)
	_combat.bonus_attack_fired.connect(_on_bonus_attack_fired)
	_on_hp_changed()

	DebugLog.reset_battle()
	DebugLog.info("battle", "start — enemies: %s" % _enemy_snapshot())

	var dummy_on := enable_dummy_player
	if ProjectSettings.has_setting("memory_arena/dummy_player"):
		dummy_on = dummy_on or bool(ProjectSettings.get_setting("memory_arena/dummy_player"))
	if dummy_on:
		_dummy = DummyPlayer.new()
		_dummy.name = "DummyPlayer"
		_dummy.max_matches = dummy_max_matches
		add_child(_dummy)
		_dummy.setup(_board, _combat, true)
		## Human input still works; dummy also acts. Block selector keys if you want pure bot later.


func _on_hp_changed() -> void:
	_hud.refresh_hp()


func _on_player_defeated() -> void:
	handle_battle_ended("You Lose", false)


func _on_all_enemies_defeated() -> void:
	handle_battle_ended("You Win Hurray Hurray", true)


func handle_battle_ended(message: String, won: bool) -> void:
	if _battle_ended:
		return

	_board.set_battle_ended(true)
	_combat.set_battle_ended(true)
	_battle_ended = true
	_hud.show_battle_end(message)
	DebugLog.battle_ended(won, _combat.player_hp, _enemy_snapshot())
	if _dummy != null:
		_dummy.request_restart_after_battle()


func _input(event: InputEvent) -> void:
	if not _battle_ended:
		return
	if event.is_echo():
		return
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_effect_applied(description: String) -> void:
	_hud.set_last_effect(description)


func _on_pair_matched_logged(effect_id: int) -> void:
	DebugLog.record_true_pair(effect_id)


func _on_color_matched(_color_id: int) -> void:
	DebugLog.record_color_match(_color_id)
	_combat.hurry_next_attack()
	_hud.set_last_effect("Color match +%.0f mana" % Combat.MANA_PER_COLOR_MATCH)
	_combat.add_mana(Combat.MANA_PER_COLOR_MATCH)
	_hud.update_mana(_combat.mana, Combat.MANA_MAX)


func _on_icon_only_matched() -> void:
	DebugLog.record_icon_only()


func _on_pair_mismatched() -> void:
	DebugLog.record_miss()


func _on_bonus_attack_fired(damage: int) -> void:
	_hud.set_last_effect("Bonus attack: %d damage" % damage)


func _enemy_snapshot() -> String:
	var parts: PackedStringArray = []
	for enemy in _combat.enemies:
		parts.append("%s %d/%d" % [enemy.display_name, enemy.hp, enemy.max_hp])
	return ", ".join(parts)
