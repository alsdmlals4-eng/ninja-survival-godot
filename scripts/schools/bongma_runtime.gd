extends SchoolRuntimeBase
class_name BongmaRuntime

const SPIRIT_MAX := 120.0
const SPIRIT_REGEN := 5.0
const KILL_SPIRIT := 2.0
const KILL_BONUS_META := &"bongma_spirit_death_claimed"
const WARD_INTERVAL := 8.0
const WARD_DURATION := 4.0
const WARD_RADIUS := 140.0
const ULTIMATE_COST := 100.0
const ULTIMATE_DURATION := 6.0
const BASE_ATTACK_INTERVAL := 0.70
const WARD_ATTACK_INTERVAL := 0.50
const ULTIMATE_ATTACK_INTERVAL := 0.50
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
var _second_temporary_familiar: BongmaFamiliar
var _ward_visual: Polygon2D
var _last_ultimate_ready: bool = false
var _kill_bonus_remaining: float = 0.0


func configure_run_systems(
	resolver: CombatResolver,
	tracker: CombatContributionTracker
) -> void:
	super.configure_run_systems(resolver, tracker)
	for familiar in [_base_familiar, _temporary_familiar, _second_temporary_familiar]:
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
	_kill_bonus_remaining = 0.0
	_refresh_familiar_intervals()
	_emit_resource()
	_emit_ultimate_ready_if_changed(true)


func deactivate() -> void:
	_clear_familiar(_base_familiar)
	cancel_ultimate()
	_base_familiar = null
	_clear_ward_visual()
	ward_time_remaining = 0.0
	ultimate_time_remaining = 0.0
	super.deactivate()


func _process(delta: float) -> void:
	if not active or delta <= 0.0 or not is_finite(delta) or get_tree().paused:
		return
	if not is_instance_valid(player) or player.is_dead():
		cancel_ultimate()
		return

	if ultimate_time_remaining <= 0.0:
		_kill_bonus_remaining = maxf(_kill_bonus_remaining - delta, 0.0)
		if _has_target_in_range(480.0):
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
			cancel_ultimate()

	_refresh_familiar_intervals()
	_emit_ultimate_ready_if_changed()


func on_enemy_died(enemy: Node) -> void:
	if not active or ultimate_time_remaining > 0.0 or get_tree().paused or not is_instance_valid(player) or player.is_dead():
		return
	if not enemy is Node2D or enemy.has_meta(KILL_BONUS_META) or combat_resolver == null:
		return
	if not combat_resolver.current_damage_kind_for(enemy) in [&"normal", &"weapon", &"direct_injutsu"]:
		return
	if not enemy.has_method("is_dead") or not enemy.is_dead() or enemy.global_position.distance_squared_to(player.global_position) > 480.0 * 480.0:
		return
	enemy.set_meta(KILL_BONUS_META, true)
	if _kill_bonus_remaining > 0.0:
		return
	_kill_bonus_remaining = 1.0
	_add_spirit(KILL_SPIRIT)


func try_use_ultimate() -> bool:
	if ultimate_block_reason() != &"":
		return false
	_temporary_familiar = _spawn_familiar("FamiliarTemporary")
	_second_temporary_familiar = _spawn_familiar("FamiliarTemporarySecond")
	if not is_instance_valid(_temporary_familiar) or not is_instance_valid(_second_temporary_familiar):
		cancel_ultimate()
		return false

	spirit = maxf(spirit - ULTIMATE_COST, 0.0)
	ultimate_time_remaining = ULTIMATE_DURATION
	_refresh_familiar_intervals()
	for familiar in [_temporary_familiar, _second_temporary_familiar]:
		if ultimate_time_remaining <= 0.0 or not is_instance_valid(familiar):
			break
		familiar.attack_once()
		familiar._cooldown_remaining = ULTIMATE_ATTACK_INTERVAL
	_emit_resource()
	_emit_ultimate_ready_if_changed(true)
	school_feedback.emit("백귀진")
	return true


func is_ultimate_ready() -> bool:
	return active and ultimate_time_remaining <= 0.0 and spirit >= ULTIMATE_COST


func ultimate_block_reason() -> StringName:
	var reason := super.ultimate_block_reason()
	if reason != &"":
		return reason
	if not is_instance_valid(player) or player.is_dead() or get_tree().paused:
		return &"inactive"
	return &"" if _has_target_in_range(320.0, true) else &"no_target"


func cancel_ultimate() -> void:
	ultimate_time_remaining = 0.0
	_clear_familiar(_temporary_familiar)
	_clear_familiar(_second_temporary_familiar)
	_temporary_familiar = null
	_second_temporary_familiar = null


func _has_target_in_range(radius: float, visible_only: bool = false) -> bool:
	if not is_instance_valid(player) or get_tree() == null:
		return false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Node2D or enemy.is_queued_for_deletion() or not enemy.has_method("take_damage"):
			continue
		if is_instance_valid(world) and not world.is_ancestor_of(enemy):
			continue
		if enemy.has_method("is_dead") and enemy.is_dead():
			continue
		if enemy.global_position.distance_squared_to(player.global_position) > radius * radius:
			continue
		if visible_only and (not enemy.is_visible_in_tree() or not enemy.get_viewport_rect().has_point(enemy.get_global_transform_with_canvas().origin)):
			continue
		return true
	return false


func _spawn_base_familiar() -> void:
	if is_instance_valid(_base_familiar):
		return
	_base_familiar = _spawn_familiar("Familiar")


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
	var dedicated := node_name.begins_with("FamiliarTemporary")
	familiar.set_damage_kind(&"ultimate" if dedicated else &"normal")
	if dedicated:
		familiar.target_radius = 320.0
		familiar.target_from_player = true
		familiar.maximum_follow_distance = 180.0
		familiar.follow_offset = Vector2(96.0 if node_name.ends_with("Second") else -96.0, -64.0)
		familiar.follow_distance = 12.0
		familiar.global_position = player.global_position + familiar.follow_offset
	var action_callback := Callable(self, "emit_player_action_resolved")
	if not familiar.attack_resolved.is_connected(action_callback):
		familiar.attack_resolved.connect(action_callback)
	return familiar


func _clear_familiar(familiar: BongmaFamiliar) -> void:
	if is_instance_valid(familiar):
		familiar.process_mode = Node.PROCESS_MODE_DISABLED
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
	for familiar in [_base_familiar, _temporary_familiar, _second_temporary_familiar]:
		if not is_instance_valid(familiar):
			continue
		if familiar != _base_familiar:
			familiar.set_attack_interval(ULTIMATE_ATTACK_INTERVAL)
			familiar.set_damage_kind(&"ultimate")
			continue
		var interval := BASE_ATTACK_INTERVAL
		if ward_time_remaining > 0.0 and familiar.global_position.distance_squared_to(ward_center) <= WARD_RADIUS * WARD_RADIUS:
			interval = WARD_ATTACK_INTERVAL
		familiar.set_attack_interval(interval * interval_multiplier)
		familiar.set_damage_kind(&"normal")


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
