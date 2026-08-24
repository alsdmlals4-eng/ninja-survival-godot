extends GutTest

const TRACKER_PATH := "res://scripts/combat/combat_contribution_tracker.gd"
const STATE_PATH := "res://scripts/core/run_build_state.gd"
const CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"


func test_contribution_tracker_resource_exists() -> void:
	assert_true(ResourceLoader.exists(TRACKER_PATH), "Missing MVP-3 contribution tracker")


func test_segment_values_accumulate_actual_contributions_and_deltas() -> void:
	var tracker = _new_tracker()
	if tracker == null:
		return
	tracker.reset_segment(2, 10)
	tracker.record_damage(37)
	tracker.record_healing(4)
	tracker.record_defense(6)
	tracker.record_status_event()
	tracker.record_status_event(2)
	tracker.record_kill(3)
	tracker.record_kill(7)
	var snapshot: Dictionary = tracker.freeze_snapshot(5, 15)
	assert_eq(snapshot["damage"], 37)
	assert_eq(snapshot["healing"], 4)
	assert_eq(snapshot["defense"], 6)
	assert_eq(snapshot["status_events"], 3)
	assert_eq(snapshot["kills"], 2)
	assert_eq(snapshot["max_combo"], 7)
	assert_eq(snapshot["reward_orbs"], 3)
	assert_eq(snapshot["gold_earned"], 5)


func test_non_positive_records_are_ignored_and_segment_combo_starts_at_zero() -> void:
	var tracker = _new_tracker()
	if tracker == null:
		return
	tracker.reset_segment(0, 0)
	tracker.record_damage(-1)
	tracker.record_healing(0)
	tracker.record_defense(-2)
	tracker.record_status_event(0)
	var snapshot: Dictionary = tracker.freeze_snapshot(0, 0)
	assert_eq(snapshot["damage"], 0)
	assert_eq(snapshot["healing"], 0)
	assert_eq(snapshot["defense"], 0)
	assert_eq(snapshot["status_events"], 0)
	assert_eq(snapshot["kills"], 0)
	assert_eq(snapshot["max_combo"], 0)


func test_frozen_snapshot_is_immutable_until_segment_reset() -> void:
	var tracker = _new_tracker()
	if tracker == null:
		return
	tracker.reset_segment(1, 3)
	tracker.record_damage(25)
	var frozen: Dictionary = tracker.freeze_snapshot(2, 8)
	tracker.record_damage(999)
	tracker.record_kill(99)
	var copy_a: Dictionary = tracker.get_snapshot()
	assert_eq(copy_a["damage"], 25)
	assert_eq(copy_a["kills"], 0)
	assert_eq(copy_a["gold_earned"], 5)
	copy_a["damage"] = 777
	copy_a["growth_hints"].append("mutated")
	var copy_b: Dictionary = tracker.get_snapshot()
	assert_eq(copy_b["damage"], 25)
	assert_eq(copy_b["growth_hints"], frozen["growth_hints"])

	tracker.reset_segment(2, 8)
	tracker.record_damage(9)
	var next_snapshot: Dictionary = tracker.freeze_snapshot(2, 8)
	assert_eq(next_snapshot["damage"], 9)
	assert_eq(next_snapshot["gold_earned"], 0)


func test_growth_hint_tie_priority_is_damage_before_healing() -> void:
	var tracker = _new_tracker()
	if tracker == null:
		return
	tracker.reset_segment(0, 0)
	tracker.record_damage(100)
	tracker.record_healing(40)
	var snapshot: Dictionary = tracker.freeze_snapshot(0, 0)
	var hints: Array = snapshot["growth_hints"]
	assert_eq(hints.size(), 2)
	assert_eq(hints[0], "현재 화력을 유지할 피해/유파 강화가 잘 맞습니다")
	assert_eq(hints[1], "회복 기여가 실제로 나오고 있습니다. 회복 효율을 유지할 선택이 잘 맞습니다")


func test_second_axis_hint_requires_half_primary_and_minimum_one_score() -> void:
	var tracker = _new_tracker()
	if tracker == null:
		return
	tracker.reset_segment(0, 0)
	tracker.record_damage(125)
	tracker.record_status_event(1)
	var snapshot: Dictionary = tracker.freeze_snapshot(0, 0)
	var hints: Array = snapshot["growth_hints"]
	assert_eq(hints.size(), 1)
	assert_eq(hints[0], "현재 화력을 유지할 피해/유파 강화가 잘 맞습니다")


func test_matching_build_modifier_can_supply_second_synergy_hint() -> void:
	var tracker = _new_tracker()
	if tracker == null:
		return
	var state = _new_build_state()
	state.grant_gold(100)
	assert_true(state.buy_item(&"ninjutsu_training"))
	var committed = load(MODIFIER_PATH).new()
	committed.school_damage_pct = 0.12
	state.set_committed_backpack_modifiers(committed)
	tracker.reset_segment(0, state.gold)
	tracker.record_damage(50)
	var snapshot: Dictionary = tracker.freeze_snapshot(0, state.gold, state)
	var hints: Array = snapshot["growth_hints"]
	assert_eq(hints.size(), 2)
	assert_eq(hints[0], "현재 화력을 유지할 피해/유파 강화가 잘 맞습니다")
	assert_true(str(hints[1]).contains("피해"))


func test_zero_contribution_has_no_growth_hint() -> void:
	var tracker = _new_tracker()
	if tracker == null:
		return
	tracker.reset_segment(0, 0)
	var snapshot: Dictionary = tracker.freeze_snapshot(0, 0)
	assert_eq(snapshot["growth_hints"].size(), 0)


func _new_tracker():
	if not ResourceLoader.exists(TRACKER_PATH):
		return null
	var tracker = load(TRACKER_PATH).new()
	add_child_autofree(tracker)
	return tracker


func _new_build_state():
	var catalog = load(CATALOG_PATH)
	var state = load(STATE_PATH).new()
	add_child_autofree(state)
	state.configure(catalog.build_items(), catalog.build_fates())
	return state
