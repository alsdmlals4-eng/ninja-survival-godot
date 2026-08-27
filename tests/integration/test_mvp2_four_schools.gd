extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")


func test_run_starts_paused_behind_school_selection() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame

	assert_true(main.has_node("SchoolRuntimeHost"), "Main must contain SchoolRuntimeHost")
	assert_true(main.has_node("SchoolSelectionUI"), "Main must contain SchoolSelectionUI")
	if not main.has_node("SchoolRuntimeHost") or not main.has_node("SchoolSelectionUI"):
		return

	var selector = main.get_node("SchoolSelectionUI")
	var host = main.get_node("SchoolRuntimeHost")
	assert_true(selector.visible)
	assert_eq(host.selected_school_id, &"")
	assert_eq(main.get_node("Player").process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(main.get_node("Player/AutoAttack").process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(main.get_node("WaveSpawner").process_mode, Node.PROCESS_MODE_DISABLED)
	for enemy in _living_enemies(main):
		assert_eq(enemy.process_mode, Node.PROCESS_MODE_DISABLED)


func test_each_school_selection_activates_only_matching_runtime_and_combat() -> void:
	var cases := {
		&"bongma": "Bongma",
		&"cheonsul": "Cheonsul",
		&"guiin": "Guiin",
		&"heukyeong": "Heukyeong",
	}

	for school_id in cases.keys():
		var main = MAIN_SCENE.instantiate()
		add_child_autofree(main)
		await get_tree().process_frame
		if not main.has_node("SchoolRuntimeHost") or not main.has_node("SchoolSelectionUI"):
			fail_test("MVP-2 school integration nodes are missing")
			return

		var selector = main.get_node("SchoolSelectionUI")
		selector._choose(school_id)
		var host = main.get_node("SchoolRuntimeHost")
		assert_eq(host.selected_school_id, school_id)
		assert_eq(host.active_runtime.name, cases[school_id])
		assert_true(host.active_runtime.active)
		assert_true(selector.visible)
		assert_false((selector.get_node("Panel") as Control).visible)
		assert_eq(main.get_node("Player").process_mode, Node.PROCESS_MODE_INHERIT)
		assert_eq(main.get_node("WaveSpawner").process_mode, Node.PROCESS_MODE_INHERIT)
		assert_eq(main.get_node("Player/AutoAttack").process_mode, Node.PROCESS_MODE_DISABLED)
		for enemy in _living_enemies(main):
			assert_eq(enemy.process_mode, Node.PROCESS_MODE_INHERIT)
		main.queue_free()
		await get_tree().process_frame


func test_current_school_help_opens_from_hud_during_combat_without_reselecting() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	var selector = main.get_node("SchoolSelectionUI") as SchoolSelectionUI
	var hud = main.get_node("HUD") as HUDController
	assert_not_null(selector)
	assert_not_null(hud)
	if selector == null or hud == null:
		return

	selector._choose(&"cheonsul")
	var help_button := hud.get_node_or_null("SchoolHelpButton") as Button
	assert_not_null(help_button, "Combat HUD must expose current-school help")
	if help_button == null:
		return
	assert_true(help_button.visible)
	help_button.pressed.emit()

	assert_true((selector.get_node("HelpDialog") as Control).visible)
	assert_eq(selector.get_node("HelpDialog/Margin/Content/TitleLabel").text, "천술류 기능 도움말")
	assert_eq(main.get_node("SchoolRuntimeHost").selected_school_id, &"cheonsul")
	assert_false((selector.get_node("Panel") as Control).visible)


func test_second_school_selection_is_rejected() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	if not main.has_node("SchoolRuntimeHost") or not main.has_node("SchoolSelectionUI"):
		fail_test("MVP-2 school integration nodes are missing")
		return

	main.get_node("SchoolSelectionUI")._choose(&"bongma")
	var host = main.get_node("SchoolRuntimeHost")
	assert_false(host.select_school(&"heukyeong"))
	assert_eq(host.selected_school_id, &"bongma")
	assert_eq(host.active_runtime.name, "Bongma")


func test_school_kill_keeps_single_mvp1_kill_combo_orb_and_school_gain() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	if not main.has_node("SchoolRuntimeHost") or not main.has_node("SchoolSelectionUI"):
		fail_test("MVP-2 school integration nodes are missing")
		return

	main.get_node("SchoolSelectionUI")._choose(&"bongma")
	var host = main.get_node("SchoolRuntimeHost")
	var bongma = host.active_runtime
	var enemy = _living_enemies(main)[0]
	var kills_before: int = main.get_node("GameState").kill_count
	var combo_before: int = main.get_node("CombatDDD").combo_count
	var spirit_before: float = bongma.spirit

	enemy.take_damage(enemy.max_health)

	assert_eq(main.get_node("GameState").kill_count, kills_before + 1)
	assert_eq(main.get_node("CombatDDD").combo_count, combo_before + 1)
	assert_eq(_living_reward_orbs(main).size(), 1)
	assert_almost_eq(bongma.spirit, spirit_before + 10.0, 0.001)


func test_repeated_enemy_death_callback_is_idempotent() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	main.get_node("SchoolSelectionUI")._choose(&"bongma")
	var bongma = main.get_node("SchoolRuntimeHost").active_runtime
	var enemy = _living_enemies(main)[0]

	enemy.take_damage(enemy.max_health)
	var kills_after_first: int = main.get_node("GameState").kill_count
	var combo_after_first: int = main.get_node("CombatDDD").combo_count
	var spirit_after_first: float = bongma.spirit
	var orbs_after_first: int = _living_reward_orbs(main).size()

	main._on_enemy_died(enemy)

	assert_eq(main.get_node("GameState").kill_count, kills_after_first)
	assert_eq(main.get_node("CombatDDD").combo_count, combo_after_first)
	assert_almost_eq(bongma.spirit, spirit_after_first, 0.001)
	assert_eq(_living_reward_orbs(main).size(), orbs_after_first)


func test_wave_spawned_enemy_is_wired_after_selection() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	if not main.has_node("SchoolSelectionUI"):
		fail_test("MVP-2 selector is missing")
		return

	main.get_node("SchoolSelectionUI")._choose(&"guiin")
	var spawner = main.get_node("WaveSpawner")
	var count_before := _living_enemies(main).size()
	assert_eq(spawner.spawn_wave(), 2)
	var enemies := _living_enemies(main)
	assert_eq(enemies.size(), count_before + 2)
	for enemy in enemies.slice(count_before):
		assert_eq(enemy.target, main.get_node("Player"))
		assert_true(enemy.is_connected("died", Callable(main, "_on_enemy_died")))


func test_alive_ui_accept_uses_selected_ultimate() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	if not main.has_node("SchoolRuntimeHost") or not main.has_node("SchoolSelectionUI"):
		fail_test("MVP-2 school integration nodes are missing")
		return

	main.get_node("SchoolSelectionUI")._choose(&"bongma")
	var bongma = main.get_node("SchoolRuntimeHost").active_runtime
	bongma.spirit = 100.0
	var event := InputEventAction.new()
	event.action = &"ui_accept"
	event.pressed = true
	main._unhandled_input(event)
	assert_almost_eq(bongma.ultimate_time_remaining, 6.0, 0.001)


func test_ultimate_button_reuses_selected_school_runtime_action() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	main.get_node("SchoolSelectionUI")._choose(&"bongma")
	var bongma = main.get_node("SchoolRuntimeHost").active_runtime
	bongma.spirit = 100.0
	var ultimate_button := main.get_node_or_null("HUD/UltimateButton") as Button
	assert_not_null(ultimate_button, "Combat HUD must expose the ultimate button")
	if ultimate_button == null:
		return
	ultimate_button.pressed.emit()
	assert_almost_eq(bongma.ultimate_time_remaining, 6.0, 0.001)


func test_cheonsul_test_buttons_spawn_isolated_elite_and_mid_boss() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	main.get_node("SchoolSelectionUI")._choose(&"cheonsul")
	var slice_snapshot: Dictionary = main.cheonsul_slice.get_snapshot()
	var elite_button := main.get_node_or_null("HUD/TestEliteButton") as Button
	var boss_button := main.get_node_or_null("HUD/TestBossButton") as Button
	assert_not_null(elite_button, "Cheonsul combat must expose the test elite button")
	assert_not_null(boss_button, "Cheonsul combat must expose the test boss button")
	if elite_button == null or boss_button == null:
		return

	elite_button.pressed.emit()
	boss_button.pressed.emit()
	var roles: Array[StringName] = []
	for enemy in _living_enemies(main):
		roles.append(StringName(enemy.get_meta("cheonsul_slice_role", &"")))
	assert_true(roles.has(&"test_elite"))
	assert_true(roles.has(&"test_boss"))
	assert_eq(main.cheonsul_slice.get_snapshot().get("state"), slice_snapshot.get("state"), "Test jumps must not mutate canonical Cheonsul progression")
	var gold_before: int = main.run_build_state.gold
	for enemy in _living_enemies(main):
		if StringName(enemy.get_meta("cheonsul_slice_role", &"")) in [&"test_elite", &"test_boss"]:
			enemy.take_damage(enemy.max_health)
	assert_eq(main.cheonsul_slice.get_snapshot().get("state"), slice_snapshot.get("state"), "Defeating test targets must not mutate canonical Cheonsul progression")
	assert_eq(main.run_build_state.gold, gold_before, "Test encounters must not grant persistent currency")


func test_restart_button_is_wired_while_player_is_alive() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	var hud = main.get_node("HUD")
	assert_true(hud.has_signal("restart_requested"), "HUD restart signal must exist")
	assert_true(main.has_method("_restart_run"), "Main must expose one restart path for button and game-over Enter")
	if not hud.has_signal("restart_requested") or not main.has_method("_restart_run"):
		return
	assert_true(
		hud.is_connected("restart_requested", Callable(main, "_restart_run")),
		"Live restart button must stay wired before death"
	)


func test_game_over_deactivates_school_runtime_and_freezes_school_effects() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	if not main.has_node("SchoolRuntimeHost") or not main.has_node("SchoolSelectionUI"):
		fail_test("MVP-2 school integration nodes are missing")
		return

	main.get_node("SchoolSelectionUI")._choose(&"heukyeong")
	var host = main.get_node("SchoolRuntimeHost")
	var heukyeong = host.active_runtime
	var enemy = _living_enemies(main)[0]
	heukyeong.apply_needle_hit(enemy, false)
	var badge: Node = enemy.get_node_or_null("EnemyEffectBadge")
	assert_not_null(badge)
	var school_help_button := main.get_node("HUD/SchoolHelpButton") as Button
	assert_true(school_help_button.visible)
	school_help_button.pressed.emit()
	assert_true((main.get_node("SchoolSelectionUI/HelpDialog") as Control).visible)

	main.get_node("Player").take_damage(100000)
	assert_true(main.game_over)
	assert_false(heukyeong.active)
	assert_eq(host.process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(main.get_node("WaveSpawner").process_mode, Node.PROCESS_MODE_DISABLED)
	assert_true(badge == null or badge.is_queued_for_deletion())
	assert_eq(heukyeong.get_total_active_marks(), 0)
	assert_false(school_help_button.visible, "Game over must remove the combat-only help entry point")
	assert_false((main.get_node("SchoolSelectionUI/HelpDialog") as Control).visible, "Game over must dismiss a live help dialog")


func _living_enemies(main: Node) -> Array[Node]:
	var enemies: Array[Node] = []
	for child in main.get_children():
		if child.is_in_group("enemies") and not child.is_queued_for_deletion():
			enemies.append(child)
	return enemies


func _living_reward_orbs(main: Node) -> Array[Node]:
	var orbs: Array[Node] = []
	for child in main.get_children():
		if child.is_in_group("reward_orbs") and not child.is_queued_for_deletion():
			orbs.append(child)
	return orbs
