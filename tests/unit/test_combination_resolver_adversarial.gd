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

	var preview = session.preview_item(spare_id, Vector2i(3, 2), 0)
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


func test_pending_transaction_is_bound_to_original_session() -> void:
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var original_session = _session(committed)
	var other_session = _session(committed)
	var resolver = _combination_resolver()

	assert_true(resolver.begin_result_preview(original_session, &"water_mist", water_id, stealth_id))
	assert_false(resolver.commit_result(other_session, Vector2i(1, 1)))
	resolver.cancel_result(other_session)
	assert_true(original_session.combination_transaction_active)
	assert_false(resolver.pending_result.is_empty())
	assert_not_null(original_session.state.get_item(water_id))
	assert_not_null(original_session.state.get_item(stealth_id))

	resolver.cancel_result(original_session)
	assert_false(original_session.combination_transaction_active)
	assert_true(resolver.pending_result.is_empty())
	assert_not_null(original_session.state.get_item(water_id))
	assert_not_null(original_session.state.get_item(stealth_id))


func test_reversed_source_arguments_are_canonicalized_without_identity_loss() -> void:
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var session = _session(committed)
	var resolver = _combination_resolver()

	assert_true(resolver.begin_result_preview(session, &"water_mist", stealth_id, water_id))
	assert_eq(resolver.pending_result.get("source_a_instance"), water_id)
	assert_eq(resolver.pending_result.get("source_b_instance"), stealth_id)
	assert_true(resolver.commit_result(session, Vector2i(1, 1)))
	assert_null(session.state.get_item(water_id))
	assert_null(session.state.get_item(stealth_id))
	assert_not_null(_find_definition(session.state, &"water_mist"))


func test_begin_rejects_uncommitted_item_preview_and_whole_layout_mode() -> void:
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var spare_id: int = committed.add_item(&"shuriken", Vector2i(3, 1))
	var session = _session(committed)
	var resolver = _combination_resolver()

	var preview = session.preview_item(spare_id, Vector2i(3, 2), 0)
	assert_true(preview.valid)
	assert_false(resolver.begin_result_preview(session, &"water_mist", water_id, stealth_id))
	assert_false(session.combination_transaction_active)
	assert_not_null(session.state.get_item(water_id))
	assert_not_null(session.state.get_item(stealth_id))
	assert_true(session.commit_item_preview())

	var mode_session = _session(committed)
	assert_true(mode_session.enter_whole_layout_move_mode())
	assert_false(resolver.begin_result_preview(mode_session, &"water_mist", water_id, stealth_id))
	assert_false(mode_session.combination_transaction_active)
	mode_session.exit_whole_layout_move_mode()


func test_cancel_preserves_prior_normal_edit_history() -> void:
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var spare_id: int = committed.add_item(&"shuriken", Vector2i(3, 1))
	var session = _session(committed)
	var resolver = _combination_resolver()

	var preview = session.preview_item(spare_id, Vector2i(3, 2), 0)
	assert_true(preview.valid)
	assert_true(session.commit_item_preview())
	assert_eq(session.state.get_item(spare_id).origin, Vector2i(3, 2))

	assert_true(resolver.begin_result_preview(session, &"water_mist", water_id, stealth_id))
	resolver.cancel_result(session)
	assert_false(session.combination_transaction_active)
	assert_true(session.undo(), "Cancelling a no-op combination preview must preserve earlier edit history")
	assert_eq(session.state.get_item(spare_id).origin, Vector2i(3, 1))


func test_hint_stage_rejects_stale_discovery_for_missing_recipe() -> void:
	var resolver = _combination_resolver()
	var state = _starting_state()
	var resolution = _resolver().resolve(state, _item_defs(), _bag_defs(), &"")
	assert_eq(
		resolver.hint_stage(&"removed_recipe", state, resolution, {&"removed_recipe": true}, _combos()),
		0,
		"Discovery memory must not resurrect a recipe missing from current combo authority"
	)


func test_failed_result_commit_does_not_consume_future_instance_id() -> void:
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var session = _session(committed)
	var resolver = _combination_resolver()
	var before_next_id: int = session.state.next_instance_id

	assert_true(resolver.begin_result_preview(session, &"water_mist", water_id, stealth_id))
	assert_false(resolver.commit_result(session, Vector2i(0, 0)))
	assert_eq(session.state.next_instance_id, before_next_id)
	assert_true(session.combination_transaction_active)
	assert_not_null(session.state.get_item(water_id))
	assert_not_null(session.state.get_item(stealth_id))
	resolver.cancel_result(session)


func test_pending_result_view_is_defensive() -> void:
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var session = _session(committed)
	var resolver = _combination_resolver()

	assert_true(resolver.begin_result_preview(session, &"water_mist", water_id, stealth_id))
	var external_view: Dictionary = resolver.pending_result
	external_view["combo_id"] = &"explosive_bomb"
	external_view["source_a_instance"] = 999
	external_view["result_item"] = &"explosive_bomb"
	assert_eq(resolver.pending_result.get("combo_id"), &"water_mist")
	assert_eq(resolver.pending_result.get("source_a_instance"), water_id)
	assert_eq(resolver.pending_result.get("result_item"), &"water_mist")
	resolver.cancel_result(session)


func test_discovered_combinations_view_is_defensive() -> void:
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var session = _session(committed)
	var resolver = _combination_resolver()

	assert_true(resolver.begin_result_preview(session, &"water_mist", water_id, stealth_id))
	assert_true(resolver.commit_result(session, Vector2i(1, 1)))
	var external_view: Dictionary = resolver.discovered_combinations
	external_view.clear()
	external_view[&"explosive_bomb"] = true
	assert_true(resolver.discovered_combinations.has(&"water_mist"))
	assert_false(resolver.discovered_combinations.has(&"explosive_bomb"))


func _find_definition(state, definition_id: StringName):
	for instance in state.items.values():
		if instance.definition_id == definition_id:
			return instance
	return null


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


func _combos() -> Dictionary:
	return load(CATALOG_PATH).build_combinations()
