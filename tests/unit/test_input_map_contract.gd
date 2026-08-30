extends GutTest


func test_dec037_movement_and_dash_actions_are_declared() -> void:
	for action_name in [&"move_left", &"move_right", &"move_up", &"move_down", &"dash"]:
		assert_true(InputMap.has_action(action_name), "%s must be a named input action" % action_name)


func test_movement_actions_keep_keyboard_left_stick_and_dpad_families() -> void:
	_assert_movement_action(&"move_left", 65, 4194319, 0, -1.0, 13)
	_assert_movement_action(&"move_right", 68, 4194321, 0, 1.0, 14)
	_assert_movement_action(&"move_up", 87, 4194320, 1, -1.0, 11)
	_assert_movement_action(&"move_down", 83, 4194322, 1, 1.0, 12)


func test_dash_has_keyboard_and_gamepad_bindings() -> void:
	var events := InputMap.action_get_events(&"dash")
	assert_true(_has_key(events, 4194325), "dash must support Left Shift")
	assert_true(_has_key(events, 32), "dash must support Space")
	assert_true(_has_joypad_button(events, 0), "dash must support the south face button")


func _assert_movement_action(
	action_name: StringName,
	primary_key: int,
	arrow_key: int,
	stick_axis: int,
	stick_value: float,
	dpad_button: int
) -> void:
	var events := InputMap.action_get_events(action_name)
	assert_true(_has_key(events, primary_key), "%s must support its WASD key" % action_name)
	assert_true(_has_key(events, arrow_key), "%s must support its arrow key" % action_name)
	assert_true(
		_has_joypad_motion(events, stick_axis, stick_value),
		"%s must support the matching left-stick direction" % action_name
	)
	assert_true(_has_joypad_button(events, dpad_button), "%s must support the matching D-pad direction" % action_name)


func _has_key(events: Array[InputEvent], physical_keycode: int) -> bool:
	return events.any(func(event: InputEvent) -> bool:
		return event is InputEventKey and event.physical_keycode == physical_keycode
	)


func _has_joypad_motion(events: Array[InputEvent], axis: int, axis_value: float) -> bool:
	return events.any(func(event: InputEvent) -> bool:
		return event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value)
	)


func _has_joypad_button(events: Array[InputEvent], button_index: int) -> bool:
	return events.any(func(event: InputEvent) -> bool:
		return event is InputEventJoypadButton and event.button_index == button_index
	)
