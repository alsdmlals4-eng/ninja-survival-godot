extends CharacterBody2D
class_name EnemyChaser

signal died(enemy: Node)
signal damaged(enemy: Node, actual_damage: int, remaining_health: int, maximum_health: int)

@export var max_health: int = 20
@export var move_speed: float = 90.0
@export var contact_damage: int = 10
@export var contact_range: float = 28.0
@export var contact_cooldown: float = 0.75

var health: int = 20
var target: Node2D
var _dead: bool = false
var _contact_cooldown_remaining: float = 0.0


func _ready() -> void:
	health = max(max_health, 1)
	_dead = false
	add_to_group("enemies")


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		return

	_contact_cooldown_remaining = max(_contact_cooldown_remaining - delta, 0.0)

	if not is_instance_valid(target):
		velocity = Vector2.ZERO
		return

	var offset := target.global_position - global_position
	if not offset.is_zero_approx():
		velocity = offset.normalized() * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	if _is_touching_target() or offset.length_squared() <= contact_range * contact_range:
		_try_contact_damage()


func set_target(new_target: Node2D) -> void:
	target = new_target


func take_damage(amount: int) -> int:
	if amount <= 0 or _dead:
		return 0

	var before := health
	health = max(health - amount, 0)
	var actual_damage := before - health
	if actual_damage > 0:
		damaged.emit(self, actual_damage, health, max_health)
	if health == 0:
		_dead = true
		died.emit(self)
		queue_free()
	return actual_damage


func is_dead() -> bool:
	return _dead


func _is_touching_target() -> bool:
	for collision_index in range(get_slide_collision_count()):
		var collision := get_slide_collision(collision_index)
		if collision.get_collider() == target:
			return true
	return false


func _try_contact_damage() -> void:
	if _contact_cooldown_remaining > 0.0:
		return
	if not is_instance_valid(target) or not target.has_method("take_damage"):
		return

	target.take_damage(contact_damage)
	_contact_cooldown_remaining = contact_cooldown
