extends GutTest

const CODEC = preload("res://scripts/core/run_resume_codec.gd")
const STORE = preload("res://scripts/core/run_resume_store.gd")
const TEST_PATH := "user://gut_profile_v2_20260914.json"
const LEGACY_PATH := "user://gut_legacy_wallet_migration_20260914.json"

class TemporaryFailure:
	extends "res://scripts/core/run_resume_store.gd"
	var failure := ""
	func _open_temporary_file(path: String) -> FileAccess:
		if failure == "open":
			return null
		return FileAccess.open(path, FileAccess.WRITE)
	func _store_temporary_text(file: FileAccess, text: String) -> bool:
		if failure == "write":
			file.store_string(text.left(8))
			return false
		return file.store_string(text)
	func _flush_temporary_file(file: FileAccess) -> Error:
		file.flush()
		return ERR_FILE_CANT_WRITE if failure == "flush" else file.get_error()
	func _readback_matches(path: String, text: String) -> bool:
		if failure == "readback" and path.ends_with(".tmp"):
			return false
		return super._readback_matches(path, text)


func test_temporary_failures_preserve_committed_bytes_and_request_for_recovery() -> void:
	for failure in ["open", "write", "flush", "readback"]:
		_clean_test_files()
		var store = TemporaryFailure.new()
		assert_true(store.configure_profile(TEST_PATH))
		assert_true(store.transact_profile(_empty_profile(), 0, "init:test").ok)
		var original := FileAccess.get_file_as_string(TEST_PATH)
		var candidate: Dictionary = store.load_profile().profile
		candidate.meta.soul_balance = 3
		var request := candidate.duplicate(true)
		store.failure = failure
		var result: Dictionary = store.transact_profile(candidate, 1, "grant:test")
		assert_false(result.ok, failure)
		assert_eq(FileAccess.get_file_as_string(TEST_PATH), original, failure)
		assert_eq(candidate, request, "Failure must not mutate caller receipt/revision")
		assert_false(FileAccess.file_exists(TEST_PATH + ".previous"))
		var reopened = STORE.new()
		assert_true(reopened.configure_profile(TEST_PATH))
		assert_eq(reopened.load_profile().profile.meta.soul_balance, 0)
		assert_eq(FileAccess.file_exists(TEST_PATH + ".tmp"), failure != "open")
		if failure != "open":
			store.failure = ""
			assert_false(store.transact_profile(candidate, 1, "grant:test").ok,
				"Existing incomplete candidate must not be overwritten by retry")
			assert_eq(FileAccess.get_file_as_string(TEST_PATH), original)

class ReadbackFailure:
	extends "res://scripts/core/run_resume_store.gd"
	var fail_canonical := false
	func _readback_matches(path: String, expected_text: String) -> bool:
		if fail_canonical and path == storage_path():
			return false
		return super._readback_matches(path, expected_text)

class CleanupFailure:
	extends "res://scripts/core/run_resume_store.gd"
	func _remove_previous_record() -> Error:
		return ERR_CANT_CREATE


class RenameFailure:
	extends "res://scripts/core/run_resume_store.gd"
	var failed_calls: Array[int] = []
	var rename_calls := 0
	func _rename_record(from: String, to: String) -> Error:
		rename_calls += 1
		if failed_calls.has(rename_calls):
			return ERR_CANT_CREATE
		return DirAccess.rename_absolute(from, to)


class ReadbackAndRenameFailure:
	extends RenameFailure
	var fail_canonical := false
	func _readback_matches(path: String, expected_text: String) -> bool:
		if fail_canonical and path == storage_path():
			return false
		return super._readback_matches(path, expected_text)


func test_readback_rollback_rename_failures_preserve_both_recovery_versions() -> void:
	for failed_rename in [3, 4]:
		_clean_test_files()
		var store = ReadbackAndRenameFailure.new()
		assert_true(store.configure_profile(TEST_PATH))
		assert_true(store.transact_profile(_empty_profile(), 0, "init:test").ok)
		var original := FileAccess.get_file_as_string(TEST_PATH)
		var candidate: Dictionary = store.load_profile().profile
		candidate.meta.soul_balance = 3
		store.rename_calls = 0
		store.failed_calls.assign([failed_rename])
		store.fail_canonical = true
		var result: Dictionary = store.transact_profile(candidate, 1, "grant:test")
		assert_false(result.ok)
		assert_eq(result.warning, &"recovery_required")
		assert_eq(FileAccess.get_file_as_string(TEST_PATH + ".previous"), original)
		var new_path: String = TEST_PATH if failed_rename == 3 else TEST_PATH + ".tmp"
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(new_path))
		assert_true(parsed is Dictionary)
		if parsed is Dictionary:
			assert_eq(parsed.meta.soul_balance, 3.0)
			assert_true(parsed.meta.transaction_receipts.has("grant:test"))


func test_profile_rename_failures_keep_original_and_preserve_failed_rollback_candidates() -> void:
	for failures in [[1], [2], [2, 3]]:
		_clean_test_files()
		var store = RenameFailure.new()
		assert_true(store.configure_profile(TEST_PATH))
		assert_true(store.transact_profile(_empty_profile(), 0, "init:test").ok)
		var original := FileAccess.get_file_as_string(TEST_PATH)
		var candidate: Dictionary = store.load_profile().profile
		candidate.meta.soul_balance = 3
		store.rename_calls = 0
		store.failed_calls.assign(failures)
		var result: Dictionary = store.transact_profile(candidate, 1, "grant:test")
		assert_false(result.ok, "Injected file replacement failure must not report success")
		if failures.size() == 2:
			assert_false(FileAccess.file_exists(TEST_PATH))
			assert_eq(FileAccess.get_file_as_string(TEST_PATH + ".previous"), original)
			assert_true(FileAccess.file_exists(TEST_PATH + ".tmp"), "Failed rollback keeps both versions for recovery")
			assert_eq(store.load_profile().get("reason", &""), &"recovery_required")
		else:
			assert_eq(FileAccess.get_file_as_string(TEST_PATH), original)
			assert_eq(store.load_profile().profile.meta.soul_balance, 0)


func test_profile_readback_failure_restores_old_bytes_and_cleanup_warning_is_success() -> void:
	var store = ReadbackFailure.new()
	if not store.has_method("configure_profile"):
		assert_true(false)
		return
	store.configure_profile(TEST_PATH)
	assert_true(store.transact_profile(_empty_profile(), 0, "init:test").ok)
	var before := FileAccess.get_file_as_string(TEST_PATH)
	var next: Dictionary = store.load_profile().profile
	next.meta.soul_balance = 3
	store.fail_canonical = true
	assert_false(store.transact_profile(next, 1, "grant:test").ok)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH), before)
	assert_eq(store.load_profile().profile.meta.soul_balance, 0)
	assert_true(FileAccess.file_exists(TEST_PATH + ".tmp"), "Failed candidate preserved for explicit recovery")
	_clean_test_files()
	var cleanup = CleanupFailure.new()
	cleanup.configure_profile(TEST_PATH)
	assert_true(cleanup.transact_profile(_empty_profile(), 0, "init:test").ok)
	next = cleanup.load_profile().profile
	next.meta.soul_balance = 3
	var result: Dictionary = cleanup.transact_profile(next, 1, "grant:test")
	assert_true(result.ok)
	assert_eq(result.warning, &"previous_cleanup_pending")
	assert_eq(cleanup.load_profile().profile.meta.soul_balance, 3)
	assert_true(cleanup.transact_profile(next, 1, "grant:test").already_applied)
	assert_eq(cleanup.load_profile().profile.meta.soul_balance, 3)


func before_each() -> void:
	_clean_test_files()


func after_each() -> void:
	_clean_test_files()


func _clean_test_files() -> void:
	if FileAccess.file_exists(LEGACY_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(LEGACY_PATH))
	for suffix in ["", ".tmp", ".previous"]:
		if FileAccess.file_exists(TEST_PATH + suffix):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH + suffix))


func test_profile_store_persists_once_and_rejects_conflicting_or_stale_requests() -> void:
	var store = STORE.new()
	assert_true(store.has_method("configure_profile"))
	if not store.has_method("configure_profile"):
		return
	assert_true(store.configure_profile(TEST_PATH))
	var candidate := _empty_profile()
	var first: Dictionary = store.transact_profile(candidate, 0, "init:test")
	assert_true(first.ok)
	assert_eq(first.revision, 1)
	var bytes := FileAccess.get_file_as_string(TEST_PATH)
	var replay: Dictionary = store.transact_profile(candidate, 0, "init:test")
	assert_true(replay.ok)
	assert_true(replay.already_applied)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH), bytes)
	candidate.meta.soul_balance = 2
	assert_false(store.transact_profile(candidate, 0, "init:test").ok)
	assert_false(store.transact_profile(candidate, 0, "other:test").ok)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH), bytes)
	var reloaded = STORE.new()
	assert_true(reloaded.configure_profile(TEST_PATH))
	assert_eq(reloaded.load_profile().profile.revision, 1)
	assert_false(reloaded.save_checkpoint({}))
	assert_false(reloaded.clear_record(), "Legacy deletion cannot erase a profile")
	assert_false(reloaded.configure(TEST_PATH))
	assert_eq(FileAccess.get_file_as_string(TEST_PATH), bytes)


func test_recovery_inspection_reports_candidates_without_promoting_or_deleting() -> void:
	var store = ReadbackFailure.new()
	assert_true(store.configure_profile(TEST_PATH))
	assert_true(store.transact_profile(_empty_profile(), 0, "init:test").ok)
	var next: Dictionary = store.load_profile().profile
	next.meta.soul_balance = 3
	store.fail_canonical = true
	assert_false(store.transact_profile(next, 1, "grant:test").ok)
	var canonical := FileAccess.get_file_as_string(TEST_PATH)
	var temporary := FileAccess.get_file_as_string(TEST_PATH + ".tmp")
	assert_true(store.has_method("inspect_profile_recovery"))
	if not store.has_method("inspect_profile_recovery"):
		return
	var inspected: Dictionary = store.inspect_profile_recovery()
	assert_true(inspected.ok)
	assert_eq(inspected.candidates.size(), 3)
	assert_eq(inspected.candidates[0].revision, 1)
	assert_true(inspected.candidates[0].valid)
	assert_eq(inspected.candidates[0].sha256, canonical.sha256_text())
	assert_false(inspected.candidates[1].exists)
	assert_true(inspected.candidates[2].valid)
	assert_eq(inspected.candidates[2].revision, 2)
	assert_eq(inspected.candidates[2].sha256, temporary.sha256_text())
	assert_true(inspected.requires_review)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH), canonical)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH + ".tmp"), temporary)


func test_recovery_selection_rejects_stale_inventory_and_reads_only_chosen_profile() -> void:
	var store = ReadbackFailure.new()
	assert_true(store.configure_profile(TEST_PATH))
	assert_true(store.transact_profile(_empty_profile(), 0, "init:test").ok)
	var next: Dictionary = store.load_profile().profile
	next.meta.soul_balance = 4
	store.fail_canonical = true
	assert_false(store.transact_profile(next, 1, "grant:test").ok)
	var observed: Dictionary = store.inspect_profile_recovery()
	assert_true(store.has_method("read_recovery_candidate"))
	if not store.has_method("read_recovery_candidate"):
		return
	var canonical := FileAccess.get_file_as_string(TEST_PATH)
	var temporary := FileAccess.get_file_as_string(TEST_PATH + ".tmp")
	var chosen: Dictionary = store.read_recovery_candidate("temporary", observed)
	assert_true(chosen.ok)
	assert_eq(chosen.profile.meta.soul_balance, 4)
	assert_eq(chosen.source_sha256, temporary.sha256_text())
	assert_eq(store.read_recovery_candidate("canonical", observed).profile.meta.soul_balance, 0)
	assert_false(store.read_recovery_candidate("previous", observed).ok)
	assert_false(store.read_recovery_candidate("../external", observed).ok)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH), canonical)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH + ".tmp"), temporary)
	var file := FileAccess.open(TEST_PATH + ".tmp", FileAccess.WRITE)
	file.store_string(temporary + "\n")
	file.close()
	assert_false(store.read_recovery_candidate("canonical", observed).ok, "Even an unselected candidate change invalidates the review")
	assert_false(store.read_recovery_candidate("temporary", observed).ok)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH), canonical)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH + ".tmp"), temporary + "\n")


func test_recovery_inspection_keeps_missing_and_corrupt_candidates_distinct() -> void:
	var store = STORE.new()
	assert_false(store.inspect_profile_recovery().ok)
	assert_true(store.configure_profile(TEST_PATH))
	var empty: Dictionary = store.inspect_profile_recovery()
	assert_false(empty.requires_review)
	for candidate in empty.candidates:
		assert_false(candidate.exists)
		assert_eq(candidate.reason, &"missing")
	var file := FileAccess.open(TEST_PATH + ".tmp", FileAccess.WRITE)
	assert_not_null(file)
	file.store_string("{broken")
	file.close()
	var inspected: Dictionary = store.inspect_profile_recovery()
	assert_true(inspected.requires_review)
	assert_false(inspected.candidates[0].exists)
	assert_false(inspected.candidates[2].valid)
	assert_eq(inspected.candidates[2].reason, &"invalid_json")
	assert_eq(inspected.candidates[2].sha256, "{broken".sha256_text())
	assert_eq(store.load_profile().reason, &"recovery_required")
	assert_false(FileAccess.file_exists(TEST_PATH))
	assert_eq(FileAccess.get_file_as_string(TEST_PATH + ".tmp"), "{broken")
	file = FileAccess.open(TEST_PATH, FileAccess.WRITE)
	file.store_string("{}")
	file.close()
	inspected = store.inspect_profile_recovery()
	assert_true(inspected.requires_review)
	assert_true(inspected.candidates[0].exists)
	assert_false(inspected.candidates[0].valid)
	assert_ne(inspected.candidates[0].reason, &"invalid_json")
	assert_eq(FileAccess.get_file_as_string(TEST_PATH), "{}")
	assert_eq(FileAccess.get_file_as_string(TEST_PATH + ".tmp"), "{broken")


func test_profile_store_invalid_candidate_and_write_failure_do_not_publish() -> void:
	var store = STORE.new()
	if not store.has_method("configure_profile"):
		assert_true(false, "Profile store missing")
		return
	assert_true(store.configure_profile(TEST_PATH))
	var invalid := _empty_profile()
	invalid.meta.soul_balance = 0.1
	assert_false(store.transact_profile(invalid, 0, "init:test").ok)
	assert_false(FileAccess.file_exists(TEST_PATH))
	var unwritable = STORE.new()
	assert_true(unwritable.configure_profile("user://gut_profile_missing_parent_20260914/profile.json"))
	assert_false(unwritable.transact_profile(_empty_profile(), 0, "init:test").ok)
	assert_eq(unwritable.load_profile().reason, &"missing")


func test_profile_transaction_adds_its_own_unlock_receipt_without_caller_forgery() -> void:
	var store = STORE.new()
	store.configure_profile(TEST_PATH)
	var initial := _empty_profile()
	initial.meta.soul_balance = 3
	assert_true(store.transact_profile(initial, 0, "init:test").ok)
	var next: Dictionary = store.load_profile().profile
	next.meta.soul_balance = 0
	next.meta.unlocked_support_choice = true
	assert_false(CODEC.new().decode_profile_v2(next).ok, "Uncommitted candidate is not a durable profile")
	assert_true(store.transact_profile(next, 1, "unlock:support-choice-v1").ok)
	assert_true(store.load_profile().profile.meta.unlocked_support_choice)
	assert_eq(store.load_profile().profile.meta.soul_balance, 0)


func test_legacy_wallet_import_is_one_time_and_preserves_source_bytes() -> void:
	var store = STORE.new()
	assert_true(store.configure_profile(TEST_PATH))
	assert_true(store.has_method("import_legacy_wallet"))
	if not store.has_method("import_legacy_wallet"):
		return
	var source := "{\n  \"balance\": 7\n}"
	var file := FileAccess.open(LEGACY_PATH, FileAccess.WRITE)
	file.store_string(source)
	file.close()
	assert_true(store.import_legacy_wallet(LEGACY_PATH).ok)
	var profile: Dictionary = store.load_profile().profile
	assert_eq(profile.meta.soul_balance, 7)
	assert_eq(profile.revision, 1)
	assert_null(profile.active_run)
	assert_true(profile.meta.transaction_receipts.has("migrate:wallet-v1:" + source.sha256_text()))
	assert_eq(FileAccess.get_file_as_string(LEGACY_PATH), source)
	var committed := FileAccess.get_file_as_string(TEST_PATH)
	var reopened = STORE.new()
	assert_true(reopened.configure_profile(TEST_PATH))
	assert_false(reopened.import_legacy_wallet(LEGACY_PATH).ok)
	assert_eq(FileAccess.get_file_as_string(TEST_PATH), committed)
	assert_eq(FileAccess.get_file_as_string(LEGACY_PATH), source)


func test_legacy_import_refuses_missing_corrupt_future_and_pending_recovery() -> void:
	var store = STORE.new()
	assert_true(store.configure_profile(TEST_PATH))
	assert_true(store.has_method("import_legacy_wallet"))
	if not store.has_method("import_legacy_wallet"):
		return
	assert_false(store.import_legacy_wallet(LEGACY_PATH).ok)
	for source in ["broken", "{\"balance\": -1}", "{\"balance\": 1.5}", "{\"balance\": 8, \"schema_version\": 3}"]:
		var file := FileAccess.open(LEGACY_PATH, FileAccess.WRITE)
		file.store_string(source)
		file.close()
		assert_false(store.import_legacy_wallet(LEGACY_PATH).ok)
		assert_false(FileAccess.file_exists(TEST_PATH))
		assert_eq(FileAccess.get_file_as_string(LEGACY_PATH), source)
	var file := FileAccess.open(LEGACY_PATH, FileAccess.WRITE)
	file.store_string("{\"balance\": 8}")
	file.close()
	file = FileAccess.open(TEST_PATH + ".tmp", FileAccess.WRITE)
	file.store_string("unresolved")
	file.close()
	assert_false(store.import_legacy_wallet(LEGACY_PATH).ok)
	assert_false(FileAccess.file_exists(TEST_PATH))
	assert_eq(FileAccess.get_file_as_string(TEST_PATH + ".tmp"), "unresolved")


func test_legacy_import_write_failure_keeps_wallet_and_never_reimports_candidate() -> void:
	for failure in ["open", "write", "flush", "readback"]:
		_clean_test_files()
		var source := "{\"balance\": 9}"
		var file := FileAccess.open(LEGACY_PATH, FileAccess.WRITE)
		file.store_string(source)
		file.close()
		var store = TemporaryFailure.new()
		assert_true(store.configure_profile(TEST_PATH))
		store.failure = failure
		assert_false(store.import_legacy_wallet(LEGACY_PATH).ok, failure)
		assert_eq(FileAccess.get_file_as_string(LEGACY_PATH), source, failure)
		assert_false(FileAccess.file_exists(TEST_PATH), failure)
		store.failure = ""
		if failure == "open":
			assert_true(store.import_legacy_wallet(LEGACY_PATH).ok)
			assert_eq(store.load_profile().profile.meta.soul_balance, 9)
		else:
			var candidate := FileAccess.get_file_as_string(TEST_PATH + ".tmp")
			assert_false(store.import_legacy_wallet(LEGACY_PATH).ok)
			assert_eq(FileAccess.get_file_as_string(TEST_PATH + ".tmp"), candidate)


func _empty_profile() -> Dictionary:
	return {
		"schema_version": 2, "revision": 0, "content_contract": "ns-replan-20260911",
		"meta": {"soul_balance": 0, "unlocked_support_choice": false,
			"settled_run_ids": [], "applied_transaction_ids": [], "transaction_receipts": {}},
		"active_run": null,
	}


func test_profile_envelope_roundtrip_and_strict_numeric_boundaries() -> void:
	var codec = CODEC.new()
	assert_true(codec.has_method("decode_profile_v2"))
	if not codec.has_method("decode_profile_v2"):
		return
	var source := _empty_profile()
	var decoded: Dictionary = codec.decode_profile_v2(JSON.parse_string(JSON.stringify(source)))
	assert_true(decoded.ok)
	assert_eq(decoded.profile.meta.soul_balance, 0)
	decoded.profile.meta.soul_balance = 999
	assert_eq(source.meta.soul_balance, 0)
	for invalid in [null, true, "2", -1, 0.5, INF, NAN, 9007199254740992]:
		var raw := _empty_profile()
		raw.meta.soul_balance = invalid
		assert_false(codec.decode_profile_v2(raw).ok)
		raw = _empty_profile()
		raw.revision = invalid
		assert_false(codec.decode_profile_v2(raw).ok)
	for invalid in [null, true, "2", 2.1, 1, 3]:
		var raw := _empty_profile()
		raw.schema_version = invalid
		assert_false(codec.decode_profile_v2(raw).ok)


func test_profile_does_not_admit_unvalidated_active_run_or_receipts() -> void:
	var codec = CODEC.new()
	if not codec.has_method("decode_profile_v2"):
		assert_true(false, "Profile codec missing")
		return
	var raw := _empty_profile()
	raw.active_run = {"checkpoint": {}}
	assert_false(codec.decode_profile_v2(raw).ok)
	raw = _empty_profile()
	raw.meta.applied_transaction_ids = ["init:test"]
	assert_false(codec.decode_profile_v2(raw).ok, "IDs require matching receipts")
	raw = _empty_profile()
	raw.meta.unlocked_support_choice = 1
	assert_false(codec.decode_profile_v2(raw).ok)
	raw = _empty_profile()
	raw.meta.settled_run_ids = ["run", "run"]
	assert_false(codec.decode_profile_v2(raw).ok)
