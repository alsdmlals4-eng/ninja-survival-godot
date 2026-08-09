extends GutTest

const RUNTIME_PATH := "res://scripts/schools/guiin_runtime.gd"
const PLAYER_PATH := "res://scripts/player/player_controller.gd"
const ENEMY_PATH := "res://scripts/enemies/enemy_chaser.gd"


func _make_runtime():
	assert_true(ResourceLoader.exists(RUNTIME_PATH), "Guiin runtime script must exist")
	if not ResourceLoader.exists(RUNTIME_PATH):
		return null
	var world := Node2D.new()
	add_child_autofree(world)
	var player = load(PLAYER_PATH).new()
	world.add_child(player)
	var runtime = load(RUNTIME_PATH).new()
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


func test_baseline_pulse_interval_radius_and_damage() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	assert_almost_eq(runtime.current_pulse_interval(), 0.90, 0.001)
	assert_almost_eq(runtime.current_pulse_radius(), 80.0, 0.001)
	assert_eq(runtime.current_pulse_damage(), 10)


func test_low_health_berserker_changes_radius_and_damage_at_half_health() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.player.health = 51
	assert_almost_eq(runtime.current_pulse_radius(), 80.0, 0.001)
	assert_eq(runtime.current_pulse_damage(), 10)
	runtime.player.health = 50
	assert_almost_eq(runtime.current_pulse_radius(), 110.0, 0.001)
	assert_eq(runtime.current_pulse_damage(), 15)


func test_melee_pulse_hits_only_enemies_inside_current_radius_and_gains_four_each() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var near_enemy = _enemy(runtime.world, Vector2(40, 0))
	var edge_enemy = _enemy(runtime.world, Vector2(80, 0))
	var far_enemy = _enemy(runtime.world, Vector2(81, 0))

	assert_eq(runtime.perform_melee_pulse(), 2)
	assert_eq(near_enemy.health, 90)
	assert_eq(edge_enemy.health, 90)
	assert_eq(far_enemy.health, 100)
	assert_almost_eq(runtime.gwihyeol, 8.0, 0.001)
	assert_almost_eq(runtime.time_since_gain, 0.0, 0.001)


func test_enemy_kill_adds_twelve_and_resource_clamps_at_one_hundred() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.gwihyeol = 95.0
	var enemy := Node.new()
	runtime.on_enemy_died(enemy)
	enemy.free()
	assert_almost_eq(runtime.gwihyeol, 100.0, 0.001)
	assert_almost_eq(runtime.time_since_gain, 0.0, 0.001)


func test_gwihyeol_waits_one_second_then_decays_six_per_second() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.gwihyeol = 50.0
	runtime.time_since_gain = 0.0
	runtime._pulse_remaining = 999.0

	runtime._process(0.75)
	assert_almost_eq(runtime.gwihyeol, 50.0, 0.001)
	runtime._process(0.25)
	assert_almost_eq(runtime.gwihyeol, 50.0, 0.001)
	runtime._process(0.50)
	assert_almost_eq(runtime.gwihyeol, 47.0, 0.001)


func test_high_gwihyeol_multiplier_applies_after_berserker_base() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.player.health = 50
	runtime.gwihyeol = 74.9
	assert_eq(runtime.current_pulse_damage(), 15)
	runtime.gwihyeol = 75.0
	assert_eq(runtime.current_pulse_damage(), 18)


func test_guiin_form_cost_duration_interval_radius_and_rounding() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.player.health = 50
	runtime.gwihyeol = 100.0
	assert_true(runtime.is_ultimate_ready())
	assert_true(runtime.try_use_ultimate())
	assert_almost_eq(runtime.gwihyeol, 0.0, 0.001)
	assert_almost_eq(runtime.ultimate_time_remaining, 6.0, 0.001)
	assert_almost_eq(runtime.current_pulse_interval(), 0.45, 0.001)
	assert_almost_eq(runtime.current_pulse_radius(), 130.0, 0.001)
	assert_eq(runtime.current_pulse_damage(), 19)

	runtime.gwihyeol = 75.0
	assert_eq(runtime.current_pulse_damage(), 23)
	assert_false(runtime.try_use_ultimate())


func test_ultimate_ends_after_six_seconds_and_resource_gain_still_works() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.gwihyeol = 100.0
	assert_true(runtime.try_use_ultimate())
	runtime._pulse_remaining = 999.0
	var enemy := Node.new()
	runtime.on_enemy_died(enemy)
	enemy.free()
	assert_almost_eq(runtime.gwihyeol, 12.0, 0.001)
	runtime._process(0.5)
	assert_almost_eq(runtime.gwihyeol, 12.0, 0.001)
	assert_almost_eq(runtime.ultimate_time_remaining, 5.5, 0.001)
	runtime._process(5.5)
	assert_almost_eq(runtime.ultimate_time_remaining, 0.0, 0.001)
	assert_almost_eq(runtime.current_pulse_interval(), 0.90, 0.001)


func test_deactivated_runtime_does_not_pulse_or_decay() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2(20, 0))
	runtime.gwihyeol = 50.0
	runtime.time_since_gain = 2.0
	runtime.deactivate()
	runtime._process(10.0)
	assert_eq(enemy.health, 100)
	assert_almost_eq(runtime.gwihyeol, 50.0, 0.001)