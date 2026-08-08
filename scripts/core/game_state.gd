extends Node
class_name GameState

signal score_changed(score: int, kill_count: int)

var score: int = 0
var kill_count: int = 0


func register_kill(points: int = 100) -> void:
	kill_count += 1
	score += max(points, 0)
	score_changed.emit(score, kill_count)
