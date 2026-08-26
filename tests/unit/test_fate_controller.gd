extends GutTest

const FATE_CONTROLLER_PATH := "res://scripts/core/fate_controller.gd"
const STATE_PATH := "res://scripts/core/run_build_state.gd"
const CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"


func test_fate_controller_resource_exists() -> void:
	assert_true(ResourceLoader.exists(FATE_CONTROLLER_PATH), "Missing MVP-3 fate controller")


func test_begin_rest_offers_three_unique_unselected_fates() -> void:
	var fixture := _new_fixture(31)
	if fixture.is_empty():
		return
	var state = fixture.state
	var fate = fixture.fate
	assert_true(state.select_fate(&"slaughter_path"))
	fate.begin_rest()
	assert_eq(fate.candidate_ids.size(), 3)
	assert_eq(_unique_count(fate.candidate_ids), 3)
	assert_false(fate.candidate_ids.has(&"slaughter_path"))
	assert_eq(fate.selected_this_rest, &"")
	assert_false(fate.can_continue())


func test_choose_requires_current_candidate_and_only_one_choice_per_rest() -> void:
	var fixture := _new_fixture(37)
	if fixture.is_empty():
		return
	var state = fixture.state
	var fate = fixture.fate
	fate.begin_rest()
	assert_false(fate.choose(&"not_offered"))
	assert_false(fate.can_continue())
	var chosen: StringName = fate.candidate_ids[0]
	assert_true(fate.choose(chosen))
	assert_true(fate.can_continue())
	assert_eq(fate.selected_this_rest, chosen)
	assert_true(state.has_fate(chosen))
	var selected_count: int = state.selected_fates.size()
	var second: StringName = fate.candidate_ids[1]
	assert_false(fate.choose(second))
	assert_eq(state.selected_fates.size(), selected_count)
	assert_false(state.has_fate(second))


func test_t12_pending_choice_leaves_build_state_unchanged_until_atomic_commit() -> void:
	var fixture := _new_fixture(39)
	if fixture.is_empty():
		return
	var state = fixture.state
	var fate = fixture.fate
	fate.begin_rest()
	var chosen: StringName = fate.candidate_ids[0]

	assert_true(fate.choose_pending(chosen))
	assert_eq(fate.selected_this_rest, chosen)
	assert_true(fate.can_continue())
	assert_false(state.has_fate(chosen))
	assert_eq(fate.pending_fate_id(), chosen)


func test_new_rest_resets_local_choice_but_excludes_previous_fate() -> void:
	var fixture := _new_fixture(41)
	if fixture.is_empty():
		return
	var fate = fixture.fate
	fate.begin_rest()
	var first: StringName = fate.candidate_ids[0]
	assert_true(fate.choose(first))
	fate.begin_rest()
	assert_eq(fate.selected_this_rest, &"")
	assert_false(fate.can_continue())
	assert_false(fate.candidate_ids.has(first))
	assert_eq(fate.candidate_ids.size(), 3)
	assert_eq(_unique_count(fate.candidate_ids), 3)


func test_third_rest_offers_exact_three_remaining_fates() -> void:
	var fixture := _new_fixture(43)
	if fixture.is_empty():
		return
	var state = fixture.state
	var fate = fixture.fate
	assert_true(state.select_fate(&"slaughter_path"))
	assert_true(state.select_fate(&"guardian_path"))
	fate.begin_rest()
	var expected := {
		&"shadow_path": true,
		&"forbidden_path": true,
		&"seal_path": true,
	}
	assert_eq(fate.candidate_ids.size(), 3)
	for fate_id in fate.candidate_ids:
		assert_true(expected.has(fate_id), "Unexpected remaining fate: %s" % fate_id)


func test_already_selected_fate_cannot_be_selected_again_even_if_requested() -> void:
	var fixture := _new_fixture(47)
	if fixture.is_empty():
		return
	var state = fixture.state
	var fate = fixture.fate
	assert_true(state.select_fate(&"shadow_path"))
	fate.begin_rest()
	assert_false(fate.choose(&"shadow_path"))
	assert_eq(state.selected_fates.size(), 1)
	assert_false(fate.can_continue())


func _new_fixture(seed_value: int) -> Dictionary:
	if not ResourceLoader.exists(FATE_CONTROLLER_PATH):
		return {}
	var catalog = load(CATALOG_PATH)
	var items: Dictionary = catalog.build_items()
	var fates: Dictionary = catalog.build_fates()
	var state = load(STATE_PATH).new()
	add_child_autofree(state)
	state.configure(items, fates)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var fate = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(fate)
	fate.configure(state, fates, rng)
	return {"state": state, "fate": fate}


func _unique_count(values: Array) -> int:
	var seen := {}
	for value in values:
		seen[value] = true
	return seen.size()
