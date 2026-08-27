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


func _make_runtime():
	assert_true(ResourceLoader.exists(RUNTIME_PATH), "Cheonsul runtime script must exist")
	assert_true(ResourceLoader.exists(BADGE_SCENE_PATH), "Enemy effect badge scene must exist")
	if not ResourceLoader.exists(RUNTIME_PATH) or not ResourceLoader.exists(BADGE_SCENE_PATH):
		return null
	var world := Node2D.new()
	add_child_autofree(world)
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


func test_reaction_charge_clamps_at_three_and_ultimate_clears_statuses() -> void:
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
	assert_eq(enemy.health, health_before - 18)
	assert_eq(runtime.reaction_count, 0.0)
	assert_false(runtime.has_status(enemy, &"wet"))
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
	assert_eq(enemy.health, health_before - 27)


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
