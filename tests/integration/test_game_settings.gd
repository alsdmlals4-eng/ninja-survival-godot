extends GutTest

const MAIN = preload("res://scenes/main/main_scene.tscn")
const ISOLATION = preload("res://tests/helpers/main_storage_isolation.gd")
var _original_volume := 1.0

func before_each() -> void:
	_original_volume = AudioServer.get_bus_volume_linear(0)

func after_each() -> void:
	get_tree().paused = false
	for action in [&"dash", &"ultimate", &"ui_accept"]: Input.action_release(action)
	AudioServer.set_bus_volume_linear(0, _original_volume)

func _main():
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	main.selected_rules_enabled = true
	add_child_autofree(main)
	return main

func test_title_settings_commit_reloads_without_creating_a_run_and_cancel_is_read_only() -> void:
	var main = _main()
	var settings = main.get_node_or_null("GameSettings")
	assert_not_null(settings, "Selected title needs actual settings consumers, not fullscreen only.")
	if settings == null: return
	main.title_screen.settings_button.pressed.emit()
	assert_true(settings.ui.visible)
	settings.ui.volume.value = 40
	settings.ui.effects.value = 25
	settings.ui.shake.button_pressed = false
	settings.ui.input_help.button_pressed = false
	settings.ui.apply_button.pressed.emit()
	assert_almost_eq(AudioServer.get_bus_volume_linear(0), 0.4, 0.001)
	assert_false(FileAccess.file_exists(main.profile_storage_path))
	var before := FileAccess.get_file_as_bytes(settings.storage_path)
	settings.ui.volume.value = 90
	settings.ui.close_button.pressed.emit()
	assert_eq(FileAccess.get_file_as_bytes(settings.storage_path), before)
	var second = MAIN.instantiate()
	ISOLATION.prepare(second)
	second.selected_rules_enabled = true
	second.profile_storage_path = main.profile_storage_path
	add_child_autofree(second)
	var restored = second.get_node("GameSettings")
	assert_eq(restored.values.volume, 40)
	assert_eq(restored.values.effects, 25)
	assert_false(restored.values.input_help)
	assert_false(second.hud.ultimate_button.text.contains("[E/Y]"))
	await get_tree().process_frame

func test_inactive_second_main_does_not_take_over_host_audio_settings() -> void:
	var main = _main()
	var settings = main.get_node("GameSettings")
	var candidate: Dictionary = settings.values.duplicate(true)
	candidate.volume = 40
	assert_true(settings.commit(candidate).ok)
	var inactive = _main()
	assert_eq(inactive.get_node("GameSettings").values.volume, 100)
	assert_almost_eq(AudioServer.get_bus_volume_linear(0), 0.4, 0.001)

func test_pause_resume_waits_for_menu_keys_without_cancelling_existing_effects() -> void:
	var main = _main()
	main.title_screen.new_game_requested.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.confirm_button.pressed.emit()
	main.school_selection.school_selected.emit(&"bongma")
	await get_tree().process_frame
	await get_tree().process_frame
	var charges: int = main.player.current_dash_charges()
	main.hud.settings_button.pressed.emit()
	assert_true(get_tree().paused)
	var button = main.hud.resume_button.get_parent().get_node("PreferencesButton")
	button.pressed.emit()
	main.get_node("GameSettings").ui.close_button.pressed.emit()
	assert_true(get_tree().paused, "Preferences returns to the paused menu.")
	Input.action_press(&"dash")
	Input.action_press(&"ultimate")
	Input.action_press(&"ui_accept")
	main.hud.resume_button.pressed.emit()
	await get_tree().process_frame
	assert_true(get_tree().paused, "Resume must wait for held menu actions to release.")
	assert_true(main._combat_enabled, "Pause must not cancel combat effects or add entry protection.")
	for action in [&"dash", &"ultimate", &"ui_accept"]: Input.action_release(action)
	await get_tree().create_timer(0.08, true).timeout
	assert_false(get_tree().paused)
	assert_eq(main.player.current_dash_charges(), charges)

func test_settings_failed_write_and_invalid_values_do_not_publish_or_change_profile() -> void:
	var main = _main()
	var settings = main.get_node_or_null("GameSettings")
	assert_not_null(settings)
	if settings == null: return
	var initial: Dictionary = settings.values.duplicate(true)
	var invalid: Dictionary = initial.duplicate(true)
	invalid.effects = -1
	assert_false(settings.commit(invalid).ok)
	assert_eq(settings.values, initial)
	settings.storage_path = "user://missing_settings_%d/sub/settings.cfg" % Time.get_ticks_usec()
	var changed: Dictionary = initial.duplicate(true)
	changed.volume = 35
	assert_false(settings.commit(changed).ok)
	assert_eq(settings.values, initial)
	assert_false(FileAccess.file_exists(main.profile_storage_path))
	settings.open(main.title_screen.settings_button)
	settings.ui.volume.value = 35
	settings.ui.apply_button.pressed.emit()
	assert_true(settings.ui.status.text.contains("저장하지 못"))
	assert_true(settings.ui.visible)

func test_effect_density_never_changes_enemy_telegraphs_or_damage_and_shake_stops() -> void:
	var main = _main()
	var settings = main.get_node_or_null("GameSettings")
	assert_not_null(settings)
	if settings == null: return
	var values: Dictionary = settings.values.duplicate(true)
	values.effects = 20
	values.shake = true
	assert_true(settings.commit(values).ok)
	var target := Node2D.new()
	main.add_child(target)
	target.position = Vector2(40, 0)
	main.basic_weapons._spawn_katana_effect(main.player, target)
	var effect = main.basic_weapons._active_katana_effects.back().node
	assert_almost_eq(effect.self_modulate.a, 0.2, 0.001)
	var warning := Polygon2D.new()
	main.add_child(warning)
	assert_eq(warning.self_modulate.a, 1.0, "Enemy warning is outside cosmetic density group.")
	var hp: int = main.player.health
	settings.on_damage_resolved(10, 10, 0, false)
	settings.advance_shake(0.02)
	assert_ne(main.player.get_node("Camera2D").offset, Vector2.ZERO)
	assert_eq(main.player.health, hp, "Presentation never causes damage.")
	values.shake = false
	assert_true(settings.commit(values).ok)
	assert_eq(main.player.get_node("Camera2D").offset, Vector2.ZERO)
	settings.advance_shake(1.0)
	assert_eq(main.player.get_node("Camera2D").offset, Vector2.ZERO)
