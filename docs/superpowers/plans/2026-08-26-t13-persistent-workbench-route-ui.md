# T13 Persistent Workbench Route UI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a reusable Workbench REST view that renders provisional next-route and pending Fate choices without taking domain ownership.

**Architecture:** `RestFlowUI` receives plain snapshots from T08/T12 owners, renders standard `Button` controls, and emits route/Fate/commit intents. The existing caller must accept an intent, mutate a domain owner, then re-render a new snapshot. MainController is not migrated because its protected MVP-3 loop does not construct a T12 spatial REST transaction.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1, `.tscn` Control scene.

**Spec:** `docs/superpowers/specs/2026-08-26-t13-persistent-workbench-route-ui-design.md`

## Global Constraints

- Implement GitHub Issue #62 only; PR #49 remains read-only/superseded.
- UI renders snapshots and emits intents only; it must not call route, Fate, session, or commit owners.
- Show only `unvisited_school_ids`; reveal no HP/DPS/spawn/timing values.
- Keep legacy Result/Shop/Fate/Preview/Complete contracts working unchanged.
- Use normal Godot `Button` focus for mouse, keyboard/gamepad and touch; add no InputMap action.
- T14 runtime/encounter integration and Human/device claims remain out of scope.

---

### Task 1: Write the failing Workbench UI contracts

**Files:**
- Modify: `tests/integration/test_mvp3_rest_flow_ui.gd`

**Interfaces:**
- Produces the expected `show_workbench(route_snapshot, fate_candidate_ids, fate_definitions, pending_fate_id, readiness_failures)` method and two new signals.

- [ ] **Step 1: Add the missing scene/method/signal assertions**

```gdscript
assert_true(ui.has_node("Panel/Margin/Content/WorkbenchView/RouteCards"))
assert_true(ui.has_node("Panel/Margin/Content/WorkbenchView/FateCandidates"))
assert_true(ui.has_node("Panel/Margin/Content/WorkbenchView/CommitButton"))
assert_true(ui.has_method("show_workbench"))
assert_true(ui.has_signal("workbench_route_selected_requested"))
assert_true(ui.has_signal("workbench_commit_requested"))
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `& $godotExe --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_mvp3_rest_flow_ui.gd -gexit`

Expected: only Workbench contract absence fails.

- [ ] **Step 3: Add rendering, intent, and focus tests**

```gdscript
ui.show_workbench({"unvisited_school_ids": [&"cheonsul", &"guiin"], "provisional_school_id": &"guiin"}, candidates, fates, &"guardian_path", [&"buffer_not_empty"])
assert_eq(route_cards.get_child_count(), 2)
assert_true(route_cards.get_child(1).text.contains("임시 선택"))
assert_false(route_cards.get_child(0).text.contains("HP"))
route_cards.get_child(0).emit_signal("pressed")
assert_eq(emitted, [["route", &"cheonsul"]])
```

Assert that unresolved readiness disables commit, all dynamic buttons remain focusable, and presses emit no direct domain mutation.

- [ ] **Step 4: Run the focused test and verify RED, then commit RED**

Run the Step 2 command; expected failure is missing `show_workbench`. Commit with `test: define T13 Workbench route UI contract`.

### Task 2: Build snapshot-only Workbench rendering

**Files:**
- Modify: `scenes/ui/rest_flow_ui.tscn`
- Modify: `scripts/ui/rest_flow_ui.gd`
- Modify: `tests/integration/test_mvp3_rest_flow_ui.gd`

**Interfaces:**
- Consumes: plain route/Fate/readiness snapshots.
- Produces: standard Control buttons plus `workbench_route_selected_requested`, existing `fate_selected_requested`, and `workbench_commit_requested`.

- [ ] **Step 1: Add a hidden `WorkbenchView`**

Put a heading, instructional/status labels, `RouteCards`, `FateCandidates`, `CommitStatusLabel`, and `CommitButton` under the existing REST content container. Dynamic lists are Containers; legacy node paths remain unchanged.

- [ ] **Step 2: Add exact render entrypoint and signals**

```gdscript
signal workbench_route_selected_requested(school_id: StringName)
signal workbench_commit_requested

func show_workbench(route_snapshot: Dictionary, fate_candidate_ids: Array[StringName], fate_definitions: Dictionary, pending_fate_id: StringName, readiness_failures: Array[StringName]) -> void:
	_show_only(workbench_view)
	_render_workbench_routes(route_snapshot)
	_render_workbench_fates(fate_candidate_ids, fate_definitions, pending_fate_id)
	_render_workbench_commit(route_snapshot, pending_fate_id, readiness_failures)
```

Use one fixed local Korean copy table for each four-school identity/risk/gimmick/reward/tag. Render only known values from `unvisited_school_ids`, label the matching provisional choice `임시 선택`, and map known failure codes to human-readable unfinished work text.

- [ ] **Step 3: Preserve focus and intent-only behavior**

Free stale dynamic children before rebuilding. Bind only IDs to `pressed`; defer focus to the provisional route card, otherwise the first valid card. Disable commit if a route/Fate is missing or failures are non-empty, and emit no commit signal while disabled.

- [ ] **Step 4: Integrate lifecycle and run GREEN test**

Add `workbench_view` to `_all_views()` so every legacy view hides it. Run the Task 1 focused command; all legacy and new REST UI tests pass. Commit with `feat: add T13 Workbench route UI contract`.

### Task 3: Harden the UI boundary and verify

**Files:**
- Modify: `tests/integration/test_mvp3_rest_flow_ui.gd`

**Interfaces:**
- Produces fail-closed evidence for unknown IDs, stale cards, incomplete commit, and signal-only UI authority.

- [ ] **Step 1: Add adversarial RED tests**

```gdscript
ui.show_workbench({"unvisited_school_ids": [&"unknown"], "provisional_school_id": &"unknown"}, [], {}, &"", [])
assert_eq(route_cards.get_child_count(), 0)
assert_true(commit_button.disabled)

ui.show_workbench({"unvisited_school_ids": [&"cheonsul"], "provisional_school_id": &"cheonsul"}, candidates, fates, &"seal_path", [&"session_rebound"])
commit_button.emit_signal("pressed")
assert_eq(emitted, [])
```

Also re-render with a shorter route list and prove stale children disappear.

- [ ] **Step 2: Run focused RED and make the smallest fail-closed fixes**

Run the Task 1 command. Filter unknown schools, disable incomplete commit, and guard the commit callback. Do not add domain calls.

- [ ] **Step 3: Run focused GREEN and full deterministic gates**

Run:

```powershell
& $godotExe --headless --path . --import
& $godotExe --headless --path . --scene res://scenes/main/main_scene.tscn --quit-after 120
& $godotExe --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Expected: import/smoke exit zero; no `SCRIPT ERROR:` or `ERROR:`; all GUT tests pass. Commit test hardening with `test: harden T13 Workbench UI boundary`.

### Task 4: Complete review and delivery evidence

**Files:**
- Modify: `docs/ACTIVE_CONTEXT.md`
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Modify: `docs/superpowers/specs/2026-08-26-t13-persistent-workbench-route-ui-design.md`
- Modify: `docs/superpowers/plans/2026-08-26-t13-persistent-workbench-route-ui.md`

- [ ] **Step 1: Run five full-scope adversarial loops**

Re-attack legal-card filtering, hidden-tuning leakage, stale dynamic controls/focus, route/Fate/readiness gate, and MainController/T14 scope drift. Change only validated defects and run focused/full regression after every correction.

- [ ] **Step 2: Inspect exact scope**

Run `git diff --check origin/main...HEAD` and `git diff --name-only origin/main...HEAD`. Expect only UI/tests/docs surfaces.

- [ ] **Step 3: Create and validate the exact-head PR**

Push `codex/t13-workbench-route-ui-62`, create an Issue #62-linked PR, and wait for exact-head manifest/import/main-smoke/full-GUT success. Do not direct-push `main` or mutate PR #49.

- [ ] **Step 4: After authorized merge, verify merged main and handoff**

Fresh-read the merged default branch in a detached test worktree, repeat import/main smoke/full GUT, then update Production Handoff and confirm Notion readback. Keep Human/device evidence `NOT_RUN` unless directly executed.
