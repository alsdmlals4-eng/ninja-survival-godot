# 네 유파 공통 Circuit 도메인 계약을 검증한다.
extends GutTest

const CONTROLLER_PATH := "res://scripts/core/school_circuit_controller.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MVP4_CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const BUILD_STATE_PATH := "res://scripts/core/run_build_state.gd"
const FATE_CONTROLLER_PATH := "res://scripts/core/fate_controller.gd"
const ECONOMY_POLICY_PATH := "res://resources/run_economy_policy.tres"

const EXPECTED_ENCOUNTERS := {
	&"bongma": {
		"core": [&"seal_chaser", &"shikigami_handler", &"barrier_carrier"],
		"elite": &"mobile_array_caster",
		"boss": &"hundred_demon_array_master",
	},
	&"cheonsul": {
		"core": [&"fire_mark_caster", &"water_vein_caster", &"lightning_chain_caster"],
		"elite": &"five_element_tuner",
		"boss": &"heavenly_change_taoist",
	},
	&"guiin": {
		"core": [&"surge_fighter", &"pressure_monk", &"ghost_blood_chaser"],
		"elite": &"melee_chaos_captain",
		"boss": &"ghost_general",
	},
	&"heukyeong": {
		"core": [&"shuriken_scout", &"poison_shadow_assassin", &"dark_mark_pursuer"],
		"elite": &"shadow_chief",
		"boss": &"night_executioner",
	},
}


func test_school_circuit_controller_resource_exists() -> void:
	assert_true(ResourceLoader.exists(CONTROLLER_PATH), "네 유파 공통 Circuit 조정자가 필요합니다.")


func test_each_school_can_begin_first_route_with_its_own_composition() -> void:
	if not ResourceLoader.exists(CONTROLLER_PATH):
		return
	var controller_script = load(CONTROLLER_PATH)
	assert_not_null(controller_script)
	if controller_script == null:
		return
	for school_id in EXPECTED_ENCOUNTERS.keys():
		var circuit = controller_script.new()
		add_child_autofree(circuit)
		assert_true(circuit.begin_school(school_id), "%s 시작 경로를 열어야 합니다." % school_id)
		assert_eq(circuit.route_state.active_school_id(), school_id)
		var encounter: Dictionary = circuit.get_snapshot().get("encounter", {})
		var expected: Dictionary = EXPECTED_ENCOUNTERS[school_id]
		assert_eq(encounter.get("school_id"), school_id)
		assert_eq(encounter.get("core_monster_ids"), expected.get("core"))
		assert_eq(encounter.get("elite_id"), expected.get("elite"))
		assert_eq(encounter.get("boss_id"), expected.get("boss"))


func test_started_school_accepts_the_encounter_clock() -> void:
	if not ResourceLoader.exists(CONTROLLER_PATH):
		return
	var controller_script = load(CONTROLLER_PATH)
	assert_not_null(controller_script)
	if controller_script == null:
		return
	var circuit = controller_script.new()
	add_child_autofree(circuit)
	assert_true(circuit.begin_school(&"cheonsul"))
	assert_true(circuit.sync_elapsed(165.0), "시작한 학교는 Elite 경고 시점까지 lifecycle을 진행해야 합니다.")
	assert_eq(circuit.get_snapshot().get("state"), &"elite_warning")


func test_invalid_or_second_school_request_is_atomic() -> void:
	if not ResourceLoader.exists(CONTROLLER_PATH):
		return
	var controller_script = load(CONTROLLER_PATH)
	assert_not_null(controller_script)
	if controller_script == null:
		return
	var circuit = controller_script.new()
	add_child_autofree(circuit)
	assert_false(circuit.begin_school(&"unknown"))
	assert_eq(circuit.route_state.active_school_id(), &"")
	assert_true(circuit.begin_school(&"cheonsul"))
	var before: Dictionary = circuit.get_snapshot()
	assert_false(circuit.begin_school(&"bongma"))
	assert_eq(circuit.get_snapshot(), before)


func test_each_school_reaches_its_pending_boss_reward_workbench() -> void:
	if not ResourceLoader.exists(CONTROLLER_PATH):
		return
	for school_id in EXPECTED_ENCOUNTERS.keys():
		var circuit = _new_configured_circuit(school_id)
		assert_not_null(circuit, "%s Circuit workbench configuration이 필요합니다." % school_id)
		if circuit == null:
			continue
		assert_true(circuit.sync_elapsed(180.0))
		assert_true(circuit.mark_elite_defeated())
		assert_true(circuit.recover_trace())
		assert_true(circuit.sync_elapsed(270.0))
		assert_true(bool(circuit.get_snapshot().get("boss_requested", false)))
		assert_true(circuit.mark_boss_defeated())
		assert_eq(circuit.route_state.cleared_school_ids(), [school_id])
		var workbench: Dictionary = circuit.workbench_snapshot()
		assert_true(bool(workbench.get("boss_reward_pending", false)))
		assert_eq((workbench.get("boss_reward_options", []) as Array).size(), 3)
		assert_true((workbench.get("readiness_failures", []) as Array).has(&"boss_reward_pending"))


func test_normal_enemy_reward_is_recorded_through_the_active_school_circuit() -> void:
	var circuit = _new_configured_circuit(&"heukyeong")
	assert_not_null(circuit)
	if circuit == null:
		return
	var build_state = circuit._build_state
	var gold_before: int = int(build_state.gold)
	var granted: int = circuit.record_normal_enemy_defeated()
	assert_true(granted in [0, 1])
	assert_eq(int(build_state.gold), gold_before + granted)
	var receipts: Array = build_state.get_economy_receipts()
	assert_eq(receipts.size(), 1)
	assert_eq(receipts[0], {"source": &"normal", "amount": granted, "school_id": &"heukyeong"})


func test_boss_reward_moves_only_from_pending_choice_to_rest_buffer_then_board() -> void:
	var circuit = _new_configured_circuit(&"cheonsul")
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(circuit.sync_elapsed(180.0))
	assert_true(circuit.mark_elite_defeated())
	assert_true(circuit.recover_trace())
	assert_true(circuit.sync_elapsed(270.0))
	assert_true(circuit.mark_boss_defeated())
	var before: Dictionary = circuit.workbench_snapshot()
	assert_false(circuit.choose_boss_reward(-1))
	assert_eq(circuit.workbench_snapshot(), before, "유효하지 않은 보상 선택은 작업대를 바꾸면 안 됩니다.")
	assert_true(circuit.choose_boss_reward(0))
	var selected: Dictionary = circuit.workbench_snapshot()
	assert_false(bool(selected.get("boss_reward_pending", true)))
	assert_eq((selected.get("buffer", []) as Array).size(), 1)
	assert_false(circuit.choose_boss_reward(1), "보상은 정확히 하나만 버퍼로 들어가야 합니다.")

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
	assert_true(placed, "선택된 보상은 합법적인 6×6 시작 영역에 배치할 수 있어야 합니다.")
	assert_eq((circuit.workbench_snapshot().get("buffer", []) as Array).size(), 0)
	var workbench: Dictionary = circuit.workbench_snapshot()
	var board: Dictionary = workbench.get("backpack_board", {})
	assert_true((board.get("active_cells", []) as Array).has(Vector2i(1, 1)))
	assert_eq((board.get("items", []) as Array).size(), 1)
	assert_true(circuit.undo_workbench_edit())
	assert_eq((circuit.workbench_snapshot().get("buffer", []) as Array).size(), 1)


func test_workbench_combination_is_explicit_and_keeps_domain_transaction_ownership() -> void:
	var circuit = _new_configured_circuit(&"cheonsul")
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(circuit.sync_elapsed(180.0))
	assert_true(circuit.mark_elite_defeated())
	assert_true(circuit.recover_trace())
	assert_true(circuit.sync_elapsed(270.0))
	assert_true(circuit.mark_boss_defeated())
	var session = circuit._backpack_session
	var water_id: int = session._state.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = session._state.add_item(&"stealth_art", Vector2i(2, 1))
	assert_gt(water_id, 0)
	assert_gt(stealth_id, 0)
	var before: Dictionary = circuit.workbench_snapshot()
	var options: Array = before.get("combination_options", [])
	assert_eq(options.size(), 1)
	assert_eq(options[0].get("combo_id"), &"water_mist")
	assert_eq(options[0].get("source_a_instance"), water_id)
	assert_eq(options[0].get("source_b_instance"), stealth_id)
	assert_true(circuit.begin_workbench_combination(0))
	assert_true(bool(circuit.workbench_snapshot().get("combination_pending", false)))
	assert_false(circuit.commit_workbench(), "Pending combination must block atomic Workbench commit.")
	assert_true(circuit.commit_workbench_combination(Vector2i(1, 1)))
	var board: Dictionary = circuit.workbench_snapshot().get("backpack_board", {})
	assert_eq((board.get("items", []) as Array).size(), 1)
	assert_eq((board.get("items", [])[0] as Dictionary).get("definition_id"), &"water_mist")
	assert_false(bool(circuit.workbench_snapshot().get("combination_pending", true)))


func test_workbench_commits_placed_reward_fate_and_next_school_as_one_tuple() -> void:
	var circuit = _new_configured_circuit(&"cheonsul")
	assert_not_null(circuit)
	if circuit == null:
		return
	assert_true(circuit.sync_elapsed(180.0))
	assert_true(circuit.mark_elite_defeated())
	assert_true(circuit.recover_trace())
	assert_true(circuit.sync_elapsed(270.0))
	assert_true(circuit.mark_boss_defeated())
	assert_true(circuit.choose_boss_reward(0))
	assert_true(circuit.open_chest())
	assert_true(_place_every_buffer_item(circuit))
	var fate_id: StringName = circuit.workbench_snapshot().get("fate_candidate_ids", [])[0]
	assert_true(circuit.choose_fate(fate_id))
	assert_true(circuit.choose_next_route(&"bongma"))
	assert_true(circuit.commit_workbench())
	assert_eq(circuit.route_state.active_school_id(), &"bongma")
	assert_true((circuit.get_snapshot().get("selected_fate_ids", []) as Array).has(fate_id))
	assert_true(circuit.begin_school(&"bongma"), "atomic commit 뒤 다음 학교 lifecycle을 열어야 합니다.")
	assert_eq(circuit.get_snapshot().get("encounter", {}).get("school_id"), &"bongma")


func test_deterministic_four_school_machine_circuit_reaches_final_binding_eligibility_in_non_catalog_order() -> void:
	var circuit = _new_configured_circuit(&"heukyeong")
	assert_not_null(circuit)
	if circuit == null:
		return
	var ordered_schools: Array[StringName] = [&"heukyeong", &"bongma", &"guiin", &"cheonsul"]
	for index in range(ordered_schools.size()):
		var school_id := ordered_schools[index]
		if index > 0:
			assert_true(_earn_normal_gold_until(circuit, _highest_purchasable_bag_price(circuit)))
		assert_true(circuit.sync_elapsed(180.0), "%s must reach its Elite gate" % school_id)
		assert_true(circuit.mark_elite_defeated())
		assert_true(circuit.recover_trace())
		assert_true(circuit.sync_elapsed(280.0), "%s must reach its Boss gate after Trace recovery" % school_id)
		assert_true(circuit.mark_boss_defeated())
		assert_true(circuit.route_state.is_school_cleared(school_id))
		if index == ordered_schools.size() - 1:
			break
		assert_true(_choose_smallest_boss_reward(circuit))
		assert_true(circuit.open_chest())
		if index > 0:
			var bag_offer: Dictionary = circuit.workbench_snapshot().get("bag_offer", {})
			assert_false(bag_offer.is_empty())
			assert_gte(int(circuit._build_state.gold), int(bag_offer.get("price", 0)))
			var bag_bought: bool = circuit.buy_shop_bag()
			assert_true(
				bag_bought,
				"Bag buy failed with gold=%d, pending_bag=%s, bought_this_rest=%s, offer=%s" % [
					int(circuit._build_state.gold),
					str(circuit._backpack_session.pending_bag),
					str(circuit._reward_controller._shop._bag_bought_this_rest),
					str(bag_offer),
				]
			)
			assert_true(_place_pending_bag(circuit), "Purchased bag must have at least one legal placement.")
		assert_true(_place_every_buffer_item(circuit), "All pending rewards must fit after the planned bag placement.")
		var fate_id: StringName = circuit.workbench_snapshot().get("fate_candidate_ids", [])[0]
		assert_true(circuit.choose_fate(fate_id))
		assert_true(circuit.choose_next_route(ordered_schools[index + 1]))
		assert_true(circuit.commit_workbench())
		assert_true(circuit.begin_school(ordered_schools[index + 1]))
	assert_eq(circuit.route_state.clear_order(), ordered_schools)
	assert_true(circuit.route_state.is_final_binding_eligible())
	assert_eq(circuit.route_state.get_unvisited_schools(), [])
	assert_false(circuit.commit_workbench(), "Final Binding is outside this package and must not be simulated as another school commit.")


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


func _choose_smallest_boss_reward(circuit) -> bool:
	var options: Array = circuit.workbench_snapshot().get("boss_reward_options", [])
	var best_index := -1
	var best_area := 999
	for index in range(options.size()):
		var definition = circuit._item_defs.get(StringName(options[index]))
		if definition == null:
			continue
		var footprint: Vector2i = definition.footprint_size
		var area := footprint.x * footprint.y
		if area < best_area:
			best_area = area
			best_index = index
	return best_index >= 0 and circuit.choose_boss_reward(best_index)


func _place_pending_bag(circuit) -> bool:
	var session = circuit._backpack_session
	var pending = session.pending_bag
	if pending == null:
		return false
	var best_origin := Vector2i(-1, -1)
	var best_rotation := -1
	var best_score := -1
	for rotation in range(4):
		for y in range(6):
			for x in range(6):
				var score := _pending_bag_placement_score(circuit, pending.definition_id, Vector2i(x, y), rotation)
				if score > best_score:
					best_score = score
					best_origin = Vector2i(x, y)
					best_rotation = rotation
	return best_score >= 0 and circuit.place_pending_bag(best_origin, best_rotation)


func _pending_bag_placement_score(circuit, bag_id: StringName, origin: Vector2i, rotation: int) -> int:
	var session = circuit._backpack_session
	var before_state = session.state
	var before_active: Dictionary = before_state.get_active_cells()
	if before_state.add_bag(bag_id, origin, rotation) <= 0:
		return -1
	var resolution = session._resolver.resolve(before_state, circuit._item_defs, circuit._bag_defs, circuit._active_school_id)
	if not resolution.valid:
		return -1
	var added_cells := 0
	var connected_cells := 0
	for cell in before_state.get_active_cells().keys():
		if before_active.has(cell):
			continue
		added_cells += 1
		for direction in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			if before_active.has(Vector2i(cell) + direction):
				connected_cells += 1
	return connected_cells * 100 + added_cells


func _earn_normal_gold_until(circuit, target_gold: int) -> bool:
	if target_gold <= 0:
		return true
	for _attempt in range(1000):
		if int(circuit._build_state.gold) >= target_gold:
			return true
		circuit.record_normal_enemy_defeated()
	return int(circuit._build_state.gold) >= target_gold


func _highest_purchasable_bag_price(circuit) -> int:
	var highest := 0
	for definition in circuit._bag_defs.values():
		highest = maxi(highest, int(definition.base_price))
	return highest


func _new_configured_circuit(school_id: StringName):
	var controller_script = load(CONTROLLER_PATH)
	var mvp3_catalog = load(MVP3_CATALOG_PATH)
	var mvp4_catalog = load(MVP4_CATALOG_PATH)
	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	var economy_rng := RandomNumberGenerator.new()
	economy_rng.seed = 8128 + EXPECTED_ENCOUNTERS.keys().find(school_id)
	build_state.configure(mvp4_catalog.build_items(), mvp3_catalog.build_fates(), load(ECONOMY_POLICY_PATH), economy_rng)
	var fate_controller = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(fate_controller)
	var rng := RandomNumberGenerator.new()
	rng.seed = 406 + EXPECTED_ENCOUNTERS.keys().find(school_id)
	fate_controller.configure(build_state, mvp3_catalog.build_fates(), rng)
	var circuit = controller_script.new()
	add_child_autofree(circuit)
	if not circuit.configure_workbench(build_state, fate_controller, mvp4_catalog.build_items(), mvp4_catalog.build_bags(), rng):
		return null
	if not circuit.begin_school(school_id):
		return null
	return circuit
