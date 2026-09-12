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
var _selected_casts: Array[Dictionary] = []
var _ticking := false
var _support_remaining: Dictionary = {}
var _support_zones: Dictionary = {}
var _selected_marks: Dictionary = {}
const SUPPORT_BOOKS := [&"guiin_iron_blood_guard", &"guiin_demon_step", &"cheonsul_ice_veil", &"heukyeong_smoke_step", &"bongma_guardian_ward", &"bongma_barrier_step"]


func configure(player: Node2D, world: Node, combat_resolver: CombatResolver, loadout: Node) -> bool:
	if player == null or world == null or loadout == null:
		return false
	if not loadout.has_method("active_spell_ids"):
		return false
	if is_instance_valid(_loadout) and _loadout.has_signal("loadout_changed") and _loadout.is_connected("loadout_changed", _prune_selected_casts):
		_loadout.disconnect("loadout_changed", _prune_selected_casts)
	if is_instance_valid(_player) and _player.has_signal("dash_ended") and _player.is_connected("dash_ended", _on_dash_ended):
		_player.disconnect("dash_ended", _on_dash_ended)
	clear_runtime_effects()
	_remaining_by_spell.clear()
	_player = player
	_world = world
	_combat_resolver = combat_resolver
	_loadout = loadout
	if _loadout.has_signal("loadout_changed"):
		_loadout.connect("loadout_changed", _prune_selected_casts)
	if _player.has_signal("dash_ended"):
		_player.connect("dash_ended", _on_dash_ended)
	return true


func _process(delta: float) -> void:
	tick_auto_cast(delta)


func _remove_support(id: StringName) -> void:
	_support_remaining.erase(id)
	_support_zones.erase(id)
	if is_instance_valid(_player) and _player.has_method("remove_ninjutsu_boon"):
		_player.call("remove_ninjutsu_boon", id)


func _apply_support(id: StringName, config: Dictionary) -> void:
	if not is_instance_valid(_player) or not _player.has_method("set_ninjutsu_boon"):
		return
	_player.call("set_ninjutsu_boon", id, float(config.get("damage_reduction", 0.0)), float(config.get("move_speed_bonus", 0.0)), int(config.get("shield", 0)))
	_support_remaining[id] = maxf(float(_support_remaining.get(id, 0.0)), float(config.duration))
	if config.kind in ["ward", "dash_ward"]:
		_support_zones[id] = {"origin": _player.global_position, "config": config}


func _tick_support_books(delta: float) -> void:
	if not _player.has_method("set_ninjutsu_boon"):
		return
	for id in _support_remaining.keys():
		_support_remaining[id] = maxf(float(_support_remaining[id]) - delta, 0.0)
		if float(_support_remaining[id]) <= 0.000001:
			_remove_support(id)
	for id in _support_zones.keys():
		var zone: Dictionary = _support_zones[id]
		var config: Dictionary = zone.config
		if _player.global_position.distance_squared_to(zone.origin) <= pow(float(config.radius), 2):
			_player.call("set_ninjutsu_boon", id, float(config.damage_reduction), 0.0, 0)
		else:
			_player.call("remove_ninjutsu_boon", id)
	for raw_id in _loadout.call("active_spell_ids"):
		var id := StringName(raw_id)
		if not SUPPORT_BOOKS.has(id):
			continue
		var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_id(id)
		var config: Dictionary = definition.effect_config
		if config.kind == "proximity_guard":
			if _selected_target(_player.global_position, float(config.target_range)) != null:
				_apply_support(id, config)
			else:
				_remove_support(id)
			continue
		var remaining := maxf(float(_remaining_by_spell.get(id, config.cooldown)) - delta, 0.0)
		_remaining_by_spell[id] = remaining
		if config.kind not in ["shield", "ward"] or remaining > 0.000001:
			continue
		if _selected_target(_player.global_position, float(config.target_range)) == null:
			_remaining_by_spell[id] = 0.12
			continue
		_remaining_by_spell[id] = float(config.cooldown)
		_apply_support(id, config)


func _on_dash_ended() -> void:
	if not is_instance_valid(_loadout) or not is_instance_valid(_player) or get_tree().paused or not can_process():
		return
	if _player.has_method("is_dead") and _player.call("is_dead"):
		return
	if not _loadout.has_method("get_snapshot") or _loadout.call("get_snapshot").get("selection_contract", "") != "selectable-v2":
		return
	for raw_id in _loadout.call("active_spell_ids"):
		var id := StringName(raw_id)
		if not [&"guiin_demon_step", &"heukyeong_smoke_step", &"bongma_barrier_step"].has(id):
			continue
		var config: Dictionary = NINJUTSU_CATALOG_SCRIPT.definition_for_id(id).effect_config
		if float(_remaining_by_spell.get(id, config.cooldown)) > 0.000001:
			continue
		_remaining_by_spell[id] = float(config.cooldown)
		_apply_support(id, config)


func _exit_tree() -> void:
	clear_runtime_effects()


func tick_auto_cast(delta: float) -> void:
	if _ticking:
		return
	_ticking = true
	_tick_auto_cast(delta)
	_ticking = false


func _tick_auto_cast(delta: float) -> void:
	if not is_finite(delta) or delta <= 0.0 or not is_instance_valid(_player) or not is_instance_valid(_world) or not is_instance_valid(_loadout):
		return
	if get_tree() != null and get_tree().paused:
		return
	if _player.has_method("is_dead") and bool(_player.call("is_dead")):
		clear_runtime_effects()
		return
	_advance_effects(delta)
	if _loadout.has_method("get_snapshot") and _loadout.call("get_snapshot").get("selection_contract", "") == "selectable-v2":
		_tick_support_books(delta)
		_tick_selected_marks(delta)
	if _combat_resolver != null and _combat_resolver.sword_only_mode:
		_selected_casts.clear()
		for entry in _active_effects:
			var effect = entry.get("node")
			if is_instance_valid(effect) and not effect.is_queued_for_deletion():
				effect.queue_free()
		_active_effects.clear()
		return
	if _loadout.has_method("get_snapshot") and _loadout.call("get_snapshot").get("selection_contract", "") == "selectable-v2":
		_tick_selected_books(delta)
		return
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


# Opt-in consumer: unsupported books never fall through to legacy generic attacks.
# Cooldowns are retained while unequipped; a fresh controller is a fresh Stage.
func _tick_selected_marks(delta: float) -> void:
	for key in _selected_marks.keys():
		var mark: Dictionary = _selected_marks[key]
		mark.remaining = float(mark.remaining) - delta
		if float(mark.remaining) <= 0.000001 or not is_instance_valid(mark.target) or mark.target.is_queued_for_deletion():
			_selected_marks.erase(key)


func _tick_selected_books(delta: float) -> void:
	_advance_selected_casts(delta)
	for raw_id in _loadout.call("active_spell_ids"):
		var id := StringName(raw_id)
		if not [&"guiin_ghost_blood_wave", &"guiin_afterimage_charge", &"guiin_asura_ring", &"guiin_rakshasa_kicks", &"cheonsul_wind_pillar", &"heukyeong_shadow_needle", &"heukyeong_pursuit_dart"].has(id):
			continue
		var definition = NINJUTSU_CATALOG_SCRIPT.definition_for_id(id)
		var config: Dictionary = definition.effect_config
		var cooldown := float(config.cooldown)
		var remaining := maxf(float(_remaining_by_spell.get(id, cooldown)) - delta, 0.0)
		_remaining_by_spell[id] = remaining
		if remaining > 0.000001:
			continue
		var origin := _player.global_position
		var target := _selected_target(origin, float(config.target_range), config.kind in ["needle", "dart"])
		if target == null:
			_remaining_by_spell[id] = 0.12
			continue
		# Reserve before damage callbacks to prevent reentrant duplicate casts.
		_remaining_by_spell[id] = cooldown
		var direction := origin.direction_to(target.global_position)
		if direction.is_zero_approx():
			direction = Vector2.RIGHT
		var cast: Dictionary = {"id": id, "config": config, "origin": origin, "direction": direction, "elapsed": 0.0, "next_tick": 1, "hit_ids": {}}
		_selected_casts.append(cast)
		_hit_selected_cast(cast)
		if not _selected_casts.has(cast):
			return
		if float(config.duration) <= 0.0:
			_selected_casts.erase(cast)
		if config.kind in ["wind_projectile", "needle", "dart"]:
			cast.visual = _spawn_effect(definition, origin, 0.13, float(config.duration))
		else:
			_spawn_effect(definition, origin, 0.13)


func has_selected_mark(target: Node) -> bool:
	return is_instance_valid(target) and _selected_marks.has(target.get_instance_id()) and float(_selected_marks[target.get_instance_id()].remaining) > 0.000001


func _selected_target(origin: Vector2, radius: float, prefer_mark: bool = false) -> Node2D:
	var nearest: Node2D = null
	var distance := radius * radius
	for enemy in _valid_enemies():
		if not _world.is_ancestor_of(enemy):
			continue
		var candidate_distance := origin.distance_squared_to(enemy.global_position)
		if candidate_distance > radius * radius:
			continue
		var priority := prefer_mark and has_selected_mark(enemy)
		var current_priority := prefer_mark and has_selected_mark(nearest)
		if nearest == null or (priority and not current_priority) or (priority == current_priority and (candidate_distance < distance or (candidate_distance == distance and enemy.get_instance_id() < nearest.get_instance_id()))):
			nearest = enemy
			distance = candidate_distance
	return nearest


func _prune_selected_casts() -> void:
	if not is_instance_valid(_loadout):
		_selected_casts.clear()
		return
	var active: Array = _loadout.call("active_spell_ids")
	if not active.has(&"heukyeong_shadow_needle"):
		_selected_marks.clear()
	for id in SUPPORT_BOOKS:
		if not active.has(id):
			_remove_support(id)
	for cast in _selected_casts.duplicate():
		if not active.has(cast.id):
			_selected_casts.erase(cast)
	for entry in _active_effects.duplicate():
		if not active.has(entry.get("spell_id", &"")):
			var effect = entry.get("node")
			if is_instance_valid(effect) and not effect.is_queued_for_deletion():
				effect.queue_free()
			_active_effects.erase(entry)


func _advance_selected_casts(delta: float) -> void:
	_prune_selected_casts()
	for cast in _selected_casts.duplicate():
		if not _selected_casts.has(cast):
			continue
		var config: Dictionary = cast.config
		cast.previous_elapsed = float(cast.elapsed)
		cast.elapsed = float(cast.elapsed) + delta
		if config.kind in ["wind_projectile", "needle", "dart"]:
			var visual = cast.get("visual")
			if is_instance_valid(visual) and not visual.is_queued_for_deletion():
				visual.global_position = Vector2(cast.origin) + Vector2(cast.direction) * minf(float(cast.elapsed), float(config.duration)) * float(config.speed)
			_hit_selected_cast(cast)
		elif config.kind == "afterimage_line":
			if float(cast.elapsed) < float(config.duration):
				_hit_selected_cast(cast)
		else:
			while int(cast.next_tick) < int(config.get("ticks", 1)) and float(cast.elapsed) + 0.000001 >= int(cast.next_tick) * float(config.get("tick_interval", 0.0)):
				cast.next_tick = int(cast.next_tick) + 1
				_hit_selected_cast(cast)
		if float(cast.elapsed) + 0.000001 >= float(config.duration):
			_selected_casts.erase(cast)


func _hit_selected_cast(cast: Dictionary) -> void:
	var config: Dictionary = cast.config
	if config.kind in ["needle", "dart"]:
		_hit_single_selected_projectile(cast)
		return
	for enemy in _valid_enemies():
		if not _selected_casts.has(cast) or not is_instance_valid(_player):
			return
		if _player.has_method("is_dead") and bool(_player.call("is_dead")):
			return
		if _combat_resolver != null and _combat_resolver.sword_only_mode:
			return
		if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or not _world.is_ancestor_of(enemy):
			continue
		var offset: Vector2 = enemy.global_position - Vector2(cast.origin)
		var direction: Vector2 = cast.direction
		if config.kind == "wind_projectile":
			var start_distance := minf(float(cast.get("previous_elapsed", 0.0)), float(config.duration)) * float(config.speed)
			var end_distance := minf(minf(float(cast.elapsed), float(config.duration)) * float(config.speed), float(config.length))
			var along := offset.dot(direction)
			if along < start_distance or along > end_distance or absf(offset.cross(direction)) > float(config.width) * 0.5 or cast.hit_ids.has(enemy.get_instance_id()):
				continue
		elif config.kind == "afterimage_line":
			var along := offset.dot(direction)
			if along < 0 or along > float(config.length) or absf(offset.cross(direction)) > float(config.width) * 0.5 or cast.hit_ids.has(enemy.get_instance_id()):
				continue
		else:
			if offset.length_squared() > pow(float(config.radius), 2):
				continue
			if config.kind == "kick_cone" and not offset.is_zero_approx() and absf(direction.angle_to(offset)) > deg_to_rad(float(config.angle_degrees) * 0.5):
				continue
		cast.hit_ids[enemy.get_instance_id()] = true
		if _combat_resolver != null:
			_combat_resolver.deal_school_damage(enemy, float(config.damage), &"direct_injutsu")
		else:
			enemy.call("take_damage", int(config.damage))


# Sweep the projectile center against the authored radius; consume the first
# intersection before emitting damage callbacks. No homing or legacy burst.
func _hit_single_selected_projectile(cast: Dictionary) -> void:
	if not _selected_casts.has(cast):
		return
	var config: Dictionary = cast.config
	var start: Vector2 = Vector2(cast.origin) + Vector2(cast.direction) * minf(float(cast.get("previous_elapsed", 0.0)), float(config.duration)) * float(config.speed)
	var end: Vector2 = Vector2(cast.origin) + Vector2(cast.direction) * minf(float(cast.elapsed), float(config.duration)) * float(config.speed)
	var segment := end - start
	var length_squared := segment.length_squared()
	var first: Node2D = null
	var first_time := INF
	for enemy in _valid_enemies():
		if not _world.is_ancestor_of(enemy):
			continue
		var offset := start - enemy.global_position
		var c := offset.length_squared() - pow(float(config.projectile_radius), 2)
		var time := 0.0
		if c > 0.0:
			if length_squared <= 0.000001:
				continue
			var b := offset.dot(segment)
			var discriminant := b * b - length_squared * c
			if discriminant < 0.0:
				continue
			time = (-b - sqrt(discriminant)) / length_squared
			if time < 0.0 or time > 1.0:
				continue
		if first == null or time < first_time or (time == first_time and enemy.get_instance_id() < first.get_instance_id()):
			first = enemy
			first_time = time
	if first == null:
		return
	_selected_casts.erase(cast)
	var visual = cast.get("visual")
	if is_instance_valid(visual) and not visual.is_queued_for_deletion():
		visual.queue_free()
	# Mark before notification so reentrant cleanup cannot restore a removed mark.
	if config.kind == "needle":
		_selected_marks[first.get_instance_id()] = {"target": first, "remaining": float(config.mark_duration)}
	if _combat_resolver != null:
		_combat_resolver.deal_school_damage(first, float(config.damage), &"direct_injutsu")
	else:
		first.call("take_damage", int(config.damage))


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


func _spawn_effect(definition, position: Vector2, effect_scale: float, duration: float = EFFECT_LIFETIME) -> Sprite2D:
	if not is_instance_valid(_world):
		return null
	var effect := Sprite2D.new()
	effect.name = "NinjutsuEffect"
	effect.texture = _effect_texture(definition)
	effect.global_position = position
	effect.scale = Vector2.ONE * effect_scale
	effect.modulate = _school_color(StringName(definition.school_id))
	effect.z_index = 2
	_world.add_child(effect)
	_active_effects.append({"node": effect, "remaining": duration, "spell_id": definition.ninjutsu_id})
	return effect


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
	_selected_marks.clear()
	for id in SUPPORT_BOOKS:
		_remove_support(id)
	_selected_casts.clear()
	for entry in _active_effects:
		var effect = entry.get("node")
		if is_instance_valid(effect) and not effect.is_queued_for_deletion():
			effect.queue_free()
	_active_effects.clear()
