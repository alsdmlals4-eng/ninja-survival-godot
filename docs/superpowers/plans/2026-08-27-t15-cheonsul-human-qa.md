# T15 Cheonsul Human QA Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish direct human evidence for the merged Cheonsul release-near vertical slice before any remaining-school production begins.

**Architecture:** Preserve T14 runtime as the system under test. A Korean protocol separates participant answers from live/automated observations; shared-chassis code changes are allowed only after a directly observed failure and receive focused regression before the complete suite.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1 transient local/CI dependency, Markdown, Notion Production Handoff.

**Spec:** GitHub Issue #68 and `docs/qa/2026-08-27-t15-cheonsul-human-qa-protocol.md`.

## Global Constraints

- Base from `origin/main` `25e2bf3a5ecd026f56428e75f18389da2c430c40`; do not use old image/T12 branches as runtime evidence.
- Do not modify, rebase, close, merge, or absorb read-only PR #49.
- Do not add remaining-school content, raster assets, Boss-reward selection/placement UI, auto-commit behavior, or device/export claims.
- Do not stage local `.godot/` or transient `addons/gut/`; CI owns the same pinned GUT 9.7.1 bootstrap.
- Keep source/static, import/parse/smoke/GUT, live observation, Human Usability, Player Experience, and device evidence distinct.
- New GDScript begins with a Korean role comment; production code follows TDD.

---

### Task 1: Publish the Human QA protocol

**Files:**
- Create: `docs/qa/2026-08-27-t15-cheonsul-human-qa-protocol.md`

**Interfaces:**
- Consumes: T14 Cheonsul signals/text, `SchoolSelectionUI`, `RestFlowUI`, current Human QA criteria.
- Produces: fixed participant steps, questions, input-path requirements, pass/fail rules, and a result table.

- [x] **Step 1: Record the evidence boundary and out-of-scope Workbench behavior.**

State that direct person answers are mandatory for Human/Player claims and that the current read-only Boss-reward state is not a selection/placement defect.

- [x] **Step 2: Record the precise visible signals and three core input paths.**

Use actual current Korean strings: `천술류: 원소 반응을 준비하세요.`, `WET + SHOCK`, `Enter로 회수하세요.`, `작업대 — 다음 유파는 임시 선택입니다`.

- [x] **Step 3: Add participant questions, the result table, and the GOOD_DEPTH/BAD_FRICTION rubric.**

Require a direct answer after each relevant signal. A synthetic `InputEventScreenTouch` regression does not substitute for physical touch evidence.

- [x] **Step 4: Commit the protocol.**

```bash
git add docs/qa/2026-08-27-t15-cheonsul-human-qa-protocol.md
git commit -m "docs: add T15 Cheonsul Human QA protocol"
```

### Task 2: Recreate the automated baseline and live-session readiness

**Files:**
- Modify: none unless a tool/setup finding affects only documentation.

**Interfaces:**
- Consumes: `.github/workflows/gut.yml`, `project.godot`, current T14 scene/tests.
- Produces: exact fresh-main baseline receipt and explicit live-tool availability.

- [x] **Step 1: Run Godot import, editor parse, and five-second main-scene smoke.**

```powershell
& $godotConsole --headless --import --path .
& $godotConsole --headless --path . --editor --quit
& $godotConsole --headless --path . --quit-after 5
```

Expected: each command exits `0`; this does not establish Human or Player Experience evidence.

- [x] **Step 2: Reproduce the CI-pinned local GUT route without changing repository source.**

Read `.github/workflows/gut.yml` first. If `addons/gut` is absent, use only a temporary GUT `9.7.1` copy, rerun Godot import after the copy, and never stage `addons/gut`.

- [x] **Step 3: Run complete GUT and retain the exact result.**

```powershell
& $godotConsole --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Observed: `485/485` tests and `5301` assertions on unchanged `main`.

- [x] **Step 4: Establish the live editor boundary.**

Use `hera status`/`hera instances` only against a directly returned current-project editor. If no agent connection exists, record `LIVE_HERA_NOT_CONNECTED`; do not infer UI or human input from a different project/editor.

### Task 3: Run direct participant sessions

**Files:**
- Create: `docs/qa/records/2026-08-27-t15-cheonsul-human-qa-results.md`

**Interfaces:**
- Consumes: Task 1 protocol and a direct participant’s actual play/answers.
- Produces: criterion-level evidence, `PASS`/`FAIL`/`UNCLEAR`/`NOT_RUN`, and all input-path results.

- [ ] **Step 1: Run the natural-time 30-second Cheonsul read.**

Start `res://scenes/main/main_scene.tscn`, choose Cheonsul without pre-explaining the mechanics, and record the participant’s answer to the first protocol question.

- [ ] **Step 2: Continue the same real run through Core, Elite, Trace, Boss, and Workbench.**

Do not skip lifecycle time for tension judgment. Record the participant answer after the reaction signal, after Trace availability, and after the Workbench appears.

- [ ] **Step 3: Exercise mouse, keyboard/gamepad-focus, and physical touch paths.**

Use the protocol’s minimum outcome for each. If no physical touch hardware is available, record `TOUCH_NOT_RUN — physical touch hardware unavailable`; do not convert synthetic GUT coverage into a human result.

- [ ] **Step 4: Classify each participant report and decide the gate.**

Write every row in the result table. A `FAIL`, an unrooted `UNCLEAR`, or missing required human evidence keeps T15 closed and blocks T16.

### Task 4: Correct only validated shared-chassis findings

**Files:**
- Modify: exact source/UI/test files named by a direct Task 3 failure.
- Modify: `docs/qa/records/2026-08-27-t15-cheonsul-human-qa-results.md`

**Interfaces:**
- Consumes: a reproducible Task 3 finding and the affected current owner.
- Produces: a minimal, tested correction or a documented non-code follow-up.

- [ ] **Step 1: Trace the failing signal to its current owner before changing source.**

Use `superpowers:systematic-debugging`; document the observed symptom, exact reproduction, source owner, and one hypothesis. Do not change unrelated tuning or visual assets.

- [ ] **Step 2: Write a focused failing GUT regression for any deterministic code defect.**

Place the test beside the current owner: Cheonsul runtime, vertical-slice controller, MainController lifecycle integration, or RestFlowUI. Run it and record the real RED failure.

- [ ] **Step 3: Implement one minimal correction and rerun focused regression.**

Keep route/Fate/backpack authority in existing domain owners. Do not implement Boss-reward selection/placement or auto-commit as a QA shortcut.

- [ ] **Step 4: Re-run import, parse, smoke, full GUT, and the affected direct Human criterion.**

Only mark the criterion corrected when automated evidence and new direct participant evidence both exist.

### Task 5: Record evidence, review, and hand off the next gate

**Files:**
- Modify: `docs/ACTIVE_CONTEXT.md`
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Modify: `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`
- Modify: this plan
- Modify: Notion `06 · Production · Handoff`

**Interfaces:**
- Consumes: Tasks 1–4 exact evidence.
- Produces: one current status and a clean T16-open or T15-blocked decision.

- [ ] **Step 1: Perform five full adversarial passes.**

Re-attack identity/readability, tension/telegraph, Trace, Workbench boundary, input parity/Korean readability, and evidence-claim separation. Fix a validated finding before restarting the five-pass count.

- [ ] **Step 2: Update repository routers and traceability.**

State only evidence actually obtained. Keep missing physical touch, device/export, and unobserved human outcomes as `NOT_RUN`.

- [ ] **Step 3: Read back the Notion Production Handoff after its update.**

Record Issue #68/PR identity, exact repository revision, test evidence, human-session facts, live-tool limitation, remaining risks, and the T16 decision. Do not claim Notion success until fetch/readback returns added content.

- [ ] **Step 4: Run final review and prepare the fresh Issue #68 PR.**

Use `superpowers:requesting-code-review`, verify exact head, and create a PR only after its documentation and evidence accurately represent the finished gate. Do not merge without user authorization.

## Plan self-review

- Spec coverage: Task 1 defines every human criterion; Task 2 creates fresh-main technical context; Task 3 gathers direct human evidence; Task 4 limits correction scope; Task 5 preserves the decision and handoff.
- Placeholder scan: no undefined runtime owner, test command, success condition, or evidence class is used. Human answers remain intentionally unavailable until a person supplies them and are not fabricated.
- Type consistency: this plan introduces no production API. Existing `SchoolSelectionUI`, `CheonsulRuntime`, `CheonsulVerticalSliceController`, and `RestFlowUI` remain their current owners.
