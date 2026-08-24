extends GutTest

const COMBINATION_RESOLVER_PATH := "res://scripts/backpack/combination_resolver.gd"
const SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"


func test_successful_combination_clears_prior_edit_history() -> void:
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var spare_id: int = committed.add_item(&"shuriken", Vector2i(3, 1))
	var session = _session(committed)
	var resolver = _combination_resolver()

	var preview = session.preview_item(spare_id, Vector2i(4, 1), 0)
	assert_true(preview.valid)
	assert_true(session.commit_item_preview())
	assert_true(session.undo())
	assert_true(session.redo())

	assert_true(resolver.begin_result_preview(session, &"water_mist", water_id, stealth_id))
	assert_true(resolver.commit_result(session, Vector2i(1, 1)))
	assert_false(session.undo(), "Completed combination must form a history barrier")
	assert_false(session.redo(), "Completed combination must clear redo across the irreversible transaction")


func test_session_has_no_public_recipe_bypass_methods() -> void:
	var session = _session(_starting_state())
	assert_false(session.has_method("begin_combination_transaction"), "Only CombinationResolver may open a combination transaction")
	assert_false(session.has_method("commit_combination_transaction"), "Only CombinationResolver may commit recipe replacement")
	assert_false(session.has_method("cancel_combination_transaction"), "Only CombinationResolver may close the pending recipe transaction")


func _combination_resolver():
	return load(COMBINATION_RESOLVER_PATH).new()


func _session(committed_state):
	var session = load(SESSION_PATH).new()
	session.begin(committed_state, _resolver(), _item_defs(), _bag_defs(), &"cheonsul")
	return session


func _starting_state():
	return load(STATE_PATH).new().create_starting_state()


func _resolver():
	return load(RESOLVER_PATH).new()


func _item_defs() -> Dictionary:
	return load(CATALOG_PATH).build_items()


func _bag_defs() -> Dictionary:
	return load(CATALOG_PATH).build_bags()
