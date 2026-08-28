# Elite가 만든 Trace의 정착·근거리 회수 계약을 검증한다.
extends GutTest

const TRACE_PATH := "res://scripts/rewards/trace_pickup.gd"


func _make_target(position: Vector2) -> Node2D:
	var target := Node2D.new()
	target.global_position = position
	add_child_autofree(target)
	return target


func test_trace_resource_exists() -> void:
	assert_true(ResourceLoader.exists(TRACE_PATH), "Trace pickup domain owner가 필요합니다.")


func test_trace_settles_then_homes_and_recovers_once() -> void:
	if not ResourceLoader.exists(TRACE_PATH):
		return
	var trace = load(TRACE_PATH).new()
	trace.global_position = Vector2(80.0, 0.0)
	add_child_autofree(trace)
	var target := _make_target(Vector2.ZERO)
	assert_true(trace.configure(target))
	watch_signals(trace)

	trace._process(0.35)
	assert_eq(trace.phase_name(), &"ready")
	assert_eq(trace.global_position, Vector2(80.0, 0.0), "정착 구간에는 자동 이동하지 않아야 합니다.")
	assert_signal_not_emitted(trace, "recovered")

	trace._process(0.39)
	assert_eq(trace.phase_name(), &"homing")
	assert_signal_not_emitted(trace, "recovered")
	trace._process(0.01)
	assert_eq(trace.phase_name(), &"recovered")
	assert_eq(trace.global_position, target.global_position)
	assert_signal_emitted(trace, "recovered")

	trace._process(1.0)
	assert_signal_emit_count(trace, "recovered", 1)


func test_trace_waits_for_a_player_inside_the_pickup_radius() -> void:
	if not ResourceLoader.exists(TRACE_PATH):
		return
	var trace = load(TRACE_PATH).new()
	trace.global_position = Vector2.ZERO
	add_child_autofree(trace)
	var target := _make_target(Vector2(97.0, 0.0))
	assert_true(trace.configure(target))
	watch_signals(trace)

	trace._process(1.0)
	assert_eq(trace.phase_name(), &"ready")
	assert_eq(trace.global_position, Vector2.ZERO)
	assert_signal_not_emitted(trace, "recovered")
