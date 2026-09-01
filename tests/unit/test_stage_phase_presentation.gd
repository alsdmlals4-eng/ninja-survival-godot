# 공개 스테이지/페이즈 표시 경계가 lifecycle 상태만 해석하는지 검증한다.
extends GutTest

const StagePhasePresentation = preload("res://scripts/ui/stage_phase_presentation.gd")


func test_cheonsul_core_maps_to_public_stage_and_phase_one() -> void:
	var view := StagePhasePresentation.describe(&"cheonsul", &"core")
	assert_eq(view, {
		"visible": true,
		"stage": "스테이지 · 천술류 전장",
		"phase": "페이즈 1 · Core 압박",
	})


func test_all_live_circuit_states_have_only_approved_phase_labels() -> void:
	var expected := {
		&"core": "페이즈 1 · Core 압박",
		&"elite_warning": "페이즈 2 · Elite 접근",
		&"elite_active": "페이즈 2 · Elite 접근",
		&"trace_available": "페이즈 3 · Trace 회수",
		&"trace_recovered": "페이즈 3 · Trace 회수",
		&"boss_warning": "페이즈 3 · Trace 회수",
		&"boss_active": "페이즈 4 · Boss 결전",
	}
	for circuit_state in expected:
		assert_eq(StagePhasePresentation.describe(&"bongma", circuit_state)["phase"], expected[circuit_state])


func test_unknown_stage_or_circuit_state_hides_presentation() -> void:
	assert_eq(StagePhasePresentation.describe(&"unknown", &"core"), {"visible": false, "stage": "", "phase": ""})
	assert_eq(StagePhasePresentation.describe(&"cheonsul", &"cleared"), {"visible": false, "stage": "", "phase": ""})
