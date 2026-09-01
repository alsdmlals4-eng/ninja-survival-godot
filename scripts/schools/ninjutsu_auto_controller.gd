# 확정 인법서를 수동 버튼 없이 자동 전투에 적용한다.
extends Node
class_name NinjutsuAutoController

const NINJUTSU_CATALOG_SCRIPT = preload("res://scripts/data/ninjutsu_catalog.gd")
const SHURIKEN_PROJECTILE_SCENE = preload("res://scenes/projectiles/shuriken_projectile.tscn")
const FALLBACK_EFFECT_TEXTURE: Texture2D = preload("res://assets/runtime/visual-core/basic_weapon_effects_v1.png")

const CAST_INTERVAL := 0.9
const TARGET_RADIUS := 320.0
const AREA_RADIUS := 112.0
const EFFECT_LIFETIME := 0.22

var _player: Node2D
var _world: Node
var _combat_resolver: CombatResolver
var _loadout: Node
var _remaining_by_spell: Dictionary = {}
var _active_effects: Array[Dictionary] = []


func configure(player: Node2D, world: Node, combat_resolver: CombatResolver, loadout: Node) -> bool:
	if player == null or world == null or loadout == null:
		return false
	if not loadout.has_method("active_spell_ids"):
		return false
	_player = player
	_world = world
	_combat_resolver = combat_resolver
	_loadout = loadout
	return true


func _process(delta: float) -> void:
	tick_auto_cast(delta)


func _exit_tree() -> void:
	clear_runtime_effects()


func tick_auto_cast(delta: float) -> void:
	if delta <= 0.0 or not is_instance_valid(_player) or not is_instance_valid(_world) or _loadout == null:
		return
	_advance_effects(delta)
	for raw_spell_id in _loadout.call("active_spell_ids"):
		var spell_id := StringName(raw_spell_id)
		var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_id(spell_id)
		if definition == null or definition.acquisition_lane == &"starter":
			continue
		var remaining := maxf(float(_remaining_by_spell.get(spell_id, 0.0)) - delta, 0.0)
		if remaining > 0.0:
			_remaining_by_spell[spell_id] = remaining
			continue
		if _cast_definition(definition):
			_remaining_by_spell[spell_id] = CAST_INTERVAL
		else:
			_remaining_by_spell[spell_id] = 0.12


func _cast_definition(definition) -> bool:
	var target := _nearest_enemy(_player.global_position)
	if target == null:
		return false
	match StringName(definition.primitive_id):
		&"telegraphed_zone":
			return _cast_zone(definition, target)
		&"mark_or_link":
			return _cast_link(definition, target)
		&"pulse_or_ring":
			return _cast_pulse(definition, target)
		&"line_dash":
			return _cast_line(definition, target)
		&"fan_or_arc_projectile":
			return _cast_projectile_fan(definition, target)
	return false


func _cast_zone(definition, target: Node2D) -> bool:
	var hit_count := 0
	for enemy in _valid_enemies():
		if enemy.global_position.distance_squared_to(target.global_position) <= AREA_RADIUS * AREA_RADIUS:
			if _deal_damage(enemy, 10) > 0:
				hit_count += 1
	_spawn_effect(definition, target.global_position, 0.12)
	return hit_count > 0


func _cast_link(definition, target: Node2D) -> bool:
	var candidates := _valid_enemies()
	candidates.sort_custom(func(first: Node2D, second: Node2D) -> bool:
		return target.global_position.distance_squared_to(first.global_position) < target.global_position.distance_squared_to(second.global_position)
	)
	var hit_count := 0
	for index in range(mini(candidates.size(), 3)):
		if _deal_damage(candidates[index], 8 if index > 0 else 14) > 0:
			hit_count += 1
	_spawn_effect(definition, target.global_position, 0.10)
	return hit_count > 0


func _cast_pulse(definition, target: Node2D) -> bool:
	var hit_count := 0
	for enemy in _valid_enemies():
		if enemy.global_position.distance_squared_to(_player.global_position) <= AREA_RADIUS * AREA_RADIUS:
			if _deal_damage(enemy, 12) > 0:
				hit_count += 1
	_spawn_effect(definition, _player.global_position, 0.13)
	return hit_count > 0


func _cast_line(definition, target: Node2D) -> bool:
	var start := _player.global_position
	var direction := target.global_position - start
	if direction.is_zero_approx():
		return false
	var end := start + direction.normalized() * TARGET_RADIUS
	var hit_count := 0
	for enemy in _valid_enemies():
		var closest := Geometry2D.get_closest_point_to_segment(enemy.global_position, start, end)
		if enemy.global_position.distance_squared_to(closest) <= 28.0 * 28.0:
			if _deal_damage(enemy, 13) > 0:
				hit_count += 1
	_spawn_effect(definition, start.lerp(end, 0.5), 0.09)
	return hit_count > 0


func _cast_projectile_fan(definition, target: Node2D) -> bool:
	var aim := target.global_position - _player.global_position
	if aim.is_zero_approx():
		return false
	var spawned := 0
	for angle_offset in [-0.18, 0.0, 0.18]:
		var projectile_node = SHURIKEN_PROJECTILE_SCENE.instantiate()
		if not projectile_node is Node2D:
			if projectile_node != null:
				projectile_node.free()
			continue
		_world.add_child(projectile_node)
		var projectile := projectile_node as Node2D
		projectile.global_position = _player.global_position
		if projectile.has_method("configure"):
			projectile.call("configure", aim.rotated(angle_offset), 590.0, 8, _combat_resolver)
		spawned += 1
	_spawn_effect(definition, _player.global_position, 0.08)
	return spawned > 0


func _nearest_enemy(origin: Vector2) -> Node2D:
	var nearest: Node2D = null
	var nearest_distance := TARGET_RADIUS * TARGET_RADIUS
	for enemy in _valid_enemies():
		var distance := origin.distance_squared_to(enemy.global_position)
		if distance <= nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest


func _valid_enemies() -> Array[Node2D]:
	var result: Array[Node2D] = []
	if get_tree() == null:
		return result
	for candidate in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(candidate) or not candidate is Node2D:
			continue
		if candidate.is_queued_for_deletion() or not candidate.has_method("take_damage"):
			continue
		if candidate.has_method("is_dead") and bool(candidate.call("is_dead")):
			continue
		result.append(candidate as Node2D)
	return result


func _deal_damage(target: Node, amount: int) -> int:
	if _combat_resolver != null:
		return _combat_resolver.deal_school_damage(target, float(amount), &"normal")
	if target == null or not is_instance_valid(target) or not target.has_method("take_damage"):
		return 0
	var result = target.call("take_damage", amount)
	return int(result) if result is int else 0


func _spawn_effect(definition, position: Vector2, effect_scale: float) -> void:
	if not is_instance_valid(_world):
		return
	var effect := Sprite2D.new()
	effect.name = "NinjutsuEffect"
	effect.texture = _effect_texture(definition)
	effect.global_position = position
	effect.scale = Vector2.ONE * effect_scale
	effect.modulate = _school_color(StringName(definition.school_id))
	effect.z_index = 2
	_world.add_child(effect)
	_active_effects.append({"node": effect, "remaining": EFFECT_LIFETIME})


func _effect_texture(definition) -> Texture2D:
	if definition != null and not str(definition.visual_asset_path).is_empty() and ResourceLoader.exists(definition.visual_asset_path):
		var loaded = load(definition.visual_asset_path)
		if loaded is Texture2D:
			return loaded as Texture2D
	return FALLBACK_EFFECT_TEXTURE


func _school_color(school_id: StringName) -> Color:
	match school_id:
		&"bongma":
			return Color("e5c981")
		&"cheonsul":
			return Color("91c8ff")
		&"guiin":
			return Color("ff7d74")
		&"heukyeong":
			return Color("c294ff")
	return Color.WHITE


func _advance_effects(delta: float) -> void:
	for index in range(_active_effects.size() - 1, -1, -1):
		var entry: Dictionary = _active_effects[index]
		var effect = entry.get("node")
		var remaining := float(entry.get("remaining", 0.0)) - delta
		if remaining > 0.0 and is_instance_valid(effect):
			entry["remaining"] = remaining
			_active_effects[index] = entry
			continue
		if is_instance_valid(effect) and not effect.is_queued_for_deletion():
			effect.queue_free()
		_active_effects.remove_at(index)


func clear_runtime_effects() -> void:
	for entry in _active_effects:
		var effect = entry.get("node")
		if is_instance_valid(effect) and not effect.is_queued_for_deletion():
			effect.queue_free()
	_active_effects.clear()
