extends GutTest

const MAIN = preload("res://scenes/main/main_scene.tscn")
const ISOLATION = preload("res://tests/helpers/main_storage_isolation.gd")

func test_title_awakening_unlock_then_start_support_and_selected_codex() -> void:
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	main.selected_rules_enabled = true
	add_child_autofree(main)
	main.selected_run.begin_new_game()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.confirm_button.pressed.emit()
	main.school_selection.school_selected.emit(&"bongma")
	await get_tree().process_frame
	main._set_combat_enabled(false)
	var store = main.selected_run.store
	var profile: Dictionary = store.load_profile().profile
	profile.meta.soul_balance = 3
	assert_true(store.transact_profile(profile, int(profile.revision), "test:fund").ok)
	main.selected_run.refresh_title()
	main.title_screen.show_title()
	main.title_screen.awakening_button.pressed.emit()
	assert_false(main.title_screen.support_unlock_button.disabled)
	main.title_screen.support_unlock_button.pressed.emit()
	assert_true(main.title_screen.support_unlock_button.disabled)
	assert_true(main.title_screen.awakening_balance_label.text.contains("닌자소울 · 0"))
	main.title_screen.awakening_close_button.pressed.emit()
	main.title_screen.codex_button.pressed.emit()
	main.title_screen._support_tab.pressed.emit()
	assert_true(main.title_screen.codex_entries.text.contains("근접 비전"))
	assert_true(main.title_screen.codex_entries.text.contains("18%"))
	main.title_screen.codex_close_button.pressed.emit()
	main.selected_run.begin_new_game()
	var ui = main.selected_run.start_ui
	assert_eq(ui.support_buttons.size(), 3)
	ui.option_buttons[0].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	assert_true(ui.confirm_button.disabled)
	ui.support_buttons[1].pressed.emit()
	assert_false(ui.confirm_button.disabled)
	ui.confirm_button.pressed.emit()
	main.school_selection.school_selected.emit(&"cheonsul")
	await get_tree().process_frame
	main._set_combat_enabled(false)
	assert_eq(main.player.health, 120)
	assert_eq(main.player.max_health, 120)
	assert_eq(store.load_profile().profile.active_run.checkpoint.backpack.items.size(), 3)

func test_start_selection_cancel_preserves_prior_profile_bytes() -> void:
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	main.selected_rules_enabled = true
	add_child_autofree(main)
	main.title_screen.new_game_requested.emit()
	var ui = main.selected_run.start_ui
	assert_true(ui.has_signal("cancelled"))
	if not ui.has_signal("cancelled"): return
	ui.cancelled.emit()
	assert_true(main.title_screen.visible)
	assert_false(FileAccess.file_exists(main.profile_storage_path))
	main.title_screen.new_game_requested.emit()
	ui = main.selected_run.start_ui
	ui.option_buttons[0].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	ui.confirm_button.pressed.emit()
	main.school_selection.school_selected.emit(&"guiin")
	await get_tree().process_frame
	main._set_combat_enabled(false)
	var before := FileAccess.get_file_as_bytes(main.profile_storage_path)
	main.selected_run.begin_new_game()
	main.selected_run.start_ui.cancelled.emit()
	assert_eq(FileAccess.get_file_as_bytes(main.profile_storage_path), before)
	assert_true(main.title_screen.visible)

class ReadbackFaultStore:
	extends "res://scripts/core/run_resume_store.gd"
	var fail_read_after_write := false
	var read_blocked := false
	func _open_temporary_file(destination: String) -> FileAccess:
		if fail_read_after_write: read_blocked = true
		return super._open_temporary_file(destination)
	func load_profile() -> Dictionary:
		return {"ok": false, "reason": &"unreadable"} if read_blocked else super.load_profile()

func test_last_soul_retry_recovers_saved_receipt_after_readback_failure() -> void:
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	main.selected_rules_enabled = true
	add_child_autofree(main)
	main.title_screen.new_game_requested.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.confirm_button.pressed.emit()
	main.school_selection.school_selected.emit(&"bongma")
	await get_tree().process_frame
	var fault = ReadbackFaultStore.new()
	fault.configure_profile(main.profile_storage_path)
	var profile: Dictionary = fault.load_profile().profile
	profile.meta.soul_balance = 1
	assert_true(fault.transact_profile(profile, int(profile.revision), "setup:one-soul").ok)
	main.selected_run.store = fault
	assert_true(main.selected_run.adopt(fault.load_profile().profile))
	main._on_player_died()
	fault.fail_read_after_write = true
	main.selected_run.retry()
	assert_true(main.game_over)
	fault.fail_read_after_write = false
	fault.read_blocked = false
	var saved: Dictionary = fault.load_profile().profile
	assert_eq(int(saved.meta.soul_balance), 0)
	assert_true(saved.active_run.retry_consumed)
	assert_true(main.selected_run.can_retry(), "Must recover an applied retry before checking a new retry's balance")
	main.selected_run.retry()
	await get_tree().process_frame
	assert_false(main.game_over)
	assert_eq(fault.load_profile().profile, saved, "Retry recovery must not debit twice")

func test_default_new_game_two_books_independent_battlefield_and_saved_continue() -> void:
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	assert_true("selected_rules_enabled" in main, "Default Main still uses legacy starter flow")
	if not "selected_rules_enabled" in main: main.free(); return
	main.selected_rules_enabled = true
	add_child_autofree(main)
	await get_tree().process_frame
	main.title_screen.new_game_requested.emit()
	assert_not_null(main.selected_run.start_ui)
	assert_false(main._combat_enabled)
	var ui = main.selected_run.start_ui
	ui.school_buttons[2].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	ui.option_buttons[0].pressed.emit()
	ui.confirm_button.pressed.emit()
	assert_true(main.school_selection.visible)
	main.school_selection.school_selected.emit(&"heukyeong")
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(main._combat_enabled)
	assert_eq(main.school_host.selected_school_id, &"guiin")
	assert_eq(main.school_circuit.route_state.active_school_id(), &"heukyeong")
	assert_eq(main.ninjutsu_loadout.get_snapshot().active_spell_ids.size(), 2)
	var loaded: Dictionary = main.selected_run.store.load_profile()
	assert_true(loaded.ok)
	var copy = MAIN.instantiate()
	ISOLATION.prepare(copy)
	copy.selected_rules_enabled = true
	copy.profile_storage_path = main.profile_storage_path
	add_child_autofree(copy)
	main._set_combat_enabled(false)
	copy.title_screen.continue_requested.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(copy._combat_enabled)
	assert_eq(copy.ninjutsu_loadout.get_snapshot(), main.ninjutsu_loadout.get_snapshot())
	assert_eq(copy.school_host.selected_school_id, &"guiin")
	assert_eq(copy.school_circuit.route_state.active_school_id(), &"heukyeong")

# Accelerates encounter time/damage only; this is not natural play/balance evidence.
func test_four_battlefields_rest_choices_and_final_boss_use_selected_profile() -> void:
	var main = MAIN.instantiate()
	ISOLATION.prepare(main)
	main.selected_rules_enabled = true
	add_child_autofree(main)
	main.title_screen.new_game_requested.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.confirm_button.pressed.emit()
	main.school_selection.school_selected.emit(&"bongma")
	await get_tree().process_frame
	await get_tree().process_frame
	var schools := [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
	for index in range(4):
		assert_true(main._combat_enabled)
		assert_eq(main.school_circuit.route_state.active_school_id(), schools[index])
		main.school_circuit.sync_elapsed(180.0)
		var elite = _enemy(main, &"elite")
		assert_not_null(elite)
		if elite == null: return
		elite.take_damage(99999)
		var trace = main.current_trace_pickup
		assert_not_null(trace)
		if trace == null: return
		main.player.global_position = trace.global_position
		trace._process(0.75)
		main.school_circuit.sync_elapsed(290.0)
		var boss = _enemy(main, &"boss")
		assert_not_null(boss)
		if boss == null: return
		boss.take_damage(99999)
		var screen = main.selected_run.rest_screen
		assert_not_null(screen, "School %s must open selected rest" % schools[index])
		if screen == null: return
		assert_false(main._combat_enabled)
		assert_true(main.rest_flow_ui.workbench_view.visible)
		screen.action_button("trace", "melee" if index == 0 else "absorb").pressed.emit()
		main.rest_flow_ui.workbench_boss_reward_choices.get_child(0).pressed.emit()
		main.rest_flow_ui.workbench_chest_open_button.pressed.emit()
		# Keep the 3x3 start constraint; sell received support instead of minting bags.
		for unused in range(6):
			if screen.adapter.spatial.buffer.is_empty(): break
			main.rest_flow_ui.workbench_shop_sell_requested.emit(screen.adapter.spatial.buffer[0].instance_id)
		if index < 3: main.rest_flow_ui.workbench_route_selected_requested.emit(schools[index + 1])
		var fates: Array = screen.adapter.snapshot().fate_state.candidate_ids
		if index < 3 and not fates.is_empty(): main.rest_flow_ui.fate_selected_requested.emit(StringName(fates[0]))
		assert_false(main.rest_flow_ui.workbench_commit_button.disabled, str(screen.adapter.readiness(screen._charge)))
		if main.rest_flow_ui.workbench_commit_button.disabled: return
		if index == 3:
			Input.action_press(&"dash")
			Input.action_press(&"ultimate")
			Input.action_press(&"ui_accept")
		main.rest_flow_ui.workbench_commit_button.pressed.emit()
		await get_tree().process_frame
		await get_tree().process_frame
		if index == 3:
			assert_false(main._combat_enabled, "Final departure must wait for menu inputs to release")
			var saved_final: Dictionary = main.selected_run.store.load_profile().profile
			assert_true(main.selected_run.adopt(saved_final), "Final continue uses the same release gate")
			await get_tree().process_frame
			assert_false(main._combat_enabled)
			for action in [&"dash", &"ultimate", &"ui_accept"]: Input.action_release(action)
			await get_tree().process_frame
			await get_tree().process_frame
			assert_true(main._combat_enabled)
	assert_true(main._final_battle_started)
	assert_eq(main.school_circuit.route_state.clear_order(), schools)
	var final = _enemy(main, &"final_boss")
	assert_not_null(final)
	if final != null: final.take_damage(99999)
	assert_true(main.rest_flow_ui.complete_view.visible)
	var profile: Dictionary = main.selected_run.store.load_profile().profile
	assert_null(profile.active_run, "Final victory must settle once, not leave a resumable farming checkpoint")
	assert_eq(int(profile.meta.soul_balance), 6)

func _enemy(main, role: StringName):
	for child in main.get_children():
		if child.get_meta(&"school_circuit_role", &"") == role and not child.is_queued_for_deletion(): return child
	return null
