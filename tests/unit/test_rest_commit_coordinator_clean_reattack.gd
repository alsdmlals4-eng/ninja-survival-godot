extends GutTest

const COORDINATOR_PATH := "res://scripts/core/rest_commit_coordinator.gd"
const FATE_CONTROLLER_PATH := "res://scripts/core/fate_controller.gd"
const BACKPACK_STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const BACKPACK_RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const REST_SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const BUILD_STATE_PATH := "res://scripts/core/run_build_state.gd"
const ROUTE_STATE_PATH := "res://scripts/core/run_route_state.gd"
const MVP4_CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MODIFIER_SET_PATH := "res://scripts/data/run_modifier_set.gd"


func test_clean_full_post_clear_transaction_commits_backpack_fate_and_next_route_exactly_once() -> void:
	var fixture := _fixture(1701, &"bongma")
	assert_true(fixture.route.set_provisional_next_school(&"bongma"))
	assert_true(fixture.route.commit_provisional_next_school())
	assert_true(fixture.route.mark_active_school_cleared())
	assert_eq(fixture.route.stage_index(), 2)

	var preview = fixture.session.preview_item(fixture.item_instance_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	assert_true(fixture.session.commit_item_preview())
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fate_id))
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	var expected_modifiers := _modifier_signature(fixture.session.current_resolution().modifiers)

	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	assert_eq(coordinator.commit_failures(), [])
	assert_true(coordinator.commit())
	assert_eq(coordinator.committed_backpack_state().get_item(fixture.item_instance_id).origin, Vector2i(2, 1))
	assert_eq(_modifier_signature(fixture.build_state.get_committed_backpack_modifiers()), expected_modifiers)
	assert_true(fixture.build_state.has_fate(fate_id))
	assert_eq(fixture.build_state.selected_fates.count(fate_id), 1)
	assert_eq(fixture.route.active_school_id(), &"cheonsul")
	assert_eq(fixture.route.provisional_school_id(), &"")
	assert_eq(fixture.route.stage_index(), 2)
	assert_eq(fixture.build_state.selected_school_id, &"bongma", "Next route commit must not pre-activate next-school combat identity")

	var after := _committed_signature(fixture, coordinator)
	assert_false(coordinator.commit())
	assert_eq(_committed_signature(fixture, coordinator), after, "Duplicate commit must be a total committed-state noop")


func test_clean_independent_gate_families_fail_closed_without_committed_state_drift() -> void:
	# Missing Fate.
	var missing_fate := _fixture(1703, &"guiin")
	assert_true(missing_fate.route.set_provisional_next_school(&"cheonsul"))
	var missing_fate_coordinator = _new_coordinator(missing_fate)
	assert_true(missing_fate_coordinator.begin_rest(missing_fate.session))
	var missing_fate_before := _committed_signature(missing_fate, missing_fate_coordinator)
	assert_true(missing_fate_coordinator.commit_failures().has(&"fate_pending"))
	assert_false(missing_fate_coordinator.commit())
	assert_eq(_committed_signature(missing_fate, missing_fate_coordinator), missing_fate_before)

	# Missing route.
	var missing_route := _fixture(1705, &"guiin")
	missing_route.fate.begin_rest()
	assert_true(missing_route.fate.choose_pending(missing_route.fate.candidate_ids[0]))
	var missing_route_coordinator = _new_coordinator(missing_route)
	assert_true(missing_route_coordinator.begin_rest(missing_route.session))
	var missing_route_before := _committed_signature(missing_route, missing_route_coordinator)
	assert_true(missing_route_coordinator.commit_failures().has(&"route_pending"))
	assert_false(missing_route_coordinator.commit())
	assert_eq(_committed_signature(missing_route, missing_route_coordinator), missing_route_before)

	# Unresolved T04 Workbench state.
	var unresolved := _prepared_fixture(1707, &"cheonsul")
	assert_true(unresolved.session.move_item_to_buffer(unresolved.item_instance_id))
	var unresolved_coordinator = _new_coordinator(unresolved)
	assert_true(unresolved_coordinator.begin_rest(unresolved.session))
	var unresolved_before := _committed_signature(unresolved, unresolved_coordinator)
	assert_true(unresolved_coordinator.commit_failures().has(&"buffer_not_empty"))
	assert_false(unresolved_coordinator.commit())
	assert_eq(_committed_signature(unresolved, unresolved_coordinator), unresolved_before)

	# Reward/combination external blockers.
	for blocker in [
		{"chest": 1, "boss": false, "combination": false},
		{"chest": 0, "boss": true, "combination": false},
		{"chest": 0, "boss": false, "combination": true},
	]:
		var blocked := _prepared_fixture(1710 + int(blocker["chest"]) + int(blocker["boss"]) * 2 + int(blocker["combination"]) * 4, &"heukyeong")
		var blocked_coordinator = _new_coordinator(blocked)
		assert_true(blocked_coordinator.begin_rest(blocked.session))
		var blocked_before := _committed_signature(blocked, blocked_coordinator)
		assert_false(blocked_coordinator.commit(int(blocker["chest"]), bool(blocker["boss"]), bool(blocker["combination"])))
		assert_eq(_committed_signature(blocked, blocked_coordinator), blocked_before)


func test_clean_legacy_and_atomic_fate_paths_remain_explicitly_separate_until_t13() -> void:
	var legacy := _fixture(1721, &"guiin")
	legacy.fate.begin_rest()
	var legacy_fate: StringName = legacy.fate.candidate_ids[0]
	assert_true(legacy.fate.choose(legacy_fate))
	assert_true(legacy.build_state.has_fate(legacy_fate))
	assert_false(legacy.fate._can_commit_pending())
	assert_true(legacy.route.set_provisional_next_school(&"bongma"))
	var legacy_coordinator = _new_coordinator(legacy)
	assert_true(legacy_coordinator.begin_rest(legacy.session))
	assert_true(legacy_coordinator.commit_failures().has(&"fate_pending"))
	assert_false(legacy_coordinator.commit())

	var atomic := _prepared_fixture(1723, &"bongma")
	var pending_fate: StringName = atomic.pending_fate_id
	assert_false(atomic.build_state.has_fate(pending_fate))
	assert_true(atomic.fate._can_commit_pending())
	var atomic_coordinator = _new_coordinator(atomic)
	assert_true(atomic_coordinator.begin_rest(atomic.session))
	assert_true(atomic_coordinator.commit())
	assert_true(atomic.build_state.has_fate(pending_fate))
	assert_false(atomic.fate._can_commit_pending())


func test_clean_t07_identity_observer_coherence_and_defensive_snapshot_hold_together() -> void:
	var fixture := _fixture(1731, &"guiin")
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
	var expected_modifiers := _modifier_signature(fixture.session.current_resolution().modifiers)
	var observed := {}
	fixture.build_state.fate_changed.connect(func(emitted_fate_id: StringName):
		var committed = coordinator.committed_backpack_state()
		observed["fate"] = emitted_fate_id
		observed["has_fate"] = fixture.build_state.has_fate(emitted_fate_id)
		observed["route"] = fixture.route.active_school_id()
		observed["origin"] = committed.get_item(acquired_id).origin
		observed["cursor"] = committed.next_instance_id
		observed["modifiers"] = _modifier_signature(fixture.build_state.get_committed_backpack_modifiers())
	)

	assert_true(coordinator.commit())
	assert_eq(observed.get("fate", &""), fate_id)
	assert_true(bool(observed.get("has_fate", false)))
	assert_eq(observed.get("route", &""), &"heukyeong")
	assert_eq(observed.get("origin", Vector2i(-1, -1)), Vector2i(2, 1))
	assert_eq(int(observed.get("cursor", -1)), cursor_after_acquire)
	assert_eq(observed.get("modifiers", {}), expected_modifiers)

	var view = coordinator.committed_backpack_state()
	assert_not_null(view.get_item(acquired_id))
	view.remove_item(acquired_id)
	assert_not_null(coordinator.committed_backpack_state().get_item(acquired_id), "Public committed backpack view must remain defensive")


func test_clean_final_source_boundary_contains_no_t13_or_generic_authority_bypass() -> void:
	var coordinator = load(COORDINATOR_PATH).new()
	for method_name in [
		"force_commit",
		"set_route",
		"set_fate",
		"set_selected_school",
		"grant_gold",
		"move_item",
		"add_item",
		"commit_fate",
	]:
		assert_false(coordinator.has_method(method_name), "T12 must not expose generic authority bypass: %s" % method_name)

	var coordinator_source := FileAccess.get_file_as_string(COORDINATOR_PATH)
	for forbidden in [
		"main_controller.gd",
		"rest_flow_ui.gd",
		"shop_controller.gd",
		"rest_reward_controller.gd",
		"stage_flow_controller.gd",
		"stage_encounter_state.gd",
	]:
		assert_false(coordinator_source.contains(forbidden), "T12 must not absorb T13/T14 or unrelated owner: %s" % forbidden)

	var fate_source := FileAccess.get_file_as_string(FATE_CONTROLLER_PATH)
	assert_true(fate_source.contains("func choose(fate_id"))
	assert_true(fate_source.contains("func choose_pending(fate_id"))
	assert_true(fate_source.contains("func _commit_pending()"))
	assert_false(fate_source.contains("func commit_fate"))
	assert_false(fate_source.contains("run_route_state.gd"))
	assert_false(fate_source.contains("rest_backpack_session.gd"))


func _prepared_fixture(seed_value: int, route_id: StringName) -> Dictionary:
	var fixture := _fixture(seed_value, &"guiin")
	fixture.fate.begin_rest()
	fixture["pending_fate_id"] = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fixture.pending_fate_id))
	assert_true(fixture.route.set_provisional_next_school(route_id))
	return fixture


func _fixture(seed_value: int, selected_school_id: StringName) -> Dictionary:
	var mvp4 = load(MVP4_CATALOG_PATH)
	var mvp3 = load(MVP3_CATALOG_PATH)
	var item_defs: Dictionary = mvp4.build_items()
	var bag_defs: Dictionary = mvp4.build_bags()
	var fate_defs: Dictionary = mvp3.build_fates()
	var original_state = load(BACKPACK_STATE_PATH).new().create_starting_state()
	var item_instance_id: int = original_state.add_item(&"taijutsu_training", Vector2i(1, 1))
	assert_gt(item_instance_id, 0)
	var session = load(REST_SESSION_PATH).new()
	session.begin(original_state, load(BACKPACK_RESOLVER_PATH).new(), item_defs, bag_defs, selected_school_id)
	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(item_defs, fate_defs)
	build_state.set_selected_school(selected_school_id)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var fate = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(fate)
	fate.configure(build_state, fate_defs, rng)
	var route = load(ROUTE_STATE_PATH).new()
	return {
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


func _committed_signature(fixture: Dictionary, coordinator) -> Dictionary:
	return {
		"backpack": _backpack_signature(coordinator.committed_backpack_state()),
		"fates": fixture.build_state.selected_fates.duplicate(),
		"modifiers": _modifier_signature(fixture.build_state.get_committed_backpack_modifiers()),
		"route": fixture.route.get_route_snapshot().duplicate(true),
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
