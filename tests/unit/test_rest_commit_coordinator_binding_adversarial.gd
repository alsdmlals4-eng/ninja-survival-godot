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


func test_coordinator_requires_fate_controller_to_share_the_same_build_state_authority() -> void:
	var mvp4 = load(MVP4_CATALOG_PATH)
	var mvp3 = load(MVP3_CATALOG_PATH)
	var item_defs: Dictionary = mvp4.build_items()
	var bag_defs: Dictionary = mvp4.build_bags()
	var fate_defs: Dictionary = mvp3.build_fates()
	var original_state = load(BACKPACK_STATE_PATH).new().create_starting_state()
	var session = load(REST_SESSION_PATH).new()
	session.begin(original_state, load(BACKPACK_RESOLVER_PATH).new(), item_defs, bag_defs, &"guiin")

	var authoritative_build = load(BUILD_STATE_PATH).new()
	add_child_autofree(authoritative_build)
	authoritative_build.configure(item_defs, fate_defs)
	authoritative_build.set_selected_school(&"guiin")

	var wrong_build = load(BUILD_STATE_PATH).new()
	add_child_autofree(wrong_build)
	wrong_build.configure(item_defs, fate_defs)
	wrong_build.set_selected_school(&"guiin")

	var rng := RandomNumberGenerator.new()
	rng.seed = 1801
	var fate = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(fate)
	fate.configure(authoritative_build, fate_defs, rng)
	fate.begin_rest()
	var pending_fate: StringName = fate.candidate_ids[0]
	assert_true(fate.choose_pending(pending_fate))

	var route = load(ROUTE_STATE_PATH).new()
	assert_true(route.set_provisional_next_school(&"cheonsul"))

	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(original_state, wrong_build, route, fate)
	assert_true(fate.has_method("_is_bound_to_build_state"), "T12 must verify FateController and coordinator share one RunBuildState authority")
	if not fate.has_method("_is_bound_to_build_state"):
		return
	assert_false(coordinator.begin_rest(session), "Mismatched build authorities must be rejected before any transaction can start")
	assert_false(authoritative_build.has_fate(pending_fate))
	assert_false(wrong_build.has_fate(pending_fate))
	assert_eq(route.active_school_id(), &"")
	assert_eq(route.provisional_school_id(), &"cheonsul")


func test_pending_fate_definition_must_be_prevalidated_before_route_or_backpack_mutation() -> void:
	var mvp4 = load(MVP4_CATALOG_PATH)
	var mvp3 = load(MVP3_CATALOG_PATH)
	var item_defs: Dictionary = mvp4.build_items()
	var bag_defs: Dictionary = mvp4.build_bags()
	var all_fate_defs: Dictionary = mvp3.build_fates()
	var missing_fate: StringName = &"slaughter_path"
	var fate_defs_for_controller := {
		missing_fate: all_fate_defs[missing_fate],
		&"guardian_path": all_fate_defs[&"guardian_path"],
		&"shadow_path": all_fate_defs[&"shadow_path"],
	}
	var fate_defs_for_build := fate_defs_for_controller.duplicate()
	fate_defs_for_build.erase(missing_fate)

	var original_state = load(BACKPACK_STATE_PATH).new().create_starting_state()
	var session = load(REST_SESSION_PATH).new()
	session.begin(original_state, load(BACKPACK_RESOLVER_PATH).new(), item_defs, bag_defs, &"guiin")

	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(item_defs, fate_defs_for_build)
	build_state.set_selected_school(&"guiin")

	var rng := RandomNumberGenerator.new()
	rng.seed = 1803
	var fate = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(fate)
	fate.configure(build_state, fate_defs_for_controller, rng)
	fate.begin_rest()
	assert_true(fate.candidate_ids.has(missing_fate))
	assert_true(fate.choose_pending(missing_fate))

	var route = load(ROUTE_STATE_PATH).new()
	assert_true(route.set_provisional_next_school(&"cheonsul"))
	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(original_state, build_state, route, fate)
	assert_true(coordinator.begin_rest(session))

	var failures: Array[StringName] = coordinator.commit_failures()
	assert_true(failures.has(&"fate_pending"), "A pending Fate unknown to RunBuildState must fail during read-only prevalidation")
	assert_false(coordinator.commit())
	assert_false(build_state.has_fate(missing_fate))
	assert_eq(route.active_school_id(), &"", "Failed Fate commit must not leave route partially committed")
	assert_eq(route.provisional_school_id(), &"cheonsul")
