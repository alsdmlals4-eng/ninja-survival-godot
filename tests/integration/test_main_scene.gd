extends GutTest

const MAIN_SCENE := "res://scenes/main/main_scene.tscn"
const REQUIRED_RUNTIME_RESOURCES := [
	"res://scripts/core/main_controller.gd",
	"res://scripts/ui/hud.gd",
	"res://scenes/enemies/enemy_basic.tscn",
	"res://scenes/projectiles/projectile_basic.tscn",
]


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


func test_runtime_resources_exist() -> void:
	for path in REQUIRED_RUNTIME_RESOURCES:
		assert_true(ResourceLoader.exists(path), "Missing MVP-0 runtime resource: %s" % path)
