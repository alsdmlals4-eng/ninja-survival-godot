extends GutTest

const CATALOG_PATH := "res://scripts/data/encounter_catalog.gd"
const SCHOOL_DEF_PATH := "res://scripts/data/school_encounter_definition.gd"
const STAGE_PROFILE_PATH := "res://scripts/data/stage_encounter_profile.gd"
const PATTERN_DEF_PATH := "res://scripts/data/encounter_pattern_definition.gd"

const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const PRIMITIVE_IDS: Array[StringName] = [
	&"chase_contact",
	&"line_dash",
	&"fan_or_arc_projectile",
	&"telegraphed_zone",
	&"summon_or_proxy",
	&"mark_or_link",
	&"pulse_or_ring",
	&"barrier_or_lane",
]
const CHEONSUL_FIRST_SLICE_PATTERNS: Array[StringName] = [
	&"fan_or_arc_projectile",
	&"telegraphed_zone",
	&"mark_or_link",
]


func test_t09_resources_exist() -> void:
	for path in [CATALOG_PATH, SCHOOL_DEF_PATH, STAGE_PROFILE_PATH, PATTERN_DEF_PATH]:
		assert_true(ResourceLoader.exists(path), "Missing T09 resource: %s" % path)


func test_catalog_exposes_exact_canonical_primitive_vocabulary_and_cheonsul_first_slice() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	assert_eq(catalog.supported_primitive_ids(), PRIMITIVE_IDS)
	assert_eq(catalog.first_slice_school_id(), &"cheonsul")
	assert_eq(catalog.first_slice_pattern_ids(), CHEONSUL_FIRST_SLICE_PATTERNS)


func test_four_school_definitions_have_exact_core_elite_boss_and_pattern_refs() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	var schools: Dictionary = catalog.build_school_encounters()
	assert_eq(schools.size(), 4)
	assert_eq(_sorted_string_names(schools.keys()), _sorted_string_names(SCHOOL_IDS))

	_assert_school(
		schools[&"bongma"],
		[&"seal_chaser", &"shikigami_handler", &"barrier_carrier"],
		&"mobile_array_caster",
		&"hundred_demon_array_master",
		[&"chase_contact", &"telegraphed_zone", &"summon_or_proxy", &"barrier_or_lane"],
		&"triple_mobile_seal_array"
	)
	_assert_school(
		schools[&"cheonsul"],
		[&"fire_mark_caster", &"water_vein_caster", &"lightning_chain_caster"],
		&"five_element_tuner",
		&"heavenly_change_taoist",
		CHEONSUL_FIRST_SLICE_PATTERNS,
		&"chained_five_element_shift"
	)
	_assert_school(
		schools[&"guiin"],
		[&"surge_fighter", &"pressure_monk", &"ghost_blood_chaser"],
		&"melee_chaos_captain",
		&"ghost_general",
		[&"line_dash", &"pulse_or_ring", &"chase_contact"],
		&"chained_ghost_blood_rush"
	)
	_assert_school(
		schools[&"heukyeong"],
		[&"shuriken_scout", &"poison_shadow_assassin", &"dark_mark_pursuer"],
		&"shadow_chief",
		&"night_executioner",
		[&"fan_or_arc_projectile", &"telegraphed_zone", &"mark_or_link", &"summon_or_proxy"],
		&"triple_shadow_execution_line"
	)


func test_stage_profiles_are_four_shared_profiles_not_sixteen_school_stage_copies() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	var profiles: Dictionary = catalog.build_stage_profiles()
	assert_eq(profiles.size(), 4)
	for stage_index in range(1, 5):
		assert_true(profiles.has(stage_index))
		var profile = profiles[stage_index]
		assert_eq(profile.stage_index, stage_index)
		assert_almost_eq(profile.density_multiplier, 1.0, 0.001, "T09 keeps density neutral until later tuning evidence")
		assert_almost_eq(profile.stat_multiplier, 1.0, 0.001, "T09 keeps stats neutral until later tuning evidence")
		assert_eq(profile.pattern_depth_tier, stage_index)
		assert_eq(profile.max_concurrent_advanced_gimmicks, 1 if stage_index <= 2 else 2)
		assert_eq(profile.boss_capstone_enabled, stage_index == 4)


func test_cheonsul_first_slice_patterns_encode_fairness_without_inventing_timing_seconds() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	var patterns: Dictionary = catalog.build_first_slice_patterns()
	assert_eq(patterns.size(), 3)
	assert_eq(_sorted_string_names(patterns.keys()), _sorted_string_names(CHEONSUL_FIRST_SLICE_PATTERNS))

	var fan = patterns[&"fan_or_arc_projectile"]
	assert_true(fan.telegraph_parameters.get("anticipation_required", false))
	assert_true(fan.telegraph_parameters.get("readable_origin", false))
	assert_true(fan.telegraph_parameters.get("readable_direction", false))
	assert_false(fan.telegraph_parameters.has("warning_seconds"), "Release-near human QA owns exact warning duration")

	var zone = patterns[&"telegraphed_zone"]
	assert_true(zone.telegraph_parameters.get("visible_boundary", false))
	assert_true(zone.telegraph_parameters.get("expiry_cue", false))
	assert_false(zone.telegraph_parameters.has("warning_seconds"))

	var mark = patterns[&"mark_or_link"]
	assert_true(mark.telegraph_parameters.get("visible_ownership", false))
	assert_true(mark.telegraph_parameters.get("release_cue", false))
	assert_false(mark.telegraph_parameters.get("hidden_target_selection", true))
	assert_false(mark.telegraph_parameters.has("warning_seconds"))


func test_first_slice_pattern_definitions_keep_execution_and_presentation_data_separate() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	var patterns: Dictionary = catalog.build_first_slice_patterns()
	for primitive_id in CHEONSUL_FIRST_SLICE_PATTERNS:
		var definition = patterns[primitive_id]
		assert_eq(definition.primitive_id, primitive_id)
		assert_false(definition.execution_parameters.is_empty())
		assert_true(definition.presentation_hooks.has(&"cheonsul"))
		assert_true(definition.tags.size() > 0)


func test_catalog_validation_is_clean_for_approved_t09_data() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	assert_eq(catalog.validate_catalog(), [])


func test_stage_profile_validation_rejects_out_of_range_concurrency_and_capstone_mismatch() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	var profiles: Dictionary = catalog.build_stage_profiles()
	profiles[2].max_concurrent_advanced_gimmicks = 3
	assert_true(_contains_fragment(catalog.validate_stage_profiles(profiles), "concurrency"))

	profiles = catalog.build_stage_profiles()
	profiles[3].boss_capstone_enabled = true
	assert_true(_contains_fragment(catalog.validate_stage_profiles(profiles), "capstone"))

	profiles = catalog.build_stage_profiles()
	profiles[4].stage_index = 5
	assert_true(_contains_fragment(catalog.validate_stage_profiles(profiles), "stage"))


func test_school_validation_rejects_unknown_school_duplicate_core_and_unknown_primitive_ref() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	var schools: Dictionary = catalog.build_school_encounters()
	schools[&"cheonsul"].school_id = &"missing"
	assert_true(_contains_fragment(catalog.validate_school_encounters(schools), "school"))

	schools = catalog.build_school_encounters()
	schools[&"bongma"].core_monster_ids[1] = schools[&"bongma"].core_monster_ids[0]
	assert_true(_contains_fragment(catalog.validate_school_encounters(schools), "core"))

	schools = catalog.build_school_encounters()
	schools[&"guiin"].pattern_refs.append(&"missing_primitive")
	assert_true(_contains_fragment(catalog.validate_school_encounters(schools), "primitive"))


func test_build_calls_return_independent_resources_and_collections() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	var schools_a: Dictionary = catalog.build_school_encounters()
	var schools_b: Dictionary = catalog.build_school_encounters()
	schools_a[&"cheonsul"].core_monster_ids.clear()
	schools_a.erase(&"bongma")
	assert_eq(schools_b.size(), 4)
	assert_eq(schools_b[&"cheonsul"].core_monster_ids.size(), 3)

	var profiles_a: Dictionary = catalog.build_stage_profiles()
	var profiles_b: Dictionary = catalog.build_stage_profiles()
	profiles_a[4].boss_capstone_enabled = false
	assert_true(profiles_b[4].boss_capstone_enabled)

	var patterns_a: Dictionary = catalog.build_first_slice_patterns()
	var patterns_b: Dictionary = catalog.build_first_slice_patterns()
	patterns_a[&"mark_or_link"].telegraph_parameters["hidden_target_selection"] = true
	assert_false(patterns_b[&"mark_or_link"].telegraph_parameters["hidden_target_selection"])


func _catalog():
	if not ResourceLoader.exists(CATALOG_PATH):
		return null
	return load(CATALOG_PATH)


func _assert_school(definition, core_ids: Array[StringName], elite_id: StringName, boss_id: StringName, pattern_refs: Array[StringName], capstone_id: StringName) -> void:
	assert_not_null(definition)
	if definition == null:
		return
	assert_eq(definition.core_monster_ids, core_ids)
	assert_eq(definition.core_monster_ids.size(), 3)
	assert_eq(definition.elite_id, elite_id)
	assert_eq(definition.boss_id, boss_id)
	assert_eq(definition.pattern_refs, pattern_refs)
	assert_eq(definition.stage4_boss_capstone_id, capstone_id)


func _sorted_string_names(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		result.append(StringName(value))
	result.sort_custom(func(a, b): return str(a) < str(b))
	return result


func _contains_fragment(errors: Array, fragment: String) -> bool:
	for error in errors:
		if str(error).to_lower().contains(fragment.to_lower()):
			return true
	return false
