extends SceneTree
## Compare imported runtime pixels with the approved source; read-only.
func _initialize() -> void:
	var paths: Array[String] = ["res://docs/assets/approved/img-01-player-runtime-core/player_runtime_move_v2_alpha.png"]
	var catalog = load("res://scripts/data/encounter_catalog.gd")
	paths.append(catalog.actor_definition_for(&"hundred_demon_array_master").visual_asset_path)
	for path in paths:
		if not ResourceLoader.exists(path):
			push_error("Missing runtime texture: " + path)
			quit(1)
			return
		var source := Image.new()
		if source.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) != OK:
			quit(1)
			return
		var texture = load(path)
		var imported: Image = texture.get_image()
		if imported.is_compressed(): imported.decompress()
		source.convert(Image.FORMAT_RGBA8)
		imported.convert(Image.FORMAT_RGBA8)
		var source_bytes := source.get_data()
		var imported_bytes := imported.get_data()
		var alpha_differences := 0
		if source.get_size() != imported.get_size() or source_bytes.size() != imported_bytes.size():
			push_error("Imported dimensions differ: " + path)
			quit(1)
			return
		for index in range(3, source_bytes.size(), 4):
			if source_bytes[index] != imported_bytes[index]: alpha_differences += 1
		print("TEXTURE_READBACK ", path, " size=", imported.get_size(), " alpha_differences=", alpha_differences, " sample=", imported.get_pixel(800, 650))
		if alpha_differences != 0:
			quit(1)
			return
	quit()
