extends Node
class_name BasicWeaponController

const EQUIPMENT_STATE_SCRIPT = preload("res://scripts/core/equipment_loadout_state.gd")
const EQUIPMENT_CATALOG_SCRIPT = preload("res://scripts/data/equipment_catalog.gd")
const BACKPACK_SCRIPT = preload("res://scripts/backpack/backpack_state.gd")
const BACKPACK_RESOLVER = preload("res://scripts/backpack/backpack_resolver.gd")
const SELECTED_CATALOG = preload("res://scripts/data/selected_backpack_catalog.gd")
const SPATIAL_CATALOG = preload("res://scripts/data/mvp4_catalog.gd")
const POWER_RUNTIME = preload("res://scripts/combat/equipment_power_runtime.gd")
var _equipment_powers = POWER_RUNTIME.new()

signal katana_resolved(target_count: int)
signal shuriken_fired(projectile: Node2D)

@export var katana_interval: float = 0.65
@export var katana_radius: float = 112.0
@export var katana_half_angle_degrees: float = 60.0
@export var katana_damage: float = 10.0
@export var shuriken_interval: float = 0.75
@export var shuriken_projectile_scene: PackedScene
@export var shuriken_speed: float = 560.0
@export var shuriken_damage: float = 9.0
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
var _projectile_equipment_bonus: float = 0.0
var _guiin_original: Dictionary = {}
var _guiin_sword_remaining: float = 0.0
var _melee_manual_bonus: float = 0.0
var _projectile_manual_bonus: float = 0.0
var _combination_effects: Array[StringName] = []
var _thunder_remaining: float = 0.0
var _explosive_remaining: float = 0.0
var _combination_generation: int = 0
var _mist_remaining: float = 0.0
var _mist_cooldown: float = 0.0
const MIST_BOON: StringName = &"combination_water_mist"


# The preparation coordinator calls this only after committing its whole build.
# Derive from canonical definitions, never from UI-supplied modifier numbers.
func apply_committed_backpack(backpack) -> bool:
	if not _guiin_original.is_empty() or not (backpack is BACKPACK_SCRIPT) or not backpack.uses_selectable_books():
		return false
	var definitions: Dictionary = SELECTED_CATALOG.build_items()
	var resolution = BACKPACK_RESOLVER.new().resolve(backpack, definitions, SPATIAL_CATALOG.build_bags(), &"")
	if not resolution.valid:
		return false
	var melee := 0.0
	var projectile := 0.0
	var effects: Array[StringName] = []
	for item in backpack.items.values():
		var payload: Dictionary = definitions[item.definition_id].school_payload
		if payload.has("combination_effect"):
			effects.append(StringName(payload.combination_effect))
		if payload.get("weapon_slot", "") == "melee":
			melee += float(payload.get("weapon_damage_bonus", 0.0))
		elif payload.get("weapon_slot", "") == "projectile":
			projectile += float(payload.get("weapon_damage_bonus", 0.0))
	_melee_manual_bonus = clampf(melee, 0.0, 0.60)
	_projectile_manual_bonus = clampf(projectile, 0.0, 0.60)
	_combination_effects = effects
	_combination_generation += 1
	var player := get_parent() as PlayerController
	if player != null:
		if not player.damage_resolved.is_connected(_on_player_damage):
			player.damage_resolved.connect(_on_player_damage)
		if not effects.has(&"water_mist"):
			_mist_remaining = 0.0
			player.remove_ninjutsu_boon(MIST_BOON)
	return true


func configure(new_combat_resolver: CombatResolver) -> void:
	combat_resolver = new_combat_resolver


func reset_for_checkpoint() -> void:
	# A checkpoint owns the committed build, not the failed battle's live attacks
	# or temporary clocks. Pause alone never calls this reset.
	end_guiin_form()
	_combination_generation += 1
	_katana_remaining = 0.0
	_shuriken_remaining = 0.0
	_thunder_remaining = 0.0
	_explosive_remaining = 0.0
	_mist_remaining = 0.0
	_mist_cooldown = 0.0
	var source := get_parent()
	_equipment_powers.clear(source)
	if source is PlayerController: source.remove_ninjutsu_boon(MIST_BOON)
	for effect in _active_katana_effects:
		var node = effect.get("node")
		if is_instance_valid(node) and not node.is_queued_for_deletion(): node.queue_free()
	_active_katana_effects.clear()
	if get_tree() == null or source == null: return
	for projectile in get_tree().get_nodes_in_group("friendly_weapon_projectiles"):
		if projectile is BasicProjectile and projectile.get_parent() == source.get_parent() and projectile.combat_resolver == combat_resolver:
			projectile.queue_free()


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
	katana_damage = float(melee["damage"])
	katana_half_angle_degrees = float(melee.get("angle", 0.0)) * 0.5
	_melee_shape = str(melee["shape"])
	_melee_width = float(melee.get("width", 0.0))
	_projectile_profile = projectile
	shuriken_interval = float(projectile["interval"])
	shuriken_target_radius = float(projectile["range"])
	shuriken_speed = float(projectile.get("speed", 0.0))
	_projectile_equipment_bonus = equipment.equipped_damage_bonus(&"projectile")
	shuriken_damage = float(projectile["damage"])
	_equipment_powers.configure(snapshot, get_parent())
	_combination_generation += 1 # In-flight projectiles cannot acquire a newly equipped power.
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
	_equipment_powers.clear(get_parent())
	var player := get_parent() as PlayerController
	if is_instance_valid(player):
		player.remove_ninjutsu_boon(MIST_BOON)
		if player.damage_resolved.is_connected(_on_player_damage):
			player.damage_resolved.disconnect(_on_player_damage)


func _process(delta: float) -> void:
	if delta <= 0.0 or not is_finite(delta) or get_tree().paused:
		return
	var source := get_parent() as Node2D
	if source == null:
		return
	if source.has_method("is_dead") and bool(source.call("is_dead")):
		return

	_advance_katana_effects(delta)
	_equipment_powers.advance(delta, source)
	_thunder_remaining = maxf(_thunder_remaining - delta, 0.0)
	_explosive_remaining = maxf(_explosive_remaining - delta, 0.0)
	_mist_cooldown = maxf(_mist_cooldown - delta, 0.0)
	if _mist_remaining > 0.0:
		_mist_remaining = maxf(_mist_remaining - delta, 0.0)
		if _mist_remaining <= 0.0 and source is PlayerController:
			source.remove_ninjutsu_boon(MIST_BOON)
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
	var first_hit := false
	var generation := _combination_generation
	for target in cone_targets:
		if generation != _combination_generation:
			break
		var actual := _resolve_basic_damage(target, katana_damage * (1.0 + _melee_equipment_bonus + _melee_manual_bonus if _guiin_original.is_empty() else 1.0))
		if actual > 0 and not first_hit and generation == _combination_generation:
			first_hit = true
			if _guiin_original.is_empty():
				_equipment_powers.on_weapon_hit(&"melee", target, actual, source, combat_resolver)
			if _guiin_original.is_empty() and _combination_effects.has(&"thunder_blade") and _thunder_remaining <= 0.0 and is_instance_valid(target):
				_thunder_remaining = 1.0
				_trigger_combination(target.global_position, 120.0, 6.0, target, 2)
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
	var cast_claim := {"used": false, "generation": _combination_generation}
	if _projectile_profile.get("shape", "") == "delayed_blast":
		var bomb := _spawn_projectile(source, Vector2.ZERO, cast_claim)
		if bomb != null:
			bomb.global_position = target.global_position
		return bomb

	var first: Node2D = null
	var count := int(_projectile_profile.get("count", 1))
	for index in range(count):
		var offset_degrees := float(_projectile_profile.get("spread", 0.0)) * (-1.0 if index == 0 else 1.0) if count > 1 else 0.0
		var projectile := _spawn_projectile(source, aim.rotated(deg_to_rad(offset_degrees)), cast_claim)
		if first == null:
			first = projectile
	if first != null and source is PlayerController:
		source.record_auto_weapon_direction(aim)
	return first


func _spawn_projectile(source: Node2D, aim: Vector2, cast_claim: Dictionary = {}) -> Node2D:
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
		projectile.call("configure", aim, shuriken_speed, roundi(shuriken_damage * (1.0 + _projectile_equipment_bonus + _projectile_manual_bonus)), combat_resolver)
	if projectile is BasicProjectile:
		projectile.damage_applied.connect(_on_projectile_damage.bind(cast_claim))
	shuriken_fired.emit(projectile)
	return projectile


func _on_player_damage(_requested: int, resolved: int, _prevented: int, evaded: bool) -> void:
	var player := get_parent() as PlayerController
	if player == null or player.health <= 0 or player.is_dead() or get_tree().paused or evaded or resolved <= 0:
		return
	if _combination_effects.has(&"water_mist") and _mist_cooldown <= 0.0:
		_mist_cooldown = 3.0
		_mist_remaining = 1.0
		player.set_ninjutsu_boon(MIST_BOON, 0.0, 0.20)


func _on_projectile_damage(target: Node, actual: int, claim: Dictionary) -> void:
	if actual <= 0 or bool(claim.get("used", true)) or claim.get("generation", -1) != _combination_generation:
		return
	claim["used"] = true
	var source := get_parent()
	if not is_instance_valid(source) or (source.has_method("is_dead") and source.is_dead()) or get_tree().paused or not _guiin_original.is_empty():
		return
	_equipment_powers.on_weapon_hit(&"projectile", target, actual, source, combat_resolver)
	if _combination_effects.has(&"explosive_bomb") and _explosive_remaining <= 0.0 and is_instance_valid(target) and target is Node2D:
		_explosive_remaining = 4.0
		_trigger_combination(target.global_position, 96.0, 12.0, null, 0)


func _trigger_combination(center: Vector2, radius: float, damage: float, excluded: Node, limit: int) -> void:
	var generation := _combination_generation
	var count := 0
	for target in _closest_targets_in_radius(get_tree().get_nodes_in_group("enemies"), center, radius):
		if target == excluded:
			continue
		if generation != _combination_generation or not _guiin_original.is_empty():
			return
		if not _is_valid_target(target):
			continue
		if combat_resolver != null:
			combat_resolver.deal_combination_damage(target, damage)
		else:
			target.take_damage(roundi(damage))
		count += 1
		if limit > 0 and count >= limit:
			return


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
	effect.add_to_group("player_cosmetic_effect")
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
