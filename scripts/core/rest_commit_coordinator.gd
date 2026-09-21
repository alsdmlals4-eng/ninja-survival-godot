# Workbench 백팩·Fate·다음 경로를 한 번에 확정하는 T12 도메인 조정자다.
extends RefCounted
class_name RestCommitCoordinator

const SELECTED_BACKPACK = preload("res://scripts/backpack/backpack_state.gd")
const SELECTED_CATALOG = preload("res://scripts/data/selected_backpack_catalog.gd")
const SELECTED_BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const SELECTED_ACCESS = preload("res://scripts/core/tradition_access_state.gd")
const SELECTED_EQUIPMENT = preload("res://scripts/core/equipment_loadout_state.gd")
const SELECTED_LOADOUT = preload("res://scripts/core/ninjutsu_loadout_state.gd")
const BAG_RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const BAG_CATALOG = preload("res://scripts/data/mvp4_catalog.gd")
const CARRIED_ITEM = preload("res://scripts/data/item_instance.gd")
const REST_BUFFER = preload("res://scripts/backpack/rest_backpack_session.gd")
const SELECTED_DEPARTURE = preload("res://scripts/core/selected_departure_builder.gd")
const SELECTED_FORGE = preload("res://scripts/core/selected_forge_builder.gd")
const SELECTED_ENTRY = preload("res://scripts/core/selected_preparation_builder.gd")
const SELECTED_PURCHASE = preload("res://scripts/core/selected_purchase_builder.gd")


# Pure cross-owner gate, not a disk transaction or a mutation of live owners.
static func validate_selected_build_bundle(bundle: Dictionary) -> bool:
	for key in ["backpack", "loadout", "equipment", "access"]:
		if not (bundle.get(key) is Dictionary):
			return false
	var contract = bundle.backpack.get("catalog_contract")
	if not (contract is String or contract is StringName) or str(contract) != SELECTED_BOOKS.CONTRACT:
		return false
	var bag = SELECTED_BACKPACK.from_persistent_snapshot(bundle.backpack)
	if bag == null or not bag.uses_selectable_books():
		return false
	var access = SELECTED_ACCESS.new()
	var equipment = SELECTED_EQUIPMENT.new()
	if not access.restore_selected_snapshot(bundle.access) or not equipment.restore_snapshot(bundle.equipment):
		return false
	# Old numeric receipts remain history. New powers require an exact trace binding.
	var powers: Dictionary = equipment.get_snapshot().imbuements
	for instance_id in powers:
		for school in powers[instance_id]:
			var receipt: Dictionary = bundle.access.trace_decisions.get(StringName(school), {})
			if receipt.get("choice") != "enhance" or receipt.get("imbuement") != school \
				or receipt.get("equipment_instance") != instance_id:
				return false
	var origin = bundle.loadout.get("origin_school_id")
	if not (origin is String or origin is StringName) or StringName(origin) != access.starting_school_id():
		return false
	var resolution = BAG_RESOLVER.new().resolve(bag, SELECTED_CATALOG.build_items(), BAG_CATALOG.build_bags(), access.starting_school_id())
	if not resolution.valid:
		return false
	if not (bundle.loadout.get("draft_picks") is Array):
		return false
	var placed: Array = []
	for item in bag.items.values():
		var spell := SELECTED_BOOKS.spell_id(item.definition_id)
		if spell != &"":
			if not _selected_book_owned(item.definition_id, access.unlocked_ninjutsu_school_ids(), bundle.loadout.draft_picks):
				return false
			placed.append(spell)
	if not _validate_selected_buffer(bundle.get("buffer", []), bag, placed, access.unlocked_ninjutsu_school_ids(), bundle.loadout.draft_picks):
		return false
	var loadout = SELECTED_LOADOUT.new()
	var valid: bool = loadout.can_restore_selected_snapshot(bundle.loadout, placed, access.unlocked_ninjutsu_school_ids())
	loadout.free()
	return valid


static func _selected_book_owned(definition_id: StringName, unlocked: Array, draft_picks: Array) -> bool:
	var spell := SELECTED_BOOKS.spell_id(definition_id)
	var definition = SELECTED_BOOKS.NINJUTSU.definition_for_id(spell)
	if definition == null or not unlocked.has(definition.school_id):
		return false
	return not str(definition_id).begins_with("start_book:") or draft_picks.has(spell)


static func _validate_selected_buffer(raw_buffer, bag, placed: Array, unlocked: Array, draft_picks: Array) -> bool:
	if not (raw_buffer is Array) or raw_buffer.size() > REST_BUFFER.BUFFER_CAPACITY:
		return false
	var carried: Array = []
	var owned_spells: Array = placed.duplicate()
	for raw in raw_buffer:
		if not (raw is Dictionary) or raw.size() != 3 or not (raw.get("definition_id") is String or raw.get("definition_id") is StringName):
			return false
		for field in ["instance_id", "rotation_quarters"]:
			var value = raw.get(field)
			if not (value is int or value is float) or not is_finite(float(value)) or value < 0 or value > 9007199254740991 or float(value) != floor(float(value)):
				return false
		var item = CARRIED_ITEM.new()
		item.instance_id = int(raw.instance_id)
		item.definition_id = StringName(raw.definition_id)
		item.rotation_quarters = int(raw.rotation_quarters)
		var spell := SELECTED_BOOKS.spell_id(item.definition_id)
		if spell != &"":
			if owned_spells.has(spell) or not _selected_book_owned(item.definition_id, unlocked, draft_picks):
				return false
			owned_spells.append(spell)
		carried.append(item)
	return REST_BUFFER.is_valid_carried_buffer(carried, bag, SELECTED_CATALOG.build_items())

var _committed_backpack_state = null
var _source_backpack_state = null
var _build_state: RunBuildState
var _route_state: RunRouteState
var _fate_controller: FateController
var _ninjutsu_loadout = null
var _session: RestBackpackSession
var _session_generation: int = -1
var _configured: bool = false
var _committed_this_rest: bool = false
var _commit_in_progress: bool = false
var _final_preparation: bool = false
var _selected_profile_store = null


# Selected-mode business commands use the existing profile store. They return
# detached persisted values; Main adopts them only after success (R03).
# Never bind this mode to the legacy in-memory commit path.
func configure_selected_profile(store) -> bool:
	if _configured or _selected_profile_store != null or _commit_in_progress or store == null:
		return false
	if not store.has_method("load_profile") or not store.has_method("transact_profile"):
		return false
	_selected_profile_store = store
	return true


func prepare_selected_trace(request: Dictionary) -> Dictionary:
	if _selected_profile_store == null or _commit_in_progress:
		return {"ok": false, "reason": &"not_ready"}
	return _prepare_selected_trace_request(request)


func commit_selected_forge(request: Dictionary) -> Dictionary:
	return _commit_selected_candidate(request, SELECTED_FORGE)


func commit_selected_entry(request: Dictionary) -> Dictionary:
	return _commit_selected_candidate(request, SELECTED_ENTRY)


func commit_selected_purchase(request: Dictionary) -> Dictionary:
	return _commit_selected_candidate(request, SELECTED_PURCHASE)


func _commit_selected_candidate(request: Dictionary, builder: Script) -> Dictionary:
	if _selected_profile_store == null or _commit_in_progress:
		return {"ok": false, "reason": &"not_ready"}
	_commit_in_progress = true
	var prepared: Dictionary = builder.new().prepare(request, _selected_profile_store)
	var result := prepared
	if prepared.ok and not prepared.get("already_applied", false):
		result = _selected_profile_store.transact_profile(prepared.profile,
			int(request.expected_revision), prepared.transaction_id)
		if result.ok:
			var readback: Dictionary = _selected_profile_store.load_profile()
			if not readback.ok or readback.profile.revision != result.revision \
				or not readback.profile.meta.transaction_receipts.has(prepared.transaction_id):
				result = {"ok": false, "reason": &"committed_reload_required", "persisted": true}
			else:
				result = {"ok": true, "already_applied": result.already_applied,
					"profile": readback.profile, "transaction_id": prepared.transaction_id,
					"outcome": prepared.get("outcome", {}), "warning": result.get("warning", &"")}
	_commit_in_progress = false
	return result


func prepare_selected_departure(request: Dictionary) -> Dictionary:
	if _selected_profile_store == null or _commit_in_progress:
		return {"ok": false, "reason": &"not_ready"}
	return SELECTED_DEPARTURE.new().prepare(request, _selected_profile_store)


func commit_selected_departure(request: Dictionary) -> Dictionary:
	if _selected_profile_store == null or _commit_in_progress:
		return {"ok": false, "reason": &"not_ready"}
	_commit_in_progress = true
	var prepared: Dictionary = SELECTED_DEPARTURE.new().prepare(request, _selected_profile_store)
	var result := prepared
	if prepared.ok and not prepared.get("already_applied", false):
		result = _selected_profile_store.transact_profile(prepared.profile,
			int(request.expected_revision), prepared.transaction_id)
		if result.ok:
			var readback: Dictionary = _selected_profile_store.load_profile()
			if not readback.ok or readback.profile.revision != result.revision \
				or not readback.profile.meta.transaction_receipts.has(prepared.transaction_id):
				result = {"ok": false, "reason": &"committed_reload_required", "persisted": true}
			else:
				result = {"ok": true, "already_applied": result.already_applied,
					"profile": readback.profile, "transaction_id": prepared.transaction_id,
					"warning": result.get("warning", &"")}
	_commit_in_progress = false
	return result


func commit_selected_trace(request: Dictionary) -> Dictionary:
	if _selected_profile_store == null or _commit_in_progress:
		return {"ok": false, "reason": &"not_ready"}
	_commit_in_progress = true
	var prepared := _prepare_selected_trace_request(request)
	var result := prepared
	if prepared.ok and not prepared.get("already_applied", false):
		result = _selected_profile_store.transact_profile(prepared.profile,
			int(request.expected_revision), prepared.transaction_id)
		if result.ok:
			var readback: Dictionary = _selected_profile_store.load_profile()
			if not readback.ok or readback.profile.revision != result.revision \
				or not readback.profile.meta.transaction_receipts.has(prepared.transaction_id):
				result = {"ok": false, "reason": &"committed_reload_required", "persisted": true}
			else:
				result = {"ok": true, "already_applied": result.already_applied,
					"profile": readback.profile, "transaction_id": prepared.transaction_id,
					"warning": result.get("warning", &"")}
	_commit_in_progress = false
	return result


func _prepare_selected_trace_request(request: Dictionary) -> Dictionary:
	# Callers send intent + observed revisions, never a replacement profile. Clone
	# only the validated durable preparation so preview state cannot mint ownership.
	if request.size() != 8:
		return {"ok": false, "reason": &"invalid_trace_request"}
	var identity: Array = ["trace-v1"]
	for field in ["run_id", "prepare_session_id", "school_id", "choice", "slot"]:
		var value = request.get(field)
		if not (value is String or value is StringName) or str(value).length() > 256:
			return {"ok": false, "reason": &"invalid_trace_request"}
		identity.append(str(value))
	if request.run_id == "" or request.prepare_session_id == "" \
		or StringName(request.school_id) not in SELECTED_ACCESS.SCHOOL_IDS \
		or StringName(request.choice) not in [&"absorb", &"enhance"]:
		return {"ok": false, "reason": &"invalid_trace_request"}
	for field in ["expected_revision", "expected_prepare_revision", "expected_equipment_revision"]:
		var value = request.get(field)
		if not (value is int or value is float) or not is_finite(float(value)) \
			or value < 0 or value >= 9007199254740991 or float(value) != floor(float(value)):
			return {"ok": false, "reason": &"invalid_trace_request"}
		identity.append(int(value))
	var transaction_id := "trace:" + JSON.stringify(identity).sha256_text()
	var loaded: Dictionary = _selected_profile_store.load_profile()
	if not loaded.ok:
		return loaded
	var profile: Dictionary = loaded.profile
	# Exact intent/revisions produce the same receipt after reopen, even if a later
	# transaction advanced the profile. Return current state, never replay old data.
	if profile.meta.transaction_receipts.has(transaction_id):
		return {"ok": true, "already_applied": true, "profile": profile,
			"transaction_id": transaction_id}
	if profile.revision != request.expected_revision:
		return {"ok": false, "reason": &"stale_revision"}
	var run = profile.active_run
	if not (run is Dictionary) or run.run_id != str(request.run_id):
		return {"ok": false, "reason": &"wrong_run"}
	var preparation = run.preparation
	if not (preparation is Dictionary) or preparation.prepare_session_id != str(request.prepare_session_id):
		return {"ok": false, "reason": &"wrong_preparation"}
	if preparation.revision != request.expected_prepare_revision \
		or preparation.equipment.revision != request.expected_equipment_revision:
		return {"ok": false, "reason": &"stale_preparation"}
	if run.checkpoint.route.active_school_id != str(request.school_id):
		return {"ok": false, "reason": &"wrong_trace"}
	var access = SELECTED_ACCESS.new()
	var equipment = SELECTED_EQUIPMENT.new()
	if not access.restore_selected_snapshot(preparation.access) or not equipment.restore_snapshot(preparation.equipment):
		return {"ok": false, "reason": &"invalid_preparation"}
	if not access.decide_trace(StringName(request.school_id), StringName(request.choice), equipment,
		StringName(request.slot), int(request.expected_equipment_revision)):
		return {"ok": false, "reason": &"trace_choice_rejected"}
	var candidate: Dictionary = profile.duplicate(true)
	candidate.active_run.preparation.access = access.get_snapshot()
	candidate.active_run.preparation.equipment = equipment.get_snapshot()
	candidate.active_run.preparation.revision = int(preparation.revision) + 1
	# Runtime load avoids a preload cycle: the codec already uses this owner's
	# pure bundle validation. The store remains the only disk writer.
	var decoded: Dictionary = load("res://scripts/core/run_resume_codec.gd").new().decode_profile_v2(candidate)
	if not decoded.ok:
		return decoded
	return {"ok": true, "already_applied": false, "profile": decoded.profile,
		"transaction_id": transaction_id}


func configure(
	committed_backpack_state,
	build_state: RunBuildState,
	route_state: RunRouteState,
	fate_controller: FateController,
	ninjutsu_loadout = null,
	final_preparation: bool = false
) -> bool:
	if _selected_profile_store != null or _session != null or _commit_in_progress or _committed_this_rest:
		return false
	if committed_backpack_state == null or build_state == null or route_state == null or fate_controller == null:
		return false
	if ninjutsu_loadout != null and (
		not ninjutsu_loadout.has_method("can_commit_pending")
		or not ninjutsu_loadout.has_method("commit_pending")
	):
		return false
	_source_backpack_state = committed_backpack_state
	_committed_backpack_state = committed_backpack_state.copy_value()
	_build_state = build_state
	_route_state = route_state
	_fate_controller = fate_controller
	_ninjutsu_loadout = ninjutsu_loadout
	_final_preparation = final_preparation
	_configured = true
	_committed_this_rest = false
	_session_generation = -1
	return true


func begin_rest(session: RestBackpackSession) -> bool:
	if not _configured or _committed_this_rest or _commit_in_progress or _session != null or session == null:
		return false
	if not _fate_controller._is_bound_to_build_state(_build_state):
		return false
	if not session._is_bound_to_committed_state(_source_backpack_state):
		return false
	_session = session
	_session_generation = session._transaction_generation()
	return true


func committed_backpack_state():
	if _committed_backpack_state == null:
		return null
	return _committed_backpack_state.copy_value()


func commit_failures(
	chest_count: int = 0,
	boss_reward_pending: bool = false,
	combination_pending: bool = false
) -> Array[StringName]:
	var failures: Array[StringName] = []
	if _committed_this_rest:
		failures.append(&"already_committed")
	if _commit_in_progress:
		failures.append(&"commit_in_progress")
	if _session == null:
		failures.append(&"missing_session")
		return failures
	if not _session._is_bound_to_committed_state(_source_backpack_state) \
		or _session._transaction_generation() != _session_generation:
		failures.append(&"session_rebound")

	failures.append_array(_session.commit_failures(chest_count, boss_reward_pending, combination_pending))
	if _fate_controller == null \
		or not _fate_controller._is_bound_to_build_state(_build_state) \
		or not _fate_controller._can_commit_pending():
		failures.append(&"fate_pending")
	if not _route_ready():
		failures.append(&"route_pending")
	if _ninjutsu_loadout != null and not bool(_ninjutsu_loadout.call("can_commit_pending")):
		failures.append(&"ninjutsu_pending_invalid")
	return failures


func commit(
	chest_count: int = 0,
	boss_reward_pending: bool = false,
	combination_pending: bool = false
) -> bool:
	if not commit_failures(chest_count, boss_reward_pending, combination_pending).is_empty():
		return false
	var candidate_state = _session.state
	var resolution = _session.current_resolution()
	if candidate_state == null or resolution == null or not bool(resolution.valid):
		return false

	# 사전검증 뒤 세 확정 호출은 외부 시그널 이전의 실패 불가능한 상태 전이이다.
	_commit_in_progress = true
	_committed_backpack_state = candidate_state.copy_value()
	_build_state.set_committed_backpack_modifiers(resolution.modifiers)
	if not _final_preparation and not _route_state.commit_provisional_next_school():
		_commit_in_progress = false
		return false
	if not _fate_controller._commit_pending():
		_commit_in_progress = false
		return false
	if _ninjutsu_loadout != null and not bool(_ninjutsu_loadout.call("commit_pending")):
		_commit_in_progress = false
		return false
	_committed_this_rest = true
	_session = null
	_session_generation = -1
	_commit_in_progress = false
	return true


func _route_ready() -> bool:
	if _route_state == null or _route_state.cleared_school_ids().is_empty():
		return false
	if _final_preparation:
		return _route_state.is_final_binding_eligible() \
			and _route_state.active_school_id() == &"" \
			and _route_state.provisional_school_id() == &""
	return not _route_state.is_final_binding_eligible() \
		and _route_state.can_commit_provisional_next_school()
