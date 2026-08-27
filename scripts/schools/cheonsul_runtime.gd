extends SchoolRuntimeBase
class_name CheonsulRuntime

const CAST_INTERVAL := 1.80
const CAST_EPSILON := 0.000001
const FLAME_RADIUS := 90.0
const FLAME_DAMAGE := 6
const FIELD_VISUAL_DURATION := 0.60
const FIELD_VISUAL_TEXTURE: Texture2D = preload("res://assets/runtime/visual-core/cheonsul_flame_field_v1.png")
const BURN_DURATION := 3.0
const BURN_TICK_INTERVAL := 1.0
const BURN_DAMAGE := 2
const TOKEN_DURATION := 4.0
const REACTION_DAMAGE := 10
const CHAIN_RADIUS := 120.0
const CHAIN_DAMAGE := 6
const REACTION_MAXIMUM := 3.0
const ULTIMATE_DAMAGE := 18

@export var badge_scene: PackedScene

var reaction_count: float = 0.0

var _cast_remaining: float = CAST_INTERVAL
var _next_token: StringName = &"wet"
var _states: Dictionary = {}
var _field_visuals: Array[Dictionary] = []
var _last_ultimate_ready: bool = false


func activate() -> void:
	if active:
		return
	super.activate()
	reaction_count = 0.0
	_cast_remaining = CAST_INTERVAL
	_next_token = &"wet"
	_clear_states()
	_clear_field_visuals()
	_emit_resource()
	_emit_ultimate_ready_if_changed(true)


func deactivate() -> void:
	_clear_states()
	_clear_field_visuals()
	super.deactivate()


func _process(delta: float) -> void:
	if not active or delta <= 0.0:
		return

	_tick_states(delta)
	_tick_field_visuals(delta)

	_cast_remaining -= delta
	if _cast_remaining <= CAST_EPSILON:
		var target := _select_cast_target()
		if target == null:
			_cast_remaining = 0.1
		else:
			apply_flame_cast(target.global_position)
			_cast_remaining = CAST_INTERVAL

	_emit_ultimate_ready_if_changed()


func apply_flame_cast(center: Vector2) -> int:
	if not active:
		return 0

	_spawn_field_visual(center)
	var hit_enemies: Array[Node2D] = []
	var resolved_damage := false
	for enemy in _valid_enemies():
		if enemy.global_position.distance_squared_to(center) > FLAME_RADIUS * FLAME_RADIUS:
			continue
		if _deal_damage(enemy, FLAME_DAMAGE) > 0:
			resolved_damage = true
		hit_enemies.append(enemy)
		if enemy.has_method("is_dead") and enemy.is_dead():
			continue
		_apply_burn(enemy)

	if hit_enemies.is_empty():
		return 0

	var token := _next_token
	for enemy in hit_enemies:
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if enemy.has_method("is_dead") and enemy.is_dead():
			continue
		apply_token(enemy, token)

	_next_token = &"shock" if token == &"wet" else &"wet"
	if resolved_damage:
		emit_player_action_resolved()
	return hit_enemies.size()


func apply_token(enemy: Node2D, token: StringName) -> bool:
	if not active or not _is_valid_enemy(enemy):
		return false
	if token != &"wet" and token != &"shock":
		return false

	var state := _ensure_state(enemy)
	_record_status_event()
	if token == &"wet":
		state["wet_remaining"] = TOKEN_DURATION
		_states[enemy.get_instance_id()] = state
		_update_badge(enemy.get_instance_id())
		return false

	state["shock_remaining"] = TOKEN_DURATION
	if float(state["wet_remaining"]) <= 0.0:
		_states[enemy.get_instance_id()] = state
		_update_badge(enemy.get_instance_id())
		return false

	state["wet_remaining"] = 0.0
	state["shock_remaining"] = 0.0
	_states[enemy.get_instance_id()] = state

	var reaction_center := enemy.global_position
	var reaction_multiplier := _reaction_effect_multiplier()
	_deal_damage(enemy, REACTION_DAMAGE, &"normal", reaction_multiplier)
	for other in _valid_enemies():
		if other == enemy:
			continue
		if other.global_position.distance_squared_to(reaction_center) <= CHAIN_RADIUS * CHAIN_RADIUS:
			_deal_damage(other, CHAIN_DAMAGE, &"normal", reaction_multiplier)

	_record_status_event()
	_add_reaction_progress()
	school_feedback.emit("WET + SHOCK")
	_update_badge(enemy.get_instance_id())
	return true


func has_status(enemy: Node, token: StringName) -> bool:
	_prune_invalid_states()
	if not is_instance_valid(enemy):
		return false
	var instance_id := enemy.get_instance_id()
	if not _states.has(instance_id):
		return false
	var state: Dictionary = _states[instance_id]
	match token:
		&"burn":
			return float(state["burn_remaining"]) > 0.0
		&"wet":
			return float(state["wet_remaining"]) > 0.0
		&"shock":
			return float(state["shock_remaining"]) > 0.0
	return false


func on_enemy_died(enemy: Node) -> void:
	if not is_instance_valid(enemy):
		return
	_remove_state(enemy.get_instance_id())


func is_ultimate_ready() -> bool:
	return active and reaction_count >= REACTION_MAXIMUM


func try_use_ultimate() -> bool:
	if not is_ultimate_ready():
		return false

	_prune_invalid_states()
	var targets: Array[Node2D] = []
	for instance_id in _states.keys():
		var state: Dictionary = _states[instance_id]
		if not _state_has_any_status(state):
			continue
		var enemy = state["enemy"]
		if _is_valid_enemy(enemy):
			targets.append(enemy as Node2D)

	if targets.is_empty():
		return false

	for enemy in targets:
		if _is_valid_enemy(enemy):
			_deal_damage(enemy, ULTIMATE_DAMAGE, &"ultimate")

	_clear_states()
	reaction_count = 0.0
	_emit_resource()
	_emit_ultimate_ready_if_changed(true)
	school_feedback.emit("오행폭주")
	return true


func _apply_burn(enemy: Node2D) -> void:
	var state := _ensure_state(enemy)
	state["burn_remaining"] = BURN_DURATION
	state["burn_tick_remaining"] = BURN_TICK_INTERVAL
	_states[enemy.get_instance_id()] = state
	_record_status_event()
	_update_badge(enemy.get_instance_id())


func _tick_states(delta: float) -> void:
	for instance_id in _states.keys():
		if not _states.has(instance_id):
			continue
		var state: Dictionary = _states[instance_id]
		var enemy = state["enemy"]
		if not _is_valid_enemy(enemy):
			_remove_state(instance_id)
			continue

		var burn_before := float(state["burn_remaining"])
		if burn_before > 0.0:
			var active_burn_delta := minf(delta, burn_before)
			state["burn_remaining"] = maxf(burn_before - delta, 0.0)
			var tick_remaining := float(state["burn_tick_remaining"]) - active_burn_delta
			while tick_remaining <= 0.0:
				if not _is_valid_enemy(enemy):
					break
				_deal_damage(enemy, BURN_DAMAGE)
				tick_remaining += BURN_TICK_INTERVAL
			state["burn_tick_remaining"] = tick_remaining

		state["wet_remaining"] = maxf(float(state["wet_remaining"]) - delta, 0.0)
		state["shock_remaining"] = maxf(float(state["shock_remaining"]) - delta, 0.0)

		if not _is_valid_enemy(enemy):
			_remove_state(instance_id)
			continue

		_states[instance_id] = state
		_update_badge(instance_id)


func _tick_field_visuals(delta: float) -> void:
	for index in range(_field_visuals.size() - 1, -1, -1):
		var entry: Dictionary = _field_visuals[index]
		entry["remaining"] = maxf(float(entry["remaining"]) - delta, 0.0)
		var node = entry["node"]
		if float(entry["remaining"]) <= 0.0 or not is_instance_valid(node):
			if is_instance_valid(node):
				node.queue_free()
			_field_visuals.remove_at(index)
		else:
			_field_visuals[index] = entry


func _spawn_field_visual(center: Vector2) -> void:
	var visual := Sprite2D.new()
	visual.name = "FlameFieldVisual"
	visual.texture = FIELD_VISUAL_TEXTURE
	var texture_size := FIELD_VISUAL_TEXTURE.get_size()
	var longest_edge := maxf(texture_size.x, texture_size.y)
	if longest_edge > 0.0:
		visual.scale = Vector2.ONE * (FLAME_RADIUS * 2.0 / longest_edge)
	add_child(visual)
	visual.global_position = center
	_field_visuals.append({"node": visual, "remaining": FIELD_VISUAL_DURATION})


func _clear_field_visuals() -> void:
	for entry in _field_visuals:
		var node = entry.get("node")
		if is_instance_valid(node):
			node.queue_free()
	_field_visuals.clear()


func _ensure_state(enemy: Node2D) -> Dictionary:
	var instance_id := enemy.get_instance_id()
	if _states.has(instance_id):
		return _states[instance_id]
	var state := {
		"enemy": enemy,
		"burn_remaining": 0.0,
		"burn_tick_remaining": BURN_TICK_INTERVAL,
		"wet_remaining": 0.0,
		"shock_remaining": 0.0,
		"badge": null,
	}
	_states[instance_id] = state
	return state


func _update_badge(instance_id: int) -> void:
	if not _states.has(instance_id):
		return
	var state: Dictionary = _states[instance_id]
	var enemy = state["enemy"]
	if not _is_valid_enemy(enemy):
		_remove_state(instance_id)
		return

	var labels: Array[String] = []
	if float(state["burn_remaining"]) > 0.0:
		labels.append("BURN")
	if float(state["wet_remaining"]) > 0.0:
		labels.append("WET")
	if float(state["shock_remaining"]) > 0.0:
		labels.append("SHOCK")

	if labels.is_empty():
		var old_badge = state["badge"]
		if is_instance_valid(old_badge):
			old_badge.queue_free()
		_states.erase(instance_id)
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

	if is_instance_valid(badge) and badge.has_method("set_text"):
		badge.set_text("/".join(labels))
	_states[instance_id] = state


func _remove_state(instance_id: int) -> void:
	if not _states.has(instance_id):
		return
	var state: Dictionary = _states[instance_id]
	var badge = state.get("badge")
	if is_instance_valid(badge):
		badge.queue_free()
	_states.erase(instance_id)


func _clear_states() -> void:
	for instance_id in _states.keys():
		_remove_state(instance_id)
	_states.clear()


func _prune_invalid_states() -> void:
	for instance_id in _states.keys():
		var state: Dictionary = _states[instance_id]
		if not _is_valid_enemy(state.get("enemy")):
			_remove_state(instance_id)


func _state_has_any_status(state: Dictionary) -> bool:
	return (
		float(state["burn_remaining"]) > 0.0
		or float(state["wet_remaining"]) > 0.0
		or float(state["shock_remaining"]) > 0.0
	)


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


func _select_cast_target() -> Node2D:
	if _next_token == &"shock":
		var wet_target := _nearest_enemy_with_status(&"wet")
		if wet_target != null:
			return wet_target
	return _nearest_enemy()


func _nearest_enemy_with_status(token: StringName) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance: float = INF
	var origin: Vector2 = player.global_position if is_instance_valid(player) else Vector2.ZERO
	for enemy in _valid_enemies():
		if not has_status(enemy, token):
			continue
		var distance: float = origin.distance_squared_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy
	return nearest


func _nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_distance: float = INF
	var origin: Vector2 = player.global_position if is_instance_valid(player) else Vector2.ZERO
	for enemy in _valid_enemies():
		var distance: float = origin.distance_squared_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy
	return nearest


func _deal_damage(
	target: Node,
	base_damage: float,
	damage_kind: StringName = &"normal",
	extra_multiplier: float = 1.0
) -> int:
	if not is_instance_valid(target) or not target.has_method("take_damage"):
		return 0
	if combat_resolver != null:
		return combat_resolver.deal_school_damage(target, base_damage, damage_kind, extra_multiplier)
	var requested := maxi(roundi(base_damage * maxf(extra_multiplier, 0.0)), 1)
	var result = target.call("take_damage", requested)
	return int(result) if result is int else requested


func _reaction_effect_multiplier() -> float:
	return (
		maxf(1.0 + run_modifiers.cheonsul_reaction_damage_pct, 0.0)
		* maxf(1.0 + run_modifiers.school_status_effect_pct, 0.0)
	)


func _add_reaction_progress() -> void:
	var gain_multiplier := maxf(1.0 + run_modifiers.school_resource_gain_pct, 0.0)
	gain_multiplier *= maxf(1.0 + run_modifiers.ultimate_charge_gain_pct, 0.0)
	reaction_count = clampf(reaction_count + gain_multiplier, 0.0, REACTION_MAXIMUM)
	_emit_resource()
	_emit_ultimate_ready_if_changed()


func _record_status_event(count: int = 1) -> void:
	if contribution_tracker != null:
		contribution_tracker.record_status_event(count)


func _emit_resource() -> void:
	resource_changed.emit("REACTION", reaction_count, REACTION_MAXIMUM)


func _emit_ultimate_ready_if_changed(force: bool = false) -> void:
	var ready := is_ultimate_ready()
	if force or ready != _last_ultimate_ready:
		_last_ultimate_ready = ready
		ultimate_ready_changed.emit(ready)


func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	var safe_segments := maxi(segments, 3)
	for index in range(safe_segments):
		var angle := TAU * float(index) / float(safe_segments)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points
