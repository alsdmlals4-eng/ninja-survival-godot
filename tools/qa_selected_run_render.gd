extends SceneTree
## Real controls/rendering with accelerated encounter time and damage only.
## Isolated profiles; no claim of natural play, human UX or device approval.

var main
var output := ""

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(1152, 760)
	output = "C:/Users/user/Tools/NinjaSurvival-Local/diagnostics/selected-run-" + str(Time.get_ticks_usec())
	DirAccess.make_dir_recursive_absolute(output)
	main = load("res://scenes/main/main_scene.tscn").instantiate()
	var fixture := "user://qa_selected_" + str(Time.get_ticks_usec())
	main.wallet_storage_path = fixture + "_wallet.json"
	main.resume_storage_path = fixture + "_resume.json"
	main.profile_storage_path = fixture + "_profile.json"
	root.add_child(main)
	await process_frame
	await _click(main.title_screen.start_button)
	var ui = main.selected_run.start_ui
	if ui == null: _fail("title input"); return
	await _click(ui.school_buttons[1])
	await _click(ui.option_buttons[0])
	await _click(ui.option_buttons[0])
	await _capture("start")
	await _click(ui.confirm_button)
	await _click(main.school_selection.get_node("Panel/Margin/Choices/BongmaButton"))
	await create_timer(2.0).timeout
	if not main._combat_enabled: _fail("battlefield input"); return
	await _capture("battle")
	main.school_circuit.sync_elapsed(180.0)
	var elite = _actor(&"elite")
	if elite == null: _fail("elite"); return
	elite.take_damage(99999)
	var trace = main.current_trace_pickup
	main.player.global_position = trace.global_position
	trace._process(0.75)
	main.school_circuit.sync_elapsed(290.0)
	var boss = _actor(&"boss")
	if boss == null: _fail("boss"); return
	boss.take_damage(99999)
	await process_frame
	await process_frame
	var screen = main.selected_run.rest_screen
	if screen == null: _fail("rest"); return
	await _capture("rest-entry")
	await _click(screen.action_button("trace", "absorb"))
	if not screen.adapter.snapshot().access.trace_decisions.has("bongma"): _fail("trace input"); return
	await _click(main.rest_flow_ui.workbench_boss_reward_choices.get_child(0))
	await _click(main.rest_flow_ui.workbench_chest_open_button)
	await _capture("rest-rewards")
	# Buffer carry is legitimate and avoids adding test-only free bag area.
	await _click(main.rest_flow_ui.workbench_route_cards.get_child(1))
	await _click(main.rest_flow_ui.workbench_fate_candidates.get_child(0))
	await _capture("rest-departure")
	if main.rest_flow_ui.workbench_commit_button.disabled: _fail("departure readiness"); return
	await _click(main.rest_flow_ui.workbench_commit_button)
	await process_frame
	if not main._combat_enabled or main.school_circuit.route_state.active_school_id() == &"bongma": _fail("departure input"); return
	# Isolated QA funding only: verify the real awakening and support controls.
	main._set_combat_enabled(false)
	var store = main.selected_run.store
	var profile: Dictionary = store.load_profile().profile
	profile.meta.soul_balance = 3
	if not store.transact_profile(profile, int(profile.revision), "qa:fund").ok: _fail("qa funding"); return
	main.title_screen.show_title()
	main.selected_run.refresh_title()
	await _click(main.title_screen.awakening_button)
	await _click(main.title_screen.support_unlock_button)
	await _capture("awakening")
	if not store.load_profile().profile.meta.unlocked_support_choice: _fail("awakening input"); return
	await _click(main.title_screen.awakening_close_button)
	await _click(main.title_screen.codex_button)
	await _click(main.title_screen._support_tab)
	await _capture("codex-support")
	await _click(main.title_screen.codex_close_button)
	await _click(main.title_screen.start_button)
	await _click(main.title_screen.new_game_confirm_button)
	ui = main.selected_run.start_ui
	await _click(ui.option_buttons[0])
	await _click(ui.option_buttons[0])
	await _click(ui.support_buttons[1])
	await _capture("start-support")
	if ui.confirm_button.disabled or ui.session.snapshot().backpack.items.size() != 3: _fail("support input"); return
	await _click(ui.cancel_button)
	# Recovery exercise writes only this QA profile; production profile is untouched.
	var original := FileAccess.get_file_as_bytes(main.profile_storage_path)
	var previous := FileAccess.open(main.profile_storage_path + ".previous", FileAccess.WRITE)
	previous.store_buffer(original)
	previous.close()
	var broken := FileAccess.open(main.profile_storage_path, FileAccess.WRITE)
	broken.store_string("qa corrupt source")
	broken.close()
	main.selected_run.refresh_title()
	await _click(main.title_screen.recovery_button)
	await _click(main.selected_run.recovery_ui.choice_buttons[1])
	await _capture("recovery-choice")
	await _click(main.selected_run.recovery_ui.confirm_button)
	if FileAccess.get_file_as_bytes(main.profile_storage_path) != original: _fail("recovery publication"); return
	await _capture("recovered-title")
	print("SELECTED_RUN_RENDER_PASS ", output, " actual pointer start/trace/reward/route/fate/departure; accelerated battle gates")
	main.queue_free()
	await process_frame
	quit(0)

func _click(button: Button) -> void:
	if button == null or button.disabled: _fail("unavailable button"); return
	# Focus-follow scrolling is the same Control path available to a keyboard user.
	button.grab_focus()
	await process_frame
	await process_frame
	var center := button.get_global_rect().get_center()
	if not Rect2(Vector2.ZERO, Vector2(root.size)).has_point(center): _fail("offscreen button: " + button.text); return
	print("INPUT_TARGET ", button.text, " rect=", button.get_global_rect(), " focus=", button.has_focus(), " viewport=", root.size)
	var motion := InputEventMouseMotion.new()
	motion.position = center
	Input.parse_input_event(motion)
	await process_frame
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.position = center
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame
	await process_frame

func _actor(role: StringName):
	for child in main.get_children():
		if child.get_meta(&"school_circuit_role", &"") == role and not child.is_queued_for_deletion(): return child
	return null

func _capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	if root.get_texture().get_image().save_png(output.path_join(label + ".png")) != OK: _fail("capture")
	print("CAPTURE ", output.path_join(label + ".png"))

func _fail(reason: String) -> void:
	push_error("SELECTED_RUN_RENDER_FAIL " + reason)
	quit(1)
