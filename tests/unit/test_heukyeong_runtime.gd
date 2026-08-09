extends GutTest

const RUNTIME_PATH := "res://scripts/schools/heukyeong_runtime.gd"
const BADGE_SCENE_PATH := "res://scenes/ui/enemy_effect_badge.tscn"
const PLAYER_PATH := "res://scripts/player/player_controller.gd"
const ENEMY_PATH := "res://scripts/enemies/enemy_chaser.gd"


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


func test_attack_once_hits_at_most_three_nearest_enemies() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemies: Array[Node] = []
	for distance in [40, 10, 30, 20]:
		enemies.append(_enemy(runtime.world, Vector2(distance, 0)))
	runtime.set_rng_seed(7)
	var hit := runtime.attack_once()
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
	assert_false(runtime.apply_needle_hit(enemy, false))
	assert_eq(enemy.health, 94)
	assert_eq(runtime.get_mark_count(enemy), 1)
	assert_true(runtime.apply_needle_hit(enemy, true))
	assert_eq(enemy.health, 66)
	assert_eq(runtime.get_mark_count(enemy), 0)


func test_marked_target_uses_forty_percent_critical_threshold() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	assert_false(runtime.apply_needle_hit(enemy, false))
	assert_almost_eq(runtime.get_critical_chance(enemy), 0.40, 0.001)
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


func test_marks_do_not_expire_with_time_and_charge_is_live_total() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var first = _enemy(runtime.world, Vector2.ZERO)
	var second = _enemy(runtime.world, Vector2(50, 0))
	runtime.apply_needle_hit(first, false)
	runtime.apply_needle_hit(second, true)
	assert_eq(runtime.get_total_active_marks(), 3)
	runtime._attack_remaining = 999.0
	runtime._process(30.0)
	assert_eq(runtime.get_mark_count(first), 1)
	assert_eq(runtime.get_mark_count(second), 2)
	assert_eq(runtime.get_total_active_marks(), 3)


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


func test_shadow_execution_uses_current_marks_and_clears_all() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var targets: Array[Node] = []
	for index in range(3):
		var enemy = _enemy(runtime.world, Vector2(index * 40, 0), 200)
		runtime.apply_needle_hit(enemy, true)
		targets.append(enemy)
	assert_eq(runtime.get_total_active_marks(), 6)
	assert_true(runtime.is_ultimate_ready())

	var before: Array[int] = []
	for enemy in targets:
		before.append(enemy.health)
	assert_true(runtime.try_use_ultimate())
	for index in range(targets.size()):
		assert_eq(targets[index].health, before[index] - 22)
		assert_eq(runtime.get_mark_count(targets[index]), 0)
	assert_eq(runtime.get_total_active_marks(), 0)
	assert_false(runtime.is_ultimate_ready())


func test_deactivate_clears_marks_and_badges() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2.ZERO)
	runtime.apply_needle_hit(enemy, false)
	var badge: Node = enemy.get_node_or_null("EnemyEffectBadge")
	assert_not_null(badge)
	runtime.deactivate()
	assert_eq(runtime.get_total_active_marks(), 0)
	assert_true(badge == null or badge.is_queued_for_deletion())