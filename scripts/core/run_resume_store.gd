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
