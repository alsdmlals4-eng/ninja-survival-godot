extends SceneTree
## Diagnostic samples, NOT enemy caps, natural play, target-device acceptance or GPU timings.
## Real selected Main/AI/weapons/rendering; stationary QA player and very high enemy HP.

var main
var omit_collision := false
var stationary_enemies := false
var time_enemy_calls := false
var legacy_contact := false

class SampledActor extends SchoolEncounterActor:
	static var measured_usec := 0
	static var measured_calls := 0
	func _physics_process(delta: float) -> void:
		var begin := Time.get_ticks_usec()
		super._physics_process(delta)
		measured_usec += Time.get_ticks_usec() - begin
		measured_calls += 1

func _initialize() -> void:
	call_deferred("_run")

func _quantile(values: Array[float], fraction: float) -> float:
	var sorted := values.duplicate()
	sorted.sort()
	return sorted[clampi(int(ceil(fraction * sorted.size())) - 1, 0, sorted.size() - 1)]

func _run() -> void:
	omit_collision = OS.get_cmdline_user_args().has("--probe-no-enemy-collision")
	stationary_enemies = OS.get_cmdline_user_args().has("--probe-stationary-enemies")
	time_enemy_calls = OS.get_cmdline_user_args().has("--probe-time-enemies")
	legacy_contact = OS.get_cmdline_user_args().has("--probe-legacy-contact")
	root.size = Vector2i(1280, 720)
	main = load("res://scenes/main/main_scene.tscn").instantiate()
	var prefix := "user://qa_horde_%d_%d" % [OS.get_process_id(), Time.get_ticks_usec()]
	main.profile_storage_path = prefix + "_profile.json"
	main.wallet_storage_path = prefix + "_wallet.json"
	main.resume_storage_path = prefix + "_resume.json"
	root.add_child(main)
	seed(921)
	main.selected_run.begin_new_game()
	main.selected_run.start_ui._seed = 921
	main.selected_run.start_ui.school_buttons[0].pressed.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.option_buttons[0].pressed.emit()
	main.selected_run.start_ui.confirm_button.pressed.emit()
	main.school_selection.school_selected.emit(&"bongma")
	await process_frame
	await process_frame
	main.wave_spawner.set_spawning_enabled(false)
	main.player.max_health = 100000000
	main.player.health = 100000000
	var scene := load("res://scenes/enemies/school_encounter_actor.tscn") as PackedScene
	var rng := RandomNumberGenerator.new()
	rng.seed = 921
	var count := 0
	print("HORDE_PROFILE engine=", Engine.get_version_info().string, " display=", DisplayServer.get_name(), " renderer=", RenderingServer.get_video_adapter_name(), " viewport=", root.size, " vsync=", DisplayServer.window_get_vsync_mode(), " diagnostic_omit_enemy_collision=", omit_collision, " legacy_contact=", legacy_contact, " starter_seed=921 spells=", main.ninjutsu_loadout.active_spell_ids())
	for requested in [100, 300, 600, 1000]:
		var setup_begin := Time.get_ticks_usec()
		while count < requested:
			var enemy = scene.instantiate()
			if time_enemy_calls: enemy.set_script(SampledActor)
			enemy.position = Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(450.0, 900.0)
			main.add_child(enemy)
			main._wire_enemy(enemy)
			if legacy_contact:
				enemy._open_field_contact = false
				enemy.motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
			if omit_collision: enemy.collision_mask = 0
			if stationary_enemies: enemy.set_physics_process(false)
			enemy.max_health = 100000000
			enemy.health = 100000000
			count += 1
		var setup_ms := (Time.get_ticks_usec() - setup_begin) / 1000.0
		var warm_until := Time.get_ticks_msec() + 1500
		while Time.get_ticks_msec() < warm_until: await process_frame
		var frames: Array[float] = []
		SampledActor.measured_usec = 0
		SampledActor.measured_calls = 0
		var cpu: Array[float] = []
		var physics: Array[float] = []
		var sample_until := Time.get_ticks_msec() + 5000
		var previous := Time.get_ticks_usec()
		while Time.get_ticks_msec() < sample_until:
			await process_frame
			var now := Time.get_ticks_usec()
			frames.append((now - previous) / 1000.0)
			previous = now
			cpu.append(Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0)
			physics.append(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0)
		print("HORDE_SAMPLE ", JSON.stringify({"enemies": requested, "observed": get_nodes_in_group("enemies").size(), "frames": frames.size(), "setup_ms": setup_ms,
			"frame_ms_p50": _quantile(frames, 0.5), "frame_ms_p95": _quantile(frames, 0.95), "frame_ms_p99": _quantile(frames, 0.99), "frame_ms_max": frames.max(),
			"engine_process_ms_p95": _quantile(cpu, 0.95), "engine_physics_ms_p95": _quantile(physics, 0.95),
			"memory_bytes": Performance.get_monitor(Performance.MEMORY_STATIC), "nodes": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
			"collision_pairs": Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS), "draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME), "gpu_time": "NOT_MEASURED",
			"instrumented_enemy_calls": SampledActor.measured_calls, "instrumented_enemy_ms": SampledActor.measured_usec / 1000.0}))
	main.queue_free()
	await process_frame
	print("HORDE_PROFILE_COMPLETED not target-device performance approval")
	quit(0)
