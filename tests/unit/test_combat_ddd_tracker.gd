extends GutTest

const TRACKER_PATH := "res://scripts/combat/combat_ddd_tracker.gd"


func test_first_kill_starts_combo_and_scores_base() -> void:
	var tracker = _make_tracker()
	if tracker == null:
		return
	tracker.register_kill()
	assert_eq(tracker.combo_count, 1)
	assert_eq(tracker.max_combo, 1)
	assert_eq(tracker.stylish_score, 100)
	assert_eq(tracker.combo_time_remaining, 2.5)


func test_kill_inside_window_increments_combo_and_step_bonus() -> void:
	var tracker = _make_tracker()
	if tracker == null:
		return
	tracker.register_kill()
	tracker._process(1.0)
	tracker.register_kill()
	assert_eq(tracker.combo_count, 2)
	assert_eq(tracker.stylish_score, 220)
	assert_eq(tracker.combo_time_remaining, 2.5)


func test_timeout_resets_current_combo_but_preserves_maximum() -> void:
	var tracker = _make_tracker()
	if tracker == null:
		return
	tracker.register_kill()
	tracker.register_kill()
	tracker._process(2.5)
	assert_eq(tracker.combo_count, 0)
	assert_eq(tracker.max_combo, 2)


func test_kill_after_timeout_restarts_at_one() -> void:
	var tracker = _make_tracker()
	if tracker == null:
		return
	tracker.register_kill()
	tracker._process(3.0)
	tracker.register_kill()
	assert_eq(tracker.combo_count, 1)
	assert_eq(tracker.max_combo, 1)
	assert_eq(tracker.stylish_score, 200)


func test_title_thresholds_emit_exactly_once_on_threshold_kill() -> void:
	var tracker = _make_tracker()
	if tracker == null:
		return
	watch_signals(tracker)
	for _i in range(10):
		tracker.register_kill()
	assert_signal_emit_count(tracker, "title_triggered", 3)
	assert_signal_emitted_with_parameters(tracker, "title_triggered", ["그림자 연쇄"], 0)
	assert_signal_emitted_with_parameters(tracker, "title_triggered", ["닌자 난무"], 1)
	assert_signal_emitted_with_parameters(tracker, "title_triggered", ["백귀 격파"], 2)


func test_reward_collection_adds_counter_and_style_only() -> void:
	var tracker = _make_tracker()
	if tracker == null:
		return
	tracker.register_reward_collected()
	assert_eq(tracker.reward_count, 1)
	assert_eq(tracker.stylish_score, 25)
	assert_eq(tracker.combo_count, 0)


func _make_tracker() -> Node:
	assert_true(ResourceLoader.exists(TRACKER_PATH), "CombatDDDTracker script must exist")
	if not ResourceLoader.exists(TRACKER_PATH):
		return null
	var script = load(TRACKER_PATH)
	assert_not_null(script)
	if script == null:
		return null
	var tracker = script.new()
	add_child_autofree(tracker)
	return tracker
