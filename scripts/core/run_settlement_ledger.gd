# Run 안에서 서로 다른 학교 Boss의 소울 집계 자격을 중복 없이 기록한다.
extends RefCounted
class_name RunSettlementLedger

const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const SELECTED_ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")

var _eligible_school_boss_ids: Array[StringName] = []

func unlock_selected_support(store, revision: int) -> Dictionary:
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok: return loaded
	var profile: Dictionary = loaded.profile
	if profile.meta.unlocked_support_choice: return {"ok": true, "already_applied": true, "profile": profile}
	if profile.revision != revision: return {"ok": false, "reason": &"stale_revision"}
	if profile.meta.soul_balance < SELECTED_ITEMS.SUPPORT_UNLOCK_COST: return {"ok": false, "reason": &"insufficient_souls"}
	var candidate: Dictionary = profile.duplicate(true)
	candidate.meta.soul_balance -= SELECTED_ITEMS.SUPPORT_UNLOCK_COST
	candidate.meta.unlocked_support_choice = true
	return _selected_write_readback(store, candidate, revision, "unlock:support-choice-v1")

# Selected-profile lifecycle uses the existing single-file store. Main supplies a
# confirmed start bundle; no disk transaction takes place during selection.
func start_selected_run(store, bundle: Dictionary, first_school: StringName, run_id: String,
		expected_revision: int, maximum_health: int) -> Dictionary:
	var codec = load("res://scripts/core/run_resume_codec.gd").new()
	if not codec._profile_unique_ids([run_id]) or maximum_health <= 0 or maximum_health > 1000000 \
		or expected_revision < 0 or not SCHOOL_IDS.has(first_school): return {"ok": false, "reason": &"invalid_start"}
	var coordinator = load("res://scripts/core/rest_commit_coordinator.gd")
	if not coordinator.validate_selected_build_bundle(bundle): return {"ok": false, "reason": &"invalid_start_bundle"}
	# Only the approved initial ownership, not a caller-invented late-run inventory.
	var gear = load("res://scripts/core/equipment_loadout_state.gd").new()
	var initial_bag: Dictionary = coordinator.SELECTED_BACKPACK.new().create_selectable_starting_state().to_persistent_snapshot()
	if bundle.equipment != gear.get_snapshot() or bundle.loadout.active_spell_ids.size() != 2 \
		or bundle.loadout.draft_picks.size() != 2 or not bundle.access.trace_decisions.is_empty() \
		or not bundle.access.stabilized_school_ids.is_empty() or bundle.backpack.bags != initial_bag.bags \
		or bundle.backpack.items.size() not in [2, 3]: return {"ok": false, "reason": &"invalid_start_ownership"}
	var support_count := 0
	for item in bundle.backpack.items:
		if str(item.definition_id).begins_with("start_support:"):
			if not SELECTED_ITEMS.START_SUPPORT_IDS.has(StringName(str(item.definition_id).trim_prefix("start_support:"))): return {"ok": false, "reason": &"invalid_start_ownership"}
			support_count += 1
		elif not str(item.definition_id).begins_with("start_book:"): return {"ok": false, "reason": &"invalid_start_ownership"}
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok and loaded.get("reason") != &"missing": return loaded
	var profile: Dictionary = loaded.profile if loaded.ok else {
		"schema_version": 2, "revision": 0, "content_contract": codec.PROFILE_CONTRACT,
		"meta": {"soul_balance": 0, "unlocked_support_choice": false, "settled_run_ids": [],
			"applied_transaction_ids": [], "transaction_receipts": {}}, "active_run": null}
	if profile.active_run is Dictionary and profile.active_run.run_id == run_id:
		return {"ok": true, "already_applied": true, "profile": profile}
	if profile.revision != expected_revision: return {"ok": false, "reason": &"stale_revision"}
	if support_count != (1 if profile.meta.unlocked_support_choice else 0): return {"ok": false, "reason": &"invalid_start_support"}
	if profile.meta.settled_run_ids.has(run_id): return {"ok": false, "reason": &"run_id_reused"}
	var transaction_id := "start:" + run_id
	var candidate: Dictionary = profile.duplicate(true)
	if profile.active_run is Dictionary:
		transaction_id = "settle:" + str(profile.active_run.run_id)
		candidate.meta.soul_balance += _selected_reward(profile.active_run, false)
		candidate.meta.settled_run_ids.append(profile.active_run.run_id)
	var route = load("res://scripts/core/run_route_state.gd").new()
	route.set_provisional_next_school(first_school)
	route.commit_provisional_next_school()
	var bag = coordinator.SELECTED_BACKPACK.from_persistent_snapshot(bundle.backpack)
	var modifiers = coordinator.BAG_RESOLVER.new().resolve(bag, coordinator.SELECTED_CATALOG.build_items(),
		coordinator.BAG_CATALOG.build_bags(), StringName(bundle.loadout.origin_school_id)).modifiers
	var origin: String = str(bundle.loadout.origin_school_id)
	var initial_health := maxi(roundi((maximum_health + modifiers.max_health_flat) * maxf(1.0 + modifiers.max_health_pct, 0.0)), 1)
	var checkpoint := {"rules_version": codec.PROFILE_CONTRACT, "prepare_session_id": "departure:initial:" + run_id,
		"build": {"gold": 0, "selected_school_id": origin, "owned_items": {}, "selected_fates": [],
			"economy_receipts": [], "equipment": bundle.equipment, "committed_backpack_modifiers": modifiers.to_persistent_snapshot()},
		"route": route.get_route_snapshot(), "circuit": {"phase": "core", "active_school_id": str(first_school)},
		"backpack": bundle.backpack, "buffer": [], "loadout": bundle.loadout, "access": bundle.access,
		"ultimate_charge": {"school_id": origin, "resource_amount": 0},
		"vitals": {"health": initial_health, "max_health": initial_health, "emergency_potions": 0}}
	candidate.active_run = {"run_id": run_id, "starting_school": origin, "elite_qualified": false,
		"retry_consumed": false, "eligible_boss_ids": [], "checkpoint": checkpoint, "preparation": null}
	candidate = JSON.parse_string(JSON.stringify(candidate))
	return _selected_write_readback(store, candidate, expected_revision, transaction_id)

func _selected_reward(run: Dictionary, victory: bool) -> int:
	var bosses: int = run.eligible_boss_ids.size()
	return bosses + (2 if victory else 0) if bosses > 0 else (1 if run.elite_qualified else 0)

func settle_selected_run(store, run_id: String, revision: int, victory: bool, elite_qualified: bool) -> Dictionary:
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok: return loaded
	var profile: Dictionary = loaded.profile
	if profile.meta.settled_run_ids.has(run_id): return {"ok": true, "already_applied": true, "profile": profile}
	if profile.revision != revision: return {"ok": false, "reason": &"stale_revision"}
	if not (profile.active_run is Dictionary) or profile.active_run.run_id != run_id: return {"ok": false, "reason": &"wrong_run"}
	if victory and (profile.active_run.checkpoint.circuit.phase != "final_boss" or profile.active_run.eligible_boss_ids.size() != 4):
		return {"ok": false, "reason": &"final_gate_pending"}
	var candidate: Dictionary = profile.duplicate(true)
	candidate.active_run.elite_qualified = candidate.active_run.elite_qualified or elite_qualified
	var reward := _selected_reward(candidate.active_run, victory)
	candidate.meta.soul_balance += reward
	candidate.meta.settled_run_ids.append(run_id)
	candidate.active_run = null
	var result := _selected_write_readback(store, candidate, revision, "settle:" + run_id)
	if result.ok: result["reward"] = reward
	return result

func retry_selected_run(store, run_id: String, revision: int, elite_qualified: bool) -> Dictionary:
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok: return loaded
	var profile: Dictionary = loaded.profile
	if not (profile.active_run is Dictionary) or profile.active_run.run_id != run_id: return {"ok": false, "reason": &"wrong_run"}
	if profile.meta.transaction_receipts.has("retry:" + run_id): return {"ok": true, "already_applied": true, "profile": profile}
	if profile.revision != revision: return {"ok": false, "reason": &"stale_revision"}
	if profile.active_run.retry_consumed or profile.meta.soul_balance < 1: return {"ok": false, "reason": &"retry_unavailable"}
	var candidate: Dictionary = profile.duplicate(true)
	candidate.meta.soul_balance -= 1
	candidate.active_run.retry_consumed = true
	candidate.active_run.elite_qualified = candidate.active_run.elite_qualified or elite_qualified
	candidate.active_run.preparation = null
	return _selected_write_readback(store, candidate, revision, "retry:" + run_id)

func _selected_write_readback(store, candidate: Dictionary, revision: int, transaction_id: String) -> Dictionary:
	var result: Dictionary = store.transact_profile(candidate, revision, transaction_id)
	if not result.ok: return result
	var readback: Dictionary = store.load_profile()
	if not readback.ok or readback.profile.revision != result.revision \
		or not readback.profile.meta.transaction_receipts.has(transaction_id):
		return {"ok": false, "reason": &"committed_reload_required", "persisted": true}
	return {"ok": true, "already_applied": result.already_applied, "profile": readback.profile}


func record_school_boss(school_id: StringName) -> bool:
	if not SCHOOL_IDS.has(school_id) or _eligible_school_boss_ids.has(school_id):
		return false
	_eligible_school_boss_ids.append(school_id)
	return true


func eligible_school_boss_ids() -> Array[StringName]:
	return _eligible_school_boss_ids.duplicate()


func get_snapshot() -> Dictionary:
	return {"eligible_school_boss_ids": eligible_school_boss_ids()}


func can_restore_from_snapshot(snapshot: Dictionary) -> bool:
	var restored: Array[StringName] = []
	for raw_school_id in Array(snapshot.get("eligible_school_boss_ids", [])):
		var school_id := StringName(raw_school_id)
		if not SCHOOL_IDS.has(school_id) or restored.has(school_id):
			return false
		restored.append(school_id)
	return true


func restore_from_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_from_snapshot(snapshot):
		return false
	var restored: Array[StringName] = []
	for raw_school_id in Array(snapshot.get("eligible_school_boss_ids", [])):
		var school_id := StringName(raw_school_id)
		restored.append(school_id)
	_eligible_school_boss_ids = restored
	return true
