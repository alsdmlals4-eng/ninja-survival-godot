extends GutTest

const REQUIRED_SCRIPTS := [
	"res://scripts/core/game_state.gd",
	"res://scripts/player/player_controller.gd",
	"res://scripts/enemies/enemy_chaser.gd",
	"res://scripts/combat/auto_attack_controller.gd",
	"res://scripts/combat/projectile.gd",
]


func test_mvp0_script_resources_exist() -> void:
	for path in REQUIRED_SCRIPTS:
		assert_true(ResourceLoader.exists(path), "Missing MVP-0 script: %s" % path)
