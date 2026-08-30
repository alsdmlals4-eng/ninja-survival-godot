extends GutTest

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func test_combat_top_bar_shows_dash_play_and_settings_only() -> void:
	var hud = _spawn_hud()
	if hud == null or not hud.has_method("show_combat_hud"):
		fail_test("DEC-037 combat HUD presentation API is missing")
		return

	hud.show_combat_hud(true)
	for node_path in [
		"CombatTopBar/Row/DashLabel",
		"CombatTopBar/Row/PlayLabel",
		"CombatTopBar/Row/SettingsButton",
	]:
		var control := hud.get_node_or_null(node_path) as Control
		assert_not_null(control, "Missing compact combat control: %s" % node_path)
		if control != null:
			assert_true(control.visible, "Combat control must be visible: %s" % node_path)

	assert_eq(hud.combat_persistent_control_names(), ["DashLabel", "PlayLabel", "SettingsButton"])


func test_normal_combat_tree_excludes_legacy_status_skill_and_test_controls() -> void:
	var hud = _spawn_hud()
	assert_not_null(hud)
	if hud == null:
		return

	for prohibited_name in [
		"HealthLabel", "ScoreLabel", "ComboLabel", "StyleLabel", "RewardLabel",
		"SchoolLabel", "SchoolResourceLabel", "UltimateLabel", "SchoolFeedbackLabel",
		"ComboTitleLabel", "StageLabel", "StageTimeLabel", "GoldLabel",
		"SchoolHelpButton", "UltimateButton", "TestEliteButton", "TestBossButton",
		"CombatGuideLabel",
	]:
		assert_null(
			hud.get_node_or_null(prohibited_name),
			"Normal combat must not expose legacy HUD control: %s" % prohibited_name,
		)


func test_dash_and_play_are_render_only() -> void:
	var hud = _spawn_hud()
	if hud == null or not hud.has_method("set_dash_state") or not hud.has_method("set_play_time"):
		fail_test("DEC-037 dash/play rendering API is missing")
		return

	hud.set_dash_state(1, 2)
	hud.set_play_time(134.9)
	assert_eq(hud.dash_text(), "DASH 1 / 2")
	assert_eq(hud.play_text(), "PLAY 02:14")
	assert_eq(hud.combat_persistent_control_names(), ["DashLabel", "PlayLabel", "SettingsButton"])


func test_stage_phase_is_contextual_and_can_be_hidden() -> void:
	var hud = _spawn_hud()
	if hud == null or not hud.has_method("set_stage_phase"):
		fail_test("DEC-037 stage/phase presentation API is missing")
		return

	hud.set_stage_phase("스테이지 · 천술류 전장", "페이즈 3 · Trace 회수", true)
	var label := hud.get_node_or_null("CombatTopBar/Row/StagePhaseLabel") as Label
	assert_not_null(label)
	if label == null:
		return
	assert_true(label.visible)
	assert_eq(label.text, "스테이지 · 천술류 전장 · 페이즈 3 · Trace 회수")

	hud.set_stage_phase("", "", false)
	assert_false(label.visible)
	assert_eq(label.text, "")

	hud.set_stage_phase("스테이지 · 천술류 전장", "페이즈 3 · Trace 회수", true)
	hud.show_combat_hud(false)
	assert_false(label.visible)
	hud.show_combat_hud(true)
	assert_true(label.visible, "Combat re-entry must restore the current contextual Stage/Phase")


func test_settings_panel_is_pause_safe_and_emits_only_intents() -> void:
	var hud = _spawn_hud()
	if hud == null:
		return
	for signal_name in [
		"settings_requested", "resume_requested", "current_tradition_help_requested", "restart_requested",
	]:
		assert_true(hud.has_signal(signal_name), "Missing settings intent: %s" % signal_name)
	if not hud.has_method("open_settings") or not hud.has_method("close_settings"):
		fail_test("DEC-037 settings presentation API is missing")
		return

	var panel := hud.get_node_or_null("SettingsPanel") as Control
	var resume := hud.find_child("ResumeButton", true, false) as Button
	var help := hud.find_child("TraditionHelpButton", true, false) as Button
	var restart := hud.find_child("RestartButton", true, false) as Button
	assert_not_null(panel)
	assert_not_null(resume)
	assert_not_null(help)
	assert_not_null(restart)
	if panel == null or resume == null or help == null or restart == null:
		return

	assert_false(panel.visible)
	assert_eq(panel.process_mode, Node.PROCESS_MODE_WHEN_PAUSED)
	watch_signals(hud)
	hud.open_settings()
	assert_true(panel.visible)
	assert_signal_emitted(hud, "settings_requested")
	assert_eq(hud.get_viewport().gui_get_focus_owner(), resume)

	get_tree().paused = true
	resume.pressed.emit()
	assert_signal_emitted(hud, "resume_requested")
	assert_false(panel.visible)
	get_tree().paused = false

	hud.open_settings()
	help.pressed.emit()
	assert_signal_emitted(hud, "current_tradition_help_requested")
	restart.pressed.emit()
	assert_signal_emitted(hud, "restart_requested")


func test_settings_actions_have_distinct_layout_rects_inside_the_actions_container() -> void:
	var hud = _spawn_hud()
	if hud == null:
		return
	hud.open_settings()
	await get_tree().process_frame
	var actions := hud.get_node_or_null("SettingsPanel/Dialog/Margin/Actions") as VBoxContainer
	var resume := hud.find_child("ResumeButton", true, false) as Button
	var help := hud.find_child("TraditionHelpButton", true, false) as Button
	var restart := hud.find_child("RestartButton", true, false) as Button
	assert_not_null(actions)
	assert_not_null(resume)
	assert_not_null(help)
	assert_not_null(restart)
	if actions == null or resume == null or help == null or restart == null:
		return

	assert_eq(resume.get_parent(), actions)
	assert_eq(help.get_parent(), actions)
	assert_eq(restart.get_parent(), actions)
	assert_false(resume.get_global_rect().intersects(help.get_global_rect()))
	assert_false(resume.get_global_rect().intersects(restart.get_global_rect()))
	assert_false(help.get_global_rect().intersects(restart.get_global_rect()))


func test_each_settings_button_emits_only_its_matching_intent() -> void:
	_assert_single_settings_intent("ResumeButton", "resume_requested", [
		"current_tradition_help_requested", "restart_requested",
	])
	_assert_single_settings_intent("TraditionHelpButton", "current_tradition_help_requested", [
		"resume_requested", "restart_requested",
	])
	_assert_single_settings_intent("RestartButton", "restart_requested", [
		"resume_requested", "current_tradition_help_requested",
	])


func test_touch_controls_are_hidden_on_desktop_and_emit_named_movement_actions() -> void:
	var hud = _spawn_hud()
	if hud == null:
		return
	var touch_controls := hud.get_node_or_null("TouchControls") as Control
	var move_left := hud.get_node_or_null("TouchControls/MovePad/MoveLeftButton") as Button
	var dash := hud.get_node_or_null("TouchControls/DashButton") as Button
	assert_not_null(touch_controls)
	assert_not_null(move_left)
	assert_not_null(dash)
	if touch_controls == null or move_left == null or dash == null:
		return

	hud.show_combat_hud(true)
	if not DisplayServer.is_touchscreen_available():
		assert_false(touch_controls.visible, "Desktop combat layout must not expose touch affordances")

	move_left.button_down.emit()
	assert_true(Input.is_action_pressed(&"move_left"))
	move_left.button_up.emit()
	assert_false(Input.is_action_pressed(&"move_left"))
	dash.button_down.emit()
	assert_true(Input.is_action_pressed(&"dash"))
	dash.button_up.emit()
	assert_false(Input.is_action_pressed(&"dash"))


func test_game_over_keeps_the_terminal_retry_route() -> void:
	var hud = _spawn_hud()
	if hud == null:
		return
	assert_true(hud.has_signal("retry_requested"))
	var panel := hud.get_node_or_null("GameOverPanel") as Control
	var retry := hud.get_node_or_null("GameOverPanel/RetryButton") as Button
	assert_not_null(panel)
	assert_not_null(retry)
	if panel == null or retry == null:
		return

	watch_signals(hud)
	hud.show_game_over(true, 3)
	assert_true(panel.visible)
	assert_true(retry.visible)
	assert_false(retry.disabled)
	retry.pressed.emit()
	assert_signal_emitted(hud, "retry_requested")
	hud.hide_game_over()
	assert_false(panel.visible)


func _spawn_hud():
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	return hud


func _assert_single_settings_intent(button_name: String, expected_signal: String, unexpected_signals: Array[String]) -> void:
	var hud = _spawn_hud()
	if hud == null:
		return
	hud.open_settings()
	var button := hud.find_child(button_name, true, false) as Button
	assert_not_null(button, "Missing settings button: %s" % button_name)
	if button == null:
		return
	watch_signals(hud)
	button.pressed.emit()
	assert_signal_emitted(hud, expected_signal)
	for unexpected_signal in unexpected_signals:
		assert_signal_not_emitted(hud, unexpected_signal)
