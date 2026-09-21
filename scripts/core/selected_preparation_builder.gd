# Captures the stopped battlefield once. No file writes or live node mutations.
extends RefCounted

const ACCESS = preload("res://scripts/core/tradition_access_state.gd")
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const SESSION = preload("res://scripts/backpack/rest_backpack_session.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")
const BAGS = preload("res://scripts/data/mvp4_catalog.gd")
const FATES = preload("res://scripts/data/mvp3_catalog.gd")
const BUILD = preload("res://scripts/core/run_build_state.gd")
const FATE = preload("res://scripts/core/fate_controller.gd")
const REWARDS = preload("res://scripts/core/rest_reward_controller.gd")
const MODIFIERS = preload("res://scripts/data/run_modifier_set.gd")

func prepare(request: Dictionary, store) -> Dictionary:
	if request.size() != 9 + int(request.has("ultimate_charge")) + int(request.has("battle_progress")): return _fail(&"invalid_entry")
	for field in ["run_id", "departure_id", "school_id"]:
		if not (request.get(field) is String or request.get(field) is StringName) \
			or str(request[field]).is_empty() or str(request[field]).length() > 256: return _fail(&"invalid_entry")
	for field in ["expected_revision", "gold", "health", "maximum_health", "emergency_potions"]:
		var value = request.get(field)
		if not (value is int or value is float) or not is_finite(float(value)) \
			or value < 0 or value >= 9007199254740991 or floor(float(value)) != float(value): return _fail(&"invalid_entry")
	if request.health <= 0 or request.health > request.maximum_health: return _fail(&"invalid_entry")
	var encounter = request.get("encounter")
	if not (encounter is Dictionary) or encounter.get("state") != &"cleared": return _fail(&"encounter_not_cleared")
	for gate in ["elite_cleared", "trace_recovered", "boss_requested"]:
		if encounter.get(gate) != true: return _fail(&"encounter_not_cleared")
	var identity := JSON.stringify(["entry-v1", str(request.run_id), str(request.departure_id), str(request.school_id)])
	var transaction_id := "enter:" + identity.sha256_text()
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok: return loaded
	var profile: Dictionary = loaded.profile
	if profile.meta.transaction_receipts.has(transaction_id):
		return {"ok": true, "already_applied": true, "profile": profile, "transaction_id": transaction_id}
	if profile.revision != request.expected_revision: return _fail(&"stale_revision")
	var run = profile.active_run
	if not (run is Dictionary) or run.run_id != str(request.run_id): return _fail(&"wrong_run")
	var cp: Dictionary = run.checkpoint.duplicate(true)
	if request.has("battle_progress"):
		if not load("res://scripts/core/run_experience_state.gd").valid_battle_progress(cp, request.battle_progress):
			return _fail(&"invalid_battle_progress")
		var normalized: Dictionary = JSON.parse_string(JSON.stringify(request.battle_progress))
		cp.growth = normalized.growth
		cp.backpack = normalized.backpack
		cp.loadout = normalized.loadout
	var charge = request.get("ultimate_charge", cp.ultimate_charge)
	if not load("res://scripts/core/run_resume_codec.gd").valid_selected_charge(charge, str(run.starting_school)):
		return _fail(&"invalid_ultimate_charge")
	if run.preparation != null or cp.prepare_session_id != str(request.departure_id) \
		or cp.route.active_school_id != str(request.school_id) or cp.circuit.phase != "core": return _fail(&"wrong_departure")
	if int(request.gold) < int(cp.build.gold): return _fail(&"invalid_battle_gold")
	if int(request.emergency_potions) > int(cp.get("vitals", {}).get("emergency_potions", 0)):
		return _fail(&"unowned_consumable")
	var access = ACCESS.new()
	if not access.restore_selected_snapshot(cp.access) or not access.stabilize_school(StringName(request.school_id)):
		return _fail(&"invalid_access")
	var session = SESSION.new()
	var carried: Array = []
	var instance_script = load("res://scripts/data/item_instance.gd")
	for raw in cp.buffer:
		var item = instance_script.new()
		item.instance_id = int(raw.instance_id)
		item.definition_id = StringName(raw.definition_id)
		item.rotation_quarters = int(raw.rotation_quarters)
		carried.append(item)
	if not session.begin(BAG.from_persistent_snapshot(cp.backpack), RESOLVER.new(), ITEMS.build_items(),
		BAGS.build_bags(), StringName(run.starting_school), carried, true): return _fail(&"invalid_backpack")
	var build = BUILD.new()
	build.configure(ITEMS.build_items(), FATES.build_fates())
	var build_snapshot: Dictionary = cp.build.duplicate(true)
	build_snapshot.committed_backpack_modifiers = MODIFIERS.from_persistent_snapshot(cp.build.committed_backpack_modifiers)
	if not build.restore_from_checkpoint(build_snapshot):
		build.free()
		return _fail(&"invalid_build")
	build.gold = int(request.gold)
	var rng := RandomNumberGenerator.new()
	rng.seed = identity.sha256_text().substr(0, 15).hex_to_int()
	var rewards = REWARDS.new()
	rewards.configure(build, session, ITEMS.build_items(), BAGS.build_bags(), rng, access)
	rewards.begin_rest(int(cp.route.stage_index), StringName(run.starting_school), 1, StringName(request.school_id))
	var fate = FATE.new()
	fate.configure(build, FATES.build_fates(), rng)
	fate.begin_rest()
	var modifiers = build.get_modifiers()
	var healing := maxi(roundi(request.maximum_health * maxf(0.25 + modifiers.rest_start_heal_pct, 0.0) \
		* maxf(1.0 + modifiers.healing_pct, 0.0)), 0)
	var prep := {"prepare_session_id": "prepare:" + identity.sha256_text(), "phase": "preparing", "revision": 0,
		"access": access.get_snapshot(), "equipment": cp.build.equipment.duplicate(true),
		"spatial_session": session.persistent_preparation_snapshot(), "loadout": cp.loadout.duplicate(true),
		"gold": int(request.gold), "reward_state": rewards.persistent_snapshot(), "pending_fate": "",
		"provisional_school": "", "healing_applied": true, "fate_state": fate.persistent_preparation_snapshot(),
		"ultimate_charge": charge.duplicate(true),
		"vitals": {"health": mini(int(request.health) + healing, int(request.maximum_health)),
			"max_health": int(request.maximum_health), "emergency_potions": int(request.emergency_potions)}}
	fate.free()
	if cp.has("growth"): prep.growth = cp.growth.duplicate(true)
	rewards.free()
	build.free()
	var candidate: Dictionary = profile.duplicate(true)
	candidate.active_run.preparation = prep
	candidate.active_run.elite_qualified = true
	if not candidate.active_run.eligible_boss_ids.has(str(request.school_id)):
		candidate.active_run.eligible_boss_ids.append(str(request.school_id))
	var decoded: Dictionary = load("res://scripts/core/run_resume_codec.gd").new().decode_profile_v2(candidate)
	if not decoded.ok: return decoded
	return {"ok": true, "already_applied": false, "profile": decoded.profile, "transaction_id": transaction_id}

func _fail(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
