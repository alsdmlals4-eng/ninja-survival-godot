# CURRENT_CONFIRMED_DECISIONS

```yaml
owner_role: CURRENT_APPROVED_PRODUCT_AND_PROTECTED_SCOPE_LEDGER
updated_at: 2026-08-21 KST
runtime_baseline: MVP_0_TO_3_INTEGRATED
latest_product_canon: docs/canon/2026-08-21-dec014-025-product-canon.md
latest_migration_traceability: docs/traceability/2026-08-21-dec014-025-migration-traceability.md
next_product_gate: DEC_026
mvp4_production_implementation: NOT_STARTED
new_school_circuit_runtime: NOT_STARTED
```

This is the current mutable decision router. Historical detail remains in dated specs/plans/handoffs and merged PR history; do not use an older status sentence to override this file.

## 1. Current product definition

`닌자의 신 / 닌자 서바이벌` is a 2D survival roguelike where the player chooses a starting ninja school, clears all four school battlefields in a player-chosen order, opens their tradition acquisition packages, and uses a spatial/rotation/adjacency backpack build to defeat a separate final calamity.

Current high-level Run:

`starting school -> choose unvisited school -> ~5m battlefield with Elite/trace/school Boss -> branch Workbench/Fate -> repeat four schools -> final binding Workbench -> separate final Boss -> result/Ninja Soul`.

`~20 minutes` is the target active-combat time through the fourth school Boss, not the whole Run end.

Full DEC-014~025 implementation-facing detail is owned by:

`docs/canon/2026-08-21-dec014-025-product-canon.md`.

## 2. Protected integrated baseline

Keep and regression-protect until deliberately replaced by approved TDD behavior changes:

- MVP-0 basic movement/combat/game-over foundation.
- MVP-1 combat DDD: kill combo, stylish score, reward absorption feedback.
- MVP-2 four-school shallow runtime and school-resource/ultimate contracts.
- MVP-3 contribution/result, GOLD, Shop, Fate, current three-segment rest-loop runtime as a rollback baseline.
- Godot 4.7.1 project/import/main-scene smoke path.
- GUT 9.7.1 regression suite and source-fidelity / duplicate-UID CI guards.

A green MVP-3 test does not mean the new DEC-014~025 Run is implemented.

## 3. Protected MVP-4 spatial decisions

### DEC-2026-08-11-001 — Persistent Workbench / spatial backpack

Still approved:

- fixed `6x6` board,
- starting `4x3` active area,
- purchasable bags expand usable area,
- item and bag 90-degree rotation,
- rectangular regular items with selected L/T bag shapes,
- orthogonal adjacency,
- special bag activates by at least one-cell item overlap,
- six-slot REST work buffer,
- explicit atomic first-tier combination transaction,
- whole-layout movement mode is visible and mutually exclusive with normal focus/cell navigation,
- complete mouse, keyboard/gamepad-focus and touch completion paths,
- UI renders snapshots/emits intents; domain classes own legality/economy/combination rules.

Architecture direction remains:

`Item/Bag definitions -> BackpackState -> BackpackResolver -> RestBackpackSession/CombinationResolver -> committed RunBuildState snapshot -> combat runtime`.

### DEC-2026-08-11-002 — Hybrid spatial content

Still approved:

- every base item remains standalone-useful,
- strong-spatial identity is selective rather than every item using the same formula,
- existing 19 base acquisition items, 3 first-tier combinations and 5 purchasable bags remain protected authoring content unless later explicitly changed,
- spatial/static effects use deterministic data contracts rather than item-ID branches in UI/resolver,
- legacy MVP-3 effects must not remain a second combat-modifier authority after committed spatial migration.

Detailed old L2 spatial spec remains:

`docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`.

## 4. Current four-school philosophy

Protected product identity:

- **봉마:** prepare space and let familiars/barriers fight; mobile stronghold, not stationary tower defense.
- **천술:** make statuses and transform the field through ordered elemental reactions.
- **귀인:** become stronger by sustaining dangerous close-range presence; low HP alone is not the universal core.
- **흑영:** identify and remove dangerous targets first through marks/priority/execution; indirect control remains compatible with auto-combat.

Current MVP-2 runtime is evidence and migration baseline, not something to delete wholesale.

Current Heukyeong mark canon is the merged MVP-3 behavior: base `8.0s` refreshable marks; 3+ stacks burst and clear that target's marks.

## 5. DEC-014~025 current authority summary

The following current decisions are mirrored in the dated product canon:

- DEC-014: four-school circuit + final rest + separate final Boss.
- DEC-015: freely choose among unvisited schools; school identity and Stage 1..4 difficulty are separate axes.
- DEC-016/019: trace is Run progression and **tradition access**, not automatic school power; DEC-019 supersedes automatic-buff interpretation.
- DEC-017: each school owns Core Monster x3 + Elite x1 + Boss x1 + gimmick library; Stage gimmick depth grows 1->4 with concurrent advanced-gimmick cap 2.
- DEC-018: final calamity reuses/recombines learned four-school encounter language.
- DEC-020: four liberated-school representatives provide one short final-battle support callback each in clear order; player build still owns victory.
- DEC-021/021A: access packages and reward lanes control acquisition timing while preserving existing item identity/affinity/combinations.
- DEC-022: four-trace binding means Final Binding Workbench, not a new automatic upgrade tree.
- DEC-023: Heukyeong mark duration reconciled to current merged/tested 8-second refreshable runtime.
- DEC-024: Elite -> chest token + non-expiring trace -> trace recovery -> timed warning -> school Boss dual gate.
- DEC-025: unvisited-school risk/reward preview; route selection is provisional in Workbench and Fate atomically commits build + Fate + next school.

## 6. Planning / implementation boundary

The old 2026-08-11 MVP-4 plan is split by current authority:

### Reuse

Old T01-T07 remain the low-level implementation direction:

`data -> state -> resolver -> REST session -> combination -> committed modifier migration -> reward/shop/chest transactions`.

T04/T07 receive later bounded amendments for route commit/access lanes, but their domain ownership is not discarded.

### Superseded for execution

Old T08-T12 are not executable current plans because they assume the obsolete immediate-Boss/three-segment composition.

Use:

`docs/traceability/2026-08-21-dec014-025-migration-traceability.md`

for the current recalculation.

## 7. Closed historical execution routes

- PR #17 (`T00 provider adoption`) is **closed and unmerged**. Do not reopen, merge or treat it as a prerequisite.
- `impl/mvp4-t01-spatial-data-contracts` is a historical prepared baseline. Do not resume production work from it.
- Future production packages branch from fresh merged `main` after current canon/plan readback and current Phase-B readiness.

Historical PRs/handoffs remain evidence; they are not deleted.

## 8. Current evidence ceiling

```yaml
mvp0_to_mvp3: IMPLEMENTED_AUTOMATED_REGRESSION_BASELINE
last_observed_pr20_regression: 34_TEST_SCRIPTS_250_TESTS_1624_ASSERTIONS_PASS
mvp4_spatial_runtime: NOT_STARTED
school_circuit_runtime: NOT_STARTED
trace_runtime: NOT_STARTED
final_calamity_runtime: NOT_STARTED
release_near_vertical_slice_human_qa: NOT_RUN
android_device_qa: NOT_RUN
export_release: NOT_READY
```

Do not promote a documented decision or implementation plan to runtime/test/human PASS without executed evidence.

## 9. Next material product gate

**DEC-026 — four-school Core Monster / Elite / Boss concrete attack sets and Stage pattern budget.**

DEC-026 is not approved yet. Do not invent its attack/pattern content inside BUILD.

After DEC-026 is approved, recalculate detailed T08+ implementation tasks, run Phase-B Definition of Ready again, then authorize fresh Phase-C packages.
