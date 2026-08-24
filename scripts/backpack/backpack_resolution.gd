extends RefCounted
class_name BackpackResolution

const RunModifierSetScript = preload("res://scripts/data/run_modifier_set.gd")

var valid: bool = true
var failure_code: StringName = &""
var failure_cells: Array[Vector2i] = []
var active_cells: Dictionary = {}
var item_cells: Dictionary = {}
var adjacency_pairs: Array[Vector2i] = []
var special_bag_hits: Dictionary = {}
var modifiers = RunModifierSetScript.new()


func fail(code: StringName, cells: Array[Vector2i] = []) -> BackpackResolution:
	valid = false
	failure_code = code
	failure_cells = cells.duplicate()
	return self
