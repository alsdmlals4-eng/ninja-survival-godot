extends SceneTree
func _initialize() -> void:
	call_deferred("_run")
func _run() -> void:
	root.size = Vector2i(800, 500)
	var back := ColorRect.new()
	back.color = Color("657886")
	back.size = Vector2(800, 500)
	root.add_child(back)
	for index in range(3):
		var sprite := Sprite2D.new()
		sprite.texture = load("res://docs/assets/approved/img-01-player-runtime-core/player_runtime_move_v2_alpha.png")
		sprite.position = Vector2(190 + index * 250, 250)
		sprite.scale = Vector2.ONE * [0.25, 0.10, 0.05][index]
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		root.add_child(sprite)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("C:/Users/user/Tools/NinjaSurvival-Local/diagnostics/sprite-render-probe-20260921.png")
	quit()
