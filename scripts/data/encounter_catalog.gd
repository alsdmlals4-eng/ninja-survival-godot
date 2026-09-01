extends RefCounted
class_name EncounterCatalog

const SchoolEncounterDefinitionScript = preload("res://scripts/data/school_encounter_definition.gd")
const StageEncounterProfileScript = preload("res://scripts/data/stage_encounter_profile.gd")
const EncounterPatternDefinitionScript = preload("res://scripts/data/encounter_pattern_definition.gd")
const EncounterActorDefinitionScript = preload("res://scripts/data/encounter_actor_definition.gd")

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
	errors.append_array(validate_actor_definitions(build_actor_definitions()))
	return errors


static func build_actor_definitions() -> Dictionary:
	var actors: Dictionary = {}
	_add_actor(actors, &"seal_chaser", &"bongma", &"core", "봉인 추적자", [], 34, 108.0, 8, [])
	_add_actor(actors, &"shikigami_handler", &"bongma", &"core", "식신 사역자", [], 26, 78.0, 5, [])
	_add_actor(actors, &"barrier_carrier", &"bongma", &"core", "결계 운반자", [], 42, 68.0, 9, [])
	_add_actor(actors, &"mobile_array_caster", &"bongma", &"elite", "이동진 술사", [&"elite"], 180, 82.0, 13, [&"telegraphed_zone", &"summon_or_proxy"])
	_add_actor(actors, &"hundred_demon_array_master", &"bongma", &"boss", "백귀진 주재자", [&"boss"], 520, 70.0, 18, [&"telegraphed_zone", &"summon_or_proxy", &"barrier_or_lane"])

	_add_actor(actors, &"fire_mark_caster", &"cheonsul", &"core", "화인 술사", [], 28, 80.0, 5, [])
	_add_actor(actors, &"water_vein_caster", &"cheonsul", &"core", "수맥 술사", [], 36, 74.0, 7, [])
	_add_actor(actors, &"lightning_chain_caster", &"cheonsul", &"core", "뇌쇄 술사", [], 32, 86.0, 7, [])
	_add_actor(actors, &"five_element_tuner", &"cheonsul", &"elite", "오행 조율자", [&"elite"], 190, 78.0, 13, [&"telegraphed_zone", &"mark_or_link"])
	_add_actor(actors, &"heavenly_change_taoist", &"cheonsul", &"boss", "천변 도사", [&"boss"], 540, 68.0, 19, [&"fan_or_arc_projectile", &"telegraphed_zone", &"mark_or_link"])

	_add_actor(actors, &"surge_fighter", &"guiin", &"core", "쇄도 권객", [], 38, 116.0, 10, [])
	_add_actor(actors, &"pressure_monk", &"guiin", &"core", "압박 승병", [], 34, 76.0, 7, [])
	_add_actor(actors, &"ghost_blood_chaser", &"guiin", &"core", "귀혈 추적자", [], 44, 94.0, 11, [])
	_add_actor(actors, &"melee_chaos_captain", &"guiin", &"elite", "난전 대장", [&"elite"], 210, 86.0, 15, [&"line_dash", &"pulse_or_ring"])
	_add_actor(actors, &"ghost_general", &"guiin", &"boss", "귀신장", [&"boss"], 560, 74.0, 21, [&"line_dash", &"pulse_or_ring", &"chase_contact"])

	_add_actor(actors, &"shuriken_scout", &"heukyeong", &"core", "표창 척후", [], 30, 102.0, 6, [])
	_add_actor(actors, &"poison_shadow_assassin", &"heukyeong", &"core", "독영 살수", [], 34, 96.0, 8, [])
	_add_actor(actors, &"dark_mark_pursuer", &"heukyeong", &"core", "암표 추격자", [], 38, 90.0, 9, [])
	_add_actor(actors, &"shadow_chief", &"heukyeong", &"elite", "그림자 두령", [&"elite"], 200, 88.0, 14, [&"mark_or_link", &"summon_or_proxy"])
	_add_actor(actors, &"night_executioner", &"heukyeong", &"boss", "야행 처형자", [&"boss"], 550, 76.0, 20, [&"mark_or_link", &"summon_or_proxy", &"line_dash"])
	return actors


static func actor_definition_for(actor_id: StringName):
	var definition = build_actor_definitions().get(actor_id)
	return definition.copy_value() if definition != null else null


static func validate_actor_definitions(actors: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if actors.size() != 20:
		errors.append("Expected exactly twenty encounter actor definitions")
	var roles: Dictionary = {&"core": 0, &"elite": 0, &"boss": 0}
	for raw_id in actors.keys():
		var actor = actors.get(raw_id)
		if actor == null:
			errors.append("Null encounter actor: %s" % raw_id)
			continue
		if actor.actor_id == &"" or actor.actor_id != StringName(raw_id):
			errors.append("Encounter actor key/id mismatch: %s" % raw_id)
		if not SCHOOL_IDS.has(actor.school_id):
			errors.append("Unknown encounter actor school: %s" % actor.actor_id)
		if not roles.has(actor.role):
			errors.append("Unknown encounter actor role: %s" % actor.actor_id)
			continue
		roles[actor.role] = int(roles[actor.role]) + 1
		if actor.display_name.is_empty() or actor.visual_asset_path.is_empty():
			errors.append("Encounter actor presentation missing: %s" % actor.actor_id)
		if actor.role == &"core":
			if not actor.pattern_definitions.is_empty():
				errors.append("Core actors must not own special attack patterns: %s" % actor.actor_id)
			if actor.tags.has(&"ranged"):
				errors.append("Core actors must not advertise ranged attacks: %s" % actor.actor_id)
		else:
			var minimum_pattern_count := 2 if actor.role == &"elite" else 3
			if actor.pattern_definitions.size() < minimum_pattern_count:
				errors.append("Encounter actor pattern count too low: %s" % actor.actor_id)
		for pattern in actor.pattern_definitions:
			if not SUPPORTED_PRIMITIVE_IDS.has(StringName(pattern.get("primitive_id", &""))):
				errors.append("Unknown actor primitive: %s" % actor.actor_id)
			if float(pattern.get("telegraph_duration", 0.0)) <= 0.0:
				errors.append("Encounter actor telegraph missing: %s" % actor.actor_id)
			if float(pattern.get("recovery_duration", 0.0)) <= 0.0:
				errors.append("Encounter actor recovery missing: %s" % actor.actor_id)
	for role in roles.keys():
		var expected := 12 if role == &"core" else 4
		if int(roles[role]) != expected:
			errors.append("Encounter actor role cardinality mismatch: %s" % role)
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


static func _add_actor(
	actors: Dictionary,
	actor_id: StringName,
	school_id: StringName,
	role: StringName,
	display_name: String,
	tags: Array[StringName],
	max_health: int,
	move_speed: float,
	contact_damage: int,
	primitive_ids: Array[StringName]
) -> void:
	var definition = EncounterActorDefinitionScript.new()
	definition.actor_id = actor_id
	definition.school_id = school_id
	definition.role = role
	definition.display_name = display_name
	definition.tags = tags.duplicate()
	definition.max_health = max_health
	definition.move_speed = move_speed
	definition.contact_damage = contact_damage
	definition.contact_range = 30.0 if role == &"core" else 38.0 if role == &"elite" else 44.0
	definition.visual_asset_path = "res://assets/runtime/encounters/actors/%s.png" % actor_id
	for primitive_id in primitive_ids:
		definition.pattern_definitions.append(_actor_pattern(primitive_id, school_id, role))
	actors[actor_id] = definition


static func _actor_pattern(primitive_id: StringName, school_id: StringName, role: StringName) -> Dictionary:
	var telegraph_duration := 0.45 if role == &"core" else 0.70 if role == &"elite" else 0.85
	var execute_duration := 0.15 if role == &"core" else 0.22 if role == &"elite" else 0.28
	var recovery_duration := 0.40 if role == &"core" else 0.55 if role == &"elite" else 0.65
	return {
		"primitive_id": primitive_id,
		"school_id": school_id,
		"telegraph_duration": telegraph_duration,
		"execute_duration": execute_duration,
		"recovery_duration": recovery_duration,
	}


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
