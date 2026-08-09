extends GutTest

const SPAWNER_PATH := "res://scripts/spawning/wave_spawner.gd"
const ENEMY_SCENE := preload("res://scenes/enemies/enemy_basic.tscn")


func test_spawn_wave_adds_two_below_cap() -> void:
	var context = _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	assert_eq(spawner.spawn_wave(), 2)
	assert_eq(_living_enemy_children(context.spawn_parent).size(), 2)


func test_spawn_wave_only_fills_remaining_capacity() -> void:
	var context = _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	spawner.max_active_enemies = 3
	_add_enemy(context.spawn_parent)
	_add_enemy(context.spawn_parent)
	assert_eq(spawner.spawn_wave(), 1)
	assert_eq(_living_enemy_children(context.spawn_parent).size(), 3)


func test_spawn_wave_does_nothing_at_cap() -> void:
	var context = _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	spawner.max_active_enemies = 2
	_add_enemy(context.spawn_parent)
	_add_enemy(context.spawn_parent)
	assert_eq(spawner.spawn_wave(), 0)
	assert_eq(_living_enemy_children(context.spawn_parent).size(), 2)


func test_disabled_spawner_does_not_spawn() -> void:
	var context = _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	spawner.set_spawning_enabled(false)
	assert_eq(spawner.spawn_wave(), 0)
	assert_eq(_living_enemy_children(context.spawn_parent).size(), 0)


func test_spawn_positions_rotate_through_cardinal_directions() -> void:
	var context = _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	spawner.spawn_distance = 320.0
	assert_eq(spawner.spawn_wave(), 2)
	var enemies = _living_enemy_children(context.spawn_parent)
	assert_eq(enemies[0].global_position, context.anchor.global_position + Vector2(320, 0))
	assert_eq(enemies[1].global_position, context.anchor.global_position + Vector2(0, 320))


func test_process_waits_for_interval_then_spawns_batch() -> void:
	var context = _make_context()
	if context.is_empty():
		return
	var spawner = context.spawner
	spawner.wave_interval = 5.0
	spawner._process(4.9)
	assert_eq(_living_enemy_children(context.spawn_parent).size(), 0)
	spawner._process(0.1)
	assert_eq(_living_enemy_children(context.spawn_parent).size(), 2)


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


func _add_enemy(spawn_parent: Node) -> Node:
	var enemy = ENEMY_SCENE.instantiate()
	spawn_parent.add_child(enemy)
	return enemy


func _living_enemy_children(spawn_parent: Node) -> Array[Node]:
	var enemies: Array[Node] = []
	for child in spawn_parent.get_children():
		if child.is_in_group("enemies") and not child.is_queued_for_deletion():
			enemies.append(child)
	return enemies
