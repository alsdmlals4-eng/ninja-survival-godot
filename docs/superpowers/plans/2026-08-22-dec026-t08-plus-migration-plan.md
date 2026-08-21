# DEC-026 T08+ Migration Plan

```yaml
status: READY_FOR_PHASE_B_REVIEW
source_main: 47d98b18d27c45874d473d469feba0a89bcc675b
source_canon:
  - docs/canon/2026-08-21-dec014-025-product-canon.md
  - docs/canon/2026-08-22-dec026-encounter-pattern-budget.md
preserve_old_tasks: T01_T07
runtime_claim: NONE
```

## Strategy

Keep the 2026-08-11 MVP-4 T01–T07 low-level spatial/domain plan. Replace the obsolete old T08–T12 execution route with the smallest sequence that proves one school end-to-end before four-school multiplication.

## New execution tasks

### T08 — RunRouteState / school circuit domain
- add one bounded Run-level route owner for unvisited/provisional/cleared schools, Stage index and clear order;
- reject revisits;
- separate school identity from Stage profile;
- fourth clear routes to Final Binding instead of Stage 5;
- unit tests first.

### T09 — Encounter definitions + StageEncounterProfile
- add data contracts for Core x3 / Elite / Boss / pattern refs per school;
- add Stage 1..4 profile with density/stat/depth/concurrency/capstone fields;
- implement only the minimum shared primitive vocabulary required by the first slice;
- no 16-controller duplication.

### T10 — Elite → Trace → Boss gate
- implement warning/Elite/chest token/trace lifecycle/Boss dual gate;
- pause new normal spawns while trace is AVAILABLE, not the clock/current hazards;
- prevent Elite/Boss overlap;
- seeded unit/integration tests.

### T11 — Access packages + reward lanes
- amend old T07 transaction layer with package/lane eligibility and canonical item-ID dedupe;
- preserve 19 items / 3 combinations / 5 bags;
- no auto school-stat bonus.

### T12 — Atomic Workbench + Fate + next-route commit
- keep route selection provisional during Workbench;
- define one transaction coordinator for final backpack snapshot + Fate + next school;
- all-or-nothing commit tests;
- UI remains intent/snapshot only.

### T13 — Persistent Workbench route-preview UI/input
- render unvisited-school cards, risk/gimmick/reward/tag links without exact hidden tuning values;
- keyboard/gamepad/touch paths;
- preserve backpack editing and six-slot buffer.

### T14 — Cheonsul one-school release-near Vertical Slice
- first 30s status/reaction signature;
- Core pressure using DEC-026 shared primitives;
- ~3m Elite;
- trace recovery;
- ~5m Boss;
- result/reward/branch/Workbench/next-route preview;
- production-candidate UI/visual/VFX/audio feedback sufficient for human judgment.

### T15 — Human QA gate
Measure:
- 30s school identity readability;
- Core→Elite→Boss tension curve;
- telegraph fairness;
- trace clarity;
- backpack/route comprehension;
- Workbench fatigue;
- Korean readability;
- whether placement changes next-combat expectation.

If this gate fails, correct the shared chassis before multiplying content.

### T16 — Expand Bongma / Guiin / Heukyeong
- reuse shared encounter chassis;
- author each school's Core x3 / Elite / Boss from DEC-026;
- tune product-identity deltas independently;
- preserve advanced-gimmick concurrency cap 2.

### T17 — Four-school circuit integration
- full free-order clear path;
- Stage 1..4 profile composition;
- trace/access-package progression;
- clear-order persistence;
- fourth-clear Final Binding routing.

### T18 — Final calamity package
- derive exact final-boss script from learned four-school languages;
- keep support callbacks short/situational and player-build victory ownership;
- this task may require a later focused final-boss content decision before implementation.

### T19 — Full-run verification
- Godot import/main smoke/full GUT;
- deterministic route/reward/commit tests;
- release-near full-run human QA;
- run-duration/rest-fatigue evidence;
- Windows first, Android/export near release per project policy.

## Dependency order

`T01→T07 preserved foundation -> T08 -> T09 -> T10 -> T11 -> T12 -> T13 -> T14 -> T15 GATE -> T16 -> T17 -> T18 -> T19`

T09–T13 can be subdivided into small PRs, but no later package may claim success without readback from merged main and regression evidence.

## Phase-B Definition of Ready

Ready inputs now exist for T08–T14:
- DEC-014~025 canon synced;
- DEC-026 attack/pattern budget approved;
- MVP-0~3 regression baseline preserved;
- old T01–T07 reuse boundary explicit;
- current open PR inventory was empty before this planning branch;
- historical PR #17 and stale T01 branch are not prerequisites.

Not yet ready to claim:
- runtime implementation;
- Human PASS;
- four-school completion;
- final-boss exact script;
- Android/export readiness.
