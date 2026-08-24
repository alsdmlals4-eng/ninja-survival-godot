extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"

const SCHOOL_IDS := [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]


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
	main.get_node("StageFlow").segment_duration_seconds = 0.01
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

	var flow = main.get_node("StageFlow")
	flow._process(0.01)
	var boss = _stage_bosses(main)[0]
	boss.take_damage(99999)
	assert_eq(flow.phase, flow.Phase.RESULT)
	assert_eq(orb.process_mode, Node.PROCESS_MODE_DISABLED)

	var rest_ui = main.get_node("RestFlowUI")
	rest_ui.result_continue_requested.emit()
	rest_ui.shop_continue_requested.emit()
	var fate = main.get_node("FateController")
	rest_ui.fate_selected_requested.emit(fate.candidate_ids[0])
	rest_ui.preview_start_requested.emit()
	assert_eq(flow.phase, flow.Phase.COMBAT)
	assert_eq(orb.process_mode, Node.PROCESS_MODE_INHERIT)


func test_game_over_during_combat_is_terminal_and_never_opens_rest() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	main._on_school_selected(&"guiin")
	var flow = main.get_node("StageFlow")
	assert_eq(flow.phase, flow.Phase.COMBAT)
	main.get_node("Player").take_damage(99999)
	assert_true(main.game_over)
	assert_eq(flow.phase, flow.Phase.GAME_OVER)
	assert_true(main.get_node("HUD/GameOverPanel").visible)
	assert_false(main.get_node("RestFlowUI/Panel").visible)
	assert_false(flow.enter_result_after_boss())


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


func _first_reward_orb(main: Node):
	for child in main.get_children():
		if child is RewardOrb and not child.is_queued_for_deletion():
			return child
	return null
