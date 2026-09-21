extends SceneTree
## Isolated rendering fixture: real player/enemy scenes and breath consumer.
## No MainController/profile/wallet creation; no gameplay save writes.

func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.size = Vector2i(1152, 648)
	var world := Node2D.new()
	root.add_child(world)
	var floor_visual := Sprite2D.new()
	floor_visual.texture = load("res://assets/runtime/visual-core/moonlit_battlefield_floor_tile_v1.png")
	floor_visual.position = Vector2(576, 324)
	world.add_child(floor_visual)
	var player = load("res://scenes/player/player.tscn").instantiate()
	world.add_child(player)
	player.position = Vector2(440, 340)
	player.get_node("Camera2D").enabled = false
	player.process_mode = Node.PROCESS_MODE_DISABLED
	for offset in [Vector2(170, -25), Vector2(240, 50), Vector2(-160, 80)]:
		var enemy = load("res://scenes/enemies/enemy_basic.tscn").instantiate()
		enemy.max_health = 300
		world.add_child(enemy)
		enemy.position = player.position + offset
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
	var runtime = load("res://scripts/schools/cheonsul_runtime.gd").new()
	world.add_child(runtime)
	runtime.configure(player, world)
	runtime.activate()
	runtime.set_process(false)
	runtime._cast_remaining = 999.0
	runtime.reaction_count = 3.0
	if not runtime.try_use_ultimate():
		push_error("Breath render fixture activation rejected")
		quit(1)
		return
	runtime._process(0.3)
	await process_frame
	await RenderingServer.frame_post_draw
	var output := "res://docs/reviews/breath-runtime-20260912.png"
	var result := root.get_texture().get_image().save_png(output)
	print("BREATH_RENDER_CAPTURE ", result, " ", output)
	runtime.deactivate()
	world.queue_free()
	await process_frame
	quit(0 if result == OK else 1)
