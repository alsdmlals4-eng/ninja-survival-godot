extends "res://tests/support/selected_profile_fixture.gd"

const ADAPTER_PATH = "res://scripts/ui/selected_rest_adapter.gd"

func _adapter(store):
	assert_true(ResourceLoader.exists(ADAPTER_PATH), "Selected preparation needs a real screen adapter")
	if not ResourceLoader.exists(ADAPTER_PATH): return null
	var adapter = load(ADAPTER_PATH).new()
	assert_true(adapter.open(store).ok)
	return adapter

func test_draft_stays_detached_and_survives_trace_forge_and_failed_purchase() -> void:
	var fixture := _fixture()
	var adapter = _adapter(fixture.store)
	if adapter == null: return
	var before := FileAccess.get_file_as_string(fixture.path)
	var item = adapter.spatial.state.items.values()[0]
	assert_true(adapter.edit("to_buffer", [item.instance_id]))
	var draft: Dictionary = adapter.spatial.persistent_preparation_snapshot()
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)
	assert_true(adapter.choose_route(&"guiin"))
	assert_true(adapter.trace("enhance", "melee").ok)
	assert_eq(adapter.spatial.persistent_preparation_snapshot(), draft)
	assert_eq(adapter.route.provisional_school_id(), &"guiin")
	assert_true(adapter.forge("melee").ok)
	assert_eq(adapter.spatial.persistent_preparation_snapshot(), draft)
	before = FileAccess.get_file_as_string(fixture.path)
	fixture.store.fail_open = true
	assert_false(adapter.purchase("equipment", "kunai").ok)
	assert_eq(FileAccess.get_file_as_string(fixture.path), before)
	assert_eq(adapter.spatial.persistent_preparation_snapshot(), draft)
	fixture.store.fail_open = false
	assert_true(adapter.purchase("equipment", "kunai").ok)
	assert_eq(adapter.spatial.persistent_preparation_snapshot(), draft)
	assert_false(adapter.edit("undo", []), "Undo must not resurrect paid/sold state")
	assert_true(adapter.purchase("equip", "kunai").ok)
	assert_eq(adapter.snapshot().equipment.equipped_slots.projectile, "gear_kunai")
	assert_eq(fixture.store.load_profile().profile.active_run.checkpoint, fixture.profile.active_run.checkpoint)

func test_readback_uncertainty_blocks_new_commands_until_explicit_reload() -> void:
	var fixture := _fixture()
	var adapter = _adapter(fixture.store)
	if adapter == null: return
	fixture.store.fail_read_after_write = true
	var result: Dictionary = adapter.purchase("equipment", "kunai")
	assert_false(result.ok)
	assert_eq(result.reason, &"committed_reload_required")
	assert_false(adapter.purchase("equipment", "shortbow").ok)
	assert_false(adapter.edit("undo", []))
	fixture.store.fail_read_after_write = false
	fixture.store.read_blocked = false
	assert_true(adapter.reload().ok)
	assert_true(adapter.snapshot().equipment.owned_instances.has("gear_kunai"))
	assert_false(adapter.purchase("equipment", "kunai").ok)
	assert_eq(int(adapter.snapshot().gold), 115)

func test_stale_screen_cannot_overwrite_other_saved_changes() -> void:
	var fixture := _fixture()
	var first = _adapter(fixture.store)
	var stale = _adapter(fixture.store)
	if first == null or stale == null: return
	assert_true(first.purchase("equipment", "kunai").ok)
	var bytes := FileAccess.get_file_as_string(fixture.path)
	assert_eq(stale.purchase("equipment", "shortbow").reason, &"stale_revision")
	assert_eq(FileAccess.get_file_as_string(fixture.path), bytes)
	assert_true(stale.reload().ok)
	assert_true(stale.purchase("equip", "kunai").ok)
	assert_false(stale.purchase("equip", "shortbow").ok)

func test_move_uses_preview_contract_and_failed_move_has_no_lingering_preview() -> void:
	var fixture := _fixture()
	var adapter = _adapter(fixture.store)
	if adapter == null: return
	var item = adapter.spatial.state.items.values()[0]
	assert_true(adapter.edit("move", [item.instance_id, item.origin, item.rotation_quarters]))
	assert_false(adapter.edit("move", [item.instance_id, Vector2i(99, 99), 0]))
	assert_false(adapter.spatial.persistent_preparation_snapshot().is_empty())
