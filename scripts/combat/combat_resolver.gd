extends Node
class_name CombatResolver

var contribution_tracker: CombatContributionTracker
var run_modifiers := RunModifierSet.new()


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
	var result = target.call("take_damage", requested)
	if not result is int:
		return 0
	var actual := maxi(int(result), 0)
	if contribution_tracker != null:
		contribution_tracker.record_damage(actual)
	return actual


func deal_basic_weapon_damage(target: Node, base_damage: float) -> int:
	if target == null or not is_instance_valid(target) or not target.has_method("take_damage"):
		return 0
	if base_damage <= 0.0:
		return 0

	var requested := maxi(roundi(base_damage), 1)
	var result = target.call("take_damage", requested)
	if not result is int:
		return 0
	var actual := maxi(int(result), 0)
	if contribution_tracker != null:
		contribution_tracker.record_damage(actual)
	return actual
