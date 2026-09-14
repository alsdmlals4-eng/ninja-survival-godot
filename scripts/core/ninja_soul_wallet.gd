# 재도전 비용만 영구 저장하는 닌자소울 wallet을 담당한다.
extends Node
class_name NinjaSoulWallet

signal balance_changed(new_balance: int)

const DEFAULT_STORAGE_PATH := "user://ninja_soul_wallet_v1.json"

var _storage_path := DEFAULT_STORAGE_PATH
var _balance := 0
var _configured := false


func configure(storage_path: String = DEFAULT_STORAGE_PATH, initial_balance_if_missing: int = 0) -> bool:
	if storage_path.is_empty():
		return false
	var candidate_balance: int
	if FileAccess.file_exists(storage_path):
		candidate_balance = _read_balance_from_disk(storage_path)
		if candidate_balance < 0:
			return false
	else:
		candidate_balance = maxi(initial_balance_if_missing, 0)
		if decode_legacy_balance({"balance": candidate_balance}) < 0 or not _write_to_disk(candidate_balance, storage_path):
			return false
	_storage_path = storage_path
	_balance = candidate_balance
	_configured = true
	balance_changed.emit(_balance)
	return true


func balance() -> int:
	return _balance


func can_spend(amount: int) -> bool:
	return _configured and amount > 0 and _balance >= amount


func spend_for_retry() -> bool:
	return spend(1)


func spend(amount: int) -> bool:
	if not can_spend(amount):
		return false
	var next_balance := _balance - amount
	if not _write_to_disk(next_balance):
		return false
	_balance = next_balance
	balance_changed.emit(_balance)
	return true


func get_snapshot() -> Dictionary:
	return {
		"balance": _balance,
		"storage_path": _storage_path,
		"configured": _configured,
	}


func _read_balance_from_disk(path: String) -> int:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return -1
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		return -1
	return decode_legacy_balance(parser.data)


# JSON numbers are doubles. Reject lossy/future data before conversion or migration.
static func decode_legacy_balance(parsed) -> int:
	if not (parsed is Dictionary) or parsed.has("schema_version"):
		return -1
	var raw = parsed.get("balance")
	if not (raw is int or raw is float):
		return -1
	if not is_finite(float(raw)) or raw < 0 or raw > 9007199254740991 or float(raw) != floor(float(raw)):
		return -1
	return int(raw)


func _write_to_disk(balance_to_write: int, path: String = _storage_path) -> bool:
	if balance_to_write < 0:
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"balance": balance_to_write}))
	return file.get_error() == OK
