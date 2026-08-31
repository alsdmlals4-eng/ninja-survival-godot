extends Node
class_name EncounterPatternController

signal state_changed(state: StringName, pattern: Dictionary)
signal execute_requested(pattern: Dictionary)

const State := {
	"chase": &"chase",
	"telegraph": &"telegraph",
	"execute": &"execute",
	"recovery": &"recovery",
}

var _patterns: Array[Dictionary] = []
var _pattern_index := 0
var _state: StringName = State.chase
var _remaining := 0.65
var _active_pattern: Dictionary = {}


func configure(patterns: Array[Dictionary]) -> bool:
	if patterns.is_empty():
		return false
	var copied: Array[Dictionary] = []
	for pattern in patterns:
		if not _is_valid_pattern(pattern):
			return false
		copied.append(pattern.duplicate(true))
	_patterns = copied
	_pattern_index = 0
	_state = State.chase
	_remaining = 0.65
	_active_pattern = {}
	return true


func advance(delta: float) -> void:
	if delta <= 0.0 or _patterns.is_empty():
		return
	if _state == State.chase:
		_remaining = maxf(_remaining - delta, 0.0)
		if _remaining <= 0.0:
			_enter_telegraph()
		return
	_remaining = maxf(_remaining - delta, 0.0)
	if _remaining > 0.0:
		return
	match _state:
		State.telegraph:
			_enter_execute()
		State.execute:
			_enter_recovery()
		State.recovery:
			_enter_chase()


func force_start_for_test() -> bool:
	if _patterns.is_empty():
		return false
	_enter_telegraph()
	return true


func state_name() -> StringName:
	return _state


func active_pattern() -> Dictionary:
	return _active_pattern.duplicate(true)


func current_telegraph_duration() -> float:
	return float(_active_pattern.get("telegraph_duration", 0.0))


func current_execute_duration() -> float:
	return float(_active_pattern.get("execute_duration", 0.0))


func has_telegraph(pattern_id: StringName) -> bool:
	for pattern in _patterns:
		if StringName(pattern.get("primitive_id", &"")) == pattern_id and float(pattern.get("telegraph_duration", 0.0)) > 0.0:
			return true
	return false


func has_recovery(pattern_id: StringName) -> bool:
	for pattern in _patterns:
		if StringName(pattern.get("primitive_id", &"")) == pattern_id and float(pattern.get("recovery_duration", 0.0)) > 0.0:
			return true
	return false


func _enter_telegraph() -> void:
	_active_pattern = _patterns[_pattern_index].duplicate(true)
	_state = State.telegraph
	_remaining = float(_active_pattern.get("telegraph_duration", 0.0))
	state_changed.emit(_state, active_pattern())


func _enter_execute() -> void:
	_state = State.execute
	_remaining = float(_active_pattern.get("execute_duration", 0.0))
	state_changed.emit(_state, active_pattern())
	execute_requested.emit(active_pattern())


func _enter_recovery() -> void:
	_state = State.recovery
	_remaining = float(_active_pattern.get("recovery_duration", 0.0))
	state_changed.emit(_state, active_pattern())


func _enter_chase() -> void:
	_pattern_index = (_pattern_index + 1) % _patterns.size()
	_state = State.chase
	_remaining = 0.65
	_active_pattern = {}
	state_changed.emit(_state, {})


func _is_valid_pattern(pattern: Dictionary) -> bool:
	return (
		StringName(pattern.get("primitive_id", &"")) != &""
		and float(pattern.get("telegraph_duration", 0.0)) > 0.0
		and float(pattern.get("execute_duration", 0.0)) > 0.0
		and float(pattern.get("recovery_duration", 0.0)) > 0.0
	)
