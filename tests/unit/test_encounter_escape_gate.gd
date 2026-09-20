extends GutTest

const ACTOR = preload("res://scenes/enemies/school_encounter_actor.tscn")
const CATALOG = preload("res://scripts/data/encounter_catalog.gd")
const GEOMETRY = preload("res://scripts/enemies/encounter_danger_geometry.gd")

class Walker extends CharacterBody2D:
	var move_speed := 120.0

func _context() -> Dictionary:
	var actor = ACTOR.instantiate()
	add_child_autofree(actor)
	actor.set_physics_process(false)
	actor.position = Vector2(-300, 0)
	actor.configure_definition(CATALOG.actor_definition_for(&"five_element_tuner"))
	var player := Walker.new()
	player.collision_layer = 1
	player.collision_mask = 16
	var collision := CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	collision.shape = circle
	player.add_child(collision)
	add_child_autofree(player)
	actor.configure_target(player)
	var budget = load("res://scripts/enemies/encounter_danger_budget.gd").new()
	actor.configure_pattern_budget(budget)
	assert_true(actor.has_method("enable_fair_warning"), "Selected actors need a walk-escape gate before danger admission.")
	if not actor.has_method("enable_fair_warning"): return {}
	actor.enable_fair_warning()
	return {"actor": actor, "player": player, "budget": budget}

func test_slow_walker_gets_windup_then_sufficient_locked_escape_time() -> void:
	var c := _context()
	if c.is_empty(): return
	assert_true(c.actor.pattern_controller.force_start_for_test())
	assert_eq(c.actor.pattern_state(), &"windup")
	assert_almost_eq(c.actor._telegraph_visual.modulate.a, 0.65, 0.001, "Preparation is visually distinct from the locked warning.")
	# Radius92 + body14 + margin6:64 is unsafe,128 is the first valid distance.
	assert_almost_eq(c.actor.current_telegraph_duration(), 128.0 / 120.0 + 0.15 + 0.2, 0.001)
	c.actor.pattern_controller.advance(0.19)
	assert_eq(c.actor.pattern_state(), &"windup")
	c.actor.pattern_controller.advance(0.011)
	assert_eq(c.actor.pattern_state(), &"locked")
	assert_almost_eq(c.actor._telegraph_visual.modulate.a, 1.0, 0.001)
	c.player.position = Vector2(0, 200)
	c.actor.pattern_controller.advance(0.65)
	assert_eq(c.actor.pattern_state(), &"locked", "A slow walker must not be reduced to the minimum lock time.")
	assert_eq(c.actor._pattern_geometry.start, Vector2.ZERO, "The hazard cannot follow the escaping player.")
	c.actor.pattern_controller.advance(0.57)
	assert_eq(c.actor.pattern_state(), &"execute")

func test_enclosed_walker_delays_attack_without_consuming_slot_or_opening_bonus() -> void:
	var c := _context()
	if c.is_empty(): return
	for position in [Vector2(40, 0), Vector2(-40, 0), Vector2(0, 40), Vector2(0, -40)]:
		var wall := StaticBody2D.new()
		wall.collision_layer = 16
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(8, 100) if position.x != 0 else Vector2(100, 8)
		shape.shape = rectangle
		wall.add_child(shape)
		wall.position = position
		add_child_autofree(wall)
	await get_tree().physics_frame
	await get_tree().physics_frame
	c.actor.pattern_controller.configure(c.actor.definition.pattern_definitions, 0.2)
	assert_false(c.actor.pattern_controller.force_start_for_test())
	assert_eq(c.actor.pattern_state(), &"chase")
	assert_eq(c.budget.active_count(), 0)
	assert_almost_eq(c.actor.pattern_controller._opening_telegraph_bonus, 0.2, 0.001)

func test_zero_walking_speed_cannot_be_justified_by_unused_dash() -> void:
	var c := _context()
	if c.is_empty(): return
	c.player.move_speed = 0.0
	assert_false(c.actor.pattern_controller.force_start_for_test())
	assert_eq(c.budget.active_count(), 0)

func test_disabled_player_cannot_start_a_warning_or_query_a_detached_physics_body() -> void:
	var c := _context()
	if c.is_empty(): return
	c.player.process_mode = Node.PROCESS_MODE_DISABLED
	assert_false(c.actor.pattern_controller.force_start_for_test())
	assert_eq(c.budget.active_count(), 0)

func test_denied_fair_warning_does_not_repeat_sixty_physics_sweeps_per_second() -> void:
	var c := _context()
	if c.is_empty(): return
	var attempts := [0]
	c.actor.pattern_controller.start_permission = func(): attempts[0] += 1; return false
	c.actor.pattern_controller.advance(0.65)
	for unused in range(5): c.actor.pattern_controller.advance(1.0 / 60.0)
	assert_eq(attempts[0], 1)
	c.actor.pattern_controller.advance(0.02)
	assert_eq(attempts[0], 2)

func test_active_dash_cannot_make_an_enemy_blocked_walk_route_look_safe() -> void:
	var c := _context()
	if c.is_empty(): return
	c.player.process_mode = Node.PROCESS_MODE_DISABLED
	var player = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(player)
	player.set_physics_process(false)
	c.actor.configure_target(player)
	for position in [Vector2(40, 0), Vector2(-40, 0), Vector2(0, 40), Vector2(0, -40)]:
		var wall := StaticBody2D.new()
		wall.collision_layer = 2
		var collision := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(8, 100) if position.x != 0 else Vector2(100, 8)
		collision.shape = rectangle
		wall.add_child(collision)
		wall.position = position
		add_child_autofree(wall)
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_true(player.request_dash())
	assert_false(c.actor.pattern_controller.force_start_for_test(), "The post-dash walking mask must include enemies even during invulnerability.")
	assert_eq(c.budget.active_count(), 0)

func test_escape_solver_rejects_crossing_another_danger_even_with_safe_endpoint() -> void:
	var c := _context()
	if c.is_empty(): return
	var solver = load("res://scripts/enemies/encounter_escape_solver.gd")
	var dangers := [GEOMETRY.new(Vector2.ZERO, Vector2.ZERO, 20.0), GEOMETRY.new(Vector2(64, -200), Vector2(64, 200), 10.0)]
	var result: Dictionary = solver.find_escape(Vector2.ZERO, 120.0, 20.0, dangers, Callable())
	assert_true(result.ok)
	assert_lt(result.destination.x, 34.0, "Safe endpoint across the lane is not a safe path.")
	assert_false(solver.find_escape(Vector2.ZERO, 120.0, 20.0, [GEOMETRY.new(Vector2.ZERO, Vector2.ZERO, 300.0)], Callable()).ok)
