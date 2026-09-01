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
	assert_eq(definitions.size(), 12)
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


func _catalog():
	if not ResourceLoader.exists(CATALOG_PATH):
		return null
	return load(CATALOG_PATH)


func _contains_fragment(errors: Array, fragment: String) -> bool:
	for error in errors:
		if str(error).to_lower().contains(fragment.to_lower()):
			return true
	return false
