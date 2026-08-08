extends CharacterBody2D
class_name PlayerController

signal health_changed(current_health: int, maximum_health: int)
signal died

@export var max_health: int = 100
@export var move_speed: float = 240.0

var health: int = 100
var _dead: bool = false


func _ready() -> void:
	health = max(max_health, 1)
	_dead = false
	health_changed.emit(health, max_health)


func _physics_process(_delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		return

	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * move_speed
	move_and_slide()


func take_damage(amount: int) -> void:
	if amount <= 0 or _dead:
		return

	health = max(health - amount, 0)
	health_changed.emit(health, max_health)

	if health == 0:
		_dead = true
		died.emit()


func is_dead() -> bool:
	return _dead
