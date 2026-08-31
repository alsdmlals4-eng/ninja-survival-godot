extends Node
class_name BasicWeaponController

signal katana_resolved(target_count: int)
signal shuriken_fired(projectile: Node2D)

@export var katana_interval: float = 0.65
@export var katana_radius: float = 112.0
@export var katana_max_targets: int = 3
@export var katana_damage: float = 10.0
@export var shuriken_interval: float = 0.75
@export var shuriken_projectile_scene: PackedScene
@export var shuriken_speed: float = 560.0
@export var shuriken_damage: int = 9
@export var weapon_effect_texture: Texture2D
@export var katana_effect_lifetime: float = 0.14
@export var katana_effect_scale := Vector2(0.075, 0.075)

var combat_resolver: CombatResolver
var _katana_remaining: float = 0.0
var _shuriken_remaining: float = 0.0
var _active_katana_effects: Array[Dictionary] = []


func configure(new_combat_resolver: CombatResolver) -> void:
	combat_resolver = new_combat_resolver


func _process(delta: float) -> void:
	var source := get_parent() as Node2D
	if source == null:
		return
	if source.has_method("is_dead") and bool(source.call("is_dead")):
		return

	_advance_katana_effects(delta)
	_katana_remaining = maxf(_katana_remaining - delta, 0.0)
	_shuriken_remaining = maxf(_shuriken_remaining - delta, 0.0)
	if _katana_remaining <= 0.0:
		if swing_katana_once() > 0:
			_katana_remaining = maxf(katana_interval, 0.05)
		else:
			_katana_remaining = 0.1
	if _shuriken_remaining <= 0.0:
		if fire_shuriken_once() != null:
			_shuriken_remaining = maxf(shuriken_interval, 0.05)
		else:
			_shuriken_remaining = 0.1


func find_nearest_target(candidates: Array, origin: Vector2) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance: float = INF

	for candidate in candidates:
		if not _is_valid_target(candidate):
			continue
		var target := candidate as Node2D
		var distance := origin.distance_squared_to(target.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = target

	return nearest


func swing_katana_once() -> int:
	var source := get_parent() as Node2D
	if source == null or get_tree() == null or katana_radius <= 0.0 or katana_max_targets <= 0:
		return 0

	var targets := _closest_targets_in_radius(
		get_tree().get_nodes_in_group("enemies"),
		source.global_position,
		katana_radius,
		katana_max_targets
	)
	if targets.is_empty():
		return 0

	for target in targets:
		_resolve_basic_damage(target, katana_damage)
	_spawn_katana_effect(source, targets[0])
	katana_resolved.emit(targets.size())
	return targets.size()


func fire_shuriken_once() -> Node2D:
	if shuriken_projectile_scene == null:
		return null
	var source := get_parent() as Node2D
	if source == null or get_tree() == null:
		return null

	var target := find_nearest_target(get_tree().get_nodes_in_group("enemies"), source.global_position)
	if target == null:
		return null
	var aim := target.global_position - source.global_position
	if aim.is_zero_approx():
		return null

	var projectile_node := shuriken_projectile_scene.instantiate()
	if not projectile_node is Node2D:
		projectile_node.free()
		return null
	var world := source.get_parent()
	if world == null:
		projectile_node.free()
		return null

	world.add_child(projectile_node)
	var projectile := projectile_node as Node2D
	projectile.global_position = source.global_position
	if projectile.has_method("configure"):
		projectile.call("configure", aim, shuriken_speed, shuriken_damage, combat_resolver)
	shuriken_fired.emit(projectile)
	return projectile


func _closest_targets_in_radius(
	candidates: Array,
	origin: Vector2,
	radius: float,
	limit: int
) -> Array[Node2D]:
	var valid_targets: Array[Node2D] = []
	var radius_squared := radius * radius
	for candidate in candidates:
		if not _is_valid_target(candidate):
			continue
		var target := candidate as Node2D
		if origin.distance_squared_to(target.global_position) <= radius_squared:
			valid_targets.append(target)

	valid_targets.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position)
	)
	return valid_targets.slice(0, mini(limit, valid_targets.size()))


func _resolve_basic_damage(target: Node, base_damage: float) -> int:
	if combat_resolver != null:
		return combat_resolver.deal_basic_weapon_damage(target, base_damage)
	if target == null or not is_instance_valid(target) or not target.has_method("take_damage") or base_damage <= 0.0:
		return 0
	var result = target.call("take_damage", maxi(roundi(base_damage), 1))
	return int(result) if result is int else 0


func _is_valid_target(candidate: Variant) -> bool:
	if not is_instance_valid(candidate) or not candidate is Node2D:
		return false
	if candidate.has_method("is_dead") and bool(candidate.call("is_dead")):
		return false
	return candidate.has_method("take_damage")


func _spawn_katana_effect(source: Node2D, target: Node2D) -> void:
	if weapon_effect_texture == null:
		return
	var world := source.get_parent()
	if world == null:
		return
	var effect := Sprite2D.new()
	effect.name = "KatanaEffect"
	effect.texture = weapon_effect_texture
	effect.region_enabled = true
	var texture_size := weapon_effect_texture.get_size()
	effect.region_rect = Rect2(Vector2.ZERO, Vector2(texture_size.x * 0.5, texture_size.y))
	effect.global_position = source.global_position + (target.global_position - source.global_position).normalized() * 36.0
	effect.rotation = (target.global_position - source.global_position).angle()
	effect.scale = katana_effect_scale
	effect.z_index = 2
	world.add_child(effect)
	_active_katana_effects.append({"node": effect, "remaining": maxf(katana_effect_lifetime, 0.01)})


func _advance_katana_effects(delta: float) -> void:
	if delta <= 0.0:
		return
	for index in range(_active_katana_effects.size() - 1, -1, -1):
		var effect_state: Dictionary = _active_katana_effects[index]
		var effect := effect_state.get("node") as Node
		var remaining := float(effect_state.get("remaining", 0.0)) - delta
		if remaining > 0.0 and is_instance_valid(effect):
			effect_state["remaining"] = remaining
			_active_katana_effects[index] = effect_state
			continue
		if is_instance_valid(effect) and not effect.is_queued_for_deletion():
			effect.queue_free()
		_active_katana_effects.remove_at(index)
