extends GutTest

const STATE_PATH := "res://scripts/core/run_build_state.gd"
const CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"


func test_run_build_state_resource_exists() -> void:
	assert_true(ResourceLoader.exists(STATE_PATH), "Missing MVP-3 run build state")


func test_gold_grants_spends_and_boss_reward_are_atomic() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_eq(state.gold, 0)
	assert_eq(state.grant_gold(-5), 0)
	assert_eq(state.gold, 0)
	assert_false(state.try_spend_gold(1))
	assert_eq(state.gold, 0)
	assert_eq(state.grant_normal_kill_gold(), 1)
	assert_eq(state.gold, 1)
	assert_eq(state.grant_boss_gold(), 25)
	assert_eq(state.gold, 26)
	assert_true(state.try_spend_gold(20))
	assert_eq(state.gold, 6)


func test_fortune_talisman_uses_fractional_normal_kill_gold_carry() -> void:
	var state = _new_state()
	if state == null:
		return
	state.grant_gold(100)
	assert_true(state.buy_item(&"fortune_talisman"))
	var before := state.gold
	for _i in range(4):
		state.grant_normal_kill_gold()
	assert_eq(state.gold - before, 5)
	assert_eq(state.grant_boss_gold(), 25)

	assert_true(state.buy_item(&"fortune_talisman"))
	before = state.gold
	for _i in range(2):
		state.grant_normal_kill_gold()
	assert_eq(state.gold - before, 3)


func test_inventory_caps_and_failed_buy_are_atomic() -> void:
	var state = _new_state()
	if state == null:
		return
	state.grant_gold(1000)
	assert_true(state.buy_item(&"taijutsu_training"))
	assert_true(state.buy_item(&"taijutsu_training"))
	var gold_before := state.gold
	assert_false(state.buy_item(&"taijutsu_training"))
	assert_eq(state.item_count(&"taijutsu_training"), 2)
	assert_eq(state.gold, gold_before)

	for item_id in [&"protection_talisman", &"fortune_talisman", &"ninjutsu_training", &"enlightenment"]:
		assert_true(state.buy_item(item_id))
	assert_eq(state.total_item_count(), 6)
	gold_before = state.gold
	assert_false(state.buy_item(&"regeneration_scroll"))
	assert_eq(state.total_item_count(), 6)
	assert_eq(state.gold, gold_before)


func test_insufficient_gold_and_unknown_item_do_not_mutate_inventory() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_false(state.buy_item(&"taijutsu_training"))
	assert_false(state.buy_item(&"missing"))
	assert_eq(state.gold, 0)
	assert_eq(state.total_item_count(), 0)


func test_sale_refunds_half_and_recomputes_item_modifier() -> void:
	var state = _new_state()
	if state == null:
		return
	state.grant_gold(100)
	assert_true(state.buy_item(&"taijutsu_training"))
	assert_true(state.buy_item(&"taijutsu_training"))
	assert_almost_eq(state.get_modifiers().move_speed_pct, 0.20, 0.001)
	var before_sale := state.gold
	assert_true(state.sell_item(&"taijutsu_training"))
	assert_eq(state.gold - before_sale, 10)
	assert_eq(state.item_count(&"taijutsu_training"), 1)
	assert_almost_eq(state.get_modifiers().move_speed_pct, 0.10, 0.001)
	before_sale = state.gold
	assert_false(state.sell_item(&"missing"))
	assert_eq(state.gold, before_sale)


func test_all_basic_item_modifiers_recompute_from_owned_sources() -> void:
	var state = _new_state()
	if state == null:
		return
	state.grant_gold(1000)
	for item_id in [
		&"protection_talisman",
		&"fortune_talisman",
		&"ninjutsu_training",
		&"enlightenment",
		&"regeneration_scroll",
		&"ultimate_treatise",
	]:
		assert_true(state.buy_item(item_id))
	var modifiers = state.get_modifiers()
	assert_almost_eq(modifiers.max_health_flat, 20.0, 0.001)
	assert_almost_eq(modifiers.normal_kill_gold_pct, 0.25, 0.001)
	assert_almost_eq(modifiers.school_damage_pct, 0.12, 0.001)
	assert_almost_eq(modifiers.school_resource_gain_pct, 0.20, 0.001)
	assert_almost_eq(modifiers.rest_start_heal_pct, 0.20, 0.001)
	assert_almost_eq(modifiers.ultimate_charge_gain_pct, 0.25, 0.001)


func test_school_emblem_maps_to_only_selected_school_channel() -> void:
	var expected := {
		&"bongma": [&"bongma_familiar_interval_pct", -0.15],
		&"cheonsul": [&"cheonsul_reaction_damage_pct", 0.20],
		&"guiin": [&"guiin_melee_radius_pct", 0.15],
		&"heukyeong": [&"heukyeong_marked_crit_bonus", 0.15],
	}
	for school_id in expected.keys():
		var state = _new_state()
		if state == null:
			return
		state.set_selected_school(school_id)
		state.grant_gold(100)
		assert_true(state.buy_item(&"school_emblem"))
		var modifiers = state.get_modifiers()
		var expected_field: StringName = expected[school_id][0]
		assert_almost_eq(float(modifiers.get(expected_field)), float(expected[school_id][1]), 0.001)
		for field_name in [&"bongma_familiar_interval_pct", &"cheonsul_reaction_damage_pct", &"guiin_melee_radius_pct", &"heukyeong_marked_crit_bonus"]:
			if field_name != expected_field:
				assert_almost_eq(float(modifiers.get(field_name)), 0.0, 0.001)


func test_fates_apply_exact_modifiers_and_cannot_repeat() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_true(state.select_fate(&"slaughter_path"))
	assert_true(state.select_fate(&"guardian_path"))
	assert_true(state.select_fate(&"shadow_path"))
	assert_true(state.select_fate(&"forbidden_path"))
	assert_true(state.select_fate(&"seal_path"))
	assert_false(state.select_fate(&"seal_path"))
	assert_true(state.has_fate(&"seal_path"))
	var modifiers = state.get_modifiers()
	assert_almost_eq(modifiers.school_damage_pct, 0.10, 0.001)
	assert_almost_eq(modifiers.healing_pct, -0.10, 0.001)
	assert_almost_eq(modifiers.damage_taken_pct, -0.05, 0.001)
	assert_almost_eq(modifiers.move_speed_pct, 0.15, 0.001)
	assert_almost_eq(modifiers.evasion_chance, 0.10, 0.001)
	assert_almost_eq(modifiers.max_health_pct, -0.15, 0.001)
	assert_almost_eq(modifiers.school_resource_gain_pct, 0.25, 0.001)
	assert_almost_eq(modifiers.school_status_effect_pct, 0.20, 0.001)
	assert_almost_eq(modifiers.ultimate_charge_gain_pct, 0.30, 0.001)
	assert_almost_eq(modifiers.ultimate_power_pct, 0.25, 0.001)
	assert_almost_eq(modifiers.non_ultimate_school_damage_pct, -0.15, 0.001)


func test_heukyeong_converts_readiness_bonus_to_mark_duration_after_sum() -> void:
	var state = _new_state()
	if state == null:
		return
	state.set_selected_school(&"heukyeong")
	state.grant_gold(100)
	assert_true(state.buy_item(&"ultimate_treatise"))
	assert_true(state.select_fate(&"seal_path"))
	var modifiers = state.get_modifiers()
	assert_almost_eq(modifiers.ultimate_charge_gain_pct, 0.0, 0.001)
	assert_almost_eq(modifiers.heukyeong_mark_duration_pct, 0.55, 0.001)


func test_get_modifiers_returns_independent_copy() -> void:
	var state = _new_state()
	if state == null:
		return
	var copy_a = state.get_modifiers()
	copy_a.school_damage_pct = 99.0
	assert_almost_eq(state.get_modifiers().school_damage_pct, 0.0, 0.001)


func _new_state():
	if not ResourceLoader.exists(STATE_PATH):
		return null
	var state = load(STATE_PATH).new()
	add_child_autofree(state)
	var catalog = load(CATALOG_PATH)
	state.configure(catalog.build_items(), catalog.build_fates())
	return state
