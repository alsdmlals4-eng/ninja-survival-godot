extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")
var _viewport_before := Vector2i.ZERO


func before_each() -> void:
	_viewport_before = get_tree().root.size
	get_tree().root.size = Vector2i(1152, 648)


func after_each() -> void:
	get_tree().paused = false
	get_tree().root.size = _viewport_before
	Input.action_release(&"dash")
	for path in ["user://gut_manual_ultimate_wallet.json", "user://gut_manual_ultimate_resume.json"]:
		for suffix in ["", ".tmp", ".previous"]:
			if FileAccess.file_exists(path + suffix):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(path + suffix))


func test_persisted_action_accepts_all_input_devices() -> void:
	var config := ConfigFile.new()
	assert_eq(config.load("res://project.godot"), OK)
	for event in config.get_value("input", "ultimate")["events"]:
		assert_eq(event.device, -1, "The shipped action must not be tied to a test device")


func _main(school: StringName = &"guiin"):
	var main = MAIN_SCENE.instantiate()
	main.wallet_storage_path = "user://gut_manual_ultimate_wallet.json"
	main.resume_storage_path = "user://gut_manual_ultimate_resume.json"
	preload("res://tests/helpers/main_storage_isolation.gd").prepare(main)
	add_child_autofree(main)
	main.title_screen.hide()
	main.school_selection.show_starting_school_selection()
	main.school_selection._choose(school)
	main.player.get_node("Camera2D").force_update_scroll()
	return main


func _charge_guiin(main) -> void:
	var target = load("res://scripts/enemies/enemy_chaser.gd").new()
	target.max_health = 1000
	main.add_child(target)
	target.global_position = main.player.global_position + Vector2(40, 0)
	main.school_host.active_runtime._set_gwihyeol(100.0, true)


func _key(echo: bool = false) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = KEY_E
	event.pressed = true
	event.echo = echo
	return event


func test_keyboard_ultimate_consumes_ready_resource_and_starts_effect() -> void:
	var main = _main()
	_charge_guiin(main)
	main._unhandled_input(_key())
	assert_eq(main.school_host.active_runtime.gwihyeol, 0.0)
	assert_gt(main.school_host.active_runtime.ultimate_time_remaining, 0.0)
	assert_ne(main.basic_weapons.process_mode, Node.PROCESS_MODE_DISABLED)


func test_pad_ultimate_has_the_same_effect_without_a_manual_attack_mode() -> void:
	var main = _main()
	_charge_guiin(main)
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_Y
	event.pressed = true
	main._unhandled_input(event)
	assert_eq(main.school_host.active_runtime.gwihyeol, 0.0)
	assert_gt(main.school_host.active_runtime.ultimate_time_remaining, 0.0)


func test_top_button_renders_readiness_and_activates_existing_runtime() -> void:
	var main = _main()
	_charge_guiin(main)
	var button := main.hud.get_node_or_null("CombatTopBar/Row/UltimateButton") as Button
	assert_not_null(button, "The one manual ultimate must have a visible combat input")
	if button == null:
		return
	assert_true(button.visible)
	assert_string_contains(button.text, "준비")
	button.pressed.emit()
	assert_eq(main.school_host.active_runtime.gwihyeol, 0.0)
	assert_string_contains(button.text, "발동")


func test_echo_does_not_spend_a_ready_ultimate() -> void:
	var main = _main()
	_charge_guiin(main)
	main._unhandled_input(_key(true))
	assert_eq(main.school_host.active_runtime.gwihyeol, 100.0)
	assert_eq(main.school_host.active_runtime.ultimate_time_remaining, 0.0)


func test_open_tradition_help_blocks_but_closed_canvas_does_not() -> void:
	var main = _main()
	_charge_guiin(main)
	main.school_selection.open_runtime_school_help(&"guiin", main.hud.settings_button)
	main._unhandled_input(_key())
	assert_eq(main.school_host.active_runtime.gwihyeol, 100.0)
	main.school_selection.dismiss_school_help()
	main._unhandled_input(_key())
	assert_eq(main.school_host.active_runtime.gwihyeol, 0.0)


func test_paused_noncombat_and_dead_states_do_not_spend() -> void:
	var main = _main()
	_charge_guiin(main)
	main.hud.open_settings()
	main._unhandled_input(_key())
	assert_eq(main.school_host.active_runtime.gwihyeol, 100.0)
	main.hud.close_settings()
	get_tree().paused = false
	main._set_combat_enabled(false)
	main._unhandled_input(_key())
	assert_eq(main.school_host.active_runtime.gwihyeol, 100.0)
	main._set_combat_enabled(true)
	main.player.health = 0
	main._unhandled_input(_key())
	assert_eq(main.school_host.active_runtime.gwihyeol, 100.0)


func test_charging_rejection_has_feedback_and_preserves_resource() -> void:
	var main = _main()
	main.school_host.active_runtime._set_gwihyeol(20.0, true)
	main._unhandled_input(_key())
	assert_eq(main.school_host.active_runtime.gwihyeol, 20.0)
	var button := main.hud.get_node_or_null("CombatTopBar/Row/UltimateButton") as Button
	assert_not_null(button)
	if button != null:
		assert_string_contains(button.text, "충전")


func test_cheonsul_no_target_rejection_is_visible_and_preserves_charge() -> void:
	var main = _main(&"cheonsul")
	main.school_host.active_runtime.reaction_count = 3.0
	main._unhandled_input(_key())
	assert_eq(main.school_host.active_runtime.reaction_count, 3.0)
	var button := main.hud.get_node_or_null("CombatTopBar/Row/UltimateButton") as Button
	assert_not_null(button)
	if button != null:
		assert_string_contains(button.text, "대상 없음")


func test_cheonsul_success_damages_status_target_and_consumes_once() -> void:
	var main = _main(&"cheonsul")
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	enemy.max_health = 1000
	main.add_child(enemy)
	var runtime = main.school_host.active_runtime
	runtime.apply_flame_cast(enemy.global_position)
	runtime.reaction_count = 3.0
	var health_before: int = enemy.health
	main._unhandled_input(_key())
	assert_lt(enemy.health, health_before)
	assert_eq(runtime.reaction_count, 0.0)
	var health_after: int = enemy.health
	main._unhandled_input(_key())
	assert_eq(enemy.health, health_after, "A second request cannot duplicate a consumed ultimate")


func test_clicked_ultimate_does_not_capture_space_dash_focus() -> void:
	var main = _main()
	_charge_guiin(main)
	var button := main.hud.get_node_or_null("CombatTopBar/Row/UltimateButton") as Button
	assert_not_null(button)
	if button == null:
		return
	await get_tree().process_frame
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = button.get_global_rect().get_center()
	click.pressed = true
	main.get_viewport().push_input(click, true)
	click = click.duplicate()
	click.pressed = false
	main.get_viewport().push_input(click, true)
	await get_tree().process_frame
	assert_ne(main.get_viewport().gui_get_focus_owner(), button,
		"Clicking ultimate must not make the next Space dash activate it through ui_accept")


func test_cheonsul_button_to_breath_to_dash_cancels_pending_ticks() -> void:
	var main = _main(&"cheonsul")
	var runtime = main.school_host.active_runtime
	runtime._cast_remaining = 999.0
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	enemy.max_health = 1000
	main.add_child(enemy)
	enemy.global_position = main.player.global_position
	runtime.reaction_count = 3.0
	main.hud.get_node("CombatTopBar/Row/UltimateButton").pressed.emit()
	assert_eq(enemy.health, 992)
	assert_eq(runtime.reaction_count, 0.0)
	main.player.set_movement_intent(Vector2.RIGHT)
	assert_true(main.player.request_dash())
	runtime._process(1.5)
	assert_eq(enemy.health, 992, "Host/button and player dash share the runtime cancellation contract")


func test_button_intent_is_blocked_during_pause_and_noncombat() -> void:
	var main = _main()
	_charge_guiin(main)
	var button := main.hud.get_node("CombatTopBar/Row/UltimateButton") as Button
	main.hud.open_settings()
	button.pressed.emit()
	assert_eq(main.school_host.active_runtime.gwihyeol, 100.0)
	main.hud.close_settings()
	get_tree().paused = false
	main._set_combat_enabled(false)
	button.pressed.emit()
	assert_eq(main.school_host.active_runtime.gwihyeol, 100.0)


func test_feedback_returns_to_latest_readiness_after_expiry() -> void:
	var main = _main()
	_charge_guiin(main)
	main._unhandled_input(_key())
	main.hud._process(2.0)
	assert_string_contains(main.hud.ultimate_button.text, "충전 중")


func test_heukyeong_main_button_executes_without_marks_and_blocks_preparation() -> void:
	var main = _main(&"heukyeong")
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	enemy.max_health = 1000
	main.add_child(enemy)
	enemy.global_position = main.player.global_position + Vector2(100, 0)
	var runtime = main.school_host.active_runtime
	runtime.execution_charge = 3.0
	main._set_combat_enabled(false)
	main.hud.ultimate_button.pressed.emit()
	assert_eq(enemy.health, 1000)
	assert_eq(runtime.execution_charge, 3.0)
	main._set_combat_enabled(true)
	main.hud.ultimate_button.pressed.emit()
	assert_eq(enemy.health, 974)
	assert_eq(runtime.execution_charge, 0.0)
	main._unhandled_input(_key())
	assert_eq(enemy.health, 974)


func test_cheonsul_preparation_cancels_breath_without_resuming_pending_hits() -> void:
	var main = _main(&"cheonsul")
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	enemy.max_health = 1000
	main.add_child(enemy)
	enemy.global_position = main.player.global_position + Vector2(40, 0)
	var runtime = main.school_host.active_runtime
	runtime._cast_remaining = 999.0
	runtime.reaction_count = 3.0
	main.hud.ultimate_button.pressed.emit()
	assert_eq(enemy.health, 992)
	main._set_combat_enabled(false)
	assert_eq(runtime._breath_remaining, 0.0)
	assert_false(runtime._breath_visual.visible)
	assert_eq(runtime.reaction_count, 0.0)
	main._set_combat_enabled(true)
	runtime._process(0.5)
	assert_eq(enemy.health, 992)
	assert_eq(runtime.reaction_count, 0.0625)


func test_bongma_button_spawns_two_dedicated_familiars_and_preparation_cancels_without_refund() -> void:
	var main = _main(&"bongma")
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	enemy.max_health = 1000
	main.add_child(enemy)
	enemy.global_position = main.player.global_position + Vector2(40, 0)
	var runtime = main.school_host.active_runtime
	runtime.spirit = 120.0
	main.hud.ultimate_button.pressed.emit()
	assert_eq(enemy.health, 984)
	assert_eq(runtime.spirit, 20.0)
	assert_true(is_instance_valid(runtime._temporary_familiar))
	assert_true(is_instance_valid(runtime._second_temporary_familiar))
	assert_eq(runtime._base_familiar.damage_kind, &"normal")
	main._set_combat_enabled(false)
	assert_null(runtime._temporary_familiar)
	assert_null(runtime._second_temporary_familiar)
	assert_eq(runtime.spirit, 20.0)
	assert_eq(runtime.ultimate_time_remaining, 0.0)
	main._set_combat_enabled(true)
	main._unhandled_input(_key())
	assert_eq(runtime.spirit, 20.0)
	assert_eq(enemy.health, 984)


func test_guiin_input_switches_to_sword_only_then_restores_on_preparation_entry() -> void:
	var main = _main()
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	enemy.max_health = 1000
	main.add_child(enemy)
	enemy.global_position = main.player.global_position + Vector2(40, 0)
	_charge_guiin(main)
	main.basic_weapons._katana_remaining = 0.27
	main.basic_weapons._shuriken_remaining = 0.42
	main._unhandled_input(_key())
	assert_true(main.combat_resolver.sword_only_mode)
	assert_eq(enemy.health, 980)
	assert_eq(main.school_host.active_runtime.perform_melee_pulse(), 0)
	assert_null(main.basic_weapons.fire_shuriken_once())
	get_tree().paused = true
	main.school_host.active_runtime._process(10.0)
	get_tree().paused = false
	assert_eq(main.school_host.active_runtime.ultimate_time_remaining, 6.0)
	main._set_combat_enabled(false)
	assert_false(main.combat_resolver.sword_only_mode)
	assert_eq(main.basic_weapons.katana_damage, 10.0)
	assert_eq(main.basic_weapons._katana_remaining, 0.27)
	assert_eq(main.basic_weapons._shuriken_remaining, 0.42)
