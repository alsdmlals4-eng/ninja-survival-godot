extends GutTest

const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"


func test_validate_items_rejects_unsupported_legacy_effect_kind() -> void:
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	var item = items[&"taijutsu_training"]
	item.static_modifier_payload = {}
	item.effect_kind = &"not_a_real_modifier"
	var errors: Array[String] = catalog.validate_items(items)
	assert_false(errors.is_empty(), "Unsupported legacy effect_kind must fail catalog validation")


func test_validate_items_rejects_non_numeric_static_payload_value() -> void:
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	items[&"katana"].static_modifier_payload = {&"school_damage_pct": "invalid"}
	var errors: Array[String] = catalog.validate_items(items)
	assert_false(errors.is_empty(), "Static modifier payload values must be numeric")


func test_validate_items_rejects_non_numeric_spatial_payload_value() -> void:
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	items[&"katana"].spatial_rules[0].modifier_payload = {&"school_damage_pct": "invalid"}
	var errors: Array[String] = catalog.validate_items(items)
	assert_false(errors.is_empty(), "Spatial modifier payload values must be numeric")
