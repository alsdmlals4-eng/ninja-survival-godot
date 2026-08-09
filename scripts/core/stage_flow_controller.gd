extends Node
class_name StageFlowController

enum Phase {
	SCHOOL_SELECT,
	COMBAT,
	BOSS,
	RESULT,
	SHOP,
	FATE,
	PREVIEW,
	COMPLETE,
	GAME_OVER,
}

signal phase_changed(phase: Phase)
signal segment_time_changed(segment: int, remaining: float)
signal boss_requested(tier: int)
signal run_completed

@export var segment_duration_seconds: float = 300.0

var phase: Phase = Phase.SCHOOL_SELECT
var segment_index: int = 1
var segment_time_remaining: float = 300.0


func _process(delta: float) -> void:
	if phase != Phase.COMBAT or delta <= 0.0:
		return
	segment_time_remaining = maxf(segment_time_remaining - delta, 0.0)
	segment_time_changed.emit(segment_index, segment_time_remaining)
	if segment_time_remaining > 0.0:
		return
	_set_phase(Phase.BOSS)
	boss_requested.emit(segment_index)


func start_after_school_selection() -> bool:
	if phase != Phase.SCHOOL_SELECT:
		return false
	segment_index = 1
	segment_time_remaining = maxf(segment_duration_seconds, 0.0)
	_set_phase(Phase.COMBAT)
	segment_time_changed.emit(segment_index, segment_time_remaining)
	if segment_time_remaining <= 0.0:
		_set_phase(Phase.BOSS)
		boss_requested.emit(segment_index)
	return true


func enter_result_after_boss() -> bool:
	if phase != Phase.BOSS:
		return false
	_set_phase(Phase.RESULT)
	return true


func continue_to_shop() -> bool:
	if phase != Phase.RESULT:
		return false
	_set_phase(Phase.SHOP)
	return true


func continue_to_fate() -> bool:
	if phase != Phase.SHOP:
		return false
	_set_phase(Phase.FATE)
	return true


func continue_to_preview(fate_selected: bool) -> bool:
	if phase != Phase.FATE or not fate_selected:
		return false
	if segment_index >= 3:
		_set_phase(Phase.COMPLETE)
		run_completed.emit()
		return true
	_set_phase(Phase.PREVIEW)
	return true


func start_next_combat() -> bool:
	if phase != Phase.PREVIEW or segment_index >= 3:
		return false
	segment_index += 1
	segment_time_remaining = maxf(segment_duration_seconds, 0.0)
	_set_phase(Phase.COMBAT)
	segment_time_changed.emit(segment_index, segment_time_remaining)
	if segment_time_remaining <= 0.0:
		_set_phase(Phase.BOSS)
		boss_requested.emit(segment_index)
	return true


func mark_game_over() -> void:
	if phase == Phase.GAME_OVER:
		return
	_set_phase(Phase.GAME_OVER)


func _set_phase(next_phase: Phase) -> void:
	if phase == next_phase:
		return
	phase = next_phase
	phase_changed.emit(phase)
