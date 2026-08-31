extends GutTest

const ACTOR_SCENE := preload("res://scenes/enemies/school_encounter_actor.tscn")
const ENCOUNTER_CATALOG_SCRIPT := preload("res://scripts/data/encounter_catalog.gd")
const PATTERN_PROJECTILE_META := &"ninja_encounter_pattern_projectile"


class DamageTarget extends Node2D:
	var received_damage: int = 0

	func take_damage(amount: int) -> int:
		received_damage += amount
		return amount


func test_ranged_core_execution_spawns_a_pattern_projectile() -> void:
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	actor.global_position = Vector2.ZERO
	assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(&"shikigami_handler")))

	var target := DamageTarget.new()
	add_child_autofree(target)
	target.global_position = Vector2(120.0, 0.0)
	assert_true(actor.configure_target(target))

	actor._on_pattern_execute_requested(actor.definition.pattern_definitions[0])

	assert_eq(_pattern_projectile_count(actor), 1, "A ranged Core must emit a physical projectile instead of only resolving contact damage.")


func test_telegraphed_zone_uses_the_locked_warning_position() -> void:
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	actor.global_position = Vector2.ZERO
	assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(&"five_element_tuner")))

	var target := DamageTarget.new()
	add_child_autofree(target)
	target.global_position = Vector2(120.0, 0.0)
	assert_true(actor.configure_target(target))
	var zone_pattern: Dictionary = actor.definition.pattern_definitions[0]

	actor._on_pattern_state_changed(&"telegraph", zone_pattern)
	target.global_position = Vector2(360.0, 0.0)
	actor._on_pattern_execute_requested(zone_pattern)

	assert_eq(target.received_damage, 0, "Moving out of a telegraphed zone before execution must avoid its damage.")


func _pattern_projectile_count(actor: Node) -> int:
	var count := 0
	for child in actor.get_children():
		if bool(child.get_meta(PATTERN_PROJECTILE_META, false)):
			count += 1
	return count
