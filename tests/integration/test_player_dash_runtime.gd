extends GutTest

const MAIN_SCENE := "res://scenes/main/main_scene.tscn"
const PLAYER_SCENE := "res://scenes/player/player.tscn"


func before_each() -> void:
	_release_movement_actions()


func after_each() -> void:
	_release_movement_actions()


func test_dash_uses_character_body_collision_path_without_teleport_or_mask_change() -> void:
	var player = _spawn_scene(PLAYER_SCENE)
	player.global_position = Vector2.ZERO
	var original_layer: int = player.collision_layer
	var original_mask: int = player.collision_mask

	var wall := StaticBody2D.new()
	wall.collision_layer = 2
	wall.collision_mask = 1
	wall.global_position = Vector2(60.0, 0.0)
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(20.0, 160.0)
	wall_shape.shape = rectangle
	wall.add_child(wall_shape)
	add_child_autofree(wall)
	await get_tree().physics_frame

	player.set_movement_intent(Vector2.RIGHT)
	assert_true(player.request_dash())
	var collided := false
	for _frame in range(30):
		await get_tree().physics_frame
		collided = collided or player.get_slide_collision_count() > 0

	assert_true(collided, "dash must keep the existing move_and_slide collision response")
	assert_gt(player.global_position.x, 0.0, "dash must move through CharacterBody2D physics")
	assert_lt(player.global_position.x, 50.0, "dash must not teleport through the wall")
	assert_almost_eq(player.global_position.y, 0.0, 0.1)
	assert_eq(player.collision_layer, original_layer)
	assert_eq(player.collision_mask, original_mask)


func test_right_pointer_dash_uses_player_camera_canvas_transform() -> void:
	var main = _spawn_scene(MAIN_SCENE)
	var player = main.get_node("Player")
	var camera := player.get_node("Camera2D") as Camera2D
	main._set_combat_enabled(true)
	player.global_position = Vector2(420.0, -180.0)
	camera.zoom = Vector2(1.35, 1.35)
	await get_tree().process_frame
	await get_tree().physics_frame

	var world_offset := Vector2(90.0, -45.0)
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_RIGHT
	event.pressed = true
	event.position = player.get_canvas_transform() * (player.global_position + world_offset)
	var dash_directions: Array[Vector2] = []
	player.dash_started.connect(func(direction: Vector2): dash_directions.append(direction))

	main._unhandled_input(event)

	assert_eq(dash_directions.size(), 1)
	if not dash_directions.is_empty():
		assert_almost_eq(dash_directions[0].x, world_offset.normalized().x, 0.0001)
		assert_almost_eq(dash_directions[0].y, world_offset.normalized().y, 0.0001)
	assert_eq(player.current_dash_charges(), 1)


func test_parsed_space_dashes_once_without_focused_legacy_ultimate_activation() -> void:
	var main = _spawn_scene(MAIN_SCENE)
	main.get_node("SchoolSelectionUI")._choose(&"bongma")
	var player = main.get_node("Player")
	var bongma = main.get_node("SchoolRuntimeHost").active_runtime
	bongma.spirit = 100.0
	bongma.set_process(false)
	player.set_pointer_target(player.global_position + Vector2.RIGHT * 120.0)
	var dash_directions: Array[Vector2] = []
	player.dash_started.connect(func(direction: Vector2): dash_directions.append(direction))
	await get_tree().process_frame

	var space_event := InputEventKey.new()
	space_event.keycode = KEY_SPACE
	space_event.physical_keycode = KEY_SPACE
	space_event.pressed = true
	assert_true(space_event.is_action_pressed(&"dash"), "Space must exercise the real dash InputMap binding")
	assert_true(space_event.is_action_pressed(&"ui_accept"), "regression requires the overlapping legacy action")

	Input.parse_input_event(space_event)
	Input.flush_buffered_events()
	await get_tree().physics_frame
	await get_tree().physics_frame
	var space_release := space_event.duplicate() as InputEventKey
	space_release.pressed = false
	Input.parse_input_event(space_release)
	Input.flush_buffered_events()
	await get_tree().process_frame

	assert_eq(dash_directions.size(), 1, "one parsed Space press must start exactly one player-owned dash")
	assert_eq(player.current_dash_charges(), 1)
	assert_almost_eq(bongma.spirit, 100.0, 0.001, "dash must not spend legacy ultimate spirit")
	assert_almost_eq(bongma.ultimate_time_remaining, 0.0, 0.001, "dash must not invoke the legacy ultimate")


func test_automatic_combat_hud_has_no_ultimate_button() -> void:
	var main = _spawn_scene(MAIN_SCENE)
	main.get_node("SchoolSelectionUI")._choose(&"bongma")
	assert_null(main.get_node_or_null("HUD/UltimateButton"))


func test_combat_disable_clears_pointer_target_before_reenable() -> void:
	var main = _spawn_scene(MAIN_SCENE)
	var player = main.get_node("Player")
	main._set_combat_enabled(true)
	player.set_movement_intent(Vector2.LEFT)
	player.set_pointer_target(player.global_position + Vector2.RIGHT * 120.0)

	main._set_combat_enabled(false)
	main._set_combat_enabled(true)
	watch_signals(player)

	assert_true(player.request_dash())
	assert_signal_emitted_with_parameters(player, "dash_started", [Vector2.LEFT])


func test_control_consumed_click_leaves_pointer_target_unchanged() -> void:
	var main = _spawn_main_in_subviewport()
	var player = main.get_node("Player")
	main._set_combat_enabled(true)
	player.set_pointer_target(player.global_position + Vector2.RIGHT * 120.0)

	var blocker_layer := CanvasLayer.new()
	blocker_layer.layer = 100
	main.add_child(blocker_layer)
	var blocker := Button.new()
	blocker.name = "PointerBlocker"
	blocker.position = Vector2.ZERO
	blocker.size = main.get_viewport_rect().size
	blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	blocker_layer.add_child(blocker)
	await get_tree().process_frame
	var click_position := blocker.get_global_rect().position + blocker.size * Vector2(0.8, 0.8)
	main.get_viewport().push_input(GutInputFactory.mouse_motion(click_position, click_position), true)
	main.get_viewport().push_input(GutInputFactory.mouse_left_button_down(click_position, click_position), true)
	main.get_viewport().push_input(GutInputFactory.mouse_left_button_up(click_position, click_position), true)
	await get_tree().process_frame

	assert_eq(main.get_viewport().gui_get_hovered_control(), blocker)
	watch_signals(player)
	assert_true(player.request_dash())
	assert_signal_emitted_with_parameters(player, "dash_started", [Vector2.RIGHT])


func test_pointer_input_is_ignored_when_combat_disabled_or_game_over() -> void:
	var combat_disabled_main = _spawn_scene(MAIN_SCENE)
	_assert_pointer_input_ignored(combat_disabled_main, "combat-disabled input")

	var game_over_main = _spawn_scene(MAIN_SCENE)
	game_over_main._set_combat_enabled(true)
	game_over_main.game_over = true
	_assert_pointer_input_ignored(game_over_main, "game-over input")


func _assert_pointer_input_ignored(main, context: String) -> void:
	var player = main.get_node("Player")
	player.set_movement_intent(Vector2.LEFT)
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = true
	event.position = player.get_canvas_transform() * (player.global_position + Vector2.RIGHT * 120.0)
	main._unhandled_input(event)
	watch_signals(player)

	assert_true(player.request_dash(), context)
	assert_signal_emitted_with_parameters(player, "dash_started", [Vector2.LEFT])


func _spawn_scene(path: String):
	var packed: PackedScene = load(path)
	assert_not_null(packed)
	if packed == null:
		return null
	var instance = packed.instantiate()
	add_child_autofree(instance)
	return instance


func _spawn_main_in_subviewport():
	var viewport := SubViewport.new()
	viewport.size = Vector2i(640, 360)
	viewport.handle_input_locally = true
	add_child_autofree(viewport)
	var packed: PackedScene = load(MAIN_SCENE)
	assert_not_null(packed)
	if packed == null:
		return null
	var main = packed.instantiate()
	viewport.add_child(main)
	return main


func _release_movement_actions() -> void:
	for action_name in [&"move_left", &"move_right", &"move_up", &"move_down", &"dash"]:
		Input.action_release(action_name)
