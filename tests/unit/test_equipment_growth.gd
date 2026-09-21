extends GutTest

const GEAR = preload("res://scripts/core/equipment_loadout_state.gd")
const ACCESS = preload("res://scripts/core/tradition_access_state.gd")

func test_school_imbuement_is_not_a_numeric_upgrade() -> void:
	for school in [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]:
		for slot in [&"melee", &"projectile", &"outfit"]:
			var gear = GEAR.new()
			assert_true(gear.has_method("imbue_equipped"), "Missing independent school power owner")
			if not gear.has_method("imbue_equipped"): return
			assert_true(gear.imbue_equipped(school, slot))
			var state: Dictionary = gear.get_snapshot()
			assert_eq(state.upgrade_rank_by_instance[state.equipped_slots[str(slot)]], 0)
			assert_eq(gear.equipped_imbuements(slot), [String(school)])
			assert_false(gear.imbue_equipped(school, slot))
			assert_false(gear.imbue_equipped(school, &"outfit" if slot != &"outfit" else &"melee"))
			assert_eq(gear.get_snapshot(), state)

func test_trace_grants_power_and_keeps_starting_books_access() -> void:
	var gear = GEAR.new()
	var access = ACCESS.new()
	assert_true(access.initialize_selected(&"guiin"))
	assert_true(access.stabilize_school(&"guiin"))
	assert_true(access.decide_trace(&"guiin", &"enhance", gear, &"melee", 0))
	assert_eq(gear.get_snapshot().upgrade_rank_by_instance.gear_katana, 0)
	assert_eq(access.get_snapshot().trace_decisions[&"guiin"],
		{"choice": "enhance", "equipment_instance": "gear_katana", "imbuement": "guiin"})
	assert_eq(access.unlocked_ninjutsu_school_ids(), [&"guiin"])

func test_old_numeric_save_keeps_rank_without_inventing_school_power() -> void:
	var gear = GEAR.new()
	gear.upgrade_equipped(&"melee")
	var old: Dictionary = gear.get_snapshot()
	old.erase("imbuements")
	var restored = GEAR.new()
	assert_true(restored.restore_snapshot(JSON.parse_string(JSON.stringify(old))))
	assert_almost_eq(restored.equipped_damage_bonus(&"melee"), 0.15, 0.00001)
	assert_true(restored.has_method("equipped_imbuements"))
	if restored.has_method("equipped_imbuements"):
		assert_eq(restored.equipped_imbuements(&"melee"), [])

func test_imbuements_follow_the_instance_and_disappear_when_sold() -> void:
	var gear = GEAR.new()
	assert_true(gear.has_method("imbue_equipped"))
	if not gear.has_method("imbue_equipped"): return
	gear.imbue_equipped(&"guiin", &"melee")
	gear.acquire(&"naginata")
	gear.equip(&"melee", &"naginata")
	assert_eq(gear.equipped_imbuements(&"melee"), [])
	gear.equip(&"melee", &"katana")
	assert_eq(gear.equipped_imbuements(&"melee"), ["guiin"])
	gear.equip(&"melee", &"naginata")
	assert_eq(gear.sell(&"katana"), 0)
	assert_false(gear.get_snapshot().imbuements.has("gear_katana"))
	assert_true(GEAR.is_valid_snapshot(gear.get_snapshot()))

func test_invalid_imbuement_snapshots_are_rejected_without_mutation() -> void:
	var gear = GEAR.new()
	var before: Dictionary = gear.get_snapshot()
	for powers in [{"gear_katana": ["missing"]}, {"gear_missing": ["guiin"]},
		{"gear_katana": ["guiin", "guiin"]}, {"gear_katana": ["guiin"], "gear_shuriken": ["guiin"]},
		{"gear_katana": "guiin"}]:
		var bad := before.duplicate(true)
		bad.imbuements = powers
		assert_false(gear.restore_snapshot(bad))
		assert_eq(gear.get_snapshot(), before)

func test_forging_failure_preserves_rank_and_powers_but_reports_price() -> void:
	var gear = GEAR.new()
	assert_true(gear.has_method("forge_equipped"))
	if not gear.has_method("forge_equipped"): return
	gear.imbue_equipped(&"guiin", &"melee")
	var before: Dictionary = gear.get_snapshot()
	var quote: Dictionary = gear.forge_quote(&"melee")
	assert_eq(int(quote.cost), 20)
	assert_eq(int(quote.chance_percent), 80)
	var failed: Dictionary = gear.forge_equipped(&"melee", 0.9)
	assert_true(failed.ok)
	assert_false(failed.succeeded)
	assert_eq(int(failed.cost), 20)
	assert_eq(gear.get_snapshot(), before)
	var success: Dictionary = gear.forge_equipped(&"melee", 0.0)
	assert_true(success.ok and success.succeeded)
	assert_eq(gear.get_snapshot().upgrade_rank_by_instance.gear_katana, 1)
	assert_eq(gear.equipped_imbuements(&"melee"), ["guiin"])
	assert_eq(int(gear.forge_quote(&"melee").cost), 35)

func test_forging_caps_and_invalid_rolls_do_not_modify_equipment() -> void:
	var gear = GEAR.new()
	assert_true(gear.has_method("forge_equipped"))
	if not gear.has_method("forge_equipped"): return
	for invalid in [-0.1, 1.0, INF, NAN]:
		assert_false(gear.forge_equipped(&"melee", invalid).ok)
	assert_false(gear.forge_equipped(&"unknown", 0.0).ok)
	for unused in range(4): assert_true(gear.forge_equipped(&"outfit", 0.0).succeeded)
	var capped: Dictionary = gear.get_snapshot()
	assert_false(gear.forge_quote(&"outfit").ok)
	assert_false(gear.forge_equipped(&"outfit", 0.0).ok)
	assert_eq(gear.get_snapshot(), capped)

func test_selected_bundle_rejects_unearned_or_misbound_school_powers() -> void:
	var start = add_child_autofree(load("res://scripts/core/start_loadout_session.gd").new())
	start.begin(&"bongma", 42)
	for unused in range(2): start.choose(start.snapshot().draft.options[0])
	assert_true(start.confirm())
	var bundle: Dictionary = start.committed_snapshot()
	bundle.equipment.imbuements = {"gear_katana": ["guiin"]}
	assert_false(RestCommitCoordinator.validate_selected_build_bundle(bundle), "No trace means no school power")
	var access = ACCESS.new()
	access.restore_selected_snapshot(bundle.access)
	access.stabilize_school(&"guiin")
	var gear = GEAR.new()
	access.decide_trace(&"guiin", &"enhance", gear, &"projectile", 0)
	bundle.access = access.get_snapshot()
	assert_false(RestCommitCoordinator.validate_selected_build_bundle(bundle), "Trace cannot bind power to a different instance")
	bundle.equipment = gear.get_snapshot()
	assert_true(RestCommitCoordinator.validate_selected_build_bundle(bundle))
