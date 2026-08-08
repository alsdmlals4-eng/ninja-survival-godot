extends GutTest

const MAIN_SCENE := "res://scenes/main/main_scene.tscn"


func test_main_scene_resource_exists() -> void:
	assert_true(ResourceLoader.exists(MAIN_SCENE), "MVP-0 main scene must exist")
