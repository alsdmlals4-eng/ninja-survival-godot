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


func test_choose_keeps_legacy_immediate_commit_for_current_main_controller() -> void:
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
	assert_true(state.has_fate(chosen), "Legacy MainController compatibility must keep immediate Fate commit until T13 migration")
	var selected_count: int = state.selected_fates.size()
	var second: StringName = fate.candidate_ids[1]
	assert_false(fate.choose(second))
	assert_eq(state.selected_fates.size(), selected_count)
	assert_false(state.has_fate(second))


func test_choose_pending_api_exists_for_t12_atomic_commit() -> void:
	var fixture := _new_fixture(38)
	if fixture.is_empty():
		return
	assert_true(fixture.fate.has_method("choose_pending"), "T12 requires FateController.choose_pending()")
	assert_true(fixture.fate.has_method("_can_commit_pending"), "T12 requires pending validation bridge")
	assert_true(fixture.fate.has_method("_commit_pending"), "T12 requires pending commit bridge")


func test_choose_pending_keeps_fate_uncommitted_for_t12_atomic_commit() -> void:
	var fixture := _new_fixture(39)
	if fixture.is_empty():
		return
	var state = fixture.state
	var fate = fixture.fate
	if not fate.has_method("choose_pending"):
		return
	fate.begin_rest()
	var chosen: StringName = fate.candidate_ids[0]
	var second: StringName = fate.candidate_ids[1]
	assert_true(fate.choose_pending(chosen))
	assert_true(fate.can_continue())
	assert_eq(fate.selected_this_rest, chosen)
	assert_false(state.has_fate(chosen), "T12 pending path must not mutate committed RunBuildState")
	assert_true(fate._can_commit_pending())
	assert_false(fate.choose_pending(second))
	assert_false(state.has_fate(second))


func test_new_rest_resets_local_choice_and_excludes_previous_legacy_fate() -> void:
	var fixture := _new_fixture(41)
	if fixture.is_empty():
		return
	var state = fixture.state
	var fate = fixture.fate
	fate.begin_rest()
	var first: StringName = fate.candidate_ids[0]
	assert_true(fate.choose(first))
	assert_true(state.has_fate(first))
	fate.begin_rest()
	assert_eq(fate.selected_this_rest, &"")
	assert_false(fate.can_continue())
	assert_false(fate.candidate_ids.has(first))
	assert_eq(fate.candidate_ids.size(), 3)
	assert_eq(_unique_count(fate.candidate_ids), 3)


func test_begin_rest_discards_abandoned_pending_choice_without_committing_it() -> void:
	var fixture := _new_fixture(42)
	if fixture.is_empty() or not fixture.fate.has_method("choose_pending"):
		return
	var state = fixture.state
	var fate = fixture.fate
	fate.begin_rest()
	var abandoned: StringName = fate.candidate_ids[0]
	assert_true(fate.choose_pending(abandoned))
	assert_true(fate._can_commit_pending())
	fate.begin_rest()
	assert_false(state.has_fate(abandoned))
	assert_eq(fate.selected_this_rest, &"")
	assert_false(fate._can_commit_pending())


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
	if fate.has_method("choose_pending"):
		assert_false(fate.choose_pending(&"shadow_path"))
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
