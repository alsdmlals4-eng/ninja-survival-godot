extends GutTest

const ACCESS = preload("res://scripts/core/tradition_access_state.gd")
const EQUIPMENT = preload("res://scripts/core/equipment_loadout_state.gd")


func test_restore_rejects_malformed_fields_without_partial_mutation() -> void:
	var access = ACCESS.new()
	access.initialize_selected(&"guiin")
	access.stabilize_school(&"guiin")
	access.decide_trace(&"guiin", &"enhance", EQUIPMENT.new(), &"melee", 0)
	var before: Dictionary = access.get_snapshot()
	var valid: Dictionary = JSON.parse_string(JSON.stringify(before))
	var restored = ACCESS.new()
	assert_true(restored.restore_selected_snapshot(valid))
	for field in ["access_contract", "initialized", "starting_school_id", "stabilized_school_ids", "trace_decisions", "open_school_ids", "unlocked_ninjutsu_school_ids"]:
		var malformed: Dictionary = valid.duplicate(true)
		malformed[field] = null
		assert_false(access.restore_selected_snapshot(malformed), field)
		assert_eq(access.get_snapshot(), before)
	for rank in [-1, 0, 1.5, 5, "1", null, true]:
		var malformed: Dictionary = valid.duplicate(true)
		malformed.trace_decisions.guiin.rank = rank
		assert_false(access.restore_selected_snapshot(malformed))
		assert_eq(access.get_snapshot(), before)
	valid.open_school_ids.append("guiin")
	assert_false(access.restore_selected_snapshot(valid))
	assert_eq(access.get_snapshot(), before)


func test_stabilization_opens_materials_but_only_absorption_unlocks_foreign_books() -> void:
	var access = ACCESS.new()
	assert_true(access.has_method("initialize_selected"))
	if not access.has_method("initialize_selected"):
		return
	assert_true(access.initialize_selected(&"bongma"))
	assert_true(access.stabilize_school(&"cheonsul"))
	assert_true(access.eligible_item_ids().has(&"water_style"))
	assert_false(access.unlocked_ninjutsu_school_ids().has(&"cheonsul"))
	var gear = EQUIPMENT.new()
	assert_true(access.decide_trace(&"cheonsul", &"absorb", gear, &"", 0))
	assert_true(access.unlocked_ninjutsu_school_ids().has(&"cheonsul"))
	assert_eq(gear.get_snapshot().revision, 0)
	assert_false(access.decide_trace(&"cheonsul", &"enhance", gear, &"melee", 0))
	assert_eq(gear.get_snapshot().revision, 0)
	assert_false(access.eligible_item_ids().has(&"katana"))
	assert_true(access.eligible_item_ids().has(&"blast_powder"))


func test_start_trace_keeps_start_access_and_stale_revision_consumes_nothing() -> void:
	var access = ACCESS.new()
	assert_true(access.has_method("initialize_selected"))
	if not access.has_method("initialize_selected"):
		return
	access.initialize_selected(&"guiin")
	var gear = EQUIPMENT.new()
	assert_false(access.decide_trace(&"guiin", &"enhance", gear, &"melee", 0))
	assert_true(access.stabilize_school(&"guiin"))
	assert_false(access.decide_trace(&"guiin", &"absorb", gear, &"", 0))
	var before: Dictionary = access.get_snapshot()
	assert_false(access.decide_trace(&"guiin", &"enhance", gear, &"melee", 3))
	assert_eq(access.get_snapshot(), before)
	assert_true(access.decide_trace(&"guiin", &"enhance", gear, &"melee", 0))
	assert_eq(gear.get_snapshot().upgrade_rank_by_instance.gear_katana, 1)
	assert_true(access.unlocked_ninjutsu_school_ids().has(&"guiin"))
	access.stabilize_school(&"heukyeong")
	assert_true(access.decide_trace(&"heukyeong", &"enhance", gear, &"outfit", 1))
	assert_false(access.unlocked_ninjutsu_school_ids().has(&"heukyeong"))
	assert_true(access.eligible_item_ids().has(&"projectile_manual"), "Forfeiting books does not close common combination materials.")
	assert_eq(gear.get_snapshot().upgrade_rank_by_instance.gear_ninja_suit, 1)


func test_candidate_trace_and_equipment_changes_do_not_mutate_committed_sources() -> void:
	var access = ACCESS.new()
	access.initialize_selected(&"bongma")
	access.stabilize_school(&"guiin")
	assert_true(access.has_method("copy_value"))
	if not access.has_method("copy_value"):
		return
	var candidate = access.copy_value()
	var gear = EQUIPMENT.new()
	var candidate_gear = EQUIPMENT.new()
	candidate_gear.restore_snapshot(gear.get_snapshot())
	assert_true(candidate.decide_trace(&"guiin", &"enhance", candidate_gear, &"projectile", 0))
	assert_true(access.get_snapshot().trace_decisions.is_empty())
	assert_eq(gear.get_snapshot().upgrade_rank_by_instance.gear_shuriken, 0)
	assert_eq(candidate_gear.get_snapshot().upgrade_rank_by_instance.gear_shuriken, 1)
	var hostile: Dictionary = candidate.get_snapshot()
	hostile.trace_decisions.clear()
	assert_false(candidate.get_snapshot().trace_decisions.is_empty())
	var before: Dictionary = candidate_gear.get_snapshot()
	assert_false(candidate.decide_trace(&"guiin", &"enhance", candidate_gear, &"projectile", 1))
	assert_eq(candidate_gear.get_snapshot(), before)


func test_selected_trace_json_restore_derives_access_and_rejects_forged_unlocks() -> void:
	var access = ACCESS.new()
	access.initialize_selected(&"bongma")
	access.stabilize_school(&"cheonsul")
	var gear = EQUIPMENT.new()
	access.decide_trace(&"cheonsul", &"absorb", gear, &"", 0)
	assert_true(access.has_method("restore_selected_snapshot"))
	if not access.has_method("restore_selected_snapshot"):
		return
	var raw: Dictionary = JSON.parse_string(JSON.stringify(access.get_snapshot()))
	var restored = ACCESS.new()
	assert_true(restored.restore_selected_snapshot(raw))
	assert_eq(restored.unlocked_ninjutsu_school_ids(), [&"bongma", &"cheonsul"])
	var before: Dictionary = restored.get_snapshot()
	raw.unlocked_ninjutsu_school_ids.append("guiin")
	assert_false(restored.restore_selected_snapshot(raw))
	assert_eq(restored.get_snapshot(), before)
	raw = JSON.parse_string(JSON.stringify(access.get_snapshot()))
	raw.trace_decisions.cheonsul = {"choice": "enhance", "equipment_instance": "gear_missing", "rank": 1}
	assert_false(restored.restore_selected_snapshot(raw))
	assert_eq(restored.get_snapshot(), before)
