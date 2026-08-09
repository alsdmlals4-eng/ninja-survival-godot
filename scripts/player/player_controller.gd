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

	var ui_direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := resolve_movement_direction(
		ui_direction,
		Input.is_physical_key_pressed(KEY_A),
		Input.is_physical_key_pressed(KEY_D),
		Input.is_physical_key_pressed(KEY_W),
		Input.is_physical_key_pressed(KEY_S)
	)
	velocity = direction * move_speed
	move_and_slide()


func resolve_movement_direction(
	ui_direction: Vector2,
	a_pressed: bool,
	d_pressed: bool,
	w_pressed: bool,
	s_pressed: bool
) -> Vector2:
	var wasd_direction := Vector2(
		float(int(d_pressed) - int(a_pressed)),
		float(int(s_pressed) - int(w_pressed))
	)
	return (ui_direction + wasd_direction).limit_length(1.0)


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
