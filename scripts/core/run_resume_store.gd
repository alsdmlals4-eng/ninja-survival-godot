# 이어하기 파일 I/O만 담당한다. 도메인 복원과 전투 재개 결정은 MainController가 소유한다.
extends RefCounted
class_name RunResumeStore

const DEFAULT_STORAGE_PATH := "user://run_resume_v1.json"
const TEMPORARY_SUFFIX := ".tmp"
const PREVIOUS_SUFFIX := ".previous"
const RUN_RESUME_CODEC_SCRIPT = preload("res://scripts/core/run_resume_codec.gd")

var _storage_path := DEFAULT_STORAGE_PATH
var _codec = RUN_RESUME_CODEC_SCRIPT.new()
var _configured := false
var _last_save_warning: StringName = &""
var _profile_mode := false
var _profile_transaction_busy := false


func configure_profile(path: String) -> bool:
	if _configured or path.is_empty() or path.get_file() in ["run_resume_v1.json", "ninja_soul_wallet_v1.json"]:
		return false
	_storage_path = path
	_profile_mode = true
	_configured = true
	return true


# Initial import only. Legacy run state is deliberately not translated.
# The source is opened READ-only; this store's existing transaction owns publication.
func import_legacy_wallet(source_path: String) -> Dictionary:
	if not _configured or not _profile_mode or _profile_transaction_busy:
		return {"ok": false, "reason": &"not_ready"}
	if source_path.is_empty():
		return {"ok": false, "reason": &"invalid_source"}
	var inventory := inspect_profile_recovery()
	for candidate in inventory.candidates:
		if candidate.exists:
			return {"ok": false, "reason": &"profile_or_recovery_exists"}
	if not FileAccess.file_exists(source_path):
		return {"ok": false, "reason": &"legacy_missing"}
	var file := FileAccess.open(source_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "reason": &"legacy_unreadable"}
	var bytes := file.get_buffer(file.get_length())
	var read_error := file.get_error()
	file.close()
	if read_error != OK:
		return {"ok": false, "reason": &"legacy_unreadable"}
	var parser := JSON.new()
	if parser.parse(bytes.get_string_from_utf8()) != OK:
		return {"ok": false, "reason": &"invalid_legacy_wallet"}
	var balance: int = preload("res://scripts/core/ninja_soul_wallet.gd").decode_legacy_balance(parser.data)
	if balance < 0:
		return {"ok": false, "reason": &"invalid_legacy_wallet"}
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	var source_hash := hash.finish().hex_encode()
	var profile := {"schema_version": 2, "revision": 0,
		"content_contract": RUN_RESUME_CODEC_SCRIPT.PROFILE_CONTRACT,
		"meta": {"soul_balance": balance, "unlocked_support_choice": false,
			"settled_run_ids": [], "applied_transaction_ids": [], "transaction_receipts": {}},
		"active_run": null}
	return transact_profile(profile, 0, "migrate:wallet-v1:" + source_hash)


func load_profile() -> Dictionary:
	if not _configured or not _profile_mode:
		return {"ok": false, "reason": &"not_configured"}
	if not FileAccess.file_exists(_storage_path):
		var recovery := FileAccess.file_exists(_previous_storage_path()) or FileAccess.file_exists(_temporary_storage_path())
		return {"ok": false, "reason": &"recovery_required" if recovery else &"missing"}
	var file := FileAccess.open(_storage_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "reason": &"unreadable"}
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK or not (parser.data is Dictionary):
		return {"ok": false, "reason": &"invalid_json"}
	return _codec.decode_profile_v2(parser.data)


# Read-only recovery inventory. A newer temporary file is not a committed save.
# Selection/promotion needs a separate compare-by-hash recovery transaction.
func inspect_profile_recovery() -> Dictionary:
	if not _configured or not _profile_mode or _profile_transaction_busy:
		return {"ok": false, "reason": &"not_ready"}
	return _profile_recovery_inventory()


func _profile_recovery_inventory() -> Dictionary:
	var candidates: Array = []
	var roles := ["canonical", "previous", "temporary"]
	var paths := [_storage_path, _previous_storage_path(), _temporary_storage_path()]
	var requires_review := false
	for index in range(paths.size()):
		var path: String = paths[index]
		var item := {"role": roles[index], "path": path, "exists": FileAccess.file_exists(path),
			"valid": false, "reason": &"missing", "sha256": "", "revision": -1}
		if item.exists:
			var file := FileAccess.open(path, FileAccess.READ)
			if file == null:
				item.reason = &"unreadable"
			else:
				var bytes := file.get_buffer(file.get_length())
				var read_error := file.get_error()
				file.close()
				var hash := HashingContext.new()
				hash.start(HashingContext.HASH_SHA256)
				hash.update(bytes)
				item.sha256 = hash.finish().hex_encode()
				var parser := JSON.new()
				item.reason = &"unreadable" if read_error != OK else &"invalid_json"
				if read_error == OK and parser.parse(bytes.get_string_from_utf8()) == OK and parser.data is Dictionary:
					var decoded: Dictionary = _codec.decode_profile_v2(parser.data)
					item.valid = decoded.ok
					item.reason = decoded.get("reason", &"")
					if decoded.ok:
						item.revision = decoded.profile.revision
			requires_review = requires_review or index != 0 or not item.valid
		candidates.append(item)
	return {"ok": true, "requires_review": requires_review, "candidates": candidates}


# Resolve a reviewed role, never a caller-supplied path. This returns values only;
# recovery publication must preserve originals and recheck the inventory again.
func read_recovery_candidate(role: String, observed: Dictionary) -> Dictionary:
	if not role in ["canonical", "previous", "temporary"]:
		return {"ok": false, "reason": &"invalid_recovery_role"}
	var current := inspect_profile_recovery()
	if not current.ok:
		return current
	if current != observed:
		return {"ok": false, "reason": &"stale_recovery_inventory"}
	var selected: Dictionary = {}
	for candidate in current.candidates:
		if candidate.role == role:
			selected = candidate
	if not selected.get("valid", false):
		return {"ok": false, "reason": &"invalid_recovery_candidate"}
	var file := FileAccess.open(selected.path, FileAccess.READ)
	if file == null:
		return {"ok": false, "reason": &"recovery_unreadable"}
	var bytes := file.get_buffer(file.get_length())
	var read_error := file.get_error()
	file.close()
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	var digest := hash.finish().hex_encode()
	if read_error != OK or digest != selected.sha256 or inspect_profile_recovery() != current:
		return {"ok": false, "reason": &"stale_recovery_inventory"}
	var parser := JSON.new()
	if parser.parse(bytes.get_string_from_utf8()) != OK or not (parser.data is Dictionary):
		return {"ok": false, "reason": &"invalid_recovery_candidate"}
	var decoded: Dictionary = _codec.decode_profile_v2(parser.data)
	if not decoded.ok:
		return decoded
	return {"ok": true, "profile": decoded.profile, "source_sha256": digest, "role": role}


# Explicit reviewed choice only. Preserve every source, including corrupt bytes,
# before displacing live paths. This is not a multi-process lock or crash-proof FS.
func publish_recovery_candidate(role: String, observed: Dictionary) -> Dictionary:
	var selected := read_recovery_candidate(role, observed)
	if not selected.ok:
		return selected
	_profile_transaction_busy = true
	var result := _publish_reviewed_recovery(role, observed, selected)
	_profile_transaction_busy = false
	return result


func _publish_reviewed_recovery(role: String, observed: Dictionary, selected: Dictionary) -> Dictionary:
	var sources: Dictionary = {}
	for item in observed.candidates:
		if not item.exists:
			continue
		var read := _read_recovery_bytes(item.path)
		if not read.ok or _recovery_digest(read.bytes) != item.sha256:
			return {"ok": false, "reason": &"stale_recovery_inventory"}
		sources[item.role] = read.bytes
	if _profile_recovery_inventory() != observed:
		return {"ok": false, "reason": &"stale_recovery_inventory"}
	var archive := _storage_path + ".recovery/" + str(Time.get_unix_time_from_system()).replace(".", "_") + "_" + str(Time.get_ticks_usec())
	if DirAccess.dir_exists_absolute(archive) or FileAccess.file_exists(archive):
		return {"ok": false, "reason": &"recovery_archive_exists"}
	if DirAccess.make_dir_recursive_absolute(archive) != OK:
		return {"ok": false, "reason": &"recovery_archive_failed"}
	for source_role in sources:
		if not _preserve_recovery_bytes(archive.path_join(source_role + ".original"), sources[source_role]):
			return {"ok": false, "reason": &"recovery_preservation_failed", "archive_path": archive}
	var receipt := {"selected_role": role, "selected_sha256": selected.source_sha256,
		"inventory": observed}
	if not _preserve_recovery_bytes(archive.path_join("inventory.json"), JSON.stringify(receipt).to_utf8_buffer()):
		return {"ok": false, "reason": &"recovery_preservation_failed", "archive_path": archive}
	var staged := archive.path_join("selected.pending")
	var selected_bytes: PackedByteArray = sources[role]
	if not _preserve_recovery_bytes(staged, selected_bytes) or not _readback_matches(staged, selected_bytes.get_string_from_utf8()):
		return {"ok": false, "reason": &"recovery_staging_failed", "archive_path": archive}
	if _profile_recovery_inventory() != observed:
		return {"ok": false, "reason": &"stale_recovery_inventory", "archive_path": archive}
	var displaced: Array = []
	for item in observed.candidates:
		if not item.exists:
			continue
		var backup: String = archive.path_join(item.role + ".displaced")
		# Recheck each exact source immediately before moving it.
		var read := _read_recovery_bytes(item.path)
		if not read.ok or _recovery_digest(read.bytes) != item.sha256:
			return _rollback_recovery(displaced, archive, &"stale_recovery_inventory")
		if _rename_record(ProjectSettings.globalize_path(item.path), ProjectSettings.globalize_path(backup)) != OK:
			return _rollback_recovery(displaced, archive, &"recovery_displace_failed")
		displaced.append({"source": item.path, "backup": backup})
	if FileAccess.file_exists(_storage_path) or _rename_record(ProjectSettings.globalize_path(staged), ProjectSettings.globalize_path(_storage_path)) != OK:
		return _rollback_recovery(displaced, archive, &"recovery_publish_failed")
	if not _readback_matches(_storage_path, selected_bytes.get_string_from_utf8()):
		var quarantine := archive.path_join("failed-publication")
		if _rename_record(ProjectSettings.globalize_path(_storage_path), ProjectSettings.globalize_path(quarantine)) != OK:
			return {"ok": false, "reason": &"recovery_required", "archive_path": archive}
		return _rollback_recovery(displaced, archive, &"recovery_readback_failed")
	return {"ok": true, "profile": selected.profile, "source_sha256": selected.source_sha256,
		"archive_path": archive, "role": role}


func _rollback_recovery(displaced: Array, archive: String, reason: StringName) -> Dictionary:
	var restored := true
	for index in range(displaced.size() - 1, -1, -1):
		var item: Dictionary = displaced[index]
		# Never overwrite a file that appeared while recovery was in progress.
		if FileAccess.file_exists(item.source) or _rename_record(ProjectSettings.globalize_path(item.backup), ProjectSettings.globalize_path(item.source)) != OK:
			restored = false
	return {"ok": false, "reason": reason if restored else &"recovery_required", "archive_path": archive}


func _read_recovery_bytes(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false}
	var bytes := file.get_buffer(file.get_length())
	var succeeded := file.get_error() == OK
	file.close()
	return {"ok": succeeded, "bytes": bytes}


func _recovery_digest(bytes: PackedByteArray) -> String:
	var hash := HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(bytes)
	return hash.finish().hex_encode()


func _preserve_recovery_bytes(path: String, bytes: PackedByteArray) -> bool:
	if FileAccess.file_exists(path) or not _write_recovery_file(path, bytes):
		return false
	var read := _read_recovery_bytes(path)
	return read.ok and read.bytes == bytes


# Narrow filesystem boundary for genuine I/O failure injection.
func _write_recovery_file(path: String, bytes: PackedByteArray) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	var succeeded := file.store_buffer(bytes)
	file.flush()
	succeeded = succeeded and file.get_error() == OK
	file.close()
	return succeeded


# The caller owns business legality; this owner validates the complete envelope,
# request identity and durable compare-and-write. No live combat owner is mutated.
func transact_profile(candidate: Dictionary, expected_revision: int, transaction_id: String) -> Dictionary:
	if not _configured or not _profile_mode or _profile_transaction_busy:
		return {"ok": false, "reason": &"not_ready"}
	if expected_revision < 0 or not RUN_RESUME_CODEC_SCRIPT._profile_unique_ids([transaction_id]):
		return {"ok": false, "reason": &"invalid_request"}
	# The store, never the caller, adds this receipt after candidate validation.
	# Disk decode/readback below always use the strict (no pending ID) path.
	var validation: Dictionary = _codec.decode_profile_v2(candidate, transaction_id)
	if not validation.ok:
		return validation
	var next: Dictionary = validation.profile
	var current_result := load_profile()
	var current: Dictionary = {}
	if current_result.ok:
		current = current_result.profile
	elif current_result.reason != &"missing":
		return current_result
	var revision := int(current.get("revision", 0))
	var receipts: Dictionary = current.get("meta", {}).get("transaction_receipts", {})
	var request := next.duplicate(true)
	request.erase("revision")
	request.meta.erase("applied_transaction_ids")
	request.meta.erase("transaction_receipts")
	var digest := JSON.stringify(_canonical_request_numbers(request), "", true, true).sha256_text()
	if receipts.has(transaction_id):
		if receipts[transaction_id].request_digest != digest:
			return {"ok": false, "reason": &"transaction_conflict"}
		return {"ok": true, "revision": revision, "already_applied": true, "warning": &""}
	if expected_revision != revision or int(next.revision) != revision:
		return {"ok": false, "reason": &"stale_revision"}
	if next.meta.transaction_receipts != receipts or next.meta.applied_transaction_ids != current.get("meta", {}).get("applied_transaction_ids", []):
		return {"ok": false, "reason": &"receipt_mutation"}
	next.revision = revision + 1
	next.meta.applied_transaction_ids.append(transaction_id)
	next.meta.transaction_receipts[transaction_id] = {"revision": next.revision, "request_digest": digest}
	if not _codec.decode_profile_v2(next).ok:
		return {"ok": false, "reason": &"invalid_candidate"}
	_profile_transaction_busy = true
	var saved := _write_payload(next)
	_profile_transaction_busy = false
	if not saved:
		return {"ok": false, "reason": &"write_failed", "warning": _last_save_warning}
	return {"ok": true, "revision": next.revision, "already_applied": false, "warning": _last_save_warning}


# JSON reload turns integer fields into floats. Request identity must follow the
# validated numeric value, not whether it came from a live owner or a JSON parser.
func _canonical_request_numbers(value):
	if value is float and is_finite(value) and absf(value) <= 9007199254740991 and value == floor(value):
		return int(value)
	if value is Array:
		var values: Array = []
		for child in value:
			values.append(_canonical_request_numbers(child))
		return values
	if value is Dictionary:
		var values: Dictionary = {}
		for key in value:
			values[key] = _canonical_request_numbers(value[key])
		return values
	return value


func configure(storage_path: String = DEFAULT_STORAGE_PATH) -> bool:
	if _profile_mode or storage_path.is_empty():
		return false
	_storage_path = storage_path
	_configured = true
	return true


func has_record() -> bool:
	return _configured and (FileAccess.file_exists(_storage_path) or FileAccess.file_exists(_previous_storage_path()))


func save_checkpoint(checkpoint: Dictionary) -> bool:
	if not _configured or _profile_mode:
		return false
	var payload: Dictionary = _codec.encode_checkpoint(checkpoint)
	if payload.is_empty() or not bool(_codec.decode_checkpoint(payload).get("ok", false)):
		return false
	return _write_payload(payload)


func load_checkpoint() -> Dictionary:
	if not _configured or _profile_mode:
		return {"ok": false, "reason": &"not_configured"}
	if not FileAccess.file_exists(_storage_path):
		return {"ok": false, "reason": &"recovery_required"} if FileAccess.file_exists(_previous_storage_path()) else {"ok": false, "reason": &"missing"}
	var file := FileAccess.open(_storage_path, FileAccess.READ)
	if file == null:
		return {"ok": false, "reason": &"unreadable"}
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {"ok": false, "reason": &"invalid_json"}
	return _codec.decode_checkpoint(parsed)


func clear_record() -> bool:
	if not _configured or _profile_mode:
		return false
	var succeeded := true
	for storage_path in [_storage_path, _temporary_storage_path(), _previous_storage_path()]:
		if FileAccess.file_exists(storage_path):
			succeeded = DirAccess.remove_absolute(ProjectSettings.globalize_path(storage_path)) == OK and succeeded
	return succeeded


func storage_path() -> String:
	return _storage_path


func _write_payload(payload: Dictionary) -> bool:
	_last_save_warning = &""
	var serialized := JSON.stringify(payload, "", true, _profile_mode)
	if serialized.is_empty():
		return false
	var temporary_path := _temporary_storage_path()
	if FileAccess.file_exists(temporary_path):
		_last_save_warning = &"temporary_recovery_required"
		return false
	if FileAccess.file_exists(_previous_storage_path()):
		return false

	var temporary_file := _open_temporary_file(temporary_path)
	if temporary_file == null:
		_last_save_warning = &"temporary_open_failed"
		return false
	if not _store_temporary_text(temporary_file, serialized):
		temporary_file.close()
		_last_save_warning = &"temporary_write_failed"
		return false
	var flush_error := _flush_temporary_file(temporary_file)
	temporary_file.close()
	if flush_error != OK:
		_last_save_warning = &"temporary_flush_failed"
		return false
	if not _readback_matches(temporary_path, serialized):
		_last_save_warning = &"temporary_readback_failed"
		return false

	var target_path := ProjectSettings.globalize_path(_storage_path)
	var temporary_absolute_path := ProjectSettings.globalize_path(temporary_path)
	var previous_path := _previous_storage_path()
	var previous_absolute_path := ProjectSettings.globalize_path(previous_path)
	var moved_previous := false
	if FileAccess.file_exists(_storage_path):
		if _rename_record(target_path, previous_absolute_path) != OK:
			_last_save_warning = &"previous_rename_failed"
			_remove_if_present(temporary_path)
			return false
		moved_previous = true
	if _rename_record(temporary_absolute_path, target_path) != OK:
		_last_save_warning = &"promote_rename_failed"
		if moved_previous and _rename_record(previous_absolute_path, target_path) != OK:
			_last_save_warning = &"recovery_required"
			return false # Preserve both original and candidate if rollback also fails.
		_remove_if_present(temporary_path)
		return false
	if not _readback_matches(_storage_path, serialized):
		_last_save_warning = &"canonical_readback_failed"
		# Keep the failed new candidate for explicit recovery; restore old bytes.
		if _rename_record(target_path, temporary_absolute_path) != OK:
			_last_save_warning = &"recovery_required"
		elif moved_previous and _rename_record(previous_absolute_path, target_path) != OK:
			_last_save_warning = &"recovery_required"
		return false
	if moved_previous and _remove_previous_record() != OK:
		_last_save_warning = &"previous_cleanup_pending"
	return true


func _readback_matches(path: String, expected_text: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	if text != expected_text:
		return false
	var parser := JSON.new()
	if parser.parse(text) != OK or not (parser.data is Dictionary):
		return false
	var decoded: Dictionary = _codec.decode_profile_v2(parser.data) if _profile_mode else _codec.decode_checkpoint(parser.data)
	return bool(decoded.get("ok", false))


func last_save_warning() -> StringName:
	return _last_save_warning


func _rename_record(from: String, to: String) -> Error:
	return DirAccess.rename_absolute(from, to)


# Keep real file ownership here; tests inject only the failing I/O operation.
func _open_temporary_file(path: String) -> FileAccess:
	return FileAccess.open(path, FileAccess.WRITE)


func _store_temporary_text(file: FileAccess, text: String) -> bool:
	return file.store_string(text) and file.get_error() == OK


func _flush_temporary_file(file: FileAccess) -> Error:
	file.flush()
	return file.get_error()


func _remove_previous_record() -> Error:
	return DirAccess.remove_absolute(ProjectSettings.globalize_path(_previous_storage_path()))


func _remove_if_present(storage_path: String) -> void:
	if FileAccess.file_exists(storage_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(storage_path))


func _temporary_storage_path() -> String:
	return _storage_path + TEMPORARY_SUFFIX


func _previous_storage_path() -> String:
	return _storage_path + PREVIOUS_SUFFIX
