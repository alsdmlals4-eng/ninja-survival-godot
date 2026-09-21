extends GutTest

const ACTOR = preload("res://scenes/enemies/school_encounter_actor.tscn")
const CATALOG = preload("res://scripts/data/encounter_catalog.gd")

class Target extends Node2D:
	var received := 0
	func take_damage(amount: int) -> int:
		received += amount
		return amount

func _budget(capacity: int):
	var probe = ACTOR.instantiate()
	var supported: bool = probe.has_method("configure_pattern_budget")
	probe.free()
	assert_true(supported, "Selected encounter actors must use the shared danger budget.")
	if not supported: return null
	var budget = load("res://scripts/enemies/encounter_danger_budget.gd").new()
	assert_true(budget.set_capacity(capacity))
	return budget

func _actor(budget, id: StringName = &"five_element_tuner"):
	var actor = ACTOR.instantiate()
	add_child_autofree(actor)
	actor.set_physics_process(false)
	actor.configure_definition(CATALOG.actor_definition_for(id))
	actor.configure_pattern_budget(budget)
	var target := Node2D.new()
	add_child_autofree(target)
	target.position = Vector2(200, 0)
	actor.configure_target(target)
	return actor

func test_capacity_one_blocks_a_second_warning_until_owner_is_removed() -> void:
	var budget = _budget(1)
	if budget == null: return
	var first = _actor(budget)
	var second = _actor(budget)
	assert_true(first.pattern_controller.force_start_for_test())
	assert_false(second.pattern_controller.force_start_for_test())
	assert_eq(second.pattern_state(), &"chase")
	first.queue_free()
	await get_tree().process_frame
	assert_true(second.pattern_controller.force_start_for_test())
	assert_eq(budget.active_count(), 1)

func test_capacity_two_never_admits_a_third_or_duplicate_reservation() -> void:
	var budget = _budget(2)
	if budget == null: return
	var first = _actor(budget)
	var second = _actor(budget)
	var third = _actor(budget)
	assert_true(first.pattern_controller.force_start_for_test())
	assert_true(second.pattern_controller.force_start_for_test())
	assert_false(first.pattern_controller.force_start_for_test())
	assert_false(third.pattern_controller.force_start_for_test())
	assert_eq(budget.active_count(), 2)
	assert_false(budget.set_capacity(3))
	assert_false(third.pattern_controller.force_start_for_test())

func test_projectile_holds_slot_past_recovery_then_releases_when_expired() -> void:
	var budget = _budget(1)
	if budget == null: return
	var first = _actor(budget, &"heavenly_change_taoist")
	var second = _actor(budget)
	assert_true(first.pattern_controller.force_start_for_test())
	first.pattern_controller.advance(first.current_telegraph_duration())
	first.pattern_controller.advance(first.current_execute_duration())
	first.pattern_controller.advance(10.0)
	assert_eq(first.pattern_state(), &"chase")
	assert_false(second.pattern_controller.force_start_for_test(), "Live projectiles outlast the attack state.")
	for child in first.get_children():
		if child.has_meta(first.PATTERN_PROJECTILE_META): child.queue_free()
	await get_tree().process_frame
	first._physics_process(0.0)
	assert_true(second.pattern_controller.force_start_for_test())

func test_pause_freezes_slot_and_does_not_restart_pattern_on_resume() -> void:
	var budget = _budget(1)
	if budget == null: return
	var first = _actor(budget)
	var second = _actor(budget)
	assert_true(first.pattern_controller.force_start_for_test())
	get_tree().paused = true
	first._physics_process(10.0)
	assert_eq(first.pattern_state(), &"telegraph")
	assert_eq(budget.active_count(), 1)
	assert_false(second.pattern_controller.force_start_for_test())
	get_tree().paused = false
	assert_eq(first.pattern_state(), &"telegraph")

func test_fired_projectiles_do_not_inherit_caster_motion_during_slot_hold() -> void:
	var budget = _budget(1)
	if budget == null: return
	var actor = _actor(budget, &"heavenly_change_taoist")
	actor.position = Vector2(100, 50)
	actor.pattern_controller.force_start_for_test()
	actor.pattern_controller.advance(actor.current_telegraph_duration())
	var bullets: Array = []
	for child in actor.get_children():
		if child.has_meta(actor.PATTERN_PROJECTILE_META): bullets.append(child)
	assert_eq(bullets.size(), 3)
	actor.position += Vector2(250, 100)
	for bullet in bullets:
		assert_eq(bullet.global_position, Vector2(100, 50), "Fired enemy bullets are world-space, not attached to the walking caster.")

func test_death_retires_projectile_damage_before_releasing_the_shared_slot() -> void:
	var budget = _budget(1)
	if budget == null: return
	var actor = _actor(budget, &"heavenly_change_taoist")
	actor.pattern_controller.force_start_for_test()
	actor.pattern_controller.advance(actor.current_telegraph_duration())
	var bullet
	for child in actor.get_children():
		if child.has_meta(actor.PATTERN_PROJECTILE_META): bullet = child; break
	assert_not_null(bullet)
	if bullet == null: return
	var target := Target.new()
	add_child_autofree(target)
	actor.take_damage(99999)
	assert_false(bullet.hit_body(target), "Death must disable outstanding attacks before end-of-frame node disposal.")
	assert_eq(target.received, 0)
	assert_eq(budget.active_count(), 0)
