# 네 유파 공통 전장과 작업대 입력이 Main에 연결되는지를 검증한다.
extends GutTest

const MAIN_SCENE := preload("res://scenes/main/main_scene.tscn")
const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]
const EXPECTED_FIRST_CORE_IDS := {
	&"bongma": &"seal_chaser",
	&"cheonsul": &"fire_mark_caster",
	&"guiin": &"surge_fighter",
	&"heukyeong": &"shuriken_scout",
}
const RETRY_WALLET_PATH := "user://gut_school_circuit_retry_wallet.json"


func before_each() -> void:
	_remove_retry_wallet_storage()


func after_each() -> void:
	_remove_retry_wallet_storage()


func test_each_school_selection_starts_the_same_circuit_runtime_with_its_own_encounter_identity() -> void:
	for school_id in SCHOOL_IDS:
		var main: Node = _new_main()
		if main == null:
			continue
		main._on_school_selected(school_id)
		assert_not_null(main.school_circuit, "%s must use the shared circuit runtime" % school_id)
		if main.school_circuit == null:
			continue
		assert_eq(main.school_circuit.route_state.active_school_id(), school_id)
		assert_eq(main.get_node("RunBuildState").selected_school_id, school_id)
		assert_eq(
			(main.get_node("HUD/CombatTopBar/Row/StagePhaseLabel") as Label).text,
			"스테이지 · %s 전장 · 페이즈 1 · Core 압박" % main.school_host.selected_school_name,
		)
		var core_enemy = _first_live_normal_enemy(main)
		assert_not_null(core_enemy)
		if core_enemy != null:
			assert_eq(core_enemy.get_meta(&"school_circuit_encounter_id", &""), EXPECTED_FIRST_CORE_IDS[school_id])



func test_circuit_phase_changes_render_public_phase_without_mutating_route_depth() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"cheonsul")
	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	var route_depth: int = int(circuit.route_state.stage_index())

	main._on_school_circuit_phase_changed(&"boss_active")

	assert_eq(
		(main.get_node("HUD/CombatTopBar/Row/StagePhaseLabel") as Label).text,
		"스테이지 · 천술류 전장 · 페이즈 4 · Boss 결전",
	)
	assert_eq(circuit.route_state.stage_index(), route_depth, "Public Phase rendering must not write route depth.")


func test_workbench_ui_intents_delegate_to_the_shared_circuit_without_ui_ownership() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"cheonsul")
	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(circuit.sync_elapsed(180.0))
	var elite = _role_enemy(main, &"elite")
	assert_not_null(elite)
	if elite == null:
		return
	elite.take_damage(99999)
	var trace = main.current_trace_pickup
	assert_not_null(trace)
	if trace == null:
		return
	main.get_node("Player").global_position = trace.global_position
	trace._process(0.35)
	trace._process(0.40)
	assert_true(circuit.sync_elapsed(280.0))
	var boss = _role_enemy(main, &"boss")
	assert_not_null(boss)
	if boss == null:
		return
	boss.take_damage(99999)
	var rest_ui = main.get_node("RestFlowUI")
	assert_true(rest_ui.get_node("Panel/Margin/Content/WorkbenchView").visible)
	assert_true(bool(circuit.workbench_snapshot().get("boss_reward_pending", false)))
	rest_ui.workbench_boss_reward_selected.emit(0)
	assert_false(bool(circuit.workbench_snapshot().get("boss_reward_pending", true)))
	assert_eq((circuit.workbench_snapshot().get("buffer", []) as Array).size(), 1)
	rest_ui.workbench_chest_open_requested.emit()
	assert_eq(int(circuit.workbench_snapshot().get("chest_count", -1)), 0)
	assert_eq((circuit.workbench_snapshot().get("buffer", []) as Array).size(), 3)


func test_workbench_board_move_and_undo_intents_delegate_to_the_shared_circuit() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"cheonsul")
	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(_clear_active_school_to_workbench(main, circuit))
	assert_true(circuit.choose_boss_reward(0))
	assert_true(_place_first_buffer_item(circuit))
	main._render_school_circuit_workbench()
	var before: Dictionary = circuit.workbench_snapshot().get("backpack_board", {})
	var board_items: Array = before.get("items", [])
	assert_eq(board_items.size(), 1)
	if board_items.is_empty():
		return
	var placed: Dictionary = board_items[0]
	var item_id := int(placed.get("instance_id", 0))
	var source_origin := Vector2i(placed.get("origin", Vector2i.ZERO))
	var move := _first_legal_item_move(circuit, item_id, source_origin)
	assert_false(move.is_empty())
	if move.is_empty():
		return
	var rest_ui = main.get_node("RestFlowUI")
	assert_true(rest_ui.get_node("Panel/Margin/Content/WorkbenchView/BoardGrid").get_child_count() == 36)
	rest_ui.workbench_existing_item_move_requested.emit(item_id, move.get("origin"), int(move.get("rotation", 0)))
	var moved = circuit._backpack_session.state.get_item(item_id)
	assert_eq(moved.origin, move.get("origin"))
	assert_eq(moved.rotation_quarters, int(move.get("rotation", 0)))
	rest_ui.workbench_undo_requested.emit()
	var undone = circuit._backpack_session.state.get_item(item_id)
	assert_eq(undone.origin, source_origin)


func test_workbench_combination_intents_delegate_through_main_without_ui_state_ownership() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"cheonsul")
	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(_clear_active_school_to_workbench(main, circuit))
	var session = circuit._backpack_session
	assert_gt(session._state.add_item(&"water_style", Vector2i(1, 1)), 0)
	assert_gt(session._state.add_item(&"stealth_art", Vector2i(2, 1)), 0)
	main._render_school_circuit_workbench()
	var rest_ui = main.get_node("RestFlowUI")
	var choices: Container = rest_ui.get_node("Panel/Margin/Content/WorkbenchView/CombinationChoices")
	assert_eq(choices.get_child_count(), 1)
	if choices.get_child_count() != 1:
		return
	choices.get_child(0).emit_signal("pressed")
	await get_tree().process_frame
	assert_true(bool(circuit.workbench_snapshot().get("combination_pending", false)))
	var board: GridContainer = rest_ui.get_node("Panel/Margin/Content/WorkbenchView/BoardGrid")
	board.get_child(7).emit_signal("pressed")
	await get_tree().process_frame
	assert_false(bool(circuit.workbench_snapshot().get("combination_pending", true)))
	var board_items: Array = circuit.workbench_snapshot().get("backpack_board", {}).get("items", [])
	assert_eq(board_items.size(), 1)
	assert_eq((board_items[0] as Dictionary).get("definition_id"), &"water_mist")


func test_checkpoint_retry_spends_one_soul_once_and_restores_the_next_school_baseline() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"cheonsul")
	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(_clear_active_school_to_workbench(main, circuit))
	assert_true(circuit.choose_boss_reward(0))
	assert_true(circuit.open_chest())
	assert_true(_place_every_buffer_item(circuit))
	var fate_id: StringName = circuit.workbench_snapshot().get("fate_candidate_ids", [])[0]
	assert_true(circuit.choose_fate(fate_id))
	assert_true(circuit.choose_next_route(&"bongma"))
	main.get_node("RestFlowUI").workbench_commit_requested.emit()
	assert_eq(circuit.route_state.active_school_id(), &"bongma")
	assert_true(main.run_checkpoint.is_valid())
	var checkpoint_gold := int(main.get_node("RunBuildState").gold)
	assert_true(main.ninja_soul_wallet.configure(RETRY_WALLET_PATH, 1))
	main.get_node("RunBuildState").grant_gold(9)
	main.get_node("Player").take_damage(99999)
	assert_true(main.game_over)
	assert_true(main.get_node("HUD/GameOverPanel/RetryButton").visible)
	main.get_node("HUD").retry_requested.emit()
	assert_false(main.game_over)
	assert_eq(main.ninja_soul_wallet.balance(), 0)
	assert_eq(main.get_node("RunBuildState").gold, checkpoint_gold)
	assert_eq(circuit.route_state.active_school_id(), &"bongma")
	assert_eq(circuit.get_snapshot().get("elapsed_seconds"), 0.0)
	assert_false(main.get_node("HUD/GameOverPanel").visible)
	main.get_node("Player").take_damage(99999)
	assert_true(main.game_over)
	assert_false(main.get_node("HUD/GameOverPanel/RetryButton").visible, "A Run must not offer a second paid retry.")


func test_invalid_checkpoint_never_debits_a_soul_or_consumes_the_retry() -> void:
	var main: Node = _new_main()
	if main == null:
		return
	main._on_school_selected(&"cheonsul")
	var circuit = main.school_circuit
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(_clear_active_school_to_workbench(main, circuit))
	assert_true(circuit.choose_boss_reward(0))
	assert_true(circuit.open_chest())
	assert_true(_place_every_buffer_item(circuit))
	var fate_id: StringName = circuit.workbench_snapshot().get("fate_candidate_ids", [])[0]
	assert_true(circuit.choose_fate(fate_id))
	assert_true(circuit.choose_next_route(&"bongma"))
	main.get_node("RestFlowUI").workbench_commit_requested.emit()
	assert_true(main.run_checkpoint.is_valid())
	assert_true(main.ninja_soul_wallet.configure(RETRY_WALLET_PATH, 1))
	main.run_checkpoint._snapshot["build"] = {}
	main.get_node("Player").take_damage(99999)
	assert_true(main.game_over)
	main.get_node("HUD").retry_requested.emit()
	assert_true(main.game_over)
	assert_eq(main.ninja_soul_wallet.balance(), 1)
	assert_true(main.run_checkpoint.can_retry_school(&"bongma"))


func _new_main():
	var main = MAIN_SCENE.instantiate()
	add_child_autofree(main)
	return main


func _first_live_normal_enemy(main: Node):
	for child in main.get_children():
		if child.is_in_group("enemies") and not child.is_queued_for_deletion():
			return child
	return null


func _role_enemy(main: Node, role: StringName):
	for child in main.get_children():
		if child.get_meta(&"school_circuit_role", &"") == role and not child.is_queued_for_deletion():
			return child
	return null


func _clear_active_school_to_workbench(main: Node, circuit) -> bool:
	if not circuit.sync_elapsed(180.0):
		return false
	var elite = _role_enemy(main, &"elite")
	if elite == null:
		return false
	elite.take_damage(99999)
	var trace = main.current_trace_pickup
	if trace == null:
		return false
	main.get_node("Player").global_position = trace.global_position
	trace._process(0.35)
	trace._process(0.40)
	if not circuit.sync_elapsed(280.0):
		return false
	var boss = _role_enemy(main, &"boss")
	if boss == null:
		return false
	boss.take_damage(99999)
	return circuit.get_snapshot().get("state") == &"cleared"


func _place_every_buffer_item(circuit) -> bool:
	_expand_fixture_board(circuit)
	while not (circuit.workbench_snapshot().get("buffer", []) as Array).is_empty():
		var placed := false
		for rotation in range(4):
			for y in range(6):
				for x in range(6):
					if circuit.place_buffer_item(0, Vector2i(x, y), rotation):
						placed = true
						break
				if placed:
					break
			if placed:
				break
		if not placed:
			return false
	return true


func _expand_fixture_board(circuit) -> void:
	var state = circuit._backpack_session._state
	if state.bags.size() != 1:
		return
	assert_gt(state.add_bag(&"small_pouch", Vector2i(0, 0)), 0)
	assert_gt(state.add_bag(&"small_pouch", Vector2i(3, 4)), 0)
	assert_gt(state.add_bag(&"long_pouch", Vector2i(0, 4)), 0)


func _place_first_buffer_item(circuit) -> bool:
	for rotation in range(4):
		for y in range(6):
			for x in range(6):
				if circuit.place_buffer_item(0, Vector2i(x, y), rotation):
					return true
	return false


func _first_legal_item_move(circuit, item_id: int, source_origin: Vector2i) -> Dictionary:
	for rotation in range(4):
		for y in range(6):
			for x in range(6):
				var origin := Vector2i(x, y)
				if origin == source_origin and rotation == 0:
					continue
				var preview = circuit._backpack_session.preview_item(item_id, origin, rotation)
				if preview != null and preview.valid:
					return {"origin": origin, "rotation": rotation}
	return {}


func _remove_retry_wallet_storage() -> void:
	if FileAccess.file_exists(RETRY_WALLET_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RETRY_WALLET_PATH))
