extends RefCounted
class_name TraditionAccessState

const SELECTED_CATALOG = preload("res://scripts/data/selected_backpack_catalog.gd")
const EQUIPMENT_STATE = preload("res://scripts/core/equipment_loadout_state.gd")

const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const UNIVERSAL_ITEMS: Array[StringName] = [
	&"fortune_talisman",
	&"ninjutsu_training",
	&"regeneration_scroll",
	&"ultimate_treatise",
	&"school_emblem",
	&"forbidden_talisman",
	&"bomb",
]
const SCHOOL_PACKAGES := {
	&"bongma": [&"enlightenment", &"barrier_art", &"greater_summoning_circle"],
	&"cheonsul": [&"water_style", &"lightning_style", &"fire_style"],
	&"guiin": [&"taijutsu_training", &"protection_talisman", &"katana"],
	&"heukyeong": [&"shuriken", &"stealth_art", &"poison_needles"],
}

var _initialized: bool = false
var _starting_school_id: StringName = &""
var _open_school_ids: Array[StringName] = []
var _selected_mode := false
var _stabilized_school_ids: Array[StringName] = []
var _unlocked_ninjutsu: Array[StringName] = []
var _trace_decisions: Dictionary = {}


func initialize_selected(starting_school_id: StringName) -> bool:
	if not initialize(starting_school_id):
		return false
	_selected_mode = true
	_unlocked_ninjutsu = [starting_school_id]
	return true


func unlocked_ninjutsu_school_ids() -> Array[StringName]:
	return _unlocked_ninjutsu.duplicate()


func copy_value():
	var copy = get_script().new()
	copy._initialized = _initialized
	copy._starting_school_id = _starting_school_id
	copy._open_school_ids = _open_school_ids.duplicate()
	copy._selected_mode = _selected_mode
	copy._stabilized_school_ids = _stabilized_school_ids.duplicate()
	copy._unlocked_ninjutsu = _unlocked_ninjutsu.duplicate()
	copy._trace_decisions = _trace_decisions.duplicate(true)
	return copy


# Operates on preparation candidates. The profile transaction persists and adopts
# access + equipment together; this method never touches files or combat gear.
func decide_trace(school_id: StringName, choice: StringName, equipment, slot: StringName, expected_revision: int) -> bool:
	if not _selected_mode or not _initialized or not _stabilized_school_ids.has(school_id) or _trace_decisions.has(school_id):
		return false
	if not (equipment is EQUIPMENT_STATE) or equipment.get_snapshot().revision != expected_revision:
		return false
	if school_id != _starting_school_id and _unlocked_ninjutsu.has(school_id):
		return false
	var record := {"choice": str(choice)}
	if choice == &"absorb":
		if school_id == _starting_school_id or slot != &"":
			return false
		_unlocked_ninjutsu.append(school_id)
	elif choice == &"enhance":
		if not EQUIPMENT_STATE.SLOTS.has(str(slot)):
			return false
		var before: Dictionary = equipment.get_snapshot()
		if not equipment.imbue_equipped(school_id, slot):
			return false
		record["equipment_instance"] = before.equipped_slots[str(slot)]
		record["imbuement"] = str(school_id)
	else:
		return false
	_trace_decisions[school_id] = record
	return true


func restore_selected_snapshot(snapshot: Dictionary) -> bool:
	if not _is_text(snapshot.get("access_contract")) or str(snapshot.access_contract) != "selected-traces-v2":
		return false
	if not (snapshot.get("initialized") is bool) or not snapshot.initialized:
		return false
	if not _is_text(snapshot.get("starting_school_id")):
		return false
	var candidate = get_script().new()
	if not candidate.initialize_selected(StringName(snapshot.starting_school_id)):
		return false
	var stabilized = snapshot.get("stabilized_school_ids")
	if not (stabilized is Array):
		return false
	for school in stabilized:
		if not _is_text(school) or not candidate.stabilize_school(StringName(school)):
			return false
	var decisions = snapshot.get("trace_decisions")
	if not (decisions is Dictionary):
		return false
	for school in decisions:
		if not _is_text(school) or not candidate._stabilized_school_ids.has(StringName(school)):
			return false
		var record = decisions[school]
		if not (record is Dictionary) or not _is_text(record.get("choice")):
			return false
		if str(record.choice) == "absorb":
			if record.size() != 1 or StringName(school) == candidate._starting_school_id:
				return false
			candidate._unlocked_ninjutsu.append(StringName(school))
		elif str(record.choice) == "enhance":
			if record.size() != 3 or not _is_text(record.get("equipment_instance")):
				return false
			var instance := str(record.equipment_instance)
			if not instance.begins_with("gear_") or EQUIPMENT_STATE.CATALOG.definition(StringName(instance.trim_prefix("gear_"))).is_empty():
				return false
			if record.has("imbuement"):
				if not _is_text(record.imbuement) or str(record.imbuement) != str(school): return false
			else:
				# Preserve old numeric trace receipts; never retroactively mint powers.
				var rank = record.get("rank")
				if not (rank is int or rank is float): return false
				if not is_finite(float(rank)) or float(rank) != floor(float(rank)) or rank < 1 or rank > 4: return false
		else:
			return false
		candidate._trace_decisions[StringName(school)] = record.duplicate(true)
	if not _same_school_set(snapshot.get("open_school_ids"), candidate._open_school_ids):
		return false
	if not _same_school_set(snapshot.get("unlocked_ninjutsu_school_ids"), candidate._unlocked_ninjutsu):
		return false
	_initialized = true
	_selected_mode = true
	_starting_school_id = candidate._starting_school_id
	_open_school_ids = candidate._open_school_ids
	_stabilized_school_ids = candidate._stabilized_school_ids
	_unlocked_ninjutsu = candidate._unlocked_ninjutsu
	_trace_decisions = candidate._trace_decisions
	return true


func _is_text(value) -> bool:
	return value is String or value is StringName


func _same_school_set(raw, expected: Array[StringName]) -> bool:
	if not (raw is Array) or raw.size() != expected.size():
		return false
	var seen := {}
	for school in raw:
		if not _is_text(school) or not expected.has(StringName(school)) or seen.has(StringName(school)):
			return false
		seen[StringName(school)] = true
	return true


func initialize(starting_school_id: StringName) -> bool:
	if _initialized or not SCHOOL_IDS.has(starting_school_id):
		return false
	_initialized = true
	_starting_school_id = starting_school_id
	_open_school_ids = [starting_school_id]
	return true


func stabilize_school(school_id: StringName) -> bool:
	if _selected_mode:
		if not _initialized or not SCHOOL_IDS.has(school_id) or _stabilized_school_ids.has(school_id):
			return false
		_stabilized_school_ids.append(school_id)
		if not _open_school_ids.has(school_id):
			_open_school_ids.append(school_id)
		return true
	if not _initialized or not SCHOOL_IDS.has(school_id) or _open_school_ids.has(school_id):
		return false
	_open_school_ids.append(school_id)
	return true


func is_initialized() -> bool:
	return _initialized


func starting_school_id() -> StringName:
	return _starting_school_id


func is_school_package_open(school_id: StringName) -> bool:
	return _initialized and _open_school_ids.has(school_id)


func open_school_ids() -> Array[StringName]:
	return _open_school_ids.duplicate()


func universal_item_ids() -> Array[StringName]:
	return _mapped_item_ids(UNIVERSAL_ITEMS)


func school_package_item_ids(school_id: StringName) -> Array[StringName]:
	if not SCHOOL_IDS.has(school_id):
		return []
	return _mapped_item_ids(SCHOOL_PACKAGES[school_id])


func _mapped_item_ids(source: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for id in source:
		result.append(SELECTED_CATALOG.REPLACEMENTS.get(id, id) if _selected_mode else id)
	return result


func eligible_item_ids() -> Array[StringName]:
	if not _initialized:
		return []
	var result: Array[StringName] = []
	var seen := {}
	_append_unique(result, seen, universal_item_ids())
	for school_id in SCHOOL_IDS:
		if _open_school_ids.has(school_id):
			_append_unique(result, seen, school_package_item_ids(school_id))
	return result


func eligible_lane_pools() -> Array[Dictionary]:
	if not _initialized:
		return []
	var lanes: Array[Dictionary] = []
	lanes.append({"lane_id": &"universal", "item_ids": universal_item_ids()})
	for school_id in SCHOOL_IDS:
		if _open_school_ids.has(school_id):
			lanes.append({
				"lane_id": StringName("school_%s" % str(school_id)),
				"item_ids": school_package_item_ids(school_id),
			})
	return _deep_copy_lanes(lanes)


func get_snapshot() -> Dictionary:
	var snapshot := {
		"initialized": _initialized,
		"starting_school_id": _starting_school_id,
		"open_school_ids": open_school_ids(),
		"eligible_item_ids": eligible_item_ids(),
		"eligible_lane_pools": eligible_lane_pools(),
	}
	if _selected_mode:
		snapshot["access_contract"] = "selected-traces-v2"
		snapshot["stabilized_school_ids"] = _stabilized_school_ids.duplicate()
		snapshot["unlocked_ninjutsu_school_ids"] = unlocked_ninjutsu_school_ids()
		snapshot["trace_decisions"] = _trace_decisions.duplicate(true)
	return snapshot


func _append_unique(target: Array[StringName], seen: Dictionary, source) -> void:
	for raw_id in source:
		var item_id := StringName(raw_id)
		if not seen.has(item_id):
			seen[item_id] = true
			target.append(item_id)


func _deep_copy_lanes(source: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for lane in source:
		var item_ids: Array[StringName] = []
		for raw_id in Array(lane.get("item_ids", [])):
			item_ids.append(StringName(raw_id))
		result.append({
			"lane_id": StringName(lane.get("lane_id", &"")),
			"item_ids": item_ids,
		})
	return result
