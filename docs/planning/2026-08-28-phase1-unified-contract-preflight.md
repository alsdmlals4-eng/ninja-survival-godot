# Phase 1 단일 구현계약 사전점검 — 2026-08-28

```yaml
status: PHASE_1_PLANNING_CO_DESIGN_IN_PROGRESS
implementation_contract: NOT_YET_AUTHORED
phase_2_preproduction_review: BLOCKED_BY_OPEN_PHASE_1_DECISIONS
phase_3_element_production: NOT_STARTED
phase_4_codex_implementation: NOT_STARTED
phase_5_user_vertical_slice_validation: NOT_RUN
completed_main_read: bebff40f2a327bca19ca32d01d03631449314945
open_prs_read_only:
  - PR_49_DRAFT_SUPERSEDED_T12_REFERENCE
```

## 1. 목적과 증거 경계

이 문서는 승인된 Phase 1 결정을 하나의 후속 구현계약으로 묶기 전의 **actual-state 대조 기록**이다. 구현 명령, 새 Godot Scene/Node/Resource, runtime asset 제작, Human/Player PASS 선언은 포함하지 않는다.

Fresh-read한 현재 owner는 다음과 같다.

- Repository: `docs/CURRENT_CONFIRMED_DECISIONS.md`, DEC-014~025, DEC-026, DEC-027, DEC-028, `docs/ACTIVE_CONTEXT.md`, actual `scripts/`, `scenes/`, `tests/`.
- Human-facing Notion: `08 · 핵심 시스템 · 상세` (`3c11b237-eb1c-8152-8974-cfbd10c889c0`), `02 · 비주얼 바이블` (`3c01b237-eb1c-8116-9028-c8c8c427e467`), `06 · Production · Handoff` (`3c01b237-eb1c-81b4-a3f5-ec575f3c77b5`).
- Base five-phase interface: `WORK_PROJECT_EXECUTION_CURRENT_ROUTER.md` and `WORK_FIVE_PHASE_VERTICAL_SLICE_EXECUTION_CONTRACT.md`; it is a shared lifecycle interface, not a replacement project canon.

## 2. 이 단계에서 확정된 입력

- **DEC-027:** 천술류는 직접 주문 조준 없이 이동·적 군집으로 읽을 수 있는 공간 조건을 만들고 자동 반응의 고가치 결과를 읽는다.
- **DEC-028:** 그 공간 조건은 자동 `WET` 시전 지점에 짧게 남는 고정 청색 준비 결계다. 다음 자동 `SHOCK`은 결계 안의 준비된 군집을 우선한다.
- **Combat visual grammar:** 상태는 작은 아이콘, 적 HP는 기본 숨김 후 피격된 적 하나만 표시, 천술류는 청색 + 호박/주황이다.
- **Visual-board boundary:** 현재 네 패널 보드는 `REFERENCE_ONLY GENERATED_EXPLORATION`이다. runtime asset, Scene/UI 구현, Human Usability/Player Experience PASS가 아니다.
- **DEC-029:** 사용자는 C안을 선택했다. 네 유파 모두의 완결 lifecycle과 shared four-school circuit을 구현·machine 검증한 뒤 첫 Human/Player validation을 연다.
- **DEC-030:** 사용자는 A안을 선택했다. 첫 Human/Player validation은 네 번째 Boss Result/Reward가 `final_binding_eligible`을 확인하는 지점에서 끝난다. Final Binding Workbench·final calamity·ending은 이후 별도 package다.
- **DEC-031:** 기본 사망은 Run 전체 종료와 one-checkpoint retry의 경계를 소유한다. 재도전 통화와 영구 지갑 금지 범위는 DEC-033으로 supersede됐다.
- **DEC-032:** 사용자는 C안을 선택했다. 첫 30초에 강제 안내를 넣지 않고, 원할 때 현재 선택 유파의 확장된 한국어 도움말을 읽는다. 도움말은 무보조 첫인상 검증을 대체하지 않는다.
- **DEC-033:** 사용자는 Boss-only Ninja Soul을 승인했다. 런 종료에 distinct Boss × 2 + rank C/B/A/S = 0/1/2/4를 한 번 정산하고, retry는 persistent Ninja Soul 1을 쓴다. GOLD는 normal 20% × 1G / Elite 5G / Boss 10G로 분리한다.

## 3. 실제 대조 findings

| ID | 판정 | 실제 근거 | 단일 구현계약 영향 | 사용자 결정 |
|---|---|---|---|---|
| F-01 | `PARTIAL` | `CheonsulRuntime`은 1.8초 간격의 자동 `WET`/`SHOCK`과 일반 `WET` 우선 타기팅만 가진다. | 고정 청색 준비 결계·결계 안 군집 우선·안전한 유도 피드백을 새로 연결해야 한다. | 수치와 QA floor는 계약에서, core meaning은 DEC-028로 확정. |
| F-02 | `CONFLICT` | DEC-024는 Trace의 settle/homing/근거리 자동 획득을 소유하지만, `MainController`와 `HUD`는 `R`/버튼으로 즉시 `recover_trace()`를 호출한다. | Trace object/자동 회수/보스 gate UI를 정본으로 재정렬한다. | 불필요 — 승인 canon을 구현이 따라야 한다. |
| F-03 | `CONFLICT` | `EnemyEffectBadge`는 `Label`이며 `BURN`/`WET`/`SHOCK` 단어를 렌더한다. `EnemyChaser`에는 enemy HP UI가 없다. | 아이콘 상태와 ‘피격된 적 하나만’ HP 표시를 별도 presentational owner로 추가해야 한다. | 불필요 — 사용자 승인 visual grammar를 따른다. |
| F-04 | `CONFLICT` | `EncounterCatalog`에는 천술류 Core 3 / Elite / Boss와 `fan_or_arc_projectile`, `telegraphed_zone`, `mark_or_link` data가 있으나, 실제 Slice는 generic `EnemyChaser`와 `StageBoss`를 생성한다. | shared primitive + Cheonsul composition을 data-first로 실제 runtime에 연결하고, DEC-026의 telegraph/concurrency budget을 검증한다. | 불필요 — DEC-026이 제품 범위를 이미 소유한다. |
| F-05 | `BLOCKING_GAP` | T12 domain transaction은 존재하지만 Cheonsul Workbench UI는 보상 후보를 읽기만 하며 선택·6×6 배치·회전·조합·가방 입력을 제공하지 않는다. commit은 `boss_reward_pending`으로 막힌다. | Boss reward → spatial Workbench → provisional route/Fate → atomic commit의 실제 입력 경로를 구현 범위에 포함해야 한다. | 불필요 — 보호 규칙과 T12 boundary가 이미 확정. |
| F-06 | `WEAKNESS` | Cheonsul 선택 시 HUD의 `TEST · 정예 소환`/`TEST · 중간 보스 소환`이 현재 일반 combat controls와 함께 보인다. HUD에는 다수의 영문 운영 라벨도 남아 있다. | 검증용 점프는 player-facing slice에서 격리하고, 핵심 runtime 한국어 문구/정보 위계를 visual QA 항목으로 만든다. | 불필요 — release-near consumer와 테스트 도구를 분리한다. |
| F-07 | `NOT_RUN` | GitHub GUT/Windows internal build evidence는 존재하지만 Ninja Survival의 live render, Human Usability, Player Experience, touch/device/export는 현재 증명되지 않았다. | Phase 4의 machine evidence와 Phase 5의 실제 Human Slice를 분리한다. | 불필요 — evidence ceiling을 낮추지 않는다. |
| F-08 | `CONFLICT` | `RunBuildState`는 normal kill마다 확정 `1G`, Boss마다 `25G`를 주며 Elite reward·rank·persistent Ninja Soul wallet·Run-end settlement owner가 없다. | DEC-033의 normal chance / Elite 5G / Boss 10G / Boss-only Soul / Result settlement를 data·runtime·save·UI·test 단일 contract로 교체해야 한다. | 불필요 — 사용자 승인 DEC-033을 구현이 따라야 한다. |

## 4. 첫 Grill Me — 검증 진입 경계 · RESOLVED

현재 제품 약속은 네 유파 중 시작 학교를 고르는 구조지만, release-near로 증명해야 할 것은 먼저 **천술류 한 학교의 완결된 Core → Elite → Trace → Boss → Workbench → 다음 경로**다. 현재 `SchoolSelectionUI`는 네 유파를 모두 선택하게 하지만, 완결 lifecycle은 Cheonsul에만 연결되어 있다.

사용자는 다음 세 가지 중 **C**를 승인했다. 이 선택은 종전의 Cheonsul-only Human gate를 현재 package에서 supersede한다.

| 후보 | Player value | 제작비/위험 | 되돌리기 | 추천 |
|---|---|---|---|---|
| A. Cheonsul 검증 진입으로 한정 | 누구도 legacy 경로를 release-near slice로 오인하지 않는다. 첫 5분의 promise를 한 경험으로 검증한다. | 선택 화면의 진입 규칙/안내를 조정하지만 네 유파 lifecycle 동시 구현을 피한다. | 높음 — 이후 네 유파가 준비되면 원래 선택 규칙을 복원한다. | 미채택 |
| B. 네 유파 선택은 유지, Cheonsul만 검증 안내 | 전체 세계관의 폭은 즉시 보인다. | 플레이어가 비완결 경로를 선택해 핵심 Slice 평가를 흐릴 위험이 크다. | 높음 | 비추천 |
| C. **네 유파 모두 완결 lifecycle로 올린 뒤 검증** | 시작 선택·route·Workbench 약속을 실제 four-school circuit으로 검증한다. | 네 유파 composition/Workbench/QA 범위가 커지고 최초 Human evidence가 늦어진다. | 낮음 | **사용자 승인** |

이는 구현 세부가 아니라 **이번 Human/Player validation에서 플레이어에게 무엇을 약속하는가**를 정하는 product boundary다. C안과 DEC-030 final package 경계, 아래 DEC-031/033 failure/retry/settlement 경계, DEC-032 선택형 도움말 경계가 확정됐다. 남은 material decision은 Trace/Workbench/encounter/UI consumer의 계약 값 대조이며, 이 문서는 `PHASE_1_PLANNING_CO_DESIGN_IN_PROGRESS`를 유지한다.

## 5. 두 번째 Grill Me — final package 경계 · RESOLVED

제품 canon은 네 유파 뒤 Final Binding Workbench와 최종 재앙을 약속하지만, 실제 `RunRouteState`는 현재 `final_binding_eligible` 상태까지만 소유한다. 사용자는 아래 후보 중 **A**를 승인했다.

| 후보 | Player value | 제작비/위험 | 되돌리기 | 판정 |
|---|---|---|---|---|
| A. **네 번째 Boss 뒤 Final Binding 진입 자격까지** | 네 유파 선택·route·Workbench의 가치와 가독성을 먼저 검증한다. | 최종 Boss/ending 가설을 별도 유지해 현재 contract 폭증을 막는다. | 높음 | **사용자 승인 / 권장** |
| B. Final Binding Workbench까지만 | 마지막 build 결산 감각을 먼저 확인한다. | final battle 없이 긴 준비만 남아 product payoff를 오해시킬 수 있다. | 중간 | 미채택 |
| C. Final Binding·최종 재앙·결과까지 | 전설이 되는 full-Run 결산을 한 번에 경험한다. | 2-phase Boss·4유파 support·ending·QA가 동시 확대된다. | 낮음 | 미채택 |

DEC-030은 최종 결산을 삭제하지 않는다. first Human test에서 Final Binding availability만 명확히 확인하고, 최종 패키지는 DEC-018/020/022를 다시 review하는 별도 계약으로 연다.

## 6. 다음 순서

1. DEC-029/030/031/032 경계에 맞춰 선택형 도움말, Trace/Workbench/visual consumer의 기존 정본과 실제 code 차이를 재검토한다.
2. 아직 승인되지 않았고 제품 의미를 바꾸는 핵심 결정만 한 건씩 Grill Me로 확정한다.
3. 남은 material decision이 없을 때만 단일 구현계약과 Phase 2 preproduction review packet을 작성한다.

## 7. 세 번째 Grill Me — 패배와 재도전 · RESOLVED

현재 구현은 player death 뒤 `Game Over`를 보이고 scene을 reload해 Run 전체를 새로 시작한다. canon에는 death/retry persistence owner가 없었다. 사용자는 **B+A**를 승인했다.

| 후보 | Player value | 제작비/위험 | 판정 |
|---|---|---|---|
| A. 직전 Workbench부터 같은 학교 재도전 | 4유파 circuit과 Boss 학습을 이어가되, 이전 commit 선택은 보호한다. | checkpoint/restore/no-duplication contract가 필요하다. | **A 요소 채택** |
| B. Run 전체 초기화 | 생존 실패와 route/Build 선택의 무게를 지킨다. | 현재 구현과 가깝지만 20분 circuit 검증 피로가 크다. | **기본 규칙 채택** |
| C. 즉시 부활/부활 token | 초반 실패를 낮춘다. | 새 자원·UI·밸런스와 위험 약화가 크다. | 기각 |

승인 규칙: 기본은 B, 단 한 Run에 한 번 valid Workbench checkpoint가 있으면 persistent Ninja Soul `1`을 지불해 A 방식으로 같은 활성 학교를 `0:00`부터 다시 시작한다. failed-school transient reward/Trace/progress는 모두 잃는다. DEC-033의 distinct Boss eligibility만 Run-end settlement까지 idempotently 보존한다.

## 8. 네 번째 Grill Me — 첫 30초 설명 접근 · RESOLVED

정본은 첫 `0:00–0:30`에 유파 시그니처가 읽혀야 한다고 요구하지만, 실제 구현의 `show_school_feedback()`은 짧은 문장이고 상세 설명은 선택형 전투 HUD 도움말뿐이다. 사용자는 다음 중 **C**를 선택했다.

| 후보 | Player value | 제작비/위험 | 판정 |
|---|---|---|---|
| A. 행동→결과 마이크로 안내 | 자동전투 중에도 무엇을 시도할지 즉시 안다. | 유파별 성공 이벤트·표현을 강제로 연결해야 하며, 첫 진입을 방해할 수 있다. | 미채택 |
| B. 전투 전 설명 카드 | 규칙을 가장 명시적으로 읽는다. | 시작 흐름을 멈추고 4개 카드/스킵/UI 범위를 늘린다. | 미채택 |
| C. **원할 때 읽는 확장 도움말** | 필요할 때 실제 행동·정보·결과를 다시 확인한다. | 무보조 첫인상 문제를 스스로 해결하지 못하며, 문구와 runtime의 동기화가 필요하다. | **사용자 승인** |

승인 규칙: 현재 선택 유파의 기존 전투 `기능 도움말` 경로에서 더 명확한 한국어 설명을 제공한다. 강제 prompt/card/marker는 추가하지 않는다. 상태는 compact icon-first를 지키며, 도움말을 읽은 뒤의 이해는 첫 30초 무보조 Human 가독성 `PASS`의 대체 근거가 아니다.
