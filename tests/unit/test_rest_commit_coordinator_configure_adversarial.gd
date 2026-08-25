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


func test_configure_cannot_replace_owner_tuple_while_t12_transaction_is_active() -> void:
	var fixture := _prepared_fixture(1811)
	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(fixture.original_state, fixture.build_state, fixture.route, fixture.fate)
	assert_true(coordinator.begin_rest(fixture.session))

	var alternate_state = fixture.original_state.copy_value()
	assert_true(alternate_state.move_item(fixture.item_instance_id, Vector2i(2, 1)))
	var alternate_build = load(BUILD_STATE_PATH).new()
	add_child_autofree(alternate_build)
	alternate_build.configure(fixture.item_defs, fixture.fate_defs)
	alternate_build.set_selected_school(&"guiin")
	var alternate_route = load(ROUTE_STATE_PATH).new()
	var alternate_rng := RandomNumberGenerator.new()
	alternate_rng.seed = 1812
	var alternate_fate = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(alternate_fate)
	alternate_fate.configure(alternate_build, fixture.fate_defs, alternate_rng)

	coordinator.configure(alternate_state, alternate_build, alternate_route, alternate_fate)

	assert_true(coordinator.commit(), "Active transaction must remain bound to its original owner tuple; configure must be ignored/rejected until it ends")
	assert_eq(coordinator.committed_backpack_state().get_item(fixture.item_instance_id).origin, Vector2i(1, 1))
	assert_true(fixture.build_state.has_fate(fixture.pending_fate_id))
	assert_eq(fixture.route.active_school_id(), &"cheonsul")
	assert_eq(alternate_route.active_school_id(), &"")
	assert_eq(alternate_build.selected_fates.size(), 0)


func _prepared_fixture(seed_value: int) -> Dictionary:
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
	assert_true(route.set_provisional_next_school(&"guiin"))
	assert_true(route.commit_provisional_next_school())
	assert_true(route.mark_active_school_cleared())
	assert_true(route.set_provisional_next_school(&"cheonsul"))
	fate.begin_rest()
	var pending_fate_id: StringName = fate.candidate_ids[0]
	assert_true(fate.choose_pending(pending_fate_id))
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
		"pending_fate_id": pending_fate_id,
	}
