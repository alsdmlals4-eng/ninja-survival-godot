extends Node
class_name ShopController

signal offers_changed(offer_ids: Array[StringName])
signal transaction_failed(reason: String)

const BagInstanceScript = preload("res://scripts/data/bag_instance.gd")
const MVP4CatalogScript = preload("res://scripts/data/mvp4_catalog.gd")

var offer_ids: Array[StringName] = []
var offer_lane_ids: Array[StringName] = []
var bag_offer_id: StringName = &""
var rest_changes: Array[String] = []

var _build_state: RunBuildState
var _item_defs: Dictionary = {}
var _bag_defs: Dictionary = {}
var _session = null
var _rng: RandomNumberGenerator
var _reroll_index: int = 0
var _spatial_mode: bool = false
var _bag_bought_this_rest: bool = false
var _offer_lanes: Array[Dictionary] = []


func configure(
	build_state: RunBuildState,
	item_defs: Dictionary,
	rng: RandomNumberGenerator = null
) -> void:
	_build_state = build_state
	_item_defs = item_defs.duplicate()
	_bag_defs.clear()
	_session = null
	_spatial_mode = false
	_offer_lanes.clear()
	_set_rng(rng)


func configure_spatial(
	build_state: RunBuildState,
	session,
	item_defs: Dictionary,
	bag_defs: Dictionary,
	rng: RandomNumberGenerator = null,
	offer_lanes: Array = []
) -> void:
	_build_state = build_state
	_session = session
	_item_defs = item_defs.duplicate()
	_bag_defs = bag_defs.duplicate()
	_spatial_mode = true
	_offer_lanes = _sanitize_offer_lanes(offer_lanes)
	_set_rng(rng)


func set_spatial_offer_lanes(offer_lanes: Array) -> void:
	if not _spatial_mode:
		return
	_offer_lanes = _sanitize_offer_lanes(offer_lanes)


func begin_rest() -> void:
	_reroll_index = 0
	_bag_bought_this_rest = false
	rest_changes.clear()
	var rolled: Dictionary = _roll_offer_bundle()
	var rolled_ids: Array[StringName] = rolled.get("item_ids", [])
	var rolled_lanes: Array[StringName] = rolled.get("lane_ids", [])
	var rolled_bag: StringName = _roll_bag_offer() if _spatial_mode else &""
	if rolled_ids.size() < 3 or (_spatial_mode and rolled_bag == &""):
		offer_ids.clear()
		offer_lane_ids.clear()
		bag_offer_id = &""
		transaction_failed.emit("상점 후보가 부족합니다")
		return
	offer_ids = rolled_ids
	offer_lane_ids = rolled_lanes
	bag_offer_id = rolled_bag
	offers_changed.emit(offer_ids.duplicate())


func buy_offer(index: int) -> bool:
	if _spatial_mode:
		return _buy_spatial_offer(index)
	if index < 0 or index >= offer_ids.size():
		transaction_failed.emit("잘못된 상품입니다")
		return false
	if _build_state == null:
		transaction_failed.emit("상점 상태가 준비되지 않았습니다")
		return false

	var item_id: StringName = offer_ids[index]
	if not _build_state.buy_item(item_id):
		transaction_failed.emit("구매할 수 없습니다")
		return false

	_record_change("구매", item_id)
	return true


func buy_bag_offer() -> bool:
	if not _spatial_mode or _build_state == null or _session == null:
		transaction_failed.emit("가방 상점 상태가 준비되지 않았습니다")
		return false
	if _bag_bought_this_rest or bag_offer_id == &"":
		transaction_failed.emit("이번 휴식에서 가방을 더 구매할 수 없습니다")
		return false
	var definition = _bag_defs.get(bag_offer_id)
	if definition == null or int(definition.base_price) <= 0:
		transaction_failed.emit("잘못된 가방 상품입니다")
		return false
	if _session.pending_bag != null or _session.combination_transaction_active or int(_session.input_mode) != 0:
		transaction_failed.emit("가방을 받을 공간 상태가 아닙니다")
		return false
	var price: int = int(definition.base_price)
	if _build_state.gold < price:
		transaction_failed.emit("GOLD가 부족합니다")
		return false

	var pending = BagInstanceScript.new()
	pending.definition_id = bag_offer_id
	if not _session.set_pending_bag(pending):
		transaction_failed.emit("가방을 받을 수 없습니다")
		return false
	if not _build_state.try_spend_gold(price):
		transaction_failed.emit("GOLD가 부족합니다")
		return false

	_bag_bought_this_rest = true
	rest_changes.append("가방 구매: %s" % str(definition.display_name))
	return true


func sell_item(item_or_instance) -> bool:
	if _spatial_mode:
		return _sell_spatial_item(int(item_or_instance))
	if _build_state == null:
		transaction_failed.emit("상점 상태가 준비되지 않았습니다")
		return false
	var item_id := StringName(item_or_instance)
	if not _build_state.sell_item(item_id):
		transaction_failed.emit("판매할 수 없습니다")
		return false

	_record_change("판매", item_id)
	return true


func reroll() -> bool:
	if _build_state == null:
		transaction_failed.emit("상점 상태가 준비되지 않았습니다")
		return false

	var cost := get_reroll_cost()
	if _build_state.gold < cost:
		transaction_failed.emit("GOLD가 부족합니다")
		return false

	var rolled: Dictionary = _roll_offer_bundle()
	var rolled_ids: Array[StringName] = rolled.get("item_ids", [])
	var rolled_lanes: Array[StringName] = rolled.get("lane_ids", [])
	var rolled_bag: StringName = _roll_bag_offer() if _spatial_mode else bag_offer_id
	if rolled_ids.size() < 3 or (_spatial_mode and rolled_bag == &""):
		transaction_failed.emit("상점 후보가 부족합니다")
		return false

	if not _build_state.try_spend_gold(cost):
		transaction_failed.emit("GOLD가 부족합니다")
		return false

	_reroll_index += 1
	offer_ids = rolled_ids
	offer_lane_ids = rolled_lanes
	bag_offer_id = rolled_bag
	offers_changed.emit(offer_ids.duplicate())
	return true


func get_reroll_cost() -> int:
	match _reroll_index:
		0:
			return 5
		1:
			return 10
		_:
			return 15


func _buy_spatial_offer(index: int) -> bool:
	if index < 0 or index >= offer_ids.size():
		transaction_failed.emit("잘못된 상품입니다")
		return false
	if _build_state == null or _session == null:
		transaction_failed.emit("상점 상태가 준비되지 않았습니다")
		return false
	var item_id: StringName = offer_ids[index]
	var definition = _item_defs.get(item_id)
	if definition == null or int(definition.base_price) <= 0:
		transaction_failed.emit("잘못된 상품입니다")
		return false
	var price: int = int(definition.base_price)
	if _build_state.gold < price:
		transaction_failed.emit("GOLD가 부족합니다")
		return false
	if not _session._can_acquire_items_to_buffer([item_id]):
		transaction_failed.emit("작업 버퍼에 빈 칸이 없습니다")
		return false

	# Commit the session-side acquisition before GOLD emits its synchronous change signal.
	# Validation above guarantees no observer can see a paid-but-not-yet-acquired half-state.
	var created_ids: Array[int] = _session._acquire_items_to_buffer([item_id])
	if created_ids.size() != 1:
		transaction_failed.emit("구매 아이템을 작업 버퍼에 넣지 못했습니다")
		return false
	if not _build_state.try_spend_gold(price):
		_session._remove_item_for_sale(created_ids[0])
		transaction_failed.emit("GOLD가 부족합니다")
		return false
	_record_change("구매", item_id)
	return true


func _sell_spatial_item(instance_id: int) -> bool:
	if _build_state == null or _session == null or instance_id <= 0:
		transaction_failed.emit("판매할 수 없습니다")
		return false
	var instance = _find_spatial_item(instance_id)
	if instance == null:
		transaction_failed.emit("판매할 수 없습니다")
		return false
	var definition = _item_defs.get(instance.definition_id)
	if definition == null:
		transaction_failed.emit("판매할 수 없습니다")
		return false
	var removed = _session._remove_item_for_sale(instance_id)
	if removed == null:
		transaction_failed.emit("판매할 수 없습니다")
		return false
	var refund: int = maxi(int(definition.sell_price()), 0)
	if refund > 0:
		_build_state.grant_gold(refund)
	rest_changes.append("판매: %s" % str(definition.display_name))
	return true


func _find_spatial_item(instance_id: int):
	for item in _session.buffer:
		if item != null and int(item.instance_id) == instance_id:
			return item.copy_value()
	var session_state = _session.state
	if session_state == null:
		return null
	return session_state.get_item(instance_id)


func _roll_offer_bundle() -> Dictionary:
	if _build_state == null or _rng == null:
		return {"item_ids": [], "lane_ids": []}

	if not _spatial_mode:
		var legacy_pool: Array[StringName] = []
		for raw_id in _item_defs.keys():
			var item_id := StringName(raw_id)
			var definition = _item_defs.get(item_id)
			if definition != null and _build_state.item_count(item_id) < RunBuildState.MAX_DUPLICATE_ITEMS:
				legacy_pool.append(item_id)
		if legacy_pool.size() < 3:
			return {"item_ids": [], "lane_ids": []}
		legacy_pool.sort_custom(func(a, b): return str(a) < str(b))
		return {"item_ids": _draw_distinct(legacy_pool, 3), "lane_ids": []}

	var lanes: Array[Dictionary] = _effective_offer_lanes()
	if _unique_item_count(lanes) < 3:
		return {"item_ids": [], "lane_ids": []}
	var rolled_ids: Array[StringName] = []
	var rolled_lanes: Array[StringName] = []
	for _i in range(3):
		lanes = _non_empty_lanes(lanes)
		if lanes.is_empty():
			return {"item_ids": [], "lane_ids": []}
		var lane_index: int = _rng.randi_range(0, lanes.size() - 1)
		var lane: Dictionary = lanes[lane_index]
		var pool: Array = lane["item_ids"]
		var item_index: int = _rng.randi_range(0, pool.size() - 1)
		var item_id := StringName(pool[item_index])
		rolled_ids.append(item_id)
		rolled_lanes.append(StringName(lane["lane_id"]))
		_remove_item_from_lanes(lanes, item_id)
	return {"item_ids": rolled_ids, "lane_ids": rolled_lanes}


func _effective_offer_lanes() -> Array[Dictionary]:
	if not _offer_lanes.is_empty():
		return _sanitize_offer_lanes(_offer_lanes)
	var fallback_items: Array[StringName] = []
	for item_id in MVP4CatalogScript.base_acquisition_item_ids():
		if _item_defs.get(item_id) != null:
			fallback_items.append(item_id)
	return [{"lane_id": &"legacy_all", "item_ids": fallback_items}]


func _sanitize_offer_lanes(raw_lanes: Array) -> Array[Dictionary]:
	var canonical: Array[StringName] = MVP4CatalogScript.base_acquisition_item_ids()
	var result: Array[Dictionary] = []
	var used_lane_ids := {}
	for raw_lane in raw_lanes:
		if typeof(raw_lane) != TYPE_DICTIONARY:
			continue
		var lane: Dictionary = raw_lane
		var lane_id := StringName(lane.get("lane_id", &""))
		if lane_id == &"" or used_lane_ids.has(lane_id):
			continue
		var item_ids: Array[StringName] = []
		var seen := {}
		for raw_item_id in Array(lane.get("item_ids", [])):
			var item_id := StringName(raw_item_id)
			if canonical.has(item_id) and _item_defs.get(item_id) != null and not seen.has(item_id):
				seen[item_id] = true
				item_ids.append(item_id)
		if not item_ids.is_empty():
			used_lane_ids[lane_id] = true
			result.append({"lane_id": lane_id, "item_ids": item_ids})
	return result


func _non_empty_lanes(lanes: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for lane in lanes:
		if not Array(lane.get("item_ids", [])).is_empty():
			result.append({"lane_id": StringName(lane["lane_id"]), "item_ids": Array(lane["item_ids"]).duplicate()})
	return result


func _remove_item_from_lanes(lanes: Array[Dictionary], item_id: StringName) -> void:
	for lane in lanes:
		var items: Array = lane["item_ids"]
		while items.has(item_id):
			items.erase(item_id)
		lane["item_ids"] = items


func _unique_item_count(lanes: Array[Dictionary]) -> int:
	var seen := {}
	for lane in lanes:
		for raw_id in Array(lane.get("item_ids", [])):
			seen[StringName(raw_id)] = true
	return seen.size()


func _roll_bag_offer() -> StringName:
	if not _spatial_mode or _rng == null:
		return &""
	var pool: Array[StringName] = []
	for bag_id in MVP4CatalogScript.purchasable_bag_ids():
		if _bag_defs.get(bag_id) != null:
			pool.append(bag_id)
	if pool.is_empty():
		return &""
	pool.sort_custom(func(a, b): return str(a) < str(b))
	return pool[_rng.randi_range(0, pool.size() - 1)]


func _draw_distinct(pool: Array[StringName], count: int) -> Array[StringName]:
	var remaining: Array[StringName] = pool.duplicate()
	var rolled: Array[StringName] = []
	for _i in range(count):
		var index := _rng.randi_range(0, remaining.size() - 1)
		rolled.append(remaining[index])
		remaining.remove_at(index)
	return rolled


func _record_change(action: String, item_id: StringName) -> void:
	var definition = _item_defs.get(item_id)
	var display_name := str(item_id)
	if definition != null:
		display_name = str(definition.display_name)
	rest_changes.append("%s: %s" % [action, display_name])


func _set_rng(rng: RandomNumberGenerator) -> void:
	if rng == null:
		_rng = RandomNumberGenerator.new()
		_rng.randomize()
	else:
		_rng = rng
