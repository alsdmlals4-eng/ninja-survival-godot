# MainController는 확정 checkpoint만 이어하기로 복원하고, 새 게임은 명시 확인 뒤에만 그 기록을 지운다.
extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")
const ROUTE_STATE_SCRIPT := preload("res://scripts/core/run_route_state.gd")
const BACKPACK_STATE_SCRIPT := preload("res://scripts/backpack/backpack_state.gd")

var _storage_path := "user://gut_main_title_resume_flow.json"


func before_each() -> void:
	_remove_storage_files()


func after_each() -> void:
	_remove_storage_files()


func test_continue_restores_committed_build_into_fresh_active_stage_core_pressure() -> void:
	var seed_main: Node = await _new_main()
	if seed_main == null:
		return
	assert_true(seed_main.run_resume_store.configure(_storage_path))
	seed_main.run_build_state.set_selected_school(&"bongma")
	assert_true(seed_main.ninjutsu_loadout.activate_starter(&"cheonsul"))
	assert_true(seed_main.run_settlement_ledger.record_school_boss(&"cheonsul"))
	assert_true(seed_main.run_resume_store.save_checkpoint(_make_checkpoint(seed_main)))
	seed_main.queue_free()
	await get_tree().process_frame

	var main: Node = await _new_main()
	if main == null:
		return
	assert_true(main.run_resume_store.configure(_storage_path))
	main._refresh_title_resume_state()
	var title := main.get_node("TitleScreen") as CanvasLayer
	assert_false((title.get_node("LogoLockup/MenuButtons/ContinueButton") as Button).disabled)
	main._on_title_continue_requested()
	await get_tree().process_frame

	assert_false(title.visible)
	assert_true(main._combat_enabled)
	assert_eq(main.school_circuit.route_state.active_school_id(), &"bongma")
	assert_eq(main.school_circuit.get_snapshot().get("state"), &"core")
	assert_lt(main._school_circuit_elapsed_seconds, 1.0, "Resume begins at the 0:00 Core-pressure boundary; one test frame may advance the internal clock.")
	assert_eq((main.get_node("HUD/CombatTopBar/Row/PlayLabel") as Label).text, "PLAY 00:00")
	assert_eq(main.ninjutsu_loadout.active_spell_ids(), [&"cheonsul_flame_mark"])
	assert_eq(main.run_build_state.selected_school_id, &"bongma")


func test_new_game_requires_confirmation_before_deleting_the_continue_record() -> void:
	var main: Node = await _new_main()
	if main == null:
		return
	assert_true(main.run_resume_store.configure(_storage_path))
	main.run_build_state.set_selected_school(&"bongma")
	assert_true(main.ninjutsu_loadout.activate_starter(&"cheonsul"))
	assert_true(main.run_resume_store.save_checkpoint(_make_checkpoint(main)))
	main._refresh_title_resume_state()

	main._on_title_new_game_requested()
	var title := main.get_node("TitleScreen") as CanvasLayer
	assert_true((title.get_node("NewGameConfirmPanel") as Control).visible)
	assert_true(main.run_resume_store.has_record())
	main._on_title_new_game_confirmed()
	assert_false(main.run_resume_store.has_record())
	assert_false(title.visible)
	assert_true((main.get_node("SchoolSelectionUI") as CanvasLayer).visible)
	assert_false(main._combat_enabled)


func test_corrupt_continue_record_stays_present_but_cannot_open_combat() -> void:
	var file := FileAccess.open(_storage_path, FileAccess.WRITE)
	assert_not_null(file)
	if file == null:
		return
	file.store_string('{"schema_version":99}')
	file.flush()
	file = null

	var main: Node = await _new_main()
	if main == null:
		return
	assert_true(main.run_resume_store.configure(_storage_path))
	main._refresh_title_resume_state()
	var title := main.get_node("TitleScreen") as CanvasLayer
	var continue_button := title.get_node("LogoLockup/MenuButtons/ContinueButton") as Button
	var status_label := title.get_node("LogoLockup/MenuButtons/ContinueStatusLabel") as Label
	assert_true(continue_button.disabled)
	assert_eq(status_label.text, "이어하기 기록을 확인할 수 없습니다.")
	assert_true(main.run_resume_store.has_record())
	assert_false(main._combat_enabled)


func test_continue_keeps_an_already_consumed_awakening_retry_consumed() -> void:
	var seed_main: Node = await _new_main()
	if seed_main == null:
		return
	assert_true(seed_main.run_resume_store.configure(_storage_path))
	seed_main.run_build_state.set_selected_school(&"bongma")
	assert_true(seed_main.ninjutsu_loadout.activate_starter(&"cheonsul"))
	assert_true(seed_main.run_settlement_ledger.record_school_boss(&"cheonsul"))
	var consumed_checkpoint := _make_checkpoint(seed_main)
	consumed_checkpoint["retry_consumed"] = true
	assert_true(seed_main.run_resume_store.save_checkpoint(consumed_checkpoint))
	seed_main.queue_free()
	await get_tree().process_frame

	var main: Node = await _new_main()
	if main == null:
		return
	assert_true(main.run_resume_store.configure(_storage_path))
	main._on_title_continue_requested()
	await get_tree().process_frame

	assert_true(main.run_checkpoint.is_valid())
	assert_false(main.run_checkpoint.can_retry_school(&"bongma"), "A consumed Awakening retry must not reopen after Continue.")


func _make_checkpoint(main) -> Dictionary:
	var route = ROUTE_STATE_SCRIPT.new()
	assert_true(route.set_provisional_next_school(&"cheonsul"))
	assert_true(route.commit_provisional_next_school())
	assert_true(route.mark_active_school_cleared())
	assert_true(route.set_provisional_next_school(&"bongma"))
	assert_true(route.commit_provisional_next_school())
	var backpack = BACKPACK_STATE_SCRIPT.new().create_starting_state()
	assert_eq(backpack.add_item(&"taijutsu_training", Vector2i(1, 1)), 2)
	return {
		"build": main.run_build_state.get_checkpoint_snapshot(),
		"route": route.get_route_snapshot(),
		"eligible_school_boss_ids": main.run_settlement_ledger.get_snapshot().get("eligible_school_boss_ids", []),
		"circuit": {
			"active_school_id": &"bongma",
			"committed_backpack_state": backpack,
		},
		"loadout": main.ninjutsu_loadout.get_snapshot(),
	}


func _new_main():
	var main := MAIN_SCENE.instantiate()
	add_child_autofree(main)
	await get_tree().process_frame
	return main


func _remove_storage_files() -> void:
	for suffix in ["", ".tmp", ".previous"]:
		var path: String = _storage_path + String(suffix)
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
