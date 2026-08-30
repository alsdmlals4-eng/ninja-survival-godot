extends GutTest

const RUN_MODIFIER_SET_PATH := "res://scripts/data/run_modifier_set.gd"
const ITEM_DEFINITION_PATH := "res://scripts/data/item_definition.gd"
const SPATIAL_RULE_DEFINITION_PATH := "res://scripts/data/spatial_rule_definition.gd"
const BAG_DEFINITION_PATH := "res://scripts/data/bag_definition.gd"
const COMBINATION_DEFINITION_PATH := "res://scripts/data/combination_definition.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"

const EXPECTED_BASE_ITEM_IDS: Array[StringName] = [
	&"taijutsu_training",
	&"protection_talisman",
	&"fortune_talisman",
	&"ninjutsu_training",
	&"enlightenment",
	&"regeneration_scroll",
	&"ultimate_treatise",
	&"school_emblem",
	&"katana",
	&"shuriken",
	&"bomb",
	&"water_style",
	&"lightning_style",
	&"fire_style",
	&"stealth_art",
	&"poison_needles",
	&"barrier_art",
	&"greater_summoning_circle",
	&"forbidden_talisman",
]

const EXPECTED_COMBO_RESULT_IDS: Array[StringName] = [
	&"water_mist",
	&"thunder_blade",
	&"explosive_bomb",
]

const EXPECTED_PURCHASABLE_BAG_IDS: Array[StringName] = [
	&"small_pouch",
	&"long_pouch",
	&"square_pouch",
	&"tactical_t_pouch",
	&"ninjutsu_l_pouch",
]


func test_t01_data_resources_exist() -> void:
	for path in [
		ITEM_DEFINITION_PATH,
		RUN_MODIFIER_SET_PATH,
		SPATIAL_RULE_DEFINITION_PATH,
		BAG_DEFINITION_PATH,
		COMBINATION_DEFINITION_PATH,
		CATALOG_PATH,
	]:
		assert_true(ResourceLoader.exists(path), "Missing T01 data resource: %s" % path)


func test_run_modifier_set_rejects_unknown_fields_without_mutation() -> void:
	var modifiers = load(RUN_MODIFIER_SET_PATH).new()
	assert_true(modifiers.has_method("add_delta"), "RunModifierSet must own modifier-field validation")
	if not modifiers.has_method("add_delta"):
		return
	assert_true(modifiers.add_delta(&"school_damage_pct", 0.25))
	assert_almost_eq(modifiers.school_damage_pct, 0.25, 0.001)
	assert_false(modifiers.add_delta(&"not_a_real_modifier", 99.0))
	assert_almost_eq(modifiers.school_damage_pct, 0.25, 0.001)


func test_catalog_has_exact_base_and_combination_result_boundaries() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	var base_ids: Array[StringName] = catalog.base_acquisition_item_ids()
	var result_ids: Array[StringName] = catalog.combination_result_item_ids()

	assert_eq(base_ids, EXPECTED_BASE_ITEM_IDS)
	assert_eq(result_ids, EXPECTED_COMBO_RESULT_IDS)
	assert_eq(items.size(), 22)

	var seen := {}
	for item_id in base_ids:
		assert_true(items.has(item_id), "Missing base item: %s" % item_id)
		assert_false(seen.has(item_id), "Duplicate item id: %s" % item_id)
		seen[item_id] = true
	for item_id in result_ids:
		assert_true(items.has(item_id), "Missing combination result item: %s" % item_id)
		assert_false(base_ids.has(item_id), "Combination result leaked into base acquisition: %s" % item_id)
		assert_false(seen.has(item_id), "Duplicate result id: %s" % item_id)
		seen[item_id] = true


func test_catalog_has_five_purchasable_bags_plus_one_starting_3x3_bag() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var catalog = load(CATALOG_PATH)
	var bags: Dictionary = catalog.build_bags()
	var purchasable_ids: Array[StringName] = catalog.purchasable_bag_ids()

	assert_eq(purchasable_ids, EXPECTED_PURCHASABLE_BAG_IDS)
	assert_eq(bags.size(), 6)
	for bag_id in purchasable_ids:
		assert_true(bags.has(bag_id), "Missing purchasable bag: %s" % bag_id)

	var starting_ids: Array[StringName] = []
	for raw_id in bags.keys():
		var bag_id := StringName(raw_id)
		if not purchasable_ids.has(bag_id):
			starting_ids.append(bag_id)
	assert_eq(starting_ids.size(), 1, "Exactly one non-shop starting bag must exist")
	if starting_ids.size() != 1:
		return
	var starting_bag = bags[starting_ids[0]]
	assert_eq(starting_bag.base_price, 0)
	assert_eq(starting_bag.cells.size(), 9)
	assert_true(starting_bag.cells.has(Vector2i(0, 0)))
	assert_true(starting_bag.cells.has(Vector2i(2, 2)))
	assert_false(starting_bag.cells.has(Vector2i(3, 2)))


func test_non_square_item_and_irregular_bags_rotate_with_normalized_cells() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	var bags: Dictionary = catalog.build_bags()

	var katana = items[&"katana"]
	var vertical: Array[Vector2i] = katana.footprint(0)
	var horizontal: Array[Vector2i] = katana.footprint(1)
	assert_true(vertical.has(Vector2i(0, 2)))
	assert_false(vertical.has(Vector2i(2, 0)))
	assert_true(horizontal.has(Vector2i(2, 0)))
	assert_false(horizontal.has(Vector2i(0, 2)))

	for bag_id in [&"tactical_t_pouch", &"ninjutsu_l_pouch"]:
		var bag = bags[bag_id]
		for rotation in range(4):
			var cells: Array[Vector2i] = bag.footprint(rotation)
			assert_eq(cells.size(), bag.cells.size())
			for cell in cells:
				assert_gte(cell.x, 0, "%s rotation %d produced negative x" % [bag_id, rotation])
				assert_gte(cell.y, 0, "%s rotation %d produced negative y" % [bag_id, rotation])


func test_existing_mvp3_item_values_survive_legacy_adapter_semantics() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var items: Dictionary = load(CATALOG_PATH).build_items()
	var expected := {
		&"taijutsu_training": {&"move_speed_pct": 0.10},
		&"protection_talisman": {&"max_health_flat": 20.0},
		&"fortune_talisman": {&"normal_kill_gold_pct": 0.25},
		&"ninjutsu_training": {&"school_damage_pct": 0.12},
		&"enlightenment": {&"school_resource_gain_pct": 0.20},
		&"regeneration_scroll": {&"rest_start_heal_pct": 0.20},
		&"ultimate_treatise": {&"ultimate_charge_gain_pct": 0.25},
	}
	for item_id in expected.keys():
		var item = items[item_id]
		assert_true(item.has_method("resolved_static_modifier_payload"), "Missing legacy adapter on %s" % item_id)
		if not item.has_method("resolved_static_modifier_payload"):
			continue
		var payload: Dictionary = item.resolved_static_modifier_payload()
		assert_eq(payload.size(), 1, "Legacy adapter must not double-apply %s" % item_id)
		for field_name in expected[item_id].keys():
			assert_almost_eq(float(payload.get(field_name, 0.0)), float(expected[item_id][field_name]), 0.001)


func test_combo_results_have_exact_multi_axis_payloads_and_are_not_base_rewards() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	var base_ids: Array[StringName] = catalog.base_acquisition_item_ids()

	var water_mist: Dictionary = items[&"water_mist"].static_modifier_payload
	assert_almost_eq(float(water_mist[&"evasion_chance"]), 0.10, 0.001)
	assert_almost_eq(float(water_mist[&"move_speed_pct"]), 0.08, 0.001)
	assert_almost_eq(float(water_mist[&"school_status_effect_pct"]), 0.20, 0.001)

	var thunder_blade: Dictionary = items[&"thunder_blade"].static_modifier_payload
	assert_almost_eq(float(thunder_blade[&"non_ultimate_school_damage_pct"]), 0.28, 0.001)
	assert_almost_eq(float(thunder_blade[&"school_resource_gain_pct"]), 0.10, 0.001)
	assert_almost_eq(float(thunder_blade[&"move_speed_pct"]), 0.05, 0.001)

	var explosive_bomb: Dictionary = items[&"explosive_bomb"].static_modifier_payload
	assert_almost_eq(float(explosive_bomb[&"school_damage_pct"]), 0.22, 0.001)
	assert_almost_eq(float(explosive_bomb[&"non_ultimate_school_damage_pct"]), 0.10, 0.001)
	assert_almost_eq(float(explosive_bomb[&"school_status_effect_pct"]), 0.22, 0.001)
	assert_almost_eq(float(explosive_bomb[&"damage_taken_pct"]), 0.05, 0.001)

	for result_id in EXPECTED_COMBO_RESULT_IDS:
		assert_false(base_ids.has(result_id))


func test_combinations_resolve_to_existing_sources_and_results() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	var combinations: Dictionary = catalog.build_combinations()
	assert_eq(combinations.size(), 3)
	for combo in combinations.values():
		assert_true(items.has(combo.source_a), "Missing combination source A: %s" % combo.source_a)
		assert_true(items.has(combo.source_b), "Missing combination source B: %s" % combo.source_b)
		assert_true(items.has(combo.result_item), "Missing combination result: %s" % combo.result_item)


func test_spatial_rules_use_supported_modifier_fields_and_exact_strong_item_budget() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var modifier_script = load(RUN_MODIFIER_SET_PATH)
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	var strong_count := 0
	for item_id in catalog.base_acquisition_item_ids():
		var item = items[item_id]
		if item.spatial_rules.is_empty():
			continue
		strong_count += 1
		for rule in item.spatial_rules:
			for field_name in rule.modifier_payload.keys():
				assert_true(modifier_script.is_supported_field(StringName(field_name)), "Unsupported spatial modifier: %s" % field_name)
	assert_eq(strong_count, 8)


func test_catalog_validation_is_clean_and_rejects_unsupported_modifier_payload() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var catalog = load(CATALOG_PATH)
	assert_eq(catalog.validate_catalog(), [])

	var items: Dictionary = catalog.build_items()
	var bad_item = items[&"katana"]
	bad_item.static_modifier_payload = {&"not_a_real_modifier": 1.0}
	var errors: Array[String] = catalog.validate_items(items)
	assert_false(errors.is_empty(), "Unsupported modifier keys must fail catalog validation")
