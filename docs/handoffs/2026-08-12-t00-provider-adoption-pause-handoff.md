# T00 Provider Adoption Pause Handoff — 2026-08-12

> Resume package for the current Phase-C operational prerequisite. This document does not replace `docs/ACTIVE_CONTEXT.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, or the approved MVP-4 design/plan owners. Always fetch current GitHub `main` and open PRs before acting.

## Purpose

The user paused implementation work to perform a collision-safe handoff. This package preserves the exact T00 provider-adoption blocker, the CI fidelity repair applied in the handoff-closure PR, and the safe resume order. **Do not begin MVP-4 T01 from this handoff until T00 is source-faithfully revalidated and integrated.**

## Observed baseline

```yaml
source_project: alsdmlals4-eng/ninja-survival-godot
state_observed_at_main: b4c2c91380df6b9835c58952edae10b8c558da55
handoff_closure_branch: ops/handoff-t00-ci-fidelity-20260812
handoff_closure_pr: PENDING_AT_DOCUMENT_CREATION
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

Current `main` CI historically assumed GUT was absent and always performed:

```text
cp -R Gut-9.7.1/addons/gut addons/gut
```

T00 makes `addons/gut/**` project-owned/vendored. On Linux, copying the downloaded `gut` directory into an existing `addons/gut` directory produced a second tree at `addons/gut/gut/**`. The validation run therefore did not represent the actual intended T00 repository state.

### Failed or misleading approach

`workflow conclusion = success` was initially tempting as merge evidence. It must not be treated as PASS when the workflow preparation step creates a duplicate source tree and the engine reports duplicate resource identity.

### Project resolution applied by this handoff closure

`.github/workflows/gut.yml` is changed so that:

1. if `addons/gut/plugin.cfg` exists, CI verifies GUT 9.7.1 and reuses the vendored tree;
2. the vendored route rejects `addons/gut/gut`;
3. if GUT is absent, CI still bootstraps pinned GUT 9.7.1 for current-main compatibility;
4. a partial pre-existing `addons/gut` is rejected rather than overlaid;
5. Godot import output is captured and `UID duplicate detected` makes the job fail.

This is a project validation/workflow improvement, not a T00 provider-content change.

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
→ require no addons/gut/gut and no UID duplicate diagnostics
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
project_application: APPLIED_IN_HANDOFF_CLOSURE_PR
project_owner: .github/workflows/gut.yml
project_verification: EXACT_PR_CI_REQUIRED
base_candidate: YES_AFTER_PROJECT_MERGE
knowledge_state: VALIDATED_PATTERN_AFTER_EXACT_PR_CI
```

Project-specific part: detect/reuse vendored GUT 9.7.1 and fail Godot import on duplicate UID diagnostics.

Reusable common principle: dependency preparation must not silently overlay a downloaded dependency into a path that the checked-out revision already owns; validation should fail when preparation creates duplicate source/resource identity that makes the tested tree differ materially from the intended repository state.

### LRN-NS-2026-08-12-002 — T00 remains a prerequisite package

```yaml
classification: PROJECT_ONLY
project_application: APPLIED
project_owner: docs/ACTIVE_CONTEXT.md + this handoff
verification: RESUME_ROUTE_RE_READ
base_proposal: N/A
```

T00 provider adoption stays separate from MVP-4 T01. T01 does not inherit a provider-integrated baseline until T00 is current-main reviewed, validated, merged, and read back.

### LRN-NS-2026-08-12-003 — blocker evidence belongs in the existing handoff owner

```yaml
classification: NO_PROMOTION
project_application: APPLIED
project_owner: docs/ACTIVE_CONTEXT.md + this handoff
base_existing_solution: maintaining-project-context-and-handoff
reason: existing Base owner already covers exact blocker/status/resume preservation; no new broad skill is warranted
```

## Recent applicable troubleshooting lesson

```yaml
lesson_id: NS-T00-CI-001
symptom: green CI while Godot import reports duplicate UIDs under addons/gut/gut and addons/gut
impact: false confidence in T00 merge readiness; tested source shape differs from intended repository state
root_cause: CI unconditionally overlays downloaded GUT into a now-vendored addons/gut path
failed_or_misleading_approach: treating workflow success alone as sufficient evidence
resolution: vendored-aware dependency preparation plus duplicate-UID import failure gate
verification: exact current handoff-closure PR CI, then exact current T00 PR CI after refresh
fast_recovery_steps:
  - inspect checked-out dependency path before installing anything
  - distinguish vendored/repository-owned from CI-only bootstrap dependency
  - reject nested duplicate directory
  - capture engine import diagnostics
  - validate the exact current PR revision
prevention_or_action_item: keep source-shape-aware GUT preparation and duplicate UID gate in project CI
owner_source: .github/workflows/gut.yml
knowledge_state: VALIDATED_PATTERN_AFTER_EXACT_PR_CI
```

## Base promotion boundary

After the project handoff-closure PR is merged and read back, the reusable part of `LRN-NS-2026-08-12-001` may be submitted to `alsdmlals4-eng/Base` **only under `[수정제안서]/**`**, using the then-current proposal schema and a fresh collision check against Base main and concurrent proposal PRs. Base active Skills/Docs/Templates/Tools/Tests/Workflows are read-only in this stage.

## Continuation checkpoint

```yaml
continuation_checkpoint:
  state_observed_at_main: b4c2c91380df6b9835c58952edae10b8c558da55
  work_merge_main_sha: PENDING_HANDOFF_CLOSURE_PR
  closure_pr: PENDING_AT_DOCUMENT_CREATION
  closure_head_sha: PENDING_EXACT_VALIDATION
  self_merge_sha_required_in_file: false
  resume_rule: FETCH_LATEST_MAIN_BEFORE_USE
```

The handoff-closure PR's own merge SHA does not need a recursive writeback PR. GitHub history plus the latest `main` readback is authoritative for that final self-merge identity.
