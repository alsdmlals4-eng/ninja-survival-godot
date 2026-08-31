extends GutTest

const REQUIRED_SCRIPTS := [
	"res://scripts/core/game_state.gd",
	"res://scripts/core/main_controller.gd",
	"res://scripts/player/player_controller.gd",
	"res://scripts/enemies/enemy_chaser.gd",
	"res://scripts/combat/basic_weapon_controller.gd",
	"res://scripts/combat/projectile.gd",
	"res://scripts/ui/hud.gd",
]
const MVP1_TRACKER_PATH := "res://scripts/combat/combat_ddd_tracker.gd"
const MVP1_REWARD_ORB_PATH := "res://scripts/combat/reward_orb.gd"
const MVP1_WAVE_SPAWNER_PATH := "res://scripts/spawning/wave_spawner.gd"
const MVP2_RUNTIME_BASE_PATH := "res://scripts/schools/school_runtime_base.gd"
const MVP2_RUNTIME_HOST_PATH := "res://scripts/schools/school_runtime_host.gd"
const MVP2_SELECTOR_PATH := "res://scripts/ui/school_selection_ui.gd"
const MVP2_BONGMA_RUNTIME_PATH := "res://scripts/schools/bongma_runtime.gd"
const MVP2_BONGMA_FAMILIAR_PATH := "res://scripts/schools/bongma_familiar.gd"
const MVP2_CHEONSUL_RUNTIME_PATH := "res://scripts/schools/cheonsul_runtime.gd"
const MVP2_GUIIN_RUNTIME_PATH := "res://scripts/schools/guiin_runtime.gd"
const MVP2_HEUKYEONG_RUNTIME_PATH := "res://scripts/schools/heukyeong_runtime.gd"
const MVP2_BADGE_PATH := "res://scripts/ui/enemy_effect_badge.gd"
const PLAYER_VISUAL_PATH := "res://scripts/player/player_visual_controller.gd"
const MVP3_DATA_PATHS := [
	"res://scripts/data/item_definition.gd",
	"res://scripts/data/fate_definition.gd",
	"res://scripts/data/run_modifier_set.gd",
	"res://scripts/data/mvp3_catalog.gd",
]


func test_mvp0_script_resources_exist() -> void:
	for path in REQUIRED_SCRIPTS:
		assert_true(ResourceLoader.exists(path), "Missing MVP-0 script: %s" % path)


func test_mvp1_tracker_resource_exists() -> void:
	assert_true(ResourceLoader.exists(MVP1_TRACKER_PATH), "Missing MVP-1 tracker script")


func test_mvp1_reward_orb_resource_exists() -> void:
	assert_true(ResourceLoader.exists(MVP1_REWARD_ORB_PATH), "Missing MVP-1 reward orb script")


func test_mvp1_wave_spawner_resource_exists() -> void:
	assert_true(ResourceLoader.exists(MVP1_WAVE_SPAWNER_PATH), "Missing MVP-1 wave spawner script")


func test_mvp2_shared_school_resources_exist() -> void:
	for path in [MVP2_RUNTIME_BASE_PATH, MVP2_RUNTIME_HOST_PATH, MVP2_SELECTOR_PATH]:
		assert_true(ResourceLoader.exists(path), "Missing MVP-2 shared script: %s" % path)


func test_mvp3_data_resources_exist() -> void:
	for path in MVP3_DATA_PATHS:
		assert_true(ResourceLoader.exists(path), "Missing MVP-3 data script: %s" % path)


func test_game_state_contract() -> void:
	var state = load("res://scripts/core/game_state.gd").new()
	assert_true(state.has_method("register_kill"))
	assert_true(_has_property(state, "score"))
	assert_true(_has_property(state, "kill_count"))
	state.free()


func test_main_controller_contract() -> void:
	var main = load("res://scripts/core/main_controller.gd").new()
	assert_true(_has_property(main, "game_over"))
	main.free()


func test_player_controller_contract() -> void:
	var player = load("res://scripts/player/player_controller.gd").new()
	assert_true(player.has_method("take_damage"))
	assert_true(player.has_method("is_dead"))
	assert_true(_has_property(player, "max_health"))
	assert_true(_has_property(player, "health"))
	assert_true(_has_property(player, "move_speed"))
	player.free()


func test_enemy_chaser_contract() -> void:
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	assert_true(enemy.has_method("set_target"))
	assert_true(enemy.has_method("take_damage"))
	assert_true(enemy.has_method("is_dead"))
	assert_true(_has_property(enemy, "max_health"))
	assert_true(_has_property(enemy, "health"))
	assert_true(_has_property(enemy, "move_speed"))
	assert_true(_has_property(enemy, "contact_damage"))
	enemy.free()


func test_basic_weapon_controller_contract() -> void:
	var controller = load("res://scripts/combat/basic_weapon_controller.gd").new()
	assert_true(controller.has_method("find_nearest_target"))
	assert_true(controller.has_method("swing_katana_once"))
	assert_true(controller.has_method("fire_shuriken_once"))
	assert_true(_has_property(controller, "katana_interval"))
	assert_true(_has_property(controller, "shuriken_projectile_scene"))
	assert_true(_has_property(controller, "shuriken_speed"))
	assert_true(_has_property(controller, "shuriken_damage"))
	controller.free()


func test_projectile_contract() -> void:
	var projectile = load("res://scripts/combat/projectile.gd").new()
	assert_true(projectile.has_method("configure"))
	assert_true(projectile.has_method("hit_body"))
	assert_true(_has_property(projectile, "direction"))
	assert_true(_has_property(projectile, "speed"))
	assert_true(_has_property(projectile, "damage"))
	assert_true(_has_property(projectile, "lifetime"))
	projectile.free()


func test_combat_ddd_tracker_contract() -> void:
	assert_true(ResourceLoader.exists(MVP1_TRACKER_PATH), "Missing MVP-1 tracker script")
	if not ResourceLoader.exists(MVP1_TRACKER_PATH):
		return
	var tracker = load(MVP1_TRACKER_PATH).new()
	assert_true(tracker.has_method("register_kill"))
	assert_true(tracker.has_method("register_reward_collected"))
	assert_true(_has_property(tracker, "combo_count"))
	assert_true(_has_property(tracker, "max_combo"))
	assert_true(_has_property(tracker, "stylish_score"))
	assert_true(_has_property(tracker, "reward_count"))
	assert_true(_has_property(tracker, "combo_time_remaining"))
	tracker.free()


func test_reward_orb_contract() -> void:
	assert_true(ResourceLoader.exists(MVP1_REWARD_ORB_PATH), "Missing MVP-1 reward orb script")
	if not ResourceLoader.exists(MVP1_REWARD_ORB_PATH):
		return
	var orb = load(MVP1_REWARD_ORB_PATH).new()
	assert_true(orb.has_method("configure"))
	assert_true(_has_property(orb, "target"))
	assert_true(_has_property(orb, "move_speed"))
	assert_true(_has_property(orb, "collect_radius"))
	assert_true(_has_property(orb, "lifetime"))
	orb.free()


func test_wave_spawner_contract() -> void:
	assert_true(ResourceLoader.exists(MVP1_WAVE_SPAWNER_PATH), "Missing MVP-1 wave spawner script")
	if not ResourceLoader.exists(MVP1_WAVE_SPAWNER_PATH):
		return
	var spawner = load(MVP1_WAVE_SPAWNER_PATH).new()
	assert_true(spawner.has_method("configure"))
	assert_true(spawner.has_method("configure_horde_profile"))
	assert_true(spawner.has_method("ensure_minimum_active"))
	assert_true(spawner.has_method("spawn_wave"))
	assert_true(spawner.has_method("set_spawning_enabled"))
	assert_true(_has_property(spawner, "enemy_scene"))
	assert_true(_has_property(spawner, "wave_interval"))
	assert_true(_has_property(spawner, "batch_size"))
	assert_true(_has_property(spawner, "minimum_active_enemies"))
	assert_false(_has_property(spawner, "max_active_enemies"), "DEC-039 user override forbids a normal-enemy maximum cap.")
	assert_true(_has_property(spawner, "minimum_spawn_distance"))
	assert_true(_has_property(spawner, "maximum_spawn_distance"))
	spawner.free()


func test_school_runtime_base_contract() -> void:
	assert_true(ResourceLoader.exists(MVP2_RUNTIME_BASE_PATH), "Missing MVP-2 runtime base script")
	if not ResourceLoader.exists(MVP2_RUNTIME_BASE_PATH):
		return
	var runtime = load(MVP2_RUNTIME_BASE_PATH).new()
	for method_name in ["configure", "activate", "deactivate", "on_enemy_died", "try_use_ultimate", "is_ultimate_ready"]:
		assert_true(runtime.has_method(method_name), "Missing runtime method: %s" % method_name)
	for signal_name in ["resource_changed", "ultimate_ready_changed", "school_feedback", "player_action_resolved"]:
		assert_true(runtime.has_signal(signal_name), "Missing runtime signal: %s" % signal_name)
	assert_true(runtime.has_method("emit_player_action_resolved"))
	assert_true(_has_property(runtime, "active"))
	runtime.free()


func test_school_runtime_host_contract() -> void:
	assert_true(ResourceLoader.exists(MVP2_RUNTIME_HOST_PATH), "Missing MVP-2 runtime host script")
	if not ResourceLoader.exists(MVP2_RUNTIME_HOST_PATH):
		return
	var host = load(MVP2_RUNTIME_HOST_PATH).new()
	for method_name in ["configure", "select_school", "forward_enemy_died", "try_use_ultimate", "deactivate"]:
		assert_true(host.has_method(method_name), "Missing host method: %s" % method_name)
	for property_name in ["selected_school_id", "selected_school_name", "active_runtime"]:
		assert_true(_has_property(host, property_name), "Missing host property: %s" % property_name)
	assert_true(host.has_signal("player_action_resolved"))
	host.free()


func test_player_visual_controller_contract() -> void:
	assert_true(ResourceLoader.exists(PLAYER_VISUAL_PATH), "Missing player visual controller")
	if not ResourceLoader.exists(PLAYER_VISUAL_PATH):
		return
	var visual = load(PLAYER_VISUAL_PATH).new()
	for method_name in ["show_hit", "advance_pose", "current_pose"]:
		assert_true(visual.has_method(method_name), "Missing player visual method: %s" % method_name)
	assert_false(visual.has_method("show_attack"))
	visual.free()


func test_bongma_runtime_contract() -> void:
	assert_true(ResourceLoader.exists(MVP2_BONGMA_RUNTIME_PATH), "Missing Bongma runtime")
	if not ResourceLoader.exists(MVP2_BONGMA_RUNTIME_PATH):
		return
	var runtime = load(MVP2_BONGMA_RUNTIME_PATH).new()
	assert_true(runtime.has_method("try_use_ultimate"))
	for property_name in ["spirit", "spirit_maximum", "ward_center", "ward_time_remaining", "ultimate_time_remaining"]:
		assert_true(_has_property(runtime, property_name), "Missing Bongma property: %s" % property_name)
	runtime.free()


func test_bongma_familiar_contract() -> void:
	assert_true(ResourceLoader.exists(MVP2_BONGMA_FAMILIAR_PATH), "Missing Bongma familiar")
	if not ResourceLoader.exists(MVP2_BONGMA_FAMILIAR_PATH):
		return
	var familiar = load(MVP2_BONGMA_FAMILIAR_PATH).new()
	for method_name in ["configure", "set_attack_interval", "attack_once"]:
		assert_true(familiar.has_method(method_name), "Missing familiar method: %s" % method_name)
	assert_true(_has_property(familiar, "attack_interval"))
	assert_true(_has_property(familiar, "damage"))
	familiar.free()


func test_cheonsul_runtime_contract() -> void:
	assert_true(ResourceLoader.exists(MVP2_CHEONSUL_RUNTIME_PATH), "Missing Cheonsul runtime")
	if not ResourceLoader.exists(MVP2_CHEONSUL_RUNTIME_PATH):
		return
	var runtime = load(MVP2_CHEONSUL_RUNTIME_PATH).new()
	for method_name in ["apply_flame_cast", "apply_token", "has_status", "try_use_ultimate", "is_ultimate_ready"]:
		assert_true(runtime.has_method(method_name), "Missing Cheonsul method: %s" % method_name)
	assert_true(_has_property(runtime, "reaction_count"))
	runtime.free()


func test_guiin_runtime_contract() -> void:
	assert_true(ResourceLoader.exists(MVP2_GUIIN_RUNTIME_PATH), "Missing Guiin runtime")
	if not ResourceLoader.exists(MVP2_GUIIN_RUNTIME_PATH):
		return
	var runtime = load(MVP2_GUIIN_RUNTIME_PATH).new()
	for method_name in ["perform_melee_pulse", "current_pulse_interval", "current_pulse_radius", "current_pulse_damage", "try_use_ultimate", "is_ultimate_ready"]:
		assert_true(runtime.has_method(method_name), "Missing Guiin method: %s" % method_name)
	for property_name in ["gwihyeol", "time_since_gain", "ultimate_time_remaining"]:
		assert_true(_has_property(runtime, property_name), "Missing Guiin property: %s" % property_name)
	runtime.free()


func test_heukyeong_runtime_contract() -> void:
	assert_true(ResourceLoader.exists(MVP2_HEUKYEONG_RUNTIME_PATH), "Missing Heukyeong runtime")
	if not ResourceLoader.exists(MVP2_HEUKYEONG_RUNTIME_PATH):
		return
	var runtime = load(MVP2_HEUKYEONG_RUNTIME_PATH).new()
	for method_name in ["set_rng_seed", "attack_once", "apply_needle_hit", "get_mark_count", "get_total_active_marks", "get_critical_chance", "try_use_ultimate", "is_ultimate_ready"]:
		assert_true(runtime.has_method(method_name), "Missing Heukyeong method: %s" % method_name)
	runtime.free()


func test_enemy_effect_badge_contract() -> void:
	assert_true(ResourceLoader.exists(MVP2_BADGE_PATH), "Missing enemy effect badge")
	if not ResourceLoader.exists(MVP2_BADGE_PATH):
		return
	var badge = load(MVP2_BADGE_PATH).new()
	assert_true(badge.has_method("set_text"))
	badge.free()


func test_hud_contract() -> void:
	var hud = load("res://scripts/ui/hud.gd").new()
	assert_true(hud.has_method("set_health"))
	assert_true(hud.has_method("set_score"))
	assert_true(hud.has_method("show_game_over"))
	hud.free()


func _has_property(instance: Object, property_name: StringName) -> bool:
	for property in instance.get_property_list():
		if property.name == property_name:
			return true
	return false
