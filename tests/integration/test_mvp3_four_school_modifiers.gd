extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"

const SCHOOL_IDS := [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const WORKBENCH_FIXTURE_SEED := 1


func test_each_school_receives_committed_backpack_fate_and_school_modifiers() -> void:
	for school_id in SCHOOL_IDS:
		var main = MAIN_SCENE.instantiate()
		add_child_autofree(main)
		main._on_school_selected(school_id)
		var state = main.get_node("RunBuildState")
		state.grant_gold(1000)
		assert_true(state.buy_item(&"ninjutsu_training"), "Ninjutsu training purchase failed for %s" % school_id)
		assert_true(state.buy_item(&"ultimate_treatise"), "Ultimate treatise purchase failed for %s" % school_id)
		assert_true(state.buy_item(&"school_emblem"), "School emblem purchase failed for %s" % school_id)
		var committed = load(MODIFIER_PATH).new()
		committed.school_damage_pct = 0.12
		committed.ultimate_charge_gain_pct = 0.25
		match school_id:
			&"bongma": committed.bongma_familiar_interval_pct = -0.15
			&"cheonsul": committed.cheonsul_reaction_damage_pct = 0.20
			&"guiin": committed.guiin_melee_radius_pct = 0.15
			&"heukyeong": committed.heukyeong_marked_crit_bonus = 0.15
		state.set_committed_backpack_modifiers(committed)
		assert_true(state.select_fate(&"seal_path"), "Seal path selection failed for %s" % school_id)
		main._sync_run_modifiers()

		var runtime = main.get_node("SchoolRuntimeHost").active_runtime
		assert_not_null(runtime)
		assert_almost_eq(runtime.run_modifiers.school_damage_pct, 0.12, 0.001)
		assert_almost_eq(runtime.run_modifiers.non_ultimate_school_damage_pct, -0.15, 0.001)
		assert_almost_eq(runtime.run_modifiers.ultimate_power_pct, 0.25, 0.001)

		match school_id:
			&"bongma":
				assert_almost_eq(runtime.run_modifiers.ultimate_charge_gain_pct, 0.55, 0.001)
				assert_almost_eq(runtime.run_modifiers.bongma_familiar_interval_pct, -0.15, 0.001)
			&"cheonsul":
				assert_almost_eq(runtime.run_modifiers.ultimate_charge_gain_pct, 0.55, 0.001)
				assert_almost_eq(runtime.run_modifiers.cheonsul_reaction_damage_pct, 0.20, 0.001)
			&"guiin":
				assert_almost_eq(runtime.run_modifiers.ultimate_charge_gain_pct, 0.55, 0.001)
				assert_almost_eq(runtime.run_modifiers.guiin_melee_radius_pct, 0.15, 0.001)
			&"heukyeong":
				assert_almost_eq(runtime.run_modifiers.ultimate_charge_gain_pct, 0.0, 0.001)
				assert_almost_eq(runtime.run_modifiers.heukyeong_mark_duration_pct, 0.55, 0.001)
				assert_almost_eq(runtime.run_modifiers.heukyeong_marked_crit_bonus, 0.15, 0.001)


func test_process_pause_and_resume_preserve_selected_school_identity_and_runtime_resource() -> void:
	for school_id in SCHOOL_IDS:
		var main = MAIN_SCENE.instantiate()
		add_child_autofree(main)
		main._on_school_selected(school_id)
		var host = main.get_node("SchoolRuntimeHost")
		var runtime = host.active_runtime
		var marker_before: Variant = _resource_marker(runtime, school_id)
		main._set_combat_enabled(false)
		assert_eq(host.selected_school_id, school_id)
		assert_true(runtime.active)
		assert_eq(_resource_marker(runtime, school_id), marker_before)
		main._set_combat_enabled(true)
		assert_eq(host.selected_school_id, school_id)
		assert_true(runtime.active)
		assert_eq(_resource_marker(runtime, school_id), marker_before)


func test_frozen_result_stays_equal_after_shop_fate_heal_and_reroll_mutations() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	main._on_school_selected(&"bongma")
	var tracker = main.get_node("ContributionTracker")
	var state = main.get_node("RunBuildState")
	var shop = main.get_node("ShopController")
	var fate = main.get_node("FateController")
	var player = main.get_node("Player")

	tracker.reset_segment(0, 0)
	tracker.record_damage(50)
	tracker.record_defense(4)
	state.grant_gold(100)
	var frozen: Dictionary = tracker.freeze_snapshot(0, state.gold, state)
	var expected := frozen.duplicate(true)

	shop.begin_rest()
	assert_true(shop.buy_offer(0))
	main._sync_run_modifiers()
	shop.reroll()
	fate.begin_rest()
	assert_true(fate.choose(fate.candidate_ids[0]))
	main._sync_run_modifiers()
	player.take_damage(20)
	player.heal(10)

	assert_eq(tracker.get_snapshot(), expected)


func test_reward_orbs_are_paused_during_result_rest_and_resume_next_combat() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	main._on_school_selected(&"bongma")
	var normal = _first_live_normal_enemy(main)
	assert_not_null(normal)
	if normal == null:
		return
	normal.take_damage(9999)
	var orb = _first_reward_orb(main)
	assert_not_null(orb)
	if orb == null:
		return
	assert_eq(orb.process_mode, Node.PROCESS_MODE_INHERIT)

	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	# The production circuit randomizes offers. This fixture needs one reproducible
	# reward/chest layout before it validates the commit and orb process mode.
	circuit._rng.seed = WORKBENCH_FIXTURE_SEED
	assert_true(_clear_active_school_to_workbench(main, circuit))
	assert_eq(orb.process_mode, Node.PROCESS_MODE_DISABLED)

	assert_true(circuit.choose_boss_reward(0))
	assert_true(circuit.open_chest())
	assert_true(_place_every_buffer_item(circuit))
	var fate_id: StringName = circuit.workbench_snapshot().get("fate_candidate_ids", [])[0]
	assert_true(circuit.choose_fate(fate_id))
	assert_true(circuit.choose_next_route(&"cheonsul"))
	main._on_workbench_commit_requested()
	assert_eq(circuit.route_state.active_school_id(), &"cheonsul")
	assert_eq(orb.process_mode, Node.PROCESS_MODE_INHERIT)


func test_game_over_during_combat_is_terminal_and_never_opens_rest() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	main._on_school_selected(&"guiin")
	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_eq(circuit.get_snapshot().get("state"), &"core")
	main.get_node("Player").take_damage(99999)
	assert_true(main.game_over)
	assert_eq(circuit.get_snapshot().get("state"), &"core")
	assert_true(main.get_node("HUD/GameOverPanel").visible)
	assert_false(main.get_node("RestFlowUI/Panel").visible)


func _resource_marker(runtime: Node, school_id: StringName):
	match school_id:
		&"bongma":
			return runtime.spirit
		&"cheonsul":
			return runtime.reaction_count
		&"guiin":
			return runtime.gwihyeol
		&"heukyeong":
			return runtime.get_total_active_marks()
	return null


func _stage_bosses(main: Node) -> Array:
	var result: Array = []
	for child in main.get_children():
		if child.has_method("is_stage_boss") and child.is_stage_boss() and not child.is_queued_for_deletion():
			result.append(child)
	return result


func _first_live_normal_enemy(main: Node):
	for child in main.get_children():
		if not child.is_in_group("enemies") or child.is_queued_for_deletion():
			continue
		if child.has_method("is_stage_boss") and child.is_stage_boss():
			continue
		return child
	return null


func _role_enemy(main: Node, role: StringName):
	for child in main.get_children():
		if child.get_meta(&"school_circuit_role", &"") == role and not child.is_queued_for_deletion():
			return child
	return null


func _clear_active_school_to_workbench(main: Node, circuit) -> bool:
	if not circuit.sync_elapsed(180.0):
		return false
	var elite = _role_enemy(main, &"elite")
	if elite == null:
		return false
	elite.take_damage(99999)
	var trace = main.current_trace_pickup
	if trace == null:
		return false
	main.get_node("Player").global_position = trace.global_position
	trace._process(0.35)
	trace._process(0.40)
	if not circuit.sync_elapsed(280.0):
		return false
	var boss = _role_enemy(main, &"boss")
	if boss == null:
		return false
	boss.take_damage(99999)
	return circuit.get_snapshot().get("state") == &"cleared"


func _place_every_buffer_item(circuit) -> bool:
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


func _first_reward_orb(main: Node):
	for child in main.get_children():
		if child is RewardOrb and not child.is_queued_for_deletion():
			return child
	return null
