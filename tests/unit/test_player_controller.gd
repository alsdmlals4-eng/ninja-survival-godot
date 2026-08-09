extends GutTest

const PlayerScript = preload("res://scripts/player/player_controller.gd")

var death_count: int = 0


func before_each() -> void:
	death_count = 0


func test_damage_reduces_health_clamps_and_dies_once() -> void:
	var player = PlayerScript.new()
	player.max_health = 30
	add_child_autofree(player)
	player.died.connect(_on_player_died)

	player.take_damage(12)
	assert_eq(player.health, 18)
	assert_false(player.is_dead())

	player.take_damage(99)
	assert_eq(player.health, 0)
	assert_true(player.is_dead())
	assert_eq(death_count, 1)

	player.take_damage(5)
	assert_eq(death_count, 1)


func test_non_positive_damage_is_ignored() -> void:
	var player = PlayerScript.new()
	player.max_health = 30
	add_child_autofree(player)

	player.take_damage(0)
	player.take_damage(-5)

	assert_eq(player.health, 30)


func test_resolve_movement_direction_supports_wasd_and_ui_keys() -> void:
	var player = PlayerScript.new()
	add_child_autofree(player)

	assert_eq(
		player.resolve_movement_direction(Vector2.ZERO, true, false, false, false),
		Vector2.LEFT,
		"A must add left movement without removing the existing UI-key path"
	)
	var diagonal: Vector2 = player.resolve_movement_direction(
		Vector2.ZERO,
		false,
		true,
		true,
		false
	)
	assert_almost_eq(diagonal.x, 0.707106, 0.001)
	assert_almost_eq(diagonal.y, -0.707106, 0.001)
	assert_eq(
		player.resolve_movement_direction(Vector2.RIGHT, true, false, false, false),
		Vector2.ZERO,
		"Opposing arrow/WASD directions should cancel"
	)


func _on_player_died() -> void:
	death_count += 1
