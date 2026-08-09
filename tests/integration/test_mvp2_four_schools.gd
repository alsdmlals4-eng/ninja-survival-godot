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
		assert_false(selector.visible)
		assert_eq(main.get_node("Player").process_mode, Node.PROCESS_MODE_INHERIT)
		assert_eq(main.get_node("WaveSpawner").process_mode, Node.PROCESS_MODE_INHERIT)
		assert_eq(main.get_node("Player/AutoAttack").process_mode, Node.PROCESS_MODE_DISABLED)
		for enemy in _living_enemies(main):
			assert_eq(enemy.process_mode, Node.PROCESS_MODE_INHERIT)
		main.queue_free()
		await get_tree().process_frame


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

	main.get_node("Player").take_damage(100000)
	assert_true(main.game_over)
	assert_false(heukyeong.active)
	assert_eq(host.process_mode, Node.PROCESS_MODE_DISABLED)
	assert_eq(main.get_node("WaveSpawner").process_mode, Node.PROCESS_MODE_DISABLED)
	assert_true(badge == null or badge.is_queued_for_deletion())
	assert_eq(heukyeong.get_total_active_marks(), 0)


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