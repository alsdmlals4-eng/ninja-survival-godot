extends GutTest

const REST_SCENE_PATH := "res://scenes/ui/rest_flow_ui.tscn"
const CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"

var emitted: Array = []


func before_each() -> void:
	emitted.clear()


func test_rest_flow_scene_exists() -> void:
	assert_true(ResourceLoader.exists(REST_SCENE_PATH), "Missing MVP-3 RestFlowUI scene")


func test_rest_flow_has_all_state_views_methods_and_intent_signals() -> void:
	var ui = _new_ui()
	if ui == null:
		return
	for path in [
		"Panel/Margin/Content/ResultView",
		"Panel/Margin/Content/ShopView",
		"Panel/Margin/Content/FateView",
		"Panel/Margin/Content/WorkbenchView",
		"Panel/Margin/Content/PreviewView",
		"Panel/Margin/Content/CompleteView",
		"Panel/Margin/Content/WorkbenchView/RouteCards",
		"Panel/Margin/Content/WorkbenchView/FateCandidates",
		"Panel/Margin/Content/WorkbenchView/CommitButton",
	]:
		assert_true(ui.has_node(path), "Missing rest view: %s" % path)
	for method_name in ["show_result", "show_shop", "show_fate", "show_workbench", "show_preview", "show_complete", "hide_all"]:
		assert_true(ui.has_method(method_name), "Missing RestFlowUI method: %s" % method_name)
	for signal_name in [
		"result_continue_requested",
		"shop_buy_requested",
		"shop_sell_requested",
		"shop_reroll_requested",
		"shop_continue_requested",
		"fate_selected_requested",
		"workbench_route_selected_requested",
		"workbench_commit_requested",
		"preview_start_requested",
		"restart_requested",
	]:
		assert_true(ui.has_signal(signal_name), "Missing RestFlowUI signal: %s" % signal_name)


func test_show_result_renders_zero_heal_and_defense_as_no_contribution() -> void:
	var ui = _new_ui()
	if ui == null:
		return
	ui.show_result({
		"damage": 123,
		"healing": 0,
		"defense": 0,
		"status_events": 4,
		"kills": 9,
		"max_combo": 6,
		"gold_earned": 15,
		"growth_hints": ["피해 강화 추천"],
	})
	assert_true(ui.get_node("Panel").visible)
	assert_true(ui.get_node("Panel/Margin/Content/ResultView").visible)
	assert_false(ui.get_node("Panel/Margin/Content/ShopView").visible)
	assert_true(ui.get_node("Panel/Margin/Content/ResultView/HealingLabel").text.contains("기여 없음"))
	assert_true(ui.get_node("Panel/Margin/Content/ResultView/DefenseLabel").text.contains("기여 없음"))
	assert_true(ui.get_node("Panel/Margin/Content/ResultView/DamageLabel").text.contains("123"))
	assert_true(ui.get_node("Panel/Margin/Content/ResultView/HintsLabel").text.contains("피해 강화 추천"))


func test_result_and_shop_buttons_emit_intents_without_mutating_data() -> void:
	var ui = _new_ui()
	if ui == null:
		return
	ui.result_continue_requested.connect(func(): emitted.append(["result"]))
	ui.shop_buy_requested.connect(func(index: int): emitted.append(["buy", index]))
	ui.shop_reroll_requested.connect(func(): emitted.append(["reroll"]))
	ui.shop_continue_requested.connect(func(): emitted.append(["shop_next"]))
	ui.shop_sell_requested.connect(func(item_id: StringName): emitted.append(["sell", item_id]))

	ui.show_result({"damage": 1, "healing": 0, "defense": 0, "status_events": 0, "kills": 0, "max_combo": 0, "gold_earned": 0, "growth_hints": []})
	ui.get_node("Panel/Margin/Content/ResultView/ContinueButton").emit_signal("pressed")

	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	var offers: Array[StringName] = [&"taijutsu_training", &"ninjutsu_training", &"school_emblem"]
	var owned := {&"taijutsu_training": 1}
	ui.show_shop(77, offers, items, owned, 10)
	assert_eq(ui.get_node("Panel/Margin/Content/ShopView/GoldLabel").text, "GOLD 77")
	var offers_box = ui.get_node("Panel/Margin/Content/ShopView/Offers")
	assert_eq(offers_box.get_child_count(), 3)
	assert_true(offers_box.get_child(0).text.contains("체술단련"))
	offers_box.get_child(1).emit_signal("pressed")
	ui.get_node("Panel/Margin/Content/ShopView/RerollButton").emit_signal("pressed")
	ui.get_node("Panel/Margin/Content/ShopView/ContinueButton").emit_signal("pressed")
	var owned_box = ui.get_node("Panel/Margin/Content/ShopView/OwnedList")
	assert_eq(owned_box.get_child_count(), 1)
	owned_box.get_child(0).emit_signal("pressed")

	assert_eq(emitted[0], ["result"])
	assert_eq(emitted[1], ["buy", 1])
	assert_eq(emitted[2], ["reroll"])
	assert_eq(emitted[3], ["shop_next"])
	assert_eq(emitted[4], ["sell", &"taijutsu_training"])


func test_fate_view_shows_three_benefit_cost_cards_and_has_no_skip() -> void:
	var ui = _new_ui()
	if ui == null:
		return
	ui.fate_selected_requested.connect(func(fate_id: StringName): emitted.append(["fate", fate_id]))
	var catalog = load(CATALOG_PATH)
	var fates: Dictionary = catalog.build_fates()
	var candidates: Array[StringName] = [&"slaughter_path", &"guardian_path", &"seal_path"]
	ui.show_fate(candidates, fates)
	var box = ui.get_node("Panel/Margin/Content/FateView/Candidates")
	assert_eq(box.get_child_count(), 3)
	for button in box.get_children():
		assert_true(button.text.contains("장점"))
		assert_true(button.text.contains("대가"))
	assert_false(ui.get_node("Panel/Margin/Content/FateView").has_node("ContinueButton"), "Fate must not expose a skip/continue button")
	box.get_child(2).emit_signal("pressed")
	assert_eq(emitted, [["fate", &"seal_path"]])


func test_workbench_renders_only_unvisited_routes_and_emits_intents() -> void:
	var ui = _new_ui()
	if ui == null:
		return
	ui.workbench_route_selected_requested.connect(func(school_id: StringName): emitted.append(["route", school_id]))
	ui.fate_selected_requested.connect(func(fate_id: StringName): emitted.append(["fate", fate_id]))
	ui.workbench_commit_requested.connect(func(): emitted.append(["commit"]))
	var catalog = load(CATALOG_PATH)
	var fates: Dictionary = catalog.build_fates()
	var unvisited: Array[StringName] = [&"cheonsul", &"guiin"]
	var candidates: Array[StringName] = [&"slaughter_path", &"guardian_path"]
	var readiness_failures: Array[StringName] = []
	ui.show_workbench(
		{
			"unvisited_school_ids": unvisited,
			"provisional_school_id": &"guiin",
		},
		candidates,
		fates,
		&"guardian_path",
		readiness_failures
	)

	var route_cards = ui.get_node("Panel/Margin/Content/WorkbenchView/RouteCards")
	var fate_cards = ui.get_node("Panel/Margin/Content/WorkbenchView/FateCandidates")
	var commit_button = ui.get_node("Panel/Margin/Content/WorkbenchView/CommitButton")
	assert_true(ui.get_node("Panel/Margin/Content/WorkbenchView").visible)
	assert_eq(route_cards.get_child_count(), 2)
	assert_eq(fate_cards.get_child_count(), 2)
	assert_true(route_cards.get_child(1).text.contains("임시 선택"))
	assert_false(route_cards.get_child(0).text.contains("HP"))
	assert_false(commit_button.disabled)
	for button in route_cards.get_children() + fate_cards.get_children():
		assert_ne(button.focus_mode, Control.FOCUS_NONE)

	route_cards.get_child(0).emit_signal("pressed")
	fate_cards.get_child(1).emit_signal("pressed")
	commit_button.emit_signal("pressed")
	assert_eq(emitted, [["route", &"cheonsul"], ["fate", &"guardian_path"], ["commit"]])


func test_preview_and_complete_are_distinct_terminal_states() -> void:
	var ui = _new_ui()
	if ui == null:
		return
	ui.preview_start_requested.connect(func(): emitted.append(["start"]))
	ui.restart_requested.connect(func(): emitted.append(["restart"]))
	var summary := {
		"headline": "피해 기여 우세",
		"shop_changes": ["구매: 인법단련"],
		"new_fate": "살육의 길",
		"selected_fates": ["살육의 길"],
		"gold": 22,
		"next_boss": "BOSS 2 HP 350 / CONTACT 20",
	}
	ui.show_preview(summary)
	assert_true(ui.get_node("Panel/Margin/Content/PreviewView").visible)
	assert_false(ui.get_node("Panel/Margin/Content/CompleteView").visible)
	assert_true(ui.get_node("Panel/Margin/Content/PreviewView/SummaryLabel").text.contains("BOSS 2"))
	ui.get_node("Panel/Margin/Content/PreviewView/StartButton").emit_signal("pressed")
	assert_eq(emitted, [["start"]])

	ui.show_complete(summary)
	assert_true(ui.get_node("Panel/Margin/Content/CompleteView").visible)
	assert_false(ui.get_node("Panel/Margin/Content/PreviewView").visible)
	assert_true(ui.get_node("Panel/Margin/Content/CompleteView/TitleLabel").text.contains("MVP-3 LOOP COMPLETE"))
	assert_false(ui.get_node("Panel/Margin/Content/CompleteView").has_node("StartButton"))
	ui.get_node("Panel/Margin/Content/CompleteView/RestartButton").emit_signal("pressed")
	assert_eq(emitted, [["start"], ["restart"]])


func test_hide_all_hides_overlay_and_every_state_view() -> void:
	var ui = _new_ui()
	if ui == null:
		return
	ui.show_preview({})
	ui.hide_all()
	assert_false(ui.get_node("Panel").visible)
	for view_name in ["ResultView", "ShopView", "FateView", "PreviewView", "CompleteView"]:
		assert_false(ui.get_node("Panel/Margin/Content/%s" % view_name).visible)


func _new_ui():
	if not ResourceLoader.exists(REST_SCENE_PATH):
		return null
	var ui = load(REST_SCENE_PATH).instantiate()
	add_child_autofree(ui)
	return ui
