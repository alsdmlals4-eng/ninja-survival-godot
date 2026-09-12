extends GutTest

const SCENE := "res://scenes/ui/start_loadout_ui.tscn"


func test_real_buttons_choose_place_and_confirm_without_starting_a_legacy_run() -> void:
	assert_true(ResourceLoader.exists(SCENE), "Start preparation must have a runnable UI consumer.")
	if not ResourceLoader.exists(SCENE):
		return
	var ui = load(SCENE).instantiate()
	add_child_autofree(ui)
	await get_tree().process_frame
	watch_signals(ui)
	ui.school_buttons[1].pressed.emit()
	assert_eq(ui.session.snapshot().draft.school_id, &"cheonsul")
	assert_true(ui.confirm_button.disabled)
	ui.option_buttons[0].pressed.emit()
	assert_true(ui.confirm_button.disabled)
	ui.option_buttons[1].pressed.emit()
	assert_false(ui.confirm_button.disabled)
	assert_eq(ui.session.snapshot().backpack.items.size(), 2)
	ui.cell_buttons[0].pressed.emit()
	ui.cell_buttons[2].pressed.emit()
	assert_eq(ui.session.snapshot().backpack.items[0].origin_x, 3)
	ui.confirm_button.pressed.emit()
	assert_signal_emit_count(ui, "prepared", 1)
	assert_true(ui.confirm_button.disabled)
	assert_true(ui.status_label.text.contains("준비 확정"))
	ui.confirm_button.pressed.emit()
	assert_signal_emit_count(ui, "prepared", 1)
	ui.school_buttons[0].pressed.emit()
	assert_eq(ui.session.snapshot().draft.school_id, &"cheonsul", "Confirmed selection is frozen until explicitly restarted.")


func test_keyboard_can_pick_both_books_and_confirm() -> void:
	var ui = load(SCENE).instantiate()
	add_child_autofree(ui)
	await get_tree().process_frame
	await _keyboard_press(ui.option_buttons[0])
	assert_eq(ui.session.snapshot().draft.picks.size(), 1)
	await _keyboard_press(ui.option_buttons[1])
	assert_eq(ui.session.snapshot().draft.picks.size(), 2)
	await _keyboard_press(ui.confirm_button)
	assert_false(ui.session.committed_snapshot().is_empty())


func _keyboard_press(button: Button) -> void:
	button.grab_focus()
	for pressed in [true, false]:
		var key := InputEventKey.new()
		key.keycode = KEY_SPACE
		key.pressed = pressed
		Input.parse_input_event(key)
		await get_tree().process_frame
