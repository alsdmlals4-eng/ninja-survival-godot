extends GutTest

const ENCOUNTER_STATE_PATH := "res://scripts/core/stage_encounter_state.gd"
const WAVE_SPAWNER_PATH := "res://scripts/spawning/wave_spawner.gd"


func test_timing_mutation_has_no_public_property_bypass() -> void:
	var state = _new_state()
	for property_name in [
		&"elite_warning_at_seconds",
		&"elite_spawn_at_seconds",
		&"boss_warning_earliest_at_seconds",
		&"boss_appearance_earliest_at_seconds",
		&"boss_warning_duration_seconds",
	]:
		assert_false(_has_property(state, property_name), "Timing authority must go through configure_timing: %s" % property_name)


func test_configure_timing_and_elapsed_reject_nonfinite_or_mid_encounter_mutation() -> void:
	var state = _new_state()
	var initial: Dictionary = state.get_snapshot()
	assert_false(state.configure_timing(NAN, 180.0, 260.0, 270.0, 10.0))
	assert_false(state.configure_timing(165.0, INF, 260.0, 270.0, 10.0))
	assert_eq(state.get_snapshot(), initial)

	assert_false(state.sync_elapsed(NAN))
	assert_false(state.sync_elapsed(INF))
	assert_eq(state.get_snapshot(), initial)

	assert_true(state.sync_elapsed(1.0))
	var after_start: Dictionary = state.get_snapshot()
	assert_false(state.configure_timing(1.0, 2.0, 3.0, 4.0, 1.0))
	assert_eq(state.get_snapshot(), after_start)


func test_early_recovery_large_time_jump_uses_canonical_warning_start_and_requests_boss_once() -> void:
	var state = _new_state()
	var events: Array[StringName] = []
	state.boss_warning_requested.connect(func(): events.append(&"warning"))
	state.boss_requested.connect(func(): events.append(&"boss"))

	assert_true(state.sync_elapsed(180.0))
	assert_true(state.mark_elite_cleared())
	assert_true(state.sync_elapsed(200.0))
	assert_true(state.recover_trace())
	assert_eq(state.state_name(), &"trace_recovered")
	assert_true(state.sync_elapsed(500.0))
	assert_eq(state.state_name(), &"boss_active")
	assert_almost_eq(float(state.get_snapshot()["boss_warning_started_at_seconds"]), 260.0, 0.001)
	assert_eq(events, [&"warning", &"boss"])
	assert_true(state.sync_elapsed(600.0))
	assert_eq(events, [&"warning", &"boss"], "Equal/later sync must never duplicate warning or boss requests")


func test_external_observers_never_see_half_committed_elite_or_boss_transitions() -> void:
	var state = _new_state()
	var elite_clear_views: Array[Dictionary] = []
	var boss_views: Array[Dictionary] = []
	state.chest_token_requested.connect(func(_amount: int): elite_clear_views.append(state.get_snapshot()))
	state.trace_spawn_requested.connect(func(): elite_clear_views.append(state.get_snapshot()))
	state.boss_requested.connect(func(): boss_views.append(state.get_snapshot()))

	assert_true(state.sync_elapsed(180.0))
	assert_true(state.mark_elite_cleared())
	assert_eq(elite_clear_views.size(), 2)
	for snapshot in elite_clear_views:
		assert_eq(snapshot["state"], &"trace_available")
		assert_true(bool(snapshot["elite_cleared"]))
		assert_false(bool(snapshot["normal_spawning_allowed"]))

	assert_true(state.sync_elapsed(260.0))
	assert_true(state.recover_trace())
	assert_true(state.sync_elapsed(270.0))
	assert_eq(boss_views.size(), 1)
	assert_eq(boss_views[0]["state"], &"boss_active")
	assert_true(bool(boss_views[0]["boss_requested"]))
	assert_false(bool(boss_views[0]["normal_spawning_allowed"]))


func test_wave_spawner_remains_an_actuator_of_permission_facts_not_gate_authority() -> void:
	var state = _new_state()
	var spawner = load(WAVE_SPAWNER_PATH).new()
	assert_true(spawner.has_method(&"set_spawning_enabled"), "WaveSpawner must remain a one-way spawn-permission actuator")
	spawner.free()

	var permission_events: Array[bool] = []
	state.normal_spawn_permission_changed.connect(func(allowed: bool): permission_events.append(allowed))
	assert_true(state.sync_elapsed(180.0))
	assert_true(state.mark_elite_cleared())
	assert_eq(state.state_name(), &"trace_available")
	assert_true(state.sync_elapsed(200.0))
	assert_true(state.recover_trace())
	assert_eq(state.state_name(), &"trace_recovered")
	assert_true(state.sync_elapsed(270.0))
	assert_eq(state.state_name(), &"boss_active")
	assert_eq(permission_events, [false, true, false], "Gate publishes facts; actuator decides only whether to spawn")


func test_failed_operations_are_total_noops_across_lifecycle() -> void:
	var state = _new_state()
	var initial: Dictionary = state.get_snapshot()
	assert_false(state.mark_elite_cleared())
	assert_false(state.recover_trace())
	assert_false(state.mark_boss_cleared())
	assert_eq(state.get_snapshot(), initial)

	assert_true(state.sync_elapsed(180.0))
	var elite_active: Dictionary = state.get_snapshot()
	assert_false(state.recover_trace())
	assert_false(state.mark_boss_cleared())
	assert_eq(state.get_snapshot(), elite_active)

	assert_true(state.mark_elite_cleared())
	var trace_available: Dictionary = state.get_snapshot()
	assert_false(state.mark_elite_cleared())
	assert_false(state.mark_boss_cleared())
	assert_eq(state.get_snapshot(), trace_available)

	assert_true(state.sync_elapsed(260.0))
	assert_true(state.recover_trace())
	var boss_warning: Dictionary = state.get_snapshot()
	assert_false(state.mark_elite_cleared())
	assert_false(state.recover_trace())
	assert_false(state.mark_boss_cleared())
	assert_eq(state.get_snapshot(), boss_warning)

	assert_true(state.sync_elapsed(270.0))
	assert_true(state.mark_boss_cleared())
	var cleared: Dictionary = state.get_snapshot()
	assert_false(state.mark_elite_cleared())
	assert_false(state.recover_trace())
	assert_false(state.mark_boss_cleared())
	assert_eq(state.get_snapshot(), cleared)


func test_gate_exposes_no_generic_force_state_or_reward_economy_api() -> void:
	var state = _new_state()
	for method_name in [
		&"set_state",
		&"force_state",
		&"set_elite_cleared",
		&"set_trace_recovered",
		&"set_boss_requested",
		&"grant_gold",
		&"grant_style",
		&"grant_reward_orb",
	]:
		assert_false(state.has_method(method_name), "Encounter gate must not expose authority bypass: %s" % method_name)
	var source := FileAccess.get_file_as_string(ENCOUNTER_STATE_PATH).to_lower()
	for forbidden_fragment in ["runbuildstate", "restrewardcontroller", "rewardorb", "grant_gold", "style_score"]:
		assert_false(source.contains(forbidden_fragment), "Encounter gate must not own reward/economy authority: %s" % forbidden_fragment)


func test_zero_warning_duration_still_respects_earliest_boss_appearance() -> void:
	var state = _new_state()
	assert_true(state.configure_timing(1.0, 2.0, 3.0, 4.0, 0.0))
	var events: Array[StringName] = []
	state.boss_warning_requested.connect(func(): events.append(&"warning"))
	state.boss_requested.connect(func(): events.append(&"boss"))
	assert_true(state.sync_elapsed(2.0))
	assert_true(state.mark_elite_cleared())
	assert_true(state.sync_elapsed(3.0))
	assert_true(state.recover_trace())
	assert_eq(events, [&"warning"])
	assert_eq(state.state_name(), &"boss_warning")
	assert_true(state.sync_elapsed(3.999))
	assert_eq(events, [&"warning"])
	assert_true(state.sync_elapsed(4.0))
	assert_eq(events, [&"warning", &"boss"])
	assert_eq(state.state_name(), &"boss_active")


func _new_state():
	return load(ENCOUNTER_STATE_PATH).new()


func _has_property(object: Object, property_name: StringName) -> bool:
	for property in object.get_property_list():
		if StringName(property.get("name", "")) == property_name:
			return true
	return false
