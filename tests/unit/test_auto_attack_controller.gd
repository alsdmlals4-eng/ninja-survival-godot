extends GutTest

const AutoAttackScript = preload("res://scripts/combat/auto_attack_controller.gd")
const PROJECTILE_SCENE := preload("res://scenes/projectiles/projectile_basic.tscn")


func test_nearest_target_returns_closest_node() -> void:
	var controller = AutoAttackScript.new()
	add_child_autofree(controller)
	var far_target = Node2D.new()
	far_target.position = Vector2(100, 0)
	add_child_autofree(far_target)
	var near_target = Node2D.new()
	near_target.position = Vector2(20, 0)
	add_child_autofree(near_target)

	assert_eq(
		controller.find_nearest_target([far_target, near_target], Vector2.ZERO),
		near_target,
	)


func test_nearest_target_returns_null_for_empty_list() -> void:
	var controller = AutoAttackScript.new()
	add_child_autofree(controller)

	assert_null(controller.find_nearest_target([], Vector2.ZERO))


func test_nearest_target_ignores_non_node2d_candidates() -> void:
	var controller = AutoAttackScript.new()
	add_child_autofree(controller)
	var invalid_candidate = Node.new()
	add_child_autofree(invalid_candidate)
	var valid_target = Node2D.new()
	valid_target.position = Vector2(40, 0)
	add_child_autofree(valid_target)

	assert_eq(
		controller.find_nearest_target([invalid_candidate, valid_target], Vector2.ZERO),
		valid_target,
	)


func test_fire_once_spawns_projectile_toward_nearest_enemy() -> void:
	var world = Node2D.new()
	add_child_autofree(world)
	var source = Node2D.new()
	source.position = Vector2(10, 10)
	world.add_child(source)
	var controller = AutoAttackScript.new()
	controller.projectile_scene = PROJECTILE_SCENE
	controller.projectile_speed = 640.0
	controller.projectile_damage = 11
	source.add_child(controller)
	var target = Node2D.new()
	target.position = Vector2(110, 10)
	target.add_to_group("enemies")
	world.add_child(target)

	var projectile = controller.fire_once()

	assert_not_null(projectile)
	if projectile == null:
		return
	assert_eq(projectile.get_parent(), world)
	assert_eq(projectile.global_position, source.global_position)
	assert_eq(projectile.direction, Vector2.RIGHT)
	assert_eq(projectile.speed, 640.0)
	assert_eq(projectile.damage, 11)
