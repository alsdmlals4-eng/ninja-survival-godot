extends Node2D
class_name BongmaFamiliar

signal attack_resolved

@export var follow_distance: float = 72.0
@export var follow_speed: float = 220.0

var player: PlayerController
var attack_interval: float = 0.70
var damage: int = 8
var damage_kind: StringName = &"normal"
var combat_resolver: CombatResolver
var _cooldown_remaining: float = 0.0
var target_radius: float = INF
var target_from_player: bool = false
var maximum_follow_distance: float = INF
var follow_offset := Vector2.ZERO


func configure(
	new_player: PlayerController,
	new_attack_interval: float,
	new_damage: int,
	resolver: CombatResolver = null
) -> void:
	player = new_player
	attack_interval = maxf(new_attack_interval, 0.05)
	damage = maxi(new_damage, 1)
	combat_resolver = resolver
	_cooldown_remaining = 0.0


func set_attack_interval(seconds: float) -> void:
	attack_interval = maxf(seconds, 0.05)
	_cooldown_remaining = minf(_cooldown_remaining, attack_interval)


func set_combat_resolver(resolver: CombatResolver) -> void:
	combat_resolver = resolver


func set_damage_kind(kind: StringName) -> void:
	damage_kind = kind


func _physics_process(delta: float) -> void:
	if delta <= 0.0 or not is_finite(delta) or not is_instance_valid(player) or player.is_dead() or get_tree().paused or is_queued_for_deletion():
		return

	var offset := player.global_position - global_position
	if offset.length_squared() > maximum_follow_distance * maximum_follow_distance:
		global_position = player.global_position - offset.normalized() * maximum_follow_distance
	offset = player.global_position + follow_offset - global_position
	if offset.length_squared() <= follow_distance * follow_distance:
		return
	global_position = global_position.move_toward(player.global_position + follow_offset, follow_speed * delta)


func _process(delta: float) -> void:
	if delta <= 0.0 or not is_finite(delta) or get_tree().paused or is_queued_for_deletion():
		return
	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)
	if _cooldown_remaining > 0.0:
		return

	if attack_once() != null:
		_cooldown_remaining = attack_interval
	else:
		_cooldown_remaining = 0.1


func attack_once() -> Node:
	if not is_instance_valid(player) or player.is_dead() or get_tree().paused or is_queued_for_deletion():
		return null
	var target := _nearest_target()
	if target == null:
		return null
	var actual_damage := 0
	if combat_resolver != null:
		actual_damage = combat_resolver.deal_school_damage(target, float(damage), damage_kind)
	else:
		actual_damage = target.take_damage(damage)
	if actual_damage > 0:
		attack_resolved.emit()
	return target


func _nearest_target() -> Node2D:
	if get_tree() == null:
		return null

	var nearest: Node2D = null
	var nearest_distance := INF
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(candidate) or not candidate is Node2D:
			continue
		if candidate.has_method("is_dead") and candidate.is_dead():
			continue
		if not candidate.has_method("take_damage"):
			continue

		var node := candidate as Node2D
		if node.is_queued_for_deletion():
			continue
		if is_instance_valid(player) and player.get_parent() != null and not player.get_parent().is_ancestor_of(node):
			continue
		var origin := player.global_position if target_from_player and is_instance_valid(player) else global_position
		if origin.distance_squared_to(node.global_position) > target_radius * target_radius:
			continue
		var distance := global_position.distance_squared_to(node.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = node

	return nearest
