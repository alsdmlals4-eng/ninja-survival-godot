extends Area2D
class_name BasicProjectile

signal damage_applied(target: Node, actual: int)

var direction: Vector2 = Vector2.ZERO
@export var speed: float = 500.0
@export var damage: int = 10
@export var lifetime: float = 2.0
@export var pierce_count: int = 0
@export var blast_radius: float = 0.0
@export var blast_delay: float = 0.45
var combat_resolver: CombatResolver

var _remaining_lifetime: float = 2.0
var _hit_target_ids: Dictionary = {}
var _blast_remaining: float = 0.0


func _ready() -> void:
	add_to_group("friendly_weapon_projectiles")
	_remaining_lifetime = max(lifetime, 0.01)
	_blast_remaining = maxf(blast_delay, 0.01)


func _physics_process(delta: float) -> void:
	if delta <= 0.0 or not is_finite(delta) or is_queued_for_deletion() or get_tree().paused:
		return
	if blast_radius > 0.0:
		_blast_remaining -= delta
		if _blast_remaining <= 0.0:
			_resolve_blast()
		return
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
	if not direction.is_zero_approx():
		rotation = direction.angle()
	speed = new_speed
	damage = new_damage
	combat_resolver = new_combat_resolver


func hit_body(body: Node) -> bool:
	if blast_radius > 0.0 or is_queued_for_deletion() or get_tree().paused or not is_instance_valid(body) or not body.has_method("take_damage"):
		return false
	if body.has_method("is_dead") and bool(body.call("is_dead")):
		return false
	if _hit_target_ids.has(body.get_instance_id()):
		return false

	_hit_target_ids[body.get_instance_id()] = true
	if _hit_target_ids.size() >= maxi(pierce_count, 0) + 1:
		queue_free()
	_apply_damage(body)
	return true


func _apply_damage(body: Node) -> void:
	var actual := 0
	if combat_resolver != null:
		actual = combat_resolver.deal_basic_weapon_damage(body, float(damage))
	else:
		var result = body.take_damage(damage)
		actual = int(result) if result is int else 0
	if actual > 0:
		damage_applied.emit(body, actual)


func _resolve_blast() -> void:
	queue_free()
	for body in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(body) or not body is Node2D or body.is_queued_for_deletion() or not body.has_method("take_damage"):
			continue
		if body.has_method("is_dead") and bool(body.call("is_dead")):
			continue
		if global_position.distance_squared_to(body.global_position) <= blast_radius * blast_radius:
			_apply_damage(body)


func _on_body_entered(body: Node) -> void:
	hit_body(body)
