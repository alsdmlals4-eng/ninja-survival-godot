# Stopped-camp purchases compose existing inventory/economy owners before I/O.
extends RefCounted

const GEAR = preload("res://scripts/core/equipment_loadout_state.gd")
const ACCESS = preload("res://scripts/core/tradition_access_state.gd")
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const SESSION = preload("res://scripts/backpack/rest_backpack_session.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")
const BAGS = preload("res://scripts/data/mvp4_catalog.gd")
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")
const BUILD = preload("res://scripts/core/run_build_state.gd")
const FATES = preload("res://scripts/data/mvp3_catalog.gd")
const MODIFIERS = preload("res://scripts/data/run_modifier_set.gd")
const REWARDS = preload("res://scripts/core/rest_reward_controller.gd")
const LAYOUT = preload("res://scripts/core/selected_layout_contract.gd")

func prepare(request: Dictionary, store) -> Dictionary:
	if request.size() != 6 + int(request.has("spatial_session")) or not LAYOUT.primitive(request): return _fail(&"invalid_purchase")
	var identity: Array = ["purchase-v1"]
	for field in ["run_id", "prepare_session_id", "kind", "offer_id"]:
		var value = request.get(field)
		if not (value is String or value is StringName) or str(value).length() > 256: return _fail(&"invalid_purchase")
		identity.append(str(value))
	if request.run_id == "" or request.prepare_session_id == "" \
		or str(request.kind) not in ["shop_item", "bag", "book", "equipment", "potion", "emergency", "boss_reward", "chest", "sell_item", "reroll"]: return _fail(&"invalid_purchase")
	for field in ["expected_revision", "expected_prepare_revision"]:
		var value = request.get(field)
		if not (value is int or value is float) or not is_finite(float(value)) or value < 0 \
			or value >= 9007199254740991 or float(value) != floor(float(value)): return _fail(&"invalid_purchase")
		identity.append(int(value))
	if request.has("spatial_session"):
		if not (request.spatial_session is Dictionary): return _fail(&"invalid_layout")
		identity.append(JSON.parse_string(JSON.stringify(request.spatial_session, "", true, true)))
	var transaction_id := "buy:" + JSON.stringify(identity).sha256_text()
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
	if prep.revision != request.expected_prepare_revision: return _fail(&"stale_preparation")
	var candidate: Dictionary = profile.duplicate(true)
	var updated: Dictionary = candidate.active_run.preparation
	var access = ACCESS.new()
	access.restore_selected_snapshot(prep.access)
	var gear = GEAR.new()
	gear.restore_snapshot(prep.equipment)
	var session = SESSION.new()
	session.begin(BAG.from_persistent_snapshot(prep.spatial_session.backpack), RESOLVER.new(),
		ITEMS.build_items(), BAGS.build_bags(), StringName(run.starting_school))
	if not session.restore_preparation_snapshot(prep.spatial_session): return _fail(&"invalid_preparation")
	if request.has("spatial_session"):
		if not LAYOUT.same_owned_inventory(prep.spatial_session, request.spatial_session) \
			or not session.restore_preparation_snapshot(request.spatial_session): return _fail(&"invalid_layout")
	var build = BUILD.new()
	build.configure(ITEMS.build_items(), FATES.build_fates())
	var build_snapshot: Dictionary = run.checkpoint.build.duplicate(true)
	build_snapshot.gold = int(prep.gold)
	build_snapshot.equipment = prep.equipment
	build_snapshot.committed_backpack_modifiers = MODIFIERS.from_persistent_snapshot(run.checkpoint.build.committed_backpack_modifiers)
	if not build.restore_from_checkpoint(build_snapshot):
		build.free()
		return _fail(&"invalid_build")
	var rewards = REWARDS.new()
	rewards.configure(build, session, ITEMS.build_items(), BAGS.build_bags(), RandomNumberGenerator.new(), access)
	var outcome := _fail(&"invalid_rewards")
	if rewards.restore_persistent_snapshot(prep.reward_state):
		outcome = _purchase(str(request.kind), str(request.offer_id), updated, build, gear, session, rewards, access)
	if outcome.ok:
		updated.gold = build.gold
		updated.equipment = gear.get_snapshot()
		updated.spatial_session = session.persistent_preparation_snapshot()
		# Saved preparation reflects its owned draft; live combat still reads checkpoint.
		var active: Array = []
		for item in updated.spatial_session.backpack.items:
			var spell := BOOKS.spell_id(StringName(item.definition_id))
			if spell != &"": active.append(str(spell))
		updated.loadout.active_spell_ids = active
		updated.loadout.pending_spell_ids = []
		updated.reward_state = rewards.persistent_snapshot()
		updated.revision = int(prep.revision) + 1
	rewards.free()
	build.free()
	if not outcome.ok: return outcome
	var decoded: Dictionary = load("res://scripts/core/run_resume_codec.gd").new().decode_profile_v2(candidate)
	if not decoded.ok: return decoded
	return {"ok": true, "already_applied": false, "profile": decoded.profile,
		"transaction_id": transaction_id, "outcome": outcome}

func _purchase(kind: String, id: String, prep: Dictionary, build, gear, session, rewards, access) -> Dictionary:
	match kind:
		"boss_reward":
			var index: int = rewards.boss_reward_options().find(StringName(id))
			return {"ok": true} if index >= 0 and rewards.choose_boss_reward(index) else _fail(&"boss_reward_unavailable")
		"chest":
			return {"ok": true} if id == "" and rewards.open_chest() else _fail(&"chest_unavailable")
		"sell_item":
			return {"ok": true} if id.is_valid_int() and str(id.to_int()) == id and id.to_int() > 0 \
				and rewards.sell_item(id.to_int()) else _fail(&"sale_unavailable")
		"reroll":
			return {"ok": true} if id == "" and rewards.reroll_shop() else _fail(&"reroll_unavailable")
		"shop_item":
			var index: int = rewards.shop_item_options().find(StringName(id))
			return {"ok": true} if index >= 0 and rewards.buy_shop_item(index) else _fail(&"item_unavailable")
		"bag":
			return {"ok": true} if String(rewards.shop_bag_option()) == id and rewards.buy_shop_bag() else _fail(&"bag_unavailable")
		"equipment":
			var definition: Dictionary = GEAR.CATALOG.definition(StringName(id))
			if definition.is_empty() or gear.get_snapshot().owned_instances.has("gear_" + id): return _fail(&"equipment_unavailable")
			if build.gold < int(definition.price): return _fail(&"insufficient_gold")
			if not gear.acquire(StringName(id)): return _fail(&"equipment_unavailable")
			build.try_spend_gold(int(definition.price))
		"book":
			var definition = BOOKS.NINJUTSU.definition_for_id(StringName(id))
			if definition == null or not access.unlocked_ninjutsu_school_ids().has(definition.school_id): return _fail(&"book_locked")
			var spatial: Dictionary = session.persistent_preparation_snapshot()
			for item in spatial.backpack.items + spatial.buffer:
				if BOOKS.spell_id(StringName(item.definition_id)) == StringName(id): return _fail(&"book_owned")
			var book := BOOKS.book_id(StringName(id))
			var price: int = BOOKS.build_items()[book].base_price
			if build.gold < price: return _fail(&"insufficient_gold")
			if session._acquire_items_to_buffer([book]).size() != 1: return _fail(&"buffer_capacity")
			build.try_spend_gold(price)
		"potion", "emergency":
			if id != "" or not prep.has("vitals"): return _fail(&"vitals_unavailable")
			var data: Dictionary = GEAR.GROWTH.CONSUMABLES[kind]
			if build.gold < data.cost: return _fail(&"insufficient_gold")
			if kind == "potion":
				if prep.vitals.health >= prep.vitals.max_health: return _fail(&"health_full")
				var healing := maxi(roundi(float(data.healing) * maxf(1.0 + build.get_modifiers().healing_pct, 0.0)), 0)
				if healing == 0: return _fail(&"healing_blocked")
				prep.vitals.health = mini(int(prep.vitals.health) + healing, int(prep.vitals.max_health))
			else:
				if prep.vitals.emergency_potions >= data.capacity: return _fail(&"consumable_capacity")
				prep.vitals.emergency_potions += 1
			build.try_spend_gold(int(data.cost))
	return {"ok": true, "kind": kind, "offer_id": id}

func _fail(reason: StringName) -> Dictionary:
	return {"ok": false, "reason": reason}
