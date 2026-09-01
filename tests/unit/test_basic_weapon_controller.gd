extends GutTest

const BASIC_WEAPON_SCRIPT := preload("res://scripts/combat/basic_weapon_controller.gd")
const COMBAT_RESOLVER_SCRIPT := preload("res://scripts/combat/combat_resolver.gd")
const CONTRIBUTION_TRACKER_SCRIPT := preload("res://scripts/combat/combat_contribution_tracker.gd")
const SHURIKEN_SCENE := preload("res://scenes/projectiles/shuriken_projectile.tscn")

class DamageTarget:
	extends Node2D
	var health: int = 100

	func take_damage(amount: int) -> int:
		var actual := mini(maxi(amount, 0), health)
		health -= actual
		return actual

	func is_dead() -> bool:
		return health <= 0


func test_katana_hits_at_most_three_closest_valid_targets_and_records_damage() -> void:
	var fixture := _new_fixture()
	var controller := fixture.get("controller") as BasicWeaponController
	controller.katana_radius = 112.0
	controller.katana_damage = 10.0
	var targets: Array[DamageTarget] = []
	for distance in [20.0, 30.0, 40.0, 50.0, 140.0]:
		var target := DamageTarget.new()
		target.global_position = Vector2(float(distance), 0.0)
		target.add_to_group("enemies")
		(fixture.get("world") as Node2D).add_child(target)
		targets.append(target)

	assert_eq(controller.swing_katana_once(), 3)
	assert_eq(targets[0].health, 90)
	assert_eq(targets[1].health, 90)
	assert_eq(targets[2].health, 90)
	assert_eq(targets[3].health, 100)
	assert_eq(targets[4].health, 100)
	assert_eq(fixture.tracker.damage, 30)


func test_shuriken_spawns_toward_nearest_valid_target_with_combat_resolver() -> void:
	var fixture := _new_fixture()
	var controller := fixture.get("controller") as BasicWeaponController
	var world := fixture.get("world") as Node2D
	var source := fixture.get("source") as Node2D
	var resolver := fixture.get("resolver") as CombatResolver
	var target := DamageTarget.new()
	target.global_position = Vector2(120.0, 0.0)
	target.add_to_group("enemies")
	world.add_child(target)
	controller.shuriken_projectile_scene = SHURIKEN_SCENE
	controller.shuriken_speed = 640.0
	controller.shuriken_damage = 11

	var projectile: Node2D = controller.fire_shuriken_once()

	assert_not_null(projectile)
	if projectile == null:
		return
	assert_eq(projectile.get_parent(), world)
	assert_eq(projectile.global_position, source.global_position)
	assert_eq(projectile.direction, Vector2.RIGHT)
	assert_eq(projectile.speed, 640.0)
	assert_eq(projectile.damage, 11)
	assert_eq(projectile.combat_resolver, resolver)


func test_dead_or_out_of_range_targets_do_not_receive_a_katana_hit() -> void:
	var fixture := _new_fixture()
	var world := fixture.get("world") as Node2D
	var controller := fixture.get("controller") as BasicWeaponController
	var tracker = fixture.get("tracker")
	var dead_target := DamageTarget.new()
	dead_target.health = 0
	dead_target.global_position = Vector2(30.0, 0.0)
	dead_target.add_to_group("enemies")
	world.add_child(dead_target)
	var far_target := DamageTarget.new()
	far_target.global_position = Vector2(300.0, 0.0)
	far_target.add_to_group("enemies")
	world.add_child(far_target)

	assert_eq(controller.swing_katana_once(), 0)
	assert_eq(tracker.damage, 0)


func _new_fixture() -> Dictionary:
	var world := Node2D.new()
	add_child_autofree(world)
	var source := Node2D.new()
	world.add_child(source)
	var tracker = CONTRIBUTION_TRACKER_SCRIPT.new()
	tracker.reset_segment(0, 0)
	world.add_child(tracker)
	var resolver = COMBAT_RESOLVER_SCRIPT.new()
	resolver.configure(tracker)
	world.add_child(resolver)
	var controller = BASIC_WEAPON_SCRIPT.new()
	source.add_child(controller)
	controller.configure(resolver)
	return {
		"world": world,
		"source": source,
		"tracker": tracker,
		"resolver": resolver,
		"controller": controller,
	}
