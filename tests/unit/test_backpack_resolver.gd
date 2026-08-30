extends GutTest

const RESOLUTION_PATH := "res://scripts/backpack/backpack_resolution.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const ITEM_INSTANCE_PATH := "res://scripts/data/item_instance.gd"
const BAG_INSTANCE_PATH := "res://scripts/data/bag_instance.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"


func test_t03_resources_exist() -> void:
	assert_true(ResourceLoader.exists(RESOLUTION_PATH), "Missing T03 BackpackResolution")
	assert_true(ResourceLoader.exists(RESOLVER_PATH), "Missing T03 BackpackResolver")


func test_resolve_rejects_disconnected_active_cells_and_accepts_connected_extension() -> void:
	if not _t03_ready():
		return
	var resolver = _resolver()
	var item_defs: Dictionary = _item_defs()
	var bag_defs: Dictionary = _bag_defs()

	var disconnected = _starting_state()
	assert_gt(disconnected.add_bag(&"small_pouch", Vector2i(0, 5)), 0)
	var invalid = resolver.resolve(disconnected, item_defs, bag_defs, &"cheonsul")
	assert_false(invalid.valid)
	assert_eq(invalid.failure_code, &"disconnected_active_cells")

	var connected = _starting_state()
	assert_gt(connected.add_bag(&"small_pouch", Vector2i(1, 4)), 0)
	var valid = resolver.resolve(connected, item_defs, bag_defs, &"cheonsul")
	assert_true(valid.valid)
	assert_eq(valid.failure_code, &"")
	assert_eq(valid.active_cells.size(), 11)


func test_can_place_item_and_bag_return_reasoned_read_only_previews() -> void:
	if not _t03_ready():
		return
	var resolver = _resolver()
	var item_defs: Dictionary = _item_defs()
	var bag_defs: Dictionary = _bag_defs()
	var state = _starting_state()
	var existing_id: int = state.add_item(&"taijutsu_training", Vector2i(1, 1))
	assert_gt(existing_id, 0)
	var original_next_id: int = state.next_instance_id

	var overlap_item = load(ITEM_INSTANCE_PATH).new()
	overlap_item.definition_id = &"fortune_talisman"
	overlap_item.origin = Vector2i(1, 1)
	var overlap_result = resolver.can_place_item(state, overlap_item, item_defs, bag_defs)
	assert_false(overlap_result.valid)
	assert_eq(overlap_result.failure_code, &"item_overlap")

	var inactive_item = load(ITEM_INSTANCE_PATH).new()
	inactive_item.definition_id = &"fortune_talisman"
	inactive_item.origin = Vector2i(0, 0)
	var inactive_result = resolver.can_place_item(state, inactive_item, item_defs, bag_defs)
	assert_false(inactive_result.valid)
	assert_eq(inactive_result.failure_code, &"inactive_item_cell")

	var overlap_bag = load(BAG_INSTANCE_PATH).new()
	overlap_bag.definition_id = &"small_pouch"
	overlap_bag.origin = Vector2i(1, 1)
	var bag_overlap_result = resolver.can_place_bag(state, overlap_bag, item_defs, bag_defs)
	assert_false(bag_overlap_result.valid)
	assert_eq(bag_overlap_result.failure_code, &"bag_overlap")

	var disconnected_bag = load(BAG_INSTANCE_PATH).new()
	disconnected_bag.definition_id = &"small_pouch"
	disconnected_bag.origin = Vector2i(0, 5)
	var disconnected_result = resolver.can_place_bag(state, disconnected_bag, item_defs, bag_defs)
	assert_false(disconnected_result.valid)
	assert_eq(disconnected_result.failure_code, &"disconnected_active_cells")

	var connected_bag = load(BAG_INSTANCE_PATH).new()
	connected_bag.definition_id = &"small_pouch"
	connected_bag.origin = Vector2i(1, 4)
	var connected_result = resolver.can_place_bag(state, connected_bag, item_defs, bag_defs)
	assert_true(connected_result.valid)

	assert_eq(state.get_item(existing_id).origin, Vector2i(1, 1), "Resolver previews must not mutate committed state")
	assert_eq(state.bags.size(), 1)
	assert_eq(state.next_instance_id, original_next_id)


func test_existing_instance_previews_replace_in_place_without_mutating_source() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	var item_id: int = state.add_item(&"taijutsu_training", Vector2i(1, 1))
	var bag_id: int = state.add_bag(&"small_pouch", Vector2i(1, 4))
	assert_gt(item_id, 0)
	assert_gt(bag_id, 0)
	var resolver = _resolver()
	var item_defs: Dictionary = _item_defs()
	var bag_defs: Dictionary = _bag_defs()

	var item_candidate = state.get_item(item_id)
	item_candidate.origin = Vector2i(2, 1)
	assert_true(resolver.can_place_item(state, item_candidate, item_defs, bag_defs).valid)
	assert_eq(state.get_item(item_id).origin, Vector2i(1, 1))

	var bag_candidate = state.get_bag(bag_id)
	bag_candidate.origin = Vector2i(0, 4)
	assert_true(resolver.can_place_bag(state, bag_candidate, item_defs, bag_defs).valid)
	assert_eq(state.get_bag(bag_id).origin, Vector2i(1, 4))


func test_irregular_rotated_bag_contributes_exact_active_cells() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	var bag_id: int = state.add_bag(&"ninjutsu_l_pouch", Vector2i(0, 0), 1)
	assert_gt(bag_id, 0)
	var resolution = _resolver().resolve(state, _item_defs(), _bag_defs(), &"bongma")
	assert_true(resolution.valid)
	for cell in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1)]:
		assert_true(resolution.active_cells.has(cell), "Rotated L-bag cell missing: %s" % cell)
	assert_eq(resolution.active_cells.size(), 13)


func test_orthogonal_pair_is_canonical_once_even_when_multiple_edges_touch() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	var katana_id: int = state.add_item(&"katana", Vector2i(1, 1))
	var water_id: int = state.add_item(&"water_style", Vector2i(2, 1))
	assert_gt(katana_id, 0)
	assert_gt(water_id, 0)
	var resolution = _resolver().resolve(state, _item_defs(), _bag_defs(), &"cheonsul")
	assert_true(resolution.valid)
	var pair := Vector2i(mini(katana_id, water_id), maxi(katana_id, water_id))
	assert_eq(resolution.adjacency_pairs.count(pair), 1)
	assert_almost_eq(resolution.modifiers.non_ultimate_school_damage_pct, 0.26, 0.001, "Katana static + one adjacency bonus")


func test_diagonal_only_items_are_not_adjacent() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	var first_id: int = state.add_item(&"shuriken", Vector2i(1, 1))
	var second_id: int = state.add_item(&"taijutsu_training", Vector2i(2, 2))
	assert_gt(first_id, 0)
	assert_gt(second_id, 0)
	var resolution = _resolver().resolve(state, _item_defs(), _bag_defs(), &"heukyeong")
	assert_true(resolution.valid)
	var pair := Vector2i(mini(first_id, second_id), maxi(first_id, second_id))
	assert_false(resolution.adjacency_pairs.has(pair))


func test_per_distinct_neighbor_rule_and_selected_school_static_payload_are_deterministic() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	var emblem_id: int = state.add_item(&"school_emblem", Vector2i(1, 1))
	var water_id: int = state.add_item(&"water_style", Vector2i(3, 1))
	var fire_id: int = state.add_item(&"fire_style", Vector2i(1, 3), 1)
	assert_gt(emblem_id, 0)
	assert_gt(water_id, 0)
	assert_gt(fire_id, 0)

	var resolver = _resolver()
	var first = resolver.resolve(state, _item_defs(), _bag_defs(), &"cheonsul")
	var second = resolver.resolve(state, _item_defs(), _bag_defs(), &"cheonsul")
	assert_true(first.valid)
	assert_true(second.valid)
	assert_eq(first.adjacency_pairs, second.adjacency_pairs)
	assert_almost_eq(first.modifiers.cheonsul_reaction_damage_pct, 0.20, 0.001)
	assert_almost_eq(first.modifiers.school_damage_pct, 0.16, 0.001, "Fire static 0.10 + two emblem neighbors at 0.03 each")
	assert_almost_eq(first.modifiers.school_resource_gain_pct, 0.15, 0.001)
	assert_almost_eq(first.modifiers.school_status_effect_pct, 0.10, 0.001)
	assert_almost_eq(second.modifiers.school_damage_pct, first.modifiers.school_damage_pct, 0.001)


func test_per_distinct_neighbor_rule_caps_at_three_matches() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	assert_gt(state.add_bag(&"small_pouch", Vector2i(1, 4)), 0)
	var shuriken_id: int = state.add_item(&"shuriken", Vector2i(2, 2))
	var water_id: int = state.add_item(&"water_style", Vector2i(1, 2))
	var lightning_id: int = state.add_item(&"lightning_style", Vector2i(3, 2))
	var fire_id: int = state.add_item(&"fire_style", Vector2i(1, 1), 1)
	var training_id: int = state.add_item(&"ninjutsu_training", Vector2i(2, 3))
	for instance_id in [shuriken_id, water_id, lightning_id, fire_id, training_id]:
		assert_gt(instance_id, 0)
	var resolution = _resolver().resolve(state, _item_defs(), _bag_defs(), &"")
	assert_true(resolution.valid)
	assert_almost_eq(resolution.modifiers.non_ultimate_school_damage_pct, 0.14, 0.001, "Shuriken static 0.05 + max three distinct ninjutsu bonuses")


func test_one_neighbor_matching_tag_and_definition_id_counts_once_for_rule() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	var item_defs: Dictionary = _item_defs()
	item_defs[&"greater_summoning_circle"].footprint_size = Vector2i(2, 2)
	item_defs[&"school_emblem"].footprint_size = Vector2i.ONE
	item_defs[&"school_emblem"].tags.append(&"barrier")
	var summon = load(ITEM_INSTANCE_PATH).new()
	summon.instance_id = 2
	summon.definition_id = &"greater_summoning_circle"
	summon.origin = Vector2i(1, 1)
	var emblem = load(ITEM_INSTANCE_PATH).new()
	emblem.instance_id = 3
	emblem.definition_id = &"school_emblem"
	emblem.origin = Vector2i(3, 1)
	state._items[summon.instance_id] = summon
	state._items[emblem.instance_id] = emblem
	var resolution = _resolver().resolve(state, item_defs, _bag_defs(), &"")
	assert_true(resolution.valid)
	assert_almost_eq(resolution.modifiers.ultimate_charge_gain_pct, 0.12, 0.001, "One neighbor matching both declared selectors must still count once")


func test_special_bag_applies_once_when_item_overlaps_multiple_cells() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	var bag_id: int = state.add_bag(&"ninjutsu_l_pouch", Vector2i(0, 2))
	var item_id: int = state.add_item(&"water_style", Vector2i(0, 2))
	assert_gt(bag_id, 0)
	assert_gt(item_id, 0)
	var resolution = _resolver().resolve(state, _item_defs(), _bag_defs(), &"cheonsul")
	assert_true(resolution.valid)
	var hits: Array = resolution.special_bag_hits.get(item_id, [])
	assert_eq(hits.size(), 1)
	assert_eq(int(hits[0]), bag_id)
	assert_almost_eq(resolution.modifiers.school_resource_gain_pct, 0.19, 0.001, "Water static 0.15 + one bag effect 0.04")


func test_distinct_special_bags_each_apply_once_to_same_item() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	var small_id: int = state.add_bag(&"small_pouch", Vector2i(1, 4))
	var long_id: int = state.add_bag(&"long_pouch", Vector2i(3, 4))
	var item_id: int = state.add_item(&"greater_summoning_circle", Vector2i(1, 3), 1)
	assert_gt(small_id, 0)
	assert_gt(long_id, 0)
	assert_gt(item_id, 0)

	var bag_defs: Dictionary = _bag_defs()
	for bag_definition_id in [&"small_pouch", &"long_pouch"]:
		bag_defs[bag_definition_id].affected_item_tag = &"ninjutsu"
		bag_defs[bag_definition_id].auxiliary_effect_kind = &"school_resource_gain_pct"
		bag_defs[bag_definition_id].auxiliary_effect_value = 0.04

	var resolution = _resolver().resolve(state, _item_defs(), bag_defs, &"bongma")
	assert_true(resolution.valid)
	var hits: Array = resolution.special_bag_hits.get(item_id, [])
	hits.sort()
	var expected := [small_id, long_id]
	expected.sort()
	assert_eq(hits, expected)
	assert_almost_eq(resolution.modifiers.school_resource_gain_pct, 0.23, 0.001, "Summoning static 0.15 + two distinct bag effects")


func test_translated_state_is_all_or_nothing_and_never_mutates_source() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	var item_id: int = state.add_item(&"taijutsu_training", Vector2i(1, 1))
	assert_gt(item_id, 0)
	var resolver = _resolver()
	var item_defs: Dictionary = _item_defs()
	var bag_defs: Dictionary = _bag_defs()

	var translated: Dictionary = resolver.translated_state(state, Vector2i(-1, 0), item_defs, bag_defs)
	assert_true(bool(translated.get("valid", false)))
	var translated_bags: Dictionary = translated.get("bags", {})
	var translated_items: Dictionary = translated.get("items", {})
	assert_eq(translated_bags[1].origin, Vector2i(0, 1))
	assert_eq(translated_items[item_id].origin, Vector2i(0, 1))

	var rejected: Dictionary = resolver.translated_state(state, Vector2i(-2, 0), item_defs, bag_defs)
	assert_false(bool(rejected.get("valid", true)))
	var rejected_bags: Dictionary = rejected.get("bags", {})
	assert_eq(rejected_bags[1].origin, Vector2i(1, 1), "Rejected translation must return the original snapshot")
	assert_eq(state.get_bag(1).origin, Vector2i(1, 1))
	assert_eq(state.get_item(item_id).origin, Vector2i(1, 1))


func test_resolution_outputs_are_independent_snapshots() -> void:
	if not _t03_ready():
		return
	var state = _starting_state()
	assert_gt(state.add_item(&"fire_style", Vector2i(1, 1)), 0)
	var resolver = _resolver()
	var first = resolver.resolve(state, _item_defs(), _bag_defs(), &"cheonsul")
	var second = resolver.resolve(state, _item_defs(), _bag_defs(), &"cheonsul")
	assert_true(first.valid)
	assert_true(second.valid)
	first.active_cells.erase(Vector2i(1, 1))
	first.modifiers.school_damage_pct = 99.0
	assert_true(second.active_cells.has(Vector2i(1, 1)))
	assert_almost_eq(second.modifiers.school_damage_pct, 0.10, 0.001)


func _t03_ready() -> bool:
	return ResourceLoader.exists(RESOLUTION_PATH) and ResourceLoader.exists(RESOLVER_PATH)


func _resolver():
	return load(RESOLVER_PATH).new()


func _starting_state():
	return load(STATE_PATH).new().create_starting_state()


func _item_defs() -> Dictionary:
	return load(CATALOG_PATH).build_items()


func _bag_defs() -> Dictionary:
	return load(CATALOG_PATH).build_bags()
