# 확정 인법서를 수동 버튼 없이 자동 전투에 적용한다.
extends Node
class_name NinjutsuAutoController

signal selected_reaction_resolved(center: Vector2)

const NINJUTSU_CATALOG_SCRIPT = preload("res://scripts/data/ninjutsu_catalog.gd")
const SHURIKEN_PROJECTILE_SCENE = preload("res://scenes/projectiles/shuriken_projectile.tscn")
const SELECTED_FAMILIAR_SCENE = preload("res://scenes/schools/bongma_familiar.tscn")
const FALLBACK_EFFECT_TEXTURE: Texture2D = preload("res://assets/runtime/visual-core/basic_weapon_effects_v1.png")

const CAST_INTERVAL := 0.9
const TARGET_RADIUS := 320.0
const AREA_RADIUS := 112.0
const EFFECT_LIFETIME := 0.22

var _player: Node2D
var _definitions: Dictionary = NINJUTSU_CATALOG_SCRIPT.build_definitions()
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
var _selected_poison: Dictionary = {}
var _selected_burn: Dictionary = {}
var _selected_control_targets: Dictionary = {}
var _selected_elements: Dictionary = {}
var _thunder_remaining := 0.0
var _effect_generation := 0
var _selected_familiar: BongmaFamiliar
const SUPPORT_BOOKS := [&"guiin_iron_blood_guard", &"guiin_demon_step", &"cheonsul_ice_veil", &"heukyeong_smoke_step", &"bongma_guardian_ward", &"bongma_barrier_step", &"cheonsul_thunder_step"]


func configure(player: Node2D, world: Node, combat_resolver: CombatResolver, loadout: Node) -> bool:
	if player == null or world == null or loadout == null:
		return false
	if not loadout.has_method("active_spell_ids"):
		return false
	if is_instance_valid(_loadout) and _loadout.has_signal("loadout_changed") and _loadout.is_connected("loadout_changed", _prune_selected_casts):
		_loadout.disconnect("loadout_changed", _prune_selected_casts)
	if is_instance_valid(_player) and _player.has_signal("dash_ended") and _player.is_connected("dash_ended", _on_dash_ended):
		_player.disconnect("dash_ended", _on_dash_ended)
	if is_instance_valid(_player) and _player.has_method("set_selected_combat_rules"):
		_player.call("set_selected_combat_rules", false)
	clear_runtime_effects()
	_remaining_by_spell.clear()
	_player = player
	_world = world
	_combat_resolver = combat_resolver
	_loadout = loadout
	_sync_selected_player_rules()
	if _loadout.has_signal("loadout_changed"):
		_loadout.connect("loadout_changed", _prune_selected_casts)
	if _player.has_signal("dash_ended"):
		_player.connect("dash_ended", _on_dash_ended)
	return true


func _process(delta: float) -> void:
	tick_auto_cast(delta)


func _remove_support(id: StringName) -> void:
	if id == &"cheonsul_thunder_step":
		_thunder_remaining = 0.0
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
	_thunder_remaining = maxf(_thunder_remaining - delta, 0.0)
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
		var definition = _definitions.get(id)
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
		if not [&"guiin_demon_step", &"heukyeong_smoke_step", &"bongma_barrier_step", &"cheonsul_thunder_step"].has(id):
			continue
		var config: Dictionary = _definitions[id].effect_config
		if float(_remaining_by_spell.get(id, config.cooldown)) > 0.000001:
			continue
		_remaining_by_spell[id] = float(config.cooldown)
		if config.kind == "dash_token":
			_thunder_remaining = float(config.duration)
		else:
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
		_tick_selected_elements(delta)
		var generation := _effect_generation
		_tick_selected_damage_status(_selected_poison, delta, "poison_damage")
		if generation != _effect_generation:
			return
		_tick_selected_damage_status(_selected_burn, delta, "burn_damage")
		if generation != _effect_generation:
			return
	if _combat_resolver != null and _combat_resolver.sword_only_mode:
		for cast in _selected_casts.duplicate():
			if cast.config.kind in ["poison_zone", "clone", "water_zone", "orbit"]:
				cast.elapsed = float(cast.elapsed) + delta
				if cast.config.kind == "orbit":
					_update_orbit_visuals(cast)
				if cast.config.kind == "clone":
					while int(cast.next_tick) < int(cast.config.ticks) and float(cast.elapsed) + 0.000001 >= int(cast.next_tick) * float(cast.config.tick_interval):
						cast.next_tick = int(cast.next_tick) + 1
				if float(cast.elapsed) >= float(cast.config.duration):
					if cast.config.kind == "water_zone":
						_clear_selected_control(cast.id)
					_selected_casts.erase(cast)
			else:
				_selected_casts.erase(cast)
		for entry in _active_effects.duplicate():
			if entry.get("spell_id", &"") in [&"heukyeong_poison_mist", &"heukyeong_shadow_clone", &"cheonsul_water_vein_bind", &"bongma_talisman_wheel"]:
				continue
			var effect = entry.get("node")
			if is_instance_valid(effect) and not effect.is_queued_for_deletion():
				effect.queue_free()
			_active_effects.erase(entry)
		return
	if _loadout.has_method("get_snapshot") and _loadout.call("get_snapshot").get("selection_contract", "") == "selectable-v2":
		_tick_selected_books(delta)
		return
	for raw_spell_id in _loadout.call("active_spell_ids"):
		var spell_id := StringName(raw_spell_id)
		var definition = _definitions.get(spell_id)
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
	var generation := _effect_generation
	_tick_selected_familiar(delta)
	if generation != _effect_generation:
		return
	_advance_selected_casts(delta)
	if generation != _effect_generation:
		return
	for raw_id in _loadout.call("active_spell_ids"):
		var id := StringName(raw_id)
		if SUPPORT_BOOKS.has(id) or id == &"bongma_hundred_demon_familiar":
			continue
		var definition = _definitions.get(id)
		var config: Dictionary = definition.effect_config.duplicate(true)
		var cooldown := float(config.cooldown)
		if config.kind == "seal_zone":
			config.duration = float(config.delay)
		var remaining := maxf(float(_remaining_by_spell.get(id, cooldown)) - delta, 0.0)
		_remaining_by_spell[id] = remaining
		if remaining > 0.000001:
			continue
		var origin := _player.global_position
		var target := _selected_target(origin, float(config.target_range), config.kind in ["needle", "dart"])
		if config.kind == "execution":
			target = _execution_target(origin, float(config.target_range), {})
		elif config.kind == "lightning_chain":
			target = _selected_lightning_target(origin, float(config.target_range), {})
		if target == null:
			_remaining_by_spell[id] = 0.12
			continue
		# Reserve before damage callbacks to prevent reentrant duplicate casts.
		if config.kind in ["poison_zone", "flame_zone", "seal_zone", "water_zone"]:
			origin = target.global_position
		_remaining_by_spell[id] = cooldown
		var direction := origin.direction_to(target.global_position)
		if direction.is_zero_approx():
			direction = Vector2.RIGHT
		var cast: Dictionary = {"id": id, "config": config, "origin": origin, "direction": direction, "elapsed": 0.0, "next_tick": 1, "hit_ids": {}}
		cast.target = target
		_selected_casts.append(cast)
		if config.kind != "seal_zone":
			_hit_selected_cast(cast)
		if not _selected_casts.has(cast):
			return
		if float(config.duration) <= 0.0 or config.kind == "flame_zone":
			_selected_casts.erase(cast)
		if config.kind == "orbit":
			cast.visuals = []
			for index in range(int(config.orbiter_count)):
				cast.visuals.append(_spawn_effect(definition, origin, 0.065, float(config.duration)))
			_update_orbit_visuals(cast)
		elif config.kind in ["wind_projectile", "needle", "dart", "poison_zone", "clone", "seal_zone", "water_zone"]:
			cast.visual = _spawn_effect(definition, origin, 0.13, float(config.duration))
		else:
			_spawn_effect(definition, origin, 0.13)


func has_selected_status(target: Node, token: StringName) -> bool:
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		return false
	var key := target.get_instance_id()
	if token == &"burn":
		return _selected_burn.has(key) and float(_selected_burn[key].remaining) > 0.000001
	return _selected_elements.has(key) and not _selected_elements[key].get(token, {}).is_empty()


func _tick_selected_elements(delta: float) -> void:
	var active: Array = _loadout.call("active_spell_ids")
	for key in _selected_elements.keys():
		var state: Dictionary = _selected_elements[key]
		if not is_instance_valid(state.target) or state.target.is_queued_for_deletion():
			_selected_elements.erase(key)
			continue
		for token in [&"wet", &"shock"]:
			for source in state[token].keys():
				state[token][source] = float(state[token][source]) - delta
				if not active.has(source) or float(state[token][source]) <= 0.000001:
					state[token].erase(source)
		if state.wet.is_empty() and state.shock.is_empty():
			_selected_elements.erase(key)


func _apply_selected_token(target: Node2D, token: StringName, source: StringName, duration: float) -> void:
	if token not in [&"wet", &"shock"] or not is_instance_valid(_player) or get_tree().paused or (_player.has_method("is_dead") and _player.is_dead()) or (_combat_resolver != null and _combat_resolver.sword_only_mode):
		return
	if not is_instance_valid(target) or target.is_queued_for_deletion() or (target.has_method("is_dead") and target.is_dead()):
		return
	var key := target.get_instance_id()
	if not _selected_elements.has(key):
		_selected_elements[key] = {"target": target, &"wet": {}, &"shock": {}}
	var state: Dictionary = _selected_elements[key]
	state[token][source] = maxf(float(state[token].get(source, 0.0)), duration)
	if token != &"shock" or state.wet.is_empty():
		return
	state.wet.clear()
	state.shock.clear()
	var generation := _effect_generation
	var center := target.global_position
	if source != &"cheonsul_thunder_step":
		selected_reaction_resolved.emit(center)
	if generation != _effect_generation:
		return
	var visited: Dictionary = {key: true}
	_deal_selected_reaction_damage(target, 10.0)
	for index in range(2):
		if generation != _effect_generation:
			return
		var other := _selected_target(center, 120.0, false, visited)
		if other == null:
			break
		visited[other.get_instance_id()] = true
		_deal_selected_reaction_damage(other, 6.0)


func _deal_selected_direct_damage(target: Node2D, damage: float) -> void:
	if not is_instance_valid(target) or target.is_queued_for_deletion() or (_combat_resolver != null and _combat_resolver.sword_only_mode):
		return
	var generation := _effect_generation
	var armed := _thunder_remaining
	_thunder_remaining = 0.0
	var actual: int = _combat_resolver.deal_school_damage(target, damage, &"direct_injutsu") if _combat_resolver != null else int(target.call("take_damage", roundi(damage)))
	if generation != _effect_generation or not _loadout.call("active_spell_ids").has(&"cheonsul_thunder_step"):
		return
	if actual > 0 and armed > 0.000001:
		_apply_selected_token(target, &"shock", &"cheonsul_thunder_step", 4.0)
	elif actual <= 0:
		_thunder_remaining = maxf(_thunder_remaining, armed)


func _deal_selected_reaction_damage(target: Node, damage: float) -> void:
	if _combat_resolver != null:
		var modifiers := _combat_resolver.run_modifiers
		var multiplier := maxf(1.0 + modifiers.cheonsul_reaction_damage_pct, 0.0) * maxf(1.0 + modifiers.school_status_effect_pct, 0.0)
		_combat_resolver.deal_school_damage(target, damage, &"reaction", multiplier)
	elif is_instance_valid(target) and not target.is_queued_for_deletion():
		target.call("take_damage", int(damage))


func _selected_lightning_target(origin: Vector2, radius: float, excluded: Dictionary) -> Node2D:
	var dry := excluded.duplicate()
	for enemy in _valid_enemies():
		if not has_selected_status(enemy, &"wet"):
			dry[enemy.get_instance_id()] = true
	var wet := _selected_target(origin, radius, false, dry)
	return wet if wet != null else _selected_target(origin, radius, false, excluded)


func _tick_selected_damage_status(states: Dictionary, delta: float, damage_key: String) -> void:
	for key in states.keys():
		if not states.has(key):
			continue
		var state: Dictionary = states[key]
		var target = state.target
		if not is_instance_valid(target) or target.is_queued_for_deletion() or not _world.is_ancestor_of(target) or (target.has_method("is_dead") and target.is_dead()):
			states.erase(key)
			continue
		state.next_tick = float(state.next_tick) - minf(delta, float(state.remaining))
		state.remaining = maxf(float(state.remaining) - delta, 0.0)
		while float(state.next_tick) <= 0.000001:
			state.next_tick = float(state.next_tick) + float(state.config.tick_interval)
			if not states.has(key) or not is_instance_valid(target) or target.is_queued_for_deletion() or (_player.has_method("is_dead") and _player.is_dead()):
				break
			if _combat_resolver != null:
				_combat_resolver.deal_school_damage(target, float(state.config[damage_key]), &"dot")
			else:
				target.call("take_damage", int(state.config[damage_key]))
		if float(state.remaining) <= 0.000001:
			states.erase(key)


func _clear_selected_familiar() -> void:
	if is_instance_valid(_selected_familiar):
		_selected_familiar.process_mode = Node.PROCESS_MODE_DISABLED
		_selected_familiar.queue_free()
	_selected_familiar = null


func _tick_selected_familiar(delta: float) -> void:
	var id := &"bongma_hundred_demon_familiar"
	if not _loadout.call("active_spell_ids").has(id) or not _player is PlayerController:
		_clear_selected_familiar()
		return
	var config: Dictionary = _definitions[id].effect_config
	if not is_instance_valid(_selected_familiar):
		_selected_familiar = SELECTED_FAMILIAR_SCENE.instantiate()
		_selected_familiar.name = "SelectedBookFamiliar"
		_world.add_child(_selected_familiar)
		_selected_familiar.global_position = _player.global_position + Vector2(48, 0)
		_selected_familiar.configure(_player, float(config.cooldown), int(config.damage), _combat_resolver)
		_selected_familiar.set_process(false)
		_selected_familiar.target_radius = float(config.target_range)
		_selected_familiar.maximum_follow_distance = float(config.follow_range)
	var remaining := maxf(float(_remaining_by_spell.get(id, config.cooldown)) - delta, 0.0)
	_remaining_by_spell[id] = remaining
	if remaining > 0.000001:
		return
	_remaining_by_spell[id] = float(config.cooldown)
	if _selected_familiar.attack_once() == null:
		_remaining_by_spell[id] = 0.12


func has_selected_mark(target: Node) -> bool:
	return is_instance_valid(target) and _selected_marks.has(target.get_instance_id()) and float(_selected_marks[target.get_instance_id()].remaining) > 0.000001


func _selected_target(origin: Vector2, radius: float, prefer_mark: bool = false, excluded: Dictionary = {}) -> Node2D:
	var nearest: Node2D = null
	var distance := radius * radius
	for enemy in _valid_enemies():
		if not _world.is_ancestor_of(enemy) or excluded.has(enemy.get_instance_id()):
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


func _sync_selected_player_rules() -> void:
	if is_instance_valid(_player) and _player.has_method("set_selected_combat_rules"):
		var selected: bool = is_instance_valid(_loadout) and _loadout.has_method("get_snapshot") and _loadout.call("get_snapshot").get("selection_contract", "") == "selectable-v2"
		_player.call("set_selected_combat_rules", selected)


func _prune_selected_casts() -> void:
	_sync_selected_player_rules()
	if not is_instance_valid(_loadout):
		_selected_casts.clear()
		return
	var active: Array = _loadout.call("active_spell_ids")
	_tick_selected_elements(0.0)
	for source in _selected_control_targets.keys():
		if not active.has(source):
			_clear_selected_control(source)
		else:
			for key in _selected_control_targets[source].keys():
				if not is_instance_valid(_selected_control_targets[source][key]):
					_selected_control_targets[source].erase(key)
	if not active.has(&"bongma_hundred_demon_familiar"):
		_clear_selected_familiar()
	if not active.has(&"heukyeong_shadow_needle"):
		_selected_marks.clear()
	if not active.has(&"heukyeong_poison_mist"):
		_selected_poison.clear()
	if not active.has(&"cheonsul_flame_mark"):
		_selected_burn.clear()
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
		if config.kind == "orbit":
			var end: float = cast.elapsed
			var sample: float = cast.previous_elapsed
			while sample < minf(end, float(config.duration)) and _selected_casts.has(cast):
				sample = minf(sample + 0.025, minf(end, float(config.duration)))
				cast.elapsed = sample
				_hit_selected_cast(cast)
			cast.elapsed = end
			_update_orbit_visuals(cast)
		elif config.kind in ["wind_projectile", "needle", "dart"]:
			var visual = cast.get("visual")
			if is_instance_valid(visual) and not visual.is_queued_for_deletion():
				visual.global_position = Vector2(cast.origin) + Vector2(cast.direction) * minf(float(cast.elapsed), float(config.duration)) * float(config.speed)
			_hit_selected_cast(cast)
		elif config.kind == "seal_zone":
			if float(cast.elapsed) + 0.000001 >= float(config.delay):
				_hit_selected_cast(cast)
		elif config.kind in ["afterimage_line", "poison_zone", "water_zone"]:
			if float(cast.elapsed) < float(config.duration):
				_hit_selected_cast(cast)
		else:
			while int(cast.next_tick) < int(config.get("ticks", 1)) and float(cast.elapsed) + 0.000001 >= int(cast.next_tick) * float(config.get("tick_interval", 0.0)):
				cast.next_tick = int(cast.next_tick) + 1
				_hit_selected_cast(cast)
		if float(cast.elapsed) + 0.000001 >= float(config.duration):
			if config.kind == "water_zone":
				_clear_selected_control(cast.id)
			_selected_casts.erase(cast)


func _orbit_position(cast: Dictionary, index: int) -> Vector2:
	var angle := float(cast.elapsed) * float(cast.config.angular_speed) + index * TAU / int(cast.config.orbiter_count)
	return _player.global_position + Vector2.RIGHT.rotated(angle) * float(cast.config.radius)


func _update_orbit_visuals(cast: Dictionary) -> void:
	var visuals: Array = cast.get("visuals", [])
	for index in range(visuals.size()):
		if is_instance_valid(visuals[index]) and not visuals[index].is_queued_for_deletion():
			visuals[index].global_position = _orbit_position(cast, index)


func _apply_selected_control(enemy: Node, source: StringName, duration: float, slow: float = 0.0, bind: bool = true) -> void:
	if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or not enemy.has_method("apply_book_control"):
		return
	if enemy.call("apply_book_control", source, duration, slow, bind):
		if not _selected_control_targets.has(source):
			_selected_control_targets[source] = {}
		_selected_control_targets[source][enemy.get_instance_id()] = enemy


func _clear_selected_control(source: StringName) -> void:
	for enemy in _selected_control_targets.get(source, {}).values():
		if is_instance_valid(enemy):
			enemy.call("remove_book_control", source)
	_selected_control_targets.erase(source)


func _hit_selected_cast(cast: Dictionary) -> void:
	var config: Dictionary = cast.config
	if config.kind == "orbit":
		for enemy in _valid_enemies():
			if not _selected_casts.has(cast):
				return
			if not _world.is_ancestor_of(enemy):
				continue
			var key: int = enemy.get_instance_id()
			var hit: Dictionary = cast.hit_ids.get(key, {"count": 0, "at": -INF})
			if int(hit.count) >= int(config.max_hits_per_target) or float(cast.elapsed) - float(hit.at) + 0.000001 < float(config.hit_interval):
				continue
			for index in range(int(config.orbiter_count)):
				if enemy.global_position.distance_squared_to(_orbit_position(cast, index)) <= pow(float(config.contact_radius), 2):
					cast.hit_ids[key] = {"count": int(hit.count) + 1, "at": float(cast.elapsed)}
					_deal_selected_direct_damage(enemy, float(config.damage))
					break
		return
	if config.kind == "water_zone":
		for enemy in _valid_enemies():
			if not _selected_casts.has(cast):
				return
			if not _world.is_ancestor_of(enemy):
				continue
			if enemy.global_position.distance_squared_to(cast.origin) > pow(float(config.radius), 2):
				if enemy.has_method("remove_book_control"):
					enemy.call("remove_book_control", cast.id)
				continue
			_apply_selected_control(enemy, cast.id, maxf(float(config.duration) - float(cast.elapsed), 0.001), float(config.slow), false)
			if cast.hit_ids.has(enemy.get_instance_id()):
				continue
			cast.hit_ids[enemy.get_instance_id()] = true
			_deal_selected_direct_damage(enemy, float(config.damage))
			if _selected_casts.has(cast):
				_apply_selected_token(enemy, &"wet", cast.id, float(config.wet_duration))
		return
	if config.kind in ["chain", "lightning_chain"]:
		var target: Node2D = cast.target
		var visited: Dictionary = {}
		for index in range(int(config.max_targets)):
			if not _selected_casts.has(cast) or not is_instance_valid(target) or target.is_queued_for_deletion() or (_combat_resolver != null and _combat_resolver.sword_only_mode):
				break
			var origin := target.global_position
			visited[target.get_instance_id()] = true
			var damage := float(config.damage) if index == 0 else float(config.get("followup_damage", config.damage))
			_deal_selected_direct_damage(target, damage)
			if not _selected_casts.has(cast):
				break
			if config.kind == "lightning_chain":
				_apply_selected_token(target, &"shock", cast.id, 4.0)
				target = _selected_lightning_target(origin, float(config.link_range), visited)
			else:
				_apply_selected_control(target, cast.id, float(config.bind_duration))
				target = _selected_target(origin, float(config.link_range), false, visited)
		return
	if config.kind == "clone":
		if not _selected_casts.has(cast) or (_combat_resolver != null and _combat_resolver.sword_only_mode):
			return
		var target := _selected_target(cast.origin, float(config.target_range))
		if target != null:
			if _combat_resolver != null:
				_combat_resolver.deal_school_damage(target, float(config.damage), &"clone")
			else:
				target.call("take_damage", int(config.damage))
		return
	if config.kind == "poison_zone":
		for enemy in _valid_enemies():
			if _world.is_ancestor_of(enemy) and enemy.global_position.distance_squared_to(cast.origin) <= pow(float(config.radius), 2):
				var key: int = enemy.get_instance_id()
				if not _selected_poison.has(key):
					_selected_poison[key] = {"target": enemy, "next_tick": float(config.tick_interval), "remaining": 0.0, "config": config}
				_selected_poison[key].remaining = float(config.poison_duration)
		return
	if config.kind == "execution":
		_hit_execution(cast)
		return
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
		_deal_selected_direct_damage(enemy, float(config.damage))
		if config.kind == "seal_zone" and _selected_casts.has(cast):
			_apply_selected_control(enemy, cast.id, float(config.bind_duration))
		if config.kind == "flame_zone" and _selected_casts.has(cast) and is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and not (enemy.has_method("is_dead") and enemy.is_dead()):
			var key: int = enemy.get_instance_id()
			if not _selected_burn.has(key):
				_selected_burn[key] = {"target": enemy, "next_tick": float(config.tick_interval), "remaining": 0.0, "config": config}
			_selected_burn[key].remaining = float(config.duration)


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
	_deal_selected_direct_damage(first, float(config.damage))


func _execution_target(origin: Vector2, radius: float, visited: Dictionary) -> EnemyChaser:
	var candidates: Array[EnemyChaser] = []
	for enemy in _valid_enemies():
		if enemy is EnemyChaser and _world.is_ancestor_of(enemy) and not visited.has(enemy.get_instance_id()) and origin.distance_squared_to(enemy.global_position) <= radius * radius:
			candidates.append(enemy)
	candidates.sort_custom(func(a: EnemyChaser, b: EnemyChaser) -> bool:
		if has_selected_mark(a) != has_selected_mark(b):
			return has_selected_mark(a)
		var a_hp := float(a.health) / maxi(a.max_health, 1)
		var b_hp := float(b.health) / maxi(b.max_health, 1)
		if a_hp != b_hp:
			return a_hp < b_hp
		var a_distance := origin.distance_squared_to(a.global_position)
		var b_distance := origin.distance_squared_to(b.global_position)
		return a_distance < b_distance if a_distance != b_distance else a.get_instance_id() < b.get_instance_id()
	)
	return candidates[0] if not candidates.is_empty() else null


func _hit_execution(cast: Dictionary) -> void:
	var config: Dictionary = cast.config
	var target: EnemyChaser = cast.target
	for index in range(int(config.max_followups) + 1):
		if not _selected_casts.has(cast) or not is_instance_valid(target) or target.is_queued_for_deletion() or target.is_dead():
			return
		if not is_instance_valid(_player) or (_player.has_method("is_dead") and _player.call("is_dead")) or get_tree().paused:
			return
		if _combat_resolver != null and _combat_resolver.sword_only_mode:
			return
		var center := target.global_position
		cast.hit_ids[target.get_instance_id()] = true
		var role: StringName = target.get_meta(&"school_circuit_role", &"")
		if target is SchoolEncounterActor and target.definition != null:
			role = target.definition.role
		var heavy := target is StageBoss or role in [&"elite", &"boss", &"final_boss"] or target.is_in_group("boss")
		var amount := float(config.damage)
		if heavy:
			amount *= float(config.elite_boss_multiplier)
		elif float(target.health) / maxi(target.max_health, 1) <= float(config.execute_hp_ratio):
			amount = maxf(amount, float(target.health))
		_deal_selected_direct_damage(target, amount)
		if not is_instance_valid(target) or not target.is_dead():
			return
		target = _execution_target(center, float(config.link_range), cast.hit_ids)


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
	_effect_generation += 1
	for source in _selected_control_targets.keys():
		_clear_selected_control(source)
	_clear_selected_familiar()
	_selected_marks.clear()
	_selected_poison.clear()
	_selected_burn.clear()
	for id in SUPPORT_BOOKS:
		# Per-book boons and elemental tokens never survive a combat boundary.
		_remove_support(id)
	_selected_elements.clear()
	_selected_casts.clear()
	for entry in _active_effects:
		var effect = entry.get("node")
		if is_instance_valid(effect) and not effect.is_queued_for_deletion():
			effect.queue_free()
	_active_effects.clear()
