extends GutTest

const SELECTOR_SCRIPT_PATH := "res://scripts/ui/school_selection_ui.gd"
const SELECTOR_SCENE_PATH := "res://scenes/ui/school_selection_ui.tscn"


func test_selector_scene_has_four_school_buttons() -> void:
	assert_true(ResourceLoader.exists(SELECTOR_SCENE_PATH), "School selector scene must exist")
	if not ResourceLoader.exists(SELECTOR_SCENE_PATH):
		return

	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	assert_not_null(selector.get_node_or_null("Panel/Margin/Choices/BongmaButton"))
	assert_not_null(selector.get_node_or_null("Panel/Margin/Choices/CheonsulButton"))
	assert_not_null(selector.get_node_or_null("Panel/Margin/Choices/GuiinButton"))
	assert_not_null(selector.get_node_or_null("Panel/Margin/Choices/HeukyeongButton"))


func test_cheonsul_help_opens_without_selecting_a_school() -> void:
	assert_true(ResourceLoader.exists(SELECTOR_SCENE_PATH), "School selector scene must exist")
	if not ResourceLoader.exists(SELECTOR_SCENE_PATH):
		return

	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	var ids: Array[StringName] = []
	selector.school_selected.connect(func(id: StringName): ids.append(id))
	var help_button := selector.get_node_or_null("Panel/Margin/Choices/CheonsulHelpButton") as Button
	assert_not_null(help_button, "Cheonsul must expose a separate help button")
	if help_button == null:
		return

	help_button.pressed.emit()

	var help_dialog := selector.get_node_or_null("HelpDialog") as Control
	assert_not_null(help_dialog, "Selector must own one reusable help dialog")
	if help_dialog == null:
		return
	assert_true(help_dialog.visible)
	assert_eq(selector.get_node("HelpDialog/Margin/Content/TitleLabel").text, "천술류 기능 도움말")
	assert_string_contains(selector.get_node("HelpDialog/Margin/Content/BodyLabel").text, "WET")
	assert_string_contains(selector.get_node("HelpDialog/Margin/Content/BodyLabel").text, "오행폭주")
	assert_eq(ids, [], "Reading help must not commit school selection")
	assert_true(selector.visible)


func test_help_modal_blocks_number_selection_until_cancelled() -> void:
	assert_true(ResourceLoader.exists(SELECTOR_SCENE_PATH), "School selector scene must exist")
	if not ResourceLoader.exists(SELECTOR_SCENE_PATH):
		return

	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	var ids: Array[StringName] = []
	selector.school_selected.connect(func(id: StringName): ids.append(id))
	var help_button := selector.get_node_or_null("Panel/Margin/Choices/HeukyeongHelpButton") as Button
	assert_not_null(help_button, "Heukyeong must expose a separate help button")
	if help_button == null:
		return
	help_button.pressed.emit()

	var select_event := InputEventKey.new()
	select_event.pressed = true
	select_event.keycode = KEY_4
	selector._unhandled_input(select_event)
	assert_eq(ids, [], "Number shortcuts must not select behind the help modal")
	assert_true(selector.get_node("HelpDialog").visible)
	var selection_button := selector.get_node("Panel/Margin/Choices/HeukyeongButton") as Button
	selection_button.pressed.emit()
	assert_eq(ids, [], "Selection buttons must not select behind the help modal")

	var cancel_event := InputEventAction.new()
	cancel_event.action = &"ui_cancel"
	cancel_event.pressed = true
	selector._unhandled_input(cancel_event)
	assert_false(selector.get_node("HelpDialog").visible)

	selector._unhandled_input(select_event)
	assert_eq(ids, [&"heukyeong"])


func test_help_close_button_returns_to_school_selection_without_selecting() -> void:
	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	var ids: Array[StringName] = []
	selector.school_selected.connect(func(id: StringName): ids.append(id))

	var help_button := selector.get_node("Panel/Margin/Choices/BongmaHelpButton") as Button
	help_button.pressed.emit()
	var close_button := selector.get_node("HelpDialog/Margin/Content/CloseButton") as Button
	close_button.pressed.emit()

	assert_false((selector.get_node("HelpDialog") as Control).visible)
	assert_true(selector.visible)
	assert_eq(ids, [], "Closing help must not select its school")
	assert_true(help_button.has_focus(), "Closing help must return keyboard/gamepad focus to its opener")


func test_key_three_selects_guiin_once() -> void:
	assert_true(ResourceLoader.exists(SELECTOR_SCENE_PATH), "School selector scene must exist")
	if not ResourceLoader.exists(SELECTOR_SCENE_PATH):
		return

	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	var ids: Array[StringName] = []
	selector.school_selected.connect(func(id: StringName): ids.append(id))

	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_3
	selector._unhandled_input(event)
	selector._unhandled_input(event)

	assert_eq(ids, [&"guiin"])
	assert_false(selector.visible)


func test_button_click_emits_stable_bongma_id_once() -> void:
	assert_true(ResourceLoader.exists(SELECTOR_SCENE_PATH), "School selector scene must exist")
	if not ResourceLoader.exists(SELECTOR_SCENE_PATH):
		return

	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	var ids: Array[StringName] = []
	selector.school_selected.connect(func(id: StringName): ids.append(id))
	var button: Button = selector.get_node("Panel/Margin/Choices/BongmaButton")
	button.pressed.emit()
	button.pressed.emit()

	assert_eq(ids, [&"bongma"])
	assert_false(selector.visible)


func test_invalid_school_id_is_ignored_without_locking_selector() -> void:
	assert_true(ResourceLoader.exists(SELECTOR_SCENE_PATH), "School selector scene must exist")
	if not ResourceLoader.exists(SELECTOR_SCENE_PATH):
		return

	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	var ids: Array[StringName] = []
	selector.school_selected.connect(func(id: StringName): ids.append(id))

	selector._choose(&"unknown")
	assert_true(selector.visible)
	assert_eq(ids, [])

	selector._choose(&"heukyeong")
	assert_false(selector.visible)
	assert_eq(ids, [&"heukyeong"])


func test_selector_script_exposes_selection_signal() -> void:
	assert_true(ResourceLoader.exists(SELECTOR_SCRIPT_PATH), "School selector script must exist")
	if not ResourceLoader.exists(SELECTOR_SCRIPT_PATH):
		return
	var selector = load(SELECTOR_SCRIPT_PATH).new()
	assert_true(selector.has_signal("school_selected"))
	selector.free()
