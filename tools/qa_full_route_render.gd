extends SceneTree
## Accelerated real-Main wiring/render evidence, not a normal-speed playtest.
## Test-only board expansion; isolated save paths. Never touches player profiles.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1152, 648)
	var main = load("res://scenes/main/main_scene.tscn").instantiate()
	var fixture_id := str(Time.get_ticks_usec())
	print("QA_FIXTURE_ID ", fixture_id)
	main.wallet_storage_path = "user://qa_full_route_" + fixture_id + "_wallet.json"
	main.resume_storage_path = "user://qa_full_route_" + fixture_id + "_resume.json"
	main.profile_storage_path = "user://qa_full_route_" + fixture_id + "_profile.json"
	main.selected_rules_enabled = false # Explicitly a legacy regression probe.
	root.add_child(main)
	main._on_title_new_game_requested()
	if "--heukyeong" in OS.get_cmdline_user_args():
		main.school_selection._choose(&"heukyeong")
		await _heukyeong_capture(main)
		return
	if "--bongma" in OS.get_cmdline_user_args():
		main.school_selection._choose(&"bongma")
		await _bongma_capture(main)
		return
	if "--guiin" in OS.get_cmdline_user_args():
		main.school_selection._choose(&"guiin")
		await _guiin_capture(main)
		return
	main.school_selection._choose(&"cheonsul")
	if "--cheonsul" in OS.get_cmdline_user_args():
		await _cheonsul_capture(main)
		return
	paused = true
	var circuit = main.school_circuit
	circuit._rng.seed = 178
	var order: Array[StringName] = [&"cheonsul", &"bongma", &"guiin", &"heukyeong"]
	for index in range(4):
		if not circuit.sync_elapsed(180.0):
			_fail("elite gate")
			return
		var elite = _actor(main, &"elite")
		if elite == null:
			_fail("elite actor")
			return
		elite.take_damage(99999)
		var trace = main.current_trace_pickup
		if trace == null:
			_fail("trace actor")
			return
		main.player.global_position = trace.global_position
		trace._process(0.75)
		circuit.sync_elapsed(280.0)
		var boss = _actor(main, &"boss")
		if boss == null:
			_fail("school boss")
			return
		boss.take_damage(99999)
		if "--shop" in OS.get_cmdline_user_args():
			if not circuit.choose_boss_reward(0) or not circuit.open_chest():
				_fail("shop rewards")
				return
			main._render_school_circuit_workbench()
			await _capture("preparation-shop-buffer-20260912")
			var ui = main.get_node("RestFlowUI")
			var held_count: int = circuit.workbench_snapshot().buffer.size()
			var refund: int = circuit.workbench_snapshot().buffer[0].sell_price
			var gold_before: int = main.run_build_state.gold
			await _click(ui.workbench_buffer_items.get_child(0))
			if ui.workbench_buffer_sell_button.disabled:
				_fail("pointer buffer selection")
				return
			await _capture("preparation-shop-buffer-selected-20260912")
			await _click(ui.workbench_buffer_sell_button)
			if circuit.workbench_snapshot().buffer.size() != held_count - 1 or main.run_build_state.gold != gold_before + refund:
				_fail("pointer sale transaction")
				return
			print("SHOP_RENDER_OK: actual preparation, pointer selection/sale, exact refund; no fixture board expansion")
			main.queue_free()
			await process_frame
			quit(0)
			return
		if not circuit.choose_boss_reward(0) or not circuit.open_chest() or not _place_rewards(circuit):
			_fail("reward preparation")
			return
		if not circuit.choose_fate(circuit.workbench_snapshot()["fate_candidate_ids"][0]):
			_fail("fate")
			return
		if index < 3:
			circuit.choose_next_route(order[index + 1])
		else:
			main._render_school_circuit_workbench()
			await _capture("full-route-final-preparation-20260912")
		main.get_node("RestFlowUI").workbench_commit_requested.emit()
	var final_boss = _actor(main, &"final_boss")
	if final_boss == null:
		_fail("final actor")
		return
	final_boss.pattern_controller.force_start_for_test()
	await _capture("full-route-final-battle-20260912")
	final_boss.take_damage(99999)
	await _capture("full-route-complete-20260912")
	print("FULL_ROUTE_RENDER_OK: accelerated four-school route, final actor, complete screen; isolated storage")
	main.queue_free()
	await process_frame
	quit(0)


func _heukyeong_capture(main: Node) -> void:
	main.player.get_node("Camera2D").force_update_scroll()
	var targets: Array = []
	for index in range(4):
		var enemy = load("res://scenes/enemies/enemy_basic.tscn").instantiate()
		enemy.max_health = 1000
		main.add_child(enemy)
		enemy.global_position = main.player.global_position + Vector2(80 + index * 60, 30)
		enemy.set_meta(&"school_circuit_role", [&"", &"", &"elite", &"boss"][index])
		targets.append(enemy)
	main.school_host.active_runtime.execution_charge = 3.0
	main.hud.ultimate_button.pressed.emit()
	if targets[3].health != 974 or targets[2].health != 982 or targets[0].health != 982 or targets[1].health != 1000:
		_fail("heukyeong priority damage")
		return
	await _capture("heukyeong-execution-runtime-20260912")
	print("HEUKYEONG_RUNTIME_OK: real Main input, role-priority bounded damage, no marks required; role fixture actors, not production boss art or final VFX")
	main.queue_free()
	await process_frame
	quit(0)


func _cheonsul_capture(main: Node) -> void:
	main.player.get_node("Camera2D").force_update_scroll()
	var enemy = load("res://scenes/enemies/enemy_basic.tscn").instantiate()
	enemy.max_health = 1000
	main.add_child(enemy)
	enemy.global_position = main.player.global_position + Vector2(150, 0)
	var runtime = main.school_host.active_runtime
	runtime._cast_remaining = 999.0
	runtime.reaction_count = 3.0
	main.hud.ultimate_button.pressed.emit()
	if runtime._breath_remaining <= 0.0 or enemy.health != 992:
		_fail("cheonsul breath activation")
		return
	runtime._process(0.25)
	await _capture("cheonsul-breath-lifecycle-20260912")
	main._set_combat_enabled(false)
	if runtime._breath_remaining != 0.0 or runtime._breath_visual.visible:
		_fail("cheonsul preparation cleanup")
		return
	print("CHEONSUL_RENDER_OK: actual Main button, forward breath, preparation cleanup; isolated storage")
	main.queue_free()
	await process_frame
	quit(0)


func _bongma_capture(main: Node) -> void:
	main.player.get_node("Camera2D").force_update_scroll()
	for point in [Vector2(60, 0), Vector2(180, 80), Vector2(-150, 30)]:
		var enemy = load("res://scenes/enemies/enemy_basic.tscn").instantiate()
		enemy.max_health = 1000
		main.add_child(enemy)
		enemy.global_position = main.player.global_position + point
	var runtime = main.school_host.active_runtime
	runtime.spirit = 120.0
	main.hud.ultimate_button.pressed.emit()
	if not is_instance_valid(runtime._temporary_familiar) or not is_instance_valid(runtime._second_temporary_familiar) or runtime.spirit != 20.0:
		_fail("bongma dedicated summons")
		return
	await _capture("bongma-dedicated-familiars-20260912")
	main._set_combat_enabled(false)
	if runtime._temporary_familiar != null or runtime._second_temporary_familiar != null:
		_fail("bongma preparation cleanup")
		return
	print("BONGMA_RENDER_OK: actual Main button, two dedicated summons, preparation cleanup; isolated storage; legacy familiar art")
	main.queue_free()
	await process_frame
	quit(0)


func _guiin_capture(main: Node) -> void:
	main.player.get_node("Camera2D").force_update_scroll()
	for point in [Vector2(60, 0), Vector2(110, 50), Vector2(-100, 20)]:
		var enemy = load("res://scenes/enemies/enemy_basic.tscn").instantiate()
		enemy.max_health = 1000
		main.add_child(enemy)
		enemy.global_position = main.player.global_position + point
	main.school_host.active_runtime._set_gwihyeol(100.0, true)
	main.hud.ultimate_button.pressed.emit()
	if not main.combat_resolver.sword_only_mode:
		_fail("guiin mode not active")
		return
	await _capture("guiin-sword-runtime-20260912")
	print("GUIIN_RENDER_OK: actual Main ultimate input, temporary sword; isolated storage; legacy effect art")
	main.queue_free()
	await process_frame
	quit(0)


func _click(button: Control) -> void:
	var point := button.get_global_rect().get_center()
	for pressed in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.pressed = pressed
		event.position = point
		event.global_position = point
		Input.parse_input_event(event)
		await process_frame
	await process_frame


func _actor(main: Node, role: StringName):
	for child in main.get_children():
		if child.get_meta(&"school_circuit_role", &"") == role and not child.is_queued_for_deletion():
			return child
	return null


func _place_rewards(circuit) -> bool:
	var state = circuit._backpack_session._state
	if state.bags.size() == 1:
		for y in [0, 4, 5]:
			for x in [0, 2, 4]:
				state.add_bag(&"small_pouch", Vector2i(x, y))
		for x in [0, 4, 5]:
			state.add_bag(&"long_pouch", Vector2i(x, 1), 1)
	while not circuit._backpack_session.buffer.is_empty():
		var placed := false
		for rotation in range(4):
			for y in range(6):
				for x in range(6):
					if circuit.place_buffer_item(0, Vector2i(x, y), rotation):
						placed = true
						break
				if placed:
					break
			if placed:
				break
		if not placed:
			return false
	return true


func _capture(label: String) -> void:
	# Keep the real camera/parallax/layout processing; freeze gameplay only.
	var main = root.get_child(root.get_child_count() - 1)
	main.set_process(false)
	for child in main.get_children():
		if child.is_in_group("enemies") or child is RewardOrb or child.name in ["Player", "WaveSpawner", "SchoolRuntimeHost", "CombatDDD", "NinjutsuAutoController"]:
			child.process_mode = Node.PROCESS_MODE_DISABLED
	main.player.get_node("Camera2D").force_update_scroll()
	paused = false
	await process_frame
	await process_frame
	if label.begins_with("preparation-shop-buffer"):
		main.get_node("RestFlowUI/Panel/Margin").scroll_vertical = 0
		await process_frame
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://docs/reviews/" + label + ".png")
	if error != OK:
		_fail("capture " + label)
	print("CAPTURE ", label, " ", error)


func _fail(reason: String) -> void:
	push_error("FULL_ROUTE_RENDER_FAILED: " + reason)
	quit(1)
