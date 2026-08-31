extends GutTest

const EnemyScript = preload("res://scripts/enemies/enemy_chaser.gd")
const OPENING_CONTACT_STAGGER_META := &"ninja_wave_opening_contact_stagger_seconds"

class DamageTarget:
	extends Node2D
	var damage_taken: int = 0

	func take_damage(amount: int) -> void:
		damage_taken += amount


class DamageBodyTarget:
	extends CharacterBody2D
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


func test_take_damage_returns_actual_hp_loss_including_overkill() -> void:
	var enemy = EnemyScript.new()
	enemy.max_health = 20
	add_child_autofree(enemy)
	assert_eq(enemy.take_damage(7), 7)
	assert_eq(enemy.take_damage(99), 13)
	assert_eq(enemy.take_damage(1), 0)


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


func test_opening_contact_stagger_delays_the_first_overlap_damage() -> void:
	var enemy = EnemyScript.new()
	enemy.contact_damage = 7
	enemy.set_meta(OPENING_CONTACT_STAGGER_META, 0.5)
	add_child_autofree(enemy)
	var target = DamageTarget.new()
	add_child_autofree(target)
	enemy.set_target(target)
	enemy.global_position = Vector2.ZERO
	target.global_position = Vector2.ZERO

	enemy._physics_process(0.0)
	assert_eq(target.damage_taken, 0)
	enemy._physics_process(0.49)
	assert_eq(target.damage_taken, 0)
	enemy._physics_process(0.02)
	assert_eq(target.damage_taken, 7)


func test_physics_contact_applies_damage_when_bodies_collide() -> void:
	var enemy = EnemyScript.new()
	enemy.collision_layer = 2
	enemy.collision_mask = 1
	enemy.move_speed = 90.0
	enemy.contact_damage = 10
	enemy.contact_range = 28.0
	_add_circle_shape(enemy, 14.0)
	add_child_autofree(enemy)

	var target = DamageBodyTarget.new()
	target.collision_layer = 1
	target.collision_mask = 2
	_add_circle_shape(target, 14.0)
	add_child_autofree(target)

	target.global_position = Vector2.ZERO
	enemy.global_position = Vector2(40.0, 0.0)
	enemy.set_target(target)

	for _frame in range(30):
		await get_tree().physics_frame

	assert_gt(target.damage_taken, 0, "real CharacterBody2D contact should deal damage")


func _add_circle_shape(body: CharacterBody2D, radius: float) -> void:
	var collision_shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	collision_shape.shape = circle
	body.add_child(collision_shape)


func _on_enemy_died(_enemy: Node) -> void:
	death_count += 1
