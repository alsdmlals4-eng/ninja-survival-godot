# 도감 화면이 정본 카탈로그를 그대로 읽도록 만드는 읽기 전용 presentation adapter.
extends RefCounted
class_name CodexPresentation

const ENCOUNTER_CATALOG_SCRIPT = preload("res://scripts/data/encounter_catalog.gd")
const NINJUTSU_CATALOG_SCRIPT = preload("res://scripts/data/ninjutsu_catalog.gd")
const MVP4_CATALOG_SCRIPT = preload("res://scripts/data/mvp4_catalog.gd")
const SELECTED = preload("res://scripts/data/selected_backpack_catalog.gd")
const GEAR = preload("res://scripts/data/equipment_catalog.gd")
const BOOKS = preload("res://scripts/data/ninjutsu_book_catalog.gd")

func build_selected_sections() -> Array:
	var items: Dictionary = SELECTED.build_items()
	var books: Array = []
	for id in _sorted_ids(NINJUTSU_CATALOG_SCRIPT.build_definitions()):
		var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_id(id)
		var book = items[BOOKS.book_id(id)]
		books.append({"entry_id": id, "title": definition.display_name, "school_id": definition.school_id,
			"detail": "%s · 시작 선택 또는 유파 흡수로 획득 자격 해금\n가방 배치 후 자동 발동 · %d×%d · %d엽전\n%s" % [
				_school_name(definition.school_id), book.footprint_size.x, book.footprint_size.y, book.base_price,
				_selected_effect_detail(definition.effect_config)]})
	var equipment: Array = []
	for id in _sorted_ids(GEAR.DEFINITIONS):
		var data: Dictionary = GEAR.definition(StringName(id))
		var description := "피해 감소 %.2f%%" % (float(data.reduction) * 100.0) if data.slot == "outfit" else "자동 공격 · 기본 피해 %.2f · 주기 %.2f초 · 사거리 %.2f" % [data.damage, data.interval, data.range]
		equipment.append({"entry_id": StringName(id), "title": data.name,
			"detail": "별도 장비 슬롯 · %s · 가방 점유 없음\n%s · 구입 %d엽전\n유파 힘 부여와 모닥불 수치 강화는 별개이며 해당 장비에 귀속됩니다." % [
				{"melee": "근접", "projectile": "투사", "outfit": "의복"}[data.slot], description, data.price]})
	var support: Array = []
	for id in SELECTED.base_acquisition_item_ids():
		var item = items[id]
		support.append({"entry_id": id, "title": item.display_name,
			"detail": "가방 안에 배치 · %d×%d · %d엽전 · %s" % [item.footprint_size.x, item.footprint_size.y, item.base_price, _selected_support_detail(item)]})
	var combinations: Array = []
	for recipe in SELECTED.build_combinations().values():
		combinations.append({"entry_id": recipe.id, "title": items[recipe.result_item].display_name,
			"detail": "%s + %s · 인접 재료를 작업대에서 조합\n실패·취소 시 재료 보존. 조합 부가타는 새 조합 부가타를 재귀 발동시키지 않습니다." % [items[recipe.source_a].display_name, items[recipe.source_b].display_name]})
	return [{"section_id": &"enemies", "title": "적", "entries": _build_enemy_entries()},
		{"section_id": &"ninjutsu", "title": "인법서", "entries": books},
		{"section_id": &"equipment", "title": "장비", "entries": equipment},
		{"section_id": &"support", "title": "보조품", "entries": support},
		{"section_id": &"bags", "title": "가방", "entries": _build_bag_entries()},
		{"section_id": &"combinations", "title": "조합", "entries": combinations}]

func _selected_effect_detail(data: Dictionary) -> String:
	var kinds := {"familiar": "식신 자동 공격", "chain": "봉인 사슬 연결", "ward": "고정 결계 안 피해 감소", "orbit": "부적 궤도 접촉 공격",
		"dash_ward": "대시 도착점에 결계", "seal_zone": "적 전조에 반응하는 봉인", "flame_zone": "화염 인장과 화상", "water_zone": "물 장판의 첫 진입 피해·둔화·젖음",
		"lightning_chain": "젖은 적 우선 번개 연결", "wind_projectile": "관통하는 바람", "dash_token": "대시 뒤 첫 직접 적중에 번개 반응", "shield": "피해를 흡수하는 보호막",
		"pulse": "근접 파동", "afterimage_line": "잔영 직선 공격", "ring": "근접 원형 연타", "kick_cone": "전방 연속 타격", "dash_speed": "대시 뒤 이동 속도 증가",
		"proximity_guard": "적이 가까울 때 피해 감소", "needle": "표식을 남기는 암영침", "poison_zone": "고정 독 장막", "execution": "낮은 체력의 일반 적 처형·강적은 추가 피해만",
		"dart": "표적 추적 투사", "clone": "고정 위치 분신 연타", "dash_guard": "대시 뒤 피해 감소"}
	var lines: Array[String] = [str(kinds.get(data.kind, data.kind))]
	var fields := {"cooldown": "주기(초)", "damage": "기본 피해", "duration": "지속(초)", "radius": "반경", "shield": "보호막량", "burn_damage": "화상 틱 피해", "poison_damage": "독 틱 피해", "tick_interval": "틱 간격(초)", "max_targets": "최대 대상", "ticks": "타격 횟수", "bind_duration": "일반 적 봉인(초)"}
	for key in fields:
		if data.has(key) and float(data[key]) > 0: lines.append("%s %.2f" % [fields[key], data[key]])
	for key in ["damage_reduction", "move_speed_bonus", "slow"]:
		if data.has(key): lines.append("%s %.2f%%" % [{"damage_reduction": "피해 감소", "move_speed_bonus": "이동 속도", "slow": "둔화"}[key], float(data[key]) * 100.0])
	if data.kind in ["chain", "seal_zone", "execution"]: lines.append("보스에게 즉사·강제 봉인을 적용하지 않습니다.")
	return " · ".join(lines)

func _selected_support_detail(item) -> String:
	if item.effect_kind == &"school_emblem":
		var school_lines: Array[String] = []
		for school in item.school_payload:
			var rule: Dictionary = item.school_payload[school]
			school_lines.append("%s: %s %+.0f%%" % [_school_name(school), _modifier_name(rule.field), float(rule.value) * 100.0])
		return "시작 유파에 따라 적용 · " + " / ".join(school_lines)
	if item.school_payload.has("weapon_damage_bonus"):
		return "%s 자동 공격 피해 +%.0f%%" % ["근접" if item.school_payload.weapon_slot == "melee" else "투사", float(item.school_payload.weapon_damage_bonus) * 100.0]
	var lines: Array[String] = []
	for field in item.resolved_static_modifier_payload():
		var value: float = item.resolved_static_modifier_payload()[field]
		lines.append("%s %+.0f%s" % [_modifier_name(field), value if str(field).ends_with("_flat") else value * 100.0, "" if str(field).ends_with("_flat") else "%"])
	return " · ".join(lines) if not lines.is_empty() else "조합 재료"


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
		# New selectable records are preparation data until their runtime cutover.
		if definition.acquisition_lane == &"selectable":
			continue
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
		&"normal_kill_gold_pct": "일반 적 처치 엽전",
		&"rest_start_heal_pct": "휴식 시 최대 HP 비례 추가 회복",
		&"bongma_familiar_interval_pct": "식신 공격 간격",
		&"cheonsul_reaction_damage_pct": "속성 반응 피해",
		&"guiin_melee_radius_pct": "근접 범위",
		&"heukyeong_marked_crit_bonus": "표식 대상 치명타 보너스",
		&"heukyeong_mark_duration_pct": "표식 지속시간",
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
