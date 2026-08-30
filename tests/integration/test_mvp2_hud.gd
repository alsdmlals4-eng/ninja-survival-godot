extends GutTest

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func test_mvp2_tradition_runtime_data_has_no_persistent_combat_hud_control() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	for node_name in [
		"SchoolLabel", "SchoolResourceLabel", "UltimateLabel", "SchoolFeedbackLabel", "SchoolHelpButton",
		"UltimateButton", "TestEliteButton", "TestBossButton", "CombatGuideLabel",
	]:
		assert_null(
			hud.get_node_or_null(node_name),
			"Automatic-combat HUD must not expose MVP-2 control: %s" % node_name,
		)


func test_settings_emits_current_tradition_help_as_an_intent() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	watch_signals(hud)
	hud.open_settings()
	(hud.find_child("TraditionHelpButton", true, false) as Button).pressed.emit()
	assert_signal_emitted(hud, "settings_requested")
	assert_signal_emitted(hud, "current_tradition_help_requested")


func test_settings_restart_is_not_a_persistent_normal_combat_button() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	assert_null(hud.get_node_or_null("RestartButton"))
	var settings_restart := hud.find_child("RestartButton", true, false) as Button
	assert_not_null(settings_restart)
	if settings_restart == null:
		return
	watch_signals(hud)
	hud.open_settings()
	settings_restart.pressed.emit()
	assert_signal_emitted(hud, "restart_requested")
