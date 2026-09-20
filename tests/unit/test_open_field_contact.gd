extends GutTest

class Target extends CharacterBody2D:
	var damage_taken := 0
	func take_damage(amount: int) -> void: damage_taken += amount

class WatchedEnemy extends EnemyChaser:
	var transform_notifications := 0
	func _notification(what: int) -> void:
		if what == NOTIFICATION_TRANSFORM_CHANGED: transform_notifications += 1

func _context() -> Dictionary:
	var target := Target.new()
	target.collision_layer = 1
	target.collision_mask = 2
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 14.0
	collision.shape = shape
	target.add_child(collision)
	add_child_autofree(target)
	var enemy = load("res://scenes/enemies/enemy_basic.tscn").instantiate()
	enemy.set_script(WatchedEnemy)
	enemy.position = Vector2(400, 0)
	add_child_autofree(enemy)
	enemy.set_physics_process(false)
	enemy.set_target(target)
	assert_true(enemy.has_method("enable_open_field_contact"), "Main may opt into exact circular target-only contact.")
	if not enemy.has_method("enable_open_field_contact"): return {}
	enemy.enable_open_field_contact()
	return {"enemy": enemy, "target": target}

func test_far_speed_slow_and_bind_do_not_deal_remote_damage() -> void:
	var c := _context()
	if c.is_empty(): return
	await get_tree().physics_frame
	c.enemy._physics_process(1.0 / 60.0)
	assert_almost_eq(c.enemy.position.x, 398.5, 0.001)
	c.enemy.apply_book_control(&"slow", 1.0, 0.4)
	c.enemy._physics_process(1.0 / 60.0)
	assert_almost_eq(c.enemy.position.x, 397.6, 0.001)
	c.enemy.apply_book_control(&"bind", 1.0, 0.0, true)
	c.enemy._physics_process(1.0 / 60.0)
	assert_almost_eq(c.enemy.position.x, 397.6, 0.001)
	assert_eq(c.target.damage_taken, 0)

func test_all_directions_stop_at_body_and_contact_obeys_cooldown() -> void:
	var c := _context()
	if c.is_empty(): return
	for direction in [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2(1, 1).normalized()]:
		c.enemy.position = direction * 35.0
		c.enemy._contact_cooldown_remaining = 0.0
		var before: int = c.target.damage_taken
		for tick in range(15): c.enemy._physics_process(1.0 / 60.0)
		assert_almost_eq(c.enemy.position.length(), 28.08, 0.001)
		assert_eq(c.target.damage_taken - before, 10)
		assert_false(c.enemy.is_on_floor(), "Top-down target contact must never become a rideable platform.")

func test_target_teleport_and_dash_layer_change_take_effect_immediately() -> void:
	var c := _context()
	if c.is_empty(): return
	c.enemy.position = Vector2(28.08, 0)
	c.enemy._physics_process(1.0 / 60.0)
	c.target.position = Vector2(-100, 0)
	c.enemy._physics_process(1.0 / 60.0)
	assert_almost_eq(c.enemy.position.x, 26.58, 0.001)
	c.target.position = Vector2.ZERO
	c.target.collision_layer = 0
	c.enemy._physics_process(1.0 / 60.0)
	assert_almost_eq(c.enemy.position.x, 25.08, 0.001, "Dash removes the player's body, not just its damage.")
	c.target.collision_layer = 1
	c.enemy._physics_process(1.0 / 60.0)
	assert_almost_eq(c.enemy.position.x, 28.08, 0.001)

func test_additional_collision_mask_uses_real_wall_solver() -> void:
	var c := _context()
	if c.is_empty(): return
	c.enemy.collision_mask = 17
	var wall := StaticBody2D.new()
	wall.collision_layer = 16
	wall.position = Vector2(370, 0)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10, 100)
	collision.shape = shape
	wall.add_child(collision)
	add_child_autofree(wall)
	await get_tree().physics_frame
	await get_tree().physics_frame
	for tick in range(40): c.enemy._physics_process(1.0 / 60.0)
	assert_gt(c.enemy.position.x, 385.0)

func test_scaled_bodies_and_disabled_shape_are_not_stale() -> void:
	var c := _context()
	if c.is_empty(): return
	c.target.scale = Vector2(2, 2)
	c.enemy.position = Vector2(45, 0)
	for tick in range(10): c.enemy._physics_process(1.0 / 60.0)
	assert_almost_eq(c.enemy.position.x, 42.08, 0.001)
	c.target.get_node("CollisionShape2D").disabled = true
	c.enemy._physics_process(1.0 / 60.0)
	assert_almost_eq(c.enemy.position.x, 40.58, 0.001)

func test_blocked_stationary_chase_does_not_resubmit_the_same_body_transform() -> void:
	var c := _context()
	if c.is_empty(): return
	c.enemy.set_notify_transform(true)
	c.enemy.position = Vector2(35, 0)
	for tick in range(15): c.enemy._physics_process(1.0 / 60.0)
	c.enemy.force_update_transform()
	var before: int = c.enemy.transform_notifications
	for tick in range(60):
		c.enemy._physics_process(1.0 / 60.0)
		c.enemy.force_update_transform()
	assert_almost_eq(c.enemy.position.x, 28.08, 0.001)
	assert_eq(c.enemy.transform_notifications, before, "Unchanged blocked bodies should not dirty physics/render transforms every tick.")
	assert_eq(c.target.damage_taken, 20, "Contact clocks still advance even without a transform update.")
