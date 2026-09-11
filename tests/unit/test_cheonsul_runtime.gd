extends GutTest

const RUNTIME_PATH := "res://scripts/schools/cheonsul_runtime.gd"
const BADGE_SCRIPT_PATH := "res://scripts/ui/enemy_effect_badge.gd"
const BADGE_SCENE_PATH := "res://scenes/ui/enemy_effect_badge.tscn"
const PLAYER_PATH := "res://scripts/player/player_controller.gd"
const ENEMY_PATH := "res://scripts/enemies/enemy_chaser.gd"
const TRACKER_PATH := "res://scripts/combat/combat_contribution_tracker.gd"
const RESOLVER_PATH := "res://scripts/combat/combat_resolver.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"
const FIELD_VISUAL_TEXTURE_PATH := "res://assets/runtime/visual-core/cheonsul_flame_field_v1.png"


func test_breath_hits_unmarked_front_not_back_and_stops_after_six_ticks() -> void:
	var runtime = _make_runtime()
	runtime._cast_remaining = 999.0
	var front = _enemy(runtime.world, Vector2(100, 0), 300)
	var back = _enemy(runtime.world, Vector2(-100, 0), 300)
	runtime.reaction_count = 3.0
	assert_true(runtime.try_use_ultimate())
	assert_eq(front.health, 292)
	assert_eq(back.health, 300)
	runtime._process(1.5)
	assert_eq(front.health, 252)
	assert_eq(back.health, 300)
	runtime._process(1.0)
	assert_eq(front.health, 252)


func test_breath_dash_cancels_remaining_damage_without_refund() -> void:
	var runtime = _make_runtime()
	runtime._cast_remaining = 999.0
	var enemy = _enemy(runtime.world, Vector2(100, 0))
	runtime.player.set_movement_intent(Vector2.RIGHT)
	runtime.reaction_count = 3.0
	assert_true(runtime.try_use_ultimate())
	assert_true(runtime.player.request_dash())
	runtime._process(1.5)
	assert_eq(enemy.health, 92)
	assert_eq(runtime.reaction_count, 0.0)


func test_breath_direct_request_cannot_bypass_pause() -> void:
	var runtime = _make_runtime()
	var enemy = _enemy(runtime.world, Vector2(100, 0))
	runtime.apply_token(enemy, &"wet")
	runtime.reaction_count = 3.0
	get_tree().paused = true
	var used: bool = runtime.try_use_ultimate()
	get_tree().paused = false
	assert_false(used)
	assert_eq(enemy.health, 100)
	assert_eq(runtime.reaction_count, 3.0)


func test_breath_remembers_movement_and_locks_direction_while_origin_moves() -> void:
	var runtime = _make_runtime()
	runtime._cast_remaining = 999.0
	runtime.player.set_movement_intent(Vector2.UP)
	runtime.player.set_movement_intent(Vector2.ZERO)
	var front = _enemy(runtime.world, Vector2(0, -100))
	var back = _enemy(runtime.world, Vector2(0, 100))
	runtime.reaction_count = 3.0
	assert_true(runtime.try_use_ultimate())
	assert_eq(front.health, 92)
	assert_eq(back.health, 100)
	runtime.player.set_movement_intent(Vector2.DOWN)
	runtime.player.position = Vector2(0, -250)
	runtime._process(0.25)
	assert_eq(front.health, 92, "Previously hit target is now behind the moving origin")
	assert_eq(back.health, 100)


func test_breath_catchup_respects_status_expiry_between_ticks() -> void:
	var runtime = _make_runtime()
	runtime._cast_remaining = 999.0
	var enemy = _enemy(runtime.world, Vector2(100, 0), 300)
	runtime.apply_token(enemy, &"wet")
	runtime._states[enemy.get_instance_id()]["wet_remaining"] = 0.3
	runtime.reaction_count = 3.0
	assert_true(runtime.try_use_ultimate())
	runtime._process(1.5)
	assert_eq(enemy.health, 248, "Only ticks at 0 and 0.25 receive the status bonus")


func test_breath_uses_automatic_weapon_direction_before_first_movement() -> void:
	var runtime = _make_runtime()
	var weapon = load("res://scripts/combat/basic_weapon_controller.gd").new()
	runtime.player.add_child(weapon)
	var enemy = _enemy(runtime.world, Vector2(0, 80), 300)
	assert_eq(weapon.swing_katana_once(), 1)
	runtime.reaction_count = 3.0
	assert_true(runtime.try_use_ultimate())
	assert_eq(enemy.health, 282)


func test_breath_rejects_hidden_activation_target_without_cost() -> void:
	var runtime = _make_runtime()
	var enemy = _enemy(runtime.world, Vector2(100, 0))
	enemy.hide()
	runtime.reaction_count = 3.0
	assert_false(runtime.try_use_ultimate())
	assert_eq(runtime.reaction_count, 3.0)
	assert_eq(enemy.health, 100)


func test_breath_geometry_boundaries_and_death_stop() -> void:
	var runtime = _make_runtime()
	runtime._cast_remaining = 999.0
	var inside = _enemy(runtime.world, Vector2(320, 0), 300)
	var outside = _enemy(runtime.world, Vector2(321, 0), 300)
	var angle_in = _enemy(runtime.world, Vector2(100, 0).rotated(deg_to_rad(30)), 300)
	var angle_out = _enemy(runtime.world, Vector2(100, 0).rotated(deg_to_rad(31)), 300)
	runtime.reaction_count = 3.0
	assert_true(runtime.try_use_ultimate())
	assert_eq(inside.health, 292)
	assert_eq(outside.health, 300)
	assert_eq(angle_in.health, 292)
	assert_eq(angle_out.health, 300)
	runtime.player.take_damage(10000)
	runtime._process(1.5)
	assert_eq(inside.health, 292)
	assert_false(runtime.try_use_ultimate())


func test_breath_offscreen_start_rejected_but_active_ticks_use_world_geometry() -> void:
	var runtime = _make_runtime()
	runtime._cast_remaining = 999.0
	var enemy = _enemy(runtime.world, Vector2(100, 0), 300)
	var viewport: Viewport = runtime.get_viewport()
	var original: Transform2D = viewport.canvas_transform
	viewport.canvas_transform = Transform2D(0, Vector2(2000, 2000))
	runtime.reaction_count = 3.0
	assert_false(runtime.try_use_ultimate())
	assert_eq(runtime.reaction_count, 3.0)
	viewport.canvas_transform = original
	assert_true(runtime.try_use_ultimate())
	viewport.canvas_transform = Transform2D(0, Vector2(2000, 2000))
	runtime._process(0.25)
	assert_eq(enemy.health, 284, "Active world-space attack does not shrink with the viewport")


func test_breath_pause_freezes_ticks_and_deactivate_cancels_without_refund() -> void:
	var runtime = _make_runtime()
	runtime._cast_remaining = 999.0
	var enemy = _enemy(runtime.world, Vector2(100, 0), 300)
	runtime.reaction_count = 3.0
	assert_true(runtime.try_use_ultimate())
	get_tree().paused = true
	runtime._process(1.5)
	get_tree().paused = false
	assert_eq(enemy.health, 292)
	runtime._process(0.25)
	assert_eq(enemy.health, 284)
	runtime.deactivate()
	runtime._process(1.5)
	assert_eq(enemy.health, 284)
	assert_eq(runtime.reaction_count, 0.0)


func _make_runtime():
	assert_true(ResourceLoader.exists(RUNTIME_PATH), "Cheonsul runtime script must exist")
	assert_true(ResourceLoader.exists(BADGE_SCENE_PATH), "Enemy effect badge scene must exist")
	if not ResourceLoader.exists(RUNTIME_PATH) or not ResourceLoader.exists(BADGE_SCENE_PATH):
		return null
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152, 648)
	add_child_autofree(viewport)
	viewport.canvas_transform = Transform2D(0, Vector2(576, 324))
	var world := Node2D.new()
	viewport.add_child(world)
	var player = load(PLAYER_PATH).new()
	world.add_child(player)
	var runtime = load(RUNTIME_PATH).new()
	runtime.badge_scene = load(BADGE_SCENE_PATH)
	world.add_child(runtime)
	runtime.configure(player, world)
	runtime.activate()
	return runtime


func _enemy(world: Node2D, position: Vector2, maximum_health: int = 100):
	var enemy = load(ENEMY_PATH).new()
	enemy.max_health = maximum_health
	enemy.global_position = position
	world.add_child(enemy)
	return enemy


func _configure_run_systems(runtime, modifiers = null) -> Dictionary:
	var tracker = load(TRACKER_PATH).new()
	runtime.world.add_child(tracker)
	tracker.reset_segment(0, 0)
	var resolver = load(RESOLVER_PATH).new()
	runtime.world.add_child(resolver)
	resolver.configure(tracker)
	runtime.configure_run_systems(resolver, tracker)
	if modifiers == null:
		modifiers = load(MODIFIER_PATH).new()
	resolver.set_modifiers(modifiers)
	runtime.apply_run_modifiers(modifiers)
	return {"tracker": tracker, "resolver": resolver}


func test_enemy_effect_badge_is_minimal_text_view() -> void:
	assert_true(ResourceLoader.exists(BADGE_SCRIPT_PATH), "Enemy effect badge script must exist")
	assert_true(ResourceLoader.exists(BADGE_SCENE_PATH), "Enemy effect badge scene must exist")
	if not ResourceLoader.exists(BADGE_SCENE_PATH):
		return
	var badge = load(BADGE_SCENE_PATH).instantiate()
	add_child_autofree(badge)
	assert_true(badge.has_method("set_text"))
	badge.set_text("BURN/WET")
	assert_eq(badge.text, "BURN/WET")


func test_flame_cast_hits_radius_and_burn_ticks_once_per_second() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var near_enemy = _enemy(runtime.world, Vector2(40, 0))
	var far_enemy = _enemy(runtime.world, Vector2(140, 0))

	watch_signals(runtime)
	assert_eq(runtime.apply_flame_cast(Vector2.ZERO), 1)
	assert_eq(near_enemy.health, 94)
	assert_eq(far_enemy.health, 100)
	assert_signal_emitted(runtime, "player_action_resolved")
	assert_true(runtime.has_status(near_enemy, &"burn"))
	runtime._cast_remaining = 999.0

	runtime._process(1.0)
	assert_eq(near_enemy.health, 92)
	runtime._process(1.0)
	assert_eq(near_enemy.health, 90)


func test_flame_cast_without_a_target_does_not_emit_player_action() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	watch_signals(runtime)
	assert_eq(runtime.apply_flame_cast(Vector2(9999, 9999)), 0)
	assert_signal_not_emitted(runtime, "player_action_resolved")


func test_flame_cast_spawns_a_textured_runtime_field_visual() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var center := Vector2(56, -24)
	runtime.apply_flame_cast(center)
	var field_visual: Node = runtime.get_node_or_null("FlameFieldVisual")
	assert_true(field_visual is Sprite2D, "Cheonsul field must render through a Sprite2D consumer")
	if not field_visual is Sprite2D:
		return
	assert_true(ResourceLoader.exists(FIELD_VISUAL_TEXTURE_PATH), "Cheonsul field source must exist locally")
	assert_not_null(field_visual.texture, "Cheonsul field must consume the approved local texture")
	assert_eq(field_visual.global_position, center)


func test_same_token_refreshes_four_second_duration() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	runtime._cast_remaining = 999.0
	assert_false(runtime.apply_token(enemy, &"wet"))
	runtime._process(3.5)
	assert_true(runtime.has_status(enemy, &"wet"))
	assert_false(runtime.apply_token(enemy, &"wet"))
	runtime._process(3.5)
	assert_true(runtime.has_status(enemy, &"wet"))
	runtime._process(0.6)
	assert_false(runtime.has_status(enemy, &"wet"))


func test_wet_then_shock_reacts_once_and_chain_is_non_recursive() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var target = _enemy(runtime.world, Vector2.ZERO)
	var chain = _enemy(runtime.world, Vector2(80, 0))
	var far_enemy = _enemy(runtime.world, Vector2(180, 0))

	assert_false(runtime.apply_token(target, &"wet"))
	assert_true(runtime.apply_token(target, &"shock"))
	assert_eq(target.health, 90)
	assert_eq(chain.health, 94)
	assert_eq(far_enemy.health, 100)
	assert_eq(runtime.reaction_count, 1.0)
	assert_false(runtime.has_status(target, &"wet"))
	assert_false(runtime.has_status(target, &"shock"))
	assert_false(runtime.has_status(chain, &"wet"))
	assert_false(runtime.has_status(chain, &"shock"))


func test_shock_then_wet_waits_for_next_shock() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	assert_false(runtime.apply_token(enemy, &"shock"))
	assert_false(runtime.apply_token(enemy, &"wet"))
	assert_eq(runtime.reaction_count, 0.0)
	assert_true(runtime.has_status(enemy, &"shock"))
	assert_true(runtime.has_status(enemy, &"wet"))
	assert_true(runtime.apply_token(enemy, &"shock"))
	assert_eq(runtime.reaction_count, 1.0)


func test_fractional_reaction_readiness_uses_resource_and_ultimate_gain() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.ultimate_charge_gain_pct = 0.25
	_configure_run_systems(runtime, modifiers)
	var enemy = _enemy(runtime.world, Vector2.ZERO, 300)
	for _index in range(2):
		runtime.apply_token(enemy, &"wet")
		assert_true(runtime.apply_token(enemy, &"shock"))
	assert_almost_eq(float(runtime.reaction_count), 2.5, 0.001)
	assert_false(runtime.is_ultimate_ready())
	runtime.apply_token(enemy, &"wet")
	assert_true(runtime.apply_token(enemy, &"shock"))
	assert_almost_eq(float(runtime.reaction_count), 3.0, 0.001)
	assert_true(runtime.is_ultimate_ready())


func test_reaction_charge_clamps_and_breath_preserves_status_for_bonus() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO, 300)
	for _index in range(4):
		runtime.apply_token(enemy, &"wet")
		runtime.apply_token(enemy, &"shock")
	assert_eq(runtime.reaction_count, 3.0)
	assert_true(runtime.is_ultimate_ready())

	runtime.apply_token(enemy, &"wet")
	var health_before: int = enemy.health
	assert_true(runtime.try_use_ultimate())
	assert_eq(enemy.health, health_before - 10)
	assert_eq(runtime.reaction_count, 0.0)
	assert_true(runtime.has_status(enemy, &"wet"))
	assert_false(runtime.is_ultimate_ready())


func test_emblem_and_forbidden_path_multiply_reaction_and_chain_damage() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.cheonsul_reaction_damage_pct = 0.20
	modifiers.school_status_effect_pct = 0.20
	var systems := _configure_run_systems(runtime, modifiers)
	var target = _enemy(runtime.world, Vector2.ZERO, 100)
	var chain = _enemy(runtime.world, Vector2(80, 0), 100)
	assert_false(runtime.apply_token(target, &"wet"))
	assert_true(runtime.apply_token(target, &"shock"))
	assert_eq(target.health, 86)
	assert_eq(chain.health, 91)
	assert_eq(systems.tracker.damage, 23)


func test_forbidden_status_multiplier_does_not_increase_burn_tick_damage() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_status_effect_pct = 0.50
	_configure_run_systems(runtime, modifiers)
	var enemy = _enemy(runtime.world, Vector2.ZERO, 100)
	assert_eq(runtime.apply_flame_cast(Vector2.ZERO), 1)
	assert_eq(enemy.health, 94)
	runtime._cast_remaining = 999.0
	runtime._process(1.0)
	assert_eq(enemy.health, 92)


func test_seal_path_penalizes_non_ultimate_damage_but_strengthens_ultimate() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.non_ultimate_school_damage_pct = -0.50
	modifiers.ultimate_power_pct = 0.50
	_configure_run_systems(runtime, modifiers)
	var enemy = _enemy(runtime.world, Vector2.ZERO, 300)
	assert_eq(runtime.apply_flame_cast(Vector2.ZERO), 1)
	assert_eq(enemy.health, 297)
	runtime.reaction_count = 3.0
	var health_before: int = enemy.health
	assert_true(runtime.try_use_ultimate())
	assert_eq(enemy.health, health_before - 15)


func test_successful_status_applications_and_reaction_are_recorded_once_each() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var systems := _configure_run_systems(runtime)
	var enemy = _enemy(runtime.world, Vector2.ZERO, 200)
	assert_eq(runtime.apply_flame_cast(Vector2.ZERO), 1)
	assert_eq(systems.tracker.damage, 6)
	assert_eq(systems.tracker.status_events, 2, "Flame hit should record BURN and WET applications")
	assert_false(runtime.apply_token(enemy, &"invalid"))
	assert_eq(systems.tracker.status_events, 2)
	assert_true(runtime.apply_token(enemy, &"shock"))
	assert_eq(systems.tracker.status_events, 4, "SHOCK application and the actual reaction are separate successful events")


func test_ultimate_without_status_target_preserves_ready_charge() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.reaction_count = 3.0
	assert_true(runtime.is_ultimate_ready())
	assert_false(runtime.try_use_ultimate())
	assert_eq(runtime.reaction_count, 3.0)


func test_deactivate_clears_owned_state_and_badges() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	runtime.apply_token(enemy, &"wet")
	assert_true(runtime.has_status(enemy, &"wet"))
	var badge: Node = enemy.get_node_or_null("EnemyEffectBadge")
	assert_not_null(badge)

	runtime.deactivate()
	assert_false(runtime.has_status(enemy, &"wet"))
	assert_true(badge == null or badge.is_queued_for_deletion())


func test_automatic_cast_waits_one_point_eight_seconds_and_alternates_tokens() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2(30, 0), 200)
	runtime._process(1.79)
	assert_eq(enemy.health, 200)
	runtime._process(0.01)
	assert_eq(enemy.health, 194)
	assert_true(runtime.has_status(enemy, &"wet"))
	runtime._process(1.80)
	assert_eq(runtime.reaction_count, 1.0)


func test_automatic_shock_prioritizes_existing_wet_target() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var wet_enemy = _enemy(runtime.world, Vector2(110, 0), 200)
	var fresh_near_enemy = _enemy(runtime.world, Vector2(-20, 0), 200)
	assert_false(runtime.apply_token(wet_enemy, &"wet"))
	runtime._next_token = &"shock"
	runtime._cast_remaining = 0.0

	runtime._process(0.01)

	assert_eq(runtime.reaction_count, 1.0, "SHOCK should chase a live WET target so reaction charge progresses reliably")
	assert_lt(wet_enemy.health, 200)
	assert_eq(fresh_near_enemy.health, 200, "The closer fresh enemy should not steal the SHOCK cast from an existing WET target")
