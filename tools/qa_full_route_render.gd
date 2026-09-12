extends SceneTree
## Accelerated real-Main wiring/render evidence, not a normal-speed playtest.
## Test-only board expansion; isolated save paths. Never touches player profiles.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1152, 648)
	var main = load("res://scenes/main/main_scene.tscn").instantiate()
	var fixture_id := str(Time.get_ticks_usec())
	main.wallet_storage_path = "user://qa_full_route_" + fixture_id + "_wallet.json"
	main.resume_storage_path = "user://qa_full_route_" + fixture_id + "_resume.json"
	root.add_child(main)
	main._on_title_new_game_requested()
	main.school_selection._choose(&"cheonsul")
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
	await RenderingServer.frame_post_draw
	var error := root.get_texture().get_image().save_png("res://docs/reviews/" + label + ".png")
	if error != OK:
		_fail("capture " + label)
	print("CAPTURE ", label, " ", error)


func _fail(reason: String) -> void:
	push_error("FULL_ROUTE_RENDER_FAILED: " + reason)
	quit(1)
