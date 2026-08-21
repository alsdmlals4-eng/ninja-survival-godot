# DEC-014~025 Canon Rebaseline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconcile the GitHub active canon/execution router with approved Notion DEC-014~025 without changing production gameplay code or discarding the verified MVP-0~3 rollback baseline.

**Architecture:** Preserve the 2026-08-11 MVP-4 spatial domain plan for T01-T07. Add a dated product-canon mirror and migration traceability packet, replace mutable entry/router docs with concise current state, and block executable T08+ gameplay planning at DEC-026 rather than inventing attack/pattern content.

**Tech Stack:** Markdown, GitHub pull requests, Notion project pages/data sources, existing Godot 4.7.1 + GUT 9.7.1 CI for regression evidence.

**Spec:** `docs/canon/2026-08-21-dec014-025-product-canon.md`

## Global Constraints

- No `scripts/`, `scenes/`, `data/`, `assets/`, `project.godot`, addon, workflow or gameplay-test behavior changes in this package.
- Existing MVP-0~3 runtime remains the rollback baseline.
- PR #17 remains closed/unmerged historical evidence; do not reopen or merge it.
- Historical `impl/mvp4-t01-spatial-data-contracts` is not the active implementation branch.
- T01-T07 low-level spatial/backpack direction is preserved.
- Old T08-T12 are non-executable after this rebaseline.
- DEC-026 is unresolved and blocks detailed encounter/pattern implementation planning.
- Notion is human-facing product/visual/flow authority; GitHub is structured implementation/traceability/runtime authority.
- No new paid service or plan is required.

---

### Task 1: Mirror the approved product canon

**Files:**
- Create: `docs/canon/2026-08-21-dec014-025-product-canon.md`

**Interfaces:**
- Consumes: Notion DEC-014~025.
- Produces: implementation-facing current product behavior summary.

- [x] **Step 1: Record repository and Notion source snapshots.**
- [x] **Step 2: Record DEC-014~025 with supersession semantics.**
- [x] **Step 3: Preserve existing MVP-4 spatial contracts explicitly.**
- [x] **Step 4: Record PR #17/old T01 branch as historical, not executable.**
- [x] **Step 5: Set DEC-026 as next product gate without inventing content.**

### Task 2: Recalculate traceability

**Files:**
- Create: `docs/traceability/2026-08-21-dec014-025-migration-traceability.md`

**Interfaces:**
- Consumes: Task 1 canon + old 2026-08-11 MVP-4 traceability/plan.
- Produces: reuse/supersede map and new MIG-01..MIG-08 requirements.

- [x] **Step 1: Classify old T01-T12 as REUSE / RECALCULATE / SUPERSEDED.**
- [x] **Step 2: Define school-circuit, trace gate, reward-lane, route-commit and final-binding requirements.**
- [x] **Step 3: Separate automated, runtime and human evidence.**
- [x] **Step 4: Block detailed T08+ executable planning on DEC-026.**

### Task 3: Refresh mutable GitHub routers

**Files:**
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Modify: `docs/ACTIVE_CONTEXT.md`
- Modify: `README.md`
- Modify: `MVP_ROADMAP.md`
- Modify: `docs/SYSTEM_MAP.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Modify: `docs/BASE_RULES_VERSION.md`
- Modify: `AGENTS.md`

**Interfaces:**
- Consumes: Tasks 1-2.
- Produces: one current read path for humans and agents.

- [ ] **Step 1: Replace stale product-decision ledger with a current router that preserves old spatial canon and points to DEC-014~025 mirror.**
- [ ] **Step 2: Replace stale PR #17/T01 resume state with `CANON_REBASELINE / DEC026_NEXT_GATE`.**
- [ ] **Step 3: Remove active wording that treats three segments or 20 minutes as complete current Run structure.**
- [ ] **Step 4: Mark old T08-T12 as historical/non-executable while preserving T01-T07.**
- [ ] **Step 5: Update Base observation to current Base main and keep full Base sync as NOT_RUN unless actually performed.**
- [ ] **Step 6: Update AGENTS current-scope wording and human-evidence rule without altering the byte-exact legacy delivery-contract file.**

### Task 4: Synchronize Notion execution surfaces

**Notion surfaces:**
- Project Home properties/status.
- `01 · 프로젝트 전체 작업계획` backing task database.
- `06 · Production · Handoff`.
- relevant Core System records where stale structured metadata would misroute future retrieval.

- [ ] **Step 1: After GitHub PR merge, update project `Repo Main SHA`, `Last Synced`, and Sync State from actual readback.**
- [ ] **Step 2: Create/refresh a NINJA_SURVIVAL work item for DEC-026 and the subsequent migration package.**
- [ ] **Step 3: Update Production Handoff with merged canon paths, evidence ceiling, and next gate.**
- [ ] **Step 4: Do not report Notion/GitHub sync complete until both sides are read back.**

### Task 5: PR verification, merge and post-merge review

- [ ] **Step 1: Confirm branch diff contains documentation/Notion-sync planning only.**
- [ ] **Step 2: Run PR CI; require existing Godot import, smoke and full GUT regression to remain green.**
- [ ] **Step 3: Run at least five full adversarial review loops over canon freshness, authority order, old-reference removal, traceability, and regression evidence.**
- [ ] **Step 4: Merge only with no open blocking finding.**
- [ ] **Step 5: Read back merged main and post-merge CI.**
- [ ] **Step 6: Synchronize Notion from the merged SHA, then read back Notion and GitHub once more.**

## Completion criteria

This rebaseline is complete only when:

- DEC-014~025 is available from GitHub implementation canon,
- no active router tells an executor to revive PR #17 or the old pinned T01 branch,
- current entry docs no longer present the three-segment Run as the latest product target,
- T01-T07 reuse and T08+ recalculation boundaries are explicit,
- DEC-026 is the only next material product gate,
- PR/post-merge existing CI remains green,
- Notion project home/handoff/work plan references the merged GitHub state,
- at least five post-change adversarial loops finish cleanly.
