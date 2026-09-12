extends GutTest

func _fixture(ids: Array, school: StringName = &"guiin") -> Dictionary:
	var world := Node2D.new()
	add_child_autofree(world)
	var player = load("res://scripts/player/player_controller.gd").new()
	world.add_child(player)
	player.set_physics_process(false)
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	enemy.max_health = 1000
	world.add_child(enemy)
	enemy.position = Vector2(60, 0)
	enemy.set_physics_process(false)
	enemy.set_process(false)
	var loadout = load("res://scripts/core/ninjutsu_loadout_state.gd").new()
	world.add_child(loadout)
	loadout.begin_start_draft(school, 12)
	for index in range(2):
		loadout.choose_start_draft(loadout.start_draft_snapshot().options[0])
	loadout.commit_drafted_start(loadout.start_draft_snapshot().picks)
	assert_true(loadout.commit_placed_ninjutsu(ids, [&"guiin", &"cheonsul", &"heukyeong", &"bongma"]))
	var controller = load("res://scripts/schools/ninjutsu_auto_controller.gd").new()
	world.add_child(controller)
	controller.set_process(false)
	controller.configure(player, world, null, loadout)
	return {"player": player, "enemy": enemy, "loadout": loadout, "controller": controller, "world": world}


func test_proximity_guard_reduces_damage_only_while_enemy_is_near() -> void:
	var f := _fixture([&"guiin_iron_blood_guard"])
	f.controller.tick_auto_cast(0.01)
	assert_eq(f.player.take_damage(20), 18)
	f.player.advance_damage_protection(0.4)
	f.enemy.position.x = 111
	f.controller.tick_auto_cast(0.01)
	assert_eq(f.player.take_damage(20), 20)


func test_ice_shield_absorbs_after_reduction_and_dash_does_not_spend_it() -> void:
	var f := _fixture([&"guiin_iron_blood_guard", &"cheonsul_ice_veil"])
	f.controller.tick_auto_cast(9.0)
	assert_true(f.player.request_dash())
	assert_eq(f.player.take_damage(20), 0)
	f.player._advance_dash_state(0.2)
	assert_eq(f.player.take_damage(20), 6, "18 mitigated damage minus12 shield")
	f.player.advance_damage_protection(0.4)
	assert_eq(f.player.take_damage(20), 18)


func test_demon_step_triggers_on_actual_dash_end_and_expires_without_extra_charge() -> void:
	var f := _fixture([&"guiin_demon_step"])
	f.controller.tick_auto_cast(5.0)
	assert_almost_eq(f.player.move_speed, 240.0, 0.001)
	assert_true(f.player.request_dash())
	assert_almost_eq(f.player.move_speed, 240.0, 0.001)
	f.player._advance_dash_state(0.2)
	assert_almost_eq(f.player.move_speed, 276.0, 0.001)
	assert_eq(f.player.current_dash_charges(), 1)
	f.controller.tick_auto_cast(1.2)
	assert_almost_eq(f.player.move_speed, 240.0, 0.001)


func test_smoke_step_guard_ends_after_one_second() -> void:
	var f := _fixture([&"heukyeong_smoke_step"], &"heukyeong")
	f.controller.tick_auto_cast(6.0)
	f.player.request_dash()
	f.player._advance_dash_state(0.2)
	assert_eq(f.player.take_damage(20), 17)
	f.player.advance_damage_protection(0.4)
	f.controller.tick_auto_cast(1.0)
	assert_eq(f.player.take_damage(20), 20)


func test_removing_books_clears_shield_and_reduction_immediately() -> void:
	var f := _fixture([&"guiin_iron_blood_guard", &"cheonsul_ice_veil"])
	f.controller.tick_auto_cast(9.0)
	f.loadout.commit_placed_ninjutsu([], [&"guiin"])
	assert_eq(f.player.take_damage(20), 20)


func test_pause_freezes_shield_duration_and_guiin_form_keeps_protection() -> void:
	var f := _fixture([&"guiin_iron_blood_guard", &"cheonsul_ice_veil"])
	var resolver = load("res://scripts/combat/combat_resolver.gd").new()
	f.world.add_child(resolver)
	f.controller.configure(f.player, f.world, resolver, f.loadout)
	f.controller.tick_auto_cast(9.0)
	get_tree().paused = true
	f.controller.tick_auto_cast(20.0)
	get_tree().paused = false
	resolver.sword_only_mode = true
	f.controller.tick_auto_cast(1.0)
	assert_eq(f.player.take_damage(20), 6)
	f.player.advance_damage_protection(0.4)
	f.controller.tick_auto_cast(2.0)
	assert_eq(f.player.take_damage(20), 18)


func test_gear_modifier_refresh_preserves_speed_boon_without_compounding() -> void:
	var f := _fixture([&"guiin_demon_step"])
	f.controller.tick_auto_cast(5.0)
	f.player.request_dash()
	f.player._advance_dash_state(0.2)
	var modifiers = load("res://scripts/data/run_modifier_set.gd").new()
	modifiers.move_speed_pct = 0.1
	f.player.apply_run_modifiers(modifiers)
	f.player.apply_run_modifiers(modifiers)
	assert_almost_eq(f.player.move_speed, 300.0, 0.001)
	f.controller.tick_auto_cast(1.2)
	assert_almost_eq(f.player.move_speed, 264.0, 0.001)


func test_death_and_stage_reconfigure_remove_boons_without_completing_a_dash() -> void:
	var f := _fixture([&"guiin_demon_step"])
	f.controller.tick_auto_cast(5.0)
	f.player.request_dash()
	f.player._advance_dash_state(0.2)
	assert_almost_eq(f.player.move_speed, 276.0, 0.001)
	f.controller.configure(f.player, f.world, null, f.loadout)
	assert_almost_eq(f.player.move_speed, 240.0, 0.001)
	f.controller.tick_auto_cast(5.0)
	f.player.request_dash()
	f.player._advance_dash_state(0.2)
	f.player.take_damage(10000)
	assert_true(f.player.is_dead())
	assert_almost_eq(f.player.move_speed, 240.0, 0.001)


func test_full_shield_absorption_does_not_grant_free_invulnerability() -> void:
	var f := _fixture([&"cheonsul_ice_veil"], &"cheonsul")
	f.controller.tick_auto_cast(9.0)
	assert_eq(f.player.take_damage(8), 0)
	assert_eq(f.player.take_damage(8), 4)


func test_repeated_dash_end_cannot_refresh_boon_before_internal_cooldown() -> void:
	var f := _fixture([&"guiin_demon_step"])
	f.controller.tick_auto_cast(5.0)
	f.player.request_dash()
	f.player._advance_dash_state(0.2)
	f.controller.tick_auto_cast(1.0)
	f.player.request_dash()
	f.player._advance_dash_state(0.2)
	f.controller.tick_auto_cast(0.2)
	assert_almost_eq(f.player.move_speed, 240.0, 0.001)


func test_ward_and_barrier_use_maximum_not_sum_and_do_not_follow_player() -> void:
	var f := _fixture([&"bongma_guardian_ward", &"bongma_barrier_step"], &"bongma")
	f.controller.tick_auto_cast(8.0)
	f.player.request_dash()
	f.player._advance_dash_state(0.2)
	assert_eq(f.player.take_damage(20), 16)
	f.player.advance_damage_protection(0.4)
	f.player.position = Vector2(121, 0)
	f.controller.tick_auto_cast(0.1)
	assert_eq(f.player.take_damage(20), 20)
	f.player.advance_damage_protection(0.4)
	f.player.position = Vector2.ZERO
	f.controller.tick_auto_cast(0.1)
	assert_eq(f.player.take_damage(20), 16, "A still-live fixed zone protects again on reentry.")


func test_barrier_is_fixed_at_dash_destination_and_expires() -> void:
	var f := _fixture([&"bongma_barrier_step"], &"bongma")
	f.controller.tick_auto_cast(6.0)
	f.player.request_dash()
	f.player.position = Vector2(200, 0)
	f.player._advance_dash_state(0.2)
	assert_eq(f.player.take_damage(20), 18)
	f.player.advance_damage_protection(0.4)
	f.player.position = Vector2(291, 0)
	f.controller.tick_auto_cast(0.1)
	assert_eq(f.player.take_damage(20), 20)
	f.player.advance_damage_protection(0.4)
	f.player.position = Vector2(200, 0)
	f.controller.tick_auto_cast(1.4)
	assert_eq(f.player.take_damage(20), 20)


func test_heukyeong_resource_reads_selected_mark_without_owning_or_bursting_it() -> void:
	var f := _fixture([&"heukyeong_shadow_needle"], &"heukyeong")
	var runtime = load("res://scripts/schools/heukyeong_runtime.gd").new()
	f.world.add_child(runtime)
	runtime.configure(f.player, f.world)
	runtime.configure_ninjutsu_loadout(f.loadout)
	if runtime.has_method("configure_selected_status_provider"):
		runtime.configure_selected_status_provider(f.controller)
	var resolver = load("res://scripts/combat/combat_resolver.gd").new()
	f.world.add_child(resolver)
	runtime.configure_run_systems(resolver, null)
	runtime.activate()
	runtime.set_process(false)
	f.controller.configure(f.player, f.world, resolver, f.loadout)
	f.controller.tick_auto_cast(1.1)
	f.controller.tick_auto_cast(0.2)
	assert_eq(runtime.get_mark_count(f.enemy), 1)
	assert_almost_eq(runtime.execution_charge, 0.25, 0.00001)
	assert_eq(f.enemy.health, 994)
	f.loadout.commit_placed_ninjutsu([], [&"heukyeong"])
	assert_eq(runtime.get_mark_count(f.enemy), 0)
	assert_true(runtime._marks.is_empty(), "Origin runtime must not copy selected mark state.")


func test_all_school_runtimes_keep_charge_but_do_not_supply_unowned_attacks() -> void:
	for school in [&"bongma", &"cheonsul", &"heukyeong"]:
		var f := _fixture([], school)
		var runtime = load("res://scripts/schools/%s_runtime.gd" % school).new()
		f.world.add_child(runtime)
		runtime.configure(f.player, f.world)
		assert_true(runtime.has_method("configure_ninjutsu_loadout"), str(school))
		if not runtime.has_method("configure_ninjutsu_loadout"):
			continue
		if school == &"bongma":
			runtime.familiar_scene = load("res://scenes/schools/bongma_familiar.tscn")
		runtime.configure_ninjutsu_loadout(f.loadout)
		runtime.activate()
		runtime._process(10.0)
		assert_eq(f.enemy.health, 1000, str(school) + " must not have a free automatic attack")
		if school == &"bongma":
			assert_null(runtime.get_node_or_null("Familiar"))
			assert_gt(runtime.spirit, 0.0)
		elif school == &"cheonsul":
			assert_gt(runtime.reaction_count, 0.0)
		else:
			assert_gt(runtime.execution_charge, 0.0)
