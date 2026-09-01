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


func configure(storage_path: String = DEFAULT_STORAGE_PATH) -> bool:
	if storage_path.is_empty():
		return false
	_storage_path = storage_path
	_configured = true
	return true


func has_record() -> bool:
	return _configured and (FileAccess.file_exists(_storage_path) or FileAccess.file_exists(_previous_storage_path()))


func save_checkpoint(checkpoint: Dictionary) -> bool:
	if not _configured:
		return false
	var payload: Dictionary = _codec.encode_checkpoint(checkpoint)
	if payload.is_empty():
		return false
	return _write_payload(payload)


func load_checkpoint() -> Dictionary:
	if not _configured:
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
	if not _configured:
		return false
	var succeeded := true
	for storage_path in [_storage_path, _temporary_storage_path(), _previous_storage_path()]:
		if FileAccess.file_exists(storage_path):
			succeeded = DirAccess.remove_absolute(ProjectSettings.globalize_path(storage_path)) == OK and succeeded
	return succeeded


func storage_path() -> String:
	return _storage_path


func _write_payload(payload: Dictionary) -> bool:
	var serialized := JSON.stringify(payload)
	if serialized.is_empty():
		return false
	var temporary_path := _temporary_storage_path()
	if FileAccess.file_exists(temporary_path) and DirAccess.remove_absolute(ProjectSettings.globalize_path(temporary_path)) != OK:
		return false
	if FileAccess.file_exists(_previous_storage_path()):
		return false

	var temporary_file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if temporary_file == null:
		return false
	temporary_file.store_string(serialized)
	temporary_file.flush()
	var write_succeeded := temporary_file.get_error() == OK
	temporary_file = null
	if not write_succeeded:
		_remove_if_present(temporary_path)
		return false

	var target_path := ProjectSettings.globalize_path(_storage_path)
	var temporary_absolute_path := ProjectSettings.globalize_path(temporary_path)
	var previous_path := _previous_storage_path()
	var previous_absolute_path := ProjectSettings.globalize_path(previous_path)
	var moved_previous := false
	if FileAccess.file_exists(_storage_path):
		if DirAccess.rename_absolute(target_path, previous_absolute_path) != OK:
			_remove_if_present(temporary_path)
			return false
		moved_previous = true
	if DirAccess.rename_absolute(temporary_absolute_path, target_path) != OK:
		if moved_previous:
			DirAccess.rename_absolute(previous_absolute_path, target_path)
		_remove_if_present(temporary_path)
		return false
	if moved_previous and DirAccess.remove_absolute(previous_absolute_path) != OK:
		return false
	return true


func _remove_if_present(storage_path: String) -> void:
	if FileAccess.file_exists(storage_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(storage_path))


func _temporary_storage_path() -> String:
	return _storage_path + TEMPORARY_SUFFIX


func _previous_storage_path() -> String:
	return _storage_path + PREVIOUS_SUFFIX
