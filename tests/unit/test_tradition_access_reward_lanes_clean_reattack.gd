extends GutTest

const ACCESS_PATH := "res://scripts/core/tradition_access_state.gd"
const REWARD_PATH := "res://scripts/core/rest_reward_controller.gd"
const BUILD_PATH := "res://scripts/core/run_build_state.gd"
const SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"


func test_clean_full_access_progression_preserves_exact_catalog_boundaries() -> void:
	var catalog = load(CATALOG_PATH)
	var access = load(ACCESS_PATH).new()
	assert_true(access.initialize(&"cheonsul"))
	for school_id in [&"bongma", &"guiin", &"heukyeong"]:
		assert_true(access.stabilize_school(school_id))
	assert_eq(access.eligible_item_ids().size(), 19)
	assert_eq(_unique_count(access.eligible_item_ids()), 19)
	assert_eq(catalog.base_acquisition_item_ids().size(), 19)
	assert_eq(catalog.build_combinations().size(), 3)
	assert_eq(catalog.purchasable_bag_ids().size(), 5)
	assert_eq(catalog.build_items().size(), 22)


func test_clean_boss_shop_chest_outputs_are_canonical_unique_and_lane_labeled() -> void:
	var bundle: Dictionary = _bundle(9101, &"cheonsul")
	var access = load(ACCESS_PATH).new()
	assert_true(access.initialize(&"cheonsul"))
	assert_true(access.stabilize_school(&"bongma"))
	var controller = load(REWARD_PATH).new()
	add_child_autofree(controller)
	controller.configure(bundle.build_state, bundle.session, bundle.catalog.build_items(), bundle.catalog.build_bags(), _rng(9101), access)
	controller.begin_rest(2, &"cheonsul", 1, &"bongma")
	var canonical: Array = bundle.catalog.base_acquisition_item_ids()
	var boss: Array[StringName] = controller.boss_reward_options()
	var shop: Array[StringName] = controller.shop_item_options()
	assert_eq(boss.size(), 3)
	assert_eq(shop.size(), 3)
	assert_eq(_unique_count(boss), 3)
	assert_eq(_unique_count(shop), 3)
	assert_eq(controller.boss_reward_lane_ids().size(), 3)
	assert_eq(controller.shop_item_lane_ids().size(), 3)
	for item_id in boss + shop:
		assert_true(canonical.has(item_id))
	assert_true(controller.open_chest())
	assert_eq(controller.last_chest_lane_ids().size(), 2)
	for item in bundle.session.buffer:
		assert_true(canonical.has(item.definition_id))


func test_clean_reward_transaction_keeps_committed_power_frozen_until_backpack_commit() -> void:
	var bundle: Dictionary = _bundle(9201, &"guiin")
	var access = load(ACCESS_PATH).new()
	assert_true(access.initialize(&"guiin"))
	var controller = load(REWARD_PATH).new()
	add_child_autofree(controller)
	controller.configure(bundle.build_state, bundle.session, bundle.catalog.build_items(), bundle.catalog.build_bags(), _rng(9201), access)
	controller.begin_rest(1, &"guiin", 1, &"guiin")
	var before = bundle.build_state.get_modifiers()
	assert_true(controller.choose_boss_reward(0))
	assert_true(controller.open_chest())
	var after = bundle.build_state.get_modifiers()
	assert_eq(after.move_speed_pct, before.move_speed_pct)
	assert_eq(after.max_health_flat, before.max_health_flat)
	assert_eq(after.school_damage_pct, before.school_damage_pct)
	assert_eq(after.ultimate_power_pct, before.ultimate_power_pct)
	assert_eq(bundle.session.buffer.size(), 3)


func test_clean_locked_package_never_appears_before_stabilization_across_many_seeded_rests() -> void:
	for seed in range(9300, 9320):
		var bundle: Dictionary = _bundle(seed, &"bongma")
		var access = load(ACCESS_PATH).new()
		assert_true(access.initialize(&"bongma"))
		var controller = load(REWARD_PATH).new()
		add_child_autofree(controller)
		controller.configure(bundle.build_state, bundle.session, bundle.catalog.build_items(), bundle.catalog.build_bags(), _rng(seed), access)
		controller.begin_rest(1, &"bongma", 0, &"bongma")
		var locked: Array[StringName] = []
		locked.append_array(access.school_package_item_ids(&"cheonsul"))
		locked.append_array(access.school_package_item_ids(&"guiin"))
		locked.append_array(access.school_package_item_ids(&"heukyeong"))
		for item_id in controller.boss_reward_options() + controller.shop_item_options():
			assert_false(locked.has(item_id), "Locked package leaked before stabilization: %s" % item_id)


func test_clean_access_owner_has_no_direct_route_combat_or_inventory_mutation_authority() -> void:
	var access = load(ACCESS_PATH).new()
	for method_name in [
		&"set_stage_index",
		&"mark_active_school_cleared",
		&"get_modifiers",
		&"apply_modifiers",
		&"grant_gold",
		&"buy_item",
		&"add_item",
		&"force_open_all",
	]:
		assert_false(access.has_method(method_name), "Access owner must not bypass another domain: %s" % method_name)


func _bundle(seed: int, selected_school: StringName) -> Dictionary:
	var catalog = load(CATALOG_PATH)
	var build_state = load(BUILD_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(catalog.build_items(), load(MVP3_CATALOG_PATH).build_fates())
	var session = load(SESSION_PATH).new()
	session.begin(load(STATE_PATH).new().create_starting_state(), load(RESOLVER_PATH).new(), catalog.build_items(), catalog.build_bags(), selected_school)
	return {"catalog": catalog, "build_state": build_state, "session": session, "seed": seed}


func _rng(seed: int) -> RandomNumberGenerator:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	return rng


func _unique_count(values: Array) -> int:
	var seen := {}
	for value in values:
		seen[value] = true
	return seen.size()
