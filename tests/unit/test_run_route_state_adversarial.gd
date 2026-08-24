extends GutTest

const ROUTE_STATE_PATH := "res://scripts/core/run_route_state.gd"
const SCHOOL_IDS: Array[StringName] = [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]


func test_failed_operations_are_total_noops_across_initial_provisional_active_and_final_states() -> void:
	var state = _new_state()
	var initial := state.get_route_snapshot()
	assert_false(state.set_provisional_next_school(&"missing"))
	assert_false(state.commit_provisional_next_school())
	assert_false(state.mark_active_school_cleared())
	assert_eq(state.get_route_snapshot(), initial)

	assert_true(state.set_provisional_next_school(&"bongma"))
	var provisional := state.get_route_snapshot()
	assert_false(state.set_provisional_next_school(&"missing"))
	assert_false(state.mark_active_school_cleared())
	assert_eq(state.get_route_snapshot(), provisional)

	assert_true(state.commit_provisional_next_school())
	var active := state.get_route_snapshot()
	assert_false(state.set_provisional_next_school(&"cheonsul"))
	assert_false(state.commit_provisional_next_school())
	assert_eq(state.get_route_snapshot(), active)

	assert_true(state.mark_active_school_cleared())
	for school_id in [&"cheonsul", &"guiin", &"heukyeong"]:
		assert_true(_commit_and_clear(state, school_id))
	var final := state.get_route_snapshot()
	assert_false(state.set_provisional_next_school(&"bongma"))
	assert_false(state.commit_provisional_next_school())
	assert_false(state.mark_active_school_cleared())
	assert_eq(state.get_route_snapshot(), final)


func test_provisional_replacement_commits_only_latest_choice() -> void:
	var state = _new_state()
	assert_true(state.set_provisional_next_school(&"bongma"))
	assert_true(state.set_provisional_next_school(&"guiin"))
	assert_eq(state.provisional_school_id(), &"guiin")
	assert_true(state.commit_provisional_next_school())
	assert_eq(state.active_school_id(), &"guiin")
	assert_true(state.mark_active_school_cleared())
	assert_eq(state.clear_order(), [&"guiin"])
	assert_true(state.is_school_unvisited(&"bongma"))
	assert_false(state.is_school_cleared(&"bongma"))


func test_all_twenty_four_orders_preserve_prefix_invariants() -> void:
	var orders: Array = _permutations(SCHOOL_IDS)
	assert_eq(orders.size(), 24)
	for order in orders:
		var state = _new_state()
		for index in range(order.size()):
			var school_id := StringName(order[index])
			assert_true(_commit_and_clear(state, school_id), "Rejected legal prefix %s @ %d" % [order, index])
			var expected_prefix: Array = order.slice(0, index + 1)
			assert_eq(state.clear_order(), expected_prefix)
			assert_eq(state.cleared_school_ids(), expected_prefix)
			assert_eq(state.get_unvisited_schools().size(), 4 - (index + 1))
			assert_eq(_unique_count(state.clear_order()), index + 1)
			assert_eq(state.provisional_school_id(), &"")
			assert_eq(state.active_school_id(), &"")
			assert_eq(state.stage_index(), mini(index + 2, 4))
			assert_eq(state.is_final_binding_eligible(), index == 3)


func test_final_binding_is_terminal_and_stage_never_exceeds_four() -> void:
	var state = _new_state()
	for school_id in [&"heukyeong", &"guiin", &"cheonsul", &"bongma"]:
		assert_true(_commit_and_clear(state, school_id))
	var final := state.get_route_snapshot()
	for school_id in SCHOOL_IDS:
		assert_false(state.set_provisional_next_school(school_id))
	assert_false(state.commit_provisional_next_school())
	assert_false(state.mark_active_school_cleared())
	assert_eq(state.stage_index(), 4)
	assert_true(state.is_final_binding_eligible())
	assert_eq(state.get_route_snapshot(), final)


func test_public_route_views_never_expose_live_clear_order_authority() -> void:
	var state = _new_state()
	assert_true(_commit_and_clear(state, &"bongma"))
	var school_ids := state.school_ids()
	var unvisited := state.get_unvisited_schools()
	var cleared := state.cleared_school_ids()
	var order := state.clear_order()
	var snapshot := state.get_route_snapshot()

	school_ids.clear()
	unvisited.append(&"bongma")
	cleared.clear()
	order.append(&"missing")
	snapshot["school_ids"].clear()
	snapshot["unvisited_school_ids"].clear()
	snapshot["cleared_school_ids"].clear()
	snapshot["clear_order"].append(&"missing")
	snapshot["stage_index"] = 99
	snapshot["final_binding_eligible"] = true

	assert_eq(state.school_ids(), SCHOOL_IDS)
	assert_eq(state.get_unvisited_schools(), [&"cheonsul", &"guiin", &"heukyeong"])
	assert_eq(state.cleared_school_ids(), [&"bongma"])
	assert_eq(state.clear_order(), [&"bongma"])
	assert_eq(state.stage_index(), 2)
	assert_false(state.is_final_binding_eligible())


func test_route_state_exposes_no_generic_force_restore_or_direct_stage_mutation_api() -> void:
	var state = _new_state()
	for method_name in [
		&"set_stage_index",
		&"set_clear_order",
		&"restore_route_snapshot",
		&"force_clear_school",
		&"mark_school_cleared",
		&"set_final_binding_eligible",
	]:
		assert_false(state.has_method(method_name), "Route authority bypass must not be public: %s" % method_name)


func test_every_reported_route_identity_is_from_canonical_four_school_set() -> void:
	var state = _new_state()
	for school_id in [&"guiin", &"bongma"]:
		assert_true(_commit_and_clear(state, school_id))
	assert_true(state.set_provisional_next_school(&"heukyeong"))
	var snapshot := state.get_route_snapshot()
	for school_id in snapshot["school_ids"]:
		assert_true(SCHOOL_IDS.has(school_id))
	for school_id in snapshot["unvisited_school_ids"]:
		assert_true(SCHOOL_IDS.has(school_id))
	for school_id in snapshot["cleared_school_ids"]:
		assert_true(SCHOOL_IDS.has(school_id))
	for school_id in snapshot["clear_order"]:
		assert_true(SCHOOL_IDS.has(school_id))
	assert_true(SCHOOL_IDS.has(snapshot["provisional_school_id"]))
	assert_eq(snapshot["active_school_id"], &"")


func _new_state():
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


func _unique_count(values: Array) -> int:
	var seen := {}
	for value in values:
		seen[value] = true
	return seen.size()
