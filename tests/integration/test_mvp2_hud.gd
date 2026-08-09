extends GutTest

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func test_hud_has_mvp2_school_feedback_contract() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	for node_name in ["SchoolLabel", "SchoolResourceLabel", "UltimateLabel", "SchoolFeedbackLabel"]:
		assert_true(hud.has_node(node_name), "Missing MVP-2 HUD node: %s" % node_name)
	for method_name in ["set_school", "set_school_resource", "set_ultimate_ready", "show_school_feedback"]:
		assert_true(hud.has_method(method_name), "Missing MVP-2 HUD method: %s" % method_name)


func test_hud_formats_school_resource_and_ultimate_state() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	if not _has_mvp2_feedback(hud):
		fail_test("MVP-2 HUD feedback contract is missing")
		return

	hud.set_school("봉마류")
	assert_eq(hud.get_node("SchoolLabel").text, "SCHOOL 봉마류")
	hud.set_school_resource("SPIRIT", 41.6, 120.0)
	assert_eq(hud.get_node("SchoolResourceLabel").text, "SPIRIT 42 / 120")
	hud.set_ultimate_ready(false)
	assert_eq(hud.get_node("UltimateLabel").text, "ULT charging")
	hud.set_ultimate_ready(true)
	assert_eq(hud.get_node("UltimateLabel").text, "ULT READY")


func test_school_feedback_clears_after_one_second() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	if not _has_mvp2_feedback(hud):
		fail_test("MVP-2 HUD feedback contract is missing")
		return

	hud.show_school_feedback("백귀야행")
	assert_eq(hud.get_node("SchoolFeedbackLabel").text, "백귀야행")
	await get_tree().create_timer(1.1).timeout
	assert_eq(hud.get_node("SchoolFeedbackLabel").text, "")


func test_older_school_feedback_timeout_does_not_clear_newer_feedback() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	if not _has_mvp2_feedback(hud):
		fail_test("MVP-2 HUD feedback contract is missing")
		return

	hud.show_school_feedback("MARK BURST")
	await get_tree().create_timer(0.5).timeout
	hud.show_school_feedback("암영처형")
	await get_tree().create_timer(0.6).timeout
	assert_eq(hud.get_node("SchoolFeedbackLabel").text, "암영처형")
	await get_tree().create_timer(0.5).timeout
	assert_eq(hud.get_node("SchoolFeedbackLabel").text, "")


func _has_mvp2_feedback(hud: Node) -> bool:
	return (
		hud.has_node("SchoolLabel")
		and hud.has_node("SchoolResourceLabel")
		and hud.has_node("UltimateLabel")
		and hud.has_node("SchoolFeedbackLabel")
		and hud.has_method("set_school")
		and hud.has_method("set_school_resource")
		and hud.has_method("set_ultimate_ready")
		and hud.has_method("show_school_feedback")
	)