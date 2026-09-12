extends CharacterBody2D
class_name PlayerController

const MAX_DASH_CHARGES := 2
const DASH_DURATION_SECONDS := 0.20
const DASH_SPEED_MULTIPLIER := 3.0
const DASH_RECHARGE_SECONDS := 1.5
const POINTER_ARRIVAL_RADIUS := 12.0
const HIT_PROTECTION_SECONDS := 0.35
const ENTRY_PROTECTION_SECONDS := 1.0

signal health_changed(current_health: int, maximum_health: int)
signal healing_resolved(actual: int)
signal damage_resolved(requested: int, resolved: int, prevented: int, evaded: bool)
signal dash_state_changed(charges: int, maximum_charges: int)
signal dash_started(direction: Vector2)
signal dash_ended
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
var _last_movement_direction := Vector2.ZERO
var _last_weapon_direction := Vector2.ZERO


var _dash_charges: int = MAX_DASH_CHARGES
var _dash_remaining: float = 0.0
var _dash_direction := Vector2.ZERO
var _dash_recharge_elapsed: float = 0.0
var _dash_saved_layer: int = 0
var _dash_saved_mask: int = 0
var _dash_collision_override: bool = false
var _damage_protection_remaining: float = 0.0
var _ninjutsu_boons: Dictionary = {}
var _selected_combat_rules := false


func set_selected_combat_rules(enabled: bool) -> void:
	if _selected_combat_rules == enabled:
		return
	_selected_combat_rules = enabled
	_refresh_move_speed()


# Transient combat effects only. Never added to persistent RunModifierSet/save.
func set_ninjutsu_boon(source: StringName, reduction: float, speed_bonus: float, shield: int = 0) -> bool:
	if source == &"" or not is_finite(reduction) or not is_finite(speed_bonus) or reduction < 0 or reduction > 1 or speed_bonus < 0 or shield < 0 or _dead:
		return false
	var previous: Dictionary = _ninjutsu_boons.get(source, {})
	_ninjutsu_boons[source] = {"reduction": reduction, "speed_bonus": speed_bonus, "shield": maxi(shield, int(previous.get("shield", 0)))}
	_refresh_move_speed()
	return true


func remove_ninjutsu_boon(source: StringName) -> void:
	_ninjutsu_boons.erase(source)
	_refresh_move_speed()


func _refresh_move_speed() -> void:
	var bonus := _run_modifiers.move_speed_pct
	for boon in _ninjutsu_boons.values():
		bonus += float(boon.speed_bonus)
	var multiplier := maxf(1.0 + bonus, 0.0)
	if _selected_combat_rules:
		multiplier = minf(multiplier, 1.6)
	move_speed = maxf(_base_move_speed * multiplier, 0.0)


func combat_facing_direction() -> Vector2:
	if not _last_movement_direction.is_zero_approx():
		return _last_movement_direction
	return _last_weapon_direction if not _last_weapon_direction.is_zero_approx() else Vector2.RIGHT


func record_auto_weapon_direction(direction: Vector2) -> void:
	if direction.is_finite() and not direction.is_zero_approx():
		_last_weapon_direction = direction.normalized()


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
	if get_tree().paused:
		return
	advance_damage_protection(delta)
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
	if _dead or _dash_charges <= 0 or _dash_remaining > 0.0 or get_tree().paused:
		return false
	_update_resolved_direction()
	var recharge_was_idle := _dash_charges == MAX_DASH_CHARGES
	_dash_charges -= 1
	_dash_remaining = DASH_DURATION_SECONDS
	_dash_saved_layer = collision_layer
	_dash_saved_mask = collision_mask
	_dash_collision_override = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(2, false)
	_dash_direction = _last_movement_direction if not _last_movement_direction.is_zero_approx() else Vector2.DOWN
	if recharge_was_idle:
		_dash_recharge_elapsed = 0.0
	dash_started.emit(_dash_direction)
	dash_state_changed.emit(_dash_charges, MAX_DASH_CHARGES)
	return true


func _update_resolved_direction() -> void:
	if not _has_pointer_target:
		_resolved_direction = _movement_intent
		if not _resolved_direction.is_zero_approx():
			_last_movement_direction = _resolved_direction.normalized()
		return
	var offset := _pointer_target - global_position
	_resolved_direction = (
		Vector2.ZERO
		if offset.length() <= POINTER_ARRIVAL_RADIUS
		else offset.normalized()
	)
	if not _resolved_direction.is_zero_approx():
		_last_movement_direction = _resolved_direction.normalized()


func _advance_dash_state(delta: float) -> void:
	if _dead or delta <= 0.0 or not is_finite(delta) or get_tree().paused:
		return
	var was_dashing := _dash_remaining > 0.0
	_dash_remaining = maxf(_dash_remaining - delta, 0.0)
	if _dash_remaining <= 0.0:
		_restore_dash_collision()
		if was_dashing:
			dash_ended.emit()
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
	_refresh_move_speed()
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
	_restore_dash_collision()
	_ninjutsu_boons.clear()
	_refresh_move_speed()
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
	grant_entry_protection()
	health_changed.emit(health, max_health)
	dash_state_changed.emit(_dash_charges, MAX_DASH_CHARGES)


func _restore_dash_collision() -> void:
	if not _dash_collision_override:
		return
	collision_layer = _dash_saved_layer
	collision_mask = _dash_saved_mask
	_dash_collision_override = false


func take_damage(amount: int) -> int:
	if amount <= 0 or _dead or (is_inside_tree() and get_tree().paused):
		return 0

	var requested := amount
	if _damage_protection_remaining > 0.0:
		damage_resolved.emit(requested, 0, requested, false)
		return 0
	if _dash_remaining > 0.0:
		damage_resolved.emit(requested, 0, requested, true)
		return 0

	var evasion_chance := clampf(_run_modifiers.evasion_chance, 0.0, 1.0)
	if evasion_chance > 0.0 and _rng.randf() < evasion_chance:
		damage_resolved.emit(requested, 0, requested, true)
		return 0

	var damage_multiplier := maxf(1.0 + _run_modifiers.damage_taken_pct, 0.0)
	var reduction := 0.0
	var strongest_ward := 0.0
	for source in _ninjutsu_boons:
		var boon: Dictionary = _ninjutsu_boons[source]
		if source in [&"bongma_guardian_ward", &"bongma_barrier_step"]:
			strongest_ward = maxf(strongest_ward, float(boon.reduction))
		else:
			reduction += float(boon.reduction)
	reduction += strongest_ward
	var final_multiplier := damage_multiplier * (1.0 - minf(reduction, 0.6))
	if _selected_combat_rules:
		final_multiplier = maxf(1.0 + _run_modifiers.damage_taken_pct - reduction, 0.4)
	var resolved := maxi(roundi(float(requested) * final_multiplier), 0)
	# Stable source order makes multi-shield consumption deterministic.
	var sources := _ninjutsu_boons.keys()
	sources.sort()
	for source in sources:
		var boon: Dictionary = _ninjutsu_boons[source]
		var absorbed := mini(resolved, int(boon.shield))
		boon.shield = int(boon.shield) - absorbed
		resolved -= absorbed
	var prevented := maxi(requested - resolved, 0)
	if resolved <= 0:
		damage_resolved.emit(requested, 0, prevented, false)
		return 0

	var before := health
	health = max(health - resolved, 0)
	var actual := before - health
	if actual > 0:
		_damage_protection_remaining = HIT_PROTECTION_SECONDS
	damage_resolved.emit(requested, resolved, prevented, false)
	health_changed.emit(health, max_health)

	if health == 0:
		_dead = true
		_ninjutsu_boons.clear()
		_refresh_move_speed()
		died.emit()
	return actual


func grant_entry_protection() -> void:
	_damage_protection_remaining = maxf(_damage_protection_remaining, ENTRY_PROTECTION_SECONDS)


func advance_damage_protection(delta: float) -> void:
	if delta <= 0.0 or not is_finite(delta) or _dead or (is_inside_tree() and get_tree().paused):
		return
	_damage_protection_remaining = maxf(_damage_protection_remaining - delta, 0.0)


func set_rng_seed(seed_value: int) -> void:
	_rng.seed = seed_value


func is_dead() -> bool:
	return _dead
