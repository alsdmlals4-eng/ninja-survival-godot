extends GutTest

const SHOP_PATH := "res://scripts/core/shop_controller.gd"
const STATE_PATH := "res://scripts/core/run_build_state.gd"
const CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"


func test_shop_controller_resource_exists() -> void:
	assert_true(ResourceLoader.exists(SHOP_PATH), "Missing MVP-3 shop controller")


func test_begin_rest_creates_three_distinct_eligible_offers() -> void:
	var fixture = _new_fixture(7)
	if fixture.is_empty():
		return
	var state = fixture.state
	var shop = fixture.shop
	state.grant_gold(1000)
	assert_true(state.buy_item(&"taijutsu_training"))
	assert_true(state.buy_item(&"taijutsu_training"))
	shop.begin_rest()
	assert_eq(shop.offer_ids.size(), 3)
	assert_eq(_unique_count(shop.offer_ids), 3)
	assert_false(shop.offer_ids.has(&"taijutsu_training"))
	assert_eq(shop.get_reroll_cost(), 5)


func test_successful_offer_purchase_delegates_to_build_state_and_records_change() -> void:
	var fixture = _new_fixture(11)
	if fixture.is_empty():
		return
	var state = fixture.state
	var shop = fixture.shop
	state.grant_gold(1000)
	shop.begin_rest()
	var item_id: StringName = shop.offer_ids[0]
	var definition = fixture.items[item_id]
	var before_gold: int = int(state.gold)
	assert_true(shop.buy_offer(0))
	assert_eq(state.item_count(item_id), 1)
	assert_eq(before_gold - state.gold, int(definition.base_price))
	assert_eq(shop.rest_changes.size(), 1)


func test_failed_purchase_is_atomic_and_does_not_record_change() -> void:
	var fixture = _new_fixture(13)
	if fixture.is_empty():
		return
	var state = fixture.state
	var shop = fixture.shop
	shop.begin_rest()
	var offers_before: Array = shop.offer_ids.duplicate()
	assert_false(shop.buy_offer(0))
	assert_eq(state.gold, 0)
	assert_eq(state.total_item_count(), 0)
	assert_eq(shop.offer_ids, offers_before)
	assert_eq(shop.rest_changes.size(), 0)
	assert_false(shop.buy_offer(-1))
	assert_false(shop.buy_offer(99))


func test_sale_refunds_and_records_change() -> void:
	var fixture = _new_fixture(17)
	if fixture.is_empty():
		return
	var state = fixture.state
	var shop = fixture.shop
	state.grant_gold(100)
	assert_true(state.buy_item(&"ninjutsu_training"))
	shop.begin_rest()
	var before_gold: int = int(state.gold)
	assert_true(shop.sell_item(&"ninjutsu_training"))
	assert_eq(state.gold - before_gold, 15)
	assert_eq(state.item_count(&"ninjutsu_training"), 0)
	assert_eq(shop.rest_changes.size(), 1)
	before_gold = int(state.gold)
	assert_false(shop.sell_item(&"ninjutsu_training"))
	assert_eq(state.gold, before_gold)
	assert_eq(shop.rest_changes.size(), 1)


func test_reroll_cost_sequence_and_insufficient_gold_are_atomic() -> void:
	var fixture = _new_fixture(19)
	if fixture.is_empty():
		return
	var state = fixture.state
	var shop = fixture.shop
	state.grant_gold(100)
	shop.begin_rest()
	assert_eq(shop.get_reroll_cost(), 5)
	assert_true(shop.reroll())
	assert_eq(shop.get_reroll_cost(), 10)
	assert_true(shop.reroll())
	assert_eq(shop.get_reroll_cost(), 15)
	assert_true(shop.reroll())
	assert_eq(shop.get_reroll_cost(), 15)
	assert_eq(state.gold, 70)

	state.try_spend_gold(70)
	var offers_before: Array = shop.offer_ids.duplicate()
	var cost_before: int = shop.get_reroll_cost()
	assert_false(shop.reroll())
	assert_eq(state.gold, 0)
	assert_eq(shop.offer_ids, offers_before)
	assert_eq(shop.get_reroll_cost(), cost_before)


func test_new_rest_resets_reroll_cost_and_change_history() -> void:
	var fixture = _new_fixture(23)
	if fixture.is_empty():
		return
	var state = fixture.state
	var shop = fixture.shop
	state.grant_gold(1000)
	shop.begin_rest()
	assert_true(shop.buy_offer(0))
	assert_true(shop.reroll())
	assert_eq(shop.get_reroll_cost(), 10)
	assert_eq(shop.rest_changes.size(), 1)
	shop.begin_rest()
	assert_eq(shop.get_reroll_cost(), 5)
	assert_eq(shop.offer_ids.size(), 3)
	assert_eq(_unique_count(shop.offer_ids), 3)
	assert_eq(shop.rest_changes.size(), 0)


func _new_fixture(seed_value: int) -> Dictionary:
	if not ResourceLoader.exists(SHOP_PATH):
		return {}
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	var fates: Dictionary = catalog.build_fates()
	var state = load(STATE_PATH).new()
	add_child_autofree(state)
	state.configure(items, fates)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var shop = load(SHOP_PATH).new()
	add_child_autofree(shop)
	shop.configure(state, items, rng)
	return {"state": state, "shop": shop, "items": items}


func _unique_count(values: Array) -> int:
	var seen := {}
	for value in values:
		seen[value] = true
	return seen.size()
