extends Node
class_name ShopController

signal offers_changed(offer_ids: Array[StringName])
signal transaction_failed(reason: String)

var offer_ids: Array[StringName] = []
var rest_changes: Array[String] = []

var _build_state: RunBuildState
var _item_defs: Dictionary = {}
var _rng: RandomNumberGenerator
var _reroll_index: int = 0


func configure(
	build_state: RunBuildState,
	item_defs: Dictionary,
	rng: RandomNumberGenerator = null
) -> void:
	_build_state = build_state
	_item_defs = item_defs.duplicate()
	if rng == null:
		_rng = RandomNumberGenerator.new()
		_rng.randomize()
	else:
		_rng = rng


func begin_rest() -> void:
	_reroll_index = 0
	rest_changes.clear()
	var rolled := _roll_offers()
	if rolled.size() < 3:
		offer_ids.clear()
		transaction_failed.emit("상점 후보가 부족합니다")
		return
	offer_ids = rolled
	offers_changed.emit(offer_ids.duplicate())


func buy_offer(index: int) -> bool:
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

	var definition = _item_defs.get(item_id)
	var display_name := str(item_id)
	if definition != null:
		display_name = str(definition.display_name)
	rest_changes.append("구매: %s" % display_name)
	return true


func sell_item(item_id: StringName) -> bool:
	if _build_state == null:
		transaction_failed.emit("상점 상태가 준비되지 않았습니다")
		return false
	if not _build_state.sell_item(item_id):
		transaction_failed.emit("판매할 수 없습니다")
		return false

	var definition = _item_defs.get(item_id)
	var display_name := str(item_id)
	if definition != null:
		display_name = str(definition.display_name)
	rest_changes.append("판매: %s" % display_name)
	return true


func reroll() -> bool:
	if _build_state == null:
		transaction_failed.emit("상점 상태가 준비되지 않았습니다")
		return false

	var rolled := _roll_offers()
	if rolled.size() < 3:
		transaction_failed.emit("상점 후보가 부족합니다")
		return false

	var cost := get_reroll_cost()
	if not _build_state.try_spend_gold(cost):
		transaction_failed.emit("GOLD가 부족합니다")
		return false

	_reroll_index += 1
	offer_ids = rolled
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


func _roll_offers() -> Array[StringName]:
	var pool: Array[StringName] = []
	if _build_state == null or _rng == null:
		return pool

	for raw_id in _item_defs.keys():
		var item_id := StringName(raw_id)
		if _build_state.item_count(item_id) < RunBuildState.MAX_DUPLICATE_ITEMS:
			pool.append(item_id)

	if pool.size() < 3:
		return []

	var rolled: Array[StringName] = []
	for _i in range(3):
		var index := _rng.randi_range(0, pool.size() - 1)
		rolled.append(pool[index])
		pool.remove_at(index)
	return rolled
