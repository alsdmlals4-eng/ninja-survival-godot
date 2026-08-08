extends Node
class_name GameState

signal score_changed(score: int, kill_count: int)

var score: int = 0
var kill_count: int = 0


func register_kill(_points: int = 100) -> void:
	pass
