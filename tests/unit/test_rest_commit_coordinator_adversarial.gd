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
const BAG_INSTANCE_PATH := "res://scripts/data/bag_instance.gd"


func test_each_independent_rest_blocker_is_atomic_and_preserves_pending_inputs() -> void:
	var blockers := [
		"buffer",
		"pending_bag",
		"item_preview",
		"whole_layout",
		"combination_active",
		"chest_flag",
		"boss_flag",
		"combination_flag",
	]
	for index in range(blockers.size()):
		var fixture := _prepared_fixture(1300 + index)
		var blocker: String = blockers[index]
		var chest_count := 0
		var boss_pending := false
		var combination_pending := false
		match blocker:
			"buffer":
				assert_true(fixture.session.move_item_to_buffer(fixture.item_instance_id))
			"pending_bag":
				var pending = load(BAG_INSTANCE_PATH).new()
				pending.definition_id = &"small_pouch"
				assert_true(fixture.session.set_pending_bag(pending))
			"item_preview":
				var preview = fixture.session.preview_item(fixture.item_instance_id, Vector2i(2, 1), 0)
				assert_true(preview.valid)
			"whole_layout":
				assert_true(fixture.session.enter_whole_layout_move_mode())
			"combination_active":
				assert_true(fixture.session._begin_combination_transaction())
			"chest_flag":
				chest_count = 1
			"boss_flag":
				boss_pending = true
			"combination_flag":
				combination_pending = true

		var coordinator = _new_coordinator(fixture)
		assert_true(coordinator.begin_rest(fixture.session))
		var before := _whole_snapshot(fixture, coordinator)
		var failures: Array[StringName] = coordinator.commit_failures(chest_count, boss_pending, combination_pending)
		assert_false(failures.is_empty(), "Expected blocker to be reported: %s" % blocker)
		assert_false(coordinator.commit(chest_count, boss_pending, combination_pending), "Blocked commit must fail: %s" % blocker)
		_assert_whole_snapshot(fixture, coordinator, before, blocker)


func test_legacy_immediate_choose_never_satisfies_t12_pending_commit_gate() -> void:
	var fixture := _base_fixture(1320)
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose(fate_id))
	assert_true(fixture.build_state.has_fate(fate_id))
	assert_false(fixture.fate._can_commit_pending())
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _whole_snapshot(fixture, coordinator)
	assert_true(coordinator.commit_failures().has(&"fate_pending"))
	assert_false(coordinator.commit())
	_assert_whole_snapshot(fixture, coordinator, before, "legacy Fate compatibility path")


func test_stale_pending_fate_that_was_committed_elsewhere_fails_closed() -> void:
	var fixture := _base_fixture(1321)
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fate_id))
	assert_true(fixture.build_state.select_fate(fate_id), "Simulate stale external commit before coordinator")
	assert_false(fixture.fate._can_commit_pending())
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _whole_snapshot(fixture, coordinator)
	assert_true(coordinator.commit_failures().has(&"fate_pending"))
	assert_false(coordinator.commit())
	_assert_whole_snapshot(fixture, coordinator, before, "stale pending Fate")


func test_abandoned_pending_fate_is_reset_and_cannot_be_committed_by_coordinator() -> void:
	var fixture := _base_fixture(1322)
	fixture.fate.begin_rest()
	var abandoned: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(abandoned))
	fixture.fate.begin_rest()
	assert_false(fixture.build_state.has_fate(abandoned))
	assert_false(fixture.fate._can_commit_pending())
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _whole_snapshot(fixture, coordinator)
	assert_false(coordinator.commit())
	_assert_whole_snapshot(fixture, coordinator, before, "abandoned pending Fate")


func test_failed_preview_block_can_be_resolved_then_same_transaction_commits_once() -> void:
	var fixture := _prepared_fixture(1330)
	var preview = fixture.session.preview_item(fixture.item_instance_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _whole_snapshot(fixture, coordinator)
	assert_true(coordinator.commit_failures().has(&"item_preview_pending"))
	assert_false(coordinator.commit())
	_assert_whole_snapshot(fixture, coordinator, before, "preview before resolution")

	assert_true(fixture.session.commit_item_preview())
	assert_true(coordinator.commit())
	assert_true(fixture.build_state.has_fate(fixture.pending_fate_id))
	assert_eq(fixture.route.active_school_id(), &"cheonsul")
	assert_eq(coordinator.committed_backpack_state().get_item(fixture.item_instance_id).origin, Vector2i(2, 1))
	var after := _whole_snapshot(fixture, coordinator)
	assert_false(coordinator.commit())
	_assert_whole_snapshot(fixture, coordinator, after, "duplicate commit")


func test_fate_changed_observer_sees_route_backpack_modifiers_and_fate_as_one_coherent_tuple() -> void:
	var fixture := _base_fixture(1340)
	var preview = fixture.session.preview_item(fixture.item_instance_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	assert_true(fixture.session.commit_item_preview())
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fate_id))
	assert_true(fixture.route.set_provisional_next_school(&"heukyeong"))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var expected_modifiers := _modifier_signature(fixture.session.current_resolution().modifiers)
	var observed := {}
	fixture.build_state.fate_changed.connect(func(emitted_fate_id: StringName):
		observed["fate_id"] = emitted_fate_id
		observed["has_fate"] = fixture.build_state.has_fate(emitted_fate_id)
		observed["route_active"] = fixture.route.active_school_id()
		observed["route_provisional"] = fixture.route.provisional_school_id()
		observed["backpack_origin"] = coordinator.committed_backpack_state().get_item(fixture.item_instance_id).origin
		observed["committed_modifiers"] = _modifier_signature(fixture.build_state.get_committed_backpack_modifiers())
	)

	assert_true(coordinator.commit())
	assert_eq(observed.get("fate_id", &""), fate_id)
	assert_true(bool(observed.get("has_fate", false)))
	assert_eq(observed.get("route_active", &""), &"heukyeong")
	assert_eq(observed.get("route_provisional", &"missing"), &"")
	assert_eq(observed.get("backpack_origin", Vector2i(-1, -1)), Vector2i(2, 1))
	assert_eq(observed.get("committed_modifiers", {}), expected_modifiers)


func test_representative_route_prefixes_commit_only_latest_legal_unvisited_school_without_advancing_stage() -> void:
	var prefixes := [
		[],
		[&"bongma"],
		[&"bongma", &"cheonsul"],
		[&"bongma", &"cheonsul", &"guiin"],
	]
	for index in range(prefixes.size()):
		var fixture := _base_fixture(1350 + index)
		_apply_clear_prefix(fixture.route, prefixes[index])
		var stage_before: int = fixture.route.stage_index()
		var unvisited: Array[StringName] = fixture.route.get_unvisited_schools()
		assert_false(unvisited.is_empty())
		var first_candidate: StringName = unvisited[0]
		var latest_candidate: StringName = unvisited[unvisited.size() - 1]
		assert_true(fixture.route.set_provisional_next_school(first_candidate))
		assert_true(fixture.route.set_provisional_next_school(latest_candidate))
		fixture.fate.begin_rest()
		var fate_id: StringName = fixture.fate.candidate_ids[0]
		assert_true(fixture.fate.choose_pending(fate_id))
		var coordinator = _new_coordinator(fixture)
		assert_true(coordinator.begin_rest(fixture.session))
		assert_true(coordinator.commit())
		assert_eq(fixture.route.active_school_id(), latest_candidate)
		assert_eq(fixture.route.provisional_school_id(), &"")
		assert_eq(fixture.route.stage_index(), stage_before, "Route commit must not advance Stage")
		assert_true(fixture.build_state.has_fate(fate_id))


func test_final_binding_route_state_rejects_t12_commit_without_partial_mutation() -> void:
	var fixture := _base_fixture(1360)
	_apply_clear_prefix(fixture.route, [&"bongma", &"cheonsul", &"guiin", &"heukyeong"])
	assert_true(fixture.route.is_final_binding_eligible())
	fixture.fate.begin_rest()
	assert_true(fixture.fate.choose_pending(fixture.fate.candidate_ids[0]))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var before := _whole_snapshot(fixture, coordinator)
	assert_true(coordinator.commit_failures().has(&"route_pending"))
	assert_false(coordinator.commit())
	_assert_whole_snapshot(fixture, coordinator, before, "final binding route")


func test_pending_commit_bridge_rejects_unoffered_stale_and_legacy_selection() -> void:
	var unoffered := _base_fixture(1370)
	unoffered.fate.begin_rest()
	assert_false(unoffered.fate._commit_pending())

	var legacy := _base_fixture(1371)
	legacy.fate.begin_rest()
	assert_true(legacy.fate.choose(legacy.fate.candidate_ids[0]))
	assert_false(legacy.fate._commit_pending())

	var stale := _base_fixture(1372)
	stale.fate.begin_rest()
	var stale_id: StringName = stale.fate.candidate_ids[0]
	assert_true(stale.fate.choose_pending(stale_id))
	assert_true(stale.build_state.select_fate(stale_id))
	assert_false(stale.fate._commit_pending())


func test_committed_backpack_is_defensive_and_coordinator_exposes_no_generic_authority_bypass() -> void:
	var fixture := _prepared_fixture(1380)
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	assert_true(coordinator.commit())
	var view = coordinator.committed_backpack_state()
	view.remove_item(fixture.item_instance_id)
	assert_not_null(coordinator.committed_backpack_state().get_item(fixture.item_instance_id))
	for method_name in [
		"force_commit",
		"set_route",
		"set_fate",
		"set_backpack_state",
		"move_item",
		"add_item",
		"grant_item",
	]:
		assert_false(coordinator.has_method(method_name), "Coordinator must not expose generic authority bypass: %s" % method_name)
	assert_false(fixture.fate.has_method("commit_fate"), "FateController must not expose a generic public commit bypass")


func _prepared_fixture(seed_value: int, route_id: StringName = &"cheonsul") -> Dictionary:
	var fixture := _base_fixture(seed_value)
	fixture.fate.begin_rest()
	fixture["pending_fate_id"] = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fixture.pending_fate_id))
	assert_true(fixture.route.set_provisional_next_school(route_id))
	return fixture


func _base_fixture(seed_value: int) -> Dictionary:
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
	coordinator.configure(fixture.original_state, fixture.build_state, fixture.route, fixture.fate)
	return coordinator


func _apply_clear_prefix(route, prefix: Array) -> void:
	for school_id in prefix:
		assert_true(route.set_provisional_next_school(StringName(school_id)))
		assert_true(route.commit_provisional_next_school())
		assert_true(route.mark_active_school_cleared())


func _whole_snapshot(fixture: Dictionary, coordinator) -> Dictionary:
	return {
		"committed_backpack": _backpack_signature(coordinator.committed_backpack_state()),
		"selected_fates": fixture.build_state.selected_fates.duplicate(),
		"committed_modifiers": _modifier_signature(fixture.build_state.get_committed_backpack_modifiers()),
		"route": fixture.route.get_route_snapshot().duplicate(true),
		"session_state": _backpack_signature(fixture.session.state),
		"buffer": _buffer_signature(fixture.session.buffer),
		"pending_bag": _bag_signature(fixture.session.pending_bag),
		"input_mode": int(fixture.session.input_mode),
		"combination_active": bool(fixture.session.combination_transaction_active),
		"fate_selected_this_rest": StringName(fixture.fate.selected_this_rest),
		"fate_pending_valid": bool(fixture.fate._can_commit_pending()),
	}


func _assert_whole_snapshot(fixture: Dictionary, coordinator, expected: Dictionary, context: String) -> void:
	assert_eq(_backpack_signature(coordinator.committed_backpack_state()), expected["committed_backpack"], context)
	assert_eq(fixture.build_state.selected_fates, expected["selected_fates"], context)
	assert_eq(_modifier_signature(fixture.build_state.get_committed_backpack_modifiers()), expected["committed_modifiers"], context)
	assert_eq(fixture.route.get_route_snapshot(), expected["route"], context)
	assert_eq(_backpack_signature(fixture.session.state), expected["session_state"], context)
	assert_eq(_buffer_signature(fixture.session.buffer), expected["buffer"], context)
	assert_eq(_bag_signature(fixture.session.pending_bag), expected["pending_bag"], context)
	assert_eq(int(fixture.session.input_mode), expected["input_mode"], context)
	assert_eq(bool(fixture.session.combination_transaction_active), expected["combination_active"], context)
	assert_eq(StringName(fixture.fate.selected_this_rest), expected["fate_selected_this_rest"], context)
	assert_eq(bool(fixture.fate._can_commit_pending()), expected["fate_pending_valid"], context)


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


func _buffer_signature(buffer: Array) -> Array:
	var result: Array = []
	for item in buffer:
		result.append([int(item.instance_id), StringName(item.definition_id), Vector2i(item.origin), int(item.rotation_quarters)])
	return result


func _bag_signature(bag) -> Array:
	if bag == null:
		return []
	return [int(bag.instance_id), StringName(bag.definition_id), Vector2i(bag.origin), int(bag.rotation_quarters)]


func _modifier_signature(modifiers) -> Dictionary:
	var result := {}
	for field_name in load(MODIFIER_SET_PATH).SUPPORTED_FIELDS:
		result[field_name] = float(modifiers.get(field_name))
	return result
