# ACTIVE_CONTEXT

```yaml
project: NINJA_SURVIVAL
state_router_updated_at: 2026-08-22 KST
resume_state: DEC026_APPROVED_PLAN_RECALCULATED
next_material_gate: PHASE_B_DEFINITION_OF_READY_T08_TO_T14
production_build_for_new_canon: BLOCKED_PENDING_PHASE_B_REREVIEW
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
6. `docs/traceability/2026-08-21-dec014-025-migration-traceability.md`
7. `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`
8. `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` for protected low-level spatial behavior
9. old `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md` **T01-T07 only**
10. actual `scripts/`, `scenes/`, `tests/`, `.github/workflows/gut.yml`
11. current Notion project home / Flow / Core System / Production Handoff
12. current Base `main` when Base freshness materially affects the task

## Current integrated truth

- MVP-0 basic combat is integrated.
- MVP-1 combat DDD is integrated.
- MVP-2 four-school shallow runtime is integrated.
- MVP-3 result/GOLD/Shop/Fate/three-segment runtime is integrated and remains rollback/regression baseline.
- Existing CI has source-faithful GUT preparation and duplicate-UID failure protection.
- Old MVP-3 three-segment flow is implementation reality, not the latest product target.
- MVP-4 spatial/backpack production code has not started.
- DEC-014~025 and DEC-026 are approved product/planning canon and have not been implemented yet.

Last observed regression evidence before this planning package:

`Godot 4.7.1 import PASS -> main-scene smoke PASS -> GUT 34 scripts / 250 tests / 1624 assertions PASS`.

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

School identity:

- 봉마: mobile prepared-space pressure.
- 천술: setup -> elemental reaction.
- 귀인: sustained proximity pressure with readable recovery windows.
- 흑영: visible threat/mark -> delayed execution.

Stage depth:

- Stage 1 base signature;
- Stage 2 interaction;
- Stage 3 synergy/field;
- Stage 4 mastery + one Boss capstone;
- maximum two advanced gimmicks concurrently.

Full canon: `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`.

## Plan reuse boundary

### Reuse
Old T01-T07 remain valid low-level direction for spatial data/state/resolvers/session/combination/committed modifiers/reward transaction foundation.

### Replace
Old T08-T12 remain non-executable.

Current replacement plan:

`docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`.

Execution path:

`T08 route state -> T09 encounter/profile data -> T10 Elite/trace/Boss gate -> T11 access lanes -> T12 atomic commit -> T13 Workbench route preview -> T14 Cheonsul release-near Vertical Slice -> T15 Human QA gate -> remaining schools/full circuit`.

## Next executable work

### Current gate — fresh Phase B

Run a fresh Definition of Ready from merged main for T08–T14. Confirm:

1. no conflicting open PR;
2. DEC-014~026 readback from merged main;
3. unchanged MVP-0~3 regression baseline;
4. concrete file/test ownership for T08–T14;
5. no duplicate route/combat/reward authority;
6. TDD order and rollback points;
7. first Vertical Slice remains Cheonsul unless new evidence materially changes that choice.

Only after Phase-B PASS should production implementation begin from a fresh branch.

## Historical routes

- PR #17 is closed/unmerged/historical and not a prerequisite.
- `impl/mvp4-t01-spatial-data-contracts` is historical and not a production base.
- historical PRs/handoffs remain evidence and are not rewritten.

## Human evidence rule

Before four-school multiplication, build and human-test one release-near representative Cheonsul slice:

`signature <=30 sec -> Core -> Elite -> trace -> Boss -> reward -> Workbench -> next-route preview`.

Technical placeholder/card UI may support spikes/tests but cannot close final player-experience PASS.

## Runtime/tool boundary

Notion may record a dedicated Godot slot/path, but latest product-canon migration runtime remains `NOT_RUN`. Repository `project.godot` does not inherit historical PR #17 provider integration merely because the old PR existed.

## Resume rule

`fetch latest main -> inspect open/recent merged PRs -> read current decisions/canon/plan -> compare actual code/tests -> continue only from evidence-backed state`.
