extends GutTest

const FAMILIAR_PATH := "res://scripts/schools/bongma_familiar.gd"
const PLAYER_PATH := "res://scripts/player/player_controller.gd"
const ENEMY_PATH := "res://scripts/enemies/enemy_chaser.gd"


func test_attack_once_damages_nearest_valid_enemy() -> void:
	assert_true(ResourceLoader.exists(FAMILIAR_PATH), "Bongma familiar script must exist")
	if not ResourceLoader.exists(FAMILIAR_PATH):
		return

	var world := Node2D.new()
	add_child_autofree(world)
	var player = load(PLAYER_PATH).new()
	world.add_child(player)
	var familiar = load(FAMILIAR_PATH).new()
	world.add_child(familiar)
	familiar.configure(player, 0.70, 8)

	var near_enemy = load(ENEMY_PATH).new()
	near_enemy.global_position = Vector2(20, 0)
	world.add_child(near_enemy)
	var far_enemy = load(ENEMY_PATH).new()
	far_enemy.global_position = Vector2(80, 0)
	world.add_child(far_enemy)

	var hit = familiar.attack_once()
	assert_eq(hit, near_enemy)
	assert_eq(near_enemy.health, 12)
	assert_eq(far_enemy.health, 20)


func test_follow_moves_only_beyond_seventy_two_pixels() -> void:
	assert_true(ResourceLoader.exists(FAMILIAR_PATH), "Bongma familiar script must exist")
	if not ResourceLoader.exists(FAMILIAR_PATH):
		return

	var world := Node2D.new()
	add_child_autofree(world)
	var player = load(PLAYER_PATH).new()
	world.add_child(player)
	var familiar = load(FAMILIAR_PATH).new()
	world.add_child(familiar)
	familiar.configure(player, 0.70, 8)

	player.global_position = Vector2(50, 0)
	familiar.global_position = Vector2.ZERO
	familiar._physics_process(0.1)
	assert_eq(familiar.global_position, Vector2.ZERO)

	player.global_position = Vector2(100, 0)
	familiar._physics_process(0.1)
	assert_gt(familiar.global_position.x, 0.0)


func test_attack_ignores_dead_enemy() -> void:
	assert_true(ResourceLoader.exists(FAMILIAR_PATH), "Bongma familiar script must exist")
	if not ResourceLoader.exists(FAMILIAR_PATH):
		return

	var world := Node2D.new()
	add_child_autofree(world)
	var player = load(PLAYER_PATH).new()
	world.add_child(player)
	var familiar = load(FAMILIAR_PATH).new()
	world.add_child(familiar)
	familiar.configure(player, 0.70, 8)

	var dead_enemy = load(ENEMY_PATH).new()
	dead_enemy.global_position = Vector2(10, 0)
	world.add_child(dead_enemy)
	dead_enemy.take_damage(999)
	var alive_enemy = load(ENEMY_PATH).new()
	alive_enemy.global_position = Vector2(30, 0)
	world.add_child(alive_enemy)

	assert_eq(familiar.attack_once(), alive_enemy)
	assert_eq(alive_enemy.health, 12)
