extends CanvasLayer
class_name HUDController

@onready var health_label: Label = $HealthLabel
@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var style_label: Label = $StyleLabel
@onready var reward_label: Label = $RewardLabel
@onready var combo_title_label: Label = $ComboTitleLabel
@onready var game_over_panel: Control = $GameOverPanel

var _title_generation: int = 0


func _ready() -> void:
	game_over_panel.visible = false


func set_health(current: int, maximum: int) -> void:
	health_label.text = "HP %d / %d" % [current, maximum]


func set_score(score: int, kills: int) -> void:
	score_label.text = "KILLS %d  SCORE %d" % [kills, score]


func set_combo(current: int, maximum: int) -> void:
	if current <= 0:
		combo_label.text = ""
		return
	combo_label.text = "COMBO x%d  MAX %d" % [current, maximum]


func set_stylish_score(score: int) -> void:
	style_label.text = "STYLE %d" % score


func set_reward_count(count: int) -> void:
	reward_label.text = "ORBS %d" % count


func show_combo_title(title: String) -> void:
	_title_generation += 1
	var generation := _title_generation
	combo_title_label.text = title
	await get_tree().create_timer(1.0).timeout
	if generation == _title_generation:
		combo_title_label.text = ""


func show_game_over() -> void:
	game_over_panel.visible = true
