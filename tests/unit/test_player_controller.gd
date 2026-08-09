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


func _on_player_died() -> void:
	death_count += 1
