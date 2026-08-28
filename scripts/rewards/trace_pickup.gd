# Elite Trace의 정착·근거리 유도·단일 회수를 소유한다.
extends Node2D
class_name TracePickup

const SETTLE_DURATION := 0.35
const PICKUP_RADIUS := 96.0
const HOMING_DURATION := 0.40
const EPSILON := 0.000001

signal recovered(trace: TracePickup)

var target: Node2D
var _phase: StringName = &"settling"
var _settle_remaining: float = SETTLE_DURATION
var _homing_remaining: float = HOMING_DURATION


func configure(new_target: Node2D) -> bool:
	if target != null or not is_instance_valid(new_target):
		return false
	target = new_target
	return true


func phase_name() -> StringName:
	return _phase


func _process(delta: float) -> void:
	if _phase == &"recovered":
		return
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		queue_free()
		return
	var remaining_delta := maxf(delta, 0.0)
	if _phase == &"settling":
		var consumed := minf(remaining_delta, _settle_remaining)
		_settle_remaining -= consumed
		remaining_delta -= consumed
		if _settle_remaining > EPSILON:
			return
		_settle_remaining = 0.0
		_phase = &"ready"
		if remaining_delta <= EPSILON:
			return
	if _phase == &"ready":
		if global_position.distance_to(target.global_position) > PICKUP_RADIUS:
			return
		_phase = &"homing"
	if _phase != &"homing" or remaining_delta <= 0.0:
		return
	var remaining_duration := maxf(_homing_remaining, EPSILON)
	var distance := global_position.distance_to(target.global_position)
	var travel := distance * minf(remaining_delta / remaining_duration, 1.0)
	global_position = global_position.move_toward(target.global_position, travel)
	_homing_remaining = maxf(_homing_remaining - remaining_delta, 0.0)
	if _homing_remaining > EPSILON:
		return
	global_position = target.global_position
	_phase = &"recovered"
	recovered.emit(self)
	queue_free()
