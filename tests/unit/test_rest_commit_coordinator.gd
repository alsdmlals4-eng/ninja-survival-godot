# T12 Workbench 원자 확정 조정자의 성공과 무변경 실패 계약을 검증한다.
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


func test_t12_coordinator_resource_exists() -> void:
	assert_true(ResourceLoader.exists(COORDINATOR_PATH), "Missing T12 RestCommitCoordinator")


func test_valid_rest_tuple_commits_backpack_fate_and_route_once() -> void:
	var fixture := _prepared_fixture(601)
	if fixture.is_empty() or not ResourceLoader.exists(COORDINATOR_PATH):
		return
	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(fixture.committed_state, fixture.build_state, fixture.route, fixture.fate)

	assert_true(coordinator.begin_rest(fixture.session))
	assert_true(coordinator.commit())
	assert_eq(coordinator.committed_backpack_state().get_item(fixture.item_instance_id).origin, Vector2i(1, 1))
	assert_true(fixture.build_state.has_fate(fixture.pending_fate_id))
	assert_eq(fixture.route.active_school_id(), &"cheonsul")
	assert_eq(fixture.route.provisional_school_id(), &"")
	assert_false(coordinator.commit())
	assert_eq(fixture.build_state.selected_fates.size(), 1)


func test_missing_pending_fate_leaves_committed_route_and_build_unchanged() -> void:
	var fixture := _prepared_fixture(607, false)
	if fixture.is_empty() or not ResourceLoader.exists(COORDINATOR_PATH):
		return
	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(fixture.committed_state, fixture.build_state, fixture.route, fixture.fate)
	var route_before: Dictionary = fixture.route.get_route_snapshot()
	var fates_before: Array[StringName] = fixture.build_state.selected_fates.duplicate()

	assert_true(coordinator.begin_rest(fixture.session))
	assert_false(coordinator.commit())
	assert_eq(fixture.route.get_route_snapshot(), route_before)
	assert_eq(fixture.build_state.selected_fates, fates_before)
	assert_eq(coordinator.committed_backpack_state().get_item(fixture.item_instance_id).origin, Vector2i(1, 1))


func test_first_school_provisional_route_is_not_a_t12_commit_tuple() -> void:
	var fixture := _prepared_fixture(613, true, false)
	if fixture.is_empty() or not ResourceLoader.exists(COORDINATOR_PATH):
		return
	var coordinator = load(COORDINATOR_PATH).new()
	coordinator.configure(fixture.committed_state, fixture.build_state, fixture.route, fixture.fate)
	var route_before: Dictionary = fixture.route.get_route_snapshot()

	assert_true(coordinator.begin_rest(fixture.session))
	assert_false(coordinator.commit())
	assert_eq(fixture.route.get_route_snapshot(), route_before)
	assert_false(fixture.build_state.has_fate(fixture.pending_fate_id))


func _prepared_fixture(
	seed_value: int,
	select_pending_fate: bool = true,
	has_cleared_school: bool = true
) -> Dictionary:
	var mvp4 = load(MVP4_CATALOG_PATH)
	var mvp3 = load(MVP3_CATALOG_PATH)
	var item_defs: Dictionary = mvp4.build_items()
	var bag_defs: Dictionary = mvp4.build_bags()
	var fate_defs: Dictionary = mvp3.build_fates()
	var committed_state = load(BACKPACK_STATE_PATH).new().create_starting_state()
	var item_instance_id: int = committed_state.add_item(&"taijutsu_training", Vector2i(1, 1))
	assert_gt(item_instance_id, 0)
	var session = load(REST_SESSION_PATH).new()
	session.begin(committed_state, load(BACKPACK_RESOLVER_PATH).new(), item_defs, bag_defs, &"guiin")
	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(item_defs, fate_defs)
	build_state.set_selected_school(&"guiin")
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var fate = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(fate)
	fate.configure(build_state, fate_defs, rng)
	fate.begin_rest()
	var pending_fate_id: StringName = fate.candidate_ids[0]
	if select_pending_fate:
		assert_true(fate.choose_pending(pending_fate_id))
	var route = load(ROUTE_STATE_PATH).new()
	if has_cleared_school:
		assert_true(route.set_provisional_next_school(&"guiin"))
		assert_true(route.commit_provisional_next_school())
		assert_true(route.mark_active_school_cleared())
	assert_true(route.set_provisional_next_school(&"cheonsul"))
	return {
		"committed_state": committed_state,
		"item_instance_id": item_instance_id,
		"session": session,
		"build_state": build_state,
		"fate": fate,
		"route": route,
		"pending_fate_id": pending_fate_id,
	}
