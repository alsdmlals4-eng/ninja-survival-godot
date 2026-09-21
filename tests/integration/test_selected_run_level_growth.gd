extends GutTest
const MAIN = preload("res://scenes/main/main_scene.tscn")
const ISOLATION = preload("res://tests/helpers/main_storage_isolation.gd")

func _start():
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	main.selected_rules_enabled = true
	add_child(main)
	main.selected_run.begin_new_game()
	var ui = main.selected_run.start_ui
	ui.school_buttons[1].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	ui.confirm_button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	main.wave_spawner.set_process(false)
	return main

func after_each() -> void:
	get_tree().paused = false

func test_real_kills_grant_xp_once_and_level_choice_upgrades_owned_book() -> void:
	var main = await _start()
	assert_true("levels" in main.selected_run)
	if not "levels" in main.selected_run: main.free(); return
	var levels = main.selected_run.levels
	for index in range(12):
		var actor = load("res://scenes/enemies/school_encounter_actor.tscn").instantiate()
		main.add_child(actor)
		actor.configure_definition(EncounterCatalog.actor_definition_for(&"fire_mark_caster"))
		main._wire_enemy(actor)
		actor.take_damage(9999)
		main._on_enemy_died(actor)
	assert_eq(levels.growth.snapshot().xp, 12)
	levels.poll()
	assert_true(get_tree().paused)
	var choices: Array = levels.options
	assert_gte(choices.size(), 2)
	var choice: Dictionary = choices.filter(func(option): return option.kind == "upgrade")[0]
	assert_true(levels.choose(choice))
	assert_eq(levels.growth.rank(StringName(choice.id)), 2)
	assert_eq(levels.growth.pending_choices(), 0)
	assert_true(main.hud.find_child("ExperienceGauge", true, false).get_node("Value").text.contains("Lv.2"))
	get_tree().paused = false
	main.free()

func test_level_growth_survives_boss_rest_save_without_changing_retry_checkpoint() -> void:
	var main = await _start()
	if not "levels" in main.selected_run: assert_true(false); main.free(); return
	var levels = main.selected_run.levels
	levels.growth.grant(12)
	levels.poll()
	var choice: Dictionary = levels.options.filter(func(option): return option.kind == "acquire")[0]
	assert_true(levels.choose(choice))
	get_tree().paused = false
	main.selected_run._waiting_pause_release = false
	main.school_circuit.sync_elapsed(180.0)
	for actor in main.get_children():
		if actor.get_meta(&"school_circuit_role", &"") == &"elite": actor.take_damage(99999)
	main.player.global_position = main.current_trace_pickup.global_position
	main.current_trace_pickup._process(0.75)
	main.school_circuit.sync_elapsed(290.0)
	for actor in main.get_children():
		if actor.get_meta(&"school_circuit_role", &"") == &"boss": actor.take_damage(99999)
	var loaded: Dictionary = main.selected_run.store.load_profile()
	assert_true(loaded.ok)
	var prep = loaded.profile.active_run.preparation
	assert_not_null(prep, "Growth must not make camp-entry transaction fail.")
	if prep is Dictionary:
		assert_eq(int(prep.growth.xp), 40)
		assert_eq(prep.spatial_session.backpack.items.size(), 3)
		assert_eq(loaded.profile.active_run.checkpoint.backpack.items.size(), 2, "Original retry boundary remains intact.")
		assert_true(main.selected_run.adopt(loaded.profile), "Reopen saved camp before departure.")
		var screen = main.selected_run.rest_screen
		screen.action_button("trace", "melee").pressed.emit()
		main.rest_flow_ui.workbench_boss_reward_choices.get_child(0).pressed.emit()
		main.rest_flow_ui.workbench_chest_open_button.pressed.emit()
		main.rest_flow_ui.workbench_route_selected_requested.emit(&"bongma")
		main.rest_flow_ui.fate_selected_requested.emit(StringName(screen.adapter.snapshot().fate_state.candidate_ids[0]))
		assert_false(main.rest_flow_ui.workbench_commit_button.disabled)
		main.rest_flow_ui.workbench_commit_button.pressed.emit()
		var departed: Dictionary = main.selected_run.store.load_profile().profile
		assert_null(departed.active_run.preparation)
		assert_eq(int(departed.active_run.checkpoint.growth.xp), 40)
		assert_true(main.selected_run.adopt(departed), "Reload actual next-field checkpoint.")
		assert_eq(main.selected_run.levels.growth.snapshot().xp, 40)
		assert_eq(main.selected_run.levels.capture().backpack.items.size(), 3)
	main.free()

func test_growth_transaction_rejects_deleting_originals_and_forging_learned_book() -> void:
	var main = await _start()
	var checkpoint: Dictionary = main.selected_run.store.load_profile().profile.active_run.checkpoint
	var progress: Dictionary = main.selected_run.levels.capture()
	var growth = load("res://scripts/core/run_experience_state.gd")
	assert_true(growth.valid_battle_progress(checkpoint, progress))
	var broken := progress.duplicate(true)
	broken.backpack.items.pop_back()
	assert_false(growth.valid_battle_progress(checkpoint, broken))
	broken = progress.duplicate(true)
	broken.growth = {"xp": 12, "spent": 1, "ranks": {}, "learned": ["cheonsul_flame_mark"]}
	assert_false(growth.valid_battle_progress(checkpoint, broken), "A learned receipt without actual bag acquisition is invalid.")
	main.free()

func test_level_acquisition_commits_real_bag_and_respects_school_access() -> void:
	var main = await _start()
	if not "levels" in main.selected_run: assert_true(false); main.free(); return
	var levels = main.selected_run.levels
	levels.growth.grant(12)
	levels.poll()
	var choices: Array = levels.options.filter(func(option): return option.kind == "acquire")
	assert_gt(choices.size(), 0)
	if not choices.is_empty():
		var id: StringName = StringName(choices[0].id)
		assert_eq(load("res://scripts/data/ninjutsu_catalog.gd").definition_for_id(id).school_id, &"cheonsul")
		assert_true(levels.choose(choices[0]))
		assert_true(main.ninjutsu_loadout.active_spell_ids().has(id))
		assert_eq(levels.capture().backpack.items.size(), 3)
	get_tree().paused = false
	main.free()
