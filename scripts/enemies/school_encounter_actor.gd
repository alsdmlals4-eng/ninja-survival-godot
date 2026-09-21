extends EnemyChaser
class_name SchoolEncounterActor

const PATTERN_CONTROLLER_SCRIPT = preload("res://scripts/enemies/encounter_pattern_controller.gd")
const DANGER_GEOMETRY = preload("res://scripts/enemies/encounter_danger_geometry.gd")
const WARNING_VISUAL = preload("res://scripts/enemies/encounter_warning_visual.gd")
const PROJECTILE_AIM = preload("res://scripts/enemies/encounter_projectile_aim.gd")
const ESCAPE_SOLVER = preload("res://scripts/enemies/encounter_escape_solver.gd")
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
const FALLBACK_CORE_ART := [
	"res://assets/runtime/visual-core/flame_ninja_v1.png",
	"res://assets/runtime/visual-core/cursed_lantern_v1.png",
	"res://assets/runtime/visual-core/shadow_beast_v1.png",
]
const FALLBACK_ELITE_ART := "res://assets/runtime/encounters/actors/mobile_array_caster.png"
const FALLBACK_BOSS_ART := "res://assets/runtime/visual-core/cheonsul_stage_boss_v1.png"
const TELEGRAPHED_ZONE_RADIUS := 92.0
const LINE_DASH_HALF_WIDTH := 30.0
const PULSE_RADIUS := 118.0
const PROXY_RADIUS := 86.0
const PROXY_ARM_DURATION := 0.35
const PROXY_LIFETIME := 0.85
const MARK_DURATION := 3.5
var definition = null
var pattern_controller = null
var _telegraph_visual: Node2D
var _pattern_geometry
var _projectile_directions := PackedVector2Array()
var _telegraphed_position := Vector2.ZERO
var _telegraph_origin := Vector2.ZERO
var _marked_target: Node2D
var _mark_remaining := 0.0
var _mark_visual: Sprite2D
var _proxy_hazards: Array[Dictionary] = []
var _pattern_budget
var _pattern_slot_held := false
var _fair_warning := false


func book_control_role() -> StringName:
	return StringName(definition.role) if definition != null else super.book_control_role()


func _ready() -> void:
	super._ready()
	died.connect(_retire_dead_actor_attacks)


func _retire_dead_actor_attacks(_actor: Node) -> void:
	_clear_telegraph()
	_clear_runtime_effects()
	for child in get_children():
		if child.has_meta(PATTERN_PROJECTILE_META) and not child.is_queued_for_deletion():
			child.queue_free()
	_release_pattern_slot()


func _physics_process(delta: float) -> void:
	if get_tree() != null and get_tree().paused:
		return
	if _dead:
		velocity = Vector2.ZERO
		_clear_runtime_effects()
		return
	_advance_runtime_effects(delta)
	_release_finished_pattern_slot()
	if pattern_controller != null:
		pattern_controller.advance(delta)
		if pattern_controller.state_name() != &"chase":
			velocity = Vector2.ZERO
			return
	super._physics_process(delta)


func configure_definition(value) -> bool:
	if value == null or value.actor_id == &"" or value.role == &"":
		return false
	if value.role == &"core" and not value.pattern_definitions.is_empty():
		return false
	if value.role == &"elite" and value.pattern_definitions.size() < 2:
		return false
	if value.role == &"boss" and value.pattern_definitions.size() != 3:
		return false
	if value.role == &"core":
		_clear_pattern_controller()
		_clear_telegraph()
		_clear_runtime_effects()
	else:
		_ensure_pattern_controller()
		if pattern_controller == null or not pattern_controller.configure(value.pattern_definitions):
			return false
	# WaveSpawner supplies the first definition after _ready. Initialize only a
	# fresh, undamaged actor; reconfiguration must never be an implicit heal.
	var initialize_health := definition == null and not _dead and health == max_health
	definition = value.copy_value()
	max_health = maxi(definition.max_health, 1)
	if initialize_health:
		health = max_health
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
	_release_pattern_slot()
	_clear_telegraph()
	_clear_runtime_effects()


func configure_pattern_budget(budget) -> void:
	if _pattern_budget == budget:
		return
	_release_pattern_slot()
	_pattern_budget = budget
	if pattern_controller != null:
		pattern_controller.start_permission = _reserve_pattern_slot


func _reserve_pattern_slot() -> bool:
	if _dead or is_queued_for_deletion() or (get_tree() != null and get_tree().paused):
		return false
	if _pattern_slot_held:
		return false
	if _fair_warning and not _prepare_walk_escape():
		return false
	if _pattern_budget == null:
		return true
	_pattern_slot_held = _pattern_budget.try_reserve(self)
	return _pattern_slot_held


func enable_fair_warning() -> void:
	_fair_warning = true
	if pattern_controller != null:
		pattern_controller.fair_warning = true
		pattern_controller.start_permission = _reserve_pattern_slot


func _prepare_walk_escape() -> bool:
	if not is_instance_valid(target) or not target is PhysicsBody2D or not target.can_process():
		return false
	_capture_telegraph_position(pattern_controller.next_pattern())
	var hazards := _planned_dangers()
	if _pattern_budget != null: hazards.append_array(_pattern_budget.other_dangers(self))
	var collision := target.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null or not collision.shape is CircleShape2D:
		return false
	var clearance: float = collision.shape.radius * maxf(absf(collision.global_scale.x), absf(collision.global_scale.y)) + 6.0
	var shape := CircleShape2D.new()
	shape.radius = clearance
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, collision.global_position)
	query.exclude = [target.get_rid()]
	query.collision_mask = target.walking_collision_mask() if target.has_method("walking_collision_mask") else target.collision_mask
	var result: Dictionary = ESCAPE_SOLVER.find_escape(collision.global_position, float(target.get("move_speed")), clearance, hazards, _walk_path_clear.bind(query))
	if not result.ok: return false
	pattern_controller.locked_duration = result.locked_duration
	return true


func _walk_path_clear(destination: Vector2, query: PhysicsShapeQueryParameters2D) -> bool:
	var space := target.get_world_2d().direct_space_state
	# cast_motion ignores initial overlap, so reject that separately.
	query.motion = Vector2.ZERO
	if not space.intersect_shape(query, 1).is_empty(): return false
	query.motion = destination - query.transform.origin
	var fractions := space.cast_motion(query)
	return fractions.size() == 2 and fractions[0] >= 1.0


func _planned_dangers() -> Array:
	var hazards: Array = []
	if _pattern_geometry != null: hazards.append(_pattern_geometry)
	for direction in _projectile_directions:
		hazards.append(DANGER_GEOMETRY.new(_telegraph_origin, _telegraph_origin + direction * (720.0 if is_stage_boss() else 640.0), 5.0))
	return hazards


func danger_geometries() -> Array:
	var hazards: Array = []
	if pattern_state() in [&"telegraph", &"windup", &"locked", &"execute"]:
		hazards.append_array(_planned_dangers())
	for hazard in _proxy_hazards:
		if not hazard.resolved and hazard.geometry != null: hazards.append(hazard.geometry)
	for child in get_children():
		if child.has_meta(PATTERN_PROJECTILE_META) and not child.is_queued_for_deletion():
			hazards.append(DANGER_GEOMETRY.new(child.global_position, child.global_position + child.direction * child.speed * maxf(child._remaining_lifetime, 0.0), 5.0))
	return hazards


func _release_pattern_slot() -> void:
	if _pattern_budget != null and _pattern_slot_held:
		_pattern_budget.release(self)
	_pattern_slot_held = false


func _release_finished_pattern_slot() -> void:
	if not _pattern_slot_held or pattern_state() != &"chase" or not _proxy_hazards.is_empty():
		return
	for child in get_children():
		if child.has_meta(PATTERN_PROJECTILE_META) and not child.is_queued_for_deletion():
			return
	_release_pattern_slot()


func is_stage_boss() -> bool:
	return definition != null and definition.role == &"boss"


func current_telegraph_duration() -> float:
	return pattern_controller.current_telegraph_duration() if pattern_controller != null else 0.0


func current_execute_duration() -> float:
	return pattern_controller.current_execute_duration() if pattern_controller != null else 0.0


func advance_pattern_for_test(delta: float) -> void:
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
	pattern_controller.fair_warning = _fair_warning
	if _pattern_budget != null or _fair_warning:
		pattern_controller.start_permission = _reserve_pattern_slot
	add_child(pattern_controller)
	pattern_controller.execute_requested.connect(_on_pattern_execute_requested)
	pattern_controller.state_changed.connect(_on_pattern_state_changed)


func _clear_pattern_controller() -> void:
	_release_pattern_slot()
	if pattern_controller == null:
		return
	pattern_controller.queue_free()
	pattern_controller = null


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
	if state == &"telegraph" or state == &"windup":
		_capture_telegraph_position(pattern)
		_show_telegraph(pattern)
		if state == &"windup" and is_instance_valid(_telegraph_visual):
			_telegraph_visual.modulate.a = 0.65
	elif state == &"locked" and is_instance_valid(_telegraph_visual):
		_telegraph_visual.modulate.a = 1.0
	elif state == &"recovery" or state == &"chase":
		_clear_telegraph()
		_release_finished_pattern_slot()


func _resolve_pattern_damage(target_node: Node, multiplier: float = 1.0) -> int:
	if target_node == null or not is_instance_valid(target_node) or not target_node.has_method("take_damage"):
		return 0
	var amount := maxi(roundi(float(maxi(contact_damage, 1)) * maxf(multiplier, 0.0)), 1)
	var result = target_node.call("take_damage", amount)
	return int(result) if result is int else 0


func _resolve_telegraphed_zone_damage() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	if _pattern_geometry == null or not _pattern_geometry.contains(target.global_position):
		return 0
	return _resolve_pattern_damage(target)


func _capture_telegraph_position(pattern: Dictionary) -> void:
	var primitive_id := StringName(pattern.get("primitive_id", &""))
	_telegraph_origin = global_position
	_projectile_directions.clear()
	if primitive_id == &"fan_or_arc_projectile" and is_instance_valid(target):
		var aim := target.global_position - _telegraph_origin
		if not aim.is_zero_approx():
			var count := 3 if is_stage_boss() else 1
			for index in range(count):
				_projectile_directions.append(aim.normalized().rotated((float(index) - float(count - 1) * 0.5) * 0.22))
	if primitive_id in [&"telegraphed_zone", &"line_dash", &"mark_or_link", &"summon_or_proxy", &"barrier_or_lane"] \
		and target != null and is_instance_valid(target):
		_telegraphed_position = target.global_position
		_lock_damage_geometry(primitive_id)
		return
	_telegraphed_position = global_position
	_lock_damage_geometry(primitive_id)


func _lock_damage_geometry(primitive_id: StringName) -> void:
	_pattern_geometry = null
	match primitive_id:
		&"telegraphed_zone":
			_pattern_geometry = DANGER_GEOMETRY.new(_telegraphed_position, _telegraphed_position, TELEGRAPHED_ZONE_RADIUS)
		&"line_dash", &"barrier_or_lane":
			_pattern_geometry = DANGER_GEOMETRY.new(_telegraph_origin, _telegraphed_position, LINE_DASH_HALF_WIDTH)
		&"pulse_or_ring":
			_pattern_geometry = DANGER_GEOMETRY.new(_telegraph_origin, _telegraph_origin, PULSE_RADIUS)
		&"summon_or_proxy":
			_pattern_geometry = DANGER_GEOMETRY.new(_telegraphed_position, _telegraphed_position, PROXY_RADIUS)
		&"chase_contact":
			_pattern_geometry = DANGER_GEOMETRY.new(_telegraph_origin, _telegraph_origin, contact_range)


func _resolve_line_dash() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	var dash_end := _telegraphed_position
	global_position = dash_end
	if _pattern_geometry == null or not _pattern_geometry.contains(target.global_position):
		return 0
	return _resolve_pattern_damage(target, _marked_damage_multiplier(target))


func _resolve_locked_lane() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	if _pattern_geometry == null or not _pattern_geometry.contains(target.global_position):
		return 0
	return _resolve_pattern_damage(target, _marked_damage_multiplier(target))


func _resolve_pulse() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	if _pattern_geometry == null or not _pattern_geometry.contains(target.global_position):
		return 0
	return _resolve_pattern_damage(target, _marked_damage_multiplier(target))


func _resolve_chase_contact() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	if _pattern_geometry == null or not _pattern_geometry.contains(target.global_position):
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
	var boundary := WARNING_VISUAL.new()
	boundary.name = "DangerBoundary"
	proxy.add_child(boundary)
	boundary.configure(_pattern_geometry, _school_projectile_color())
	_proxy_hazards.append({
		"node": proxy,
		"position": _telegraphed_position,
		"geometry": _pattern_geometry,
		"boundary": boundary,
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
			var geometry = hazard.get("geometry")
			if target != null and is_instance_valid(target) and geometry != null and geometry.contains(target.global_position):
				_resolve_pattern_damage(target, _marked_damage_multiplier(target))
			hazard["resolved"] = true
			var boundary = hazard.get("boundary")
			if is_instance_valid(boundary):
				boundary.queue_free()
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
	for direction in _projectile_directions:
		var projectile_node = ENEMY_PATTERN_PROJECTILE_SCENE.instantiate()
		if not projectile_node is Area2D:
			if projectile_node != null:
				projectile_node.free()
			continue
		var projectile := projectile_node as Area2D
		projectile.top_level = true
		add_child(projectile)
		projectile.global_position = _telegraph_origin
		projectile.collision_layer = 8
		projectile.collision_mask = 1
		projectile.set_meta(PATTERN_PROJECTILE_META, true)
		var visual := projectile.get_node_or_null("Visual") as Sprite2D
		if visual != null:
			visual.texture = TALISMAN_PROJECTILE_TEXTURE
			visual.region_enabled = false
			visual.modulate = _school_projectile_color()
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
	_telegraph_visual = WARNING_VISUAL.new()
	_telegraph_visual.name = "PatternTelegraph"
	_telegraph_visual.top_level = true
	_telegraph_visual.global_position = _telegraphed_position
	_telegraph_visual.z_index = 1
	add_child(_telegraph_visual)
	_telegraph_visual.configure(_pattern_geometry, _school_projectile_color())
	if primitive_id == &"fan_or_arc_projectile":
		var aim := PROJECTILE_AIM.new()
		aim.name = "ProjectileAim"
		_telegraph_visual.add_child(aim)
		aim.configure(_projectile_directions, _school_projectile_color())
		return
	var ornament := Sprite2D.new()
	ornament.name = "SchoolOrnament"
	ornament.texture = texture
	ornament.scale = Vector2.ONE * 0.13
	ornament.modulate = Color(_school_projectile_color(), 0.32 if _pattern_geometry != null else 0.58)
	_telegraph_visual.add_child(ornament)


func _clear_telegraph() -> void:
	if is_instance_valid(_telegraph_visual):
		_telegraph_visual.queue_free()
	_telegraph_visual = null


func _apply_visual_asset() -> void:
	if definition == null:
		return
	var visual := get_node_or_null("Visual") as Sprite2D
	var path: String = definition.visual_asset_path
	var uses_fallback := not ResourceLoader.exists(path)
	if uses_fallback and visual != null:
		var motion = load("res://scripts/enemies/school_actor_motion.gd")
		visual.set_script(motion)
		if visual.configure_actor(definition): return
	if uses_fallback:
		match definition.role:
			&"boss": path = FALLBACK_BOSS_ART
			&"elite": path = FALLBACK_ELITE_ART
			_:
				# Stable role variation; no random reroll or final-art approval implied.
				path = FALLBACK_CORE_ART[posmod(String(definition.actor_id).hash(), FALLBACK_CORE_ART.size())]
	var texture = load(path) as Texture2D
	if visual != null and texture != null:
		visual.set_script(null)
		visual.region_enabled = false
		visual.position = Vector2.ZERO
		visual.flip_h = false
		visual.texture = texture
		visual.scale = Vector2.ONE * _actor_visual_scale()
		visual.set_meta(&"provisional_existing_art", uses_fallback)


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
