# 이어하기는 확정된 route·가방만으로 새 Core 압박 상태를 열고, 기존 유파 접근 패키지를 재구성한다.
extends GutTest

const CIRCUIT_SCRIPT = preload("res://scripts/core/school_circuit_controller.gd")
const LOADOUT_SCRIPT = preload("res://scripts/core/ninjutsu_loadout_state.gd")
const MVP3_CATALOG = preload("res://scripts/data/mvp3_catalog.gd")
const MVP4_CATALOG = preload("res://scripts/data/mvp4_catalog.gd")
const BUILD_STATE_SCRIPT = preload("res://scripts/core/run_build_state.gd")
const FATE_CONTROLLER_SCRIPT = preload("res://scripts/core/fate_controller.gd")
const ROUTE_STATE_SCRIPT = preload("res://scripts/core/run_route_state.gd")
const BACKPACK_STATE_SCRIPT = preload("res://scripts/backpack/backpack_state.gd")
const ECONOMY_POLICY = preload("res://resources/run_economy_policy.tres")


func test_persistent_resume_reconstructs_the_next_stage_as_fresh_core_pressure() -> void:
	var fixture := _new_fixture()
	var circuit = fixture.get("circuit")
	assert_not_null(circuit)
	if circuit == null:
		return
	var route = ROUTE_STATE_SCRIPT.new()
	assert_true(route.set_provisional_next_school(&"cheonsul"))
	assert_true(route.commit_provisional_next_school())
	assert_true(route.mark_active_school_cleared())
	assert_true(route.set_provisional_next_school(&"bongma"))
	assert_true(route.commit_provisional_next_school())
	var backpack = BACKPACK_STATE_SCRIPT.new().create_starting_state()
	assert_eq(backpack.add_item(&"taijutsu_training", Vector2i(1, 1)), 2)
	var checkpoint_circuit := {
		"active_school_id": &"bongma",
		"committed_backpack_state": backpack,
	}

	assert_true(ROUTE_STATE_SCRIPT.new().can_restore_from_checkpoint(route.get_route_snapshot()), "The fixture route itself must satisfy the route checkpoint contract.")
	assert_not_null(circuit._access_state_for_cleared_schools(route.cleared_school_ids()), "The cleared route must rebuild its access packages.")
	assert_true(backpack.has_method("copy_value"), "The committed backpack must retain its value-copy contract.")
	assert_true(circuit.can_restore_from_persistent_checkpoint(route.get_route_snapshot(), checkpoint_circuit))
	assert_true(circuit.restore_from_persistent_checkpoint(route.get_route_snapshot(), checkpoint_circuit))
	assert_eq(circuit.route_state.active_school_id(), &"bongma")
	assert_eq(circuit.get_snapshot().get("state"), &"core")
	assert_eq(circuit.get_snapshot().get("encounter", {}).get("school_id"), &"bongma")
	assert_eq(circuit._access_state.open_school_ids(), [&"cheonsul"])
	assert_eq(circuit.get_checkpoint_snapshot().get("committed_backpack_state").get_item(2).definition_id, &"taijutsu_training")


func test_persistent_resume_rejects_a_checkpoint_without_a_prior_committed_school() -> void:
	var fixture := _new_fixture()
	var circuit = fixture.get("circuit")
	assert_not_null(circuit)
	if circuit == null:
		return
	var route = ROUTE_STATE_SCRIPT.new()
	assert_true(route.set_provisional_next_school(&"cheonsul"))
	assert_true(route.commit_provisional_next_school())
	var backpack = BACKPACK_STATE_SCRIPT.new().create_starting_state()
	assert_false(circuit.can_restore_from_persistent_checkpoint(route.get_route_snapshot(), {
		"active_school_id": &"cheonsul",
		"committed_backpack_state": backpack,
	}))
	assert_eq(circuit.route_state.active_school_id(), &"")


func _new_fixture() -> Dictionary:
	var build_state = BUILD_STATE_SCRIPT.new()
	add_child_autofree(build_state)
	var economy_rng := RandomNumberGenerator.new()
	economy_rng.seed = 809
	build_state.configure(MVP4_CATALOG.build_items(), MVP3_CATALOG.build_fates(), ECONOMY_POLICY, economy_rng)

	var fate_controller = FATE_CONTROLLER_SCRIPT.new()
	add_child_autofree(fate_controller)
	var rng := RandomNumberGenerator.new()
	rng.seed = 410
	fate_controller.configure(build_state, MVP3_CATALOG.build_fates(), rng)

	var loadout = LOADOUT_SCRIPT.new()
	add_child_autofree(loadout)
	assert_true(loadout.activate_starter(&"cheonsul"))

	var circuit = CIRCUIT_SCRIPT.new()
	add_child_autofree(circuit)
	assert_true(circuit.configure_workbench(build_state, fate_controller, MVP4_CATALOG.build_items(), MVP4_CATALOG.build_bags(), rng))
	assert_true(circuit.configure_ninjutsu_loadout(loadout))
	return {"circuit": circuit, "loadout": loadout}
