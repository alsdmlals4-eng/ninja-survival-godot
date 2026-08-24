extends RefCounted
class_name EncounterCatalog

const SchoolEncounterDefinitionScript = preload("res://scripts/data/school_encounter_definition.gd")
const StageEncounterProfileScript = preload("res://scripts/data/stage_encounter_profile.gd")
const EncounterPatternDefinitionScript = preload("res://scripts/data/encounter_pattern_definition.gd")

const SCHOOL_IDS: Array[StringName] = [
	&"bongma",
	&"cheonsul",
	&"guiin",
	&"heukyeong",
]

const SUPPORTED_PRIMITIVE_IDS: Array[StringName] = [
	&"chase_contact",
	&"line_dash",
	&"fan_or_arc_projectile",
	&"telegraphed_zone",
	&"summon_or_proxy",
	&"mark_or_link",
	&"pulse_or_ring",
	&"barrier_or_lane",
]

const FIRST_SLICE_SCHOOL_ID: StringName = &"cheonsul"
const FIRST_SLICE_PATTERN_IDS: Array[StringName] = [
	&"fan_or_arc_projectile",
	&"telegraphed_zone",
	&"mark_or_link",
]


static func supported_primitive_ids() -> Array[StringName]:
	return SUPPORTED_PRIMITIVE_IDS.duplicate()


static func first_slice_school_id() -> StringName:
	return FIRST_SLICE_SCHOOL_ID


static func first_slice_pattern_ids() -> Array[StringName]:
	return FIRST_SLICE_PATTERN_IDS.duplicate()


static func build_school_encounters() -> Dictionary:
	var schools: Dictionary = {}
	_add_school(
		schools,
		&"bongma",
		[&"seal_chaser", &"shikigami_handler", &"barrier_carrier"],
		["봉인 추적자", "식신 사역자", "결계 운반자"],
		&"mobile_array_caster",
		"이동진 술사",
		&"hundred_demon_array_master",
		"백귀진 주재자",
		[&"chase_contact", &"telegraphed_zone", &"summon_or_proxy", &"barrier_or_lane"],
		&"triple_mobile_seal_array",
		"삼중 이동봉진"
	)
	_add_school(
		schools,
		&"cheonsul",
		[&"fire_mark_caster", &"water_vein_caster", &"lightning_chain_caster"],
		["화인 술사", "수맥 술사", "뇌쇄 술사"],
		&"five_element_tuner",
		"오행 조율자",
		&"heavenly_change_taoist",
		"천변 도사",
		[&"fan_or_arc_projectile", &"telegraphed_zone", &"mark_or_link"],
		&"chained_five_element_shift",
		"연쇄 오행전환"
	)
	_add_school(
		schools,
		&"guiin",
		[&"surge_fighter", &"pressure_monk", &"ghost_blood_chaser"],
		["쇄도 권객", "압박 승병", "귀혈 추적자"],
		&"melee_chaos_captain",
		"난전 대장",
		&"ghost_general",
		"귀신장",
		[&"line_dash", &"pulse_or_ring", &"chase_contact"],
		&"chained_ghost_blood_rush",
		"연속 귀혈쇄도"
	)
	_add_school(
		schools,
		&"heukyeong",
		[&"shuriken_scout", &"poison_shadow_assassin", &"dark_mark_pursuer"],
		["표창 척후", "독영 살수", "암표 추격자"],
		&"shadow_chief",
		"그림자 두령",
		&"night_executioner",
		"야행 처형자",
		[&"fan_or_arc_projectile", &"telegraphed_zone", &"mark_or_link", &"summon_or_proxy"],
		&"triple_shadow_execution_line",
		"삼영 처형선"
	)
	return schools


static func build_stage_profiles() -> Dictionary:
	var profiles: Dictionary = {}
	_add_stage_profile(profiles, 1, 1.0, 1.0, 1, 1, false)
	_add_stage_profile(profiles, 2, 1.0, 1.0, 2, 1, false)
	_add_stage_profile(profiles, 3, 1.0, 1.0, 3, 2, false)
	_add_stage_profile(profiles, 4, 1.0, 1.0, 4, 2, true)
	return profiles


static func build_first_slice_patterns() -> Dictionary:
	var patterns: Dictionary = {}
	_add_pattern(
		patterns,
		&"fan_or_arc_projectile",
		"부채꼴/호형 투사체",
		{
			"anticipation_required": true,
			"readable_origin": true,
			"readable_direction": true,
		},
		{"delivery": &"directional_projectile_pressure"},
		[&"projectile", &"directional", &"ranged"],
		{&"cheonsul": &"elemental_arc"}
	)
	_add_pattern(
		patterns,
		&"telegraphed_zone",
		"예고 장판",
		{
			"visible_boundary": true,
			"expiry_cue": true,
		},
		{"delivery": &"delayed_area_pressure"},
		[&"zone", &"area_control", &"telegraphed"],
		{&"cheonsul": &"elemental_zone"}
	)
	_add_pattern(
		patterns,
		&"mark_or_link",
		"표식/연결",
		{
			"visible_ownership": true,
			"release_cue": true,
			"hidden_target_selection": false,
		},
		{"delivery": &"stateful_target_relation"},
		[&"mark", &"link", &"stateful"],
		{&"cheonsul": &"elemental_mark"}
	)
	return patterns


static func validate_catalog() -> Array[String]:
	var errors: Array[String] = []
	errors.append_array(validate_school_encounters(build_school_encounters()))
	errors.append_array(validate_stage_profiles(build_stage_profiles()))
	errors.append_array(validate_first_slice_patterns(build_first_slice_patterns()))
	return errors


static func validate_school_encounters(schools: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if schools.size() != SCHOOL_IDS.size():
		errors.append("Expected four school encounter definitions")
	for school_id in SCHOOL_IDS:
		if not schools.has(school_id):
			errors.append("Missing school encounter: %s" % school_id)
			continue
		var definition = schools[school_id]
		if definition == null:
			errors.append("Null school encounter: %s" % school_id)
			continue
		if definition.school_id != school_id:
			errors.append("School key/id mismatch: %s" % school_id)
		if definition.core_monster_ids.size() != 3 or definition.core_monster_display_names.size() != 3:
			errors.append("School core roster must contain exactly three entries: %s" % school_id)
		if _unique_string_name_count(definition.core_monster_ids) != definition.core_monster_ids.size():
			errors.append("School core roster contains duplicate core ids: %s" % school_id)
		if definition.elite_id == &"" or definition.boss_id == &"" or definition.stage4_boss_capstone_id == &"":
			errors.append("School elite/boss/capstone ids must be present: %s" % school_id)
		if definition.elite_display_name.is_empty() or definition.boss_display_name.is_empty() or definition.stage4_boss_capstone_display_name.is_empty():
			errors.append("School elite/boss/capstone display names must be present: %s" % school_id)
		var role_ids: Array[StringName] = definition.core_monster_ids.duplicate()
		role_ids.append(definition.elite_id)
		role_ids.append(definition.boss_id)
		role_ids.append(definition.stage4_boss_capstone_id)
		if _unique_string_name_count(role_ids) != role_ids.size():
			errors.append("School encounter identity collision: %s" % school_id)
		if definition.pattern_refs.is_empty():
			errors.append("School pattern refs must not be empty: %s" % school_id)
		if _unique_string_name_count(definition.pattern_refs) != definition.pattern_refs.size():
			errors.append("School pattern refs contain duplicate pattern ids: %s" % school_id)
		for primitive_id in definition.pattern_refs:
			if not SUPPORTED_PRIMITIVE_IDS.has(primitive_id):
				errors.append("Unknown primitive ref %s on school %s" % [primitive_id, school_id])

	for raw_id in schools.keys():
		var school_id := StringName(raw_id)
		if not SCHOOL_IDS.has(school_id):
			errors.append("Unknown school encounter key: %s" % school_id)
	return errors


static func validate_stage_profiles(profiles: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if profiles.size() != 4:
		errors.append("Expected exactly four shared stage profiles")
	for stage_index in range(1, 5):
		if not profiles.has(stage_index):
			errors.append("Missing stage profile: %d" % stage_index)
			continue
		var profile = profiles[stage_index]
		if profile == null:
			errors.append("Null stage profile: %d" % stage_index)
			continue
		if profile.stage_index != stage_index or profile.stage_index < 1 or profile.stage_index > 4:
			errors.append("Invalid stage index: %d" % stage_index)
		if not is_finite(profile.density_multiplier) or not is_finite(profile.stat_multiplier) or profile.density_multiplier <= 0.0 or profile.stat_multiplier <= 0.0:
			errors.append("Stage multipliers must be finite and positive: %d" % stage_index)
		if profile.pattern_depth_tier != stage_index:
			errors.append("Stage pattern depth must match stage index: %d" % stage_index)
		var expected_concurrency := 1 if stage_index <= 2 else 2
		if profile.max_concurrent_advanced_gimmicks != expected_concurrency:
			errors.append("Stage concurrency contract mismatch: %d" % stage_index)
		if profile.boss_capstone_enabled != (stage_index == 4):
			errors.append("Stage capstone contract mismatch: %d" % stage_index)
	for raw_index in profiles.keys():
		var stage_index := int(raw_index)
		if stage_index < 1 or stage_index > 4:
			errors.append("Unknown stage profile key: %d" % stage_index)
	return errors


static func validate_first_slice_patterns(patterns: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if patterns.size() != FIRST_SLICE_PATTERN_IDS.size():
		errors.append("Expected exactly three first-slice primitive definitions")
	for primitive_id in FIRST_SLICE_PATTERN_IDS:
		if not patterns.has(primitive_id):
			errors.append("Missing first-slice primitive: %s" % primitive_id)
			continue
		var definition = patterns[primitive_id]
		if definition == null or definition.primitive_id != primitive_id:
			errors.append("First-slice primitive key/id mismatch: %s" % primitive_id)
			continue
		if definition.display_name.is_empty():
			errors.append("Primitive display name missing: %s" % primitive_id)
		if definition.telegraph_parameters.is_empty():
			errors.append("Primitive telegraph parameters missing: %s" % primitive_id)
		if definition.execution_parameters.is_empty():
			errors.append("Primitive execution parameters missing: %s" % primitive_id)
		if definition.tags.is_empty():
			errors.append("Primitive tags missing: %s" % primitive_id)
		if not definition.presentation_hooks.has(FIRST_SLICE_SCHOOL_ID):
			errors.append("Primitive first-slice presentation hook missing: %s" % primitive_id)
		if definition.telegraph_parameters.has("warning_seconds"):
			errors.append("Primitive warning_seconds must remain a later tuning value: %s" % primitive_id)
		if not _has_required_fair_telegraph(primitive_id, definition.telegraph_parameters):
			errors.append("Primitive telegraph fairness contract mismatch: %s" % primitive_id)
	for raw_id in patterns.keys():
		var primitive_id := StringName(raw_id)
		if not FIRST_SLICE_PATTERN_IDS.has(primitive_id):
			errors.append("Unexpected first-slice primitive definition: %s" % primitive_id)
	return errors


static func _has_required_fair_telegraph(primitive_id: StringName, parameters: Dictionary) -> bool:
	match primitive_id:
		&"fan_or_arc_projectile":
			return bool(parameters.get("anticipation_required", false)) \
				and bool(parameters.get("readable_origin", false)) \
				and bool(parameters.get("readable_direction", false))
		&"telegraphed_zone":
			return bool(parameters.get("visible_boundary", false)) \
				and bool(parameters.get("expiry_cue", false))
		&"mark_or_link":
			return bool(parameters.get("visible_ownership", false)) \
				and bool(parameters.get("release_cue", false)) \
				and not bool(parameters.get("hidden_target_selection", true))
	return false


static func _add_school(
	schools: Dictionary,
	school_id: StringName,
	core_ids: Array[StringName],
	core_names: Array[String],
	elite_id: StringName,
	elite_name: String,
	boss_id: StringName,
	boss_name: String,
	pattern_refs: Array[StringName],
	capstone_id: StringName,
	capstone_name: String
) -> void:
	var definition = SchoolEncounterDefinitionScript.new()
	definition.school_id = school_id
	definition.core_monster_ids = core_ids.duplicate()
	definition.core_monster_display_names = core_names.duplicate()
	definition.elite_id = elite_id
	definition.elite_display_name = elite_name
	definition.boss_id = boss_id
	definition.boss_display_name = boss_name
	definition.pattern_refs = pattern_refs.duplicate()
	definition.stage4_boss_capstone_id = capstone_id
	definition.stage4_boss_capstone_display_name = capstone_name
	schools[school_id] = definition


static func _add_stage_profile(
	profiles: Dictionary,
	stage_index: int,
	density_multiplier: float,
	stat_multiplier: float,
	pattern_depth_tier: int,
	max_concurrent_advanced_gimmicks: int,
	boss_capstone_enabled: bool
) -> void:
	var profile = StageEncounterProfileScript.new()
	profile.stage_index = stage_index
	profile.density_multiplier = density_multiplier
	profile.stat_multiplier = stat_multiplier
	profile.pattern_depth_tier = pattern_depth_tier
	profile.max_concurrent_advanced_gimmicks = max_concurrent_advanced_gimmicks
	profile.boss_capstone_enabled = boss_capstone_enabled
	profiles[stage_index] = profile


static func _add_pattern(
	patterns: Dictionary,
	primitive_id: StringName,
	display_name: String,
	telegraph_parameters: Dictionary,
	execution_parameters: Dictionary,
	tags: Array[StringName],
	presentation_hooks: Dictionary
) -> void:
	var definition = EncounterPatternDefinitionScript.new()
	definition.primitive_id = primitive_id
	definition.display_name = display_name
	definition.telegraph_parameters = telegraph_parameters.duplicate(true)
	definition.execution_parameters = execution_parameters.duplicate(true)
	definition.tags = tags.duplicate()
	definition.presentation_hooks = presentation_hooks.duplicate(true)
	patterns[primitive_id] = definition


static func _unique_string_name_count(values: Array[StringName]) -> int:
	var seen: Dictionary = {}
	for value in values:
		seen[value] = true
	return seen.size()
