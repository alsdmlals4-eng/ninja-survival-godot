# SYSTEM_MAP

## 목적

현재 실제 runtime/domain responsibility와 DEC-014~026 제품 목표 사이의 연결을 한눈에 보여준다.

이 문서는 제품 규칙 자체의 정본이 아니다.

- 제품 행동: `CURRENT_CONFIRMED_DECISIONS.md` + dated product/encounter canon.
- 현재 resume state: `ACTIVE_CONTEXT.md`.
- 문서/Notion authority routing: `DOCUMENTATION_MAP.md`.
- 구현 사실: actual `scripts/`, `scenes/`, `data/`, `tests/`.
- 정확한 merge/test receipt: Git history + Notion `Production · Handoff`.

## 1. Current implementation baseline

최신 제품 구현 baseline은 **T11까지 integrated domain/automated scope**다. 그 이후 repository `main`에는 docs-only alignment가 추가될 수 있으므로, repository SHA와 제품 구현 단계는 같은 개념으로 취급하지 않는다.

| 영역 | 현재 owner / surface | 구현 현실 | 현재 disposition |
|---|---|---|---|
| Main composition | `scripts/core/main_controller.gd` | MVP-3 playable composition baseline | preserve; T13/T14에서 새 Workbench/route/encounter 소비 연결 |
| Game score / kill / contribution | `scripts/core/game_state.gd` | integrated baseline | reuse |
| Stage flow | `scripts/core/stage_flow_controller.gd` | MVP-3 3-segment rollback baseline | 새 4유파 제품 흐름으로 migration 예정; 역사 동작 삭제 전 회귀 보호 |
| Run build | `scripts/core/run_build_state.gd` | **T06 committed item/spatial modifier authority integrated** | combat power single-authority 보호 |
| Combat resolver | `scripts/combat/combat_resolver.gd` | committed run modifier consumer | reuse consumer; legacy double-application 금지 |
| Wave spawning | `scripts/spawning/wave_spawner.gd` | normal enemy spawn baseline | reuse API; 별도 wave system 만들지 않음 |
| Four-school shallow runtime | `scripts/schools/*_runtime.gd` | MVP-2 migration baseline integrated | 4유파 철학에 맞춰 bounded tuning; wholesale rewrite 금지 |
| REST outer UI | `scripts/ui/rest_flow_ui.gd` + scene | MVP-3 RESULT/SHOP/FATE/PREVIEW shell | T13에서 Persistent Workbench/route-preview input으로 migration |
| Spatial data | T01 definitions/catalog | **INTEGRATED** | item/bag/recipe definition authority |
| Backpack committed state | T02 `BackpackState` + item/bag instances | **INTEGRATED** | committed geometry/state authority |
| Spatial resolution | T03 `BackpackResolver` + `BackpackResolution` | **INTEGRATED** | connectivity/adjacency/special-bag/modifier derived authority |
| REST edit session | T04 `RestBackpackSession` + `BuildPreviewSnapshot` | **INTEGRATED** | pending edit/buffer/history/mode authority |
| Combination | T05 `CombinationResolver` | **INTEGRATED** | recipe eligibility/hint/pending/atomic 2→1 authority |
| Committed combat build | T06 `RunBuildState` migration | **INTEGRATED** | finalized spatial modifier snapshot combat authority |
| Acquisition transactions | T07 Boss/Shop/Chest spatial acquisition foundation | **INTEGRATED** | exact acquisition transaction/domain boundary |
| Route state | T08 `RunRouteState` | **INTEGRATED** | cleared order / provisional next school / route facts |
| Encounter data | T09 encounter definitions + Stage profiles | **INTEGRATED** | school encounter/gimmick data authority |
| Encounter lifecycle | T10 Elite → Trace → Boss domain gate | **INTEGRATED** | deterministic milestone/gate authority |
| Tradition access / reward lanes | T11 Run-level access + Boss/Shop/Chest lane-first selection | **INTEGRATED** | acquisition eligibility/reward-lane authority; 직접 combat stat 아님 |
| Tests / CI | `tests/**`, `.github/workflows/gut.yml` | active regression evidence | protect / extend exact-head |

## 2. Spatial / Workbench ownership chain

```text
T01 definitions/catalog · INTEGRATED
        ↓
T02 BackpackState · committed facts
        ↓ read-only
T03 BackpackResolver · legality/adjacency/special-bag/modifiers
        ↓
T04 RestBackpackSession · pending REST edits / buffer / history
        ↘
         T05 CombinationResolver · pending/atomic first-tier combination
        ↓ finalized snapshot
T06 RunBuildState · committed item/spatial combat modifier authority
        ↓
CombatResolver / school runtime consumers
```

Protected rules:

- fixed 6x6 board / centered 4x3 starting active area,
- item and bag 90-degree rotation,
- orthogonal adjacency,
- selected L/T bag shapes,
- special-bag one-cell-or-more overlap,
- exact six-slot REST buffer,
- explicit first-tier atomic combination,
- preview/uncommitted items contribute zero combat power,
- one committed spatial modifier snapshot is the item/spatial combat authority.

UI는 snapshots를 렌더하고 intents를 보낼 뿐 geometry/economy/combination/combat authority가 되지 않는다.

## 3. Run route / encounter / reward ownership chain

```text
T08 RunRouteState
  ├─ cleared_schools / clear order
  ├─ provisional_next_school
  ├─ school identity vs Stage 1..4 separation
  └─ final routing facts

T09 encounter definitions + StageEncounterProfile
        ↓
T10 deterministic Elite -> Trace -> Boss lifecycle gate
        ↓
T11 tradition access state + reward-lane eligibility
```

Current product flow target:

```text
starting school
-> choose unvisited school
-> Core Monster + Stage gimmick
-> ~3m Elite
-> chest token + trace AVAILABLE
-> trace RECOVERED
-> Boss warning / time gate
-> ~5m school Boss
-> RESULT / Boss Reward
-> joint branch
-> trace STABILIZED / tradition access OPEN
-> Persistent Workbench
-> provisional next school
-> Shop / Chest / Backpack / Combination
-> Fate atomically commits build + Fate + route
-> repeat four schools exactly once
-> Final Binding Workbench
-> separate 난세 재앙핵
-> final result / Ninja Soul / legend
```

Trace는 RewardOrb와 별도이며 ORB/STYLE/GOLD/direct combat power를 주지 않는다. `STABILIZED`는 전승 item이 등장할 수 있는 접근을 열 뿐 자동 유파 버프가 아니다.

## 4. Current missing integration boundary

T01~T11의 domain integration이 있다고 해서 새 제품 Run이 end-to-end playable하다는 뜻은 아니다.

현재 다음 제품 패키지:

### T12 — Atomic Workbench + Fate + next-route commit · NEXT FRESH PACKAGE

목표:

- finalized T04/T05 Workbench state,
- pending Fate,
- T08 provisional next-school route

를 **all-or-none**으로 검증/commit하는 단일 final REST transaction boundary를 확립한다.

T12에서 하지 않는 것:

- Persistent Workbench production UI/input migration (T13),
- MainController 새 Run 조립 전체 (T13/T14),
- Cheonsul release-near encounter slice (T14),
- Human QA (T15).

Closed PR #43은 historical/WIP read-only다. 새 T12는 then-current completed `main`에서 fresh branch/package로 시작하고 #43에서 여전히 유효한 material만 ADAPT한다.

## 5. T13~T15 integration target

```text
T12 atomic REST commit domain
        ↓
T13 Persistent Workbench route-preview UI/input
        ↓
T14 Cheonsul one-school release-near Vertical Slice
  signature <=30s
  -> Core pressure
  -> ~3m Elite
  -> trace
  -> ~5m Boss
  -> reward
  -> Persistent Workbench
  -> next-route preview
        ↓
T15 Human QA gate
```

T14 전에는 4유파 전체 content를 먼저 복제하지 않는다.

Human QA는 다음을 실제 사람 플레이로 확인한다.

- 첫 30초 유파 정체성 가독성,
- Core→Elite→Boss tension curve,
- telegraph fairness,
- trace 이해,
- backpack/route 판단 가치,
- Workbench comprehension/fatigue,
- Korean layout/readability,
- mouse / keyboard-gamepad / touch core completion paths.

## 6. Four-school product identity

공통 전투/백팩/Workbench/Fate 프레임을 공유하고, 유파는 서로 다른 **위험 처리 철학**으로 분리한다.

| 유파 | 위험 처리 철학 | 공간/빌드 관계 |
|---|---|---|
| 봉마류 | 공간을 준비하고 식신·결계가 대신 싸우게 한다 | 소환 + 설치/결계 |
| 천술류 | 상태를 만들고 순서대로 원소 반응을 일으킨다 | 서로 다른 원소/상태 |
| 귀인류 | 위험한 근접 체류를 유지하며 힘을 끌어낸다 | 근접 무기 + 생존/회복 |
| 흑영류 | 위험 표적을 표식·우선순위·처형으로 먼저 제거한다 | 투척/원거리 + 표식/독/처형 |

고정 진지 강요, 직접 마우스 표적 지정, 저체력 단일 정체성처럼 자동전투/서바이버 이동 감정을 깨는 방향은 장기 제품 정체성으로 고정하지 않는다.

## 7. Reward / economy boundary

```text
tradition access package = 언제 어떤 item이 등장 가능한가
item affinity/tag        = 무엇과 시너지가 있는가
reward lane              = 지금 왜 이 선택지가 제시되는가
actual power             = 획득 후 committed backpack 배치/인접/조합
```

보호 범위:

- 19 base-acquisition item IDs,
- 3 first-tier combinations,
- 5 purchasable bags,
- Boss / Shop / Chest 획득 축,
- lane-first selection + canonical item-ID dedupe,
- existing sell/economy behavior unless explicitly superseded.

Access state가 combat stat authority가 되지 않게 한다.

## 8. Final binding / final battle target

```text
fourth school Boss
-> RESULT / Boss Reward
-> joint branch
-> four traces bound
-> Final Binding Persistent Workbench
-> final build + fourth Fate commit
-> separate 난세 재앙핵
-> liberated-school support callbacks
-> player backpack build owns victory
-> final result / Ninja Soul / legend
```

Final Boss는 네 유파에서 이미 학습한 encounter language를 재조합한다. 새로운 전혀 다른 전투 문법을 마지막에 갑자기 추가하지 않는다.

## 9. Human Home / Visual GDD projection

Notion `닌자 서바이벌 · Home`은 이 system map을 그대로 복사하는 화면이 아니다.

Home은 사람이 **게임 정체성 → 실제 플레이 → 핵심 시스템 → Visual → 핵심 데이터 → 콘텐츠 → 현재 개발 현실**을 스크롤로 이해하는 Living GDD projection이다.

대량 데이터는 Master DB filtered Linked View로 노출해 중복 정본을 만들지 않는다.

- 승인 Visual: `ASSET LIBRARY · Master` project/approved filter.
- 사람용 시스템 데이터: `CORE SYSTEM · Master` project/confirmed filter + human-facing fields.

AI용 source path/SHA/ID/PR/test/evidence는 Project Registry/System / Production Handoff / GitHub에 남긴다.

## 10. Verification layers / evidence ceiling

```text
source / contract
-> import / parse
-> main-scene smoke
-> focused/full GUT
-> live runtime / render / input
-> Human Usability
-> Player Experience
-> device / export
```

현재 automated/domain evidence:

- MVP-0~3 baseline integrated.
- T01~T11 domain chain integrated with automated evidence.

아직 그 증거로 PASS라 말할 수 없는 것:

- intended new four-school Run end-to-end playability,
- production-candidate Persistent Workbench UI/input,
- Cheonsul release-near player experience,
- device/Android readiness,
- final full-run experience.

`NOT_RUN`은 PASS가 아니다.

## 11. Next execution artifact

**T12 — Atomic Workbench + Fate + next-route commit**.

```text
then-current completed main
-> current Base/project authority readback
-> actual code/tests/canon inspection
-> closed PR #43 read-only comparison
-> fresh branch
-> exact T12 boundary
-> TDD / adversarial review / exact-head verification
-> PR / merge
-> post-merge GitHub + Notion readback
```

T12가 T13/T14 scope를 흡수하지 않게 한다.