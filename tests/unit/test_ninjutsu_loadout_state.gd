# 런 단위 인법서의 시작·대기·원자 확정 계약을 검증한다.
extends GutTest

const LOADOUT_PATH := "res://scripts/core/ninjutsu_loadout_state.gd"


func test_two_round_draft_has_three_unique_options_and_no_free_combat_effect() -> void:
	var loadout = load(LOADOUT_PATH).new()
	add_child_autofree(loadout)
	assert_true(loadout.begin_start_draft(&"bongma", 123))
	var first: Dictionary = loadout.start_draft_snapshot()
	assert_eq(first.options.size(), 3)
	assert_false(loadout.choose_start_draft(&"unknown"))
	assert_eq(loadout.start_draft_snapshot(), first)
	assert_true(loadout.choose_start_draft(first.options[0]))
	var second: Dictionary = loadout.start_draft_snapshot()
	assert_eq(second.options.size(), 3)
	assert_false(second.options.has(first.options[0]))
	assert_true(loadout.choose_start_draft(second.options[0]))
	assert_true(loadout.active_spell_ids().is_empty())
	assert_false(loadout.commit_drafted_start([first.options[0]]))
	assert_true(loadout.commit_drafted_start([first.options[0], second.options[0]]))
	assert_eq(loadout.active_spell_ids(), [first.options[0], second.options[0]])
	assert_false(loadout.activate_starter(&"bongma"))
	assert_false(loadout.stage_scroll(&"bongma", &"elite_scroll"))
	assert_false(loadout.commit_pending())
	assert_false(loadout.commit_drafted_start([first.options[0], second.options[0]]))


func test_placed_book_commit_limits_four_active_one_unlocked_foreign_and_is_atomic() -> void:
	var loadout = load(LOADOUT_PATH).new()
	add_child_autofree(loadout)
	assert_true(loadout.begin_start_draft(&"bongma", 1))
	assert_true(loadout.choose_start_draft(loadout.start_draft_snapshot().options[0]))
	assert_true(loadout.choose_start_draft(loadout.start_draft_snapshot().options[0]))
	assert_true(loadout.commit_drafted_start(loadout.start_draft_snapshot().picks))
	var initial: Dictionary = loadout.get_snapshot()
	assert_false(loadout.commit_placed_ninjutsu([&"cheonsul_ice_veil"], [&"bongma"]))
	assert_eq(loadout.get_snapshot(), initial)
	assert_false(loadout.commit_placed_ninjutsu([&"cheonsul_ice_veil", &"cheonsul_wind_pillar"], [&"bongma", &"cheonsul"]))
	assert_eq(loadout.get_snapshot(), initial)
	var valid := [&"bongma_guardian_ward", &"bongma_talisman_wheel", &"bongma_barrier_step", &"cheonsul_ice_veil"]
	assert_true(loadout.commit_placed_ninjutsu(valid, [&"bongma", &"cheonsul"]))
	assert_eq(loadout.active_spell_ids(), valid)
	var before: Dictionary = loadout.get_snapshot()
	valid.append(&"bongma_suppression_seal")
	assert_false(loadout.commit_placed_ninjutsu(valid, [&"bongma", &"cheonsul"]))
	assert_eq(loadout.get_snapshot(), before)
	assert_false(loadout.commit_placed_ninjutsu([&"bongma_guardian_ward", &"bongma_guardian_ward"], [&"bongma"]))
	assert_true(loadout.commit_placed_ninjutsu([], [&"bongma"]))
	assert_true(loadout.active_spell_ids().is_empty(), "Removing all books cannot revive a hidden starter.")


func test_seeded_draft_reaches_all_sixty_pairs_without_changing_repeated_options() -> void:
	var total_pairs := 0
	for school in [&"bongma", &"cheonsul", &"guiin", &"heukyeong"]:
		var pairs: Dictionary = {}
		for seed_value in range(512):
			var loadout = load(LOADOUT_PATH).new()
			assert_true(loadout.begin_start_draft(school, seed_value))
			var first: Dictionary = loadout.start_draft_snapshot()
			assert_eq(loadout.start_draft_snapshot(), first)
			assert_true(loadout.choose_start_draft(first.options[0]))
			var second: Dictionary = loadout.start_draft_snapshot()
			assert_true(loadout.choose_start_draft(second.options[0]))
			var picks: Array = loadout.start_draft_snapshot().picks
			assert_true(loadout.commit_drafted_start(picks))
			picks.sort()
			pairs[str(picks)] = true
			loadout.free()
			if pairs.size() == 15:
				break
		assert_eq(pairs.size(), 15)
		total_pairs += pairs.size()
	assert_eq(total_pairs, 60, "Domain draft coverage only; not sixty full combat acceptance runs.")


func test_selected_school_starter_is_the_only_immediate_starting_ninjutsu() -> void:
	assert_true(ResourceLoader.exists(LOADOUT_PATH), "런 단위 인법서 상태가 필요합니다.")
	if not ResourceLoader.exists(LOADOUT_PATH):
		return
	var loadout = load(LOADOUT_PATH).new()
	add_child_autofree(loadout)

	assert_true(loadout.activate_starter(&"bongma"))
	assert_eq(loadout.active_spell_ids(), [&"bongma_hundred_demon_familiar"])
	assert_false(loadout.activate_starter(&"cheonsul"), "런 시작 후 다른 유파의 기본 인법을 중복 활성화하면 안 됩니다.")
	assert_eq(loadout.active_spell_ids(), [&"bongma_hundred_demon_familiar"])


func test_elite_and_boss_scrolls_remain_inactive_until_one_commit() -> void:
	assert_true(ResourceLoader.exists(LOADOUT_PATH), "런 단위 인법서 상태가 필요합니다.")
	if not ResourceLoader.exists(LOADOUT_PATH):
		return
	var loadout = load(LOADOUT_PATH).new()
	add_child_autofree(loadout)

	assert_true(loadout.activate_starter(&"cheonsul"))
	assert_true(loadout.stage_scroll(&"cheonsul", &"elite_scroll"))
	assert_true(loadout.stage_scroll(&"cheonsul", &"boss_scroll"))
	assert_eq(loadout.active_spell_ids(), [&"cheonsul_flame_mark"], "대기 인법서는 Workbench 확정 전 전투에 섞이면 안 됩니다.")
	assert_eq(loadout.pending_spell_ids(), [&"cheonsul_water_vein_bind", &"cheonsul_lightning_chain_shift"])
	assert_true(loadout.can_commit_pending())

	assert_true(loadout.commit_pending())
	assert_eq(
		loadout.active_spell_ids(),
		[&"cheonsul_flame_mark", &"cheonsul_water_vein_bind", &"cheonsul_lightning_chain_shift"]
	)
	assert_eq(loadout.pending_spell_ids(), [])


func test_scroll_rejects_unknown_lane_cross_school_and_duplicates_without_mutation() -> void:
	assert_true(ResourceLoader.exists(LOADOUT_PATH), "런 단위 인법서 상태가 필요합니다.")
	if not ResourceLoader.exists(LOADOUT_PATH):
		return
	var loadout = load(LOADOUT_PATH).new()
	add_child_autofree(loadout)

	assert_true(loadout.activate_starter(&"heukyeong"))
	assert_false(loadout.stage_scroll(&"heukyeong", &"starter"))
	assert_false(loadout.stage_scroll(&"bongma", &"elite_scroll"))
	assert_true(loadout.stage_scroll(&"heukyeong", &"elite_scroll"))
	var before: Dictionary = loadout.get_snapshot()
	assert_false(loadout.stage_scroll(&"heukyeong", &"elite_scroll"))
	assert_eq(loadout.get_snapshot(), before)
