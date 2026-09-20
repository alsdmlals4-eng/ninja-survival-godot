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


func test_fan_projectiles_keep_announced_origin_and_direction_after_target_moves() -> void:
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	actor.set_physics_process(false)
	actor.global_position = Vector2(100, 50)
	assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(&"heavenly_change_taoist")))
	var target := DamageTarget.new()
	add_child_autofree(target)
	target.global_position = Vector2(300, 50)
	actor.configure_target(target)
	var fan := _pattern_with_primitive(actor.definition.pattern_definitions, &"fan_or_arc_projectile")
	actor._on_pattern_state_changed(&"telegraph", fan)
	target.global_position = Vector2(100, 300)
	actor.global_position = Vector2(140, 70)
	actor._on_pattern_execute_requested(fan)
	var bullets: Array = []
	for child in actor.get_children():
		if child.has_meta(PATTERN_PROJECTILE_META): bullets.append(child)
	assert_eq(bullets.size(), 3)
	if bullets.size() != 3: return
	assert_eq(bullets[1].global_position, Vector2(100, 50), "Shot origin must remain at the announced position.")
	assert_almost_eq(bullets[1].direction, Vector2.RIGHT, Vector2.ONE * 0.001, "Moving sideways during warning must not be countered by last-frame retargeting.")
	assert_almost_eq(bullets[0].direction.angle(), -0.22, 0.001)
	assert_almost_eq(bullets[2].direction.angle(), 0.22, 0.001)
	var aim = actor._telegraph_visual.get_node_or_null("ProjectileAim")
	assert_not_null(aim, "Projectile warning must show the announced directions, not a generic damage circle.")
	if aim != null:
		assert_eq(aim.rays.size(), 3)
		assert_almost_eq(aim.rays[1], Vector2.RIGHT, Vector2.ONE * 0.001)


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

func test_world_offset_and_caster_motion_cannot_displace_locked_warning() -> void:
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	actor.global_position = Vector2(215.0, -80.0)
	assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(&"five_element_tuner")))
	var target := DamageTarget.new()
	add_child_autofree(target)
	target.global_position = Vector2(410.0, 135.0)
	assert_true(actor.configure_target(target))
	var zone_pattern: Dictionary = actor.definition.pattern_definitions[0]
	actor._on_pattern_state_changed(&"telegraph", zone_pattern)
	assert_eq(actor._telegraph_visual.global_position, Vector2(410.0, 135.0), "Rendered warning must equal damage center away from world origin.")
	actor.global_position += Vector2(50.0, 15.0)
	assert_eq(actor._telegraph_visual.global_position, Vector2(410.0, 135.0), "Locked field must not follow caster transforms.")
	target.global_position = Vector2(410.0, 135.0)
	actor._on_pattern_execute_requested(zone_pattern)
	assert_gt(target.received_damage, 0)


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


func test_warning_geometry_and_damage_agree_at_zone_and_lane_boundaries() -> void:
	for fixture in [
		{ "actor": &"five_element_tuner", "primitive": &"telegraphed_zone", "inside": Vector2(502, 135), "outside": Vector2(502.1, 135) },
		{ "actor": &"ghost_general", "primitive": &"line_dash", "inside": Vector2(310, 165), "outside": Vector2(310, 165.1) },
	]:
		var actor = ACTOR_SCENE.instantiate()
		add_child_autofree(actor)
		actor.global_position = Vector2(210, 135)
		assert_true(actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(fixture.actor)))
		var target := DamageTarget.new()
		add_child_autofree(target)
		target.global_position = Vector2(410, 135)
		actor.configure_target(target)
		var pattern := _pattern_with_primitive(actor.definition.pattern_definitions, fixture.primitive)
		actor._on_pattern_state_changed(&"telegraph", pattern)
		var geometry = actor._telegraph_visual.get("geometry")
		assert_not_null(geometry, "Warning must consume the locked damage geometry, not an unrelated image scale.")
		if geometry == null:
			continue
		assert_true(geometry.contains(fixture.inside))
		assert_false(geometry.contains(fixture.outside))
		target.global_position = fixture.outside
		actor._on_pattern_execute_requested(pattern)
		assert_eq(target.received_damage, 0)
		target.global_position = fixture.inside
		actor._on_pattern_execute_requested(pattern)
		assert_gt(target.received_damage, 0)


func test_every_spawnable_actor_has_a_visible_runtime_texture_and_preserves_locked_art() -> void:
	for definition in ENCOUNTER_CATALOG_SCRIPT.build_actor_definitions().values():
		var actor = ACTOR_SCENE.instantiate()
		add_child_autofree(actor)
		assert_true(actor.configure_definition(definition))
		var visual: Sprite2D = actor.get_node("Visual")
		assert_not_null(visual.texture, "%s must not be an invisible damaging enemy when final art is absent." % definition.actor_id)
		if ResourceLoader.exists(definition.visual_asset_path) and visual.texture != null:
			assert_eq(visual.texture.resource_path, definition.visual_asset_path)


func test_proxy_keeps_its_boundary_until_delayed_damage_even_after_caster_recovers() -> void:
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	actor.configure_definition(ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(&"shadow_chief"))
	var target := DamageTarget.new()
	add_child_autofree(target)
	target.position = Vector2(120, 0)
	actor.configure_target(target)
	var pattern := _pattern_with_primitive(actor.definition.pattern_definitions, &"summon_or_proxy")
	actor._on_pattern_state_changed(&"telegraph", pattern)
	actor._on_pattern_execute_requested(pattern)
	actor._on_pattern_state_changed(&"recovery", pattern)
	var proxy := actor.get_node("EncounterProxy")
	var warning := proxy.get_node_or_null("DangerBoundary")
	assert_not_null(warning, "Proxy must retain its own boundary after the actor's execute phase ends.")
	if warning == null:
		return
	actor._advance_runtime_effects(0.34)
	assert_false(warning.is_queued_for_deletion())
	assert_eq(target.received_damage, 0)
	actor._advance_runtime_effects(0.02)
	assert_gt(target.received_damage, 0)
	assert_true(warning.is_queued_for_deletion(), "Single-hit danger cue ends when its actual damage is resolved.")


func _pattern_with_primitive(patterns: Array, primitive_id: StringName) -> Dictionary:
	for pattern in patterns:
		if StringName(pattern.get("primitive_id", &"")) == primitive_id:
			return pattern
	return {}
