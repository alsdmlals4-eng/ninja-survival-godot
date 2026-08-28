extends CharacterBody2D
class_name PlayerController

signal health_changed(current_health: int, maximum_health: int)
signal healing_resolved(actual: int)
signal damage_resolved(requested: int, resolved: int, prevented: int, evaded: bool)
signal died

@export var max_health: int = 100
@export var move_speed: float = 240.0

var health: int = 100
var _dead: bool = false
var _base_max_health: int = 100
var _base_move_speed: float = 240.0
var _run_modifiers := RunModifierSet.new()
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_base_max_health = maxi(max_health, 1)
	_base_move_speed = maxf(move_speed, 0.0)
	max_health = _base_max_health
	move_speed = _base_move_speed
	health = max_health
	_dead = false
	_rng.randomize()
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
	health_changed.emit(health, max_health)


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
