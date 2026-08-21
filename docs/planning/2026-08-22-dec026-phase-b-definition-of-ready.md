# DEC-026 Fresh Phase-B Definition of Ready

```yaml
project: NINJA_SURVIVAL
review_date: 2026-08-22 KST
source_main: 963e720c42534d50c72af4bd79cf5e446367cdbd
source_canon:
  - docs/canon/2026-08-21-dec014-025-product-canon.md
  - docs/canon/2026-08-22-dec026-encounter-pattern-budget.md
source_traceability: docs/traceability/2026-08-22-dec026-post-gate-traceability.md
source_plan: docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md
open_pr_conflict_at_review: NONE
verdict: PHASE_B_PASS
implementation_start: T01_FROM_FRESH_MAIN
runtime_claim: NONE
human_claim: NONE
```

## 1. Verdict

**PHASE_B_PASS.**

The product inputs required to implement the spatial foundation and the first school-circuit Vertical Slice are now sufficiently explicit. Production may begin from a **fresh branch created from merged main**, using TDD and small mergeable packages.

This PASS does not mean DEC-014~026 is implemented. Current gameplay remains the MVP-0~3 regression baseline until production tasks deliberately replace behavior with tests.

## 2. Why implementation begins at T01, not T08

DEC-026 closed the missing input for T08+ planning, but old MVP-4 T01~T07 were never implemented on production `main`.

Therefore the executable order is:

`T01 -> T02 -> T03 -> T04 -> T05 -> T06 -> T07 -> T08 -> T09 -> T10 -> T11 -> T12 -> T13 -> T14 -> T15 Human QA gate`.

Do not jump directly to route/encounter UI while the backpack domain, committed modifier authority and transaction foundation are missing.

The historical `impl/mvp4-t01-spatial-data-contracts` branch is not reused as a base. It may be consulted only as historical evidence if useful; implementation branches start from current merged main.

## 3. Current runtime ownership readback

### StageFlowController — keep phase/timer ownership only

Current file: `scripts/core/stage_flow_controller.gd`.

Current behavior is a strict MVP-3 state machine:

`SCHOOL_SELECT -> COMBAT -> BOSS -> RESULT -> SHOP -> FATE -> PREVIEW`, with completion after segment 3.

Current tests explicitly protect the third-Fate completion/no-segment-four behavior. This remains rollback evidence until new migration tests replace the relevant expectation.

**Phase-B decision:** do not make StageFlowController own school clear order, access packages, provisional route or backpack/Fate transaction state. It may evolve to orchestrate combat/rest phases and timing/gates, while dedicated Run-level owners supply route/trace state.

### MainController — preserve composition-root role

Current file: `scripts/core/main_controller.gd`.

It currently creates/configures RunBuildState, ShopController, FateController, StageFlowController, contribution/combat systems and the REST UI, wires signals, spawns the stage Boss and transitions rest screens.

**Phase-B decision:** MainController remains the composition root/integration adapter. Do not turn it into a second rule engine. New domain state is instantiated/wired here, while legality and atomic transactions stay in dedicated classes.

### RunBuildState — final committed combat-build authority

Current file: `scripts/core/run_build_state.gd`.

Current MVP-3 behavior owns immediate item counts, GOLD, selected Fates and recomputed modifiers.

**Migration rule:** T06 makes it consume the committed spatial snapshot instead of retaining legacy item-count behavior as a competing final modifier authority. GOLD may remain here if the T01~T07 implementation preserves one economy authority, but spatial legality and REST editing do not move into RunBuildState.

### FateController — candidate/selection intent, not final commit authority

Current file: `scripts/core/fate_controller.gd`.

Current `choose()` immediately calls `RunBuildState.select_fate()`. That is correct MVP-3 evidence but conflicts with DEC-025 all-or-nothing `backpack + Fate + next school` commit.

**Migration rule:** retain Fate candidate generation/validation responsibilities; stop using direct RunBuildState mutation as the final DEC-025 commit path. T12 introduces one transaction boundary that validates all three inputs before committing any of them.

### ShopController — shop interaction, not reward-pool canon

Current file: `scripts/core/shop_controller.gd`.

Current `_roll_offers()` uses a flat item pool and purchases directly into RunBuildState.

**Migration rule:** T07/T11 add a deterministic reward/access resolver below acquisition UIs. ShopController requests eligible offers/transactions; it does not independently define school-package eligibility or duplicate a reward-lane algorithm.

### WaveSpawner — generic normal-spawn actuator

Current file: `scripts/spawning/wave_spawner.gd`.

It currently owns generic timed batch spawning and an enable/disable switch.

**Migration rule:** preserve it as an actuator where possible. Encounter/trace gate state tells it when normal spawning is allowed. Do not put Elite/Trace/Boss lifecycle truth inside WaveSpawner.

## 4. New single-authority map

| Domain | Authority | UI / controller relationship |
|---|---|---|
| Backpack occupied cells, rotation, usable area, buffer | `BackpackState` + `BackpackResolver` | UI emits intents/renders snapshots |
| REST pending spatial edits | `RestBackpackSession` | Workbench UI never mutates committed build directly |
| Combination transaction | `CombinationResolver` | atomic result returned to session |
| Committed combat modifiers | `RunBuildState` after T06 migration | combat reads snapshot only |
| School visit/provisional/clear order, Stage index | new `RunRouteState` | route UI reads snapshot/emits provisional intent |
| Encounter composition | `SchoolEncounterDefinition` + `StageEncounterProfile` | Stage runtime consumes data |
| Elite/Trace/Boss lifecycle | new bounded `StageEncounterState` / coordinator | StageFlow observes gate outcomes; WaveSpawner acts on spawn permission |
| Access packages/reward lanes | new `RewardPoolResolver` (name may vary if repo convention requires) | Shop/Chest/Boss reward request seeded candidates |
| Fate candidates | `FateController` | selection remains pending until commit |
| Final REST commit | new `RestCommitCoordinator` | validates backpack snapshot + pending Fate + provisional route, then commits all-or-none |
| Screen composition/signals | `MainController` + UI nodes | no gameplay rule duplication |

Names above are intended owner boundaries. During implementation, a class may be renamed to match repository conventions, but two authorities for the same truth are not allowed.

## 5. T01~T14 exact implementation packages

### T01 — spatial data contracts/catalog

**New candidate files**
- `scripts/data/item_shape_definition.gd` if shape fields cannot live cleanly in existing ItemDefinition without breaking MVP-3 compatibility;
- `scripts/data/bag_definition.gd`;
- `scripts/data/mvp4_catalog.gd`.

**Prefer extending** `scripts/data/item_definition.gd` when backward-compatible fields are sufficient rather than creating parallel item identities.

**Tests**
- catalog IDs unique and deterministic;
- 19 base items / 5 bags / 3 combination inputs/results protected;
- rotation/shape/tag data validates;
- combo-result IDs excluded from base acquisition pool.

**Rollback:** data-only package; no main-scene behavior change.

### T02 — BackpackState

**New** `scripts/core/backpack_state.gd` or `scripts/backpack/backpack_state.gd` if a dedicated folder becomes justified.

Owns cells/items/bags/rotation/active-area facts only. No UI nodes, GOLD spending, Fate or combat modifiers.

**Tests:** place/move/remove/rotate, 4x3 start within 6x6, occupied-cell collisions, bag expansion, snapshot/copy isolation.

### T03 — BackpackResolver

**New** deterministic pure resolver.

Owns orthogonal adjacency, usable cells, special-bag overlap activation and static spatial effect resolution. No item-ID branching in UI.

**Tests:** adjacency edges, rotation invariants, L/T bag coverage, invalid overlaps, deterministic identical-input output.

### T04 — RestBackpackSession

Owns pending REST edits and six-slot buffer. It does not change RunBuildState until T12 final commit.

**Tests:** edit/undo-like replacement semantics as specified, buffer cap, pending snapshot isolation, invalid intent leaves session unchanged.

### T05 — CombinationResolver

Explicit atomic first-tier combinations. Failed recipe leaves inputs unchanged; successful recipe consumes/creates exactly once.

**Tests:** all three protected recipes, rotation-independent identity where applicable, no partial consumption.

### T06 — committed RunBuildState migration

Replace legacy immediate item-count modifier authority with committed spatial-build modifier snapshot. Preserve GOLD/Fate effects where compatible and regression-test the old item effects through the new committed path.

**Critical:** never leave both old `owned_items` modifier recomputation and new spatial snapshot simultaneously authoritative.

### T07 — acquisition transaction foundation

Boss/Shop/Chest transaction layer writes rewards into REST buffer/session rather than directly increasing committed combat power.

Keep source distinction for Boss/Shop/Chest and deterministic seeded tests.

### T08 — RunRouteState

**New candidate:** `scripts/core/run_route_state.gd`.

Owns:
- four school IDs;
- `unvisited / provisional-next / cleared`;
- clear order;
- Stage index 1..4 independent from school identity;
- no revisit;
- provisional changes before commit;
- fourth clear -> final-binding eligibility.

**Tests:** all 24 four-school orders may be generated/accepted when legal; revisit rejection; failed provisional selection no mutation; final-binding only after four unique clears.

### T09 — encounter definitions / Stage profiles

**New candidate data files**
- `scripts/data/encounter_pattern_definition.gd`;
- `scripts/data/school_encounter_definition.gd`;
- `scripts/data/stage_encounter_profile.gd`;
- catalog entries for DEC-026 school sets.

Start with shared primitives required by Cheonsul; definitions for other schools may be authored as data but production scenes/behavior are not multiplied before T15.

**Tests:** Core x3/Elite/Boss refs valid, Stage depth 1..4, advanced-gimmick cap <=2, Stage4 capstone flag only where intended.

### T10 — Elite -> Trace -> Boss gate

**New candidate:** `scripts/core/stage_encounter_state.gd` plus a trace scene/script only if a world object is required.

Owns lifecycle:
`CORE -> ELITE_WARNING -> ELITE_ACTIVE -> TRACE_AVAILABLE -> TRACE_RECOVERED -> BOSS_WARNING -> BOSS_ACTIVE -> CLEARED`.

It emits facts; `WaveSpawner` remains normal-spawn actuator; `StageFlowController` remains phase/timer orchestration.

**Tests:** Elite token/trace exactly once; trace no expiry; normal spawn disabled while trace available; clock not paused; no Elite/Boss overlap; late recovery soft overtime; Boss requires all gates.

### T11 — access packages / reward lanes

**New candidate:** `scripts/core/reward_pool_resolver.gd` or equivalent deterministic domain service.

Owns Universal + school package access, lane-before-item selection and canonical item-ID dedupe. ShopController/Chest/Boss reward do not each reimplement eligibility.

**Tests:** starting package access, trace stabilization unlock, dedupe, combo-result exclusion, no recipe-completion guarantee for Chest.

### T12 — atomic REST commit

**New candidate:** `scripts/core/rest_commit_coordinator.gd`.

Input:
- valid pending Backpack/Workbench snapshot;
- pending Fate candidate;
- provisional next-school choice.

Commit succeeds only if all validate. On failure none of committed build/Fate/route changes.

FateController should expose pending selection/candidate validation instead of being the final mutator.

**Tests:** fail each input independently and verify all three committed states unchanged; success commits exactly once; duplicate commit rejected.

### T13 — Workbench + route-preview UI/input

Extend the existing REST UI or introduce focused child components rather than one giant scene script.

UI shows only unvisited schools and human-readable risk/gimmick/reward/tag links; exact hidden HP/DPS/spawn values stay hidden.

Keyboard/gamepad/touch paths and focus restoration are testable. UI emits intents; it never owns legality.

### T14 — Cheonsul release-near Vertical Slice

Integrate only enough content to judge the real loop:

`<=30s Cheonsul setup/reaction signature -> Core pressure -> ~3m Elite -> Trace -> ~5m Boss -> Result/Reward -> branch -> Workbench -> provisional route preview`.

Reuse current Cheonsul runtime where it already expresses setup/reaction. Replace only the pieces required by approved DEC-026 behavior.

This package is not Human PASS by itself; T15 is the separate human gate.

## 6. TDD / merge package order

Recommended PR slices:

1. **P1:** T01 data contracts/catalog.
2. **P2:** T02 BackpackState.
3. **P3:** T03 resolver.
4. **P4:** T04 session + T05 combination if diff remains reviewable; split otherwise.
5. **P5:** T06 committed modifier migration.
6. **P6:** T07 acquisition transaction foundation.
7. **P7:** T08 route state.
8. **P8:** T09 encounter/profile data.
9. **P9:** T10 Elite/Trace/Boss gate.
10. **P10:** T11 reward/access resolver.
11. **P11:** T12 atomic commit.
12. **P12:** T13 UI/input.
13. **P13:** T14 Cheonsul Vertical Slice integration.
14. **Gate:** T15 Human QA before T16 multiplication.

Every package:

`red test -> minimal implementation -> focused test -> full GUT -> import -> main smoke -> diff/readback -> adversarial review -> merge -> merged-main readback`.

If an existing open/draft PR appears, do not modify or merge it as part of unrelated follow-up; re-evaluate package ownership from main.

## 7. Regression replacement policy

The current `test_stage_flow_controller.gd` explicitly asserts no segment 4. Do not simply delete it when migrating.

When T08/T10/T17 intentionally replace that behavior:

1. add new tests proving the approved four-school route and final-binding transition;
2. keep unchanged MVP-3 tests that still describe reusable phase rules;
3. replace only expectations directly superseded by current canon;
4. document the supersession in the implementation PR.

The same applies to Fate tests that currently assert `choose()` immediately updates RunBuildState: T12 must first add atomic-commit tests, then deliberately migrate the old expectation.

## 8. Implementation Reality Gate

### Confirmed now

- current `main` at review: `963e720c42534d50c72af4bd79cf5e446367cdbd`;
- open PR inventory: none at fresh Phase-B start;
- DEC-014~025 and DEC-026 are merged planning canon;
- PR #22 exact-head GUT workflow succeeded;
- current controllers and tests still describe MVP-3 runtime, proving the migration is real rather than already implemented;
- T01~T07 production code is still absent and must precede T08+.

### Not confirmed / not claimed

- T01~T14 runtime implementation;
- new 4-school run execution;
- Trace world object behavior;
- atomic Workbench/Fate/route runtime;
- release-near Human QA;
- four-school full-run duration/fatigue;
- final calamity exact script;
- Android/export.

## 9. Five-round adversarial review

### Loop 1 — duplicate authority attack

Finding: easiest implementation would let MainController, StageFlowController, FateController and UI each hold pieces of route/commit truth.

Correction: explicit authority map; RunRouteState owns route, RestCommitCoordinator owns final transaction, MainController only composes.

**Result: PASS after boundary correction.**

### Loop 2 — premature T08 attack

Finding: DEC-026 makes T08+ plan-ready, but T01~T07 are not in main. Starting route UI first would create temporary parallel inventory/reward code and rework.

Correction: implementation starts T01 from fresh main; T08+ stays sequenced after T07.

**Result: PASS.**

### Loop 3 — regression destruction attack

Finding: old tests encode three-segment/Fate-immediate behavior and could be deleted merely to make new code green.

Correction: test supersession policy requires new approved-behavior evidence before replacing only directly conflicting expectations.

**Result: PASS.**

### Loop 4 — content multiplication attack

Finding: DEC-026 defines 4x Core/Elite/Boss sets, inviting production of all four before validating the loop.

Correction: T14 Cheonsul first, T15 Human QA hard gate, T16 remaining schools only afterward.

**Result: PASS.**

### Loop 5 — overarchitecture attack

Finding: new route, encounter, reward and transaction domains could become a framework project.

Correction: each new owner is introduced only for an already-approved distinct source of truth; use current MainController/WaveSpawner/RunBuildState/Shop/Fate systems where responsibility remains valid; no event bus, ECS, DI framework or generic scripting language is required for this MVP.

**Result: PASS.**

## 10. Phase-B close condition

`PHASE_B_PASS` is valid because there is now one executable order, one authority map, explicit rollback points, explicit test migration rules and an evidence ceiling.

**Next execution point:** fresh production branch from the merged Phase-B main, beginning with **T01 spatial data contracts/catalog**, not runtime T08 directly.
