extends Node
class_name RestRewardController

signal rewards_changed
signal transaction_failed(reason: StringName)

const ShopControllerScript = preload("res://scripts/core/shop_controller.gd")

var _build_state: RunBuildState
var _session = null
var _item_defs: Dictionary = {}
var _bag_defs: Dictionary = {}
var _rng: RandomNumberGenerator
var _shop = null

var _segment_index: int = 0
var _selected_school_id: StringName = &""
var _chest_tokens: int = 0
var _boss_reward_ids: Array[StringName] = []
var _boss_reward_pending: bool = false


func configure(
	build_state: RunBuildState,
	session,
	item_defs: Dictionary,
	bag_defs: Dictionary,
	rng: RandomNumberGenerator
) -> void:
	_build_state = build_state
	_session = session
	_item_defs = item_defs.duplicate()
	_bag_defs = bag_defs.duplicate()
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


func begin_rest(segment_index: int, selected_school_id: StringName, chest_tokens: int) -> void:
	_segment_index = maxi(segment_index, 0)
	_selected_school_id = selected_school_id
	_chest_tokens = maxi(chest_tokens, 0)
	_boss_reward_ids = _roll_boss_rewards(selected_school_id)
	_boss_reward_pending = _boss_reward_ids.size() == 3
	if _shop != null:
		_shop.begin_rest()
	if not _boss_reward_pending:
		transaction_failed.emit(&"boss_reward_pool_unavailable")
	rewards_changed.emit()


func boss_reward_options() -> Array[StringName]:
	return _boss_reward_ids.duplicate()


func choose_boss_reward(index: int) -> bool:
	if not _boss_reward_pending or index < 0 or index >= _boss_reward_ids.size():
		transaction_failed.emit(&"boss_reward_unavailable")
		return false
	if _session == null:
		transaction_failed.emit(&"session_unavailable")
		return false
	var item_id: StringName = _boss_reward_ids[index]
	if not _session.can_acquire_items_to_buffer([item_id]):
		transaction_failed.emit(&"buffer_capacity")
		return false
	var created: Array[int] = _session.acquire_items_to_buffer([item_id])
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
	var pool := _base_item_pool()
	if pool.size() < 2:
		transaction_failed.emit(&"chest_pool_unavailable")
		return false
	var item_ids: Array[StringName] = _draw_distinct(pool, 2)
	if not _session.can_acquire_items_to_buffer(item_ids):
		transaction_failed.emit(&"buffer_capacity")
		return false
	var created: Array[int] = _session.acquire_items_to_buffer(item_ids)
	if created.size() != 2:
		transaction_failed.emit(&"chest_commit_failed")
		return false
	_chest_tokens -= 1
	rewards_changed.emit()
	return true


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


func shop_bag_option() -> StringName:
	if _shop == null:
		return &""
	return _shop.bag_offer_id


func _roll_boss_rewards(selected_school_id: StringName) -> Array[StringName]:
	var pool := _base_item_pool()
	if pool.size() < 3 or _rng == null:
		return []
	var affinity_tag := StringName("affinity_%s" % str(selected_school_id))
	var affinity_pool: Array[StringName] = []
	for item_id in pool:
		var definition = _item_defs.get(item_id)
		if definition != null and definition.tags.has(affinity_tag):
			affinity_pool.append(item_id)
	if affinity_pool.is_empty():
		return []

	affinity_pool.sort_custom(func(a, b): return str(a) < str(b))
	var first: StringName = affinity_pool[_rng.randi_range(0, affinity_pool.size() - 1)]
	var remaining: Array[StringName] = pool.duplicate()
	remaining.erase(first)
	var result: Array[StringName] = [first]
	result.append_array(_draw_distinct(remaining, 2))
	return result


func _base_item_pool() -> Array[StringName]:
	var pool: Array[StringName] = []
	for raw_id in _item_defs.keys():
		var item_id := StringName(raw_id)
		var definition = _item_defs.get(item_id)
		if definition != null and int(definition.base_price) > 0:
			pool.append(item_id)
	pool.sort_custom(func(a, b): return str(a) < str(b))
	return pool


func _draw_distinct(pool: Array[StringName], count: int) -> Array[StringName]:
	var rolled: Array[StringName] = []
	if _rng == null or count < 0 or pool.size() < count:
		return rolled
	var remaining: Array[StringName] = pool.duplicate()
	for _i in range(count):
		var index := _rng.randi_range(0, remaining.size() - 1)
		rolled.append(remaining[index])
		remaining.remove_at(index)
	return rolled


func _on_shop_transaction_failed(reason: String) -> void:
	transaction_failed.emit(StringName(reason))