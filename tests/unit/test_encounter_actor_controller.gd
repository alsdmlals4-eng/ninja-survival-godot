extends GutTest

const ACTOR := "res://scripts/enemies/school_encounter_actor.gd"
const SCENE := "res://scenes/enemies/school_encounter_actor.tscn"

func test_actor_and_scene_exist() -> void:
	assert_true(ResourceLoader.exists(ACTOR))
	assert_true(ResourceLoader.exists(SCENE))
