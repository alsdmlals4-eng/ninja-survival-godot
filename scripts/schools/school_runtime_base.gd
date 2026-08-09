extends Node
class_name SchoolRuntimeBase

signal resource_changed(label: String, current: float, maximum: float)
signal ultimate_ready_changed(ready: bool)
signal school_feedback(text: String)

var player: PlayerController
var world: Node2D
var active: bool = false


func configure(new_player: PlayerController, new_world: Node2D) -> void:
	player = new_player
	world = new_world


func activate() -> void:
	active = true
	process_mode = Node.PROCESS_MODE_INHERIT


func deactivate() -> void:
	active = false
	process_mode = Node.PROCESS_MODE_DISABLED


func on_enemy_died(_enemy: Node) -> void:
	pass


func try_use_ultimate() -> bool:
	return false


func is_ultimate_ready() -> bool:
	return false
