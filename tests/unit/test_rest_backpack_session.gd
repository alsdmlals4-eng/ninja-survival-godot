extends GutTest

const SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const PREVIEW_PATH := "res://scripts/backpack/build_preview_snapshot.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const BAG_INSTANCE_PATH := "res://scripts/data/bag_instance.gd"


func test_t04_resources_exist() -> void:
	assert_true(ResourceLoader.exists(PREVIEW_PATH), "Missing T04 BuildPreviewSnapshot")
	assert_true(ResourceLoader.exists(SESSION_PATH), "Missing T04 RestBackpackSession")


func test_begin_copies_committed_state_and_item_preview_is_non_mutating_with_selected_school() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var item_id: int = committed.add_item(&"school_emblem", Vector2i(1, 1))
	assert_gt(item_id, 0)
	var session = _session(committed, &"cheonsul")
	if session == null:
		return

	var preview = session.preview_item(item_id, Vector2i(2, 1), 0)
	assert_not_null(preview)
	if preview == null:
		return
	assert_true(preview.valid)
	assert_eq(committed.get_item(item_id).origin, Vector2i(1, 1))
	assert_eq(session.state.get_item(item_id).origin, Vector2i(1, 1))
	assert_eq(preview.state.get_item(item_id).origin, Vector2i(2, 1))
	assert_almost_eq(preview.modifiers.cheonsul_reaction_damage_pct, 0.20, 0.001)

	assert_true(session.commit_item_preview())
	assert_eq(session.state.get_item(item_id).origin, Vector2i(2, 1))
	assert_eq(committed.get_item(item_id).origin, Vector2i(1, 1), "REST edits must not mutate committed source")


func test_buffer_round_trip_disables_effects_requires_legal_placement_and_preserves_instance_id() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var item_id: int = committed.add_item(&"shuriken", Vector2i(1, 1))
	assert_gt(item_id, 0)
	var session = _session(committed)
	if session == null:
		return
	var resolver = _resolver()
	var before = resolver.resolve(session.state, _item_defs(), _bag_defs(), &"")
	assert_almost_eq(before.modifiers.non_ultimate_school_damage_pct, 0.05, 0.001)

	assert_true(session.move_item_to_buffer(item_id))
	assert_eq(session.buffer.size(), 1)
	assert_eq(session.buffer[0].instance_id, item_id)
	assert_null(session.state.get_item(item_id))
	var buffered = resolver.resolve(session.state, _item_defs(), _bag_defs(), &"")
	assert_almost_eq(buffered.modifiers.non_ultimate_school_damage_pct, 0.0, 0.001)

	assert_false(session.place_buffer_item(0, Vector2i(0, 0)))
	assert_eq(session.buffer.size(), 1)
	assert_null(session.state.get_item(item_id))

	assert_true(session.place_buffer_item(0, Vector2i(2, 1)))
	assert_eq(session.buffer.size(), 0)
	assert_not_null(session.state.get_item(item_id))
	assert_eq(session.state.get_item(item_id).instance_id, item_id, "Board-buffer-board must preserve stable T02 identity")
	assert_eq(session.state.get_item(item_id).origin, Vector2i(2, 1))


func test_buffer_capacity_is_exactly_six_and_seventh_move_is_atomic() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var cells: Array[Vector2i] = [
		Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
		Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
	]
	var ids: Array[int] = []
	for cell in cells:
		var item_id: int = committed.add_item(&"shuriken", cell)
		assert_gt(item_id, 0)
		ids.append(item_id)
	var session = _session(committed)
	if session == null:
		return

	for index in range(6):
		assert_true(session.move_item_to_buffer(ids[index]))
	assert_eq(session.buffer.size(), 6)
	assert_false(session.move_item_to_buffer(ids[6]))
	assert_eq(session.buffer.size(), 6)
	assert_not_null(session.state.get_item(ids[6]))
	assert_eq(session.state.get_item(ids[6]).origin, cells[6])


func test_edit_history_undo_redo_and_new_edit_clears_redo() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var item_id: int = committed.add_item(&"shuriken", Vector2i(1, 1))
	var session = _session(committed)
	if session == null:
		return

	var preview = session.preview_item(item_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	assert_true(session.commit_item_preview())
	assert_eq(session.state.get_item(item_id).origin, Vector2i(2, 1))
	assert_true(session.undo())
	assert_eq(session.state.get_item(item_id).origin, Vector2i(1, 1))
	assert_true(session.redo())
	assert_eq(session.state.get_item(item_id).origin, Vector2i(2, 1))

	assert_true(session.undo())
	preview = session.preview_item(item_id, Vector2i(3, 1), 0)
	assert_true(preview.valid)
	assert_true(session.commit_item_preview())
	assert_eq(session.state.get_item(item_id).origin, Vector2i(3, 1))
	assert_false(session.redo(), "A new committed edit must clear redo history")


func test_buffer_transition_is_undoable_without_changing_instance_identity() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var item_id: int = committed.add_item(&"shuriken", Vector2i(1, 1))
	var session = _session(committed)
	if session == null:
		return

	assert_true(session.move_item_to_buffer(item_id))
	assert_null(session.state.get_item(item_id))
	assert_eq(session.buffer[0].instance_id, item_id)
	assert_true(session.undo())
	assert_not_null(session.state.get_item(item_id))
	assert_eq(session.state.get_item(item_id).instance_id, item_id)
	assert_eq(session.buffer.size(), 0)
	assert_true(session.redo())
	assert_null(session.state.get_item(item_id))
	assert_eq(session.buffer[0].instance_id, item_id)


func test_pending_bag_acquisition_is_not_history_but_placement_is_undoable() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var session = _session(committed)
	if session == null:
		return
	var pending = load(BAG_INSTANCE_PATH).new()
	pending.definition_id = &"small_pouch"

	assert_true(session.set_pending_bag(pending))
	assert_false(session.undo(), "Acquiring/setting a pending bag is not an edit-history action")
	assert_true(session.place_pending_bag(Vector2i(0, 0)))
	assert_eq(session.state.bags.size(), 2)
	assert_null(session.pending_bag)

	assert_true(session.undo())
	assert_eq(session.state.bags.size(), 1)
	assert_not_null(session.pending_bag)
	assert_eq(session.pending_bag.definition_id, &"small_pouch")
	assert_true(session.redo())
	assert_eq(session.state.bags.size(), 2)
	assert_null(session.pending_bag)


func test_whole_layout_translation_requires_explicit_mode_and_failure_is_atomic() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var session = _session(committed)
	if session == null:
		return
	assert_eq(session.input_mode, 0)
	assert_false(session.translate_whole_layout(Vector2i(-1, 0)))
	assert_eq(session.state.get_bag(1).origin, Vector2i(1, 1))

	assert_true(session.enter_whole_layout_move_mode())
	assert_eq(session.input_mode, 1)
	assert_true(session.translate_whole_layout(Vector2i(-1, 0)))
	assert_eq(session.state.get_bag(1).origin, Vector2i(0, 1))
	assert_false(session.translate_whole_layout(Vector2i(-1, 0)))
	assert_eq(session.state.get_bag(1).origin, Vector2i(0, 1), "Failed whole translation must be all-or-nothing")
	assert_eq(session.input_mode, 1, "Failed translation must keep visible whole-layout mode")

	session.exit_whole_layout_move_mode()
	assert_eq(session.input_mode, 0)
	assert_false(session.translate_whole_layout(Vector2i(1, 0)))
	assert_eq(session.state.get_bag(1).origin, Vector2i(0, 1))


func test_whole_layout_translation_is_undoable_without_undoing_mode_switch() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var session = _session(committed)
	if session == null:
		return
	assert_true(session.enter_whole_layout_move_mode())
	assert_true(session.translate_whole_layout(Vector2i(-1, 0)))
	assert_true(session.undo())
	assert_eq(session.state.get_bag(1).origin, Vector2i(1, 1))
	assert_eq(session.input_mode, 1, "Undo changes edit state, not the visible input mode")
	assert_true(session.redo())
	assert_eq(session.state.get_bag(1).origin, Vector2i(0, 1))
	assert_eq(session.input_mode, 1)


func test_commit_failures_are_deterministic_and_include_resolver_reason() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var session = _session(committed)
	if session == null:
		return
	assert_eq(session.commit_failures(0, false, false), [])

	var item_id: int = session.state.add_item(&"shuriken", Vector2i(1, 1))
	assert_gt(item_id, 0)
	# Public state is defensive; seed a fresh session with an item for buffer failure coverage.
	committed = _starting_state()
	item_id = committed.add_item(&"shuriken", Vector2i(1, 1))
	session = _session(committed)
	assert_true(session.move_item_to_buffer(item_id))
	var pending = load(BAG_INSTANCE_PATH).new()
	pending.definition_id = &"small_pouch"
	assert_true(session.set_pending_bag(pending))
	assert_eq(
		session.commit_failures(2, true, true),
		[&"boss_reward_pending", &"chest_pending", &"buffer_not_empty", &"pending_bag", &"combination_pending"]
	)

	var disconnected = _starting_state()
	assert_gt(disconnected.add_bag(&"small_pouch", Vector2i(0, 5)), 0)
	var invalid_session = _session(disconnected)
	assert_eq(invalid_session.commit_failures(0, false, false), [&"disconnected_active_cells"])


func test_public_session_views_and_preview_cannot_bypass_edit_history_authority() -> void:
	var committed = _starting_state()
	if committed == null:
		return
	var item_id: int = committed.add_item(&"shuriken", Vector2i(1, 1))
	var session = _session(committed)
	if session == null:
		return

	var exposed_state = session.state
	assert_true(exposed_state.move_item(item_id, Vector2i(2, 1)))
	assert_eq(session.state.get_item(item_id).origin, Vector2i(1, 1), "Public session state must be defensive")
	assert_false(session.undo(), "Mutating a public view must not create hidden history")

	assert_true(session.move_item_to_buffer(item_id))
	var exposed_buffer = session.buffer
	exposed_buffer[0].origin = Vector2i(4, 3)
	assert_eq(session.buffer[0].origin, Vector2i(1, 1), "Public buffer view must be defensive")
	assert_true(session.undo())

	var preview = session.preview_item(item_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	var exposed_preview_state = preview.state
	assert_true(exposed_preview_state.move_item(item_id, Vector2i(3, 1)))
	assert_true(session.commit_item_preview())
	assert_eq(session.state.get_item(item_id).origin, Vector2i(2, 1), "Returned preview must not mutate the stored commit candidate")


func _session(committed_state, selected_school_id: StringName = &""):
	if not ResourceLoader.exists(SESSION_PATH) or not ResourceLoader.exists(PREVIEW_PATH):
		assert_true(false, "T04 session resources must exist before behavior tests")
		return null
	var session = load(SESSION_PATH).new()
	session.begin(committed_state, _resolver(), _item_defs(), _bag_defs(), selected_school_id)
	return session


func _starting_state():
	if not ResourceLoader.exists(STATE_PATH):
		return null
	return load(STATE_PATH).new().create_starting_state()


func _resolver():
	return load(RESOLVER_PATH).new()


func _item_defs() -> Dictionary:
	return load(CATALOG_PATH).build_items()


func _bag_defs() -> Dictionary:
	return load(CATALOG_PATH).build_bags()
