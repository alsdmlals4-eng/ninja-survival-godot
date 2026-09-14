extends GutTest

const CATALOG_PATH := "res://scripts/data/selected_backpack_catalog.gd"
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const LEGACY = preload("res://scripts/data/mvp4_catalog.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const SESSION = preload("res://scripts/backpack/rest_backpack_session.gd")
const COMBINATION = preload("res://scripts/backpack/combination_resolver.gd")


func test_selected_support_materials_fit_restore_and_do_not_change_legacy() -> void:
	var bag = BAG.new().create_selectable_starting_state()
	assert_gt(bag.add_item(&"melee_manual", Vector2i(1, 1)), 0)
	assert_gt(bag.add_item(&"projectile_manual", Vector2i(2, 1)), 0)
	assert_eq(bag.add_item(&"katana", Vector2i(3, 1)), 0)
	var restored = BAG.from_persistent_snapshot(JSON.parse_string(JSON.stringify(bag.to_persistent_snapshot())))
	assert_not_null(restored)
	if restored != null:
		assert_eq(restored.items.size(), 2)
	var legacy = BAG.new().create_starting_state()
	assert_eq(legacy.add_item(&"melee_manual", Vector2i(1, 1)), 0)
	assert_gt(legacy.add_item(&"katana", Vector2i(1, 1)), 0)


func test_selected_recipe_consumes_manual_not_character_equipment_atomically() -> void:
	assert_true(ResourceLoader.exists(CATALOG_PATH))
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var catalog = load(CATALOG_PATH)
	var bag = BAG.new().create_selectable_starting_state()
	var manual: int = bag.add_item(&"melee_manual", Vector2i(1, 1))
	var lightning: int = bag.add_item(&"lightning_style", Vector2i(2, 1))
	var session = SESSION.new()
	assert_true(session.begin(bag, RESOLVER.new(), catalog.build_items(), LEGACY.build_bags(), &"bongma"))
	var combo = COMBINATION.new()
	assert_true(combo.begin_result_preview(session, &"thunder_blade", manual, lightning))
	var before: Dictionary = session.state.to_persistent_snapshot()
	assert_false(combo.commit_result(session, Vector2i(5, 5)))
	assert_eq(session.state.to_persistent_snapshot(), before)
	assert_true(combo.commit_result(session, Vector2i(1, 1)))
	assert_eq(session.state.items.size(), 1)
	assert_eq(session.state.items.values()[0].definition_id, &"thunder_blade")
	assert_eq(bag.items.size(), 2, "Preparation must not mutate the committed source.")
	assert_eq(catalog.build_items()[&"thunder_blade"].sell_price(), 35)
	assert_eq(LEGACY.build_combinations()[&"thunder_blade"].source_a, &"katana")


func test_selected_combination_results_are_unique_but_materials_can_stack() -> void:
	var bag = BAG.new().create_selectable_starting_state()
	assert_gt(bag.add_item(&"thunder_blade", Vector2i(1, 1)), 0)
	assert_eq(bag.add_item(&"thunder_blade", Vector2i(2, 1)), 0)
	var bag2 = BAG.new().create_selectable_starting_state()
	assert_gt(bag2.add_item(&"projectile_manual", Vector2i(1, 1)), 0)
	assert_gt(bag2.add_item(&"projectile_manual", Vector2i(2, 1)), 0)
	var catalog = load(CATALOG_PATH)
	var ids: Array = catalog.base_acquisition_item_ids()
	assert_eq(ids.size(), 19)
	assert_false(ids.has(&"katana"))
	assert_false(ids.has(&"shuriken"))
	assert_false(ids.has(&"bomb"))
	var definitions: Dictionary = catalog.build_items()
	assert_eq(definitions.size(), 70)
	definitions[&"water_style"].base_price = 999
	assert_eq(catalog.build_items()[&"water_style"].base_price, 30)
	assert_eq(LEGACY.build_items()[&"water_style"].base_price, 30)
