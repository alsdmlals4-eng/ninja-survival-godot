extends GutTest

const ITEM_DEFINITION_PATH := "res://scripts/data/item_definition.gd"
const FATE_DEFINITION_PATH := "res://scripts/data/fate_definition.gd"
const RUN_MODIFIER_SET_PATH := "res://scripts/data/run_modifier_set.gd"
const CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"

const ITEM_IDS := [
	&"taijutsu_training",
	&"protection_talisman",
	&"fortune_talisman",
	&"ninjutsu_training",
	&"enlightenment",
	&"regeneration_scroll",
	&"ultimate_treatise",
	&"school_emblem",
]

const FATE_IDS := [
	&"slaughter_path",
	&"guardian_path",
	&"shadow_path",
	&"forbidden_path",
	&"seal_path",
]

const MODIFIER_FIELDS := [
	&"move_speed_pct",
	&"max_health_flat",
	&"max_health_pct",
	&"damage_taken_pct",
	&"healing_pct",
	&"normal_kill_gold_pct",
	&"school_damage_pct",
	&"non_ultimate_school_damage_pct",
	&"school_resource_gain_pct",
	&"ultimate_charge_gain_pct",
	&"ultimate_power_pct",
	&"school_status_effect_pct",
	&"evasion_chance",
	&"rest_start_heal_pct",
	&"bongma_familiar_interval_pct",
	&"cheonsul_reaction_damage_pct",
	&"guiin_melee_radius_pct",
	&"heukyeong_marked_crit_bonus",
	&"heukyeong_mark_duration_pct",
]


func test_mvp3_data_resources_exist() -> void:
	for path in [ITEM_DEFINITION_PATH, FATE_DEFINITION_PATH, RUN_MODIFIER_SET_PATH, CATALOG_PATH]:
		assert_true(ResourceLoader.exists(path), "Missing MVP-3 data resource: %s" % path)


func test_catalog_has_exact_eight_items_with_stable_ids() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var items: Dictionary = load(CATALOG_PATH).build_items()
	assert_eq(items.size(), 8)
	for item_id in ITEM_IDS:
		assert_true(items.has(item_id), "Missing item id: %s" % item_id)


func test_catalog_item_prices_and_effects_match_approved_design() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var items: Dictionary = load(CATALOG_PATH).build_items()
	assert_eq(items[&"taijutsu_training"].display_name, "체술단련")
	assert_eq(items[&"taijutsu_training"].base_price, 20)
	assert_eq(items[&"taijutsu_training"].effect_kind, &"move_speed_pct")
	assert_almost_eq(items[&"taijutsu_training"].effect_value, 0.10, 0.001)

	assert_eq(items[&"protection_talisman"].display_name, "호신 부적")
	assert_eq(items[&"protection_talisman"].base_price, 20)
	assert_eq(items[&"protection_talisman"].effect_kind, &"max_health_flat")
	assert_almost_eq(items[&"protection_talisman"].effect_value, 20.0, 0.001)

	assert_eq(items[&"fortune_talisman"].base_price, 20)
	assert_eq(items[&"fortune_talisman"].effect_kind, &"normal_kill_gold_pct")
	assert_almost_eq(items[&"fortune_talisman"].effect_value, 0.25, 0.001)

	assert_eq(items[&"ninjutsu_training"].base_price, 30)
	assert_eq(items[&"ninjutsu_training"].effect_kind, &"school_damage_pct")
	assert_almost_eq(items[&"ninjutsu_training"].effect_value, 0.12, 0.001)

	assert_eq(items[&"enlightenment"].base_price, 30)
	assert_eq(items[&"enlightenment"].effect_kind, &"school_resource_gain_pct")
	assert_almost_eq(items[&"enlightenment"].effect_value, 0.20, 0.001)

	assert_eq(items[&"regeneration_scroll"].base_price, 30)
	assert_eq(items[&"regeneration_scroll"].effect_kind, &"rest_start_heal_pct")
	assert_almost_eq(items[&"regeneration_scroll"].effect_value, 0.20, 0.001)

	assert_eq(items[&"ultimate_treatise"].base_price, 40)
	assert_eq(items[&"ultimate_treatise"].effect_kind, &"ultimate_charge_gain_pct")
	assert_almost_eq(items[&"ultimate_treatise"].effect_value, 0.25, 0.001)

	assert_eq(items[&"school_emblem"].base_price, 40)
	assert_eq(items[&"school_emblem"].effect_kind, &"school_emblem")
	assert_almost_eq(items[&"school_emblem"].school_payload[&"bongma"][&"value"], -0.15, 0.001)
	assert_almost_eq(items[&"school_emblem"].school_payload[&"cheonsul"][&"value"], 0.20, 0.001)
	assert_almost_eq(items[&"school_emblem"].school_payload[&"guiin"][&"value"], 0.15, 0.001)
	assert_almost_eq(items[&"school_emblem"].school_payload[&"heukyeong"][&"value"], 0.15, 0.001)


func test_all_item_sell_prices_are_half_of_base_price() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var items: Dictionary = load(CATALOG_PATH).build_items()
	for item_id in ITEM_IDS:
		var item = items[item_id]
		assert_eq(item.sell_price(), item.base_price / 2, "Sell price mismatch: %s" % item_id)


func test_catalog_has_exact_five_fates_with_stable_ids() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var fates: Dictionary = load(CATALOG_PATH).build_fates()
	assert_eq(fates.size(), 5)
	for fate_id in FATE_IDS:
		assert_true(fates.has(fate_id), "Missing fate id: %s" % fate_id)


func test_fate_modifier_values_match_approved_design() -> void:
	if not ResourceLoader.exists(CATALOG_PATH):
		return
	var fates: Dictionary = load(CATALOG_PATH).build_fates()
	assert_almost_eq(fates[&"slaughter_path"].modifiers[&"school_damage_pct"], 0.20, 0.001)
	assert_almost_eq(fates[&"slaughter_path"].modifiers[&"healing_pct"], -0.40, 0.001)

	assert_almost_eq(fates[&"guardian_path"].modifiers[&"damage_taken_pct"], -0.20, 0.001)
	assert_almost_eq(fates[&"guardian_path"].modifiers[&"healing_pct"], 0.30, 0.001)
	assert_almost_eq(fates[&"guardian_path"].modifiers[&"school_damage_pct"], -0.10, 0.001)

	assert_almost_eq(fates[&"shadow_path"].modifiers[&"move_speed_pct"], 0.15, 0.001)
	assert_almost_eq(fates[&"shadow_path"].modifiers[&"evasion_chance"], 0.10, 0.001)
	assert_almost_eq(fates[&"shadow_path"].modifiers[&"max_health_pct"], -0.15, 0.001)

	assert_almost_eq(fates[&"forbidden_path"].modifiers[&"school_resource_gain_pct"], 0.25, 0.001)
	assert_almost_eq(fates[&"forbidden_path"].modifiers[&"school_status_effect_pct"], 0.20, 0.001)
	assert_almost_eq(fates[&"forbidden_path"].modifiers[&"damage_taken_pct"], 0.15, 0.001)

	assert_almost_eq(fates[&"seal_path"].modifiers[&"ultimate_charge_gain_pct"], 0.30, 0.001)
	assert_almost_eq(fates[&"seal_path"].modifiers[&"ultimate_power_pct"], 0.25, 0.001)
	assert_almost_eq(fates[&"seal_path"].modifiers[&"non_ultimate_school_damage_pct"], -0.15, 0.001)


func test_modifier_snapshot_starts_neutral_and_copy_is_independent() -> void:
	if not ResourceLoader.exists(RUN_MODIFIER_SET_PATH):
		return
	var modifiers = load(RUN_MODIFIER_SET_PATH).new()
	for field_name in MODIFIER_FIELDS:
		assert_true(_has_property(modifiers, field_name), "Missing modifier field: %s" % field_name)
		assert_almost_eq(float(modifiers.get(field_name)), 0.0, 0.001, "Non-neutral field: %s" % field_name)
	assert_true(modifiers.has_method("copy_values"))
	if not modifiers.has_method("copy_values"):
		return
	modifiers.school_damage_pct = 0.25
	var copied = modifiers.copy_values()
	assert_almost_eq(copied.school_damage_pct, 0.25, 0.001)
	copied.school_damage_pct = 0.75
	assert_almost_eq(modifiers.school_damage_pct, 0.25, 0.001)


func _has_property(instance: Object, property_name: StringName) -> bool:
	for property in instance.get_property_list():
		if property.name == property_name:
			return true
	return false
