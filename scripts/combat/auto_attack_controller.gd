extends Node
class_name AutoAttackController

@export var attack_interval: float = 0.8
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 500.0
@export var projectile_damage: int = 10


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
	return null
