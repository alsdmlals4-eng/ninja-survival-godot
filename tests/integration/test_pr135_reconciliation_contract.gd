extends GutTest

func test_reconciled_runtime_exposes_user_approved_front_door_and_auto_combat_consumers() -> void:
	assert_true(ResourceLoader.exists("res://scenes/ui/title_screen.tscn"))
	assert_true(ResourceLoader.exists("res://scripts/combat/basic_weapon_controller.gd"))
	assert_true(ResourceLoader.exists("res://scripts/enemies/school_encounter_actor.gd"))
	assert_true(ResourceLoader.exists("res://scripts/core/ninjutsu_loadout_state.gd"))
	assert_true(FileAccess.file_exists("res://docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md"))
