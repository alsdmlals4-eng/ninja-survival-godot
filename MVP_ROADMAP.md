# MVP_ROADMAP

## 목적

기존 `MVP-0~MVP-5` 번호를 유지하면서, 최신 DEC-014~026과 실제 구현 진행을 분리해 관리한다.

게임 내부의 `Stage 1~4`와 개발 로드맵 번호를 혼동하지 않는다.

## 현재 공식 MVP 상태

```yaml
MVP_0_BASIC_COMBAT: INTEGRATED
MVP_1_COMBAT_DDD: INTEGRATED
MVP_2_FOUR_SCHOOLS_SHALLOW: INTEGRATED
MVP_3_RESULT_REST_SHOP_FATE: INTEGRATED_ROLLBACK_BASELINE
MVP_4_BACKPACK_COMBINATION: T01_T02_T03_T04_INTEGRATED_NEXT_T05
MVP_5_FINAL_LOOP_META: NOT_STARTED
DEC014_025_MIGRATION_OVERLAY: DOCUMENTED_NOT_IMPLEMENTED
DEC026_ENCOUNTER_PATTERN_BUDGET: APPROVED_NOT_IMPLEMENTED
PHASE_B: PASS
NEXT_IMPLEMENTATION_GATE: T05_COMBINATION_RESOLVER
RELEASE_NEAR_VERTICAL_SLICE_HUMAN_QA: NOT_RUN
```

최신 DEC-014~026은 기존 MVP 번호를 폐기하는 새 MVP 번호 체계가 아니라, **MVP-4/5가 실제 제품 Run과 연결될 때 따라야 할 migration/encounter overlay**다.

## 제품 전체 검증 질문

1. 자동 생존 전투와 DDD가 짧게 재미있는가?
2. 네 유파가 이름/색만 다른 것이 아니라 위험 처리 방식이 다른가?
3. 전투 보상이 Workbench 판단으로 이어지는가?
4. 백팩 공간·회전·인접·조합이 빌드 기억을 만드는가?
5. 다음 유파 선택이 현재 빌드와 의미 있는 trade-off를 만드는가?
6. 네 유파를 평정한 뒤 별도 최종전이 피로가 아니라 climax로 느껴지는가?
7. 한 판 뒤 다른 시작 유파/순서/빌드를 시험하고 싶어지는가?

# MVP-0 — 기본 전투 기반 · INTEGRATED

검증 범위:

- 8방향 이동
- 카메라
- 적 추적
- 자동 공격
- 피격/처치
- HUD
- 게임오버/restart

현재 구현/테스트를 회귀 보호한다.

# MVP-1 — Combat DDD · INTEGRATED

검증 범위:

- kill combo / max combo
- stylish score
- reward absorption feedback
- timed wave pressure

현재 회귀 baseline을 보호한다.

# MVP-2 — 4유파 얕은 구현 · INTEGRATED BASELINE

현재 대표 runtime은 존재한다.

장기 제품 정체성:

| 유파 | 위험 처리 철학 |
|---|---|
| 봉마 | 이동형 진지 · 식신/결계로 공간을 준비하고 대신 싸우게 한다 |
| 천술 | 상태를 만들고 원소 반응으로 전장을 바꾼다 |
| 귀인 | 위험한 근접 체류를 유지할수록 강해진다 |
| 흑영 | 위험 표적을 표식/우선순위/처형으로 먼저 제거한다 |

현재 봉마 fixed ward / 귀인 low-HP bonus / 흑영 nearest-target rule은 삭제하지 않고 대표 Vertical Slice tuning 후보로 둔다.

# MVP-3 — 결과/휴식/상점/운명 skeleton · INTEGRATED ROLLBACK BASELINE

현재 실제 구현:

`SCHOOL_SELECT -> COMBAT -> BOSS -> RESULT -> SHOP -> FATE -> PREVIEW -> three-segment COMPLETE`.

이 흐름은 최신 제품 Run target이 아니라 **검증된 rollback/regression baseline**이다.

새 DEC 행동을 구현하는 TDD package에서 의도적으로 교체되기 전까지 해당 테스트를 보호한다.

# MVP-4 — 백팩/조합 기초 · T01/T02/T03/T04 INTEGRATED / T05 NEXT

목표:

> 휴식 중 백팩의 공간 판단이 다음 전투 성능과 다음 경로 선택을 바꾸는지 검증한다.

보호 범위:

- 6x6 board / 4x3 start
- purchasable bag expansion
- item + bag 90-degree rotation
- rectangular regular items + selected L/T bags
- six-slot REST work buffer
- orthogonal adjacency
- one-cell special-bag overlap
- explicit atomic first-tier combinations
- Boss / Shop / Chest acquisition pillars
- Persistent Workbench
- deterministic domain state/resolution separated from UI
- mouse / keyboard-gamepad focus / touch completion paths

## T01 — Spatial Data Contracts / Catalog · INTEGRATED

PR #27 merged as `7c9206702526f99dfadf44a617cd150853ec733f`.

Implemented:

- extend existing `ItemDefinition` instead of creating a second item authority,
- `RunModifierSet` supported modifier-field validation,
- bounded `SpatialRuleDefinition`,
- one starting 4x3 bag + five purchasable bag definitions,
- 19 base acquisition items + 3 combination-result lookup definitions,
- 8 strong-spatial base-item contracts,
- 3 first-tier combination definitions,
- explicit base/result acquisition boundaries,
- unsupported modifier key / non-numeric payload validation,
- existing MVP-3 item values and sell runtime compatibility.

Verification:

`Godot 4.7.1 import PASS -> main smoke PASS -> GUT 263/263 PASS -> 1829 assertions PASS`.

Evidence ceiling: **data foundation only**. Placement legality, adjacency resolution, REST editing and playable Workbench remain unimplemented at the T01 evidence level.

## T02 — BackpackState · INTEGRATED

PR #29 merged as `126e6c942d74f97166ef0c881afc5d79cae3d274`.

Implemented:

- `ItemInstance` / `BagInstance` value objects,
- one committed `BackpackState` authority,
- fixed 6x6 board and centered starting 4x3 active area,
- shared monotonic item/bag instance ids,
- origin and normalized 90-degree rotation,
- atomic add/move/remove/rotate,
- inactive-cell rejection and board bounds,
- item-item / bag-bag collision rejection,
- bag expansion/shrink active-area facts and orphan prevention,
- defensive public collection snapshots and `copy_value()` isolation,
- T04-validated stable-ID restore owner paths for buffered/reconstructed existing instances.

Adversarial review found a live `items`/`bags` view mutation bypass and closed it before merge. T04 later verified the restore paths reject item↔bag shared-ID collisions and do not advance IDs on failed restore.

Final exact-head verification:

`Godot 4.7.1 import PASS -> main smoke PASS -> GUT 274/274 PASS -> 1915 assertions PASS -> T02 focused 11/11 PASS`.

Evidence ceiling: **committed spatial-state domain engine only**. Adjacency/connectivity/special-bag resolution, REST editing, combinations, UI and Human play remain later gates.

## T03 — BackpackResolver · INTEGRATED

PR #31 merged as `2dcf055d82df02d44335f209897436572efa6739`.

Implemented:

- read-only deterministic resolver over T02 defensive snapshots,
- 4-neighbor connected active-layout legality,
- orthogonal adjacency canonical once per distinct item pair,
- data-driven T01 spatial-rule aggregation with distinct-neighbor caps,
- one neighbor matching tag + definition id still counted once,
- one-cell-or-more special-bag overlap activation once per distinct bag instance,
- static + selected-school emblem modifier snapshot,
- reasoned candidate item/bag legality previews,
- all-or-nothing whole-layout translation preview,
- deterministic failure cells and independent resolution snapshots,
- fail-closed behavior for missing definitions.

Adversarial review added direct coverage for rule caps/selector semantics and found/fixed the null-state diagnostic misclassification before merge.

Final exact-head verification:

`Godot 4.7.1 import PASS -> main smoke PASS -> GUT 292/292 PASS -> 2026 assertions PASS -> T03 focused 18/18 PASS`.

Evidence ceiling: **deterministic spatial-resolution domain engine only**. REST editing/session history, combinations, playable Workbench UI, committed combat integration and Human play remain later gates.

## T04 — RestBackpackSession · INTEGRATED

PR #33 merged as `d07f16d6bae90a09bba0a5f0b8991216d006c966`.

Implemented:

- session-owned copy of committed T02 state,
- exact six-slot REST work buffer,
- board→buffer removing spatial effects and legal buffer→board restoring stable item identity,
- defensive `BuildPreviewSnapshot` separated from committed/session state,
- selected-school preview modifier context through T03,
- deep edit history / undo / redo and new-edit redo clearing,
- non-history pending-bag acquisition as an edit-history barrier,
- explicit mutually-exclusive whole-layout movement mode,
- all-or-nothing whole-layout translation preserving future instance-ID cursor,
- deterministic commit-readiness failures for pending buffer/bag/preview, active whole-layout mode and invalid resolved state,
- defensive public state/buffer/pending-bag/preview boundaries.

Adversarial review found and fixed three session/control issues: a valid visible preview could pass the commit gate without being committed; whole-layout mode initially allowed per-item edits; and active whole-layout mode initially did not block later commit.

Final exact-head verification:

`Godot 4.7.1 import PASS -> main smoke PASS -> GUT 309/309 PASS -> 2202 assertions PASS -> T04 focused 17/17 PASS`.

Evidence ceiling: **REST backpack edit-session domain engine only**. Combination transaction, actual Workbench UI/input UX, committed combat integration and Human play remain later gates.

## T05 — CombinationResolver · NEXT

T05 consumes T01/T02/T03/T04 and owns explicit first-tier combination transactions:

- only valid orthogonally adjacent on-board source pairs are eligible,
- progressive hints distinguish ingredient-owned / ready / discovered state,
- begin result preview preserves both source instances,
- invalid result placement and cancel preserve both sources,
- legal commit consumes exactly two sources once and creates exactly one result,
- repeated commit is ignored,
- first success marks discovery.

Do not move GOLD/Fate/economy orchestration, Workbench UI authority or T06 final combat modifier authority into T05.

# MVP-5 — 최종 Run / 결과 / Ninja Soul · NOT_STARTED

기존 명칭은 유지하되 최신 DEC-014~026에 따라 최종 Run 구조를 다음처럼 해석한다.

```text
4유파 battlefield를 정확히 한 번씩 순회
-> fourth school Boss
-> Final Binding Workbench
-> separate final calamity battle
-> final result / Ninja Soul / replay motivation
```

`약 20분`은 fourth school Boss까지의 active-combat 목표치이며, final rest/final battle은 별도 시간이다.

보호 규칙:

- 4흔적 결속은 새 자동 upgrade tree가 아니다.
- Final Binding은 모든 access package가 열린 마지막 Persistent Workbench다.
- Final Boss는 앞서 배운 학교 문법을 재조합한다.
- 해방된 4유파가 clear order에 따라 각 1회 짧게 지원한다.
- 지원은 위험 완화/공격 창이며 자동 승리가 아니다.
- 실제 최종 승리와 결정타는 플레이어 backpack build가 담당한다.
- Ninja Soul은 Run 결정을 압도하는 영구 공격력/체력 누적보다 horizontal unlock/option/convenience 방향을 우선한다.

DEC-026은 학교별 encounter/pattern budget을 승인했지만 final calamity의 exact full attack script는 후속 final-boss planning/implementation 대상이다.

# DEC-014~026 Migration Overlay

## Overlay A — Four-School Circuit

```text
starting school
-> choose unvisited school
-> school battlefield
-> Core Monsters + current Stage gimmick
-> ~3m Elite
-> chest token + trace
-> trace recovery
-> ~5m school Boss
-> RESULT / Boss Reward
-> joint branch / trace STABILIZED
-> Persistent Workbench
-> provisional next school
-> Fate commit
-> repeat until all four schools are cleared exactly once
```

핵심 구조:

- `school` = encounter identity,
- 게임 내부 `Stage 1~4` = difficulty/gimmick-depth profile,
- trace = tradition acquisition access, not automatic power,
- next school = player choice among unvisited routes,
- Fate atomically commits build + Fate + next route.

상세 요구사항: `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`.

## Overlay B — Encounter Content Gate · DEC-026 APPROVED

첫 콘텐츠 상한:

- Core Monster 12 = 3 x 4 schools
- Elite 4
- School Boss 4
- School gimmick libraries 4

게임 내부 Stage gimmick depth:

- Stage 1 base signature
- Stage 2 + interaction gimmick
- Stage 3 + synergy/field gimmick
- Stage 4 mastery + one Boss capstone
- concurrent advanced-gimmick default cap 2

DEC-026 approved the **shared attack primitives + school-owned encounter compositions** architecture. Current runtime implementation remains NOT_STARTED.

## Overlay C — One-School Release-Near Vertical Slice · NOT_RUN

4유파 콘텐츠 전체를 제작하기 전에 **천술류**로 다음 end-to-end를 먼저 완성한다.

```text
signature within ~30 sec
-> Core Monster pressure
-> Elite
-> trace
-> Boss
-> result/reward
-> branch Workbench
-> next-route preview
```

Human gate:

- school identity readability,
- combat pacing/tension,
- Elite/Boss telegraph fairness,
- trace readability,
- Workbench comprehension,
- placement/combination decision value,
- rest duration/fatigue,
- Korean UI readability,
- production-candidate visual/audio/VFX coherence.

Card/text placeholder는 이 Human PASS를 대신할 수 없다.

## Overlay D — Final Binding / Final Calamity · PARTIAL SPEC

Four-school circuit 완료 뒤:

`fourth Boss -> RESULT -> Final Binding Workbench -> final Fate/build commit -> 난세 재앙핵`.

현재 approved structure와 DEC-026에서 재사용 가능한 encounter language를 보호하되, final calamity exact full script는 후속 구현/검증에서 닫는다.

# 구현 순서

```text
T01 Spatial Data Contracts · INTEGRATED
-> T02 BackpackState · INTEGRATED
-> T03 BackpackResolver · INTEGRATED
-> T04 RestBackpackSession · INTEGRATED
-> T05 CombinationResolver · NEXT
-> T06 committed RunBuildState migration
-> T07 acquisition transaction foundation
-> T08~T14 post-DEC-026 packages
-> T15 human QA
-> remaining three-school content multiplication
-> final binding/final calamity implementation
-> full-run QA / Android / export / release work
```

새 package는 PR #33이 병합된 fresh `main`에서 시작한다.

# 현재 제외 / 후속

- full deep skill trees for all four schools
- second/third-tier combinations
- arbitrary complex regular-item polyomino system
- deep set/curse/rarity layers
- base-building/economy management core
- permanent Meta stats that dominate Run choices
- large branching ending campaign
- full release balance before representative Vertical Slice proves the core

# 성공/재검토 기준

성공:

- 한 유파 Vertical Slice만으로 전투->Elite->trace->Boss->Workbench 감정 변화가 읽힌다.
- backpack 배치가 실제 다음 전투/경로 기대를 바꾼다.
- route order가 전략을 만들지만 정답 경로 하나로 고정되지 않는다.
- 4유파 확장 후에도 shared framework로 제작비가 통제된다.
- final battle이 플레이어 build를 무력화하지 않는다.

재검토:

- 첫 유파 5분이 반복적이거나 의미 없이 길다.
- Workbench가 매번 과도하게 길어져 Run 피로를 만든다.
- school identity보다 common auto-combat가 더 강하게 느껴진다.
- route order가 특정 school-last 정답으로 수렴한다.
- content multiplication cost가 framework 재사용보다 빠르게 증가한다.
