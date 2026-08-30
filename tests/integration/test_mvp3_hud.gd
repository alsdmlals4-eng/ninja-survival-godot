extends GutTest

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func test_mvp3_stage_uses_contextual_stage_phase_and_upward_play_time() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	hud.show_combat_hud(true)
	hud.set_stage_phase("스테이지 · 봉마류 전장", "페이즈 2 · Elite 접근", true)
	hud.set_play_time(271.01)
	assert_eq(
		(hud.get_node("CombatTopBar/Row/StagePhaseLabel") as Label).text,
		"스테이지 · 봉마류 전장 · 페이즈 2 · Elite 접근",
	)
	assert_eq((hud.get_node("CombatTopBar/Row/PlayLabel") as Label).text, "PLAY 04:31")


func test_mvp3_legacy_segment_timer_and_gold_controls_do_not_survive_normal_combat() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	for node_name in ["StageLabel", "StageTimeLabel", "GoldLabel"]:
		assert_null(
			hud.get_node_or_null(node_name),
			"Normal combat must not expose legacy MVP-3 control: %s" % node_name,
		)


func test_mvp3_game_over_retry_overlay_remains_available() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	hud.show_game_over(true, 4)
	var panel := hud.get_node_or_null("GameOverPanel") as Control
	var retry := hud.get_node_or_null("GameOverPanel/RetryButton") as Button
	assert_not_null(panel)
	assert_not_null(retry)
	if panel == null or retry == null:
		return
	assert_true(panel.visible)
	assert_true(retry.visible)
	assert_string_contains(retry.text, "보유 4")
	hud.hide_game_over()
	assert_false(panel.visible)
