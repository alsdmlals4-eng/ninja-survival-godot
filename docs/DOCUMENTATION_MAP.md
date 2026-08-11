# DOCUMENTATION_MAP

## 목적

이 문서는 `ninja-survival-godot` 저장소의 활성 문서 역할과 권위 경계를 구분한다.

## 핵심 문서

| 문서 | 역할 | 상태 |
|---|---|---|
| `AGENTS.md` | AI/Codex 최상위 프로젝트 규칙, 프로젝트별 override, 단계형 MVP·안전·실행 경계 | current |
| `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md` | Base current-main thin-adapter 방식의 활성 실행/검수/병합/로컬 전달 계약 | `ACTIVE / v4.5 / 2026-08-11-r2` |
| `docs/CURRENT_CONFIRMED_DECISIONS.md` | 최신 사용자 승인 제품/설계 Decision 복원 원장 | MVP-4 `DESIGN_APPROVED` |
| `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` | MVP-4 L2 detailed design: 규칙·UX·입력·오류·검증 계약 | `APPROVED` |
| `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md` | 승인 Spec Requirement/AC를 구현 Task·path·Verification에 연결하는 L3 packet | `coverage_status: GAP` until actual implementation evidence |
| `docs/planning/2026-08-11-mvp4-content-balance-v1.md` | DEC-002의 초기 아이템/가방/조합/획득 수치·태그 authoring defaults | `RECOMMENDED_DEFAULT` |
| `docs/research/2026-08-11-mvp4-backpack-survivors-benchmark.md` | Backpack/Survivors/현업 비교 근거와 프로젝트 번역 | evidence only |
| `docs/planning/2026-08-11-mvp4-content-data-contract.md` | 다중 modifier·spatial-rule·acquisition determinism 데이터 계약 | `PHASE_B_VALIDATED` |
| `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md` | 12-task strict TDD implementation plan | executable only with Phase-B readiness record |
| `docs/planning/2026-08-11-mvp4-phase-b-definition-of-ready.md` | 최신 main/Base/Sheet/code를 재검수해 technical MUST_FIX를 닫고 Phase C 진입을 허가하는 Phase-B record | `PHASE_B_PASS` |
| `docs/ACTIVE_CONTEXT.md` | 현재 baseline, 구현/검증 상태, next executable step resume router | current |
| `README.md` | 저장소 소개와 현재 MVP 요약 | supporting |
| `PROJECT_BRIEF.md` | 프로젝트 약속, 장르, 핵심 경험, 4유파와 핵심 loop | supporting |
| `DESIGN_INTENT.md` | 전투 DDD, 휴식/백팩 설계 원칙, 벤치마킹 반영 | supporting |
| `MVP_ROADMAP.md` | MVP-0~MVP-5 단계별 범위와 완료 기준 | current staged scope |
| `docs/BASE_RULES_VERSION.md` | 마지막 프로젝트 Base sync와 최신 원격 관찰 분리 | full sync `NOT_RUN` |
| `docs/handoffs/*.md` | 날짜별 session/handoff snapshot | historical resume evidence |
| `TEST_CHECKLIST.md` | 공용 실행/검수 체크리스트 | supporting |
| `docs/UNITY_MIGRATION_AUDIT.md` | Unity 원본 분석 | historical/reference |
| `docs/GODOT_PORT_PLAN.md` | Godot 전환 계획 | implementation truth 대체 금지 |
| `docs/SYSTEM_MAP.md` | 실제 시스템 책임과 MVP-4 확장 경계 | supporting |
| `docs/CODEX_GOAL_MVP_001.md` | 과거 MVP-0 실행 지시문 | historical executed goal |

## v4.5 r2 source identity / project binding

```yaml
canonical_contract: PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md
contract_version: 4.5
contract_revision: 2026-08-11-r2
source_bytes: 77734
source_lf_count: 2849
source_sha256: 3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4
source_git_blob_sha1: de7c6f818a4c96d2a02edea5eaff33bb1c39e8da
source_storage: BYTE_EXACT_ROOT_FILE
project_binding: AGENTS.md
```

원문 r2는 그대로 보존한다. r2 §4의 `Switchy-Express-Cargo-Puzzle` local/Godot path는 이 프로젝트에서 `STALE_FOREIGN_PROJECT_INPUT / NON_EXECUTABLE_FOR_NINJA_SURVIVAL`이며, `AGENTS.md`의 Ninja Survival 경로 override가 실행 입력을 소유한다.

## MVP-4 현재 문서/실행 체인

```text
latest user instruction
→ AGENTS.md / project safety-engine-data override
→ v4.5 r2 active delivery contract
→ docs/CURRENT_CONFIRMED_DECISIONS.md
→ approved L2 feature spec
→ DEC-002 balance + benchmark evidence
→ L3 traceability packet
→ Superpowers 12-task implementation plan
→ explicit user `기획 완료` [RECEIVED 2026-08-11]
→ docs/planning/2026-08-11-mvp4-phase-b-definition-of-ready.md
→ PHASE B PASS
→ PHASE C — PowerShell / Codex / Godot BUILD
→ T01 focused RED → GREEN → task regressions
→ exact-head review / CI / human evidence / merge / readback
```

### Phase-B amendment rule

The existing implementation plan remains the task-order owner. The Phase-B readiness record is a narrow later technical amendment for:

- `RunModifierSet` supported-field validation;
- `ItemDefinition.static_modifier_payload`;
- `SpatialRuleDefinition`;
- legacy no-double-apply semantics;
- explicit base-acquisition vs combo-result pools;
- deterministic canonical candidate ordering;
- additional T01/T03/T07 RED evidence;
- the corrected phase boundary `기획 완료 → Phase B PASS → Phase C`.

If older plan text conflicts on those exact points, the Phase-B readiness record wins. It does not supersede Decisions/L2 product authority or change the 12-task order.

## 현재 단계

```yaml
active_delivery_contract: V4_5_R2
mvp4_design: APPROVED
mvp4_written_spec: APPROVED
mvp4_traceability: WRITTEN_COVERAGE_GAP
mvp4_implementation_plan: WRITTEN_WITH_PHASE_B_AMENDMENT
user_planning_complete_gate: GRANTED_2026_08_11
phase_b_final_planning_review: PASS
phase_c_production_build: AUTHORIZED_NOT_STARTED
mvp4_runtime_verification: NOT_RUN
```

`PHASE_B_PASS` is planning/readiness evidence only. It is not T01 GREEN, runtime PASS, human QA PASS, or MVP-4 completion evidence.

## 권위 충돌 처리

```text
latest user instruction
→ AGENTS / project safety-engine-data rules
→ active v4.5 r2 delivery contract
→ docs/CURRENT_CONFIRMED_DECISIONS.md
→ current detailed feature/domain canon
→ Phase-B readiness technical amendment
→ L3 + implementation plan
→ docs/ACTIVE_CONTEXT.md for mutable state
→ actual code / Scene / data / tests for implementation facts
→ project Google Sheets
→ historical docs / PRs / conversations / external benchmarks
```

MVP-4 회귀 민감 규칙:

- item + bag 90° rotation included;
- selected L/T bags included, arbitrary complex regular-item polyomino excluded;
- ~3-minute elite opportunity + ~5-minute segment boss cadence;
- six-slot REST work buffer and zero-buffer Fate gate;
- explicit atomic combination with progressive hints;
- Persistent Workbench with backpack continuously central;
- normal directional navigation and explicit visible `전체 이동 모드` are mutually exclusive;
- UI never becomes spatial/economy/reward/combination authority;
- DEC-002 strong-spatial product range is 7–9, with 8 the first authoring default;
- combo results are lookup-visible but base-acquisition-ineligible;
- legacy and new static modifier payloads never double-apply.

과거 활성 문서에 `rotation excluded`, current rule처럼 쓰인 `5/10/15 midboss`, `owned_items` count를 MVP-4 final modifier authority로 복원하는 표현, 또는 `기획 완료 → 즉시 T01 BUILD` 표현이 나오면 freshness finding으로 처리한다.

## Google Sheets 상태

프로젝트 GDD Google Sheets는 user-facing workspace이며 GitHub 정본을 대체하지 않는다.

2026-08-11 readback에서 일부 tab에 과거 rotation/timing 표현이 남아 있고 write는 `403 PERMISSION_DENIED`로 막혀 있다.

```yaml
sheet_sync_state: GITHUB_UPDATE_PENDING_SHEET
write_state: BLOCKED_USER_ACTION_403
classification: LOCAL_TASK_BLOCKER
```

권한이 복구되기 전 Sheet를 `SYNCED`로 보고하지 않는다. 이 blocker는 독립 Phase-C 구현 준비를 중단시키지 않는다.

## 환경 메모

```yaml
godot_engine_target: 4.7.1
gut_target: 9.7.1
godot_ai_user_reported_local_version: 3.1.4
godot_ai_status: INFORMATIONAL_UNTIL_PHASE_C_FRESH_EXECUTION_VERIFICATION
```

Godot AI 3.1.4는 Godot Engine 버전과 혼동하지 않는다.

## 작업 기준

- 과거 문서만으로 현재 구현 완료를 추정하지 않는다.
- Godot 구현 문서는 Godot/GDScript 용어로 작성한다.
- 작업 시작마다 최신 Base current `main`, 프로젝트 `main`, open/draft PR, 실제 code/test를 재조회한다.
- 벤치마크는 표면 복제가 아니라 문제·trade-off 검증에 사용한다.
- 승인 Decision 변경은 Decision 원장과 상세 Spec을 먼저 갱신한 뒤 Traceability/Plan을 재대조한다.
- Plan의 파일명/API가 actual repository와 충돌하면 BUILD 전에 Phase-B amendment 또는 새 RED evidence로 교정한다.
- Handoff/ActiveContext가 repository truth와 충돌하면 repository truth로 교정한다.
- Phase C에서는 fresh execution identity를 확인한 뒤 T01 focused RED부터 시작한다.
