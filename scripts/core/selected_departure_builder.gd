# Pure selected-mode departure composition. No disk writes or live owner signals.
extends RefCounted

const ROUTE = preload("res://scripts/core/run_route_state.gd")
const GEAR = preload("res://scripts/core/equipment_loadout_state.gd")
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const SESSION = preload("res://scripts/backpack/rest_backpack_session.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")
const BAGS = preload("res://scripts/data/mvp4_catalog.gd")
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const BUILD = preload("res://scripts/core/run_build_state.gd")
const FATE = preload("res://scripts/core/fate_controller.gd")
const FATES = preload("res://scripts/data/mvp3_catalog.gd")
const LAYOUT = preload("res://scripts/core/selected_layout_contract.gd")


func prepare(request: Dictionary, store) -> Dictionary:
	if not _valid_request(request):
		return _fail(&"invalid_departure_request")
	# JSON normalizes int/float and StringName differences across reopen. Never
	# serialize arbitrary objects or non-finite numbers into a receipt identity.
	var normalized: Dictionary = JSON.parse_string(JSON.stringify(request, "", true, true))
	var transaction_id := "depart:" + JSON.stringify(normalized, "", true, true).sha256_text()
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok:
		return loaded
	var profile: Dictionary = loaded.profile
	if profile.meta.transaction_receipts.has(transaction_id):
		return {"ok": true, "already_applied": true, "profile": profile, "transaction_id": transaction_id}
	if profile.revision != request.expected_revision:
		return _fail(&"stale_revision")
	var run = profile.active_run
	if not (run is Dictionary) or run.run_id != str(request.run_id):
		return _fail(&"wrong_run")
	var prep = run.preparation
	if not (prep is Dictionary) or prep.prepare_session_id != str(request.prepare_session_id):
		return _fail(&"wrong_preparation")
	if prep.revision != request.expected_prepare_revision or prep.equipment.revision != request.expected_equipment_revision:
		return _fail(&"stale_preparation")
	if prep.has("ultimate_charge") and prep.ultimate_charge != normalized.ultimate_charge:
		return _fail(&"charge_changed")
	var route = ROUTE.new()
	if not route.restore_from_checkpoint(run.checkpoint.route) or not route.mark_active_school_cleared():
		return _fail(&"invalid_route")
	for school in route.cleared_school_ids():
		if not prep.access.trace_decisions.has(str(school)):
			return _fail(&"trace_pending")
	if route.is_final_binding_eligible():
		if request.next_school_id != "":
			return _fail(&"no_fifth_school")
	elif not route.set_provisional_next_school(StringName(request.next_school_id)) or not route.commit_provisional_next_school():
		return _fail(&"route_pending")
	# A paid bag may be placed in this draft, but cannot be discarded at departure.
	if normalized.spatial_session.get("pending_bag") != null:
		return _fail(&"pending_bag")
	var session = SESSION.new()
	session.begin(BAG.from_persistent_snapshot(prep.spatial_session.backpack), RESOLVER.new(),
		ITEMS.build_items(), BAGS.build_bags(), StringName(run.starting_school))
	if not session.restore_preparation_snapshot(normalized.spatial_session):
		return _fail(&"invalid_layout")
	var failures: Array = session.commit_failures(int(prep.reward_state.chests), bool(prep.reward_state.boss_pending), false)
	if not failures.is_empty():
		return {"ok": false, "reason": failures[0], "failures": failures}
	if not LAYOUT.same_owned_inventory(prep.spatial_session, normalized.spatial_session):
		return _fail(&"ownership_changed")
	var equipment = GEAR.new()
	equipment.restore_snapshot(prep.equipment)
	for slot in GEAR.SLOTS:
		var instance_id: String = str(request.equipped_slots[slot])
		if not prep.equipment.owned_instances.has(instance_id):
			return _fail(&"unowned_equipment")
		if prep.equipment.equipped_slots[slot] != instance_id:
			var id := StringName(prep.equipment.owned_instances[instance_id].definition_id)
			if not equipment.equip(StringName(slot), id):
				return _fail(&"invalid_equipment_slot")
	var fate_result := _fates_for_departure(prep, run.checkpoint.build.selected_fates,
		StringName(request.fate_id), route.is_final_binding_eligible())
	if not fate_result.ok:
		return fate_result
	var spatial: Dictionary = session.persistent_preparation_snapshot()
	var loadout: Dictionary = prep.loadout.duplicate(true)
	var active: Array = []
	for item in spatial.backpack.items:
		var spell := BOOKS.spell_id(StringName(item.definition_id))
		if spell != &"":
			active.append(str(spell))
	loadout.active_spell_ids = active
	loadout.pending_spell_ids = []
	var checkpoint: Dictionary = run.checkpoint.duplicate(true)
	checkpoint.prepare_session_id = str(request.prepare_session_id)
	checkpoint.route = route.get_route_snapshot()
	checkpoint.circuit = {"phase": "final_boss" if route.is_final_binding_eligible() else "core",
		"active_school_id": str(route.active_school_id())}
	checkpoint.backpack = spatial.backpack
	checkpoint.buffer = spatial.buffer
	checkpoint.access = prep.access.duplicate(true)
	checkpoint.loadout = loadout
	checkpoint.ultimate_charge = normalized.ultimate_charge
	if prep.has("vitals"):
		checkpoint.vitals = prep.vitals.duplicate(true)
	checkpoint.build.gold = int(prep.gold)
	checkpoint.build.equipment = equipment.get_snapshot()
	checkpoint.build.selected_fates = fate_result.selected
	checkpoint.build.committed_backpack_modifiers = session.current_resolution().modifiers.to_persistent_snapshot()
	var candidate: Dictionary = profile.duplicate(true)
	candidate.active_run.checkpoint = checkpoint
	candidate.active_run.preparation = null
	# Runtime load avoids codec -> coordinator -> builder -> codec preload cycle.
	var decoded: Dictionary = load("res://scripts/core/run_resume_codec.gd").new().decode_profile_v2(candidate)
	if not decoded.ok:
		return decoded
	return {"ok": true, "already_applied": false, "profile": decoded.profile, "transaction_id": transaction_id}


func _fates_for_departure(prep: Dictionary, selected: Array, choice: StringName, final: bool) -> Dictionary:
	if not prep.has("fate_state"):
		return {"ok": true, "selected": selected.duplicate()} if final and choice == &"" else _fail(&"fate_candidates_unavailable")
	if choice == &"":
		return {"ok": true, "selected": selected.duplicate()} if final or prep.fate_state.candidate_ids.is_empty() else _fail(&"fate_pending")
	var build = BUILD.new()
	build.configure(ITEMS.build_items(), FATES.build_fates())
	for id in selected:
		build.select_fate(StringName(id))
	var fate = FATE.new()
	fate.configure(build, FATES.build_fates(), RandomNumberGenerator.new())
	var snapshot: Dictionary = prep.fate_state.duplicate(true)
	snapshot.pending_fate = str(choice)
	var valid: bool = fate.restore_preparation_snapshot(snapshot) and fate._commit_pending()
	var result := {"ok": true, "selected": build.selected_fates.duplicate()} if valid else _fail(&"fate_rejected")
	fate.free()
	build.free()
	return result


func _valid_request(request: Dictionary) -> bool:
	if request.size() != 10 or not _primitive(request):
		return false
	for field in ["run_id", "prepare_session_id", "next_school_id", "fate_id"]:
		if not (request.get(field) is String or request.get(field) is StringName) or str(request[field]).length() > 256:
			return false
	if request.run_id == "" or request.prepare_session_id == "":
		return false
	for field in ["expected_revision", "expected_prepare_revision", "expected_equipment_revision"]:
		var value = request.get(field)
		if not _integer(value) or value < 0 or value >= 9007199254740991:
			return false
	if not (request.get("spatial_session") is Dictionary) or not (request.get("equipped_slots") is Dictionary) or not (request.get("ultimate_charge") is Dictionary):
		return false
	if request.equipped_slots.size() != 3:
		return false
	for slot in GEAR.SLOTS:
		if not (request.equipped_slots.get(slot) is String or request.equipped_slots.get(slot) is StringName):
			return false
	var spatial: Dictionary = request.spatial_session
	if not (spatial.get("backpack") is Dictionary) or spatial.backpack.size() != 4:
		return false
	if not _integer(spatial.backpack.get("next_instance_id")):
		return false
	for records in [spatial.backpack.get("items"), spatial.backpack.get("bags"), spatial.get("buffer")]:
		if not (records is Array):
			return false
		for record in records:
			if not (record is Dictionary):
				return false
			for field in ["instance_id", "rotation_quarters", "origin_x", "origin_y"]:
				if record.has(field) and not _integer(record[field]):
					return false
	return true


func _integer(value) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and absf(float(value)) <= 9007199254740991


func _primitive(value, depth := 0) -> bool:
	if depth > 16: return false
	match typeof(value):
		TYPE_NIL, TYPE_BOOL, TYPE_STRING, TYPE_STRING_NAME: return true
		TYPE_INT, TYPE_FLOAT: return is_finite(float(value)) and absf(float(value)) <= 9007199254740991
		TYPE_ARRAY:
			for child in value:
				if not _primitive(child, depth + 1): return false
			return true
		TYPE_DICTIONARY:
			for key in value:
				if not (key is String or key is StringName) or not _primitive(value[key], depth + 1): return false
			return true
	return false


func _fail(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
