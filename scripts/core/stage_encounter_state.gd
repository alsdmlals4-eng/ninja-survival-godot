extends RefCounted
class_name StageEncounterState

enum State {
	CORE,
	ELITE_WARNING,
	ELITE_ACTIVE,
	TRACE_AVAILABLE,
	TRACE_RECOVERED,
	BOSS_WARNING,
	BOSS_ACTIVE,
	CLEARED,
}

signal elite_warning_requested
signal elite_requested
signal chest_token_requested(amount: int)
signal trace_spawn_requested
signal trace_recovered
signal boss_warning_requested
signal boss_requested
signal boss_cleared
signal normal_spawn_permission_changed(allowed: bool)

var elite_warning_at_seconds: float = 165.0
var elite_spawn_at_seconds: float = 180.0
var boss_warning_earliest_at_seconds: float = 260.0
var boss_appearance_earliest_at_seconds: float = 270.0
var boss_warning_duration_seconds: float = 10.0

var _state: State = State.CORE
var _elapsed_seconds: float = 0.0
var _elite_cleared: bool = false
var _trace_recovered: bool = false
var _boss_requested: bool = false
var _boss_warning_started_at: float = -1.0
var _normal_spawning_allowed: bool = true


func configure_timing(
	new_elite_warning_at_seconds: float,
	new_elite_spawn_at_seconds: float,
	new_boss_warning_earliest_at_seconds: float,
	new_boss_appearance_earliest_at_seconds: float,
	new_boss_warning_duration_seconds: float
) -> bool:
	if _state != State.CORE or _elapsed_seconds != 0.0:
		return false
	if not _timing_is_valid(
		new_elite_warning_at_seconds,
		new_elite_spawn_at_seconds,
		new_boss_warning_earliest_at_seconds,
		new_boss_appearance_earliest_at_seconds,
		new_boss_warning_duration_seconds
	):
		return false

	elite_warning_at_seconds = new_elite_warning_at_seconds
	elite_spawn_at_seconds = new_elite_spawn_at_seconds
	boss_warning_earliest_at_seconds = new_boss_warning_earliest_at_seconds
	boss_appearance_earliest_at_seconds = new_boss_appearance_earliest_at_seconds
	boss_warning_duration_seconds = new_boss_warning_duration_seconds
	return true


func sync_elapsed(new_elapsed_seconds: float) -> bool:
	if not is_finite(new_elapsed_seconds) or new_elapsed_seconds < 0.0:
		return false
	if new_elapsed_seconds < _elapsed_seconds:
		return false

	_elapsed_seconds = new_elapsed_seconds

	if _state == State.CORE and _elapsed_seconds >= elite_warning_at_seconds:
		_state = State.ELITE_WARNING
		elite_warning_requested.emit()

	if _state == State.ELITE_WARNING and _elapsed_seconds >= elite_spawn_at_seconds:
		_state = State.ELITE_ACTIVE
		elite_requested.emit()

	if _state == State.TRACE_RECOVERED and _elapsed_seconds >= boss_warning_earliest_at_seconds:
		_start_boss_warning(boss_warning_earliest_at_seconds)

	if _state == State.BOSS_WARNING:
		var boss_ready_at := maxf(
			boss_appearance_earliest_at_seconds,
			_boss_warning_started_at + boss_warning_duration_seconds
		)
		if _elapsed_seconds >= boss_ready_at and not _boss_requested:
			_boss_requested = true
			_state = State.BOSS_ACTIVE
			_set_normal_spawning_allowed(false)
			boss_requested.emit()

	return true


func mark_elite_cleared() -> bool:
	if _state != State.ELITE_ACTIVE or _elite_cleared:
		return false

	_elite_cleared = true
	_state = State.TRACE_AVAILABLE
	_set_normal_spawning_allowed(false)
	chest_token_requested.emit(1)
	trace_spawn_requested.emit()
	return true


func recover_trace() -> bool:
	if _state != State.TRACE_AVAILABLE or _trace_recovered:
		return false

	_trace_recovered = true
	_state = State.TRACE_RECOVERED
	_set_normal_spawning_allowed(true)
	trace_recovered.emit()

	if _elapsed_seconds >= boss_warning_earliest_at_seconds:
		_start_boss_warning(_elapsed_seconds)
	return true


func mark_boss_cleared() -> bool:
	if _state != State.BOSS_ACTIVE:
		return false
	_state = State.CLEARED
	_set_normal_spawning_allowed(false)
	boss_cleared.emit()
	return true


func normal_spawning_allowed() -> bool:
	return _normal_spawning_allowed


func state_name() -> StringName:
	match _state:
		State.CORE:
			return &"core"
		State.ELITE_WARNING:
			return &"elite_warning"
		State.ELITE_ACTIVE:
			return &"elite_active"
		State.TRACE_AVAILABLE:
			return &"trace_available"
		State.TRACE_RECOVERED:
			return &"trace_recovered"
		State.BOSS_WARNING:
			return &"boss_warning"
		State.BOSS_ACTIVE:
			return &"boss_active"
		State.CLEARED:
			return &"cleared"
	return &"unknown"


func get_snapshot() -> Dictionary:
	return {
		"state": state_name(),
		"elapsed_seconds": _elapsed_seconds,
		"elite_warning_at_seconds": elite_warning_at_seconds,
		"elite_spawn_at_seconds": elite_spawn_at_seconds,
		"boss_warning_earliest_at_seconds": boss_warning_earliest_at_seconds,
		"boss_appearance_earliest_at_seconds": boss_appearance_earliest_at_seconds,
		"boss_warning_duration_seconds": boss_warning_duration_seconds,
		"boss_warning_started_at_seconds": _boss_warning_started_at,
		"elite_cleared": _elite_cleared,
		"trace_recovered": _trace_recovered,
		"boss_requested": _boss_requested,
		"normal_spawning_allowed": _normal_spawning_allowed,
	}


func _start_boss_warning(started_at_seconds: float) -> void:
	if _state != State.TRACE_RECOVERED or _boss_warning_started_at >= 0.0:
		return
	_boss_warning_started_at = started_at_seconds
	_state = State.BOSS_WARNING
	boss_warning_requested.emit()


func _set_normal_spawning_allowed(allowed: bool) -> void:
	if _normal_spawning_allowed == allowed:
		return
	_normal_spawning_allowed = allowed
	normal_spawn_permission_changed.emit(allowed)


func _timing_is_valid(
	new_elite_warning_at_seconds: float,
	new_elite_spawn_at_seconds: float,
	new_boss_warning_earliest_at_seconds: float,
	new_boss_appearance_earliest_at_seconds: float,
	new_boss_warning_duration_seconds: float
) -> bool:
	for value in [
		new_elite_warning_at_seconds,
		new_elite_spawn_at_seconds,
		new_boss_warning_earliest_at_seconds,
		new_boss_appearance_earliest_at_seconds,
		new_boss_warning_duration_seconds,
	]:
		if not is_finite(value) or value < 0.0:
			return false
	if new_elite_warning_at_seconds > new_elite_spawn_at_seconds:
		return false
	if new_elite_spawn_at_seconds > new_boss_warning_earliest_at_seconds:
		return false
	if new_boss_warning_earliest_at_seconds > new_boss_appearance_earliest_at_seconds:
		return false
	return true
