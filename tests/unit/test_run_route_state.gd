extends GutTest

const ROUTE_STATE_PATH := "res://scripts/core/run_route_state.gd"
const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]


func test_t08_resource_exists() -> void:
	assert_true(ResourceLoader.exists(ROUTE_STATE_PATH), "Missing T08 RunRouteState")


func test_initial_state_has_four_unvisited_schools_and_stage_one() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_eq(state.school_ids(), SCHOOL_IDS)
	assert_eq(state.get_unvisited_schools(), SCHOOL_IDS)
	assert_eq(state.provisional_school_id(), &"")
	assert_eq(state.active_school_id(), &"")
	assert_eq(state.cleared_school_ids(), [])
	assert_eq(state.clear_order(), [])
	assert_eq(state.stage_index(), 1)
	assert_false(state.is_final_binding_eligible())


func test_provisional_route_can_change_before_commit_without_clearing_any_school() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_true(state.set_provisional_next_school(&"bongma"))
	assert_eq(state.provisional_school_id(), &"bongma")
	assert_true(state.set_provisional_next_school(&"cheonsul"))
	assert_eq(state.provisional_school_id(), &"cheonsul")
	assert_eq(state.active_school_id(), &"")
	assert_eq(state.cleared_school_ids(), [])
	assert_eq(state.stage_index(), 1)


func test_failed_provisional_selection_is_atomic() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_true(state.set_provisional_next_school(&"guiin"))
	var before: Dictionary = state.get_route_snapshot()
	assert_false(state.set_provisional_next_school(&"missing"))
	assert_eq(state.get_route_snapshot(), before)


func test_commit_provisional_route_sets_active_school_without_advancing_stage() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_false(state.commit_provisional_next_school())
	assert_true(state.set_provisional_next_school(&"heukyeong"))
	assert_true(state.commit_provisional_next_school())
	assert_eq(state.provisional_school_id(), &"")
	assert_eq(state.active_school_id(), &"heukyeong")
	assert_eq(state.stage_index(), 1)
	assert_eq(state.get_unvisited_schools(), SCHOOL_IDS)
	assert_false(state.set_provisional_next_school(&"bongma"), "A second route cannot be provisioned while a battlefield is active")


func test_clearing_active_school_updates_unvisited_order_and_stage_independently_from_identity() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_true(_commit_and_clear(state, &"heukyeong"))
	assert_eq(state.clear_order(), [&"heukyeong"])
	assert_eq(state.cleared_school_ids(), [&"heukyeong"])
	assert_eq(state.get_unvisited_schools(), [&"bongma", &"cheonsul", &"guiin"])
	assert_eq(state.stage_index(), 2)
	assert_eq(state.active_school_id(), &"")
	assert_false(state.is_final_binding_eligible())

	assert_true(_commit_and_clear(state, &"bongma"))
	assert_eq(state.clear_order(), [&"heukyeong", &"bongma"])
	assert_eq(state.stage_index(), 3)


func test_revisit_is_rejected_without_mutating_current_provisional_choice() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_true(_commit_and_clear(state, &"bongma"))
	assert_true(state.set_provisional_next_school(&"cheonsul"))
	var before: Dictionary = state.get_route_snapshot()
	assert_false(state.set_provisional_next_school(&"bongma"))
	assert_eq(state.get_route_snapshot(), before)
	assert_false(state.is_school_unvisited(&"bongma"))
	assert_true(state.is_school_cleared(&"bongma"))


func test_clear_requires_active_committed_route_and_cannot_repeat() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_false(state.mark_active_school_cleared())
	assert_true(state.set_provisional_next_school(&"guiin"))
	assert_false(state.mark_active_school_cleared(), "Provisional selection is not a committed battlefield")
	assert_true(state.commit_provisional_next_school())
	assert_true(state.mark_active_school_cleared())
	var after_clear: Dictionary = state.get_route_snapshot()
	assert_false(state.mark_active_school_cleared())
	assert_eq(state.get_route_snapshot(), after_clear)


func test_fourth_unique_clear_enters_final_binding_without_stage_five() -> void:
	var state = _new_state()
	if state == null:
		return
	for school_id in SCHOOL_IDS:
		assert_true(_commit_and_clear(state, school_id))
	assert_eq(state.clear_order(), SCHOOL_IDS)
	assert_true(state.get_unvisited_schools().is_empty())
	assert_true(state.is_final_binding_eligible())
	assert_eq(state.stage_index(), 4, "There is no Stage 5 after the fourth school clear")
	assert_false(state.set_provisional_next_school(&"bongma"))
	assert_false(state.commit_provisional_next_school())


func test_all_twenty_four_school_orders_are_legal_and_preserve_exact_clear_order() -> void:
	var orders: Array = _permutations(SCHOOL_IDS)
	assert_eq(orders.size(), 24)
	for order in orders:
		var state = _new_state()
		if state == null:
			return
		for school_id in order:
			assert_true(_commit_and_clear(state, StringName(school_id)), "Legal order rejected: %s" % [order])
		assert_eq(state.clear_order(), order, "Clear order must preserve player choice")
		assert_true(state.is_final_binding_eligible())
		assert_eq(state.stage_index(), 4)


func test_public_snapshots_are_defensive_and_cannot_reopen_cleared_school() -> void:
	var state = _new_state()
	if state == null:
		return
	assert_true(_commit_and_clear(state, &"cheonsul"))
	var unvisited: Array[StringName] = state.get_unvisited_schools()
	var cleared: Array[StringName] = state.cleared_school_ids()
	var order: Array[StringName] = state.clear_order()
	var snapshot: Dictionary = state.get_route_snapshot()
	unvisited.clear()
	cleared.clear()
	order.append(&"bongma")
	snapshot["clear_order"].clear()
	snapshot["stage_index"] = 99
	assert_eq(state.get_unvisited_schools(), [&"bongma", &"guiin", &"heukyeong"])
	assert_eq(state.cleared_school_ids(), [&"cheonsul"])
	assert_eq(state.clear_order(), [&"cheonsul"])
	assert_eq(state.stage_index(), 2)
	assert_false(state.set_provisional_next_school(&"cheonsul"))


func _new_state():
	if not ResourceLoader.exists(ROUTE_STATE_PATH):
		assert_true(false, "T08 RunRouteState must exist before behavior tests")
		return null
	return load(ROUTE_STATE_PATH).new()


func _commit_and_clear(state, school_id: StringName) -> bool:
	if not state.set_provisional_next_school(school_id):
		return false
	if not state.commit_provisional_next_school():
		return false
	return state.mark_active_school_cleared()


func _permutations(values: Array[StringName]) -> Array:
	var result: Array = []
	_permute_into([], values.duplicate(), result)
	return result


func _permute_into(prefix: Array, remaining: Array[StringName], result: Array) -> void:
	if remaining.is_empty():
		result.append(prefix.duplicate())
		return
	for index in range(remaining.size()):
		var next_prefix: Array = prefix.duplicate()
		next_prefix.append(remaining[index])
		var next_remaining: Array[StringName] = remaining.duplicate()
		next_remaining.remove_at(index)
		_permute_into(next_prefix, next_remaining, result)
