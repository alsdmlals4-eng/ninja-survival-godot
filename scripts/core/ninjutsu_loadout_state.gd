# 선택 유파 인법서의 런 단위 대기·확정 상태를 소유한다.
extends Node
class_name NinjutsuLoadoutState

const NINJUTSU_CATALOG_SCRIPT = preload("res://scripts/data/ninjutsu_catalog.gd")

signal loadout_changed

var _origin_school_id: StringName = &""
var _active_spell_ids: Array[StringName] = []
var _pending_spell_ids: Array[StringName] = []


func activate_starter(school_id: StringName) -> bool:
	if _origin_school_id != &"" or school_id == &"":
		return false
	var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_lane(school_id, &"starter")
	if definition == null or definition.school_id != school_id:
		return false
	_origin_school_id = school_id
	_active_spell_ids.append(definition.ninjutsu_id)
	loadout_changed.emit()
	return true


func can_stage_scroll(school_id: StringName, lane: StringName) -> bool:
	if _origin_school_id == &"" or school_id != _origin_school_id:
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
	return {
		"origin_school_id": _origin_school_id,
		"active_spell_ids": active_spell_ids(),
		"pending_spell_ids": pending_spell_ids(),
	}
