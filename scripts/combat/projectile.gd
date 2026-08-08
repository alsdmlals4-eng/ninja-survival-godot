extends Area2D
class_name BasicProjectile

var direction: Vector2 = Vector2.ZERO
@export var speed: float = 500.0
@export var damage: int = 10


func configure(new_direction: Vector2, new_speed: float, new_damage: int) -> void:
	direction = new_direction.normalized() if not new_direction.is_zero_approx() else Vector2.ZERO
	speed = new_speed
	damage = new_damage
