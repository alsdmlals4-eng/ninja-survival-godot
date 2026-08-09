extends GutTest

const PlayerScript = preload("res://scripts/player/player_controller.gd")
const ModifierScript = preload("res://scripts/data/run_modifier_set.gd")

var death_count: int = 0
var damage_events: Array = []
var healing_events: Array = []


func before_each() -> void:
	death_count = 0
	damage_events.clear()
	healing_events.clear()


func test_damage_reduces_health_clamps_and_dies_once() -> void:
	var player = PlayerScript.new()
	player.max_health = 30
	add_child_autofree(player)
	player.died.connect(_on_player_died)

	assert_eq(player.take_damage(12), 12)
	assert_eq(player.health, 18)
	assert_false(player.is_dead())

	assert_eq(player.take_damage(99), 18)
	assert_eq(player.health, 0)
	assert_true(player.is_dead())
	assert_eq(death_count, 1)

	assert_eq(player.take_damage(5), 0)
	assert_eq(death_count, 1)


func test_non_positive_damage_is_ignored() -> void:
	var player = PlayerScript.new()
	player.max_health = 30
	add_child_autofree(player)

	assert_eq(player.take_damage(0), 0)
	assert_eq(player.take_damage(-5), 0)
	assert_eq(player.health, 30)


func test_run_modifiers_recompute_max_health_and_move_speed_from_base_stats() -> void:
	var player = PlayerScript.new()
	player.max_health = 100
	player.move_speed = 240.0
	add_child_autofree(player)
	var modifiers = ModifierScript.new()
	modifiers.max_health_flat = 20.0
	modifiers.max_health_pct = -0.15
	modifiers.move_speed_pct = 0.25
	player.apply_run_modifiers(modifiers)
	assert_eq(player.max_health, 102)
	assert_almost_eq(player.move_speed, 300.0, 0.001)
	assert_eq(player.health, 100)

	player.apply_run_modifiers(ModifierScript.new())
	assert_eq(player.max_health, 100)
	assert_almost_eq(player.move_speed, 240.0, 0.001)


func test_removing_max_health_clamps_current_hp_without_damage_event() -> void:
	var player = PlayerScript.new()
	player.max_health = 100
	add_child_autofree(player)
	player.damage_resolved.connect(_on_damage_resolved)
	var boosted = ModifierScript.new()
	boosted.max_health_flat = 20.0
	player.apply_run_modifiers(boosted)
	assert_eq(player.max_health, 120)
	assert_eq(player.heal(20), 20)
	assert_eq(player.health, 120)
	player.apply_run_modifiers(ModifierScript.new())
	assert_eq(player.max_health, 100)
	assert_eq(player.health, 100)
	assert_eq(damage_events.size(), 0)


func test_heal_returns_actual_restoration_after_healing_modifier_and_cap() -> void:
	var player = PlayerScript.new()
	player.max_health = 100
	add_child_autofree(player)
	player.healing_resolved.connect(_on_healing_resolved)
	assert_eq(player.take_damage(30), 30)
	var modifiers = ModifierScript.new()
	modifiers.healing_pct = 0.30
	player.apply_run_modifiers(modifiers)
	assert_eq(player.heal(10), 13)
	assert_eq(player.health, 83)
	assert_eq(player.heal(999), 17)
	assert_eq(player.health, 100)
	assert_eq(healing_events, [13, 17])
	assert_eq(player.heal(0), 0)


func test_damage_reduction_reports_resolved_and_prevented_damage() -> void:
	var player = PlayerScript.new()
	player.max_health = 100
	add_child_autofree(player)
	player.damage_resolved.connect(_on_damage_resolved)
	var modifiers = ModifierScript.new()
	modifiers.damage_taken_pct = -0.20
	player.apply_run_modifiers(modifiers)
	assert_eq(player.take_damage(10), 8)
	assert_eq(player.health, 92)
	assert_eq(damage_events.size(), 1)
	assert_eq(damage_events[0], [10, 8, 2, false])


func test_evasion_prevents_full_requested_damage() -> void:
	var player = PlayerScript.new()
	player.max_health = 100
	add_child_autofree(player)
	player.damage_resolved.connect(_on_damage_resolved)
	player.set_rng_seed(99)
	var modifiers = ModifierScript.new()
	modifiers.evasion_chance = 1.0
	player.apply_run_modifiers(modifiers)
	assert_eq(player.take_damage(25), 0)
	assert_eq(player.health, 100)
	assert_eq(damage_events[0], [25, 0, 25, true])


func test_overkill_is_not_reported_as_defense() -> void:
	var player = PlayerScript.new()
	player.max_health = 5
	add_child_autofree(player)
	player.damage_resolved.connect(_on_damage_resolved)
	assert_eq(player.take_damage(10), 5)
	assert_eq(player.health, 0)
	assert_eq(damage_events[0], [10, 10, 0, false])


func test_dead_player_cannot_be_healed_or_damaged_again() -> void:
	var player = PlayerScript.new()
	player.max_health = 5
	add_child_autofree(player)
	assert_eq(player.take_damage(5), 5)
	assert_true(player.is_dead())
	assert_eq(player.heal(5), 0)
	assert_eq(player.take_damage(5), 0)
	assert_eq(player.health, 0)


func test_resolve_movement_direction_supports_wasd_and_ui_keys() -> void:
	var player = PlayerScript.new()
	add_child_autofree(player)

	assert_eq(
		player.resolve_movement_direction(Vector2.ZERO, true, false, false, false),
		Vector2.LEFT,
		"A must add left movement without removing the existing UI-key path"
	)
	var diagonal: Vector2 = player.resolve_movement_direction(
		Vector2.ZERO,
		false,
		true,
		true,
		false
	)
	assert_almost_eq(diagonal.x, 0.707106, 0.001)
	assert_almost_eq(diagonal.y, -0.707106, 0.001)
	assert_eq(
		player.resolve_movement_direction(Vector2.RIGHT, true, false, false, false),
		Vector2.ZERO,
		"Opposing arrow/WASD directions should cancel"
	)


func _on_player_died() -> void:
	death_count += 1


func _on_damage_resolved(requested: int, resolved: int, prevented: int, evaded: bool) -> void:
	damage_events.append([requested, resolved, prevented, evaded])


func _on_healing_resolved(actual: int) -> void:
	healing_events.append(actual)
