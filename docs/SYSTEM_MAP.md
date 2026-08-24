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
| Stage flow | `scripts/core/stage_flow_controller.gd` | 3-segment `SCHOOL_SELECT->COMBAT->BOSS->RESULT->SHOP->FATE->PREVIEW/COMPLETE` | baseline only; current product target differs |
| Run build | `scripts/core/run_build_state.gd` | GOLD + non-spatial owned items + Fate modifiers | migrate to committed spatial authority |
| Combat resolver | `scripts/combat/combat_resolver.gd` | run modifiers applied to damage | reuse |
| Contribution | `scripts/combat/combat_contribution_tracker.gd` | segment contribution snapshot | reuse/extend only if new evidence needs it |
| Wave spawning | `scripts/spawning/wave_spawner.gd` | timed/capped normal enemies | reuse API; do not create second wave system by default |
| Stage Boss | `scripts/enemies/stage_boss.gd` | stat-tier Boss baseline | school-Boss/final-Boss migration reference, not current final implementation |
| Four schools | `scripts/schools/*_runtime.gd` | four shallow identities integrated | preserve as baseline; bounded later tuning |
| Shop | `scripts/core/shop_controller.gd` | immediate non-spatial purchase/sell semantics | reuse economy/reroll/sell pieces; route acquisition to Workbench/access lanes |
| Fate | `scripts/core/fate_controller.gd` | one choice per rest | reuse candidates; later atomic route/build commit integration |
| Rest UI | `scripts/ui/rest_flow_ui.gd` + scene | RESULT/SHOP/FATE/PREVIEW/COMPLETE | outer shell baseline; Workbench/route preview target differs |
| Item data | `scripts/data/item_definition.gd` + `mvp3_catalog.gd` | 8 current runtime items + fates | spatial/catalog migration planned |
| Tests/CI | `tests/**`, `.github/workflows/gut.yml` | active regression baseline | protect; replace tests only with approved behavior RED/GREEN |

## 2. Protected spatial domain target

```text
ItemDefinition / BagDefinition / CombinationDefinition
          ↓
ItemInstance / BagInstance
          ↓
BackpackState
          ↓
BackpackResolver
          ↓
RestBackpackSession ── CombinationResolver
          ↓
BuildPreviewSnapshot
          ↓
committed RunBuildState snapshot + Fate
          ↓
RunModifierSet / CombatResolver / SchoolRuntimeHost / player runtime
```

Responsibilities:

### BackpackState

- fixed 6x6 board,
- bags/items and stable instance identity,
- origin/rotation,
- committed spatial state only.

### BackpackResolver

- bounds/occupancy,
- active bag cells,
- bag connectivity/collision,
- orthogonal adjacency,
- special-bag overlap,
- deterministic active modifier resolution.

### RestBackpackSession

- six-slot work buffer,
- preview placement/rotation,
- whole-layout movement mode,
- Undo/Redo edit history,
- pending bag,
- combination preview/transaction,
- commit readiness.

### Workbench UI

- render snapshots,
- expose intent/actions,
- show legality/synergy/combination/route feedback,
- never become geometry/economy/combination authority.

## 3. New Run-level circuit target

Current product canon requires a bounded owner above individual school runtimes.

Architecture direction approved by the fresh Phase-B review:

```text
RunRouteState
  ├─ cleared_schools in clear order
  ├─ provisional_next_school
  ├─ current_stage_index 1..4
  └─ four-school-complete / final-routing state

SchoolEncounterDefinition
  + StageEncounterProfile
  + school gimmick/pattern data
          ↓
StageEncounterState / bounded coordinator
  ├─ Elite / Trace / Boss lifecycle
  └─ normal-spawn permission for existing WaveSpawner
```

Do not hardcode every route permutation or 16 school-stage variants in UI/MainController. DEC-026 and the fresh Phase-B record have approved these owner boundaries; runtime implementation remains NOT_STARTED and must follow the T01→T14 package order.

## 4. Battlefield progression target

```text
COMBAT / Core Monsters
-> ~2:40 Elite warning
-> ~3:00 school Elite
-> Elite death
   -> chest token +1 exactly once
   -> trace AVAILABLE
-> trace auto-approach / close-range recovery
-> TRACE RECOVERED
-> BossApproachProfile + earliest-time/warning gate
-> school Boss around five-minute boundary
-> RESULT / Boss Reward
-> return to joint branch
-> trace STABILIZED / school access package OPEN
-> Persistent Workbench
-> provisional next-school route
-> Fate commit
```

Trace is separate from RewardOrb and must not grant ORB/STYLE/GOLD.

## 5. Access-package / reward-lane target

```text
access package = when item can appear
affinity/tag = what builds/schools it synergizes with
reward lane = why this candidate is offered now
actual power = only committed backpack placement/adjacency/combination
```

Run start:

`Universal + starting-school package open`.

After school Boss + branch return:

`that school's package opens`.

Boss/Shop/Chest should select a lane/pool first, then item, and deduplicate by canonical item ID. Do not turn 19 existing items into mutually exclusive school-owned items.

Existing Shop sell semantics are a protected runtime fact unless a later approved design changes them; LOW_VALUE_REWARD_RECOVERY does not invent a second dismantle/conversion economy.

## 6. Route preview / commit target

Workbench owns a player-facing comparison surface for unvisited schools.

Route choice:

- provisional while editing,
- changeable before Fate,
- Fate atomically commits `backpack + fate + next_school`,
- failed commit mutates none of the three,
- clear history remains visible and feeds final support order.

Route card can reveal school philosophy, Stage gimmick depth, Elite/Boss main risk, access/reward meaning and real current-build links.

Do not expose exact hidden tuning tables or AI win recommendations.

## 7. Final binding / final battle target

```text
fourth school Boss
-> RESULT / Boss Reward
-> joint branch
-> four traces bound
-> Final Binding Persistent Workbench
-> all access packages open
-> final build + fourth Fate commit
-> separate 난세 재앙핵 battle
-> liberated-school support callbacks in clear order
-> player build owns victory
-> final result / Ninja Soul
```

Four-school support is risk relief/attack-window narrative payoff, not companion management or automatic victory.

Final Boss reuses/recombines previously learned school languages. DEC-026 supplies the bounded encounter vocabulary/pattern budget; the final calamity's exact full script remains a later implementation/planning responsibility and is not runtime evidence yet.

## 8. Four-school runtime migration notes

Current runtime is protected evidence:

- 봉마: familiar + current fixed ward.
- 천술: status/reaction loop.
- 귀인: melee pulse + current low-HP berserker modifier.
- 흑영: marks/crit/execution + current nearest-target attack.

Long-term product tuning candidates:

- 봉마 -> mobile stronghold expression.
- 귀인 -> dangerous close-range presence rather than low HP alone.
- 흑영 -> threat-priority execution while keeping auto-combat compatibility.
- 천술 -> preserve reaction identity while expanding content later.

Tune after one-school representative slice; do not rewrite all four simultaneously.

## 9. Task reuse / supersession map

Old `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md`:

- T01-T07: reusable low-level direction.
- T08-T12: historical/non-executable after DEC-014~025.

Current execution owners:

- spatial specification: `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
- spatial data contract: `docs/planning/2026-08-11-mvp4-content-data-contract.md`
- post-DEC-026 traceability: `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`
- fresh Phase-B: `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
- T08+ replacement plan: `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`

Current next implementation package: **T01 spatial data contracts/catalog**.

## 10. Verification layers

```text
unit
- catalog/shape/modifier validation
- backpack geometry/connectivity/adjacency
- combination atomicity
- access-package/reward-lane determinism
- school-route state
- trace state/gates
- atomic route/build/Fate commit

integration
- Core -> Elite -> trace -> Boss -> branch
- reward -> Workbench -> route preview -> Fate commit
- four schools exactly once -> final binding
- regression with current combat/school/Fate/Shop ownership

runtime
- Godot import/main scene
- representative battlefield pacing
- real UI focus/input behavior

human
- one-school release-near Vertical Slice first
- school identity/readability
- telegraph fairness
- trace comprehension
- Workbench decision value/fatigue
- Korean layout/readability
- only after pass: four-school multiplication
```

Automated GREEN and human PASS remain separate evidence classes.

## 11. Current evidence ceiling

- MVP-0~3 integrated.
- DEC-014~026 planning canon approved.
- fresh Phase-B PASS.
- MVP-4 spatial production not started.
- DEC-014~026 migration runtime not started.
- release-near human QA not run.
- Android/export not ready.

Do not use this target map as proof that any missing runtime exists.
