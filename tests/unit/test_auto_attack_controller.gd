extends GutTest

const AutoAttackScript = preload("res://scripts/combat/auto_attack_controller.gd")


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
