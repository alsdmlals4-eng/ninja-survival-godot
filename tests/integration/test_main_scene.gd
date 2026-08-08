extends GutTest

const MAIN_SCENE := "res://scenes/main/main_scene.tscn"


func test_main_scene_resource_exists() -> void:
	assert_true(ResourceLoader.exists(MAIN_SCENE), "MVP-0 main scene must exist")


func test_main_scene_has_core_nodes() -> void:
	var packed: PackedScene = load(MAIN_SCENE)
	assert_not_null(packed)
	if packed == null:
		return

	var main = packed.instantiate()
	add_child_autofree(main)

	assert_not_null(main.get_node_or_null("GameState"))
	assert_not_null(main.get_node_or_null("Player"))
	assert_not_null(main.get_node_or_null("HUD"))
	assert_not_null(main.get_node_or_null("Player/Camera2D"))
	assert_not_null(main.get_node_or_null("Player/AutoAttack"))
