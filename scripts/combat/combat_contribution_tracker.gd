extends Node
class_name CombatContributionTracker

const AXIS_PRIORITY := [&"damage", &"healing", &"defense", &"status", &"combo"]
const AXIS_HINTS := {
	&"damage": "현재 화력을 유지할 피해/유파 강화가 잘 맞습니다",
	&"healing": "회복 기여가 실제로 나오고 있습니다. 회복 효율을 유지할 선택이 잘 맞습니다",
	&"defense": "생존 투자 효율이 실제로 나오고 있습니다",
	&"status": "상태·반응 빈도 또는 효과를 키우는 선택이 잘 맞습니다",
	&"combo": "이동·공격 주기를 유지해 콤보 흐름을 강화할 수 있습니다",
}

var damage: int = 0
var healing: int = 0
var defense: int = 0
var status_events: int = 0
var kills: int = 0
var max_combo: int = 0

var _base_reward_count: int = 0
var _base_gold: int = 0
var _snapshot: Dictionary = {}
var _frozen: bool = false


func reset_segment(base_reward_count: int, base_gold: int) -> void:
	damage = 0
	healing = 0
	defense = 0
	status_events = 0
	kills = 0
	max_combo = 0
	_base_reward_count = maxi(base_reward_count, 0)
	_base_gold = maxi(base_gold, 0)
	_snapshot.clear()
	_frozen = false


func record_damage(actual: int) -> void:
	if _frozen or actual <= 0:
		return
	damage += actual


func record_healing(actual: int) -> void:
	if _frozen or actual <= 0:
		return
	healing += actual


func record_defense(prevented: int) -> void:
	if _frozen or prevented <= 0:
		return
	defense += prevented


func record_status_event(count: int = 1) -> void:
	if _frozen or count <= 0:
		return
	status_events += count


func record_kill(current_combo: int) -> void:
	if _frozen:
		return
	kills += 1
	max_combo = maxi(max_combo, maxi(current_combo, 0))


func freeze_snapshot(
	current_reward_count: int,
	current_gold: int,
	build_state: RunBuildState = null
) -> Dictionary:
	if _frozen:
		return get_snapshot()

	_snapshot = {
		"damage": damage,
		"healing": healing,
		"defense": defense,
		"status_events": status_events,
		"kills": kills,
		"max_combo": max_combo,
		"reward_orbs": maxi(current_reward_count - _base_reward_count, 0),
		"gold_earned": maxi(current_gold - _base_gold, 0),
		"economy_receipts": [] if build_state == null else build_state.get_economy_receipts(),
		"growth_hints": _build_growth_hints(build_state),
	}
	_frozen = true
	return get_snapshot()


func get_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func _build_growth_hints(build_state: RunBuildState = null) -> Array[String]:
	var scores := {
		&"damage": float(damage) / 25.0,
		&"healing": float(healing) / 10.0,
		&"defense": float(defense) / 10.0,
		&"status": float(status_events) * 2.0,
		&"combo": float(max_combo),
	}
	var primary := _highest_axis(scores, &"")
	if primary == &"" or float(scores[primary]) <= 0.0:
		return []

	var hints: Array[String] = [str(AXIS_HINTS[primary])]
	var second := _highest_axis(scores, primary)
	if second != &"":
		var primary_score := float(scores[primary])
		var second_score := float(scores[second])
		if second_score >= 1.0 and second_score >= primary_score * 0.5:
			hints.append(str(AXIS_HINTS[second]))
			return hints

	var synergy := _build_synergy_hint(primary, build_state)
	if not synergy.is_empty():
		hints.append(synergy)
	return hints


func _highest_axis(scores: Dictionary, excluded: StringName) -> StringName:
	var best: StringName = &""
	var best_score := -1.0
	for axis in AXIS_PRIORITY:
		if axis == excluded:
			continue
		var score := float(scores.get(axis, 0.0))
		if score > best_score:
			best = axis
			best_score = score
	return best


func _build_synergy_hint(primary: StringName, build_state: RunBuildState) -> String:
	if build_state == null:
		return ""
	var modifiers = build_state.get_modifiers()
	match primary:
		&"damage":
			if modifiers.school_damage_pct > 0.0 or modifiers.ultimate_power_pct > 0.0 or modifiers.cheonsul_reaction_damage_pct > 0.0 or modifiers.heukyeong_marked_crit_bonus > 0.0 or modifiers.bongma_familiar_interval_pct < 0.0 or modifiers.guiin_melee_radius_pct > 0.0:
				return "보유한 피해 강화가 현재 주력 기여와 시너지를 냅니다"
		&"healing":
			if modifiers.healing_pct > 0.0 or modifiers.rest_start_heal_pct > 0.0:
				return "보유한 회복 강화가 현재 회복 기여와 시너지를 냅니다"
		&"defense":
			if modifiers.damage_taken_pct < 0.0 or modifiers.evasion_chance > 0.0 or modifiers.max_health_flat > 0.0 or modifiers.max_health_pct > 0.0:
				return "보유한 생존 강화가 현재 방어 기여와 시너지를 냅니다"
		&"status":
			if modifiers.school_status_effect_pct > 0.0 or modifiers.cheonsul_reaction_damage_pct > 0.0 or modifiers.heukyeong_mark_duration_pct > 0.0 or modifiers.heukyeong_marked_crit_bonus > 0.0:
				return "보유한 상태·반응 강화가 현재 기여와 시너지를 냅니다"
		&"combo":
			if modifiers.move_speed_pct > 0.0 or modifiers.bongma_familiar_interval_pct < 0.0 or modifiers.guiin_melee_radius_pct > 0.0:
				return "보유한 이동·공격 주기 강화가 콤보 유지와 시너지를 냅니다"
	return ""
