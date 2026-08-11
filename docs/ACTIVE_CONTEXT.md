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
10. T00 pause/current blocker handoff: `docs/handoffs/2026-08-12-t00-provider-adoption-pause-handoff.md`
11. historical Phase-C T01 package handoff: `docs/handoffs/2026-08-11-mvp4-phase-c-t01-codex-handoff.md`
12. actual current code/scenes/data/tests, current GitHub PR state, and current Base `main`

The Phase-B record is a narrow later technical amendment to T01/T03/T07 and old phase-status wording. Product authority remains Decisions/L2. For mutable Google Sheet access/synchronization state, this router supersedes older pre-recovery `403` status snippets elsewhere; those older snippets are not current permission authority.

## Current stage

```yaml
project: alsdmlals4-eng/ninja-survival-godot
latest_integrated_runtime_milestone: MVP-3
phase_b_review_baseline_main: 11a81208ec9ad7ca9f4a044d3226e1be0ea25f76
phase_b_merge_main: 225d68e7545062e3c2bc720562263fe6a67131bd
phase_b_post_merge_gut: PASS_RUN_31454048030
phase_c_handoff_merge_main_before_postmerge_fix: 4d0b3f39581103500675ad5ac7e89da4805a6114
phase_c_handoff_post_merge_gut: PASS_RUN_31454909432
phase_c_handoff_postmerge_fix_main: 318d90efa0549d1e21266e011d63db98dfcade3d
phase_c_handoff_postmerge_fix_gut: PASS_RUN_31455361366
base_main_observed_phase_b: 315c66eea9614c284b9c11c4d522141065dfa4b0
mvp4_product_design: APPROVED
mvp4_decision_001: INTEGRATED
mvp4_decision_002: INTEGRATED_PR_12
mvp4_explicit_planning_complete_declaration: RECEIVED_2026_08_11
phase_a: COMPLETE
phase_b_final_planning_review: PASS
phase_b_open_must_fix: 0
phase_b_open_user_decision_required: 0
phase_c_build: AUTHORIZED
t00_provider_adoption_pr: 17
t00_provider_adoption_branch: ops/godot471-provider-uid-adoption
t00_provider_adoption_head_observed: bcd6d566de991fa1fe84aebf186e5dd654d6d274
t00_provider_adoption_status: BLOCKED_PENDING_SOURCE_FAITHFUL_REVALIDATION
t00_blocker: CI_UNCONDITIONALLY_OVERLAID_VENDORED_GUT_CREATING_ADDONS_GUT_GUT_AND_UID_DUPLICATES
t00_handoff: docs/handoffs/2026-08-12-t00-provider-adoption-pause-handoff.md
phase_c_t01_handoff: docs/handoffs/2026-08-11-mvp4-phase-c-t01-codex-handoff.md
phase_c_t01_remote_branch: impl/mvp4-t01-spatial-data-contracts
phase_c_t01_branch_base: 225d68e7545062e3c2bc720562263fe6a67131bd
phase_c_t01_branch_policy: HISTORICAL_PHASE_B_PIN_AWAITING_POST_T00_REFRESH_DECISION
phase_c_t01_latest_operational_docs: READ_FROM_ORIGIN_MAIN
phase_c_t01_status: PAUSED_PENDING_T00_INTEGRATION_AND_BASELINE_REFRESH
mvp4_production_code: NOT_STARTED
mvp4_runtime_evidence: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_android_device_qa: NOT_RUN
```

`PHASE_B_PASS`, a prepared historical T01 branch, local T00 evidence, and a green workflow are readiness/evidence inputs only. Do not claim T00 merge readiness when the validation preparation changed the checked-out source shape, and do not claim T01 GREEN or MVP-4 runtime/human PASS until current exact validation exists.

## Phase chain

```text
PHASE A — planning [COMPLETE]
→ explicit `기획 완료` [RECEIVED]
→ PHASE B — Final Planning Review / DoR [PASS]
→ PHASE C — BUILD [AUTHORIZED]
→ T00 provider/executor adoption [OPEN / SOURCE-FIDELITY REVALIDATION REQUIRED]
→ T00 merge + new-main readback
→ refresh/recreate T01 package baseline against provider-integrated main
→ T01 focused RED [PAUSED / NOT RUN]
→ T01 GREEN + regression + package review
→ T02 ... T12
```

## Current T00 prerequisite and CI fidelity gate

PR #17 is the active Phase-C provider/executor prerequisite. Its observed package includes HiGodot 3.1.4, GUT 9.7.1, Hera Agent Godot 1.0.0, provider activation/autoload metadata, and project-owned Godot 4.7.1 UID sidecars.

The first remote workflow for that PR ended green, but its dependency-preparation step unconditionally copied downloaded GUT into an already-vendored `addons/gut` directory. On Linux this produced `addons/gut/gut/**`, and Godot import reported many `UID duplicate detected` diagnostics. Therefore that green run is not source-faithful merge evidence.

Current project CI must preserve both states safely:

- when GUT is not vendored, bootstrap pinned GUT 9.7.1 once for CI;
- when GUT is vendored, verify and reuse that tree rather than overlaying another copy;
- reject a nested `addons/gut/gut` tree;
- capture import diagnostics and fail on `UID duplicate detected`.

The detailed recovery contract is in `docs/handoffs/2026-08-12-t00-provider-adoption-pause-handoff.md`.

## T01 baseline / operational-doc boundary

The historical package branch remains:

`impl/mvp4-t01-spatial-data-contracts@225d68e7545062e3c2bc720562263fe6a67131bd`

It was intentionally pinned to the Phase-B implementation baseline before T00 provider adoption became the active prerequisite. The older handoff allowed only two operational-document drift paths before T01 execution. **That narrow preflight is now superseded for execution purposes once this T00/CI-fidelity handoff closure lands**, because current main legitimately gains CI/handoff operational changes and T00 is expected to add provider/UID paths.

Do not execute production T01 against the old drift assumption. After T00 is source-faithfully validated and merged:

- fetch latest `main` and current Phase-C contract;
- read this router and the T00 pause handoff;
- read the old T01 handoff as historical package scope/technical context, not as permission to ignore new main paths;
- compare the intended T01 delta with the provider-integrated main;
- refresh/recreate the T01 implementation package using the current approved branch policy;
- preserve the T01 file boundary and technical contract unless current canon/approved plan explicitly changes them;
- observe focused T01 RED before production GREEN code.

Do not force-update the old pinned branch merely to erase history. Preserve it as historical evidence until the current package refresh route is chosen from fresh main.

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

## Google Sheet synchronization

The connected project Google Sheet is now writable and synchronized for the MVP-4 planning surfaces that were previously stale.

```yaml
spreadsheet_id: 1zGVjsvYQe057W6hiAEO2AkIdO1MBJdhVBYlGW92vd3A
project_sheet_read: PASS
project_sheet_permission_observed: ANYONE_WRITER
project_sheet_write_probe: PASS_2026_08_11
project_sheet_write: PASS
project_sheet_sync: SYNCED_TO_CURRENT_MVP4_CANON_2026_08_11
classification: NO_BLOCKER
```

Verified synchronized surfaces:

- `핵심요약`: MVP-4 now explicitly includes size differences, item/bag 90° rotation and selected L/T bags; deep set/curse/arbitrary complex shapes remain later.
- `백팩`: old staged-rotation wording removed; 6x6 / 4x3 / size / selected L/T bag / 90° rotation are marked MVP-4 basics; set/curse are future candidates.
- `MVP범위`: old `회전/복잡한 모양은 제외` wording removed; regular items remain rectangular while selected L/T bags and 90° rotation are included.
- `휴식구간흐름`: active flow now uses ~5-minute segment boss → RESULT → forced BOSS_REWARD → REST Workbench, with ~3-minute elite context.
- `인법과조합`: only 물안개 / 뇌명도 / 폭렬탄 are marked MVP-4; 독무 / 번개걸음 remain clearly labeled `후속 후보`.
- `벤치마킹`: refreshed Backpack Battles / Backpack Hero / DRG Survivor / Sproggiwood / Resogun evidence and DEC-2026-08-11-002 Hybrid A conclusion added.
- `변경메모`: historical 2026-07-10 rows are preserved and new 2026-08-11 superseding rows record current rotation, combo, cadence, benchmark and sync decisions.

Post-write searches returned zero matches for the stale active phrases `초기부터 전부 열지 않음`, `회전/복잡한 모양은 제외`, and `5/10/15분 보스 처치`; `후속 후보` correctly returns exactly the two future combination rows.

Older `403 / GITHUB_UPDATE_PENDING_SHEET` snippets in `docs/CURRENT_CONFIRMED_DECISIONS.md` or `docs/DOCUMENTATION_MAP.md` describe the pre-permission-recovery observation and are stale as mutable access-state evidence. Do not use them to override this fresh verified Sheet state. They are intentionally not edited before T01 because the product decisions in those files remain authoritative and unchanged.

## Environment facts

```yaml
godot_engine_target: 4.7.1
gut_target: 9.7.1
godot_ai_user_reported_local_version: 3.1.4
godot_ai_status: INFORMATIONAL_UNTIL_FRESH_LOCAL_VERIFICATION
local_windows_powershell_codex_godot_execution_in_this_chat: UNAVAILABLE
```

Godot AI 3.1.4 is separate from Godot Engine 4.7.1. The local executor must freshly verify Codex, Godot Engine, GUT and any Godot-AI/HiGodot/Hera route before use.

## Learning / Base promotion state

```yaml
LRN-NS-2026-08-12-001:
  classification: SPLIT
  project_application: .github/workflows/gut.yml
  project_verification: EXACT_HANDOFF_CLOSURE_PR_CI_REQUIRED
  base_candidate: CI_SOURCE_FIDELITY_FOR_VENDORED_DEPENDENCIES
LRN-NS-2026-08-12-002:
  classification: PROJECT_ONLY
  project_application: T00_BEFORE_T01_RESUME_ROUTE
  project_verification: ACTIVE_CONTEXT_AND_HANDOFF_REREAD
LRN-NS-2026-08-12-003:
  classification: NO_PROMOTION
  existing_base_owner: maintaining-project-context-and-handoff
```

Any Base promotion from this checkpoint is proposal-only: `[수정제안서]/**`. Base active implementation is a separate stage and is not authorized by this handoff work.

## Next executable step

**Do not start T01. First finish and merge the project handoff/CI-fidelity closure, then submit/merge any validated reusable lesson as a collision-safe Base proposal-only PR. On later implementation resume, fetch latest main and PR #17, require the current project CI fidelity guard, revalidate T00 without `addons/gut/gut` or `UID duplicate detected`, perform adversarial review, merge T00 only if current gates pass, read back new main, refresh/recreate the T01 package baseline from that provider-integrated main, and only then observe focused T01 RED before production GREEN code.**
