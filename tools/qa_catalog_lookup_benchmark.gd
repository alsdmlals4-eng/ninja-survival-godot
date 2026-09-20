extends SceneTree
## Diagnostic only: measure repeated canonical lookup; no gameplay tuning.
func _initialize() -> void:
	var catalog = load("res://scripts/data/ninjutsu_catalog.gd")
	var start := Time.get_ticks_usec()
	for iteration in range(1000):
		var definition = catalog.definition_for_id(&"bongma_hundred_demon_familiar")
		if definition == null: quit(1); return
	print("CATALOG_LOOKUP_1000_MS ", (Time.get_ticks_usec() - start) / 1000.0)
	quit(0)
