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
