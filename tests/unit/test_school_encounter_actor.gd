extends GutTest

const ACTOR_SCENE := preload("res://scenes/enemies/school_encounter_actor.tscn")
const ENCOUNTER_CATALOG_SCRIPT := preload("res://scripts/data/encounter_catalog.gd")
const PATTERN_PROJECTILE_META := &"ninja_encounter_pattern_projectile"
const BONGMA_BOSS_ID := &"hundred_demon_array_master"
const BONGMA_FAMILIAR_TEXTURE := "res://assets/runtime/encounters/summons/bongma_hundred_demon_familiar.png"
const BONGMA_FAMILIAR_VISUAL_SCALE := 0.03


class DamageTarget extends Node2D:
	var received_damage: int = 0

	func take_damage(amount: int) -> int:
		received_damage += amount
		return amount


func test_core_actor_configures_without_a_pattern_controller_or_projectile_attack() -> void:
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	actor.global_position = Vector2.ZERO
	assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(&"shikigami_handler")))

	var target := DamageTarget.new()
	add_child_autofree(target)
	target.global_position = Vector2(120.0, 0.0)
	assert_true(actor.configure_target(target))

	assert_true(actor.definition.pattern_definitions.is_empty(), "Core definitions must not retain a hidden special attack schedule.")
	assert_null(actor.pattern_controller, "Core actors must use EnemyChaser pursuit/contact instead of creating a pattern controller.")
	assert_eq(_pattern_projectile_count(actor), 0)


func test_reconfiguring_an_elite_as_a_core_clears_its_special_runtime_effects() -> void:
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
	assert_eq(actor.active_proxy_count(), 1)

	assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(&"shikigami_handler")))
	assert_null(actor.pattern_controller)
	assert_eq(actor.active_proxy_count(), 0, "A Core reconfiguration must not retain an Elite proxy hazard.")


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


func test_bongma_summon_proxy_uses_the_locked_familiar_cutout_without_tinting_it() -> void:
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	actor.global_position = Vector2.ZERO
	assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(BONGMA_BOSS_ID)))

	var target := DamageTarget.new()
	add_child_autofree(target)
	target.global_position = Vector2(120.0, 0.0)
	assert_true(actor.configure_target(target))
	var proxy_pattern := _pattern_with_primitive(actor.definition.pattern_definitions, &"summon_or_proxy")
	assert_false(proxy_pattern.is_empty(), "The Bongma Boss must retain its approved summon/proxy pattern.")
	if proxy_pattern.is_empty():
		return

	actor._on_pattern_state_changed(&"telegraph", proxy_pattern)
	actor._on_pattern_execute_requested(proxy_pattern)

	var proxy := actor.get_node_or_null("EncounterProxy") as Node2D
	assert_not_null(proxy)
	if proxy == null:
		return
	var visual := proxy.get_node_or_null("Visual") as Sprite2D
	assert_not_null(visual)
	if visual != null:
		assert_not_null(visual.texture)
		if visual.texture != null:
			assert_eq(visual.texture.resource_path, BONGMA_FAMILIAR_TEXTURE)
		assert_eq(visual.scale, Vector2.ONE * BONGMA_FAMILIAR_VISUAL_SCALE)
		assert_eq(visual.modulate, Color.WHITE)


func _pattern_projectile_count(actor: Node) -> int:
	var count := 0
	for child in actor.get_children():
		if bool(child.get_meta(PATTERN_PROJECTILE_META, false)):
			count += 1
	return count


func _pattern_with_primitive(patterns: Array, primitive_id: StringName) -> Dictionary:
	for pattern in patterns:
		if StringName(pattern.get("primitive_id", &"")) == primitive_id:
			return pattern
	return {}
