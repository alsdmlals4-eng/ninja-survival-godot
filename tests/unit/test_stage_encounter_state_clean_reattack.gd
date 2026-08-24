extends GutTest

const ENCOUNTER_STATE_PATH := "res://scripts/core/stage_encounter_state.gd"


func test_compact_full_lifecycle_preserves_terminal_snapshot_invariants() -> void:
	var state = _new_state()
	assert_true(state.configure_timing(1.0, 2.0, 3.0, 4.0, 1.0))
	assert_true(state.sync_elapsed(1.0))
	assert_eq(state.state_name(), &"elite_warning")
	assert_true(state.sync_elapsed(2.0))
	assert_eq(state.state_name(), &"elite_active")
	assert_true(state.mark_elite_cleared())
	assert_eq(state.state_name(), &"trace_available")
	assert_false(state.normal_spawning_allowed())
	assert_true(state.recover_trace())
	assert_eq(state.state_name(), &"trace_recovered")
	assert_true(state.normal_spawning_allowed())
	assert_true(state.sync_elapsed(3.0))
	assert_eq(state.state_name(), &"boss_warning")
	assert_true(state.sync_elapsed(4.0))
	assert_eq(state.state_name(), &"boss_active")
	assert_false(state.normal_spawning_allowed())
	assert_true(state.mark_boss_cleared())
	var final: Dictionary = state.get_snapshot()
	assert_eq(final["state"], &"cleared")
	assert_true(bool(final["elite_cleared"]))
	assert_true(bool(final["trace_recovered"]))
	assert_true(bool(final["boss_requested"]))
	assert_false(bool(final["normal_spawning_allowed"]))
	assert_almost_eq(float(final["elapsed_seconds"]), 4.0, 0.001)


func test_equal_elapsed_sync_at_each_threshold_is_idempotent_and_does_not_duplicate_events() -> void:
	var state = _new_state()
	assert_true(state.configure_timing(1.0, 2.0, 3.0, 4.0, 1.0))
	var events: Array[StringName] = []
	state.elite_warning_requested.connect(func(): events.append(&"elite_warning"))
	state.elite_requested.connect(func(): events.append(&"elite"))
	state.boss_warning_requested.connect(func(): events.append(&"boss_warning"))
	state.boss_requested.connect(func(): events.append(&"boss"))

	assert_true(state.sync_elapsed(1.0))
	assert_true(state.sync_elapsed(1.0))
	assert_true(state.sync_elapsed(2.0))
	assert_true(state.sync_elapsed(2.0))
	assert_true(state.mark_elite_cleared())
	assert_true(state.recover_trace())
	assert_true(state.sync_elapsed(3.0))
	assert_true(state.sync_elapsed(3.0))
	assert_true(state.sync_elapsed(4.0))
	assert_true(state.sync_elapsed(4.0))
	assert_eq(events, [&"elite_warning", &"elite", &"boss_warning", &"boss"])


func test_early_and_late_trace_recovery_preserve_distinct_warning_start_semantics() -> void:
	var early = _new_state()
	assert_true(early.configure_timing(1.0, 2.0, 3.0, 4.0, 1.0))
	assert_true(early.sync_elapsed(2.0))
	assert_true(early.mark_elite_cleared())
	assert_true(early.recover_trace())
	assert_true(early.sync_elapsed(10.0))
	assert_eq(early.state_name(), &"boss_active")
	assert_almost_eq(float(early.get_snapshot()["boss_warning_started_at_seconds"]), 3.0, 0.001)

	var late = _new_state()
	assert_true(late.configure_timing(1.0, 2.0, 3.0, 4.0, 1.0))
	assert_true(late.sync_elapsed(2.0))
	assert_true(late.mark_elite_cleared())
	assert_true(late.sync_elapsed(10.0))
	assert_true(late.recover_trace())
	assert_eq(late.state_name(), &"boss_warning")
	assert_almost_eq(float(late.get_snapshot()["boss_warning_started_at_seconds"]), 10.0, 0.001)
	assert_true(late.sync_elapsed(10.999))
	assert_eq(late.state_name(), &"boss_warning")
	assert_true(late.sync_elapsed(11.0))
	assert_eq(late.state_name(), &"boss_active")


func test_snapshot_state_flags_and_spawn_permission_are_consistent_at_every_gate() -> void:
	var state = _new_state()
	assert_true(state.configure_timing(1.0, 2.0, 3.0, 4.0, 1.0))
	_assert_snapshot(state, &"core", false, false, false, true)
	assert_true(state.sync_elapsed(1.0))
	_assert_snapshot(state, &"elite_warning", false, false, false, true)
	assert_true(state.sync_elapsed(2.0))
	_assert_snapshot(state, &"elite_active", false, false, false, true)
	assert_true(state.mark_elite_cleared())
	_assert_snapshot(state, &"trace_available", true, false, false, false)
	assert_true(state.recover_trace())
	_assert_snapshot(state, &"trace_recovered", true, true, false, true)
	assert_true(state.sync_elapsed(3.0))
	_assert_snapshot(state, &"boss_warning", true, true, false, true)
	assert_true(state.sync_elapsed(4.0))
	_assert_snapshot(state, &"boss_active", true, true, true, false)
	assert_true(state.mark_boss_cleared())
	_assert_snapshot(state, &"cleared", true, true, true, false)


func test_permission_events_are_exactly_trace_pause_recovery_resume_and_boss_pause() -> void:
	var state = _new_state()
	assert_true(state.configure_timing(1.0, 2.0, 3.0, 4.0, 1.0))
	var permission_events: Array[bool] = []
	state.normal_spawn_permission_changed.connect(func(allowed: bool): permission_events.append(allowed))
	assert_true(state.sync_elapsed(2.0))
	assert_true(state.mark_elite_cleared())
	assert_true(state.recover_trace())
	assert_true(state.sync_elapsed(3.0))
	assert_true(state.sync_elapsed(4.0))
	assert_true(state.mark_boss_cleared())
	assert_eq(permission_events, [false, true, false])


func test_source_keeps_stageflow_and_runtime_authorities_outside_encounter_gate() -> void:
	var source := FileAccess.get_file_as_string(ENCOUNTER_STATE_PATH).to_lower()
	for forbidden_fragment in [
		"func _process",
		"stageflowcontroller",
		"maincontroller",
		"wavespawner",
		"runbuildstate",
		"restrewardcontroller",
		"encountercatalog",
	]:
		assert_false(source.contains(forbidden_fragment), "T10 gate must remain a narrow lifecycle owner: %s" % forbidden_fragment)
	var state = _new_state()
	for property_name in [
		&"elite_warning_at_seconds",
		&"elite_spawn_at_seconds",
		&"boss_warning_earliest_at_seconds",
		&"boss_appearance_earliest_at_seconds",
		&"boss_warning_duration_seconds",
	]:
		assert_false(_has_property(state, property_name))


func _new_state():
	return load(ENCOUNTER_STATE_PATH).new()


func _assert_snapshot(state, expected_state: StringName, elite_cleared: bool, trace_recovered: bool, boss_requested: bool, spawning_allowed: bool) -> void:
	var snapshot: Dictionary = state.get_snapshot()
	assert_eq(snapshot["state"], expected_state)
	assert_eq(bool(snapshot["elite_cleared"]), elite_cleared)
	assert_eq(bool(snapshot["trace_recovered"]), trace_recovered)
	assert_eq(bool(snapshot["boss_requested"]), boss_requested)
	assert_eq(bool(snapshot["normal_spawning_allowed"]), spawning_allowed)


func _has_property(object: Object, property_name: StringName) -> bool:
	for property in object.get_property_list():
		if StringName(property.get("name", "")) == property_name:
			return true
	return false
