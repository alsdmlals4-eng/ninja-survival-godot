extends RefCounted
class_name TraditionAccessState

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


func initialize(starting_school_id: StringName) -> bool:
	if _initialized or not SCHOOL_IDS.has(starting_school_id):
		return false
	_initialized = true
	_starting_school_id = starting_school_id
	_open_school_ids = [starting_school_id]
	return true


func stabilize_school(school_id: StringName) -> bool:
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
	return UNIVERSAL_ITEMS.duplicate()


func school_package_item_ids(school_id: StringName) -> Array[StringName]:
	if not SCHOOL_IDS.has(school_id):
		return []
	var result: Array[StringName] = []
	for item_id in SCHOOL_PACKAGES[school_id]:
		result.append(StringName(item_id))
	return result


func eligible_item_ids() -> Array[StringName]:
	if not _initialized:
		return []
	var result: Array[StringName] = []
	var seen := {}
	_append_unique(result, seen, UNIVERSAL_ITEMS)
	for school_id in SCHOOL_IDS:
		if _open_school_ids.has(school_id):
			_append_unique(result, seen, SCHOOL_PACKAGES[school_id])
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
	return {
		"initialized": _initialized,
		"starting_school_id": _starting_school_id,
		"open_school_ids": open_school_ids(),
		"eligible_item_ids": eligible_item_ids(),
		"eligible_lane_pools": eligible_lane_pools(),
	}


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
