# 네 유파 공통 Circuit 도메인 계약을 검증한다.
extends GutTest

const CONTROLLER_PATH := "res://scripts/core/school_circuit_controller.gd"
const MVP3_CATALOG_PATH := "res://scripts/data/mvp3_catalog.gd"
const MVP4_CATALOG_PATH := "res://scripts/data/mvp4_catalog.gd"
const BUILD_STATE_PATH := "res://scripts/core/run_build_state.gd"
const FATE_CONTROLLER_PATH := "res://scripts/core/fate_controller.gd"

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


func _new_configured_circuit(school_id: StringName):
	var controller_script = load(CONTROLLER_PATH)
	var mvp3_catalog = load(MVP3_CATALOG_PATH)
	var mvp4_catalog = load(MVP4_CATALOG_PATH)
	var build_state = load(BUILD_STATE_PATH).new()
	add_child_autofree(build_state)
	build_state.configure(mvp4_catalog.build_items(), mvp3_catalog.build_fates())
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
