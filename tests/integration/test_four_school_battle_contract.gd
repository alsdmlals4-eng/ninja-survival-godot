# 네 유파의 전투·인법서·Workbench 연결 계약을 끝까지 검증한다.
extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")

const EXPECTED := {
	&"bongma": {
		"elite": &"mobile_array_caster",
		"boss": &"hundred_demon_array_master",
		"spells": [&"bongma_hundred_demon_familiar", &"bongma_seal_chain", &"bongma_guardian_ward"],
	},
	&"cheonsul": {
		"elite": &"five_element_tuner",
		"boss": &"heavenly_change_taoist",
		"spells": [&"cheonsul_flame_mark", &"cheonsul_water_vein_bind", &"cheonsul_lightning_chain_shift"],
	},
	&"guiin": {
		"elite": &"melee_chaos_captain",
		"boss": &"ghost_general",
		"spells": [&"guiin_ghost_blood_wave", &"guiin_afterimage_charge", &"guiin_asura_ring"],
	},
	&"heukyeong": {
		"elite": &"shadow_chief",
		"boss": &"night_executioner",
		"spells": [&"heukyeong_shadow_needle", &"heukyeong_poison_mist", &"heukyeong_chain_execution"],
	},
}


func test_every_selected_school_commits_its_two_scrolls_and_keeps_three_automatic_patterns() -> void:
	for school_id in EXPECTED.keys():
		var main: Node = MAIN_SCENE.instantiate()
		preload("res://tests/helpers/main_storage_isolation.gd").prepare(main)
		add_child_autofree(main)
		main._on_school_selected(school_id)
		await get_tree().process_frame
		var circuit = main.school_circuit
		assert_not_null(circuit, "%s Circuit must start" % school_id)
		if circuit == null:
			continue
		# Workbench reward shapes are random; this contract exercises scroll activation,
		# not a random packing puzzle. Keep its pre-existing full placement path deterministic.
		circuit._rng.seed = 410
		var expected: Dictionary = EXPECTED[school_id]

		assert_true(circuit.sync_elapsed(180.0))
		var elite = _role_enemy(main, &"elite")
		assert_not_null(elite)
		if elite == null:
			continue
		assert_eq(elite.get_meta(&"school_circuit_encounter_id", &""), expected.get("elite"))
		assert_true(elite is SchoolEncounterActor)
		elite.take_damage(99999)

		var trace = main.current_trace_pickup
		assert_not_null(trace)
		if trace == null:
			continue
		main.get_node("Player").global_position = trace.global_position
		trace._process(0.35)
		trace._process(0.40)
		assert_true(circuit.sync_elapsed(280.0))

		var boss = _role_enemy(main, &"boss")
		assert_not_null(boss)
		if boss == null:
			continue
		assert_eq(boss.get_meta(&"school_circuit_encounter_id", &""), expected.get("boss"))
		assert_true(boss is SchoolEncounterActor)
		_assert_boss_patterns_are_telegraphed(boss as SchoolEncounterActor)
		boss.take_damage(99999)

		assert_true(circuit.choose_boss_reward(0))
		assert_true(circuit.open_chest())
		assert_true(_place_every_buffer_item(circuit))
		var fate_id: StringName = circuit.workbench_snapshot().get("fate_candidate_ids", [])[0]
		assert_true(circuit.choose_fate(fate_id))
		var next_school_id: StringName = circuit.route_state.get_unvisited_schools()[0]
		assert_true(circuit.choose_next_route(next_school_id))
		assert_true(circuit.commit_workbench())
		assert_eq(main.ninjutsu_loadout.active_spell_ids(), expected.get("spells"))

		assert_true(circuit.begin_school(next_school_id))
		assert_eq(main.ninjutsu_loadout.active_spell_ids(), expected.get("spells"), "Committed scrolls must remain active in a later Stage.")
		main.queue_free()
		await get_tree().process_frame


# Characterization of the existing Main path, not selected-profile integration
# or a natural five-minute playthrough. Missing rest rendering/combat suspension,
# replayed rewards, and bypassed Elite/Trace gates must all fail this check.
func test_every_school_boss_opens_safe_rest_without_replaying_rewards() -> void:
	for school_id in EXPECTED.keys():
		var main: Node = MAIN_SCENE.instantiate()
		preload("res://tests/helpers/main_storage_isolation.gd").prepare(main)
		add_child_autofree(main)
		main._on_title_new_game_requested()
		main.school_selection._choose(school_id)
		var circuit = main.school_circuit
		var ui = main.get_node("RestFlowUI")
		assert_true(main._combat_enabled)
		assert_false(ui.workbench_view.visible)
		assert_true(circuit.sync_elapsed(180.0))
		var elite = _role_enemy(main, &"elite")
		assert_not_null(elite)
		if elite == null: continue
		assert_eq(elite.get_meta(&"school_circuit_encounter_id"), EXPECTED[school_id].elite)
		assert_null(_role_enemy(main, &"boss"), "Time without Elite/Trace must not spawn a Boss")
		elite.take_damage(99999)
		assert_false(ui.workbench_view.visible, "An Elite kill is not school completion")
		var trace = main.current_trace_pickup
		assert_not_null(trace)
		if trace == null: continue
		assert_true(circuit.sync_elapsed(280.0))
		assert_null(_role_enemy(main, &"boss"), "A late uncollected Trace still gates the Boss")
		main.player.global_position = trace.global_position
		trace._process(0.35)
		trace._process(0.40)
		assert_null(_role_enemy(main, &"boss"), "Late recovery must still show the Boss warning")
		assert_true(circuit.sync_elapsed(290.0))
		var boss = _role_enemy(main, &"boss")
		assert_not_null(boss)
		if boss == null: continue
		assert_eq(boss.get_meta(&"school_circuit_encounter_id"), EXPECTED[school_id].boss)
		boss.take_damage(99999)
		assert_eq(circuit.get_snapshot().state, &"cleared")
		assert_true(ui.visible)
		assert_true(ui.workbench_view.visible, "Boss death must open the real rest controls")
		assert_false(main._combat_enabled)
		assert_eq(main.player.process_mode, Node.PROCESS_MODE_DISABLED)
		assert_eq(main.basic_weapons.process_mode, Node.PROCESS_MODE_DISABLED)
		assert_eq(main.wave_spawner.process_mode, Node.PROCESS_MODE_DISABLED)
		assert_eq(main.school_host.process_mode, Node.PROCESS_MODE_DISABLED)
		assert_true(ui.workbench_commit_button.disabled, "Unresolved rewards cannot depart")
		var before: Dictionary = circuit.workbench_snapshot()
		assert_true(before.boss_reward_pending)
		assert_eq(before.chest_count, 1)
		assert_eq(before.shop_offers.size(), 3)
		assert_eq(circuit.route_state.clear_order(), [school_id])
		var elapsed: float = main._run_play_elapsed_seconds
		# A full-health fixture would hide erroneous redraw healing via the HP cap.
		main.player.health = main.player.max_health - 20
		assert_gt(main.player.health, 0)
		assert_lt(main.player.health, main.player.max_health)
		var hp: int = main.player.health
		main._process(5.0)
		assert_eq(main._run_play_elapsed_seconds, elapsed, "Rest is outside active combat time")
		assert_false(circuit.mark_boss_defeated(), "Duplicate death must not reenter rest")
		main._render_school_circuit_workbench()
		main._render_school_circuit_workbench()
		assert_eq(circuit.workbench_snapshot(), before, "Redraw cannot reroll or repay rewards")
		assert_eq(main.player.health, hp, "Redraw cannot grant healing")
		await get_tree().process_frame
		assert_null(_role_enemy(main, &"boss"))
		for child in main.get_children():
			assert_false(child.is_in_group("enemies") and not child.is_queued_for_deletion(), "Rest must remove remaining combat enemies")
		main.queue_free()
		await get_tree().process_frame


func _assert_boss_patterns_are_telegraphed(boss: SchoolEncounterActor) -> void:
	assert_not_null(boss.definition)
	if boss.definition == null:
		return
	assert_eq(boss.definition.pattern_definitions.size(), 3)
	var primitive_ids: Array[StringName] = []
	var unique_primitive_ids: Dictionary = {}
	for pattern in boss.definition.pattern_definitions:
		var primitive_id := StringName(pattern.get("primitive_id", &""))
		primitive_ids.append(primitive_id)
		unique_primitive_ids[primitive_id] = true
		assert_gt(float(pattern.get("telegraph_duration", 0.0)), 0.0)
		assert_gt(float(pattern.get("recovery_duration", 0.0)), 0.0)
	assert_eq(primitive_ids.size(), unique_primitive_ids.size(), "A Boss must not repeat one generic attack three times.")


func _role_enemy(main: Node, role: StringName):
	for child in main.get_children():
		if child.get_meta(&"school_circuit_role", &"") == role and not child.is_queued_for_deletion():
			return child
	return null


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
