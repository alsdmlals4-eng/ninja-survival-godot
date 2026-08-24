extends GutTest

const SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const BAG_INSTANCE_PATH := "res://scripts/data/bag_instance.gd"
const ITEM_INSTANCE_PATH := "res://scripts/data/item_instance.gd"


func test_irreversible_pending_bag_acquisition_breaks_prior_edit_history() -> void:
	var committed = _starting_state()
	var item_id: int = committed.add_item(&"shuriken", Vector2i(1, 1))
	assert_gt(item_id, 0)
	var session = _session(committed)

	var preview = session.preview_item(item_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	assert_true(session.commit_item_preview())
	assert_true(session.undo())
	assert_eq(session.state.get_item(item_id).origin, Vector2i(1, 1))
	assert_true(session.redo())
	assert_eq(session.state.get_item(item_id).origin, Vector2i(2, 1))

	var pending = load(BAG_INSTANCE_PATH).new()
	pending.definition_id = &"small_pouch"
	assert_true(session.set_pending_bag(pending))
	assert_false(session.undo(), "Undo must not cross a non-history acquisition boundary")
	assert_false(session.redo(), "Redo must not cross a non-history acquisition boundary")
	assert_eq(session.state.get_item(item_id).origin, Vector2i(2, 1))
	assert_not_null(session.pending_bag)


func test_restore_paths_preserve_shared_identity_and_are_atomic() -> void:
	var state = _starting_state()
	var existing_item_id: int = state.add_item(&"shuriken", Vector2i(1, 1))
	assert_eq(existing_item_id, 2)
	assert_eq(state.next_instance_id, 3)

	var duplicate_item = load(ITEM_INSTANCE_PATH).new()
	duplicate_item.instance_id = existing_item_id
	duplicate_item.definition_id = &"shuriken"
	duplicate_item.origin = Vector2i(2, 1)
	assert_false(state.restore_item_instance(duplicate_item))
	assert_eq(state.next_instance_id, 3)

	var item_colliding_with_bag_id = load(ITEM_INSTANCE_PATH).new()
	item_colliding_with_bag_id.instance_id = 1
	item_colliding_with_bag_id.definition_id = &"shuriken"
	item_colliding_with_bag_id.origin = Vector2i(2, 1)
	assert_false(state.restore_item_instance(item_colliding_with_bag_id))
	assert_eq(state.next_instance_id, 3)

	var bag_colliding_with_item_id = load(BAG_INSTANCE_PATH).new()
	bag_colliding_with_item_id.instance_id = existing_item_id
	bag_colliding_with_item_id.definition_id = &"small_pouch"
	bag_colliding_with_item_id.origin = Vector2i(0, 0)
	assert_false(state.restore_bag_instance(bag_colliding_with_item_id))
	assert_eq(state.next_instance_id, 3)

	var invalid_high_item = load(ITEM_INSTANCE_PATH).new()
	invalid_high_item.instance_id = 9
	invalid_high_item.definition_id = &"shuriken"
	invalid_high_item.origin = Vector2i(0, 0)
	assert_false(state.restore_item_instance(invalid_high_item))
	assert_eq(state.next_instance_id, 3, "Failed restore must not consume or advance identity")

	var valid_high_item = load(ITEM_INSTANCE_PATH).new()
	valid_high_item.instance_id = 9
	valid_high_item.definition_id = &"shuriken"
	valid_high_item.origin = Vector2i(2, 1)
	assert_true(state.restore_item_instance(valid_high_item))
	assert_eq(state.get_item(9).instance_id, 9)
	assert_eq(state.next_instance_id, 10, "Successful high-id restore must preserve monotonic future identity")


func _session(committed_state):
	var session = load(SESSION_PATH).new()
	session.begin(committed_state, load(RESOLVER_PATH).new(), _item_defs(), _bag_defs(), &"")
	return session


func _starting_state():
	return load(STATE_PATH).new().create_starting_state()


func _item_defs() -> Dictionary:
	return load(CATALOG_PATH).build_items()


func _bag_defs() -> Dictionary:
	return load(CATALOG_PATH).build_bags()
