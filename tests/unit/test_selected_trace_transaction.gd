extends GutTest

const COORDINATOR = preload("res://scripts/core/rest_commit_coordinator.gd")
const CODEC = preload("res://scripts/core/run_resume_codec.gd")
const STORE = preload("res://scripts/core/run_resume_store.gd")
const START = preload("res://scripts/core/start_loadout_session.gd")
const ROUTE = preload("res://scripts/core/run_route_state.gd")
const ACCESS = preload("res://scripts/core/tradition_access_state.gd")
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const SPATIAL = preload("res://scripts/backpack/rest_backpack_session.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const CATALOG = preload("res://scripts/data/selected_backpack_catalog.gd")
const BAGS = preload("res://scripts/data/mvp4_catalog.gd")
const FATES = preload("res://scripts/data/mvp3_catalog.gd")
const MODIFIERS = preload("res://scripts/data/run_modifier_set.gd")

var root: String
var fixture_index := 0

class FailingStore:
	extends "res://scripts/core/run_resume_store.gd"
	var fail_open := false
	var fail_read_after_write := false
	var read_blocked := false
	var on_write := Callable()
	func _open_temporary_file(destination: String) -> FileAccess:
		if on_write.is_valid():
			on_write.call()
		if fail_read_after_write:
			read_blocked = true
		return null if fail_open else super._open_temporary_file(destination)
	func load_profile() -> Dictionary:
		return {"ok": false, "reason": &"unreadable"} if read_blocked else super.load_profile()

func before_each() -> void:
	root = "user://gut_trace_transaction_%s_%s" % [OS.get_process_id(), Time.get_ticks_usec()]
	assert_eq(DirAccess.make_dir_recursive_absolute(root), OK)
	fixture_index = 0

func after_each() -> void:
	assert_true(root.begins_with("user://gut_trace_transaction_"))
	for file in DirAccess.get_files_at(root):
		DirAccess.remove_absolute(root.path_join(file))
	DirAccess.remove_absolute(root)

func _fixture(origin: StringName = &"bongma", battlefield: StringName = &"cheonsul") -> Dictionary:
	fixture_index += 1
	var start = add_child_autofree(START.new())
	assert_true(start.begin(origin, 42))
	for unused in range(2):
		assert_true(start.choose(start.snapshot().draft.options[0]))
	assert_true(start.confirm())
	var bundle: Dictionary = start.committed_snapshot()
	var route = ROUTE.new()
	assert_true(route.set_provisional_next_school(battlefield))
	assert_true(route.commit_provisional_next_school())
	var checkpoint := {
		"rules_version": CODEC.PROFILE_CONTRACT, "prepare_session_id": "departure:initial",
		"build": {"gold": 0, "selected_school_id": origin, "owned_items": {}, "selected_fates": [],
			"economy_receipts": [], "equipment": bundle.equipment,
			"committed_backpack_modifiers": MODIFIERS.new().to_persistent_snapshot()},
		"route": route.get_route_snapshot(), "circuit": {"phase": "core", "active_school_id": battlefield},
		"backpack": bundle.backpack, "buffer": [], "loadout": bundle.loadout, "access": bundle.access,
		"ultimate_charge": {"school_id": origin, "resource_amount": 0}}
	var access = ACCESS.new()
	assert_true(access.restore_selected_snapshot(bundle.access))
	assert_true(access.stabilize_school(battlefield))
	var spatial = SPATIAL.new()
	assert_true(spatial.begin(BAG.from_persistent_snapshot(bundle.backpack), RESOLVER.new(),
		CATALOG.build_items(), BAGS.build_bags(), origin, [], true))
	var build = add_child_autofree(load("res://scripts/core/run_build_state.gd").new())
	build.configure(CATALOG.build_items(), FATES.build_fates())
	var rewards = add_child_autofree(load("res://scripts/core/rest_reward_controller.gd").new())
	var rng := RandomNumberGenerator.new()
	rng.seed = 75
	rewards.configure(build, spatial, CATALOG.build_items(), BAGS.build_bags(), rng, access)
	rewards.begin_rest(1, origin, 1, battlefield)
	var preparation := {"prepare_session_id": "prepare:after:1", "phase": "preparing", "revision": 0,
		"access": access.get_snapshot(), "equipment": bundle.equipment,
		"spatial_session": spatial.persistent_preparation_snapshot(), "loadout": bundle.loadout,
		"gold": 150, "reward_state": rewards.persistent_snapshot(), "pending_fate": "",
		"provisional_school": "", "healing_applied": true}
	var raw := {"schema_version": 2, "revision": 0, "content_contract": CODEC.PROFILE_CONTRACT,
		"meta": {"soul_balance": 2, "unlocked_support_choice": false, "settled_run_ids": [],
			"applied_transaction_ids": [], "transaction_receipts": {}},
		"active_run": {"run_id": "run:trace", "starting_school": str(origin), "elite_qualified": true,
			"retry_consumed": false, "eligible_boss_ids": [str(battlefield)],
			"checkpoint": checkpoint, "preparation": preparation}}
	raw = JSON.parse_string(JSON.stringify(raw))
	var path := root.path_join("profile_%s.json" % fixture_index)
	var store = FailingStore.new()
	assert_true(store.configure_profile(path))
	assert_true(store.transact_profile(raw, 0, "prepare:initial").ok)
	return {"store": store, "profile": store.load_profile().profile, "path": path}

func _request(fixture: Dictionary, choice := "enhance", slot := "melee") -> Dictionary:
	return {"run_id": "run:trace", "prepare_session_id": "prepare:after:1",
		"school_id": fixture.profile.active_run.checkpoint.route.active_school_id,
		"choice": choice, "slot": slot, "expected_revision": 1,
		"expected_prepare_revision": 0, "expected_equipment_revision": 0}

func _coordinator(store):
	var result = COORDINATOR.new()
	assert_true(result.has_method("configure_selected_profile"), "Missing durable preparation business transaction")
	if not result.has_method("configure_selected_profile"):
		return null
	assert_true(result.configure_selected_profile(store))
	return result

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
	assert_eq(result.profile.active_run.preparation.equipment.upgrade_rank_by_instance.gear_katana, 1)
	assert_eq(result.profile.active_run.preparation.access.trace_decisions.cheonsul,
		{"choice": "enhance", "equipment_instance": "gear_katana", "rank": 1})
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
		assert_eq(int(ranks.gear_katana), 1 if slot == "melee" else 0)
		assert_eq(int(ranks.gear_shuriken), 1 if slot == "projectile" else 0)
		assert_eq(int(ranks.gear_ninja_suit), 1 if slot == "outfit" else 0)
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
	assert_eq(int(fixture.store.load_profile().profile.active_run.preparation.equipment.upgrade_rank_by_instance.gear_katana), 1)

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
		assert_eq(int(fixture.store.load_profile().profile.active_run.preparation.equipment.upgrade_rank_by_instance.gear_katana), 1)
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
	assert_eq(int(retry.profile.active_run.preparation.equipment.upgrade_rank_by_instance.gear_katana), 1)

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
