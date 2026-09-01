extends RefCounted
class_name NinjutsuCatalog

const NINJUTSU_DEFINITION_SCRIPT = preload("res://scripts/data/ninjutsu_definition.gd")

const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const ACQUISITION_LANES: Array[StringName] = [&"starter", &"elite_scroll", &"boss_scroll"]


static func build_definitions() -> Dictionary:
	var definitions: Dictionary = {}
	_add(definitions, &"bongma_hundred_demon_familiar", &"bongma", &"starter", "백귀 식신", &"summon_or_proxy")
	_add(definitions, &"bongma_seal_chain", &"bongma", &"elite_scroll", "봉인쇄", &"mark_or_link")
	_add(definitions, &"bongma_guardian_ward", &"bongma", &"boss_scroll", "수호결계", &"pulse_or_ring")
	_add(definitions, &"cheonsul_flame_mark", &"cheonsul", &"starter", "화염 인장", &"telegraphed_zone")
	_add(definitions, &"cheonsul_water_vein_bind", &"cheonsul", &"elite_scroll", "수맥 결박", &"telegraphed_zone")
	_add(definitions, &"cheonsul_lightning_chain_shift", &"cheonsul", &"boss_scroll", "뇌쇄 전이", &"mark_or_link")
	_add(definitions, &"guiin_ghost_blood_wave", &"guiin", &"starter", "귀혈파", &"pulse_or_ring")
	_add(definitions, &"guiin_afterimage_charge", &"guiin", &"elite_scroll", "잔영 쇄도", &"line_dash")
	_add(definitions, &"guiin_asura_ring", &"guiin", &"boss_scroll", "수라진", &"pulse_or_ring")
	_add(definitions, &"heukyeong_shadow_needle", &"heukyeong", &"starter", "암영침", &"fan_or_arc_projectile")
	_add(definitions, &"heukyeong_poison_mist", &"heukyeong", &"elite_scroll", "독무 장막", &"telegraphed_zone")
	_add(definitions, &"heukyeong_chain_execution", &"heukyeong", &"boss_scroll", "사슬 처형", &"mark_or_link")
	return definitions


static func definition_for_lane(school_id: StringName, lane: StringName):
	if not SCHOOL_IDS.has(school_id) or not ACQUISITION_LANES.has(lane):
		return null
	for definition in build_definitions().values():
		if definition.school_id == school_id and definition.acquisition_lane == lane:
			return definition.copy_value()
	return null


static func definition_for_id(ninjutsu_id: StringName):
	var definition = build_definitions().get(ninjutsu_id)
	return definition.copy_value() if definition != null else null


static func validate_definitions(definitions: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if definitions.size() != 12:
		errors.append("Expected exactly twelve ninjutsu definitions")
	var seen_ids: Dictionary = {}
	for raw_id in definitions.keys():
		var definition = definitions.get(raw_id)
		if definition == null:
			errors.append("Null ninjutsu definition: %s" % raw_id)
			continue
		if definition.ninjutsu_id == &"" or definition.ninjutsu_id != StringName(raw_id):
			errors.append("Ninjutsu key/id mismatch: %s" % raw_id)
		if seen_ids.has(definition.ninjutsu_id):
			errors.append("Duplicate ninjutsu id: %s" % definition.ninjutsu_id)
		seen_ids[definition.ninjutsu_id] = true
		if not SCHOOL_IDS.has(definition.school_id):
			errors.append("Unknown ninjutsu school: %s" % definition.ninjutsu_id)
		if not ACQUISITION_LANES.has(definition.acquisition_lane):
			errors.append("Unknown ninjutsu lane: %s" % definition.ninjutsu_id)
		if definition.display_name.is_empty() or definition.primitive_id == &"":
			errors.append("Ninjutsu presentation missing: %s" % definition.ninjutsu_id)
	for school_id in SCHOOL_IDS:
		for lane in ACQUISITION_LANES:
			var lane_count := 0
			for definition in definitions.values():
				if definition != null and definition.school_id == school_id and definition.acquisition_lane == lane:
					lane_count += 1
			if lane_count != 1:
				errors.append("School %s requires exactly one %s" % [school_id, lane])
	return errors


static func _add(
	definitions: Dictionary,
	ninjutsu_id: StringName,
	school_id: StringName,
	lane: StringName,
	display_name: String,
	primitive_id: StringName
) -> void:
	var definition = NINJUTSU_DEFINITION_SCRIPT.new()
	definition.ninjutsu_id = ninjutsu_id
	definition.school_id = school_id
	definition.acquisition_lane = lane
	definition.display_name = display_name
	definition.primitive_id = primitive_id
	definition.visual_asset_path = "res://assets/runtime/encounters/ninjutsu/%s.png" % ninjutsu_id
	definitions[ninjutsu_id] = definition
