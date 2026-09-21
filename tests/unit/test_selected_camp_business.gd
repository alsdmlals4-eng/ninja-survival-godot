extends "res://tests/support/selected_profile_fixture.gd"

func _command(f: Dictionary, kind: String, id: String = "") -> Dictionary:
	f.profile = f.store.load_profile().profile
	return {"run_id": f.profile.active_run.run_id, "prepare_session_id": f.profile.active_run.preparation.prepare_session_id,
		"kind": kind, "offer_id": id, "expected_revision": f.profile.revision,
		"expected_prepare_revision": f.profile.active_run.preparation.revision}

func _draft(f: Dictionary):
	var spatial: Dictionary = f.store.load_profile().profile.active_run.preparation.spatial_session
	var session = SPATIAL.new()
	assert_true(session.begin(BAG.from_persistent_snapshot(spatial.backpack), RESOLVER.new(),
		CATALOG.build_items(), BAGS.build_bags(), &"bongma", [], true))
	assert_true(session.restore_preparation_snapshot(spatial))
	return session

func test_reserved_boss_reward_chest_and_sale_are_durable_and_not_replayed() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	var id := str(f.profile.active_run.preparation.reward_state.boss_ids[0])
	var request := _command(f, "boss_reward", id)
	var result: Dictionary = c.commit_selected_purchase(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_false(result.profile.active_run.preparation.reward_state.boss_pending)
	assert_eq(result.profile.active_run.preparation.spatial_session.buffer.size(), 1)
	assert_true(c.commit_selected_purchase(request).already_applied)
	assert_false(c.commit_selected_purchase(_command(f, "boss_reward", id)).ok)
	request = _command(f, "chest")
	result = c.commit_selected_purchase(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(int(result.profile.active_run.preparation.reward_state.chests), 0)
	assert_eq(result.profile.active_run.preparation.spatial_session.buffer.size(), 3)
	assert_true(c.commit_selected_purchase(request).already_applied)
	assert_false(c.commit_selected_purchase(_command(f, "chest")).ok)
	var item: Dictionary = result.profile.active_run.preparation.spatial_session.buffer[0]
	request = _command(f, "sell_item", str(int(item.instance_id)))
	result = c.commit_selected_purchase(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(result.profile.active_run.preparation.spatial_session.buffer.size(), 2)
	assert_gt(int(result.profile.active_run.preparation.gold), 150)
	assert_true(c.commit_selected_purchase(request).already_applied)
	assert_eq(result.profile.active_run.checkpoint, f.profile.active_run.checkpoint)
	assert_false(c.commit_selected_purchase(_command(f, "sell_item", str(int(item.instance_id)))).ok)

func test_purchase_adopts_valid_owned_layout_but_not_departure_power() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	var session = _draft(f)
	var first_id: int = session.state.items.keys()[0]
	assert_true(session.move_item_to_buffer(first_id))
	var draft: Dictionary = session.persistent_preparation_snapshot()
	var request := _command(f, "equipment", "naginata")
	request.spatial_session = draft
	var result: Dictionary = c.commit_selected_purchase(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(result.profile.active_run.preparation.spatial_session, JSON.parse_string(JSON.stringify(draft)))
	assert_eq(result.profile.active_run.preparation.loadout.active_spell_ids.size(), 1)
	assert_eq(result.profile.active_run.checkpoint.loadout.active_spell_ids.size(), 2)
	assert_eq(result.profile.active_run.checkpoint, f.profile.active_run.checkpoint)
	assert_true(c.commit_selected_purchase(request).already_applied)

func test_draft_cannot_mint_discard_or_reidentify_owned_items() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	var before := FileAccess.get_file_as_bytes(f.path)
	for mutation in ["drop", "mint", "identity", "next", "fraction", "pending"]:
		var request := _command(f, "equipment", "naginata")
		request.spatial_session = f.profile.active_run.preparation.spatial_session.duplicate(true)
		var spatial: Dictionary = request.spatial_session
		match mutation:
			"drop": spatial.backpack.items.remove_at(0)
			"mint": spatial.buffer.append({"instance_id": 100, "definition_id": "healing_herb", "rotation_quarters": 0})
			"identity": spatial.backpack.items[0].definition_id = spatial.backpack.items[1].definition_id
			"next": spatial.backpack.next_instance_id += 1
			"fraction": spatial.backpack.items[0].instance_id += 0.5
			"pending": spatial.pending_bag = {"instance_id": 0, "definition_id": "starter_bag", "rotation_quarters": 0}
		assert_false(c.commit_selected_purchase(request).ok, mutation)
		assert_eq(FileAccess.get_file_as_bytes(f.path), before, mutation)

func test_layout_and_reward_fail_together_and_retry_keeps_reserved_outcome() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	var session = _draft(f)
	assert_true(session.move_item_to_buffer(session.state.items.keys()[0]))
	var request := _command(f, "chest")
	request.spatial_session = session.persistent_preparation_snapshot()
	var before := FileAccess.get_file_as_bytes(f.path)
	f.store.fail_open = true
	assert_false(c.commit_selected_purchase(request).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)
	f.store.fail_open = false
	var result: Dictionary = c.commit_selected_purchase(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(result.profile.active_run.preparation.spatial_session.buffer.size(), 3)
	assert_eq(int(result.profile.active_run.preparation.reward_state.chests), 0)
	assert_eq(result.profile.active_run.checkpoint, f.profile.active_run.checkpoint)
	assert_true(c.commit_selected_purchase(request).already_applied)

func test_reroll_failure_preserves_rng_and_success_is_charged_once() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	var request := _command(f, "reroll")
	var before := FileAccess.get_file_as_bytes(f.path)
	f.store.fail_open = true
	assert_false(c.commit_selected_purchase(request).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)
	f.store.fail_open = false
	var result: Dictionary = c.commit_selected_purchase(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_lt(int(result.profile.active_run.preparation.gold), 150)
	assert_eq(int(result.profile.active_run.preparation.reward_state.shop.reroll_index), 1)
	var repeated: Dictionary = c.commit_selected_purchase(request)
	assert_true(repeated.already_applied)
	assert_eq(repeated.profile, result.profile)
	assert_false(c.commit_selected_purchase(_command(f, "reroll", "forged-discount")).ok)

func test_purchased_bag_placement_survives_the_next_purchase_without_duplication() -> void:
	var f := _fixture()
	var c = _coordinator(f.store)
	var result: Dictionary = c.commit_selected_purchase(_command(f, "bag", str(f.profile.active_run.preparation.reward_state.shop.bag_id)))
	assert_true(result.ok, str(result))
	if not result.ok: return
	var session = _draft(f)
	var placed := false
	for y in range(6):
		for x in range(6):
			for rotation in range(4):
				if not placed: placed = session.place_pending_bag(Vector2i(x, y), rotation)
	assert_true(placed)
	if not placed: return
	var request := _command(f, "equipment", "naginata")
	request.spatial_session = session.persistent_preparation_snapshot()
	result = c.commit_selected_purchase(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_null(result.profile.active_run.preparation.spatial_session.pending_bag)
	assert_eq(result.profile.active_run.preparation.spatial_session.backpack.bags.size(), 2)
	assert_true(c.commit_selected_purchase(request).already_applied)
	assert_eq(result.profile.active_run.checkpoint.backpack.bags.size(), 1)
