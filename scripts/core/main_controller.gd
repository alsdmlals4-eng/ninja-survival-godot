extends Node2D
class_name MainController

const SPAWN_DIRECTIONS := [
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.UP,
]

@export var enemy_scene: PackedScene
@export var enemy_spawn_distance: float = 320.0

var game_over: bool = false
var _spawn_direction_index: int = 0

@onready var game_state: GameState = $GameState
@onready var player: PlayerController = $Player
@onready var hud: HUDController = $HUD


func _ready() -> void:
	game_state.score_changed.connect(hud.set_score)
	player.health_changed.connect(hud.set_health)
	player.died.connect(_on_player_died)

	hud.set_health(player.health, player.max_health)
	hud.set_score(game_state.score, game_state.kill_count)

	for child in get_children():
		if child.is_in_group("enemies"):
			_wire_enemy(child)


func _unhandled_input(event: InputEvent) -> void:
	if game_over and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func _on_enemy_died(_enemy: Node) -> void:
	game_state.register_kill(100)
	if game_over:
		return
	call_deferred("_spawn_replacement_enemy")


func _spawn_replacement_enemy() -> void:
	if game_over or enemy_scene == null or not is_instance_valid(player):
		return

	var enemy_node := enemy_scene.instantiate()
	if not enemy_node is Node2D:
		enemy_node.free()
		return

	add_child(enemy_node)
	var enemy := enemy_node as Node2D
	var direction: Vector2 = SPAWN_DIRECTIONS[_spawn_direction_index % SPAWN_DIRECTIONS.size()]
	_spawn_direction_index += 1
	enemy.global_position = player.global_position + direction * enemy_spawn_distance
	_wire_enemy(enemy)


func _wire_enemy(enemy: Node) -> void:
	if enemy.has_method("set_target"):
		enemy.set_target(player)
	if enemy.has_signal("died"):
		var death_callback := Callable(self, "_on_enemy_died")
		if not enemy.is_connected("died", death_callback):
			enemy.connect("died", death_callback)


func _on_player_died() -> void:
	if game_over:
		return
	game_over = true
	_stop_gameplay()
	hud.show_game_over()


func _stop_gameplay() -> void:
	for child in get_children():
		if child == game_state or child == hud:
			continue
		child.process_mode = Node.PROCESS_MODE_DISABLED
