extends "res://tests/support/selected_profile_fixture.gd"

func _camp() -> Dictionary:
	var f := _fixture()
	var profile: Dictionary = f.profile.duplicate(true)
	profile.active_run.preparation.vitals = {"health": 50, "max_health": 100, "emergency_potions": 0}
	assert_true(f.store.transact_profile(profile, 1, "setup:hp").ok)
	f.profile = f.store.load_profile().profile
	return f

func _buy_request(f: Dictionary, kind: String, id: String) -> Dictionary:
	f.profile = f.store.load_profile().profile
	return {"run_id": f.profile.active_run.run_id, "prepare_session_id": f.profile.active_run.preparation.prepare_session_id,
		"kind": kind, "offer_id": id, "expected_revision": f.profile.revision,
		"expected_prepare_revision": f.profile.active_run.preparation.revision}

func test_equipment_purchase_stays_outside_bag_and_repeated_intent_costs_once() -> void:
	var f := _camp()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_purchase"))
	if not c.has_method("commit_selected_purchase"): return
	var request := _buy_request(f, "equipment", "naginata")
	var result: Dictionary = c.commit_selected_purchase(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	var prep: Dictionary = result.profile.active_run.preparation
	assert_eq(int(prep.gold), 105)
	assert_true(prep.equipment.owned_instances.has("gear_naginata"))
	assert_eq(prep.equipment.equipped_slots.melee, "gear_katana", "Purchase is not forced equip")
	assert_eq(prep.spatial_session, f.profile.active_run.preparation.spatial_session)
	assert_true(c.commit_selected_purchase(request).already_applied)
	assert_false(c.commit_selected_purchase(_buy_request(f, "equipment", "naginata")).ok)
	assert_eq(int(f.store.load_profile().profile.active_run.preparation.gold), 105)

func test_consumables_share_saved_cost_and_effect_and_preserve_departure() -> void:
	var f := _camp()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_purchase"))
	if not c.has_method("commit_selected_purchase"): return
	for purchase in [["potion", 135, 75], ["emergency", 110, 75], ["potion", 95, 100]]:
		var result: Dictionary = c.commit_selected_purchase(_buy_request(f, purchase[0], ""))
		assert_true(result.ok, str(result))
		if not result.ok: return
		assert_eq(int(result.profile.active_run.preparation.gold), purchase[1])
		assert_eq(int(result.profile.active_run.preparation.vitals.health), purchase[2])
		assert_eq(result.profile.active_run.checkpoint, f.profile.active_run.checkpoint)
	assert_false(c.commit_selected_purchase(_buy_request(f, "potion", "")).ok, "Full HP cannot spend on wasted healing")
	assert_false(c.commit_selected_purchase(_buy_request(f, "emergency", "")).ok, "Carry limit1")
	assert_eq(int(f.store.load_profile().profile.active_run.preparation.vitals.emergency_potions), 1)

func test_book_requires_absorption_then_costs40_and_has_zero_power_in_buffer() -> void:
	var f := _camp()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_purchase"))
	if not c.has_method("commit_selected_purchase"): return
	assert_false(c.commit_selected_purchase(_buy_request(f, "book", "cheonsul_wind_pillar")).ok)
	var trace: Dictionary = _request(f, "absorb", "")
	trace.expected_revision = f.profile.revision
	assert_true(c.commit_selected_trace(trace).ok)
	var result: Dictionary = c.commit_selected_purchase(_buy_request(f, "book", "cheonsul_wind_pillar"))
	assert_true(result.ok, str(result))
	if not result.ok: return
	var prep: Dictionary = result.profile.active_run.preparation
	assert_eq(int(prep.gold), 110)
	assert_eq(prep.spatial_session.buffer[0].definition_id, "book:cheonsul_wind_pillar")
	assert_false(prep.loadout.active_spell_ids.has("cheonsul_wind_pillar"))
	assert_false(c.commit_selected_purchase(_buy_request(f, "book", "cheonsul_wind_pillar")).ok)
	assert_false(c.commit_selected_purchase(_buy_request(f, "book", "start_book:cheonsul_wind_pillar")).ok)

func test_failed_purchase_keeps_gold_health_inventory_and_profile_bytes_unchanged() -> void:
	var f := _camp()
	var c = _coordinator(f.store)
	assert_true(c.has_method("commit_selected_purchase"))
	if not c.has_method("commit_selected_purchase"): return
	var request := _buy_request(f, "potion", "")
	var before := FileAccess.get_file_as_bytes(f.path)
	f.store.fail_open = true
	assert_false(c.commit_selected_purchase(request).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)
	f.store.fail_open = false
	assert_true(c.commit_selected_purchase(request).ok)
	assert_true(c.commit_selected_purchase(request).already_applied)
	assert_eq(int(f.store.load_profile().profile.active_run.preparation.vitals.health), 75)

func test_reserved_shop_and_bag_offers_are_the_only_spatial_purchases() -> void:
	var f := _camp()
	var c = _coordinator(f.store)
	var shop: Dictionary = f.profile.active_run.preparation.reward_state.shop
	var item_id := str(shop.offer_ids[0])
	var price: int = CATALOG.build_items()[StringName(item_id)].base_price
	var item: Dictionary = c.commit_selected_purchase(_buy_request(f, "shop_item", item_id))
	assert_true(item.ok, str(item))
	if not item.ok: return
	assert_eq(int(item.profile.active_run.preparation.gold), 150 - price)
	assert_eq(item.profile.active_run.preparation.spatial_session.buffer[0].definition_id, item_id)
	assert_false(c.commit_selected_purchase(_buy_request(f, "bag", "not-an-offer")).ok)
	var bag: Dictionary = c.commit_selected_purchase(_buy_request(f, "bag", str(shop.bag_id)))
	assert_true(bag.ok, str(bag))
	if not bag.ok: return
	assert_not_null(bag.profile.active_run.preparation.spatial_session.pending_bag)
	assert_true(bag.profile.active_run.preparation.reward_state.shop.bag_bought)
	assert_false(c.commit_selected_purchase(_buy_request(f, "bag", str(shop.bag_id))).ok)

func test_unfunded_or_forged_purchase_preserves_all_owners() -> void:
	var f := _camp()
	var c = _coordinator(f.store)
	var request := _buy_request(f, "equipment", "naginata")
	for field in ["cost", "quantity", "health", "equipment"]:
		var forged := request.duplicate(true)
		forged[field] = 0
		assert_false(c.commit_selected_purchase(forged).ok)
	var poor: Dictionary = f.profile.duplicate(true)
	poor.active_run.preparation.gold = 0
	assert_true(f.store.transact_profile(poor, int(f.profile.revision), "setup:poor").ok)
	var before := FileAccess.get_file_as_bytes(f.path)
	assert_false(c.commit_selected_purchase(_buy_request(f, "potion", "")).ok)
	assert_false(c.commit_selected_purchase(_buy_request(f, "equipment", "naginata")).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)

func test_full_buffer_rejects_book_and_saved_readback_failure_is_not_double_charged() -> void:
	var f := _camp()
	var c = _coordinator(f.store)
	var full: Dictionary = f.profile.duplicate(true)
	var spatial = SPATIAL.new()
	spatial.begin(BAG.from_persistent_snapshot(full.active_run.preparation.spatial_session.backpack),
		RESOLVER.new(), CATALOG.build_items(), BAGS.build_bags(), &"bongma")
	spatial.restore_preparation_snapshot(full.active_run.preparation.spatial_session)
	assert_eq(spatial._acquire_items_to_buffer([&"fortune_talisman", &"fortune_talisman", &"fortune_talisman",
		&"fortune_talisman", &"fortune_talisman", &"fortune_talisman"]).size(), 6)
	full.active_run.preparation.spatial_session = spatial.persistent_preparation_snapshot()
	assert_true(f.store.transact_profile(full, int(f.profile.revision), "setup:full").ok)
	var picks: Array = full.active_run.preparation.loadout.draft_picks
	var spell := ""
	for definition in load("res://scripts/data/ninjutsu_catalog.gd").build_definitions().values():
		if definition.school_id == &"bongma" and not picks.has(str(definition.ninjutsu_id)):
			spell = str(definition.ninjutsu_id)
			break
	var before := FileAccess.get_file_as_bytes(f.path)
	assert_false(c.commit_selected_purchase(_buy_request(f, "book", spell)).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)
	var request := _buy_request(f, "potion", "")
	f.store.fail_read_after_write = true
	var failed_read: Dictionary = c.commit_selected_purchase(request)
	assert_false(failed_read.ok)
	assert_true(failed_read.get("persisted", false))
	f.store.read_blocked = false
	f.store.fail_read_after_write = false
	var resumed: Dictionary = c.commit_selected_purchase(request)
	assert_true(resumed.ok and resumed.already_applied)
	assert_eq(int(resumed.profile.active_run.preparation.gold), 135)
	assert_eq(int(resumed.profile.active_run.preparation.vitals.health), 75)
