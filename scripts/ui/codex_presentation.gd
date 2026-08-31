# 도감 화면이 정본 카탈로그를 그대로 읽도록 만드는 읽기 전용 presentation adapter.
extends RefCounted
class_name CodexPresentation

const ENCOUNTER_CATALOG_SCRIPT = preload("res://scripts/data/encounter_catalog.gd")
const NINJUTSU_CATALOG_SCRIPT = preload("res://scripts/data/ninjutsu_catalog.gd")
const MVP4_CATALOG_SCRIPT = preload("res://scripts/data/mvp4_catalog.gd")


func build_sections() -> Array:
	var item_defs: Dictionary = MVP4_CATALOG_SCRIPT.build_items()
	return [
		{
			"section_id": &"enemies",
			"title": "적",
			"entries": _build_enemy_entries(),
		},
		{
			"section_id": &"ninjutsu",
			"title": "인법서",
			"entries": _build_ninjutsu_entries(),
		},
		{
			"section_id": &"equipment",
			"title": "장비",
			"entries": _build_equipment_entries(item_defs),
		},
		{
			"section_id": &"bags",
			"title": "가방",
			"entries": _build_bag_entries(),
		},
		{
			"section_id": &"combinations",
			"title": "조합",
			"entries": _build_combination_entries(item_defs),
		},
	]


func _build_enemy_entries() -> Array:
	var entries: Array = []
	var definitions: Dictionary = ENCOUNTER_CATALOG_SCRIPT.build_actor_definitions()
	for actor_id in _sorted_ids(definitions):
		var definition = definitions.get(actor_id)
		entries.append({
			"entry_id": definition.actor_id,
			"title": definition.display_name,
			"school_id": definition.school_id,
			"role": definition.role,
			"detail": _enemy_detail(definition),
		})
	return entries


func _build_ninjutsu_entries() -> Array:
	var entries: Array = []
	var definitions: Dictionary = NINJUTSU_CATALOG_SCRIPT.build_definitions()
	for ninjutsu_id in _sorted_ids(definitions):
		var definition = definitions.get(ninjutsu_id)
		entries.append({
			"entry_id": definition.ninjutsu_id,
			"title": definition.display_name,
			"school_id": definition.school_id,
			"acquisition_lane": definition.acquisition_lane,
			"detail": "%s · %s · %s" % [_ninjutsu_lane_text(definition.acquisition_lane), _primitive_text(definition.primitive_id), _school_name(definition.school_id)],
		})
	return entries


func _build_equipment_entries(item_defs: Dictionary) -> Array:
	var entries: Array = []
	for item_id in _sorted_ids(item_defs):
		var definition = item_defs.get(item_id)
		entries.append({
			"entry_id": definition.id,
			"title": definition.display_name,
			"detail": "가방 안에 배치 · %d×%d · %s" % [definition.footprint_size.x, definition.footprint_size.y, _modifier_summary(definition.resolved_static_modifier_payload())],
		})
	return entries


func _build_bag_entries() -> Array:
	var entries: Array = []
	var bag_defs: Dictionary = MVP4_CATALOG_SCRIPT.build_bags()
	for bag_id in _sorted_ids(bag_defs):
		var definition = bag_defs.get(bag_id)
		var price_text := "시작 가방" if definition.id == MVP4_CATALOG_SCRIPT.STARTING_BAG_ID else "%d GOLD" % definition.base_price
		entries.append({
			"entry_id": definition.id,
			"title": definition.display_name,
			"detail": "%s · %d칸 활성화 · 90도 회전 가능" % [price_text, definition.cells.size()],
		})
	return entries


func _build_combination_entries(item_defs: Dictionary) -> Array:
	var entries: Array = []
	var combinations: Dictionary = MVP4_CATALOG_SCRIPT.build_combinations()
	for combination_id in _sorted_ids(combinations):
		var definition = combinations.get(combination_id)
		var source_a = item_defs.get(definition.source_a)
		var source_b = item_defs.get(definition.source_b)
		var result = item_defs.get(definition.result_item)
		entries.append({
			"entry_id": definition.id,
			"title": result.display_name if result != null else String(definition.result_item),
			"detail": "%s + %s를 작업대에서 조합" % [source_a.display_name if source_a != null else definition.source_a, source_b.display_name if source_b != null else definition.source_b],
		})
	return entries


func _enemy_detail(definition) -> String:
	var school_text := _school_name(definition.school_id)
	match definition.role:
		&"core":
			return "%s 코어 적 · 추격과 접촉 압박" % school_text
		&"elite":
			return "%s 엘리트 · 전조 후 패턴 %d종" % [school_text, definition.pattern_definitions.size()]
		&"boss":
			return "%s 보스 · 전조 후 유파 패턴 %d종" % [school_text, definition.pattern_definitions.size()]
		_:
			return "%s 적" % school_text


func _ninjutsu_lane_text(lane: StringName) -> String:
	match lane:
		&"starter":
			return "시작 인법"
		&"elite_scroll":
			return "엘리트 인법서"
		&"boss_scroll":
			return "보스 인법서"
		_:
			return "인법서"


func _primitive_text(primitive_id: StringName) -> String:
	var labels := {
		&"summon_or_proxy": "식신/대리 공격",
		&"mark_or_link": "표식/연결",
		&"pulse_or_ring": "원형 파동",
		&"telegraphed_zone": "예고 장판",
		&"line_dash": "직선 쇄도",
		&"fan_or_arc_projectile": "부채꼴 투사체",
	}
	return String(labels.get(primitive_id, primitive_id))


func _modifier_summary(payload: Dictionary) -> String:
	if payload.is_empty():
		return "조합 재료"
	var modifier_names: Array[String] = []
	for raw_field in payload.keys():
		modifier_names.append(_modifier_name(StringName(raw_field)))
	modifier_names.sort()
	return ", ".join(modifier_names)


func _modifier_name(field_name: StringName) -> String:
	var names := {
		&"move_speed_pct": "이동 속도",
		&"max_health_flat": "최대 HP",
		&"max_health_pct": "최대 HP",
		&"damage_taken_pct": "피해량",
		&"healing_pct": "회복",
		&"school_damage_pct": "유파 피해",
		&"non_ultimate_school_damage_pct": "비오의 피해",
		&"school_resource_gain_pct": "유파 자원",
		&"ultimate_charge_gain_pct": "오의 충전",
		&"ultimate_power_pct": "오의 위력",
		&"school_status_effect_pct": "상태 효과",
		&"evasion_chance": "회피",
	}
	return String(names.get(field_name, field_name))


func _school_name(school_id: StringName) -> String:
	var names := {
		&"bongma": "봉마",
		&"cheonsul": "천술",
		&"guiin": "귀인",
		&"heukyeong": "흑영",
	}
	return String(names.get(school_id, school_id))


func _sorted_ids(definitions: Dictionary) -> Array:
	var ids: Array = definitions.keys()
	ids.sort()
	return ids
