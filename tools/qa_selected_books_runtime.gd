extends SceneTree
## Actual engine-process smoke using production actors; no Main or save writes.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var player = load("res://scripts/player/player_controller.gd").new()
	world.add_child(player)
	player.set_physics_process(false)
	var enemy = load("res://scripts/enemies/enemy_chaser.gd").new()
	enemy.max_health = 1000
	world.add_child(enemy)
	enemy.position = Vector2(60, 0)
	enemy.set_physics_process(false)
	enemy.set_process(false)
	var loadout = load("res://scripts/core/ninjutsu_loadout_state.gd").new()
	world.add_child(loadout)
	loadout.begin_start_draft(&"guiin", 12)
	for index in range(2):
		loadout.choose_start_draft(loadout.start_draft_snapshot().options[0])
	loadout.commit_drafted_start(loadout.start_draft_snapshot().picks)
	loadout.commit_placed_ninjutsu([&"guiin_rakshasa_kicks"], [&"guiin"])
	var controller = load("res://scripts/schools/ninjutsu_auto_controller.gd").new()
	world.add_child(controller)
	controller.configure(player, world, null, loadout)
	if "--support" in OS.get_cmdline_user_args():
		loadout.commit_placed_ninjutsu([&"guiin_demon_step"], [&"guiin"])
		player.set_physics_process(true)
		await create_timer(5.15).timeout
		if not player.request_dash():
			push_error("SUPPORT_RUNTIME_FAIL dash request")
			quit(1)
			return
		await create_timer(0.35).timeout
		if not is_equal_approx(player.move_speed, 276.0):
			push_error("SUPPORT_RUNTIME_FAIL actual dash-end speed")
			quit(1)
			return
		await create_timer(1.2).timeout
		if not is_equal_approx(player.move_speed, 240.0):
			push_error("SUPPORT_RUNTIME_FAIL expired speed")
			quit(1)
			return
		world.queue_free()
		await process_frame
		print("SUPPORT_BOOKS_RUNTIME_PASS real physics dash-end and process duration; no save writes")
		quit(0)
		return
	await create_timer(2.9).timeout
	if enemy.health != 985:
		push_error("SELECTED_BOOKS_RUNTIME_FAIL expected three real-process hits: " + str(enemy.health))
		quit(1)
		return
	loadout.commit_placed_ninjutsu([], [&"guiin"])
	await create_timer(0.4).timeout
	if enemy.health != 985:
		push_error("SELECTED_BOOKS_RUNTIME_FAIL unequipped attack")
		quit(1)
		return
	world.queue_free()
	await process_frame
	print("SELECTED_BOOKS_RUNTIME_PASS real actors and process ticks; no final art or Main cutover claim")
	quit(0)
