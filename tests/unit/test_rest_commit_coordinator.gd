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


func test_t12_resource_exists() -> void:
	assert_true(ResourceLoader.exists(COORDINATOR_PATH), "Missing T12 RestCommitCoordinator")


func test_fate_choice_is_pending_until_atomic_commit() -> void:
	var fixture := _new_fixture(1201)
	var fate = fixture.fate
	var build_state = fixture.build_state
	fate.begin_rest()
	var fate_id: StringName = fate.candidate_ids[0]
	assert_true(fate.choose(fate_id))
	assert_eq(fate.selected_this_rest, fate_id)
	assert_true(fate.can_continue())
	assert_false(build_state.has_fate(fate_id), "Pending Fate must not mutate committed RunBuildState")


func test_missing_pending_fate_rejects_commit_without_mutating_any_committed_state() -> void:
	if not ResourceLoader.exists(COORDINATOR_PATH):
		return
	var fixture := _new_fixture(1203)
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _committed_snapshot(fixture, coordinator)
	assert_false(coordinator.commit())
	_assert_committed_snapshot(fixture, coordinator, before)


func test_missing_provisional_route_rejects_commit_without_mutating_any_committed_state() -> void:
	if not ResourceLoader.exists(COORDINATOR_PATH):
		return
	var fixture := _new_fixture(1205)
	fixture.fate.begin_rest()
	assert_true(fixture.fate.choose(fixture.fate.candidate_ids[0]))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _committed_snapshot(fixture, coordinator)
	assert_false(coordinator.commit())
	_assert_committed_snapshot(fixture, coordinator, before)


func test_unresolved_workbench_buffer_rejects_commit_without_mutating_any_committed_state() -> void:
	if not ResourceLoader.exists(COORDINATOR_PATH):
		return
	var fixture := _new_fixture(1207)
	fixture.fate.begin_rest()
	assert_true(fixture.fate.choose(fixture.fate.candidate_ids[0]))
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	assert_true(fixture.session.move_item_to_buffer(fixture.item_instance_id))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _committed_snapshot(fixture, coordinator)
	assert_false(coordinator.commit())
	_assert_committed_snapshot(fixture, coordinator, before)


func test_success_commits_final_backpack_fate_and_latest_provisional_route_exactly_once() -> void:
	if not ResourceLoader.exists(COORDINATOR_PATH):
		return
	var fixture := _new_fixture(1211)
	var preview = fixture.session.preview_item(fixture.item_instance_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	assert_true(fixture.session.commit_item_preview())
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose(fate_id))
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	assert_true(fixture.route.set_provisional_next_school(&"heukyeong"))

	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var expected_modifiers = fixture.session.current_resolution().modifiers.copy_values()
	assert_true(coordinator.commit())

	var committed = coordinator.committed_backpack_state()
	assert_not_null(committed)
	assert_eq(committed.get_item(fixture.item_instance_id).origin, Vector2i(2, 1))
	assert_eq(fixture.original_state.get_item(fixture.item_instance_id).origin, Vector2i(1, 1))
	assert_true(fixture.build_state.has_fate(fate_id))
	assert_eq(fixture.build_state.selected_fates.count(fate_id), 1)
	assert_eq(fixture.route.active_school_id(), &"heukyeong")
	assert_eq(fixture.route.provisional_school_id(), &"")
	_assert_modifier_values_equal(fixture.build_state.get_committed_backpack_modifiers(), expected_modifiers)

	committed.move_item(fixture.item_instance_id, Vector2i(3, 1))
	assert_eq(coordinator.committed_backpack_state().get_item(fixture.item_instance_id).origin, Vector2i(2, 1), "Committed backpack view must be defensive")

	var after := _committed_snapshot(fixture, coordinator)
	assert_false(coordinator.commit())
	_assert_committed_snapshot(fixture, coordinator, after)


func test_commit_failure_reasons_are_read_only_and_identify_missing_fate_and_route() -> void:
	if not ResourceLoader.exists(COORDINATOR_PATH):
		return
	var fixture := _new_fixture(1213)
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _committed_snapshot(fixture, coordinator)
	var failures: Array[StringName] = coordinator.commit_failures()
	assert_true(failures.has(&"fate_pending"))
	assert_true(failures.has(&"route_pending"))
	_assert_committed_snapshot(fixture, coordinator, before)


func _new_fixture(seed_value: int) -> Dictionary:
	var mvp4 = load(MVP4_CATALOG_PATH)
	var mvp3 = load(MVP3_CATALOG_PATH)
	var item_defs: Dictionary = mvp4.build_items()
	var bag_defs: Dictionary = mvp4.build_bags()
	var fate_defs: Dictionary = mvp3.build_fates()

	var original_state = load(BACKPACK_STATE_PATH).new().create_starting_state()
	var item_instance_id: int = original_state.add_item(&"taijutsu_training", Vector2i(1, 1))
	assert_gt(item_instance_id, 0)
	var resolver = load(BACKPACK_RESOLVER_PATH).new()
	var session = load(REST_SESSION_PATH).new()
	session.begin(original_state, resolver, item_defs, bag_defs, &"guiin")

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
		"resolver": resolver,
		"session": session,
		"build_state": build_state,
		"fate": fate,
		"route": route,
	}


func _new_coordinator(fixture: Dictionary):
	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(
		fixture.original_state,
		fixture.build_state,
		fixture.route,
		fixture.fate
	)
	return coordinator


func _committed_snapshot(fixture: Dictionary, coordinator) -> Dictionary:
	return {
		"backpack": _backpack_signature(coordinator.committed_backpack_state()),
		"selected_fates": fixture.build_state.selected_fates.duplicate(),
		"committed_modifiers": _modifier_signature(fixture.build_state.get_committed_backpack_modifiers()),
		"route": fixture.route.get_route_snapshot().duplicate(true),
	}


func _assert_committed_snapshot(fixture: Dictionary, coordinator, expected: Dictionary) -> void:
	assert_eq(_backpack_signature(coordinator.committed_backpack_state()), expected["backpack"])
	assert_eq(fixture.build_state.selected_fates, expected["selected_fates"])
	assert_eq(_modifier_signature(fixture.build_state.get_committed_backpack_modifiers()), expected["committed_modifiers"])
	assert_eq(fixture.route.get_route_snapshot(), expected["route"])


func _backpack_signature(state) -> Dictionary:
	if state == null:
		return {}
	var item_values := {}
	for instance_id in state.items.keys():
		var item = state.items[instance_id]
		item_values[int(instance_id)] = [StringName(item.definition_id), Vector2i(item.origin), int(item.rotation_quarters)]
	var bag_values := {}
	for instance_id in state.bags.keys():
		var bag = state.bags[instance_id]
		bag_values[int(instance_id)] = [StringName(bag.definition_id), Vector2i(bag.origin), int(bag.rotation_quarters)]
	return {
		"items": item_values,
		"bags": bag_values,
		"next_instance_id": int(state.next_instance_id),
	}


func _modifier_signature(modifiers) -> Dictionary:
	var result := {}
	for field_name in load(MODIFIER_SET_PATH).SUPPORTED_FIELDS:
		result[field_name] = float(modifiers.get(field_name))
	return result


func _assert_modifier_values_equal(actual, expected) -> void:
	assert_eq(_modifier_signature(actual), _modifier_signature(expected))
