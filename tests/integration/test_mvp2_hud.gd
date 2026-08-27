extends GutTest

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

var restart_count: int = 0
var school_help_count: int = 0
var ultimate_count: int = 0
var test_elite_count: int = 0
var test_boss_count: int = 0
var trace_recovery_count: int = 0


func before_each() -> void:
	restart_count = 0
	school_help_count = 0
	ultimate_count = 0
	test_elite_count = 0
	test_boss_count = 0
	trace_recovery_count = 0


func test_hud_has_mvp2_school_feedback_contract() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	for node_name in ["SchoolLabel", "SchoolResourceLabel", "UltimateLabel", "SchoolFeedbackLabel"]:
		assert_true(hud.has_node(node_name), "Missing MVP-2 HUD node: %s" % node_name)
	for method_name in ["set_school", "set_school_resource", "set_ultimate_ready", "show_school_feedback"]:
		assert_true(hud.has_method(method_name), "Missing MVP-2 HUD method: %s" % method_name)


func test_restart_button_is_always_available_and_emits_request() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	assert_true(hud.has_signal("restart_requested"), "HUD must expose a restart_requested signal")
	assert_true(hud.has_node("RestartButton"), "HUD must expose an always-available RestartButton")
	if not hud.has_signal("restart_requested") or not hud.has_node("RestartButton"):
		return
	var button := hud.get_node("RestartButton") as Button
	assert_true(button.visible)
	hud.restart_requested.connect(_on_restart_requested)
	button.emit_signal("pressed")
	assert_eq(restart_count, 1)


func test_school_help_button_is_hidden_until_combat_and_emits_intent() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	assert_true(hud.has_signal("school_help_requested"), "HUD must emit a school-help intent")
	assert_true(hud.has_node("SchoolHelpButton"), "HUD must expose the current-school help button")
	if not hud.has_signal("school_help_requested") or not hud.has_node("SchoolHelpButton"):
		return
	var button := hud.get_node("SchoolHelpButton") as Button
	assert_false(button.visible, "The help button must not appear before a school is selected")
	hud.school_help_requested.connect(_on_school_help_requested)
	hud.show_school_help("천술류")
	assert_true(button.visible)
	assert_eq(button.text, "천술류 기능 도움말")
	button.emit_signal("pressed")
	assert_eq(school_help_count, 1)
	hud.hide_school_help()
	assert_false(button.visible)


func test_combat_controls_expose_ultimate_guidance_and_test_jump_intents() -> void:
	var hud = HUD_SCENE.instantiate()
	add_child_autofree(hud)
	for signal_name in ["ultimate_requested", "test_elite_requested", "test_boss_requested", "trace_recovery_requested"]:
		assert_true(hud.has_signal(signal_name), "HUD must expose combat-control intent: %s" % signal_name)
	for node_name in ["UltimateButton", "CombatGuideLabel", "TestEliteButton", "TestBossButton", "TraceRecoveryButton"]:
		assert_true(hud.has_node(node_name), "HUD must expose combat control: %s" % node_name)
	if not hud.has_method("show_combat_controls"):
		fail_test("HUD must expose one combat-control presentation API")
		return

	hud.ultimate_requested.connect(_on_ultimate_requested)
	hud.test_elite_requested.connect(_on_test_elite_requested)
	hud.test_boss_requested.connect(_on_test_boss_requested)
	hud.trace_recovery_requested.connect(_on_trace_recovery_requested)
	hud.set_ultimate_ready(true)
	hud.show_combat_controls("천술류", "오행폭주: 상태가 있는 적에게 폭발 피해를 준다.", true)

	var guide := hud.get_node("CombatGuideLabel") as Label
	var ultimate := hud.get_node("UltimateButton") as Button
	assert_string_contains(guide.text, "자동 투사체")
	assert_string_contains(guide.text, "Enter")
	assert_string_contains(guide.text, "오행폭주")
	assert_true(ultimate.visible)
	assert_false(ultimate.disabled)
	assert_false((hud.get_node("TraceRecoveryButton") as Button).visible)
	hud.set_trace_recovery_available(true)
	assert_true((hud.get_node("TraceRecoveryButton") as Button).visible)
	ultimate.pressed.emit()
	(hud.get_node("TestEliteButton") as Button).pressed.emit()
	(hud.get_node("TestBossButton") as Button).pressed.emit()
	(hud.get_node("TraceRecoveryButton") as Button).pressed.emit()
	assert_eq(ultimate_count, 1)
	assert_eq(test_elite_count, 1)
	assert_eq(test_boss_count, 1)
	assert_eq(trace_recovery_count, 1)


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


func _on_restart_requested() -> void:
	restart_count += 1


func _on_school_help_requested() -> void:
	school_help_count += 1


func _on_ultimate_requested() -> void:
	ultimate_count += 1


func _on_test_elite_requested() -> void:
	test_elite_count += 1


func _on_test_boss_requested() -> void:
	test_boss_count += 1


func _on_trace_recovery_requested() -> void:
	trace_recovery_count += 1


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
