# ACTIVE_CONTEXT

> Mutable resume router for `ninja-survival-godot`. Re-query GitHub `main` every time; this file does not own the SHA of the commit that contains itself.

## Authority / read order

1. current project `main` + open/draft PR inventory
2. `AGENTS.md`
3. `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`
4. `docs/CURRENT_CONFIRMED_DECISIONS.md`
5. approved L2: `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
6. DEC-002 defaults: `docs/planning/2026-08-11-mvp4-content-balance-v1.md`
7. benchmark evidence: `docs/research/2026-08-11-mvp4-backpack-survivors-benchmark.md`
8. validated data contract: `docs/planning/2026-08-11-mvp4-content-data-contract.md`
9. Phase-B record: `docs/planning/2026-08-11-mvp4-phase-b-definition-of-ready.md`
10. L3: `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md`
11. TDD plan: `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md`
12. current actual code / scenes / data / tests
13. connected Google Sheet where relevant
14. current Base `main` for relevant contract drift

The Phase-B record is a narrow later technical amendment to T01/T03/T07 and the phase-status sentence in the older plan. It does not replace Decisions/L2 product authority or the 12-task execution order.

Last updated: 2026-08-11

## Current baseline / gates

```yaml
project: alsdmlals4-eng/ninja-survival-godot
phase_b_entry_main: 11a81208ec9ad7ca9f4a044d3226e1be0ea25f76
phase_b_entry_open_or_draft_prs: 0
base_main_observed_phase_b: 315c66eea9614c284b9c11c4d522141065dfa4b0
latest_integrated_runtime_milestone: MVP-3
mvp4_product_design: APPROVED
mvp4_decision_001: INTEGRATED
mvp4_decision_002: INTEGRATED_PR_12
mvp4_l2: APPROVED_AND_INTEGRATED
mvp4_l3: INTEGRATED_COVERAGE_GAP
mvp4_implementation_plan: INTEGRATED_12_TASKS_WITH_PHASE_B_AMENDMENT
mvp4_explicit_planning_complete_declaration: RECEIVED_2026_08_11
phase_a: COMPLETE
phase_b_final_planning_review: PASS
phase_b_record: docs/planning/2026-08-11-mvp4-phase-b-definition-of-ready.md
phase_b_open_must_fix: 0
phase_b_open_user_decision_required: 0
phase_c_build: AUTHORIZED_NOT_STARTED
next_task: T01_SPATIAL_DATA_CONTRACTS_FOCUSED_RED
mvp4_implementation_branch: NONE_AT_PHASE_B_ENTRY
mvp4_implementation_pr: NONE_AT_PHASE_B_ENTRY
mvp4_production_code: NOT_STARTED
mvp4_gut_runtime_evidence: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_android_device_qa: NOT_RUN
```

`PHASE_B_PASS` is readiness evidence only. Do not report T01 GREEN, MVP-4 runtime PASS, human usability PASS, Android PASS, or MVP-4 completion until the corresponding execution evidence exists.

## Active delivery contract

```yaml
active_delivery_contract: PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md
contract_version: 4.5
contract_revision: 2026-08-11-r2
contract_source_bytes: 77734
contract_source_lf_count: 2849
contract_source_sha256: 3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4
contract_source_git_blob_sha1: de7c6f818a4c96d2a02edea5eaff33bb1c39e8da
contract_source_path_conflict: SWITCHY_EXPRESS_STALE_PATH_OVERRIDDEN_BY_AGENTS
ninja_survival_local_and_godot_path: C:/Users/user/Documents/GitHub/Ninza/ninja-survival-godot
```

Authoritative phase chain:

```text
PHASE A — planning
→ explicit `기획 완료` [RECEIVED]
→ PHASE B — final planning review / DoR [PASS]
→ PHASE C — PowerShell / Codex / Godot BUILD [AUTHORIZED, NOT STARTED]
→ T01 RED → GREEN → ... → T12 verification/closure
```

## Phase-B technical closure

The validated content-data contract now requires:

- `RunModifierSet` owns the supported modifier field list and additive helper;
- `ItemDefinition.static_modifier_payload: Dictionary[StringName, float]`;
- `ItemDefinition.spatial_rules: Array[SpatialRuleDefinition]`;
- new bounded `scripts/data/spatial_rule_definition.gd` for orthogonal adjacency only;
- no resolver item-ID branches for strong-spatial content;
- static payload wins over legacy `effect_kind/effect_value`; never double-apply;
- existing `school_emblem.school_payload` remains selected-school conditional behavior;
- explicit `base_acquisition_item_ids()` and `combination_result_item_ids()` boundaries;
- canonical-sort candidate IDs before seeded weighted selection;
- T01/T03/T07 RED tests directly prove those contracts.

The first content authoring default remains 8 strong-spatial items, while the approved product tuning range remains 7–9.

## Expected current runtime mismatch

At the Phase-B entry main, runtime is intentionally still MVP-3:

- `ItemDefinition` has only legacy single-effect fields plus school payload;
- `RunBuildState.owned_items` count recomputes item modifiers immediately;
- shop purchase immediately affects owned/modifier state;
- `StageFlowController` still uses `RESULT → SHOP → FATE → PREVIEW`;
- `RestFlowUI` still uses separate Result/Shop/Fate/Preview views;
- no BackpackState/Resolver/Session/CombinationResolver;
- no RestRewardController, StageElite/chest token, forced boss reward, or Persistent Workbench;
- no MVP-4 production tests.

These are T01–T11 implementation targets, not planning defects. Re-query actual code before every Phase-C execution block.

## Protected MVP-4 scope

- fixed `6x6` board / starting `4x3` active area;
- item and bag 90° rotation;
- regular items rectangular; selected L/T bags only;
- bags orthogonally connected, no overlap; items only on active cells;
- individual bag move carries overlapping item candidates but never another bag;
- orthogonal item adjacency; same pair effect once regardless shared-edge count;
- special bag applies on at least one overlapped item cell; distinct special bags may each apply;
- 6-slot REST work buffer; buffer contributes zero combat/spatial/combo effect and must be empty before Fate;
- boss reward = quality/choice, shop = control/economy, chest = quantity/randomness;
- ~3-minute elite opportunity, ~5-minute segment boss;
- explicit atomic first-tier combinations: water_mist, thunder_blade, explosive_bomb;
- Persistent Workbench with board central;
- mouse, keyboard/gamepad and touch full paths;
- visible mutually-exclusive whole-layout movement mode;
- UI renders snapshots/emits intent only;
- Fate is final REST commit boundary;
- DEC-002 hybrid direction: every base item useful alone, 7–9 strong-spatial tuning range, 8 first default;
- 5 bags remain 4 normal + 1 special;
- no new save system, rarity layer, deeper combo tiers, arbitrary polyomino regular items, deep set/curse system or unrelated refactor.

## Task order

```text
T01 data contracts/catalog
→ T02 BackpackState
→ T03 BackpackResolver
→ T04 RestBackpackSession
→ T05 CombinationResolver
→ T06 committed modifier migration
→ T07 boss/shop/chest acquisition
→ T08 StageElite/cadence/phase flow
→ T09 Persistent Workbench UI
→ T10 input/responsive parity
→ T11 full composition/Fate boundary
→ T12 full verification/human evidence/traceability closure
```

Use strict focused RED → observe intended failure → minimal GREEN → relevant regression → exact diff review → commit explicit paths. Independent review checkpoints remain after T03, T07, T10 and T11.

## Google Sheet blocker

The project Google Sheet is readable but write remains blocked by `403 PERMISSION_DENIED`; no attempted write is considered applied.

Known stale areas include:

- `백팩`: old staged rotation wording;
- `인법과조합`: future combinations not clearly separated from current 3;
- `변경메모`: old `5/10/15분` flow as historical text;
- `벤치마킹`: missing current DEC-002 benchmark rows.

```yaml
project_sheet_read: PASS
project_sheet_sync: GITHUB_UPDATE_PENDING_SHEET
project_sheet_write: BLOCKED_USER_ACTION_403
classification: LOCAL_TASK_BLOCKER
required_user_action: grant editor permission or reconnect a writer-capable Google account
```

Do not report Sheet `SYNCED` until a write and reread succeed. Do not block independent Phase-C implementation solely because of this Sheet permission.

## Environment facts

```yaml
godot_engine_target: 4.7.1
gut_target: 9.7.1
godot_ai_user_reported_local_version: 3.1.4
godot_ai_status: INFORMATIONAL_UNTIL_FRESH_LOCAL_VERIFICATION
```

Godot AI 3.1.4 is separate from the Godot Engine version. Phase C must verify the fresh local PowerShell/Codex/Godot authoring route and any HiGodot/Hera/Godot-AI availability before using or claiming it.

## Next executable step

**Enter PHASE C only after this Phase-B readiness batch is integrated and current main is re-read. Start T01 with the focused RED tests required by the validated content-data contract. The current chat does not claim local Windows PowerShell/Codex/Godot process execution until that route is actually available and verified.**
