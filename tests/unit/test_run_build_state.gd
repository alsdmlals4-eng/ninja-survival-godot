extends GutTest

const STATE_PATH := "res://scripts/core/run_build_state.gd"
const CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MODIFIER_PATH := "res://scripts/data/run_modifier_set.gd"


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


func test_committed_fortune_modifier_uses_fractional_normal_kill_gold_carry() -> void:
	var state = _new_state()
	if state == null:
		return
	var committed = load(MODIFIER_PATH).new()
	committed.normal_kill_gold_pct = 0.25
	state.set_committed_backpack_modifiers(committed)
	var before: int = int(state.gold)
	for _i in range(4):
		state.grant_normal_kill_gold()
	assert_eq(state.gold - before, 5)
	assert_eq(state.grant_boss_gold(), 25)

	committed.normal_kill_gold_pct = 0.50
	state.set_committed_backpack_modifiers(committed)
	before = int(state.gold)
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
	var gold_before: int = int(state.gold)
	assert_false(state.buy_item(&"taijutsu_training"))
	assert_eq(state.item_count(&"taijutsu_training"), 2)
	assert_eq(state.gold, gold_before)

	for item_id in [&"protection_talisman", &"fortune_talisman", &"ninjutsu_training", &"enlightenment"]:
		assert_true(state.buy_item(item_id))
	assert_eq(state.total_item_count(), 6)
	gold_before = int(state.gold)
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


func test_sale_refunds_half_without_becoming_modifier_authority() -> void:
	var state = _new_state()
	if state == null:
		return
	state.grant_gold(100)
	assert_true(state.buy_item(&"taijutsu_training"))
	assert_true(state.buy_item(&"taijutsu_training"))
	assert_almost_eq(state.get_modifiers().move_speed_pct, 0.0, 0.001)
	var before_sale: int = int(state.gold)
	assert_true(state.sell_item(&"taijutsu_training"))
	assert_eq(state.gold - before_sale, 10)
	assert_eq(state.item_count(&"taijutsu_training"), 1)
	assert_almost_eq(state.get_modifiers().move_speed_pct, 0.0, 0.001)
	before_sale = int(state.gold)
	assert_false(state.sell_item(&"missing"))
	assert_eq(state.gold, before_sale)


func test_committed_backpack_snapshot_is_single_item_modifier_authority() -> void:
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
	var before_commit = state.get_modifiers()
	assert_almost_eq(before_commit.max_health_flat, 0.0, 0.001)
	assert_almost_eq(before_commit.normal_kill_gold_pct, 0.0, 0.001)
	assert_almost_eq(before_commit.school_damage_pct, 0.0, 0.001)

	var committed = load(MODIFIER_PATH).new()
	committed.max_health_flat = 20.0
	committed.normal_kill_gold_pct = 0.25
	committed.school_damage_pct = 0.12
	committed.school_resource_gain_pct = 0.20
	committed.rest_start_heal_pct = 0.20
	committed.ultimate_charge_gain_pct = 0.25
	state.set_committed_backpack_modifiers(committed)
	var modifiers = state.get_modifiers()
	assert_almost_eq(modifiers.max_health_flat, 20.0, 0.001)
	assert_almost_eq(modifiers.normal_kill_gold_pct, 0.25, 0.001)
	assert_almost_eq(modifiers.school_damage_pct, 0.12, 0.001)
	assert_almost_eq(modifiers.school_resource_gain_pct, 0.20, 0.001)
	assert_almost_eq(modifiers.rest_start_heal_pct, 0.20, 0.001)
	assert_almost_eq(modifiers.ultimate_charge_gain_pct, 0.25, 0.001)


func test_committed_school_modifier_snapshot_is_not_rederived_from_owned_items() -> void:
	var state = _new_state()
	if state == null:
		return
	state.set_selected_school(&"cheonsul")
	state.grant_gold(100)
	assert_true(state.buy_item(&"school_emblem"))
	assert_almost_eq(state.get_modifiers().cheonsul_reaction_damage_pct, 0.0, 0.001)
	var committed = load(MODIFIER_PATH).new()
	committed.cheonsul_reaction_damage_pct = 0.20
	state.set_committed_backpack_modifiers(committed)
	assert_almost_eq(state.get_modifiers().cheonsul_reaction_damage_pct, 0.20, 0.001)


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


func test_committed_backpack_modifiers_and_fate_combine_once() -> void:
	var state = _new_state()
	if state == null:
		return
	var committed = load(MODIFIER_PATH).new()
	committed.school_damage_pct = 0.22
	committed.move_speed_pct = 0.08
	state.set_committed_backpack_modifiers(committed)
	assert_true(state.select_fate(&"slaughter_path"))
	assert_true(state.select_fate(&"shadow_path"))
	var modifiers = state.get_modifiers()
	assert_almost_eq(modifiers.school_damage_pct, 0.42, 0.001)
	assert_almost_eq(modifiers.move_speed_pct, 0.23, 0.001)


func test_heukyeong_converts_committed_and_fate_readiness_after_sum() -> void:
	var state = _new_state()
	if state == null:
		return
	state.set_selected_school(&"heukyeong")
	var committed = load(MODIFIER_PATH).new()
	committed.ultimate_charge_gain_pct = 0.25
	state.set_committed_backpack_modifiers(committed)
	assert_true(state.select_fate(&"seal_path"))
	var modifiers = state.get_modifiers()
	assert_almost_eq(modifiers.ultimate_charge_gain_pct, 0.0, 0.001)
	assert_almost_eq(modifiers.heukyeong_mark_duration_pct, 0.55, 0.001)


func test_committed_snapshot_set_and_get_are_value_isolated() -> void:
	var state = _new_state()
	if state == null:
		return
	var source = load(MODIFIER_PATH).new()
	source.school_damage_pct = 0.20
	state.set_committed_backpack_modifiers(source)
	source.school_damage_pct = 99.0
	assert_almost_eq(state.get_modifiers().school_damage_pct, 0.20, 0.001)
	var fetched = state.get_committed_backpack_modifiers()
	fetched.school_damage_pct = 77.0
	assert_almost_eq(state.get_committed_backpack_modifiers().school_damage_pct, 0.20, 0.001)


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
