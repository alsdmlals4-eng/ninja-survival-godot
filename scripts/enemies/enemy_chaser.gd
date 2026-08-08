extends CharacterBody2D
class_name EnemyChaser

signal died(enemy: Node)

@export var max_health: int = 20
@export var move_speed: float = 90.0
@export var contact_damage: int = 10

var health: int = 20
var target: Node2D


func set_target(new_target: Node2D) -> void:
	target = new_target


func take_damage(_amount: int) -> void:
	pass


func is_dead() -> bool:
	return false
