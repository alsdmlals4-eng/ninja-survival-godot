extends Node
class_name BasicWeaponController

const EQUIPMENT_STATE_SCRIPT = preload("res://scripts/core/equipment_loadout_state.gd")
const EQUIPMENT_CATALOG_SCRIPT = preload("res://scripts/data/equipment_catalog.gd")

signal katana_resolved(target_count: int)
signal shuriken_fired(projectile: Node2D)

@export var katana_interval: float = 0.65
@export var katana_radius: float = 112.0
@export var katana_half_angle_degrees: float = 60.0
@export var katana_damage: float = 10.0
@export var shuriken_interval: float = 0.75
@export var shuriken_projectile_scene: PackedScene
@export var shuriken_speed: float = 560.0
@export var shuriken_damage: int = 9
@export var shuriken_target_radius: float = 480.0
@export var weapon_effect_texture: Texture2D
@export var katana_effect_lifetime: float = 0.14
@export var katana_effect_scale := Vector2(0.075, 0.075)

var combat_resolver: CombatResolver
var _katana_remaining: float = 0.0
var _shuriken_remaining: float = 0.0
var _active_katana_effects: Array[Dictionary] = []
var _melee_shape: String = "cone"
var _melee_width: float = 0.0
var _projectile_profile: Dictionary = {}
var _melee_equipment_bonus: float = 0.0
var _guiin_original: Dictionary = {}
var _guiin_sword_remaining: float = 0.0


func configure(new_combat_resolver: CombatResolver) -> void:
	combat_resolver = new_combat_resolver


func apply_equipment_snapshot(snapshot: Dictionary) -> bool:
	if not _guiin_original.is_empty():
		return false
	var equipment = EQUIPMENT_STATE_SCRIPT.new()
	if not equipment.restore_snapshot(snapshot):
		return false
	var melee: Dictionary = EQUIPMENT_CATALOG_SCRIPT.definition(equipment.equipped_definition(&"melee"))
	var projectile: Dictionary = EQUIPMENT_CATALOG_SCRIPT.definition(equipment.equipped_definition(&"projectile"))
	katana_interval = float(melee["interval"])
	_melee_equipment_bonus = equipment.equipped_damage_bonus(&"melee")
	katana_radius = float(melee["range"])
	katana_damage = float(melee["damage"]) * (1.0 + equipment.equipped_damage_bonus(&"melee"))
	katana_half_angle_degrees = float(melee.get("angle", 0.0)) * 0.5
	_melee_shape = str(melee["shape"])
	_melee_width = float(melee.get("width", 0.0))
	_projectile_profile = projectile
	shuriken_interval = float(projectile["interval"])
	shuriken_target_radius = float(projectile["range"])
	shuriken_speed = float(projectile.get("speed", 0.0))
	shuriken_damage = roundi(float(projectile["damage"]) * (1.0 + equipment.equipped_damage_bonus(&"projectile")))
	return true


func begin_guiin_form() -> bool:
	var source := get_parent() as Node2D
	if not _guiin_original.is_empty() or source == null or not is_inside_tree() or get_tree().paused:
		return false
	if source.has_method("is_dead") and bool(source.call("is_dead")):
		return false
	_guiin_original = {"damage": katana_damage, "radius": katana_radius, "angle": katana_half_angle_degrees,
		"interval": katana_interval, "shape": _melee_shape, "width": _melee_width}
	katana_damage = 20.0 * (1.0 + _melee_equipment_bonus)
	katana_radius = 168.0
	katana_half_angle_degrees = 75.0
	katana_interval = 0.325
	_melee_shape = "cone"
	_melee_width = 0.0
	if combat_resolver != null:
		combat_resolver.sword_only_mode = true
	for projectile in get_tree().get_nodes_in_group("friendly_weapon_projectiles"):
		if projectile is BasicProjectile and projectile.get_parent() == source.get_parent() and projectile.combat_resolver == combat_resolver:
			projectile.queue_free()
	_guiin_sword_remaining = 0.325 if swing_katana_once() > 0 else 0.12
	return true


func end_guiin_form() -> void:
	if _guiin_original.is_empty():
		return
	katana_damage = float(_guiin_original["damage"])
	katana_radius = float(_guiin_original["radius"])
	katana_half_angle_degrees = float(_guiin_original["angle"])
	katana_interval = float(_guiin_original["interval"])
	_melee_shape = str(_guiin_original["shape"])
	_melee_width = float(_guiin_original["width"])
	_guiin_original.clear()
	_guiin_sword_remaining = 0.0
	if is_instance_valid(combat_resolver):
		combat_resolver.sword_only_mode = false


func _exit_tree() -> void:
	end_guiin_form()


func _process(delta: float) -> void:
	if delta <= 0.0 or get_tree().paused:
		return
	var source := get_parent() as Node2D
	if source == null:
		return
	if source.has_method("is_dead") and bool(source.call("is_dead")):
		return

	_advance_katana_effects(delta)
	if not _guiin_original.is_empty():
		_guiin_sword_remaining = maxf(_guiin_sword_remaining - delta, 0.0)
		if _guiin_sword_remaining <= 0.0:
			_guiin_sword_remaining = katana_interval if swing_katana_once() > 0 else 0.12
		return
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
		if distance < nearest_distance or (distance == nearest_distance and nearest != null and target.get_instance_id() < nearest.get_instance_id()):
			nearest_distance = distance
			nearest = target

	return nearest


func swing_katana_once() -> int:
	var source := get_parent() as Node2D
	if source == null or get_tree() == null or get_tree().paused or katana_radius <= 0.0:
		return 0
	if source.has_method("is_dead") and source.call("is_dead"):
		return 0

	var targets := _closest_targets_in_radius(
		get_tree().get_nodes_in_group("enemies"),
		source.global_position,
		katana_radius
	)
	if targets.is_empty():
		return 0
	var aim := (targets[0].global_position - source.global_position).normalized()
	if aim.is_zero_approx():
		aim = source.combat_facing_direction() if source is PlayerController else Vector2.RIGHT
	if _melee_shape == "rectangle":
		targets = _closest_targets_in_radius(get_tree().get_nodes_in_group("enemies"), source.global_position,
			sqrt(katana_radius * katana_radius + _melee_width * _melee_width * 0.25))
	var cone_targets: Array[Node2D] = []
	for target in targets:
		var offset := target.global_position - source.global_position
		var inside: bool
		if _melee_shape == "rectangle":
			inside = offset.dot(aim) >= 0.0 and offset.dot(aim) <= katana_radius and absf(offset.cross(aim)) <= _melee_width * 0.5
		else:
			inside = offset.is_zero_approx() or offset.normalized().dot(aim) >= cos(deg_to_rad(katana_half_angle_degrees)) - 0.000001
		if inside:
			cone_targets.append(target)

	if source is PlayerController:
		source.record_auto_weapon_direction(aim)
	for target in cone_targets:
		_resolve_basic_damage(target, katana_damage)
	_spawn_katana_effect(source, targets[0])
	katana_resolved.emit(cone_targets.size())
	return cone_targets.size()


func fire_shuriken_once() -> Node2D:
	if not _guiin_original.is_empty():
		return null
	if shuriken_projectile_scene == null:
		return null
	var source := get_parent() as Node2D
	if source == null or get_tree() == null or get_tree().paused:
		return null
	if source.has_method("is_dead") and source.call("is_dead"):
		return null

	var target := find_nearest_target(get_tree().get_nodes_in_group("enemies"), source.global_position)
	if target == null or source.global_position.distance_squared_to(target.global_position) > shuriken_target_radius * shuriken_target_radius:
		return null
	var aim := target.global_position - source.global_position
	if aim.is_zero_approx():
		return null
	if _projectile_profile.get("shape", "") == "delayed_blast":
		var bomb := _spawn_projectile(source, Vector2.ZERO)
		if bomb != null:
			bomb.global_position = target.global_position
		return bomb

	var first: Node2D = null
	var count := int(_projectile_profile.get("count", 1))
	for index in range(count):
		var offset_degrees := float(_projectile_profile.get("spread", 0.0)) * (-1.0 if index == 0 else 1.0) if count > 1 else 0.0
		var projectile := _spawn_projectile(source, aim.rotated(deg_to_rad(offset_degrees)))
		if first == null:
			first = projectile
	if first != null and source is PlayerController:
		source.record_auto_weapon_direction(aim)
	return first


func _spawn_projectile(source: Node2D, aim: Vector2) -> Node2D:
	var projectile_node := shuriken_projectile_scene.instantiate()
	if not projectile_node is Node2D:
		projectile_node.free()
		return null
	var world := source.get_parent()
	if world == null:
		projectile_node.free()
		return null

	if projectile_node is BasicProjectile and not _projectile_profile.is_empty():
		projectile_node.lifetime = float(_projectile_profile.get("lifetime", 1.0))
		projectile_node.pierce_count = int(_projectile_profile.get("pierce", 0))
		if _projectile_profile.get("shape", "") == "delayed_blast":
			projectile_node.blast_radius = float(_projectile_profile["radius"])
			projectile_node.blast_delay = float(_projectile_profile["delay"])
			projectile_node.collision_layer = 0
			projectile_node.collision_mask = 0
			projectile_node.monitoring = false
		var collision := projectile_node.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision != null and collision.shape is CircleShape2D:
			collision.shape = collision.shape.duplicate()
			collision.shape.radius = float(_projectile_profile["radius"])
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
	radius: float
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
		var a_distance := origin.distance_squared_to(a.global_position)
		var b_distance := origin.distance_squared_to(b.global_position)
		return a.get_instance_id() < b.get_instance_id() if a_distance == b_distance else a_distance < b_distance
	)
	return valid_targets


func _resolve_basic_damage(target: Node, base_damage: float) -> int:
	if combat_resolver != null:
		if not _guiin_original.is_empty():
			return combat_resolver.deal_guiin_sword_damage(target, base_damage)
		return combat_resolver.deal_basic_weapon_damage(target, base_damage)
	if target == null or not is_instance_valid(target) or not target.has_method("take_damage") or base_damage <= 0.0:
		return 0
	var result = target.call("take_damage", maxi(roundi(base_damage), 1))
	return int(result) if result is int else 0


func _is_valid_target(candidate: Variant) -> bool:
	if not is_instance_valid(candidate) or not candidate is Node2D or candidate.is_queued_for_deletion():
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
