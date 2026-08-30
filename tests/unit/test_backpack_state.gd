extends GutTest

const ITEM_INSTANCE_PATH := "res://scripts/data/item_instance.gd"
const BAG_INSTANCE_PATH := "res://scripts/data/bag_instance.gd"
const BACKPACK_STATE_PATH := "res://scripts/backpack/backpack_state.gd"


func test_t02_resources_exist() -> void:
	for path in [ITEM_INSTANCE_PATH, BAG_INSTANCE_PATH, BACKPACK_STATE_PATH]:
		assert_true(ResourceLoader.exists(path), "Missing T02 resource: %s" % path)


func test_starting_state_has_centered_3x3_active_area_and_stable_starting_bag() -> void:
	var state = _starting_state()
	if state == null:
		return
	var active_cells: Dictionary = state.get_active_cells()
	assert_eq(active_cells.size(), 9)
	assert_true(active_cells.has(Vector2i(1, 1)))
	assert_true(active_cells.has(Vector2i(3, 3)))
	assert_false(active_cells.has(Vector2i(4, 3)))
	assert_false(active_cells.has(Vector2i(0, 0)))
	assert_eq(state.bags.size(), 1)
	var starting_bag = state.get_bag(1)
	assert_not_null(starting_bag)
	if starting_bag == null:
		return
	assert_eq(starting_bag.instance_id, 1)
	assert_eq(starting_bag.definition_id, &"starting_ninja_bag")
	assert_eq(starting_bag.origin, Vector2i(1, 1))
	assert_eq(starting_bag.rotation_quarters, 0)
	assert_eq(state.next_instance_id, 2)


func test_successful_item_and_bag_additions_share_monotonic_instance_ids() -> void:
	var state = _starting_state()
	if state == null:
		return
	var first_item_id: int = state.add_item(&"taijutsu_training", Vector2i(1, 1))
	var bag_id: int = state.add_bag(&"small_pouch", Vector2i(0, 0))
	var second_item_id: int = state.add_item(&"fortune_talisman", Vector2i(2, 1))
	assert_eq(first_item_id, 2)
	assert_eq(bag_id, 3)
	assert_eq(second_item_id, 4)
	assert_eq(state.next_instance_id, 5)


func test_invalid_item_placement_rejects_inactive_cells_and_collision_without_consuming_id() -> void:
	var state = _starting_state()
	if state == null:
		return
	assert_eq(state.add_item(&"taijutsu_training", Vector2i(0, 0)), 0)
	assert_eq(state.next_instance_id, 2)
	var first_id: int = state.add_item(&"taijutsu_training", Vector2i(1, 1))
	assert_eq(first_id, 2)
	assert_eq(state.add_item(&"fortune_talisman", Vector2i(1, 1)), 0)
	assert_eq(state.next_instance_id, 3)
	assert_eq(state.add_item(&"fortune_talisman", Vector2i(2, 1)), 3)


func test_unknown_definitions_and_instance_ids_are_atomic_noops() -> void:
	var state = _starting_state()
	if state == null:
		return
	var next_id_before: int = state.next_instance_id
	assert_eq(state.add_item(&"not_an_item", Vector2i(1, 1)), 0)
	assert_eq(state.add_bag(&"not_a_bag", Vector2i(0, 0)), 0)
	assert_eq(state.next_instance_id, next_id_before)
	assert_false(state.move_item(999, Vector2i(1, 1)))
	assert_false(state.rotate_item(999))
	assert_null(state.remove_item(999))
	assert_null(state.get_item(999))
	assert_false(state.move_bag(999, Vector2i(0, 0)))
	assert_false(state.rotate_bag(999))
	assert_null(state.remove_bag(999))
	assert_null(state.get_bag(999))
	assert_eq(state.next_instance_id, next_id_before)


func test_rotation_inputs_normalize_to_quarter_turns() -> void:
	var state = _starting_state()
	if state == null:
		return
	var katana_id: int = state.add_item(&"katana", Vector2i(1, 1), 5)
	var pouch_id: int = state.add_bag(&"small_pouch", Vector2i(0, 4), -1)
	assert_gt(katana_id, 0)
	assert_gt(pouch_id, 0)
	assert_eq(state.get_item(katana_id).rotation_quarters, 1)
	assert_eq(state.get_bag(pouch_id).rotation_quarters, 3)


func test_item_move_and_rotation_are_atomic_against_collision_and_active_area() -> void:
	var state = _starting_state()
	if state == null:
		return
	var katana_id: int = state.add_item(&"katana", Vector2i(1, 1))
	var blocker_id: int = state.add_item(&"taijutsu_training", Vector2i(2, 1))
	assert_gt(katana_id, 0)
	assert_gt(blocker_id, 0)
	assert_false(state.rotate_item(katana_id))
	assert_eq(state.get_item(katana_id).rotation_quarters, 0)
	assert_true(state.move_item(blocker_id, Vector2i(3, 3)))
	assert_true(state.rotate_item(katana_id))
	assert_eq(state.get_item(katana_id).rotation_quarters, 1)
	assert_false(state.move_item(katana_id, Vector2i(2, 3)))
	assert_eq(state.get_item(katana_id).origin, Vector2i(1, 1))
	assert_true(state.move_item(katana_id, Vector2i(1, 2)))
	assert_eq(state.get_item(katana_id).origin, Vector2i(1, 2))


func test_bag_expansion_updates_active_cells_and_rejects_overlap_or_board_escape() -> void:
	var state = _starting_state()
	if state == null:
		return
	var small_id: int = state.add_bag(&"small_pouch", Vector2i(0, 0))
	assert_eq(small_id, 2)
	assert_eq(state.get_active_cells().size(), 11)
	assert_eq(state.add_bag(&"square_pouch", Vector2i(0, 0)), 0)
	assert_eq(state.add_bag(&"long_pouch", Vector2i(4, 5)), 0)
	var square_id: int = state.add_bag(&"square_pouch", Vector2i(4, 4))
	assert_eq(square_id, 3)
	assert_eq(state.get_active_cells().size(), 15)


func test_starting_bag_cannot_be_removed_or_moved_when_it_would_orphan_an_item() -> void:
	var state = _starting_state()
	if state == null:
		return
	var item_id: int = state.add_item(&"taijutsu_training", Vector2i(3, 3))
	assert_gt(item_id, 0)
	assert_null(state.remove_bag(1))
	assert_false(state.move_bag(1, Vector2i(0, 1)))
	var starting_bag = state.get_bag(1)
	assert_eq(starting_bag.origin, Vector2i(1, 1))
	assert_eq(starting_bag.rotation_quarters, 0)
	assert_not_null(state.get_item(item_id))


func test_public_collection_views_cannot_mutate_committed_instances() -> void:
	var state = _starting_state()
	if state == null:
		return
	var item_id: int = state.add_item(&"taijutsu_training", Vector2i(1, 1))
	var bag_id: int = state.add_bag(&"small_pouch", Vector2i(0, 0))
	var item_view: Dictionary = state.items
	var bag_view: Dictionary = state.bags
	item_view[item_id].origin = Vector2i(4, 3)
	bag_view[bag_id].origin = Vector2i(5, 5)
	assert_eq(state.get_item(item_id).origin, Vector2i(1, 1), "Public item view must be defensive")
	assert_eq(state.get_bag(bag_id).origin, Vector2i(0, 0), "Public bag view must be defensive")


func test_remove_lookup_and_copy_are_value_isolated() -> void:
	var state = _starting_state()
	if state == null:
		return
	var item_id: int = state.add_item(&"taijutsu_training", Vector2i(1, 1))
	var bag_id: int = state.add_bag(&"small_pouch", Vector2i(0, 0))
	var exposed_item = state.get_item(item_id)
	exposed_item.origin = Vector2i(4, 3)
	assert_eq(state.get_item(item_id).origin, Vector2i(1, 1))

	var copied = state.copy_value()
	assert_true(copied.move_item(item_id, Vector2i(2, 1)))
	assert_not_null(copied.remove_bag(bag_id))
	assert_eq(copied.get_item(item_id).origin, Vector2i(2, 1))
	assert_null(copied.get_bag(bag_id))
	assert_eq(state.get_item(item_id).origin, Vector2i(1, 1))
	assert_not_null(state.get_bag(bag_id))

	var copy_new_id: int = copied.add_item(&"fortune_talisman", Vector2i(3, 1))
	assert_eq(copy_new_id, 4)
	assert_eq(state.next_instance_id, 4)
	var original_new_id: int = state.add_item(&"fortune_talisman", Vector2i(3, 1))
	assert_eq(original_new_id, 4)


func _starting_state():
	if not ResourceLoader.exists(BACKPACK_STATE_PATH):
		return null
	var seed = load(BACKPACK_STATE_PATH).new()
	assert_true(seed.has_method("create_starting_state"), "BackpackState must expose create_starting_state()")
	if not seed.has_method("create_starting_state"):
		return null
	return seed.create_starting_state()
