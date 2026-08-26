# 천술류 세로 슬라이스 도메인 계약을 검증한다.
extends GutTest

const CONTROLLER_PATH := "res://scripts/core/cheonsul_vertical_slice_controller.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MVP4_CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const BUILD_STATE_PATH := "res://scripts/core/run_build_state.gd"
const FATE_CONTROLLER_PATH := "res://scripts/core/fate_controller.gd"


func test_first_school_commits_cheonsul_without_rest_commit() -> void:
	var controller_script = load(CONTROLLER_PATH)
	assert_not_null(controller_script, "천술류 세로 슬라이스 조정자가 필요합니다.")
	if controller_script == null:
		return
	var slice = controller_script.new()
	add_child_autofree(slice)
	assert_true(slice.begin_first_school())
	assert_eq(slice.route_state.active_school_id(), &"cheonsul")
	assert_eq(slice.route_state.cleared_school_ids(), [])


func test_first_school_exposes_cheonsul_encounter_catalog_identity() -> void:
	var controller_script = load(CONTROLLER_PATH)
	assert_not_null(controller_script, "천술류 세로 슬라이스 조정자가 필요합니다.")
	if controller_script == null:
		return
	var slice = controller_script.new()
	add_child_autofree(slice)
	assert_true(slice.begin_first_school())
	var encounter: Dictionary = slice.get_snapshot().get("encounter", {})
	assert_eq(encounter.get("school_id"), &"cheonsul")
	assert_eq(encounter.get("core_monster_ids"), [&"fire_mark_caster", &"water_vein_caster", &"lightning_chain_caster"])
	assert_eq(encounter.get("elite_id"), &"five_element_tuner")
	assert_eq(encounter.get("boss_id"), &"heavenly_change_taoist")
	assert_eq(encounter.get("pattern_refs"), [&"fan_or_arc_projectile", &"telegraphed_zone", &"mark_or_link"])


func test_boss_request_requires_elite_trace_and_elapsed_time() -> void:
	var controller_script = load(CONTROLLER_PATH)
	assert_not_null(controller_script, "천술류 세로 슬라이스 조정자가 필요합니다.")
	if controller_script == null:
		return
	var slice = controller_script.new()
	add_child_autofree(slice)
	assert_true(slice.begin_first_school())
	assert_true(slice.sync_elapsed(270.0))
	assert_false(bool(slice.get_snapshot().get("boss_requested", false)))
	assert_false(slice.recover_trace())
	assert_true(slice.mark_elite_defeated())
	assert_true(slice.sync_elapsed(280.0))
	assert_false(bool(slice.get_snapshot().get("boss_requested", false)))
	assert_true(slice.recover_trace())
	assert_true(slice.sync_elapsed(290.0))
	assert_true(bool(slice.get_snapshot().get("boss_requested", false)))


func test_boss_clear_creates_pending_reward_workbench_without_auto_commit() -> void:
	var controller_script = load(CONTROLLER_PATH)
	assert_not_null(controller_script, "천술류 세로 슬라이스 조정자가 필요합니다.")
	if controller_script == null:
		return
	var mvp3_catalog = load(MVP3_CATALOG_PATH)
	var mvp4_catalog = load(MVP4_CATALOG_PATH)
	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(mvp4_catalog.build_items(), mvp3_catalog.build_fates())
	var fate_controller = load(FATE_CONTROLLER_PATH).new()
	add_child_autofree(fate_controller)
	var rng := RandomNumberGenerator.new()
	rng.seed = 65
	fate_controller.configure(build_state, mvp3_catalog.build_fates(), rng)
	var slice = controller_script.new()
	add_child_autofree(slice)
	slice.configure_workbench(build_state, fate_controller, mvp4_catalog.build_items(), mvp4_catalog.build_bags(), rng)
	assert_true(slice.begin_first_school())
	assert_true(slice.sync_elapsed(180.0))
	assert_true(slice.mark_elite_defeated())
	assert_true(slice.recover_trace())
	assert_true(slice.sync_elapsed(270.0))
	assert_true(bool(slice.get_snapshot().get("boss_requested", false)))
	assert_true(slice.mark_boss_defeated())
	assert_eq(slice.route_state.cleared_school_ids(), [&"cheonsul"])
	var workbench: Dictionary = slice.workbench_snapshot()
	assert_true(bool(workbench.get("boss_reward_pending", false)))
	assert_eq((workbench.get("boss_reward_options", []) as Array).size(), 3)
	assert_true((workbench.get("readiness_failures", []) as Array).has(&"boss_reward_pending"))
	assert_eq(build_state.selected_fates, [])
	assert_eq(slice.route_state.provisional_school_id(), &"")
