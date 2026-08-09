extends RefCounted
class_name MVP3Catalog

const ItemDefinitionScript = preload("res://scripts/data/item_definition.gd")
const FateDefinitionScript = preload("res://scripts/data/fate_definition.gd")


static func build_items() -> Dictionary:
	var items := {}
	_add_item(items, &"taijutsu_training", "체술단련", 20, [&"support", &"movement"], &"move_speed_pct", 0.10)
	_add_item(items, &"protection_talisman", "호신 부적", 20, [&"support", &"survival"], &"max_health_flat", 20.0)
	_add_item(items, &"fortune_talisman", "행운 부적", 20, [&"support", &"economy"], &"normal_kill_gold_pct", 0.25)
	_add_item(items, &"ninjutsu_training", "인법단련", 30, [&"support", &"damage"], &"school_damage_pct", 0.12)
	_add_item(items, &"enlightenment", "깨달음", 30, [&"support", &"resource"], &"school_resource_gain_pct", 0.20)
	_add_item(items, &"regeneration_scroll", "재생의 두루마리", 30, [&"support", &"healing"], &"rest_start_heal_pct", 0.20)
	_add_item(items, &"ultimate_treatise", "오의 비전서", 40, [&"support", &"ultimate"], &"ultimate_charge_gain_pct", 0.25)
	_add_item(
		items,
		&"school_emblem",
		"유파 증표",
		40,
		[&"support", &"school"],
		&"school_emblem",
		0.0,
		{
			&"bongma": {&"field": &"bongma_familiar_interval_pct", &"value": -0.15},
			&"cheonsul": {&"field": &"cheonsul_reaction_damage_pct", &"value": 0.20},
			&"guiin": {&"field": &"guiin_melee_radius_pct", &"value": 0.15},
			&"heukyeong": {&"field": &"heukyeong_marked_crit_bonus", &"value": 0.15},
		}
	)
	return items


static func build_fates() -> Dictionary:
	var fates := {}
	_add_fate(
		fates,
		&"slaughter_path",
		"살육의 길",
		"유파 피해 +20%",
		"회복 효율 -40%",
		{&"school_damage_pct": 0.20, &"healing_pct": -0.40}
	)
	_add_fate(
		fates,
		&"guardian_path",
		"수호의 길",
		"받는 피해 -20%, 회복 효율 +30%",
		"유파 피해 -10%",
		{&"damage_taken_pct": -0.20, &"healing_pct": 0.30, &"school_damage_pct": -0.10}
	)
	_add_fate(
		fates,
		&"shadow_path",
		"그림자의 길",
		"이동속도 +15%, 회피 +10%p",
		"최대 HP -15%",
		{&"move_speed_pct": 0.15, &"evasion_chance": 0.10, &"max_health_pct": -0.15}
	)
	_add_fate(
		fates,
		&"forbidden_path",
		"금기의 길",
		"유파 자원 +25%, 상태/반응 효과 +20%",
		"받는 피해 +15%",
		{&"school_resource_gain_pct": 0.25, &"school_status_effect_pct": 0.20, &"damage_taken_pct": 0.15}
	)
	_add_fate(
		fates,
		&"seal_path",
		"봉인의 길",
		"오의 준비 +30%, 오의 위력 +25%",
		"비오의 유파 직접 피해 -15%",
		{&"ultimate_charge_gain_pct": 0.30, &"ultimate_power_pct": 0.25, &"non_ultimate_school_damage_pct": -0.15}
	)
	return fates


static func _add_item(
	items: Dictionary,
	item_id: StringName,
	name: String,
	price: int,
	tags: Array[StringName],
	effect_kind: StringName,
	effect_value: float,
	school_payload: Dictionary = {}
) -> void:
	var definition = ItemDefinitionScript.new()
	definition.id = item_id
	definition.display_name = name
	definition.base_price = price
	definition.tags = tags.duplicate()
	definition.effect_kind = effect_kind
	definition.effect_value = effect_value
	definition.school_payload = school_payload.duplicate(true)
	items[item_id] = definition


static func _add_fate(
	fates: Dictionary,
	fate_id: StringName,
	name: String,
	benefit_text: String,
	cost_text: String,
	modifiers: Dictionary
) -> void:
	var definition = FateDefinitionScript.new()
	definition.id = fate_id
	definition.display_name = name
	definition.benefit_text = benefit_text
	definition.cost_text = cost_text
	definition.modifiers = modifiers.duplicate(true)
	fates[fate_id] = definition
