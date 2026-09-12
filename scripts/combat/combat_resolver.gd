extends Node
class_name CombatResolver

signal damage_started(event_id: int, target: Node, kind: StringName)
signal damage_finished(event_id: int, actual_damage: int)

var contribution_tracker: CombatContributionTracker
var run_modifiers := RunModifierSet.new()
var sword_only_mode: bool = false
var _resolving_target_id: int = 0
var _resolving_damage_kind: StringName = &""
var _damage_event_serial := 0


func configure(tracker: CombatContributionTracker) -> void:
	contribution_tracker = tracker


func set_modifiers(modifiers: RunModifierSet) -> void:
	run_modifiers = modifiers.copy_values() if modifiers != null else RunModifierSet.new()


func deal_school_damage(
	target: Node,
	base_damage: float,
	damage_kind: StringName = &"normal",
	extra_multiplier: float = 1.0
) -> int:
	if sword_only_mode:
		return 0
	if target == null or not is_instance_valid(target) or not target.has_method("take_damage"):
		return 0
	if base_damage <= 0.0 or extra_multiplier <= 0.0:
		return 0

	var value := base_damage * maxf(1.0 + run_modifiers.school_damage_pct, 0.0)
	if damage_kind == &"ultimate":
		value *= maxf(1.0 + run_modifiers.ultimate_power_pct, 0.0)
	else:
		value *= maxf(1.0 + run_modifiers.non_ultimate_school_damage_pct, 0.0)
	value *= maxf(extra_multiplier, 0.0)
	if value <= 0.0:
		return 0

	var requested := maxi(roundi(value), 1)
	var result = _apply_owned_damage(target, requested, damage_kind)
	if not result is int:
		return 0
	var actual := maxi(int(result), 0)
	if contribution_tracker != null:
		contribution_tracker.record_damage(actual)
	return actual


func deal_basic_weapon_damage(target: Node, base_damage: float) -> int:
	if sword_only_mode:
		return 0
	if target == null or not is_instance_valid(target) or not target.has_method("take_damage"):
		return 0
	if base_damage <= 0.0:
		return 0

	var requested := maxi(roundi(base_damage), 1)
	var result = _apply_owned_damage(target, requested, &"weapon")
	if not result is int:
		return 0
	var actual := maxi(int(result), 0)
	if contribution_tracker != null:
		contribution_tracker.record_damage(actual)
	return actual


func deal_guiin_sword_damage(target: Node, base_damage: float) -> int:
	if not sword_only_mode or not is_instance_valid(target) or not target.has_method("take_damage") or base_damage <= 0.0:
		return 0
	var value := base_damage * maxf(1.0 + run_modifiers.ultimate_power_pct, 0.0)
	if value <= 0.0:
		return 0
	var result = _apply_owned_damage(target, maxi(roundi(value), 1), &"ultimate")
	var actual := maxi(int(result), 0) if result is int else 0
	if contribution_tracker != null:
		contribution_tracker.record_damage(actual)
	return actual


func current_damage_kind_for(target: Node) -> StringName:
	if not is_instance_valid(target) or target.get_instance_id() != _resolving_target_id:
		return &""
	return _resolving_damage_kind


func _apply_owned_damage(target: Node, amount: int, kind: StringName):
	if target.is_queued_for_deletion() or (target.has_method("is_dead") and target.is_dead()):
		return 0
	# Enemy death is synchronous. Preserve nested calls without leaving stale ownership.
	var previous_target := _resolving_target_id
	var previous_kind := _resolving_damage_kind
	_resolving_target_id = target.get_instance_id()
	_resolving_damage_kind = kind
	_damage_event_serial += 1
	var event_id := _damage_event_serial
	damage_started.emit(event_id, target, kind)
	var result = target.call("take_damage", amount) if is_instance_valid(target) and not target.is_queued_for_deletion() else 0
	damage_finished.emit(event_id, maxi(result, 0) if result is int else 0)
	_resolving_target_id = previous_target
	_resolving_damage_kind = previous_kind
	return result
