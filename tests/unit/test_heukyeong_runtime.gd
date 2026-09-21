extends GutTest

const RUNTIME_PATH := "res://scripts/schools/heukyeong_runtime.gd"
const BADGE_SCENE_PATH := "res://scenes/ui/enemy_effect_badge.tscn"
const PLAYER_PATH := "res://scripts/player/player_controller.gd"
const ENEMY_PATH := "res://scripts/enemies/enemy_chaser.gd"
const TRACKER_PATH := "res://scripts/combat/combat_contribution_tracker.gd"
const RESOLVER_PATH := "res://scripts/combat/combat_resolver.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"
var _previous_viewport_size: Vector2i


func before_each() -> void:
	_previous_viewport_size = get_tree().root.size
	get_tree().root.size = Vector2i(1152, 648)


func after_each() -> void:
	get_tree().paused = false
	get_tree().root.size = _previous_viewport_size


class ImmuneEnemy:
	extends Node2D


	func _ready() -> void:
		add_to_group("enemies")


	func take_damage(_amount: int) -> int:
		return 0


	func is_dead() -> bool:
		return false


func test_execution_needs_no_marks_prioritizes_boss_elite_then_nearest_and_caps_three() -> void:
	var runtime = _make_runtime()
	runtime._attack_remaining = 999.0
	var normal = _enemy(runtime.world, Vector2(10, 0), 1000)
	var extra = _enemy(runtime.world, Vector2(20, 0), 1000)
	var elite = _enemy(runtime.world, Vector2(100, 0), 1000)
	elite.set_meta(&"school_circuit_role", &"elite")
	var boss = _enemy(runtime.world, Vector2(300, 0), 1000)
	boss.set_meta(&"school_circuit_role", &"boss")
	runtime._process(24.0)
	assert_true(runtime.is_ultimate_ready())
	assert_true(runtime.try_use_ultimate())
	assert_eq(boss.health, 974)
	assert_eq(elite.health, 982)
	assert_eq(normal.health, 982)
	assert_eq(extra.health, 1000)
	assert_false(runtime.is_ultimate_ready())
	assert_false(runtime.try_use_ultimate())


func test_execution_charge_ignores_empty_far_pause_and_death() -> void:
	var runtime = _make_runtime()
	runtime._attack_remaining = 999.0
	runtime._process(24.0)
	assert_false(runtime.is_ultimate_ready())
	var enemy = _enemy(runtime.world, Vector2(481, 0), 1000)
	runtime._process(24.0)
	assert_false(runtime.is_ultimate_ready())
	enemy.position.x = 100
	get_tree().paused = true
	runtime._process(24.0)
	get_tree().paused = false
	assert_false(runtime.is_ultimate_ready())
	runtime._process(24.0)
	assert_true(runtime.is_ultimate_ready())
	enemy.hide()
	assert_false(runtime.try_use_ultimate())
	enemy.show()
	runtime.player.take_damage(99999)
	assert_false(runtime.try_use_ultimate())


func test_owned_marked_direct_damage_bonus_excludes_dot_and_ultimate_and_survives_lethal_cleanup() -> void:
	var runtime = _make_runtime()
	var systems := _configure_run_systems(runtime)
	runtime._attack_remaining = 999.0
	var enemy = _enemy(runtime.world, Vector2(100, 0), 1000)
	runtime.apply_needle_hit(enemy, false)
	assert_eq(runtime.execution_charge, 0.0, "A mark created by this hit is not a preexisting mark.")
	systems.resolver.deal_school_damage(enemy, 2.0, &"normal")
	systems.resolver.deal_school_damage(enemy, 8.0, &"ultimate")
	assert_eq(runtime.execution_charge, 0.0)
	systems.resolver.deal_basic_weapon_damage(enemy, 10.0)
	assert_eq(runtime.execution_charge, 0.25)
	systems.resolver.deal_school_damage(enemy, 6.0, &"direct_injutsu")
	assert_eq(runtime.execution_charge, 0.25)
	runtime._process(1.0)
	assert_eq(runtime.execution_charge, 0.375)
	enemy.died.connect(runtime.on_enemy_died)
	systems.resolver.deal_basic_weapon_damage(enemy, 99999.0)
	assert_eq(runtime.get_mark_count(enemy), 0)
	assert_eq(runtime.execution_charge, 0.625, "Lethal hit keeps its pre-impact marked qualification.")
	assert_true(runtime._pending_direct_hits.is_empty())
	runtime._on_damage_finished(1, 10)
	assert_eq(runtime.execution_charge, 0.625, "Replayed/unknown resolved IDs cannot reward again.")


func test_execution_ties_use_stable_instance_order_and_outside_target_is_excluded() -> void:
	var runtime = _make_runtime()
	var first = _enemy(runtime.world, Vector2(100, 0), 1000)
	var second = _enemy(runtime.world, Vector2(100, 0), 1000)
	var outside = _enemy(runtime.world, Vector2(321, 0), 1000)
	outside.set_meta(&"school_circuit_role", &"boss")
	runtime.execution_charge = 3.0
	assert_true(runtime.try_use_ultimate())
	assert_eq(first.health, 974)
	assert_eq(second.health, 982)
	assert_eq(outside.health, 1000)


func _make_runtime():
	assert_true(ResourceLoader.exists(RUNTIME_PATH), "Heukyeong runtime script must exist")
	if not ResourceLoader.exists(RUNTIME_PATH):
		return null
	var world := Node2D.new()
	add_child_autofree(world)
	var player = load(PLAYER_PATH).new()
	world.add_child(player)
	var runtime = load(RUNTIME_PATH).new()
	if ResourceLoader.exists(BADGE_SCENE_PATH):
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


func test_attack_once_hits_at_most_three_nearest_enemies() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemies: Array[Node] = []
	for distance in [40, 10, 30, 20]:
		enemies.append(_enemy(runtime.world, Vector2(distance, 0)))
	runtime.set_rng_seed(7)
	var hit: Array = runtime.attack_once()
	assert_eq(hit.size(), 3)
	assert_eq(hit[0].global_position.x, 10.0)
	assert_eq(hit[1].global_position.x, 20.0)
	assert_eq(hit[2].global_position.x, 30.0)
	assert_eq(enemies[0].health, 100)


func test_normal_and_critical_hits_apply_exact_damage_and_marks() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	watch_signals(runtime)
	assert_false(runtime.apply_needle_hit(enemy, false))
	assert_eq(enemy.health, 94)
	assert_eq(runtime.get_mark_count(enemy), 1)
	assert_signal_emitted(runtime, "player_action_resolved")
	assert_true(runtime.apply_needle_hit(enemy, true))
	assert_eq(enemy.health, 66)
	assert_eq(runtime.get_mark_count(enemy), 0)


func test_zero_actual_needle_damage_does_not_emit_player_action() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var immune := ImmuneEnemy.new()
	runtime.world.add_child(immune)
	watch_signals(runtime)
	assert_false(runtime.apply_needle_hit(immune, false))
	assert_signal_not_emitted(runtime, "player_action_resolved")


func test_marked_target_uses_emblem_critical_bonus_only_when_marked() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.heukyeong_marked_crit_bonus = 0.15
	runtime.apply_run_modifiers(modifiers)
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	assert_almost_eq(runtime.get_critical_chance(enemy), 0.20, 0.001)
	assert_false(runtime.apply_needle_hit(enemy, false))
	assert_almost_eq(runtime.get_critical_chance(enemy), 0.55, 0.001)
	var fresh = _enemy(runtime.world, Vector2(100, 0))
	assert_almost_eq(runtime.get_critical_chance(fresh), 0.20, 0.001)


func test_mark_badge_is_visible_before_burst() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	runtime.apply_needle_hit(enemy, false)
	var badge: Label = enemy.get_node_or_null("EnemyEffectBadge") as Label
	assert_not_null(badge)
	assert_eq(badge.text, "MARK 1")
	runtime.apply_needle_hit(enemy, true)
	assert_true(badge == null or badge.is_queued_for_deletion())


func test_marks_expire_after_exact_base_eight_second_duration() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	runtime.apply_needle_hit(enemy, false)
	runtime._attack_remaining = 999.0
	runtime._process(7.99)
	assert_eq(runtime.get_mark_count(enemy), 1)
	runtime._process(0.01)
	assert_eq(runtime.get_mark_count(enemy), 0)
	assert_eq(runtime.get_total_active_marks(), 0)


func test_ultimate_treatise_extends_new_marks_to_ten_seconds() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.heukyeong_mark_duration_pct = 0.25
	runtime.apply_run_modifiers(modifiers)
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	runtime.apply_needle_hit(enemy, false)
	runtime._attack_remaining = 999.0
	runtime._process(9.99)
	assert_eq(runtime.get_mark_count(enemy), 1)
	runtime._process(0.01)
	assert_eq(runtime.get_mark_count(enemy), 0)


func test_treatise_plus_seal_readiness_extends_mark_duration_by_fifty_five_percent() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.heukyeong_mark_duration_pct = 0.55
	runtime.apply_run_modifiers(modifiers)
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	runtime.apply_needle_hit(enemy, false)
	runtime._attack_remaining = 999.0
	runtime._process(12.39)
	assert_eq(runtime.get_mark_count(enemy), 1)
	runtime._process(0.01)
	assert_eq(runtime.get_mark_count(enemy), 0)


func test_reapplying_run_modifiers_rescales_existing_mark_remaining_proportionally() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	runtime.apply_needle_hit(enemy, false)
	runtime._attack_remaining = 999.0
	runtime._process(4.0)
	var extended = load(MODIFIER_PATH).new()
	extended.heukyeong_mark_duration_pct = 1.0
	runtime.apply_run_modifiers(extended)
	runtime._process(7.99)
	assert_eq(runtime.get_mark_count(enemy), 1)
	runtime._process(0.01)
	assert_eq(runtime.get_mark_count(enemy), 0)


func test_resource_bonus_uses_fractional_credit_without_fractional_visible_marks() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_resource_gain_pct = 0.20
	runtime.apply_run_modifiers(modifiers)
	var enemies: Array = []
	for index in range(5):
		var enemy = _enemy(runtime.world, Vector2(index * 30, 0), 200)
		enemies.append(enemy)
		assert_false(runtime.apply_needle_hit(enemy, false))
	assert_eq(runtime.get_mark_count(enemies[0]), 1)
	assert_eq(runtime.get_mark_count(enemies[3]), 1)
	assert_eq(runtime.get_mark_count(enemies[4]), 2)
	assert_eq(runtime.get_total_active_marks(), 6)


func test_marks_are_independent_of_execution_charge() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var first = _enemy(runtime.world, Vector2.ZERO, 200)
	var second = _enemy(runtime.world, Vector2(50, 0), 200)
	runtime.apply_needle_hit(first, true)
	runtime.apply_needle_hit(second, false)
	assert_eq(runtime.get_total_active_marks(), 3)
	assert_false(runtime.is_ultimate_ready(), "Marks are not the execution resource.")


func test_queued_enemy_is_pruned_from_live_mark_charge() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var first = _enemy(runtime.world, Vector2.ZERO)
	var second = _enemy(runtime.world, Vector2(50, 0))
	runtime.apply_needle_hit(first, false)
	runtime.apply_needle_hit(second, true)
	assert_eq(runtime.get_total_active_marks(), 3)
	second.queue_free()
	assert_eq(runtime.get_total_active_marks(), 1)


func test_seeded_rng_produces_reproducible_critical_sequence() -> void:
	var first_runtime = _make_runtime()
	var second_runtime = _make_runtime()
	if first_runtime == null or second_runtime == null:
		return
	first_runtime.set_rng_seed(4242)
	second_runtime.set_rng_seed(4242)
	var first_results: Array[bool] = []
	var second_results: Array[bool] = []
	for index in range(12):
		var first_enemy = _enemy(first_runtime.world, Vector2(index * 20, 0), 1000)
		var second_enemy = _enemy(second_runtime.world, Vector2(index * 20, 100), 1000)
		first_results.append(first_runtime.apply_needle_hit(first_enemy))
		second_results.append(second_runtime.apply_needle_hit(second_enemy))
	assert_eq(first_results, second_results)


func test_forbidden_path_boosts_burst_status_damage_but_not_needle_base() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_status_effect_pct = 0.20
	var systems := _configure_run_systems(runtime, modifiers)
	var enemy = _enemy(runtime.world, Vector2.ZERO, 200)
	assert_false(runtime.apply_needle_hit(enemy, false))
	assert_true(runtime.apply_needle_hit(enemy, true))
	assert_eq(enemy.health, 163)
	assert_eq(systems.tracker.damage, 37)
	assert_eq(systems.tracker.status_events, 3, "Two mark applications plus one burst should be tracked")


func test_shadow_execution_adds_fixed_mark_bonus_without_status_multiplier_or_consumption() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_status_effect_pct = 0.20
	_configure_run_systems(runtime, modifiers)
	var first = _enemy(runtime.world, Vector2.ZERO, 200)
	var second = _enemy(runtime.world, Vector2(50, 0), 200)
	runtime.apply_needle_hit(first, true)
	runtime.apply_needle_hit(second, false)
	assert_eq(runtime.get_total_active_marks(), 3)
	var first_before: int = first.health
	var second_before: int = second.health
	runtime.execution_charge = 3.0
	assert_true(runtime.try_use_ultimate())
	assert_eq(first.health, first_before - 30)
	assert_eq(second.health, second_before - 22)
	assert_eq(runtime.get_total_active_marks(), 3)
	assert_false(runtime.is_ultimate_ready())


func test_seal_path_penalizes_needle_but_strengthens_shadow_execution() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.non_ultimate_school_damage_pct = -0.15
	modifiers.ultimate_power_pct = 0.25
	_configure_run_systems(runtime, modifiers)
	var first = _enemy(runtime.world, Vector2.ZERO, 200)
	var second = _enemy(runtime.world, Vector2(50, 0), 200)
	assert_true(runtime.apply_needle_hit(first, true))
	assert_false(runtime.apply_needle_hit(second, false))
	assert_eq(first.health, 190)
	assert_eq(second.health, 195)
	var first_before: int = first.health
	var second_before: int = second.health
	runtime.execution_charge = 3.0
	assert_true(runtime.try_use_ultimate())
	assert_eq(first.health, first_before - 38)
	assert_eq(second.health, second_before - 28)


func test_deactivate_clears_marks_badges_and_fractional_credit() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_resource_gain_pct = 0.20
	runtime.apply_run_modifiers(modifiers)
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	runtime.apply_needle_hit(enemy, false)
	var badge: Node = enemy.get_node_or_null("EnemyEffectBadge")
	assert_not_null(badge)
	assert_gt(float(runtime._mark_gain_credit), 0.0)
	runtime.deactivate()
	assert_eq(runtime.get_total_active_marks(), 0)
	assert_almost_eq(float(runtime._mark_gain_credit), 0.0, 0.001)
	assert_true(badge == null or badge.is_queued_for_deletion())
