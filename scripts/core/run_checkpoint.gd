# 성공 작업대 뒤 한 번의 같은 학교 재도전에 필요한 Run snapshot을 보관한다.
extends RefCounted
class_name RunCheckpoint

var _snapshot: Dictionary = {}
var _retry_consumed := false


func capture(
	build_snapshot: Dictionary,
	route_snapshot: Dictionary,
	ledger_snapshot: Dictionary,
	circuit_snapshot: Dictionary = {}
) -> bool:
	var active_school_id := StringName(route_snapshot.get("active_school_id", &""))
	if active_school_id == &"" or build_snapshot.is_empty() or ledger_snapshot.is_empty():
		return false
	_snapshot = {
		"build": build_snapshot.duplicate(true),
		"route": route_snapshot.duplicate(true),
		"eligible_school_boss_ids": Array(ledger_snapshot.get("eligible_school_boss_ids", [])).duplicate(),
		"circuit": circuit_snapshot.duplicate(true),
	}
	_retry_consumed = false
	return true


func is_valid() -> bool:
	return not _snapshot.is_empty()


func can_retry_school(school_id: StringName) -> bool:
	return is_valid() and not _retry_consumed and school_id != &"" and StringName(_snapshot.get("route", {}).get("active_school_id", &"")) == school_id


func consume_retry() -> bool:
	if not is_valid() or _retry_consumed:
		return false
	_retry_consumed = true
	return true


func get_snapshot() -> Dictionary:
	return {
		"valid": is_valid(),
		"retry_consumed": _retry_consumed,
		"build": _snapshot.get("build", {}).duplicate(true),
		"route": _snapshot.get("route", {}).duplicate(true),
		"eligible_school_boss_ids": Array(_snapshot.get("eligible_school_boss_ids", [])).duplicate(),
		"circuit": _snapshot.get("circuit", {}).duplicate(true),
	}
