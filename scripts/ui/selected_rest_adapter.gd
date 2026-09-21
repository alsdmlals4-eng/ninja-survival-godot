# Detached presentation draft. Existing owners retain legality and disk authority.
extends RefCounted

const COORDINATOR = preload("res://scripts/core/rest_commit_coordinator.gd")
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const SESSION = preload("res://scripts/backpack/rest_backpack_session.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")
const BAGS = preload("res://scripts/data/mvp4_catalog.gd")
const ROUTE = preload("res://scripts/core/run_route_state.gd")
const COMBINATION = preload("res://scripts/backpack/combination_resolver.gd")

var spatial
var route
var pending_fate := ""
var pending_combination: Dictionary = {}
var reload_required := false
var _profile: Dictionary = {}
var _store
var _coordinator
var _pending_departure: Dictionary = {}

func open(store) -> Dictionary:
	if _store != null: return _fail(&"already_open")
	var coordinator = COORDINATOR.new()
	if not coordinator.configure_selected_profile(store): return _fail(&"not_ready")
	_store = store
	_coordinator = coordinator
	return reload()

func reload() -> Dictionary:
	if _store == null: return _fail(&"not_ready")
	# The write may have succeeded even when readback failed. Replay the exact
	# intent to read its receipt before expecting another preparation snapshot.
	if not _pending_departure.is_empty():
		var recovered: Dictionary = _coordinator.commit_selected_departure(_pending_departure)
		if recovered.ok:
			_clear_departed()
			recovered["departed"] = true
		return recovered
	var loaded: Dictionary = _store.load_profile()
	if not loaded.ok: return loaded
	if not _adopt(loaded.profile): return _fail(&"preparation_unavailable")
	reload_required = false
	return {"ok": true}

func _adopt(profile: Dictionary, preserve_layout := false) -> bool:
	if not (profile.get("active_run") is Dictionary) or not (profile.active_run.get("preparation") is Dictionary): return false
	var prep: Dictionary = profile.active_run.preparation
	var next_spatial = SESSION.new()
	next_spatial.begin(BAG.from_persistent_snapshot(prep.spatial_session.backpack), RESOLVER.new(),
		ITEMS.build_items(), BAGS.build_bags(), StringName(profile.active_run.starting_school))
	if not next_spatial.restore_preparation_snapshot(prep.spatial_session): return false
	var same_camp: bool = not _profile.is_empty() and _profile.active_run.run_id == profile.active_run.run_id \
		and _profile.active_run.preparation.prepare_session_id == prep.prepare_session_id
	if preserve_layout and same_camp:
		if not next_spatial.restore_preparation_snapshot(spatial.persistent_preparation_snapshot()): return false
	var next_route = ROUTE.new()
	if not next_route.restore_from_checkpoint(profile.active_run.checkpoint.route) or not next_route.mark_active_school_cleared(): return false
	if same_camp and route != null: next_route.set_provisional_next_school(route.provisional_school_id())
	else: pending_fate = ""
	_profile = profile.duplicate(true)
	spatial = next_spatial
	route = next_route
	pending_combination = {}
	return true

func snapshot() -> Dictionary:
	return _profile.active_run.preparation.duplicate(true) if not _profile.is_empty() else {}

func profile_snapshot() -> Dictionary:
	return _profile.duplicate(true)

func _ready_for_command() -> bool:
	return not _profile.is_empty() and not reload_required and spatial != null

func edit(kind: String, args: Array) -> bool:
	if not _ready_for_command() or not pending_combination.is_empty(): return false
	match kind:
		"to_buffer": return spatial.move_item_to_buffer(int(args[0]))
		"place_buffer": return spatial.place_buffer_item(int(args[0]), args[1], int(args[2]))
		"place_bag": return spatial.place_pending_bag(args[0], int(args[1]))
		"move":
			var preview = spatial.preview_item(int(args[0]), args[1], int(args[2]))
			return preview != null and preview.valid and spatial.commit_item_preview()
		"undo": return spatial.undo()
	return false

func choose_route(school: StringName) -> bool:
	return _ready_for_command() and route.set_provisional_next_school(school)

func choose_fate(id: StringName) -> bool:
	if not _ready_for_command() or not snapshot().get("fate_state", {}).get("candidate_ids", []).has(str(id)): return false
	pending_fate = str(id)
	return true

func _base_request() -> Dictionary:
	var prep := snapshot()
	return {"run_id": _profile.active_run.run_id, "prepare_session_id": prep.prepare_session_id,
		"expected_revision": int(_profile.revision), "expected_prepare_revision": int(prep.revision)}

func _accept(result: Dictionary, preserve_layout := false) -> Dictionary:
	if result.get("persisted", false) or result.get("reason") in [&"stale_revision", &"stale_preparation"]:
		reload_required = true
	if result.ok and not _adopt(result.profile, preserve_layout):
		reload_required = true
		return {"ok": false, "reason": &"committed_reload_required", "persisted": true}
	return result

func purchase(kind: String, id: String, combination: Dictionary = {}) -> Dictionary:
	if not _ready_for_command(): return _fail(&"reload_required")
	if not pending_combination.is_empty() and kind != "combination": return _fail(&"combination_pending")
	var request := _base_request()
	request.merge({"kind": kind, "offer_id": id, "spatial_session": spatial.persistent_preparation_snapshot()})
	if kind == "combination": request["combination"] = combination.duplicate(true)
	return _accept(_coordinator.commit_selected_purchase(request))

func trace(choice: String, slot: String) -> Dictionary:
	if not _ready_for_command(): return _fail(&"reload_required")
	if not pending_combination.is_empty(): return _fail(&"combination_pending")
	var request := _base_request()
	request.merge({"school_id": _profile.active_run.checkpoint.route.active_school_id, "choice": choice,
		"slot": slot, "expected_equipment_revision": int(snapshot().equipment.revision)})
	return _accept(_coordinator.commit_selected_trace(request), true)

func forge(slot: String) -> Dictionary:
	if not _ready_for_command(): return _fail(&"reload_required")
	if not pending_combination.is_empty(): return _fail(&"combination_pending")
	var request := _base_request()
	request.merge({"slot": slot, "expected_equipment_revision": int(snapshot().equipment.revision)})
	return _accept(_coordinator.commit_selected_forge(request), true)

func combination_options() -> Array:
	if not _ready_for_command() or not pending_combination.is_empty(): return []
	return COMBINATION.new().eligible_pairs(spatial.state, spatial.current_resolution(), ITEMS.build_combinations())

func begin_combination(id: StringName, a: int, b: int) -> bool:
	for option in combination_options():
		if option.combo_id == id and option.source_a_instance == a and option.source_b_instance == b:
			pending_combination = option.duplicate(true)
			return true
	return false

func cancel_combination() -> void:
	pending_combination = {}

func commit_combination(origin: Vector2i, rotation: int) -> Dictionary:
	if pending_combination.is_empty(): return _fail(&"combination_unavailable")
	return purchase("combination", str(pending_combination.combo_id), {
		"source_a": pending_combination.source_a_instance, "source_b": pending_combination.source_b_instance,
		"x": origin.x, "y": origin.y, "rotation": rotation})

func departure_request(charge: Dictionary) -> Dictionary:
	var request := _base_request()
	request.merge({"expected_equipment_revision": int(snapshot().equipment.revision),
		"spatial_session": spatial.persistent_preparation_snapshot(), "equipped_slots": snapshot().equipment.equipped_slots,
		"next_school_id": str(route.provisional_school_id()), "fate_id": pending_fate, "ultimate_charge": charge.duplicate(true)})
	return request

func readiness(charge: Dictionary) -> Array[StringName]:
	if not _ready_for_command(): return [&"reload_required"]
	if not pending_combination.is_empty(): return [&"combination_pending"]
	var result: Dictionary = _coordinator.prepare_selected_departure(departure_request(charge))
	var failures: Array[StringName] = []
	if not result.ok: failures.append(StringName(result.reason))
	return failures

func depart(charge: Dictionary) -> Dictionary:
	var failures := readiness(charge)
	if not failures.is_empty(): return _fail(failures[0])
	var request := departure_request(charge)
	var result: Dictionary = _coordinator.commit_selected_departure(request)
	if result.ok:
		_clear_departed()
	elif result.get("persisted", false):
		_pending_departure = request.duplicate(true)
		reload_required = true
	return result

func _clear_departed() -> void:
	_profile = {}
	spatial = null
	route = null
	_pending_departure = {}
	reload_required = false

func _fail(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
