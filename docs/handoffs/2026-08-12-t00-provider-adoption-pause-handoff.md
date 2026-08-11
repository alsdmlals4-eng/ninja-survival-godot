# T00 Provider Adoption Pause Handoff — 2026-08-12

> Resume package for the current Phase-C operational prerequisite. This document does not replace `docs/ACTIVE_CONTEXT.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, or the approved MVP-4 design/plan owners. Always fetch current GitHub `main` and open PRs before acting.

## Purpose

The user paused implementation work to perform a collision-safe handoff. This package preserves the exact T00 provider-adoption blocker, the CI fidelity repair applied in the handoff-closure PR, the completed proposal-only Base promotion, and the safe resume order. **Do not begin MVP-4 T01 from this handoff until T00 is source-faithfully revalidated and integrated.**

## Observed baseline

```yaml
source_project: alsdmlals4-eng/ninja-survival-godot
state_observed_at_main: b6c4b8a082a120f65e833b133684b899f00e05ba
handoff_closure_branch: ops/handoff-t00-ci-fidelity-20260812
handoff_closure_pr: 18
handoff_closure_head: e1d7faef5f306d87c14d3074c44f0a303dfe0501
handoff_closure_main: b6c4b8a082a120f65e833b133684b899f00e05ba
handoff_closure_ci: PASS_RUN_31514428025_BOOTSTRAP_ROUTE
base_proposal_id: BCP-2026-021-ci-source-fidelity-for-vendored-dependencies
base_proposal_pr: 291
base_proposal_merge_main_observed: d7dedbc6548294ac6109c22548e40adb0d6d273a
base_proposal_status: SUBMITTED
base_implementation_authority: NOT_GRANTED_IN_THIS_STAGE
t00_pr: 17
t00_branch: ops/godot471-provider-uid-adoption
t00_head_observed: bcd6d566de991fa1fe84aebf186e5dd654d6d274
t00_state: BLOCKED_PENDING_SOURCE_FAITHFUL_REVALIDATION
t01_branch: impl/mvp4-t01-spatial-data-contracts
t01_phase_b_base: 225d68e7545062e3c2bc720562263fe6a67131bd
t01_state: PAUSED_NOT_STARTED
mvp4_production_code: NOT_STARTED
mvp4_runtime_evidence: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_android_device_qa: NOT_RUN
```

## T00 package being preserved

PR #17 is the separate provider/executor adoption package. Its observed scope is:

- HiGodot 3.1.4 addon;
- GUT 9.7.1 addon;
- Hera Agent Godot 1.0.0 addon;
- `project.godot` plugin/autoload activation metadata;
- 24 project-owned Godot 4.7.1 `.gd.uid` sidecars.

The package had fresh local Godot 4.7.1 import/parse evidence and a remote GUT workflow that ended green. That green result is **not sufficient merge evidence** because the workflow modified the checked-out source shape before validation.

## Exact blocker and root cause

### Symptom

During PR #17's GitHub Actions import, Godot emitted many diagnostics of the form:

```text
UID duplicate detected between res://addons/gut/gut/... and res://addons/gut/...
```

The workflow nevertheless continued through smoke and GUT tests and concluded success.

### Root cause

The historical CI assumed GUT was absent and always performed:

```text
cp -R Gut-9.7.1/addons/gut addons/gut
```

T00 makes `addons/gut/**` project-owned/vendored. On Linux, copying the downloaded `gut` directory into an existing `addons/gut` directory produced a second tree at `addons/gut/gut/**`. The validation run therefore did not represent the actual intended T00 repository state.

### Failed or misleading approach

`workflow conclusion = success` was initially tempting as merge evidence. It must not be treated as PASS when the workflow preparation step creates a duplicate source tree and the engine reports duplicate resource identity.

### Project resolution applied by PR #18

`.github/workflows/gut.yml` now behaves as follows:

1. if `addons/gut/plugin.cfg` exists, CI verifies GUT 9.7.1 and reuses the vendored tree;
2. the vendored route rejects `addons/gut/gut`;
3. if GUT is absent, CI bootstraps pinned GUT 9.7.1 for current-main compatibility;
4. a partial pre-existing `addons/gut` is rejected rather than overlaid;
5. Godot import output is captured and `UID duplicate detected` makes the job fail.

PR #18 exact validation run `31514428025` passed Godot 4.7.1 installation, GUT preparation, project import, main-scene smoke and full GUT regression with 250/250 tests on the non-vendored/bootstrap route. The vendored route still requires exact current T00 validation before PR #17 can merge.

## Resume-first read order

1. `AGENTS.md`
2. latest `docs/ACTIVE_CONTEXT.md`
3. this handoff
4. latest `docs/handoffs/2026-08-11-mvp4-phase-c-t01-codex-handoff.md`
5. current GitHub `main`
6. current PR #17 metadata, changed files, diff, reviews/threads, and current validation runs
7. approved MVP-4 Decisions/L2/Phase-B DoR/traceability/implementation plan before any T01 product edit

Historical SHA values in this handoff are locators, not permission to skip fresh reads.

## Next executable sequence

```text
fetch latest project main
→ inspect current PR #17 head/base/diff
→ confirm handoff-closure CI source-fidelity guard exists on current main
→ refresh/reconstruct only the T00 delta as required by current main
→ run exact current PR validation
→ require vendored-GUT route, no addons/gut/gut and no UID duplicate diagnostics
→ adversarial review of T00 scope, provider versions, project.godot activation, UID sidecars and runtime/export risks
→ merge T00 only if all current gates pass
→ read back new project main and post-merge CI
→ refresh the T01 implementation baseline/branch from the provider-integrated approved main according to current package policy
→ only then execute focused T01 RED → GREEN
```

Do not fast-forward or rewrite the old pinned T01 branch merely to make this handoff look current. After T00 integration, choose the current approved package-refresh route based on fresh main and the active Phase-C contract.

## Stop / block conditions

- PR #17 current validation still creates or reports duplicate GUT/UID state.
- T00 changed files exceed the provider/UID adoption scope without an approved reason.
- current main has product/code/canon drift that materially conflicts with the T00 delta.
- HiGodot/GUT/Hera version identity differs from the approved T00 package without a new validated decision.
- required runtime/editor verification is unavailable and the claim depends on it: report `BLOCKED_UNVERIFIED`, not PASS.
- any attempt is made to begin T01 production code before T00 integration/readback.

## Learning closure

### LRN-NS-2026-08-12-001 — CI source fidelity for vendored dependencies

```yaml
classification: SPLIT
project_application: APPLIED_AND_MERGED_PR_18
project_owner: .github/workflows/gut.yml
project_verification: PASS_RUN_31514428025_BOOTSTRAP_ROUTE
base_candidate: PROMOTED_PROPOSAL_ONLY
base_proposal_id: BCP-2026-021-ci-source-fidelity-for-vendored-dependencies
base_proposal_pr: 291
base_proposal_merged: true
base_proposal_status: SUBMITTED
base_main_observed_after_merge: d7dedbc6548294ac6109c22548e40adb0d6d273a
base_implementation_authority: NOT_GRANTED_IN_THIS_STAGE
closure: CLOSED_FOR_HANDOFF_STAGE
```

Project-specific part: detect/reuse vendored GUT 9.7.1 and fail Godot import on duplicate UID diagnostics.

Reusable common principle: dependency preparation must not silently overlay a downloaded dependency into a path that the checked-out revision already owns; validation should fail when preparation creates duplicate source/resource identity that makes the tested tree differ materially from the intended repository state.

The common principle is now stored in Base as proposal-only BCP `BCP-2026-021-ci-source-fidelity-for-vendored-dependencies`. This storage merge does not authorize active Base implementation.

### LRN-NS-2026-08-12-002 — T00 remains a prerequisite package

```yaml
classification: PROJECT_ONLY
project_application: APPLIED
project_owner: docs/ACTIVE_CONTEXT.md + this handoff
verification: RESUME_ROUTE_RE_READ
base_proposal: N/A
closure: CLOSED
```

T00 provider adoption stays separate from MVP-4 T01. T01 does not inherit a provider-integrated baseline until T00 is current-main reviewed, validated, merged, and read back.

### LRN-NS-2026-08-12-003 — blocker evidence belongs in the existing handoff owner

```yaml
classification: NO_PROMOTION
project_application: APPLIED
project_owner: docs/ACTIVE_CONTEXT.md + this handoff
base_existing_solution: maintaining-project-context-and-handoff
reason: existing Base owner already covers exact blocker/status/resume preservation; no new broad skill is warranted
closure: CLOSED
```

## Recent applicable troubleshooting lesson

```yaml
lesson_id: NS-T00-CI-001
symptom: green CI while Godot import reports duplicate UIDs under addons/gut/gut and addons/gut
impact: false confidence in T00 merge readiness; tested source shape differs from intended repository state
root_cause: CI unconditionally overlays downloaded GUT into a now-vendored addons/gut path
failed_or_misleading_approach: treating workflow success alone as sufficient evidence
resolution: vendored-aware dependency preparation plus duplicate-UID import failure gate
verification: PR #18 bootstrap-route exact CI PASS; vendored route exact T00 CI remains required before PR #17 merge
fast_recovery_steps:
  - inspect checked-out dependency path before installing anything
  - distinguish vendored/repository-owned from CI-only bootstrap dependency
  - reject nested duplicate directory
  - capture engine import diagnostics
  - validate the exact current PR revision
prevention_or_action_item: keep source-shape-aware GUT preparation and duplicate UID gate in project CI
owner_source: .github/workflows/gut.yml
knowledge_state: VALIDATED_PROJECT_PATTERN_WITH_T00_VENDORED_ROUTE_PENDING
```

## Base promotion result and boundary

```yaml
base_proposal:
  id: BCP-2026-021-ci-source-fidelity-for-vendored-dependencies
  proposal_pr: https://github.com/alsdmlals4-eng/Base/pull/291
  merged_to_base_main: true
  base_main_observed_after_merge: d7dedbc6548294ac6109c22548e40adb0d6d273a
  proposal_status: SUBMITTED
  proposal_storage_merge_authority: GRANTED_BY_HANDOFF_INSTRUCTION_V5
  base_implementation_authority: NOT_GRANTED_IN_THIS_STAGE
  implementation_status: NOT_STARTED_IN_THIS_STAGE
  implementation_boundary: SEPARATE_FOLLOWUP_STAGE
  existing_solution_verdict: ABSORB
  next_action: separate Base implementation stage only if later authorized
```

The proposal-only Base PR changed only `[수정제안서]/**`. Active Base Skills/Docs/Templates/Tools/Tests/Workflows were not modified in this stage.

## Continuation checkpoint

```yaml
continuation_checkpoint:
  state_observed_at_main: b6c4b8a082a120f65e833b133684b899f00e05ba
  work_merge_main_sha: b6c4b8a082a120f65e833b133684b899f00e05ba
  closure_pr: 18
  closure_head_sha: e1d7faef5f306d87c14d3074c44f0a303dfe0501
  base_proposal_pr: 291
  base_proposal_main_observed: d7dedbc6548294ac6109c22548e40adb0d6d273a
  self_merge_sha_required_in_file: false
  resume_rule: FETCH_LATEST_MAIN_BEFORE_USE
```

This final Base-proposal sync is itself a continuation-state update. Its own future merge SHA is intentionally not written back through another recursive PR. GitHub history plus latest `main` readback remains authoritative for that self-merge identity.
