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

const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]


func test_t12_atomic_workbench_commit_rejects_route_before_any_school_has_been_cleared() -> void:
	var fixture := _fixture(1599, &"guiin")
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fate_id))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var failures: Array[StringName] = coordinator.commit_failures()
	assert_true(failures.has(&"route_pending"), "DEC-025 T12 atomic Workbench commit applies only after at least one school clear; first battlefield uses separate confirmation")
	assert_false(coordinator.commit())
	assert_false(fixture.build_state.has_fate(fate_id))
	assert_eq(fixture.route.active_school_id(), &"")
	assert_eq(fixture.route.provisional_school_id(), &"cheonsul")


func test_all_twelve_cleared_school_to_next_school_contexts_commit_without_changing_selected_school_identity() -> void:
	var case_index := 0
	for current_school in SCHOOL_IDS:
		for next_school in SCHOOL_IDS:
			if next_school == current_school:
				continue
			var fixture := _fixture(1600 + case_index, current_school)
			case_index += 1
			assert_true(fixture.route.set_provisional_next_school(current_school))
			assert_true(fixture.route.commit_provisional_next_school())
			assert_true(fixture.route.mark_active_school_cleared())
			assert_eq(fixture.route.stage_index(), 2)
			assert_true(fixture.route.is_school_unvisited(next_school))
			assert_true(fixture.route.set_provisional_next_school(next_school))
			fixture.fate.begin_rest()
			var fate_id: StringName = fixture.fate.candidate_ids[0]
			assert_true(fixture.fate.choose_pending(fate_id))
			var coordinator = _new_coordinator(fixture)
			assert_true(coordinator.begin_rest(fixture.session))
			assert_true(coordinator.commit(), "%s -> %s must be a legal T12 commit" % [current_school, next_school])
			assert_eq(fixture.route.active_school_id(), next_school)
			assert_eq(fixture.route.provisional_school_id(), &"")
			assert_eq(fixture.route.stage_index(), 2, "T12 route commit must not advance stage")
			assert_eq(fixture.build_state.selected_school_id, current_school, "T12 must not pre-activate next-school combat identity")
			assert_true(fixture.build_state.has_fate(fate_id))
	assert_eq(case_index, 12)


func test_provisional_route_replacement_after_current_clear_commits_only_latest_choice() -> void:
	var fixture := _fixture(1620, &"bongma")
	assert_true(fixture.route.set_provisional_next_school(&"bongma"))
	assert_true(fixture.route.commit_provisional_next_school())
	assert_true(fixture.route.mark_active_school_cleared())
	assert_true(fixture.route.set_provisional_next_school(&"cheonsul"))
	assert_true(fixture.route.set_provisional_next_school(&"guiin"))
	assert_true(fixture.route.set_provisional_next_school(&"heukyeong"))
	fixture.fate.begin_rest()
	assert_true(fixture.fate.choose_pending(fixture.fate.candidate_ids[0]))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	assert_true(coordinator.commit())
	assert_eq(fixture.route.active_school_id(), &"heukyeong")
	assert_true(fixture.route.is_school_unvisited(&"cheonsul"))
	assert_true(fixture.route.is_school_unvisited(&"guiin"))


func test_failed_revisit_request_does_not_replace_valid_provisional_route_before_commit() -> void:
	var fixture := _fixture(1622, &"guiin")
	assert_true(fixture.route.set_provisional_next_school(&"guiin"))
	assert_true(fixture.route.commit_provisional_next_school())
	assert_true(fixture.route.mark_active_school_cleared())
	assert_true(fixture.route.set_provisional_next_school(&"bongma"))
	assert_false(fixture.route.set_provisional_next_school(&"guiin"))
	assert_eq(fixture.route.provisional_school_id(), &"bongma")
	fixture.fate.begin_rest()
	var fate_id: StringName = fixture.fate.candidate_ids[0]
	assert_true(fixture.fate.choose_pending(fate_id))
	var coordinator = _new_coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	assert_true(coordinator.commit())
	assert_eq(fixture.route.active_school_id(), &"bongma")
	assert_eq(fixture.build_state.selected_school_id, &"guiin")
	assert_true(fixture.build_state.has_fate(fate_id))


func test_coordinator_source_does_not_absorb_t13_ui_main_reward_or_stageflow_authority() -> void:
	var source := FileAccess.get_file_as_string(COORDINATOR_PATH)
	for forbidden_path in [
		"main_controller.gd",
		"rest_flow_ui.gd",
		"shop_controller.gd",
		"rest_reward_controller.gd",
		"stage_flow_controller.gd",
		"stage_encounter_state.gd",
	]:
		assert_false(source.contains(forbidden_path), "T12 coordinator must not preload/absorb later or unrelated owner: %s" % forbidden_path)
	for forbidden_method in ["set_selected_school", "grant_gold", "select_fate(", "mark_active_school_cleared"]:
		assert_false(source.contains(forbidden_method), "T12 must consume existing narrow owner APIs, not absorb extra authority: %s" % forbidden_method)


func test_fate_controller_keeps_legacy_adapter_and_atomic_path_explicitly_separate_without_route_or_backpack_imports() -> void:
	var source := FileAccess.get_file_as_string(FATE_CONTROLLER_PATH)
	assert_true(source.contains("func choose(fate_id"))
	assert_true(source.contains("func choose_pending(fate_id"))
	assert_true(source.contains("func _commit_pending()"))
	assert_false(source.contains("run_route_state.gd"))
	assert_false(source.contains("rest_backpack_session.gd"))
	assert_false(source.contains("rest_commit_coordinator.gd"))
	assert_false(source.contains("func commit_fate"), "No generic public Fate commit bypass")


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
		"session": session,
		"build_state": build_state,
		"fate": fate,
		"route": route,
	}


func _new_coordinator(fixture: Dictionary):
	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(fixture.original_state, fixture.build_state, fixture.route, fixture.fate)
	return coordinator