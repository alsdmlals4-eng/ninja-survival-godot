extends RefCounted
class_name RestBackpackSession

const BackpackStateScript = preload("res://scripts/backpack/backpack_state.gd")
const BackpackResolutionScript = preload("res://scripts/backpack/backpack_resolution.gd")
const BuildPreviewSnapshotScript = preload("res://scripts/backpack/build_preview_snapshot.gd")

const BUFFER_CAPACITY := 6

enum InputMode {
	NORMAL,
	WHOLE_LAYOUT_MOVE,
}

var _state = null
var _buffer: Array = []
var _pending_bag = null
var input_mode: int = InputMode.NORMAL

var _resolver = null
var _item_defs: Dictionary = {}
var _bag_defs: Dictionary = {}
var _selected_school_id: StringName = &""
var _undo_stack: Array = []
var _redo_stack: Array = []
var _pending_preview_state = null

var state:
	get:
		if _state == null:
			return null
		return _state.copy_value()

var buffer:
	get:
		return _copy_buffer(_buffer)

var pending_bag:
	get:
		if _pending_bag == null:
			return null
		return _pending_bag.copy_value()


func begin(committed_state, resolver, item_defs: Dictionary, bag_defs: Dictionary, selected_school_id: StringName) -> void:
	_state = committed_state.copy_value() if committed_state != null else null
	_resolver = resolver
	_item_defs = item_defs.duplicate()
	_bag_defs = bag_defs.duplicate()
	_selected_school_id = selected_school_id
	_buffer.clear()
	_pending_bag = null
	input_mode = InputMode.NORMAL
	_undo_stack.clear()
	_redo_stack.clear()
	_pending_preview_state = null


func preview_item(instance_id: int, origin: Vector2i, rotation_quarters: int):
	_pending_preview_state = null
	if input_mode != InputMode.NORMAL:
		return _snapshot(_state, BackpackResolutionScript.new().fail(&"whole_layout_mode_active"))
	if _state == null:
		return _snapshot(_state, BackpackResolutionScript.new().fail(&"missing_state"))
	if _resolver == null:
		return _snapshot(_state, BackpackResolutionScript.new().fail(&"missing_resolver"))
	var current = _state.get_item(instance_id)
	if current == null:
		return _snapshot(_state, BackpackResolutionScript.new().fail(&"unknown_item_instance"))

	var candidate = current.copy_value()
	candidate.origin = origin
	candidate.rotation_quarters = posmod(rotation_quarters, 4)
	var legality = _resolver.can_place_item(_state, candidate, _item_defs, _bag_defs)
	if not legality.valid:
		return _snapshot(_state, legality)

	var candidate_state = _state.copy_value()
	if candidate_state.remove_item(instance_id) == null:
		return _snapshot(_state, BackpackResolutionScript.new().fail(&"unknown_item_instance"))
	if not candidate_state.restore_item_instance(candidate):
		return _snapshot(_state, BackpackResolutionScript.new().fail(&"invalid_item_placement"))
	var resolution = _resolver.resolve(candidate_state, _item_defs, _bag_defs, _selected_school_id)
	if resolution.valid:
		_pending_preview_state = candidate_state.copy_value()
	return _snapshot(candidate_state if resolution.valid else _state, resolution)


func commit_item_preview() -> bool:
	if input_mode != InputMode.NORMAL or _pending_preview_state == null:
		return false
	_record_edit()
	_state = _pending_preview_state.copy_value()
	_pending_preview_state = null
	return true


func rotate_item(instance_id: int) -> bool:
	if input_mode != InputMode.NORMAL or _state == null:
		return false
	var current = _state.get_item(instance_id)
	if current == null:
		return false
	var preview = preview_item(instance_id, current.origin, current.rotation_quarters + 1)
	if preview == null or not preview.valid:
		return false
	return commit_item_preview()


func move_item_to_buffer(instance_id: int) -> bool:
	if input_mode != InputMode.NORMAL or _state == null or _buffer.size() >= BUFFER_CAPACITY:
		return false
	var candidate_state = _state.copy_value()
	var removed = candidate_state.remove_item(instance_id)
	if removed == null:
		return false
	_record_edit()
	_state = candidate_state
	_buffer.append(removed.copy_value())
	_pending_preview_state = null
	return true


func place_buffer_item(buffer_index: int, origin: Vector2i, rotation_quarters: int = 0) -> bool:
	if input_mode != InputMode.NORMAL or _state == null or _resolver == null:
		return false
	if buffer_index < 0 or buffer_index >= _buffer.size():
		return false
	var candidate = _buffer[buffer_index].copy_value()
	candidate.origin = origin
	candidate.rotation_quarters = posmod(rotation_quarters, 4)
	var candidate_state = _state.copy_value()
	if not candidate_state.restore_item_instance(candidate):
		return false
	var resolution = _resolver.resolve(candidate_state, _item_defs, _bag_defs, _selected_school_id)
	if not resolution.valid:
		return false
	_record_edit()
	_state = candidate_state
	_buffer.remove_at(buffer_index)
	_pending_preview_state = null
	return true


func set_pending_bag(bag) -> bool:
	if input_mode != InputMode.NORMAL or bag == null or _pending_bag != null:
		return false
	if not _bag_defs.has(bag.definition_id):
		return false
	_pending_bag = bag.copy_value()
	_pending_bag.rotation_quarters = posmod(_pending_bag.rotation_quarters, 4)
	_pending_preview_state = null
	# Acquisition is outside edit history. Do not let Undo cross this irreversible boundary.
	_undo_stack.clear()
	_redo_stack.clear()
	return true


func place_pending_bag(origin: Vector2i, rotation_quarters: int = 0) -> bool:
	if input_mode != InputMode.NORMAL or _state == null or _resolver == null or _pending_bag == null:
		return false
	var candidate_state = _state.copy_value()
	var pending = _pending_bag.copy_value()
	pending.origin = origin
	pending.rotation_quarters = posmod(rotation_quarters, 4)
	var placed: bool = false
	if pending.instance_id > 0:
		placed = candidate_state.restore_bag_instance(pending)
	else:
		placed = candidate_state.add_bag(pending.definition_id, pending.origin, pending.rotation_quarters) > 0
	if not placed:
		return false
	var resolution = _resolver.resolve(candidate_state, _item_defs, _bag_defs, _selected_school_id)
	if not resolution.valid:
		return false
	_record_edit()
	_state = candidate_state
	_pending_bag = null
	_pending_preview_state = null
	return true


func enter_whole_layout_move_mode() -> bool:
	if _state == null or _resolver == null:
		return false
	if input_mode != InputMode.NORMAL:
		return false
	if _pending_bag != null or _pending_preview_state != null:
		return false
	input_mode = InputMode.WHOLE_LAYOUT_MOVE
	return true


func translate_whole_layout(delta: Vector2i) -> bool:
	if input_mode != InputMode.WHOLE_LAYOUT_MOVE or _state == null or _resolver == null:
		return false
	if delta == Vector2i.ZERO:
		return false
	var translated: Dictionary = _resolver.translated_state(_state, delta, _item_defs, _bag_defs)
	if not bool(translated.get("valid", false)):
		return false
	var candidate_state = _state_from_views(
		translated.get("items", {}),
		translated.get("bags", {}),
		_state.next_instance_id
	)
	if candidate_state == null:
		return false
	var resolution = _resolver.resolve(candidate_state, _item_defs, _bag_defs, _selected_school_id)
	if not resolution.valid:
		return false
	_record_edit()
	_state = candidate_state
	_pending_preview_state = null
	return true


func exit_whole_layout_move_mode() -> void:
	input_mode = InputMode.NORMAL


func undo() -> bool:
	if _undo_stack.is_empty():
		return false
	_redo_stack.append(_capture_edit_snapshot())
	var snapshot: Dictionary = _undo_stack.pop_back()
	_restore_edit_snapshot(snapshot)
	_pending_preview_state = null
	return true


func redo() -> bool:
	if _redo_stack.is_empty():
		return false
	_undo_stack.append(_capture_edit_snapshot())
	var snapshot: Dictionary = _redo_stack.pop_back()
	_restore_edit_snapshot(snapshot)
	_pending_preview_state = null
	return true


func commit_failures(chest_count: int, boss_reward_pending: bool, combination_pending: bool) -> Array[StringName]:
	var failures: Array[StringName] = []
	if boss_reward_pending:
		failures.append(&"boss_reward_pending")
	if chest_count > 0:
		failures.append(&"chest_pending")
	if not _buffer.is_empty():
		failures.append(&"buffer_not_empty")
	if _pending_bag != null:
		failures.append(&"pending_bag")
	if _pending_preview_state != null:
		failures.append(&"item_preview_pending")
	if _state == null:
		failures.append(&"missing_state")
	elif _resolver == null:
		failures.append(&"missing_resolver")
	else:
		var resolution = _resolver.resolve(_state, _item_defs, _bag_defs, _selected_school_id)
		if not resolution.valid:
			failures.append(resolution.failure_code if resolution.failure_code != &"" else &"invalid_backpack")
	if combination_pending:
		failures.append(&"combination_pending")
	return failures


func _record_edit() -> void:
	_undo_stack.append(_capture_edit_snapshot())
	_redo_stack.clear()


func _capture_edit_snapshot() -> Dictionary:
	return {
		"state": _state.copy_value() if _state != null else null,
		"buffer": _copy_buffer(_buffer),
		"pending_bag": _pending_bag.copy_value() if _pending_bag != null else null,
	}


func _restore_edit_snapshot(snapshot: Dictionary) -> void:
	var snapshot_state = snapshot.get("state")
	_state = snapshot_state.copy_value() if snapshot_state != null else null
	_buffer = _copy_buffer(snapshot.get("buffer", []))
	var snapshot_bag = snapshot.get("pending_bag")
	_pending_bag = snapshot_bag.copy_value() if snapshot_bag != null else null


func _copy_buffer(source: Array) -> Array:
	var copied: Array = []
	for item in source:
		if item != null:
			copied.append(item.copy_value())
	return copied


func _state_from_views(items: Dictionary, bags: Dictionary, minimum_next_instance_id: int):
	var rebuilt = BackpackStateScript.new()
	for instance_id in _sorted_instance_ids(bags):
		if not rebuilt.restore_bag_instance(bags[instance_id]):
			return null
	for instance_id in _sorted_instance_ids(items):
		if not rebuilt.restore_item_instance(items[instance_id]):
			return null
	rebuilt.next_instance_id = maxi(rebuilt.next_instance_id, minimum_next_instance_id)
	return rebuilt


func _sorted_instance_ids(instances: Dictionary) -> Array[int]:
	var ids: Array[int] = []
	for raw_id in instances.keys():
		ids.append(int(raw_id))
	ids.sort()
	return ids


func _snapshot(preview_state, resolution):
	return BuildPreviewSnapshotScript.new().capture(preview_state, resolution)
