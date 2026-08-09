extends GutTest

const FLOW_PATH := "res://scripts/core/stage_flow_controller.gd"

var boss_requests: Array[int] = []
var completion_count: int = 0


func before_each() -> void:
	boss_requests.clear()
	completion_count = 0


func test_stage_flow_resource_exists() -> void:
	assert_true(ResourceLoader.exists(FLOW_PATH), "Missing MVP-3 stage flow controller")


func test_default_phase_and_timer_do_not_advance_before_selection() -> void:
	var flow = _new_flow()
	if flow == null:
		return
	assert_eq(flow.segment_duration_seconds, 300.0)
	assert_eq(flow.phase, flow.Phase.SCHOOL_SELECT)
	assert_eq(flow.segment_index, 1)
	flow._process(100.0)
	assert_eq(flow.phase, flow.Phase.SCHOOL_SELECT)
	assert_eq(flow.segment_time_remaining, 300.0)


func test_start_copies_injected_duration_and_threshold_requests_one_boss() -> void:
	var flow = _new_flow()
	if flow == null:
		return
	flow.segment_duration_seconds = 0.05
	flow.boss_requested.connect(_on_boss_requested)
	assert_true(flow.start_after_school_selection())
	assert_eq(flow.phase, flow.Phase.COMBAT)
	assert_almost_eq(flow.segment_time_remaining, 0.05, 0.0001)
	flow._process(0.03)
	assert_eq(flow.phase, flow.Phase.COMBAT)
	flow._process(0.03)
	assert_eq(flow.phase, flow.Phase.BOSS)
	assert_eq(boss_requests, [1])
	assert_almost_eq(flow.segment_time_remaining, 0.0, 0.0001)
	flow._process(99.0)
	assert_eq(boss_requests, [1])


func test_illegal_transitions_are_rejected_without_phase_change() -> void:
	var flow = _new_flow()
	if flow == null:
		return
	assert_false(flow.enter_result_after_boss())
	assert_false(flow.continue_to_shop())
	assert_false(flow.continue_to_fate())
	assert_false(flow.continue_to_preview(true))
	assert_false(flow.start_next_combat())
	assert_eq(flow.phase, flow.Phase.SCHOOL_SELECT)


func test_boss_result_and_rest_order_are_strict() -> void:
	var flow = _new_flow()
	if flow == null:
		return
	flow.segment_duration_seconds = 0.01
	assert_true(flow.start_after_school_selection())
	flow._process(0.01)
	assert_eq(flow.phase, flow.Phase.BOSS)
	assert_true(flow.enter_result_after_boss())
	assert_eq(flow.phase, flow.Phase.RESULT)
	assert_false(flow.continue_to_fate())
	assert_true(flow.continue_to_shop())
	assert_eq(flow.phase, flow.Phase.SHOP)
	assert_true(flow.continue_to_fate())
	assert_eq(flow.phase, flow.Phase.FATE)
	assert_false(flow.continue_to_preview(false))
	assert_eq(flow.phase, flow.Phase.FATE)
	assert_true(flow.continue_to_preview(true))
	assert_eq(flow.phase, flow.Phase.PREVIEW)


func test_preview_starts_segments_two_and_three_with_fresh_injected_duration() -> void:
	var flow = _new_flow()
	if flow == null:
		return
	flow.segment_duration_seconds = 0.25
	assert_true(flow.start_after_school_selection())
	_finish_segment_into_preview(flow)
	assert_eq(flow.segment_index, 1)
	flow.segment_duration_seconds = 0.5
	assert_true(flow.start_next_combat())
	assert_eq(flow.segment_index, 2)
	assert_eq(flow.phase, flow.Phase.COMBAT)
	assert_almost_eq(flow.segment_time_remaining, 0.5, 0.0001)
	_finish_segment_into_preview(flow)
	assert_true(flow.start_next_combat())
	assert_eq(flow.segment_index, 3)
	assert_eq(flow.phase, flow.Phase.COMBAT)


func test_third_fate_choice_enters_complete_once_and_cannot_start_segment_four() -> void:
	var flow = _new_flow()
	if flow == null:
		return
	flow.run_completed.connect(_on_run_completed)
	flow.segment_duration_seconds = 0.01
	assert_true(flow.start_after_school_selection())
	_finish_segment_into_preview(flow)
	assert_true(flow.start_next_combat())
	_finish_segment_into_preview(flow)
	assert_true(flow.start_next_combat())
	assert_eq(flow.segment_index, 3)
	flow._process(0.01)
	assert_true(flow.enter_result_after_boss())
	assert_true(flow.continue_to_shop())
	assert_true(flow.continue_to_fate())
	assert_true(flow.continue_to_preview(true))
	assert_eq(flow.phase, flow.Phase.COMPLETE)
	assert_eq(completion_count, 1)
	assert_false(flow.continue_to_preview(true))
	assert_false(flow.start_next_combat())
	assert_eq(completion_count, 1)
	assert_eq(flow.segment_index, 3)


func test_game_over_is_terminal_for_stage_progression() -> void:
	var flow = _new_flow()
	if flow == null:
		return
	assert_true(flow.start_after_school_selection())
	flow.mark_game_over()
	assert_eq(flow.phase, flow.Phase.GAME_OVER)
	flow._process(999.0)
	assert_eq(flow.phase, flow.Phase.GAME_OVER)
	assert_false(flow.enter_result_after_boss())
	assert_false(flow.start_next_combat())


func _new_flow():
	if not ResourceLoader.exists(FLOW_PATH):
		return null
	var flow = load(FLOW_PATH).new()
	add_child_autofree(flow)
	return flow


func _finish_segment_into_preview(flow) -> void:
	flow._process(flow.segment_time_remaining)
	assert_eq(flow.phase, flow.Phase.BOSS)
	assert_true(flow.enter_result_after_boss())
	assert_true(flow.continue_to_shop())
	assert_true(flow.continue_to_fate())
	assert_true(flow.continue_to_preview(true))


func _on_boss_requested(tier: int) -> void:
	boss_requests.append(tier)


func _on_run_completed() -> void:
	completion_count += 1
