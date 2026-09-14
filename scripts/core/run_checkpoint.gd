# 성공 작업대 뒤 한 번의 같은 학교 재도전에 필요한 Run snapshot을 보관한다.
extends RefCounted
class_name RunCheckpoint

var _snapshot: Dictionary = {}
var _retry_consumed := false


func capture(
	build_snapshot: Dictionary,
	route_snapshot: Dictionary,
	ledger_snapshot: Dictionary,
	circuit_snapshot: Dictionary = {},
	loadout_snapshot: Dictionary = {},
	retry_consumed := false
) -> bool:
	var active_school_id := StringName(route_snapshot.get("active_school_id", &""))
	if active_school_id == &"" or build_snapshot.is_empty() or ledger_snapshot.is_empty():
		return false
	_snapshot = {
		"build": _copy_build(build_snapshot),
		"route": route_snapshot.duplicate(true),
		"eligible_school_boss_ids": Array(ledger_snapshot.get("eligible_school_boss_ids", [])).duplicate(),
		"circuit": _copy_circuit(circuit_snapshot),
		"loadout": loadout_snapshot.duplicate(true),
	}
	_retry_consumed = retry_consumed
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


func restore_unconsumed_retry() -> bool:
	if not is_valid() or not _retry_consumed:
		return false
	_retry_consumed = false
	return true


func get_snapshot() -> Dictionary:
	return {
		"valid": is_valid(),
		"retry_consumed": _retry_consumed,
		"build": _copy_build(_snapshot.get("build", {})),
		"route": _snapshot.get("route", {}).duplicate(true),
		"eligible_school_boss_ids": Array(_snapshot.get("eligible_school_boss_ids", [])).duplicate(),
		"circuit": _copy_circuit(_snapshot.get("circuit", {})),
		"loadout": _snapshot.get("loadout", {}).duplicate(true),
	}


func _copy_build(source: Dictionary) -> Dictionary:
	var copied: Dictionary = source.duplicate(true)
	var modifiers = source.get("committed_backpack_modifiers")
	if modifiers is RunModifierSet:
		copied["committed_backpack_modifiers"] = modifiers.copy_values()
	return copied


func _copy_circuit(source: Dictionary) -> Dictionary:
	# Dictionary.duplicate(true) does not copy RefCounted domain values.
	var copied: Dictionary = source.duplicate(true)
	var backpack = source.get("committed_backpack_state")
	if backpack is BackpackState:
		copied["committed_backpack_state"] = backpack.copy_value()
	if source.get("carried_buffer") is Array:
		var held: Array = []
		for item in source.carried_buffer:
			held.append(item.copy_value() if item is ItemInstance else item)
		copied["carried_buffer"] = held
	return copied
