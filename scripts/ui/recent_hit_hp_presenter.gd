# 가장 최근에 피격된 적 하나의 짧은 HP 표시를 소유한다.
extends Node
class_name RecentHitHpPresenter

const DISPLAY_DURATION := 1.25
const BAR_SIZE := Vector2(64.0, 8.0)
const BAR_OFFSET := Vector2(-32.0, -52.0)

var _current_enemy: Node2D
var _bar: ProgressBar
var _remaining: float = 0.0


func observe_enemy(enemy: Node) -> bool:
	if not is_instance_valid(enemy) or not enemy is Node2D or not enemy.has_signal(&"damaged"):
		return false
	var hit_callback := Callable(self, "_on_enemy_damaged")
	if not enemy.is_connected(&"damaged", hit_callback):
		enemy.connect(&"damaged", hit_callback)
	var death_callback := Callable(self, "_on_enemy_died")
	if enemy.has_signal(&"died") and not enemy.is_connected(&"died", death_callback):
		enemy.connect(&"died", death_callback)
	return true


func record_hit(enemy: Node2D, remaining_health: int, maximum_health: int) -> bool:
	if not _is_displayable(enemy) or maximum_health <= 0 or remaining_health <= 0:
		if enemy == _current_enemy:
			_clear_current()
		return false
	if enemy != _current_enemy:
		_clear_current()
		_current_enemy = enemy
		_bar = _create_bar()
		enemy.add_child(_bar)
	_bar.max_value = float(maximum_health)
	_bar.value = clampf(float(remaining_health), 0.0, float(maximum_health))
	_bar.show()
	_remaining = DISPLAY_DURATION
	return true


func visible_enemy() -> Node2D:
	return _current_enemy


func visible_bar() -> ProgressBar:
	return _bar


func _process(delta: float) -> void:
	if _current_enemy == null:
		return
	if not _is_displayable(_current_enemy):
		_clear_current()
		return
	_remaining = maxf(_remaining - maxf(delta, 0.0), 0.0)
	if _remaining <= 0.0:
		_clear_current()


func _on_enemy_damaged(enemy: Node, actual_damage: int, remaining_health: int, maximum_health: int) -> void:
	if actual_damage <= 0 or not enemy is Node2D:
		return
	record_hit(enemy as Node2D, remaining_health, maximum_health)


func _on_enemy_died(enemy: Node) -> void:
	if enemy == _current_enemy:
		_clear_current()


func _create_bar() -> ProgressBar:
	var bar := ProgressBar.new()
	bar.name = "RecentHitHpBar"
	bar.position = BAR_OFFSET
	bar.size = BAR_SIZE
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.show_percentage = false
	bar.min_value = 0.0
	return bar


func _is_displayable(enemy: Node2D) -> bool:
	return is_instance_valid(enemy) and not enemy.is_queued_for_deletion() and enemy.is_inside_tree() and enemy.is_visible_in_tree()


func _clear_current() -> void:
	if is_instance_valid(_bar):
		_bar.queue_free()
	_current_enemy = null
	_bar = null
	_remaining = 0.0
