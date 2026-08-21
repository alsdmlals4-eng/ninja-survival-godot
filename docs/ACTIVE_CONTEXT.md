# ACTIVE_CONTEXT

```yaml
project: NINJA_SURVIVAL
state_router_updated_at: 2026-08-21 KST
resume_state: CANON_REBASELINED_TO_DEC014_025
next_material_gate: DEC_026
production_build_for_new_canon: BLOCKED_PENDING_DEC026_AND_PHASE_B_REREVIEW
mvp0_to_mvp3_runtime: INTEGRATED
mvp4_spatial_production: NOT_STARTED
school_circuit_runtime: NOT_STARTED
trace_runtime: NOT_STARTED
final_calamity_runtime: NOT_STARTED
release_near_vertical_slice_human_qa: NOT_RUN
android_device_qa: NOT_RUN
```

## Purpose

This file is the mutable resume router. Product rules live in `docs/CURRENT_CONFIRMED_DECISIONS.md` and the dated canon it references. Implementation facts live in actual code/scenes/tests and executed evidence.

Do not reconstruct current state from older handoff status sentences without first reading current `main`, current PR inventory and this router.

## Current read order

1. `AGENTS.md`
2. active chat/user instruction
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. `docs/canon/2026-08-21-dec014-025-product-canon.md`
5. `docs/traceability/2026-08-21-dec014-025-migration-traceability.md`
6. `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` for protected low-level spatial behavior
7. `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md` **T01-T07 only**
8. actual `scripts/`, `scenes/`, `tests/`, `.github/workflows/gut.yml`
9. current Notion project home / Flow / Core System pages for human-facing product/visual context
10. current Base `main` only when Base freshness materially affects the task

## Current integrated truth

- MVP-0 basic combat is integrated.
- MVP-1 combat DDD is integrated.
- MVP-2 four-school shallow runtime is integrated.
- MVP-3 result/GOLD/Shop/Fate/three-segment runtime is integrated and remains the rollback/regression baseline.
- Existing CI has source-faithful GUT preparation and duplicate-UID failure protection.
- The old MVP-3 three-segment flow is **implementation reality**, not the latest product target.
- MVP-4 spatial/backpack production code has not started.
- DEC-014~025 changes are documented current product canon and have not been implemented yet.

Last observed pre-rebaseline PR-head regression evidence:

`Godot 4.7.1 import PASS -> main-scene smoke PASS -> GUT 34 scripts / 250 tests / 1624 assertions PASS`.

Do not treat this as DEC-014~025 runtime evidence.

## Current product target

```text
starting school
-> choose unvisited school battlefield
-> Core Monsters / Stage gimmick
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

## Old execution routes — historical only

### PR #17

PR #17 is closed and unmerged. It is **not** an active prerequisite and must not be reopened/merged or used as the base of current production work unless a future user explicitly names that PR and authorizes that action.

### Historical T01 branch

`impl/mvp4-t01-spatial-data-contracts` is a historical prepared baseline. Do not execute production changes from that stale pinned baseline.

Future production branches are created from fresh merged `main` after current canon/plan readback and current Phase-B readiness.

## Plan reuse boundary

### Still reusable

The old 2026-08-11 MVP-4 T01-T07 direction remains valid for:

- spatial data/catalog contracts,
- BackpackState,
- BackpackResolver,
- RestBackpackSession,
- CombinationResolver,
- committed RunBuildState modifier authority,
- reward/shop/chest transaction foundation.

DEC-021 access-lane and DEC-025 atomic-route inputs are bounded amendments to those domains, not reasons for a rewrite.

### Superseded for execution

Old T08-T12 are non-executable because they assume immediate Boss + three-segment completion.

Current replacement requirements are MIG-01..MIG-08 in:

`docs/traceability/2026-08-21-dec014-025-migration-traceability.md`.

A detailed new T08+ code plan is blocked until DEC-026 resolves concrete Core Monster/Elite/Boss attack sets and Stage pattern budget.

## Next executable work

### Current next Gate — PLAN

**DEC-026: four-school Core Monster / Elite / Boss concrete attack sets + Stage pattern budget.**

Before asking for implementation:

1. use current Notion world/core-system canon and benchmark evidence,
2. design DEC-026 without adding a second combat game per school,
3. preserve shared chassis + telegraph + Stage profile budgets,
4. run required adversarial review,
5. obtain user approval for the material product decision,
6. write/recalculate the detailed T08+ implementation plan,
7. run Phase-B Definition of Ready on fresh main,
8. only then enter new Phase-C production packages.

### Work that may continue independently before DEC-026

- documentation/readback correction,
- Notion/GitHub sync,
- benchmark/evidence collection for DEC-026,
- stale structured-metadata correction,
- verification of the unchanged MVP-0~3 regression baseline.

Do not claim new gameplay production is ready merely because these independent tasks are complete.

## Human-evidence rule

Technical placeholder/card UI may support spikes and automated tests. It cannot close the final player-experience gate.

Before scaling all four school battlefields, build and human-test one release-near representative school slice with production-candidate UI/UX, visuals, animation/VFX and audio feedback:

`signature <=30 sec -> Elite -> trace -> Boss -> reward -> Workbench -> next-route preview`.

Measure school readability, pacing, telegraph fairness, trace clarity, Workbench comprehension/fatigue and Korean text readability before four-school content multiplication.

## Runtime/tool boundary

Notion currently records a dedicated Ninja Survival Godot slot/path, but the latest product-canon migration runtime remains `NOT_RUN`.

Repository `project.godot` does not currently contain the old PR #17 provider adoption. Do not claim HiGodot/Hera/Godot-AI project integration from historical PR content.

## Base freshness

Current Base remote must be re-read when it affects a task. This router does not claim a full Base sync merely because current Base was observed during the canon audit.

## Resume rule

On every resume:

`fetch/read latest main -> inspect open/recent merged PRs -> read current decisions/canon/traceability -> compare actual code/tests -> continue only from evidence-backed current state`.
