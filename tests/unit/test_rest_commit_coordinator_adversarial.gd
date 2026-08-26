# T12 원자 확정의 소유자 고정·관찰 일관성·차단 경로를 재공격한다.
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


func test_active_rest_rejects_owner_tuple_replacement() -> void:
	var fixture := _prepared_fixture(701)
	var coordinator = _coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var alternate_state = fixture.committed_state.copy_value()
	assert_true(alternate_state.move_item(fixture.item_instance_id, Vector2i(2, 1)))
	var alternate_build = _build_state(fixture.item_defs, fixture.fate_defs)
	var alternate_route = load(ROUTE_STATE_PATH).new()
	var alternate_fate = _fate(alternate_build, fixture.fate_defs, 702)

	assert_false(coordinator.configure(alternate_state, alternate_build, alternate_route, alternate_fate))
	assert_true(coordinator.commit())
	assert_eq(coordinator.committed_backpack_state().get_item(fixture.item_instance_id).origin, Vector2i(1, 1))
	assert_true(fixture.build_state.has_fate(fixture.pending_fate_id))
	assert_eq(fixture.route.active_school_id(), &"cheonsul")
	assert_false(alternate_build.has_fate(fixture.pending_fate_id))
	assert_eq(alternate_route.active_school_id(), &"")


func test_fate_observer_sees_completed_tuple_and_cannot_reenter_commit() -> void:
	var fixture := _prepared_fixture(709)
	assert_true(fixture.session.commit_item_preview() == false)
	var preview = fixture.session.preview_item(fixture.item_instance_id, Vector2i(2, 1), 0)
	assert_true(preview.valid)
	assert_true(fixture.session.commit_item_preview())
	var coordinator = _coordinator(fixture)
	assert_true(coordinator.begin_rest(fixture.session))
	var observed := {}
	var reentrant_results: Array[bool] = []
	fixture.build_state.fate_changed.connect(func(fate_id: StringName):
		observed["has_fate"] = fixture.build_state.has_fate(fate_id)
		observed["route"] = fixture.route.active_school_id()
		observed["origin"] = coordinator.committed_backpack_state().get_item(fixture.item_instance_id).origin
		reentrant_results.append(coordinator.commit())
	)

	assert_true(coordinator.commit())
	assert_true(bool(observed.get("has_fate", false)))
	assert_eq(observed.get("route", &""), &"cheonsul")
	assert_eq(observed.get("origin", Vector2i(-1, -1)), Vector2i(2, 1))
	assert_eq(reentrant_results, [false])


func test_unresolved_buffer_blocks_every_committed_owner() -> void:
	var fixture := _prepared_fixture(719)
	assert_true(fixture.session.move_item_to_buffer(fixture.item_instance_id))
	var coordinator = _coordinator(fixture)
	var route_before: Dictionary = fixture.route.get_route_snapshot()
	var modifier_before := _modifier_signature(fixture.build_state.get_committed_backpack_modifiers())

	assert_true(coordinator.begin_rest(fixture.session))
	assert_true(coordinator.commit_failures().has(&"buffer_not_empty"))
	assert_false(coordinator.commit())
	assert_eq(fixture.route.get_route_snapshot(), route_before)
	assert_false(fixture.build_state.has_fate(fixture.pending_fate_id))
	assert_eq(_modifier_signature(fixture.build_state.get_committed_backpack_modifiers()), modifier_before)
	assert_not_null(coordinator.committed_backpack_state().get_item(fixture.item_instance_id))


func _prepared_fixture(seed_value: int) -> Dictionary:
	var mvp4 = load(MVP4_CATALOG_PATH)
	var mvp3 = load(MVP3_CATALOG_PATH)
	var item_defs: Dictionary = mvp4.build_items()
	var fate_defs: Dictionary = mvp3.build_fates()
	var committed_state = load(BACKPACK_STATE_PATH).new().create_starting_state()
	var item_instance_id: int = committed_state.add_item(&"taijutsu_training", Vector2i(1, 1))
	var session = load(REST_SESSION_PATH).new()
	session.begin(committed_state, load(BACKPACK_RESOLVER_PATH).new(), item_defs, mvp4.build_bags(), &"guiin")
	var build_state = _build_state(item_defs, fate_defs)
	var fate = _fate(build_state, fate_defs, seed_value)
	fate.begin_rest()
	var pending_fate_id: StringName = fate.candidate_ids[0]
	assert_true(fate.choose_pending(pending_fate_id))
	var route = load(ROUTE_STATE_PATH).new()
	assert_true(route.set_provisional_next_school(&"guiin"))
	assert_true(route.commit_provisional_next_school())
	assert_true(route.mark_active_school_cleared())
	assert_true(route.set_provisional_next_school(&"cheonsul"))
	return {
		"item_defs": item_defs,
		"fate_defs": fate_defs,
		"committed_state": committed_state,
		"item_instance_id": item_instance_id,
		"session": session,
		"build_state": build_state,
		"fate": fate,
		"route": route,
		"pending_fate_id": pending_fate_id,
	}


func _coordinator(fixture: Dictionary):
	var coordinator = load(COORDINATOR_PATH).new()
	assert_true(coordinator.configure(fixture.committed_state, fixture.build_state, fixture.route, fixture.fate))
	return coordinator


func _build_state(item_defs: Dictionary, fate_defs: Dictionary):
	var state = load(BUILD_STATE_PATH).new()
	add_child_autofree(state)
	state.configure(item_defs, fate_defs)
	state.set_selected_school(&"guiin")
	return state


func _fate(build_state, fate_defs: Dictionary, seed_value: int):
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var fate = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(fate)
	fate.configure(build_state, fate_defs, rng)
	return fate


func _modifier_signature(modifiers) -> Dictionary:
	var result := {}
	for field_name in load(MODIFIER_SET_PATH).SUPPORTED_FIELDS:
		result[field_name] = float(modifiers.get(field_name))
	return result
