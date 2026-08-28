extends CanvasLayer
class_name HUDController

signal restart_requested
signal retry_requested
signal school_help_requested
signal ultimate_requested
signal test_elite_requested
signal test_boss_requested

@onready var health_label: Label = $HealthLabel
@onready var score_label: Label = $ScoreLabel
@onready var combo_label: Label = $ComboLabel
@onready var style_label: Label = $StyleLabel
@onready var reward_label: Label = $RewardLabel
@onready var school_label: Label = $SchoolLabel
@onready var school_resource_label: Label = $SchoolResourceLabel
@onready var ultimate_label: Label = $UltimateLabel
@onready var school_feedback_label: Label = $SchoolFeedbackLabel
@onready var combo_title_label: Label = $ComboTitleLabel
@onready var stage_label: Label = $StageLabel
@onready var stage_time_label: Label = $StageTimeLabel
@onready var gold_label: Label = $GoldLabel
@onready var restart_button: Button = $RestartButton
@onready var school_help_button: Button = $SchoolHelpButton
@onready var ultimate_button: Button = $UltimateButton
@onready var combat_guide_label: Label = $CombatGuideLabel
@onready var test_elite_button: Button = $TestEliteButton
@onready var test_boss_button: Button = $TestBossButton
@onready var game_over_panel: Control = $GameOverPanel
@onready var game_over_message: Label = $GameOverPanel/Message
@onready var retry_button: Button = $GameOverPanel/RetryButton

var _title_generation: int = 0
var _school_feedback_generation: int = 0
var _ultimate_ready: bool = false


func _ready() -> void:
	game_over_panel.visible = false
	school_help_button.hide()
	hide_combat_controls()
	restart_button.pressed.connect(_on_restart_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	school_help_button.pressed.connect(_on_school_help_pressed)
	ultimate_button.pressed.connect(_on_ultimate_pressed)
	test_elite_button.pressed.connect(_on_test_elite_pressed)
	test_boss_button.pressed.connect(_on_test_boss_pressed)


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


func set_school(name: String) -> void:
	school_label.text = "SCHOOL %s" % name


func show_school_help(school_name: String) -> void:
	if school_name.is_empty():
		hide_school_help()
		return
	school_help_button.text = "%s 기능 도움말" % school_name
	school_help_button.show()


func hide_school_help() -> void:
	school_help_button.hide()


func show_combat_controls(school_name: String, ultimate_description: String, show_test_jumps: bool) -> void:
	combat_guide_label.text = "기본 공격: 자동 투사체가 가까운 적을 노립니다.\n궁극기 [Enter/버튼] — %s" % ultimate_description
	combat_guide_label.show()
	ultimate_button.text = "%s 궁극기 [Enter]" % school_name
	ultimate_button.disabled = not _ultimate_ready
	ultimate_button.show()
	if show_test_jumps:
		test_elite_button.show()
		test_boss_button.show()
	else:
		test_elite_button.hide()
		test_boss_button.hide()


func hide_combat_controls() -> void:
	combat_guide_label.hide()
	ultimate_button.hide()
	test_elite_button.hide()
	test_boss_button.hide()


func set_school_resource(label: String, current: float, maximum: float) -> void:
	school_resource_label.text = "%s %d / %d" % [label, roundi(current), roundi(maximum)]


func set_ultimate_ready(ready: bool) -> void:
	_ultimate_ready = ready
	ultimate_label.text = "ULT READY" if ready else "ULT charging"
	ultimate_button.disabled = not ready


func set_stage(segment: int, total: int = 3) -> void:
	stage_label.text = "SEGMENT %d/%d" % [maxi(segment, 0), maxi(total, 1)]


func set_stage_time(seconds_remaining: float) -> void:
	var total_seconds := maxi(ceili(maxf(seconds_remaining, 0.0)), 0)
	var minutes := floori(float(total_seconds) / 60.0)
	var seconds := total_seconds % 60
	stage_time_label.text = "TIME %02d:%02d" % [minutes, seconds]


func set_gold(gold: int) -> void:
	gold_label.text = "GOLD %d" % maxi(gold, 0)


func show_school_feedback(text: String) -> void:
	_school_feedback_generation += 1
	var generation := _school_feedback_generation
	school_feedback_label.text = text
	await get_tree().create_timer(1.0).timeout
	if generation == _school_feedback_generation:
		school_feedback_label.text = ""


func show_combo_title(title: String) -> void:
	_title_generation += 1
	var generation := _title_generation
	combo_title_label.text = title
	await get_tree().create_timer(1.0).timeout
	if generation == _title_generation:
		combo_title_label.text = ""


func show_game_over(retry_available: bool = false, ninja_soul_balance: int = 0) -> void:
	game_over_message.text = "GAME OVER"
	if retry_available:
		game_over_message.text += "\n닌자소울 1로 현재 학교 재도전"
	retry_button.visible = retry_available
	retry_button.disabled = not retry_available
	retry_button.text = "재도전 · 닌자소울 1 (보유 %d)" % maxi(ninja_soul_balance, 0)
	game_over_panel.visible = true


func hide_game_over() -> void:
	game_over_panel.visible = false


func _on_restart_pressed() -> void:
	restart_requested.emit()


func _on_retry_pressed() -> void:
	if retry_button.disabled:
		return
	retry_requested.emit()


func _on_school_help_pressed() -> void:
	school_help_requested.emit()


func _on_ultimate_pressed() -> void:
	ultimate_requested.emit()


func _on_test_elite_pressed() -> void:
	test_elite_requested.emit()


func _on_test_boss_pressed() -> void:
	test_boss_requested.emit()
