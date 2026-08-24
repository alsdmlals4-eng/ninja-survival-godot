extends GutTest

const ACCESS_PATH := "res://scripts/core/tradition_access_state.gd"
const REWARD_PATH := "res://scripts/core/rest_reward_controller.gd"
const SHOP_PATH := "res://scripts/core/shop_controller.gd"
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


func test_failed_access_mutations_are_total_noops_and_second_initialize_cannot_replace_starting_school() -> void:
	var access = load(ACCESS_PATH).new()
	var initial: Dictionary = access.get_snapshot()
	assert_false(access.stabilize_school(&"bongma"))
	assert_false(access.initialize(&"missing"))
	assert_eq(access.get_snapshot(), initial)
	assert_true(access.initialize(&"cheonsul"))
	var initialized: Dictionary = access.get_snapshot()
	assert_false(access.initialize(&"bongma"))
	assert_false(access.stabilize_school(&"missing"))
	assert_eq(access.get_snapshot(), initialized)
	assert_eq(access.starting_school_id(), &"cheonsul")


func test_access_snapshots_and_nested_lane_arrays_are_deeply_defensive() -> void:
	var access = load(ACCESS_PATH).new()
	assert_true(access.initialize(&"bongma"))
	assert_true(access.stabilize_school(&"guiin"))
	var snapshot: Dictionary = access.get_snapshot()
	var open_ids: Array = snapshot["open_school_ids"]
	var eligible: Array = snapshot["eligible_item_ids"]
	var lanes: Array = snapshot["eligible_lane_pools"]
	open_ids.clear()
	eligible.clear()
	lanes[0]["item_ids"].clear()
	lanes.append({"lane_id": &"fake", "item_ids": [&"missing"]})
	assert_eq(access.open_school_ids(), [&"bongma", &"guiin"])
	assert_eq(access.eligible_item_ids().size(), 13)
	assert_eq(access.eligible_lane_pools().size(), 3)
	assert_eq(access.universal_item_ids(), UNIVERSAL)


func test_shop_lane_sanitizer_rejects_locked_unknown_ids_and_dedupes_same_item_across_lanes() -> void:
	var bundle: Dictionary = _base_bundle(8101, &"cheonsul")
	var shop = load(SHOP_PATH).new()
	add_child_autofree(shop)
	shop.configure_spatial(
		bundle.build_state,
		bundle.session,
		bundle.catalog.build_items(),
		bundle.catalog.build_bags(),
		_seeded_rng(8101),
		[
			{"lane_id": &"universal", "item_ids": [&"bomb", &"bomb", &"missing"]},
			{"lane_id": &"school_cheonsul", "item_ids": [&"bomb", &"water_style", &"fire_style"]},
		]
	)
	shop.begin_rest()
	assert_eq(shop.offer_ids.size(), 3)
	assert_eq(_unique_count(shop.offer_ids), 3)
	assert_false(shop.offer_ids.has(&"missing"))
	assert_true(shop.offer_ids.has(&"bomb"))
	assert_true(shop.offer_ids.has(&"water_style"))
	assert_true(shop.offer_ids.has(&"fire_style"))


func test_failed_spatial_reroll_preserves_offer_ids_lane_ids_and_seeded_rng_state() -> void:
	var bundle: Dictionary = _base_bundle(8201, &"cheonsul")
	var access = load(ACCESS_PATH).new()
	assert_true(access.initialize(&"cheonsul"))
	var controller = load(REWARD_PATH).new()
	add_child_autofree(controller)
	var rng = _seeded_rng(8201)
	controller.configure(bundle.build_state, bundle.session, bundle.catalog.build_items(), bundle.catalog.build_bags(), rng, access)
	controller.begin_rest(1, &"cheonsul", 0, &"cheonsul")
	var before_items: Array[StringName] = controller.shop_item_options()
	var before_lanes: Array[StringName] = controller.shop_item_lane_ids()
	var control_rng = _seeded_rng(8201)
	# Advance control RNG by replaying begin_rest on an equivalent controller.
	var control_bundle: Dictionary = _base_bundle(8201, &"cheonsul")
	var control_access = load(ACCESS_PATH).new()
	assert_true(control_access.initialize(&"cheonsul"))
	var control_controller = load(REWARD_PATH).new()
	add_child_autofree(control_controller)
	control_controller.configure(control_bundle.build_state, control_bundle.session, control_bundle.catalog.build_items(), control_bundle.catalog.build_bags(), control_rng, control_access)
	control_controller.begin_rest(1, &"cheonsul", 0, &"cheonsul")
	assert_false(controller.reroll_shop(), "Zero GOLD reroll must fail before RNG consumption")
	assert_eq(controller.shop_item_options(), before_items)
	assert_eq(controller.shop_item_lane_ids(), before_lanes)
	assert_eq(rng.randi(), control_rng.randi(), "Failed reroll must not advance seeded RNG")


func test_missing_required_boss_lane_fails_closed_without_falling_back_to_global_pool() -> void:
	var bundle: Dictionary = _base_bundle(8301, &"cheonsul")
	var access = load(ACCESS_PATH).new()
	assert_true(access.initialize(&"cheonsul"))
	assert_true(access.stabilize_school(&"bongma"))
	var item_defs: Dictionary = bundle.catalog.build_items()
	for item_id in [&"enlightenment", &"barrier_art", &"greater_summoning_circle"]:
		item_defs.erase(item_id)
	var controller = load(REWARD_PATH).new()
	add_child_autofree(controller)
	controller.configure(bundle.build_state, bundle.session, item_defs, bundle.catalog.build_bags(), _seeded_rng(8301), access)
	controller.begin_rest(2, &"cheonsul", 0, &"bongma")
	assert_true(controller.has_pending_boss_reward())
	assert_eq(controller.boss_reward_options(), [])
	assert_eq(controller.boss_reward_lane_ids(), [])
	assert_false(controller.choose_boss_reward(0))


func test_access_progression_and_reward_generation_never_mutate_committed_combat_modifier_authority() -> void:
	var bundle: Dictionary = _base_bundle(8401, &"cheonsul")
	var access = load(ACCESS_PATH).new()
	assert_true(access.initialize(&"cheonsul"))
	var before = bundle.build_state.get_modifiers()
	assert_true(access.stabilize_school(&"bongma"))
	var controller = load(REWARD_PATH).new()
	add_child_autofree(controller)
	controller.configure(bundle.build_state, bundle.session, bundle.catalog.build_items(), bundle.catalog.build_bags(), _seeded_rng(8401), access)
	controller.begin_rest(2, &"cheonsul", 1, &"bongma")
	assert_eq(bundle.build_state.get_modifiers().damage_multiplier, before.damage_multiplier)
	assert_eq(bundle.build_state.get_modifiers().max_health_multiplier, before.max_health_multiplier)
	assert_eq(bundle.build_state.get_modifiers().move_speed_multiplier, before.move_speed_multiplier)
	assert_eq(bundle.build_state.get_modifiers().school_damage_multiplier, before.school_damage_multiplier)


func test_access_packages_persist_across_rests_but_locked_school_stays_locked_until_stabilized() -> void:
	var bundle: Dictionary = _base_bundle(8501, &"guiin")
	var access = load(ACCESS_PATH).new()
	assert_true(access.initialize(&"guiin"))
	var controller = load(REWARD_PATH).new()
	add_child_autofree(controller)
	controller.configure(bundle.build_state, bundle.session, bundle.catalog.build_items(), bundle.catalog.build_bags(), _seeded_rng(8501), access)
	controller.begin_rest(1, &"guiin", 0, &"guiin")
	assert_false(access.is_school_package_open(&"heukyeong"))
	controller.begin_rest(2, &"guiin", 0, &"guiin")
	assert_false(access.is_school_package_open(&"heukyeong"))
	assert_true(access.stabilize_school(&"heukyeong"))
	controller.begin_rest(3, &"guiin", 0, &"heukyeong")
	assert_true(access.is_school_package_open(&"guiin"))
	assert_true(access.is_school_package_open(&"heukyeong"))
	assert_eq(access.eligible_lane_pools().size(), 3)


func test_all_start_new_school_pairs_preserve_boss_lane_semantics_and_canonical_dedupe() -> void:
	var schools: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
	for start_school in schools:
		for new_school in schools:
			if new_school == start_school:
				continue
			var bundle: Dictionary = _base_bundle(8600 + schools.find(start_school) * 10 + schools.find(new_school), start_school)
			var access = load(ACCESS_PATH).new()
			assert_true(access.initialize(start_school))
			assert_true(access.stabilize_school(new_school))
			var controller = load(REWARD_PATH).new()
			add_child_autofree(controller)
			controller.configure(bundle.build_state, bundle.session, bundle.catalog.build_items(), bundle.catalog.build_bags(), _seeded_rng(8600 + schools.find(start_school) * 10 + schools.find(new_school)), access)
			controller.begin_rest(2, start_school, 0, new_school)
			var options: Array[StringName] = controller.boss_reward_options()
			assert_eq(options.size(), 3)
			assert_eq(_unique_count(options), 3)
			assert_eq(controller.boss_reward_lane_ids(), [&"current_build_continuity", &"newly_liberated_tradition", &"bridge_universal"])
			assert_true(access.school_package_item_ids(start_school).has(options[0]))
			assert_true(access.school_package_item_ids(new_school).has(options[1]))
			assert_true(access.universal_item_ids().has(options[2]))


func _base_bundle(seed: int, selected_school: StringName) -> Dictionary:
	var catalog = load(CATALOG_PATH)
	var build_state = load(BUILD_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(catalog.build_items(), load(MVP3_CATALOG_PATH).build_fates())
	var session = load(SESSION_PATH).new()
	session.begin(load(STATE_PATH).new().create_starting_state(), load(RESOLVER_PATH).new(), catalog.build_items(), catalog.build_bags(), selected_school)
	return {"catalog": catalog, "build_state": build_state, "session": session, "rng": _seeded_rng(seed)}


func _seeded_rng(seed: int) -> RandomNumberGenerator:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	return rng


func _unique_count(values: Array) -> int:
	var seen := {}
	for value in values:
		seen[value] = true
	return seen.size()
