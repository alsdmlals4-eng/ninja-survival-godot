extends GutTest

const CATALOG_PATH := "res://scripts/data/encounter_catalog.gd"
const SCHOOL_DEF_PATH := "res://scripts/data/school_encounter_definition.gd"
const STAGE_PROFILE_PATH := "res://scripts/data/stage_encounter_profile.gd"
const PATTERN_DEF_PATH := "res://scripts/data/encounter_pattern_definition.gd"

const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const FIRST_SLICE_PATTERN_IDS: Array[StringName] = [
	&"fan_or_arc_projectile",
	&"telegraphed_zone",
	&"mark_or_link",
]


func test_fairness_corruption_fails_closed_instead_of_becoming_valid_pattern_data() -> void:
	var catalog = load(CATALOG_PATH)
	var patterns: Dictionary = catalog.build_first_slice_patterns()
	patterns[&"fan_or_arc_projectile"].telegraph_parameters["readable_direction"] = false
	assert_true(_contains_fragment(catalog.validate_first_slice_patterns(patterns), "telegraph"))

	patterns = catalog.build_first_slice_patterns()
	patterns[&"telegraphed_zone"].telegraph_parameters["visible_boundary"] = false
	assert_true(_contains_fragment(catalog.validate_first_slice_patterns(patterns), "telegraph"))

	patterns = catalog.build_first_slice_patterns()
	patterns[&"mark_or_link"].telegraph_parameters["hidden_target_selection"] = true
	assert_true(_contains_fragment(catalog.validate_first_slice_patterns(patterns), "telegraph"))


func test_stage_profiles_reject_nan_infinity_and_non_positive_multipliers() -> void:
	var catalog = load(CATALOG_PATH)
	var profiles: Dictionary = catalog.build_stage_profiles()
	profiles[1].density_multiplier = NAN
	assert_true(_contains_fragment(catalog.validate_stage_profiles(profiles), "multiplier"))

	profiles = catalog.build_stage_profiles()
	profiles[2].stat_multiplier = INF
	assert_true(_contains_fragment(catalog.validate_stage_profiles(profiles), "multiplier"))

	profiles = catalog.build_stage_profiles()
	profiles[3].density_multiplier = 0.0
	assert_true(_contains_fragment(catalog.validate_stage_profiles(profiles), "multiplier"))


func test_school_role_identity_collision_is_rejected() -> void:
	var catalog = load(CATALOG_PATH)
	var schools: Dictionary = catalog.build_school_encounters()
	schools[&"bongma"].elite_id = schools[&"bongma"].core_monster_ids[0]
	assert_true(_contains_fragment(catalog.validate_school_encounters(schools), "identity"))

	schools = catalog.build_school_encounters()
	schools[&"cheonsul"].boss_id = schools[&"cheonsul"].elite_id
	assert_true(_contains_fragment(catalog.validate_school_encounters(schools), "identity"))

	schools = catalog.build_school_encounters()
	schools[&"guiin"].stage4_boss_capstone_id = schools[&"guiin"].boss_id
	assert_true(_contains_fragment(catalog.validate_school_encounters(schools), "identity"))


func test_duplicate_school_pattern_refs_are_rejected() -> void:
	var catalog = load(CATALOG_PATH)
	var schools: Dictionary = catalog.build_school_encounters()
	schools[&"heukyeong"].pattern_refs.append(schools[&"heukyeong"].pattern_refs[0])
	assert_true(_contains_fragment(catalog.validate_school_encounters(schools), "pattern"))


func test_school_and_stage_resources_keep_independent_axes() -> void:
	var school = load(SCHOOL_DEF_PATH).new()
	var stage = load(STAGE_PROFILE_PATH).new()
	assert_false(_has_property(school, &"stage_index"))
	assert_false(_has_property(school, &"density_multiplier"))
	assert_false(_has_property(school, &"stat_multiplier"))
	assert_false(_has_property(stage, &"school_id"))
	assert_false(_has_property(stage, &"core_monster_ids"))
	assert_false(_has_property(stage, &"boss_id"))


func test_first_slice_patterns_do_not_smuggle_unapproved_tuning_numbers_or_extra_primitives() -> void:
	var catalog = load(CATALOG_PATH)
	var patterns: Dictionary = catalog.build_first_slice_patterns()
	assert_eq(_sorted_string_names(patterns.keys()), _sorted_string_names(FIRST_SLICE_PATTERN_IDS))
	for primitive_id in FIRST_SLICE_PATTERN_IDS:
		var definition = patterns[primitive_id]
		for forbidden_key in ["warning_seconds", "damage", "radius", "projectile_speed", "cooldown_seconds"]:
			assert_false(definition.telegraph_parameters.has(forbidden_key), "%s telegraph invented tuning key %s" % [primitive_id, forbidden_key])
			assert_false(definition.execution_parameters.has(forbidden_key), "%s execution invented tuning key %s" % [primitive_id, forbidden_key])


func test_resource_copy_values_are_deeply_isolated() -> void:
	var catalog = load(CATALOG_PATH)
	var school = catalog.build_school_encounters()[&"cheonsul"]
	var school_copy = school.copy_value()
	school_copy.core_monster_ids.clear()
	school_copy.pattern_refs.append(&"missing")
	assert_eq(school.core_monster_ids.size(), 3)
	assert_false(school.pattern_refs.has(&"missing"))

	var stage = catalog.build_stage_profiles()[4]
	var stage_copy = stage.copy_value()
	stage_copy.stage_index = 99
	stage_copy.boss_capstone_enabled = false
	assert_eq(stage.stage_index, 4)
	assert_true(stage.boss_capstone_enabled)

	var pattern = catalog.build_first_slice_patterns()[&"mark_or_link"]
	var pattern_copy = pattern.copy_value()
	pattern_copy.telegraph_parameters["hidden_target_selection"] = true
	pattern_copy.presentation_hooks[&"cheonsul"] = &"mutated"
	assert_false(pattern.telegraph_parameters["hidden_target_selection"])
	assert_ne(pattern.presentation_hooks[&"cheonsul"], &"mutated")


func _contains_fragment(errors: Array, fragment: String) -> bool:
	for error in errors:
		if str(error).to_lower().contains(fragment.to_lower()):
			return true
	return false


func _has_property(object: Object, property_name: StringName) -> bool:
	for property in object.get_property_list():
		if StringName(property.get("name", "")) == property_name:
			return true
	return false


func _sorted_string_names(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		result.append(StringName(value))
	result.sort_custom(func(a, b): return str(a) < str(b))
	return result
