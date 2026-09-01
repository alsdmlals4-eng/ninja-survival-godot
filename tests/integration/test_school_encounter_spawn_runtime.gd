extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")

func test_selected_stage_spawns_a_catalog_core_actor() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	main._on_school_selected(&"bongma")
	await get_tree().process_frame
	var core_enemy = _first_live_normal_enemy(main)
	assert_not_null(core_enemy, "The selected Stage must immediately maintain its Core horde.")
	if core_enemy == null:
		return
	assert_eq(core_enemy.get_script().resource_path, "res://scripts/enemies/school_encounter_actor.gd")
	assert_eq(core_enemy.get_meta(&"school_circuit_encounter_id", &""), &"seal_chaser")


func _first_live_normal_enemy(main: Node):
	for child in main.get_children():
		if child.is_in_group("enemies") and not child.is_queued_for_deletion():
			return child
	return null
