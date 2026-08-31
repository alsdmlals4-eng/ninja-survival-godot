# 메인 화면은 새 게임·이어하기·각성·도감 등 모든 진입 행동을 분명한 UI 상태로 노출한다.
extends GutTest

const TITLE_SCREEN := "res://scenes/ui/title_screen.tscn"


func test_title_exposes_all_requested_actions_and_disables_continue_without_a_valid_checkpoint() -> void:
	var title := (load(TITLE_SCREEN) as PackedScene).instantiate()
	add_child_autofree(title)
	await get_tree().process_frame

	for button_name in ["StartButton", "ContinueButton", "AwakeningButton", "CodexButton", "GuideButton", "SettingsButton", "QuitButton"]:
		assert_not_null(title.get_node_or_null("LogoLockup/MenuButtons/%s" % button_name), "Title action is required: %s" % button_name)
	var new_game_button := title.get_node("LogoLockup/MenuButtons/StartButton") as Button
	var continue_button := title.get_node("LogoLockup/MenuButtons/ContinueButton") as Button
	assert_eq(new_game_button.text, "새 게임")
	assert_eq(continue_button.text, "이어하기")
	assert_true(continue_button.disabled)
	assert_true(title.has_signal(&"new_game_requested"))
	assert_true(title.has_signal(&"continue_requested"))
	assert_true(title.has_signal(&"quit_requested"))


func test_title_opens_awakening_codex_and_new_game_confirmation_as_local_presentation_states() -> void:
	var title := (load(TITLE_SCREEN) as PackedScene).instantiate()
	add_child_autofree(title)
	await get_tree().process_frame

	title.set_continue_state(true)
	var continue_button := title.get_node("LogoLockup/MenuButtons/ContinueButton") as Button
	assert_false(continue_button.disabled)
	watch_signals(title)
	continue_button.pressed.emit()
	assert_signal_emitted(title, "continue_requested")

	title.set_awakening_balance(7)
	(title.get_node("LogoLockup/MenuButtons/AwakeningButton") as Button).pressed.emit()
	await get_tree().process_frame
	var awakening_panel := title.get_node("AwakeningPanel") as Control
	assert_true(awakening_panel.visible)
	assert_true((title.get_node("AwakeningPanel/Dialog/Margin/Actions/BalanceLabel") as Label).text.contains("7"))

	(title.get_node("AwakeningPanel/Dialog/Margin/Actions/CloseButton") as Button).pressed.emit()
	(title.get_node("LogoLockup/MenuButtons/CodexButton") as Button).pressed.emit()
	await get_tree().process_frame
	assert_true((title.get_node("CodexPanel") as Control).visible)
	assert_true((title.get_node("CodexPanel/Dialog/Margin/Actions/Tabs/EnemyTab") as Button).button_pressed)
	assert_true((title.get_node("CodexPanel/Dialog/Margin/Actions/Entries") as RichTextLabel).text.contains("적"))

	title.show_new_game_confirmation()
	assert_true((title.get_node("NewGameConfirmPanel") as Control).visible)
	(title.get_node("NewGameConfirmPanel/Dialog/Margin/Actions/Buttons/ConfirmButton") as Button).pressed.emit()
	assert_signal_emitted(title, "new_game_confirmed")


func test_title_exit_requires_a_local_confirmation_before_emitting_its_intent() -> void:
	var title := (load(TITLE_SCREEN) as PackedScene).instantiate()
	add_child_autofree(title)
	await get_tree().process_frame
	watch_signals(title)
	(title.get_node("LogoLockup/MenuButtons/QuitButton") as Button).pressed.emit()
	assert_true((title.get_node("QuitConfirmPanel") as Control).visible)
	(title.get_node("QuitConfirmPanel/Dialog/Margin/Actions/Buttons/ConfirmButton") as Button).pressed.emit()
	assert_signal_emitted(title, "quit_requested")
