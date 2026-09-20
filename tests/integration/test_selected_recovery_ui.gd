extends "res://tests/support/selected_profile_fixture.gd"

const VIEW_PATH := "res://scripts/ui/selected_profile_recovery_ui.gd"

func test_no_valid_live_candidate_explains_preserved_archive_without_publishing() -> void:
	var fixture := _fixture()
	var view = add_child_autofree(load(VIEW_PATH).new())
	var inventory: Dictionary = fixture.store.inspect_profile_recovery()
	for item in inventory.candidates: item.valid = false
	inventory.publication_incomplete = true
	view.show_inventory(inventory)
	watch_signals(view)
	assert_true(view.confirm_button.disabled)
	assert_true(view.status_label.text.contains(ProjectSettings.globalize_path(inventory.recovery_archive_root)))
	assert_true(view.status_label.text.contains("게임을 종료"))
	assert_true(view.status_label.text.contains("삭제하지"))
	view.confirm_button.pressed.emit()
	assert_signal_not_emitted(view, "recovery_confirmed")
	await get_tree().process_frame

func test_recovery_is_explicit_and_cancel_preserves_every_source() -> void:
	var fixture := _fixture()
	assert_true(ResourceLoader.exists(VIEW_PATH))
	if not ResourceLoader.exists(VIEW_PATH): return
	# Only isolated fixture sources, never user profiles.
	var bytes := FileAccess.get_file_as_bytes(fixture.path)
	var previous := FileAccess.open(fixture.path + ".previous", FileAccess.WRITE)
	previous.store_buffer(bytes)
	previous.close()
	var view = add_child_autofree(load(VIEW_PATH).new())
	var inventory: Dictionary = fixture.store.inspect_profile_recovery()
	view.show_inventory(inventory)
	watch_signals(view)
	assert_true(view.confirm_button.disabled)
	view.choice_buttons[1].pressed.emit()
	assert_false(view.confirm_button.disabled)
	assert_signal_not_emitted(view, "recovery_confirmed")
	view.cancel_button.pressed.emit()
	assert_false(view.visible)
	assert_eq(FileAccess.get_file_as_bytes(fixture.path), bytes)
	assert_eq(FileAccess.get_file_as_bytes(fixture.path + ".previous"), bytes)
	view.show_inventory(inventory)
	view.choice_buttons[1].pressed.emit()
	view.confirm_button.pressed.emit()
	assert_signal_emitted_with_parameters(view, "recovery_confirmed", ["previous", inventory])
	assert_eq(FileAccess.get_file_as_bytes(fixture.path), bytes, "UI emits intent only")
	await get_tree().process_frame
	await get_tree().process_frame

func test_title_recovery_rechecks_sources_and_restores_only_after_confirmation() -> void:
	var fixture := _fixture()
	var main = load("res://scenes/main/main_scene.tscn").instantiate()
	load("res://tests/helpers/main_storage_isolation.gd").prepare(main)
	main.selected_rules_enabled = true
	main.profile_storage_path = fixture.path
	var bytes := FileAccess.get_file_as_bytes(fixture.path)
	var previous := FileAccess.open(fixture.path + ".previous", FileAccess.WRITE)
	previous.store_buffer(bytes)
	previous.close()
	var corrupt := FileAccess.open(fixture.path, FileAccess.WRITE)
	corrupt.store_string("broken fixture")
	corrupt.close()
	add_child_autofree(main)
	assert_true(main.title_screen.continue_button.disabled)
	assert_true(main.title_screen.recovery_button.visible)
	main.title_screen.recovery_button.pressed.emit()
	var view = main.selected_run.recovery_ui
	assert_true(view.choice_buttons[0].disabled)
	view.choice_buttons[1].pressed.emit()
	assert_eq(FileAccess.get_file_as_string(fixture.path), "broken fixture")
	view.confirm_button.pressed.emit()
	assert_eq(FileAccess.get_file_as_bytes(fixture.path), bytes)
	assert_false(main.title_screen.continue_button.disabled)
	assert_false(main.title_screen.recovery_button.visible)
	assert_true(DirAccess.dir_exists_absolute(fixture.path + ".recovery"))
	await get_tree().process_frame
