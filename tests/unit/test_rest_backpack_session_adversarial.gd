extends GutTest

const SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const BAG_INSTANCE_PATH := "res://scripts/data/bag_instance.gd"


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
