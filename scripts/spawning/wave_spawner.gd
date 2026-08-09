extends Node
class_name WaveSpawner

signal enemy_spawned(enemy: Node)

const SPAWN_DIRECTIONS := [
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.UP,
]

@export var enemy_scene: PackedScene
@export var wave_interval: float = 5.0
@export var batch_size: int = 2
@export var max_active_enemies: int = 8
@export var spawn_distance: float = 320.0

var spawn_parent: Node
var anchor: Node2D
var _spawning_enabled: bool = true
var _time_remaining: float = 5.0
var _spawn_direction_index: int = 0


func configure(new_spawn_parent: Node, new_anchor: Node2D) -> void:
	spawn_parent = new_spawn_parent
	anchor = new_anchor
	_time_remaining = maxf(wave_interval, 0.0)


func set_spawning_enabled(value: bool) -> void:
	_spawning_enabled = value


func spawn_wave() -> int:
	if not _spawning_enabled or enemy_scene == null:
		return 0
	if spawn_parent == null or not is_instance_valid(spawn_parent):
		return 0
	if anchor == null or not is_instance_valid(anchor):
		return 0

	var capacity := maxi(max_active_enemies - _active_enemy_count(), 0)
	var spawn_count := mini(maxi(batch_size, 0), capacity)
	var spawned := 0

	for _i in range(spawn_count):
		var enemy_node := enemy_scene.instantiate()
		if not enemy_node is Node2D:
			enemy_node.free()
			continue

		spawn_parent.add_child(enemy_node)
		var enemy := enemy_node as Node2D
		var direction: Vector2 = SPAWN_DIRECTIONS[_spawn_direction_index % SPAWN_DIRECTIONS.size()]
		_spawn_direction_index += 1
		enemy.global_position = anchor.global_position + direction * spawn_distance
		enemy_spawned.emit(enemy)
		spawned += 1

	return spawned


func _process(delta: float) -> void:
	if not _spawning_enabled or delta <= 0.0:
		return
	if spawn_parent == null or not is_instance_valid(spawn_parent):
		return
	if anchor == null or not is_instance_valid(anchor):
		return

	_time_remaining -= delta
	if _time_remaining <= 0.0:
		spawn_wave()
		_time_remaining = maxf(wave_interval, 0.0)


func _active_enemy_count() -> int:
	if spawn_parent == null or not is_instance_valid(spawn_parent):
		return 0

	var count := 0
	for child in spawn_parent.get_children():
		if child.is_in_group("enemies") and not child.is_queued_for_deletion():
			count += 1
	return count
