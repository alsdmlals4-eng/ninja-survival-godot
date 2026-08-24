# ACTIVE_CONTEXT

```yaml
project: NINJA_SURVIVAL
state_router_updated_at: 2026-08-24 KST
resume_state: T02_INTEGRATED_READY_FOR_T03
next_material_gate: T03_BACKPACK_RESOLVER
production_build_for_new_canon: IN_PROGRESS_T02_BACKPACK_STATE_MERGED
mvp0_to_mvp3_runtime: INTEGRATED
mvp4_spatial_production: T01_T02_INTEGRATED
backpack_state_runtime: INTEGRATED
backpack_resolver_runtime: NOT_STARTED
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
11. old `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md` **T03-T07 reusable detail only**
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
- **T02 BackpackState is integrated on main.**
- T01 supplies canonical item/bag/combination/spatial-rule definitions and acquisition boundaries.
- T02 adds committed 6x6 backpack spatial state: centered 4x3 starting area, stable item/bag instances, origin/rotation, atomic place/move/remove/rotate, item/item and bag/bag collision facts, active-area union, orphan prevention and defensive snapshot/copy isolation.
- T02 deliberately does **not** implement orthogonal adjacency resolution, bag connectivity rule, special-bag overlap effects, REST editing, combination transactions, Workbench UI or combat modifier migration.
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

## T02 implementation receipt

```yaml
t02_pr: 29
t02_merge_sha: 126e6c942d74f97166ef0c881afc5d79cae3d274
baseline_main: 9cf3f15b8c390bc412082f397500a58905bf5912
red_1_head: 9635f923325b5b70fa1f37776f56512485de0738
red_1_workflow: 32690539179
red_1_result: IMPORT_PASS_MAIN_SMOKE_PASS_OLD_263_PASS_NEW_T02_RESOURCES_FAIL_AS_EXPECTED
green_1_head: 5e6b1481009e96cec1b9f8e03da43f504b42ea0e
green_1_workflow: 32690747727
green_1_result: 271_OF_271_PASS_1894_ASSERTIONS
authority_red_head: 1d4c94dc66e39d3689430ca42a694d04132eb774
authority_red_workflow: 32690939823
authority_finding: LIVE_ITEMS_AND_BAGS_VIEWS_COULD_BYPASS_COMMITTED_STATE_VALIDATION
authority_green_head: 853ba62160637a16fff4a1438194b0e2d2988639
authority_green_workflow: 32691023039
authority_green_result: 272_OF_272_PASS_1897_ASSERTIONS
final_head: 60adbb99886c96c687b20befe4a61e5e3bcb71f1
final_workflow: 32691243156
final_job: 97325177811
final_result: GODOT_4_7_1_IMPORT_PASS_MAIN_SMOKE_PASS_GUT_274_OF_274_PASS_1915_ASSERTIONS
t02_focused_tests: 11_OF_11_PASS
human_evidence: NOT_RUN
```

The adversarial authority finding was closed by moving live instance collections behind defensive public snapshots. Invalid definitions/ids/placements are atomic no-ops and failed additions do not consume shared instance IDs.

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

- `ItemDefinition` / `MVP4Catalog`: T01 data identity, footprint/tag/static/spatial metadata and explicit acquisition boundaries — **INTEGRATED**.
- `BackpackState`: committed board/item/bag/origin/rotation/active-area/collision facts — **T02 INTEGRATED**.
- `BackpackResolver`: deterministic connected-layout legality, orthogonal adjacency, special-bag overlap and active spatial modifier resolution — **T03 NEXT**.
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

T01 and T02 are complete. Remaining approved implementation order is:

`T03 -> T04 -> T05 -> T06 -> T07 -> T08 -> T09 -> T10 -> T11 -> T12 -> T13 -> T14 -> T15 Human QA gate`.

Do not jump directly to T08; the remaining spatial/transaction foundation must still be implemented in order.

## Next executable work — T03

Create a **fresh production branch from merged main** and implement `BackpackResolver` with TDD.

T03 owns deterministic spatial rule resolution over committed `BackpackState` facts:

- connected usable-cell/layout legality required by the approved spatial spec,
- orthogonal adjacency evaluation,
- special-bag one-cell-overlap activation,
- deterministic active spatial modifier resolution,
- no mutation of the committed state while resolving.

T03 must not absorb `RestBackpackSession`, GOLD/Fate, Workbench UI, combination transactions or final combat-modifier authority.

T03 close gate:

`red tests -> minimal implementation -> focused tests -> full GUT -> import -> main smoke -> diff/readback -> adversarial review -> merge -> merged-main readback`.

## Regression replacement rule

Current MVP-3 tests are rollback evidence. Do not delete conflicting tests just to make migration green. Add approved new behavior evidence first, then replace only expectations explicitly superseded by current canon.

## Historical routes

- PR #17 is closed/unmerged/historical and not a prerequisite.
- old `impl/mvp4-t01-spatial-data-contracts` is historical and not a production base.
- PR #27 is merged T01 implementation evidence.
- PR #29 is merged T02 implementation evidence.
- historical PRs/handoffs remain evidence and are not rewritten.

## Human evidence rule

Before four-school multiplication, T14 builds the Cheonsul slice and T15 separately human-tests:

`signature <=30 sec -> Core -> Elite -> trace -> Boss -> reward -> Workbench -> next-route preview`.

Technical placeholder/card UI may support spikes/tests but cannot close final player-experience PASS.

## Runtime/tool boundary

T01 data resources and T02 committed spatial state have actual Godot 4.7.1 import/main-smoke/full-GUT evidence. **Playable Workbench interaction remains NOT_RUN/NOT_STARTED because T03+ resolver/session/UI integration does not exist yet.** Android/export and Human QA remain release-near work and are not implied by T02 completion.

## Resume rule

`fetch latest main -> inspect open/recent merged PRs -> read current decisions/canon/Phase-B/plan -> compare actual code/tests -> continue only from evidence-backed state`.
