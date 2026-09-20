extends "res://tests/support/selected_profile_fixture.gd"

func _forge_request(fixture: Dictionary, slot := "melee") -> Dictionary:
	return {"run_id": "run:trace", "prepare_session_id": "prepare:after:1", "slot": slot,
		"expected_revision": int(fixture.profile.revision),
		"expected_prepare_revision": int(fixture.profile.active_run.preparation.revision),
		"expected_equipment_revision": int(fixture.profile.active_run.preparation.equipment.revision)}

func test_forge_persists_cost_outcome_and_reopen_duplicate_once() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_forge"))
	if not c.has_method("commit_selected_forge"): return
	var request := _forge_request(f)
	var result: Dictionary = c.commit_selected_forge(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(int(result.profile.active_run.preparation.gold), 130)
	assert_eq(int(result.profile.active_run.preparation.equipment.upgrade_rank_by_instance.gear_katana), 1 if result.outcome.succeeded else 0)
	assert_eq(result.profile.active_run.checkpoint, f.profile.active_run.checkpoint)
	assert_eq(int(result.profile.active_run.preparation.revision), 1)
	var reopened = STORE.new()
	reopened.configure_profile(f.path)
	var again = _coordinator(reopened)
	var replay: Dictionary = again.commit_selected_forge(request)
	assert_true(replay.ok and replay.already_applied)
	assert_eq(replay.profile, reopened.load_profile().profile)
	assert_eq(int(replay.profile.active_run.preparation.gold), 130)

func test_forge_io_failure_preserves_save_and_retry_keeps_same_result() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_forge"))
	if not c.has_method("commit_selected_forge"): return
	var request := _forge_request(f)
	var before := FileAccess.get_file_as_bytes(f.path)
	f.store.fail_open = true
	assert_false(c.commit_selected_forge(request).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)
	f.store.fail_open = false
	var result: Dictionary = c.commit_selected_forge(request)
	assert_true(result.ok)
	assert_eq(int(f.store.load_profile().profile.active_run.preparation.gold), 130)
	assert_eq(f.store.load_profile().profile.active_run.preparation.access, f.profile.active_run.preparation.access)

func test_forge_refuses_insufficient_money_stale_or_client_supplied_outcome() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_forge"))
	if not c.has_method("commit_selected_forge"): return
	var request := _forge_request(f)
	for field in ["roll", "cost", "succeeded"]:
		var forged := request.duplicate(true)
		forged[field] = 0
		assert_false(c.commit_selected_forge(forged).ok)
	var poor: Dictionary = f.profile.duplicate(true)
	poor.active_run.preparation.gold = 19
	assert_true(f.store.transact_profile(poor, 1, "prepare:poor").ok)
	assert_false(c.commit_selected_forge(request).ok)
	f.profile = f.store.load_profile().profile
	var before := FileAccess.get_file_as_bytes(f.path)
	var result: Dictionary = c.commit_selected_forge(_forge_request(f))
	assert_false(result.ok)
	assert_eq(result.reason, &"insufficient_gold")
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)

func test_forge_failure_is_paid_without_destroying_rank_or_imbuement() -> void:
	var saw_failure := false
	var saw_success := false
	for attempt in range(12):
		var f := _fixture()
		var c = _coordinator(f.store)
		assert_true(c.has_method("commit_selected_forge"))
		if not c.has_method("commit_selected_forge"): return
		assert_true(c.commit_selected_trace(_request(f)).ok)
		f.profile = f.store.load_profile().profile
		# Different durable preparation revisions represent different paid attempts.
		for prior in range(attempt):
			var changed: Dictionary = f.profile.duplicate(true)
			changed.active_run.preparation.revision += 1
			assert_true(f.store.transact_profile(changed, int(f.profile.revision), "setup:%s" % prior).ok)
			f.profile = f.store.load_profile().profile
		var result: Dictionary = c.commit_selected_forge(_forge_request(f))
		assert_true(result.ok, str(result))
		if not result.ok: continue
		assert_eq(int(result.profile.active_run.preparation.gold), 130)
		assert_eq(result.profile.active_run.preparation.equipment.imbuements.gear_katana, ["cheonsul"])
		if result.outcome.succeeded:
			saw_success = true
		else:
			saw_failure = true
			assert_eq(int(result.profile.active_run.preparation.equipment.upgrade_rank_by_instance.gear_katana), 0)
	assert_true(saw_failure, "Both actual receipt-derived outcomes must be covered")
	assert_true(saw_success)

func test_preview_is_pure_and_changes_only_trace_and_selected_equipment() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	var before := FileAccess.get_file_as_string(fixture.path)
	var request := _request(fixture)
	var result: Dictionary = coordinator.prepare_selected_trace(request)
	assert_true(result.ok, str(result))
	if not result.ok:
		return
	assert_eq(result.profile.active_run.preparation.equipment.upgrade_rank_by_instance.gear_katana, 0)
	assert_eq(result.profile.active_run.preparation.equipment.imbuements.gear_katana, ["cheonsul"])
	assert_eq(result.profile.active_run.preparation.access.trace_decisions.cheonsul,
		{"choice": "enhance", "equipment_instance": "gear_katana", "imbuement": "cheonsul"})
	assert_eq(result.profile.active_run.checkpoint, fixture.profile.active_run.checkpoint)
	assert_eq(result.profile.meta, fixture.profile.meta)
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)
	assert_eq(request, _request(fixture))

func test_trace_commit_persists_together_without_mutating_departure() -> void:
	for slot in ["melee", "projectile", "outfit"]:
		var fixture := _fixture()
		var coordinator = _coordinator(fixture.store)
		if coordinator == null:
			return
		var result: Dictionary = coordinator.commit_selected_trace(_request(fixture, "enhance", slot))
		assert_true(result.ok, str(result))
		if not result.ok:
			continue
		var reopened = STORE.new()
		reopened.configure_profile(fixture.path)
		var profile: Dictionary = reopened.load_profile().profile
		assert_eq(profile.revision, 2)
		assert_eq(int(profile.active_run.preparation.revision), 1)
		var ranks: Dictionary = profile.active_run.preparation.equipment.upgrade_rank_by_instance
		assert_eq(int(ranks.gear_katana), 0)
		assert_eq(int(ranks.gear_shuriken), 0)
		assert_eq(int(ranks.gear_ninja_suit), 0)
		var instance_id: String = profile.active_run.preparation.equipment.equipped_slots[slot]
		assert_eq(profile.active_run.preparation.equipment.imbuements[instance_id], ["cheonsul"])
		assert_eq(profile.active_run.preparation.access.unlocked_ninjutsu_school_ids, ["bongma"])
		assert_eq(profile.active_run.checkpoint, fixture.profile.active_run.checkpoint)
		assert_eq(profile.active_run.preparation.spatial_session, fixture.profile.active_run.preparation.spatial_session)
		assert_eq(profile.active_run.preparation.reward_state, fixture.profile.active_run.preparation.reward_state)
		assert_eq(int(profile.active_run.preparation.gold), 150)

func test_absorption_unlocks_candidates_without_granting_a_book_or_upgrade() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	var result: Dictionary = coordinator.commit_selected_trace(_request(fixture, "absorb", ""))
	assert_true(result.ok, str(result))
	if result.ok:
		var preparation: Dictionary = result.profile.active_run.preparation
		assert_eq(preparation.access.unlocked_ninjutsu_school_ids, ["bongma", "cheonsul"])
		assert_eq(preparation.equipment, fixture.profile.active_run.preparation.equipment)
		assert_eq(preparation.loadout, fixture.profile.active_run.preparation.loadout)
		assert_eq(preparation.spatial_session, fixture.profile.active_run.preparation.spatial_session)

func test_starting_school_keeps_books_and_rejects_redundant_absorption() -> void:
	var fixture := _fixture(&"guiin", &"guiin")
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	assert_false(coordinator.commit_selected_trace(_request(fixture, "absorb", "")).ok)
	assert_eq(fixture.store.load_profile().profile, fixture.profile)
	var result: Dictionary = coordinator.commit_selected_trace(_request(fixture))
	assert_true(result.ok)
	if result.ok:
		assert_eq(result.profile.active_run.preparation.loadout, fixture.profile.active_run.preparation.loadout)
		assert_eq(result.profile.active_run.preparation.access.unlocked_ninjutsu_school_ids, ["guiin"])

func test_reopen_and_repeated_identical_request_never_upgrade_twice() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	var request := _request(fixture)
	assert_true(coordinator.commit_selected_trace(request).ok)
	var before := FileAccess.get_file_as_string(fixture.path)
	var reopened = STORE.new()
	reopened.configure_profile(fixture.path)
	var other = _coordinator(reopened)
	var result: Dictionary = other.commit_selected_trace(JSON.parse_string(JSON.stringify(request)))
	assert_true(result.ok, str(result))
	assert_true(result.get("already_applied", false))
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)
	assert_false(other.commit_selected_trace(_request(fixture, "enhance", "outfit")).ok)
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)

func test_stale_run_session_revisions_and_malformed_intent_do_not_write() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	var before := FileAccess.get_file_as_string(fixture.path)
	for key in _request(fixture):
		var request := _request(fixture)
		request[key] = null
		assert_false(coordinator.commit_selected_trace(request).ok, key)
	for pair in [["run_id", "wrong"], ["prepare_session_id", "old"], ["expected_revision", 0],
		["expected_prepare_revision", 1], ["expected_equipment_revision", 1], ["school_id", "heukyeong"],
		["choice", "both"], ["slot", "unknown"], ["expected_revision", 1.5]]:
		var request := _request(fixture)
		request[pair[0]] = pair[1]
		assert_false(coordinator.commit_selected_trace(request).ok, str(pair))
	var unknown := _request(fixture)
	unknown.gold = 999
	assert_false(coordinator.commit_selected_trace(unknown).ok)
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)

func test_io_failure_preserves_decision_and_equipment_then_retry_applies_once() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	fixture.store.fail_open = true
	var before := FileAccess.get_file_as_string(fixture.path)
	assert_false(coordinator.commit_selected_trace(_request(fixture)).ok)
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)
	fixture.store.fail_open = false
	assert_true(coordinator.commit_selected_trace(_request(fixture)).ok)
	assert_eq(fixture.store.load_profile().profile.active_run.preparation.equipment.imbuements.gear_katana, ["cheonsul"])

func test_reentrant_commit_is_rejected_during_io_and_returned_values_are_detached() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	var nested: Array = []
	fixture.store.on_write = func(): nested.append(coordinator.commit_selected_trace(_request(fixture)))
	var result: Dictionary = coordinator.commit_selected_trace(_request(fixture))
	assert_true(result.ok, str(result))
	assert_eq(nested.size(), 1)
	assert_false(nested[0].ok)
	if result.ok:
		result.profile.active_run.preparation.equipment.upgrade_rank_by_instance.gear_katana = 4
		assert_eq(int(fixture.store.load_profile().profile.active_run.preparation.equipment.upgrade_rank_by_instance.gear_katana), 0)
		assert_eq(fixture.store.load_profile().profile.active_run.preparation.equipment.imbuements.gear_katana, ["cheonsul"])
	fixture.store.on_write = Callable()

func test_preview_must_not_override_a_newer_saved_preparation() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	assert_true(coordinator.prepare_selected_trace(_request(fixture)).ok)
	var changed: Dictionary = fixture.profile.duplicate(true)
	changed.active_run.preparation.gold = 120
	changed.active_run.preparation.revision = 1
	assert_true(fixture.store.transact_profile(changed, 1, "prepare:shop").ok)
	var before := FileAccess.get_file_as_string(fixture.path)
	assert_false(coordinator.commit_selected_trace(_request(fixture)).ok)
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)

func test_post_write_reload_failure_reports_persistence_and_retries_without_duplication() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	fixture.store.fail_read_after_write = true
	var result: Dictionary = coordinator.commit_selected_trace(_request(fixture))
	assert_false(result.ok)
	assert_true(result.get("persisted", false))
	assert_eq(result.get("reason"), &"committed_reload_required")
	fixture.store.read_blocked = false
	fixture.store.fail_read_after_write = false
	var retry: Dictionary = coordinator.commit_selected_trace(_request(fixture))
	assert_true(retry.ok)
	assert_true(retry.get("already_applied", false))
	assert_eq(retry.profile.active_run.preparation.equipment.imbuements.gear_katana, ["cheonsul"])

func test_duplicate_after_later_transaction_returns_current_profile_not_old_state() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	assert_true(coordinator.commit_selected_trace(_request(fixture)).ok)
	var changed: Dictionary = fixture.store.load_profile().profile
	changed.active_run.preparation.gold = 100
	changed.active_run.preparation.revision += 1
	assert_true(fixture.store.transact_profile(changed, 2, "prepare:later-shop").ok)
	var result: Dictionary = coordinator.commit_selected_trace(_request(fixture))
	assert_true(result.ok)
	assert_true(result.get("already_applied", false))
	assert_eq(result.profile.revision, 3)
	assert_eq(int(result.profile.active_run.preparation.gold), 100)

func test_selected_binding_cannot_switch_to_legacy_or_another_store() -> void:
	var fixture := _fixture()
	var coordinator = _coordinator(fixture.store)
	if coordinator == null:
		return
	assert_false(coordinator.configure_selected_profile(fixture.store))
	assert_false(coordinator.configure(null, null, null, null))
	var unconfigured = COORDINATOR.new()
	assert_false(unconfigured.commit_selected_trace(_request(fixture)).ok)
