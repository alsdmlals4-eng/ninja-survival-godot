extends "res://tests/support/selected_profile_fixture.gd"

const LEDGER = preload("res://scripts/core/run_settlement_ledger.gd")

func test_support_unlock_cost_is_atomic_idempotent_and_preserves_active_run() -> void:
	var fixture := _fixture()
	var ledger = LEDGER.new()
	assert_true(ledger.has_method("unlock_selected_support"))
	if not ledger.has_method("unlock_selected_support"): return
	assert_false(ledger.unlock_selected_support(fixture.store, 1).ok, "Two souls cannot buy three-soul unlock")
	var funded: Dictionary = fixture.store.load_profile().profile
	funded.meta.soul_balance = 4
	assert_true(fixture.store.transact_profile(funded, 1, "test:fund").ok)
	var before := FileAccess.get_file_as_string(fixture.path)
	fixture.store.fail_open = true
	assert_false(ledger.unlock_selected_support(fixture.store, 2).ok)
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)
	fixture.store.fail_open = false
	assert_true(ledger.unlock_selected_support(fixture.store, 2).ok)
	var after: Dictionary = fixture.store.load_profile().profile
	assert_eq(int(after.meta.soul_balance), 1)
	assert_true(after.meta.unlocked_support_choice)
	assert_eq(after.active_run, funded.active_run)
	assert_true(ledger.unlock_selected_support(fixture.store, 2).ok)
	assert_eq(fixture.store.load_profile().profile, after)

func test_start_support_is_real_zero_sale_item_and_requires_profile_unlock() -> void:
	var fixture := _fixture()
	var start = add_child_autofree(START.new())
	assert_true(start.has_method("choose_support"))
	if not start.has_method("choose_support"): return
	start.begin(&"guiin", 42, true)
	for unused in range(2): start.choose(start.snapshot().draft.options[0])
	assert_false(start.confirm(), "Unlocked start must choose one support")
	assert_true(start.choose_support(&"protection_talisman"))
	assert_true(start.confirm())
	var bundle: Dictionary = start.committed_snapshot()
	assert_eq(bundle.backpack.items.size(), 3)
	var item = load("res://scripts/data/selected_backpack_catalog.gd").build_items()[&"start_support:protection_talisman"]
	assert_eq(item.sell_price(), 0)
	assert_eq(item.footprint_size, Vector2i(1, 2))
	var ledger = LEDGER.new()
	assert_false(ledger.start_selected_run(fixture.store, bundle, &"bongma", "run:support", 1, 100).ok)
	var funded: Dictionary = fixture.store.load_profile().profile
	funded.meta.soul_balance = 3
	assert_true(fixture.store.transact_profile(funded, 1, "test:fund").ok)
	assert_true(ledger.unlock_selected_support(fixture.store, 2).ok)
	var result: Dictionary = ledger.start_selected_run(fixture.store, bundle, &"bongma", "run:support", 3, 100)
	assert_true(result.ok, str(result))
	if result.ok:
		assert_eq(result.profile.active_run.checkpoint.backpack.items.size(), 3)
		assert_eq(int(result.profile.active_run.checkpoint.vitals.health), 120)
		assert_eq(int(result.profile.active_run.checkpoint.vitals.max_health), 120)
		var forged: Dictionary = result.profile.duplicate(true)
		forged.meta.unlocked_support_choice = false
		assert_false(load("res://scripts/core/run_resume_codec.gd").new().decode_profile_v2(forged).ok, "Free starter cannot survive without the unlock")

func test_new_game_atomically_settles_abandoned_run_and_publishes_start_bundle() -> void:
	var fixture := _fixture()
	var ledger = LEDGER.new()
	assert_true(ledger.has_method("start_selected_run"))
	if not ledger.has_method("start_selected_run"): return
	var start = add_child_autofree(START.new())
	start.begin(&"guiin", 42)
	for unused in range(2): start.choose(start.snapshot().draft.options[0])
	start.confirm()
	var bundle: Dictionary = start.committed_snapshot()
	var before := FileAccess.get_file_as_string(fixture.path)
	fixture.store.fail_open = true
	assert_false(ledger.start_selected_run(fixture.store, bundle, &"heukyeong", "run:new", 1, 100).ok)
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)
	fixture.store.fail_open = false
	var result: Dictionary = ledger.start_selected_run(fixture.store, bundle, &"heukyeong", "run:new", 1, 100)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(result.profile.active_run.starting_school, "guiin")
	assert_eq(result.profile.active_run.checkpoint.route.active_school_id, "heukyeong")
	assert_eq(int(result.profile.meta.soul_balance), 3)
	assert_true(result.profile.meta.settled_run_ids.has("run:trace"))
	assert_true(result.profile.meta.transaction_receipts.has("settle:run:trace"))
	assert_true(ledger.start_selected_run(fixture.store, bundle, &"heukyeong", "run:new", 1, 100).ok)
	assert_eq(int(fixture.store.load_profile().profile.meta.soul_balance), 3)
	assert_false(ledger.start_selected_run(fixture.store, bundle, &"bongma", "run:other", 1, 100).ok)

func test_initial_start_does_not_write_legacy_files_and_invalid_start_leaves_profile_missing() -> void:
	var ledger = LEDGER.new()
	assert_true(ledger.has_method("start_selected_run"))
	if not ledger.has_method("start_selected_run"): return
	var store = STORE.new()
	var path := root.path_join("new_profile.json")
	assert_true(store.configure_profile(path))
	assert_false(ledger.start_selected_run(store, {}, &"bongma", "run:new", 0, 100).ok)
	assert_false(FileAccess.file_exists(path))
	var start = add_child_autofree(START.new())
	start.begin(&"cheonsul", 31)
	for unused in range(2): start.choose(start.snapshot().draft.options[0])
	start.confirm()
	var result: Dictionary = ledger.start_selected_run(store, start.committed_snapshot(), &"bongma", "run:new", 0, 100)
	assert_true(result.ok, str(result))
	if result.ok:
		assert_eq(int(result.profile.meta.soul_balance), 0)
		assert_eq(result.profile.active_run.checkpoint.loadout.active_spell_ids.size(), 2)

func test_settlement_once_and_retry_once_with_failed_write_preserved() -> void:
	var fixture := _fixture()
	var ledger = LEDGER.new()
	assert_true(ledger.has_method("settle_selected_run"))
	assert_true(ledger.has_method("retry_selected_run"))
	if not ledger.has_method("settle_selected_run") or not ledger.has_method("retry_selected_run"): return
	assert_false(ledger.settle_selected_run(fixture.store, "run:trace", 1, true, true).ok, "No early victory award")
	var result: Dictionary = ledger.retry_selected_run(fixture.store, "run:trace", 1, true)
	assert_true(result.ok, str(result))
	if not result.ok: return
	assert_eq(int(result.profile.meta.soul_balance), 1)
	assert_true(result.profile.active_run.retry_consumed)
	assert_null(result.profile.active_run.preparation)
	assert_true(ledger.retry_selected_run(fixture.store, "run:trace", 1, true).ok)
	assert_eq(int(fixture.store.load_profile().profile.meta.soul_balance), 1)
	fixture.store.fail_open = true
	var before := FileAccess.get_file_as_string(fixture.path)
	assert_false(ledger.settle_selected_run(fixture.store, "run:trace", 2, false, true).ok)
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)
	fixture.store.fail_open = false
	assert_true(ledger.settle_selected_run(fixture.store, "run:trace", 2, false, true).ok)
	assert_true(ledger.settle_selected_run(fixture.store, "run:trace", 2, false, true).ok)
	var profile: Dictionary = fixture.store.load_profile().profile
	assert_null(profile.active_run)
	assert_eq(int(profile.meta.soul_balance), 2)
