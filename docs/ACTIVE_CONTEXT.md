# ACTIVE_CONTEXT

```yaml
project: NINJA_SURVIVAL
state_router_updated_at: 2026-08-24 KST
resume_state: T11_MERGED_MAIN_T12_OPEN_DRAFT_READ_ONLY
next_material_gate: T12_OPEN_DRAFT_REVIEW_ONLY
production_build_for_new_canon: T01_TO_T11_DOMAIN_SURFACES_PRESENT_ON_MERGED_MAIN
mvp0_to_mvp3_runtime: INTEGRATED
mvp4_spatial_production: T01_T02_T03_T04_T05_INTEGRATED
backpack_state_runtime: INTEGRATED
backpack_resolver_runtime: INTEGRATED
rest_backpack_session_runtime: INTEGRATED
combination_transaction_runtime: INTEGRATED
t06_to_t11_domain_surfaces: PRESENT_ON_MERGED_MAIN
committed_spatial_combat_integration: SOURCE_AND_TEST_SCOPE_ONLY
school_circuit_runtime: SOURCE_AND_TEST_SCOPE_ONLY
trace_runtime: SOURCE_AND_TEST_SCOPE_ONLY
dec026_encounter_runtime: SOURCE_AND_TEST_SCOPE_ONLY
playable_workbench_ui_input: NOT_RUN
production_candidate_visual_audio_feedback: NOT_RUN
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
11. old `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md` **T06-T07 reusable detail only**
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
- **T03 BackpackResolver is integrated on main.**
- **T04 RestBackpackSession is integrated on main.**
- **T05 CombinationResolver is integrated on main.**
- **T06~T11 domain surfaces are present on current merged `main` (`265bab32da087c070ea2ea0d98a3bdace1e10f7f`): committed build, route, encounter, REST reward/shop, and tradition-access reward lanes.**
- **PR #43 is a T12 draft. It is `OPEN_DRAFT_READ_ONLY`, not merged authority.**
- T01 supplies canonical item/bag/combination/spatial-rule definitions and acquisition boundaries.
- T02 adds committed 6x6 backpack spatial state: centered 4x3 starting area, stable item/bag instances, origin/rotation, atomic place/move/remove/rotate, item/item and bag/bag collision facts, active-area union, orphan prevention and defensive snapshot/copy isolation. T04 adds only validated stable-instance restore owner paths for buffer/rebuild use.
- T03 reads T02 defensive snapshots and deterministically resolves connected active layouts, orthogonal adjacency, T01 spatial-rule aggregation, special-bag overlap effects, selected-school emblem/static modifiers, reasoned placement previews and all-or-nothing whole-layout translation without mutating committed state.
- T04 owns a copy of committed state for REST editing: exact six-slot buffer, defensive build preview snapshot, selected-school preview context, deep edit history/undo-redo, pending-bag placement, explicit mutually-exclusive whole-layout mode, atomic translation and deterministic commit-readiness failures.
- T05 reuses T01 recipes/T03 adjacency/T04 session state to resolve valid on-board source pairs, progressive combination hints and source-preserving pending result transactions; only a valid resolved result placement atomically consumes exactly two sources and creates one result.
- T01~T11 source/test surfaces do not prove an actual playable Workbench UI/input path, production-candidate visual/audio feedback, device readiness, or Human experience. Those evidence states remain **NOT_RUN**.
- DEC-014~025 and DEC-026 remain approved product/planning canon; no source/test receipt alone promotes the full release-near Vertical Slice.
- Fresh Phase-B remains the planning boundary; the next source review boundary is the T12 draft, not an automatic implementation authorization.

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

## T03 implementation receipt

```yaml
t03_pr: 31
t03_merge_sha: 2dcf055d82df02d44335f209897436572efa6739
baseline_main: a7515e8bfe7ac3678ba6a10863361a681e822d0e
red_1_head: f596f1bc3bacaee32fde7acc3eb40844db96da53
red_1_workflow: 32692921634
red_1_job: 97329698394
red_1_result: BASE_MANIFEST_PASS_IMPORT_PASS_MAIN_SMOKE_PASS_OLD_274_PASS_NEW_T03_RESOURCES_FAIL_AS_EXPECTED
green_1_head: 12b1fdf91fd9bca548869390ec39ff0a560c218b
green_1_workflow: 32693124217
green_1_job: 97330248507
green_1_result: GUT_285_OF_285_PASS_1989_ASSERTIONS_T03_11_OF_11
hardening_1_head: 6215ecea5809eb04dae0113912f30a96ea4e1096
hardening_1_workflow: 32693300464
hardening_1_job: 97330722718
hardening_1_result: GUT_288_OF_288_PASS_2007_ASSERTIONS_T03_CORE_14_OF_14
hardening_2_head: 664050e51845b93049664a79fc02fc342991af6e
hardening_2_workflow: 32693403582
hardening_2_job: 97331012865
hardening_2_result: GUT_291_OF_291_PASS_2022_ASSERTIONS_T03_CORE_14_ADV_3
diagnostic_red_head: 89940837b46e3f0579a36d67ff4b44dd69b0720b
diagnostic_red_workflow: 32693526072
diagnostic_red_job: 97331350057
diagnostic_red_result: IMPORT_PASS_MAIN_SMOKE_PASS_291_OF_292_ONLY_MISSING_STATE_REASON_FAIL
diagnostic_finding: NULL_STATE_MISREPORTED_AS_MISSING_CANDIDATE
final_head: e0dacee9048a01e799012b8aca12760e07ca47ea
final_workflow: 32693618582
final_job: 97331600797
final_result: GODOT_4_7_1_IMPORT_PASS_MAIN_SMOKE_PASS_GUT_292_OF_292_PASS_2026_ASSERTIONS
t03_focused_tests: 18_OF_18_PASS
human_evidence: NOT_RUN
```

T03 remained data-driven: spatial effects are resolved from T01 rule/bag data rather than item-id branches. Missing definitions fail closed without partial modifier output. The diagnostic finding was reproduced by RED and corrected so null state and null candidate now report distinct failure codes.

## T04 implementation receipt

```yaml
t04_pr: 33
t04_merge_sha: d07f16d6bae90a09bba0a5f0b8991216d006c966
baseline_main: ec9882253b1a008b7d53f708722e7845212cddcd
red_1_head: 5fa5d74f3e1998d86c26d48e11ebcf8e2351ead9
red_1_workflow: 32695618152
red_1_job: 97337026420
red_1_result: BASE_MANIFEST_PASS_IMPORT_PASS_MAIN_SMOKE_PASS_OLD_292_PASS_NEW_T04_11_FAIL_RESOURCE_ABSENT
green_1_head: b42cfc961210fc6e75652ce3df6e263bdb122ea4
green_1_workflow: 32695817185
green_1_job: 97337565026
green_1_result: GUT_303_OF_303_PASS_2143_ASSERTIONS_T04_11_OF_11
history_hardening_head: ca32ccf3f82d65deb91961b903d01ef1277a15e3
history_hardening_workflow: 32695984011
history_hardening_job: 97338011997
restore_hardening_head: 3829a3c104a6aaa3fe4aae10e0f67485f1a7537e
restore_hardening_workflow: 32696060777
restore_hardening_job: 97338224703
preview_gate_red_head: 2d47108e6994f28667596c57d7e78867d4709f74
preview_gate_red_workflow: 32696147993
preview_gate_red_job: 97338466148
preview_gate_finding: UNCOMMITTED_VISIBLE_PREVIEW_COULD_PASS_COMMIT_GATE
preview_gate_green_head: 5a2068530ecbb0171f442d2d1170e0de8826b5c2
preview_gate_green_workflow: 32696255483
preview_gate_green_job: 97338767959
mode_exclusive_red_head: 060064f9d8b8d2bcf663ec9f42e0d6430d4ea87d
mode_exclusive_red_workflow: 32696337586
mode_exclusive_red_job: 97339001293
mode_exclusive_finding: WHOLE_LAYOUT_MODE_ALLOWED_PER_ITEM_EDITS
mode_exclusive_green_head: ab99b36df221e80e613f62a7c2e622a346dbf5db
mode_exclusive_green_workflow: 32696450208
mode_exclusive_green_job: 97339327022
mode_commit_red_head: 2fbf48316e3c7b12eb47e9f30a8b9123cd7778cf
mode_commit_red_workflow: 32696533136
mode_commit_red_job: 97339563177
mode_commit_finding: WHOLE_LAYOUT_MODE_DID_NOT_BLOCK_LATER_COMMIT
final_head: 6972e14cfa94dcce4d372a632db6d5e74809ee62
final_workflow: 32696702180
final_job: 97340051028
final_result: GODOT_4_7_1_IMPORT_PASS_MAIN_SMOKE_PASS_GUT_309_OF_309_PASS_2202_ASSERTIONS
t04_focused_tests: 17_OF_17_PASS
human_evidence: NOT_RUN
```

T04 uses bounded deep-state edit snapshots rather than introducing a second geometry state or inverse-command authority. Non-history pending-bag acquisition cuts prior edit history so Undo cannot silently erase/refund it. Adversarial review found and fixed three control-state gaps before merge: an uncommitted visible preview could pass commit readiness; whole-layout mode allowed per-item edits; and active whole-layout mode did not initially block later commit until explicit gates were added.

## T05 implementation receipt

```yaml
t05_pr: 35
t05_merge_sha: 8cefce75456f8b72a8f69559857676cca67a6c5d
baseline_main: 585be5541abaec926567938b9d19a2ad767164da
red_1_head: d2cdb319ddd9efdd7038298a65d364467ba89603
red_1_workflow: 32707721159
red_1_job: 97372294031
red_1_result: BASE_MANIFEST_PASS_IMPORT_PASS_MAIN_SMOKE_PASS_OLD_309_PASS_NEW_T05_10_FAIL_RESOURCE_ABSENT
green_1_head: 50ca9477cee030ccdc6ae540880c00478bb27de9
green_1_workflow: 32708021401
green_1_job: 97373228898
green_1_result: GUT_319_OF_319_PASS_2263_ASSERTIONS_T05_CORE_10_OF_10
authority_red_head: 77837e0fce9e0a75a30391fed73d5394a174009d
authority_red_workflow: 32708175187
authority_red_job: 97373678180
authority_finding: PUBLIC_SESSION_TRANSACTION_METHODS_BYPASSED_COMBINATION_RECIPE_AUTHORITY
authority_green_head: 58c2049c6c7539b1bfdf20f34be24c8807a682f1
authority_green_workflow: 32708374976
authority_green_job: 97374312665
session_hardening_head: af14781e3324324e9a82d613c32084fc35863562
session_hardening_workflow: 32708516762
session_hardening_job: 97374735488
modal_hardening_head: 1eecb9f43a0d4a902adfe79cc5866daac3f4e562
modal_hardening_workflow: 32708721186
discovery_red_head: 2c801fbea56f675eee35e28e071a4264ff6c61bc
discovery_red_workflow: 32708845116
discovery_red_job: 97375722792
discovery_finding: STALE_DISCOVERY_COULD_RESURRECT_REMOVED_RECIPE
discovery_green_head: f6a180543c8ac4f48ae2f6d191bf5a6046d69a1b
discovery_green_workflow: 32708952920
discovery_green_job: 97376048043
final_head: d14ff2e8702d610de1678c22737982bd5b73e22a
final_workflow: 32709071039
final_job: 97376407499
final_result: GODOT_4_7_1_IMPORT_PASS_MAIN_SMOKE_PASS_GUT_329_OF_329_PASS_2322_ASSERTIONS
t05_focused_tests: 20_OF_20_PASS
human_evidence: NOT_RUN
```

T05 keeps recipe eligibility/discovery in `CombinationResolver` and state replacement in the owning REST session through an underscore-prefixed internal project-contract bridge. GDScript does not enforce language-level privacy, so the bridge is protected by project ownership rules and tests rather than claimed as inaccessible. Successful combination is an irreversible history boundary; cancel is a no-op that preserves prior edit history. Current recipe authority is checked before discovery memory so stale data cannot resurrect removed recipes, and failed result placement preserves sources, pending state and future instance identity.

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
- `BackpackState`: committed board/item/bag/origin/rotation/active-area/collision facts — **T02 INTEGRATED**, with T04-validated stable-instance restore owner paths.
- `BackpackResolver`: deterministic connected-layout legality, orthogonal adjacency, special-bag overlap and active spatial modifier resolution — **T03 INTEGRATED**.
- `RestBackpackSession`: pending REST edits, six-slot buffer, edit history/undo-redo, preview, whole-layout edit mode and combination modal bridge — **T04/T05 INTEGRATED**.
- `CombinationResolver`: current recipe eligibility, progressive hints, pending result transaction and discovery — **T05 INTEGRATED**.
- `RunBuildState`: final committed spatial combat modifier authority — **T06 NEXT**.
- `RunRouteState`: school visit/provisional/clear order and Stage index.
- encounter definitions/profiles: school content + Stage depth data.
- bounded stage encounter state/coordinator: Elite/Trace/Boss lifecycle.
- reward/access resolver: package/lane eligibility and deterministic dedupe.
- `FateController`: candidate/pending Fate responsibility, not final multi-domain commit authority.
- `RestCommitCoordinator`: atomic backpack + Fate + next-school commit.
- `MainController`: composition/integration only.
- `WaveSpawner`: normal-spawn actuator, not lifecycle truth.

Full review: `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`.

## Current source-review boundary

`T01~T11` are represented in current merged `main` source/test surfaces. The next named package, `T12: add atomic Workbench commit coordinator`, is **open draft PR #43**.

Treat it as read-only review input. Before any later implementation decision, compare current `main`, the draft diff/receipts, current canon/traceability, code/tests, and the still-missing actual-play/visual/audio/device evidence. This router does not authorize draft merge, rebase, or runtime mutation.

## Regression replacement rule

Current MVP-3 tests are rollback evidence. Do not delete conflicting tests just to make migration green. Add approved new behavior evidence first, then replace only expectations explicitly superseded by current canon.

## Historical routes

- PR #17 is closed/unmerged/historical and not a prerequisite.
- old `impl/mvp4-t01-spatial-data-contracts` is historical and not a production base.
- PR #27 is merged T01 implementation evidence.
- PR #29 is merged T02 implementation evidence.
- PR #31 is merged T03 implementation evidence.
- PR #33 is merged T04 implementation evidence.
- PR #35 is merged T05 implementation evidence.
- historical PRs/handoffs remain evidence and are not rewritten.

## Human evidence rule

Before four-school multiplication, T14 builds the Cheonsul slice and T15 separately human-tests:

`signature <=30 sec -> Core -> Elite -> trace -> Boss -> reward -> Workbench -> next-route preview`.

Technical placeholder/card UI may support spikes/tests but cannot close final player-experience PASS.

## Runtime/tool boundary

T01 data resources, T02 committed spatial state, T03 deterministic resolver, T04 REST edit-session domain engine and T05 first-tier atomic combination transaction have actual Godot 4.7.1 import/main-smoke/full-GUT evidence. **Playable Workbench interaction and committed spatial combat integration remain NOT_RUN/NOT_STARTED because the actual Workbench UI/input and T06 combat-authority migration do not exist yet.** Android/export and Human QA remain release-near work and are not implied by T05 completion.

## Resume rule

`fetch latest main -> inspect open/recent merged PRs -> read current decisions/canon/Phase-B/plan -> compare actual code/tests -> continue only from evidence-backed state`.
