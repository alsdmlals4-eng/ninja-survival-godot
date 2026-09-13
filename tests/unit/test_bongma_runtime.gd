extends GutTest

const RUNTIME_PATH := "res://scripts/schools/bongma_runtime.gd"
const FAMILIAR_SCENE_PATH := "res://scenes/schools/bongma_familiar.tscn"
const PLAYER_PATH := "res://scripts/player/player_controller.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"

var _previous_viewport_size: Vector2i


func before_each() -> void:
	_previous_viewport_size = get_tree().root.size
	get_tree().root.size = Vector2i(1152, 648)


func after_each() -> void:
	get_tree().paused = false
	get_tree().root.size = _previous_viewport_size


func _target(runtime, position: Vector2 = Vector2(40, 0)):
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	enemy.max_health = 1000
	runtime.world.add_child(enemy)
	enemy.global_position = position
	return enemy


func test_charge_requires_live_nearby_target_and_freezes_during_pause_and_ultimate() -> void:
	var runtime = _make_runtime()
	runtime.activate()
	runtime._process(1.0)
	assert_eq(runtime.spirit, 0.0)
	var enemy = _target(runtime, Vector2(480, 0))
	runtime._process(1.0)
	assert_eq(runtime.spirit, 5.0)
	enemy.global_position.x = 481
	runtime._process(1.0)
	assert_eq(runtime.spirit, 5.0)
	enemy.global_position = Vector2(40, 0)
	get_tree().paused = true
	runtime._process(1.0)
	assert_eq(runtime.spirit, 5.0)
	get_tree().paused = false
	runtime.spirit = 120.0
	assert_true(runtime.try_use_ultimate())
	runtime._process(1.0)
	assert_eq(runtime.spirit, 20.0)


func test_ultimate_adds_two_dedicated_familiars_without_converting_normal_familiar() -> void:
	var runtime = _make_runtime()
	runtime.activate()
	var enemy = _target(runtime)
	var normal = runtime._base_familiar
	runtime.spirit = 100.0
	assert_true(runtime.try_use_ultimate())
	assert_eq(_familiar_children(runtime).size(), 3)
	assert_eq(normal.damage_kind, &"normal")
	assert_almost_eq(normal.attack_interval, 0.70, 0.001)
	assert_eq(enemy.health, 984, "Two dedicated immediate8damage strikes.")
	for familiar in _familiar_children(runtime):
		if familiar == normal:
			continue
		assert_eq(familiar.damage_kind, &"ultimate")
		assert_almost_eq(familiar.attack_interval, 0.50, 0.001)
	runtime._process(6.0)
	assert_eq(_familiar_children(runtime).size(), 1)
	assert_eq(runtime.spirit, 0.0, "Duration cannot charge the next activation.")


func test_only_owned_nonultimate_kills_gain_two_with_one_second_event_limit() -> void:
	var runtime = _make_runtime()
	var resolver = load("res://scripts/combat/combat_resolver.gd").new()
	runtime.world.add_child(resolver)
	runtime.configure_run_systems(resolver, null)
	runtime.activate()
	var first = _target(runtime)
	first.died.connect(runtime.on_enemy_died)
	assert_gt(resolver.deal_basic_weapon_damage(first, 99999), 0)
	assert_eq(runtime.spirit, 2.0)
	var second = _target(runtime)
	second.died.connect(runtime.on_enemy_died)
	assert_gt(resolver.deal_school_damage(second, 99999, &"normal"), 0)
	assert_eq(runtime.spirit, 2.0, "Only one kill bonus per second, even across attack sources.")
	var third = _target(runtime)
	third.died.connect(runtime.on_enemy_died)
	runtime._process(1.0)
	assert_eq(runtime.spirit, 7.0)
	assert_gt(resolver.deal_school_damage(third, 99999, &"ultimate"), 0)
	assert_eq(runtime.spirit, 7.0, "Ultimate damage never charges itself.")
	runtime.on_enemy_died(first)
	assert_eq(runtime.spirit, 7.0, "Replayed death without an owned damage context gives nothing.")


func test_owned_damage_over_time_clone_and_reaction_kills_charge_but_unknown_does_not() -> void:
	for kind in [&"dot", &"clone", &"reaction", &"unknown", &"ultimate"]:
		var runtime = _make_runtime()
		var resolver = load("res://scripts/combat/combat_resolver.gd").new()
		runtime.world.add_child(resolver)
		runtime.configure_run_systems(resolver, null)
		runtime.activate()
		var enemy = _target(runtime)
		enemy.died.connect(runtime.on_enemy_died)
		assert_gt(resolver.deal_school_damage(enemy, 99999, kind), 0)
		var expected := 2.0 if kind in [&"dot", &"clone", &"reaction"] else 0.0
		assert_eq(runtime.spirit, expected, str(kind))
		runtime.on_enemy_died(enemy)
		assert_eq(runtime.spirit, expected, "Replayed death must not grant more spirit.")


func test_dedicated_familiars_keep_formation_range_and_pause_until_death_cleanup() -> void:
	var runtime = _make_runtime()
	runtime.activate()
	var enemy = _target(runtime)
	runtime.spirit = 120.0
	assert_true(runtime.try_use_ultimate())
	var first = runtime._temporary_familiar
	var second = runtime._second_temporary_familiar
	assert_gt(first.global_position.distance_to(second.global_position), 100.0)
	enemy.global_position = Vector2(321, 0)
	assert_null(first.attack_once(), "Dedicated summons cannot attack beyond player-relative320range.")
	enemy.global_position = Vector2(320, 0)
	assert_eq(first.attack_once(), enemy)
	first.global_position = Vector2(999, 999)
	first._physics_process(0.016)
	assert_lte(first.global_position.distance_to(runtime.player.global_position), 180.0)
	get_tree().paused = true
	var cooldown: float = first._cooldown_remaining
	runtime._process(3.0)
	first._process(3.0)
	assert_eq(runtime.ultimate_time_remaining, 6.0)
	assert_eq(first._cooldown_remaining, cooldown)
	assert_null(first.attack_once())
	get_tree().paused = false
	runtime.player.take_damage(99999)
	runtime._process(0.016)
	assert_eq(runtime.ultimate_time_remaining, 0.0)
	assert_eq(_familiar_children(runtime).size(), 1)
	assert_eq(runtime.spirit, 20.0, "Death removes summons without refunding the paid cost.")
	assert_null(first.attack_once(), "Queued summons cannot hit after cancellation.")


func test_other_world_targets_do_not_enable_charge_or_familiar_attack() -> void:
	var runtime = _make_runtime()
	var other = _make_runtime()
	runtime.activate()
	_target(other)
	runtime._process(1.0)
	assert_eq(runtime.spirit, 0.0)
	assert_null(runtime._base_familiar.attack_once())
	runtime.spirit = 100.0
	assert_false(runtime.try_use_ultimate())


func _make_runtime():
	assert_true(ResourceLoader.exists(RUNTIME_PATH), "Bongma runtime script must exist")
	assert_true(ResourceLoader.exists(FAMILIAR_SCENE_PATH), "Bongma familiar scene must exist")
	if not ResourceLoader.exists(RUNTIME_PATH) or not ResourceLoader.exists(FAMILIAR_SCENE_PATH):
		return null
	var world := Node2D.new()
	add_child_autofree(world)
	var player = load(PLAYER_PATH).new()
	world.add_child(player)
	var runtime = load(RUNTIME_PATH).new()
	runtime.familiar_scene = load(FAMILIAR_SCENE_PATH)
	world.add_child(runtime)
	runtime.configure(player, world)
	return runtime


func _familiar_children(runtime: Node) -> Array[Node]:
	var result: Array[Node] = []
	for child in runtime.get_children():
		if child.name.to_lower().begins_with("familiar") and not child.is_queued_for_deletion():
			result.append(child)
	return result


func test_nearby_spirit_regen_clamps_and_unowned_death_cannot_charge() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.activate()
	_target(runtime)
	runtime._process(2.0)
	assert_almost_eq(runtime.spirit, 10.0, 0.001)
	var enemy := Node.new()
	runtime.on_enemy_died(enemy)
	enemy.free()
	assert_almost_eq(runtime.spirit, 10.0, 0.001)
	runtime.spirit = 119.0
	runtime._process(1.0)
	assert_almost_eq(runtime.spirit, 120.0, 0.001)


func test_resource_and_ultimate_readiness_modifiers_multiply_spirit_gain() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.school_resource_gain_pct = 0.20
	modifiers.ultimate_charge_gain_pct = 0.25
	runtime.apply_run_modifiers(modifiers)
	runtime.activate()
	_target(runtime)
	runtime._process(2.0)
	assert_almost_eq(runtime.spirit, 15.0, 0.001)
	var enemy := Node.new()
	runtime.on_enemy_died(enemy)
	enemy.free()
	assert_almost_eq(runtime.spirit, 15.0, 0.001)


func test_activation_creates_one_base_familiar() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.activate()
	assert_eq(_familiar_children(runtime).size(), 1)
	var familiar = _familiar_children(runtime)[0]
	assert_almost_eq(familiar.attack_interval, 0.70, 0.001)
	assert_eq(familiar.damage, 8)
	assert_eq(familiar.damage_kind, &"normal")


func test_school_emblem_reduces_all_selected_familiar_intervals() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	var modifiers = load(MODIFIER_PATH).new()
	modifiers.bongma_familiar_interval_pct = -0.15
	runtime.apply_run_modifiers(modifiers)
	runtime.activate()
	var familiar = _familiar_children(runtime)[0]
	assert_almost_eq(familiar.attack_interval, 0.595, 0.001)
	runtime.player.global_position = Vector2.ZERO
	runtime._process(8.0)
	familiar.global_position = runtime.ward_center
	runtime._process(0.1)
	assert_almost_eq(familiar.attack_interval, 0.425, 0.001)


func test_ward_is_stationary_four_second_window_every_eight_seconds() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.activate()
	runtime.player.global_position = Vector2(40, 20)
	runtime._process(8.0)
	assert_eq(runtime.ward_center, Vector2(40, 20))
	assert_almost_eq(runtime.ward_time_remaining, 4.0, 0.001)
	runtime.player.global_position = Vector2(200, 200)
	runtime._process(1.0)
	assert_eq(runtime.ward_center, Vector2(40, 20))
	assert_almost_eq(runtime.ward_time_remaining, 3.0, 0.001)


func test_ward_bonus_only_applies_to_familiar_inside_active_ward() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.activate()
	runtime.player.global_position = Vector2.ZERO
	runtime._process(8.0)
	var familiar = _familiar_children(runtime)[0]
	familiar.global_position = runtime.ward_center
	runtime._process(0.1)
	assert_almost_eq(familiar.attack_interval, 0.50, 0.001)
	familiar.global_position = runtime.ward_center + Vector2(200, 0)
	runtime._process(0.1)
	assert_almost_eq(familiar.attack_interval, 0.70, 0.001)
	runtime._process(4.0)
	familiar.global_position = runtime.ward_center
	runtime._process(0.1)
	assert_almost_eq(familiar.attack_interval, 0.70, 0.001)


func test_ultimate_requires_visible_target_and_two_valid_familiars_before_cost() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.activate()
	runtime.spirit = 100.0
	assert_true(runtime.is_ultimate_ready())
	assert_false(runtime.try_use_ultimate())
	assert_almost_eq(runtime.spirit, 100.0, 0.001)
	var enemy = _target(runtime, Vector2(321, 0))
	assert_false(runtime.try_use_ultimate())
	enemy.global_position = Vector2(40, 0)
	enemy.hide()
	assert_false(runtime.try_use_ultimate())
	enemy.show()
	runtime.familiar_scene = null
	assert_false(runtime.try_use_ultimate())
	assert_eq(runtime.spirit, 100.0)
	assert_eq(_familiar_children(runtime).size(), 1)
