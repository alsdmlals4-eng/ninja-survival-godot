# ACTIVE_CONTEXT

```yaml
project: NINJA_SURVIVAL
state_router_updated_at: 2026-08-24 KST
resume_state: T01_INTEGRATED_READY_FOR_T02
next_material_gate: T02_BACKPACK_STATE
production_build_for_new_canon: IN_PROGRESS_T01_DATA_FOUNDATION_MERGED
mvp0_to_mvp3_runtime: INTEGRATED
mvp4_spatial_production: T01_DATA_FOUNDATION_INTEGRATED
backpack_state_runtime: NOT_STARTED
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
10. `docs/planning/2026-08-11-mvp4-content-data-contract.md`
11. old `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md` **T02-T07 reusable detail only**
12. actual `scripts/`, `scenes/`, `tests/`, `.github/workflows/gut.yml`
13. current Notion project home / Flow / Core System / Production Handoff
14. current Base `main` when Base freshness materially affects the task

## Current integrated truth

- MVP-0 basic combat is integrated.
- MVP-1 combat DDD is integrated.
- MVP-2 four-school shallow runtime is integrated.
- MVP-3 result/GOLD/Shop/Fate/three-segment runtime is integrated and remains rollback/regression baseline.
- Existing CI has source-faithful GUT preparation and duplicate-UID failure protection.
- Old MVP-3 three-segment flow is implementation reality, not the latest product target.
- **T01 spatial data contracts/catalog are integrated on main.**
- T01 adds the data foundation only: 19 base acquisition items, 3 combination-result lookup items, one starting 4x3 bag + five purchasable bags, eight strong-spatial item definitions, three first-tier combination definitions, bounded spatial-rule data and modifier validation.
- T01 does **not** implement BackpackState, spatial legality/resolution, REST editing, combination transactions, Workbench UI or playable backpack behavior.
- DEC-014~025 and DEC-026 are approved product/planning canon; their school-circuit/trace/encounter runtime remains not implemented.
- Fresh Phase-B remains the execution boundary for the T01~T14 chain.

## T01 implementation receipt

```yaml
t01_pr: 27
t01_merge_sha: 7c9206702526f99dfadf44a617cd150853ec733f
baseline_main: eafec9c9d8efed7869734ca0d4b0a3372017d1da
red_1_head: b6b7f0b52f73a8354143c69c927c9e57db9d33c4
red_1_workflow: 32688077232
red_1_result: IMPORT_PASS_MAIN_SMOKE_PASS_OLD_250_PASS_NEW_T01_CONTRACTS_FAIL_AS_EXPECTED
green_1_head: cbc431bea445da456f1bec5a5df15aca3ecdc3fe
green_1_workflow: 32688283418
green_1_result: 260_OF_260_PASS_1826_ASSERTIONS
schema_experiment: EXPORTED_TYPED_DICTIONARY_REJECTED_AFTER_GODOT_IMPORT_REGRESSION
red_2_head: 3c570d86898d817bf1ec5abd04463ccfc867490f
red_2_workflow: 32688990852
red_2_result: OLD_260_PASS_NEW_3_VALIDATION_CASES_FAIL_AS_EXPECTED
final_head: 97b2258abdbbf5bcf2833e0e04174f5d0537a675
final_workflow: 32689126286
final_job: 97319490788
final_result: GODOT_4_7_1_IMPORT_PASS_MAIN_SMOKE_PASS_GUT_263_OF_263_PASS_1829_ASSERTIONS
human_evidence: NOT_RUN
```

The stricter typed-Dictionary experiment was not retained because it caused an actual import regression. Current data uses Godot-compatible `Dictionary` storage with supported-key and numeric-value validation at the catalog boundary. This is an evidence-driven compatibility choice, not a relaxation of the validation requirement.

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

- `ItemDefinition` / `MVP4Catalog`: T01 data identity, footprint/tag/static/spatial metadata and explicit acquisition boundaries.
- `BackpackState/BackpackResolver`: spatial legality and resolved spatial effects — **T02/T03, not implemented yet**.
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

T01 is complete. Remaining approved implementation order is:

`T02 -> T03 -> T04 -> T05 -> T06 -> T07 -> T08 -> T09 -> T10 -> T11 -> T12 -> T13 -> T14 -> T15 Human QA gate`.

Do not jump directly to T08; the remaining spatial/transaction foundation must still be implemented in order.

## Next executable work — T02

Create a **fresh production branch from merged main** and implement `BackpackState` with TDD.

T02 owns committed spatial facts only:

- fixed 6x6 board,
- starting 4x3 active area supplied by T01 catalog data,
- stable item/bag instance identity,
- origin/rotation,
- place/move/remove/rotate state transitions,
- occupied-cell collision facts,
- bag expansion state,
- snapshot/copy isolation.

T02 must not absorb `BackpackResolver` adjacency/special-bag calculation, GOLD spending, Fate, UI or combat modifier authority.

T02 close gate:

`red tests -> minimal implementation -> focused tests -> full GUT -> import -> main smoke -> diff/readback -> adversarial review -> merge -> merged-main readback`.

## Regression replacement rule

Current MVP-3 tests are rollback evidence. Do not delete conflicting tests just to make migration green. Add approved new behavior evidence first, then replace only expectations explicitly superseded by current canon.

## Historical routes

- PR #17 is closed/unmerged/historical and not a prerequisite.
- `impl/mvp4-t01-spatial-data-contracts` is historical and not a production base.
- PR #27 is the merged T01 implementation evidence; new packages branch from its merged main result, not from the old branch.
- historical PRs/handoffs remain evidence and are not rewritten.

## Human evidence rule

Before four-school multiplication, T14 builds the Cheonsul slice and T15 separately human-tests:

`signature <=30 sec -> Core -> Elite -> trace -> Boss -> reward -> Workbench -> next-route preview`.

Technical placeholder/card UI may support spikes/tests but cannot close final player-experience PASS.

## Runtime/tool boundary

T01 data resources have actual Godot 4.7.1 import/main-smoke/full-GUT evidence. **Playable spatial backpack runtime remains NOT_RUN because T02+ does not exist yet.** Android/export and Human QA remain release-near work and are not implied by T01 completion.

## Resume rule

`fetch latest main -> inspect open/recent merged PRs -> read current decisions/canon/Phase-B/plan -> compare actual code/tests -> continue only from evidence-backed state`.
