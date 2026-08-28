# 공통 유파 회로로 교체된 Main 전장 흐름의 회귀를 검증한다.
extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")


func test_main_scene_keeps_existing_runtime_owners_before_a_school_starts() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	for node_name in [
		"RunBuildState",
		"ShopController",
		"FateController",
		"StageFlow",
		"ContributionTracker",
		"CombatResolver",
		"RestFlowUI",
		"RecentHitHpPresenter",
	]:
		assert_true(main.has_node(node_name), "Missing current main-scene node: %s" % node_name)
	assert_null(main.school_circuit, "A circuit must be created only after the player selects a school.")


func test_school_selection_starts_the_four_school_circuit_and_syncs_hud_and_build_state() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	var build_state = main.get_node("RunBuildState")
	var player = main.get_node("Player")
	var spawner = main.get_node("WaveSpawner")
	assert_eq(build_state.gold, 0)
	assert_eq(player.process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(spawner.process_mode, Node.PROCESS_MODE_DISABLED)

	main._on_school_selected(&"bongma")
	assert_not_null(main.school_circuit)
	assert_eq(main.school_circuit.route_state.active_school_id(), &"bongma")
	assert_eq(build_state.selected_school_id, &"bongma")
	assert_eq(player.process_mode, Node.PROCESS_MODE_INHERIT)
	assert_eq(spawner.process_mode, Node.PROCESS_MODE_INHERIT)
	assert_eq(main.get_node("Player/AutoAttack").process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(main.get_node("HUD/StageLabel").text, "SEGMENT 1/4")
	assert_eq(main.get_node("HUD/StageTimeLabel").text, "TIME 04:30")
	assert_eq(main.get_node("HUD/GoldLabel").text, "GOLD 0")


func test_circuit_normal_enemy_reward_orb_remains_active_while_legacy_stage_flow_is_idle() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"cheonsul")
	var enemy = _first_live_normal_enemy(main)
	assert_not_null(enemy)
	if enemy == null:
		return
	enemy.take_damage(9999)
	var orbs := _living_reward_orbs(main)
	assert_eq(orbs.size(), 1)
	if orbs.is_empty():
		return
	assert_ne(orbs[0].process_mode, Node.PROCESS_MODE_DISABLED)


func test_circuit_runtime_requires_world_trace_before_boss_and_ends_at_workbench() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"cheonsul")
	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(circuit.sync_elapsed(180.0))
	var elite = _circuit_role_enemy(main, &"elite")
	assert_not_null(elite)
	if elite == null:
		return
	assert_eq(elite.get_meta(&"school_circuit_encounter_id", &""), &"five_element_tuner")
	elite.take_damage(9999)
	assert_eq(circuit.get_snapshot().get("state"), &"trace_available")
	assert_true(circuit.sync_elapsed(270.0))
	assert_false(bool(circuit.get_snapshot().get("boss_requested", false)))
	assert_null(main.get_node_or_null("HUD/TraceRecoveryButton"), "Trace must be an in-world pickup, not a HUD intent.")
	var trace = main.current_trace_pickup
	assert_not_null(trace)
	if trace == null:
		return
	main.get_node("Player").global_position = trace.global_position
	trace._process(0.35)
	trace._process(0.40)
	assert_eq(circuit.get_snapshot().get("state"), &"boss_warning")
	assert_true(circuit.sync_elapsed(280.0))
	var boss = _circuit_role_enemy(main, &"boss")
	assert_not_null(boss)
	if boss == null:
		return
	assert_eq(boss.get_meta(&"school_circuit_encounter_id", &""), &"heavenly_change_taoist")
	boss.take_damage(99999)
	assert_eq(circuit.get_snapshot().get("state"), &"cleared")
	assert_true(main.get_node("RestFlowUI/Panel").visible)
	assert_true(main.get_node("RestFlowUI/Panel/Margin/Content/WorkbenchView").visible)
	assert_true(main.get_node("RestFlowUI/Panel/Margin/Content/WorkbenchView/RewardStatusLabel").text.contains("보스 보상"))
	assert_true(main.get_node("RestFlowUI/Panel/Margin/Content/WorkbenchView/CommitButton").disabled)


func test_normal_enemy_death_grants_current_gold_and_kill_credit_after_selection() -> void:
	var main: Node = _new_main()
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
	assert_true(build_state.gold in [0, 1], "Normal enemies use the fixed 20% 1G policy, so a miss still produces the kill credit.")
	var receipts: Array = build_state.get_economy_receipts()
	assert_eq(receipts.size(), 1)
	assert_eq(receipts[0].get("source"), &"normal")
	assert_eq(receipts[0].get("amount"), build_state.gold)
	assert_eq(game_state.kill_count, 1)
	assert_eq(tracker.kills, 1)
	assert_eq(tracker.max_combo, 1)


func test_boss_death_enters_workbench_and_cleans_normal_enemies_without_extra_rewards() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"bongma")
	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(circuit.sync_elapsed(180.0))
	var elite = _circuit_role_enemy(main, &"elite")
	assert_not_null(elite)
	if elite == null:
		return
	elite.take_damage(99999)
	var trace = main.current_trace_pickup
	assert_not_null(trace)
	if trace == null:
		return
	main.get_node("Player").global_position = trace.global_position
	trace._process(0.35)
	trace._process(0.40)
	assert_true(circuit.sync_elapsed(280.0))
	var boss = _circuit_role_enemy(main, &"boss")
	assert_not_null(boss)
	if boss == null:
		return
	var build_state = main.get_node("RunBuildState")
	var gold_before_boss: int = int(build_state.gold)
	boss.take_damage(99999)
	assert_eq(build_state.gold, gold_before_boss + 10)
	assert_true(main.get_node("RestFlowUI/Panel/Margin/Content/WorkbenchView").visible)
	for enemy in _live_normal_enemies(main):
		assert_true(enemy.is_queued_for_deletion())


func test_game_over_during_circuit_combat_stops_combat_without_opening_rest() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"bongma")
	main.get_node("Player").take_damage(99999)
	assert_true(main.game_over)
	assert_true(main.get_node("HUD/GameOverPanel").visible)
	assert_false(main.get_node("RestFlowUI/Panel").visible)
	assert_eq(main.get_node("Player").process_mode, Node.PROCESS_MODE_DISABLED)


func _new_main():
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	return main


func _live_normal_enemies(main: Node) -> Array:
	var enemies: Array = []
	for child in main.get_children():
		if not child.is_in_group("enemies"):
			continue
		if child.has_method("is_stage_boss") and child.is_stage_boss():
			continue
		enemies.append(child)
	return enemies


func _first_live_normal_enemy(main: Node):
	for enemy in _live_normal_enemies(main):
		if not enemy.is_queued_for_deletion():
			return enemy
	return null


func _living_reward_orbs(main: Node) -> Array:
	var orbs: Array = []
	for child in main.get_children():
		if child.is_in_group("reward_orbs") and not child.is_queued_for_deletion():
			orbs.append(child)
	return orbs


func _circuit_role_enemy(main: Node, role: StringName):
	for child in main.get_children():
		if child.get_meta(&"school_circuit_role", &"") == role and not child.is_queued_for_deletion():
			return child
	return null
