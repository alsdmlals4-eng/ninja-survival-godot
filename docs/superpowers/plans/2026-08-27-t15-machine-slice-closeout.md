# T15 Cheonsul Machine Slice Closeout Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship the approved school-function-help vertical-slice increment as a safely merged, machine-verified Cheonsul entry path while deferring Human QA by the user's current execution contract.

**Architecture:** Reuse `SchoolSelectionUI` as the sole start-selection owner. Its four existing selection buttons remain the only `school_selected` emitters; four adjacent help buttons feed one modal text surface and preserve pointer, touch, keyboard, and gamepad-focus boundaries. Documentation records the Work Production Input Packet, machine evidence, and the distinct Human/Player evidence ceiling.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1, GitHub Actions, Notion Production Handoff.

**Spec:** User-provided `Work → Codex 최소 전환 버티컬 슬라이스 자동 실행` contract; GitHub Issue #68; `docs/qa/2026-08-27-t15-cheonsul-human-qa-protocol.md`.

## Global Constraints

- Current-task branch only: `codex/t15-cheonsul-human-qa-68`; PR #69 is the only mutable open PR. PR #49 remains read-only.
- Base: `d16f8255bd9f98259aba5a3beafe72ccbeaa4b0a`; project completed-main baseline: `25e2bf3a5ecd026f56428e75f18389da2c430c40`.
- No new raster asset, audio binary, economy rule, Boss-reward selection, placement UI, Fate/route auto-commit, T16 school content, direct-main push, force push, ruleset bypass, or paid service.
- Every behavior claim requires exact-head evidence. Human Usability, Player Experience, physical-touch experience, device/export, and live-Hera evidence stay explicitly separate from machine evidence.
- The current user contract sets `HUMAN_QA_DEFERRED_BY_CURRENT_USER`; do not fabricate participant answers or treat automation as Human PASS.

---

### Task 1: Publish the Work Production Input Packet

**Files:**
- Create: `docs/handoffs/2026-08-27-t15-cheonsul-machine-slice-input-packet.md`
- Modify: `docs/qa/records/2026-08-27-t15-cheonsul-human-qa-results.md`

**Interfaces:**
- Consumes: current-main T14 route, actual four school runtime mechanics, approved Visual Bible, and T15 protocol.
- Produces: a bounded `READY_FOR_SINGLE_CODEX_WINDOW` packet for existing help implementation and `HUMAN_QA_DEFERRED_BY_CURRENT_USER` evidence status.

- [x] **Step 1: Record the actual player outcome and explicit exclusions.**

Set the player outcome to reading one selected school's current mechanics before committing a starting-school selection. Exclude new assets/audio, school behavior changes, and all Workbench completion behavior.

- [x] **Step 2: Record runtime text, input, data, and validation contracts.**

Require `SchoolSelectionUI` to remain the selection authority, help data to mirror current runtime only, modal state to block selection, and `닫기`/`ui_cancel` to restore opener focus. Name focused and complete GUT, import, parse, smoke, CI, and attempted Hera routes.

- [x] **Step 3: Preserve the Human evidence boundary.**

Replace the old direct-session blocker only with `HUMAN_QA_DEFERRED_BY_CURRENT_USER`; keep every participant and physical-touch result `NOT_RUN`.

### Task 2: Reconcile exact PR head and machine evidence

**Files:**
- Modify: no source unless a verified failure is found.

**Interfaces:**
- Consumes: PR #69 exact head and `gut` GitHub check.
- Produces: exact-head evidence that does not borrow a different SHA's result.

- [x] **Step 1: Verify PR identity, base/head, mergeability, checks, review threads, and protected-scope drift.**

Require base `25e2bf3a5ecd026f56428e75f18389da2c430c40`, exact reviewed head, one completed successful `gut` check, no unresolved review decision, and no changed path outside the six scope files plus the Work Packet/closeout documentation.

- [x] **Step 2: Re-run current-head machine gates.**

Run Godot 4.7.1 import, editor parse, five-second main-scene smoke, focused `test_school_selection_ui.gd`, and complete GUT. If Hera does not expose this exact project editor, record `LIVE_HERA_NOT_CONNECTED` without substituting another project session.

### Task 3: Perform five full adversarial review loops

**Files:**
- Modify: only a validated finding's owner and its focused regression.

**Interfaces:**
- Consumes: complete diff, source authority, runtime mechanics, tests, PR, and Notion records.
- Produces: five documented whole-state re-attacks with no uncorrected blocker.

- [x] **Step 1: Attack scope and authority drift.**

Confirm no selection signal, route, Fate, combat modifier, asset, or PR #49 authority moved into help UI.

- [x] **Step 2: Attack false mechanic claims.**

Compare every help sentence with the four current runtime owners and reject any future pattern, auto-commit, or non-runtime claim.

- [x] **Step 3: Attack all input paths.**

Check help open, direct selection-button activation behind modal, number selection, `ui_cancel`, close button, and opener focus restoration.

- [x] **Step 4: Attack evidence and documentation claims.**

Verify counts, SHAs, PR status, CI result, Notion handoff, and Human/Player/Hera ceilings independently.

- [x] **Step 5: Recalculate remaining machine-executable work.**

Correct any validated finding and restart this Task's five-loop review count; otherwise record clean exit.

### Task 4: Squash merge and post-merge evidence

**Files:**
- Modify after merge: `docs/ACTIVE_CONTEXT.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`, and the T15 result record only if post-merge facts require it.

**Interfaces:**
- Consumes: a clean exact PR head.
- Produces: one squash-merged main commit and exact post-merge verification receipt.

- [x] **Step 1: Reconcile latest main immediately before merge.**

Fetch `origin/main`; if it differs from the reviewed base, rebase is forbidden and a fresh current-main PR is required. Otherwise use repository-supported squash merge without admin bypass.

- [x] **Step 2: Read new main and run post-merge gates.**

Run Godot import, editor parse, five-second main smoke, and full GUT from new main. Record actual counts and exit status.

- [x] **Step 3: Update GitHub and Notion current records and read them back.**

Update Issue #68, Production Handoff, repository routers, and the result record with merge SHA, actual evidence, Human deferral, and no image/audio change. Fetch the Notion Handoff after writing it.

### Task 5: Emit the user validation packet

**Files:**
- Modify: `docs/handoffs/2026-08-27-t15-cheonsul-machine-slice-input-packet.md`

**Interfaces:**
- Consumes: new-main identity and post-merge evidence.
- Produces: one `USER_VERTICAL_SLICE_VALIDATION_PACKET` that tells the user exactly how to open the main scene and observe help without claiming Human PASS.

- [x] **Step 1: Record launch route and expected result.**

Use `res://scenes/main/main_scene.tscn`; open any school help, close it, then choose one school. The expected result is an explanation-only modal followed by one deliberate school-selection transition.

- [x] **Step 2: Record known limits and feedback questions.**

List Human/Player/physical touch/device/export and live-Hera as `NOT_RUN` or deferred exactly as observed, then ask the user to note comprehension, Korean readability, and any input leak.

## Plan self-review

- Spec coverage: Task 1 closes Work inputs; Task 2 establishes exact-head evidence; Task 3 executes the required five full re-attacks; Task 4 safely integrates current-task work; Task 5 supplies the requested runnable validation handoff.
- Placeholder scan: no undefined product owner, success condition, input, implementation path, or evidence class is used.
- Type consistency: the plan preserves the existing `SchoolSelectionUI.school_selected(school_id: StringName)` interface and names only existing runtime/test owners.

## Machine closeout review record

- Scope/authority loop: clean. The diff keeps `SchoolSelectionUI` as the only selection emitter and does not touch route, Fate, combat modifiers, assets, or PR #49.
- Runtime-claim loop: clean. Each help sentence was compared with `BongmaRuntime`, `CheonsulRuntime`, `GuiinRuntime`, and `HeukyeongRuntime`; no future encounter/pattern or auto-commit claim remains.
- Input loop: clean after the already completed RED → GREEN correction. Focused tests cover help open, direct button and numeric selection blocking, cancel/close, and focus return.
- Evidence loop: clean. PR head `349ddf1f51f5f61897b73df1ddde19eb4ab82ef1` had a successful exact-head GitHub `gut` check; local import, editor parse, five-second main smoke, focused GUT `8/8` / `38`, and CI-scope full GUT `488/488` / `5321` passed. `LIVE_HERA_NOT_CONNECTED`, Human, Player Experience, touch, device/export remain unpromoted.
- Remaining-work loop: no machine-executable feature defect remains before merge. The post-merge receipt, repository/Notion readback, and user validation packet remain Tasks 4–5, so this is not a completion claim.
