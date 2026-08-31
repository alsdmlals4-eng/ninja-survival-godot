extends GutTest

const ACTOR_SCENE := preload("res://scenes/enemies/school_encounter_actor.tscn")
const ENCOUNTER_CATALOG_SCRIPT := preload("res://scripts/data/encounter_catalog.gd")
const MANIFEST_PATH := "res://docs/assets/approved/img-02-runtime-visual-core/RUNTIME_VISUAL_CORE_MANIFEST.md"
const MOBILE_ARRAY_CASTER_ID := &"mobile_array_caster"
const MOBILE_ARRAY_CASTER_TEXTURE := "res://assets/runtime/encounters/actors/mobile_array_caster.png"
const MOBILE_ARRAY_CASTER_SHA256 := "1e145d6e00a0322c894cc3b1384a65c9d225b16a700093dd76eb205efd62fbfd"
const MOBILE_ARRAY_CASTER_MANIFEST_ID := "NINJA_RUNTIME_ENCOUNTER_BONGMA_MOBILE_ARRAY_CASTER_01"
const HUNDRED_DEMON_ARRAY_MASTER_ID := &"hundred_demon_array_master"
const HUNDRED_DEMON_ARRAY_MASTER_TEXTURE := "res://assets/runtime/encounters/actors/hundred_demon_array_master.png"
const HUNDRED_DEMON_ARRAY_MASTER_SHA256 := "b97f20076b64e0e84eef2714e5d5551a49648ea97b0583226b31f220d5b9527c"
const HUNDRED_DEMON_ARRAY_MASTER_MANIFEST_ID := "NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_ARRAY_MASTER_01"
const HUNDRED_DEMON_ARRAY_MASTER_VISUAL_SCALE := 0.09


func test_locked_mobile_array_caster_source_and_manifest_are_exact() -> void:
	var definition = ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(MOBILE_ARRAY_CASTER_ID)
	assert_not_null(definition)
	if definition == null:
		return

	assert_eq(definition.visual_asset_path, MOBILE_ARRAY_CASTER_TEXTURE)
	assert_true(ResourceLoader.exists(MOBILE_ARRAY_CASTER_TEXTURE), "The user-locked Elite source must exist at its catalog path.")
	assert_eq(FileAccess.get_sha256(MOBILE_ARRAY_CASTER_TEXTURE).to_lower(), MOBILE_ARRAY_CASTER_SHA256)

	var manifest_text := FileAccess.get_file_as_string(MANIFEST_PATH)
	assert_true(manifest_text.contains(MOBILE_ARRAY_CASTER_MANIFEST_ID))
	assert_true(manifest_text.contains("`assets/runtime/encounters/actors/mobile_array_caster.png`"))
	assert_true(manifest_text.contains(MOBILE_ARRAY_CASTER_SHA256))
	assert_true(manifest_text.contains("SchoolEncounterActor/Visual"))
	assert_true(manifest_text.contains("built-in image model"))
	assert_true(manifest_text.contains("USER_LOCKED"))


func test_locked_mobile_array_caster_binds_to_the_exact_school_actor_visual() -> void:
	if not ResourceLoader.exists(MOBILE_ARRAY_CASTER_TEXTURE):
		return
	var definition = ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(MOBILE_ARRAY_CASTER_ID)
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	assert_true(actor.configure_definition(definition))

	var visual := actor.get_node_or_null("Visual") as Sprite2D
	assert_not_null(visual)
	if visual != null:
		assert_not_null(visual.texture)
		if visual.texture != null:
			assert_eq(visual.texture.resource_path, MOBILE_ARRAY_CASTER_TEXTURE)


func test_locked_hundred_demon_array_master_source_and_manifest_are_exact() -> void:
	var definition = ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(HUNDRED_DEMON_ARRAY_MASTER_ID)
	assert_not_null(definition)
	if definition == null:
		return

	assert_eq(definition.visual_asset_path, HUNDRED_DEMON_ARRAY_MASTER_TEXTURE)
	assert_true(ResourceLoader.exists(HUNDRED_DEMON_ARRAY_MASTER_TEXTURE), "The user-locked Bongma Boss source must exist at its catalog path.")
	assert_eq(FileAccess.get_sha256(HUNDRED_DEMON_ARRAY_MASTER_TEXTURE).to_lower(), HUNDRED_DEMON_ARRAY_MASTER_SHA256)

	var manifest_text := FileAccess.get_file_as_string(MANIFEST_PATH)
	assert_true(manifest_text.contains(HUNDRED_DEMON_ARRAY_MASTER_MANIFEST_ID))
	assert_true(manifest_text.contains("`assets/runtime/encounters/actors/hundred_demon_array_master.png`"))
	assert_true(manifest_text.contains(HUNDRED_DEMON_ARRAY_MASTER_SHA256))
	assert_true(manifest_text.contains("SchoolEncounterActor/Visual"))
	assert_true(manifest_text.contains("built-in image model"))
	assert_true(manifest_text.contains("USER_LOCKED"))


func test_locked_hundred_demon_array_master_binds_to_the_exact_school_actor_visual_at_boss_scale() -> void:
	if not ResourceLoader.exists(HUNDRED_DEMON_ARRAY_MASTER_TEXTURE):
		fail_test("The user-locked Bongma Boss source must exist before visual binding can be verified.")
		return
	var definition = ENCOUNTER_CATALOG_SCRIPT.actor_definition_for(HUNDRED_DEMON_ARRAY_MASTER_ID)
	var actor = ACTOR_SCENE.instantiate()
	add_child_autofree(actor)
	assert_true(actor.configure_definition(definition))

	var visual := actor.get_node_or_null("Visual") as Sprite2D
	assert_not_null(visual)
	if visual != null:
		assert_not_null(visual.texture)
		if visual.texture != null:
			assert_eq(visual.texture.resource_path, HUNDRED_DEMON_ARRAY_MASTER_TEXTURE)
		assert_eq(visual.scale, Vector2.ONE * HUNDRED_DEMON_ARRAY_MASTER_VISUAL_SCALE)
