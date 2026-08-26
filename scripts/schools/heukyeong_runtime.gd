extends SchoolRuntimeBase
class_name HeukyeongRuntime

const ATTACK_INTERVAL := 1.10
const TIMER_EPSILON := 0.000001
const MAX_TARGETS := 3
const BASE_DAMAGE := 6
const BASE_CRITICAL_CHANCE := 0.20
const MARKED_CRITICAL_CHANCE := 0.40
const CRITICAL_MULTIPLIER := 2.0
const BASE_MARK_DURATION := 8.0
const BURST_THRESHOLD := 3
const BURST_DAMAGE := 16
const ULTIMATE_MARK_THRESHOLD := 3

@export var badge_scene: PackedScene

var _rng := RandomNumberGenerator.new()
var _marks: Dictionary = {}
var _attack_remaining: float = ATTACK_INTERVAL
var _last_ultimate_ready: bool = false
var _mark_gain_credit: float = 0.0


func activate() -> void:
	if active:
		return
	super.activate()
	_clear_all_marks()
	_mark_gain_credit = 0.0
	_attack_remaining = ATTACK_INTERVAL
	_rng.randomize()
	_emit_resource()
	_emit_ultimate_ready_if_changed(true)


func deactivate() -> void:
	_clear_all_marks()
	_mark_gain_credit = 0.0
	super.deactivate()


func apply_run_modifiers(modifiers: RunModifierSet) -> void:
	super.apply_run_modifiers(modifiers)
	var new_duration := _effective_mark_duration()
	for instance_id in _marks.keys():
		var state: Dictionary = _marks[instance_id]
		var old_duration := maxf(float(state.get("duration", BASE_MARK_DURATION)), TIMER_EPSILON)
		var old_remaining := clampf(float(state.get("remaining", old_duration)), 0.0, old_duration)
		var remaining_ratio := old_remaining / old_duration
		state["duration"] = new_duration
		state["remaining"] = new_duration * remaining_ratio
		_marks[instance_id] = state


func _process(delta: float) -> void:
	if not active or delta <= 0.0:
		return

	_tick_marks(delta)
	_attack_remaining -= delta
	if _attack_remaining <= TIMER_EPSILON:
		attack_once()
		_attack_remaining = ATTACK_INTERVAL

	_emit_ultimate_ready_if_changed()


func set_rng_seed(seed_value: int) -> void:
	_rng.seed = seed_value


func attack_once() -> Array[Node]:
	var candidates := _valid_enemies()
	if candidates.is_empty():
		return []

	var origin: Vector2 = player.global_position if is_instance_valid(player) else Vector2.ZERO
	candidates.sort_custom(func(first: Node2D, second: Node2D) -> bool:
		return origin.distance_squared_to(first.global_position) < origin.distance_squared_to(second.global_position)
	)

	var hit: Array[Node] = []
	var target_count := mini(MAX_TARGETS, candidates.size())
	for index in range(target_count):
		var enemy := candidates[index]
		if not _is_valid_enemy(enemy):
			continue
		apply_needle_hit(enemy)
		hit.append(enemy)
	return hit


func apply_needle_hit(enemy: Node2D, force_critical: Variant = null) -> bool:
	if not active or not _is_valid_enemy(enemy):
		return false

	var critical_chance := get_critical_chance(enemy)
	var is_critical := bool(force_critical) if force_critical != null else _rng.randf() < critical_chance
	var multiplier := CRITICAL_MULTIPLIER if is_critical else 1.0
	var actual_damage := _deal_damage(enemy, float(BASE_DAMAGE), &"normal", multiplier)
	if actual_damage <= 0:
		return is_critical
	emit_player_action_resolved()

	if not _is_valid_enemy(enemy):
		_remove_mark_state(enemy.get_instance_id())
		_emit_resource_and_ready()
		return is_critical

	var mark_gain := _consume_mark_gain(2 if is_critical else 1)
	if mark_gain <= 0:
		return is_critical

	var instance_id := enemy.get_instance_id()
	var state := _ensure_mark_state(enemy)
	var next_marks := int(state["marks"]) + mark_gain
	_record_status_event()

	if next_marks >= BURST_THRESHOLD:
		_deal_damage(enemy, float(BURST_DAMAGE), &"normal", _status_effect_multiplier())
		_remove_mark_state(instance_id)
		_record_status_event()
		school_feedback.emit("MARK BURST")
	else:
		var duration := _effective_mark_duration()
		state["marks"] = next_marks
		state["duration"] = duration
		state["remaining"] = duration
		_marks[instance_id] = state
		_update_badge(instance_id)

	_emit_resource_and_ready()
	return is_critical


func get_critical_chance(enemy: Node) -> float:
	if get_mark_count(enemy) <= 0:
		return BASE_CRITICAL_CHANCE
	return clampf(MARKED_CRITICAL_CHANCE + run_modifiers.heukyeong_marked_crit_bonus, 0.0, 1.0)


func get_mark_count(enemy: Node) -> int:
	_prune_invalid_marks()
	if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
		return 0
	var instance_id := enemy.get_instance_id()
	if not _marks.has(instance_id):
		return 0
	return int((_marks[instance_id] as Dictionary)["marks"])


func get_total_active_marks() -> int:
	_prune_invalid_marks()
	var total := 0
	for instance_id in _marks.keys():
		var state: Dictionary = _marks[instance_id]
		total += int(state["marks"])
	return total


func on_enemy_died(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		return
	_remove_mark_state(enemy.get_instance_id())
	_emit_resource_and_ready()


func is_ultimate_ready() -> bool:
	return active and get_total_active_marks() >= ULTIMATE_MARK_THRESHOLD


func try_use_ultimate() -> bool:
	if not is_ultimate_ready():
		return false

	_prune_invalid_marks()
	var targets: Array[Dictionary] = []
	for instance_id in _marks.keys():
		var state: Dictionary = _marks[instance_id]
		var enemy = state["enemy"]
		if _is_valid_enemy(enemy) and int(state["marks"]) > 0:
			targets.append({"enemy": enemy, "marks": int(state["marks"])})

	if targets.is_empty():
		return false

	for target in targets:
		var enemy = target["enemy"]
		if not _is_valid_enemy(enemy):
			continue
		var base_damage := 14 + 4 * int(target["marks"])
		_deal_damage(enemy, float(base_damage), &"ultimate", _status_effect_multiplier())

	_clear_all_marks()
	_emit_resource_and_ready(true)
	school_feedback.emit("암영처형")
	return true


func _ensure_mark_state(enemy: Node2D) -> Dictionary:
	var instance_id := enemy.get_instance_id()
	if _marks.has(instance_id):
		return _marks[instance_id]
	var duration := _effective_mark_duration()
	var state := {
		"enemy": enemy,
		"marks": 0,
		"duration": duration,
		"remaining": duration,
		"badge": null,
	}
	_marks[instance_id] = state
	return state


func _tick_marks(delta: float) -> void:
	_prune_invalid_marks()
	for instance_id in _marks.keys():
		if not _marks.has(instance_id):
			continue
		var state: Dictionary = _marks[instance_id]
		state["remaining"] = maxf(float(state.get("remaining", 0.0)) - delta, 0.0)
		if float(state["remaining"]) <= TIMER_EPSILON:
			_remove_mark_state(instance_id)
		else:
			_marks[instance_id] = state


func _update_badge(instance_id: int) -> void:
	if not _marks.has(instance_id):
		return
	var state: Dictionary = _marks[instance_id]
	var enemy = state["enemy"]
	if not _is_valid_enemy(enemy):
		_remove_mark_state(instance_id)
		return

	var marks := int(state["marks"])
	if marks <= 0:
		_remove_mark_state(instance_id)
		return

	var badge = state["badge"]
	if not is_instance_valid(badge) and badge_scene != null:
		var instance := badge_scene.instantiate()
		if instance is EnemyEffectBadge:
			badge = instance
			badge.name = "EnemyEffectBadge"
			enemy.add_child(badge)
			state["badge"] = badge
		else:
			instance.free()

	if is_instance_valid(badge):
		badge.set_text("MARK %d" % marks)
	_marks[instance_id] = state


func _remove_mark_state(instance_id: int) -> void:
	if not _marks.has(instance_id):
		return
	var state: Dictionary = _marks[instance_id]
	var badge = state.get("badge")
	if is_instance_valid(badge):
		badge.queue_free()
	_marks.erase(instance_id)


func _clear_all_marks() -> void:
	for instance_id in _marks.keys():
		_remove_mark_state(instance_id)
	_marks.clear()


func _prune_invalid_marks() -> void:
	for instance_id in _marks.keys():
		var state: Dictionary = _marks[instance_id]
		if not _is_valid_enemy(state.get("enemy")):
			_remove_mark_state(instance_id)


func _consume_mark_gain(base_gain: int) -> int:
	if base_gain <= 0:
		return 0
	var multiplier := maxf(1.0 + run_modifiers.school_resource_gain_pct, 0.0)
	_mark_gain_credit += float(base_gain) * multiplier
	var whole_gain := floori(_mark_gain_credit + TIMER_EPSILON)
	_mark_gain_credit = maxf(_mark_gain_credit - float(whole_gain), 0.0)
	return whole_gain


func _effective_mark_duration() -> float:
	return BASE_MARK_DURATION * maxf(1.0 + run_modifiers.heukyeong_mark_duration_pct, 0.05)


func _status_effect_multiplier() -> float:
	return maxf(1.0 + run_modifiers.school_status_effect_pct, 0.0)


func _deal_damage(
	target: Node,
	base_damage: float,
	damage_kind: StringName,
	extra_multiplier: float = 1.0
) -> int:
	if target == null or not is_instance_valid(target) or not target.has_method("take_damage"):
		return 0
	if combat_resolver != null:
		return combat_resolver.deal_school_damage(target, base_damage, damage_kind, extra_multiplier)
	var requested := maxi(roundi(base_damage * maxf(extra_multiplier, 0.0)), 1)
	var result = target.call("take_damage", requested)
	if result is int:
		return maxi(int(result), 0)
	return requested


func _record_status_event(count: int = 1) -> void:
	if contribution_tracker != null:
		contribution_tracker.record_status_event(count)


func _is_valid_enemy(candidate) -> bool:
	if not is_instance_valid(candidate) or not candidate is Node2D:
		return false
	if candidate.is_queued_for_deletion():
		return false
	if candidate.has_method("is_dead") and candidate.is_dead():
		return false
	return candidate.has_method("take_damage")


func _valid_enemies() -> Array[Node2D]:
	var result: Array[Node2D] = []
	if get_tree() == null:
		return result
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if _is_valid_enemy(candidate):
			result.append(candidate as Node2D)
	return result


func _emit_resource() -> void:
	resource_changed.emit("MARKS", float(get_total_active_marks()), float(ULTIMATE_MARK_THRESHOLD))


func _emit_resource_and_ready(force_ready: bool = false) -> void:
	_emit_resource()
	_emit_ultimate_ready_if_changed(force_ready)


func _emit_ultimate_ready_if_changed(force: bool = false) -> void:
	var ready := is_ultimate_ready()
	if force or ready != _last_ultimate_ready:
		_last_ultimate_ready = ready
		ultimate_ready_changed.emit(ready)
