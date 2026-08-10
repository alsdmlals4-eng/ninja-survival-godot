# DOCUMENTATION_MAP

## 목적

이 문서는 `ninja-survival-godot` 저장소의 활성 문서 역할과 권위 경계를 구분한다.

## 핵심 문서

| 문서 | 역할 | 상태 |
|---|---|---|
| `AGENTS.md` | AI/Codex 최상위 작업 규칙, 단계형 MVP·안전·실행 경계 | current |
| `README.md` | 저장소 소개와 현재 MVP 요약 | MVP-4 design sync |
| `PROJECT_BRIEF.md` | 프로젝트 약속, 장르, 핵심 경험, 4유파와 핵심 loop | MVP-4 design sync |
| `DESIGN_INTENT.md` | 전투 DDD, 휴식/백팩 설계 원칙, 벤치마킹 반영 | MVP-4 design sync |
| `MVP_ROADMAP.md` | MVP-0~MVP-5 단계별 범위와 완료 기준 | MVP-4 승인 범위 동기화 |
| `docs/CURRENT_CONFIRMED_DECISIONS.md` | 최신 사용자 승인 제품/설계 Decision 복원 원장 | MVP-4 `DESIGN_APPROVED` |
| `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` | MVP-4 L2 detailed design: 규칙·UX·입력·오류·검증 계약 | `APPROVED` |
| `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md` | 승인 Spec Requirement/AC를 구현 Task·path·Verification에 연결하는 L3 packet | written, `coverage_status: GAP` until implementation evidence exists |
| `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md` | TDD 기반 MVP-4 implementation plan | written / production gate pending `기획 완료` |
| `docs/ACTIVE_CONTEXT.md` | 현재 baseline, 구현/검증 상태, next executable step resume router | current planning state |
| `docs/handoffs/*.md` | 날짜별 session/handoff snapshot | history / resume evidence |
| `TEST_CHECKLIST.md` | 공용 실행/검수 체크리스트 | existing; MVP-4 actual evidence는 L3/validation records가 소유 |
| `docs/BASE_RULES_VERSION.md` | 마지막 프로젝트 Base sync와 최신 원격 관찰 분리 | latest remote observed, full sync NOT_RUN |
| `docs/UNITY_MIGRATION_AUDIT.md` | Unity 원본 분석 | historical/reference |
| `docs/GODOT_PORT_PLAN.md` | Godot 전환 계획 | implementation truth 대체 금지 |
| `docs/SYSTEM_MAP.md` | 실제 시스템 책임과 MVP-4 확장 경계 | MVP-4 design sync |
| `docs/CODEX_GOAL_MVP_001.md` | 과거 MVP-0 실행 지시문 | historical executed goal |

## MVP-4 현재 문서 체인

```text
latest user approval
→ docs/CURRENT_CONFIRMED_DECISIONS.md
→ approved L2 feature spec
→ L3 traceability packet
→ Superpowers implementation plan
→ explicit user `기획 완료`
→ production BUILD / executed verification
```

- `CURRENT_CONFIRMED_DECISIONS.md`는 현재 Decision과 보호 범위를 복원하며 상세 Spec을 장문 복제하지 않는다.
- L2 Spec은 플레이어 경험·규칙·상태·입력·피드백·acceptance criteria를 소유한다.
- L3 Packet은 L2 Requirement/AC를 Task·구현 경로·Verification ID에 연결한다. 실제 구현이 없으므로 현재 `GAP`가 정상이다.
- Implementation Plan은 실행 순서·파일·TDD cycle을 정의하지만 구현 완료나 검증 PASS를 소유하지 않는다.
- `ACTIVE_CONTEXT.md`는 mutable state/router다.
- 실제 code/Scene/data/test 상태가 계획과 다르면 계획을 구현 사실처럼 우선하지 않는다.

## 현재 단계

```yaml
mvp4_design: APPROVED
mvp4_written_spec: APPROVED
mvp4_traceability: WRITTEN_COVERAGE_GAP
mvp4_implementation_plan: WRITTEN
mvp4_production_build: BLOCKED_PENDING_EXPLICIT_기획_완료
mvp4_runtime_verification: NOT_RUN
```

사용자의 written-spec 승인은 L3/implementation planning을 허용한다. 프로젝트 delivery instruction의 production 전환 조건은 별도이며, **`기획 완료` 선언 전 Godot/Codex production BUILD를 시작하지 않는다.**

## 권위 충돌 처리

```text
latest user approval
→ AGENTS / project safety rules
→ docs/CURRENT_CONFIRMED_DECISIONS.md
→ current detailed feature/domain canon
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
- UI never becomes spatial/economy/reward/combination authority.

과거 활성 문서에 `rotation excluded`, 현재 규칙처럼 쓰인 `5/10/15 midboss`, 또는 `owned_items` count를 MVP-4 최종 modifier authority로 복원하는 표현이 나오면 freshness finding으로 처리한다.

## Google Sheets 상태

프로젝트 GDD Google Sheets는 user-facing workspace이며 GitHub 정본을 대체하지 않는다.

2026-08-11 감사에서 일부 tab에 과거 rotation/timing 표현이 남아 있음을 확인했고 write 요청은 `403 PERMISSION_DENIED`로 실패했다.

```yaml
sheet_sync_state: GITHUB_UPDATE_PENDING_SHEET
write_state: BLOCKED_USER_ACTION_403
```

권한이 복구되기 전 Sheet를 `SYNCED`로 보고하지 않는다.

## 작업 기준

- 과거 문서만으로 현재 구현 완료를 추정하지 않는다.
- Godot 구현 문서는 Godot/GDScript 용어로 작성한다.
- 최신 Base와 프로젝트 current canon은 작업에 필요한 범위에서 대조한다.
- 벤치마크는 표면 복제가 아니라 문제·trade-off 검증에 사용한다.
- 승인 Decision 변경은 Decision 원장과 상세 Spec을 먼저 갱신한 뒤 Traceability/Plan을 재대조한다.
- Plan의 파일명·API가 actual repository와 충돌하면 BUILD 전에 plan을 고친다.
- Handoff/ActiveContext가 repository truth와 충돌하면 repository truth로 교정한다.
- production BUILD는 explicit `기획 완료` 전 금지한다.