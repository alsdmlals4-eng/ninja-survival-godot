extends "res://tests/support/selected_profile_fixture.gd"

const ENCOUNTER = preload("res://scripts/core/stage_encounter_state.gd")

func test_rest_persists_battle_charge_and_rejects_invalid_charge() -> void:
	var f := _departure_fixture()
	var c = _coordinator(f.store)
	var request := _entry_request(f)
	request["ultimate_charge"] = {"school_id": "bongma", "resource_amount": 73.5}
	var bad := request.duplicate(true)
	bad.ultimate_charge.resource_amount = 121
	assert_false(c.commit_selected_entry(bad).ok)
	var result: Dictionary = c.commit_selected_entry(request)
	assert_true(result.ok, str(result))
	if result.ok:
		assert_eq(result.profile.active_run.preparation.ultimate_charge, request.ultimate_charge)
		assert_eq(float(result.profile.active_run.checkpoint.ultimate_charge.resource_amount), 0.0)

func _departure_fixture() -> Dictionary:
	var f := _fixture()
	var profile: Dictionary = f.profile.duplicate(true)
	profile.active_run.preparation = null
	profile.active_run.eligible_boss_ids = []
	profile.active_run.elite_qualified = false
	assert_true(f.store.transact_profile(profile, 1, "setup:departure").ok)
	f.profile = f.store.load_profile().profile
	return f

func _entry_request(f: Dictionary) -> Dictionary:
	var encounter = ENCOUNTER.new()
	encounter.sync_elapsed(180.0)
	encounter.mark_elite_cleared()
	encounter.recover_trace()
	encounter.sync_elapsed(300.0)
	encounter.mark_boss_cleared()
	return {"run_id": f.profile.active_run.run_id, "expected_revision": f.profile.revision,
		"departure_id": f.profile.active_run.checkpoint.prepare_session_id,
		"school_id": "cheonsul", "encounter": encounter.get_snapshot(),
		"gold": 75, "health": 30, "maximum_health": 100, "emergency_potions": 0}

func test_entry_persists_reserved_rewards_and_one_time_heal_without_changing_departure() -> void:
	var f := _departure_fixture()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_entry"))
	if not c.has_method("commit_selected_entry"): return
	var request := _entry_request(f)
	var result: Dictionary = c.commit_selected_entry(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	var prep: Dictionary = result.profile.active_run.preparation
	assert_eq(int(prep.gold), 75)
	assert_eq(int(prep.vitals.health), 55)
	assert_eq(int(prep.vitals.max_health), 100)
	assert_true(prep.healing_applied)
	assert_eq(int(prep.reward_state.chests), 1)
	assert_true(prep.reward_state.boss_pending)
	assert_eq(prep.fate_state.candidate_ids.size(), 3)
	assert_eq(result.profile.active_run.checkpoint, f.profile.active_run.checkpoint)
	assert_eq(result.profile.active_run.eligible_boss_ids, ["cheonsul"])
	assert_true(result.profile.active_run.elite_qualified)
	var again: Dictionary = c.commit_selected_entry(request)
	assert_true(again.ok and again.already_applied)
	assert_eq(again.profile, result.profile)
	var reopened = STORE.new()
	reopened.configure_profile(f.path)
	assert_eq(reopened.load_profile().profile.active_run.preparation, prep)

func test_entry_rejects_missing_encounter_gates_and_invalid_values_without_writes() -> void:
	var f := _departure_fixture()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_entry"))
	if not c.has_method("commit_selected_entry"): return
	var original := _entry_request(f)
	var before := FileAccess.get_file_as_bytes(f.path)
	for field in ["elite_cleared", "trace_recovered", "boss_requested"]:
		var changed := original.duplicate(true)
		changed.encounter[field] = false
		assert_false(c.commit_selected_entry(changed).ok, field)
	for replacement in [{"health": 0}, {"health": 101}, {"health": NAN}, {"gold": -1},
		{"gold": 0.5}, {"school_id": "guiin"}, {"departure_id": "stale"}, {"expected_revision": 1}, {"emergency_potions": 1}]:
		var changed := original.duplicate(true)
		changed.merge(replacement, true)
		assert_false(c.commit_selected_entry(changed).ok, str(replacement))
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)

func test_entry_io_failure_does_not_publish_healing_or_reroll_candidates() -> void:
	var f := _departure_fixture()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_entry"))
	if not c.has_method("commit_selected_entry"): return
	var request := _entry_request(f)
	var before := FileAccess.get_file_as_bytes(f.path)
	f.store.fail_open = true
	assert_false(c.commit_selected_entry(request).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)
	f.store.fail_open = false
	assert_true(c.commit_selected_entry(request).ok)
	var saved: Dictionary = f.store.load_profile().profile
	assert_eq(int(saved.active_run.preparation.vitals.health), 55)
	assert_true(c.commit_selected_entry(request).already_applied)
	assert_eq(f.store.load_profile().profile, saved)

func test_codec_rejects_bad_vitals_and_accepts_older_missing_vitals() -> void:
	var f := _fixture()
	assert_true(CODEC.new().decode_profile_v2(f.profile).ok)
	for health in [-1, 101, 1.5, NAN]:
		var candidate: Dictionary = f.profile.duplicate(true)
		candidate.active_run.preparation.vitals = {"health": health, "max_health": 100, "emergency_potions": 0}
		assert_false(CODEC.new().decode_profile_v2(candidate).ok)
	var valid: Dictionary = f.profile.duplicate(true)
	valid.active_run.preparation.vitals = {"health": 80, "max_health": 100, "emergency_potions": 0}
	assert_true(CODEC.new().decode_profile_v2(valid).ok)

func test_entry_preserves_actual_consumable_remainder_not_departure_quantity() -> void:
	for remaining in [0, 1]:
		var f := _departure_fixture()
		var profile: Dictionary = f.profile.duplicate(true)
		profile.active_run.checkpoint.vitals = {"health": 100, "max_health": 100, "emergency_potions": 1}
		assert_true(f.store.transact_profile(profile, int(f.profile.revision), "setup:medicine").ok)
		f.profile = f.store.load_profile().profile
		var c = _coordinator(f.store)
		var request := _entry_request(f)
		request.emergency_potions = remaining
		var result: Dictionary = c.commit_selected_entry(request)
		assert_true(result.ok, str(result))
		if result.ok:
			assert_eq(int(result.profile.active_run.preparation.vitals.emergency_potions), remaining)
