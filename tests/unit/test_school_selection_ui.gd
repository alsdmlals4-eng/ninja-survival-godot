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


func test_stage_wording_keeps_the_existing_school_selection_id() -> void:
	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	var selected_ids: Array[StringName] = []
	selector.school_selected.connect(func(school_id: StringName) -> void: selected_ids.append(school_id))

	assert_eq((selector.get_node("Panel/Margin/Choices/Title") as Label).text, "스테이지 선택")
	assert_string_contains(
		(selector.get_node("Panel/Margin/Choices/CheonsulButton") as Button).text,
		"스테이지 · 천술류 전장",
	)
	(selector.get_node("Panel/Margin/Choices/CheonsulButton") as Button).pressed.emit()

	assert_eq(selected_ids, [&"cheonsul"], "Public Stage copy must not rename the stable school ID.")


func test_selection_has_no_school_help_buttons() -> void:
	assert_true(ResourceLoader.exists(SELECTOR_SCENE_PATH), "School selector scene must exist")
	if not ResourceLoader.exists(SELECTOR_SCENE_PATH):
		return

	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	for node_name in ["BongmaHelpButton", "CheonsulHelpButton", "GuiinHelpButton", "HeukyeongHelpButton"]:
		assert_null(selector.get_node_or_null("Panel/Margin/Choices/%s" % node_name), "Selection must not expose %s" % node_name)


func test_selected_school_help_reopens_during_play_and_returns_to_hud_opener() -> void:
	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	var ids: Array[StringName] = []
	selector.school_selected.connect(func(id: StringName): ids.append(id))
	var runtime_opener := Button.new()
	runtime_opener.text = "천술류 기능 도움말"
	selector.add_child(runtime_opener)

	selector._choose(&"cheonsul")
	selector.open_runtime_school_help(&"cheonsul", runtime_opener)

	assert_eq(ids, [&"cheonsul"], "Runtime help must not emit a second school selection")
	assert_true(selector.visible, "The dialog owner must remain available after school selection")
	assert_false((selector.get_node("Panel") as Control).visible, "Selection choices must stay hidden during play")
	assert_true((selector.get_node("HelpDialog") as Control).visible)
	assert_eq(selector.get_node("HelpDialog/Margin/Content/TitleLabel").text, "천술류 기능 도움말")
	assert_string_contains(selector.get_node("HelpDialog/Margin/Content/BodyLabel").text, "WET")

	var cancel_event := InputEventAction.new()
	cancel_event.action = &"ui_cancel"
	cancel_event.pressed = true
	selector._unhandled_input(cancel_event)

	assert_false((selector.get_node("HelpDialog") as Control).visible)
	assert_true(runtime_opener.has_focus(), "Closing runtime help must return focus to the HUD opener")
	assert_eq(ids, [&"cheonsul"], "Closing runtime help must not change the school")


func test_runtime_help_dialog_stays_interactive_while_settings_pause_is_active() -> void:
	var selector = load(SELECTOR_SCENE_PATH).instantiate()
	add_child_autofree(selector)
	var opener := Button.new()
	selector.add_child(opener)
	selector._choose(&"cheonsul")
	get_tree().paused = true
	selector.open_runtime_school_help(&"cheonsul", opener)
	var dialog := selector.get_node("HelpDialog") as Control

	assert_eq(dialog.process_mode, Node.PROCESS_MODE_WHEN_PAUSED)
	selector._unhandled_input(_cancel_event())
	assert_false(dialog.visible)
	get_tree().paused = false


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
	assert_true(selector.visible)
	assert_false((selector.get_node("Panel") as Control).visible)


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
	assert_true(selector.visible)
	assert_false((selector.get_node("Panel") as Control).visible)


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
	assert_true(selector.visible)
	assert_false((selector.get_node("Panel") as Control).visible)
	assert_eq(ids, [&"heukyeong"])


func test_selector_script_exposes_selection_signal() -> void:
	assert_true(ResourceLoader.exists(SELECTOR_SCRIPT_PATH), "School selector script must exist")
	if not ResourceLoader.exists(SELECTOR_SCRIPT_PATH):
		return
	var selector = load(SELECTOR_SCRIPT_PATH).new()
	assert_true(selector.has_signal("school_selected"))
	selector.free()


func _cancel_event() -> InputEventAction:
	var event := InputEventAction.new()
	event.action = &"ui_cancel"
	event.pressed = true
	return event
