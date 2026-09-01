# 시작 10마리 Core가 동시에 겹쳐도 첫 접촉 피해가 한 물리 프레임에 몰리지 않도록 실제 Main 전투를 검증한다.
extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")
const NORMAL_ENEMY_META := &"ninja_wave_spawner_normal"
const OPENING_WINDOW_PHYSICS_FRAMES := 90
const MAX_DAMAGE_EVENTS_PER_PHYSICS_FRAME := 2


func test_opening_horde_spreads_resolved_damage_across_physics_frames() -> void:
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	main._on_school_selected(&"bongma")
	await get_tree().process_frame

	var player = main.get_node("Player") as PlayerController
	var opening_cores := _opening_core_enemies(main)
	assert_eq(opening_cores.size(), 10, "The Stage must begin with its required 10-Core horde before contact staggering is measured.")
	if opening_cores.size() != 10:
		return
	for enemy in opening_cores:
		enemy.global_position = player.global_position

	var resolved_damage_counts: Dictionary = {}
	player.damage_resolved.connect(func(_requested: int, resolved: int, _prevented: int, _evaded: bool) -> void:
		if resolved <= 0:
			return
		var frame := Engine.get_physics_frames()
		resolved_damage_counts[frame] = int(resolved_damage_counts.get(frame, 0)) + 1
	)

	for _frame in range(OPENING_WINDOW_PHYSICS_FRAMES):
		await get_tree().physics_frame

	assert_lte(
		_max_resolved_damage_events_in_one_frame(resolved_damage_counts),
		MAX_DAMAGE_EVENTS_PER_PHYSICS_FRAME,
		"Opening Core pressure must leave a readable dodge window instead of stacking most of the horde's first attacks in one physics frame.",
	)
	assert_gt(_total_resolved_damage_events(resolved_damage_counts), 0, "The contact-pressure assertion must observe real overlap damage instead of ending before the horde reaches the Ninja.")


func _max_resolved_damage_events_in_one_frame(counts: Dictionary) -> int:
	var maximum := 0
	for count in counts.values():
		maximum = maxi(maximum, int(count))
	return maximum


func _total_resolved_damage_events(counts: Dictionary) -> int:
	var total := 0
	for count in counts.values():
		total += int(count)
	return total


func _opening_core_enemies(main: Node) -> Array[EnemyChaser]:
	var enemies: Array[EnemyChaser] = []
	for child in main.get_children():
		if child is EnemyChaser and bool(child.get_meta(NORMAL_ENEMY_META, false)) and not child.is_queued_for_deletion():
			enemies.append(child as EnemyChaser)
	return enemies
