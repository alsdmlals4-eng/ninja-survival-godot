extends Node
class_name CombatDDDTracker

signal combo_changed(current: int, maximum: int)
signal stylish_score_changed(score: int)
signal reward_count_changed(count: int)
signal title_triggered(title: String)

const COMBO_TITLES := {
	3: "그림자 연쇄",
	6: "닌자 난무",
	10: "백귀 격파",
}

@export var combo_window: float = 2.5
@export var kill_style_base: int = 100
@export var combo_step_bonus: int = 20
@export var reward_style_bonus: int = 25

var combo_count: int = 0
var max_combo: int = 0
var stylish_score: int = 0
var reward_count: int = 0
var combo_time_remaining: float = 0.0


func _process(delta: float) -> void:
	if delta <= 0.0 or combo_count == 0:
		return
	combo_time_remaining = maxf(combo_time_remaining - delta, 0.0)
	if combo_time_remaining <= 0.0:
		combo_count = 0
		combo_changed.emit(combo_count, max_combo)


func register_kill() -> void:
	if combo_time_remaining <= 0.0:
		combo_count = 1
	else:
		combo_count += 1
	combo_time_remaining = combo_window
	max_combo = maxi(max_combo, combo_count)
	stylish_score += kill_style_base + combo_step_bonus * (combo_count - 1)
	combo_changed.emit(combo_count, max_combo)
	stylish_score_changed.emit(stylish_score)
	if COMBO_TITLES.has(combo_count):
		title_triggered.emit(COMBO_TITLES[combo_count])


func register_reward_collected() -> void:
	reward_count += 1
	stylish_score += reward_style_bonus
	reward_count_changed.emit(reward_count)
	stylish_score_changed.emit(stylish_score)
