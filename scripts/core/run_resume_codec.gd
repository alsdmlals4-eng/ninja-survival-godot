# 워크벤치 확정 checkpoint를 JSON 원시값만으로 저장하고, 모든 도메인 값을 검증 후 복원한다.
extends RefCounted
class_name RunResumeCodec

const SCHEMA_VERSION := 1

const RUN_MODIFIER_SET_SCRIPT = preload("res://scripts/data/run_modifier_set.gd")
const BACKPACK_STATE_SCRIPT = preload("res://scripts/backpack/backpack_state.gd")
const RUN_ROUTE_STATE_SCRIPT = preload("res://scripts/core/run_route_state.gd")
const RUN_SETTLEMENT_LEDGER_SCRIPT = preload("res://scripts/core/run_settlement_ledger.gd")
const NINJUTSU_LOADOUT_STATE_SCRIPT = preload("res://scripts/core/ninjutsu_loadout_state.gd")
const MVP4_CATALOG_SCRIPT = preload("res://scripts/data/mvp4_catalog.gd")
const MVP3_CATALOG_SCRIPT = preload("res://scripts/data/mvp3_catalog.gd")


func encode_checkpoint(checkpoint: Dictionary) -> Dictionary:
	var build = checkpoint.get("build", null)
	var route = checkpoint.get("route", null)
	var circuit = checkpoint.get("circuit", null)
	var loadout = checkpoint.get("loadout", null)
	if not (build is Dictionary) or not (route is Dictionary) or not (circuit is Dictionary) or not (loadout is Dictionary):
		return {}
	var modifiers = build.get("committed_backpack_modifiers", null)
	var backpack_state = circuit.get("committed_backpack_state", null)
	if modifiers == null or not modifiers.has_method("to_persistent_snapshot") or backpack_state == null or not backpack_state.has_method("to_persistent_snapshot"):
		return {}

	var persistent_build: Dictionary = build.duplicate(true)
	persistent_build["committed_backpack_modifiers"] = modifiers.to_persistent_snapshot()
	var persistent_circuit: Dictionary = circuit.duplicate(true)
	persistent_circuit.erase("committed_backpack_state")
	persistent_circuit["backpack"] = backpack_state.to_persistent_snapshot()
	var primitive_result := _to_json_primitive({
		"schema_version": SCHEMA_VERSION,
		"checkpoint": {
			"retry_consumed": bool(checkpoint.get("retry_consumed", false)),
			"build": persistent_build,
			"route": route.duplicate(true),
			"eligible_school_boss_ids": Array(checkpoint.get("eligible_school_boss_ids", [])).duplicate(),
			"circuit": persistent_circuit,
			"loadout": loadout.duplicate(true),
		},
	})
	return primitive_result.get("value", {}) if primitive_result.get("ok", false) else {}


func decode_checkpoint(payload: Dictionary) -> Dictionary:
	if int(payload.get("schema_version", -1)) != SCHEMA_VERSION:
		return {"ok": false, "reason": &"unsupported_schema"}
	var raw_checkpoint = payload.get("checkpoint", null)
	if not (raw_checkpoint is Dictionary):
		return {"ok": false, "reason": &"invalid_checkpoint"}
	var raw_build = raw_checkpoint.get("build", null)
	var raw_route = raw_checkpoint.get("route", null)
	var raw_circuit = raw_checkpoint.get("circuit", null)
	var raw_loadout = raw_checkpoint.get("loadout", null)
	var raw_retry_consumed = raw_checkpoint.get("retry_consumed", false)
	if not (raw_build is Dictionary) or not (raw_route is Dictionary) or not (raw_circuit is Dictionary) or not (raw_loadout is Dictionary) or typeof(raw_retry_consumed) != TYPE_BOOL:
		return {"ok": false, "reason": &"invalid_checkpoint"}

	var restored_build = _decode_build(raw_build)
	var restored_route = _decode_route(raw_route)
	var restored_ledger = _decode_ledger(raw_checkpoint.get("eligible_school_boss_ids", null))
	var restored_circuit = _decode_circuit(raw_circuit, restored_route)
	var restored_loadout = _decode_loadout(raw_loadout)
	if restored_build.is_empty() or restored_route.is_empty() or restored_ledger.is_empty() or restored_circuit.is_empty() or restored_loadout.is_empty():
		return {"ok": false, "reason": &"invalid_checkpoint"}
	return {
		"ok": true,
		"checkpoint": {
			"retry_consumed": raw_retry_consumed,
			"build": restored_build,
			"route": restored_route,
			"eligible_school_boss_ids": restored_ledger.get("eligible_school_boss_ids", []).duplicate(),
			"circuit": restored_circuit,
			"loadout": restored_loadout,
		},
	}


func _decode_build(raw_build: Dictionary) -> Dictionary:
	var raw_modifiers = raw_build.get("committed_backpack_modifiers", null)
	if not (raw_modifiers is Dictionary):
		return {}
	var modifiers = RUN_MODIFIER_SET_SCRIPT.from_persistent_snapshot(raw_modifiers)
	if modifiers == null:
		return {}
	var selected_school_id := StringName(raw_build.get("selected_school_id", ""))
	var raw_owned_items = raw_build.get("owned_items", null)
	var raw_fates = raw_build.get("selected_fates", null)
	var raw_gold = raw_build.get("gold", null)
	var raw_receipts = raw_build.get("economy_receipts", null)
	if selected_school_id == &"" or not (raw_owned_items is Dictionary) or not (raw_fates is Array) or not _is_non_negative_whole_number(raw_gold) or not (raw_receipts is Array):
		return {}
	if not _validate_owned_items(raw_owned_items) or not _validate_fates(raw_fates):
		return {}
	var restored_receipts := _restore_economy_receipts(raw_receipts)
	if restored_receipts.size() != raw_receipts.size():
		return {}
	return {
		"gold": int(raw_gold),
		"selected_school_id": selected_school_id,
		"owned_items": _restore_owned_items(raw_owned_items),
		"selected_fates": _restore_string_name_array(raw_fates),
		"committed_backpack_modifiers": modifiers,
		"economy_receipts": restored_receipts,
	}


func _decode_route(raw_route: Dictionary) -> Dictionary:
	var route_state = RUN_ROUTE_STATE_SCRIPT.new()
	var candidate := {
		"cleared_school_ids": _restore_string_name_array(raw_route.get("cleared_school_ids", [])),
		"active_school_id": StringName(raw_route.get("active_school_id", "")),
		"provisional_school_id": StringName(raw_route.get("provisional_school_id", "")),
		"stage_index": raw_route.get("stage_index", -1),
		"final_binding_eligible": raw_route.get("final_binding_eligible", false),
	}
	if not _is_whole_number(candidate.get("stage_index")) or not route_state.can_restore_from_checkpoint(candidate):
		return {}
	if not route_state.restore_from_checkpoint(candidate):
		return {}
	return route_state.get_route_snapshot()


func _decode_ledger(raw_eligible_school_boss_ids) -> Dictionary:
	if not (raw_eligible_school_boss_ids is Array):
		return {}
	var ledger = RUN_SETTLEMENT_LEDGER_SCRIPT.new()
	var candidate := {"eligible_school_boss_ids": _restore_string_name_array(raw_eligible_school_boss_ids)}
	if candidate.get("eligible_school_boss_ids", []).size() != raw_eligible_school_boss_ids.size():
		return {}
	if not ledger.restore_from_snapshot(candidate):
		return {}
	return ledger.get_snapshot()


func _decode_circuit(raw_circuit: Dictionary, restored_route: Dictionary) -> Dictionary:
	var active_school_id := StringName(raw_circuit.get("active_school_id", ""))
	var backpack_snapshot = raw_circuit.get("backpack", null)
	if active_school_id == &"" or active_school_id != StringName(restored_route.get("active_school_id", &"")) or not (backpack_snapshot is Dictionary):
		return {}
	var backpack_state = BACKPACK_STATE_SCRIPT.from_persistent_snapshot(backpack_snapshot)
	if backpack_state == null:
		return {}
	return {
		"active_school_id": active_school_id,
		"committed_backpack_state": backpack_state,
	}


func _decode_loadout(raw_loadout: Dictionary) -> Dictionary:
	var loadout = NINJUTSU_LOADOUT_STATE_SCRIPT.new()
	var restored: Dictionary = {}
	if loadout.restore_from_snapshot(_restore_loadout_snapshot(raw_loadout)):
		restored = loadout.get_snapshot()
	loadout.free()
	if restored.is_empty():
		return {}
	if not Array(restored.get("pending_spell_ids", [])).is_empty():
		return {}
	return restored


func _restore_loadout_snapshot(raw_loadout: Dictionary) -> Dictionary:
	return {
		"origin_school_id": StringName(raw_loadout.get("origin_school_id", "")),
		"active_spell_ids": _restore_string_name_array(raw_loadout.get("active_spell_ids", [])),
		"pending_spell_ids": _restore_string_name_array(raw_loadout.get("pending_spell_ids", [])),
	}


func _validate_owned_items(raw_owned_items: Dictionary) -> bool:
	var item_defs: Dictionary = MVP4_CATALOG_SCRIPT.build_items()
	var total_count := 0
	for raw_item_id in raw_owned_items.keys():
		if typeof(raw_item_id) != TYPE_STRING:
			return false
		var item_id := StringName(raw_item_id)
		var raw_count = raw_owned_items.get(raw_item_id)
		if not item_defs.has(item_id) or not _is_positive_whole_number(raw_count) or int(raw_count) > 2:
			return false
		total_count += int(raw_count)
	return total_count <= 6


func _restore_owned_items(raw_owned_items: Dictionary) -> Dictionary:
	var restored := {}
	for raw_item_id in raw_owned_items.keys():
		restored[StringName(raw_item_id)] = int(raw_owned_items.get(raw_item_id))
	return restored


func _restore_economy_receipts(raw_receipts: Array) -> Array[Dictionary]:
	var restored: Array[Dictionary] = []
	for raw_receipt in raw_receipts:
		if not (raw_receipt is Dictionary):
			return []
		var primitive_result := _to_json_primitive(raw_receipt)
		if not primitive_result.get("ok", false) or not (primitive_result.get("value", null) is Dictionary):
			return []
		var receipt: Dictionary = primitive_result.get("value", {})
		restored.append(receipt)
	return restored


func _validate_fates(raw_fates: Array) -> bool:
	var fate_defs: Dictionary = MVP3_CATALOG_SCRIPT.build_fates()
	var restored_fates := _restore_string_name_array(raw_fates)
	if restored_fates.size() != raw_fates.size():
		return false
	for fate_id in restored_fates:
		if not fate_defs.has(fate_id):
			return false
	return restored_fates.size() == restored_fates.duplicate().size()


func _restore_string_name_array(raw_values) -> Array[StringName]:
	if not (raw_values is Array):
		return []
	var restored: Array[StringName] = []
	for raw_value in raw_values:
		if typeof(raw_value) != TYPE_STRING:
			return []
		var value := StringName(raw_value)
		if value == &"" or restored.has(value):
			return []
		restored.append(value)
	return restored


func _to_json_primitive(value) -> Dictionary:
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_INT, TYPE_STRING:
			return {"ok": true, "value": value}
		TYPE_FLOAT:
			return {"ok": is_finite(float(value)), "value": value}
		TYPE_STRING_NAME:
			return {"ok": true, "value": String(value)}
		TYPE_ARRAY:
			var copied_array: Array = []
			for raw_value in value:
				var child_result := _to_json_primitive(raw_value)
				if not child_result.get("ok", false):
					return {"ok": false}
				copied_array.append(child_result.get("value"))
			return {"ok": true, "value": copied_array}
		TYPE_DICTIONARY:
			var copied_dictionary := {}
			for raw_key in value.keys():
				if typeof(raw_key) != TYPE_STRING and typeof(raw_key) != TYPE_STRING_NAME:
					return {"ok": false}
				var child_result := _to_json_primitive(value.get(raw_key))
				if not child_result.get("ok", false):
					return {"ok": false}
				copied_dictionary[String(raw_key)] = child_result.get("value")
			return {"ok": true, "value": copied_dictionary}
		_:
			return {"ok": false}


func _is_non_negative_whole_number(value) -> bool:
	return _is_whole_number(value) and int(value) >= 0


func _is_positive_whole_number(value) -> bool:
	return _is_whole_number(value) and int(value) > 0


func _is_whole_number(value) -> bool:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return false
	var number := float(value)
	return is_finite(number) and is_equal_approx(number, floor(number))
