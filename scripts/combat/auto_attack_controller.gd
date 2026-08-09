extends Node
class_name AutoAttackController

@export var attack_interval: float = 0.8
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 500.0
@export var projectile_damage: int = 10

var _cooldown_remaining: float = 0.0


func _process(delta: float) -> void:
	var source := get_parent() as Node2D
	if source == null:
		return
	if source.has_method("is_dead") and source.is_dead():
		return

	_cooldown_remaining = max(_cooldown_remaining - delta, 0.0)
	if _cooldown_remaining > 0.0:
		return

	var projectile := fire_once()
	if projectile != null:
		_cooldown_remaining = max(attack_interval, 0.05)
	else:
		_cooldown_remaining = 0.1


func find_nearest_target(candidates: Array, origin: Vector2) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance: float = INF

	for candidate in candidates:
		if not is_instance_valid(candidate) or not candidate is Node2D:
			continue
		if candidate.has_method("is_dead") and candidate.is_dead():
			continue

		var distance := origin.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate

	return nearest


func fire_once() -> Node2D:
	if projectile_scene == null:
		return null

	var source := get_parent() as Node2D
	if source == null or get_tree() == null:
		return null

	var target := find_nearest_target(get_tree().get_nodes_in_group("enemies"), source.global_position)
	if target == null:
		return null

	var aim := target.global_position - source.global_position
	if aim.is_zero_approx():
		return null

	var projectile_node := projectile_scene.instantiate()
	if not projectile_node is Node2D:
		projectile_node.free()
		return null

	var world := source.get_parent()
	if world == null:
		projectile_node.free()
		return null

	world.add_child(projectile_node)
	projectile_node.global_position = source.global_position
	if projectile_node.has_method("configure"):
		projectile_node.configure(aim, projectile_speed, projectile_damage)
	return projectile_node
