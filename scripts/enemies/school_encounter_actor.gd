extends EnemyChaser
class_name SchoolEncounterActor

const PATTERN_CONTROLLER_SCRIPT = preload("res://scripts/enemies/encounter_pattern_controller.gd")
const ENEMY_PATTERN_PROJECTILE_SCENE = preload("res://scenes/projectiles/shuriken_projectile.tscn")
const TALISMAN_PROJECTILE_TEXTURE = preload("res://assets/runtime/visual-core/talisman_projectile_v1.png")
const FALLBACK_TELEGRAPH_TEXTURE = preload("res://assets/runtime/visual-core/cheonsul_flame_field_v1.png")
const PATTERN_PROJECTILE_META := &"ninja_encounter_pattern_projectile"
const TELEGRAPHED_ZONE_RADIUS := 92.0

var definition = null
var pattern_controller = null
var _telegraph_visual: Sprite2D
var _telegraphed_position := Vector2.ZERO


func _ready() -> void:
	super._ready()
	_ensure_pattern_controller()


func _physics_process(delta: float) -> void:
	if _dead:
		velocity = Vector2.ZERO
		return
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
	if primitive_id == &"fan_or_arc_projectile":
		_spawn_fan_projectiles()
		return
	if primitive_id == &"telegraphed_zone":
		_resolve_telegraphed_zone_damage()
		return
	_resolve_pattern_damage(target)


func _on_pattern_state_changed(state: StringName, pattern: Dictionary) -> void:
	if state == &"telegraph":
		_capture_telegraph_position(pattern)
		_show_telegraph(pattern)
	elif state == &"recovery" or state == &"chase":
		_clear_telegraph()


func _resolve_pattern_damage(target_node: Node) -> int:
	if target_node == null or not is_instance_valid(target_node) or not target_node.has_method("take_damage"):
		return 0
	var result = target_node.call("take_damage", maxi(contact_damage, 1))
	return int(result) if result is int else 0


func _resolve_telegraphed_zone_damage() -> int:
	if target == null or not is_instance_valid(target):
		return 0
	if target.global_position.distance_squared_to(_telegraphed_position) > TELEGRAPHED_ZONE_RADIUS * TELEGRAPHED_ZONE_RADIUS:
		return 0
	return _resolve_pattern_damage(target)


func _capture_telegraph_position(pattern: Dictionary) -> void:
	var primitive_id := StringName(pattern.get("primitive_id", &""))
	if primitive_id == &"telegraphed_zone" and target != null and is_instance_valid(target):
		_telegraphed_position = target.global_position
		return
	_telegraphed_position = global_position


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
