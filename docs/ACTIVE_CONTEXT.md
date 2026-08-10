# ACTIVE_CONTEXT

> 다음 작업자가 현재 GitHub 상태를 빠르게 복원하기 위한 mutable router다.
> 제품 결정 전문은 `docs/CURRENT_CONFIRMED_DECISIONS.md`, MVP-4 상세 설계는 `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`, 구현 연결은 `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md`, 실행 계획은 `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md`를 본다.

Last updated: 2026-08-11 07:03 KST

## Baseline

```yaml
project: alsdmlals4-eng/ninja-survival-godot
main_sha_observed: 655ec26a5ac9946c0ec08f81f389ddfe66e72b65
latest_integrated_runtime_milestone: MVP-3
mvp4_design_pr_7: MERGED_CLOSED
mvp4_design_merge_commit: 655ec26a5ac9946c0ec08f81f389ddfe66e72b65
mvp4_design_post_merge_gut_run: PASS_31434691578
active_planning_branch: docs/mvp4-traceability-plan-20260811
active_planning_pr: 8
active_planning_pr_state: OPEN_VALIDATION_IN_PROGRESS
active_planning_pr_head_before_this_state_update: b93d7e54e429a53765863c420e04ee0834d7ea73
mvp4_implementation_branch: NONE
mvp4_implementation_pr: NONE
base_repo: alsdmlals4-eng/Base
base_main_observed: 315c66eea9614c284b9c11c4d522141065dfa4b0
project_base_rules_last_explicit_sync: 499c20eb9b449241864f5ada0c915fba8a7806ac
full_base_rule_sync: NOT_RUN
project_sheet_sync: GITHUB_UPDATE_PENDING_SHEET
project_sheet_write: BLOCKED_USER_ACTION_403
```

## Current stage

`MVP-4 Backpack / Combination Basics — DESIGN_APPROVED / TRACEABILITY_AND_IMPLEMENTATION_PLAN_WRITTEN / PLANNING_PR_VALIDATION / PENDING_EXPLICIT_기획_완료`

Implementation status: `NOT_STARTED`

The user approved the written MVP-4 spec on 2026-08-11 and repeated `[연속작업 진행해]`. PR #7 was squash-merged to `main@655ec26a...`; post-merge GUT run `31434691578` passed. The L3 traceability packet and Superpowers TDD implementation plan are now proposed by PR #8. None of these documentation changes are MVP-4 runtime implementation.

## Completed / verified planning work

- MVP-0 basic combat foundation integrated.
- MVP-1 combat DDD integrated.
- MVP-2 four shallow schools integrated.
- MVP-3 result/rest/shop/fate runtime integrated and remains the rollback baseline.
- MVP-4 board, rotation, bag connectivity, adjacency, special bags, buffer, acquisition pillars, cadence, combinations and Persistent Workbench are approved.
- `DEC-2026-08-11-001` Persistent Workbench is approved.
- Directional-input collision was resolved with a visible mutually exclusive `전체 이동 모드`.
- L2 written design spec received user approval and is marked `APPROVED` on PR #8.
- L3 packet maps AC-01..AC-15 with `unmapped_acceptance_criteria: []`; `coverage_status` correctly remains `GAP` because implementation evidence does not exist.
- Superpowers implementation plan contains 12 ordered TDD tasks and is `IMPLEMENTATION_READY_AFTER_EXPLICIT_기획_완료`.
- Adversarial plan review removed an executable placeholder, removed an unnecessary WaveSpawner modification, named exact `StageElite` files, and restored regression-sensitive Decision details.
- PR #8 changed-file inventory is documentation-only.

## Current ready queue

1. Re-query PR #8 exact head after this state update.
2. Verify exact-head GUT result, mergeability, changed-file inventory and unresolved review threads.
3. Re-run adversarial canonical/plan review if the head changed for any substantive reason.
4. Merge PR #8 with exact-head protection when all merge-safety gates pass.
5. Re-query post-merge `main` and post-merge GUT.
6. Reconcile this mutable router once more to the merged planning checkpoint.
7. Stop before production BUILD until the user explicitly declares `기획 완료`.

## Deferred local blocker — Google Sheets

Project GDD Sheets still contain stale older rotation/timing wording. The 2026-08-11 write attempt returned `403 PERMISSION_DENIED`.

```yaml
classification: LOCAL_TASK_BLOCKER
state: GITHUB_UPDATE_PENDING_SHEET
required_user_action: grant the connected Google account edit permission or reconnect a writer-capable account
independent_work: CONTINUE
```

Do not report Sheets as `SYNCED` until write + reread evidence succeeds.

## Production work not started

- `BackpackState`, `BackpackResolver`, `RestBackpackSession`, `CombinationResolver` implementation.
- `ItemInstance`, `BagInstance`, `BagDefinition`, MVP-4 catalog implementation.
- committed spatial modifier migration.
- boss/shop/chest REST reward implementation.
- ~3-minute `StageElite` runtime and chest-token implementation.
- Persistent Workbench/board UI implementation.
- MVP-4 automated tests, runtime validation, Windows human QA, Android device QA.
- MVP-4 implementation branch/PR/merge.

## Critical approved decisions to preserve

- fixed `6x6` board and starting `4x3` active area;
- item/bag 90-degree rotation;
- rectangular regular items and selected L/T bags;
- individual bag move carries its overlapping item candidates but never chains another bag;
- one connected orthogonal bag region;
- orthogonal item adjacency only, one effect per pair;
- one-cell special-bag overlap activation, distinct bag instances stack independently;
- six-slot REST work buffer and zero-buffer commit gate;
- boss reward + shop + chest acquisition pillars;
- boss reward biases high-value/combination-core materials and guarantees at least one current-school-related option;
- ~3-minute elite opportunity and ~5-minute segment boss;
- explicit atomic combinations with progressive hints;
- Persistent Workbench with backpack continuously central;
- complete mouse, keyboard/gamepad and touch completion paths;
- visible, mutually exclusive whole-layout movement mode;
- UI displays domain snapshots and emits intent; it never owns geometry/economy/reward/combination rules;
- Fate is the final REST commit boundary;
- no new save system in MVP-4.

## Expected current runtime mismatch

Current merged runtime is intentionally still MVP-3:

- `RunBuildState.owned_items` count ownership exists;
- shop purchase immediately creates owned item/modifier state;
- `StageFlowController` still uses `RESULT → SHOP → FATE → PREVIEW`;
- `RestFlowUI` still has separate Result/Shop/Fate/Preview views;
- no spatial backpack classes, elite/chest token, forced boss-reward layer or Persistent Workbench runtime exists.

These are implementation targets, not already-fixed bugs.

## Verification state

```yaml
mvp4_product_design: APPROVED
mvp4_written_design_spec: APPROVED_BY_USER
mvp4_design_pr_7: MERGED
mvp4_design_post_merge_ci: PASS_RUN_31434691578
mvp4_traceability_packet: WRITTEN_ON_PR_8_COVERAGE_GAP
mvp4_implementation_plan: WRITTEN_ON_PR_8_ADVERSARIAL_REVIEWED
mvp4_planning_pr_8: OPEN_VALIDATION_IN_PROGRESS
mvp4_explicit_planning_complete_declaration: NOT_RECEIVED
mvp4_code: NOT_STARTED
mvp4_gut_tests: NOT_RUN
mvp4_godot_runtime: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_android_device_qa: NOT_RUN
sheet_sync: BLOCKED_USER_ACTION_403
```

No MVP-4 runtime PASS claim is valid yet.

## Protected scope

- Do not execute MVP-4 production code before the explicit project transition phrase `기획 완료`.
- Do not silently revert approved rotation, non-rectangular bag, overlap-item movement, one-cell special-bag overlap, reward cadence, boss-reward weighting, atomic combination, Persistent Workbench or whole-layout-mode decisions.
- Do not create a second backpack/modifier authority.
- Reuse current `WaveSpawner` for existing spawn controls; do not invent a second wave system for the elite.
- Do not commit local `addons/`, `.godot/`, plugin activation, unrelated `project.godot` changes, or destructive git operations.
- Do not treat blocked Sheet sync as a global blocker.

## Resume read order

1. current GitHub `main` and open PRs
2. `AGENTS.md`
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. this file
5. approved L2 spec
6. L3 traceability packet
7. implementation plan
8. current MVP-3 implementation hotspots
9. project Google Sheet when writer/read access is available
10. current Base main only for relevant contract drift

## Next executable step

**Validate and merge documentation-only PR #8. Then reconcile this router to the merged planning checkpoint and stop at the explicit `기획 완료` gate.**