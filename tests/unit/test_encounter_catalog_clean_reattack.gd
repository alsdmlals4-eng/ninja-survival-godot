extends GutTest

const CATALOG_PATH := "res://scripts/data/encounter_catalog.gd"
const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const FIRST_SLICE_PATTERN_IDS: Array[StringName] = [
	&"fan_or_arc_projectile",
	&"telegraphed_zone",
	&"mark_or_link",
]


func test_clean_catalog_stays_valid_after_fail_closed_validator_hardening() -> void:
	var catalog = load(CATALOG_PATH)
	assert_eq(catalog.validate_catalog(), [])
	assert_eq(catalog.build_school_encounters().size(), 4)
	assert_eq(catalog.build_stage_profiles().size(), 4)
	assert_eq(catalog.build_first_slice_patterns().size(), 3)


func test_school_and_stage_axes_remain_cartesian_inputs_not_sixteen_duplicated_profiles() -> void:
	var catalog = load(CATALOG_PATH)
	var schools: Dictionary = catalog.build_school_encounters()
	var profiles: Dictionary = catalog.build_stage_profiles()
	assert_eq(schools.size(), SCHOOL_IDS.size())
	assert_eq(profiles.size(), 4)
	for school_id in SCHOOL_IDS:
		assert_true(schools.has(school_id))
		for stage_index in range(1, 5):
			assert_true(profiles.has(stage_index))
			assert_eq(profiles[stage_index].stage_index, stage_index)


func test_first_slice_materializes_only_three_cheonsul_patterns_not_all_eight_runtime_bodies() -> void:
	var catalog = load(CATALOG_PATH)
	var patterns: Dictionary = catalog.build_first_slice_patterns()
	assert_eq(_sorted_names(patterns.keys()), _sorted_names(FIRST_SLICE_PATTERN_IDS))
	assert_eq(patterns.size(), 3)
	assert_eq(catalog.supported_primitive_ids().size(), 8)
	assert_true(catalog.supported_primitive_ids().size() > patterns.size())


func test_first_slice_key_id_and_presentation_hook_corruption_fail_closed() -> void:
	var catalog = load(CATALOG_PATH)
	var patterns: Dictionary = catalog.build_first_slice_patterns()
	patterns[&"fan_or_arc_projectile"].primitive_id = &"mark_or_link"
	assert_true(_contains(catalog.validate_first_slice_patterns(patterns), "key/id"))

	patterns = catalog.build_first_slice_patterns()
	patterns[&"telegraphed_zone"].presentation_hooks.erase(&"cheonsul")
	assert_true(_contains(catalog.validate_first_slice_patterns(patterns), "presentation hook"))


func test_school_key_id_corruption_does_not_silently_change_canonical_school_axis() -> void:
	var catalog = load(CATALOG_PATH)
	var schools: Dictionary = catalog.build_school_encounters()
	schools[&"bongma"].school_id = &"cheonsul"
	assert_true(_contains(catalog.validate_school_encounters(schools), "key/id"))
	assert_eq(_sorted_names(schools.keys()), _sorted_names(SCHOOL_IDS))


func _contains(errors: Array, fragment: String) -> bool:
	for error in errors:
		if str(error).to_lower().contains(fragment.to_lower()):
			return true
	return false


func _sorted_names(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		result.append(StringName(value))
	result.sort_custom(func(a, b): return str(a) < str(b))
	return result
