extends EnemyChaser
class_name SchoolEncounterActor

const PATTERN_CONTROLLER_SCRIPT = preload("res://scripts/enemies/encounter_pattern_controller.gd")
const ENEMY_PATTERN_PROJECTILE_SCENE = preload("res://scenes/projectiles/shuriken_projectile.tscn")
const TALISMAN_PROJECTILE_TEXTURE = preload("res://assets/runtime/visual-core/talisman_projectile_v1.png")
const FALLBACK_TELEGRAPH_TEXTURE = preload("res://assets/runtime/visual-core/cheonsul_flame_field_v1.png")
const PATTERN_PROJECTILE_META := &"ninja_encounter_pattern_projectile"
const HUNDRED_DEMON_ARRAY_MASTER_ID := &"hundred_demon_array_master"
const BONGMA_HUNDRED_DEMON_FAMILIAR_TEXTURE_PATH := "res://assets/runtime/encounters/summons/bongma_hundred_demon_familiar.png"
const DEFAULT_ACTOR_VISUAL_SCALE := 0.05
const HUNDRED_DEMON_ARRAY_MASTER_VISUAL_SCALE := 0.09
const BONGMA_FAMILIAR_PROXY_VISUAL_SCALE := 0.03
const DEFAULT_PROXY_VISUAL_SCALE := 0.085
const TELEGRAPHED_ZONE_RADIUS := 92.0
const LINE_DASH_HALF_WIDTH := 30.0
const PULSE_RADIUS := 118.0
const PROXY_RADIUS := 86.0
const PROXY_ARM_DURATION := 0.35
const PROXY_LIFETIME := 0.85
const MARK_DURATION := 3.5

var definition = null
var pattern_controller = null
var _telegraph_visual: Sprite2D
var _telegraphed_position := Vector2.ZERO
var _telegraph_origin := Vector2.ZERO
var _marked_target: Node2D
var _mark_remaining := 0.0
var _mark_visual: Sprite2D
var _proxy_hazards: Array[Dictionary] = []


func _ready() -> void:
	super._ready()
	_ensure_pattern_controller()


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		_clear_runtime_effects()
		return
	_advance_runtime_effects(delta)
	_ensure_pattern_controller()
	if pattern_controller != null:
		pattern_controller.advance(delta)
		if pattern_controller.state_name() != &"chase":
			velocity = Vector2.ZERO
			return
	super._physics_process(delta)


func configure_definition(value) -> bool:
	if value == null or value.actor_id == &"" or value.role == &"" or value.pattern_definitions.is_empty():
		return false
	if value.role == &"elite" and value.pattern_definitions.size() < 2:
		return false
	if value.role == &"boss" and value.pattern_definitions.size() != 3:
		return false
	_ensure_pattern_controller()
	if pattern_controller == null or not pattern_controller.configure(value.pattern_definitions):
		return false
	definition = value.copy_value()
	max_health = maxi(definition.max_health, 1)
	move_speed = maxf(definition.move_speed, 0.0)
	contact_damage = maxi(definition.contact_damage, 0)
	contact_range = maxf(definition.contact_range, 0.0)
	_apply_visual_asset()
	return true


func configure_target(value: Node2D) -> bool:
	if value == null:
		return false
	set_target(value)
	return true


func pattern_state() -> StringName:
	return pattern_controller.state_name() if pattern_controller != null else &""


func active_pattern_id() -> StringName:
	if pattern_controller == null:
		return &""
	return StringName(pattern_controller.active_pattern().get("primitive_id", &""))


func active_proxy_count() -> int:
	return _proxy_hazards.size()


func _exit_tree() -> void:
	_clear_telegraph()
	_clear_runtime_effects()


func is_stage_boss() -> bool:
	return definition != null and definition.role == &"boss"


func current_telegraph_duration() -> float:
	return pattern_controller.current_telegraph_duration() if pattern_controller != null else 0.0


func current_execute_duration() -> float:
	return pattern_controller.current_execute_duration() if pattern_controller != null else 0.0


func advance_pattern_for_test(delta: float) -> void:
	_ensure_pattern_controller()
	if pattern_controller == null:
		return
	if pattern_controller.state_name() == &"chase":
		pattern_controller.force_start_for_test()
		return
	pattern_controller.advance(delta)


func resolve_pattern_damage_for_test(target_node: Node) -> int:
	return _resolve_pattern_damage(target_node)


func _ensure_pattern_controller() -> void:
	if pattern_controller != null:
		return
	pattern_controller = PATTERN_CONTROLLER_SCRIPT.new()
	pattern_controller.name = "EncounterPatternController"
	add_child(pattern_controller)
	pattern_controller.execute_requested.connect(_on_pattern_execute_requested)
	pattern_controller.state_changed.connect(_on_pattern_state_changed)


func _on_pattern_execute_requested(pattern: Dictionary) -> void:
	var primitive_id := StringName(pattern.get("primitive_id", &""))
	match primitive_id:
		&"fan_or_arc_projectile":
			_spawn_fan_projectiles()
		&"telegraphed_zone":
			_resolve_telegraphed_zone_damage()
		&"line_dash":
			_resolve_line_dash()
		&"mark_or_link":
			_apply_target_mark()
		&"summon_or_proxy":
			_spawn_proxy_hazard()
		&"barrier_or_lane":
			_resolve_locked_lane()
		&"pulse_or_ring":
			_resolve_pulse()
		&"chase_contact":
			_resolve_chase_contact()


func _on_pattern_state_changed(state: StringName, pattern: Dictionary) -> void:
	if state == &"telegraph":
		_capture_telegraph_position(pattern)
		_show_telegraph(pattern)
	elif state == &"recovery" or state == &"chase":
		_clear_telegraph()


func _resolve_pattern_damage(target_node: Node, multiplier: float = 1.0) -> int:
	if target_node == null or not is_instance_valid(target_node) or not target_node.has_method("take_damage"):
		return 0
	var amount := maxi(roundi(float(maxi(contact_damage, 1)) * maxf(multiplier, 0.0)), 1)
	var result = target_node.call("take_damage", amount)
	return int(result) if result is int else 0


func _resolve_telegraphed_zone_damage() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	if target.global_position.distance_squared_to(_telegraphed_position) > TELEGRAPHED_ZONE_RADIUS * TELEGRAPHED_ZONE_RADIUS:
		return 0
	return _resolve_pattern_damage(target)


func _capture_telegraph_position(pattern: Dictionary) -> void:
	var primitive_id := StringName(pattern.get("primitive_id", &""))
	_telegraph_origin = global_position
	if primitive_id in [&"telegraphed_zone", &"line_dash", &"mark_or_link", &"summon_or_proxy", &"barrier_or_lane"] \
		and target != null and is_instance_valid(target):
		_telegraphed_position = target.global_position
		return
	_telegraphed_position = global_position


func _resolve_line_dash() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	var dash_start := _telegraph_origin
	var dash_end := _telegraphed_position
	global_position = dash_end
	var closest := Geometry2D.get_closest_point_to_segment(target.global_position, dash_start, dash_end)
	if target.global_position.distance_squared_to(closest) > LINE_DASH_HALF_WIDTH * LINE_DASH_HALF_WIDTH:
		return 0
	return _resolve_pattern_damage(target, _marked_damage_multiplier(target))


func _resolve_locked_lane() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	var closest := Geometry2D.get_closest_point_to_segment(target.global_position, _telegraph_origin, _telegraphed_position)
	if target.global_position.distance_squared_to(closest) > LINE_DASH_HALF_WIDTH * LINE_DASH_HALF_WIDTH:
		return 0
	return _resolve_pattern_damage(target, _marked_damage_multiplier(target))


func _resolve_pulse() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	if target.global_position.distance_squared_to(global_position) > PULSE_RADIUS * PULSE_RADIUS:
		return 0
	return _resolve_pattern_damage(target, _marked_damage_multiplier(target))


func _resolve_chase_contact() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	if target.global_position.distance_squared_to(global_position) > contact_range * contact_range:
		return 0
	return _resolve_pattern_damage(target, _marked_damage_multiplier(target))


func _apply_target_mark() -> void:
	if target == null or not is_instance_valid(target):
		return
	_marked_target = target
	_mark_remaining = MARK_DURATION
	_clear_mark_visual()
	_mark_visual = Sprite2D.new()
	_mark_visual.name = "EncounterMark"
	_mark_visual.texture = FALLBACK_TELEGRAPH_TEXTURE
	_mark_visual.top_level = true
	_mark_visual.global_position = target.global_position
	_mark_visual.scale = Vector2.ONE * 0.075
	_mark_visual.modulate = Color(_school_projectile_color(), 0.72)
	_mark_visual.z_index = 2
	add_child(_mark_visual)


func _marked_damage_multiplier(target_node: Node) -> float:
	if _mark_remaining <= 0.0 or not is_instance_valid(_marked_target) or target_node != _marked_target:
		return 1.0
	return 1.5


func _spawn_proxy_hazard() -> void:
	var proxy := Node2D.new()
	proxy.name = "EncounterProxy"
	proxy.top_level = true
	proxy.global_position = _telegraphed_position
	var visual := Sprite2D.new()
	visual.name = "Visual"
	visual.texture = _proxy_visual_texture()
	visual.scale = Vector2.ONE * _proxy_visual_scale()
	visual.modulate = Color.WHITE if _uses_bongma_familiar_proxy() else Color(_school_projectile_color(), 0.55)
	visual.z_index = 1
	proxy.add_child(visual)
	add_child(proxy)
	_proxy_hazards.append({
		"node": proxy,
		"position": _telegraphed_position,
		"arm_remaining": PROXY_ARM_DURATION,
		"remaining": PROXY_LIFETIME,
		"resolved": false,
	})


func _advance_runtime_effects(delta: float) -> void:
	if _mark_remaining > 0.0:
		_mark_remaining = maxf(_mark_remaining - delta, 0.0)
		if is_instance_valid(_mark_visual) and is_instance_valid(_marked_target):
			_mark_visual.global_position = _marked_target.global_position
		if _mark_remaining <= 0.0:
			_marked_target = null
			_clear_mark_visual()
	for index in range(_proxy_hazards.size() - 1, -1, -1):
		var hazard: Dictionary = _proxy_hazards[index]
		var proxy = hazard.get("node") as Node2D
		hazard["arm_remaining"] = maxf(float(hazard.get("arm_remaining", 0.0)) - delta, 0.0)
		hazard["remaining"] = maxf(float(hazard.get("remaining", 0.0)) - delta, 0.0)
		if not bool(hazard.get("resolved", false)) and float(hazard["arm_remaining"]) <= 0.0:
			if target != null and is_instance_valid(target) and target.global_position.distance_squared_to(Vector2(hazard["position"])) <= PROXY_RADIUS * PROXY_RADIUS:
				_resolve_pattern_damage(target, _marked_damage_multiplier(target))
			hazard["resolved"] = true
		if float(hazard["remaining"]) <= 0.0 or not is_instance_valid(proxy):
			if is_instance_valid(proxy) and not proxy.is_queued_for_deletion():
				proxy.queue_free()
			_proxy_hazards.remove_at(index)
		else:
			_proxy_hazards[index] = hazard


func _clear_runtime_effects() -> void:
	_marked_target = null
	_mark_remaining = 0.0
	_clear_mark_visual()
	for hazard in _proxy_hazards:
		var proxy = hazard.get("node")
		if is_instance_valid(proxy) and not proxy.is_queued_for_deletion():
			proxy.queue_free()
	_proxy_hazards.clear()


func _clear_mark_visual() -> void:
	if is_instance_valid(_mark_visual) and not _mark_visual.is_queued_for_deletion():
		_mark_visual.queue_free()
	_mark_visual = null


func _spawn_fan_projectiles() -> void:
	if target == null or not is_instance_valid(target):
		return
	var base_direction := target.global_position - global_position
	if base_direction.is_zero_approx():
		return
	var projectile_count := 3 if is_stage_boss() else 1
	var spread_radians := 0.22 if projectile_count > 1 else 0.0
	for index in range(projectile_count):
		var projectile_node = ENEMY_PATTERN_PROJECTILE_SCENE.instantiate()
		if not projectile_node is Area2D:
			if projectile_node != null:
				projectile_node.free()
			continue
		var projectile := projectile_node as Area2D
		add_child(projectile)
		projectile.global_position = global_position
		projectile.collision_layer = 8
		projectile.collision_mask = 1
		projectile.set_meta(PATTERN_PROJECTILE_META, true)
		var visual := projectile.get_node_or_null("Visual") as Sprite2D
		if visual != null:
			visual.texture = TALISMAN_PROJECTILE_TEXTURE
			visual.region_enabled = false
			visual.modulate = _school_projectile_color()
		var spread_offset := (float(index) - float(projectile_count - 1) * 0.5) * spread_radians
		var direction := base_direction.normalized().rotated(spread_offset)
		if projectile.has_method("configure"):
			projectile.call("configure", direction, 360.0 if is_stage_boss() else 320.0, maxi(contact_damage, 1))


func _school_projectile_color() -> Color:
	if definition == null:
		return Color.WHITE
	match definition.school_id:
		&"bongma":
			return Color("e5c981")
		&"cheonsul":
			return Color("91c8ff")
		&"guiin":
			return Color("ff7d74")
		&"heukyeong":
			return Color("c294ff")
	return Color.WHITE


func _show_telegraph(pattern: Dictionary) -> void:
	_clear_telegraph()
	if definition == null:
		return
	var primitive_id := StringName(pattern.get("primitive_id", &""))
	var asset_path := "res://assets/runtime/encounters/telegraphs/%s_%s.png" % [definition.school_id, primitive_id]
	var texture = load(asset_path) as Texture2D if ResourceLoader.exists(asset_path) else FALLBACK_TELEGRAPH_TEXTURE
	_telegraph_visual = Sprite2D.new()
	_telegraph_visual.name = "PatternTelegraph"
	_telegraph_visual.texture = texture
	_telegraph_visual.global_position = _telegraphed_position
	_telegraph_visual.scale = Vector2.ONE * 0.13
	_telegraph_visual.modulate = Color(_school_projectile_color(), 0.58)
	_telegraph_visual.z_index = 1
	add_child(_telegraph_visual)


func _clear_telegraph() -> void:
	if is_instance_valid(_telegraph_visual):
		_telegraph_visual.queue_free()
	_telegraph_visual = null


func _apply_visual_asset() -> void:
	if definition == null or not ResourceLoader.exists(definition.visual_asset_path):
		return
	var visual := get_node_or_null("Visual") as Sprite2D
	var texture = load(definition.visual_asset_path) as Texture2D
	if visual != null and texture != null:
		visual.texture = texture
		visual.scale = Vector2.ONE * _actor_visual_scale()


func _actor_visual_scale() -> float:
	if definition != null and definition.actor_id == HUNDRED_DEMON_ARRAY_MASTER_ID:
		return HUNDRED_DEMON_ARRAY_MASTER_VISUAL_SCALE
	return DEFAULT_ACTOR_VISUAL_SCALE


func _uses_bongma_familiar_proxy() -> bool:
	return definition != null \
		and definition.school_id == &"bongma" \
		and ResourceLoader.exists(BONGMA_HUNDRED_DEMON_FAMILIAR_TEXTURE_PATH)


func _proxy_visual_texture() -> Texture2D:
	if _uses_bongma_familiar_proxy():
		var familiar_texture = load(BONGMA_HUNDRED_DEMON_FAMILIAR_TEXTURE_PATH) as Texture2D
		if familiar_texture != null:
			return familiar_texture
	return FALLBACK_TELEGRAPH_TEXTURE


func _proxy_visual_scale() -> float:
	return BONGMA_FAMILIAR_PROXY_VISUAL_SCALE if _uses_bongma_familiar_proxy() else DEFAULT_PROXY_VISUAL_SCALE
