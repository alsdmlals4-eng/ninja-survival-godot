# Run 전용 G 수입 정책과 receipt를 결정적으로 검증한다.
extends GutTest

const POLICY_PATH := "res://resources/run_economy_policy.tres"
const BUILD_STATE_PATH := "res://scripts/core/run_build_state.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"


func test_policy_resource_is_the_single_default_source_for_normal_elite_and_boss_gold() -> void:
	assert_true(ResourceLoader.exists(POLICY_PATH))
	var policy = load(POLICY_PATH)
	assert_not_null(policy)
	if policy == null:
		return
	assert_almost_eq(float(policy.normal_kill_gold_chance), 0.20, 0.0001)
	assert_eq(policy.normal_kill_gold_amount, 1)
	assert_eq(policy.elite_clear_gold, 5)
	assert_eq(policy.school_boss_clear_gold, 10)


func test_seeded_normal_rolls_are_reproducible_and_source_receipts_keep_zero_rolls() -> void:
	var policy = load(POLICY_PATH)
	if policy == null:
		return
	var first = _new_build_state(policy, 903)
	var second = _new_build_state(policy, 903)
	assert_not_null(first)
	assert_not_null(second)
	if first == null or second == null:
		return
	var first_amounts: Array[int] = []
	var second_amounts: Array[int] = []
	for _index in range(20):
		first_amounts.append(first.grant_normal_kill_gold())
		second_amounts.append(second.grant_normal_kill_gold())
	assert_eq(first_amounts, second_amounts)
	assert_true(first_amounts.has(0), "20% policy must keep failed normal rolls visible as zero receipts.")
	assert_true(first_amounts.has(1), "20% policy must still award 1G on successful rolls.")
	var receipts: Array = first.get_economy_receipts()
	assert_eq(receipts.size(), 20)
	for receipt in receipts:
		assert_eq(receipt.get("source"), &"normal")
		assert_true(int(receipt.get("amount", -1)) in [0, 1])


func test_elite_and_school_boss_rewards_are_fixed_policy_values_with_distinct_receipts() -> void:
	var policy = load(POLICY_PATH)
	if policy == null:
		return
	var build_state = _new_build_state(policy, 1)
	assert_not_null(build_state)
	if build_state == null:
		return
	build_state.set_selected_school(&"heukyeong")
	assert_eq(build_state.grant_elite_clear_gold(), 5)
	assert_eq(build_state.grant_school_boss_clear_gold(), 10)
	assert_eq(build_state.gold, 15)
	var receipts: Array = build_state.get_economy_receipts()
	assert_eq(receipts, [
		{"source": &"elite", "amount": 5, "school_id": &"heukyeong"},
		{"source": &"school_boss", "amount": 10, "school_id": &"heukyeong"},
	])


func _new_build_state(policy, seed_value: int):
	var catalog = load(MVP3_CATALOG_PATH)
	var state = load(BUILD_STATE_PATH).new()
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	state.configure(catalog.build_items(), catalog.build_fates(), policy, rng)
	add_child_autofree(state)
	return state
