extends GutTest

const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const SPATIAL_RULE_PATH := "res://scripts/data/spatial_rule_definition.gd"


func test_spatial_rules_are_data_driven_without_source_item_id_branching() -> void:
	var state = _starting_state()
	assert_gt(state.add_item(&"taijutsu_training", Vector2i(1, 1)), 0)
	assert_gt(state.add_item(&"fortune_talisman", Vector2i(2, 1)), 0)
	var resolver = _resolver()
	var bag_defs: Dictionary = _bag_defs()
	var baseline_defs: Dictionary = _item_defs()
	var baseline = resolver.resolve(state, baseline_defs, bag_defs, &"")
	assert_true(baseline.valid)

	var custom_defs: Dictionary = _item_defs()
	var rule = load(SPATIAL_RULE_PATH).new()
	rule.required_neighbor_tags.append(&"economy")
	rule.max_matches = 1
	rule.modifier_payload = {&"move_speed_pct": 0.07}
	custom_defs[&"taijutsu_training"].spatial_rules.append(rule)
	var customized = resolver.resolve(state, custom_defs, bag_defs, &"")
	assert_true(customized.valid)
	assert_almost_eq(customized.modifiers.move_speed_pct - baseline.modifiers.move_speed_pct, 0.07, 0.001)


func test_missing_item_definition_fails_closed_without_partial_modifier_output() -> void:
	var state = _starting_state()
	assert_gt(state.add_item(&"fire_style", Vector2i(1, 1)), 0)
	var item_defs: Dictionary = _item_defs()
	item_defs.erase(&"fire_style")
	var resolution = _resolver().resolve(state, item_defs, _bag_defs(), &"cheonsul")
	assert_false(resolution.valid)
	assert_eq(resolution.failure_code, &"unknown_item_definition")
	assert_almost_eq(resolution.modifiers.school_damage_pct, 0.0, 0.001)
	assert_almost_eq(resolution.modifiers.school_status_effect_pct, 0.0, 0.001)


func test_disconnected_failure_cells_are_deterministic() -> void:
	var state = _starting_state()
	assert_gt(state.add_bag(&"small_pouch", Vector2i(0, 5)), 0)
	var first = _resolver().resolve(state, _item_defs(), _bag_defs(), &"")
	var second = _resolver().resolve(state, _item_defs(), _bag_defs(), &"")
	assert_false(first.valid)
	assert_eq(first.failure_code, &"disconnected_active_cells")
	assert_eq(first.failure_cells, [Vector2i(0, 5), Vector2i(1, 5)])
	assert_eq(second.failure_cells, first.failure_cells)


func _resolver():
	return load(RESOLVER_PATH).new()


func _starting_state():
	return load(STATE_PATH).new().create_starting_state()


func _item_defs() -> Dictionary:
	return load(CATALOG_PATH).build_items()


func _bag_defs() -> Dictionary:
	return load(CATALOG_PATH).build_bags()
