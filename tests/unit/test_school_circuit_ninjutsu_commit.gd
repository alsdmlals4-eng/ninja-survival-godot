# 스테이지 인법서가 Workbench 원자 확정에 포함되는지 검증한다.
extends GutTest

const CIRCUIT_SCRIPT = preload("res://scripts/core/school_circuit_controller.gd")
const LOADOUT_SCRIPT = preload("res://scripts/core/ninjutsu_loadout_state.gd")
const MVP3_CATALOG = preload("res://scripts/data/mvp3_catalog.gd")
const MVP4_CATALOG = preload("res://scripts/data/mvp4_catalog.gd")
const BUILD_STATE_SCRIPT = preload("res://scripts/core/run_build_state.gd")
const FATE_CONTROLLER_SCRIPT = preload("res://scripts/core/fate_controller.gd")
const ECONOMY_POLICY = preload("res://resources/run_economy_policy.tres")


func test_scrolls_stage_on_elite_and_boss_reward_but_commit_with_fate_and_route_only() -> void:
	var fixture := _new_fixture()
	var circuit = fixture.get("circuit")
	var loadout = fixture.get("loadout")
	assert_not_null(circuit)
	assert_not_null(loadout)
	if circuit == null or loadout == null:
		return

	assert_true(circuit.sync_elapsed(180.0))
	assert_true(circuit.mark_elite_defeated())
	assert_eq(loadout.pending_spell_ids(), [&"cheonsul_water_vein_bind"])
	assert_eq(loadout.active_spell_ids(), [&"cheonsul_flame_mark"])
	assert_true(circuit.recover_trace())
	assert_true(circuit.sync_elapsed(270.0))
	assert_true(circuit.mark_boss_defeated())
	assert_true(circuit.choose_boss_reward(0))
	assert_eq(
		loadout.pending_spell_ids(),
		[&"cheonsul_water_vein_bind", &"cheonsul_lightning_chain_shift"],
		"보스 인법서는 보상 선택 뒤 대기하지만 아직 전투에 반영되지 않아야 합니다."
	)

	assert_true(circuit.open_chest())
	assert_true(_place_every_buffer_item(circuit))
	assert_false(circuit.commit_workbench(), "Fate와 다음 스테이지가 없으면 인법서도 활성화하면 안 됩니다.")
	assert_eq(loadout.active_spell_ids(), [&"cheonsul_flame_mark"])

	var fate_id: StringName = circuit.workbench_snapshot().get("fate_candidate_ids", [])[0]
	assert_true(circuit.choose_fate(fate_id))
	assert_true(circuit.choose_next_route(&"bongma"))
	assert_true(circuit.commit_workbench())
	assert_eq(
		loadout.active_spell_ids(),
		[&"cheonsul_flame_mark", &"cheonsul_water_vein_bind", &"cheonsul_lightning_chain_shift"]
	)
	assert_eq(loadout.pending_spell_ids(), [])


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
	assert_true(circuit.begin_school(&"cheonsul"))
	return {"circuit": circuit, "loadout": loadout}


func _place_every_buffer_item(circuit) -> bool:
	_expand_fixture_board(circuit)
	while not (circuit.workbench_snapshot().get("buffer", []) as Array).is_empty():
		var placed := false
		for rotation in range(4):
			for y in range(6):
				for x in range(6):
					if circuit.place_buffer_item(0, Vector2i(x, y), rotation):
						placed = true
						break
				if placed:
					break
			if placed:
				break
		if not placed:
			return false
	return true


func _expand_fixture_board(circuit) -> void:
	var state = circuit._backpack_session._state
	if state.bags.size() != 1:
		return
	assert_gt(state.add_bag(&"small_pouch", Vector2i(0, 0)), 0)
	assert_gt(state.add_bag(&"small_pouch", Vector2i(3, 4)), 0)
	assert_gt(state.add_bag(&"long_pouch", Vector2i(0, 4)), 0)
