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


func test_begin_rest_rejects_missing_dependencies_without_changing_committed_backpack() -> void:
	var fixture := _fixture(1401)
	var cases := [
		[null, fixture.build_state, fixture.route, fixture.fate],
		[fixture.original_state, null, fixture.route, fixture.fate],
		[fixture.original_state, fixture.build_state, null, fixture.fate],
		[fixture.original_state, fixture.build_state, fixture.route, null],
	]
	for values in cases:
		var coordinator = load(COORDINATOR_PATH).new()
		coordinator.configure(values[0], values[1], values[2], values[3])
		var before = _backpack_signature(coordinator.committed_backpack_state())
		assert_false(coordinator.begin_rest(fixture.session))
		assert_eq(_backpack_signature(coordinator.committed_backpack_state()), before)
	assert_false(_new_coordinator(fixture).begin_rest(null))


func test_repeated_validation_is_deterministic_and_never_consumes_pending_state() -> void:
	var fixture := _prepared_fixture(1403, &"cheonsul")
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _whole_signature(fixture, coordinator)
	var first: Array[StringName] = coordinator.commit_failures()
	var second: Array[StringName] = coordinator.commit_failures()
	var third: Array[StringName] = coordinator.commit_failures()
	assert_eq(first, [])
	assert_eq(second, first)
	assert_eq(third, first)
	assert_true(fixture.fate._can_commit_pending())
	assert_eq(fixture.route.provisional_school_id(), &"cheonsul")
	assert_eq(_whole_signature(fixture, coordinator), before)


func test_success_detaches_session_and_post_commit_session_mutation_cannot_rewrite_committed_snapshot() -> void:
	var fixture := _prepared_fixture(1405, &"cheonsul")
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	assert_true(coordinator.commit())
	var committed_before = _backpack_signature(coordinator.committed_backpack_state())
	assert_eq(coordinator.commit_failures(), [&"already_committed", &"missing_session"])

	var preview = fixture.session.preview_item(fixture.item_instance_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	assert_true(fixture.session.commit_item_preview())
	assert_ne(_backpack_signature(fixture.session.state), committed_before)
	assert_eq(_backpack_signature(coordinator.committed_backpack_state()), committed_before, "Detached session must not retain live authority over the committed snapshot")


func test_coordinator_can_be_reused_for_a_legitimate_next_rest_after_route_clear() -> void:
	var fixture := _prepared_fixture(1407, &"cheonsul")
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var first_fate: StringName = fixture.pending_fate_id
	assert_true(coordinator.commit())
	assert_true(fixture.build_state.has_fate(first_fate))
	assert_eq(fixture.route.active_school_id(), &"cheonsul")
	assert_true(fixture.route.mark_active_school_cleared())
	assert_eq(fixture.route.stage_index(), 2)

	var second_session = _session_from_state(coordinator.committed_backpack_state(), fixture.item_defs, fixture.bag_defs)
	fixture.fate.begin_rest()
	assert_false(fixture.fate.candidate_ids.has(first_fate))
	var second_fate: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(second_fate))
	assert_true(fixture.route.set_provisional_next_school(&"heukyeong"))
	assert_true(coordinator.begin_rest(second_session))
	assert_true(coordinator.commit())
	assert_eq(fixture.build_state.selected_fates.size(), 2)
	assert_true(fixture.build_state.has_fate(first_fate))
	assert_true(fixture.build_state.has_fate(second_fate))
	assert_eq(fixture.route.active_school_id(), &"heukyeong")
	assert_eq(fixture.route.stage_index(), 2, "Route commit itself must not advance stage")


func test_failed_validation_can_repeat_without_poisoning_later_valid_commit() -> void:
	var fixture := _fixture(1409)
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fate_id))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	for _i in range(5):
		assert_eq(coordinator.commit_failures(), [&"route_pending"])
		assert_false(coordinator.commit())
		assert_false(fixture.build_state.has_fate(fate_id))
		assert_true(fixture.fate._can_commit_pending())
	assert_true(fixture.route.set_provisional_next_school(&"bongma"))
	assert_eq(coordinator.commit_failures(), [])
	assert_true(coordinator.commit())
	assert_true(fixture.build_state.has_fate(fate_id))
	assert_eq(fixture.route.active_school_id(), &"bongma")


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
	var session = _session_from_state(original_state, item_defs, bag_defs)
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
		"original_state": original_state,
		"item_instance_id": item_instance_id,
		"session": session,
		"build_state": build_state,
		"fate": fate,
		"route": route,
	}


func _session_from_state(state, item_defs: Dictionary, bag_defs: Dictionary):
	var session = load(REST_SESSION_PATH).new()
	session.begin(state, load(BACKPACK_RESOLVER_PATH).new(), item_defs, bag_defs, &"guiin")
	return session


func _new_coordinator(fixture: Dictionary):
	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(fixture.original_state, fixture.build_state, fixture.route, fixture.fate)
	return coordinator


func _whole_signature(fixture: Dictionary, coordinator) -> Dictionary:
	return {
		"committed_backpack": _backpack_signature(coordinator.committed_backpack_state()),
		"session": _backpack_signature(fixture.session.state),
		"selected_fates": fixture.build_state.selected_fates.duplicate(),
		"committed_modifiers": _modifier_signature(fixture.build_state.get_committed_backpack_modifiers()),
		"route": fixture.route.get_route_snapshot().duplicate(true),
		"fate_selection": StringName(fixture.fate.selected_this_rest),
		"fate_pending": bool(fixture.fate._can_commit_pending()),
	}


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
	return {"items": item_values, "bags": bag_values, "next_instance_id": int(state.next_instance_id)}


func _modifier_signature(modifiers) -> Dictionary:
	var result := {}
	for field_name in load(MODIFIER_SET_PATH).SUPPORTED_FIELDS:
		result[field_name] = float(modifiers.get(field_name))
	return result
