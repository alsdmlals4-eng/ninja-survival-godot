# DOCUMENTATION_MAP

## 목적

이 문서는 `ninja-survival-godot` 저장소의 문서 역할을 구분한다.

## 핵심 문서

| 문서 | 역할 | 상태 |
|---|---|---|
| `AGENTS.md` | AI/Codex 최상위 작업 규칙, 현재 단계형 MVP 기준 | current |
| `README.md` | 저장소 소개와 현재 MVP 요약 | MVP-4 design sync |
| `PROJECT_BRIEF.md` | 프로젝트 한 줄 설명, 장르, 핵심 경험, 4유파와 핵심 loop | MVP-4 design sync |
| `DESIGN_INTENT.md` | 기획 의도, 전투 DDD, 휴식/백팩 설계 원칙, 벤치마킹 반영 | MVP-4 design sync |
| `MVP_ROADMAP.md` | MVP-0~MVP-5 단계별 범위와 완료 기준 | MVP-4 승인 범위 동기화 |
| `docs/CURRENT_CONFIRMED_DECISIONS.md` | 최신 사용자 승인 제품/설계 결정 정본 | MVP-4 design complete / written-spec review pending |
| `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` | MVP-4 L2 detailed feature design: 규칙·UX·입력·오류·검증 계약 | written-spec review pending |
| `docs/ACTIVE_CONTEXT.md` | 현재 baseline, 구현/검증 상태, next executable step를 연결하는 resume router | main은 PR #6 정합화 대기; 새 design checkpoint와 재대조 필요 |
| `docs/handoffs/*.md` | 세션/담당자 경계의 날짜별 인수인계 스냅샷. 결정 전문이나 구현 진척 정본을 중복 소유하지 않음 | history / resume evidence |
| `TEST_CHECKLIST.md` | 실행/검수 체크리스트 | 초기 작성, MVP-4 implementation plan에서 영향 재검토 필요 |
| `docs/BASE_RULES_VERSION.md` | 프로젝트에 마지막 동기화된 Base 기준과 최신 원격 관찰을 구분 | latest remote observed, full sync NOT_RUN |
| `docs/UNITY_MIGRATION_AUDIT.md` | Unity 원본 분석 결과 | 필요 시 historical/reference |
| `docs/GODOT_PORT_PLAN.md` | Godot 전환 계획 | current implementation truth를 대체하지 않음 |
| `docs/SYSTEM_MAP.md` | 현재 실제 시스템 책임과 다음 MVP-4 확장 경계 | MVP-4 design sync |
| `docs/CODEX_GOAL_MVP_001.md` | 과거 MVP-0 기본 전투 기반 실행 지시문 | historical executed goal, current MVP-4 prompt 아님 |

## 현재 문서 기준

현재 기획 MVP는 기존 최소 전투 루프보다 넓다.

- 기존 최소 전투 루프는 `MVP-0`으로 유지한다.
- 전체 기획 MVP는 `MVP_ROADMAP.md`의 `MVP-0`~`MVP-5`로 나눈다.
- 최신 승인된 제품 결정은 `docs/CURRENT_CONFIRMED_DECISIONS.md`가 복원 정본이다.
- MVP-4 상세 설계는 written-spec review 동안 `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`를 사용한다.
- `docs/ACTIVE_CONTEXT.md`는 현재 구현/검증/다음 작업만 압축해 연결하고 제품 결정 전문을 복제하지 않는다.
- 날짜별 Handoff는 session boundary snapshot이며, 재개 시 GitHub 최신 상태와 다시 대조한다.
- 과거 MVP-3 spec과 Goal 문서는 당시 설계/실행 이력이며 현재 MVP-4 규칙을 덮어쓰지 않는다.
- Codex Goal 하나에 전체 기획 MVP를 넣지 않는다.

## 권위 충돌 처리

```text
latest user approval
→ AGENTS / project safety rules
→ docs/CURRENT_CONFIRMED_DECISIONS.md
→ current detailed feature/domain canon
→ docs/ACTIVE_CONTEXT.md for state
→ actual code / Scene / data / tests for implementation facts
→ project Google Sheets
→ historical docs / PRs / conversations / external benchmarks
```

현재 MVP-4에서 회귀 민감한 최신 규칙:

- item + bag 90° rotation included.
- selected L/T bags included; arbitrary complex regular-item polyomino excluded.
- each 5-minute segment uses ~3-minute elite + ~5-minute segment boss target.
- REST uses a Persistent Workbench around the central backpack board.

과거 문서의 `rotation excluded`, `5/10/15 midboss`가 현재 target rule처럼 다시 나타나면 `CURRENT_CONFIRMED_DECISIONS.md`와 최신 detailed spec을 기준으로 freshness finding을 낸다.

## Google Sheets 상태

프로젝트 GDD Google Sheets는 user-facing workspace이며 GitHub 정본을 대체하지 않는다.

2026-08-11 감사에서 일부 Sheet tab에 과거 rotation/timing 표현이 남아 있음을 확인했고 write 요청은 `403 PERMISSION_DENIED`로 실패했다.

```yaml
sheet_sync_state: GITHUB_UPDATE_PENDING_SHEET
write_state: BLOCKED_USER_ACTION
```

권한이 복구되기 전 Sheet를 `SYNCED`로 보고하지 않는다.

## 작업 기준

- Unity 원본 분석/과거 문서만으로 현재 구현 완료를 추정하지 않는다.
- Godot 구현 문서는 Godot/GDScript 용어로 작성한다.
- 작업 시작 전 최신 Base와 프로젝트 current canon을 필요한 범위에서 대조한다.
- 벤치마크는 표면 복제가 아니라 현재 결정을 바꿀 문제와 trade-off에 사용한다.
- 사용자 승인 Decision은 현재 결정 원장과 상세 책임 원본에 동기화한다.
- Base로 승격할 내용과 프로젝트 전용 내용을 구분한다.
- Handoff/Active Context가 현재 저장소 truth와 충돌하면 저장소 truth를 먼저 확인한 뒤 상태 문서를 교정한다.
- written-spec review 전 MVP-4 implementation plan 또는 production code로 진행하지 않는다.