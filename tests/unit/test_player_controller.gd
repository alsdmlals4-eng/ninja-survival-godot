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
	_release_movement_actions()


func after_each() -> void:
	_release_movement_actions()


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


func test_movement_intent_is_limited_before_dash_direction_is_resolved() -> void:
	var player = _spawn_player()
	watch_signals(player)
	player.set_movement_intent(Vector2(3.0, 4.0))

	assert_true(player.request_dash())
	assert_signal_emitted_with_parameters(player, "dash_started", [Vector2(0.6, 0.8)])


func test_dash_consumes_one_of_two_charges_and_emits_read_only_state() -> void:
	var player = _spawn_player()
	player.set_movement_intent(Vector2.RIGHT)
	watch_signals(player)

	assert_true(player.request_dash())
	assert_eq(player.current_dash_charges(), 1)
	assert_signal_emitted_with_parameters(player, "dash_state_changed", [1, 2])


func test_dash_rejects_zero_direction_dead_player_and_empty_charges_without_mutation() -> void:
	var player = _spawn_player()
	assert_false(player.request_dash())
	assert_eq(player.current_dash_charges(), 2)

	player.set_movement_intent(Vector2.RIGHT)
	assert_true(player.request_dash())
	assert_true(player.request_dash())
	assert_eq(player.current_dash_charges(), 0)
	assert_false(player.request_dash())
	assert_eq(player.current_dash_charges(), 0)

	var dead_player = _spawn_player()
	dead_player.set_movement_intent(Vector2.RIGHT)
	assert_eq(dead_player.take_damage(dead_player.max_health), dead_player.max_health)
	assert_false(dead_player.request_dash())
	assert_eq(dead_player.current_dash_charges(), 2)


func test_dash_recharges_one_charge_after_one_point_five_seconds() -> void:
	var player = _spawn_player()
	player.set_movement_intent(Vector2.RIGHT)
	assert_true(player.request_dash())

	player._advance_dash_state(1.49)
	assert_eq(player.current_dash_charges(), 1)
	player._advance_dash_state(0.01)
	assert_eq(player.current_dash_charges(), 2)


func test_second_dash_does_not_reset_the_running_recharge_cadence() -> void:
	var player = _spawn_player()
	player.set_movement_intent(Vector2.RIGHT)
	assert_true(player.request_dash())

	player._advance_dash_state(1.49)
	assert_true(player.request_dash())
	assert_eq(player.current_dash_charges(), 0)

	player._advance_dash_state(0.01)
	assert_eq(player.current_dash_charges(), 1, "first charge must return 1.5 seconds after the initial spend")
	player._advance_dash_state(1.49)
	assert_eq(player.current_dash_charges(), 1)
	player._advance_dash_state(0.01)
	assert_eq(player.current_dash_charges(), 2, "remaining charge must follow the original 1.5-second cadence")


func test_active_dash_does_not_prevent_damage_or_bypass_body_motion() -> void:
	var player = _spawn_player()
	player.set_movement_intent(Vector2.RIGHT)
	assert_true(player.request_dash())

	assert_eq(player.take_damage(10), 10)
	assert_eq(player.health, 90)


func test_pointer_target_farther_than_arrival_radius_resolves_normalized_direction() -> void:
	var player = _spawn_player()
	player.global_position = Vector2(20.0, 30.0)
	watch_signals(player)
	player.set_pointer_target(player.global_position + Vector2(30.0, 40.0))

	assert_true(player.request_dash())
	assert_signal_emitted_with_parameters(player, "dash_started", [Vector2(0.6, 0.8)])


func test_pointer_target_inside_arrival_radius_resolves_zero_direction() -> void:
	var player = _spawn_player()
	player.set_movement_intent(Vector2.LEFT)
	player.set_pointer_target(
		player.global_position + Vector2.RIGHT * (player.POINTER_ARRIVAL_RADIUS - 0.1)
	)

	assert_false(player.request_dash())
	assert_eq(player.current_dash_charges(), 2)


func test_clearing_pointer_target_restores_action_movement_intent() -> void:
	var player = _spawn_player()
	player.set_movement_intent(Vector2.LEFT)
	player.set_pointer_target(player.global_position)
	assert_false(player.request_dash())
	player.clear_pointer_target()
	watch_signals(player)

	assert_true(player.request_dash())
	assert_signal_emitted_with_parameters(player, "dash_started", [Vector2.LEFT])


func _spawn_player():
	var player = PlayerScript.new()
	add_child_autofree(player)
	return player


func _release_movement_actions() -> void:
	for action_name in [&"move_left", &"move_right", &"move_up", &"move_down", &"dash"]:
		Input.action_release(action_name)


func _on_player_died() -> void:
	death_count += 1


func _on_damage_resolved(requested: int, resolved: int, prevented: int, evaded: bool) -> void:
	damage_events.append([requested, resolved, prevented, evaded])


func _on_healing_resolved(actual: int) -> void:
	healing_events.append(actual)
