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
	_storage_path = storage_path
	if FileAccess.file_exists(_storage_path):
		if not _load_from_disk():
			return false
	else:
		_balance = maxi(initial_balance_if_missing, 0)
		if not _write_to_disk(_balance):
			return false
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


func _load_from_disk() -> bool:
	var file := FileAccess.open(_storage_path, FileAccess.READ)
	if file == null:
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return false
	var raw_balance := int(parsed.get("balance", -1))
	if raw_balance < 0:
		return false
	_balance = raw_balance
	return true


func _write_to_disk(balance_to_write: int) -> bool:
	if balance_to_write < 0:
		return false
	var file := FileAccess.open(_storage_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify({"balance": balance_to_write}))
	return file.get_error() == OK
