extends "res://tests/support/selected_profile_fixture.gd"

func _combo_fixture() -> Dictionary:
	var f := _fixture()
	var profile: Dictionary = f.profile.duplicate(true)
	var prep: Dictionary = profile.active_run.preparation
	var session = SPATIAL.new()
	session.begin(BAG.from_persistent_snapshot(prep.spatial_session.backpack), RESOLVER.new(), CATALOG.build_items(), BAGS.build_bags(), &"bongma", [], true)
	for id in session.state.items.keys(): assert_true(session.move_item_to_buffer(id))
	var ids: Array = session._acquire_items_to_buffer([&"melee_manual", &"lightning_style"])
	assert_eq(ids.size(), 2)
	assert_true(session.place_buffer_item(2, Vector2i(1, 1)))
	assert_true(session.place_buffer_item(2, Vector2i(2, 1)))
	prep.spatial_session = session.persistent_preparation_snapshot()
	prep.loadout.active_spell_ids = []
	assert_true(f.store.transact_profile(profile, 1, "setup:combo").ok)
	f.profile = f.store.load_profile().profile
	f.ids = ids
	return f

func _combo_request(f: Dictionary) -> Dictionary:
	return {"run_id": f.profile.active_run.run_id, "prepare_session_id": f.profile.active_run.preparation.prepare_session_id,
		"kind": "combination", "offer_id": "thunder_blade", "expected_revision": f.profile.revision,
		"expected_prepare_revision": f.profile.active_run.preparation.revision,
		"combination": {"source_a": f.ids[0], "source_b": f.ids[1], "x": 1, "y": 1, "rotation": 0}}

func test_combination_replaces_both_materials_once_without_touching_equipment_or_combat() -> void:
	var f := _combo_fixture()
	var c = _coordinator(f.store)
	var request := _combo_request(f)
	var result: Dictionary = c.commit_selected_purchase(request)
	assert_true(result.ok, str(result))
	if not result.ok: return
	var prep: Dictionary = result.profile.active_run.preparation
	assert_eq(prep.spatial_session.backpack.items.size(), 1)
	assert_eq(prep.spatial_session.backpack.items[0].definition_id, "thunder_blade")
	assert_eq(prep.spatial_session.buffer.size(), 2)
	assert_eq(prep.equipment, f.profile.active_run.preparation.equipment)
	assert_eq(prep.gold, f.profile.active_run.preparation.gold)
	assert_eq(result.profile.active_run.checkpoint, f.profile.active_run.checkpoint)
	assert_true(c.commit_selected_purchase(request).already_applied)
	request.expected_revision = result.profile.revision
	request.expected_prepare_revision = prep.revision
	assert_false(c.commit_selected_purchase(request).ok)

func test_screen_adapter_offers_selected_recipe_and_commits_its_pair() -> void:
	var f := _combo_fixture()
	var adapter = load("res://scripts/ui/selected_rest_adapter.gd").new()
	assert_true(adapter.open(f.store).ok)
	var options: Array = adapter.combination_options()
	assert_eq(options.size(), 1, "Display must use selected manuals rather than legacy weapons")
	if options.is_empty(): return
	var option: Dictionary = options[0]
	assert_eq(option.combo_id, &"thunder_blade")
	assert_true(adapter.begin_combination(option.combo_id, option.source_a_instance, option.source_b_instance))
	assert_true(adapter.commit_combination(Vector2i(1, 1), 0).ok)
	assert_eq(adapter.snapshot().spatial_session.backpack.items[0].definition_id, "thunder_blade")

func test_failed_placement_or_write_keeps_materials_and_retry_composes_same_recipe() -> void:
	var f := _combo_fixture()
	var c = _coordinator(f.store)
	var before := FileAccess.get_file_as_bytes(f.path)
	for mutation in ["outside", "same", "unknown", "fraction", "extra"]:
		var request := _combo_request(f)
		match mutation:
			"outside": request.combination.x = 5
			"same": request.combination.source_b = request.combination.source_a
			"unknown": request.offer_id = "invented"
			"fraction": request.combination.x = 1.5
			"extra": request.combination.result_item = "thunder_blade"
		assert_false(c.commit_selected_purchase(request).ok, mutation)
		assert_eq(FileAccess.get_file_as_bytes(f.path), before)
	var request := _combo_request(f)
	f.store.fail_open = true
	assert_false(c.commit_selected_purchase(request).ok)
	assert_eq(FileAccess.get_file_as_bytes(f.path), before)
	f.store.fail_open = false
	assert_true(c.commit_selected_purchase(request).ok)
