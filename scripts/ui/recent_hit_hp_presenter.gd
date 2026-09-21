# 가장 최근에 피격된 적 하나의 짧은 HP 표시를 소유한다.
extends Node
class_name RecentHitHpPresenter

const DISPLAY_DURATION := 1.25
const BAR_SIZE := Vector2(64.0, 8.0)
const BAR_OFFSET := Vector2(-32.0, -52.0)

var _current_enemy: Node2D
var _bar: ProgressBar
var _remaining: float = 0.0
var persistent_bars := false
var _bars: Dictionary = {}


func observe_enemy(enemy: Node) -> bool:
	if not is_instance_valid(enemy) or not enemy is Node2D or not enemy.has_signal(&"damaged"):
		return false
	var hit_callback := Callable(self, "_on_enemy_damaged")
	if not enemy.is_connected(&"damaged", hit_callback):
		enemy.connect(&"damaged", hit_callback)
	var death_callback := Callable(self, "_on_enemy_died")
	if enemy.has_signal(&"died") and not enemy.is_connected(&"died", death_callback):
		enemy.connect(&"died", death_callback)
	if persistent_bars and not _bars.has(enemy.get_instance_id()):
		var bar := _create_bar()
		bar.name = "EnemyHpBar"
		bar.position = Vector2(-24, 34)
		bar.size = Vector2(48, 5)
		var fill := StyleBoxFlat.new()
		fill.bg_color = Color(0.82, 0.10, 0.13)
		var background := StyleBoxFlat.new()
		background.bg_color = Color(0.05, 0.02, 0.03, 0.85)
		bar.add_theme_stylebox_override("fill", fill)
		bar.add_theme_stylebox_override("background", background)
		bar.max_value = float(enemy.max_health)
		bar.value = float(enemy.health)
		enemy.add_child(bar)
		# Tree entry resolves theme caches; resize after that, not against stale defaults.
		bar.size = Vector2(48, 5)
		var id := enemy.get_instance_id()
		_bars[id] = bar
		_place_persistent_bar(&"", enemy)
		if enemy.has_signal("theme_changed"):
			enemy.connect("theme_changed", _place_persistent_bar.bind(enemy))
		enemy.tree_exiting.connect(func(): _bars.erase(id), CONNECT_ONE_SHOT)
	return true


func _place_persistent_bar(_theme: StringName, enemy: Node) -> void:
	var bar = _bars.get(enemy.get_instance_id())
	if not is_instance_valid(bar): return
	bar.position.y = 34.0
	var visual := enemy.get_node_or_null("Visual") as Sprite2D
	if visual != null and visual.texture != null:
		var bounds: Rect2 = visual.transform * visual.get_rect()
		bar.position.y = maxf(bar.position.y, bounds.end.y + 4.0)


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
	if persistent_bars:
		var bar = _bars.get(enemy.get_instance_id())
		if is_instance_valid(bar):
			bar.max_value = maximum_health
			bar.value = maxi(remaining_health, 0)
		return
	if actual_damage <= 0 or not enemy is Node2D:
		return
	record_hit(enemy as Node2D, remaining_health, maximum_health)


func _on_enemy_died(enemy: Node) -> void:
	if persistent_bars:
		var bar = _bars.get(enemy.get_instance_id())
		if is_instance_valid(bar): bar.hide()
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
