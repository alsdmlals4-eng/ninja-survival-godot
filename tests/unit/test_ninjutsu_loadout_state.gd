# 런 단위 인법서의 시작·대기·원자 확정 계약을 검증한다.
extends GutTest

const LOADOUT_PATH := "res://scripts/core/ninjutsu_loadout_state.gd"


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
