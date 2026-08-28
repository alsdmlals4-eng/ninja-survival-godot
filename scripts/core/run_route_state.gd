extends RefCounted
class_name RunRouteState

const SCHOOL_IDS: Array[StringName] = [
	&"bongma",
	&"cheonsul",
	&"guiin",
	&"heukyeong",
]

var _provisional_school_id: StringName = &""
var _active_school_id: StringName = &""
var _clear_order: Array[StringName] = []
var _stage_index: int = 1
var _final_binding_eligible: bool = false


func school_ids() -> Array[StringName]:
	return SCHOOL_IDS.duplicate()


func get_unvisited_schools() -> Array[StringName]:
	var result: Array[StringName] = []
	for school_id in SCHOOL_IDS:
		if not _clear_order.has(school_id):
			result.append(school_id)
	return result


func provisional_school_id() -> StringName:
	return _provisional_school_id


func active_school_id() -> StringName:
	return _active_school_id


func cleared_school_ids() -> Array[StringName]:
	return _clear_order.duplicate()


func clear_order() -> Array[StringName]:
	return _clear_order.duplicate()


func stage_index() -> int:
	return _stage_index


func is_final_binding_eligible() -> bool:
	return _final_binding_eligible


func is_school_unvisited(school_id: StringName) -> bool:
	return SCHOOL_IDS.has(school_id) and not _clear_order.has(school_id)


func is_school_cleared(school_id: StringName) -> bool:
	return SCHOOL_IDS.has(school_id) and _clear_order.has(school_id)


func set_provisional_next_school(school_id: StringName) -> bool:
	if _final_binding_eligible or _active_school_id != &"":
		return false
	if not is_school_unvisited(school_id):
		return false
	_provisional_school_id = school_id
	return true


func can_commit_provisional_next_school() -> bool:
	return not _final_binding_eligible \
		and _active_school_id == &"" \
		and _provisional_school_id != &"" \
		and is_school_unvisited(_provisional_school_id)


func commit_provisional_next_school() -> bool:
	if not can_commit_provisional_next_school():
		return false
	_active_school_id = _provisional_school_id
	_provisional_school_id = &""
	return true


func mark_active_school_cleared() -> bool:
	if _active_school_id == &"" or not SCHOOL_IDS.has(_active_school_id):
		return false
	if _clear_order.has(_active_school_id):
		return false

	_clear_order.append(_active_school_id)
	_active_school_id = &""
	_provisional_school_id = &""
	if _clear_order.size() >= SCHOOL_IDS.size():
		_final_binding_eligible = true
		_stage_index = SCHOOL_IDS.size()
	else:
		_stage_index = _clear_order.size() + 1
	return true


func get_route_snapshot() -> Dictionary:
	return {
		"school_ids": school_ids(),
		"unvisited_school_ids": get_unvisited_schools(),
		"provisional_school_id": _provisional_school_id,
		"active_school_id": _active_school_id,
		"cleared_school_ids": cleared_school_ids(),
		"clear_order": clear_order(),
		"stage_index": _stage_index,
		"final_binding_eligible": _final_binding_eligible,
	}


func can_restore_from_checkpoint(snapshot: Dictionary) -> bool:
	var restored_clears: Array[StringName] = []
	for raw_school_id in Array(snapshot.get("cleared_school_ids", [])):
		var school_id := StringName(raw_school_id)
		if not SCHOOL_IDS.has(school_id) or restored_clears.has(school_id):
			return false
		restored_clears.append(school_id)
	var restored_active := StringName(snapshot.get("active_school_id", &""))
	var restored_provisional := StringName(snapshot.get("provisional_school_id", &""))
	var restored_final_binding := bool(snapshot.get("final_binding_eligible", false))
	if restored_active != &"" and (not SCHOOL_IDS.has(restored_active) or restored_clears.has(restored_active)):
		return false
	if restored_provisional != &"" and (not SCHOOL_IDS.has(restored_provisional) or restored_clears.has(restored_provisional)):
		return false
	if restored_active != &"" and restored_provisional != &"":
		return false
	var expected_final_binding := restored_clears.size() == SCHOOL_IDS.size()
	if restored_final_binding != expected_final_binding:
		return false
	if expected_final_binding and (restored_active != &"" or restored_provisional != &""):
		return false
	var expected_stage_index := SCHOOL_IDS.size() if expected_final_binding else restored_clears.size() + 1
	return int(snapshot.get("stage_index", -1)) == expected_stage_index


func restore_from_checkpoint(snapshot: Dictionary) -> bool:
	if not can_restore_from_checkpoint(snapshot):
		return false
	var restored_clears: Array[StringName] = []
	for raw_school_id in Array(snapshot.get("cleared_school_ids", [])):
		var school_id := StringName(raw_school_id)
		restored_clears.append(school_id)
	var restored_active := StringName(snapshot.get("active_school_id", &""))
	var restored_provisional := StringName(snapshot.get("provisional_school_id", &""))
	var expected_final_binding := restored_clears.size() == SCHOOL_IDS.size()
	var expected_stage_index := SCHOOL_IDS.size() if expected_final_binding else restored_clears.size() + 1
	_clear_order = restored_clears
	_active_school_id = restored_active
	_provisional_school_id = restored_provisional
	_stage_index = expected_stage_index
	_final_binding_eligible = expected_final_binding
	return true
