extends RefCounted
class_name BuildPreviewSnapshot

const RunModifierSetScript = preload("res://scripts/data/run_modifier_set.gd")

var valid: bool = false
var failure_code: StringName = &""
var failure_cells: Array[Vector2i] = []
var active_cells: Dictionary = {}
var item_cells: Dictionary = {}
var adjacency_pairs: Array[Vector2i] = []
var special_bag_hits: Dictionary = {}

var _state = null
var _modifiers = RunModifierSetScript.new()

var state:
	get:
		if _state == null:
			return null
		return _state.copy_value()

var modifiers:
	get:
		return _modifiers.copy_values()


func capture(preview_state, resolution) -> BuildPreviewSnapshot:
	_state = preview_state.copy_value() if preview_state != null else null
	if resolution == null:
		valid = false
		failure_code = &"missing_resolution"
		return self

	valid = bool(resolution.valid)
	failure_code = StringName(resolution.failure_code)
	failure_cells = resolution.failure_cells.duplicate()
	active_cells = resolution.active_cells.duplicate(true)
	item_cells = resolution.item_cells.duplicate(true)
	adjacency_pairs = resolution.adjacency_pairs.duplicate()
	special_bag_hits = resolution.special_bag_hits.duplicate(true)
	_modifiers = resolution.modifiers.copy_values()
	return self
