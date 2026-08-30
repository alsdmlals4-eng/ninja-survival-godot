extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")


func test_main_scene_has_mvp1_system_nodes_and_reward_binding() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	assert_true(main.has_node("CombatDDD"))
	assert_true(main.has_node("WaveSpawner"))
	assert_true(_has_property(main, "reward_orb_scene"))


func test_enemy_death_updates_combo_and_spawns_one_reward_orb() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	if not _has_mvp1_main_contract(main):
		fail_test("MVP-1 main integration contract is missing")
		return
	_start_combat_if_mvp2(main)

	var tracker = main.get_node("CombatDDD")
	var game_state = main.get_node("GameState")
	var enemies = _living_enemies(main)
	assert_gt(enemies.size(), 0)
	if enemies.is_empty():
		return
	var enemy = enemies[0]
	var death_position: Vector2 = enemy.global_position
	var kills_before: int = game_state.kill_count
	enemy.take_damage(enemy.max_health)

	assert_eq(game_state.kill_count, kills_before + 1)
	assert_eq(tracker.combo_count, 1)
	var orbs = _living_reward_orbs(main)
	assert_eq(orbs.size(), 1)
	if orbs.size() == 1:
		assert_almost_eq(orbs[0].global_position.x, death_position.x, 0.1)
		assert_almost_eq(orbs[0].global_position.y, death_position.y, 0.1)


func test_reward_collection_updates_tracker_without_adding_persistent_combat_metrics() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	if not _has_mvp1_main_contract(main):
		fail_test("MVP-1 main integration contract is missing")
		return
	_start_combat_if_mvp2(main)

	var player = main.get_node("Player")
	var tracker = main.get_node("CombatDDD")
	var enemies = _living_enemies(main)
	if enemies.is_empty():
		fail_test("Expected an initial enemy")
		return
	var move_speed_before: float = player.move_speed
	var health_before: int = player.health
	enemies[0].take_damage(enemies[0].max_health)
	await get_tree().process_frame
	var orbs = _living_reward_orbs(main)
	assert_eq(orbs.size(), 1)
	if orbs.size() != 1:
		return
	var orb = orbs[0]
	player.global_position = orb.global_position
	orb._physics_process(0.016)
	assert_eq(tracker.reward_count, 1)
	assert_eq(tracker.stylish_score, 125)
	assert_null(main.get_node_or_null("HUD/RewardLabel"))
	assert_null(main.get_node_or_null("HUD/StyleLabel"))
	assert_eq(player.move_speed, move_speed_before)
	assert_eq(player.health, health_before)


func test_wave_spawned_enemies_are_wired_to_player() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	if not _has_mvp1_main_contract(main):
		fail_test("MVP-1 main integration contract is missing")
		return

	_start_combat_if_mvp2(main)
	var player = main.get_node("Player")
	var spawner = main.get_node("WaveSpawner")
	var count_before := _living_enemies(main).size()
	assert_eq(spawner.spawn_wave(), 3)
	var enemies = _living_enemies(main)
	assert_eq(enemies.size(), count_before + 3)
	for enemy in enemies.slice(count_before):
		assert_eq(enemy.target, player)


func test_game_over_disables_wave_spawner_and_live_reward_orbs() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	if not _has_mvp1_main_contract(main):
		fail_test("MVP-1 main integration contract is missing")
		return
	_start_combat_if_mvp2(main)

	var enemies = _living_enemies(main)
	if enemies.is_empty():
		fail_test("Expected an initial enemy")
		return
	enemies[0].take_damage(enemies[0].max_health)
	await get_tree().process_frame
	var orbs = _living_reward_orbs(main)
	assert_eq(orbs.size(), 1)
	main.get_node("Player").take_damage(100000)
	assert_true(main.game_over)
	assert_eq(main.get_node("WaveSpawner").process_mode, Node.PROCESS_MODE_DISABLED)
	if orbs.size() == 1:
		assert_eq(orbs[0].process_mode, Node.PROCESS_MODE_DISABLED)
	assert_ne(main.process_mode, Node.PROCESS_MODE_DISABLED)


func _start_combat_if_mvp2(main: Node) -> void:
	if main.has_node("SchoolSelectionUI"):
		main.get_node("SchoolSelectionUI")._choose(&"guiin")


func _has_mvp1_main_contract(main: Node) -> bool:
	return (
		main.has_node("CombatDDD")
		and main.has_node("WaveSpawner")
		and _has_property(main, "reward_orb_scene")
	)


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


func _has_property(instance: Object, property_name: StringName) -> bool:
	for property in instance.get_property_list():
		if property.name == property_name:
			return true
	return false
