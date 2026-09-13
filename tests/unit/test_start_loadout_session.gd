extends GutTest

const SESSION = preload("res://scripts/core/start_loadout_session.gd")
const COORDINATOR = preload("res://scripts/core/rest_commit_coordinator.gd")


func _confirmed(school: StringName):
	var session = add_child_autofree(SESSION.new())
	assert_true(session.begin(school, 42))
	for index in range(2):
		assert_true(session.choose(session.snapshot().draft.options[0]))
	assert_true(session.confirm())
	return session.committed_snapshot()


func test_all_start_schools_produce_cross_validated_build_bundles() -> void:
	var coordinator = COORDINATOR.new()
	assert_true(coordinator.has_method("validate_selected_build_bundle"))
	if not coordinator.has_method("validate_selected_build_bundle"):
		return
	for school in [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]:
		var bundle: Dictionary = _confirmed(school)
		assert_true(bundle.has("access"))
		assert_true(coordinator.validate_selected_build_bundle(JSON.parse_string(JSON.stringify(bundle))))
		var broken: Dictionary = bundle.duplicate(true)
		broken.backpack.items.clear()
		assert_false(coordinator.validate_selected_build_bundle(broken), "Active books require actual placement")
		broken = bundle.duplicate(true)
		broken.equipment.equipped_slots.melee = "gear_missing"
		assert_false(coordinator.validate_selected_build_bundle(broken))
		broken = bundle.duplicate(true)
		broken.backpack.erase("catalog_contract")
		assert_false(coordinator.validate_selected_build_bundle(broken))
		broken = bundle.duplicate(true)
		broken.access.unlocked_ninjutsu_school_ids.append("invalid_school")
		assert_false(coordinator.validate_selected_build_bundle(broken))
		broken = bundle.duplicate(true)
		broken.loadout.origin_school_id = "guiin" if school != &"guiin" else "bongma"
		assert_false(coordinator.validate_selected_build_bundle(broken), "Access and loadout share one starting school")
		broken = bundle.duplicate(true)
		broken.backpack.catalog_contract = {}
		assert_false(coordinator.validate_selected_build_bundle(broken))

const BACKPACK = preload("res://scripts/backpack/backpack_state.gd")
const RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const LEGACY = preload("res://scripts/data/mvp4_catalog.gd")
const BOOK_PATH := "res://scripts/data/ninjutsu_book_catalog.gd"
const SESSION_PATH := "res://scripts/core/start_loadout_session.gd"


func test_book_geometry_is_opt_in_and_survives_copy_and_json() -> void:
	var factory = BACKPACK.new()
	assert_true(factory.has_method("create_selectable_starting_state"), "New books must use an explicit geometry catalog, not leak into legacy rewards.")
	if not factory.has_method("create_selectable_starting_state"):
		return
	var state = factory.create_selectable_starting_state()
	var id: int = state.add_item(&"start_book:bongma_guardian_ward", Vector2i(1, 1))
	assert_gt(id, 0)
	assert_eq(state.get_active_cells().size(), 9)
	assert_eq(state.add_item(&"katana", Vector2i(2, 1)), 0, "Equipment has no backpack representation in the new mode.")
	assert_eq(state.add_item(&"book:cheonsul_ice_veil", Vector2i(1, 2)), 0, "Second cell collision must reject the entire placement.")
	assert_eq(state.add_item(&"book:cheonsul_ice_veil", Vector2i(3, 3)), 0)
	assert_gt(state.add_item(&"book:cheonsul_ice_veil", Vector2i(2, 1)), 0)
	var defs: Dictionary = load(BOOK_PATH).build_items()
	var result = RESOLVER.new().resolve(state, defs, LEGACY.build_bags(), &"bongma")
	assert_true(result.valid)
	assert_eq(result.item_cells.size(), 2)
	assert_eq(defs[&"start_book:bongma_guardian_ward"].sell_price(), 0)
	assert_eq(defs[&"book:cheonsul_ice_veil"].sell_price(), 20)
	var copied = state.copy_value()
	assert_true(copied.move_item(id, Vector2i(1, 2)))
	assert_eq(state.get_item(id).origin, Vector2i(1, 1))
	var raw: Dictionary = JSON.parse_string(JSON.stringify(state.to_persistent_snapshot()))
	var restored = BACKPACK.from_persistent_snapshot(raw)
	assert_not_null(restored)
	if restored != null:
		assert_eq(restored.to_persistent_snapshot(), state.to_persistent_snapshot())
		assert_eq(restored.add_item(&"katana", Vector2i(3, 1)), 0)
	raw.erase("catalog_contract")
	assert_null(BACKPACK.from_persistent_snapshot(raw), "New books cannot be restored with an omitted catalog contract.")
	raw["catalog_contract"] = "future-unknown"
	assert_null(BACKPACK.from_persistent_snapshot(raw))
	var legacy = factory.create_starting_state()
	assert_eq(legacy.add_item(&"book:cheonsul_ice_veil", Vector2i(1, 1)), 0)
	assert_gt(legacy.add_item(&"katana", Vector2i(1, 1)), 0)
	assert_false(legacy.to_persistent_snapshot().has("catalog_contract"))


func test_start_session_commits_only_two_placed_books_and_external_equipment() -> void:
	assert_true(ResourceLoader.exists(SESSION_PATH), "Start selection needs a real placement-backed session.")
	if not ResourceLoader.exists(SESSION_PATH):
		return
	var session = load(SESSION_PATH).new()
	add_child_autofree(session)
	assert_true(session.begin(&"bongma", 123))
	assert_true(session.committed_snapshot().is_empty())
	assert_false(session.confirm())
	var first: Dictionary = session.snapshot()
	assert_false(session.choose(&"unknown"))
	assert_eq(session.snapshot(), first)
	assert_true(session.choose(first.draft.options[0]))
	var second: Dictionary = session.snapshot()
	assert_false(second.draft.options.has(first.draft.options[0]))
	assert_true(session.choose(second.draft.options[0]))
	var preview: Dictionary = session.snapshot()
	assert_eq(preview.backpack.items.size(), 2)
	assert_eq(preview.active_spell_ids.size(), 0)
	var book_id: int = preview.backpack.items[0].instance_id
	assert_false(session.move_book(book_id, Vector2i(5, 5)))
	assert_false(session.rotate_book(book_id), "Adjacent default books block rotation without partial mutation.")
	assert_eq(session.snapshot(), preview)
	assert_true(session.move_book(book_id, Vector2i(3, 1)))
	assert_true(session.confirm())
	var committed: Dictionary = session.committed_snapshot()
	assert_eq(committed.loadout.active_spell_ids.size(), 2)
	assert_eq(committed.backpack.items.size(), 2)
	assert_eq(committed.equipment.equipped_slots, {"melee": "gear_katana", "projectile": "gear_shuriken", "outfit": "gear_ninja_suit"})
	assert_false(session.confirm())
	assert_false(session.move_book(book_id, Vector2i(1, 1)))
	assert_false(session.restart_choices())
	assert_false(session.cancel())
	committed.equipment.equipped_slots.clear()
	committed.backpack.items.clear()
	assert_eq(session.committed_snapshot().backpack.items.size(), 2)
	assert_eq(session.committed_snapshot().equipment.equipped_slots.size(), 3)
	var exposed: Dictionary = session.snapshot()
	exposed.draft.picks.clear()
	exposed.active_spell_ids.clear()
	assert_eq(session.snapshot().draft.picks.size(), 2)
	assert_eq(session.snapshot().active_spell_ids.size(), 2)


func test_cancel_and_restart_do_not_keep_picks_or_power() -> void:
	if not ResourceLoader.exists(SESSION_PATH):
		assert_true(false, "Missing start session")
		return
	var session = load(SESSION_PATH).new()
	add_child_autofree(session)
	assert_false(session.begin(&"unknown", 0))
	assert_true(session.begin(&"cheonsul", 15))
	var first: Dictionary = session.snapshot()
	assert_true(session.choose(first.draft.options[0]))
	assert_true(session.restart_choices())
	assert_eq(session.snapshot(), first, "Restart must preserve the seeded offers, not become a free reroll.")
	assert_true(session.cancel())
	assert_true(session.snapshot().is_empty())
	assert_true(session.committed_snapshot().is_empty())
	assert_false(session.confirm())
	assert_true(session.begin(&"guiin", 1))


func test_all_sixty_start_pairs_occupy_four_cells_and_commit_once() -> void:
	var total := 0
	for school in [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]:
		var reached: Dictionary = {}
		for seed_value in range(512):
			var session = load(SESSION_PATH).new()
			assert_true(session.begin(school, seed_value))
			assert_true(session.choose(session.snapshot().draft.options[0]))
			assert_true(session.choose(session.snapshot().draft.options[0]))
			var picks: Array = session.snapshot().draft.picks
			picks.sort()
			var key := str(picks)
			if not reached.has(key):
				var state = BACKPACK.from_persistent_snapshot(session.snapshot().backpack)
				var result = RESOLVER.new().resolve(state, load(BOOK_PATH).build_items(), LEGACY.build_bags(), school)
				assert_true(result.valid)
				var cells: Dictionary = {}
				for footprint in result.item_cells.values():
					for cell in footprint:
						cells[cell] = true
				assert_eq(cells.size(), 4)
				assert_eq(result.active_cells.size(), 9)
				assert_true(session.confirm())
				assert_false(session.confirm())
				reached[key] = true
			session.free()
			if reached.size() == 15:
				break
		assert_eq(reached.size(), 15)
		total += reached.size()
	assert_eq(total, 60)
