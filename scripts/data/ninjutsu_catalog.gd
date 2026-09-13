extends RefCounted
class_name NinjutsuCatalog

const NINJUTSU_DEFINITION_SCRIPT = preload("res://scripts/data/ninjutsu_definition.gd")

const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const ACQUISITION_LANES: Array[StringName] = [&"starter", &"elite_scroll", &"boss_scroll"]
const EFFECT_KINDS := ["familiar", "chain", "ward", "orbit", "dash_ward", "seal_zone", "flame_zone", "water_zone", "lightning_chain", "wind_projectile", "dash_token", "shield", "pulse", "afterimage_line", "ring", "kick_cone", "dash_speed", "proximity_guard", "needle", "poison_zone", "execution", "dart", "clone", "dash_guard"]
const TAGS := [&"injutsu", &"melee", &"projectile", &"movement", &"survival"]


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
	_add(definitions, &"bongma_talisman_wheel", &"bongma", &"selectable", "퇴마부륜", &"pulse_or_ring")
	_add(definitions, &"bongma_barrier_step", &"bongma", &"selectable", "결계보법", &"pulse_or_ring")
	_add(definitions, &"bongma_suppression_seal", &"bongma", &"selectable", "진압인", &"telegraphed_zone")
	_add(definitions, &"cheonsul_wind_pillar", &"cheonsul", &"selectable", "풍주", &"fan_or_arc_projectile")
	_add(definitions, &"cheonsul_thunder_step", &"cheonsul", &"selectable", "뇌보", &"mark_or_link")
	_add(definitions, &"cheonsul_ice_veil", &"cheonsul", &"selectable", "빙막", &"pulse_or_ring")
	_add(definitions, &"guiin_rakshasa_kicks", &"guiin", &"selectable", "나찰연각", &"pulse_or_ring")
	_add(definitions, &"guiin_demon_step", &"guiin", &"selectable", "귀일보", &"line_dash")
	_add(definitions, &"guiin_iron_blood_guard", &"guiin", &"selectable", "철혈호체", &"pulse_or_ring")
	_add(definitions, &"heukyeong_pursuit_dart", &"heukyeong", &"selectable", "추영표", &"fan_or_arc_projectile")
	_add(definitions, &"heukyeong_shadow_clone", &"heukyeong", &"selectable", "그림자분신", &"summon_or_proxy")
	_add(definitions, &"heukyeong_smoke_step", &"heukyeong", &"selectable", "연막보법", &"pulse_or_ring")
	_configure_effects(definitions)
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
	if definitions.size() != 24:
		errors.append("Expected exactly twenty-four ninjutsu definitions")
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
		if not ACQUISITION_LANES.has(definition.acquisition_lane) and definition.acquisition_lane != &"selectable":
			errors.append("Unknown ninjutsu lane: %s" % definition.ninjutsu_id)
		if definition.display_name.is_empty() or definition.primitive_id == &"":
			errors.append("Ninjutsu presentation missing: %s" % definition.ninjutsu_id)
		if not EFFECT_KINDS.has(definition.effect_config.get("kind", "")):
			errors.append("Unknown effect kind: %s" % raw_id)
		for key in ["cooldown", "target_range", "damage", "duration"]:
			var value = definition.effect_config.get(key)
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) < 0.0:
				errors.append("Invalid effect number %s: %s" % [key, raw_id])
		for key in definition.effect_config:
			if key == "kind":
				continue
			var value = definition.effect_config[key]
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) < 0.0:
				errors.append("Invalid effect parameter %s: %s" % [key, raw_id])
		if not definition.tags.has(&"injutsu"):
			errors.append("Missing injutsu tag: %s" % raw_id)
		var seen_tags: Dictionary = {}
		for tag in definition.tags:
			if not TAGS.has(tag) or seen_tags.has(tag):
				errors.append("Invalid tag: %s" % raw_id)
			seen_tags[tag] = true
	for school_id in SCHOOL_IDS:
		var school_count := 0
		for definition in definitions.values():
			if definition != null and definition.school_id == school_id:
				school_count += 1
		if school_count != 6:
			errors.append("School %s requires six definitions" % school_id)
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
	var asset_path := "res://assets/runtime/encounters/ninjutsu/%s.png" % ninjutsu_id
	definition.visual_asset_path = asset_path if ResourceLoader.exists(asset_path) else ""
	definitions[ninjutsu_id] = definition


static func _effect(definitions: Dictionary, id: StringName, kind: String, cooldown: float, damage: float, duration: float = 0.0, parameters: Dictionary = {}, extra_tags: Array[StringName] = []) -> void:
	var definition = definitions[id]
	definition.effect_config = {"kind": kind, "cooldown": cooldown, "target_range": 320.0, "damage": damage, "duration": duration}
	definition.effect_config.merge(parameters, true)
	definition.tags.assign([&"injutsu"])
	definition.tags.append_array(extra_tags)


static func _configure_effects(definitions: Dictionary) -> void:
	# R-NINJUTSU definitions. Selected consumers are connected incrementally;
	# a definition alone does not prove its runtime effect is implemented.
	_effect(definitions, &"bongma_hundred_demon_familiar", "familiar", 0.7, 8, 0, {"follow_range": 180.0})
	_effect(definitions, &"bongma_seal_chain", "chain", 4, 12, 0, {"followup_damage": 8.0, "link_range": 140.0, "max_targets": 3, "bind_duration": 0.6})
	_effect(definitions, &"bongma_guardian_ward", "ward", 8, 0, 2, {"target_range": 240.0, "radius": 120.0, "damage_reduction": 0.2}, [&"survival"])
	_effect(definitions, &"bongma_talisman_wheel", "orbit", 3, 5, 2, {"radius": 90.0, "orbiter_count": 3, "max_hits_per_target": 2, "hit_interval": 0.5, "angular_speed": PI, "contact_radius": 24.0}, [&"projectile"])
	_effect(definitions, &"bongma_barrier_step", "dash_ward", 6, 0, 1.5, {"radius": 90.0, "damage_reduction": 0.1}, [&"movement", &"survival"])
	_effect(definitions, &"bongma_suppression_seal", "seal_zone", 5, 16, 0, {"radius": 100.0, "delay": 0.2, "bind_duration": 0.4})
	_effect(definitions, &"cheonsul_flame_mark", "flame_zone", 1.8, 6, 3, {"radius": 90.0, "burn_damage": 2.0, "tick_interval": 1.0})
	_effect(definitions, &"cheonsul_water_vein_bind", "water_zone", 4, 8, 2, {"radius": 96.0, "slow": 0.25, "wet_duration": 3.0})
	_effect(definitions, &"cheonsul_lightning_chain_shift", "lightning_chain", 3, 12, 0, {"link_range": 140.0, "max_targets": 3})
	_effect(definitions, &"cheonsul_wind_pillar", "wind_projectile", 3, 14, 0.6, {"length": 360.0, "width": 48.0, "speed": 600.0}, [&"projectile"])
	_effect(definitions, &"cheonsul_thunder_step", "dash_token", 6, 0, 3, {}, [&"movement"])
	_effect(definitions, &"cheonsul_ice_veil", "shield", 9, 0, 3, {"target_range": 240.0, "shield": 12.0}, [&"survival"])
	_effect(definitions, &"guiin_ghost_blood_wave", "pulse", 0.9, 10, 0, {"target_range": 80.0, "radius": 80.0}, [&"melee"])
	_effect(definitions, &"guiin_afterimage_charge", "afterimage_line", 3, 16, 0.35, {"length": 320.0, "width": 56.0}, [&"melee"])
	_effect(definitions, &"guiin_asura_ring", "ring", 5, 8, 1, {"target_range": 112.0, "radius": 112.0, "tick_interval": 0.5, "ticks": 2}, [&"melee"])
	_effect(definitions, &"guiin_rakshasa_kicks", "kick_cone", 2.5, 5, 0.24, {"target_range": 100.0, "radius": 100.0, "angle_degrees": 100.0, "tick_interval": 0.12, "ticks": 3}, [&"melee"])
	_effect(definitions, &"guiin_demon_step", "dash_speed", 5, 0, 1.2, {"move_speed_bonus": 0.15}, [&"movement"])
	_effect(definitions, &"guiin_iron_blood_guard", "proximity_guard", 0, 0, 0, {"target_range": 110.0, "damage_reduction": 0.1}, [&"survival"])
	_effect(definitions, &"heukyeong_shadow_needle", "needle", 1.1, 6, 0.75, {"speed": 640.0, "projectile_radius": 6.0, "mark_duration": 8.0}, [&"projectile"])
	_effect(definitions, &"heukyeong_poison_mist", "poison_zone", 5, 0, 2, {"radius": 96.0, "poison_duration": 3.0, "poison_damage": 4.0, "tick_interval": 1.0})
	_effect(definitions, &"heukyeong_chain_execution", "execution", 4, 14, 0, {"execute_hp_ratio": 0.15, "elite_boss_multiplier": 1.25, "link_range": 140.0, "max_followups": 2})
	_effect(definitions, &"heukyeong_pursuit_dart", "dart", 2.2, 14, 0.8, {"speed": 600.0, "projectile_radius": 8.0}, [&"projectile"])
	_effect(definitions, &"heukyeong_shadow_clone", "clone", 7, 6, 2, {"tick_interval": 0.7, "ticks": 3})
	_effect(definitions, &"heukyeong_smoke_step", "dash_guard", 6, 0, 1, {"damage_reduction": 0.15}, [&"movement", &"survival"])
