extends GutTest

const RUNTIME_PATH := "res://scripts/schools/bongma_runtime.gd"
const FAMILIAR_SCENE_PATH := "res://scenes/schools/bongma_familiar.tscn"
const PLAYER_PATH := "res://scripts/player/player_controller.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"


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


func test_spirit_regens_and_kill_adds_ten() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.activate()
	runtime._process(2.0)
	assert_almost_eq(runtime.spirit, 10.0, 0.001)
	var enemy := Node.new()
	runtime.on_enemy_died(enemy)
	enemy.free()
	assert_almost_eq(runtime.spirit, 20.0, 0.001)
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
	runtime._process(2.0)
	assert_almost_eq(runtime.spirit, 15.0, 0.001)
	var enemy := Node.new()
	runtime.on_enemy_died(enemy)
	enemy.free()
	assert_almost_eq(runtime.spirit, 30.0, 0.001)


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


func test_hyakki_yagyo_costs_one_hundred_adds_familiar_and_marks_hits_ultimate() -> void:
	var runtime = _make_runtime()
	if runtime == null:
		return
	runtime.activate()
	runtime.spirit = 100.0
	assert_true(runtime.is_ultimate_ready())
	assert_true(runtime.try_use_ultimate())
	assert_almost_eq(runtime.spirit, 0.0, 0.001)
	assert_almost_eq(runtime.ultimate_time_remaining, 6.0, 0.001)
	assert_eq(_familiar_children(runtime).size(), 2)
	for familiar in _familiar_children(runtime):
		assert_almost_eq(familiar.attack_interval, 0.30, 0.001)
		assert_eq(familiar.damage_kind, &"ultimate")

	runtime.spirit = 100.0
	assert_false(runtime.try_use_ultimate())
	runtime._process(6.0)
	assert_eq(_familiar_children(runtime).size(), 1)
	assert_almost_eq(_familiar_children(runtime)[0].attack_interval, 0.70, 0.001)
	assert_eq(_familiar_children(runtime)[0].damage_kind, &"normal")
