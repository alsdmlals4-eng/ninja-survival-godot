extends Node
class_name ShopController

signal offers_changed(offer_ids: Array[StringName])
signal transaction_failed(reason: String)

const BagInstanceScript = preload("res://scripts/data/bag_instance.gd")

var offer_ids: Array[StringName] = []
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
	_set_rng(rng)


func configure_spatial(
	build_state: RunBuildState,
	session,
	item_defs: Dictionary,
	bag_defs: Dictionary,
	rng: RandomNumberGenerator = null
) -> void:
	_build_state = build_state
	_session = session
	_item_defs = item_defs.duplicate()
	_bag_defs = bag_defs.duplicate()
	_spatial_mode = true
	_set_rng(rng)


func begin_rest() -> void:
	_reroll_index = 0
	_bag_bought_this_rest = false
	rest_changes.clear()
	var rolled := _roll_offers()
	var rolled_bag: StringName = _roll_bag_offer() if _spatial_mode else &""
	if rolled.size() < 3 or (_spatial_mode and rolled_bag == &""):
		offer_ids.clear()
		bag_offer_id = &""
		transaction_failed.emit("상점 후보가 부족합니다")
		return
	offer_ids = rolled
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

	var rolled := _roll_offers()
	var rolled_bag: StringName = _roll_bag_offer() if _spatial_mode else bag_offer_id
	if rolled.size() < 3 or (_spatial_mode and rolled_bag == &""):
		transaction_failed.emit("상점 후보가 부족합니다")
		return false

	var cost := get_reroll_cost()
	if not _build_state.try_spend_gold(cost):
		transaction_failed.emit("GOLD가 부족합니다")
		return false

	_reroll_index += 1
	offer_ids = rolled
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
	if not _session.can_acquire_items_to_buffer([item_id]):
		transaction_failed.emit("작업 버퍼에 빈 칸이 없습니다")
		return false
	if not _build_state.try_spend_gold(price):
		transaction_failed.emit("GOLD가 부족합니다")
		return false
	var created_ids: Array[int] = _session.acquire_items_to_buffer([item_id])
	if created_ids.size() != 1:
		_build_state.grant_gold(price)
		transaction_failed.emit("구매 아이템을 작업 버퍼에 넣지 못했습니다")
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
	var removed = _session.remove_item_for_sale(instance_id)
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


func _roll_offers() -> Array[StringName]:
	var pool: Array[StringName] = []
	if _build_state == null or _rng == null:
		return pool

	for raw_id in _item_defs.keys():
		var item_id := StringName(raw_id)
		var definition = _item_defs.get(item_id)
		if definition == null:
			continue
		if _spatial_mode:
			if int(definition.base_price) > 0:
				pool.append(item_id)
		elif _build_state.item_count(item_id) < RunBuildState.MAX_DUPLICATE_ITEMS:
			pool.append(item_id)

	if pool.size() < 3:
		return []
	pool.sort_custom(func(a, b): return str(a) < str(b))
	return _draw_distinct(pool, 3)


func _roll_bag_offer() -> StringName:
	if not _spatial_mode or _rng == null:
		return &""
	var pool: Array[StringName] = []
	for raw_id in _bag_defs.keys():
		var bag_id := StringName(raw_id)
		var definition = _bag_defs.get(bag_id)
		if definition != null and int(definition.base_price) > 0:
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