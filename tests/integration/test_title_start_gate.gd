extends GutTest

const MAIN_SCENE := "res://scenes/main/main_scene.tscn"


func test_start_intent_reveals_starting_stage_selection_without_starting_combat() -> void:
	var main := (load(MAIN_SCENE) as PackedScene).instantiate()
	add_child_autofree(main)
	await get_tree().process_frame

	var title := main.get_node_or_null("TitleScreen") as CanvasLayer
	var school_selection := main.get_node_or_null("SchoolSelectionUI") as CanvasLayer
	assert_not_null(title, "Main must own the title front door above gameplay UI.")
	assert_not_null(school_selection)
	if title == null or school_selection == null:
		return

	assert_true(title.visible)
	assert_false(school_selection.visible)
	var start_button := title.get_node_or_null("LogoLockup/MenuButtons/StartButton") as Button
	assert_not_null(start_button)
	if start_button == null:
		return
	assert_true(_configure_empty_resume(main, "user://gut_title_start_gate_empty_resume.json"))

	start_button.pressed.emit()
	await get_tree().process_frame
	assert_false(title.visible)
	assert_true(school_selection.visible)
	assert_false(main._combat_enabled, "Starting a run must still require an explicit stage choice.")
	assert_eq(get_viewport().gui_get_focus_owner(), school_selection.get_node("Panel/Margin/Choices/BongmaButton"))


func test_title_secondary_buttons_open_only_their_own_panels_before_a_stage_is_selected() -> void:
	var main := (load(MAIN_SCENE) as PackedScene).instantiate()
	add_child_autofree(main)
	await get_tree().process_frame

	var title := main.get_node_or_null("TitleScreen") as CanvasLayer
	var school_selection := main.get_node_or_null("SchoolSelectionUI") as CanvasLayer
	assert_not_null(title)
	assert_not_null(school_selection)
	if title == null or school_selection == null:
		return

	assert_null(title.get_node_or_null("LogoLockup/PromiseLabel"), "The redundant title promise must not consume the main-menu action space.")
	var guide_button := title.get_node_or_null("LogoLockup/MenuButtons/GuideButton") as Button
	var settings_button := title.get_node_or_null("LogoLockup/MenuButtons/SettingsButton") as Button
	var guide_panel := title.get_node_or_null("GuidePanel") as Control
	var settings_panel := title.get_node_or_null("SettingsPanel") as Control
	assert_not_null(guide_button)
	assert_not_null(settings_button)
	assert_not_null(guide_panel)
	assert_not_null(settings_panel)
	if guide_button == null or settings_button == null or guide_panel == null or settings_panel == null:
		return

	guide_button.pressed.emit()
	await get_tree().process_frame
	assert_true(guide_panel.visible)
	assert_false(settings_panel.visible)
	assert_true(title.visible)
	assert_false(main._combat_enabled)
	assert_false(school_selection.visible, "Opening the control guide must not reveal the Stage selector.")

	(title.get_node("GuidePanel/Dialog/Margin/Actions/CloseButton") as Button).pressed.emit()
	settings_button.pressed.emit()
	await get_tree().process_frame
	assert_false(guide_panel.visible)
	assert_true(settings_panel.visible)
	assert_not_null(title.get_node_or_null("SettingsPanel/Dialog/Margin/Actions/FullscreenButton"))
	assert_false(school_selection.visible, "Opening title settings must not reveal the Stage selector.")


func _configure_empty_resume(main: Node, storage_path: String) -> bool:
	for suffix in ["", ".tmp", ".previous"]:
		var path := storage_path + String(suffix)
		if FileAccess.file_exists(path) and DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) != OK:
			return false
	return main.run_resume_store.configure(storage_path)
