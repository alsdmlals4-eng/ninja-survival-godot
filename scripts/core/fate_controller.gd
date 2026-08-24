extends Node
class_name FateController

signal candidates_changed(candidate_ids: Array[StringName])
signal fate_selected(fate_id: StringName)

var candidate_ids: Array[StringName] = []
var selected_this_rest: StringName = &""

var _build_state: RunBuildState
var _fate_defs: Dictionary = {}
var _rng: RandomNumberGenerator
var _pending_for_atomic_commit: bool = false


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
	_pending_for_atomic_commit = false
	candidate_ids = _roll_candidates()
	candidates_changed.emit(candidate_ids.duplicate())


# MVP-3 compatibility path used by the current MainController until T13 migrates
# the live Workbench flow to RestCommitCoordinator.
func choose(fate_id: StringName) -> bool:
	if selected_this_rest != &"":
		return false
	if not candidate_ids.has(fate_id):
		return false
	if _build_state == null or not _build_state.select_fate(fate_id):
		return false
	selected_this_rest = fate_id
	_pending_for_atomic_commit = false
	fate_selected.emit(fate_id)
	return true


# DEC-025/T12 path. Selection stays pending until RestCommitCoordinator commits
# backpack + Fate + provisional route as one transaction boundary.
func choose_pending(fate_id: StringName) -> bool:
	if selected_this_rest != &"":
		return false
	if not candidate_ids.has(fate_id):
		return false
	if _build_state == null or _build_state.has_fate(fate_id):
		return false
	selected_this_rest = fate_id
	_pending_for_atomic_commit = true
	fate_selected.emit(fate_id)
	return true


func can_continue() -> bool:
	return selected_this_rest != &""


func _can_commit_pending() -> bool:
	return _pending_for_atomic_commit \
		and _build_state != null \
		and selected_this_rest != &"" \
		and candidate_ids.has(selected_this_rest) \
		and not _build_state.has_fate(selected_this_rest)


func _commit_pending() -> bool:
	if not _can_commit_pending():
		return false
	if not _build_state.select_fate(selected_this_rest):
		return false
	_pending_for_atomic_commit = false
	return true


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
