extends GutTest

const COORDINATOR_PATH := "res://scripts/core/rest_commit_coordinator.gd"
const BACKPACK_STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const BACKPACK_RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const REST_SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const BUILD_STATE_PATH := "res://scripts/core/run_build_state.gd"
const FATE_CONTROLLER_PATH := "res://scripts/core/fate_controller.gd"
const ROUTE_STATE_PATH := "res://scripts/core/run_route_state.gd"
const MVP4_CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MODIFIER_SET_PATH := "res://scripts/data/run_modifier_set.gd"


func test_synchronous_fate_changed_reentrant_commit_is_rejected_and_outer_commit_finishes_once() -> void:
	var fixture := _prepared_fixture(1501, &"cheonsul")
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var reentrant_results: Array[bool] = []
	fixture.build_state.fate_changed.connect(func(_fate_id: StringName):
		reentrant_results.append(coordinator.commit())
	)
	assert_true(coordinator.commit())
	assert_eq(reentrant_results, [false], "Route/Fate guards must reject synchronous reentrant commit")
	assert_eq(fixture.build_state.selected_fates.size(), 1)
	assert_eq(fixture.route.active_school_id(), &"cheonsul")
	assert_eq(fixture.route.provisional_school_id(), &"")
	assert_false(coordinator.commit())
	assert_eq(fixture.build_state.selected_fates.size(), 1)


func test_synchronous_fate_changed_reentrant_begin_rest_is_rejected_while_outer_transaction_is_active() -> void:
	var fixture := _prepared_fixture(1503, &"bongma")
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var reentrant_begin_results: Array[bool] = []
	fixture.build_state.fate_changed.connect(func(_fate_id: StringName):
		reentrant_begin_results.append(coordinator.begin_rest(fixture.session))
	)
	assert_true(coordinator.commit())
	assert_eq(reentrant_begin_results, [false], "One active T12 transaction must reject session rebinding, including synchronous signal reentry")
	assert_eq(coordinator.commit_failures(), [&"already_committed", &"missing_session"])
	var committed_before := _backpack_signature(coordinator.committed_backpack_state())
	var preview = fixture.session.preview_item(fixture.item_instance_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	assert_true(fixture.session.commit_item_preview())
	assert_eq(_backpack_signature(coordinator.committed_backpack_state()), committed_before)


func test_t07_acquired_item_keeps_instance_identity_and_future_cursor_through_t12_commit() -> void:
	var fixture := _fixture(1505)
	var created: Array[int] = fixture.session._acquire_items_to_buffer([&"shuriken"])
	assert_eq(created.size(), 1)
	var acquired_id: int = created[0]
	var cursor_after_acquire: int = fixture.session.state.next_instance_id
	assert_true(fixture.session.place_buffer_item(0, Vector2i(2, 1), 0))
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fate_id))
	assert_true(fixture.route.set_provisional_next_school(&"heukyeong"))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	assert_true(coordinator.commit())
	var committed = coordinator.committed_backpack_state()
	assert_not_null(committed.get_item(acquired_id))
	assert_eq(committed.get_item(acquired_id).definition_id, &"shuriken")
	assert_eq(committed.get_item(acquired_id).origin, Vector2i(2, 1))
	assert_eq(committed.next_instance_id, cursor_after_acquire, "T12 must preserve T07/T02 monotonic identity cursor")


func test_final_modifiers_equal_independent_backpack_then_fate_composition_once() -> void:
	var fixture := _fixture(1507)
	var preview = fixture.session.preview_item(fixture.item_instance_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	assert_true(fixture.session.commit_item_preview())
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fate_id))
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	var expected_build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(expected_build_state)
	expected_build_state.configure(fixture.item_defs, fixture.fate_defs)
	expected_build_state.set_selected_school(&"guiin")
	expected_build_state.set_committed_backpack_modifiers(fixture.session.current_resolution().modifiers)
	assert_true(expected_build_state.select_fate(fate_id))
	var expected := _modifier_signature(expected_build_state.get_modifiers())

	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	assert_true(coordinator.commit())
	assert_eq(_modifier_signature(fixture.build_state.get_modifiers()), expected, "Coordinator must compose committed backpack + Fate exactly once")


func test_pending_selection_signal_remains_intent_only_before_atomic_commit() -> void:
	var fixture := _fixture(1509)
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	var observations: Array[Dictionary] = []
	fixture.fate.fate_selected.connect(func(emitted_id: StringName):
		observations.append({
			"fate_id": emitted_id,
			"committed": fixture.build_state.has_fate(emitted_id),
			"route_active": fixture.route.active_school_id(),
			"route_provisional": fixture.route.provisional_school_id(),
		})
	)
	assert_true(fixture.route.set_provisional_next_school(&"bongma"))
	assert_true(fixture.fate.choose_pending(fate_id))
	assert_eq(observations.size(), 1)
	assert_eq(observations[0]["fate_id"], fate_id)
	assert_false(bool(observations[0]["committed"]))
	assert_eq(observations[0]["route_active"], &"")
	assert_eq(observations[0]["route_provisional"], &"bongma")


func _prepared_fixture(seed_value: int, route_id: StringName) -> Dictionary:
	var fixture := _fixture(seed_value)
	fixture.fate.begin_rest()
	fixture["pending_fate_id"] = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fixture.pending_fate_id))
	assert_true(fixture.route.set_provisional_next_school(route_id))
	return fixture


func _fixture(seed_value: int) -> Dictionary:
	var mvp4 = load(MVP4_CATALOG_PATH)
	var mvp3 = load(MVP3_CATALOG_PATH)
	var item_defs: Dictionary = mvp4.build_items()
	var bag_defs: Dictionary = mvp4.build_bags()
	var fate_defs: Dictionary = mvp3.build_fates()
	var original_state = load(BACKPACK_STATE_PATH).new().create_starting_state()
	var item_instance_id: int = original_state.add_item(&"taijutsu_training", Vector2i(1, 1))
	assert_gt(item_instance_id, 0)
	var session = load(REST_SESSION_PATH).new()
	session.begin(original_state, load(BACKPACK_RESOLVER_PATH).new(), item_defs, bag_defs, &"guiin")
	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(item_defs, fate_defs)
	build_state.set_selected_school(&"guiin")
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var fate = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(fate)
	fate.configure(build_state, fate_defs, rng)
	var route = load(ROUTE_STATE_PATH).new()
	return {
		"item_defs": item_defs,
		"bag_defs": bag_defs,
		"fate_defs": fate_defs,
		"original_state": original_state,
		"item_instance_id": item_instance_id,
		"session": session,
		"build_state": build_state,
		"fate": fate,
		"route": route,
	}


func _new_coordinator(fixture: Dictionary):
	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(fixture.original_state, fixture.build_state, fixture.route, fixture.fate)
	return coordinator


func _backpack_signature(state) -> Dictionary:
	if state == null:
		return {}
	var item_values := {}
	for instance_id in state.items.keys():
		var item = state.items[instance_id]
		item_values[int(instance_id)] = [StringName(item.definition_id), Vector2i(item.origin), int(item.rotation_quarters)]
	return {"items": item_values, "next_instance_id": int(state.next_instance_id)}


func _modifier_signature(modifiers) -> Dictionary:
	var result := {}
	for field_name in load(MODIFIER_SET_PATH).SUPPORTED_FIELDS:
		result[field_name] = float(modifiers.get(field_name))
	return result