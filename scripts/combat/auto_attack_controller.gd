extends Node
class_name AutoAttackController

@export var attack_interval: float = 0.8
@export var projectile_scene: PackedScene


func find_nearest_target(_candidates: Array, _origin: Vector2) -> Node2D:
	return null
