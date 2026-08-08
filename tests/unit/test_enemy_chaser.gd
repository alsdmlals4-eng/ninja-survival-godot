extends GutTest

const EnemyScript = preload("res://scripts/enemies/enemy_chaser.gd")

class DamageTarget:
	extends Node2D
	var damage_taken: int = 0

	func take_damage(amount: int) -> void:
		damage_taken += amount


var death_count: int = 0


func before_each() -> void:
	death_count = 0


func test_damage_reduces_health_and_dies_once() -> void:
	var enemy = EnemyScript.new()
	enemy.max_health = 20
	add_child_autofree(enemy)
	enemy.died.connect(_on_enemy_died)

	enemy.take_damage(5)
	assert_eq(enemy.health, 15)
	assert_false(enemy.is_dead())

	enemy.take_damage(20)
	assert_eq(enemy.health, 0)
	assert_true(enemy.is_dead())
	assert_eq(death_count, 1)

	enemy.take_damage(5)
	assert_eq(death_count, 1)


func test_set_target_stores_target() -> void:
	var enemy = EnemyScript.new()
	add_child_autofree(enemy)
	var target = Node2D.new()
	add_child_autofree(target)

	enemy.set_target(target)

	assert_eq(enemy.target, target)


func test_contact_damage_is_cooldown_gated() -> void:
	var enemy = EnemyScript.new()
	enemy.contact_damage = 7
	enemy.contact_cooldown = 0.75
	add_child_autofree(enemy)
	var target = DamageTarget.new()
	add_child_autofree(target)
	enemy.set_target(target)
	enemy.global_position = Vector2.ZERO
	target.global_position = Vector2.ZERO

	enemy._physics_process(0.0)
	assert_eq(target.damage_taken, 7)

	enemy._physics_process(0.1)
	assert_eq(target.damage_taken, 7)

	enemy._physics_process(0.65)
	assert_eq(target.damage_taken, 14)


func _on_enemy_died(_enemy: Node) -> void:
	death_count += 1
