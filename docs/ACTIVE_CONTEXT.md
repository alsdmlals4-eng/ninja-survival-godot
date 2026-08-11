# ACTIVE_CONTEXT

> Mutable resume router for `ninja-survival-godot`. Always re-query current GitHub `main` and open/draft PRs; this file does not own the SHA of the commit containing itself.

## Read first

1. `AGENTS.md`
2. `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. approved L2: `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
5. DEC-002 defaults: `docs/planning/2026-08-11-mvp4-content-balance-v1.md`
6. validated data contract: `docs/planning/2026-08-11-mvp4-content-data-contract.md`
7. Phase-B record: `docs/planning/2026-08-11-mvp4-phase-b-definition-of-ready.md`
8. L3 traceability: `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md`
9. 12-task plan: `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md`
10. Phase-C T01 handoff: `docs/handoffs/2026-08-11-mvp4-phase-c-t01-codex-handoff.md`
11. actual current code/scenes/data/tests and current Base `main`

The Phase-B record is a narrow later technical amendment to T01/T03/T07 and old phase-status wording. Product authority remains Decisions/L2.

## Current stage

```yaml
project: alsdmlals4-eng/ninja-survival-godot
latest_integrated_runtime_milestone: MVP-3
phase_b_review_baseline_main: 11a81208ec9ad7ca9f4a044d3226e1be0ea25f76
phase_b_merge_main: 225d68e7545062e3c2bc720562263fe6a67131bd
phase_b_post_merge_gut: PASS_RUN_31454048030
phase_c_handoff_merge_main_before_postmerge_fix: 4d0b3f39581103500675ad5ac7e89da4805a6114
phase_c_handoff_post_merge_gut: PASS_RUN_31454909432
base_main_observed_phase_b: 315c66eea9614c284b9c11c4d522141065dfa4b0
mvp4_product_design: APPROVED
mvp4_decision_001: INTEGRATED
mvp4_decision_002: INTEGRATED_PR_12
mvp4_explicit_planning_complete_declaration: RECEIVED_2026_08_11
phase_a: COMPLETE
phase_b_final_planning_review: PASS
phase_b_open_must_fix: 0
phase_b_open_user_decision_required: 0
phase_c_build: AUTHORIZED_AWAITING_LOCAL_EXECUTOR
phase_c_t01_handoff: docs/handoffs/2026-08-11-mvp4-phase-c-t01-codex-handoff.md
phase_c_t01_remote_branch: impl/mvp4-t01-spatial-data-contracts
phase_c_t01_branch_base: 225d68e7545062e3c2bc720562263fe6a67131bd
phase_c_t01_branch_policy: INTENTIONALLY_PINNED_TO_PHASE_B_BASELINE
phase_c_t01_latest_operational_docs: READ_FROM_ORIGIN_MAIN_WITH_GIT_SHOW
phase_c_t01_status: READY_FOR_LOCAL_REDGREEN_EXECUTION
mvp4_production_code: NOT_STARTED
mvp4_runtime_evidence: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_android_device_qa: NOT_RUN
```

`PHASE_B_PASS`, prepared branch and handoff are readiness evidence only. Do not claim T01 GREEN or MVP-4 runtime/human PASS until actual local execution evidence exists.

## Phase chain

```text
PHASE A — planning [COMPLETE]
→ explicit `기획 완료` [RECEIVED]
→ PHASE B — Final Planning Review / DoR [PASS]
→ PHASE C — PowerShell / Codex / Godot BUILD [AUTHORIZED]
→ T01 focused RED [NEXT / NOT RUN]
→ T01 GREEN + regression + package review
→ T02 ... T12
```

## T01 baseline / operational-doc boundary

The package branch is intentionally pinned to Phase-B implementation baseline:

`impl/mvp4-t01-spatial-data-contracts@225d68e7545062e3c2bc720562263fe6a67131bd`

Phase-C operational documents were merged after that branch was created. Do not fast-forward the package branch just to acquire docs and do not create a self-referential package-baseline loop.

After `git fetch origin --prune`, the local executor must:

- read package canon from the branch working tree;
- read latest `docs/ACTIVE_CONTEXT.md` and `docs/handoffs/2026-08-11-mvp4-phase-c-t01-codex-handoff.md` with `git show origin/main:<path>`;
- compare `225d68e7...` to `origin/main`;
- allow pre-execution main drift only in those two operational-document paths;
- stop before editing if any other path has changed.

This is an execution-safety rule, not permission to ignore future real code/canon drift.

## T01 package boundary

Allowed modify:

- `scripts/data/item_definition.gd`
- `scripts/data/run_modifier_set.gd`
- `tests/unit/test_script_contracts.gd`

Allowed create:

- `scripts/data/spatial_rule_definition.gd`
- `scripts/data/bag_definition.gd`
- `scripts/data/item_instance.gd`
- `scripts/data/bag_instance.gd`
- `scripts/data/combination_definition.gd`
- `scripts/data/mvp4_catalog.gd`
- `tests/unit/test_mvp4_catalog.gd`

Read-only regression references:

- `scripts/data/mvp3_catalog.gd`
- `scripts/core/run_build_state.gd`
- `tests/unit/test_run_build_state.gd`
- `project.godot`

Codex may not create/switch branches, create/update/merge PRs, force-push, amend, change `project.godot`, modify UI/Scene/controllers, or begin T02 in this package. GPT reviews the pushed package branch and owns PR/merge after evidence.

## Phase-B technical contract to preserve

- `RunModifierSet` owns supported modifier fields and the additive helper.
- `ItemDefinition.static_modifier_payload: Dictionary[StringName, float]`.
- `ItemDefinition.spatial_rules: Array[SpatialRuleDefinition]`.
- `SpatialRuleDefinition` is bounded to approved orthogonal-neighbor semantics; no general relationship DSL.
- no resolver item-ID branches for strong-spatial content.
- new static payload and legacy `effect_kind/effect_value` never double-apply.
- `school_emblem.school_payload` remains selected-school conditional behavior.
- `MVP4Catalog` separates base acquisition IDs from combo-result IDs.
- candidate IDs are canonical-sorted before seeded weighted selection.
- first catalog default = 8 strong-spatial; approved product tuning range = 7–9.

## Protected MVP-4 product scope

- fixed `6x6` board / starting `4x3` active area;
- item and bag 90° rotation;
- rectangular regular items and selected L/T bags;
- connected orthogonal bag region, no bag overlap, items only on active cells;
- 6-slot REST work buffer, zero-buffer Fate gate;
- orthogonal adjacency, same pair once; one-cell special-bag overlap activation;
- boss quality / shop control / chest quantity-random acquisition roles;
- ~3-minute elite opportunity / ~5-minute segment boss;
- 3 explicit atomic first-tier combinations only;
- Persistent Workbench; mouse + keyboard/gamepad + touch completion paths;
- visible mutually-exclusive whole-layout move mode;
- UI renders snapshots/emits intent only;
- DEC-002 hybrid direction and 4-normal+1-special bag boundary;
- no new save system, rarity layer, deeper combo tiers, arbitrary polyomino regular items or deep set/curse system.

## Expected runtime before T01

The integrated runtime remains MVP-3: legacy single-effect ItemDefinition, owned-count modifier authority, immediate shop activation, linear RESULT→SHOP→FATE→PREVIEW, and no spatial backpack/elite/chest/Workbench runtime. These are implementation targets, not already-fixed behavior.

## Google Sheet blocker

```yaml
project_sheet_read: PASS
project_sheet_sync: GITHUB_UPDATE_PENDING_SHEET
project_sheet_write: BLOCKED_USER_ACTION_403
classification: LOCAL_TASK_BLOCKER
required_user_action: grant editor permission or reconnect a writer-capable Google account
```

Known stale Sheet areas include old staged rotation, future-combo labeling, historical 5/10/15 timing, and missing current benchmark rows. Do not report Sheet `SYNCED`; do not block independent Phase-C execution solely for this permission.

## Environment facts

```yaml
godot_engine_target: 4.7.1
gut_target: 9.7.1
godot_ai_user_reported_local_version: 3.1.4
godot_ai_status: INFORMATIONAL_UNTIL_FRESH_LOCAL_VERIFICATION
local_windows_powershell_codex_godot_execution_in_this_chat: UNAVAILABLE
```

Godot AI 3.1.4 is separate from Godot Engine 4.7.1. The local executor must freshly verify Codex, Godot Engine, GUT and any Godot-AI/HiGodot/Hera route before use.

## Next executable step

**On the user Windows machine, run the PowerShell preflight and Codex prompt from the latest `origin/main:docs/handoffs/2026-08-11-mvp4-phase-c-t01-codex-handoff.md`. The preflight must confirm the package branch is exactly `225d68e7...` and that `origin/main` drift is operational-doc-only before Codex edits. Observe focused T01 RED before any production GREEN code. After Codex pushes the package branch, GPT verifies the exact remote diff/evidence, creates the T01 PR, performs adversarial review and exact-head CI, merges only if all gates pass, then readbacks merged main before T02.**
