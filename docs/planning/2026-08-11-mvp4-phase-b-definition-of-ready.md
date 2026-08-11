# MVP-4 Phase B Final Planning Review / Definition of Ready

```yaml
review_id: PHASE-B-2026-08-11-MVP4
feature: MVP-4 Backpack / Combination Basics
work_mode: PLAN_TO_REVIEW
status: PHASE_B_PASS
reviewed_at: 2026-08-11
project_main_reviewed: 11a81208ec9ad7ca9f4a044d3226e1be0ea25f76
base_main_reviewed: 315c66eea9614c284b9c11c4d522141065dfa4b0
open_or_draft_project_prs_at_entry: 0
explicit_planning_complete: RECEIVED_2026_08_11
production_implementation_at_entry: NOT_STARTED
sheet_read: PASS
sheet_write: BLOCKED_USER_ACTION_403
sheet_sync: GITHUB_UPDATE_PENDING_SHEET
phase_c_authorized_after_this_record_is_integrated: true
```

## 1. Authority and purpose

This record closes the v4.5 r2 `PHASE B — FINAL PLANNING REVIEW / DEFINITION OF READY` gate for the approved MVP-4 Backpack / Combination Basics feature.

It does **not** change the approved player-facing product direction. It validates current repository reality, resolves technical implementation ambiguities discovered after DEC-2026-08-11-002, and supplies a narrow execution amendment to the already-integrated 12-task Superpowers plan.

Authority order remains:

```text
latest user instruction
→ AGENTS.md / project safety-engine-data rules
→ PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md
→ docs/CURRENT_CONFIRMED_DECISIONS.md
→ approved L2 feature spec
→ this Phase-B readiness record for reviewed technical execution choices
→ L3 traceability packet + existing implementation plan
→ actual code / Scene / data / tests for implementation facts
```

If this record conflicts with an older technical placeholder or status sentence in the implementation plan, this later Phase-B review wins **only for the technical execution detail explicitly named here**. Product rules remain owned by Decisions/L2.

## 2. Entry-state reconciliation

### Current external state

- Project current `main`: `11a81208ec9ad7ca9f4a044d3226e1be0ea25f76`.
- Project open/draft PR inventory at Phase-B entry: `0`.
- Base current `main`: `315c66eea9614c284b9c11c4d522141065dfa4b0`.
- Google Sheet is readable but still contains stale MVP-4-incompatible wording such as staged rotation; writer retry remains blocked by `403 PERMISSION_DENIED`.
- Sheet drift is `LOCAL_TASK_BLOCKER`, not a global production blocker. GitHub canon remains execution authority.

### User execution facts

- Explicit `기획 완료` was received on 2026-08-11. This closes Phase A.
- The user later reported local **Godot AI 3.1.4**. Treat this as a user-reported local tool version, separate from Godot Engine and GUT versions.
- Godot Engine implementation/test authority remains `4.7.1`; formal GUT target remains `9.7.1` unless a later approved environment change says otherwise.
- Phase C fresh execution identity must verify the actual locally available Godot AI/HiGodot/Codex/Godot routes before using them; this Phase-B record does not claim local process availability.

## 3. Current implementation classification

| Surface | Phase-B classification | Disposition |
|---|---|---|
| `scripts/data/item_definition.gd` | CURRENT_MVP3 / INSUFFICIENT_FOR_DEC002 | extend in T01; preserve legacy fields during migration |
| `scripts/data/mvp3_catalog.gd` | CURRENT_MVP3 | preserve as rollback/regression source; MVP-4 gets separate catalog |
| `scripts/data/run_modifier_set.gd` | CURRENT_REUSABLE | add central supported-field validation/add helper; no new combat system |
| `scripts/core/run_build_state.gd` | CURRENT_MVP3 / CONFLICTING_AS_FINAL_MVP4_AUTHORITY | T06 migrates combat authority to committed spatial snapshot + Fate; owned count may remain compatibility-only |
| `scripts/core/shop_controller.gd` | CURRENT_REUSABLE_BUT_IMMEDIATE_PURCHASE_SEMANTICS_STALE_FOR_MVP4 | T07 routes acquisition into REST session/buffer without immediate combat activation |
| `scripts/core/stage_flow_controller.gd` | CURRENT_MVP3 / FLOW_STALE_FOR_MVP4 | T08 adds elite + BOSS_REWARD + REST phases |
| `scripts/core/main_controller.gd` | CURRENT_COMPOSITION_ROOT | reuse and incrementally rewire T07/T08/T11 |
| `scripts/spawning/wave_spawner.gd` | CURRENT_SUFFICIENT | read-only dependency; no second wave system |
| `scripts/enemies/stage_boss.gd` | CURRENT_SUFFICIENT | read-only comparison/runtime dependency |
| `scripts/ui/rest_flow_ui.gd` | CURRENT_MVP3 / PRESENTATION_STALE_FOR_MVP4 | retain outer RESULT/FATE/PREVIEW/COMPLETE responsibility; Workbench replaces linear shop center |
| `project.godot` | CURRENT_SUFFICIENT | no default InputMap mutation for Workbench |
| BackpackState/Resolver/Session/Combination/Reward/Elite/Workbench files | MISSING_EXPECTED | create only in T01–T10 per plan |
| MVP-4 tests | MISSING_EXPECTED | create RED-first per task |

No later production implementation was found that makes any planned T01–T11 unit redundant.

## 4. Existing Solution First disposition

```yaml
reuse:
  - ItemDefinition resource model
  - RunModifierSet existing combat channels
  - RunBuildState as run-level composition boundary
  - MainController as composition root
  - ShopController reroll/economy behaviors where not superseded
  - WaveSpawner existing spawn_distance and spawning enable API
  - StageBoss existing five-minute boss identity
  - RestFlowUI outer rest/result/fate/preview shell
extend:
  - MVP4Catalog
  - spatial state/resolver/session
  - REST reward transaction controller
  - Workbench UI
build_new_because_missing_capability:
  - SpatialRuleDefinition
  - BagDefinition / instances / combination definition
  - BackpackState / BackpackResolver / RestBackpackSession / CombinationResolver
  - StageElite
  - Workbench/board UI
forbidden_duplicate_authority:
  - second wave system
  - item-id branches in BackpackResolver
  - owned_items count as concurrent combat-modifier authority after T06
  - UI-side geometry/economy/reward/combination rules
```

## 5. Closed DEC-002 content-data contract

Godot 4.7 supports typed Dictionaries and Resource-typed data. MVP-4 therefore uses the following first concrete data representation.

### 5.1 `RunModifierSet` central field authority

`RunModifierSet` becomes the sole list of valid modifier field names.

Required API shape:

```gdscript
# scripts/data/run_modifier_set.gd
const SUPPORTED_FIELDS: Array[StringName] = [
    &"move_speed_pct",
    &"max_health_flat",
    &"max_health_pct",
    &"damage_taken_pct",
    &"healing_pct",
    &"normal_kill_gold_pct",
    &"school_damage_pct",
    &"non_ultimate_school_damage_pct",
    &"school_resource_gain_pct",
    &"ultimate_charge_gain_pct",
    &"ultimate_power_pct",
    &"school_status_effect_pct",
    &"evasion_chance",
    &"rest_start_heal_pct",
    &"bongma_familiar_interval_pct",
    &"cheonsul_reaction_damage_pct",
    &"guiin_melee_radius_pct",
    &"heukyeong_marked_crit_bonus",
    &"heukyeong_mark_duration_pct",
]

static func is_supported_field(field_name: StringName) -> bool
func add_delta(field_name: StringName, amount: float) -> bool
```

Unknown fields fail catalog/test validation. They are never silently ignored.

### 5.2 `ItemDefinition` static payload and legacy adapter

Add:

```gdscript
var static_modifier_payload: Dictionary[StringName, float] = {}
var spatial_rules: Array[SpatialRuleDefinition] = []
```

Authority rule:

```text
static_modifier_payload non-empty
→ it is the static item-effect authority

else legacy effect_kind/effect_value
→ adapt to one static modifier entry when it names a RunModifierSet field

school_emblem legacy school_payload
→ remains selected-school conditional payload and is not double-added as static payload
```

The existing eight MVP-3 item values are migration-regression protected.

### 5.3 Generic spatial rule resource

Create `scripts/data/spatial_rule_definition.gd`:

```gdscript
extends Resource
class_name SpatialRuleDefinition

enum Aggregation { ONCE_IF_ANY, PER_DISTINCT_NEIGHBOR }

var required_neighbor_tags: Array[StringName] = []
var required_neighbor_definition_ids: Array[StringName] = []
var aggregation: Aggregation = Aggregation.ONCE_IF_ANY
var max_matches: int = 1
var modifier_payload: Dictionary[StringName, float] = {}
```

MVP-4 relationship is intentionally fixed to approved **orthogonal item adjacency**. Do not create a generic relationship DSL or arbitrary geometry rule engine in this MVP.

Match semantics for this MVP are `ANY` across declared tag/id requirements. One neighbor instance counts at most once for one rule evaluation even if it matches multiple requirements or shares multiple edges.

This representation covers the initial 8 strong-spatial authoring defaults while the approved product tuning range remains 7–9 without resolver item-id hardcoding.

### 5.4 Special bag

Keep the already planned simple bag descriptor:

```text
affected_item_tag
auxiliary_effect_kind
auxiliary_effect_value
```

One special bag in MVP-4 does not justify a second generic rule system.

### 5.5 Catalog acquisition boundaries

`MVP4Catalog` exposes explicit acquisition boundaries:

```gdscript
static func build_items() -> Dictionary
static func build_bags() -> Dictionary
static func build_combinations() -> Dictionary
static func base_acquisition_item_ids() -> Array[StringName]
static func combination_result_item_ids() -> Array[StringName]
```

`build_items()` contains both base items and the 3 combination result definitions for lookup. `base_acquisition_item_ids()` contains only the 19 base acquisition items. Boss/shop/chest must never derive their pool by iterating every item definition.

### 5.6 Deterministic weighted reward selection

Before any weighted draw:

1. construct candidate IDs from the explicit base acquisition list;
2. remove ineligible IDs;
3. canonical-sort candidate IDs by `StringName` text;
4. compute weight from the approved first-pass source-specific rules;
5. clamp to the source contract's minimum/maximum;
6. perform seeded/injected RNG selection without replacement where required.

Dictionary iteration order is never an input to result identity.

The implementation may place the reusable weighted-pick helper inside `MVP4Catalog` or `RestRewardController`; only one authority is allowed. T07 must prove fixed seed + identical state returns identical ordered candidates.

## 6. Required plan amendments

The existing 12-task order is retained. The following technical amendments are mandatory when executing it.

### T01 amendment

Add/create/modify:

- create `scripts/data/spatial_rule_definition.gd`;
- modify `scripts/data/run_modifier_set.gd` with central supported-field validation/add helper;
- add `static_modifier_payload` and `spatial_rules` to `ItemDefinition`;
- create `MVP4Catalog` with explicit base-acquisition/combo-result boundaries.

Focused RED must prove:

- all 19 base item IDs + 3 combo-result IDs resolve uniquely;
- 5 purchasable bags + starting bag resolve;
- multi-axis payload returns exact values;
- unknown modifier field fails validation;
- all existing MVP-3 item effects migrate without value drift;
- combo results exist in lookup but not in base acquisition IDs;
- every spatial rule payload field is supported.

### T03 amendment

In addition to existing geometry tests, RED must prove:

- `katana`: 1 or more matching element-style neighbors applies its rule once;
- `shuriken`: distinct matching ninjutsu neighbors accumulate to cap 3;
- two shared edges to the same instance do not multiply a match;
- one neighbor matching multiple requirements counts once;
- resolver contains no item-definition-ID dispatch requirement for strong-spatial effects;
- identical state/catalog input produces equivalent deterministic modifier output.

### T07 amendment

RED must prove:

- current-school boss option guarantee;
- fixed seed + identical state → identical ordered boss options;
- combo-result IDs never appear in boss/shop/chest;
- chest has zero recipe-completion bonus;
- shop/boss/chest weighting remains source-distinct;
- candidates are canonicalized before RNG selection.

### Phase status amendment

The implementation plan's older final status text `IMPLEMENTATION_READY_AFTER_EXPLICIT_기획_완료` is superseded by:

```text
EXPLICIT 기획 완료 RECEIVED
→ PHASE B PASS recorded here
→ PHASE C AUTHORIZED
→ T01 begins with focused RED
```

## 7. Dependency/order validation

The existing order remains valid:

```text
T01 data contracts/catalog
→ T02 BackpackState
→ T03 BackpackResolver
→ T04 RestBackpackSession
→ T05 CombinationResolver
→ T06 RunBuildState committed modifier migration
→ T07 reward/shop/chest transactions
→ T08 elite/cadence/phase flow
→ T09 Persistent Workbench UI
→ T10 input/responsive parity
→ T11 full composition/Fate commit
→ T12 exact verification/human evidence/traceability closure
```

Reasoning:

- T03 requires T01 definitions and T02 instances/state.
- T04 requires resolver legality and copied state semantics.
- T05 requires session + resolver adjacency.
- T06 requires a stable resolved modifier snapshot before replacing MVP-3 count authority.
- T07 requires buffer/session and explicit acquisition pools.
- T08 requires RestRewardController before elite death can grant tokens.
- UI follows stable domain snapshots rather than inventing rules first.
- T11 is the first complete composition point and remains after all domain/UI inputs exist.

No safe parallelization gain justifies changing this dependency chain for first implementation.

## 8. Protected scope and rollback

### Protected

- `6x6` board / starting `4x3` active area.
- 90-degree item + bag rotation.
- connected orthogonal bag region; no bag overlap.
- rectangular regular items, selected L/T bags only.
- six-slot REST work buffer and zero-buffer Fate gate.
- orthogonal adjacency; same pair once regardless shared-edge count.
- 1-cell special-bag overlap activation; distinct special bags can each apply.
- explicit atomic 3 first-tier combinations only.
- boss quality / shop control / chest quantity-random roles.
- ~3-minute elite opportunity and ~5-minute segment boss.
- Persistent Workbench with mouse, keyboard/gamepad and touch completion paths.
- visible mutually-exclusive whole-layout move mode.
- DEC-002 hybrid direction: every base item standalone-useful; 7–9 strong-spatial tuning range, 8 initial default.
- no new save system, rarity layer, deeper combo tiers, arbitrary polyomino regular items or deep set/curse system.

### Rollback

MVP-3 `main@11a81208ec9ad7ca9f4a044d3226e1be0ea25f76` is the Phase-B runtime rollback baseline. Each TDD task is independently committed and reviewed. Do not remove old compatibility state earlier than the task that proves its replacement; after T06, old owned-count effects must no longer be combat modifier authority.

## 9. Affected consumers

Primary implementation consumers that must remain regression-covered:

- `RunBuildState`
- `RunModifierSet`
- `PlayerController.apply_run_modifiers()`
- `SchoolRuntimeHost.apply_run_modifiers()` and four school runtimes
- `CombatResolver`
- `ShopController`
- `FateController`
- `StageFlowController`
- `MainController`
- `WaveSpawner` read-only API
- `StageBoss` read-only contract
- `RestFlowUI`
- main scene composition

## 10. Verification targets

Automated target set remains V01–V12 with the T01/T03/T07 additions above. Required release of each task is:

```text
focused RED observed for intended missing behavior
→ minimal GREEN
→ related prior-task regression
→ exact changed-file review
→ commit only explicit paths
```

Implementation PR gate remains:

- exact validation head identified;
- GUT/CI on that exact head successful;
- mergeable;
- unresolved review thread `0`;
- no validated P0/P1 or `USER_DECISION_REQUIRED` finding;
- actual changed files stay inside approved scope;
- merged-main readback + post-merge GUT required.

Human evidence remains separate:

- Windows mouse/keyboard/gamepad and responsive Workbench QA: required before claiming full MVP-4 human usability PASS.
- Android real-device/export QA: required for Android PASS; if route is unavailable, record `BLOCKED_UNVERIFIED` rather than inferring success.
- First-REST/player-experience thresholds in the content-balance doc remain hypotheses until observed.

## 11. Benchmark / industry revalidation

Fresh benchmark work already performed for DEC-002 remains implementation-relevant and no new evidence found a reason to reopen the approved A-direction.

Phase-B interpretation:

- Backpack Battles edit-friction lessons → preserve explicit bag/item editing separation and Undo/Redo support.
- Backpack Hero grouping → use weak build-aware weighting, not automatic recipes.
- DRG: Survivor tag vocabulary → keep tags shared across reward/shop/UI/hints.
- Sproggiwood asymmetry lesson → keep a few memorable asymmetric items/results; do not normalize every item into the same formula.
- Resogun pacing lesson → keep dense inventory/shop decisions in REST, not combat.

The benchmark document's `8 strong spatial` recommendation is interpreted as its initial authoring recommendation. Current product authority is `7–9`, with `8` the first default.

## 12. Adversarial review findings

### MUST_FIX — closed by this Phase-B record

1. **Plan phase-status drift**: older plan wording implied explicit `기획 완료` alone was enough for implementation readiness.
   - Fix: this record explicitly supersedes that status with Phase-B PASS requirement and records PASS.
2. **DEC-002 data encoding under-specified**: T01 had only footprint/tags and single legacy effect fields.
   - Fix: exact static multi-payload + `SpatialRuleDefinition` + central modifier validation chosen.
3. **Resolver hardcode risk**: strong-spatial content could have become item-ID branches.
   - Fix: generic bounded spatial-rule data contract chosen; relationship deliberately stays orthogonal-adjacency-only for YAGNI.
4. **Dual modifier authority risk**: legacy `effect_kind/effect_value` plus new payload could double-apply.
   - Fix: explicit single-authority fallback semantics and T01/T06 regression contract.
5. **Combo-result acquisition leakage risk**: random controllers could iterate all item definitions.
   - Fix: explicit base-acquisition list + combo-result list and RED coverage.
6. **Seed nondeterminism risk**: dictionary iteration could alter weighted draw order.
   - Fix: canonical candidate ordering before seeded RNG and T07 deterministic test.

### SHOULD_FIX / interpretation — closed without product change

- Benchmark `exactly 8` wording is not a core invariant; current Decision authority remains 7–9 with 8 initial default.
- Google Sheet remains stale but cannot be edited with current permission; continue as local deferred blocker.

### USER_DECISION_REQUIRED

`none`

### BLOCKED_UNVERIFIED

- actual Windows PowerShell/Codex/Godot local process state;
- actual local Godot AI 3.1.4 functionality/compatibility;
- HiGodot/Hera availability in the eventual local execution route;
- Windows human QA and Android device QA.

These are Phase-C/T12 runtime evidence items, not Phase-B planning blockers.

## 13. Implementation-ready contract

```yaml
implementation_ready:
  approved_scope: MVP-4 Backpack / Combination Basics T01-T12
  approval_reference:
    - user explicit 기획 완료 2026-08-11
    - DEC-2026-08-11-001
    - DEC-2026-08-11-002
    - approved L2 spec
  protected_items: Section 8 of this record + CURRENT_CONFIRMED_DECISIONS
  exact_baseline_sha: 11a81208ec9ad7ca9f4a044d3226e1be0ea25f76
  existing_solution_disposition: Section 4 PASS
  acceptance_criteria: L2 AC-01..AC-15 / no unmapped AC
  rollback: MVP-3 main@11a81208ec9ad7ca9f4a044d3226e1be0ea25f76 + per-task commits
  affected_consumers: Section 9
  test_plan: T01-T12 strict RED-GREEN + V01-V12 + Phase-B amendments
  applicable_human_or_player_evidence: Windows required; Android conditional route; player-experience formative targets not yet run
  godot_authoring_route: local Ninja Survival checkout -> fresh PowerShell/Codex execution identity -> Godot Engine 4.7.1 -> GUT 9.7.1; verify local Godot AI 3.1.4/HiGodot/Hera availability before use
```

All required fields are populated. No validated material planning blocker remains.

## 14. Final Phase-B decision

```yaml
phase_a: COMPLETE_BY_EXPLICIT_USER_DECLARATION
phase_b_final_planning_review: PASS
must_fix_open: 0
user_decision_required_open: 0
phase_c: AUTHORIZED
next_task: T01_SPATIAL_DATA_CONTRACTS_RED
production_code_written_during_phase_b: false
```

Phase C must still begin from a fresh execution identity and must not claim any T01 or MVP-4 implementation success until the focused RED is observed and subsequent GREEN evidence exists.