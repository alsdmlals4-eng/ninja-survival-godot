# MVP_ROADMAP

## 목적

`닌자의 신 / 닌자 서바이벌` Godot 버전의 **현재 구현 baseline과 앞으로 검증할 제품 slice**를 구분한다.

MVP 단계 이름은 역사와 회귀 추적을 위해 유지한다. 최신 DEC-014~025가 Run 구조를 확장했더라도 이미 병합된 MVP-0~3을 다시 이름 붙이거나 완료 사실을 지우지 않는다.

## 현재 상태

```yaml
MVP_0: INTEGRATED
MVP_1: INTEGRATED
MVP_2: INTEGRATED
MVP_3: INTEGRATED_ROLLBACK_BASELINE
MVP_4_SPATIAL: DESIGN_APPROVED_PRODUCTION_NOT_STARTED
DEC014_025_CIRCUIT_MIGRATION: DOCUMENTED_NOT_IMPLEMENTED
NEXT_PRODUCT_GATE: DEC_026
RELEASE_NEAR_VERTICAL_SLICE_HUMAN_QA: NOT_RUN
```

## 전체 제품 검증 질문

MVP/Vertical Slice는 다음을 검증한다.

1. 자동 생존 전투와 DDD가 짧게 재미있는가?
2. 네 유파가 이름/색만 다른 것이 아니라 위험을 처리하는 방식이 다른가?
3. 전투 보상이 Workbench 판단으로 이어지는가?
4. 백팩 공간·회전·인접·조합이 실제 빌드 기억을 만드는가?
5. 다음 유파 경로 선택이 현재 빌드와 meaningful trade-off를 만드는가?
6. 네 유파를 평정한 뒤 별도 최종전이 피로가 아니라 climax로 느껴지는가?
7. 한 판 뒤 다른 유파/순서/빌드를 시험하고 싶어지는가?

## Stage 0 — MVP-0 기본 전투 기반 · INTEGRATED

검증 범위:

- 8방향 이동
- 카메라
- 적 추적
- 자동 공격
- 피격/처치
- HUD
- 게임오버/restart

현재 구현/테스트를 회귀 보호한다.

## Stage 1 — MVP-1 Combat DDD · INTEGRATED

검증 범위:

- kill combo / max combo
- stylish score
- reward absorption feedback
- timed wave pressure

성능 보상형 combo multiplier를 핵심으로 확장하지 않는다.

## Stage 2 — MVP-2 Four Schools · INTEGRATED BASELINE

현재 대표 runtime은 존재하고 자동화 회귀가 있다.

장기 제품 정체성:

| 유파 | 위험 처리 철학 |
|---|---|
| 봉마 | 이동형 진지 · 식신/결계로 공간을 준비하고 대신 싸우게 한다 |
| 천술 | 상태를 만들고 원소 반응으로 전장을 바꾼다 |
| 귀인 | 위험한 근접 체류를 유지할수록 강해진다 |
| 흑영 | 위험 표적을 표식/우선순위/처형으로 먼저 제거한다 |

현재 봉마 fixed ward / 귀인 low-HP bonus / 흑영 nearest-target rule은 삭제하지 않고 Vertical Slice tuning 후보로 둔다.

## Stage 3 — MVP-3 Result / Rest Skeleton · INTEGRATED ROLLBACK BASELINE

현재 구현은:

`SCHOOL_SELECT -> COMBAT -> BOSS -> RESULT -> SHOP -> FATE -> PREVIEW -> three-segment COMPLETE`

이다.

이 흐름은 현재 production target이 아니라 **검증된 rollback/regression baseline**이다. 새 DEC 행동을 구현하는 TDD 단계에서 의도적으로 교체되기 전까지 테스트를 보호한다.

## Stage 4A — MVP-4 Spatial Domain · APPROVED / NOT_STARTED

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

기존 2026-08-11 구현 계획의 T01~T07 direction은 재사용한다.

## Stage 4B — Four-School Circuit Migration · DOCUMENTED / NOT_STARTED

최신 DEC-014~025 목표:

```text
starting school
-> choose unvisited school
-> school battlefield
-> ~3m Elite
-> chest token + trace
-> trace recovery
-> ~5m school Boss
-> RESULT / Boss Reward
-> branch / trace STABILIZED
-> Persistent Workbench
-> provisional next school
-> Fate commit
-> repeat four schools exactly once
```

핵심 구조:

- school = encounter identity,
- Stage 1..4 = difficulty/gimmick-depth profile,
- traces = tradition acquisition access, not automatic power,
- next school = player-chosen among unvisited routes,
- Fate atomically commits build + Fate + next route.

상세 migration requirements: `docs/traceability/2026-08-21-dec014-025-migration-traceability.md`.

## Stage 4C — One-School Release-Near Vertical Slice · NOT_RUN

4유파 콘텐츠를 모두 제작하기 전에 한 유파로 다음 end-to-end를 먼저 완성한다.

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

Vertical Slice가 재미/가독성 기준을 통과한 뒤 나머지 3유파 콘텐츠를 같은 framework로 확장한다.

## Stage 5 — Four-School Content Expansion · BLOCKED_DEC026

첫 콘텐츠 상한:

- Core Monster 12 = 3 x 4 schools
- Elite 4
- School Boss 4
- School gimmick libraries 4

Stage gimmick depth:

- Stage 1 base signature
- Stage 2 + interaction gimmick
- Stage 3 + synergy/field gimmick
- Stage 4 mastery + one Boss advanced pattern
- concurrent advanced-gimmick default cap 2

**DEC-026**에서 concrete Core Monster / Elite / Boss attack sets와 Stage pattern budget을 확정하기 전 상세 구현 계획을 시작하지 않는다.

## Stage 6 — Final Binding / Final Calamity · PARTIAL SPEC / NOT_STARTED

Four-school circuit 완료 뒤:

`fourth Boss -> RESULT -> Final Binding Workbench -> final Fate/build commit -> 난세 재앙핵`.

보호 규칙:

- 4흔적 결속은 새 자동 upgrade tree가 아니다.
- 네 access package가 열린 마지막 Persistent Workbench다.
- Final Boss는 앞서 배운 학교 문법을 재조합한다.
- 해방된 4유파가 clear order에 따라 각 1회 짧게 지원한다.
- 지원은 위험 완화/공격 창이며 자동 승리가 아니다.
- 최종 승리와 결정타는 플레이어의 backpack build가 담당한다.

정확한 final attack/pattern 구현은 DEC-026 및 후속 final-boss planning 이후다.

## Stage 7 — Final Result / Ninja Soul / Replay · NOT_STARTED

검증 범위:

- final result
- ninja rank / stylish result
- MVP ninjutsu/equipment or build summary
- Fate/route history
- short ending callback
- Ninja Soul horizontal/meta reward
- restart/replay motivation

Ninja Soul은 Run을 압도하는 영구 공격력/체력 누적보다 unlock/option/convenience 중심 수평 성장을 우선한다.

## 구현 순서 보호

```text
current canon sync
-> DEC-026 approval
-> fresh Phase-B review
-> reuse T01-T07 spatial domain packages
-> recalculated circuit packages
-> one-school release-near Vertical Slice
-> human QA
-> four-school expansion
-> final binding/final calamity
-> full-run QA / Android / export / release work
```

기존 `impl/mvp4-t01-spatial-data-contracts`나 closed-unmerged PR #17에서 구현을 재개하지 않는다.

## MVP 제외 / 후속

현재 검증 범위에서 제외하거나 후속으로 둔다.

- four full deep skill trees
- second/third-tier combinations
- arbitrary complex regular-item polyomino system
- deep set/curse/rarity layers
- base-building/economy management core
- permanent Meta stats that dominate Run choices
- large branching ending campaign
- full release balance before representative Vertical Slice proves the core

## 성공/실패 판단

성공:

- 한 유파 Vertical Slice만으로도 전투→Elite→trace→Boss→Workbench의 감정 변화가 읽힌다.
- backpack 배치가 실제 다음 전투/경로 기대를 바꾼다.
- route order가 전략을 만들지만 정답 경로 하나로 고정되지 않는다.
- 4유파 확장 후에도 같은 framework로 제작비가 통제된다.
- final battle이 플레이어 build를 무력화하지 않는다.

재검토:

- 첫 유파 5분이 반복적이거나 의미 없이 길다.
- Workbench가 매번 과도하게 길어져 Run 피로를 만든다.
- school identity보다 common auto-combat가 더 강하게 느껴진다.
- route order가 특정 school-last 정답으로 수렴한다.
- content multiplication cost가 framework 재사용보다 빠르게 증가한다.
