extends GutTest


func test_normal_bind_ends_then_has_two_seconds_rebind_protection() -> void:
	var enemy := EnemyChaser.new()
	add_child_autofree(enemy)
	assert_true(enemy.has_method("apply_book_control"))
	if not enemy.has_method("apply_book_control"):
		return
	assert_true(enemy.call("apply_book_control", &"chain", 0.6, 0.0, true))
	assert_eq(enemy.call("book_movement_multiplier"), 0.0)
	enemy.call("advance_book_control", 0.6)
	assert_eq(enemy.call("book_movement_multiplier"), 1.0)
	assert_false(enemy.call("apply_book_control", &"seal", 0.4, 0.0, true))
	enemy.call("advance_book_control", 2.0)
	assert_true(enemy.call("apply_book_control", &"seal", 0.4, 0.0, true))


func test_boss_bind_becomes_slow_without_mutating_base_speed() -> void:
	var enemy := StageBoss.new()
	add_child_autofree(enemy)
	assert_true(enemy.has_method("apply_book_control"))
	if not enemy.has_method("apply_book_control"):
		return
	var speed := enemy.move_speed
	enemy.call("apply_book_control", &"seal", 0.4, 0.0, true)
	assert_almost_eq(enemy.call("book_movement_multiplier"), 0.9, 0.001)
	assert_eq(enemy.move_speed, speed)
	enemy.call("advance_book_control", 0.4)
	assert_eq(enemy.call("book_movement_multiplier"), 1.0)


func test_encounter_elite_control_does_not_stop_pattern_clock() -> void:
	var enemy := SchoolEncounterActor.new()
	add_child_autofree(enemy)
	var definition = load("res://scripts/data/encounter_catalog.gd").actor_definition_for(&"mobile_array_caster")
	assert_eq(definition.role, &"elite")
	assert_true(enemy.configure_definition(definition))
	enemy.apply_book_control(&"chain", 0.6, 0.0, true)
	assert_almost_eq(enemy.book_movement_multiplier(), 0.8, 0.001)
	var before: float = enemy.pattern_controller._remaining
	enemy._physics_process(0.1)
	assert_lt(float(enemy.pattern_controller._remaining), before)
	enemy.advance_book_control(0.6)
	assert_eq(enemy.book_movement_multiplier(), 1.0)
	assert_not_null(enemy.pattern_controller, "control never removes the pattern owner")


func test_slow_cap_source_removal_pause_and_overshoot() -> void:
	var enemy := EnemyChaser.new()
	add_child_autofree(enemy)
	assert_true(enemy.has_method("apply_book_control"))
	if not enemy.has_method("apply_book_control"):
		return
	enemy.call("apply_book_control", &"water", 2.0, 0.25, false)
	enemy.call("apply_book_control", &"other", 2.0, 0.8, false)
	assert_almost_eq(enemy.call("book_movement_multiplier"), 0.6, 0.001)
	enemy.call("remove_book_control", &"other")
	assert_almost_eq(enemy.call("book_movement_multiplier"), 0.75, 0.001)
	get_tree().paused = true
	enemy.call("advance_book_control", 20.0)
	get_tree().paused = false
	assert_almost_eq(enemy.call("book_movement_multiplier"), 0.75, 0.001)
	enemy.call("apply_book_control", &"chain", 0.6, 0.0, true)
	enemy.call("advance_book_control", 3.0)
	assert_true(enemy.call("apply_book_control", &"chain", 0.6, 0.0, true))
