extends Node2D
class_name RewardOrb

signal collected(orb: RewardOrb)

@export var move_speed: float = 360.0
@export var collect_radius: float = 18.0
@export var lifetime: float = 5.0

var target: Node2D
var _collected: bool = false


func configure(new_target: Node2D) -> void:
	target = new_target


func _physics_process(delta: float) -> void:
	if _collected:
		return

	lifetime -= maxf(delta, 0.0)
	if lifetime <= 0.0:
		queue_free()
		return

	if target == null or not is_instance_valid(target):
		queue_free()
		return

	if delta > 0.0:
		global_position = global_position.move_toward(target.global_position, move_speed * delta)

	if global_position.distance_to(target.global_position) <= collect_radius:
		_collected = true
		collected.emit(self)
		queue_free()
