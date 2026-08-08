extends Node2D
class_name MainController

var game_over: bool = false

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
		if not child.is_in_group("enemies"):
			continue
		if child.has_method("set_target"):
			child.set_target(player)
		if child.has_signal("died"):
			child.died.connect(_on_enemy_died)


func _unhandled_input(event: InputEvent) -> void:
	if game_over and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()


func _on_enemy_died(_enemy: Node) -> void:
	game_state.register_kill(100)


func _on_player_died() -> void:
	if game_over:
		return
	game_over = true
	hud.show_game_over()
