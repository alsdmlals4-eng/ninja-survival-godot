extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")


func test_main_scene_contains_all_mvp3_runtime_nodes() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	for node_name in [
		"RunBuildState",
		"ShopController",
		"FateController",
		"StageFlow",
		"ContributionTracker",
		"CombatResolver",
		"RestFlowUI",
	]:
		assert_true(main.has_node(node_name), "Missing MVP-3 main-scene node: %s" % node_name)


func test_school_selection_starts_segment_one_and_syncs_hud_and_build_state() -> void:
	var main = _new_main()
	if main == null:
		return
	var flow = main.get_node("StageFlow")
	var build_state = main.get_node("RunBuildState")
	var player = main.get_node("Player")
	var spawner = main.get_node("WaveSpawner")
	assert_eq(flow.phase, flow.Phase.SCHOOL_SELECT)
	assert_eq(build_state.gold, 0)
	assert_eq(player.process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(spawner.process_mode, Node.PROCESS_MODE_DISABLED)

	main._on_school_selected(&"bongma")
	assert_eq(flow.phase, flow.Phase.COMBAT)
	assert_eq(build_state.selected_school_id, &"bongma")
	assert_eq(player.process_mode, Node.PROCESS_MODE_INHERIT)
	assert_eq(spawner.process_mode, Node.PROCESS_MODE_INHERIT)
	assert_eq(main.get_node("Player/AutoAttack").process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(main.get_node("HUD/StageLabel").text, "SEGMENT 1/3")
	assert_eq(main.get_node("HUD/StageTimeLabel").text, "TIME 05:00")
	assert_eq(main.get_node("HUD/GoldLabel").text, "GOLD 0")


func test_cheonsul_selection_starts_vertical_slice_without_replacing_legacy_stage_flow() -> void:
	var main = _new_main()
	if main == null:
		return
	var flow = main.get_node("StageFlow")
	main._on_school_selected(&"cheonsul")
	assert_not_null(main.cheonsul_slice)
	assert_eq(flow.phase, flow.Phase.SCHOOL_SELECT)
	assert_eq(main.cheonsul_slice.route_state.active_school_id(), &"cheonsul")
	assert_eq(main.get_node("RunBuildState").selected_school_id, &"cheonsul")
	assert_eq(main.get_node("Player").process_mode, Node.PROCESS_MODE_INHERIT)
	assert_eq(main.get_node("WaveSpawner").process_mode, Node.PROCESS_MODE_INHERIT)


func test_cheonsul_runtime_requires_trace_before_boss_and_ends_at_workbench() -> void:
	var main = _new_main()
	if main == null:
		return
	main._on_school_selected(&"cheonsul")
	var slice = main.cheonsul_slice
	assert_not_null(slice)
	if slice == null:
		return
	assert_true(slice.sync_elapsed(180.0))
	var elite = _cheonsul_role_enemy(main, &"elite")
	assert_not_null(elite)
	if elite == null:
		return
	elite.take_damage(9999)
	assert_eq(slice.get_snapshot().get("state"), &"trace_available")
	assert_true(slice.sync_elapsed(270.0))
	assert_false(bool(slice.get_snapshot().get("boss_requested", false)))
	var recover_event := InputEventAction.new()
	recover_event.action = &"ui_accept"
	recover_event.pressed = true
	main._unhandled_input(recover_event)
	assert_eq(slice.get_snapshot().get("state"), &"boss_warning")
	assert_true(slice.sync_elapsed(280.0))
	var boss = _cheonsul_role_enemy(main, &"boss")
	assert_not_null(boss)
	if boss == null:
		return
	boss.take_damage(99999)
	assert_eq(slice.get_snapshot().get("state"), &"cleared")
	assert_true(main.get_node("RestFlowUI/Panel").visible)
	assert_true(main.get_node("RestFlowUI/Panel/Margin/Content/WorkbenchView").visible)
	assert_true(main.get_node("RestFlowUI/Panel/Margin/Content/WorkbenchView/RewardStatusLabel").text.contains("보스 보상"))
	assert_true(main.get_node("RestFlowUI/Panel/Margin/Content/WorkbenchView/CommitButton").disabled)
	assert_eq(main.get_node("RunBuildState").selected_fates, [])
	var rest_ui = main.get_node("RestFlowUI")
	rest_ui.workbench_route_selected_requested.emit(&"bongma")
	assert_eq(slice.route_state.provisional_school_id(), &"bongma")
	var pending_fate: StringName = slice.workbench_snapshot().get("fate_candidate_ids", [])[0]
	rest_ui.fate_selected_requested.emit(pending_fate)
	assert_eq(slice.workbench_snapshot().get("pending_fate_id"), pending_fate)
	assert_eq(main.get_node("RunBuildState").selected_fates, [])
	assert_true(main.get_node("RestFlowUI/Panel/Margin/Content/WorkbenchView/CommitButton").disabled)


func test_normal_enemy_death_grants_one_gold_and_segment_kill_after_selection() -> void:
	var main = _new_main()
	if main == null:
		return
	main._on_school_selected(&"bongma")
	var build_state = main.get_node("RunBuildState")
	var tracker = main.get_node("ContributionTracker")
	var game_state = main.get_node("GameState")
	var enemy = _first_live_normal_enemy(main)
	assert_not_null(enemy)
	if enemy == null:
		return
	assert_eq(enemy.take_damage(9999), 20)
	assert_eq(build_state.gold, 1)
	assert_eq(game_state.kill_count, 1)
	assert_eq(tracker.kills, 1)
	assert_eq(tracker.max_combo, 1)


func test_segment_threshold_stops_new_waves_and_spawns_exactly_one_tier_one_boss() -> void:
	var main = _new_main(0.05)
	if main == null:
		return
	main._on_school_selected(&"bongma")
	var flow = main.get_node("StageFlow")
	var spawner = main.get_node("WaveSpawner")
	var living_normals := _live_normal_enemies(main)
	assert_gt(living_normals.size(), 0)
	flow._process(0.05)
	assert_eq(flow.phase, flow.Phase.BOSS)
	assert_false(spawner._spawning_enabled)
	assert_eq(_stage_bosses(main).size(), 1)
	var boss = _stage_bosses(main)[0]
	assert_eq(boss.tier, 1)
	assert_eq(boss.target, main.get_node("Player"))
	for enemy in living_normals:
		assert_false(enemy.is_queued_for_deletion())
		assert_eq(enemy.process_mode, Node.PROCESS_MODE_INHERIT)
	flow._process(99.0)
	assert_eq(_stage_bosses(main).size(), 1)


func test_boss_death_grants_exactly_twenty_five_gold_freezes_result_and_cleans_normals_without_rewards() -> void:
	var main = _new_main(0.01)
	if main == null:
		return
	main._on_school_selected(&"bongma")
	var flow = main.get_node("StageFlow")
	var build_state = main.get_node("RunBuildState")
	var tracker = main.get_node("ContributionTracker")
	var game_state = main.get_node("GameState")
	var ddd = main.get_node("CombatDDD")
	var rest_ui = main.get_node("RestFlowUI")
	var school_host = main.get_node("SchoolRuntimeHost")
	flow._process(0.01)
	var boss = _stage_bosses(main)[0]
	assert_eq(boss.take_damage(9999), 200)

	assert_eq(flow.phase, flow.Phase.RESULT)
	assert_eq(build_state.gold, 25)
	assert_eq(game_state.kill_count, 1)
	assert_eq(tracker.kills, 1)
	var snapshot: Dictionary = tracker.get_snapshot()
	assert_eq(snapshot["gold_earned"], 25)
	assert_eq(snapshot["kills"], 1)
	assert_eq(snapshot["max_combo"], 1)
	assert_true(rest_ui.get_node("Panel").visible)
	assert_true(rest_ui.get_node("Panel/Margin/Content/ResultView").visible)
	assert_eq(ddd.process_mode, Node.PROCESS_MODE_DISABLED)
	assert_true(school_host.active_runtime.active, "Rest pause must not semantically deactivate the selected school")
	assert_eq(school_host.process_mode, Node.PROCESS_MODE_DISABLED)
	for enemy in _live_normal_enemies(main):
		assert_true(enemy.is_queued_for_deletion())
	assert_eq(build_state.gold, 25, "Normal cleanup must not grant GOLD")
	assert_eq(game_state.kill_count, 1, "Normal cleanup must not grant score/kill credit")


func test_result_shop_fate_preview_and_next_segment_flow() -> void:
	var main = _new_main(0.01)
	if main == null:
		return
	main._on_school_selected(&"bongma")
	var flow = main.get_node("StageFlow")
	var rest_ui = main.get_node("RestFlowUI")
	var shop = main.get_node("ShopController")
	var fate = main.get_node("FateController")
	flow._process(0.01)
	_stage_bosses(main)[0].take_damage(9999)
	assert_eq(flow.phase, flow.Phase.RESULT)

	rest_ui.result_continue_requested.emit()
	assert_eq(flow.phase, flow.Phase.SHOP)
	assert_eq(shop.offer_ids.size(), 3)
	assert_true(rest_ui.get_node("Panel/Margin/Content/ShopView").visible)

	rest_ui.shop_continue_requested.emit()
	assert_eq(flow.phase, flow.Phase.FATE)
	assert_eq(fate.candidate_ids.size(), 3)
	assert_true(rest_ui.get_node("Panel/Margin/Content/FateView").visible)

	var chosen: StringName = fate.candidate_ids[0]
	rest_ui.fate_selected_requested.emit(chosen)
	assert_eq(flow.phase, flow.Phase.PREVIEW)
	assert_true(main.get_node("RunBuildState").has_fate(chosen))
	assert_true(rest_ui.get_node("Panel/Margin/Content/PreviewView").visible)
	assert_true(rest_ui.get_node("Panel/Margin/Content/PreviewView/SummaryLabel").text.contains("BOSS 2"))

	rest_ui.preview_start_requested.emit()
	assert_eq(flow.phase, flow.Phase.COMBAT)
	assert_eq(flow.segment_index, 2)
	assert_eq(main.get_node("Player").process_mode, Node.PROCESS_MODE_INHERIT)
	assert_eq(main.get_node("CombatDDD").process_mode, Node.PROCESS_MODE_INHERIT)
	assert_false(rest_ui.get_node("Panel").visible)


func test_three_accelerated_segments_end_in_complete_without_segment_four() -> void:
	var main = _new_main(0.01)
	if main == null:
		return
	main._on_school_selected(&"bongma")
	var flow = main.get_node("StageFlow")
	var rest_ui = main.get_node("RestFlowUI")
	var fate = main.get_node("FateController")

	for segment in range(1, 4):
		flow._process(0.01)
		assert_eq(flow.phase, flow.Phase.BOSS)
		var bosses := _stage_bosses(main)
		assert_eq(bosses.size(), 1)
		assert_eq(bosses[0].tier, segment)
		bosses[0].take_damage(99999)
		assert_eq(flow.phase, flow.Phase.RESULT)
		rest_ui.result_continue_requested.emit()
		assert_eq(flow.phase, flow.Phase.SHOP)
		rest_ui.shop_continue_requested.emit()
		assert_eq(flow.phase, flow.Phase.FATE)
		var chosen: StringName = fate.candidate_ids[0]
		rest_ui.fate_selected_requested.emit(chosen)
		if segment < 3:
			assert_eq(flow.phase, flow.Phase.PREVIEW)
			rest_ui.preview_start_requested.emit()
			assert_eq(flow.phase, flow.Phase.COMBAT)
			assert_eq(flow.segment_index, segment + 1)
		else:
			assert_eq(flow.phase, flow.Phase.COMPLETE)
			assert_eq(flow.segment_index, 3)
			assert_true(rest_ui.get_node("Panel/Margin/Content/CompleteView").visible)
			assert_true(rest_ui.get_node("Panel/Margin/Content/CompleteView/TitleLabel").text.contains("MVP-3 LOOP COMPLETE"))
			assert_false(flow.start_next_combat())


func test_game_over_from_boss_phase_wins_over_result_transition() -> void:
	var main = _new_main(0.01)
	if main == null:
		return
	main._on_school_selected(&"bongma")
	var flow = main.get_node("StageFlow")
	flow._process(0.01)
	assert_eq(flow.phase, flow.Phase.BOSS)
	main.get_node("Player").take_damage(99999)
	assert_eq(flow.phase, flow.Phase.GAME_OVER)
	assert_true(main.game_over)
	assert_true(main.get_node("HUD/GameOverPanel").visible)
	var boss = _stage_bosses(main)[0]
	boss.take_damage(99999)
	assert_eq(flow.phase, flow.Phase.GAME_OVER)
	assert_false(main.get_node("RestFlowUI/Panel").visible)


func _new_main(segment_duration: float = 300.0):
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	if not main.has_node("StageFlow"):
		return null
	main.get_node("StageFlow").segment_duration_seconds = segment_duration
	return main


func _stage_bosses(main: Node) -> Array:
	var bosses: Array = []
	for child in main.get_children():
		if child.has_method("is_stage_boss") and child.is_stage_boss() and not child.is_queued_for_deletion():
			bosses.append(child)
	return bosses


func _live_normal_enemies(main: Node) -> Array:
	var enemies: Array = []
	for child in main.get_children():
		if not child.is_in_group("enemies"):
			continue
		if child.has_method("is_stage_boss") and child.is_stage_boss():
			continue
		if child.is_queued_for_deletion():
			continue
		enemies.append(child)
	return enemies


func _first_live_normal_enemy(main: Node):
	var enemies := _live_normal_enemies(main)
	return null if enemies.is_empty() else enemies[0]


func _cheonsul_role_enemy(main: Node, role: StringName):
	for child in main.get_children():
		if child.get_meta(&"cheonsul_slice_role", &"") == role and not child.is_queued_for_deletion():
			return child
	return null
