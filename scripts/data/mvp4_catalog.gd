extends RefCounted
class_name MVP4Catalog

const MVP3CatalogScript = preload("res://scripts/data/mvp3_catalog.gd")
const ItemDefinitionScript = preload("res://scripts/data/item_definition.gd")
const SpatialRuleDefinitionScript = preload("res://scripts/data/spatial_rule_definition.gd")
const BagDefinitionScript = preload("res://scripts/data/bag_definition.gd")
const CombinationDefinitionScript = preload("res://scripts/data/combination_definition.gd")
const RunModifierSetScript = preload("res://scripts/data/run_modifier_set.gd")

const STARTING_BAG_ID: StringName = &"starting_ninja_bag"

const BASE_ITEM_IDS: Array[StringName] = [
	&"taijutsu_training",
	&"protection_talisman",
	&"fortune_talisman",
	&"ninjutsu_training",
	&"enlightenment",
	&"regeneration_scroll",
	&"ultimate_treatise",
	&"school_emblem",
	&"katana",
	&"shuriken",
	&"bomb",
	&"water_style",
	&"lightning_style",
	&"fire_style",
	&"stealth_art",
	&"poison_needles",
	&"barrier_art",
	&"greater_summoning_circle",
	&"forbidden_talisman",
]

const COMBINATION_RESULT_IDS: Array[StringName] = [
	&"water_mist",
	&"thunder_blade",
	&"explosive_bomb",
]

const PURCHASABLE_BAG_IDS: Array[StringName] = [
	&"small_pouch",
	&"long_pouch",
	&"square_pouch",
	&"tactical_t_pouch",
	&"ninjutsu_l_pouch",
]


static func build_items() -> Dictionary:
	var items: Dictionary = MVP3CatalogScript.build_items()

	_configure_existing_item(items, &"taijutsu_training", Vector2i(1, 1), [&"support", &"movement", &"affinity_guiin"])
	_configure_existing_item(items, &"protection_talisman", Vector2i(1, 2), [&"support", &"survival"])
	_configure_existing_item(items, &"fortune_talisman", Vector2i(1, 1), [&"support", &"economy", &"affinity_heukyeong"])
	_configure_existing_item(items, &"ninjutsu_training", Vector2i(1, 2), [&"support", &"ninjutsu", &"damage"])
	_configure_existing_item(items, &"enlightenment", Vector2i(1, 1), [&"support", &"resource", &"affinity_bongma"])
	_configure_existing_item(items, &"regeneration_scroll", Vector2i(1, 2), [&"support", &"healing"])
	_configure_existing_item(items, &"ultimate_treatise", Vector2i(1, 2), [&"support", &"ultimate", &"affinity_bongma"])
	_configure_existing_item(
		items,
		&"school_emblem",
		Vector2i(2, 2),
		[&"support", &"school", &"ninjutsu_anchor"],
		[_make_rule([&"ninjutsu"], [], SpatialRuleDefinition.Aggregation.PER_DISTINCT_NEIGHBOR, 3, {&"school_damage_pct": 0.03})]
	)

	_add_static_item(
		items, &"katana", "일본도", 35, Vector2i(1, 3),
		[&"weapon", &"melee", &"combo_core", &"affinity_guiin"],
		{&"non_ultimate_school_damage_pct": 0.18},
		[_make_rule([&"element_style"], [], SpatialRuleDefinition.Aggregation.ONCE_IF_ANY, 1, {&"non_ultimate_school_damage_pct": 0.08})]
	)
	_add_static_item(
		items, &"shuriken", "수리검", 20, Vector2i(1, 1),
		[&"weapon", &"ranged", &"connector", &"affinity_heukyeong"],
		{&"non_ultimate_school_damage_pct": 0.05},
		[_make_rule([&"ninjutsu"], [], SpatialRuleDefinition.Aggregation.PER_DISTINCT_NEIGHBOR, 3, {&"non_ultimate_school_damage_pct": 0.03})]
	)
	_add_static_item(
		items, &"bomb", "폭탄", 40, Vector2i(2, 2),
		[&"weapon", &"aoe", &"explosive", &"combo_core", &"affinity_cheonsul"],
		{&"school_damage_pct": 0.16},
		[_make_rule([&"element_style"], [], SpatialRuleDefinition.Aggregation.ONCE_IF_ANY, 1, {&"school_status_effect_pct": 0.10})]
	)
	_add_static_item(
		items, &"water_style", "수둔", 30, Vector2i(1, 2),
		[&"ninjutsu", &"element_style", &"water", &"status", &"combo_core", &"affinity_cheonsul"],
		{&"school_resource_gain_pct": 0.15}
	)
	_add_static_item(
		items, &"lightning_style", "뇌둔", 35, Vector2i(1, 2),
		[&"ninjutsu", &"element_style", &"lightning", &"combo_core", &"affinity_cheonsul", &"affinity_guiin"],
		{&"ultimate_charge_gain_pct": 0.20}
	)
	_add_static_item(
		items, &"fire_style", "화둔", 35, Vector2i(1, 2),
		[&"ninjutsu", &"element_style", &"fire", &"status", &"combo_core", &"affinity_cheonsul"],
		{&"school_damage_pct": 0.10, &"school_status_effect_pct": 0.10}
	)
	_add_static_item(
		items, &"stealth_art", "은신술", 30, Vector2i(1, 2),
		[&"ninjutsu", &"stealth", &"support", &"combo_core", &"affinity_heukyeong"],
		{&"evasion_chance": 0.05},
		[_make_rule([&"weapon"], [], SpatialRuleDefinition.Aggregation.ONCE_IF_ANY, 1, {&"non_ultimate_school_damage_pct": 0.05})]
	)
	_add_static_item(
		items, &"poison_needles", "독침술", 30, Vector2i(1, 2),
		[&"weapon", &"ranged", &"poison", &"status", &"affinity_heukyeong"],
		{&"school_status_effect_pct": 0.15},
		[_make_rule([&"stealth"], [], SpatialRuleDefinition.Aggregation.ONCE_IF_ANY, 1, {&"school_status_effect_pct": 0.10})]
	)
	_add_static_item(
		items, &"barrier_art", "결계술", 40, Vector2i(2, 2),
		[&"ninjutsu", &"survival", &"barrier", &"affinity_bongma"],
		{&"damage_taken_pct": -0.10},
		[_make_rule([&"support"], [], SpatialRuleDefinition.Aggregation.ONCE_IF_ANY, 1, {&"damage_taken_pct": -0.05})]
	)
	_add_static_item(
		items, &"greater_summoning_circle", "대형 소환진", 50, Vector2i(2, 3),
		[&"ninjutsu", &"summon", &"ultimate", &"ritual", &"affinity_bongma"],
		{&"ultimate_power_pct": 0.30, &"school_resource_gain_pct": 0.15},
		[_make_rule([&"barrier"], [&"school_emblem"], SpatialRuleDefinition.Aggregation.ONCE_IF_ANY, 1, {&"ultimate_charge_gain_pct": 0.12})]
	)
	_add_static_item(
		items, &"forbidden_talisman", "금기의 부적", 45, Vector2i(1, 3),
		[&"curse", &"support", &"risk_reward"],
		{&"school_damage_pct": 0.22, &"school_resource_gain_pct": 0.20, &"damage_taken_pct": 0.12}
	)

	_add_static_item(
		items, &"water_mist", "물안개", 0, Vector2i(2, 2), [],
		{&"evasion_chance": 0.10, &"move_speed_pct": 0.08, &"school_status_effect_pct": 0.20}
	)
	_add_static_item(
		items, &"thunder_blade", "뇌명도", 0, Vector2i(1, 3), [],
		{&"non_ultimate_school_damage_pct": 0.28, &"school_resource_gain_pct": 0.10, &"move_speed_pct": 0.05}
	)
	_add_static_item(
		items, &"explosive_bomb", "폭렬탄", 0, Vector2i(2, 2), [],
		{&"school_damage_pct": 0.22, &"non_ultimate_school_damage_pct": 0.10, &"school_status_effect_pct": 0.22, &"damage_taken_pct": 0.05}
	)

	return items


static func build_bags() -> Dictionary:
	var bags := {}
	_add_bag(bags, STARTING_BAG_ID, "기본 가방", 0, _rectangle_cells(Vector2i(4, 3)))
	_add_bag(bags, &"small_pouch", "소형 주머니", 20, [Vector2i(0, 0), Vector2i(1, 0)])
	_add_bag(bags, &"long_pouch", "긴 주머니", 30, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)])
	_add_bag(bags, &"square_pouch", "사각 주머니", 40, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)])
	_add_bag(bags, &"tactical_t_pouch", "전술 T형 주머니", 45, [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1)])
	_add_bag(
		bags,
		&"ninjutsu_l_pouch",
		"인법 L형 주머니",
		50,
		[Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2)],
		&"ninjutsu",
		&"school_resource_gain_pct",
		0.04
	)
	return bags


static func build_combinations() -> Dictionary:
	var combinations := {}
	_add_combination(combinations, &"water_mist", &"water_style", &"stealth_art", &"water_mist")
	_add_combination(combinations, &"thunder_blade", &"katana", &"lightning_style", &"thunder_blade")
	_add_combination(combinations, &"explosive_bomb", &"bomb", &"fire_style", &"explosive_bomb")
	return combinations


static func base_acquisition_item_ids() -> Array[StringName]:
	return BASE_ITEM_IDS.duplicate()


static func combination_result_item_ids() -> Array[StringName]:
	return COMBINATION_RESULT_IDS.duplicate()


static func purchasable_bag_ids() -> Array[StringName]:
	return PURCHASABLE_BAG_IDS.duplicate()


static func validate_catalog() -> Array[String]:
	var items := build_items()
	var errors := validate_items(items)
	errors.append_array(_validate_bags(build_bags()))
	errors.append_array(_validate_combinations(build_combinations(), items))
	return errors


static func validate_items(items: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var expected_ids: Array[StringName] = []
	expected_ids.append_array(BASE_ITEM_IDS)
	expected_ids.append_array(COMBINATION_RESULT_IDS)
	if items.size() != expected_ids.size():
		errors.append("Expected %d item definitions, got %d" % [expected_ids.size(), items.size()])

	var seen := {}
	for expected_id in expected_ids:
		if seen.has(expected_id):
			errors.append("Duplicate expected item id: %s" % expected_id)
		seen[expected_id] = true
		if not items.has(expected_id):
			errors.append("Missing item definition: %s" % expected_id)

	for raw_id in items.keys():
		var item_id := StringName(raw_id)
		var definition = items[item_id]
		if definition == null:
			errors.append("Null item definition: %s" % item_id)
			continue
		if definition.id != item_id:
			errors.append("Item key/id mismatch: %s != %s" % [item_id, definition.id])
		if definition.footprint_size.x <= 0 or definition.footprint_size.y <= 0:
			errors.append("Invalid footprint size: %s" % item_id)
		if not definition.static_modifier_payload.is_empty() and RunModifierSetScript.is_supported_field(definition.effect_kind):
			errors.append("Dual static modifier authority: %s" % item_id)
		for field_name in definition.static_modifier_payload.keys():
			if not RunModifierSetScript.is_supported_field(StringName(field_name)):
				errors.append("Unsupported static modifier %s on %s" % [field_name, item_id])
		for rule in definition.spatial_rules:
			if rule == null:
				errors.append("Null spatial rule on %s" % item_id)
				continue
			if rule.max_matches <= 0:
				errors.append("Spatial rule max_matches must be positive on %s" % item_id)
			if rule.required_neighbor_tags.is_empty() and rule.required_neighbor_definition_ids.is_empty():
				errors.append("Spatial rule requires no neighbor on %s" % item_id)
			for field_name in rule.modifier_payload.keys():
				if not RunModifierSetScript.is_supported_field(StringName(field_name)):
					errors.append("Unsupported spatial modifier %s on %s" % [field_name, item_id])

	for result_id in COMBINATION_RESULT_IDS:
		if BASE_ITEM_IDS.has(result_id):
			errors.append("Combination result leaked into base acquisition ids: %s" % result_id)
	return errors


static func _validate_bags(bags: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if bags.size() != PURCHASABLE_BAG_IDS.size() + 1:
		errors.append("Expected one starting bag plus five purchasable bags")
	if not bags.has(STARTING_BAG_ID):
		errors.append("Missing starting bag")
	else:
		var starting = bags[STARTING_BAG_ID]
		if starting.cells.size() != 12:
			errors.append("Starting bag must contain 12 cells")
	for bag_id in PURCHASABLE_BAG_IDS:
		if not bags.has(bag_id):
			errors.append("Missing purchasable bag: %s" % bag_id)
	for raw_id in bags.keys():
		var bag_id := StringName(raw_id)
		var bag = bags[bag_id]
		if bag == null:
			errors.append("Null bag definition: %s" % bag_id)
			continue
		if bag.id != bag_id:
			errors.append("Bag key/id mismatch: %s != %s" % [bag_id, bag.id])
		if bag.cells.is_empty():
			errors.append("Bag has no cells: %s" % bag_id)
		var seen_cells := {}
		for cell in bag.cells:
			if seen_cells.has(cell):
				errors.append("Bag has duplicate cell %s: %s" % [cell, bag_id])
			seen_cells[cell] = true
		if bag.auxiliary_effect_kind != &"" and not RunModifierSetScript.is_supported_field(bag.auxiliary_effect_kind):
			errors.append("Unsupported bag modifier %s on %s" % [bag.auxiliary_effect_kind, bag_id])
	return errors


static func _validate_combinations(combinations: Dictionary, items: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if combinations.size() != 3:
		errors.append("Expected three first-tier combinations")
	for raw_id in combinations.keys():
		var combo_id := StringName(raw_id)
		var combination = combinations[combo_id]
		if combination == null:
			errors.append("Null combination: %s" % combo_id)
			continue
		if combination.id != combo_id:
			errors.append("Combination key/id mismatch: %s != %s" % [combo_id, combination.id])
		for item_id in [combination.source_a, combination.source_b, combination.result_item]:
			if not items.has(item_id):
				errors.append("Combination %s references missing item %s" % [combo_id, item_id])
	return errors


static func _configure_existing_item(items: Dictionary, item_id: StringName, footprint_size: Vector2i, tags: Array, rules: Array = []) -> void:
	var definition = items.get(item_id)
	if definition == null:
		return
	definition.footprint_size = footprint_size
	definition.tags.clear()
	for tag in tags:
		definition.tags.append(StringName(tag))
	definition.static_modifier_payload = {}
	definition.spatial_rules.clear()
	for rule in rules:
		definition.spatial_rules.append(rule)


static func _add_static_item(items: Dictionary, item_id: StringName, display_name: String, price: int, footprint_size: Vector2i, tags: Array, payload: Dictionary, rules: Array = []) -> void:
	var definition = ItemDefinitionScript.new()
	definition.id = item_id
	definition.display_name = display_name
	definition.base_price = price
	definition.footprint_size = footprint_size
	for tag in tags:
		definition.tags.append(StringName(tag))
	definition.static_modifier_payload = payload.duplicate(true)
	for rule in rules:
		definition.spatial_rules.append(rule)
	items[item_id] = definition


static func _make_rule(required_tags: Array, required_ids: Array, aggregation: int, max_matches: int, payload: Dictionary):
	var rule = SpatialRuleDefinitionScript.new()
	for tag in required_tags:
		rule.required_neighbor_tags.append(StringName(tag))
	for definition_id in required_ids:
		rule.required_neighbor_definition_ids.append(StringName(definition_id))
	rule.aggregation = aggregation
	rule.max_matches = max_matches
	rule.modifier_payload = payload.duplicate(true)
	return rule


static func _add_bag(bags: Dictionary, bag_id: StringName, display_name: String, price: int, cells: Array, affected_item_tag: StringName = &"", auxiliary_effect_kind: StringName = &"", auxiliary_effect_value: float = 0.0) -> void:
	var definition = BagDefinitionScript.new()
	definition.id = bag_id
	definition.display_name = display_name
	definition.base_price = price
	for cell in cells:
		definition.cells.append(Vector2i(cell))
	definition.affected_item_tag = affected_item_tag
	definition.auxiliary_effect_kind = auxiliary_effect_kind
	definition.auxiliary_effect_value = auxiliary_effect_value
	bags[bag_id] = definition


static func _add_combination(combinations: Dictionary, combo_id: StringName, source_a: StringName, source_b: StringName, result_item: StringName) -> void:
	var definition = CombinationDefinitionScript.new()
	definition.id = combo_id
	definition.source_a = source_a
	definition.source_b = source_b
	definition.result_item = result_item
	combinations[combo_id] = definition


static func _rectangle_cells(size: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(maxi(size.y, 0)):
		for x in range(maxi(size.x, 0)):
			cells.append(Vector2i(x, y))
	return cells
