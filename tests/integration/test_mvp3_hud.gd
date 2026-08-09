extends GutTest

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func test_hud_has_compact_mvp3_stage_contract() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	for node_name in ["StageLabel", "StageTimeLabel", "GoldLabel"]:
		assert_true(hud.has_node(node_name), "Missing MVP-3 HUD node: %s" % node_name)
	for method_name in ["set_stage", "set_stage_time", "set_gold"]:
		assert_true(hud.has_method(method_name), "Missing MVP-3 HUD method: %s" % method_name)


func test_hud_formats_segment_time_and_gold_exactly() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	if not hud.has_method("set_stage"):
		return
	hud.set_stage(1, 3)
	hud.set_stage_time(271.01)
	hud.set_gold(37)
	assert_eq(hud.get_node("StageLabel").text, "SEGMENT 1/3")
	assert_eq(hud.get_node("StageTimeLabel").text, "TIME 04:32")
	assert_eq(hud.get_node("GoldLabel").text, "GOLD 37")
	hud.set_stage_time(-10.0)
	assert_eq(hud.get_node("StageTimeLabel").text, "TIME 00:00")


func test_existing_mvp1_and_mvp2_hud_nodes_remain_present() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	for node_name in [
		"HealthLabel", "ScoreLabel", "ComboLabel", "StyleLabel", "RewardLabel",
		"SchoolLabel", "SchoolResourceLabel", "UltimateLabel", "SchoolFeedbackLabel",
		"ComboTitleLabel", "RestartButton", "GameOverPanel",
	]:
		assert_true(hud.has_node(node_name), "Existing HUD node regressed: %s" % node_name)
