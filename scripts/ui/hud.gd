extends CanvasLayer
class_name HUDController

@onready var health_label: Label = $HealthLabel
@onready var score_label: Label = $ScoreLabel
@onready var game_over_panel: Control = $GameOverPanel


func _ready() -> void:
	game_over_panel.visible = false


func set_health(current: int, maximum: int) -> void:
	health_label.text = "HP %d / %d" % [current, maximum]


func set_score(score: int, kills: int) -> void:
	score_label.text = "KILLS %d  SCORE %d" % [kills, score]


func show_game_over() -> void:
	game_over_panel.visible = true
