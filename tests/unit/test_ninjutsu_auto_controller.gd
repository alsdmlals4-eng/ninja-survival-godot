# 확정 인법서가 자동 전투에서만 추가 공격을 만드는지 검증한다.
extends GutTest

const AUTO_CONTROLLER_PATH := "res://scripts/schools/ninjutsu_auto_controller.gd"
const LOADOUT_SCRIPT = preload("res://scripts/core/ninjutsu_loadout_state.gd")


func test_selectable_pulse_uses_book_period_range_and_committed_membership() -> void:
	var player := Node2D.new()
	add_child_autofree(player)
	var enemy := DummyEnemy.new()
	add_child_autofree(enemy)
	enemy.position = Vector2(80, 0)
	enemy.add_to_group("enemies")
	var loadout = LOADOUT_SCRIPT.new()
	add_child_autofree(loadout)
	assert_true(loadout.begin_start_draft(&"guiin", 12))
	for index in range(2):
		assert_true(loadout.choose_start_draft(loadout.start_draft_snapshot().options[0]))
	assert_true(loadout.commit_drafted_start(loadout.start_draft_snapshot().picks))
	assert_true(loadout.commit_placed_ninjutsu([&"guiin_ghost_blood_wave"], [&"guiin"]))
	var controller = load(AUTO_CONTROLLER_PATH).new()
	add_child_autofree(controller)
	controller.set_process(false)
	assert_true(controller.configure(player, self, null, loadout))
	controller.tick_auto_cast(0.4)
	assert_eq(enemy.health, 50)
	controller.tick_auto_cast(0.5)
	assert_eq(enemy.health, 40, "Selected starter must consume the book definition, not be skipped.")
	enemy.position.x = 80.01
	controller.tick_auto_cast(0.9)
	assert_eq(enemy.health, 40)
	enemy.position.x = 80
	controller.tick_auto_cast(0.12)
	assert_eq(enemy.health, 30, "No target retries without spending a full cooldown.")
	assert_true(loadout.commit_placed_ninjutsu([], [&"guiin"]))
	controller.tick_auto_cast(2.0)
	assert_eq(enemy.health, 30)
	assert_true(loadout.commit_placed_ninjutsu([&"guiin_ghost_blood_wave"], [&"guiin"]))
	controller.tick_auto_cast(0.4)
	assert_eq(enemy.health, 30, "Re-equipping must not reset the retained cooldown.")
	controller.tick_auto_cast(0.5)
	assert_eq(enemy.health, 20)


class DummyEnemy extends Node2D:
	var health: int = 50

	func take_damage(amount: int) -> int:
		var resolved := mini(maxi(amount, 0), health)
		health -= resolved
		return resolved

	func is_dead() -> bool:
		return health <= 0


func _selected_fixture(id: StringName, school: StringName = &"guiin") -> Dictionary:
	var world := Node2D.new()
	add_child_autofree(world)
	var player := Node2D.new()
	world.add_child(player)
	var loadout = LOADOUT_SCRIPT.new()
	world.add_child(loadout)
	loadout.begin_start_draft(school, 12)
	for index in range(2):
		loadout.choose_start_draft(loadout.start_draft_snapshot().options[0])
	loadout.commit_drafted_start(loadout.start_draft_snapshot().picks)
	assert_true(loadout.commit_placed_ninjutsu([id], [school]))
	var controller = load(AUTO_CONTROLLER_PATH).new()
	world.add_child(controller)
	controller.set_process(false)
	controller.configure(player, world, null, loadout)
	return {"world": world, "player": player, "loadout": loadout, "controller": controller}


func _enemy_in(world: Node, position: Vector2) -> DummyEnemy:
	var enemy := DummyEnemy.new()
	if world == self:
		add_child_autofree(enemy)
	else:
		world.add_child(enemy)
	enemy.position = position
	enemy.add_to_group("enemies")
	return enemy


func test_wind_moves_over_time_sweeps_long_frames_and_hits_each_target_once() -> void:
	var f := _selected_fixture(&"cheonsul_wind_pillar", &"cheonsul")
	var near := _enemy_in(f.world, Vector2(120, 0))
	var far := _enemy_in(f.world, Vector2(360, 24))
	var outside := _enemy_in(f.world, Vector2(180, 24.01))
	var beyond := _enemy_in(f.world, Vector2(360.01, 0))
	f.controller.tick_auto_cast(3.0)
	assert_eq(near.health, 50, "Wind is not instantaneous damage along the whole line.")
	f.controller.tick_auto_cast(0.2)
	assert_eq(near.health, 36)
	assert_eq(far.health, 50)
	var moving_visual: Sprite2D
	for child in f.world.get_children():
		if child is Sprite2D:
			moving_visual = child
	assert_not_null(moving_visual)
	if moving_visual != null:
		assert_eq(moving_visual.position, Vector2(120, 0))
	f.player.position = Vector2(1000, 1000)
	f.controller.tick_auto_cast(1.0)
	assert_eq(near.health, 36)
	assert_eq(far.health, 36, "The final swept segment must resolve even on a long frame.")
	assert_eq(outside.health, 50)
	assert_eq(beyond.health, 50)
	var expired := _enemy_in(f.world, Vector2(200, 0))
	f.controller.tick_auto_cast(0.1)
	assert_eq(expired.health, 50)


func test_needle_moves_hits_first_target_only_and_marks_without_hidden_burst() -> void:
	var f := _selected_fixture(&"heukyeong_shadow_needle", &"heukyeong")
	var near := _enemy_in(f.world, Vector2(100, 0))
	var far := _enemy_in(f.world, Vector2(200, 0))
	f.controller.tick_auto_cast(1.1)
	assert_eq(near.health, 50)
	f.controller.tick_auto_cast(0.75)
	assert_eq(near.health, 44)
	assert_eq(far.health, 50)
	assert_true(f.controller.call("has_selected_mark", near))
	f.controller.tick_auto_cast(0.35)
	f.controller.tick_auto_cast(0.75)
	assert_eq(near.health, 38, "Repeated needle is flat six damage, not a hidden critical or burst.")
	f.loadout.commit_placed_ninjutsu([], [&"heukyeong"])
	assert_false(f.controller.call("has_selected_mark", near))


func test_dart_prioritizes_mark_but_keeps_launch_aim_and_cannot_exceed_lifetime() -> void:
	var f := _selected_fixture(&"heukyeong_shadow_needle", &"heukyeong")
	var marked := _enemy_in(f.world, Vector2(100, 0))
	f.controller.tick_auto_cast(1.1)
	f.controller.tick_auto_cast(0.2)
	marked.position = Vector2(200, 0)
	var near := _enemy_in(f.world, Vector2(0, 30))
	f.loadout.commit_placed_ninjutsu([&"heukyeong_shadow_needle", &"heukyeong_pursuit_dart"], [&"heukyeong"])
	f.controller.tick_auto_cast(2.2)
	marked.position = Vector2(200, 100)
	var along := _enemy_in(f.world, Vector2(150, 0))
	var beyond := _enemy_in(f.world, Vector2(500, 0))
	f.controller.tick_auto_cast(1.0)
	assert_eq(near.health, 50, "The marked launch target takes priority over a nearer unmarked target.")
	assert_eq(marked.health, 44, "Neither projectile follows the target after launch.")
	assert_eq(along.health, 30, "One six-damage needle and one fourteen-damage dart hit the first crossing.")
	assert_eq(beyond.health, 50)


func test_wind_pause_and_unequip_cancel_future_motion() -> void:
	var f := _selected_fixture(&"cheonsul_wind_pillar", &"cheonsul")
	var enemy := _enemy_in(f.world, Vector2(120, 0))
	f.controller.tick_auto_cast(3.0)
	get_tree().paused = true
	f.controller.tick_auto_cast(0.6)
	get_tree().paused = false
	assert_eq(enemy.health, 50)
	f.controller.tick_auto_cast(0.1)
	assert_eq(enemy.health, 50)
	f.loadout.commit_placed_ninjutsu([], [&"cheonsul"])
	f.controller.tick_auto_cast(0.5)
	assert_eq(enemy.health, 50)


func test_selected_mark_expires_during_sword_form_but_freezes_during_pause() -> void:
	var f := _selected_fixture(&"heukyeong_shadow_needle", &"heukyeong")
	var enemy := _enemy_in(f.world, Vector2(100, 0))
	var resolver = load("res://scripts/combat/combat_resolver.gd").new()
	f.world.add_child(resolver)
	f.controller.configure(f.player, f.world, resolver, f.loadout)
	f.controller.tick_auto_cast(1.1)
	f.controller.tick_auto_cast(0.2)
	assert_true(f.controller.has_selected_mark(enemy))
	resolver.sword_only_mode = true
	get_tree().paused = true
	f.controller.tick_auto_cast(20.0)
	get_tree().paused = false
	assert_true(f.controller.has_selected_mark(enemy))
	f.controller.tick_auto_cast(7.99)
	assert_true(f.controller.has_selected_mark(enemy))
	f.controller.tick_auto_cast(0.01)
	assert_false(f.controller.has_selected_mark(enemy))


func test_single_projectile_chooses_first_intersection_not_spawn_order_and_clamps_travel() -> void:
	var f := _selected_fixture(&"heukyeong_pursuit_dart", &"heukyeong")
	var far := _enemy_in(f.world, Vector2(200, 0))
	var near := _enemy_in(f.world, Vector2(100, 0))
	f.controller.tick_auto_cast(2.2)
	f.controller.tick_auto_cast(1.0)
	assert_eq(near.health, 36)
	assert_eq(far.health, 50)
	f.controller.configure(f.player, f.world, null, f.loadout)
	f.controller.tick_auto_cast(2.2)
	near.position = Vector2(100, 100)
	far.position = Vector2(489, 0)
	f.controller.tick_auto_cast(1.0)
	assert_eq(far.health, 50, "Travel480 plus radius8 cannot hit a center at489.")


func test_projectile_damage_callback_sword_form_blocks_other_pending_projectiles() -> void:
	var f := _selected_fixture(&"heukyeong_shadow_needle", &"heukyeong")
	f.loadout.commit_placed_ninjutsu([&"heukyeong_shadow_needle", &"heukyeong_pursuit_dart"], [&"heukyeong"])
	var enemy := _enemy_in(f.world, Vector2(100, 0))
	var resolver = load("res://scripts/combat/combat_resolver.gd").new()
	f.world.add_child(resolver)
	resolver.damage_finished.connect(func(_id, _damage): resolver.sword_only_mode = true)
	f.controller.configure(f.player, f.world, resolver, f.loadout)
	f.controller.tick_auto_cast(2.2)
	f.controller.tick_auto_cast(0.5)
	assert_eq(enemy.health, 44, "The first damage callback changed the combat mode; the second projectile cannot hit.")


func test_wind_uses_injutsu_damage_and_cannot_reenter_or_hit_foreign_world() -> void:
	var f := _selected_fixture(&"cheonsul_wind_pillar", &"cheonsul")
	var enemy := _enemy_in(f.world, Vector2(120, 0))
	var foreign := _enemy_in(self, Vector2(100, 0))
	var resolver = load("res://scripts/combat/combat_resolver.gd").new()
	f.world.add_child(resolver)
	var kinds: Array = []
	resolver.damage_started.connect(func(_id, _target, kind):
		kinds.append(kind)
		f.controller.tick_auto_cast(3.0)
	)
	f.controller.configure(f.player, f.world, resolver, f.loadout)
	f.controller.tick_auto_cast(3.0)
	f.controller.tick_auto_cast(0.6)
	assert_eq(enemy.health, 36)
	assert_eq(foreign.health, 50)
	assert_eq(kinds, [&"direct_injutsu"])


func test_selected_ring_ticks_at_fixed_cast_position_and_stops_after_two_hits() -> void:
	var f := _selected_fixture(&"guiin_asura_ring")
	var enemy := _enemy_in(f.world, Vector2(110, 0))
	f.controller.tick_auto_cast(5.0)
	assert_eq(enemy.health, 42)
	f.player.position = Vector2(500, 0)
	f.controller.tick_auto_cast(0.49)
	assert_eq(enemy.health, 42)
	f.controller.tick_auto_cast(0.01)
	assert_eq(enemy.health, 34)
	f.controller.tick_auto_cast(0.5)
	assert_eq(enemy.health, 34)


func test_selected_kicks_keep_cast_direction_and_exact_three_ticks() -> void:
	var f := _selected_fixture(&"guiin_rakshasa_kicks")
	var front := _enemy_in(f.world, Vector2(80, 0))
	var back := _enemy_in(f.world, Vector2(-90, 0))
	f.controller.tick_auto_cast(2.5)
	assert_eq(front.health, 45)
	assert_eq(back.health, 50)
	f.player.position = Vector2(400, 400)
	f.controller.tick_auto_cast(0.12)
	assert_eq(front.health, 40)
	f.controller.tick_auto_cast(0.12)
	assert_eq(front.health, 35)
	f.controller.tick_auto_cast(0.12)
	assert_eq(front.health, 35)
	assert_eq(back.health, 50)


func test_selected_line_hits_once_and_accepts_late_entry_without_moving_player() -> void:
	var f := _selected_fixture(&"guiin_afterimage_charge")
	var front := _enemy_in(f.world, Vector2(90, 0))
	var later := _enemy_in(f.world, Vector2(180, 40))
	var behind := _enemy_in(f.world, Vector2(-140, 0))
	f.controller.tick_auto_cast(3.0)
	assert_eq(front.health, 34)
	assert_eq(later.health, 50)
	assert_eq(f.player.position, Vector2.ZERO)
	later.position.y = 20
	f.controller.tick_auto_cast(0.1)
	assert_eq(later.health, 34)
	assert_eq(front.health, 34)
	assert_eq(behind.health, 50)
	f.controller.tick_auto_cast(0.25)
	var expired := _enemy_in(f.world, Vector2(200, 0))
	f.controller.tick_auto_cast(0.01)
	assert_eq(expired.health, 50)


func test_unequip_cancels_pending_ring_even_when_re_equipped_before_next_tick() -> void:
	var f := _selected_fixture(&"guiin_asura_ring")
	var enemy := _enemy_in(f.world, Vector2(50, 0))
	f.controller.tick_auto_cast(5.0)
	assert_eq(enemy.health, 42)
	f.loadout.commit_placed_ninjutsu([], [&"guiin"])
	var visual_count := 0
	for child in f.world.get_children():
		if child is Sprite2D and not child.is_queued_for_deletion():
			visual_count += 1
	assert_eq(visual_count, 0, "Book removal cleans presentation as well as damage.")
	f.loadout.commit_placed_ninjutsu([&"guiin_asura_ring"], [&"guiin"])
	f.controller.tick_auto_cast(0.5)
	assert_eq(enemy.health, 42)


func test_selected_attacks_pause_and_sword_form_cancels_pending_hits() -> void:
	var f := _selected_fixture(&"guiin_rakshasa_kicks")
	var enemy := _enemy_in(f.world, Vector2(50, 0))
	var resolver = load("res://scripts/combat/combat_resolver.gd").new()
	f.world.add_child(resolver)
	f.controller.configure(f.player, f.world, resolver, f.loadout)
	f.controller.tick_auto_cast(2.5)
	assert_eq(enemy.health, 45)
	get_tree().paused = true
	f.controller.tick_auto_cast(10.0)
	get_tree().paused = false
	assert_eq(enemy.health, 45)
	resolver.sword_only_mode = true
	f.controller.tick_auto_cast(0.12)
	resolver.sword_only_mode = false
	f.controller.tick_auto_cast(0.12)
	assert_eq(enemy.health, 45)


func test_reconfigure_clears_old_casts_and_starts_full_stage_period() -> void:
	var f := _selected_fixture(&"guiin_asura_ring")
	var enemy := _enemy_in(f.world, Vector2(50, 0))
	f.controller.tick_auto_cast(5.0)
	assert_eq(enemy.health, 42)
	f.controller.configure(f.player, f.world, null, f.loadout)
	f.controller.tick_auto_cast(0.5)
	assert_eq(enemy.health, 42)
	f.controller.tick_auto_cast(4.5)
	assert_eq(enemy.health, 34)


func test_selected_cast_does_not_damage_other_world_or_reenter_on_damage_callback() -> void:
	var f := _selected_fixture(&"guiin_asura_ring")
	var enemy := _enemy_in(f.world, Vector2(50, 0))
	var foreign := _enemy_in(self, Vector2(40, 0))
	var resolver = load("res://scripts/combat/combat_resolver.gd").new()
	f.world.add_child(resolver)
	resolver.damage_started.connect(func(_id, _target, _kind): f.controller.tick_auto_cast(5.0))
	f.controller.configure(f.player, f.world, resolver, f.loadout)
	f.controller.tick_auto_cast(5.0)
	assert_eq(enemy.health, 42)
	assert_eq(foreign.health, 50)


func test_callback_clear_cancels_remaining_targets_and_later_ticks() -> void:
	var f := _selected_fixture(&"guiin_asura_ring")
	var first := _enemy_in(f.world, Vector2(50, 0))
	var second := _enemy_in(f.world, Vector2(60, 0))
	var resolver = load("res://scripts/combat/combat_resolver.gd").new()
	f.world.add_child(resolver)
	resolver.damage_finished.connect(func(_id, _damage): f.controller.clear_runtime_effects())
	f.controller.configure(f.player, f.world, resolver, f.loadout)
	f.controller.tick_auto_cast(5.0)
	assert_eq(first.health, 42)
	assert_eq(second.health, 50)
	var remaining_visuals := 0
	for child in f.world.get_children():
		if child is Sprite2D and not child.is_queued_for_deletion():
			remaining_visuals += 1
	assert_eq(remaining_visuals, 0, "A cancelled cast must not recreate its visual after the damage callback.")
	f.controller.tick_auto_cast(0.5)
	assert_eq(first.health, 42)
	assert_eq(second.health, 50)


func test_starter_is_not_duplicated_but_committed_scroll_auto_casts() -> void:
	assert_true(ResourceLoader.exists(AUTO_CONTROLLER_PATH), "확정 인법서 자동 시전기가 필요합니다.")
	if not ResourceLoader.exists(AUTO_CONTROLLER_PATH):
		return
	var player := Node2D.new()
	add_child_autofree(player)
	var enemy := DummyEnemy.new()
	add_child_autofree(enemy)
	enemy.global_position = Vector2(96.0, 0.0)
	enemy.add_to_group("enemies")

	var loadout = LOADOUT_SCRIPT.new()
	add_child_autofree(loadout)
	assert_true(loadout.activate_starter(&"cheonsul"))

	var controller = load(AUTO_CONTROLLER_PATH).new()
	add_child_autofree(controller)
	assert_true(controller.configure(player, self, null, loadout))
	controller.tick_auto_cast(2.0)
	assert_eq(enemy.health, 50, "시작 인법은 기존 유파 런타임이 처리하므로 별도 시전기가 중복 공격하면 안 됩니다.")

	assert_true(loadout.stage_scroll(&"cheonsul", &"elite_scroll"))
	assert_true(loadout.commit_pending())
	controller.tick_auto_cast(1.0)
	assert_lt(enemy.health, 50, "확정된 엘리트 인법서는 수동 입력 없이 자동으로 전장에 적용돼야 합니다.")
	controller.clear_runtime_effects()
	await get_tree().process_frame
