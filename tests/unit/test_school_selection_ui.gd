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