extends Node
class_name RestRewardController

signal rewards_changed
signal transaction_failed(reason: StringName)

const ShopControllerScript = preload("res://scripts/core/shop_controller.gd")
const MVP4CatalogScript = preload("res://scripts/data/mvp4_catalog.gd")
const TraditionAccessStateScript = preload("res://scripts/core/tradition_access_state.gd")

const BOSS_REWARD_LANES: Array[StringName] = [
	&"current_build_continuity",
	&"newly_liberated_tradition",
	&"bridge_universal",
]

var _build_state: RunBuildState
var _session = null
var _item_defs: Dictionary = {}
var _bag_defs: Dictionary = {}
var _rng: RandomNumberGenerator
var _shop = null
var _access_state = null

var _segment_index: int = 0
var _selected_school_id: StringName = &""
var _newly_stabilized_school_id: StringName = &""
var _chest_tokens: int = 0
var _boss_reward_ids: Array[StringName] = []
var _boss_reward_lane_ids: Array[StringName] = []
var _last_chest_lane_ids: Array[StringName] = []
var _boss_reward_pending: bool = false


func configure(
	build_state: RunBuildState,
	session,
	item_defs: Dictionary,
	bag_defs: Dictionary,
	rng: RandomNumberGenerator,
	access_state = null
) -> void:
	_build_state = build_state
	_session = session
	_item_defs = item_defs.duplicate()
	_bag_defs = bag_defs.duplicate()
	_access_state = access_state
	if rng == null:
		_rng = RandomNumberGenerator.new()
		_rng.randomize()
	else:
		_rng = rng

	if _shop != null and is_instance_valid(_shop):
		remove_child(_shop)
		_shop.queue_free()
	_shop = ShopControllerScript.new()
	add_child(_shop)
	_shop.configure_spatial(_build_state, _session, _item_defs, _bag_defs, _rng)
	_shop.transaction_failed.connect(_on_shop_transaction_failed)


func begin_rest(
	segment_index: int,
	selected_school_id: StringName,
	chest_tokens: int,
	newly_stabilized_school_id: StringName = &""
) -> void:
	_segment_index = maxi(segment_index, 0)
	_selected_school_id = selected_school_id
	_chest_tokens = maxi(chest_tokens, 0)
	_last_chest_lane_ids.clear()
	_ensure_access_state(selected_school_id)
	_newly_stabilized_school_id = _resolve_newly_stabilized_school(newly_stabilized_school_id, selected_school_id)

	_boss_reward_ids = _roll_boss_rewards(selected_school_id, _newly_stabilized_school_id)
	_boss_reward_lane_ids.clear()
	if _boss_reward_ids.size() == 3:
		_boss_reward_lane_ids.append_array(BOSS_REWARD_LANES)
	# Boss reward is mandatory. A pool/configuration failure is unresolved work,
	# not permission to skip the reward gate. Only a successful choice clears it.
	_boss_reward_pending = true
	if _shop != null:
		_shop.set_spatial_offer_lanes(_eligible_lanes())
		_shop.begin_rest()
	if _boss_reward_ids.size() != 3:
		transaction_failed.emit(&"boss_reward_pool_unavailable")
	rewards_changed.emit()


func boss_reward_options() -> Array[StringName]:
	return _boss_reward_ids.duplicate()


func boss_reward_lane_ids() -> Array[StringName]:
	return _boss_reward_lane_ids.duplicate()


func choose_boss_reward(index: int) -> bool:
	if not _boss_reward_pending or index < 0 or index >= _boss_reward_ids.size():
		transaction_failed.emit(&"boss_reward_unavailable")
		return false
	if _session == null:
		transaction_failed.emit(&"session_unavailable")
		return false
	var item_id: StringName = _boss_reward_ids[index]
	if not _session._can_acquire_items_to_buffer([item_id]):
		transaction_failed.emit(&"buffer_capacity")
		return false
	var created: Array[int] = _session._acquire_items_to_buffer([item_id])
	if created.size() != 1:
		transaction_failed.emit(&"boss_reward_commit_failed")
		return false
	_boss_reward_pending = false
	rewards_changed.emit()
	return true


func chest_count() -> int:
	return _chest_tokens


func grant_chest_token(amount: int = 1) -> int:
	if amount <= 0:
		return 0
	_chest_tokens += amount
	rewards_changed.emit()
	return amount


func open_chest() -> bool:
	if _chest_tokens <= 0:
		transaction_failed.emit(&"chest_unavailable")
		return false
	if _session == null or _session.buffer_free_slots() < 2:
		transaction_failed.emit(&"buffer_capacity")
		return false
	var rolled: Dictionary = _draw_lane_first(_eligible_lanes(), 2)
	var item_ids: Array[StringName] = _string_name_array(rolled.get("item_ids", []))
	var lane_ids: Array[StringName] = _string_name_array(rolled.get("lane_ids", []))
	if item_ids.size() != 2 or lane_ids.size() != 2:
		transaction_failed.emit(&"chest_pool_unavailable")
		return false
	if not _session._can_acquire_items_to_buffer(item_ids):
		transaction_failed.emit(&"buffer_capacity")
		return false
	var created: Array[int] = _session._acquire_items_to_buffer(item_ids)
	if created.size() != 2:
		transaction_failed.emit(&"chest_commit_failed")
		return false
	_last_chest_lane_ids = lane_ids
	_chest_tokens -= 1
	rewards_changed.emit()
	return true


func last_chest_lane_ids() -> Array[StringName]:
	return _last_chest_lane_ids.duplicate()


func buy_shop_item(index: int) -> bool:
	if _shop == null:
		transaction_failed.emit(&"shop_unavailable")
		return false
	var success: bool = _shop.buy_offer(index)
	if success:
		rewards_changed.emit()
	return success


func buy_shop_bag() -> bool:
	if _shop == null:
		transaction_failed.emit(&"shop_unavailable")
		return false
	var success: bool = _shop.buy_bag_offer()
	if success:
		rewards_changed.emit()
	return success


func sell_item(instance_id: int) -> bool:
	if _shop == null:
		transaction_failed.emit(&"shop_unavailable")
		return false
	var success: bool = _shop.sell_item(instance_id)
	if success:
		rewards_changed.emit()
	return success


func reroll_shop() -> bool:
	if _shop == null:
		transaction_failed.emit(&"shop_unavailable")
		return false
	var success: bool = _shop.reroll()
	if success:
		rewards_changed.emit()
	return success


func has_pending_boss_reward() -> bool:
	return _boss_reward_pending


func shop_item_options() -> Array[StringName]:
	if _shop == null:
		return []
	return _shop.offer_ids.duplicate()


func shop_item_lane_ids() -> Array[StringName]:
	if _shop == null:
		return []
	return _shop.offer_lane_ids.duplicate()


func shop_bag_option() -> StringName:
	if _shop == null:
		return &""
	return _shop.bag_offer_id


func access_snapshot() -> Dictionary:
	if _access_state == null:
		return {}
	return _access_state.get_snapshot()


func _ensure_access_state(selected_school_id: StringName) -> void:
	if _access_state == null:
		_access_state = TraditionAccessStateScript.new()
	if not _access_state.is_initialized():
		_access_state.initialize(selected_school_id)


func _resolve_newly_stabilized_school(requested: StringName, fallback: StringName) -> StringName:
	if _access_state == null:
		return fallback
	if requested != &"":
		if not _access_state.is_school_package_open(requested):
			_access_state.stabilize_school(requested)
		if _access_state.is_school_package_open(requested):
			return requested
	if _access_state.is_school_package_open(fallback):
		return fallback
	return _access_state.starting_school_id()


func _roll_boss_rewards(selected_school_id: StringName, newly_stabilized_school_id: StringName) -> Array[StringName]:
	if _access_state == null or _rng == null:
		return []
	var continuity_pool: Array[StringName] = _filtered_pool(_access_state.school_package_item_ids(selected_school_id))
	var new_tradition_pool: Array[StringName] = _filtered_pool(_access_state.school_package_item_ids(newly_stabilized_school_id))
	var bridge_pool: Array[StringName] = _filtered_pool(_access_state.universal_item_ids())
	if continuity_pool.is_empty() or new_tradition_pool.is_empty() or bridge_pool.is_empty():
		return []

	var result: Array[StringName] = []
	var first: StringName = _draw_one_excluding(continuity_pool, result)
	if first == &"":
		return []
	result.append(first)
	var second: StringName = _draw_one_excluding(new_tradition_pool, result)
	if second == &"":
		return []
	result.append(second)
	var third: StringName = _draw_one_excluding(bridge_pool, result)
	if third == &"":
		return []
	result.append(third)
	return result


func _eligible_lanes() -> Array[Dictionary]:
	if _access_state == null:
		return []
	var result: Array[Dictionary] = []
	var canonical: Array[StringName] = MVP4CatalogScript.base_acquisition_item_ids()
	for lane in _access_state.eligible_lane_pools():
		var lane_id := StringName(lane.get("lane_id", &""))
		var item_ids: Array[StringName] = []
		var seen := {}
		for raw_id in Array(lane.get("item_ids", [])):
			var item_id := StringName(raw_id)
			if canonical.has(item_id) and _item_defs.get(item_id) != null and not seen.has(item_id):
				seen[item_id] = true
				item_ids.append(item_id)
		if lane_id != &"" and not item_ids.is_empty():
			result.append({"lane_id": lane_id, "item_ids": item_ids})
	return result


func _draw_lane_first(lanes: Array[Dictionary], count: int) -> Dictionary:
	var rolled_ids: Array[StringName] = []
	var rolled_lanes: Array[StringName] = []
	if _rng == null or count < 0 or _unique_item_count(lanes) < count:
		return {"item_ids": rolled_ids, "lane_ids": rolled_lanes}
	var working: Array[Dictionary] = _copy_lanes(lanes)
	for _i in range(count):
		working = _non_empty_lanes(working)
		if working.is_empty():
			return {"item_ids": [], "lane_ids": []}
		var lane_index: int = _rng.randi_range(0, working.size() - 1)
		var lane: Dictionary = working[lane_index]
		var pool: Array = lane["item_ids"]
		var item_index: int = _rng.randi_range(0, pool.size() - 1)
		var item_id := StringName(pool[item_index])
		rolled_ids.append(item_id)
		rolled_lanes.append(StringName(lane["lane_id"]))
		_remove_item_from_lanes(working, item_id)
	return {"item_ids": rolled_ids, "lane_ids": rolled_lanes}


func _filtered_pool(raw_pool) -> Array[StringName]:
	var canonical: Array[StringName] = MVP4CatalogScript.base_acquisition_item_ids()
	var result: Array[StringName] = []
	var seen := {}
	for raw_id in raw_pool:
		var item_id := StringName(raw_id)
		if canonical.has(item_id) and _item_defs.get(item_id) != null and not seen.has(item_id):
			seen[item_id] = true
			result.append(item_id)
	return result


func _draw_one_excluding(pool: Array[StringName], excluded: Array[StringName]) -> StringName:
	var remaining: Array[StringName] = []
	for item_id in pool:
		if not excluded.has(item_id):
			remaining.append(item_id)
	if remaining.is_empty() or _rng == null:
		return &""
	return remaining[_rng.randi_range(0, remaining.size() - 1)]


func _copy_lanes(lanes: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for lane in lanes:
		result.append({
			"lane_id": StringName(lane.get("lane_id", &"")),
			"item_ids": Array(lane.get("item_ids", [])).duplicate(),
		})
	return result


func _non_empty_lanes(lanes: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for lane in lanes:
		if not Array(lane.get("item_ids", [])).is_empty():
			result.append({"lane_id": StringName(lane["lane_id"]), "item_ids": Array(lane["item_ids"]).duplicate()})
	return result


func _remove_item_from_lanes(lanes: Array[Dictionary], item_id: StringName) -> void:
	for lane in lanes:
		var item_ids: Array = lane["item_ids"]
		while item_ids.has(item_id):
			item_ids.erase(item_id)
		lane["item_ids"] = item_ids


func _unique_item_count(lanes: Array[Dictionary]) -> int:
	var seen := {}
	for lane in lanes:
		for raw_id in Array(lane.get("item_ids", [])):
			seen[StringName(raw_id)] = true
	return seen.size()


func _string_name_array(raw_values) -> Array[StringName]:
	var result: Array[StringName] = []
	for raw_value in Array(raw_values):
		result.append(StringName(raw_value))
	return result


func _on_shop_transaction_failed(reason: String) -> void:
	transaction_failed.emit(StringName(reason))