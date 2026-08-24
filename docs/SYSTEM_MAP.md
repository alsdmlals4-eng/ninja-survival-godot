# SYSTEM_MAP

## 목적

현재 실제 runtime responsibility와 DEC-014~026 migration target을 한눈에 연결한다.

- 제품 행동: `docs/CURRENT_CONFIRMED_DECISIONS.md` + dated product/encounter canon.
- 현재 resume state: `docs/ACTIVE_CONTEXT.md`.
- 구현 사실: actual scripts/scenes/tests.
- 이 문서는 중복 정본이 아니라 responsibility / migration map이다.

## 1. Current implementation baseline

| 영역 | 현재 owner | 구현 현실 | migration disposition |
|---|---|---|---|
| Main composition | `scripts/core/main_controller.gd` | MVP-3 integrated | reuse composition root; later wire circuit/trace/Workbench |
| Game score/kill | `scripts/core/game_state.gd` | integrated | reuse |
| Stage flow | `scripts/core/stage_flow_controller.gd` | 3-segment baseline | current product target differs; preserve as rollback evidence |
| Run build | `scripts/core/run_build_state.gd` | GOLD + non-spatial owned items + Fate modifiers | migrate at T06 to committed spatial authority |
| Combat resolver | `scripts/combat/combat_resolver.gd` | run modifiers applied to damage | reuse |
| Wave spawning | `scripts/spawning/wave_spawner.gd` | timed/capped normal enemies | reuse API; no second wave system by default |
| Stage Boss | `scripts/enemies/stage_boss.gd` | stat-tier Boss baseline | later school/final Boss migration reference |
| Four schools | `scripts/schools/*_runtime.gd` | four shallow identities integrated | preserve baseline; bounded later tuning |
| Shop | `scripts/core/shop_controller.gd` | immediate non-spatial buy/sell | preserve sell/economy baseline; migrate acquisition at T07/T11 |
| Fate | `scripts/core/fate_controller.gd` | one choice per rest | later pending/atomic commit integration |
| Rest UI | `scripts/ui/rest_flow_ui.gd` + scene | MVP-3 RESULT/SHOP/FATE/PREVIEW | outer-shell baseline |
| **T01 item data** | `ItemDefinition` + `MVP4Catalog` + data definitions | **INTEGRATED** | canonical spatial data foundation |
| **T02 backpack state** | `scripts/backpack/backpack_state.gd` + Item/Bag instances | **INTEGRATED** | committed spatial-state authority |
| Backpack resolver | future `BackpackResolver` | **NOT_STARTED** | T03 next |
| Tests/CI | `tests/**`, `.github/workflows/gut.yml` | active regression baseline | protect / extend TDD-first |

## 2. Integrated spatial foundation

### T01 — definitions/catalog

PR #27 / `7c9206702526f99dfadf44a617cd150853ec733f` integrated:

```text
MVP3Catalog existing 8 item definitions
        ↓ reused / extended
ItemDefinition + RunModifierSet field validation
        + SpatialRuleDefinition
        + BagDefinition
        + CombinationDefinition
        ↓
MVP4Catalog
  ├─ 19 base acquisition items
  ├─ 3 combination-result lookup items
  ├─ starting 4x3 bag + 5 purchasable bags
  ├─ 8 strong-spatial item rules
  └─ 3 first-tier combination definitions
```

Existing `sell_price()` / RunBuildState/Shop sell runtime remains unchanged. T01 does not invent a second economy.

### T02 — committed BackpackState

PR #29 / `126e6c942d74f97166ef0c881afc5d79cae3d274` integrated:

```text
MVP4Catalog definitions
        ↓ referenced by stable ids
ItemInstance + BagInstance
        ↓
BackpackState
  ├─ fixed 6x6 board
  ├─ centered starting 4x3 active area
  ├─ shared monotonic instance ids
  ├─ origin + normalized quarter-turn rotation
  ├─ atomic add/move/remove/rotate
  ├─ item-item + bag-bag collision facts
  ├─ active-area union / bag expansion-shrink
  ├─ existing-item orphan prevention
  └─ defensive collection snapshots / copy isolation
```

T02 adversarial review found that live public item/bag collections could bypass state validation. That path was removed; public collection views now return defensive copies.

Final exact-head evidence: `Godot 4.7.1 import PASS -> main smoke PASS -> GUT 274/274 PASS -> 1915 assertions PASS -> T02 focused 11/11 PASS`.

## 3. Protected spatial domain target

```text
T01 definitions/catalog · INTEGRATED
          ↓
T02 BackpackState · INTEGRATED
          ↓
T03 BackpackResolver · NEXT
          ↓
T04 RestBackpackSession ── T05 CombinationResolver
          ↓
BuildPreviewSnapshot
          ↓
T06 committed RunBuildState snapshot + Fate
          ↓
RunModifierSet / CombatResolver / school runtime
```

### T02 BackpackState — INTEGRATED

Owns committed facts and state transitions only:

- fixed 6x6 board,
- T01 starting 4x3 active area,
- bags/items and stable instance identity,
- origin/rotation,
- place/move/remove/rotate,
- occupied-cell collision facts,
- bag expansion/shrink state,
- snapshot/copy isolation.

It intentionally does not calculate adjacency, connected-layout rules, special-bag effects, GOLD/Fate/UI or combat modifiers.

### T03 BackpackResolver — NEXT

Future owner for deterministic resolution over T02 facts:

- connected usable layout legality required by the approved spatial spec,
- orthogonal adjacency,
- special-bag one-cell-overlap activation,
- deterministic active spatial modifier resolution,
- no mutation of committed state during resolve.

### T04 RestBackpackSession

Future owner for six-slot buffer, preview editing/history/pending states and commit readiness.

### Workbench UI

Future UI renders snapshots/emits intents only; it never becomes geometry/economy/combination authority.

## 4. New Run-level circuit target

```text
RunRouteState
  ├─ cleared_schools in clear order
  ├─ provisional_next_school
  ├─ current_stage_index 1..4
  └─ final-routing state

SchoolEncounterDefinition
  + StageEncounterProfile
  + school gimmick/pattern data
          ↓
StageEncounterState / bounded coordinator
```

Do not hardcode route permutations or 16 school-stage controllers in UI/MainController. Runtime for these owners is still NOT_STARTED.

## 5. Battlefield progression target

```text
COMBAT / Core Monsters
-> ~2:40 Elite warning
-> ~3:00 school Elite
-> chest token + trace AVAILABLE
-> trace recovery / TRACE RECOVERED
-> BossApproachProfile + earliest-time/warning gate
-> school Boss around five-minute boundary
-> RESULT / Boss Reward
-> joint branch
-> trace STABILIZED / access package OPEN
-> Persistent Workbench
-> provisional route
-> Fate commit
```

Trace is separate from RewardOrb and must not grant ORB/STYLE/GOLD.

## 6. Access-package / reward-lane target

```text
access package = when item can appear
affinity/tag = what it synergizes with
reward lane = why it is offered now
actual power = committed backpack placement/adjacency/combination only
```

T01 provides canonical item IDs/tags and base/result pool boundaries. T02 provides committed positions/rotations only. Reward weighting/package eligibility belongs to T07/T11.

## 7. Route preview / atomic commit target

Workbench route choice is provisional and changeable before Fate. Later `RestCommitCoordinator` must atomically validate/commit `backpack + fate + next_school` or mutate none.

Do not expose exact hidden tuning tables or AI win recommendations.

## 8. Final binding / final battle target

```text
fourth school Boss
-> RESULT / Boss Reward
-> joint branch
-> four traces bound
-> Final Binding Persistent Workbench
-> final build + fourth Fate commit
-> separate 난세 재앙핵 battle
-> liberated-school support callbacks
-> player build owns victory
-> final result / Ninja Soul
```

Final Boss reuses/recombines learned school languages. Exact full final script is later work.

## 9. Four-school runtime migration notes

Current protected MVP-2 evidence:

- 봉마: familiar + fixed ward.
- 천술: status/reaction loop.
- 귀인: melee pulse + low-HP modifier.
- 흑영: marks/crit/execution + nearest-target attack.

Tune after one-school representative slice; do not rewrite all four simultaneously.

## 10. Task reuse / supersession map

- old 2026-08-11 plan T01: implemented / historical evidence after PR #27.
- old plan T02: implemented / historical evidence after PR #29 where compatible with current Phase-B.
- old T03-T07 low-level direction: reusable where current canon/Phase-B does not supersede it.
- old T08-T12: historical/non-executable.
- post-DEC-026 traceability/Phase-B/T08+ plan: current.

Current next implementation package: **T03 BackpackResolver**.

## 11. Verification layers

```text
unit
- T01 catalog/shape/modifier validation · PASS
- T02 backpack state transitions · PASS
- T03 geometry/adjacency/special-bag resolution · NEXT
- T05 combination atomicity
- T08 route state
- T10 trace gates
- T12 atomic commit

integration
- Core -> Elite -> trace -> Boss -> branch
- reward -> Workbench -> route -> Fate commit
- four schools exactly once -> final binding

runtime
- Godot import/main scene
- representative battlefield pacing
- UI focus/input behavior

human
- one-school release-near Vertical Slice first
- school identity/readability
- telegraph fairness
- trace comprehension
- Workbench decision value/fatigue
- Korean layout/readability
```

Automated GREEN and human PASS remain separate evidence classes.

## 12. Current evidence ceiling

- MVP-0~3 integrated.
- DEC-014~026 planning canon approved.
- fresh Phase-B PASS.
- **T01 spatial data contracts/catalog integrated and automated-regression verified.**
- **T02 committed BackpackState integrated and automated-regression verified.**
- BackpackResolver/REST session/Workbench interaction not started.
- DEC-014~026 circuit/trace/encounter runtime not started.
- release-near human QA not run.
- Android/export not ready.

Do not use T02 state primitives as proof that adjacency effects or playable Workbench behavior exist.
