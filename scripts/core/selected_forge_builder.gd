# Detached campfire candidate, no live gear, money or filesystem mutation.
extends RefCounted

const GEAR = preload("res://scripts/core/equipment_loadout_state.gd")

func prepare(request: Dictionary, store) -> Dictionary:
	if request.size() != 6: return _fail(&"invalid_forge_request")
	var identity: Array = ["forge-v1"]
	for field in ["run_id", "prepare_session_id", "slot"]:
		var value = request.get(field)
		if not (value is String or value is StringName) or str(value).is_empty() or str(value).length() > 256:
			return _fail(&"invalid_forge_request")
		identity.append(str(value))
	if str(request.slot) not in GEAR.SLOTS: return _fail(&"invalid_slot")
	for field in ["expected_revision", "expected_prepare_revision", "expected_equipment_revision"]:
		var value = request.get(field)
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0 \
			or value >= 9007199254740991 or float(value) != floor(float(value)):
			return _fail(&"invalid_forge_request")
		identity.append(int(value))
	var digest := JSON.stringify(identity).sha256_text()
	var transaction_id := "forge:" + digest
	var loaded: Dictionary = store.load_profile()
	if not loaded.ok: return loaded
	var profile: Dictionary = loaded.profile
	if profile.meta.transaction_receipts.has(transaction_id):
		return {"ok": true, "already_applied": true, "profile": profile, "transaction_id": transaction_id}
	if profile.revision != request.expected_revision: return _fail(&"stale_revision")
	var run = profile.active_run
	if not (run is Dictionary) or run.run_id != str(request.run_id): return _fail(&"wrong_run")
	var prep = run.preparation
	if not (prep is Dictionary) or prep.prepare_session_id != str(request.prepare_session_id): return _fail(&"wrong_preparation")
	if prep.revision != request.expected_prepare_revision or prep.equipment.revision != request.expected_equipment_revision:
		return _fail(&"stale_preparation")
	var gear = GEAR.new()
	if not gear.restore_snapshot(prep.equipment): return _fail(&"invalid_equipment")
	var quote: Dictionary = gear.forge_quote(StringName(request.slot))
	if not quote.ok: return quote
	if prep.gold < quote.cost: return _fail(&"insufficient_gold")
	# Stable 32-bit fraction: retry survives process/engine RNG changes. The caller
	# cannot send roll/cost; a paid new revision, not a click counter, changes intent.
	var roll := float(digest.substr(0, 8).hex_to_int()) / 4294967296.0
	var outcome: Dictionary = gear.forge_equipped(StringName(request.slot), roll)
	if not outcome.ok: return outcome
	var candidate := profile.duplicate(true)
	candidate.active_run.preparation.gold = int(prep.gold) - int(outcome.cost)
	candidate.active_run.preparation.equipment = gear.get_snapshot()
	candidate.active_run.preparation.revision = int(prep.revision) + 1
	var decoded: Dictionary = load("res://scripts/core/run_resume_codec.gd").new().decode_profile_v2(candidate)
	if not decoded.ok: return decoded
	return {"ok": true, "already_applied": false, "profile": decoded.profile,
		"transaction_id": transaction_id, "outcome": outcome}

func _fail(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
