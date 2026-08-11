# T00 CI Fidelity Handoff Closure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Pause T00/T01 implementation, preserve the exact T00 blocker in the project handoff, and make CI validate the repository's actual GUT source shape instead of creating a nested duplicate copy.

**Architecture:** Keep product/provider implementation untouched. Change only the project CI dependency-preparation boundary plus the existing continuation owner and one focused handoff package. The CI supports both current `main` (GUT absent, pinned CI bootstrap) and the T00 provider branch (GUT vendored, verify and reuse) while making Godot duplicate-UID import diagnostics a hard failure.

**Tech Stack:** GitHub Actions, Bash, Godot 4.7.1, GUT 9.7.1, Markdown.

## Global Constraints

- T00 PR #17 remains a separate provider-adoption package and is not merged by this handoff-closure plan unless separately revalidated after this guard lands.
- MVP-4 T01 production code remains NOT_STARTED during this plan.
- Do not alter T01 package files or its intentionally pinned Phase-B branch.
- Preserve current `main` compatibility: when `addons/gut/plugin.cfg` is absent, CI installs pinned GUT 9.7.1 exactly once.
- When GUT is vendored, CI must reuse it and reject `addons/gut/gut`.
- Project import must fail if `UID duplicate detected` is emitted.

---

### Task 1: Make GUT preparation source-shape aware

**Files:**
- Modify: `.github/workflows/gut.yml`

**Interfaces:**
- Consumes: repository checkout at the PR validation revision.
- Produces: exactly one usable `addons/gut` tree for later import and test steps.

- [ ] **Step 1:** Replace unconditional GUT overlay with `vendored -> verify/reuse`, `absent -> pinned bootstrap` branching.
- [ ] **Step 2:** Add `test ! -d addons/gut/gut` for the vendored route and reject a partial pre-existing `addons/gut` on the bootstrap route.
- [ ] **Step 3:** Capture Godot import output and fail on `UID duplicate detected`.
- [ ] **Step 4:** Run the PR workflow and require Install Godot, Prepare GUT, Import, smoke, and GUT steps to pass on the exact PR validation revision.

### Task 2: Persist the pause/recovery contract

**Files:**
- Modify: `docs/ACTIVE_CONTEXT.md`
- Create: `docs/handoffs/2026-08-12-t00-provider-adoption-pause-handoff.md`

**Interfaces:**
- Consumes: project `main`, PR #17 metadata, its known CI evidence, and the T01 handoff.
- Produces: a resume route that prevents T01 from starting before source-faithful T00 validation.

- [ ] **Step 1:** Record T00 as the current Phase-C prerequisite and PR #17 as BLOCKED_PENDING_SOURCE_FAITHFUL_REVALIDATION.
- [ ] **Step 2:** Record the root cause: unconditional CI overlay of vendored GUT created `addons/gut/gut/**` and duplicate UID diagnostics while the workflow still reported green.
- [ ] **Step 3:** Record the resume order: latest main -> PR #17 current head/diff -> source-faithful CI -> adversarial review -> T00 merge/readback -> refresh T01 baseline -> focused T01 RED.
- [ ] **Step 4:** Keep runtime/human/device QA as NOT_RUN and never promote readiness evidence to implementation PASS.

### Task 3: Review, merge, and preserve learning

**Files:**
- Review all changed files from Tasks 1-2.

**Interfaces:**
- Consumes: exact PR head/check state.
- Produces: merged project learning evidence suitable for a proposal-only Base BCP.

- [ ] **Step 1:** Verify changed-file scope and PR body traceability.
- [ ] **Step 2:** Require exact current validation to pass; treat queued/in-progress as incomplete evidence, not PASS.
- [ ] **Step 3:** Merge the handoff-closure PR and read back new project `main`.
- [ ] **Step 4:** Classify learning: CI source-fidelity principle = SPLIT/Base candidate; T00-before-T01 sequencing = PROJECT_ONLY; generic blocker-preserving handoff = REUSE existing Base owner.
- [ ] **Step 5:** Only after project application is merged, submit the reusable common principle through Base `[수정제안서]/**` using the then-current Base proposal schema and collision state.
