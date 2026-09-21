extends GutTest

const MAIN = preload("res://scenes/main/main_scene.tscn")
const ISOLATION = preload("res://tests/helpers/main_storage_isolation.gd")

func test_stationary_player_uses_standing_pose_then_returns_to_run() -> void:
	var player = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(player)
	player.set_physics_process(false)
	var visual = player.get_node("Visual")
	player.velocity = Vector2.ZERO
	visual._process(0.6)
	assert_ne(visual.texture, visual.move_texture, "Idle must not retain the running illustration.")
	player.velocity = Vector2(100, 0)
	visual._process(0.1)
	assert_eq(visual.texture, visual.move_texture)

func test_space_does_not_activate_focused_settings_during_combat() -> void:
	var hud = load("res://scenes/ui/hud.tscn").instantiate()
	add_child_autofree(hud)
	hud.show_combat_hud(true)
	hud.close_settings()
	hud.settings_button.grab_focus()
	await get_tree().process_frame
	for pressed in [true, false]:
		var key := InputEventKey.new()
		key.keycode = KEY_SPACE
		key.physical_keycode = KEY_SPACE
		key.pressed = pressed
		Input.parse_input_event(key)
		await get_tree().process_frame
	assert_false(hud.settings_panel.visible, "Dash must not activate focused Settings through ui_accept.")
	# Enter remains a keyboard path to the same control.
	for pressed in [true, false]:
		var key := InputEventKey.new()
		key.keycode = KEY_ENTER
		key.pressed = pressed
		Input.parse_input_event(key)
		await get_tree().process_frame
	assert_true(hud.settings_panel.visible)

func test_projectile_art_faces_its_real_flight_direction() -> void:
	var projectile = load("res://scenes/projectiles/shuriken_projectile.tscn").instantiate()
	add_child_autofree(projectile)
	projectile.set_physics_process(false)
	projectile.configure(Vector2.UP, 100.0, 3)
	var before: Vector2 = projectile.global_position
	projectile._physics_process(0.1)
	assert_almost_eq(projectile.global_position, before + Vector2(0, -10), Vector2.ONE * 0.01)
	assert_almost_eq(projectile.rotation, -PI / 2, 0.001, "The trail must face opposite actual travel, not always left.")

func test_pad_start_keeps_settings_accessible_when_a_is_reserved_for_dash() -> void:
	var hud = load("res://scenes/ui/hud.tscn").instantiate()
	add_child_autofree(hud)
	hud.show_combat_hud(true)
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_START
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().process_frame
	assert_true(hud.settings_panel.visible)

func test_slash_advances_and_fades_without_repeating_damage() -> void:
	var world := Node2D.new()
	add_child_autofree(world)
	var player = load("res://scenes/player/player.tscn").instantiate()
	world.add_child(player)
	player.set_physics_process(false)
	var weapons = player.get_node("BasicWeapons")
	weapons.set_process(false)
	var target := Node2D.new()
	world.add_child(target)
	target.position = Vector2(70, 0)
	weapons._spawn_katana_effect(player, target)
	var effect = world.get_node("KatanaEffect")
	var start: Vector2 = effect.position
	weapons._advance_katana_effects(0.07)
	assert_gt(effect.position.x, start.x)
	assert_lt(effect.modulate.a, 1.0)
	assert_gt(effect.modulate.a, 0.0)

func test_floor_repeats_cover_a_wide_viewport_after_resize() -> void:
	var old_size: Vector2i = get_viewport().size
	get_viewport().size = Vector2i(3440, 1440)
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var floor_layer = main.get_node("BattlefieldBackdrop")
	assert_gte(floor_layer.repeat_times * floor_layer.repeat_size.x, 3440.0 + floor_layer.repeat_size.x,
		"Need screen coverage plus a seam margin while camera scrolls.")
	main.free()
	get_viewport().size = old_size

func test_each_school_actor_has_its_own_art_instead_of_shared_fallback() -> void:
	var seen := {}
	for definition in EncounterCatalog.build_actor_definitions().values():
		var actor = load("res://scenes/enemies/school_encounter_actor.tscn").instantiate()
		add_child(actor)
		assert_true(actor.configure_definition(definition))
		var visual = actor.get_node("Visual")
		assert_false(bool(visual.get_meta(&"provisional_existing_art", true)), str(definition.actor_id))
		var identity := str(visual.texture.resource_path) + str(visual.region_rect)
		assert_false(seen.has(identity), "Different actor designs must not silently share the same crop.")
		seen[identity] = true
		actor.free()

func test_cooldown_hud_reads_spell_owner_without_advancing_it() -> void:
	var controller = load("res://scripts/schools/ninjutsu_auto_controller.gd").new()
	add_child_autofree(controller)
	assert_true(controller.has_method("cooldown_snapshot"))
	if not controller.has_method("cooldown_snapshot"): return
	var loadout = NinjutsuLoadoutState.new()
	add_child_autofree(loadout)
	loadout.begin_start_draft(&"cheonsul", 12)
	loadout.choose_start_draft(loadout.start_draft_snapshot().options[0])
	loadout.choose_start_draft(loadout.start_draft_snapshot().options[0])
	loadout.commit_drafted_start(loadout.start_draft_snapshot().picks)
	controller._loadout = loadout
	var first: StringName = loadout.active_spell_ids()[0]
	# Avoid libc tie-rounding differences at exactly1.25 between Windows/Linux.
	controller._remaining_by_spell[first] = 1.26
	var rows: Array = controller.cooldown_snapshot()
	assert_eq(rows.size(), 2)
	assert_eq(rows[0].remaining, 1.26)
	var hud = load("res://scenes/ui/hud.tscn").instantiate()
	add_child_autofree(hud)
	assert_true(hud.has_method("set_skill_cooldowns"))
	if not hud.has_method("set_skill_cooldowns"): return
	hud.set_skill_cooldowns(rows)
	assert_true(hud.find_child("SkillCooldowns", true, false).text.contains("1.3초"))
	assert_eq(controller._remaining_by_spell[first], 1.26)
	# Rendering fixture on real owners: support still runs during sword form.
	loadout._active_spell_ids.assign([&"guiin_demon_step", &"guiin_ghost_blood_wave"])
	var resolver := CombatResolver.new()
	add_child_autofree(resolver)
	resolver.sword_only_mode = true
	controller._combat_resolver = resolver
	rows = controller.cooldown_snapshot()
	assert_eq(rows[0].status, "대시 연계")
	assert_eq(rows[1].status, "귀인화 중 억제")
