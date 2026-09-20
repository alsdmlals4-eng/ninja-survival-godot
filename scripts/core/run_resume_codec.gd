# 워크벤치 확정 checkpoint를 JSON 원시값만으로 저장하고, 모든 도메인 값을 검증 후 복원한다.
extends RefCounted
class_name RunResumeCodec

const SCHEMA_VERSION := 1
const PROFILE_CONTRACT := "ns-replan-20260911"


# Departure and post-school preparation values are validated here. Business
# transactions and default Main adoption remain separate callers.
func decode_profile_v2(payload: Dictionary, pending_transaction_id: String = "") -> Dictionary:
	if not _profile_integer(payload.get("schema_version")) or payload.schema_version != 2:
		return {"ok": false, "reason": &"unsupported_schema"}
	if not (payload.get("content_contract") is String) or payload.content_contract != PROFILE_CONTRACT:
		return {"ok": false, "reason": &"unsupported_content"}
	if not _profile_integer(payload.get("revision")) or not payload.has("active_run"):
		return {"ok": false, "reason": &"invalid_profile"}
	var meta = payload.get("meta")
	if not (meta is Dictionary) or not _profile_integer(meta.get("soul_balance")) or not (meta.get("unlocked_support_choice") is bool):
		return {"ok": false, "reason": &"invalid_meta"}
	if not _profile_unique_ids(meta.get("settled_run_ids")) or not _profile_unique_ids(meta.get("applied_transaction_ids")):
		return {"ok": false, "reason": &"invalid_ledger"}
	var receipts = meta.get("transaction_receipts")
	if not (receipts is Dictionary) or receipts.size() != meta.applied_transaction_ids.size():
		return {"ok": false, "reason": &"invalid_receipts"}
	for id in meta.applied_transaction_ids:
		var receipt = receipts.get(id)
		if not (receipt is Dictionary) or receipt.size() != 2 or not _profile_integer(receipt.get("revision")):
			return {"ok": false, "reason": &"invalid_receipts"}
		if receipt.revision < 1 or receipt.revision > payload.revision or not (receipt.get("request_digest") is String):
			return {"ok": false, "reason": &"invalid_receipts"}
		var digest: String = receipt.request_digest
		if digest.length() != 64:
			return {"ok": false, "reason": &"invalid_receipts"}
		for character in digest:
			if not character in "0123456789abcdef":
				return {"ok": false, "reason": &"invalid_receipts"}
	for run_id in meta.settled_run_ids:
		if not receipts.has("settle:" + run_id) and pending_transaction_id != "settle:" + run_id:
			return {"ok": false, "reason": &"invalid_settlement"}
	if meta.unlocked_support_choice and not receipts.has("unlock:support-choice-v1") and pending_transaction_id != "unlock:support-choice-v1":
		return {"ok": false, "reason": &"invalid_unlock"}
	if payload.active_run != null:
		var active_result := _decode_active_departure(payload.active_run, meta.settled_run_ids)
		if not active_result.ok:
			return active_result
		var retry_id: String = "retry:" + payload.active_run.run_id
		if payload.active_run.retry_consumed and not receipts.has(retry_id) and pending_transaction_id != retry_id:
			return {"ok": false, "reason": &"invalid_retry_receipt"}
	# Only primitive known fields leave this codec; unknown object fields are rejected.
	if payload.size() != 5 or meta.size() != 5:
		return {"ok": false, "reason": &"unknown_profile_fields"}
	var result: Dictionary = payload.duplicate(true)
	result.revision = int(payload.revision)
	result.schema_version = 2
	result.meta.soul_balance = int(meta.soul_balance)
	if payload.active_run != null:
		result.active_run = _to_json_primitive(payload.active_run).value
	return {"ok": true, "profile": result}


func _decode_active_departure(raw, settled_run_ids: Array) -> Dictionary:
	var invalid := {"ok": false, "reason": &"invalid_active_run"}
	if not (raw is Dictionary) or raw.size() != 7 or not _profile_unique_ids([raw.get("run_id")]):
		return invalid
	if settled_run_ids.has(raw.run_id) or not (raw.get("starting_school") is String):
		return invalid
	if not (raw.get("elite_qualified") is bool) or not (raw.get("retry_consumed") is bool):
		return invalid
	if not raw.has("preparation") or not (raw.get("checkpoint") is Dictionary):
		return invalid
	if not _profile_unique_ids(raw.get("eligible_boss_ids")):
		return invalid
	var decoded := decode_selected_checkpoint(raw.checkpoint)
	if not decoded.ok:
		return decoded
	if raw.starting_school != decoded.checkpoint.loadout.origin_school_id:
		return invalid
	var clears: Array = decoded.checkpoint.route.cleared_school_ids
	if raw.preparation != null:
		var prepared := _decode_selected_preparation(raw.preparation, decoded.checkpoint)
		if not prepared.ok:
			return prepared
		clears = prepared.clears
	for school in clears:
		if not raw.eligible_boss_ids.has(school):
			return invalid
	# Rollback may retain the current battlefield's earned eligibility, but cannot
	# invent progress in any unrelated unvisited school or discard previous clears.
	var allowed: Array = clears.duplicate()
	var active_school: String = decoded.checkpoint.route.active_school_id
	if raw.retry_consumed and active_school != "" and not allowed.has(active_school):
		allowed.append(active_school)
	for school in raw.eligible_boss_ids:
		if not allowed.has(school):
			return invalid
	return {"ok": true}


# Post-school preparation derives its route from the last departure + that one
# school clear. It never overwrites the rollback checkpoint or invents a route.
func _decode_selected_preparation(raw, checkpoint: Dictionary) -> Dictionary:
	var invalid := {"ok": false, "reason": &"invalid_preparation"}
	if not (raw is Dictionary) or not _to_json_primitive(raw).ok:
		return invalid
	if raw.size() != 12 + int(raw.has("fate_state")) + int(raw.has("vitals")):
		return invalid
	if raw.has("vitals") and not _valid_vitals(raw.vitals): return invalid
	if not _profile_unique_ids([raw.get("prepare_session_id")]) or raw.prepare_session_id == checkpoint.prepare_session_id:
		return invalid
	if raw.get("phase") != "preparing" or not _profile_integer(raw.get("revision")) or not _profile_integer(raw.get("gold")):
		return invalid
	if not (raw.get("healing_applied") is bool) or not raw.healing_applied:
		return invalid
	if not (raw.get("pending_fate") is String) or not (raw.get("provisional_school") is String):
		return invalid
	# Older preparation records had no Fate reservation and only an empty choice.
	if not raw.has("fate_state") and raw.pending_fate != "":
		return invalid
	if raw.has("fate_state") and not (raw.fate_state is Dictionary):
		return invalid
	for key in ["access", "equipment", "spatial_session", "loadout", "reward_state"]:
		if not (raw.get(key) is Dictionary):
			return invalid
	var route = RUN_ROUTE_STATE_SCRIPT.new()
	if not route.restore_from_checkpoint(checkpoint.route) or not route.mark_active_school_cleared():
		return invalid
	if raw.provisional_school != "" and not route.set_provisional_next_school(StringName(raw.provisional_school)):
		return invalid
	var access = SELECTED_COORDINATOR.SELECTED_ACCESS.new()
	if not access.restore_selected_snapshot(raw.access):
		return invalid
	var clears: Array = route.cleared_school_ids()
	if raw.access.stabilized_school_ids.size() != clears.size():
		return invalid
	for school in raw.access.stabilized_school_ids:
		if not clears.has(StringName(school)):
			return invalid
	for school in checkpoint.access.trace_decisions:
		if raw.access.trace_decisions.get(school) != checkpoint.access.trace_decisions[school]:
			return invalid
	if raw.loadout.get("draft_picks") != checkpoint.loadout.draft_picks:
		return invalid
	var spatial: Dictionary = raw.spatial_session
	var bundle := {"backpack": spatial.get("backpack"), "buffer": spatial.get("buffer"),
		"loadout": raw.loadout, "equipment": raw.equipment, "access": raw.access}
	if not SELECTED_COORDINATOR.validate_selected_build_bundle(bundle):
		return invalid
	if raw.loadout.origin_school_id != checkpoint.loadout.origin_school_id:
		return invalid
	var session = REST_SESSION_SCRIPT.new()
	var items: Dictionary = SELECTED_COORDINATOR.SELECTED_CATALOG.build_items()
	var bags: Dictionary = MVP4_CATALOG_SCRIPT.build_bags()
	session.begin(BACKPACK_STATE_SCRIPT.from_persistent_snapshot(checkpoint.backpack),
		SELECTED_COORDINATOR.BAG_RESOLVER.new(), items, bags, access.starting_school_id())
	if not session.restore_preparation_snapshot(spatial):
		return invalid
	var reward: Dictionary = raw.reward_state
	if not _profile_integer(reward.get("segment")) or int(reward.segment) != int(checkpoint.route.stage_index):
		return invalid
	if reward.get("school") != String(access.starting_school_id()) or reward.get("new_school") != checkpoint.route.active_school_id:
		return invalid
	var controller = load("res://scripts/core/rest_reward_controller.gd").new()
	controller.configure(null, session, items, bags, RandomNumberGenerator.new(), access)
	var valid: bool = controller.restore_persistent_snapshot(reward)
	controller.free()
	if not valid:
		return invalid
	if raw.has("fate_state"):
		var fate_defs: Dictionary = load("res://scripts/data/mvp3_catalog.gd").build_fates()
		var build = load("res://scripts/core/run_build_state.gd").new()
		build.configure(items, fate_defs)
		for id in checkpoint.build.selected_fates:
			build.select_fate(StringName(id))
		var fate_owner = load("res://scripts/core/fate_controller.gd").new()
		fate_owner.configure(build, fate_defs, RandomNumberGenerator.new())
		var fate_valid: bool = fate_owner.restore_preparation_snapshot(raw.fate_state)
		fate_valid = fate_valid and String(fate_owner.pending_fate_id()) == raw.pending_fate
		fate_owner.free()
		build.free()
		if not fate_valid:
			return invalid
	return {"ok": true, "clears": clears}


static func _profile_integer(value) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and value >= 0 and value <= 9007199254740991 and float(value) == floor(float(value))


static func _profile_unique_ids(value) -> bool:
	if not (value is Array):
		return false
	var seen := {}
	for id in value:
		if not (id is String) or id.is_empty() or id.length() > 256 or seen.has(id):
			return false
		seen[id] = true
	return true

const RUN_MODIFIER_SET_SCRIPT = preload("res://scripts/data/run_modifier_set.gd")
const BACKPACK_STATE_SCRIPT = preload("res://scripts/backpack/backpack_state.gd")
const RUN_ROUTE_STATE_SCRIPT = preload("res://scripts/core/run_route_state.gd")
const RUN_SETTLEMENT_LEDGER_SCRIPT = preload("res://scripts/core/run_settlement_ledger.gd")
const NINJUTSU_LOADOUT_STATE_SCRIPT = preload("res://scripts/core/ninjutsu_loadout_state.gd")
const MVP4_CATALOG_SCRIPT = preload("res://scripts/data/mvp4_catalog.gd")
const MVP3_CATALOG_SCRIPT = preload("res://scripts/data/mvp3_catalog.gd")
const REST_SESSION_SCRIPT = preload("res://scripts/backpack/rest_backpack_session.gd")
const ITEM_INSTANCE_SCRIPT = preload("res://scripts/data/item_instance.gd")
const SELECTED_COORDINATOR = preload("res://scripts/core/rest_commit_coordinator.gd")


# Validates a departure snapshot without restoring or signalling any live owner.
# Profile preparation and retry eligibility are validated separately by their owners.
func decode_selected_checkpoint(raw: Dictionary) -> Dictionary:
	var invalid := {"ok": false, "reason": &"invalid_selected_checkpoint"}
	if raw.size() != 10 + int(raw.has("vitals")) or raw.get("rules_version") != PROFILE_CONTRACT:
		return invalid
	if raw.has("vitals") and not _valid_vitals(raw.vitals): return invalid
	if not _profile_unique_ids([raw.get("prepare_session_id")]):
		return invalid
	for key in ["build", "route", "circuit", "backpack", "loadout", "access", "ultimate_charge"]:
		if not (raw.get(key) is Dictionary):
			return invalid
	var primitive := _to_json_primitive(raw)
	if not primitive.ok:
		return invalid
	var candidate: Dictionary = primitive.value
	invalid.reason = &"invalid_selected_route"
	var route: Dictionary = candidate.route
	if route.size() != 8 or not _profile_integer(route.get("stage_index")) or not (route.get("final_binding_eligible") is bool):
		return invalid
	for key in ["active_school_id", "provisional_school_id"]:
		if not (route.get(key) is String):
			return invalid
	for key in ["cleared_school_ids", "clear_order", "school_ids", "unvisited_school_ids"]:
		if not _profile_unique_ids(route.get(key)):
			return invalid
	var route_owner = RUN_ROUTE_STATE_SCRIPT.new()
	if not route_owner.restore_from_checkpoint(route):
		return invalid
	var derived_route: Dictionary = _to_json_primitive(route_owner.get_route_snapshot()).value
	var compared_route: Dictionary = route.duplicate(true)
	compared_route.stage_index = int(route.stage_index)
	if compared_route != derived_route or route.provisional_school_id != "":
		return invalid
	var circuit: Dictionary = candidate.circuit
	invalid.reason = &"invalid_departure_circuit"
	if circuit.size() != 2 or circuit.get("active_school_id") != route.active_school_id:
		return invalid
	var expected_phase := "final_boss" if route.final_binding_eligible else "core"
	if circuit.get("phase") != expected_phase or (not route.final_binding_eligible and route.active_school_id == ""):
		return invalid
	var build: Dictionary = candidate.build
	invalid.reason = &"invalid_selected_build"
	if build.size() != 7 or not _profile_integer(build.get("gold")) or not (build.get("owned_items") is Dictionary) or not build.owned_items.is_empty():
		return invalid # Selected spatial items must not also enter the legacy inventory.
	if not _profile_unique_ids(build.get("selected_fates")) or not _validate_fates(build.selected_fates):
		return invalid
	if not (build.get("economy_receipts") is Array):
		return invalid
	for receipt in build.economy_receipts:
		if not (receipt is Dictionary) or receipt.size() != 3 or not _profile_integer(receipt.get("amount")):
			return invalid
		if receipt.get("source") not in ["normal", "elite", "school_boss"] or receipt.get("school_id") not in RUN_ROUTE_STATE_SCRIPT.SCHOOL_IDS:
			return invalid
	var bundle := {"backpack": candidate.backpack, "buffer": candidate.get("buffer"),
		"loadout": candidate.loadout, "access": candidate.access, "equipment": build.get("equipment")}
	invalid.reason = &"invalid_selected_bundle"
	if not SELECTED_COORDINATOR.validate_selected_build_bundle(bundle):
		return invalid
	var origin: String = candidate.loadout.origin_school_id
	invalid.reason = &"selected_origin_or_trace_mismatch"
	if build.get("selected_school_id") != origin:
		return invalid
	var stabilized: Array = candidate.access.stabilized_school_ids
	if stabilized.size() != route.cleared_school_ids.size():
		return invalid
	for school in stabilized:
		if not route.cleared_school_ids.has(school) or not candidate.access.trace_decisions.has(school):
			return invalid # Trace decisions must be resolved before another departure.
	var charge: Dictionary = candidate.ultimate_charge
	invalid.reason = &"invalid_ultimate_charge"
	var amount = charge.get("resource_amount")
	if charge.size() != 2 or charge.get("school_id") != origin or not (amount is int or amount is float):
		return invalid
	var charge_caps := {"bongma": 120, "cheonsul": 3, "guiin": 100, "heukyeong": 3}
	if not is_finite(float(amount)) or amount < 0 or amount > charge_caps[origin]:
		return invalid
	var bag = BACKPACK_STATE_SCRIPT.from_persistent_snapshot(candidate.backpack)
	invalid.reason = &"selected_modifier_mismatch"
	var resolution = SELECTED_COORDINATOR.BAG_RESOLVER.new().resolve(bag,
		SELECTED_COORDINATOR.SELECTED_CATALOG.build_items(), MVP4_CATALOG_SCRIPT.build_bags(), StringName(origin))
	if build.get("committed_backpack_modifiers") != resolution.modifiers.to_persistent_snapshot():
		return invalid
	return {"ok": true, "checkpoint": candidate}


static func _valid_vitals(value) -> bool:
	if not (value is Dictionary) or value.size() != 3: return false
	for field in ["health", "max_health", "emergency_potions"]:
		if not _profile_integer(value.get(field)): return false
	return value.health > 0 and value.max_health > 0 and value.health <= value.max_health and value.emergency_potions <= 1


func encode_checkpoint(checkpoint: Dictionary) -> Dictionary:
	var build = checkpoint.get("build", null)
	var route = checkpoint.get("route", null)
	var circuit = checkpoint.get("circuit", null)
	var loadout = checkpoint.get("loadout", null)
	if not (build is Dictionary) or not (route is Dictionary) or not (circuit is Dictionary) or not (loadout is Dictionary):
		return {}
	if loadout.has("selection_contract") or build.has("equipment"):
		return {} # Selectable books must never silently become a schema1 starter save.
	var modifiers = build.get("committed_backpack_modifiers", null)
	var backpack_state = circuit.get("committed_backpack_state", null)
	if modifiers == null or not modifiers.has_method("to_persistent_snapshot") or backpack_state == null or not backpack_state.has_method("to_persistent_snapshot"):
		return {}
	if backpack_state.to_persistent_snapshot().has("catalog_contract"):
		return {} # Even an empty new board cannot be interpreted by schema1.

	var persistent_build: Dictionary = build.duplicate(true)
	persistent_build["committed_backpack_modifiers"] = modifiers.to_persistent_snapshot()
	var persistent_circuit: Dictionary = circuit.duplicate(true)
	persistent_circuit.erase("committed_backpack_state")
	persistent_circuit["backpack"] = backpack_state.to_persistent_snapshot()
	var carried = circuit.get("carried_buffer", [])
	if not REST_SESSION_SCRIPT.is_valid_carried_buffer(carried, backpack_state, MVP4_CATALOG_SCRIPT.build_items()):
		return {}
	var serialized_buffer: Array = []
	for item in carried:
		serialized_buffer.append({"instance_id": item.instance_id, "definition_id": String(item.definition_id), "rotation_quarters": item.rotation_quarters})
	persistent_circuit["carried_buffer"] = serialized_buffer
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
	if raw_loadout.has("selection_contract"):
		return {"ok": false, "reason": &"unsupported_selection_contract"}

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
	if raw_build.has("equipment"):
		return {} # Selected equipment requires the single profile2 transaction.
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
	if backpack_snapshot is Dictionary and backpack_snapshot.has("catalog_contract"):
		return {}
	if active_school_id == &"" or active_school_id != StringName(restored_route.get("active_school_id", &"")) or not (backpack_snapshot is Dictionary):
		return {}
	var backpack_state = BACKPACK_STATE_SCRIPT.from_persistent_snapshot(backpack_snapshot)
	if backpack_state == null:
		return {}
	var raw_buffer = raw_circuit.get("carried_buffer", [])
	if not (raw_buffer is Array) or raw_buffer.size() > REST_SESSION_SCRIPT.BUFFER_CAPACITY:
		return {}
	var carried: Array = []
	for raw_item in raw_buffer:
		if not (raw_item is Dictionary) or not _is_positive_whole_number(raw_item.get("instance_id")) or not _is_whole_number(raw_item.get("rotation_quarters")) or typeof(raw_item.get("definition_id")) != TYPE_STRING:
			return {}
		var item = ITEM_INSTANCE_SCRIPT.new()
		item.instance_id = int(raw_item.instance_id)
		item.definition_id = StringName(raw_item.definition_id)
		item.rotation_quarters = int(raw_item.rotation_quarters)
		carried.append(item)
	if not REST_SESSION_SCRIPT.is_valid_carried_buffer(carried, backpack_state, MVP4_CATALOG_SCRIPT.build_items()):
		return {}
	return {
		"active_school_id": active_school_id,
		"committed_backpack_state": backpack_state,
		"carried_buffer": carried,
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
