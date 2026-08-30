extends CharacterBody2D
class_name PlayerController

const MAX_DASH_CHARGES := 2
const DASH_DURATION_SECONDS := 0.20
const DASH_SPEED_MULTIPLIER := 3.0
const DASH_RECHARGE_SECONDS := 1.5
const POINTER_ARRIVAL_RADIUS := 12.0

signal health_changed(current_health: int, maximum_health: int)
signal healing_resolved(actual: int)
signal damage_resolved(requested: int, resolved: int, prevented: int, evaded: bool)
signal dash_state_changed(charges: int, maximum_charges: int)
signal dash_started(direction: Vector2)
signal died

@export var max_health: int = 100
@export var move_speed: float = 240.0

var health: int = 100
var _dead: bool = false
var _base_max_health: int = 100
var _base_move_speed: float = 240.0
var _run_modifiers := RunModifierSet.new()
var _rng := RandomNumberGenerator.new()
var _movement_intent := Vector2.ZERO
var _pointer_target := Vector2.ZERO
var _has_pointer_target: bool = false
var _resolved_direction := Vector2.ZERO
var _dash_charges: int = MAX_DASH_CHARGES
var _dash_remaining: float = 0.0
var _dash_direction := Vector2.ZERO
var _dash_recharge_elapsed: float = 0.0


func _ready() -> void:
	_base_max_health = maxi(max_health, 1)
	_base_move_speed = maxf(move_speed, 0.0)
	max_health = _base_max_health
	move_speed = _base_move_speed
	health = max_health
	_dead = false
	_rng.randomize()
	health_changed.emit(health, max_health)
	dash_state_changed.emit(_dash_charges, MAX_DASH_CHARGES)


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		return

	set_movement_intent(
		Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	)
	_update_resolved_direction()
	if Input.is_action_just_pressed(&"dash"):
		request_dash()

	if _dash_remaining > 0.0:
		velocity = _dash_direction * move_speed * DASH_SPEED_MULTIPLIER
	else:
		velocity = _resolved_direction * move_speed
	move_and_slide()
	_advance_dash_state(delta)


func set_movement_intent(direction: Vector2) -> void:
	_movement_intent = direction.limit_length(1.0)
	_update_resolved_direction()


func set_pointer_target(world_position: Vector2) -> void:
	_pointer_target = world_position
	_has_pointer_target = true
	_update_resolved_direction()


func clear_pointer_target() -> void:
	_has_pointer_target = false
	_update_resolved_direction()


func current_dash_charges() -> int:
	return _dash_charges


func request_dash() -> bool:
	_update_resolved_direction()
	if _dead or _dash_charges <= 0 or _resolved_direction == Vector2.ZERO:
		return false
	_dash_charges -= 1
	_dash_remaining = DASH_DURATION_SECONDS
	_dash_direction = _resolved_direction
	_dash_recharge_elapsed = 0.0
	dash_started.emit(_dash_direction)
	dash_state_changed.emit(_dash_charges, MAX_DASH_CHARGES)
	return true


func _update_resolved_direction() -> void:
	if not _has_pointer_target:
		_resolved_direction = _movement_intent
		return
	var offset := _pointer_target - global_position
	_resolved_direction = (
		Vector2.ZERO
		if offset.length() <= POINTER_ARRIVAL_RADIUS
		else offset.normalized()
	)


func _advance_dash_state(delta: float) -> void:
	if _dead or delta <= 0.0:
		return
	_dash_remaining = maxf(_dash_remaining - delta, 0.0)
	if _dash_charges >= MAX_DASH_CHARGES:
		_dash_recharge_elapsed = 0.0
		return
	_dash_recharge_elapsed += delta
	while _dash_recharge_elapsed >= DASH_RECHARGE_SECONDS and _dash_charges < MAX_DASH_CHARGES:
		_dash_recharge_elapsed -= DASH_RECHARGE_SECONDS
		_dash_charges += 1
		dash_state_changed.emit(_dash_charges, MAX_DASH_CHARGES)
	if _dash_charges >= MAX_DASH_CHARGES:
		_dash_recharge_elapsed = 0.0


func apply_run_modifiers(modifiers: RunModifierSet) -> void:
	_run_modifiers = modifiers.copy_values() if modifiers != null else RunModifierSet.new()
	var hp_multiplier := maxf(1.0 + _run_modifiers.max_health_pct, 0.0)
	max_health = maxi(roundi((float(_base_max_health) + _run_modifiers.max_health_flat) * hp_multiplier), 1)
	move_speed = maxf(_base_move_speed * maxf(1.0 + _run_modifiers.move_speed_pct, 0.0), 0.0)
	if health > max_health:
		health = max_health
	health_changed.emit(health, max_health)


func heal(amount: int) -> int:
	if amount <= 0 or _dead:
		return 0
	var healing_multiplier := maxf(1.0 + _run_modifiers.healing_pct, 0.0)
	var resolved := maxi(roundi(float(amount) * healing_multiplier), 0)
	if resolved <= 0:
		return 0
	var before := health
	health = mini(health + resolved, max_health)
	var actual := health - before
	if actual > 0:
		health_changed.emit(health, max_health)
		healing_resolved.emit(actual)
	return actual


func restore_after_retry() -> void:
	_dead = false
	velocity = Vector2.ZERO
	health = max_health
	_movement_intent = Vector2.ZERO
	_has_pointer_target = false
	_resolved_direction = Vector2.ZERO
	_dash_charges = MAX_DASH_CHARGES
	_dash_remaining = 0.0
	_dash_direction = Vector2.ZERO
	_dash_recharge_elapsed = 0.0
	health_changed.emit(health, max_health)
	dash_state_changed.emit(_dash_charges, MAX_DASH_CHARGES)


func take_damage(amount: int) -> int:
	if amount <= 0 or _dead:
		return 0

	var requested := amount
	var evasion_chance := clampf(_run_modifiers.evasion_chance, 0.0, 1.0)
	if evasion_chance > 0.0 and _rng.randf() < evasion_chance:
		damage_resolved.emit(requested, 0, requested, true)
		return 0

	var damage_multiplier := maxf(1.0 + _run_modifiers.damage_taken_pct, 0.0)
	var resolved := maxi(roundi(float(requested) * damage_multiplier), 0)
	var prevented := maxi(requested - resolved, 0)
	if resolved <= 0:
		damage_resolved.emit(requested, 0, prevented, false)
		return 0

	var before := health
	health = max(health - resolved, 0)
	var actual := before - health
	damage_resolved.emit(requested, resolved, prevented, false)
	health_changed.emit(health, max_health)

	if health == 0:
		_dead = true
		died.emit()
	return actual


func set_rng_seed(seed_value: int) -> void:
	_rng.seed = seed_value


func is_dead() -> bool:
	return _dead
