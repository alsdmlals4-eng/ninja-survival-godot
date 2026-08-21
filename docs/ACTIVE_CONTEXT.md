# ACTIVE_CONTEXT

```yaml
project: NINJA_SURVIVAL
state_router_updated_at: 2026-08-22 KST
resume_state: PHASE_B_PASS_READY_FOR_T01
next_material_gate: T01_SPATIAL_DATA_CONTRACTS
production_build_for_new_canon: READY_WITH_TDD_FROM_FRESH_MAIN
mvp0_to_mvp3_runtime: INTEGRATED
mvp4_spatial_production: NOT_STARTED
school_circuit_runtime: NOT_STARTED
trace_runtime: NOT_STARTED
dec026_encounter_runtime: NOT_STARTED
release_near_vertical_slice_human_qa: NOT_RUN
android_device_qa: NOT_RUN
```

## Purpose

This file is the mutable resume router. Product rules live in `docs/CURRENT_CONFIRMED_DECISIONS.md` and dated canon files. Implementation facts live in actual code/scenes/tests and executed evidence.

Do not reconstruct current state from older handoff status sentences without first reading current `main`, current PR inventory and this router.

## Current read order

1. `AGENTS.md`
2. active chat/user instruction
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. `docs/canon/2026-08-21-dec014-025-product-canon.md`
5. `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
6. `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`
7. `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
8. `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`
9. `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
10. old `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md` **T01-T07 only**
11. actual `scripts/`, `scenes/`, `tests/`, `.github/workflows/gut.yml`
12. current Notion project home / Flow / Core System / Production Handoff
13. current Base `main` when Base freshness materially affects the task

## Current integrated truth

- MVP-0 basic combat is integrated.
- MVP-1 combat DDD is integrated.
- MVP-2 four-school shallow runtime is integrated.
- MVP-3 result/GOLD/Shop/Fate/three-segment runtime is integrated and remains rollback/regression baseline.
- Existing CI has source-faithful GUT preparation and duplicate-UID failure protection.
- Old MVP-3 three-segment flow is implementation reality, not the latest product target.
- MVP-4 spatial/backpack production code has not started.
- DEC-014~025 and DEC-026 are approved product/planning canon and have not been implemented yet.
- Fresh Phase-B review has passed for the T01~T14 execution chain and explicitly starts production at T01.

Last observed planning-PR regression evidence before production:

`Godot 4.7.1 import/main smoke/full GUT workflow PASS`; the protected quantitative baseline remains `34 scripts / 250 tests / 1624 assertions` from the unchanged MVP-0~3 runtime.

Do not treat this as DEC-014~026 runtime evidence.

## Current product target

```text
starting school
-> choose unvisited school battlefield
-> Core Monsters / Stage profile
-> ~3 min Elite
-> chest token + trace
-> recover trace
-> Boss warning / dual gate
-> school Boss around five-minute boundary
-> RESULT / Boss Reward
-> joint branch / trace STABILIZED
-> Persistent Workbench
-> provisional next-school choice
-> Shop / Chest / Backpack / Combination
-> Fate atomically commits build + Fate + next route
-> repeat until four schools cleared
-> Final Binding Workbench
-> separate final calamity Boss
-> final result / Ninja Soul
```

`~20 minutes` ends the four-school active-combat circuit, not the full Run.

## DEC-026 encounter rule

Use a shared attack-primitive chassis with school-owned compositions. Do not create four separate combat engines or 16 hardcoded school×Stage controllers.

- 봉마: mobile prepared-space pressure.
- 천술: setup -> elemental reaction.
- 귀인: sustained proximity pressure with readable recovery windows.
- 흑영: visible threat/mark -> delayed execution.

Stage depth grows from signature -> interaction -> synergy -> mastery/capstone, with maximum two advanced gimmicks concurrently.

## Phase-B authority map

- `BackpackState/BackpackResolver`: spatial legality and resolved spatial effects.
- `RestBackpackSession`: pending REST edits and six-slot buffer.
- `CombinationResolver`: atomic combination rules.
- `RunBuildState`: final committed combat modifier authority after T06 migration.
- `RunRouteState`: school visit/provisional/clear order and Stage index.
- encounter definitions/profiles: school content + Stage depth data.
- bounded stage encounter state/coordinator: Elite/Trace/Boss lifecycle.
- reward/access resolver: package/lane eligibility and deterministic dedupe.
- `FateController`: candidate/pending Fate responsibility, not final multi-domain commit authority.
- `RestCommitCoordinator`: atomic backpack + Fate + next-school commit.
- `MainController`: composition/integration only.
- `WaveSpawner`: normal-spawn actuator, not lifecycle truth.

Full review: `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`.

## Executable order

`T01 -> T02 -> T03 -> T04 -> T05 -> T06 -> T07 -> T08 -> T09 -> T10 -> T11 -> T12 -> T13 -> T14 -> T15 Human QA gate`.

DEC-026 closed the T08+ planning blocker, but T01~T07 are still absent from production main. Therefore do not jump directly to T08.

## Next executable work — T01

Create a **fresh production branch from merged main** and implement spatial data contracts/catalog with TDD.

T01 must preserve current item identity while adding only the data needed for 6x6/4x3 shapes, rotation, bag definitions, tags and protected combinations. Prefer extending existing ItemDefinition when backward-compatible instead of creating duplicate item authority.

T01 close gate:

`red tests -> minimal data implementation -> focused tests -> full GUT -> import -> main smoke -> diff/readback -> adversarial review -> merge -> merged-main readback`.

## Regression replacement rule

Current MVP-3 tests are rollback evidence. Do not delete conflicting tests just to make migration green. Add approved new behavior evidence first, then replace only expectations explicitly superseded by current canon.

## Historical routes

- PR #17 is closed/unmerged/historical and not a prerequisite.
- `impl/mvp4-t01-spatial-data-contracts` is historical and not a production base.
- historical PRs/handoffs remain evidence and are not rewritten.

## Human evidence rule

Before four-school multiplication, T14 builds the Cheonsul slice and T15 separately human-tests:

`signature <=30 sec -> Core -> Elite -> trace -> Boss -> reward -> Workbench -> next-route preview`.

Technical placeholder/card UI may support spikes/tests but cannot close final player-experience PASS.

## Runtime/tool boundary

Latest product-canon migration runtime remains `NOT_RUN`. Android/export remain release-near work, not a Phase-B readiness condition.

## Resume rule

`fetch latest main -> inspect open/recent merged PRs -> read current decisions/canon/Phase-B/plan -> compare actual code/tests -> continue only from evidence-backed state`.
