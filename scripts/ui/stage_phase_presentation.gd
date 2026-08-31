# 내부 Circuit lifecycle을 플레이어용 스테이지/페이즈 문구로만 변환한다.
class_name StagePhasePresentation
extends RefCounted

const BONGMA_STAGE := "스테이지 · 봉마류 전장"
const CHEONSUL_STAGE := "스테이지 · 천술류 전장"
const GUIIN_STAGE := "스테이지 · 귀인류 전장"
const HEUKYEONG_STAGE := "스테이지 · 흑영류 전장"

const STAGE_BY_SCHOOL := {
	&"bongma": BONGMA_STAGE,
	&"cheonsul": CHEONSUL_STAGE,
	&"guiin": GUIIN_STAGE,
	&"heukyeong": HEUKYEONG_STAGE,
}

const PHASE_BY_CIRCUIT_STATE := {
	&"core": "페이즈 1 · Core 압박",
	&"elite_warning": "페이즈 2 · Elite 접근",
	&"elite_active": "페이즈 2 · Elite 접근",
	&"trace_available": "페이즈 3 · Trace 회수",
	&"trace_recovered": "페이즈 3 · Trace 회수",
	&"boss_warning": "페이즈 3 · Trace 회수",
	&"boss_active": "페이즈 4 · Boss 결전",
}


static func describe(school_id: StringName, circuit_state: StringName) -> Dictionary:
	var stage = STAGE_BY_SCHOOL.get(school_id)
	var phase = PHASE_BY_CIRCUIT_STATE.get(circuit_state)
	if stage == null or phase == null:
		return {"visible": false, "stage": "", "phase": ""}
	return {"visible": true, "stage": stage, "phase": phase}
