extends CharacterBody2D
class_name EnemyChaser

signal died(enemy: Node)
signal damaged(enemy: Node, actual_damage: int, remaining_health: int, maximum_health: int)

const OPENING_CONTACT_STAGGER_META := &"ninja_wave_opening_contact_stagger_seconds"

@export var max_health: int = 20
@export var move_speed: float = 90.0
@export var contact_damage: int = 10
@export var contact_range: float = 28.0
@export var contact_cooldown: float = 0.75

var health: int = 20
var target: Node2D
var _dead: bool = false
var _contact_cooldown_remaining: float = 0.0
var _book_slows: Dictionary = {}
var _book_bind_remaining := 0.0
var _book_bind_protection := 0.0
var _book_bind_source: StringName = &""
var _open_field_contact := false


func book_control_role() -> StringName:
	if is_in_group("boss"):
		return &"boss"
	var role := StringName(get_meta("school_circuit_role", get_meta("cheonsul_slice_role", &"core")))
	return &"boss" if role == &"final_boss" else role


func apply_book_control(source: StringName, duration: float, slow: float, bind: bool = false) -> bool:
	if source == &"" or not is_finite(duration) or not is_finite(slow) or duration <= 0.0 or _dead:
		return false
	if bind and book_control_role() == &"core":
		if _book_bind_remaining > 0.000001 or _book_bind_protection > 0.000001:
			return false
		_book_bind_source = source
		_book_bind_remaining = duration
		set_process(true)
		return true
	var amount := clampf(slow, 0.0, 0.4)
	if bind:
		amount = 0.1 if book_control_role() == &"boss" else 0.2
	var previous: Dictionary = _book_slows.get(source, {})
	_book_slows[source] = {"remaining": maxf(duration, float(previous.get("remaining", 0.0))), "amount": maxf(amount, float(previous.get("amount", 0.0)))}
	set_process(true)
	return true


func remove_book_control(source: StringName) -> void:
	_book_slows.erase(source)
	if _book_bind_source == source and _book_bind_remaining > 0.0:
		_book_bind_remaining = 0.0
		_book_bind_protection = 2.0
		_book_bind_source = &""


func book_movement_multiplier() -> float:
	if _book_bind_remaining > 0.000001:
		return 0.0
	var slow := 0.0
	for state in _book_slows.values():
		slow = maxf(slow, float(state.amount))
	return 1.0 - minf(slow, 0.4)


func _process(delta: float) -> void:
	advance_book_control(delta)


func advance_book_control(delta: float) -> void:
	if not is_finite(delta) or delta <= 0.0 or _dead or (get_tree() != null and get_tree().paused):
		return
	for source in _book_slows.keys():
		_book_slows[source].remaining = float(_book_slows[source].remaining) - delta
		if float(_book_slows[source].remaining) <= 0.000001:
			_book_slows.erase(source)
	if _book_bind_remaining > 0.0:
		var overshoot := maxf(delta - _book_bind_remaining, 0.0)
		_book_bind_remaining = maxf(_book_bind_remaining - delta, 0.0)
		if _book_bind_remaining <= 0.000001:
			_book_bind_remaining = 0.0
			_book_bind_protection = maxf(2.0 - overshoot, 0.0)
			_book_bind_source = &""
	else:
		_book_bind_protection = maxf(_book_bind_protection - delta, 0.0)
	if _book_slows.is_empty() and _book_bind_remaining <= 0.0 and _book_bind_protection <= 0.0:
		set_process(false)


func _ready() -> void:
	set_process(false)
	health = max(max_health, 1)
	_dead = false
	_contact_cooldown_remaining = maxf(float(get_meta(OPENING_CONTACT_STAGGER_META, 0.0)), 0.0)
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
	var touching := false
	if not offset.is_zero_approx():
		velocity = offset.normalized() * move_speed * book_movement_multiplier()
		var contact := _step_open_field_contact(delta)
		if contact < 0:
			move_and_slide()
			touching = _is_touching_target()
		else:
			touching = contact == 1
	else:
		velocity = Vector2.ZERO

	if touching or offset.length_squared() <= contact_range * contact_range:
		_try_contact_damage()


func enable_open_field_contact() -> void:
	# Main's selected open field has one layer-1 body: the player. Additional
	# blockers/masks/shapes fall back to the solver; no crowd cap or tick skipping.
	_open_field_contact = true
	motion_mode = MOTION_MODE_FLOATING
	platform_wall_layers = 0


func _step_open_field_contact(delta: float) -> int:
	if not _open_field_contact or collision_mask != 1 or not target is PhysicsBody2D or not is_finite(delta) or delta < 0.0:
		return -1
	var own := get_node_or_null("CollisionShape2D") as CollisionShape2D
	var other := target.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if not _is_centered_circle(self, own) or not _is_centered_circle(target, other):
		return -1
	if not get_collision_exceptions().is_empty() or not target.get_collision_exceptions().is_empty():
		return -1
	var motion := velocity * delta
	if not motion.is_finite(): return -1
	if own.disabled or other.disabled or (target.collision_layer & collision_mask) == 0:
		global_position += motion
		return 0
	var offset := global_position - target.global_position
	var distance := offset.length()
	var radius: float = own.shape.radius * absf(own.global_scale.x) + other.shape.radius * absf(other.global_scale.x) + safe_margin
	# Pursuit is radial and both colliders are centered circles. Clamp travel to
	# the contact boundary, including overlap recovery after the player's dash.
	var travel := motion.length()
	if distance <= radius + travel:
		var contact_position := target.global_position + offset.normalized() * radius
		if global_position != contact_position:
			global_position = contact_position
		velocity = Vector2.ZERO
		return 1
	global_position += motion
	return 0


func _is_centered_circle(body: PhysicsBody2D, collision: CollisionShape2D) -> bool:
	if collision == null or not collision.shape is CircleShape2D or collision.position != Vector2.ZERO:
		return false
	var owners := body.get_shape_owners()
	return owners.size() == 1 and body.shape_owner_get_shape_count(owners[0]) == 1 and is_equal_approx(absf(collision.global_scale.x), absf(collision.global_scale.y))


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
