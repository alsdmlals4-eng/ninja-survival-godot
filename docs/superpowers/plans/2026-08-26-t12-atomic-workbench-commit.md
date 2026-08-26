# T12 원자적 Workbench 확정 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Workbench 백팩 스냅샷·보류 Fate·임시 다음 학교를 모두 성공하거나 모두 실패하게 확정한다.

**Architecture:** `FateController`는 Fate를 보류 상태로 분리한다. 새 `RestCommitCoordinator`가 REST 시작 시 소유자 묶음을 고정하고, 모든 조건을 읽기 전용으로 검증한 뒤 기존 `RunBuildState`와 `RunRouteState`의 확정 API를 한 번씩만 사용한다.

**Tech Stack:** Godot 4.x, GDScript, GUT 9.7.1, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-08-26-t12-atomic-workbench-commit-design.md`

## Global Constraints

- PR #49는 읽기 전용이며 수정·병합·리베이스하지 않는다.
- `MainController`, UI/Scene, 전투/조우, 에셋, 저장 시스템은 변경하지 않는다.
- 새 GDScript 첫 줄에는 한국어 역할 주석을 둔다.
- production 코드는 해당 RED GUT가 확인된 뒤에만 작성한다.
- import/smoke/GUT와 Human/Player/device evidence를 혼동하지 않는다.

---

### Task 1: 보류 Fate 계약

**Files:**
- Modify: `scripts/core/fate_controller.gd`
- Modify: `tests/unit/test_fate_controller.gd`

**Interfaces:**
- Produces: `choose_pending(fate_id: StringName) -> bool`, `has_pending_fate() -> bool`, `pending_fate_id() -> StringName`, and coordinator-only commit validation/application methods.

- [ ] **Step 1: Write the failing test**

```gdscript
fate.begin_rest()
var fate_id: StringName = fate.candidate_ids[0]
assert_true(fate.choose_pending(fate_id))
assert_false(state.has_fate(fate_id))
assert_eq(fate.pending_fate_id(), fate_id)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `godot --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_fate_controller.gd -gexit`

Expected: a behavior assertion fails because pending selection is absent or mutates `RunBuildState` immediately.

- [ ] **Step 3: Write minimal implementation**

```gdscript
func choose_pending(fate_id: StringName) -> bool:
	if selected_this_rest != &"" or not candidate_ids.has(fate_id) or _build_state == null:
		return false
	selected_this_rest = fate_id
	return true
```

Keep the actual `RunBuildState.select_fate()` call private to the atomic boundary and retain defensive build-state binding validation.

- [ ] **Step 4: Run focused Fate tests and verify GREEN**

- [ ] **Step 5: Commit**

```text
test: add pending Fate selection contract
```

### Task 2: Atomic coordinator success and failure boundary

**Files:**
- Create: `scripts/core/rest_commit_coordinator.gd`
- Create: `tests/unit/test_rest_commit_coordinator.gd`
- Create: `tests/unit/test_rest_commit_coordinator_adversarial.gd`

**Interfaces:**
- Consumes: `RestBackpackSession.current_resolution()`, `commit_failures(...)`, `FateController` pending API, `RunBuildState.set_committed_backpack_modifiers(...)`, `RunRouteState.commit_provisional_next_school()`.
- Produces: `configure(...)`, `begin_rest(session) -> bool`, `commit_failures(...) -> Array[StringName]`, `commit(...) -> bool`, `committed_backpack_state()`.

- [ ] **Step 1: Write failing success/failure tests**

```gdscript
assert_true(coordinator.begin_rest(session))
assert_true(coordinator.commit())
assert_true(build_state.has_fate(pending_fate_id))
assert_eq(route.active_school_id(), &"cheonsul")
assert_false(coordinator.commit())
```

Also take value snapshots before each invalid tuple and assert identical snapshots after a failed `commit()`.

- [ ] **Step 2: Run coordinator tests to verify RED**

Expected: missing coordinator resource/API assertion fails, not a parser failure.

- [ ] **Step 3: Write minimal coordinator**

Use one configured owner tuple, require `begin_rest`, aggregate existing session failure reasons, validate pending Fate and provisional route before any mutation, then copy the final session state/modifiers, commit pending Fate, and activate the provisional route exactly once.

- [ ] **Step 4: Run focused coordinator tests and verify GREEN**

- [ ] **Step 5: Commit**

```text
feat: add atomic Workbench commit coordinator
```

### Task 3: Lifetime, binding, reentrancy adversarial contract

**Files:**
- Create: `tests/unit/test_rest_commit_coordinator_binding_adversarial.gd`
- Create: `tests/unit/test_rest_commit_coordinator_configure_adversarial.gd`
- Create: `tests/unit/test_rest_commit_coordinator_lifecycle_adversarial.gd`
- Create: `tests/unit/test_rest_commit_coordinator_reentrancy_adversarial.gd`
- Create: `tests/unit/test_rest_commit_coordinator_clean_reattack.gd`

**Interfaces:**
- Consumes: Task 2 coordinator and Task 1 pending Fate API.
- Produces: Regression protection for owner identity, illegal rebinding, repeated calls, and no-mutation failures.

- [ ] **Step 1: Write one failing owner-replacement test**

```gdscript
assert_true(coordinator.begin_rest(original_session))
coordinator.configure(alternate_state, alternate_build, alternate_route, alternate_fate)
assert_true(coordinator.commit())
assert_eq(original_route.active_school_id(), &"cheonsul")
assert_eq(alternate_route.active_school_id(), &"")
```

- [ ] **Step 2: Run the test to verify RED**

Expected: active `configure()` can replace the tuple or has no guard.

- [ ] **Step 3: Add the smallest lifetime guard**

`configure()` must reject/ignore calls while a session is active; all public snapshots are defensive copies; a completed coordinator cannot commit twice.

- [ ] **Step 4: Run all T12-focused tests and verify GREEN**

- [ ] **Step 5: Commit**

```text
test: protect atomic Workbench commit lifetime
```

### Task 4: Exact-head verification and evidence

**Files:**
- Modify: `docs/ACTIVE_CONTEXT.md` only after merge authorization and factual readback.
- Modify: Notion Production Handoff only after merge authorization and factual readback.

- [ ] **Step 1: Run `git diff --check` and all T12-focused GUT tests**
- [ ] **Step 2: Run Godot import and main-scene smoke**
- [ ] **Step 3: Run full GUT suite**
- [ ] **Step 4: Perform five full approved-scope adversarial review loops**
- [ ] **Step 5: Push a new PR for Issue #60 and require its exact-head CI success**
- [ ] **Step 6: Merge only after user authorization; then re-read new `main` and Production Handoff**
