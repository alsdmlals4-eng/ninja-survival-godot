extends GutTest

const ENCOUNTER_STATE_PATH := "res://scripts/core/stage_encounter_state.gd"


func test_t10_resource_exists() -> void:
	assert_true(ResourceLoader.exists(ENCOUNTER_STATE_PATH), "Missing T10 StageEncounterState")


func test_default_state_and_authoring_timing_match_dec024_gate() -> void:
	var state = _new_state()
	if state == null:
		return
	var snapshot: Dictionary = state.get_snapshot()
	assert_eq(snapshot["state"], &"core")
	assert_almost_eq(float(snapshot["elapsed_seconds"]), 0.0, 0.001)
	assert_almost_eq(float(snapshot["elite_warning_at_seconds"]), 165.0, 0.001)
	assert_almost_eq(float(snapshot["elite_spawn_at_seconds"]), 180.0, 0.001)
	assert_almost_eq(float(snapshot["boss_warning_earliest_at_seconds"]), 260.0, 0.001)
	assert_almost_eq(float(snapshot["boss_appearance_earliest_at_seconds"]), 270.0, 0.001)
	assert_almost_eq(float(snapshot["boss_warning_duration_seconds"]), 10.0, 0.001)
	assert_true(state.normal_spawning_allowed())
	assert_false(bool(snapshot["elite_cleared"]))
	assert_false(bool(snapshot["trace_recovered"]))
	assert_false(bool(snapshot["boss_requested"]))


func test_elapsed_sync_requests_elite_warning_and_elite_exactly_once() -> void:
	var state = _new_state()
	if state == null:
		return
	var events: Array[StringName] = []
	state.elite_warning_requested.connect(func(): events.append(&"elite_warning"))
	state.elite_requested.connect(func(): events.append(&"elite"))

	assert_true(state.sync_elapsed(164.9))
	assert_eq(events, [])
	assert_true(state.sync_elapsed(165.0))
	assert_eq(state.state_name(), &"elite_warning")
	assert_eq(events, [&"elite_warning"])
	assert_true(state.sync_elapsed(179.9))
	assert_eq(events, [&"elite_warning"])
	assert_true(state.sync_elapsed(180.0))
	assert_eq(state.state_name(), &"elite_active")
	assert_eq(events, [&"elite_warning", &"elite"])
	assert_true(state.sync_elapsed(240.0))
	assert_eq(events, [&"elite_warning", &"elite"])


func test_elite_clear_emits_chest_and_trace_once_and_pauses_only_new_normal_spawns() -> void:
	var state = _new_state()
	if state == null:
		return
	var chest_amounts: Array[int] = []
	var trace_events: int = 0
	var spawn_permissions: Array[bool] = []
	state.chest_token_requested.connect(func(amount: int): chest_amounts.append(amount))
	state.trace_spawn_requested.connect(func(): trace_events += 1)
	state.normal_spawn_permission_changed.connect(func(allowed: bool): spawn_permissions.append(allowed))

	var before: Dictionary = state.get_snapshot()
	assert_false(state.mark_elite_cleared())
	assert_eq(state.get_snapshot(), before)

	assert_true(state.sync_elapsed(180.0))
	assert_true(state.mark_elite_cleared())
	assert_eq(state.state_name(), &"trace_available")
	assert_false(state.normal_spawning_allowed())
	assert_eq(chest_amounts, [1])
	assert_eq(trace_events, 1)
	assert_eq(spawn_permissions, [false])

	var after_clear: Dictionary = state.get_snapshot()
	assert_false(state.mark_elite_cleared())
	assert_eq(state.get_snapshot(), after_clear)
	assert_eq(chest_amounts, [1])
	assert_eq(trace_events, 1)


func test_trace_available_never_expires_and_clock_input_can_continue_without_spawning_boss() -> void:
	var state = _new_state()
	if state == null:
		return
	var boss_events: int = 0
	state.boss_requested.connect(func(): boss_events += 1)
	assert_true(state.sync_elapsed(180.0))
	assert_true(state.mark_elite_cleared())
	assert_true(state.sync_elapsed(3600.0))
	assert_eq(state.state_name(), &"trace_available")
	assert_almost_eq(float(state.get_snapshot()["elapsed_seconds"]), 3600.0, 0.001)
	assert_false(state.normal_spawning_allowed())
	assert_eq(boss_events, 0)


func test_early_trace_recovery_waits_for_earliest_warning_and_boss_gate() -> void:
	var state = _new_state()
	if state == null:
		return
	var warning_events: int = 0
	var boss_events: int = 0
	var spawn_permissions: Array[bool] = []
	state.boss_warning_requested.connect(func(): warning_events += 1)
	state.boss_requested.connect(func(): boss_events += 1)
	state.normal_spawn_permission_changed.connect(func(allowed: bool): spawn_permissions.append(allowed))

	assert_true(state.sync_elapsed(180.0))
	assert_true(state.mark_elite_cleared())
	assert_true(state.sync_elapsed(200.0))
	assert_true(state.recover_trace())
	assert_eq(state.state_name(), &"trace_recovered")
	assert_true(state.normal_spawning_allowed())
	assert_eq(spawn_permissions, [false, true])
	assert_eq(warning_events, 0)
	assert_eq(boss_events, 0)

	assert_true(state.sync_elapsed(259.9))
	assert_eq(warning_events, 0)
	assert_true(state.sync_elapsed(260.0))
	assert_eq(state.state_name(), &"boss_warning")
	assert_eq(warning_events, 1)
	assert_true(state.sync_elapsed(269.9))
	assert_eq(boss_events, 0)
	assert_true(state.sync_elapsed(270.0))
	assert_eq(state.state_name(), &"boss_active")
	assert_eq(boss_events, 1)
	assert_false(state.normal_spawning_allowed())


func test_late_trace_recovery_starts_warning_immediately_and_allows_soft_overtime() -> void:
	var state = _new_state()
	if state == null:
		return
	var warning_events: int = 0
	var boss_events: int = 0
	state.boss_warning_requested.connect(func(): warning_events += 1)
	state.boss_requested.connect(func(): boss_events += 1)

	assert_true(state.sync_elapsed(180.0))
	assert_true(state.mark_elite_cleared())
	assert_true(state.sync_elapsed(310.0))
	assert_eq(state.state_name(), &"trace_available")
	assert_true(state.recover_trace())
	assert_eq(state.state_name(), &"boss_warning")
	assert_eq(warning_events, 1)
	assert_eq(boss_events, 0)

	assert_true(state.sync_elapsed(319.9))
	assert_eq(boss_events, 0)
	assert_true(state.sync_elapsed(320.0))
	assert_eq(state.state_name(), &"boss_active")
	assert_eq(boss_events, 1)
	assert_gt(float(state.get_snapshot()["elapsed_seconds"]), 300.0, "Five minutes is not a hard failure")


func test_time_alone_or_trace_recovery_alone_cannot_spawn_boss() -> void:
	var state = _new_state()
	if state == null:
		return
	var boss_events: int = 0
	state.boss_requested.connect(func(): boss_events += 1)

	assert_false(state.recover_trace())
	assert_true(state.sync_elapsed(600.0))
	assert_eq(state.state_name(), &"elite_active")
	assert_eq(boss_events, 0)

	assert_true(state.mark_elite_cleared())
	assert_eq(state.state_name(), &"trace_available")
	assert_eq(boss_events, 0)
	assert_true(state.recover_trace())
	assert_eq(state.state_name(), &"boss_warning")
	assert_eq(boss_events, 0)
	assert_true(state.sync_elapsed(609.9))
	assert_eq(boss_events, 0)
	assert_true(state.sync_elapsed(610.0))
	assert_eq(boss_events, 1)


func test_trace_recovery_is_single_use_and_separate_from_chest_reward() -> void:
	var state = _new_state()
	if state == null:
		return
	var chest_events: int = 0
	var recovery_events: int = 0
	state.chest_token_requested.connect(func(_amount: int): chest_events += 1)
	state.trace_recovered.connect(func(): recovery_events += 1)
	assert_true(state.sync_elapsed(180.0))
	assert_true(state.mark_elite_cleared())
	assert_eq(chest_events, 1)
	assert_eq(recovery_events, 0)
	assert_true(state.recover_trace())
	assert_eq(chest_events, 1)
	assert_eq(recovery_events, 1)
	assert_false(state.recover_trace())
	assert_eq(chest_events, 1)
	assert_eq(recovery_events, 1)


func test_boss_and_elite_cannot_overlap_and_boss_clear_is_terminal_once() -> void:
	var state = _new_state()
	if state == null:
		return
	var cleared_events: int = 0
	state.boss_cleared.connect(func(): cleared_events += 1)
	assert_true(state.sync_elapsed(180.0))
	assert_eq(state.state_name(), &"elite_active")
	assert_false(state.mark_boss_cleared())
	assert_true(state.mark_elite_cleared())
	assert_true(state.sync_elapsed(260.0))
	assert_true(state.recover_trace())
	assert_eq(state.state_name(), &"boss_warning")
	assert_true(state.sync_elapsed(270.0))
	assert_eq(state.state_name(), &"boss_active")
	assert_false(state.mark_elite_cleared(), "Elite cannot be cleared again while Boss is active")
	assert_true(state.mark_boss_cleared())
	assert_eq(state.state_name(), &"cleared")
	assert_eq(cleared_events, 1)
	assert_false(state.mark_boss_cleared())
	assert_eq(cleared_events, 1)
	assert_false(state.normal_spawning_allowed())


func test_elapsed_input_is_monotonic_and_invalid_backwards_time_is_atomic_noop() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_true(state.sync_elapsed(100.0))
	var before: Dictionary = state.get_snapshot()
	assert_false(state.sync_elapsed(-1.0))
	assert_eq(state.get_snapshot(), before)
	assert_false(state.sync_elapsed(99.0))
	assert_eq(state.get_snapshot(), before)
	assert_true(state.sync_elapsed(100.0), "Equal time is a valid idempotent sync")


func test_custom_timing_configuration_rejects_invalid_gate_order_without_mutation() -> void:
	var state = _new_state()
	if state == null:
		return
	var before: Dictionary = state.get_snapshot()
	assert_false(state.configure_timing(180.0, 165.0, 260.0, 270.0, 10.0))
	assert_eq(state.get_snapshot(), before)
	assert_false(state.configure_timing(10.0, 20.0, 30.0, 25.0, 10.0))
	assert_eq(state.get_snapshot(), before)
	assert_false(state.configure_timing(10.0, 20.0, 30.0, 40.0, -1.0))
	assert_eq(state.get_snapshot(), before)
	assert_true(state.configure_timing(1.0, 2.0, 3.0, 4.0, 1.0))
	assert_almost_eq(float(state.get_snapshot()["elite_warning_at_seconds"]), 1.0, 0.001)


func _new_state():
	if not ResourceLoader.exists(ENCOUNTER_STATE_PATH):
		assert_true(false, "T10 StageEncounterState must exist before behavior tests")
		return null
	return load(ENCOUNTER_STATE_PATH).new()
