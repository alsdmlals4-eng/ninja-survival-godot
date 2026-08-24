extends GutTest

const ACCESS_PATH := "res://scripts/core/tradition_access_state.gd"
const REWARD_PATH := "res://scripts/core/rest_reward_controller.gd"
const BUILD_PATH := "res://scripts/core/run_build_state.gd"
const SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"

const UNIVERSAL: Array[StringName] = [
	&"fortune_talisman", &"ninjutsu_training", &"regeneration_scroll",
	&"ultimate_treatise", &"school_emblem", &"forbidden_talisman", &"bomb",
]
const BONGMA: Array[StringName] = [&"enlightenment", &"barrier_art", &"greater_summoning_circle"]
const CHEONSUL: Array[StringName] = [&"water_style", &"lightning_style", &"fire_style"]
const GUIIN: Array[StringName] = [&"taijutsu_training", &"protection_talisman", &"katana"]
const HEUKYEONG: Array[StringName] = [&"shuriken", &"stealth_art", &"poison_needles"]


func test_t11_access_resource_exists() -> void:
	assert_true(ResourceLoader.exists(ACCESS_PATH), "Missing T11 TraditionAccessState")


func test_access_packages_match_dec021_exactly_and_cover_all_nineteen_base_items_once() -> void:
	var access = _new_access()
	if access == null:
		return
	assert_eq(access.universal_item_ids(), UNIVERSAL)
	assert_eq(access.school_package_item_ids(&"bongma"), BONGMA)
	assert_eq(access.school_package_item_ids(&"cheonsul"), CHEONSUL)
	assert_eq(access.school_package_item_ids(&"guiin"), GUIIN)
	assert_eq(access.school_package_item_ids(&"heukyeong"), HEUKYEONG)
	var all_ids: Array = []
	all_ids.append_array(UNIVERSAL)
	all_ids.append_array(BONGMA)
	all_ids.append_array(CHEONSUL)
	all_ids.append_array(GUIIN)
	all_ids.append_array(HEUKYEONG)
	assert_eq(all_ids.size(), 19)
	assert_eq(_unique_count(all_ids), 19)
	var canonical: Array = load(CATALOG_PATH).base_acquisition_item_ids()
	for item_id in all_ids:
		assert_true(canonical.has(item_id), "Access package contains non-canonical item: %s" % item_id)
	for item_id in canonical:
		assert_true(all_ids.has(item_id), "Canonical base item is missing from access packages: %s" % item_id)


func test_run_start_opens_universal_and_starting_school_only() -> void:
	var access = _new_access()
	if access == null:
		return
	assert_true(access.initialize(&"cheonsul"))
	assert_true(access.is_school_package_open(&"cheonsul"))
	assert_false(access.is_school_package_open(&"bongma"))
	assert_false(access.is_school_package_open(&"guiin"))
	assert_false(access.is_school_package_open(&"heukyeong"))
	var eligible: Array = access.eligible_item_ids()
	assert_eq(eligible.size(), 10)
	for item_id in UNIVERSAL + CHEONSUL:
		assert_true(eligible.has(item_id))
	for item_id in BONGMA + GUIIN + HEUKYEONG:
		assert_false(eligible.has(item_id))


func test_stabilization_opens_package_once_without_creating_combat_power() -> void:
	var access = _new_access()
	if access == null:
		return
	assert_true(access.initialize(&"cheonsul"))
	assert_true(access.stabilize_school(&"bongma"))
	assert_true(access.is_school_package_open(&"bongma"))
	var after_first: Dictionary = access.get_snapshot()
	assert_false(access.stabilize_school(&"bongma"), "Opening the same package twice must be idempotent")
	assert_eq(access.get_snapshot(), after_first)
	assert_false(access.has_method(&"get_modifiers"))
	assert_false(access.has_method(&"grant_school_power"))
	assert_false(access.has_method(&"apply_school_bonus"))


func test_all_four_packages_open_to_exact_nineteen_items_without_duplicates() -> void:
	var access = _new_access()
	if access == null:
		return
	assert_true(access.initialize(&"bongma"))
	for school_id in [&"cheonsul", &"guiin", &"heukyeong"]:
		assert_true(access.stabilize_school(school_id))
	var eligible: Array = access.eligible_item_ids()
	assert_eq(eligible.size(), 19)
	assert_eq(_unique_count(eligible), 19)


func test_lane_pools_are_defensive_canonical_and_package_first_not_one_flat_global_pool() -> void:
	var access = _new_access()
	if access == null:
		return
	assert_true(access.initialize(&"guiin"))
	assert_true(access.stabilize_school(&"heukyeong"))
	var lanes: Array = access.eligible_lane_pools()
	assert_eq(lanes.size(), 3, "Universal + two open school lanes expected")
	var lane_ids: Array = []
	for lane in lanes:
		lane_ids.append(lane["lane_id"])
		assert_gt(Array(lane["item_ids"]).size(), 0)
	assert_true(lane_ids.has(&"universal"))
	assert_true(lane_ids.has(&"school_guiin"))
	assert_true(lane_ids.has(&"school_heukyeong"))
	lanes[0]["item_ids"].clear()
	lanes.append({"lane_id": &"fake", "item_ids": [&"missing"]})
	assert_eq(access.eligible_lane_pools().size(), 3)
	assert_eq(access.universal_item_ids(), UNIVERSAL)


func test_boss_reward_exposes_three_readable_lanes_and_newly_liberated_school_item() -> void:
	var bundle: Dictionary = _bundle(7001, &"cheonsul", [&"bongma"])
	if bundle.is_empty():
		return
	bundle.controller.begin_rest(2, &"cheonsul", 0, &"bongma")
	var options: Array = bundle.controller.boss_reward_options()
	var lanes: Array = bundle.controller.boss_reward_lane_ids()
	assert_eq(options.size(), 3)
	assert_eq(_unique_count(options), 3)
	assert_eq(lanes, [&"current_build_continuity", &"newly_liberated_tradition", &"bridge_universal"])
	assert_true(CHEONSUL.has(options[0]))
	assert_true(BONGMA.has(options[1]))
	assert_true(UNIVERSAL.has(options[2]))


func test_shop_and_chest_never_draw_locked_packages_and_report_lane_first_selection() -> void:
	for seed in range(7100, 7120):
		var bundle: Dictionary = _bundle(seed, &"cheonsul", [])
		if bundle.is_empty():
			return
		bundle.controller.begin_rest(1, &"cheonsul", 1, &"cheonsul")
		var eligible: Array = UNIVERSAL + CHEONSUL
		var shop_items: Array = bundle.controller.shop_item_options()
		var shop_lanes: Array = bundle.controller.shop_item_lane_ids()
		assert_eq(shop_items.size(), 3)
		assert_eq(shop_lanes.size(), 3)
		for i in range(shop_items.size()):
			assert_true(eligible.has(shop_items[i]), "Shop leaked locked item %s" % shop_items[i])
			assert_true([&"universal", &"school_cheonsul"].has(shop_lanes[i]))
		assert_true(bundle.controller.open_chest())
		assert_eq(bundle.session.buffer.size(), 2)
		var chest_lanes: Array = bundle.controller.last_chest_lane_ids()
		assert_eq(chest_lanes.size(), 2)
		for item in bundle.session.buffer:
			assert_true(eligible.has(item.definition_id), "Chest leaked locked item %s" % item.definition_id)


func test_access_timing_does_not_change_item_identity_affinity_combinations_or_bags() -> void:
	var catalog = load(CATALOG_PATH)
	var before_items: Dictionary = catalog.build_items()
	var access = _new_access()
	if access == null:
		return
	assert_true(access.initialize(&"bongma"))
	assert_true(access.stabilize_school(&"cheonsul"))
	assert_true(access.stabilize_school(&"guiin"))
	assert_true(access.stabilize_school(&"heukyeong"))
	var after_items: Dictionary = catalog.build_items()
	assert_eq(before_items.size(), 22)
	assert_eq(after_items.size(), 22)
	assert_eq(catalog.base_acquisition_item_ids().size(), 19)
	assert_eq(catalog.build_combinations().size(), 3)
	assert_eq(catalog.purchasable_bag_ids().size(), 5)
	assert_true(catalog.build_combinations().has(&"water_mist"))
	assert_true(catalog.build_combinations().has(&"thunder_blade"))
	assert_true(after_items[&"lightning_style"].tags.has(&"affinity_guiin"), "Multi-school affinity must survive access timing")


func _new_access():
	if not ResourceLoader.exists(ACCESS_PATH):
		assert_true(false, "T11 TraditionAccessState must exist before behavior tests")
		return null
	return load(ACCESS_PATH).new()


func _bundle(seed: int, starting_school: StringName, stabilized_schools: Array[StringName]) -> Dictionary:
	if not ResourceLoader.exists(ACCESS_PATH):
		return {}
	var catalog = load(CATALOG_PATH)
	var build_state = load(BUILD_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(catalog.build_items(), load(MVP3_CATALOG_PATH).build_fates())
	var session = load(SESSION_PATH).new()
	session.begin(load(STATE_PATH).new().create_starting_state(), load(RESOLVER_PATH).new(), catalog.build_items(), catalog.build_bags(), starting_school)
	var access = load(ACCESS_PATH).new()
	assert_true(access.initialize(starting_school))
	for school_id in stabilized_schools:
		assert_true(access.stabilize_school(school_id))
	var controller = load(REWARD_PATH).new()
	add_child_autofree(controller)
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	controller.configure(build_state, session, catalog.build_items(), catalog.build_bags(), rng, access)
	return {"controller": controller, "build_state": build_state, "session": session, "access": access}


func _unique_count(values: Array) -> int:
	var seen := {}
	for value in values:
		seen[value] = true
	return seen.size()
