# MVP-4 Phase C — T01 Codex Handoff

```yaml
handoff_id: CODEX-MVP4-T01-2026-08-11
mode: ON_DEMAND_CODEX_HANDOFF
status: READY_FOR_LOCAL_EXECUTION
repository: alsdmlals4-eng/ninja-survival-godot
base_branch: main
base_sha: 225d68e7545062e3c2bc720562263fe6a67131bd
allowed_package_branch: impl/mvp4-t01-spatial-data-contracts
remote_branch_created: true
phase_b: PASS
phase_b_record: docs/planning/2026-08-11-mvp4-phase-b-definition-of-ready.md
package: T01_SPATIAL_DATA_CONTRACTS_AND_MVP4_CATALOG
production_scope: GODOT_RUNTIME_DATA_AND_TEST_FILES_ONLY
codex_create_or_switch_branch: FORBIDDEN
codex_create_or_update_pr: FORBIDDEN
codex_merge: FORBIDDEN
force_push: FORBIDDEN
amend: FORBIDDEN
independent_commits: REQUIRED
godot_engine_target: 4.7.1
gut_target: 9.7.1
godot_ai_user_reported_local_version: 3.1.4
```

## 1. Handoff contract

> 이 명세는 현재까지의 기획 의도와 예상 상태를 설명한다. 실제 구현 상태는 반드시 현재 GitHub 저장소, 로컬 프로젝트 파일 및 Godot 프로젝트를 직접 조사하여 검증할 것. 명세와 실제 구현이 충돌하면 임의로 덮어쓰지 말고 원인을 분석한 뒤 가장 안전한 개선안을 선택할 것.

The project has passed Phase B. This package is **only T01**. Do not continue to T02 in the same Codex execution block.

## 2. Required read order

Codex must read before editing:

1. `AGENTS.md`
2. `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`
3. `docs/BASE_RULES_VERSION.md`
4. `docs/DOCUMENTATION_MAP.md`
5. `docs/CURRENT_CONFIRMED_DECISIONS.md`
6. `docs/ACTIVE_CONTEXT.md`
7. `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
8. `docs/planning/2026-08-11-mvp4-content-balance-v1.md`
9. `docs/planning/2026-08-11-mvp4-content-data-contract.md`
10. `docs/planning/2026-08-11-mvp4-phase-b-definition-of-ready.md`
11. `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md`
12. `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination.md`
13. current T01 files/tests and any current implementation drift on the allowed branch

The old plan is amended by the Phase-B record for T01/T03/T07 data/determinism details and phase semantics.

## 3. Fresh execution identity — mandatory before edit

Run from Windows PowerShell **before launching Codex**. The human/launcher may create/switch the local checkout; Codex itself must remain on the already-selected allowed branch.

```powershell
$Repo = 'C:\Users\user\Documents\GitHub\Ninza\ninja-survival-godot'
$Remote = 'https://github.com/alsdmlals4-eng/ninja-survival-godot.git'
$Branch = 'impl/mvp4-t01-spatial-data-contracts'
$ExpectedBase = '225d68e7545062e3c2bc720562263fe6a67131bd'

if (-not (Test-Path $Repo)) {
    git clone $Remote $Repo
}

Set-Location $Repo
git fetch origin --prune

if ((git status --porcelain).Length -ne 0) {
    throw 'Working tree is not clean. Preserve user changes; do not reset or clean.'
}

$LocalBranches = git branch --format='%(refname:short)'
if ($LocalBranches -contains $Branch) {
    git switch $Branch
    git merge --ff-only "origin/$Branch"
} else {
    git switch --track "origin/$Branch"
}

$Head = git rev-parse HEAD
if ($Head -ne $ExpectedBase) {
    throw "Unexpected package baseline: $Head"
}

git status --short --branch
```

Then verify the local tool identity. Do not confuse Godot AI with Godot Engine.

```powershell
codex.cmd --version
# Discover/verify the actual Godot Engine executable available locally and confirm it is 4.7.1.
# Confirm the project opens from $Repo and GUT 9.7.1 discovery route is available or can be installed by the approved project workflow.
# User-reported Godot AI version: 3.1.4. Treat as informational until the local plugin/tool itself reports that version.
```

If the branch baseline is not the expected SHA, the working tree is dirty, or Godot 4.7.1 cannot be verified, **do not guess or reset**. Report the exact observed state.

## 4. Required Codex invocation

From the already-selected package branch:

```powershell
codex.cmd -a never -s workspace-write
```

Use this prompt as the task body:

```text
@Superpowers Use this repository's spec-first workflow and active v4.5 r2 delivery contract.
Do not edit files immediately.
First read AGENTS.md, PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md, docs/BASE_RULES_VERSION.md, docs/DOCUMENTATION_MAP.md, docs/CURRENT_CONFIRMED_DECISIONS.md, docs/ACTIVE_CONTEXT.md, project-local Base rules, current Issue/Goal, and relevant files.
Confirm that Phase B Definition of Ready has passed before entering Phase C production BUILD.
Then summarize the goal, player experience, implementation scope, excluded scope, likely changed files, risks, completion criteria, and test checklist.
Proceed only within the confirmed scope.
At the end, run Compound Review and report mistakes, lessons, prevention rules, and Base-promotion candidates.

PACKAGE: MVP-4 T01 Spatial Data Contracts and MVP4Catalog only.
BASE SHA: 225d68e7545062e3c2bc720562263fe6a67131bd.
ALLOWED BRANCH: impl/mvp4-t01-spatial-data-contracts. Do not create or switch branches. Push only this branch. Do not create/update/merge a PR.

Before editing, verify the current branch, clean tree, actual repository files, Godot Engine version, GUT route, and the Phase-B readiness record. User reports local Godot AI 3.1.4; record what is actually observable, but do not treat it as the Godot Engine version and do not change package scope because of it.

Read the Phase-B technical amendment in docs/planning/2026-08-11-mvp4-phase-b-definition-of-ready.md and the validated data contract in docs/planning/2026-08-11-mvp4-content-data-contract.md. Those later technical contracts supersede older T01 technical placeholders where they conflict, without changing product rules or T01→T12 order.

STRICT TDD:
1. Write focused T01 failing GUT tests first.
2. Run them and confirm failure is the expected missing-contract/catalog behavior, not syntax/environment failure.
3. Implement the minimum T01 production/data code.
4. Run focused GREEN.
5. Run test_script_contracts.gd and existing MVP-3 data/build-state regressions relevant to preserving old item values.
6. Run full GUT if the approved local route is available.
7. Inspect exact diff and commit only approved T01 paths.
8. Push the allowed package branch only.
9. Stop after T01 and report evidence; do not begin T02.

T01 ALLOWED MODIFY:
- scripts/data/item_definition.gd
- scripts/data/run_modifier_set.gd
- tests/unit/test_script_contracts.gd

T01 ALLOWED CREATE:
- scripts/data/spatial_rule_definition.gd
- scripts/data/bag_definition.gd
- scripts/data/item_instance.gd
- scripts/data/bag_instance.gd
- scripts/data/combination_definition.gd
- scripts/data/mvp4_catalog.gd
- tests/unit/test_mvp4_catalog.gd

READ-ONLY REGRESSION REFERENCES:
- scripts/data/mvp3_catalog.gd
- scripts/core/run_build_state.gd
- tests/unit/test_run_build_state.gd
- project.godot

FORBIDDEN IN THIS PACKAGE:
- any backpack resolver/state/session implementation
- ShopController/MainController/StageFlow/UI/Scene changes
- project.godot changes
- save/autoload/input-map changes
- addons/.godot staging
- workflow changes
- item-id hardcoding for future spatial resolution
- new rarity/combo tier/combat system
- destructive git reset/clean, force push, amend, git add . or git add -A

REQUIRED T01 CONTRACT:
- existing ItemDefinition legacy id/display_name/base_price/tags/effect_kind/effect_value/school_payload behavior remains compatible;
- add footprint_size and footprint(rotation_quarters) for rectangular items;
- add static_modifier_payload: Dictionary[StringName, float];
- add spatial_rules: Array[SpatialRuleDefinition];
- RunModifierSet owns the supported modifier field list and add_delta()/validation helper;
- static_modifier_payload is authoritative when non-empty; legacy effect_kind/effect_value adapts only when static payload is empty; never double-apply;
- existing school_emblem selected-school school_payload remains conditional and preserved;
- SpatialRuleDefinition is bounded to approved orthogonal-neighbor semantics with required_neighbor_tags, required_neighbor_definition_ids, ONCE_IF_ANY/PER_DISTINCT_NEIGHBOR, max_matches, modifier_payload; no general relationship DSL;
- BagDefinition supports cells, 90-degree footprint normalization, optional one-tag auxiliary effect;
- ItemInstance/BagInstance are RefCounted value-like instances with stable integer instance_id, definition_id, origin, rotation_quarters and independent copy_value();
- CombinationDefinition contains the approved source/result identity and hint text fields needed by later T05;
- MVP4Catalog resolves 19 base items, 3 combo results, 5 purchasable bags, one starting 4x3 bag and 3 combinations;
- MVP4Catalog exposes explicit base_acquisition_item_ids() and combination_result_item_ids(); combo results are lookup-visible but base-acquisition-ineligible;
- validate all static/spatial modifier keys against RunModifierSet supported fields;
- preserve existing MVP-3 eight-item effect values exactly for first migration pass.

REQUIRED RED EVIDENCE:
- unique/resolvable 19 base item IDs + 3 combo-result IDs;
- 5 purchasable bags + starting 4x3 bag;
- katana non-square rotation vertical↔horizontal;
- L/T bag rotations normalize to non-negative local coordinates;
- multi-axis payload exact values for at least fire_style, greater_summoning_circle, forbidden_talisman and all 3 combo results;
- unsupported modifier field causes catalog validation failure;
- legacy adapter regression for all existing MVP-3 eight items;
- combo-result IDs exist in all-item lookup but are absent from base acquisition IDs;
- every combination source/result resolves;
- every spatial-rule modifier key is supported.

Do not claim T01 complete until the focused RED was actually observed, GREEN is actual, regression results are actual, exact changed files are listed, and the pushed branch HEAD is reported.
```

## 5. Expected T01 interfaces

These are the reviewed minimum contracts; implementation may improve internal naming only if tests and later plan consumers remain unambiguous.

```gdscript
# item_definition.gd additions
var footprint_size: Vector2i = Vector2i.ONE
var static_modifier_payload: Dictionary[StringName, float] = {}
var spatial_rules: Array[SpatialRuleDefinition] = []
@export var adjacency_tags: Array[StringName] = []
@export var combination_tags: Array[StringName] = []
func footprint(rotation_quarters: int) -> Array[Vector2i]
```

```gdscript
# run_modifier_set.gd additions
const SUPPORTED_FIELDS: Array[StringName] = [...]
static func is_supported_field(field_name: StringName) -> bool
func add_delta(field_name: StringName, amount: float) -> bool
```

```gdscript
# spatial_rule_definition.gd
extends Resource
class_name SpatialRuleDefinition
enum Aggregation { ONCE_IF_ANY, PER_DISTINCT_NEIGHBOR }
var required_neighbor_tags: Array[StringName] = []
var required_neighbor_definition_ids: Array[StringName] = []
var aggregation: Aggregation = Aggregation.ONCE_IF_ANY
var max_matches: int = 1
var modifier_payload: Dictionary[StringName, float] = {}
```

```gdscript
# bag_definition.gd
extends Resource
class_name BagDefinition
@export var id: StringName = &""
@export var display_name: String = ""
@export var base_price: int = 0
@export var cells: Array[Vector2i] = []
@export var affected_item_tag: StringName = &""
@export var auxiliary_effect_kind: StringName = &""
@export var auxiliary_effect_value: float = 0.0
func footprint(rotation_quarters: int) -> Array[Vector2i]
```

`ItemInstance` and `BagInstance` contain `instance_id`, `definition_id`, `origin`, `rotation_quarters`, and `copy_value()` returning an independent same-type instance.

## 6. Catalog content source

Use exact first-pass values from:

`docs/planning/2026-08-11-mvp4-content-balance-v1.md`

Do not invent new balance values in Codex. Values are `RECOMMENDED_DEFAULT`, not final balance proof.

Important product interpretation:

- product range: strong-spatial `7–9`;
- first catalog default: `8` strong-spatial items;
- all 19 base items standalone-useful;
- 3 combo results are not directly acquirable;
- 5 purchasable bags are 4 normal + 1 special;
- no rarity system.

## 7. T01 completion evidence returned to GPT

Codex must report:

```yaml
execution_identity:
  local_project_path:
  branch:
  base_sha_before_work:
  codex_version:
  godot_engine_version:
  gut_version_or_route:
  godot_ai_observed_version:
red:
  command:
  expected_failure_observed:
  failure_reason:
green:
  focused_command:
  result:
regression:
  commands: []
  result:
changed_files: []
commits: []
pushed_head_sha:
unverified_items: []
compound_review:
  mistakes_or_near_misses: []
  lessons: []
  prevention_rules: []
  base_promotion_candidates: []
```

Do not convert an unavailable local tool, Android device, or human QA route into PASS.

## 8. GPT post-Codex gate

After Codex pushes T01, GPT must:

1. re-read current `main` and all open/draft PRs;
2. inspect the exact allowed package branch HEAD and compare against `main@225d68e7...` or newer legitimate main;
3. verify only approved T01 files changed;
4. verify RED/GREEN/regression claims against actual evidence and remote CI where available;
5. run adversarial `attack → validate-critique` on the exact diff;
6. require regression tests before any valid production fix;
7. create/update the PR itself only after package validation;
8. merge only on exact-head required checks + mergeable + unresolved threads 0 + no P0/P1/user-decision finding;
9. perform merged-main readback and post-merge GUT;
10. only then prepare T02 package from the new main.

T01 success does not authorize skipping the independent review checkpoint pattern or claiming MVP-4 completion.