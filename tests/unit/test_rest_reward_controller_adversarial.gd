extends GutTest

const CONTROLLER_PATH := "res://scripts/core/rest_reward_controller.gd"
const BUILD_STATE_PATH := "res://scripts/core/run_build_state.gd"
const SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"


func test_catalog_acquisition_boundaries_win_over_price_heuristics() -> void:
	var catalog = load(CATALOG_PATH)
	var item_defs: Dictionary = catalog.build_items()
	for item_id in catalog.base_acquisition_item_ids():
		item_defs[item_id].base_price = 0
	for result_id in catalog.combination_result_item_ids():
		item_defs[result_id].base_price = 100

	var bag_defs: Dictionary = catalog.build_bags()
	for bag_id in catalog.purchasable_bag_ids():
		bag_defs[bag_id].base_price = 0
	bag_defs[catalog.STARTING_BAG_ID].base_price = 100

	var bundle := _bundle_with_defs(201, item_defs, bag_defs)
	bundle.controller.begin_rest(1, &"cheonsul", 0)
	var base_ids: Array[StringName] = catalog.base_acquisition_item_ids()
	var result_ids: Array[StringName] = catalog.combination_result_item_ids()
	for offer_id in bundle.controller.shop_item_options():
		assert_true(base_ids.has(offer_id), "Shop item offer must come from explicit base acquisition authority")
		assert_false(result_ids.has(offer_id), "Combination result must never leak into base shop acquisition")
	assert_true(catalog.purchasable_bag_ids().has(bundle.controller.shop_bag_option()), "Starting bag must never become a shop bag because of price mutation")


func test_paid_item_is_present_before_gold_changed_observers_run() -> void:
	var bundle := _bundle(202)
	bundle.controller.begin_rest(1, &"bongma", 0)
	var item_id: StringName = bundle.controller.shop_item_options()[0]
	var price: int = int(_item_defs()[item_id].base_price)
	bundle.build_state.grant_gold(price)
	var observed_buffer_sizes: Array[int] = []
	bundle.build_state.gold_changed.connect(func(_gold: int): observed_buffer_sizes.append(bundle.session.buffer.size()))

	assert_true(bundle.controller.buy_shop_item(0))
	assert_eq(observed_buffer_sizes, [1], "Synchronous GOLD observers must see the acquired item already committed to the REST session")
	assert_eq(bundle.session.buffer.size(), 1)


func test_batch_acquisition_failure_preserves_buffer_and_instance_cursor() -> void:
	var bundle := _bundle(203)
	var next_before: int = bundle.session.state.next_instance_id
	assert_false(bundle.session.can_acquire_items_to_buffer([&"shuriken", &"missing_item"]))
	var failed_ids: Array[int] = bundle.session.acquire_items_to_buffer([&"shuriken", &"missing_item"])
	assert_true(failed_ids.is_empty())
	assert_eq(bundle.session.buffer.size(), 0)
	assert_eq(bundle.session.state.next_instance_id, next_before)

	var created_ids: Array[int] = bundle.session.acquire_items_to_buffer([&"shuriken", &"water_style"])
	assert_eq(created_ids, [next_before, next_before + 1])
	assert_eq(bundle.session.state.next_instance_id, next_before + 2)


func test_failed_chest_open_is_total_noop_beyond_failure_signal() -> void:
	var bundle := _bundle(204)
	_fill_buffer(bundle.session, 5)
	bundle.controller.begin_rest(1, &"guiin", 1)
	var buffer_before: Array = bundle.session.buffer
	var cursor_before: int = bundle.session.state.next_instance_id
	var modifiers_before = bundle.build_state.get_modifiers()

	assert_false(bundle.controller.open_chest())
	assert_eq(bundle.controller.chest_count(), 1)
	assert_eq(_buffer_identity(bundle.session.buffer), _buffer_identity(buffer_before))
	assert_eq(bundle.session.state.next_instance_id, cursor_before)
	assert_almost_eq(bundle.build_state.get_modifiers().school_damage_pct, modifiers_before.school_damage_pct, 0.001)


func test_spatial_sale_uses_exact_instance_and_never_changes_committed_power() -> void:
	var catalog = load(CATALOG_PATH)
	var committed_state = load(STATE_PATH).new().create_starting_state()
	var instance_id: int = committed_state.add_item(&"shuriken", Vector2i(1, 1))
	assert_gt(instance_id, 0)
	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(catalog.build_items(), load(MVP3_CATALOG_PATH).build_fates())
	var committed_modifiers = load(MODIFIER_PATH).new()
	committed_modifiers.school_damage_pct = 0.19
	build_state.set_committed_backpack_modifiers(committed_modifiers)
	var session = load(SESSION_PATH).new()
	session.begin(committed_state, load(RESOLVER_PATH).new(), catalog.build_items(), catalog.build_bags(), &"heukyeong")
	var controller = load(CONTROLLER_PATH).new()
	add_child_autofree(controller)
	var rng = RandomNumberGenerator.new()
	rng.seed = 205
	controller.configure(build_state, session, catalog.build_items(), catalog.build_bags(), rng)
	controller.begin_rest(1, &"heukyeong", 0)

	assert_false(controller.sell_item(instance_id + 999))
	assert_not_null(session.state.get_item(instance_id))
	assert_eq(build_state.gold, 0)
	assert_true(controller.sell_item(instance_id))
	assert_null(session.state.get_item(instance_id))
	assert_eq(build_state.gold, int(catalog.build_items()[&"shuriken"].sell_price()))
	assert_almost_eq(build_state.get_modifiers().school_damage_pct, 0.19, 0.001)


func test_acquisition_is_blocked_during_whole_layout_mode_without_spending_gold() -> void:
	var bundle := _bundle(206)
	bundle.controller.begin_rest(1, &"bongma", 0)
	bundle.build_state.grant_gold(999)
	assert_true(bundle.session.enter_whole_layout_move_mode())
	var gold_before: int = bundle.build_state.gold
	var buffer_before: Array = bundle.session.buffer

	assert_false(bundle.controller.buy_shop_item(0))
	assert_false(bundle.controller.buy_shop_bag())
	assert_eq(bundle.build_state.gold, gold_before)
	assert_eq(_buffer_identity(bundle.session.buffer), _buffer_identity(buffer_before))
	assert_null(bundle.session.pending_bag)


func _bundle(seed: int) -> Dictionary:
	return _bundle_with_defs(seed, _item_defs(), _bag_defs())


func _bundle_with_defs(seed: int, item_defs: Dictionary, bag_defs: Dictionary) -> Dictionary:
	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(item_defs, load(MVP3_CATALOG_PATH).build_fates())
	var session = load(SESSION_PATH).new()
	session.begin(load(STATE_PATH).new().create_starting_state(), load(RESOLVER_PATH).new(), item_defs, bag_defs, &"cheonsul")
	var controller = load(CONTROLLER_PATH).new()
	add_child_autofree(controller)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	controller.configure(build_state, session, item_defs, bag_defs, rng)
	return {"controller": controller, "build_state": build_state, "session": session}


func _fill_buffer(session, count: int) -> void:
	var state = session.state
	var cells: Array[Vector2i] = [
		Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
		Vector2i(1, 2), Vector2i(2, 2),
	]
	for i in range(mini(count, cells.size())):
		var instance_id: int = state.add_item(&"shuriken", cells[i])
		assert_gt(instance_id, 0)
	session.begin(state, load(RESOLVER_PATH).new(), _item_defs(), _bag_defs(), &"cheonsul")
	for _i in range(mini(count, cells.size())):
		var ids: Array = session.state.items.keys()
		ids.sort()
		assert_true(session.move_item_to_buffer(int(ids[0])))


func _item_defs() -> Dictionary:
	return load(CATALOG_PATH).build_items()


func _bag_defs() -> Dictionary:
	return load(CATALOG_PATH).build_bags()


func _buffer_identity(buffer_items: Array) -> Array[String]:
	var values: Array[String] = []
	for item in buffer_items:
		values.append("%d:%s" % [int(item.instance_id), str(item.definition_id)])
	return values