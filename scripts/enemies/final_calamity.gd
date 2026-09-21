extends "res://scripts/enemies/school_encounter_actor.gd"

signal theme_changed(school_id: StringName)

const CATALOG = preload("res://scripts/data/encounter_catalog.gd")
const FINAL_HEALTH := 1800
var _theme_definitions: Array = []
var _theme_index := 0


func configure_clear_order(clear_order: Array) -> bool:
	if not _theme_definitions.is_empty() or clear_order.size() != 4:
		return false
	var schools := CATALOG.build_school_encounters()
	var seen: Array[StringName] = []
	var candidates: Array = []
	for raw_id in clear_order:
		var school_id := StringName(raw_id)
		if not schools.has(school_id) or seen.has(school_id):
			return false
		seen.append(school_id)
		var candidate = CATALOG.actor_definition_for(schools[school_id].boss_id)
		if candidate == null:
			return false
		candidate.max_health = FINAL_HEALTH
		candidate.display_name = "최종 재앙"
		candidates.append(candidate)
	if not configure_definition(candidates[0]):
		return false
	_theme_definitions = candidates
	pattern_controller.configure(definition.pattern_definitions, 0.2)
	return true


func theme_school_id() -> StringName:
	return definition.school_id if definition != null else &""


func _physics_process(delta: float) -> void:
	if not _dead and not _theme_definitions.is_empty() and pattern_state() == &"chase" \
		and _proxy_hazards.is_empty() and not _has_live_pattern_projectile():
		var next_index := clampi(int((1.0 - float(health) / float(FINAL_HEALTH)) * 4.0), 0, 3)
		if next_index > _theme_index:
			if configure_definition(_theme_definitions[next_index]):
				_theme_index = next_index
				pattern_controller.configure(definition.pattern_definitions, 0.2)
				_clear_runtime_effects()
				theme_changed.emit(theme_school_id())
	super._physics_process(delta)


func _has_live_pattern_projectile() -> bool:
	for child in get_children():
		if child.has_meta(PATTERN_PROJECTILE_META) and not child.is_queued_for_deletion():
			return true
	return false
