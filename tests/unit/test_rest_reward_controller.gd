extends GutTest

const CONTROLLER_PATH := "res://scripts/core/rest_reward_controller.gd"
const BUILD_STATE_PATH := "res://scripts/core/run_build_state.gd"
const SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"


func test_t07_resource_exists() -> void:
	assert_true(ResourceLoader.exists(CONTROLLER_PATH), "Missing T07 RestRewardController")


func test_boss_reward_has_three_distinct_options_with_school_related_candidate() -> void:
	var bundle = _bundle(101)
	if bundle.is_empty():
		return
	var controller = bundle.controller
	controller.begin_rest(2, &"cheonsul", 0)
	var options: Array = controller.boss_reward_options()
	assert_eq(options.size(), 3)
	assert_eq(_unique_count(options), 3)
	var has_school_related := false
	for item_id in options:
		var definition = _item_defs().get(item_id)
		if definition != null and definition.tags.has(&"affinity_cheonsul"):
			has_school_related = true
	assert_true(has_school_related, "Boss reward must expose at least one selected-school-related candidate")
	assert_true(controller.has_pending_boss_reward())


func test_boss_reward_requires_buffer_slot_and_can_only_be_chosen_once() -> void:
	var bundle = _bundle(102)
	if bundle.is_empty():
		return
	_fill_buffer(bundle.session, 6)
	bundle.controller.begin_rest(1, &"bongma", 0)
	assert_false(bundle.controller.choose_boss_reward(0))
	assert_true(bundle.controller.has_pending_boss_reward())
	assert_eq(bundle.session.buffer.size(), 6)

	var bundle2 = _bundle(103)
	bundle2.controller.begin_rest(1, &"bongma", 0)
	assert_true(bundle2.controller.choose_boss_reward(0))
	assert_eq(bundle2.session.buffer.size(), 1)
	assert_false(bundle2.controller.has_pending_boss_reward())
	assert_false(bundle2.controller.choose_boss_reward(1), "Boss reward choice must be one-shot")
	assert_eq(bundle2.session.buffer.size(), 1)


func test_chest_token_opens_exactly_two_items_and_failed_capacity_preserves_token() -> void:
	var bundle = _bundle(104)
	if bundle.is_empty():
		return
	bundle.controller.begin_rest(1, &"guiin", 0)
	assert_eq(bundle.controller.grant_chest_token(), 1)
	assert_eq(bundle.controller.chest_count(), 1)
	assert_true(bundle.controller.open_chest())
	assert_eq(bundle.controller.chest_count(), 0)
	assert_eq(bundle.session.buffer.size(), 2)

	var blocked = _bundle(105)
	_fill_buffer(blocked.session, 5)
	blocked.controller.begin_rest(1, &"guiin", 1)
	assert_false(blocked.controller.open_chest())
	assert_eq(blocked.controller.chest_count(), 1)
	assert_eq(blocked.session.buffer.size(), 5)


func test_chest_grant_is_explicit_and_non_positive_amount_is_ignored() -> void:
	var bundle = _bundle(106)
	if bundle.is_empty():
		return
	bundle.controller.begin_rest(1, &"heukyeong", 0)
	assert_eq(bundle.controller.grant_chest_token(2), 2)
	assert_eq(bundle.controller.chest_count(), 2)
	assert_eq(bundle.controller.grant_chest_token(0), 0)
	assert_eq(bundle.controller.grant_chest_token(-1), 0)
	assert_eq(bundle.controller.chest_count(), 2)


func test_shop_has_three_distinct_items_and_one_purchasable_bag() -> void:
	var bundle = _bundle(107)
	if bundle.is_empty():
		return
	bundle.controller.begin_rest(1, &"bongma", 0)
	var offers: Array = bundle.controller.shop_item_options()
	assert_eq(offers.size(), 3)
	assert_eq(_unique_count(offers), 3)
	var bag_id: StringName = bundle.controller.shop_bag_option()
	assert_ne(bag_id, &"")
	assert_true(_bag_defs().has(bag_id))
	assert_gt(int(_bag_defs()[bag_id].base_price), 0)


func test_shop_item_validates_gold_and_buffer_before_spend_and_never_changes_committed_power() -> void:
	var bundle = _bundle(108)
	if bundle.is_empty():
		return
	bundle.controller.begin_rest(1, &"cheonsul", 0)
	var item_id: StringName = bundle.controller.shop_item_options()[0]
	var price: int = int(_item_defs()[item_id].base_price)
	var committed = load(MODIFIER_PATH).new()
	committed.school_damage_pct = 0.11
	bundle.build_state.set_committed_backpack_modifiers(committed)
	assert_false(bundle.controller.buy_shop_item(0))
	assert_eq(bundle.build_state.gold, 0)
	assert_eq(bundle.session.buffer.size(), 0)

	bundle.build_state.grant_gold(price)
	assert_true(bundle.controller.buy_shop_item(0))
	assert_eq(bundle.build_state.gold, 0)
	assert_eq(bundle.session.buffer.size(), 1)
	assert_almost_eq(bundle.build_state.get_modifiers().school_damage_pct, 0.11, 0.001)

	var blocked = _bundle(109)
	_fill_buffer(blocked.session, 6)
	blocked.controller.begin_rest(1, &"cheonsul", 0)
	blocked.build_state.grant_gold(999)
	var gold_before: int = blocked.build_state.gold
	assert_false(blocked.controller.buy_shop_item(0))
	assert_eq(blocked.build_state.gold, gold_before)
	assert_eq(blocked.session.buffer.size(), 6)


func test_shop_bag_purchase_is_one_per_rest_and_validates_gold_before_pending_bag() -> void:
	var bundle = _bundle(110)
	if bundle.is_empty():
		return
	bundle.controller.begin_rest(1, &"bongma", 0)
	var bag_id: StringName = bundle.controller.shop_bag_option()
	var price: int = int(_bag_defs()[bag_id].base_price)
	assert_false(bundle.controller.buy_shop_bag())
	assert_null(bundle.session.pending_bag)
	bundle.build_state.grant_gold(price * 2)
	assert_true(bundle.controller.buy_shop_bag())
	assert_not_null(bundle.session.pending_bag)
	assert_eq(bundle.session.pending_bag.definition_id, bag_id)
	var after_first: int = bundle.build_state.gold
	assert_false(bundle.controller.buy_shop_bag())
	assert_eq(bundle.build_state.gold, after_first)


func test_shop_reroll_costs_five_ten_then_fifteen_and_keeps_distinct_offers() -> void:
	var bundle = _bundle(111)
	if bundle.is_empty():
		return
	bundle.controller.begin_rest(1, &"guiin", 0)
	bundle.build_state.grant_gold(100)
	var before: int = int(bundle.build_state.gold)
	assert_true(bundle.controller.reroll_shop())
	assert_eq(before - bundle.build_state.gold, 5)
	assert_eq(_unique_count(bundle.controller.shop_item_options()), 3)
	before = int(bundle.build_state.gold)
	assert_true(bundle.controller.reroll_shop())
	assert_eq(before - bundle.build_state.gold, 10)
	before = int(bundle.build_state.gold)
	assert_true(bundle.controller.reroll_shop())
	assert_eq(before - bundle.build_state.gold, 15)
	before = int(bundle.build_state.gold)
	assert_true(bundle.controller.reroll_shop())
	assert_eq(before - bundle.build_state.gold, 15)


func test_sell_by_instance_removes_spatial_item_and_refunds_definition_sell_price_only() -> void:
	var bundle = _bundle(112)
	if bundle.is_empty():
		return
	bundle.controller.begin_rest(1, &"heukyeong", 0)
	var item_id: StringName = bundle.controller.shop_item_options()[0]
	var price: int = int(_item_defs()[item_id].base_price)
	bundle.build_state.grant_gold(price)
	assert_true(bundle.controller.buy_shop_item(0))
	var instance_id: int = bundle.session.buffer[0].instance_id
	assert_eq(bundle.build_state.gold, 0)
	assert_true(bundle.controller.sell_item(instance_id))
	assert_eq(bundle.session.buffer.size(), 0)
	assert_eq(bundle.build_state.gold, int(_item_defs()[item_id].sell_price()))


func test_new_rest_resets_one_bag_purchase_and_reroll_cost_but_preserves_chest_input() -> void:
	var bundle = _bundle(113)
	if bundle.is_empty():
		return
	bundle.controller.begin_rest(1, &"bongma", 2)
	assert_eq(bundle.controller.chest_count(), 2)
	bundle.build_state.grant_gold(200)
	assert_true(bundle.controller.reroll_shop())
	var bag_price: int = int(_bag_defs()[bundle.controller.shop_bag_option()].base_price)
	assert_true(bundle.build_state.gold >= bag_price)
	assert_true(bundle.controller.buy_shop_bag())
	bundle.controller.begin_rest(2, &"bongma", 1)
	assert_eq(bundle.controller.chest_count(), 1)
	var before: int = int(bundle.build_state.gold)
	assert_true(bundle.controller.reroll_shop())
	assert_eq(before - bundle.build_state.gold, 5)
	# Existing pending bag still has to be placed; a new rest cannot silently overwrite it.
	assert_false(bundle.controller.buy_shop_bag())


func _bundle(seed: int) -> Dictionary:
	if not ResourceLoader.exists(CONTROLLER_PATH):
		assert_true(false, "T07 controller must exist before behavior tests")
		return {}
	var catalog = load(CATALOG_PATH)
	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(catalog.build_items(), load(MVP3_CATALOG_PATH).build_fates())
	var session = load(SESSION_PATH).new()
	session.begin(load(STATE_PATH).new().create_starting_state(), load(RESOLVER_PATH).new(), catalog.build_items(), catalog.build_bags(), &"cheonsul")
	var controller = load(CONTROLLER_PATH).new()
	add_child_autofree(controller)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	controller.configure(build_state, session, catalog.build_items(), catalog.build_bags(), rng)
	return {"controller": controller, "build_state": build_state, "session": session}


func _fill_buffer(session, count: int) -> void:
	var state = session.state
	var cells: Array[Vector2i] = [
		Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1),
		Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
	]
	for i in range(mini(count, cells.size())):
		var instance_id: int = state.add_item(&"shuriken", cells[i])
		assert_gt(instance_id, 0)
	# Re-open a session around the populated state so the test does not mutate a defensive snapshot.
	session.begin(state, load(RESOLVER_PATH).new(), _item_defs(), _bag_defs(), &"cheonsul")
	for i in range(mini(count, cells.size())):
		var ids: Array = session.state.items.keys()
		ids.sort()
		assert_true(session.move_item_to_buffer(int(ids[0])))


func _item_defs() -> Dictionary:
	return load(CATALOG_PATH).build_items()


func _bag_defs() -> Dictionary:
	return load(CATALOG_PATH).build_bags()


func _unique_count(values: Array) -> int:
	var seen := {}
	for value in values:
		seen[value] = true
	return seen.size()
