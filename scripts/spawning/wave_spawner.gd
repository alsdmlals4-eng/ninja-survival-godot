extends Node
class_name WaveSpawner

signal enemy_spawned(enemy: Node)

const NORMAL_ENEMY_META := &"ninja_wave_spawner_normal"
const OPENING_CONTACT_STAGGER_META := &"ninja_wave_opening_contact_stagger_seconds"
const OPENING_CONTACT_STAGGER_SLOT_COUNT := 5
const OPENING_CONTACT_STAGGER_STEP_SECONDS := 0.30
const SPAWN_WARNING = preload("res://scripts/spawning/spawn_warning.gd")
const RESERVATION_DELAY := 0.8

@export var enemy_scene: PackedScene
@export var wave_interval: float = 1.0
@export var batch_size: int = 3
@export var minimum_active_enemies: int = 10
@export var minimum_spawn_distance: float = 420.0
@export var maximum_spawn_distance: float = 560.0

var spawn_parent: Node
var anchor: Node2D
var _spawning_enabled: bool = true
var _time_remaining: float = 1.0
var _rng := RandomNumberGenerator.new()
var _opening_contact_stagger_index: int = 0
var _fair_spawning := false
var _reservations: Array[Dictionary] = []
var _reservation_epoch := 0


func _ready() -> void:
	_rng.randomize()


func configure(new_spawn_parent: Node, new_anchor: Node2D) -> void:
	_cancel_reservations()
	spawn_parent = new_spawn_parent
	anchor = new_anchor
	_time_remaining = maxf(wave_interval, 0.0)


func configure_horde_profile(
	new_wave_interval: float,
	new_batch_size: int,
	new_minimum_active_enemies: int,
	new_minimum_spawn_distance: float,
	new_maximum_spawn_distance: float
) -> bool:
	if (
		new_wave_interval <= 0.0
		or new_batch_size <= 0
		or new_minimum_active_enemies < 0
		or new_minimum_spawn_distance <= 0.0
		or new_maximum_spawn_distance < new_minimum_spawn_distance
	):
		return false

	wave_interval = new_wave_interval
	batch_size = new_batch_size
	minimum_active_enemies = new_minimum_active_enemies
	minimum_spawn_distance = new_minimum_spawn_distance
	maximum_spawn_distance = new_maximum_spawn_distance
	_time_remaining = minf(maxf(_time_remaining, 0.0), wave_interval)
	return true


func set_random_seed(value: int) -> void:
	_rng.seed = value


func set_spawning_enabled(value: bool) -> void:
	_spawning_enabled = value
	if not value:
		_cancel_reservations()


func enable_fair_spawning() -> void:
	_fair_spawning = true


func pending_spawn_count() -> int:
	return _reservations.size()


func _exit_tree() -> void:
	_cancel_reservations()


func ensure_minimum_active() -> int:
	if not _can_spawn():
		return 0
	var current := _active_normal_enemy_count()
	return _spawn_count(minimum_active_enemies - current - pending_spawn_count())


func spawn_wave() -> int:
	if not _can_spawn():
		return 0
	return _spawn_count(batch_size)


func _process(delta: float) -> void:
	if not _can_spawn() or delta <= 0.0 or not is_finite(delta) or (get_tree() != null and get_tree().paused):
		return
	_advance_reservations(delta)
	ensure_minimum_active()
	_time_remaining -= delta
	if _time_remaining <= 0.0:
		spawn_wave()
		_time_remaining = maxf(wave_interval, 0.01)


func _spawn_count(requested_count: int) -> int:
	if requested_count <= 0:
		return 0
	var spawned := 0

	for _index in range(requested_count):
		if _fair_spawning:
			var position := _offscreen_spawn_position()
			var warning := SPAWN_WARNING.new()
			warning.target_position = position
			spawn_parent.add_child(warning)
			_reservations.append({"position": position, "remaining": RESERVATION_DELAY, "warning": warning})
			spawned += 1
		elif _spawn_at(_random_annular_spawn_position()):
			spawned += 1

	return spawned


func _spawn_at(position: Vector2) -> bool:
	var enemy_node := enemy_scene.instantiate()
	if not enemy_node is Node2D:
		enemy_node.free()
		return false
	var enemy := enemy_node as Node2D
	enemy.set_meta(NORMAL_ENEMY_META, true)
	enemy.set_meta(OPENING_CONTACT_STAGGER_META, _next_opening_contact_stagger_seconds())
	# Enter physics at the destination, never briefly overlapping the player.
	enemy.position = spawn_parent.to_local(position) if spawn_parent is Node2D else position
	spawn_parent.add_child(enemy)
	enemy_spawned.emit(enemy)
	return true


func _advance_reservations(delta: float) -> void:
	var epoch := _reservation_epoch
	for index in range(_reservations.size() - 1, -1, -1):
		var pending := _reservations[index]
		if not _safe_spawn_position(pending.position):
			pending.position = _offscreen_spawn_position()
			pending.remaining = RESERVATION_DELAY
			if is_instance_valid(pending.warning): pending.warning.target_position = pending.position
			continue
		pending.remaining -= delta
		if pending.remaining <= 0.0:
			if is_instance_valid(pending.warning): pending.warning.queue_free()
			_reservations.remove_at(index)
			_spawn_at(pending.position)
			if _reservation_epoch != epoch:
				return


func _cancel_reservations() -> void:
	_reservation_epoch += 1
	for pending in _reservations:
		if is_instance_valid(pending.warning): pending.warning.queue_free()
	_reservations.clear()


func _safe_spawn_position(position: Vector2) -> bool:
	if anchor.global_position.distance_to(position) < minimum_spawn_distance:
		return false
	return not anchor.get_viewport_rect().grow(32.0).has_point(anchor.get_canvas_transform() * position)


func _offscreen_spawn_position() -> Vector2:
	var direction := Vector2.from_angle(_rng.randf_range(0.0, TAU))
	var canvas := anchor.get_canvas_transform()
	var origin := canvas * anchor.global_position
	var screen_direction := canvas.basis_xform(direction)
	var rect := anchor.get_viewport_rect().grow(48.0)
	var edge_distance := INF
	if absf(screen_direction.x) > 0.00001:
		var edge_x := rect.end.x if screen_direction.x > 0.0 else rect.position.x
		edge_distance = minf(edge_distance, maxf((edge_x - origin.x) / screen_direction.x, 0.0))
	if absf(screen_direction.y) > 0.00001:
		var edge_y := rect.end.y if screen_direction.y > 0.0 else rect.position.y
		edge_distance = minf(edge_distance, maxf((edge_y - origin.y) / screen_direction.y, 0.0))
	var near := maxf(minimum_spawn_distance, edge_distance)
	var far := maxf(maximum_spawn_distance, near + 140.0)
	var distance := sqrt(lerpf(near * near, far * far, _rng.randf()))
	return anchor.global_position + direction * distance


func _next_opening_contact_stagger_seconds() -> float:
	var slot := _opening_contact_stagger_index % OPENING_CONTACT_STAGGER_SLOT_COUNT
	_opening_contact_stagger_index += 1
	return float(slot) * OPENING_CONTACT_STAGGER_STEP_SECONDS


func _random_annular_spawn_position() -> Vector2:
	var angle := _rng.randf_range(0.0, TAU)
	var min_distance_squared := minimum_spawn_distance * minimum_spawn_distance
	var max_distance_squared := maximum_spawn_distance * maximum_spawn_distance
	var distance := sqrt(lerpf(min_distance_squared, max_distance_squared, _rng.randf()))
	return anchor.global_position + Vector2(cos(angle), sin(angle)) * distance


func _can_spawn() -> bool:
	return (
		_spawning_enabled
		and enemy_scene != null
		and spawn_parent != null
		and is_instance_valid(spawn_parent)
		and anchor != null
		and is_instance_valid(anchor)
	)


func _active_normal_enemy_count() -> int:
	if spawn_parent == null or not is_instance_valid(spawn_parent):
		return 0

	var count := 0
	for child in spawn_parent.get_children():
		if (
			child.is_in_group("enemies")
			and bool(child.get_meta(NORMAL_ENEMY_META, false))
			and not child.is_queued_for_deletion()
		):
			count += 1
	return count
