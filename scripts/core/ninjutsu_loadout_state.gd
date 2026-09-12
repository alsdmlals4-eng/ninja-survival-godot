# 선택 유파 인법서의 런 단위 대기·확정 상태를 소유한다.
extends Node
class_name NinjutsuLoadoutState

const NINJUTSU_CATALOG_SCRIPT = preload("res://scripts/data/ninjutsu_catalog.gd")

signal loadout_changed

var _origin_school_id: StringName = &""
var _active_spell_ids: Array[StringName] = []
var _pending_spell_ids: Array[StringName] = []
var _draft_school: StringName = &""
var _draft_picks: Array[StringName] = []
var _draft_options: Array[StringName] = []
var _draft_rng := RandomNumberGenerator.new()
var _selectable_mode := false


func begin_start_draft(school_id: StringName, seed_value: int) -> bool:
	if _origin_school_id != &"" or _draft_school != &"" or not NINJUTSU_CATALOG_SCRIPT.SCHOOL_IDS.has(school_id):
		return false
	_draft_school = school_id
	_draft_rng.seed = seed_value
	_draw_start_options()
	return true


func start_draft_snapshot() -> Dictionary:
	return {"school_id": _draft_school, "picks": _draft_picks.duplicate(), "options": _draft_options.duplicate(), "complete": _draft_picks.size() == 2}


func choose_start_draft(spell_id: StringName) -> bool:
	if _origin_school_id != &"" or _draft_picks.size() >= 2 or not _draft_options.has(spell_id):
		return false
	_draft_picks.append(spell_id)
	_draft_options.clear()
	if _draft_picks.size() < 2:
		_draw_start_options()
	return true


func _draw_start_options() -> void:
	var candidates: Array[StringName] = []
	for definition in NINJUTSU_CATALOG_SCRIPT.build_definitions().values():
		if definition.school_id == _draft_school and not _draft_picks.has(definition.ninjutsu_id):
			candidates.append(definition.ninjutsu_id)
	candidates.sort()
	_draft_options.clear()
	for index in range(mini(3, candidates.size())):
		var picked := _draft_rng.randi_range(0, candidates.size() - 1)
		_draft_options.append(candidates[picked])
		candidates.remove_at(picked)


# The Workbench must supply IDs from a validated placement, not UI choices.
# Main/schema2 integration is gated until the full book/placement consumer exists.
func commit_drafted_start(placed_book_ids: Array) -> bool:
	if _origin_school_id != &"" or _draft_picks.size() != 2 or placed_book_ids.size() != 2:
		return false
	var ids: Array[StringName] = []
	for raw_id in placed_book_ids:
		if not (raw_id is String or raw_id is StringName):
			return false
		var id := StringName(raw_id)
		if not _draft_picks.has(id) or ids.has(id):
			return false
		ids.append(id)
	_origin_school_id = _draft_school
	_active_spell_ids = _draft_picks.duplicate()
	_selectable_mode = true
	loadout_changed.emit()
	return true


func commit_placed_ninjutsu(placed_book_ids: Array, unlocked_school_ids: Array) -> bool:
	if not _selectable_mode or placed_book_ids.size() > 4:
		return false
	var unlocked: Array[StringName] = []
	for raw_school in unlocked_school_ids:
		if not (raw_school is String or raw_school is StringName):
			return false
		var school := StringName(raw_school)
		if not NINJUTSU_CATALOG_SCRIPT.SCHOOL_IDS.has(school) or unlocked.has(school):
			return false
		unlocked.append(school)
	if not unlocked.has(_origin_school_id):
		return false
	var ids: Array[StringName] = []
	var foreign_count := 0
	for raw_id in placed_book_ids:
		if not (raw_id is String or raw_id is StringName):
			return false
		var id := StringName(raw_id)
		var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_id(id)
		if definition == null or ids.has(id) or not unlocked.has(definition.school_id):
			return false
		if definition.school_id != _origin_school_id:
			foreign_count += 1
		if foreign_count > 1:
			return false
		ids.append(id)
	_active_spell_ids = ids
	loadout_changed.emit()
	return true


func activate_starter(school_id: StringName) -> bool:
	if _origin_school_id != &"" or _draft_school != &"" or school_id == &"":
		return false
	var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_lane(school_id, &"starter")
	if definition == null or definition.school_id != school_id:
		return false
	_origin_school_id = school_id
	_active_spell_ids.append(definition.ninjutsu_id)
	loadout_changed.emit()
	return true


func can_stage_scroll(school_id: StringName, lane: StringName) -> bool:
	if _selectable_mode or _origin_school_id == &"" or school_id != _origin_school_id:
		return false
	if lane not in [&"elite_scroll", &"boss_scroll"]:
		return false
	var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_lane(school_id, lane)
	if definition == null or definition.school_id != school_id or definition.acquisition_lane != lane:
		return false
	return not _active_spell_ids.has(definition.ninjutsu_id) and not _pending_spell_ids.has(definition.ninjutsu_id)


func stage_scroll(school_id: StringName, lane: StringName) -> bool:
	if not can_stage_scroll(school_id, lane):
		return false
	var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_lane(school_id, lane)
	if definition == null:
		return false
	_pending_spell_ids.append(definition.ninjutsu_id)
	loadout_changed.emit()
	return true


func can_commit_pending() -> bool:
	if _selectable_mode:
		return false
	var seen: Dictionary = {}
	for spell_id in _pending_spell_ids:
		if seen.has(spell_id) or _active_spell_ids.has(spell_id):
			return false
		var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_id(spell_id)
		if definition == null or definition.school_id != _origin_school_id:
			return false
		if definition.acquisition_lane not in [&"elite_scroll", &"boss_scroll"]:
			return false
		seen[spell_id] = true
	return true


func commit_pending() -> bool:
	if not can_commit_pending():
		return false
	if _pending_spell_ids.is_empty():
		return true
	_active_spell_ids.append_array(_pending_spell_ids)
	_pending_spell_ids.clear()
	loadout_changed.emit()
	return true


func origin_school_id() -> StringName:
	return _origin_school_id


func active_spell_ids() -> Array[StringName]:
	return _active_spell_ids.duplicate()


func pending_spell_ids() -> Array[StringName]:
	return _pending_spell_ids.duplicate()


func get_snapshot() -> Dictionary:
	var snapshot := {
		"origin_school_id": _origin_school_id,
		"active_spell_ids": active_spell_ids(),
		"pending_spell_ids": pending_spell_ids(),
	}
	if _selectable_mode:
		snapshot["selection_contract"] = "selectable-v2"
		snapshot["draft_picks"] = _draft_picks.duplicate()
	return snapshot


func can_restore_from_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.has("selection_contract") or _selectable_mode or _draft_school != &"":
		return false
	var restored_origin := StringName(snapshot.get("origin_school_id", &""))
	var raw_active = snapshot.get("active_spell_ids", null)
	var raw_pending = snapshot.get("pending_spell_ids", null)
	if restored_origin == &"" or not (raw_active is Array) or not (raw_pending is Array):
		return false
	var starter_definition = NINJUTSU_CATALOG_SCRIPT.definition_for_lane(restored_origin, &"starter")
	if starter_definition == null:
		return false
	var restored_active := _validated_spell_ids(raw_active, restored_origin, false)
	if restored_active.is_empty() or restored_active[0] != starter_definition.ninjutsu_id:
		return false
	var restored_pending := _validated_spell_ids(raw_pending, restored_origin, true)
	if restored_pending.size() != Array(raw_pending).size():
		return false
	for spell_id in restored_pending:
		if restored_active.has(spell_id):
			return false
	return restored_active.size() == Array(raw_active).size()


func restore_from_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_from_snapshot(snapshot):
		return false
	_origin_school_id = StringName(snapshot.get("origin_school_id", &""))
	_active_spell_ids = _validated_spell_ids(snapshot.get("active_spell_ids", []), _origin_school_id, false)
	_pending_spell_ids = _validated_spell_ids(snapshot.get("pending_spell_ids", []), _origin_school_id, true)
	loadout_changed.emit()
	return true


func _validated_spell_ids(raw_spell_ids: Array, school_id: StringName, pending_only: bool) -> Array[StringName]:
	var validated: Array[StringName] = []
	for raw_spell_id in raw_spell_ids:
		if typeof(raw_spell_id) != TYPE_STRING and typeof(raw_spell_id) != TYPE_STRING_NAME:
			return []
		var spell_id := StringName(raw_spell_id)
		var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_id(spell_id)
		if spell_id == &"" or definition == null or definition.school_id != school_id or validated.has(spell_id):
			return []
		if pending_only:
			if definition.acquisition_lane not in [&"elite_scroll", &"boss_scroll"]:
				return []
		elif definition.acquisition_lane not in [&"starter", &"elite_scroll", &"boss_scroll"]:
			return []
		validated.append(spell_id)
	return validated
