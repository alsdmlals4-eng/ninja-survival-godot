# Ninja Survival Base Adaptation Contract Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adopt the current Base work-order, evidence, reuse, and safety practices through one Ninja Survival-native operating contract without creating a second game canon or installing the full Base adapter system.

**Architecture:** Keep product meaning in the existing Decision/Canon/GDD owners and implementation truth in the Godot repository. Add one thin project-local contract that maps Base's five phases to those existing owners, then update the Base-observation ledger and documentation router to point to it. The full generated `PROJECT_BASE_ADAPTER` onboarding remains explicitly uninstalled because this project has neither its required committed legacy policy source nor a project Skill Registry baseline.

**Tech Stack:** Markdown documentation, Git/GitHub protected-branch workflow, Base `check_project_operating_contract.py` read-only validation.

**Spec:** `AGENTS.md`, `docs/BASE_RULES_VERSION.md`, `docs/DOCUMENTATION_MAP.md`, `docs/ACTIVE_CONTEXT.md`, and the user-approved 2026-09-01 recommendation: **project-native thin Base adapter**.

## Global Constraints

- Base current remote `main` observed at `19355b7ef065a21d0f2b685c7d9be64a4a3970f8`; project canon remains authoritative on conflicts.
- Preserve the existing authority order: user instruction → `AGENTS.md` → current decisions/canon → `ACTIVE_CONTEXT.md` → actual Godot code/data/scenes/tests → adopted Base patterns.
- Do not add a second GDD, second runtime-state owner, project Skill Registry, generated Base dashboard, Notion/Sheets owner, paid service, auto-merge policy, or runtime gameplay change.
- Keep the full Base `skills/PROJECT_BASE_ADAPTER.json` onboarding as `NOT_INSTALLED`; do not claim its validator passes.
- Do not modify, rebase, merge, or absorb PR #135 or historical PR #49. Preserve unknown Godot-generated files; do not delete files in this scope.
- Work in `codex/base-adaptation-contract-136`, created from exact `origin/main` `9855f9a5fa2e4297e3171a1b1903d3517719ad93`.
- Completion evidence is documentation/static/readback only. Godot runtime, Human Usability, Player Experience, and device/export remain `NOT_RUN`.

---

### Task 1: Create the thin project-native operating contract

**Files:**
- Create: `docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md`
- Test: repository text/static checks against the created contract

**Interfaces:**
- Consumes: `AGENTS.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, dated Canon, `docs/ACTIVE_CONTEXT.md`, `docs/DOCUMENTATION_MAP.md`, actual `scripts/`, `scenes/`, `data/`, `tests/`, and current Base owners when materially relevant.
- Produces: the sole project-local procedural owner for Base-derived work ordering, reuse disposition, evidence classification, approval boundaries, cleanup safety, and Base-promotion routing.

- [x] **Step 1: Write the contract's non-owning authority boundary**

Create an opening section declaring that this file is a navigation and execution contract only. It must name the existing owners for product meaning, mutable state, runtime implementation, human-facing GDD, visual assets, and historical migration material. It must state that no Base rule silently replaces approved Ninja Survival canon.

- [x] **Step 2: Map the five Base phases to current project owners**

Add a five-row mapping table with these exact phase purposes:

1. `PHASE_1_PLANNING_CO_DESIGN` — user-visible product meaning and approved decisions.
2. `PHASE_2_PREPRODUCTION_REVIEW` — feasibility, reuse, consumer coverage, Definition of Ready, and approval.
3. `PHASE_3_INGAME_INPUT_PREPARATION` — only consumer-bound assets, UI copy, data, VFX, localization, and deterministic test inputs.
4. `PHASE_4_GODOT_IMPLEMENTATION_AND_MACHINE_CLOSEOUT` — isolated implementation, exact-head checks, PR CI, merge, and post-merge readback.
5. `PHASE_5_USER_VERTICAL_SLICE_VALIDATION` — distinct actual-user evidence; never inferred from machine checks.

For every phase, identify the existing Ninja Survival owner paths and the required result state. Preserve the project’s current Human/Player/device `NOT_RUN` boundaries.

- [x] **Step 3: Define work-item and approval semantics without a new tracking database**

Specify that an existing plan, implementation contract, review, or PR description carries these fields when applicable:

```text
outcome / why_now / authority_owner / actual_consumer /
protected_scope / explicit_non_scope / reuse_disposition /
dependencies / acceptance_criteria / validation / evidence_ceiling /
rollback / project_only_lessons / base_promotion_candidates
```

Define `BLOCKS`, `INFORMS`, `USES_OUTPUT`, and `SHARES_RESOURCE`. Define that a previous same-scope approval permits technical continuation, while product meaning, public UX, cost, authority, destructive removal, and release claims require a new user decision.

- [x] **Step 4: Define evidence, lifecycle, cleanup, and autonomy boundaries**

Record E0 contract, E1 static, E2 automated test, E3 runtime, E4 visual, E5 play, and E6 human-playtest as separate evidence classes. Define scoped legacy hygiene states: `ACTIVE_OWNER`, `COMPATIBILITY`, `ARCHIVE`, `OBSOLETE_CANDIDATE`, `UNKNOWN_UNVERIFIED`. Require reference/consumer-zero and Git-recoverable readback before removal. Set the current operating ceiling to isolated-branch A2; reject automatic merge, background execution, and authority expansion.

- [x] **Step 5: Run a focused static contract check**

Run:

```powershell
rg -n 'PHASE_1_PLANNING_CO_DESIGN|PHASE_2_PREPRODUCTION_REVIEW|PHASE_3_INGAME_INPUT_PREPARATION|PHASE_4_GODOT_IMPLEMENTATION_AND_MACHINE_CLOSEOUT|PHASE_5_USER_VERTICAL_SLICE_VALIDATION|PROJECT_BASE_ADAPTER.*NOT_INSTALLED|ACTIVE_OWNER|UNKNOWN_UNVERIFIED|E0|E6' docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md
```

Expected: every required phase, the full-Base-adapter boundary, cleanup classification, and evidence endpoints appear exactly in the project-local contract.

### Task 2: Route existing project documents to the contract without copying product facts

**Files:**
- Modify: `docs/BASE_RULES_VERSION.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Modify: `docs/ACTIVE_CONTEXT.md`
- Test: stale-reference, single-owner, and link/path checks

**Interfaces:**
- Consumes: the Task 1 contract and Base fresh-read findings.
- Produces: one current Base-adoption ledger entry, one discoverable route in the documentation map, and one concise mutable-state pointer.

- [x] **Step 1: Update `BASE_RULES_VERSION.md` with the current Base observation**

Append a dated observation for Base `19355b7ef065a21d0f2b685c7d9be64a4a3970f8`. Record `ADAPT` for fresh-read/reuse-first/phase mapping/evidence boundaries/cleanup/PR readback and `DEFER` for full Base adapter onboarding, generated dashboard, Skill Registry, auto-merge, continuous operations, and Base promotion. Explicitly state that the earlier historical observations remain provenance rather than a current Base pin.

- [x] **Step 2: Add the contract to `DOCUMENTATION_MAP.md`**

Add `operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md` after the project authority/read path and before implementation mutation. Describe it as the sole procedural Base adaptation owner, not a product/canon owner. Keep the existing Reader GDD, Master GDD, Canon, Active Context, asset manifest, and implementation owners unchanged.

- [x] **Step 3: Add a concise state pointer to `ACTIVE_CONTEXT.md`**

Add only a pointer and status fields for the new operating contract: current Base observation SHA, adaptation state `ADAPT_ACTIVE`, full Base adapter state `NOT_INSTALLED_SEPARATE_ONBOARDING_REQUIRED`, and the new contract path. Do not rewrite product implementation claims or elevate any Human/Player/device evidence.

- [x] **Step 4: Run static ownership and reference checks**

Run:

```powershell
rg -n 'NINJA_SURVIVAL_PROJECT_WORK_CONTRACT|19355b7ef065a21d0f2b685c7d9be64a4a3970f8|ADAPT_ACTIVE|NOT_INSTALLED_SEPARATE_ONBOARDING_REQUIRED' docs/BASE_RULES_VERSION.md docs/DOCUMENTATION_MAP.md docs/ACTIVE_CONTEXT.md
rg -n 'full_base_adapter.*PASS|full_base_adapter_state: PASS|human_usability: PASS|player_experience: PASS|device_export_android: PASS|device_android_export: PASS' docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md docs/BASE_RULES_VERSION.md docs/DOCUMENTATION_MAP.md docs/ACTIVE_CONTEXT.md
```

Expected: the contract is discoverable from all three routers; the second command produces no overclaimed full-adapter or human-evidence status value.

### Task 3: Adversarial review, exact readback, and protected delivery

**Files:**
- Create: `docs/reviews/2026-09-01-base-adaptation-adversarial-review.md`
- Modify: `docs/superpowers/plans/2026-09-01-base-adaptation-contract.md`
- Test: diff, contract validation evidence, Markdown route readback, Git safety checks

**Interfaces:**
- Consumes: Tasks 1–2 complete document set and the read-only Base validator result.
- Produces: five validated whole-scope review loops, an explicit `NOT_INSTALLED` validator ceiling, and one reviewable documentation-only commit/PR.

- [x] **Step 1: Record five whole-scope adversarial loops**

Attack and validate these exact failure classes in separate loops: duplicate canon owner, accidental product-rule overwrite, accidental Base-adapter PASS claim, PR #135/historical PR absorption, unsupported cleanup/deletion, evidence-class inflation, and Base-generated-dashboard scope creep. Correct only validated findings, then record the clean exit.

- [x] **Step 2: Re-run the Base validator as an explicit negative boundary check**

Run:

```powershell
python C:/Users/user/Documents/GitHub/Base/tools/check_project_operating_contract.py --project-root . --base-repository C:/Users/user/Documents/GitHub/Base --check
```

Expected: nonzero exit naming the absent `skills/PROJECT_BASE_ADAPTER.json`. Record it as `EXPECTED_NOT_INSTALLED`, not a product or documentation failure and not a PASS.

- [x] **Step 3: Run final static/readback checks**

Run:

```powershell
git diff --check
git diff -- docs/BASE_RULES_VERSION.md docs/DOCUMENTATION_MAP.md docs/ACTIVE_CONTEXT.md docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md docs/reviews/2026-09-01-base-adaptation-adversarial-review.md docs/superpowers/plans/2026-09-01-base-adaptation-contract.md
git status --short
```

Expected: only the six approved documentation paths are changed; no PR #135 code, assets, generated Godot files, or historical sources appear.

- [ ] **Step 4: Commit and push the documentation-only package**

Run:

```powershell
git add docs/BASE_RULES_VERSION.md docs/DOCUMENTATION_MAP.md docs/ACTIVE_CONTEXT.md docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md docs/reviews/2026-09-01-base-adaptation-adversarial-review.md docs/superpowers/plans/2026-09-01-base-adaptation-contract.md
git commit -m "docs: adapt Base work contract for Ninja Survival"
git push -u origin codex/base-adaptation-contract-136
```

Expected: one isolated documentation commit is visible on GitHub. Open a new PR only after re-reading its exact head, status checks, changed files, and the unchanged PR #135 boundary.

## Plan Self-Review

- Spec coverage: Task 1 owns the thin contract; Task 2 connects the three existing navigation/state documents; Task 3 verifies the exact scope and delivers it safely.
- Placeholder scan: no deferred implementation detail is required for this documentation-only package. Full Base adapter onboarding is explicitly an excluded future package, not an unfinished step.
- Ownership consistency: product decisions remain in existing Decision/Canon owners; the new contract owns only process; `ACTIVE_CONTEXT.md` holds only the resume pointer and state.

## Execution Handoff

This plan is approved for inline execution in the current isolated worktree. Collaboration delegation is unavailable for this task, so execution proceeds task-by-task with the verification checkpoints above.
