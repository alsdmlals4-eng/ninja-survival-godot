extends SchoolRuntimeBase
class_name HeukyeongRuntime

const ATTACK_INTERVAL := 1.10
const TIMER_EPSILON := 0.000001
const MAX_TARGETS := 3
const BASE_DAMAGE := 6
const BASE_CRITICAL_CHANCE := 0.20
const MARKED_CRITICAL_CHANCE := 0.40
const CRITICAL_MULTIPLIER := 2.0
const BURST_THRESHOLD := 3
const BURST_DAMAGE := 16
const ULTIMATE_MARK_THRESHOLD := 3

@export var badge_scene: PackedScene

var _rng := RandomNumberGenerator.new()
var _marks: Dictionary = {}
var _attack_remaining: float = ATTACK_INTERVAL
var _last_ultimate_ready: bool = false


func activate() -> void:
	if active:
		return
	super.activate()
	_clear_all_marks()
	_attack_remaining = ATTACK_INTERVAL
	_rng.randomize()
	_emit_resource()
	_emit_ultimate_ready_if_changed(true)


func deactivate() -> void:
	_clear_all_marks()
	super.deactivate()


func _process(delta: float) -> void:
	if not active or delta <= 0.0:
		return

	_prune_invalid_marks()
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
	var hit_damage := maxi(roundi(float(BASE_DAMAGE) * multiplier), 1)
	enemy.take_damage(hit_damage)

	if not _is_valid_enemy(enemy):
		_remove_mark_state(enemy.get_instance_id())
		_emit_resource_and_ready()
		return is_critical

	var instance_id := enemy.get_instance_id()
	var state := _ensure_mark_state(enemy)
	var mark_gain := 2 if is_critical else 1
	var next_marks := int(state["marks"]) + mark_gain

	if next_marks >= BURST_THRESHOLD:
		enemy.take_damage(BURST_DAMAGE)
		_remove_mark_state(instance_id)
		school_feedback.emit("MARK BURST")
	else:
		state["marks"] = next_marks
		_marks[instance_id] = state
		_update_badge(instance_id)

	_emit_resource_and_ready()
	return is_critical


func get_critical_chance(enemy: Node) -> float:
	return MARKED_CRITICAL_CHANCE if get_mark_count(enemy) > 0 else BASE_CRITICAL_CHANCE


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
		var damage := 14 + 4 * int(target["marks"])
		enemy.take_damage(damage)

	_clear_all_marks()
	_emit_resource_and_ready(true)
	school_feedback.emit("암영처형")
	return true


func _ensure_mark_state(enemy: Node2D) -> Dictionary:
	var instance_id := enemy.get_instance_id()
	if _marks.has(instance_id):
		return _marks[instance_id]
	var state := {
		"enemy": enemy,
		"marks": 0,
		"badge": null,
	}
	_marks[instance_id] = state
	return state


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
