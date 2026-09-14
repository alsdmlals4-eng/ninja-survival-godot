extends GutTest

const RUNTIME_PATH := "res://scripts/schools/guiin_runtime.gd"
const PLAYER_PATH := "res://scripts/player/player_controller.gd"
const ENEMY_PATH := "res://scripts/enemies/enemy_chaser.gd"
const TRACKER_PATH := "res://scripts/combat/combat_contribution_tracker.gd"
const RESOLVER_PATH := "res://scripts/combat/combat_resolver.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"
var _viewport_before := Vector2i.ZERO


func before_each() -> void:
	_viewport_before = get_tree().root.size
	get_tree().root.size = Vector2i(1152, 648)


func after_each() -> void:
	get_tree().paused = false
	get_tree().root.size = _viewport_before

class ImmuneEnemy:
	extends Node2D
	var health: int = 100

	func _ready() -> void:
		add_to_group("enemies")

	func take_damage(_amount: int) -> int:
		return 0

	func is_dead() -> bool:
		return false


func _make_runtime():
	assert_true(ResourceLoader.exists(RUNTIME_PATH), "Guiin runtime script must exist")
	if not ResourceLoader.exists(RUNTIME_PATH):
		return null
	var world := Node2D.new()
	add_child_autofree(world)
	var player = load(PLAYER_PATH).new()
	world.add_child(player)
	var weapons = load("res://scripts/combat/basic_weapon_controller.gd").new()
	player.add_child(weapons)
	var runtime = load(RUNTIME_PATH).new()
	world.add_child(runtime)
	runtime.configure(player, world)
	runtime.configure_weapon_controller(weapons)
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
	runtime.basic_weapons.configure(resolver)
	if modifiers == null:
		modifiers = load(MODIFIER_PATH).new()
	resolver.set_modifiers(modifiers)
	runtime.apply_run_modifiers(modifiers)
	return {"tracker": tracker, "resolver": resolver}


func test_baseline_pulse_interval_radius_and_damage() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	assert_almost_eq(runtime.current_pulse_interval(), 0.90, 0.001)
	assert_almost_eq(runtime.current_pulse_radius(), 80.0, 0.001)
	assert_eq(runtime.current_pulse_damage(), 10)


func test_selected_books_remove_intrinsic_damage_but_keep_ultimate_charge() -> void:
	var runtime = _make_runtime()
	assert_true(runtime.has_method("configure_ninjutsu_loadout"))
	if not runtime.has_method("configure_ninjutsu_loadout"):
		return
	var loadout = load("res://scripts/core/ninjutsu_loadout_state.gd").new()
	runtime.world.add_child(loadout)
	loadout.begin_start_draft(&"guiin", 12)
	for index in range(2):
		loadout.choose_start_draft(loadout.start_draft_snapshot().options[0])
	loadout.commit_drafted_start(loadout.start_draft_snapshot().picks)
	loadout.commit_placed_ninjutsu([], [&"guiin"])
	runtime.configure_ninjutsu_loadout(loadout)
	var enemy = _enemy(runtime.world, Vector2(60, 0))
	runtime._process(0.9)
	assert_eq(enemy.health, 100, "Empty selected build cannot retain the legacy free pulse.")
	assert_eq(runtime.perform_melee_pulse(), 0)
	assert_gt(runtime.gwihyeol, 0.0, "Charge belongs to the school, not an equipped damage book.")


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


func test_school_emblem_multiplies_final_melee_radius() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.guiin_melee_radius_pct = 0.15
	runtime.apply_run_modifiers(modifiers)
	assert_almost_eq(runtime.current_pulse_radius(), 92.0, 0.001)
	runtime.player.health = 50
	assert_almost_eq(runtime.current_pulse_radius(), 126.5, 0.001)
	_enemy(runtime.world, Vector2(40, 0))
	runtime.gwihyeol = 100.0
	assert_true(runtime.try_use_ultimate())
	assert_almost_eq(runtime.basic_weapons.katana_radius, 168.0, 0.001)
	assert_eq(runtime.perform_melee_pulse(), 0)


func test_melee_pulse_hits_only_enemies_inside_current_radius_without_hit_based_charge() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var near_enemy = _enemy(runtime.world, Vector2(40, 0))
	var edge_enemy = _enemy(runtime.world, Vector2(80, 0))
	var far_enemy = _enemy(runtime.world, Vector2(81, 0))

	watch_signals(runtime)
	assert_eq(runtime.perform_melee_pulse(), 2)
	assert_eq(near_enemy.health, 90)
	assert_eq(edge_enemy.health, 90)
	assert_eq(far_enemy.health, 100)
	assert_signal_emitted(runtime, "player_action_resolved")
	assert_almost_eq(runtime.gwihyeol, 0.0, 0.001)
	assert_almost_eq(runtime.time_since_gain, 0.0, 0.001)


func test_resource_and_readiness_modifiers_apply_once_to_proximity_charge() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_resource_gain_pct = 0.20
	modifiers.ultimate_charge_gain_pct = 0.25
	_configure_run_systems(runtime, modifiers)
	_enemy(runtime.world, Vector2(20, 0))
	assert_eq(runtime.perform_melee_pulse(), 1)
	assert_almost_eq(runtime.gwihyeol, 0.0, 0.001)
	runtime._process(1.0)
	assert_almost_eq(runtime.gwihyeol, 12.0, 0.001)
	var killed := Node.new()
	runtime.on_enemy_died(killed)
	killed.free()
	assert_almost_eq(runtime.gwihyeol, 12.0, 0.001)


func test_only_actual_damage_counts_as_hit_and_resource_gain() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	_configure_run_systems(runtime)
	var immune := ImmuneEnemy.new()
	immune.global_position = Vector2(20, 0)
	runtime.world.add_child(immune)
	watch_signals(runtime)
	assert_eq(runtime.perform_melee_pulse(), 0)
	assert_almost_eq(runtime.gwihyeol, 0.0, 0.001)
	assert_signal_not_emitted(runtime, "player_action_resolved")


func test_school_damage_modifier_is_applied_once_after_local_guiin_math() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_damage_pct = 0.50
	var systems := _configure_run_systems(runtime, modifiers)
	var enemy = _enemy(runtime.world, Vector2(20, 0))
	assert_eq(runtime.current_pulse_damage(), 10)
	assert_eq(runtime.perform_melee_pulse(), 1)
	assert_eq(enemy.health, 85)
	assert_eq(systems.tracker.damage, 15)


func test_seal_path_reduces_normal_pulse_but_strengthens_only_the_guiin_sword() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.non_ultimate_school_damage_pct = -0.50
	modifiers.ultimate_power_pct = 0.50
	_configure_run_systems(runtime, modifiers)
	runtime.player.health = 50
	var enemy = _enemy(runtime.world, Vector2(20, 0), 200)
	assert_eq(runtime.perform_melee_pulse(), 1)
	assert_eq(enemy.health, 192)
	runtime.gwihyeol = 100.0
	assert_true(runtime.try_use_ultimate())
	assert_eq(runtime.basic_weapons.katana_damage, 20.0)
	assert_eq(runtime.perform_melee_pulse(), 0)
	assert_eq(enemy.health, 162)


func test_proximity_charge_clamps_at_one_hundred_without_kill_bonus() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.gwihyeol = 95.0
	var enemy := Node.new()
	runtime.on_enemy_died(enemy)
	enemy.free()
	assert_almost_eq(runtime.gwihyeol, 95.0, 0.001)
	_enemy(runtime.world, Vector2(40, 0))
	runtime._process(1.0)
	assert_almost_eq(runtime.gwihyeol, 100.0, 0.001)
	assert_almost_eq(runtime.time_since_gain, 0.0, 0.001)


func test_gwihyeol_is_retained_while_the_battlefield_is_empty() -> void:
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
	assert_almost_eq(runtime.gwihyeol, 50.0, 0.001)


func test_pulse_does_not_duplicate_the_elapsed_proximity_charge() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var enemy = _enemy(runtime.world, Vector2(20, 0))
	runtime.gwihyeol = 0.0
	runtime.time_since_gain = 0.0
	runtime._pulse_remaining = 0.0

	runtime._process(2.0)

	assert_eq(enemy.health, 90)
	assert_almost_eq(runtime.gwihyeol, 16.0, 0.001)
	assert_almost_eq(runtime.time_since_gain, 0.0, 0.001)


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
	_enemy(runtime.world, Vector2(40, 0))
	runtime.gwihyeol = 100.0
	assert_true(runtime.is_ultimate_ready())
	assert_true(runtime.try_use_ultimate())
	assert_almost_eq(runtime.gwihyeol, 0.0, 0.001)
	assert_almost_eq(runtime.ultimate_time_remaining, 6.0, 0.001)
	assert_almost_eq(runtime.basic_weapons.katana_interval, 0.325, 0.001)
	assert_almost_eq(runtime.basic_weapons.katana_radius, 168.0, 0.001)
	assert_eq(runtime.basic_weapons.katana_damage, 20.0)

	runtime.gwihyeol = 75.0
	assert_eq(runtime.basic_weapons.katana_damage, 20.0)
	assert_false(runtime.try_use_ultimate())


func test_ultimate_ends_after_six_seconds_and_blocks_resource_gain_while_active() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	_enemy(runtime.world, Vector2(40, 0))
	runtime.gwihyeol = 100.0
	assert_true(runtime.try_use_ultimate())
	runtime._pulse_remaining = 999.0
	var enemy := Node.new()
	runtime.on_enemy_died(enemy)
	enemy.free()
	assert_almost_eq(runtime.gwihyeol, 0.0, 0.001)
	runtime._process(0.5)
	assert_almost_eq(runtime.gwihyeol, 0.0, 0.001)
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


func test_charge_uses_four_per_second_plus_four_for_close_danger_not_hits_or_kills() -> void:
	var runtime = _make_runtime()
	runtime._pulse_remaining = 999.0
	var enemy = _enemy(runtime.world, Vector2(200, 0), 10000)
	runtime._process(1.0)
	assert_eq(runtime.gwihyeol, 4.0)
	enemy.position = Vector2(110, 0)
	runtime._process(1.0)
	assert_eq(runtime.gwihyeol, 12.0)
	enemy.position = Vector2(40, 0)
	runtime.perform_melee_pulse()
	runtime.on_enemy_died(enemy)
	assert_eq(runtime.gwihyeol, 12.0)


func test_charge_does_not_decay_or_generate_without_a_living_target_or_while_paused() -> void:
	var runtime = _make_runtime()
	runtime.gwihyeol = 50.0
	runtime._pulse_remaining = 999.0
	runtime._process(10.0)
	assert_eq(runtime.gwihyeol, 50.0)
	var enemy = _enemy(runtime.world, Vector2(481, 0), 10000)
	runtime._process(1.0)
	assert_eq(runtime.gwihyeol, 50.0)
	enemy.position.x = 480
	get_tree().paused = true
	runtime._process(1.0)
	get_tree().paused = false
	assert_eq(runtime.gwihyeol, 50.0)
	runtime._process(1.0)
	assert_eq(runtime.gwihyeol, 54.0)


func test_ready_guiin_requires_a_visible_target_within_168_before_spending() -> void:
	var runtime = _make_runtime()
	runtime.gwihyeol = 100.0
	var enemy = _enemy(runtime.world, Vector2(169, 0), 1000)
	assert_eq(runtime.ultimate_block_reason(), &"no_target")
	assert_false(runtime.try_use_ultimate())
	assert_eq(runtime.gwihyeol, 100.0)
	enemy.position.x = 168
	enemy.hide()
	assert_false(runtime.try_use_ultimate())
	enemy.show()
	assert_true(runtime.try_use_ultimate())
	assert_eq(runtime.gwihyeol, 0.0)
