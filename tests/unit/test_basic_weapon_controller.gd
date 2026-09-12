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


func test_katana_hits_entire_forward_crowd_without_three_target_cap() -> void:
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

	assert_eq(controller.swing_katana_once(), 4)
	assert_eq(targets[0].health, 90)
	assert_eq(targets[1].health, 90)
	assert_eq(targets[2].health, 90)
	assert_eq(targets[3].health, 90)
	assert_eq(targets[4].health, 100)
	assert_eq(fixture.tracker.damage, 40)


func test_katana_excludes_rear_and_outside_sixty_degree_half_angle() -> void:
	var fixture := _new_fixture()
	var targets: Array[DamageTarget] = []
	for point in [Vector2(20, 0), Vector2(-30, 0), Vector2(50, 86.60254), Vector2(48.48096, 87.46197)]:
		var target := DamageTarget.new()
		fixture.world.add_child(target)
		target.position = point
		target.add_to_group("enemies")
		targets.append(target)
	assert_eq(fixture.controller.swing_katana_once(), 2)
	assert_eq(targets[0].health, 90)
	assert_eq(targets[1].health, 100)
	assert_eq(targets[2].health, 90)
	assert_eq(targets[3].health, 100)


func test_shuriken_does_not_aim_beyond_480_world_units() -> void:
	var fixture := _new_fixture()
	fixture.controller.shuriken_projectile_scene = SHURIKEN_SCENE
	var target := DamageTarget.new()
	fixture.world.add_child(target)
	target.position = Vector2(481, 0)
	target.add_to_group("enemies")
	assert_null(fixture.controller.fire_shuriken_once())
	target.position.x = 480
	assert_not_null(fixture.controller.fire_shuriken_once())


func test_paused_direct_weapon_calls_do_not_damage_or_spawn() -> void:
	var fixture := _new_fixture()
	fixture.controller.shuriken_projectile_scene = SHURIKEN_SCENE
	var target := DamageTarget.new()
	fixture.world.add_child(target)
	target.position = Vector2(20, 0)
	target.add_to_group("enemies")
	get_tree().paused = true
	var hits: int = fixture.controller.swing_katana_once()
	var projectile = fixture.controller.fire_shuriken_once()
	get_tree().paused = false
	assert_eq(hits, 0)
	assert_null(projectile)
	assert_eq(target.health, 100)


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


func test_equipped_naginata_uses_forward_rectangle_and_instance_upgrade() -> void:
	var fixture := _new_fixture()
	var controller = fixture.controller
	assert_true(controller.has_method("apply_equipment_snapshot"))
	if not controller.has_method("apply_equipment_snapshot"):
		return
	var equipment = load("res://scripts/core/equipment_loadout_state.gd").new()
	assert_true(equipment.acquire(&"naginata"))
	assert_true(equipment.equip(&"melee", &"naginata"))
	assert_true(equipment.upgrade_equipped(&"melee"))
	assert_true(controller.apply_equipment_snapshot(equipment.get_snapshot()))
	var targets: Array[DamageTarget] = []
	for point in [Vector2(20, 0), Vector2(179, 23), Vector2(100, 25), Vector2(-1, 0), Vector2(181, 0)]:
		var target := DamageTarget.new()
		fixture.world.add_child(target)
		target.position = point
		target.add_to_group("enemies")
		targets.append(target)
	# Rear target would be the nearest: remove it from automatic aim by positioning it outside range.
	targets[3].position = Vector2(-181, 0)
	assert_eq(controller.swing_katana_once(), 2)
	assert_eq(targets[0].health, 80) # 17 * 1.15 = 19.55, rounded once.
	assert_eq(targets[1].health, 80)
	assert_eq(targets[2].health, 100)
	assert_eq(targets[3].health, 100)
	assert_eq(targets[4].health, 100)


func test_kunai_emits_two_projectiles_at_six_degree_offsets_with_bounded_lifetime() -> void:
	var fixture := _new_fixture()
	assert_true(fixture.controller.has_method("apply_equipment_snapshot"))
	if not fixture.controller.has_method("apply_equipment_snapshot"):
		return
	var equipment = load("res://scripts/core/equipment_loadout_state.gd").new()
	assert_true(equipment.acquire(&"kunai"))
	assert_true(equipment.equip(&"projectile", &"kunai"))
	assert_true(fixture.controller.apply_equipment_snapshot(equipment.get_snapshot()))
	fixture.controller.shuriken_projectile_scene = SHURIKEN_SCENE
	var target := DamageTarget.new()
	fixture.world.add_child(target)
	target.position = Vector2(120, 0)
	target.add_to_group("enemies")
	var emitted: Array[Node2D] = []
	fixture.controller.shuriken_fired.connect(func(projectile: Node2D): emitted.append(projectile))
	assert_not_null(fixture.controller.fire_shuriken_once())
	assert_eq(emitted.size(), 2)
	if emitted.size() != 2:
		return
	assert_almost_eq(rad_to_deg(emitted[0].direction.angle()), -6.0, 0.001)
	assert_almost_eq(rad_to_deg(emitted[1].direction.angle()), 6.0, 0.001)
	assert_eq(emitted[0].damage, 6)
	assert_eq(emitted[0].lifetime, 1.0)
	assert_eq(emitted[0].get_node("CollisionShape2D").shape.radius, 6.0)


func test_invalid_equipment_does_not_replace_current_weapon_profile() -> void:
	var fixture := _new_fixture()
	assert_true(fixture.controller.has_method("apply_equipment_snapshot"))
	if not fixture.controller.has_method("apply_equipment_snapshot"):
		return
	assert_false(fixture.controller.apply_equipment_snapshot({}))
	assert_eq(fixture.controller.katana_damage, 10.0)
	assert_eq(fixture.controller.shuriken_damage, 9)


func test_powder_bomb_locks_target_position_then_damages_only_current_blast_occupants() -> void:
	var fixture := _new_fixture()
	var equipment = load("res://scripts/core/equipment_loadout_state.gd").new()
	assert_true(equipment.acquire(&"powder_bomb"))
	assert_true(equipment.equip(&"projectile", &"powder_bomb"))
	assert_true(fixture.controller.apply_equipment_snapshot(equipment.get_snapshot()))
	if fixture.controller.shuriken_target_radius != 360.0:
		return
	fixture.controller.shuriken_projectile_scene = SHURIKEN_SCENE
	var first := DamageTarget.new()
	var second := DamageTarget.new()
	fixture.world.add_child(first)
	fixture.world.add_child(second)
	first.position = Vector2(100, 0)
	second.position = Vector2(160, 0)
	first.add_to_group("enemies")
	second.add_to_group("enemies")
	var bomb: Node2D = fixture.controller.fire_shuriken_once()
	assert_not_null(bomb)
	if bomb == null:
		return
	assert_eq(bomb.position, Vector2(100, 0))
	first.position = Vector2(300, 0)
	bomb._physics_process(0.44)
	assert_eq(second.health, 100)
	bomb._physics_process(0.02)
	assert_eq(first.health, 100)
	assert_eq(second.health, 82)
	bomb._physics_process(1.0)
	assert_eq(second.health, 82)


func test_guiin_sword_mode_blocks_other_damage_and_restores_original_weapon_clocks() -> void:
	var fixture := _new_fixture()
	assert_true(fixture.controller.has_method("begin_guiin_form"))
	if not fixture.controller.has_method("begin_guiin_form"):
		return
	var target := DamageTarget.new()
	fixture.world.add_child(target)
	target.position = Vector2(40, 0)
	target.add_to_group("enemies")
	fixture.controller._katana_remaining = 0.27
	fixture.controller._shuriken_remaining = 0.42
	fixture.controller.katana_damage = 37.0
	assert_true(fixture.controller.begin_guiin_form())
	assert_eq(target.health, 80, "Guiin form immediately uses its own20damage sword, not old equipment damage.")
	assert_eq(fixture.resolver.deal_basic_weapon_damage(target, 999), 0)
	assert_eq(fixture.resolver.deal_school_damage(target, 999), 0)
	assert_eq(fixture.resolver.deal_school_damage(target, 999, &"ultimate"), 0)
	assert_null(fixture.controller.fire_shuriken_once())
	assert_false(fixture.controller.begin_guiin_form())
	fixture.controller._process(0.325)
	assert_eq(target.health, 60)
	fixture.controller.end_guiin_form()
	fixture.controller.end_guiin_form()
	assert_eq(fixture.controller.katana_damage, 37.0)
	assert_eq(fixture.controller._katana_remaining, 0.27)
	assert_eq(fixture.controller._shuriken_remaining, 0.42)
	assert_eq(fixture.resolver.deal_basic_weapon_damage(target, 9), 9)


func test_guiin_clears_precast_projectiles_so_early_exit_cannot_revive_their_damage() -> void:
	var fixture := _new_fixture()
	var target := DamageTarget.new()
	fixture.world.add_child(target)
	target.position = Vector2(200, 0)
	target.add_to_group("enemies")
	fixture.controller.shuriken_projectile_scene = SHURIKEN_SCENE
	var projectile: BasicProjectile = fixture.controller.fire_shuriken_once()
	assert_not_null(projectile)
	assert_true(fixture.controller.begin_guiin_form())
	assert_true(projectile.is_queued_for_deletion())
	fixture.controller.end_guiin_form()
	assert_false(projectile.hit_body(target))
	assert_eq(target.health, 100)


func test_guiin_temporary_sword_inherits_rank_but_never_original_weapon_damage() -> void:
	var fixture := _new_fixture()
	var target := DamageTarget.new()
	fixture.world.add_child(target)
	target.position = Vector2(40, 0)
	target.add_to_group("enemies")
	for weapon in [&"katana", &"dual_tanto", &"naginata", &"kusarigama"]:
		for rank in range(5):
			var equipment = load("res://scripts/core/equipment_loadout_state.gd").new()
			if weapon != &"katana":
				assert_true(equipment.acquire(weapon))
				assert_true(equipment.equip(&"melee", weapon))
			for index in range(rank):
				assert_true(equipment.upgrade_equipped(&"melee"))
			assert_true(fixture.controller.apply_equipment_snapshot(equipment.get_snapshot()))
			target.health = 100
			assert_true(fixture.controller.begin_guiin_form())
			assert_eq(target.health, [80, 77, 74, 71, 68][rank])
			fixture.controller.end_guiin_form()
