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


func test_line_dash_relocates_to_the_locked_lane_without_hitting_a_player_who_evades_sideways() -> void:
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	actor.global_position = Vector2.ZERO
	assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(&"ghost_general")))

	var target := DamageTarget.new()
	add_child_autofree(target)
	target.global_position = Vector2(180.0, 0.0)
	assert_true(actor.configure_target(target))
	var dash_pattern: Dictionary = actor.definition.pattern_definitions[0]

	actor._on_pattern_state_changed(&"telegraph", dash_pattern)
	target.global_position = Vector2(180.0, 110.0)
	actor._on_pattern_execute_requested(dash_pattern)

	assert_eq(target.received_damage, 0, "Dash damage must remain on the telegraphed lane so sideways evasion is fair.")
	assert_eq(actor.global_position, Vector2(180.0, 0.0), "The enemy must complete the announced dash path instead of tracking the new player position.")


func test_summon_proxy_creates_a_delayed_hazard_instead_of_direct_contact_damage() -> void:
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	actor.global_position = Vector2.ZERO
	assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(&"shadow_chief")))

	var target := DamageTarget.new()
	add_child_autofree(target)
	target.global_position = Vector2(120.0, 0.0)
	assert_true(actor.configure_target(target))
	var proxy_pattern: Dictionary = actor.definition.pattern_definitions[1]

	actor._on_pattern_state_changed(&"telegraph", proxy_pattern)
	actor._on_pattern_execute_requested(proxy_pattern)

	assert_eq(target.received_damage, 0, "Proxy creation itself must not be indistinguishable from immediate contact damage.")
	assert_eq(actor.active_proxy_count(), 1, "A summon/proxy pattern must create one independently armed delayed hazard.")


func _pattern_projectile_count(actor: Node) -> int:
	var count := 0
	for child in actor.get_children():
		if bool(child.get_meta(PATTERN_PROJECTILE_META, false)):
			count += 1
	return count
