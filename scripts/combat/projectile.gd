extends Area2D
class_name BasicProjectile

var direction: Vector2 = Vector2.ZERO
@export var speed: float = 500.0
@export var damage: int = 10


func configure(_new_direction: Vector2, _new_speed: float, _new_damage: int) -> void:
	pass
