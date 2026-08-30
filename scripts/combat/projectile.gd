extends Area2D
class_name BasicProjectile

var direction: Vector2 = Vector2.ZERO
@export var speed: float = 500.0
@export var damage: int = 10
@export var lifetime: float = 2.0
var combat_resolver: CombatResolver

var _remaining_lifetime: float = 2.0


func _ready() -> void:
	_remaining_lifetime = max(lifetime, 0.01)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_remaining_lifetime -= delta
	if _remaining_lifetime <= 0.0:
		queue_free()


func configure(
	new_direction: Vector2,
	new_speed: float,
	new_damage: int,
	new_combat_resolver: CombatResolver = null
) -> void:
	direction = new_direction.normalized() if not new_direction.is_zero_approx() else Vector2.ZERO
	speed = new_speed
	damage = new_damage
	combat_resolver = new_combat_resolver


func hit_body(body: Node) -> bool:
	if not is_instance_valid(body) or not body.has_method("take_damage"):
		return false

	if combat_resolver != null:
		combat_resolver.deal_basic_weapon_damage(body, float(damage))
	else:
		body.take_damage(damage)
	queue_free()
	return true


func _on_body_entered(body: Node) -> void:
	hit_body(body)
