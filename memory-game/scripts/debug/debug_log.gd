extends Node
## Autoload: survives scene reloads so batch runs keep aggregate stats.
## Toggle with ProjectSettings `memory_arena/debug_log` (default true in editor).

signal line_logged(text: String)

var enabled := true

## Per-battle counters (reset each match).
var battle: Dictionary = {}

## Across reloads / dummy batch.
var session_wins := 0
var session_losses := 0
var session_matches := 0


func _ready() -> void:
	if ProjectSettings.has_setting("memory_arena/debug_log"):
		enabled = bool(ProjectSettings.get_setting("memory_arena/debug_log"))
	reset_battle()


func reset_battle() -> void:
	battle = {
		"true_pairs": 0,
		"color_matches": 0,
		"icon_only": 0,
		"misses": 0,
		"damage_dealt": 0,
		"damage_taken": 0,
		"heals": 0,
		"bonus_attacks": 0,
		"enemies_killed": 0,
		"effects": {}, # effect_id -> count
	}


func info(category: String, message: String) -> void:
	if not enabled:
		return
	var text := "[%s] %s" % [category, message]
	print(text)
	line_logged.emit(text)


func event(name: String, detail: String = "") -> void:
	if detail.is_empty():
		info("event", name)
	else:
		info("event", "%s — %s" % [name, detail])


func record_true_pair(effect_id: int) -> void:
	battle["true_pairs"] = int(battle["true_pairs"]) + 1
	var effects: Dictionary = battle["effects"]
	effects[effect_id] = int(effects.get(effect_id, 0)) + 1
	event("true_pair", "effect=%d" % effect_id)


func record_color_match(color_id: int) -> void:
	battle["color_matches"] = int(battle["color_matches"]) + 1
	event("color_match", "color=%d" % color_id)


func record_icon_only() -> void:
	battle["icon_only"] = int(battle["icon_only"]) + 1
	event("icon_only")


func record_miss() -> void:
	battle["misses"] = int(battle["misses"]) + 1
	event("miss")


func record_damage_dealt(amount: int) -> void:
	battle["damage_dealt"] = int(battle["damage_dealt"]) + amount


func record_damage_taken(amount: int) -> void:
	battle["damage_taken"] = int(battle["damage_taken"]) + amount
	event("player_hurt", "-%d HP" % amount)


func record_heal(amount: int) -> void:
	battle["heals"] = int(battle["heals"]) + amount


func record_bonus_attack(damage: int) -> void:
	battle["bonus_attacks"] = int(battle["bonus_attacks"]) + 1
	event("bonus_attack", "%d damage" % damage)


func record_enemy_killed(enemy_name: String) -> void:
	battle["enemies_killed"] = int(battle["enemies_killed"]) + 1
	event("enemy_killed", enemy_name)


func battle_ended(won: bool, player_hp: int, enemy_snapshot: String) -> void:
	session_matches += 1
	if won:
		session_wins += 1
	else:
		session_losses += 1

	var outcome := "WIN" if won else "LOSS"
	info("battle", "── %s ── player_hp=%d | %s" % [outcome, player_hp, enemy_snapshot])
	info("battle", "pairs=%d color=%d icon=%d miss=%d | dealt=%d taken=%d heals=%d bonus=%d" % [
		battle["true_pairs"],
		battle["color_matches"],
		battle["icon_only"],
		battle["misses"],
		battle["damage_dealt"],
		battle["damage_taken"],
		battle["heals"],
		battle["bonus_attacks"],
	])
	info("session", "matches=%d wins=%d losses=%d (%.0f%% win)" % [
		session_matches,
		session_wins,
		session_losses,
		(100.0 * float(session_wins) / float(session_matches)) if session_matches > 0 else 0.0,
	])
