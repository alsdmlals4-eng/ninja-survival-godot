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
	var start_button := title.get_node_or_null("LogoLockup/StartButton") as Button
	assert_not_null(start_button)
	if start_button == null:
		return

	start_button.pressed.emit()
	await get_tree().process_frame
	assert_false(title.visible)
	assert_true(school_selection.visible)
	assert_false(main._combat_enabled, "Starting a run must still require an explicit stage choice.")
	assert_eq(get_viewport().gui_get_focus_owner(), school_selection.get_node("Panel/Margin/Choices/BongmaButton"))
