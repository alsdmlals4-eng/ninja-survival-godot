extends GutTest

const CATALOG_PATH := "res://scripts/data/ninjutsu_catalog.gd"
const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]


func test_ninjutsu_catalog_resource_exists() -> void:
	assert_true(ResourceLoader.exists(CATALOG_PATH))


func test_every_school_has_one_starter_elite_scroll_and_boss_scroll() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	var definitions: Dictionary = catalog.build_definitions()
	assert_eq(definitions.size(), 24)
	for school_id in SCHOOL_IDS:
		assert_not_null(catalog.definition_for_lane(school_id, &"starter"))
		assert_not_null(catalog.definition_for_lane(school_id, &"elite_scroll"))
		assert_not_null(catalog.definition_for_lane(school_id, &"boss_scroll"))


func test_ninjutsu_catalog_rejects_a_school_without_boss_scroll() -> void:
	var catalog = _catalog()
	if catalog == null:
		return
	var definitions: Dictionary = catalog.build_definitions()
	definitions.erase(&"heukyeong_chain_execution")
	assert_true(_contains_fragment(catalog.validate_definitions(definitions), "boss_scroll"))


func test_selectable_catalog_has_six_per_school_and_sixty_distinct_start_pairs() -> void:
	var catalog = _catalog()
	var definitions: Dictionary = catalog.build_definitions()
	var pair_count := 0
	for school_id in SCHOOL_IDS:
		var ids: Array = []
		for definition in definitions.values():
			if definition.school_id == school_id:
				ids.append(definition.ninjutsu_id)
		assert_eq(ids.size(), 6)
		pair_count += ids.size() * (ids.size() - 1) / 2
	assert_eq(pair_count, 60)
	assert_true(catalog.validate_definitions(definitions).is_empty())


func test_effect_data_copy_is_independent_and_optional_numbers_are_validated() -> void:
	var catalog = _catalog()
	var definition = catalog.definition_for_id(&"bongma_talisman_wheel")
	assert_eq(definition.effect_config.get("damage"), 5.0)
	assert_eq(definition.effect_config.get("max_hits_per_target"), 2)
	var copied = definition.copy_value()
	copied.effect_config["damage"] = 99.0
	copied.tags.append(&"survival")
	assert_eq(definition.effect_config["damage"], 5.0)
	assert_false(definition.tags.has(&"survival"))
	var definitions: Dictionary = catalog.build_definitions()
	definitions[&"bongma_seal_chain"].effect_config["link_range"] = NAN
	assert_false(catalog.validate_definitions(definitions).is_empty())


func _catalog():
	if not ResourceLoader.exists(CATALOG_PATH):
		return null
	return load(CATALOG_PATH)


func _contains_fragment(errors: Array, fragment: String) -> bool:
	for error in errors:
		if str(error).to_lower().contains(fragment.to_lower()):
			return true
	return false
