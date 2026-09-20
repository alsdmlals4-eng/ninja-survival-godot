extends GutTest

const COORD = preload("res://scripts/core/rest_commit_coordinator.gd")
const STORE = preload("res://scripts/core/run_resume_store.gd")
const CODEC = preload("res://scripts/core/run_resume_codec.gd")
const START = preload("res://scripts/core/start_loadout_session.gd")
const ROUTE = preload("res://scripts/core/run_route_state.gd")
const ACCESS = preload("res://scripts/core/tradition_access_state.gd")
const GEAR = preload("res://scripts/core/equipment_loadout_state.gd")
const BAG = preload("res://scripts/backpack/backpack_state.gd")
const SPATIAL = preload("res://scripts/backpack/rest_backpack_session.gd")
const ITEMS = preload("res://scripts/data/selected_backpack_catalog.gd")
const BAGS = preload("res://scripts/data/mvp4_catalog.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const FATES = preload("res://scripts/data/mvp3_catalog.gd")
const MODIFIERS = preload("res://scripts/data/run_modifier_set.gd")

class FaultStore:
	extends "res://scripts/core/run_resume_store.gd"
	var fail_open := false
	var fail_read_after_write := false
	var read_blocked := false
	var on_write := Callable()
	func _open_temporary_file(destination: String) -> FileAccess:
		if on_write.is_valid():
			on_write.call()
		if fail_read_after_write:
			read_blocked = true
		return null if fail_open else super._open_temporary_file(destination)
	func load_profile() -> Dictionary:
		return {"ok": false, "reason": &"unreadable"} if read_blocked else super.load_profile()

var root: String
var serial := 0

func before_each() -> void:
	root = "user://gut_depart_transaction_%s_%s" % [OS.get_process_id(), Time.get_ticks_usec()]
	assert_eq(DirAccess.make_dir_recursive_absolute(root), OK)
	serial = 0

func after_each() -> void:
	assert_true(root.begins_with("user://gut_depart_transaction_"))
	for file in DirAccess.get_files_at(root):
		DirAccess.remove_absolute(root.path_join(file))
	DirAccess.remove_absolute(root)

func _fixture(order: Array = ["cheonsul"]) -> Dictionary:
	serial += 1
	var starter = add_child_autofree(START.new())
	assert_true(starter.begin(&"bongma", 42))
	for unused in range(2):
		assert_true(starter.choose(starter.snapshot().draft.options[0]))
	assert_true(starter.confirm())
	var bundle: Dictionary = starter.committed_snapshot()
	var access = ACCESS.new()
	access.restore_selected_snapshot(bundle.access)
	var gear = GEAR.new()
	var route = ROUTE.new()
	for index in range(order.size()):
		assert_true(route.set_provisional_next_school(StringName(order[index])))
		assert_true(route.commit_provisional_next_school())
		if index < order.size() - 1:
			assert_true(access.stabilize_school(StringName(order[index])))
			assert_true(access.decide_trace(StringName(order[index]), &"enhance", gear, &"melee", int(gear.get_snapshot().revision)))
			assert_true(route.mark_active_school_cleared())
	var checkpoint := {"rules_version": CODEC.PROFILE_CONTRACT, "prepare_session_id": "departure:prior",
		"build": {"gold": 0, "selected_school_id": "bongma", "owned_items": {}, "selected_fates": [],
			"economy_receipts": [], "equipment": gear.get_snapshot(),
			"committed_backpack_modifiers": MODIFIERS.new().to_persistent_snapshot()},
		"route": route.get_route_snapshot(), "circuit": {"phase": "core", "active_school_id": order[-1]},
		"backpack": bundle.backpack, "buffer": [], "loadout": bundle.loadout, "access": access.get_snapshot(),
		"ultimate_charge": {"school_id": "bongma", "resource_amount": 0}}
	assert_true(access.stabilize_school(StringName(order[-1])))
	assert_true(access.decide_trace(StringName(order[-1]), &"enhance", gear, &"outfit", int(gear.get_snapshot().revision)))
	var spatial = SPATIAL.new()
	spatial.begin(BAG.from_persistent_snapshot(bundle.backpack), RESOLVER.new(), ITEMS.build_items(), BAGS.build_bags(), &"bongma", [], true)
	var build = add_child_autofree(load("res://scripts/core/run_build_state.gd").new())
	build.configure(ITEMS.build_items(), FATES.build_fates())
	var rewards = add_child_autofree(load("res://scripts/core/rest_reward_controller.gd").new())
	var rng := RandomNumberGenerator.new()
	rng.seed = 75
	rewards.configure(build, spatial, ITEMS.build_items(), BAGS.build_bags(), rng, access)
	rewards.begin_rest(order.size(), &"bongma", 0, StringName(order[-1]))
	assert_true(rewards.choose_boss_reward(0))
	var fate = add_child_autofree(load("res://scripts/core/fate_controller.gd").new())
	fate.configure(build, FATES.build_fates(), rng)
	fate.begin_rest()
	var preparation := {"prepare_session_id": "prepare:current", "phase": "preparing", "revision": 3,
		"access": access.get_snapshot(), "equipment": gear.get_snapshot(), "spatial_session": spatial.persistent_preparation_snapshot(),
		"loadout": bundle.loadout, "gold": 150, "reward_state": rewards.persistent_snapshot(),
		"pending_fate": "", "fate_state": fate.persistent_preparation_snapshot(), "provisional_school": "", "healing_applied": true}
	var profile := {"schema_version": 2, "revision": 0, "content_contract": CODEC.PROFILE_CONTRACT,
		"meta": {"soul_balance": 2, "unlocked_support_choice": false, "settled_run_ids": [], "applied_transaction_ids": [], "transaction_receipts": {}},
		"active_run": {"run_id": "run:depart", "starting_school": "bongma", "elite_qualified": true, "retry_consumed": false,
			"eligible_boss_ids": order, "checkpoint": checkpoint, "preparation": preparation}}
	var store = FaultStore.new()
	var path := root.path_join("profile_%s.json" % serial)
	assert_true(store.configure_profile(path))
	assert_true(store.transact_profile(JSON.parse_string(JSON.stringify(profile)), 0, "prepare:fixture").ok)
	return {"store": store, "path": path, "profile": store.load_profile().profile}

func _request(fixture: Dictionary) -> Dictionary:
	var prep: Dictionary = fixture.profile.active_run.preparation
	return {"run_id": "run:depart", "prepare_session_id": prep.prepare_session_id,
		"expected_revision": fixture.profile.revision, "expected_prepare_revision": prep.revision,
		"expected_equipment_revision": prep.equipment.revision, "spatial_session": prep.spatial_session.duplicate(true),
		"equipped_slots": prep.equipment.equipped_slots.duplicate(true), "next_school_id": "guiin",
		"fate_id": prep.fate_state.candidate_ids[0], "ultimate_charge": {"school_id": "bongma", "resource_amount": 60}}

func _coordinator(store):
	var coordinator = COORD.new()
	assert_true(coordinator.has_method("prepare_selected_departure"), "Missing atomic departure candidate")
	assert_true(coordinator.has_method("commit_selected_departure"), "Missing durable departure command")
	if not coordinator.has_method("commit_selected_departure"):
		return null
	assert_true(coordinator.configure_selected_profile(store))
	return coordinator

func test_preview_composes_all_owners_without_touching_disk_or_request() -> void:
	var f := _fixture()
	var with_vitals: Dictionary = f.profile.duplicate(true)
	with_vitals.active_run.preparation.vitals = {"health": 63, "max_health": 100, "emergency_potions": 1}
	assert_true(f.store.transact_profile(with_vitals, 1, "setup:vitals").ok)
	f.profile = f.store.load_profile().profile
	var c = _coordinator(f.store)
	if c == null: return
	var request := _request(f)
	var before := request.duplicate(true)
	var bytes := FileAccess.get_file_as_bytes(f.path)
	var result: Dictionary = c.prepare_selected_departure(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	var cp: Dictionary = result.profile.active_run.checkpoint
	assert_eq(cp.route.clear_order, ["cheonsul"])
	assert_eq(cp.route.active_school_id, "guiin")
	assert_eq(cp.circuit.phase, "core")
	assert_eq(int(cp.build.gold), 150)
	assert_eq(cp.build.selected_fates, [request.fate_id])
	assert_eq(int(cp.build.equipment.upgrade_rank_by_instance.gear_ninja_suit), 0)
	assert_eq(cp.build.equipment.imbuements.gear_ninja_suit, ["cheonsul"])
	assert_eq(cp.access, f.profile.active_run.preparation.access)
	assert_eq(cp.buffer.size(), 1, "Unplaced earned reward is carried, not erased")
	assert_eq(cp.loadout.active_spell_ids, f.profile.active_run.checkpoint.loadout.active_spell_ids)
	assert_eq(int(cp.ultimate_charge.resource_amount), 60)
	assert_eq(cp.vitals, f.profile.active_run.preparation.vitals)
	assert_null(result.profile.active_run.preparation)
	assert_eq(result.profile.meta, f.profile.meta)
	assert_eq(request, before)
	assert_eq(FileAccess.get_file_as_bytes(f.path), bytes)

func test_write_failure_is_zero_change_then_reopen_retry_departs_once() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var request := _request(f)
	var bytes := FileAccess.get_file_as_bytes(f.path)
	f.store.fail_open = true
	assert_false(c.commit_selected_departure(request).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), bytes)
	assert_eq(f.store.load_profile().profile, f.profile)
	f.store.fail_open = false
	var result: Dictionary = c.commit_selected_departure(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(int(result.profile.revision), 2)
	var reopened = STORE.new()
	reopened.configure_profile(f.path)
	var duplicate: Dictionary = _coordinator(reopened).commit_selected_departure(JSON.parse_string(JSON.stringify(request)))
	assert_true(duplicate.ok)
	assert_true(duplicate.already_applied)
	assert_eq(reopened.load_profile().profile, result.profile)
	request.next_school_id = "heukyeong"
	assert_false(c.commit_selected_departure(request).ok)
	assert_eq(reopened.load_profile().profile, result.profile)

func test_unresolved_trace_rewards_chests_or_fate_blocks_departure() -> void:
	for failure in ["trace", "reward", "chest", "fate"]:
		var f := _fixture()
		var c = _coordinator(f.store)
		if c == null: return
		var profile: Dictionary = f.profile.duplicate(true)
		var prep: Dictionary = profile.active_run.preparation
		match failure:
			"trace":
				var access = ACCESS.new()
				access.restore_selected_snapshot(profile.active_run.checkpoint.access)
				access.stabilize_school(&"cheonsul")
				prep.access = access.get_snapshot()
				prep.equipment = profile.active_run.checkpoint.build.equipment.duplicate(true)
			"reward": prep.reward_state.boss_pending = true
			"chest": prep.reward_state.chests = 1
		assert_true(f.store.transact_profile(profile, 1, "fixture:" + failure).ok)
		f.profile = f.store.load_profile().profile
		var request := _request(f)
		if failure == "fate": request.fate_id = ""
		var bytes := FileAccess.get_file_as_bytes(f.path)
		assert_false(c.commit_selected_departure(request).ok, failure)
		assert_eq(FileAccess.get_file_as_bytes(f.path), bytes)

func test_request_cannot_mint_or_delete_inventory_or_forge_meta() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var bytes := FileAccess.get_file_as_bytes(f.path)
	for failure in ["missing_item", "extra_item", "replace_item", "next_id", "equipment", "gold", "access"]:
		var request := _request(f)
		match failure:
			"missing_item": request.spatial_session.buffer.clear()
			"extra_item":
				var item: Dictionary = request.spatial_session.buffer[0].duplicate()
				item.instance_id = request.spatial_session.backpack.next_instance_id
				request.spatial_session.backpack.next_instance_id += 1
				request.spatial_session.buffer.append(item)
			"replace_item": request.spatial_session.buffer[0].definition_id = "heart_charm"
			"next_id": request.spatial_session.backpack.next_instance_id += 1
			"equipment": request.equipped_slots.melee = "gear_odachi"
			"gold": request.gold = 999
			"access": request.access = f.profile.active_run.preparation.access
		assert_false(c.commit_selected_departure(request).ok, failure)
		assert_eq(FileAccess.get_file_as_bytes(f.path), bytes)

func test_final_departure_requires_no_fifth_school_and_allows_fate_skip() -> void:
	var f := _fixture(["cheonsul", "guiin", "heukyeong", "bongma"])
	var c = _coordinator(f.store)
	if c == null: return
	var request := _request(f)
	assert_false(c.prepare_selected_departure(request).ok, "No fifth battlefield")
	request.next_school_id = ""
	request.fate_id = ""
	var result: Dictionary = c.commit_selected_departure(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(result.profile.active_run.checkpoint.circuit, {"phase": "final_boss", "active_school_id": ""})
	assert_eq(result.profile.active_run.checkpoint.route.clear_order, ["cheonsul", "guiin", "heukyeong", "bongma"])
	assert_true(result.profile.active_run.checkpoint.route.final_binding_eligible)
	assert_eq(result.profile.active_run.checkpoint.build.selected_fates, [])
	assert_null(result.profile.active_run.preparation)

func test_stale_or_malformed_requests_do_not_change_preparation() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var bytes := FileAccess.get_file_as_bytes(f.path)
	for field in _request(f):
		var request := _request(f)
		request[field] = null
		assert_false(c.commit_selected_departure(request).ok, field)
	for field in ["expected_revision", "expected_prepare_revision", "expected_equipment_revision"]:
		var request := _request(f)
		request[field] += 1
		assert_false(c.commit_selected_departure(request).ok, field)
	var repeat_school := _request(f)
	repeat_school.next_school_id = "cheonsul"
	assert_false(c.commit_selected_departure(repeat_school).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), bytes)

func test_reentrant_departure_and_trace_are_blocked_during_publication() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var request := _request(f)
	var reentries: Array = []
	# FaultStore is retained by the coordinator: the injected callback must not
	# retain the coordinator in return (a test-only reference cycle).
	var coordinator_lifetime: WeakRef = weakref(c)
	f.store.on_write = func():
		reentries.append(coordinator_lifetime.get_ref().commit_selected_departure(request))
		reentries.append(coordinator_lifetime.get_ref().commit_selected_trace({}))
	var result: Dictionary = c.commit_selected_departure(request)
	assert_true(result.ok, str(result))
	assert_eq(reentries.size(), 2)
	for reentry in reentries:
		assert_false(reentry.ok)
		assert_eq(reentry.reason, &"not_ready")
	var store_lifetime: WeakRef = weakref(f.store)
	c = null
	f.store = null
	assert_null(coordinator_lifetime.get_ref(), "Reentry fixture must not retain the coordinator")
	assert_null(store_lifetime.get_ref(), "Reentry fixture must not retain the store")

func test_owned_equipment_switch_and_unplaced_book_update_only_departing_build() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var candidate: Dictionary = f.profile.duplicate(true)
	var gear = GEAR.new()
	gear.restore_snapshot(candidate.active_run.preparation.equipment)
	assert_true(gear.acquire(&"dual_tanto"))
	candidate.active_run.preparation.equipment = gear.get_snapshot()
	assert_true(f.store.transact_profile(candidate, 1, "fixture:owned-gear").ok)
	f.profile = f.store.load_profile().profile
	var request := _request(f)
	var spatial = SPATIAL.new()
	spatial.begin(BAG.from_persistent_snapshot(request.spatial_session.backpack), RESOLVER.new(), ITEMS.build_items(), BAGS.build_bags(), &"bongma")
	assert_true(spatial.restore_preparation_snapshot(request.spatial_session))
	var first: Dictionary = request.spatial_session.backpack.items[0]
	assert_true(spatial.move_item_to_buffer(int(first.instance_id)))
	request.spatial_session = spatial.persistent_preparation_snapshot()
	request.equipped_slots.melee = "gear_dual_tanto"
	var expected_active: Array = f.profile.active_run.checkpoint.loadout.active_spell_ids.duplicate()
	expected_active.erase(str(COORD.SELECTED_BOOKS.spell_id(StringName(first.definition_id))))
	var before: Dictionary = f.profile.duplicate(true)
	var result: Dictionary = c.commit_selected_departure(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	var cp: Dictionary = result.profile.active_run.checkpoint
	assert_eq(cp.build.equipment.equipped_slots.melee, "gear_dual_tanto")
	assert_eq(cp.build.equipment.owned_instances, before.active_run.preparation.equipment.owned_instances)
	assert_eq(cp.build.equipment.upgrade_rank_by_instance, before.active_run.preparation.equipment.upgrade_rank_by_instance)
	assert_eq(int(cp.build.equipment.revision), int(before.active_run.preparation.equipment.revision) + 1)
	assert_eq(cp.loadout.active_spell_ids, expected_active)
	assert_eq(cp.buffer.size(), 2)
	assert_eq(before.active_run.checkpoint.build.equipment.equipped_slots.melee, "gear_katana")
	assert_eq(before.active_run.checkpoint.loadout.active_spell_ids.size(), 2)
	assert_eq(f.profile, before, "Caller values must remain detached")

func test_committed_readback_failure_retries_without_departing_twice() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var request := _request(f)
	f.store.fail_read_after_write = true
	var result: Dictionary = c.commit_selected_departure(request)
	assert_false(result.ok)
	assert_true(result.persisted)
	assert_eq(result.reason, &"committed_reload_required")
	f.store.read_blocked = false
	f.store.fail_read_after_write = false
	result = c.commit_selected_departure(request)
	assert_true(result.ok)
	assert_true(result.already_applied)
	assert_eq(int(result.profile.revision), 2)
	assert_eq(result.profile.active_run.checkpoint.route.clear_order, ["cheonsul"])
	assert_eq(result.profile.active_run.checkpoint.build.selected_fates.size(), 1)

func test_duplicate_after_later_profile_transaction_returns_current_not_old_profile() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var request := _request(f)
	var result: Dictionary = c.commit_selected_departure(request)
	assert_true(result.ok)
	if not result.ok: return
	var later: Dictionary = result.profile.duplicate(true)
	later.active_run = null
	assert_true(f.store.transact_profile(later, 2, "fixture:ended").ok)
	var current: Dictionary = f.store.load_profile().profile
	var duplicate: Dictionary = c.commit_selected_departure(request)
	assert_true(duplicate.ok)
	assert_true(duplicate.already_applied)
	assert_null(duplicate.profile.active_run, "Old departure must not resurrect an ended run")
	assert_eq(duplicate.profile, current)

func test_all_twenty_four_clear_orders_reach_final_without_changing_order() -> void:
	for a in ROUTE.SCHOOL_IDS:
		for b in ROUTE.SCHOOL_IDS:
			if b == a: continue
			for d in ROUTE.SCHOOL_IDS:
				if d == a or d == b: continue
				for e in ROUTE.SCHOOL_IDS:
					if e == a or e == b or e == d: continue
					var order := [str(a), str(b), str(d), str(e)]
					var f := _fixture(order)
					var c = _coordinator(f.store)
					if c == null: return
					var request := _request(f)
					request.next_school_id = ""
					request.fate_id = ""
					var result: Dictionary = c.prepare_selected_departure(request)
					assert_true(result.ok, str(result))
					if not result.ok: continue
					assert_eq(result.profile.active_run.checkpoint.route.clear_order, order)
					assert_eq(result.profile.active_run.checkpoint.circuit.phase, "final_boss")
					assert_eq(result.profile.active_run.eligible_boss_ids, order)

func test_invalid_charge_geometry_or_unreserved_fate_cannot_write() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var bytes := FileAccess.get_file_as_bytes(f.path)
	for failure in ["charge", "charge_school", "charge_nan", "overlap", "fractional", "unknown_fate", "object", "pending_bag"]:
		var request := _request(f)
		match failure:
			"charge": request.ultimate_charge.resource_amount = 121
			"charge_school": request.ultimate_charge.school_id = "guiin"
			"charge_nan": request.ultimate_charge.resource_amount = NAN
			"overlap":
				request.spatial_session.backpack.items[1].origin_x = request.spatial_session.backpack.items[0].origin_x
				request.spatial_session.backpack.items[1].origin_y = request.spatial_session.backpack.items[0].origin_y
			"fractional": request.spatial_session.backpack.items[0].origin_x += 0.1
			"unknown_fate": request.fate_id = "not_a_fate"
			"object": request.spatial_session = RefCounted.new()
			"pending_bag": request.spatial_session.pending_bag = {"instance_id": 0, "definition_id": "bag_regular_2x2", "rotation_quarters": 0}
		assert_false(c.commit_selected_departure(request).ok, failure)
		assert_eq(FileAccess.get_file_as_bytes(f.path), bytes)

func test_saved_preparation_update_invalidates_existing_departure_preview() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var request := _request(f)
	assert_true(c.prepare_selected_departure(request).ok)
	var later: Dictionary = f.profile.duplicate(true)
	later.active_run.preparation.revision += 1
	later.active_run.preparation.gold = 125
	assert_true(f.store.transact_profile(later, 1, "fixture:purchase").ok)
	var bytes := FileAccess.get_file_as_bytes(f.path)
	assert_false(c.commit_selected_departure(request).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), bytes)
	assert_eq(int(f.store.load_profile().profile.active_run.preparation.gold), 125)

func test_accumulated_fates_survive_and_known_but_unoffered_fate_is_rejected() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var ids: Array = FATES.build_fates().keys()
	ids.sort()
	var profile: Dictionary = f.profile.duplicate(true)
	profile.active_run.checkpoint.build.selected_fates = [str(ids[0])]
	profile.active_run.preparation.fate_state.candidate_ids = [str(ids[1]), str(ids[2]), str(ids[3])]
	assert_true(f.store.transact_profile(profile, 1, "fixture:fate-history").ok)
	f.profile = f.store.load_profile().profile
	var request := _request(f)
	request.fate_id = str(ids[4])
	assert_false(c.commit_selected_departure(request).ok, "A real catalog fate is not automatically an offered choice")
	request.fate_id = str(ids[0])
	assert_false(c.commit_selected_departure(request).ok, "No repeated fate")
	request.fate_id = str(ids[1])
	var result: Dictionary = c.commit_selected_departure(request)
	assert_true(result.ok, str(result))
	if result.ok:
		assert_eq(result.profile.active_run.checkpoint.build.selected_fates, [str(ids[0]), str(ids[1])])

func test_six_buffer_items_survive_departure_without_contributing_power() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	if c == null: return
	var profile: Dictionary = f.profile.duplicate(true)
	var spatial = SPATIAL.new()
	spatial.begin(BAG.from_persistent_snapshot(profile.active_run.preparation.spatial_session.backpack), RESOLVER.new(), ITEMS.build_items(), BAGS.build_bags(), &"bongma")
	assert_true(spatial.restore_preparation_snapshot(profile.active_run.preparation.spatial_session))
	assert_eq(spatial._acquire_items_to_buffer([&"projectile_manual", &"projectile_manual", &"projectile_manual", &"projectile_manual", &"projectile_manual"]).size(), 5)
	profile.active_run.preparation.spatial_session = spatial.persistent_preparation_snapshot()
	assert_true(f.store.transact_profile(profile, 1, "fixture:buffer").ok)
	f.profile = f.store.load_profile().profile
	var result: Dictionary = c.commit_selected_departure(_request(f))
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(result.profile.active_run.checkpoint.buffer.size(), 6)
	assert_eq(result.profile.active_run.checkpoint.build.committed_backpack_modifiers,
		f.profile.active_run.checkpoint.build.committed_backpack_modifiers)
	assert_eq(result.profile.active_run.checkpoint.loadout.active_spell_ids,
		f.profile.active_run.checkpoint.loadout.active_spell_ids)
