extends SceneTree
## Isolated appearance inspection, never a production scene/asset binding.
func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(1000, 620)
	var picture := Image.load_from_file("res://docs/visual/candidates/player-gameplay-20260921/player-cutout.png")
	if picture == null:
		quit(1)
		return
	var texture := ImageTexture.create_from_image(picture)
	for row in range(2):
		var back := ColorRect.new()
		back.position = Vector2(0, row * 310)
		back.size = Vector2(1000, 310)
		back.color = Color("1d2935") if row == 0 else Color("e5ded1")
		root.add_child(back)
		for column in range(3):
			var sprite := Sprite2D.new()
			sprite.texture = texture
			sprite.position = Vector2(210 + column * 310, 155 + row * 310)
			# Canvas scale is explicit; visible body is slightly smaller.
			sprite.scale = Vector2.ONE * ([280.0, 96.0, 64.0][column] / 1254.0)
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
			root.add_child(sprite)
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("C:/Users/user/Tools/NinjaSurvival-Local/diagnostics/player-candidate-preview-20260921.png")
	print("PLAYER_CANDIDATE_PREVIEW ", result, " isolated light/dark inspection, not Main binding or motion approval")
	quit(0 if result == OK else 1)
