extends GutTest

func _context() -> Dictionary:
	var host := Node2D.new()
	add_child_autofree(host)
	var anchor := Node2D.new()
	host.add_child(anchor)
	anchor.position = Vector2(320, 240)
	var spawner = load("res://scripts/spawning/wave_spawner.gd").new()
	host.add_child(spawner)
	spawner.set_process(false)
	spawner.enemy_scene = load("res://scenes/enemies/enemy_basic.tscn")
	spawner.configure(host, anchor)
	assert_true(spawner.has_method("enable_fair_spawning"), "Selected mode needs delayed, offscreen reservations.")
	if not spawner.has_method("enable_fair_spawning"): return {}
	spawner.enable_fair_spawning()
	return {"host": host, "anchor": anchor, "spawner": spawner}

func test_floor_counts_pending_and_never_duplicates_before_the_warning_delay() -> void:
	var c := _context()
	if c.is_empty(): return
	assert_eq(c.spawner.ensure_minimum_active(), 10)
	assert_eq(c.spawner.ensure_minimum_active(), 0)
	assert_eq(c.spawner.pending_spawn_count(), 10)
	assert_eq(c.spawner._active_normal_enemy_count(), 0)
	c.spawner._process(0.79)
	assert_eq(c.spawner._active_normal_enemy_count(), 0)
	c.spawner._process(0.02)
	assert_eq(c.spawner._active_normal_enemy_count(), 10)
	assert_eq(c.spawner.pending_spawn_count(), 0)
	for enemy in c.host.get_children():
		if not enemy.is_in_group("enemies"): continue
		assert_gte(enemy.global_position.distance_to(c.anchor.global_position), 420.0)
		var screen: Vector2 = c.anchor.get_canvas_transform() * enemy.global_position
		assert_false(c.anchor.get_viewport_rect().grow(24).has_point(screen))

func test_phase_stop_cancels_reservations_without_removing_existing_mobs() -> void:
	var c := _context()
	if c.is_empty(): return
	c.spawner.ensure_minimum_active()
	c.spawner._process(0.81)
	assert_eq(c.spawner._active_normal_enemy_count(), 10)
	c.spawner.spawn_wave()
	assert_eq(c.spawner.pending_spawn_count(), 3)
	c.spawner.set_spawning_enabled(false)
	assert_eq(c.spawner.pending_spawn_count(), 0)
	c.spawner._process(2.0)
	assert_eq(c.spawner._active_normal_enemy_count(), 10)

func test_pause_preserves_reservations_without_advancing_their_delay() -> void:
	var c := _context()
	if c.is_empty(): return
	c.spawner.ensure_minimum_active()
	get_tree().paused = true
	c.spawner._process(5.0)
	assert_eq(c.spawner._active_normal_enemy_count(), 0)
	assert_eq(c.spawner.pending_spawn_count(), 10)
	get_tree().paused = false
	c.spawner._process(0.79)
	assert_eq(c.spawner._active_normal_enemy_count(), 0)
	c.spawner._process(0.02)
	assert_eq(c.spawner._active_normal_enemy_count(), 10)

func test_entering_reserved_position_restarts_warning_instead_of_spawning_on_player() -> void:
	var c := _context()
	if c.is_empty(): return
	c.spawner.ensure_minimum_active()
	c.anchor.global_position = c.spawner._reservations[0].position
	c.spawner._process(0.81)
	assert_gt(c.spawner.pending_spawn_count(), 0)
	for enemy in c.host.get_children():
		if enemy.is_in_group("enemies"):
			assert_gte(enemy.global_position.distance_to(c.anchor.global_position), 420.0)

func test_spawn_signal_can_cancel_remaining_batch_without_extra_mobs() -> void:
	var c := _context()
	if c.is_empty(): return
	c.spawner.enemy_spawned.connect(func(_enemy): c.spawner.set_spawning_enabled(false), CONNECT_ONE_SHOT)
	c.spawner.ensure_minimum_active()
	c.spawner._process(0.81)
	assert_eq(c.spawner._active_normal_enemy_count(), 1)
	assert_eq(c.spawner.pending_spawn_count(), 0)

func test_fair_reservations_do_not_introduce_an_enemy_count_cap() -> void:
	var c := _context()
	if c.is_empty(): return
	c.spawner.ensure_minimum_active()
	for unused in range(10): c.spawner.spawn_wave()
	assert_eq(c.spawner.pending_spawn_count(), 40)
	c.spawner._process(0.81)
	assert_eq(c.spawner._active_normal_enemy_count(), 40)
	c.spawner.spawn_wave()
	c.spawner._process(0.81)
	assert_gte(c.spawner._active_normal_enemy_count(), 43)
