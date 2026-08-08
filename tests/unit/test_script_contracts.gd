extends GutTest

const REQUIRED_SCRIPTS := [
	"res://scripts/core/game_state.gd",
	"res://scripts/player/player_controller.gd",
	"res://scripts/enemies/enemy_chaser.gd",
	"res://scripts/combat/auto_attack_controller.gd",
	"res://scripts/combat/projectile.gd",
]


func test_mvp0_script_resources_exist() -> void:
	for path in REQUIRED_SCRIPTS:
		assert_true(ResourceLoader.exists(path), "Missing MVP-0 script: %s" % path)


func test_game_state_contract() -> void:
	var state = load("res://scripts/core/game_state.gd").new()
	assert_true(state.has_method("register_kill"))
	assert_true(_has_property(state, "score"))
	assert_true(_has_property(state, "kill_count"))
	state.free()


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


func test_auto_attack_controller_contract() -> void:
	var controller = load("res://scripts/combat/auto_attack_controller.gd").new()
	assert_true(controller.has_method("find_nearest_target"))
	assert_true(_has_property(controller, "attack_interval"))
	assert_true(_has_property(controller, "projectile_scene"))
	controller.free()


func test_projectile_contract() -> void:
	var projectile = load("res://scripts/combat/projectile.gd").new()
	assert_true(projectile.has_method("configure"))
	assert_true(_has_property(projectile, "direction"))
	assert_true(_has_property(projectile, "speed"))
	assert_true(_has_property(projectile, "damage"))
	projectile.free()


func _has_property(instance: Object, property_name: StringName) -> bool:
	for property in instance.get_property_list():
		if property.name == property_name:
			return true
	return false
