extends GutTest

const GEAR = preload("res://scripts/core/equipment_loadout_state.gd")
const PLAYER = preload("res://scripts/player/player_controller.gd")
const WEAPON = preload("res://scripts/combat/basic_weapon_controller.gd")
const RESOLVER = preload("res://scripts/combat/combat_resolver.gd")
const BUILD = preload("res://scripts/core/run_build_state.gd")

class Target:
	extends Node2D
	var health := 1000
	func take_damage(amount: int) -> int:
		var actual := mini(amount, health)
		health -= actual
		return actual
	func is_dead() -> bool: return health <= 0

func _fixture(school: StringName, slot: StringName) -> Dictionary:
	var world := Node2D.new()
	add_child_autofree(world)
	var player = PLAYER.new()
	world.add_child(player)
	player.set_physics_process(false)
	player.health = 50
	var weapons = WEAPON.new()
	player.add_child(weapons)
	weapons.set_process(false)
	var resolver = RESOLVER.new()
	world.add_child(resolver)
	weapons.configure(resolver)
	var gear = GEAR.new()
	assert_true(gear.imbue_equipped(school, slot))
	assert_true(weapons.apply_equipment_snapshot(gear.get_snapshot()))
	var target := Target.new()
	world.add_child(target)
	target.position = Vector2(30, 0)
	target.add_to_group("enemies")
	return {"world": world, "player": player, "weapons": weapons, "resolver": resolver, "gear": gear, "target": target}

func test_guiin_weapon_lifesteal_has_a_shared_cap_and_no_school_damage_proc() -> void:
	var f := _fixture(&"guiin", &"melee")
	f.weapons.katana_damage = 100
	assert_eq(f.weapons.swing_katana_once(), 1)
	assert_eq(f.player.health, 52, "4HP nominal healing is bounded to2 in this quarter second")
	f.weapons.swing_katana_once()
	assert_eq(f.player.health, 52)
	f.resolver.deal_school_damage(f.target, 100)
	assert_eq(f.player.health, 52, "Ninjutsu is not a weapon proc")
	f.weapons._process(0.25)
	assert_gt(f.player.health, 52)

func test_shield_is_nonstacking_and_removal_drops_its_owned_effect() -> void:
	var f := _fixture(&"bongma", &"melee")
	f.weapons.swing_katana_once()
	assert_eq(f.player.take_damage(10), 7)
	f.player._damage_protection_remaining = 0
	f.weapons.swing_katana_once()
	assert_eq(f.player.take_damage(10), 10, "Shield cannot reproc inside4 seconds")
	f.weapons._process(4.0)
	f.weapons.swing_katana_once()
	var plain = GEAR.new()
	assert_true(f.weapons.apply_equipment_snapshot(plain.get_snapshot()))
	f.player._damage_protection_remaining = 0
	assert_eq(f.player.take_damage(10), 10, "Unequipped power cannot leave a shield behind")

func test_outfit_heal_ticks_only_during_live_weapon_processing() -> void:
	var f := _fixture(&"guiin", &"outfit")
	f.target.remove_from_group("enemies")
	f.weapons._process(1.0)
	assert_eq(f.player.health, 50)
	f.weapons._process(1.0)
	assert_eq(f.player.health, 51)
	get_tree().paused = true
	f.weapons._process(20.0)
	assert_eq(f.player.health, 51)
	get_tree().paused = false
	f.player.health = 0
	f.player._dead = true
	f.weapons._process(20.0)
	assert_eq(f.player.health, 0)

func test_passive_equipment_power_is_derived_only_from_equipped_instances() -> void:
	var gear = GEAR.new()
	gear.imbue_equipped(&"heukyeong", &"outfit")
	gear.imbue_equipped(&"cheonsul", &"outfit")
	var build = add_child_autofree(BUILD.new())
	build.configure({}, {})
	assert_true(build.commit_equipment_snapshot(gear.get_snapshot()))
	assert_almost_eq(build.get_modifiers().evasion_chance, 0.08, 0.0001)
	assert_almost_eq(build.get_modifiers().damage_taken_pct, -0.10, 0.0001)
	var plain = GEAR.new()
	build.commit_equipment_snapshot(plain.get_snapshot())
	assert_almost_eq(build.get_modifiers().evasion_chance, 0.0, 0.0001)
	assert_almost_eq(build.get_modifiers().damage_taken_pct, -0.05, 0.0001)

func test_elemental_projectile_proc_is_once_per_cast_and_never_school_scaled() -> void:
	var f := _fixture(&"cheonsul", &"projectile")
	f.weapons.shuriken_projectile_scene = load("res://scenes/projectiles/shuriken_projectile.tscn")
	f.weapons.shuriken_damage = 40
	var modifiers := RunModifierSet.new()
	modifiers.school_damage_pct = 10.0
	f.resolver.set_modifiers(modifiers)
	# Locate a deterministic seed whose first roll procs, without replacing RNG.
	var probe := RandomNumberGenerator.new()
	var chosen_seed := 0
	while true:
		probe.seed = chosen_seed
		if probe.randf() < 0.2: break
		chosen_seed += 1
	f.weapons._equipment_powers._rng.seed = chosen_seed
	var projectile = f.weapons.fire_shuriken_once()
	assert_not_null(projectile)
	projectile.pierce_count = 1
	assert_true(projectile.hit_body(f.target))
	assert_eq(f.target.health, 950, "40 weapon +10 equipment; no 11x ninjutsu multiplier")
	var second := Target.new()
	f.world.add_child(second)
	second.position = Vector2(50, 0)
	assert_true(projectile.hit_body(second))
	assert_eq(second.health, 960, "Piercing second hit cannot proc again")
	assert_eq(f.resolver.current_damage_kind_for(f.target), &"")

func test_lifesteal_actual_cap_survives_healing_bonuses_and_weapon_generation_change() -> void:
	var f := _fixture(&"guiin", &"projectile")
	f.weapons.shuriken_projectile_scene = load("res://scenes/projectiles/shuriken_projectile.tscn")
	f.weapons.shuriken_damage = 100
	var modifiers := RunModifierSet.new()
	modifiers.healing_pct = 10.0
	f.player.apply_run_modifiers(modifiers)
	var projectile = f.weapons.fire_shuriken_once()
	assert_true(projectile.hit_body(f.target))
	assert_eq(f.player.health, 52, "Cap applies after healing efficiency")
	var old_projectile = f.weapons.fire_shuriken_once()
	f.weapons.apply_equipment_snapshot(f.gear.get_snapshot())
	assert_true(old_projectile.hit_body(f.target))
	assert_eq(f.player.health, 52, "Old projectile generation cannot proc newly committed gear")

func test_invalid_equipment_preserves_current_effect_and_evasion_stays_below40percent() -> void:
	var f := _fixture(&"bongma", &"outfit")
	f.target.remove_from_group("enemies")
	f.weapons._process(8.0)
	assert_false(f.weapons.apply_equipment_snapshot({}))
	assert_eq(f.player.take_damage(10), 2)
	var gear = GEAR.new()
	gear.imbue_equipped(&"heukyeong", &"outfit")
	var build = add_child_autofree(BUILD.new())
	build.configure({}, {})
	build.commit_equipment_snapshot(gear.get_snapshot())
	var modifiers := RunModifierSet.new()
	modifiers.evasion_chance = 0.90
	build.set_committed_backpack_modifiers(modifiers)
	assert_almost_eq(build.get_modifiers().evasion_chance, 0.40, 0.0001)
