extends GutTest

const MAIN_SCENE := "res://scenes/main/main_scene.tscn"


func test_enemy_kill_is_not_replaced_immediately() -> void:
	var packed: PackedScene = load(MAIN_SCENE)
	assert_not_null(packed)
	if packed == null:
		return

	var main = packed.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame

	var enemies_before := _living_enemies(main)
	assert_gt(enemies_before.size(), 0)
	if enemies_before.is_empty():
		return

	var initial_count := enemies_before.size()
	var enemy = enemies_before[0]
	enemy.take_damage(enemy.max_health)

	await get_tree().process_frame
	await get_tree().process_frame

	var enemies_after := _living_enemies(main)
	assert_eq(enemies_after.size(), initial_count - 1, "MVP-1 must wait for a timed wave instead of instant replacement")


func _living_enemies(main: Node) -> Array[Node]:
	var enemies: Array[Node] = []
	for child in main.get_children():
		if child.is_in_group("enemies") and not child.is_queued_for_deletion():
			enemies.append(child)
	return enemies
