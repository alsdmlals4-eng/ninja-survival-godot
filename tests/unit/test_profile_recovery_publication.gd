extends GutTest

const STORE = preload("res://scripts/core/run_resume_store.gd")
var root: String
var path: String

class FailingStore:
	extends "res://scripts/core/run_resume_store.gd"
	var fail_write := ""
	var fail_renames: Array[int] = []
	var rename_count := 0
	var fail_final_read := false
	var mutate_after_backup := false
	var observed_reentry: Dictionary = {}
	func _write_recovery_file(destination: String, bytes: PackedByteArray) -> bool:
		observed_reentry = transact_profile({}, 0, "reentrant:test")
		if destination.ends_with(fail_write) and not fail_write.is_empty():
			var file := FileAccess.open(destination, FileAccess.WRITE)
			file.store_buffer(bytes.slice(0, 4))
			file.close()
			return false
		var output := FileAccess.open(destination, FileAccess.WRITE)
		if output == null:
			return false
		var result := output.store_buffer(bytes)
		output.flush()
		result = result and output.get_error() == OK
		output.close()
		if mutate_after_backup and destination.ends_with("selected.pending"):
			var file := FileAccess.open(storage_path() + ".previous", FileAccess.WRITE)
			file.store_string("changed after review")
			file.close()
		return result
	func _rename_record(from: String, to: String) -> Error:
		rename_count += 1
		if fail_renames.has(rename_count):
			return ERR_CANT_CREATE
		return super._rename_record(from, to)
	func _readback_matches(candidate_path: String, text: String) -> bool:
		if fail_final_read and candidate_path == storage_path():
			return false
		return super._readback_matches(candidate_path, text)

func before_each() -> void:
	root = "user://gut_recovery_publication_%s_%s" % [OS.get_process_id(), Time.get_ticks_usec()]
	assert_eq(DirAccess.make_dir_recursive_absolute(root), OK)
	path = root.path_join("profile.json")

func after_each() -> void:
	# Only this test's newly-created directory; never a normal player-save path.
	assert_true(root.begins_with("user://gut_recovery_publication_"))
	_remove_fixture_tree(root)

func _remove_fixture_tree(directory: String) -> void:
	assert_true(directory == root or directory.begins_with(root + "/"))
	for file in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(directory.path_join(file))
	for child in DirAccess.get_directories_at(directory):
		_remove_fixture_tree(directory.path_join(child))
	DirAccess.remove_absolute(directory)

func _profile(balance: int) -> Dictionary:
	return {"schema_version": 2, "revision": 0, "content_contract": "ns-replan-20260911",
		"meta": {"soul_balance": balance, "unlocked_support_choice": false,
			"settled_run_ids": [], "applied_transaction_ids": [], "transaction_receipts": {}},
		"active_run": null}

func _write(target: String, text: String) -> void:
	var file := FileAccess.open(target, FileAccess.WRITE)
	assert_not_null(file)
	file.store_string(text)
	file.close()

func _seed() -> Dictionary:
	var originals := {
		"canonical": JSON.stringify(_profile(2)),
		"previous": JSON.stringify(_profile(1)),
		"temporary": JSON.stringify(_profile(3))}
	_write(path, originals.canonical)
	_write(path + ".previous", originals.previous)
	_write(path + ".tmp", originals.temporary)
	return originals

func _assert_sources(originals: Dictionary) -> void:
	assert_eq(FileAccess.get_file_as_string(path), originals.canonical)
	assert_eq(FileAccess.get_file_as_string(path + ".previous"), originals.previous)
	assert_eq(FileAccess.get_file_as_string(path + ".tmp"), originals.temporary)

func _assert_archive(result: Dictionary, originals: Dictionary) -> void:
	assert_true(result.has("archive_path"))
	if not result.has("archive_path"):
		return
	for role in originals:
		assert_eq(FileAccess.get_file_as_string(result.archive_path.path_join(role + ".original")),
			originals[role], role)

func _has_publication(store) -> bool:
	assert_true(store.has_method("publish_recovery_candidate"),
		"Reviewed recovery cannot yet be published while preserving all originals")
	return store.has_method("publish_recovery_candidate")

func test_each_explicit_role_restores_exact_bytes_and_all_originals() -> void:
	for role in ["canonical", "previous", "temporary"]:
		var originals := _seed()
		var store = STORE.new()
		assert_true(store.configure_profile(path))
		if not _has_publication(store):
			return
		var observed: Dictionary = store.inspect_profile_recovery()
		var result: Dictionary = store.publish_recovery_candidate(role, observed)
		assert_true(result.ok, str(result))
		if not result.ok:
			continue
		assert_eq(FileAccess.get_file_as_string(path), originals[role])
		_assert_archive(result, originals)
		assert_false(FileAccess.file_exists(path + ".previous"))
		assert_false(FileAccess.file_exists(path + ".tmp"))
		var reopened = STORE.new()
		assert_true(reopened.configure_profile(path))
		assert_true(reopened.load_profile().ok)
		assert_false(reopened.inspect_profile_recovery().requires_review)
		assert_false(reopened.publish_recovery_candidate(role, observed).ok,
			"Stale review cannot replay recovery after a new committed state")

func test_corrupt_canonical_is_preserved_when_previous_is_selected() -> void:
	var originals := _seed()
	originals.canonical = "{broken data"
	_write(path, originals.canonical)
	var store = STORE.new()
	store.configure_profile(path)
	if not _has_publication(store):
		return
	var result: Dictionary = store.publish_recovery_candidate("previous", store.inspect_profile_recovery())
	assert_true(result.ok, str(result))
	_assert_archive(result, originals)
	assert_eq(store.load_profile().profile.meta.soul_balance, 1)

func test_stale_or_invalid_selection_never_changes_sources() -> void:
	var originals := _seed()
	var store = STORE.new()
	store.configure_profile(path)
	if not _has_publication(store):
		return
	var observed: Dictionary = store.inspect_profile_recovery()
	assert_false(store.publish_recovery_candidate("../elsewhere", observed).ok)
	_assert_sources(originals)
	originals.previous += "\n"
	_write(path + ".previous", originals.previous)
	assert_false(store.publish_recovery_candidate("temporary", observed).ok)
	_assert_sources(originals)

func test_backup_and_staging_failures_leave_originals_untouched() -> void:
	for failed_file in ["canonical.original", "previous.original", "temporary.original", "inventory.json", "selected.pending"]:
		var originals := _seed()
		var store = FailingStore.new()
		store.configure_profile(path)
		if not _has_publication(store):
			return
		store.fail_write = failed_file
		var result: Dictionary = store.publish_recovery_candidate("temporary", store.inspect_profile_recovery())
		assert_false(result.ok, failed_file)
		_assert_sources(originals)
		assert_eq(store.observed_reentry.get("reason"), &"not_ready")
		assert_true(store.inspect_profile_recovery().ok, "Busy flag must release after failure")

func test_changed_unselected_file_during_preservation_aborts_publication() -> void:
	_seed()
	var store = FailingStore.new()
	store.configure_profile(path)
	if not _has_publication(store):
		return
	store.mutate_after_backup = true
	var result: Dictionary = store.publish_recovery_candidate("temporary", store.inspect_profile_recovery())
	assert_false(result.ok)
	assert_eq(result.reason, &"stale_recovery_inventory")
	assert_eq(store.load_profile().profile.meta.soul_balance, 2)
	assert_eq(FileAccess.get_file_as_string(path + ".previous"), "changed after review")

func test_each_rename_failure_rolls_back_without_losing_sources() -> void:
	for failure in [1, 2, 3, 4]:
		var originals := _seed()
		var store = FailingStore.new()
		store.configure_profile(path)
		if not _has_publication(store):
			return
		store.fail_renames.assign([failure])
		var result: Dictionary = store.publish_recovery_candidate("temporary", store.inspect_profile_recovery())
		assert_false(result.ok)
		_assert_sources(originals)
		_assert_archive(result, originals)

func test_failed_rollback_still_keeps_every_original_in_archive() -> void:
	var originals := _seed()
	var store = FailingStore.new()
	store.configure_profile(path)
	if not _has_publication(store):
		return
	store.fail_renames.assign([4, 5])
	var result: Dictionary = store.publish_recovery_candidate("temporary", store.inspect_profile_recovery())
	assert_false(result.ok)
	assert_eq(result.reason, &"recovery_required")
	_assert_archive(result, originals)

func test_final_readback_failure_restores_old_files_and_preserves_failed_candidate() -> void:
	var originals := _seed()
	var store = FailingStore.new()
	store.configure_profile(path)
	if not _has_publication(store):
		return
	store.fail_final_read = true
	var result: Dictionary = store.publish_recovery_candidate("temporary", store.inspect_profile_recovery())
	assert_false(result.ok)
	_assert_sources(originals)
	_assert_archive(result, originals)
	assert_eq(FileAccess.get_file_as_string(result.archive_path.path_join("failed-publication")), originals.temporary)
