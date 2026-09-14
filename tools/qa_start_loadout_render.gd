extends SceneTree
## Standalone preparation UI: no Main, wallet, resume or combat side effects.

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1152, 760)
	var ui = load("res://scenes/ui/start_loadout_ui.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	ui._seed = 123
	await _click(ui.school_buttons[1])
	await _click(ui.option_buttons[0])
	await _click(ui.option_buttons[1])
	if ui.session.snapshot().backpack.items.size() != 2:
		_fail("pointer draft")
		return
	await _click(ui.cell_buttons[0])
	await _click(ui.cell_buttons[2])
	if ui.session.snapshot().backpack.items[0].origin_x != 3:
		_fail("pointer placement")
		return
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var result := image.save_png("res://docs/reviews/start-loadout-preparation-20260913.png")
	if result != OK:
		_fail("capture")
		return
	await _click(ui.confirm_button)
	if ui.session.committed_snapshot().is_empty():
		_fail("pointer confirmation")
		return
	print("START_LOADOUT_RUNTIME_PASS pointer draft, placement, confirmation; no combat/save claim")
	ui.queue_free()
	await process_frame
	quit(0)


func _click(button: Button) -> void:
	var center := button.get_global_rect().get_center()
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


func _fail(reason: String) -> void:
	push_error("START_LOADOUT_RUNTIME_FAIL " + reason)
	quit(1)
