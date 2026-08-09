extends GutTest

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func test_hud_has_mvp1_feedback_nodes_and_methods() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	assert_true(hud.has_node("ComboLabel"))
	assert_true(hud.has_node("StyleLabel"))
	assert_true(hud.has_node("RewardLabel"))
	assert_true(hud.has_node("ComboTitleLabel"))
	assert_true(hud.has_method("set_combo"))
	assert_true(hud.has_method("set_stylish_score"))
	assert_true(hud.has_method("set_reward_count"))
	assert_true(hud.has_method("show_combo_title"))


func test_hud_formats_combo_style_and_reward_feedback() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	if not _has_mvp1_feedback(hud):
		fail_test("MVP-1 HUD feedback contract is missing")
		return

	hud.set_combo(4, 7)
	assert_eq(hud.get_node("ComboLabel").text, "COMBO x4  MAX 7")
	hud.set_combo(0, 7)
	assert_eq(hud.get_node("ComboLabel").text, "")
	hud.set_stylish_score(345)
	assert_eq(hud.get_node("StyleLabel").text, "STYLE 345")
	hud.set_reward_count(3)
	assert_eq(hud.get_node("RewardLabel").text, "ORBS 3")


func test_combo_title_clears_after_one_second() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	if not _has_mvp1_feedback(hud):
		fail_test("MVP-1 HUD feedback contract is missing")
		return

	hud.show_combo_title("그림자 연쇄")
	assert_eq(hud.get_node("ComboTitleLabel").text, "그림자 연쇄")
	await get_tree().create_timer(1.1).timeout
	assert_eq(hud.get_node("ComboTitleLabel").text, "")


func test_older_title_timeout_does_not_clear_newer_title() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	if not _has_mvp1_feedback(hud):
		fail_test("MVP-1 HUD feedback contract is missing")
		return

	hud.show_combo_title("그림자 연쇄")
	await get_tree().create_timer(0.5).timeout
	hud.show_combo_title("닌자 난무")
	await get_tree().create_timer(0.6).timeout
	assert_eq(hud.get_node("ComboTitleLabel").text, "닌자 난무")
	await get_tree().create_timer(0.5).timeout
	assert_eq(hud.get_node("ComboTitleLabel").text, "")


func _has_mvp1_feedback(hud: Node) -> bool:
	return (
		hud.has_node("ComboLabel")
		and hud.has_node("StyleLabel")
		and hud.has_node("RewardLabel")
		and hud.has_node("ComboTitleLabel")
		and hud.has_method("set_combo")
		and hud.has_method("set_stylish_score")
		and hud.has_method("set_reward_count")
		and hud.has_method("show_combo_title")
	)
