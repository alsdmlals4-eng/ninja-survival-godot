extends GutTest

const COMBINATION_RESOLVER_PATH := "res://scripts/backpack/combination_resolver.gd"
const SESSION_PATH := "res://scripts/backpack/rest_backpack_session.gd"
const STATE_PATH := "res://scripts/backpack/backpack_state.gd"
const RESOLVER_PATH := "res://scripts/backpack/backpack_resolver.gd"
const CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const COMBINATION_DEFINITION_PATH := "res://scripts/data/combination_definition.gd"


func test_t05_resource_exists() -> void:
	assert_true(ResourceLoader.exists(COMBINATION_RESOLVER_PATH), "Missing T05 CombinationResolver")


func test_eligible_pairs_require_valid_orthogonal_on_board_sources() -> void:
	var combination_resolver = _combination_resolver()
	if combination_resolver == null:
		return
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var resolution = _resolver().resolve(committed, _item_defs(), _bag_defs(), &"")
	var pairs: Array = combination_resolver.eligible_pairs(committed, resolution, _combos())
	assert_eq(pairs.size(), 1)
	assert_eq(pairs[0].get("combo_id"), &"water_mist")
	assert_eq(pairs[0].get("source_a_instance"), water_id)
	assert_eq(pairs[0].get("source_b_instance"), stealth_id)

	var diagonal = _starting_state()
	var shuriken_id: int = diagonal.add_item(&"shuriken", Vector2i(1, 1))
	var fortune_id: int = diagonal.add_item(&"fortune_talisman", Vector2i(2, 2))
	var diagonal_combo = load(COMBINATION_DEFINITION_PATH).new()
	diagonal_combo.id = &"diagonal_probe"
	diagonal_combo.source_a = &"shuriken"
	diagonal_combo.source_b = &"fortune_talisman"
	diagonal_combo.result_item = &"water_mist"
	resolution = _resolver().resolve(diagonal, _item_defs(), _bag_defs(), &"")
	assert_eq(combination_resolver.eligible_pairs(diagonal, resolution, {&"diagonal_probe": diagonal_combo}), [])
	assert_not_null(diagonal.get_item(shuriken_id))
	assert_not_null(diagonal.get_item(fortune_id))


func test_buffer_source_is_not_combination_eligible() -> void:
	var combination_resolver = _combination_resolver()
	if combination_resolver == null:
		return
	var committed = _starting_state()
	committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	var session = _session(committed)
	assert_true(session.move_item_to_buffer(stealth_id))
	var resolution = _resolver().resolve(session.state, _item_defs(), _bag_defs(), &"")
	assert_eq(combination_resolver.eligible_pairs(session.state, resolution, _combos()), [])
	assert_eq(session.buffer.size(), 1)


func test_hint_stage_progresses_from_unknown_to_ingredient_ready_and_discovered() -> void:
	var combination_resolver = _combination_resolver()
	if combination_resolver == null:
		return
	var combos := _combos()
	var empty_state = _starting_state()
	var resolution = _resolver().resolve(empty_state, _item_defs(), _bag_defs(), &"")
	assert_eq(combination_resolver.hint_stage(&"water_mist", empty_state, resolution, {}, combos), 0)

	var ingredient_state = _starting_state()
	ingredient_state.add_item(&"water_style", Vector2i(1, 1))
	resolution = _resolver().resolve(ingredient_state, _item_defs(), _bag_defs(), &"")
	assert_eq(combination_resolver.hint_stage(&"water_mist", ingredient_state, resolution, {}, combos), 1)

	var separated_state = _starting_state()
	separated_state.add_item(&"water_style", Vector2i(1, 1))
	separated_state.add_item(&"stealth_art", Vector2i(4, 1))
	resolution = _resolver().resolve(separated_state, _item_defs(), _bag_defs(), &"")
	assert_eq(combination_resolver.hint_stage(&"water_mist", separated_state, resolution, {}, combos), 1)

	var ready_state = _starting_state()
	ready_state.add_item(&"water_style", Vector2i(1, 1))
	ready_state.add_item(&"stealth_art", Vector2i(2, 1))
	resolution = _resolver().resolve(ready_state, _item_defs(), _bag_defs(), &"")
	assert_eq(combination_resolver.hint_stage(&"water_mist", ready_state, resolution, {}, combos), 2)
	assert_eq(combination_resolver.hint_stage(&"water_mist", ready_state, resolution, {&"water_mist": true}, combos), 3)


func test_begin_and_cancel_result_preview_preserve_both_sources() -> void:
	var combination_resolver = _combination_resolver()
	if combination_resolver == null:
		return
	var setup := _ready_water_mist_session()
	var session = setup.session
	assert_true(combination_resolver.begin_result_preview(session, &"water_mist", setup.water_id, setup.stealth_id))
	assert_true(session.combination_transaction_active)
	assert_not_null(session.state.get_item(setup.water_id))
	assert_not_null(session.state.get_item(setup.stealth_id))
	assert_eq(combination_resolver.pending_result.get("combo_id"), &"water_mist")

	combination_resolver.cancel_result(session)
	assert_false(session.combination_transaction_active)
	assert_true(combination_resolver.pending_result.is_empty())
	assert_not_null(session.state.get_item(setup.water_id))
	assert_not_null(session.state.get_item(setup.stealth_id))


func test_begin_rejects_mismatched_nonadjacent_and_buffer_sources() -> void:
	var combination_resolver = _combination_resolver()
	if combination_resolver == null:
		return
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(4, 1))
	var session = _session(committed)
	assert_false(combination_resolver.begin_result_preview(session, &"water_mist", water_id, stealth_id))
	assert_false(combination_resolver.begin_result_preview(session, &"thunder_blade", water_id, stealth_id))

	committed = _starting_state()
	water_id = committed.add_item(&"water_style", Vector2i(1, 1))
	stealth_id = committed.add_item(&"stealth_art", Vector2i(2, 1))
	session = _session(committed)
	assert_true(session.move_item_to_buffer(stealth_id))
	assert_false(combination_resolver.begin_result_preview(session, &"water_mist", water_id, stealth_id))
	assert_false(session.combination_transaction_active)


func test_invalid_result_placement_preserves_sources_and_keeps_pending_transaction() -> void:
	var combination_resolver = _combination_resolver()
	if combination_resolver == null:
		return
	var setup := _ready_water_mist_session()
	var session = setup.session
	assert_true(combination_resolver.begin_result_preview(session, &"water_mist", setup.water_id, setup.stealth_id))
	assert_false(combination_resolver.commit_result(session, Vector2i(0, 0)))
	assert_true(session.combination_transaction_active)
	assert_not_null(session.state.get_item(setup.water_id))
	assert_not_null(session.state.get_item(setup.stealth_id))
	assert_null(_find_definition(session.state, &"water_mist"))
	assert_eq(combination_resolver.pending_result.get("combo_id"), &"water_mist")
	combination_resolver.cancel_result(session)


func test_legal_commit_consumes_exactly_two_once_creates_one_result_and_marks_discovery() -> void:
	var combination_resolver = _combination_resolver()
	if combination_resolver == null:
		return
	var setup := _ready_water_mist_session()
	var session = setup.session
	assert_true(combination_resolver.begin_result_preview(session, &"water_mist", setup.water_id, setup.stealth_id))
	assert_true(combination_resolver.commit_result(session, Vector2i(1, 1)))
	assert_false(session.combination_transaction_active)
	assert_null(session.state.get_item(setup.water_id))
	assert_null(session.state.get_item(setup.stealth_id))
	var result = _find_definition(session.state, &"water_mist")
	assert_not_null(result)
	assert_eq(session.state.items.size(), 1)
	assert_eq(result.origin, Vector2i(1, 1))
	assert_true(combination_resolver.discovered_combinations.has(&"water_mist"))
	assert_eq(combination_resolver.hint_stage(&"water_mist", session.state, _resolver().resolve(session.state, _item_defs(), _bag_defs(), &""), {}, _combos()), 3)
	assert_false(session.undo(), "Completed combinations are not REST edit-history actions")

	var result_id: int = result.instance_id
	assert_false(combination_resolver.commit_result(session, Vector2i(2, 1)), "Repeated commit must be ignored")
	assert_eq(session.state.items.size(), 1)
	assert_not_null(session.state.get_item(result_id))


func test_pending_combination_blocks_parallel_backpack_edits_and_fate_commit() -> void:
	var combination_resolver = _combination_resolver()
	if combination_resolver == null:
		return
	var setup := _ready_water_mist_session()
	var session = setup.session
	assert_true(combination_resolver.begin_result_preview(session, &"water_mist", setup.water_id, setup.stealth_id))
	assert_false(session.move_item_to_buffer(setup.water_id))
	assert_false(session.rotate_item(setup.water_id))
	assert_false(session.enter_whole_layout_move_mode())
	assert_eq(session.commit_failures(0, false, false), [&"combination_pending"])
	combination_resolver.cancel_result(session)
	assert_eq(session.commit_failures(0, false, false), [])


func test_second_pending_transaction_is_rejected_without_replacing_first() -> void:
	var combination_resolver = _combination_resolver()
	if combination_resolver == null:
		return
	var setup := _ready_water_mist_session()
	var session = setup.session
	assert_true(combination_resolver.begin_result_preview(session, &"water_mist", setup.water_id, setup.stealth_id))
	assert_false(combination_resolver.begin_result_preview(session, &"water_mist", setup.water_id, setup.stealth_id))
	assert_eq(combination_resolver.pending_result.get("source_a_instance"), setup.water_id)
	assert_eq(combination_resolver.pending_result.get("source_b_instance"), setup.stealth_id)
	combination_resolver.cancel_result(session)


func _ready_water_mist_session() -> Dictionary:
	var committed = _starting_state()
	var water_id: int = committed.add_item(&"water_style", Vector2i(1, 1))
	var stealth_id: int = committed.add_item(&"stealth_art", Vector2i(2, 1))
	return {
		"session": _session(committed),
		"water_id": water_id,
		"stealth_id": stealth_id,
	}


func _find_definition(state, definition_id: StringName):
	for instance in state.items.values():
		if instance.definition_id == definition_id:
			return instance
	return null


func _combination_resolver():
	if not ResourceLoader.exists(COMBINATION_RESOLVER_PATH):
		assert_true(false, "T05 CombinationResolver must exist before behavior tests")
		return null
	return load(COMBINATION_RESOLVER_PATH).new()


func _session(committed_state):
	var session = load(SESSION_PATH).new()
	session.begin(committed_state, _resolver(), _item_defs(), _bag_defs(), &"cheonsul")
	return session


func _starting_state():
	return load(STATE_PATH).new().create_starting_state()


func _resolver():
	return load(RESOLVER_PATH).new()


func _item_defs() -> Dictionary:
	return load(CATALOG_PATH).build_items()


func _bag_defs() -> Dictionary:
	return load(CATALOG_PATH).build_bags()


func _combos() -> Dictionary:
	return load(CATALOG_PATH).build_combinations()
