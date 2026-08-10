# ACTIVE_CONTEXT

> 다음 작업자가 현재 GitHub 상태를 빠르게 복원하기 위한 mutable router다.
> 최상위 프로젝트 규칙은 `AGENTS.md`, 활성 실행/전달 계약은 `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`, 제품 결정은 `docs/CURRENT_CONFIRMED_DECISIONS.md`, 승인 MVP-4 상세 설계는 `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`, 구현 연결은 `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md`, TDD 실행 계획은 `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md`를 본다.
> 이 파일은 자기 자신이 포함된 최종 `main` SHA를 소유하지 않는다. 재개 시 GitHub `main`을 항상 재조회한다.

Last updated: 2026-08-11

## Baseline

```yaml
project: alsdmlals4-eng/ninja-survival-godot
planning_checkpoint_sha: 360e8652b51e8125c63b7a5cdc2288092bb8e096
planning_checkpoint_meaning: PR_8_L2_L3_PLAN_INTEGRATED
latest_integrated_runtime_milestone: MVP-3
mvp4_design_pr_7: MERGED_CLOSED
mvp4_design_merge_commit: 655ec26a5ac9946c0ec08f81f389ddfe66e72b65
mvp4_planning_pr_8: MERGED_CLOSED
mvp4_planning_merge_commit: 360e8652b51e8125c63b7a5cdc2288092bb8e096
mvp4_planning_post_merge_gut: PASS_RUN_31437135591
state_reconciliation_scope: PR_9_POST_PLANNING_MERGE_METADATA_ONLY
mvp4_implementation_branch: NONE
mvp4_implementation_pr: NONE
active_delivery_contract: PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md
contract_version: 4.5
contract_revision: 2026-08-11-r2
contract_source_bytes: 77734
contract_source_lf_count: 2849
contract_source_sha256: 3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4
contract_source_git_blob_sha1: de7c6f818a4c96d2a02edea5eaff33bb1c39e8da
contract_adoption_state: ACTIVE_PROJECT_CANON_INTEGRATED_PR_10
contract_adoption_merge_commit: 653ec714b1698e8d768a07d171737c7d3d8898d0
contract_adoption_post_merge_gut: PASS_RUN_31442268566
contract_source_path_conflict: SWITCHY_EXPRESS_STALE_PATH_OVERRIDDEN_BY_AGENTS
ninja_survival_local_and_godot_path: C:/Users/user/Documents/GitHub/Ninza/ninja-survival-godot
base_repo: alsdmlals4-eng/Base
base_main_observed_at_contract_adoption: 315c66eea9614c284b9c11c4d522141065dfa4b0
project_base_rules_last_explicit_sync: 499c20eb9b449241864f5ada0c915fba8a7806ac
full_base_rule_sync: NOT_RUN
project_sheet_sync: GITHUB_UPDATE_PENDING_SHEET
project_sheet_write: BLOCKED_USER_ACTION_403
```

## Current stage

`MVP-4 Backpack / Combination Basics — DESIGN_APPROVED / TRACEABILITY_AND_IMPLEMENTATION_PLAN_INTEGRATED / V4_5_R2_CANON_INTEGRATED / PENDING_EXPLICIT_기획_완료`

Implementation status: `NOT_STARTED`

The approved L2 design, L3 traceability packet and 12-task Superpowers TDD implementation plan are integrated at planning checkpoint `360e8652...`. The byte-exact v4.5 r2 execution/delivery contract is integrated through PR #10 at `653ec714...`, and the post-merge GUT run `31442268566` completed successfully. These are planning/governance and existing-regression evidence only; they do **not** verify or start any MVP-4 production behavior.

## Active v4.5 r2 binding

The tracked contract source identity is:

```yaml
bytes: 77734
lf_count: 2849
sha256: 3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4
git_blob_sha1: de7c6f818a4c96d2a02edea5eaff33bb1c39e8da
```

The r2 source is preserved verbatim. Its §4 `Switchy-Express-Cargo-Puzzle` local/Godot paths are not silently rewritten; for this repository `AGENTS.md` classifies them as `STALE_FOREIGN_PROJECT_INPUT / NON_EXECUTABLE_FOR_NINJA_SURVIVAL` and supplies the authoritative Ninja Survival path.

The r2 phase boundary is authoritative:

```text
PHASE A — GPT CHAT PLANNING
→ explicit user `기획 완료`
→ PHASE B — FINAL PLANNING REVIEW / DEFINITION OF READY
→ PHASE B PASS
→ PHASE C — POWERSHELL / CODEX / GODOT BUILD
→ T01 RED → GREEN ...
```

The user's approval to replace the GitHub work-instruction canon and continue approved documentation work is **not** the separate `기획 완료` declaration.

## Completed planning checkpoint

- MVP-0 basic combat foundation integrated.
- MVP-1 combat DDD integrated.
- MVP-2 four shallow schools integrated.
- MVP-3 result/rest/shop/fate runtime integrated and remains the rollback baseline.
- MVP-4 product rules are approved, including board, rotation, bag connectivity, overlap-item movement, adjacency, special bags, work buffer, acquisition pillars, elite/boss cadence, combinations and Persistent Workbench.
- `DEC-2026-08-11-001` Persistent Workbench is approved.
- The directional-input collision is resolved by a visible mutually exclusive `전체 이동 모드`.
- L2 feature spec status is `APPROVED`.
- L3 traceability maps AC-01..AC-15 with no unmapped acceptance criterion; `coverage_status` remains `GAP` because actual implementation/evidence do not exist.
- Implementation plan contains 12 ordered RED→GREEN tasks and exact planned paths.
- Adversarial plan review removed an executable placeholder, removed an unnecessary WaveSpawner modification, named exact `StageElite` files, added deterministic elite tuning defaults, tightened L3 paths, and restored regression-sensitive Decision details.
- PR #8 exact planning head passed GUT and merged; post-merge main GUT also passed.
- PR #10 installed the byte-exact v4.5 r2 root contract and project adapters; exact PR head GUT and post-merge main GUT both passed.
- The source's foreign Switchy path defect remains visible in the source and is bounded by the explicit Ninja Survival override in `AGENTS.md` rather than silently rewritten.

## Production gate under v4.5 r2

Until the user explicitly declares:

```text
기획 완료
```

- do not create an MVP-4 production implementation branch;
- do not write Godot production code/scenes/data;
- do not run the implementation plan as BUILD;
- do not claim MVP-4 GUT/runtime/human QA PASS.

After `기획 완료`, **do not jump directly to T01**. Execute PHASE B first:

1. re-query current GitHub `main`, all open/draft same-goal PRs, current relevant Base `main`, and connected Sheet state;
2. reread `AGENTS.md` → active r2 contract → Decision → this router → approved L2 → L3 → implementation plan;
3. decompose the approved feature into implementation units and reclassify each relevant current code/data/scene/test surface as current / already-reflected / conflicting-stale / missing;
4. revalidate benchmark/industry evidence only where it can materially change implementation detail, without reopening approved product rules by default;
5. verify task order, dependencies, protected scope, rollback boundaries, exact file/API paths, and required verification targets against the current repository tree;
6. run required adversarial review / Superpowers planning checks and close all `MUST_FIX` readiness findings;
7. close Definition of Ready with explicit evidence that no material Phase B blocker remains;
8. only after PHASE B PASS enter PHASE C and begin T01 with a focused failing GUT test before production GREEN code.

## Deferred local blocker — Google Sheets

Project GDD Sheets still contain stale older rotation/timing wording. The 2026-08-11 write attempt returned `403 PERMISSION_DENIED`.

```yaml
classification: LOCAL_TASK_BLOCKER
state: GITHUB_UPDATE_PENDING_SHEET
required_user_action: grant the connected Google account edit permission or reconnect a writer-capable account
independent_work: V4_5_R2_CANON_INTEGRATED / WAITING_FOR_EXPLICIT_PLANNING_GATE
```

Do not report Sheets as `SYNCED` until a write and reread succeed.

## Production work not started

- `BackpackState`, `BackpackResolver`, `RestBackpackSession`, `CombinationResolver` implementation.
- `ItemInstance`, `BagInstance`, `BagDefinition`, MVP-4 catalog implementation.
- committed spatial modifier migration.
- boss/shop/chest REST reward implementation.
- ~3-minute `StageElite` runtime and chest token implementation.
- Persistent Workbench/board UI implementation.
- MVP-4 automated tests, runtime validation, Windows human QA, Android device QA.
- MVP-4 implementation branch/PR/merge.

## Critical approved decisions to preserve

- fixed `6x6` board and starting `4x3` active area;
- item/bag 90-degree rotation;
- rectangular regular items and selected L/T bags;
- individual bag move carries overlapping item candidates but never chain-moves another bag;
- one connected orthogonal bag region;
- orthogonal item adjacency only, one effect per pair;
- one-cell special-bag overlap activation; distinct bag instances may each apply;
- six-slot REST work buffer and zero-buffer Fate gate;
- boss reward + shop + chest acquisition pillars;
- boss reward biases high-value/combination-core materials and guarantees at least one current-school-related option;
- ~3-minute elite opportunity and ~5-minute segment boss;
- explicit atomic combinations with progressive hints;
- Persistent Workbench with backpack continuously central;
- complete mouse, keyboard/gamepad and touch completion paths;
- visible mutually exclusive whole-layout movement mode;
- UI displays domain snapshots and emits intent; it never owns geometry/economy/reward/combination rules;
- Fate is the final REST commit boundary;
- no new save system in MVP-4.

## Expected current runtime mismatch

The runtime at the planning checkpoint is intentionally still MVP-3:

- `RunBuildState.owned_items` count ownership exists;
- shop purchase immediately creates owned item/modifier state;
- `StageFlowController` still uses `RESULT → SHOP → FATE → PREVIEW`;
- `RestFlowUI` still has separate Result/Shop/Fate/Preview views;
- no spatial backpack classes, elite/chest token, forced boss-reward layer or Persistent Workbench runtime exists.

These are T01–T11 implementation targets, not already-fixed bugs. Re-query current code before Phase B/BUILD rather than assuming no later change occurred.

## Verification state

```yaml
mvp4_product_design: APPROVED
mvp4_written_design_spec: APPROVED_AND_INTEGRATED
mvp4_traceability_packet: INTEGRATED_COVERAGE_GAP
mvp4_implementation_plan: INTEGRATED_IMPLEMENTATION_READY_FOR_PHASE_B_REVIEW
mvp4_design_pr_7: MERGED
mvp4_planning_pr_8: MERGED
mvp4_planning_post_merge_ci: PASS_RUN_31437135591
active_delivery_contract_v4_5_r2: BYTE_EXACT_INTEGRATED_PR_10
active_delivery_contract_v4_5_r2_post_merge_ci: PASS_RUN_31442268566
mvp4_explicit_planning_complete_declaration: NOT_RECEIVED
phase_b_final_planning_review: NOT_RUN
phase_c_build: BLOCKED
mvp4_code_at_planning_checkpoint: NOT_STARTED
mvp4_gut_tests: NOT_RUN
mvp4_godot_runtime: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_android_device_qa: NOT_RUN
sheet_sync: BLOCKED_USER_ACTION_403
```

No MVP-4 runtime PASS claim is valid yet.

## Protected scope

- Do not execute MVP-4 production code before explicit `기획 완료` **and PHASE B PASS**.
- Do not silently rewrite the r2 source to hide its foreign-project path defect; use the bounded `AGENTS.md` project override.
- Do not silently revert approved rotation, non-rectangular bag, overlap-item movement, one-cell special-bag overlap, reward cadence/weighting, atomic combination, Persistent Workbench or whole-layout-mode decisions.
- Do not create a second backpack/modifier authority.
- Reuse current `WaveSpawner` API; do not invent a second wave system for the elite.
- Do not commit local `addons/`, `.godot/`, plugin activation, unrelated `project.godot` changes, or destructive git operations.
- Do not treat blocked Sheet sync as a global blocker.

## Resume read order

1. re-query current GitHub `main` and open/draft PRs
2. `AGENTS.md`
3. `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`
4. `docs/CURRENT_CONFIRMED_DECISIONS.md`
5. this file
6. approved L2 spec
7. L3 traceability packet
8. implementation plan
9. current implementation hotspots from the re-queried `main`
10. project Google Sheet when writer/read access is available
11. current Base main for relevant contract drift

## Next executable step

**Remain at the explicit `기획 완료` gate. When that declaration arrives, run PHASE B Final Planning Review / Definition of Ready against current repository/Base/Sheet evidence. Only after PHASE B PASS may PHASE C production implementation begin with T01 RED.**
