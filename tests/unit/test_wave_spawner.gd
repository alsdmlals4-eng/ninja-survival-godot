extends GutTest

const SPAWNER_PATH := "res://scripts/spawning/wave_spawner.gd"
const ENEMY_SCENE := preload("res://scenes/enemies/enemy_basic.tscn")


func test_ensure_minimum_active_fills_ten_normal_enemies_inside_random_annulus() -> void:
	var context := _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	assert_true(spawner.configure_horde_profile(1.0, 3, 10, 420.0, 560.0))
	spawner.set_random_seed(20260830)

	assert_eq(spawner.ensure_minimum_active(), 10)
	var enemies := _living_normal_enemy_children(context.spawn_parent)
	assert_eq(enemies.size(), 10)
	for enemy in enemies:
		var enemy_node := enemy as Node2D
		var distance: float = (context.anchor as Node2D).global_position.distance_to(enemy_node.global_position)
		assert_gte(distance, 420.0)
		assert_lte(distance, 560.0)


func test_ensure_minimum_active_restores_only_the_missing_normal_enemy_count() -> void:
	var context := _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	assert_true(spawner.configure_horde_profile(1.0, 3, 10, 420.0, 560.0))
	assert_eq(spawner.ensure_minimum_active(), 10)
	var leaving_enemy := _living_normal_enemy_children(context.spawn_parent)[0]
	leaving_enemy.queue_free()

	assert_eq(spawner.ensure_minimum_active(), 1)
	assert_eq(_living_normal_enemy_children(context.spawn_parent).size(), 10)


func test_spawn_wave_has_no_normal_enemy_cap() -> void:
	var context := _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	assert_true(spawner.configure_horde_profile(1.0, 3, 0, 420.0, 560.0))
	for _index in range(11):
		_add_normal_enemy(context.spawn_parent)

	assert_eq(spawner.spawn_wave(), 3)
	assert_eq(_living_normal_enemy_children(context.spawn_parent).size(), 14)
	assert_eq(spawner.spawn_wave(), 3)
	assert_eq(_living_normal_enemy_children(context.spawn_parent).size(), 17)


func test_disabled_spawner_does_not_restore_the_horde_floor() -> void:
	var context := _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	assert_true(spawner.configure_horde_profile(1.0, 3, 10, 420.0, 560.0))
	spawner.set_spawning_enabled(false)

	assert_eq(spawner.ensure_minimum_active(), 0)
	assert_eq(spawner.spawn_wave(), 0)
	assert_eq(_living_normal_enemy_children(context.spawn_parent).size(), 0)


func test_invalid_horde_profile_preserves_last_valid_configuration() -> void:
	var context := _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	assert_true(spawner.configure_horde_profile(1.0, 3, 10, 420.0, 560.0))
	var before := _profile_snapshot(spawner)

	assert_false(spawner.configure_horde_profile(0.0, 3, 10, 420.0, 560.0))
	assert_false(spawner.configure_horde_profile(1.0, 3, -1, 420.0, 560.0))
	assert_false(spawner.configure_horde_profile(1.0, 3, 10, 560.0, 420.0))
	assert_eq(_profile_snapshot(spawner), before)


func test_process_uses_timed_reinforcements_after_the_floor_is_met() -> void:
	var context := _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	assert_true(spawner.configure_horde_profile(1.0, 3, 0, 420.0, 560.0))
	spawner._process(0.9)
	assert_eq(_living_normal_enemy_children(context.spawn_parent).size(), 0)
	spawner._process(0.1)
	assert_eq(_living_normal_enemy_children(context.spawn_parent).size(), 3)


func _make_context() -> Dictionary:
	assert_true(ResourceLoader.exists(SPAWNER_PATH), "WaveSpawner script must exist")
	if not ResourceLoader.exists(SPAWNER_PATH):
		return {}
	var script = load(SPAWNER_PATH)
	assert_not_null(script)
	if script == null:
		return {}

	var spawn_parent := Node2D.new()
	add_child_autofree(spawn_parent)
	var anchor := Node2D.new()
	spawn_parent.add_child(anchor)
	anchor.global_position = Vector2(25, 40)
	var spawner = script.new()
	spawn_parent.add_child(spawner)
	spawner.enemy_scene = ENEMY_SCENE
	spawner.configure(spawn_parent, anchor)
	return {
		"spawner": spawner,
		"spawn_parent": spawn_parent,
		"anchor": anchor,
	}


func _add_normal_enemy(spawn_parent: Node) -> Node:
	var enemy = ENEMY_SCENE.instantiate()
	enemy.set_meta(&"ninja_wave_spawner_normal", true)
	spawn_parent.add_child(enemy)
	return enemy


func _living_normal_enemy_children(spawn_parent: Node) -> Array[Node]:
	var enemies: Array[Node] = []
	for child in spawn_parent.get_children():
		if (
			child.is_in_group("enemies")
			and bool(child.get_meta(&"ninja_wave_spawner_normal", false))
			and not child.is_queued_for_deletion()
		):
			enemies.append(child)
	return enemies


func _profile_snapshot(spawner: Node) -> Dictionary:
	return {
		"wave_interval": spawner.wave_interval,
		"batch_size": spawner.batch_size,
		"minimum_active_enemies": spawner.minimum_active_enemies,
		"minimum_spawn_distance": spawner.minimum_spawn_distance,
		"maximum_spawn_distance": spawner.maximum_spawn_distance,
	}
