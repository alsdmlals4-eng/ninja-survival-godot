extends GutTest

const MAIN = preload("res://scenes/main/main_scene.tscn")
const ISOLATION = preload("res://tests/helpers/main_storage_isolation.gd")

func test_each_origin_starts_its_own_stage_without_second_picker() -> void:
	for index in range(4):
		var main = MAIN.instantiate()
		ISOLATION.prepare(main)
		main.selected_rules_enabled = true
		add_child(main)
		main.selected_run.begin_new_game()
		var ui = main.selected_run.start_ui
		ui.school_buttons[index].pressed.emit()
		assert_false(ui.option_buttons[0].tooltip_text.is_empty(), "Draft must explain effect before choosing.")
		ui.option_buttons[0].pressed.emit()
		ui.option_buttons[0].pressed.emit()
		ui.confirm_button.pressed.emit()
		await get_tree().process_frame
		await get_tree().process_frame
		assert_false(main.school_selection.visible)
		assert_true(main.selected_run.is_active(), "Confirmation must save/start, without second school selection.")
		if main.selected_run.is_active():
			assert_eq(main.school_circuit.route_state.active_school_id(), [&"bongma", &"cheonsul", &"guiin", &"heukyeong"][index])
		main._set_combat_enabled(false)
		main.free()

func test_hud_displays_actual_health_and_hoverable_controls() -> void:
	var hud = load("res://scenes/ui/hud.tscn").instantiate()
	add_child_autofree(hud)
	hud.show_combat_hud(true)
	hud.set_health(37, 120)
	var health = hud.find_child("HealthGauge", true, false)
	assert_not_null(health)
	if health != null:
		assert_eq(health.value, 37.0)
		assert_eq(health.max_value, 120.0)
		assert_true(health.get_node("Value").text.contains("37 / 120"))
	assert_ne(hud.dash_label.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_true(hud.dash_label.tooltip_text.contains("Space"))
	assert_true(hud.has_method("set_ultimate_resource"))
	if hud.has_method("set_ultimate_resource"):
		hud.set_ultimate_resource("SPIRIT", 45.5, 120.0)
		assert_eq(hud.find_child("UltimateGauge", true, false).value, 45.5)

func test_spawn_bar_reads_final_configured_enemy_health_before_first_hit() -> void:
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	main.selected_rules_enabled = true
	add_child_autofree(main)
	main.selected_run.begin_new_game()
	var ui = main.selected_run.start_ui
	ui.option_buttons[0].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	ui.confirm_button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	main.wave_spawner.set_process(false)
	main.wave_spawner._process(0.81)
	var checked := 0
	for enemy in main.get_children():
		if not enemy.is_in_group("enemies"): continue
		var bar = enemy.get_node("EnemyHpBar")
		assert_eq(bar.max_value, float(enemy.max_health))
		assert_eq(bar.value, float(enemy.health))
		assert_eq(enemy.health, enemy.max_health, "A fresh unhit Core must not spawn partially injured.")
		checked += 1
	assert_gte(checked, 10)

func test_each_enemy_has_persistent_red_hp_below_feet() -> void:
	var presenter = load("res://scripts/ui/recent_hit_hp_presenter.gd").new()
	presenter.persistent_bars = true
	add_child_autofree(presenter)
	for amount in [20, 30]:
		var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
		enemy.max_health = amount
		add_child_autofree(enemy)
		presenter.observe_enemy(enemy)
		var bar = enemy.get_node_or_null("EnemyHpBar")
		assert_not_null(bar, "Every observed enemy needs its own bar before a hit.")
		if bar == null: continue
		assert_gt(bar.position.y, 0.0)
		await get_tree().process_frame
		assert_lte(bar.size.y, 8.0, "Actual layout must stay a thin bar, not the default theme's font-height block.")
		enemy.take_damage(3)
		assert_eq(bar.value, float(amount - 3))
		var fill = bar.get_theme_stylebox("fill")
		assert_gt(fill.bg_color.r, fill.bg_color.g)

func test_hover_panel_is_opaque_enough_over_crowded_battle() -> void:
	var hud = load("res://scenes/ui/hud.tscn").instantiate()
	add_child_autofree(hud)
	assert_not_null(hud.dash_label.theme)
	if hud.dash_label.theme != null:
		assert_gt(hud.dash_label.theme.get_stylebox("panel", "TooltipPanel").bg_color.a, 0.95)

func test_large_boss_hp_bar_stays_below_its_art_not_at_normal_enemy_height() -> void:
	var presenter = load("res://scripts/ui/recent_hit_hp_presenter.gd").new()
	presenter.persistent_bars = true
	add_child_autofree(presenter)
	var boss = load("res://scenes/enemies/school_encounter_actor.tscn").instantiate()
	boss.configure_definition(load("res://scripts/data/encounter_catalog.gd").actor_definition_for(&"hundred_demon_array_master"))
	add_child_autofree(boss)
	boss.set_physics_process(false)
	presenter.observe_enemy(boss)
	var visual: Sprite2D = boss.get_node("Visual")
	var visible_bounds: Rect2 = visual.transform * visual.get_rect()
	assert_gt(boss.get_node("EnemyHpBar").position.y, visible_bounds.end.y, "The large Boss bar must not cross its robe/feet.")

func test_idle_motion_changes_only_visual_and_resets_on_movement() -> void:
	var player = load("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(player)
	player.set_physics_process(false)
	var visual = player.get_node("Visual")
	var scale_before: Vector2 = visual.scale
	visual._process(0.5)
	assert_ne(visual.scale, scale_before, "Standing player needs visible breathing.")
	assert_eq(player.position, Vector2.ZERO)
	player.velocity = Vector2(240, 0)
	visual._process(0.1)
	assert_eq(visual.scale, scale_before, "Movement must restore neutral transform, not accumulate scaling.")

func test_final_boss_bar_follows_larger_and_smaller_theme_changes_without_healing() -> void:
	var presenter = load("res://scripts/ui/recent_hit_hp_presenter.gd").new()
	presenter.persistent_bars = true
	add_child_autofree(presenter)
	var boss = load("res://scenes/enemies/final_calamity.tscn").instantiate()
	assert_true(boss.configure_clear_order([&"cheonsul", &"bongma", &"guiin", &"heukyeong"]))
	add_child_autofree(boss)
	boss.set_physics_process(false)
	presenter.observe_enemy(boss)
	boss.take_damage(451)
	boss._physics_process(0.0)
	assert_eq(boss.theme_school_id(), &"bongma")
	var visual: Sprite2D = boss.get_node("Visual")
	var bounds: Rect2 = visual.transform * visual.get_rect()
	var bar = boss.get_node("EnemyHpBar")
	assert_gt(bar.position.y, bounds.end.y, "Theme transition must not retain the small-form bar height.")
	assert_eq(boss.health, 1349)
	var large_height: float = bar.position.y
	boss.take_damage(450)
	boss._physics_process(0.0)
	assert_eq(boss.theme_school_id(), &"guiin")
	assert_lt(bar.position.y, large_height, "Returning to small art must not leave a detached low bar.")
	assert_eq(bar.value, 899.0)

func test_draft_uses_supplied_inventory_art_but_never_loads_unapproved_art_itself() -> void:
	var ui = load("res://scripts/ui/start_loadout_ui.gd").new()
	assert_true("inventory_atlas" in ui)
	if not "inventory_atlas" in ui:
		ui.free()
		return
	var atlas := GradientTexture2D.new()
	atlas.width = 1254
	atlas.height = 1254
	ui.inventory_atlas = atlas
	add_child_autofree(ui)
	assert_not_null(ui.option_buttons[0].icon)
	ui.option_buttons[0].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	assert_not_null(ui.cell_buttons[0].icon)
	assert_not_null(ui.find_child("StartingGear0", true, false).texture)

func test_existing_cross_school_save_keeps_its_battlefield_on_continue() -> void:
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	main.selected_rules_enabled = true
	add_child_autofree(main)
	# Historical schema2 producer remains accepted by the storage domain.
	var start = load("res://scripts/core/start_loadout_session.gd").new()
	add_child_autofree(start)
	assert_true(start.begin(&"guiin", 42))
	for unused in range(2): assert_true(start.choose(start.snapshot().draft.options[0]))
	assert_true(start.confirm())
	var result: Dictionary = main.run_settlement_ledger.start_selected_run(main.selected_run.store,
		start.committed_snapshot(), &"heukyeong", "historical:crossschool", 0, 100)
	assert_true(result.ok)
	main.selected_run.continue_run()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_eq(main.school_circuit.route_state.active_school_id(), &"heukyeong")
	assert_eq(main.school_host.selected_school_id, &"guiin")
