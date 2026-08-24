# CURRENT_CONFIRMED_DECISIONS

```yaml
owner_role: CURRENT_APPROVED_PRODUCT_AND_PROTECTED_SCOPE_LEDGER
updated_at: 2026-08-24 KST
runtime_baseline: MVP_0_TO_3_INTEGRATED
latest_product_canon: docs/canon/2026-08-21-dec014-025-product-canon.md
latest_encounter_canon: docs/canon/2026-08-22-dec026-encounter-pattern-budget.md
latest_migration_traceability: docs/traceability/2026-08-22-dec026-post-gate-traceability.md
latest_phase_b: docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md
current_migration_plan: docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md
phase_b_verdict: PASS
t01_spatial_data_contracts: INTEGRATED
t02_backpack_state: INTEGRATED
t03_backpack_resolver: INTEGRATED
t04_rest_backpack_session: INTEGRATED
t05_combination_resolver: INTEGRATED
t06_to_t11_domain_surfaces: PRESENT_ON_MERGED_MAIN
current_main_sha: 265bab32da087c070ea2ea0d98a3bdace1e10f7f
next_product_gate: T12_OPEN_DRAFT_REVIEW_ONLY
mvp4_production_implementation: T01_TO_T11_DOMAIN_SURFACES_PRESENT_ON_MERGED_MAIN
new_school_circuit_runtime: SOURCE_AND_TEST_SCOPE_ONLY
playable_workbench_ui_input: NOT_RUN
production_candidate_visual_audio_feedback: NOT_RUN
human_device_validation: NOT_RUN
```

This is the current mutable decision router. Historical detail remains in dated specs/plans/handoffs and merged PR history; do not use an older status sentence to override this file.

## 1. Current product definition

`닌자의 신 / 닌자 서바이벌` is a 2D survival roguelike where the player chooses a starting ninja school, clears all four school battlefields in a player-chosen order, opens their tradition acquisition packages, and uses a spatial/rotation/adjacency backpack build to defeat a separate final calamity.

Current high-level Run:

`starting school -> choose unvisited school -> ~5m battlefield with Elite/trace/school Boss -> branch Workbench/Fate -> repeat four schools -> final binding Workbench -> separate final Boss -> result/Ninja Soul`.

`~20 minutes` is the target active-combat time through the fourth school Boss, not the whole Run end.

Full DEC-014~025 implementation-facing detail is owned by `docs/canon/2026-08-21-dec014-025-product-canon.md`.

DEC-026 encounter/pattern detail is owned by `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`.

## 2. Protected integrated baseline

Keep and regression-protect until deliberately replaced by approved TDD behavior changes:

- MVP-0 basic movement/combat/game-over foundation.
- MVP-1 combat DDD: kill combo, stylish score, reward absorption feedback.
- MVP-2 four-school shallow runtime and school-resource/ultimate contracts.
- MVP-3 contribution/result, GOLD, Shop, Fate, current three-segment rest-loop runtime as a rollback baseline.
- Godot 4.7.1 project/import/main-scene smoke path.
- GUT 9.7.1 regression suite and source-fidelity / duplicate-UID CI guards.
- **T01 spatial data foundation merged as PR #27 / `7c9206702526f99dfadf44a617cd150853ec733f`.**
- **T02 committed BackpackState merged as PR #29 / `126e6c942d74f97166ef0c881afc5d79cae3d274`.**
- **T03 deterministic BackpackResolver merged as PR #31 / `2dcf055d82df02d44335f209897436572efa6739`.**
- **T04 RestBackpackSession merged as PR #33 / `d07f16d6bae90a09bba0a5f0b8991216d006c966`.**
- **T05 CombinationResolver merged as PR #35 / `8cefce75456f8b72a8f69559857676cca67a6c5d`.**

A green MVP-3 test does not mean the new DEC-014~026 Run is implemented. T01 proves the spatial definitions/catalog foundation. T02 proves committed backpack spatial state primitives. T03 proves deterministic spatial resolution and read-only previews. T04 proves the REST edit-session domain engine. T05 proves the first-tier atomic combination transaction. None proves playable Workbench UI or final committed spatial combat integration.

## 3. Protected MVP-4 spatial decisions

Still approved:

- fixed `6x6` board and starting `4x3` active area,
- purchasable bags expand usable area,
- item/bag 90-degree rotation,
- orthogonal adjacency,
- selected L/T bag shapes,
- special bag activation by at least one-cell item overlap,
- six-slot REST work buffer,
- explicit atomic first-tier combination transaction,
- complete mouse, keyboard/gamepad-focus and touch completion paths,
- UI renders snapshots/emits intents; domain classes own legality/economy/combination rules,
- existing 19 base items, 3 first-tier combinations and 5 purchasable bags remain protected unless later explicitly changed.

Architecture direction remains:

`Item/Bag definitions -> BackpackState -> BackpackResolver -> RestBackpackSession/CombinationResolver -> committed RunBuildState snapshot -> combat runtime`.

T01 implements the definitions/catalog layer. T02 implements the committed `BackpackState` layer. T03 implements the deterministic `BackpackResolver` layer. T04 implements the pending REST edit-session layer. T05 implements the explicit first-tier combination transaction layer. T06 is the next committed combat-authority migration layer.

### T02 integrated contract

`BackpackState` now owns:

- fixed 6x6 board facts,
- centered 4x3 starting active area from `starting_ninja_bag`,
- shared stable item/bag instance identities,
- origin and normalized quarter-turn rotation,
- atomic add/move/remove/rotate state transitions,
- item-item and bag-bag collision rejection,
- active-area expansion/shrink facts with orphan prevention,
- defensive collection views and deep-copy isolation,
- T04-validated `restore_item_instance()` / `restore_bag_instance()` owner paths for buffered/reconstructed existing instances without exposing private interiors.

T02 does not own orthogonal adjacency scoring, bag connectivity rules, special-bag modifier resolution, REST session policy, GOLD/Fate, combination transaction, Workbench UI or combat modifier migration.

### T03 integrated contract

`BackpackResolver` now owns derived/read-only spatial resolution over T02 facts:

- fixed-board item/bag geometry revalidation against T01 definitions,
- 4-neighbor connected active-layout legality,
- orthogonal adjacency canonicalized once per distinct item pair,
- data-driven `SpatialRuleDefinition` aggregation with `ANY` selector semantics and `PER_DISTINCT_NEIGHBOR` caps,
- one neighbor matching both tag and explicit definition id still counts once,
- special-bag effects on one-cell-or-more overlap, once per distinct bag instance,
- static item payload + selected-school emblem payload into a deterministic `RunModifierSet` snapshot,
- reasoned read-only item/bag placement preview,
- all-or-nothing whole-layout translation preview,
- deterministic failure cells and independent output snapshots.

T03 does not own the REST work buffer/history, combination transaction, GOLD/Fate/economy, Workbench UI or final committed combat modifier migration.

### T04 integrated contract

`RestBackpackSession` owns pending/edit-session state over T02/T03:

- copy-on-begin separation from committed source state,
- exact six-slot work buffer,
- board-to-buffer removal that immediately removes spatial effects,
- legal buffer-to-board placement preserving stable instance identity,
- defensive `BuildPreviewSnapshot` with selected-school T03 modifier context,
- deep edit history / undo / redo with new-edit redo clearing,
- non-history pending-bag acquisition as a history barrier so undo cannot erase/refund it,
- explicit mutually-exclusive whole-layout movement mode and atomic translation,
- deterministic commit-readiness failure codes for non-empty buffer, pending bag, pending item preview, active whole-layout mode and invalid resolver state,
- defensive public session/buffer/pending-bag/preview views.

T04 does not own recipe eligibility/discovery, GOLD/Fate/economy orchestration, Workbench UI or final committed combat modifier migration.

### T05 integrated contract

`CombinationResolver` owns first-tier recipe interpretation over T01/T03/T04 facts:

- valid orthogonally adjacent on-board source pairs only,
- buffer sources are excluded,
- deterministic `UNDISCOVERED / INGREDIENT_OWNED / READY / DISCOVERED` progression,
- canonical recipe A/B instance ordering without changing stable source identity,
- source-preserving pending result transaction,
- invalid placement/cancel preserving both source instances,
- successful result placement atomically consuming exactly two source instances once and creating exactly one result,
- repeated commit protection and first-success discovery,
- current recipe existence checked before historical discovery memory,
- pending transaction blocks parallel backpack edits and later Fate commit,
- successful combination clears edit history as an irreversible transaction while cancel preserves prior history,
- pending/discovery outputs are defensive snapshots.

State replacement remains in the owning `RestBackpackSession` through an underscore-prefixed internal project-contract bridge. GDScript does not enforce access privacy; therefore tests and ownership rules protect this boundary rather than claiming it is language-inaccessible.

T05 does not own final committed combat modifier authority, GOLD/Fate/economy orchestration, Workbench UI/input, route or encounter logic.

Detailed low-level spatial spec remains `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`.

## 4. Current four-school philosophy

- **봉마:** prepare space and let familiars/barriers fight; mobile stronghold, not stationary tower defense.
- **천술:** make statuses and transform the field through ordered elemental reactions.
- **귀인:** become stronger by sustaining dangerous close-range presence; low HP alone is not the universal core.
- **흑영:** identify and remove dangerous targets first through marks/priority/execution; indirect control remains compatible with auto-combat.

Current MVP-2 runtime is evidence and migration baseline, not something to delete wholesale.

## 5. DEC-014~025 current authority summary

- DEC-014: four-school circuit + final rest + separate final Boss.
- DEC-015: freely choose among unvisited schools; school identity and Stage difficulty are separate axes.
- DEC-016/019: trace is Run progression and tradition access, not automatic school power.
- DEC-017: each school owns Core Monster x3 + Elite x1 + Boss x1 + gimmick library; Stage gimmick depth grows 1->4 with concurrent advanced-gimmick cap 2.
- DEC-018: final calamity reuses/recombines learned four-school encounter language.
- DEC-020: liberated-school representatives provide short final-battle support callbacks; player build owns victory.
- DEC-021/021A: access packages and reward lanes control acquisition timing while preserving item identity/affinity/combinations.
- DEC-022: four-trace binding means Final Binding Workbench, not a new automatic upgrade tree.
- DEC-023: Heukyeong mark duration reconciled to current 8-second refreshable runtime.
- DEC-024: Elite -> chest token + non-expiring trace -> trace recovery -> timed warning -> school Boss dual gate.
- DEC-025: route preview + provisional selection; Fate atomically commits build + Fate + next school.

## 6. DEC-026 — encounter / pattern budget — APPROVED

Selected architecture: **shared attack primitives + school-owned encounter compositions**.

Per school: Core Monster x3, Elite x1, Boss x1, bounded gimmick/pattern library and one Stage 4 Boss capstone.

Shared primitive vocabulary is intentionally small: pursuit/contact, line dash, directional projectile, telegraphed zone, summon/proxy, mark/link, pulse/ring and barrier/lane. Schools differentiate by the movement/build question they pose, timing, visuals and composition rather than by owning separate combat engines.

Stage budget:

- Stage 1: base signature, max 1 major hazard.
- Stage 2: one interaction pattern, max 1 advanced gimmick at once.
- Stage 3: one synergy/field layer, max 2 advanced gimmicks at once.
- Stage 4: mastery mix + one Boss capstone, still max 2 advanced gimmicks at once.

School encounter language:

- 봉마: moving seals/proxies/barrier lanes -> mobile-space adaptation.
- 천술: visible setup -> elemental reaction sequence.
- 귀인: committed rush/proximity pressure -> readable recovery windows.
- 흑영: visible threat/mark -> delayed execution and positioning priority.

First release-near Vertical Slice target is **천술류** because the current MVP-2 status/reaction runtime is closest to the target philosophy.

DEC-026 does not claim runtime implementation or final-calamity full attack script completion.

## 7. Current implementation boundary — merged-main through T11

Fresh review on merged main passed. Exact authority/file/test boundaries are recorded in:

`docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`.

T01~T11 domain surfaces are represented in current merged `main`. The current head is `265bab32da087c070ea2ea0d98a3bdace1e10f7f` (`T11: add tradition access reward lanes`).

PR #43 (`T12: add atomic Workbench commit coordinator`) is an **open draft** from that baseline. It is read-only review evidence, not merged/executable authority.

Key ownership:

- T01 definitions/catalog: `ItemDefinition`, `MVP4Catalog`, `BagDefinition`, `CombinationDefinition`, `SpatialRuleDefinition`.
- T02 committed spatial facts: `BackpackState`, `ItemInstance`, `BagInstance`.
- T03 spatial resolution: `BackpackResolver` + `BackpackResolution` for connected layout legality, orthogonal adjacency, special-bag overlap and deterministic spatial modifiers.
- T04 pending REST edits: `RestBackpackSession` + `BuildPreviewSnapshot` for buffer/preview/history/whole-layout session responsibility.
- T05 combinations: `CombinationResolver` for eligible orthogonal source pairs, progressive hints, pending result transaction and discovery.
- T06+ current domain surfaces include `RunBuildState`, `RunRouteState`, encounter catalog/state, REST reward/shop boundaries, and tradition-access reward lanes; exact ownership must be read from current code/tests and merged history;
- school route/clear order: `RunRouteState`;
- Elite/Trace/Boss lifecycle: bounded stage encounter state/coordinator;
- access/reward eligibility: one reward resolver;
- pending Fate: `FateController`;
- final all-or-none build+Fate+route commit: `RestCommitCoordinator`;
- integration only: `MainController`;
- normal spawn actuation only: `WaveSpawner`.

The dated plan/traceability remains design context. It cannot by itself override current merged-main state or promote draft PR #43.

## 8. T01/T02/T03/T04/T05 implementation evidence

### T01

PR #27 merged to `main` as:

`7c9206702526f99dfadf44a617cd150853ec733f`.

Final exact-head evidence before merge:

- Godot 4.7.1 import PASS,
- main-scene smoke PASS,
- full GUT `263/263` tests PASS,
- `1829` assertions PASS,
- existing MVP-3 item values and sell paths regression PASS,
- new catalog/shape/bag/combination/modifier validation PASS.

A stricter exported typed-Dictionary experiment caused an actual import regression and was rejected. Current generic Dictionary storage is guarded by supported-key and numeric-value validation at the catalog boundary.

### T02

PR #29 merged as `126e6c942d74f97166ef0c881afc5d79cae3d274`.

Final exact-head `60adbb99886c96c687b20befe4a61e5e3bcb71f1` evidence:

- Godot 4.7.1 import PASS,
- main-scene smoke PASS,
- GUT `274/274` tests PASS,
- `1915` assertions PASS,
- T02 focused `11/11` PASS.

Adversarial review found and fixed a live collection-view mutation bypass before merge; public item/bag views now return defensive snapshots.

### T03

PR #31 merged as `2dcf055d82df02d44335f209897436572efa6739`.

Final exact-head `e0dacee9048a01e799012b8aca12760e07ca47ea` evidence:

- Base reuse manifest PASS,
- Godot 4.7.1 import PASS,
- main-scene smoke PASS,
- GUT `292/292` tests PASS,
- `2026` assertions PASS,
- T03 focused `18/18` PASS.

Adversarial review added direct coverage for distinct-neighbor caps and selector one-count semantics, proved data-driven/fail-closed/deterministic behavior, and found/fixed the null-state diagnostic misclassification before merge.

### T04

PR #33 merged as `d07f16d6bae90a09bba0a5f0b8991216d006c966`.

Final exact-head `6972e14cfa94dcce4d372a632db6d5e74809ee62` evidence:

- Base reuse manifest PASS,
- Godot 4.7.1 import PASS,
- main-scene smoke PASS,
- GUT `309/309` tests PASS,
- `2202` assertions PASS,
- T04 focused `17/17` PASS.

Adversarial review verified the non-history acquisition/history boundary and stable-ID restore authority, then found/fixed three control-state gaps: uncommitted visible preview could pass commit readiness, whole-layout mode allowed per-item edits, and active whole-layout mode did not initially block later commit.

### T05

PR #35 merged as `8cefce75456f8b72a8f69559857676cca67a6c5d`.

Final exact-head `d14ff2e8702d610de1678c22737982bd5b73e22a` evidence:

- Base reuse manifest PASS,
- Godot 4.7.1 import PASS,
- main-scene smoke PASS,
- GUT `329/329` tests PASS,
- `2322` assertions PASS,
- T05 focused `20/20` PASS.

Adversarial review found/fixed two authority defects: public session transaction methods could bypass recipe authority, and stale discovery memory could resurrect a removed recipe. Additional adversarial cases verified exact-session ownership, canonical source ordering, modal collision rejection, cancel-history preservation, failed-commit ID preservation and defensive pending/discovery outputs.

## 9. Closed historical execution routes

- PR #17 is closed and unmerged. Do not reopen/merge/treat it as prerequisite.
- old `impl/mvp4-t01-spatial-data-contracts` is historical and not a production base.
- PR #27 is merged T01 evidence.
- PR #29 is merged T02 evidence.
- PR #31 is merged T03 evidence.
- PR #33 is merged T04 evidence.
- PR #35 is merged T05 evidence.

Historical PRs/handoffs remain evidence; they are not deleted.

## 10. Current evidence ceiling

```yaml
mvp0_to_mvp3: IMPLEMENTED_AUTOMATED_REGRESSION_BASELINE
t01_spatial_data_contracts: IMPLEMENTED_AUTOMATED_REGRESSION_EVIDENCE
t02_backpack_state: IMPLEMENTED_AUTOMATED_REGRESSION_EVIDENCE
t03_backpack_resolver: IMPLEMENTED_AUTOMATED_REGRESSION_EVIDENCE
t04_rest_backpack_session: IMPLEMENTED_AUTOMATED_REGRESSION_EVIDENCE
t05_combination_resolver: IMPLEMENTED_AUTOMATED_REGRESSION_EVIDENCE
final_t01_regression: 36_TEST_SCRIPTS_263_TESTS_1829_ASSERTIONS_PASS
final_t02_regression: 37_TEST_SCRIPTS_274_TESTS_1915_ASSERTIONS_PASS
final_t03_regression: 39_TEST_SCRIPTS_292_TESTS_2026_ASSERTIONS_PASS
final_t04_regression: 41_TEST_SCRIPTS_309_TESTS_2202_ASSERTIONS_PASS
final_t05_regression: 43_TEST_SCRIPTS_329_TESTS_2322_ASSERTIONS_PASS
phase_b_readiness: PASS
backpack_resolver_runtime: INTEGRATED
rest_backpack_session_runtime: INTEGRATED
combination_transaction_runtime: INTEGRATED
workbench_player_interaction: NOT_STARTED
committed_spatial_combat_integration: NOT_STARTED
school_circuit_runtime: NOT_STARTED
trace_runtime: NOT_STARTED
dec026_encounter_runtime: NOT_STARTED
release_near_vertical_slice_human_qa: NOT_RUN
android_device_qa: NOT_RUN
export_release: NOT_READY
```

Do not promote T05 atomic-combination domain evidence to Workbench UI/committed combat/Human PASS without executed evidence.

## 11. Next gate

**T12 open-draft review only.** Read current `main`, PR #43, current code/tests, canon/traceability, and the evidence boundary before any mutation decision. Do not promote the draft to merged authority through this document.

The T01~T11 source/test state does **not** prove playable Workbench input, production-quality image/animation/VFX/audio feedback, device readiness, or Human QA. Those remain `NOT_RUN` until separately executed and recorded.
