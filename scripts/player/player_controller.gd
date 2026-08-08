extends CharacterBody2D
class_name PlayerController

signal health_changed(current_health: int, maximum_health: int)
signal died

@export var max_health: int = 100
@export var move_speed: float = 240.0

var health: int = 100


func take_damage(_amount: int) -> void:
	pass


func is_dead() -> bool:
	return false
