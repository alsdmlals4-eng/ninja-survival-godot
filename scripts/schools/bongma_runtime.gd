extends SchoolRuntimeBase
class_name BongmaRuntime

const SPIRIT_MAX := 120.0
const SPIRIT_REGEN := 5.0
const KILL_SPIRIT := 10.0
const WARD_INTERVAL := 8.0
const WARD_DURATION := 4.0
const WARD_RADIUS := 140.0
const ULTIMATE_COST := 100.0
const ULTIMATE_DURATION := 6.0
const BASE_ATTACK_INTERVAL := 0.70
const WARD_ATTACK_INTERVAL := 0.50
const ULTIMATE_ATTACK_INTERVAL := 0.30
const FAMILIAR_DAMAGE := 8

@export var familiar_scene: PackedScene

var spirit: float = 0.0
var spirit_maximum: float = SPIRIT_MAX
var ward_center: Vector2 = Vector2.ZERO
var ward_time_remaining: float = 0.0
var ultimate_time_remaining: float = 0.0

var _ward_spawn_remaining: float = WARD_INTERVAL
var _base_familiar: BongmaFamiliar
var _temporary_familiar: BongmaFamiliar
var _ward_visual: Polygon2D
var _last_ultimate_ready: bool = false


func configure_run_systems(
	resolver: CombatResolver,
	tracker: CombatContributionTracker
) -> void:
	super.configure_run_systems(resolver, tracker)
	for familiar in [_base_familiar, _temporary_familiar]:
		if is_instance_valid(familiar):
			familiar.set_combat_resolver(resolver)


func apply_run_modifiers(modifiers: RunModifierSet) -> void:
	super.apply_run_modifiers(modifiers)
	if active:
		_refresh_familiar_intervals()


func activate() -> void:
	if active:
		return
	super.activate()
	spirit_maximum = SPIRIT_MAX
	spirit = clampf(spirit, 0.0, spirit_maximum)
	_ward_spawn_remaining = WARD_INTERVAL
	ward_time_remaining = 0.0
	ultimate_time_remaining = 0.0
	_spawn_base_familiar()
	_refresh_familiar_intervals()
	_emit_resource()
	_emit_ultimate_ready_if_changed(true)


func deactivate() -> void:
	_clear_familiar(_base_familiar)
	_clear_familiar(_temporary_familiar)
	_base_familiar = null
	_temporary_familiar = null
	_clear_ward_visual()
	ward_time_remaining = 0.0
	ultimate_time_remaining = 0.0
	super.deactivate()


func _process(delta: float) -> void:
	if not active or delta <= 0.0:
		return

	_add_spirit(SPIRIT_REGEN * delta)

	if ward_time_remaining > 0.0:
		ward_time_remaining = maxf(ward_time_remaining - delta, 0.0)
		if ward_time_remaining <= 0.0:
			_clear_ward_visual()

	_ward_spawn_remaining -= delta
	if _ward_spawn_remaining <= 0.0:
		_place_ward()
		_ward_spawn_remaining = WARD_INTERVAL

	if ultimate_time_remaining > 0.0:
		ultimate_time_remaining = maxf(ultimate_time_remaining - delta, 0.0)
		if ultimate_time_remaining <= 0.0:
			_clear_familiar(_temporary_familiar)
			_temporary_familiar = null

	_refresh_familiar_intervals()
	_emit_ultimate_ready_if_changed()


func on_enemy_died(_enemy: Node) -> void:
	if not active:
		return
	_add_spirit(KILL_SPIRIT)


func try_use_ultimate() -> bool:
	if not is_ultimate_ready():
		return false

	spirit = maxf(spirit - ULTIMATE_COST, 0.0)
	ultimate_time_remaining = ULTIMATE_DURATION
	_spawn_temporary_familiar()
	_refresh_familiar_intervals()
	_emit_resource()
	_emit_ultimate_ready_if_changed(true)
	school_feedback.emit("백귀야행")
	return true


func is_ultimate_ready() -> bool:
	return active and ultimate_time_remaining <= 0.0 and spirit >= ULTIMATE_COST


func _spawn_base_familiar() -> void:
	if is_instance_valid(_base_familiar):
		return
	_base_familiar = _spawn_familiar("Familiar")


func _spawn_temporary_familiar() -> void:
	if is_instance_valid(_temporary_familiar):
		return
	_temporary_familiar = _spawn_familiar("FamiliarTemporary")


func _spawn_familiar(node_name: String) -> BongmaFamiliar:
	if familiar_scene == null or not is_instance_valid(player):
		return null

	var instance := familiar_scene.instantiate()
	if not instance is BongmaFamiliar:
		instance.free()
		return null

	var familiar := instance as BongmaFamiliar
	familiar.name = node_name
	add_child(familiar)
	familiar.global_position = player.global_position + Vector2(48.0, 0.0)
	familiar.configure(player, BASE_ATTACK_INTERVAL, FAMILIAR_DAMAGE, combat_resolver)
	familiar.set_damage_kind(&"ultimate" if ultimate_time_remaining > 0.0 else &"normal")
	return familiar


func _clear_familiar(familiar: BongmaFamiliar) -> void:
	if is_instance_valid(familiar):
		familiar.queue_free()


func _place_ward() -> void:
	if not is_instance_valid(player):
		return
	ward_center = player.global_position
	ward_time_remaining = WARD_DURATION
	_clear_ward_visual()
	_ward_visual = Polygon2D.new()
	_ward_visual.name = "WardVisual"
	_ward_visual.polygon = _circle_points(WARD_RADIUS, 32)
	_ward_visual.color = Color(0.3, 0.75, 1.0, 0.16)
	add_child(_ward_visual)
	_ward_visual.global_position = ward_center


func _clear_ward_visual() -> void:
	if is_instance_valid(_ward_visual):
		_ward_visual.queue_free()
	_ward_visual = null


func _refresh_familiar_intervals() -> void:
	var interval_multiplier := maxf(1.0 + run_modifiers.bongma_familiar_interval_pct, 0.05)
	var damage_kind: StringName = &"ultimate" if ultimate_time_remaining > 0.0 else &"normal"
	for familiar in [_base_familiar, _temporary_familiar]:
		if not is_instance_valid(familiar):
			continue
		var interval := BASE_ATTACK_INTERVAL
		if ultimate_time_remaining > 0.0:
			interval = ULTIMATE_ATTACK_INTERVAL
		elif ward_time_remaining > 0.0 and familiar.global_position.distance_squared_to(ward_center) <= WARD_RADIUS * WARD_RADIUS:
			interval = WARD_ATTACK_INTERVAL
		familiar.set_attack_interval(interval * interval_multiplier)
		familiar.set_damage_kind(damage_kind)


func _add_spirit(amount: float) -> void:
	if amount <= 0.0:
		return
	var gain_multiplier := maxf(1.0 + run_modifiers.school_resource_gain_pct, 0.0)
	gain_multiplier *= maxf(1.0 + run_modifiers.ultimate_charge_gain_pct, 0.0)
	var previous := spirit
	spirit = clampf(spirit + amount * gain_multiplier, 0.0, spirit_maximum)
	if not is_equal_approx(previous, spirit):
		_emit_resource()
		_emit_ultimate_ready_if_changed()


func _emit_resource() -> void:
	resource_changed.emit("SPIRIT", spirit, spirit_maximum)


func _emit_ultimate_ready_if_changed(force: bool = false) -> void:
	var ready := is_ultimate_ready()
	if force or ready != _last_ultimate_ready:
		_last_ultimate_ready = ready
		ultimate_ready_changed.emit(ready)


func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(maxi(segments, 3)):
		var angle := TAU * float(index) / float(maxi(segments, 3))
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points
