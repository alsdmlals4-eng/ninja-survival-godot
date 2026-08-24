extends GutTest

const STATE_PATH := "res://scripts/core/run_build_state.gd"
const CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"


func test_legacy_inventory_mutations_never_change_committed_combat_snapshot() -> void:
	var state = _new_state()
	state.grant_gold(100)
	var committed = load(MODIFIER_PATH).new()
	committed.move_speed_pct = 0.07
	state.set_committed_backpack_modifiers(committed)
	assert_true(state.buy_item(&"taijutsu_training"))
	assert_true(state.buy_item(&"taijutsu_training"))
	assert_almost_eq(state.get_modifiers().move_speed_pct, 0.07, 0.001)
	assert_true(state.sell_item(&"taijutsu_training"))
	assert_almost_eq(state.get_modifiers().move_speed_pct, 0.07, 0.001)


func test_new_committed_snapshot_replaces_instead_of_accumulating_old_snapshot() -> void:
	var state = _new_state()
	var first = load(MODIFIER_PATH).new()
	first.school_damage_pct = 0.20
	first.move_speed_pct = 0.10
	state.set_committed_backpack_modifiers(first)
	var second = load(MODIFIER_PATH).new()
	second.school_damage_pct = 0.05
	state.set_committed_backpack_modifiers(second)
	var modifiers = state.get_modifiers()
	assert_almost_eq(modifiers.school_damage_pct, 0.05, 0.001)
	assert_almost_eq(modifiers.move_speed_pct, 0.0, 0.001)


func test_null_committed_snapshot_resets_item_power_but_keeps_fate_power() -> void:
	var state = _new_state()
	var committed = load(MODIFIER_PATH).new()
	committed.school_damage_pct = 0.12
	state.set_committed_backpack_modifiers(committed)
	assert_true(state.select_fate(&"slaughter_path"))
	assert_almost_eq(state.get_modifiers().school_damage_pct, 0.32, 0.001)
	state.set_committed_backpack_modifiers(null)
	assert_almost_eq(state.get_modifiers().school_damage_pct, 0.20, 0.001)
	assert_almost_eq(state.get_committed_backpack_modifiers().school_damage_pct, 0.0, 0.001)


func test_school_post_processing_never_mutates_stored_committed_snapshot() -> void:
	var state = _new_state()
	var committed = load(MODIFIER_PATH).new()
	committed.ultimate_charge_gain_pct = 0.25
	state.set_committed_backpack_modifiers(committed)
	state.set_selected_school(&"heukyeong")
	assert_almost_eq(state.get_modifiers().ultimate_charge_gain_pct, 0.0, 0.001)
	assert_almost_eq(state.get_modifiers().heukyeong_mark_duration_pct, 0.25, 0.001)
	assert_almost_eq(state.get_committed_backpack_modifiers().ultimate_charge_gain_pct, 0.25, 0.001)
	assert_almost_eq(state.get_committed_backpack_modifiers().heukyeong_mark_duration_pct, 0.0, 0.001)
	state.set_selected_school(&"bongma")
	assert_almost_eq(state.get_modifiers().ultimate_charge_gain_pct, 0.25, 0.001)
	assert_almost_eq(state.get_modifiers().heukyeong_mark_duration_pct, 0.0, 0.001)


func test_final_clamps_do_not_mutate_raw_committed_snapshot() -> void:
	var state = _new_state()
	var committed = load(MODIFIER_PATH).new()
	committed.evasion_chance = 0.90
	committed.heukyeong_marked_crit_bonus = 0.95
	state.set_committed_backpack_modifiers(committed)
	assert_true(state.select_fate(&"shadow_path"))
	var final_modifiers = state.get_modifiers()
	assert_almost_eq(final_modifiers.evasion_chance, 0.95, 0.001)
	assert_almost_eq(final_modifiers.heukyeong_marked_crit_bonus, 0.95, 0.001)
	var raw = state.get_committed_backpack_modifiers()
	assert_almost_eq(raw.evasion_chance, 0.90, 0.001)
	assert_almost_eq(raw.heukyeong_marked_crit_bonus, 0.95, 0.001)


func _new_state():
	var state = load(STATE_PATH).new()
	add_child_autofree(state)
	var catalog = load(CATALOG_PATH)
	state.configure(catalog.build_items(), catalog.build_fates())
	return state
