extends Node
class_name FateController

signal candidates_changed(candidate_ids: Array[StringName])
signal fate_selected(fate_id: StringName)

var candidate_ids: Array[StringName] = []
var selected_this_rest: StringName = &""
var _pending_fate_id: StringName = &""

var _build_state: RunBuildState
var _fate_defs: Dictionary = {}
var _rng: RandomNumberGenerator


func configure(
	build_state: RunBuildState,
	fate_defs: Dictionary,
	rng: RandomNumberGenerator = null
) -> void:
	_build_state = build_state
	_fate_defs = fate_defs.duplicate()
	if rng == null:
		_rng = RandomNumberGenerator.new()
		_rng.randomize()
	else:
		_rng = rng


func begin_rest() -> void:
	selected_this_rest = &""
	_pending_fate_id = &""
	candidate_ids = _roll_candidates()
	candidates_changed.emit(candidate_ids.duplicate())


func choose(fate_id: StringName) -> bool:
	if not choose_pending(fate_id):
		return false
	return _commit_pending()


func choose_pending(fate_id: StringName) -> bool:
	if selected_this_rest != &"" or not candidate_ids.has(fate_id) or _build_state == null:
		return false
	if _build_state.has_fate(fate_id):
		return false
	selected_this_rest = fate_id
	_pending_fate_id = fate_id
	return true


func pending_fate_id() -> StringName:
	return _pending_fate_id


func _is_bound_to_build_state(build_state: RunBuildState) -> bool:
	return _build_state != null and _build_state == build_state


func _can_commit_pending() -> bool:
	return _pending_fate_id != &"" \
		and selected_this_rest == _pending_fate_id \
		and candidate_ids.has(_pending_fate_id) \
		and _build_state != null \
		and not _build_state.has_fate(_pending_fate_id)


func _commit_pending() -> bool:
	if not _can_commit_pending() or not _build_state.select_fate(_pending_fate_id):
		return false
	var committed_fate_id := _pending_fate_id
	_pending_fate_id = &""
	fate_selected.emit(committed_fate_id)
	return true


func can_continue() -> bool:
	return selected_this_rest != &""


func _roll_candidates() -> Array[StringName]:
	var pool: Array[StringName] = []
	if _build_state == null or _rng == null:
		return pool

	for raw_id in _fate_defs.keys():
		var fate_id := StringName(raw_id)
		if not _build_state.has_fate(fate_id):
			pool.append(fate_id)

	if pool.size() < 3:
		return []
	if pool.size() == 3:
		return pool

	var rolled: Array[StringName] = []
	for _i in range(3):
		var index := _rng.randi_range(0, pool.size() - 1)
		rolled.append(pool[index])
		pool.remove_at(index)
	return rolled
