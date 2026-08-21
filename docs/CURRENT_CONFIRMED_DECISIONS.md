# CURRENT_CONFIRMED_DECISIONS

```yaml
owner_role: CURRENT_APPROVED_PRODUCT_AND_PROTECTED_SCOPE_LEDGER
updated_at: 2026-08-22 KST
runtime_baseline: MVP_0_TO_3_INTEGRATED
latest_product_canon: docs/canon/2026-08-21-dec014-025-product-canon.md
latest_encounter_canon: docs/canon/2026-08-22-dec026-encounter-pattern-budget.md
latest_migration_traceability: docs/traceability/2026-08-22-dec026-post-gate-traceability.md
current_migration_plan: docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md
next_product_gate: PHASE_B_REREVIEW_FOR_T08_TO_T14
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

DEC-026 encounter/pattern detail is owned by:

`docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`.

## 2. Protected integrated baseline

Keep and regression-protect until deliberately replaced by approved TDD behavior changes:

- MVP-0 basic movement/combat/game-over foundation.
- MVP-1 combat DDD: kill combo, stylish score, reward absorption feedback.
- MVP-2 four-school shallow runtime and school-resource/ultimate contracts.
- MVP-3 contribution/result, GOLD, Shop, Fate, current three-segment rest-loop runtime as a rollback baseline.
- Godot 4.7.1 project/import/main-scene smoke path.
- GUT 9.7.1 regression suite and source-fidelity / duplicate-UID CI guards.

A green MVP-3 test does not mean the new DEC-014~026 Run is implemented.

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

Per school:

- Core Monster x3,
- Elite x1,
- Boss x1,
- bounded gimmick/pattern library,
- one Stage 4 Boss capstone.

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

First release-near Vertical Slice target is **천술류**, because current MVP-2 status/reaction runtime is the closest product-fit baseline and isolates new route/Elite/trace/Boss/Workbench migration risk.

DEC-026 does not claim runtime implementation or final-calamity full attack script completion.

## 7. Planning / implementation boundary

Old 2026-08-11 MVP-4 tasks:

- T01-T07: reuse as low-level spatial/domain direction, with bounded access-lane/route-commit amendments.
- old T08-T12: superseded for execution.

Current replacement plan:

`docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`.

Current traceability:

`docs/traceability/2026-08-22-dec026-post-gate-traceability.md`.

New sequence is T08 RunRouteState -> T09 encounter/profile data -> T10 Elite/trace/Boss gate -> T11 access lanes -> T12 atomic commit -> T13 Workbench route preview -> T14 Cheonsul Vertical Slice -> T15 Human QA gate -> only then expand the remaining schools and full circuit.

## 8. Closed historical execution routes

- PR #17 is closed and unmerged. Do not reopen/merge/treat it as prerequisite.
- `impl/mvp4-t01-spatial-data-contracts` is a historical prepared baseline. Do not resume production work from it.
- Future production packages branch from fresh merged `main` after current Phase-B readiness.

Historical PRs/handoffs remain evidence; they are not deleted.

## 9. Current evidence ceiling

```yaml
mvp0_to_mvp3: IMPLEMENTED_AUTOMATED_REGRESSION_BASELINE
last_observed_regression: 34_TEST_SCRIPTS_250_TESTS_1624_ASSERTIONS_PASS
mvp4_spatial_runtime: NOT_STARTED
school_circuit_runtime: NOT_STARTED
trace_runtime: NOT_STARTED
dec026_encounter_runtime: NOT_STARTED
release_near_vertical_slice_human_qa: NOT_RUN
android_device_qa: NOT_RUN
export_release: NOT_READY
```

Do not promote a documented decision or implementation plan to runtime/test/human PASS without executed evidence.

## 10. Next gate

DEC-026 is approved. The next gate is a **fresh Phase-B Definition of Ready for T08–T14 on merged main**. If that review stays clean, implementation may begin from a fresh production branch with TDD, while preserving the MVP-0~3 regression baseline.
