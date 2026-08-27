# MVP_ROADMAP

## 목적

기존 `MVP-0~MVP-5` 번호를 유지하면서 최신 DEC-014~026 제품 방향과 실제 merged implementation 상태를 분리해 관리한다.

게임 내부 `Stage 1~4`와 개발 Task `T01~T19`를 혼동하지 않는다.

## 현재 공식 상태 — 2026-08-27 fresh readback

```yaml
last_product_implementation_merge: 63fcf81fdf4b5d1bbff14b5721a13f7c1afe1497
current_github_main: f77a1c86660784c1a20c9f2a9abfee7b774ba911
MVP_0_BASIC_COMBAT: INTEGRATED
MVP_1_COMBAT_DDD: INTEGRATED
MVP_2_FOUR_SCHOOLS_SHALLOW: INTEGRATED_MIGRATION_BASELINE
MVP_3_RESULT_REST_SHOP_FATE: INTEGRATED_ROLLBACK_BASELINE
MVP_4_BACKPACK_COMBINATION_AND_ROUTE_FOUNDATION: T01_TO_T16_MACHINE_SCOPE_INTEGRATED
MVP_5_FINAL_LOOP_META: NOT_STARTED_AS_COMPLETE_PRODUCT
DEC014_025_MIGRATION_OVERLAY: APPROVED_PARTIAL_DOMAIN_IMPLEMENTATION
DEC026_ENCOUNTER_PATTERN_BUDGET: APPROVED_PARTIAL_DOMAIN_IMPLEMENTATION
NEXT_PRODUCT_GATE: USER_VERTICAL_SLICE_VALIDATION_DEFERRED
CLOSED_WIP_REFERENCES: PR_43_T12_AND_PR_44_FRONT_DOOR
RELEASE_NEAR_VERTICAL_SLICE_HUMAN_QA: NOT_RUN
DEVICE_ANDROID_EXPORT: NOT_RUN
```

`T01~T16 machine scope integrated`는 실제 code/test/domain/UI-help evidence를 뜻한다. 새 Run 전체 playable, production-quality UI/visual/audio, Human/Player Experience, device/export PASS로 승격하지 않는다.

## 제품 전체 검증 질문

1. 자동 생존 전투와 DDD가 짧게 재미있는가?
2. 네 유파가 이름/색이 아니라 위험 처리 방식으로 구분되는가?
3. Core→Elite→Trace→Boss의 5분 전장이 유파 학습과 결산을 만드는가?
4. 전투 보상이 Workbench 판단으로 이어지는가?
5. 백팩 공간·회전·인접·조합이 빌드 기억을 만드는가?
6. 다음 유파 선택이 현재 빌드와 의미 있는 trade-off를 만드는가?
7. 네 유파 평정 뒤 Final Binding과 별도 최종전이 피로가 아니라 climax인가?
8. 한 판 뒤 다른 시작 유파/순서/빌드를 시험하고 싶어지는가?

# MVP-0 — 기본 전투 기반 · INTEGRATED

회귀 보호:

- 8방향 이동
- 카메라
- 적 추적
- 자동 공격
- 피격/처치
- HUD
- game over / restart

# MVP-1 — Combat DDD · INTEGRATED

회귀 보호:

- kill combo / max combo
- stylish score
- reward absorption feedback
- timed pressure
- result contribution signals

이 증거는 combat feedback foundation이며 전체 Run 재미 PASS가 아니다.

# MVP-2 — 4유파 얕은 구현 · INTEGRATED MIGRATION BASELINE

장기 정체성:

| 유파 | 위험 처리 철학 |
|---|---|
| 봉마 | 이동형 진지 · 식신/결계로 공간을 준비하고 대신 싸우게 한다 |
| 천술 | 상태를 만들고 순서/조합으로 원소 반응을 일으킨다 |
| 귀인 | 위험한 근접 체류를 유지할수록 강해진다 |
| 흑영 | 위험 표적을 표식/우선순위/처형으로 먼저 제거한다 |

기존 MVP-2 구현은 삭제 대상이 아니라 migration baseline이다. 유파별 완전 독립 시스템 4개를 만들지 않는다.

# MVP-3 — 결과/휴식/상점/Fate skeleton · INTEGRATED ROLLBACK BASELINE

기존 `SCHOOL_SELECT -> COMBAT -> BOSS -> RESULT -> SHOP -> FATE -> PREVIEW -> three-segment COMPLETE` 흐름은 최신 제품 Run이 아니라 검증된 rollback/regression baseline이다.

새 DEC 행동이 TDD package로 교체되기 전까지 기존 정상 경로를 회귀 보호한다.

# MVP-4 — 공간 백팩 + 4유파 Run domain foundation · T01~T16 MACHINE SCOPE INTEGRATED

목표:

> 전투에서 얻은 보상과 유파 전승 접근이 6x6 백팩 공간 판단, 다음 Route, 다음 전투 성능을 실제로 바꾸는가?

보호 범위:

- 6x6 / 4x3 start
- purchasable bag expansion
- item + bag 90° rotation
- orthogonal adjacency
- selected L/T bags
- six-slot REST buffer
- explicit atomic first-tier combination
- Boss / Shop / Chest acquisition pillars
- committed spatial snapshot as combat modifier authority
- unvisited-school route state
- Elite / trace / Boss lifecycle
- tradition access packages / reward lanes
- mouse / keyboard-gamepad focus / touch target paths

## T01 — Spatial Data Contracts / Catalog · INTEGRATED

- existing `ItemDefinition` extended instead of second item authority
- 19 base acquisition items + 3 combination-result lookup definitions
- starting 4x3 bag + 5 purchasable bags
- 8 strong-spatial item contracts
- 3 first-tier combination definitions
- modifier validation

Evidence ceiling: data/catalog foundation.

## T02 — BackpackState · INTEGRATED

- one committed 6x6 spatial state
- centered 4x3 starting area
- stable item/bag instance IDs
- atomic place/move/remove/rotate
- collision/active-area/orphan protection
- defensive snapshots

Evidence ceiling: committed spatial facts.

## T03 — BackpackResolver · INTEGRATED

- connected active-layout validation
- orthogonal adjacency canonicalization
- spatial-rule aggregation
- special-bag overlap
- selected-school/static modifier snapshot
- placement/whole-layout read-only previews

Evidence ceiling: deterministic spatial resolution.

## T04 — RestBackpackSession · INTEGRATED

- session-owned copy of committed state
- six-slot buffer
- defensive build preview
- undo/redo
- pending bag/item gates
- explicit whole-layout mode
- deterministic commit-readiness failures

Evidence ceiling: REST edit-session domain engine.

## T05 — CombinationResolver · INTEGRATED

- T01 recipe authority reused
- valid on-board orthogonal source pair only
- progressive `UNDISCOVERED -> INGREDIENT_OWNED -> READY -> DISCOVERED`
- source-preserving pending result
- success-only atomic exact 2→1 replacement
- pending combination blocks conflicting edits/commit

Evidence ceiling: first-tier combination transaction.

## T06 — committed RunBuildState modifier authority · INTEGRATED

One finalized spatial modifier snapshot is the combat authority. Legacy inventory/economy ownership must not double-apply item power.

## T07 — Boss / Shop / Chest spatial acquisition transactions · INTEGRATED

Boss reward, Shop and Chest acquisition route through bounded REST spatial transactions while preserving identity/economy compatibility.

## T08 — RunRouteState · INTEGRATED

- unvisited/provisional/active/cleared school facts
- reject revisits
- stage index separate from school identity
- preserve clear order
- fourth clear routes to Final Binding rather than Stage 5

## T09 — Encounter definitions + Stage profiles · INTEGRATED

- school Core x3 / Elite / Boss / pattern refs data contracts
- shared Stage 1..4 axes
- bounded shared primitive vocabulary
- first-slice Cheonsul primitive data

Evidence ceiling: encounter data/domain foundation, not playable encounter integration.

## T10 — Elite → Trace → Boss gate · INTEGRATED

- Elite warning/active
- chest token + non-expiring trace
- trace recovery
- Boss warning / dual gate
- spawn permission facts
- soft overtime / clear state

Evidence ceiling: deterministic lifecycle/domain gate.

## T11 — Tradition access packages + reward lanes · INTEGRATED

- Run-level access state
- Universal 7 + four school x3 authoring package over existing 19 item IDs
- starting-school access
- stabilization opens package
- Boss continuity / newly liberated tradition / bridge-universal lanes
- Shop/Chest lane-first selection
- canonical item-ID dedupe

Access does not create direct school combat stats; T06 remains combat modifier authority.

# T12 — Atomic Workbench + Fate + next-route commit · INTEGRATED

Status: **merged in PR #61 / `4120228…`**.

Closed PR #43 and draft PR #49 are historical read-only evidence only; neither is a resume baseline.

Approved outcome:

- Workbench route remains provisional until final commit.
- one transaction validates final T04 backpack/session state + pending Fate + T08 provisional route before mutation.
- failure mutates none of committed backpack/Fate/route state.
- success commits exactly once.
- existing domain owners remain singular.
- UI/MainController T13 behavior is not silently absorbed.

Implementation entry:

```text
fresh completed main
-> RED all-or-none contract
-> minimal pending-Fate / transaction boundary
-> full regression
-> >=5 whole-state adversarial loops until clean
-> exact-head PR gate
-> merge + postmerge repository/Notion readback
```

# T13 — Persistent Workbench route-preview UI/input · INTEGRATED

Goal:

- unvisited-school route cards
- risk/gimmick/reward/tag links
- provisional selection and change before Fate
- backpack remains central surface
- mouse / keyboard-gamepad focus / touch complete paths
- no hidden exact tuning values or AI recommendation score

Human evidence still separate from automated UI tests.

# T14 — Cheonsul one-school lifecycle / Workbench machine slice · INTEGRATED

One production-candidate school loop:

`signature <=30 sec -> Core -> ~3m Elite -> trace -> ~5m Boss -> result/reward -> Workbench -> next-route preview`.

Human judgment of representative UI, character/enemy visual language, animation/VFX and audio remains deferred; the merged evidence is machine scope only.

# T15 — Starting-school function help machine slice · INTEGRATED

Selection UI has a Korean function-help entry per school, one reusable modal, and input isolation. This task number was used for the implemented help slice; it does not close the separate human QA gate.

# Human QA Gate · DEFERRED / NOT_RUN

Measure:

- 30s school identity readability
- Core→Elite→Boss tension curve
- telegraph fairness
- trace clarity
- backpack/route comprehension
- Workbench fatigue
- Korean readability
- placement changes next-combat expectation

If this fails, correct the shared chassis before multiplying content.

# T16 — Combat HUD current-school help reopen · INTEGRATED

The selected school’s existing help dialog can reopen during combat from HUD intent. This is machine-verified help access, not a human readability or runtime-render PASS.

# Remaining-school expansion · FUTURE SEPARATE SCOPE

After user vertical-slice validation and a new explicit product decision:

- reuse shared encounter chassis,
- author school-owned Core x3 / Elite / Boss composition,
- preserve each school's risk-processing identity,
- keep concurrent advanced-gimmick cap 2.

# T17 — Four-school circuit integration

- full free-order clear path
- Stage 1..4 profile composition
- trace/access progression
- clear-order persistence
- fourth-clear Final Binding routing

# T18 — Final calamity package

- exact final-boss script from learned four-school encounter languages
- one short support callback per liberated school, default clear order
- callbacks create relief/openings, not auto-win
- player's backpack build owns actual victory

Exact final Boss content may require a focused content decision before implementation.

# T19 — Full-run verification

- Godot import/main smoke/full GUT
- deterministic route/reward/commit regression
- release-near full-run human QA
- run-duration/rest-fatigue evidence
- platform/device/export checks when release scope requires them

# MVP-5 — Final Run / result / Ninja Soul

Latest interpretation:

```text
clear four school battlefields exactly once
-> fourth school Boss
-> Final Binding Workbench
-> separate final calamity battle
-> final result / Ninja Soul / replay motivation
```

Protected principles:

- four-trace binding is not a new automatic upgrade tree,
- all four access packages are open at Final Binding,
- final build uses existing items/placement/adjacency/combinations,
- final Boss recombines previously learned school language rather than unrelated rules,
- school support is situational/short and does not own victory,
- Ninja Soul favors horizontal unlock/options/convenience over permanent stats that erase Run decisions.

# Current Visual / Human Home milestone

2026-08-25 user decision:

- master art style reference = first supplied image in the approval turn,
- dark moonlit painterly ninja fantasy + ink/brush/calligraphy language,
- dense parchment infographic style = supporting explanatory layout only,
- do not generate more images unless user explicitly requests it.

Human Home should explain the full Run, four schools, backpack core data, world/promise and current evidence ceiling without exposing raw AI/System metadata as the main reading experience.

# Historical branch/PR note

- PR #43 T12: closed/unmerged historical WIP.
- PR #44 front-door docs: closed/unmerged historical WIP.
- neither is a current implementation baseline.
- future production starts from fresh completed `main` and reuses only validated material.
