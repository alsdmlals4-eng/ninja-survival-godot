# T12 Atomic Workbench + Fate + Next-Route Commit Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement DEC-025 so one Workbench transaction validates and commits the finalized backpack snapshot, one pending Fate, and one provisional unvisited school all-or-none.

**Architecture:** Preserve existing domain owners. `RestBackpackSession` continues to own pending spatial edits and commit-readiness, `FateController` becomes candidate/pending-selection authority instead of immediately mutating `RunBuildState`, and `RunRouteState` continues to own provisional/active route facts. A focused `RestCommitCoordinator` pre-validates all three inputs, then commits the T02 `BackpackState` snapshot, T06 committed modifier snapshot, Fate, and route exactly once. UI/MainController remain outside this T12 package.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1, GitHub Actions.

**Spec:** `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md` + `docs/canon/2026-08-21-dec014-025-product-canon.md` DEC-025 + `docs/CURRENT_CONFIRMED_DECISIONS.md`.

## Global Constraints

- Route selection remains provisional throughout Workbench and may change before Fate commit.
- Fate candidate generation/validation stays in `FateController`; direct `RunBuildState` mutation is no longer the final DEC-025 selection path.
- `RestCommitCoordinator` is the sole final REST transaction boundary.
- Failed validation mutates none of committed backpack, selected Fate, or route state.
- Successful commit applies exactly once; duplicate commit is rejected.
- T02 geometry authority, T03 resolution authority, T04 session authority, T05 combination authority, T06 committed modifier authority, T07 acquisition transaction, T08 route authority, and T11 access/reward authority remain distinct.
- Existing 19 items, 3 combinations, 5 purchasable bags and all current tuning values are unchanged.
- T13 persistent Workbench UI/input and T14 playable encounter integration are excluded.
- Automated domain evidence does not claim Human/Player Experience or device/export validation.

---

### Task 1: RED — atomic commit contract and deliberate Fate supersession

**Files:**
- Create: `tests/unit/test_rest_commit_coordinator.gd`
- Modify: `tests/unit/test_fate_controller.gd`

**Interfaces:**
- Consumes: `RestBackpackSession.commit_failures(chest_count, boss_reward_pending, combination_pending)`, `RunRouteState.set_provisional_next_school()`, current `FateController.begin_rest()/choose()`.
- Produces expected contract for `res://scripts/core/rest_commit_coordinator.gd`, pending Fate semantics, and all-or-none state assertions.

- [ ] **Step 1: Write failing T12 tests**

```gdscript
const COORDINATOR_PATH := "res://scripts/core/rest_commit_coordinator.gd"

func test_t12_resource_exists() -> void:
    assert_true(ResourceLoader.exists(COORDINATOR_PATH), "Missing T12 RestCommitCoordinator")

func test_fate_choice_is_pending_until_atomic_commit() -> void:
    var fixture := _new_t12_fixture(1201)
    fixture.fate.begin_rest()
    var fate_id: StringName = fixture.fate.candidate_ids[0]
    assert_true(fixture.fate.choose(fate_id))
    assert_eq(fixture.fate.selected_this_rest, fate_id)
    assert_false(fixture.build_state.has_fate(fate_id), "Pending Fate must not mutate committed RunBuildState")
```

Add focused cases for missing/invalid backpack readiness, missing Fate, missing provisional route, legal success, and duplicate commit. Each failed case snapshots `coordinator.committed_backpack_state()`, `build_state.selected_fates`, `build_state.get_committed_backpack_modifiers()`, and `route_state.get_route_snapshot()` before the call and asserts exact equality afterward.

- [ ] **Step 2: Migrate only the directly superseded old Fate expectations**

Change `test_choose_requires_current_candidate_and_only_one_choice_per_rest` so `choose()` proves pending selection without `RunBuildState.has_fate()`. Change `test_new_rest_resets_local_choice_but_excludes_previous_fate` to commit its first pending Fate through the T12 coordinator before beginning the next rest. Keep candidate uniqueness and already-committed Fate exclusion tests.

- [ ] **Step 3: Run CI and verify RED is narrow**

Expected: pre-T12 regression remains green except the deliberately superseded Fate-immediate expectations and new T12 contract, with the coordinator resource absent/pending semantics missing. Godot import and main-scene smoke must still pass.

---

### Task 2: GREEN — make FateController pending-selection authority

**Files:**
- Modify: `scripts/core/fate_controller.gd`

**Interfaces:**
- Produces: `choose(fate_id) -> bool` as pending-only selection, `_can_commit_pending() -> bool`, `_commit_pending() -> bool`, existing `selected_this_rest` and `can_continue()` as pending state.
- Does not own backpack or route mutation.

- [ ] **Step 1: Remove immediate build mutation from `choose()`**

```gdscript
func choose(fate_id: StringName) -> bool:
    if selected_this_rest != &"":
        return false
    if not candidate_ids.has(fate_id):
        return false
    if _build_state == null or _build_state.has_fate(fate_id):
        return false
    selected_this_rest = fate_id
    fate_selected.emit(fate_id)
    return true
```

- [ ] **Step 2: Add coordinator-only pending commit bridge**

```gdscript
func _can_commit_pending() -> bool:
    return _build_state != null \
        and selected_this_rest != &"" \
        and candidate_ids.has(selected_this_rest) \
        and not _build_state.has_fate(selected_this_rest)

func _commit_pending() -> bool:
    if not _can_commit_pending():
        return false
    return _build_state.select_fate(selected_this_rest)
```

Keep the bridge underscore-prefixed to match the project’s existing T05 internal-contract convention; do not add a generic public `commit_fate` bypass.

- [ ] **Step 3: Verify focused Fate tests**

Expected: pending-selection tests pass; no Fate is added to `RunBuildState` until coordinator commit.

---

### Task 3: GREEN — RestCommitCoordinator all-or-none boundary

**Files:**
- Create: `scripts/core/rest_commit_coordinator.gd`
- Test: `tests/unit/test_rest_commit_coordinator.gd`

**Interfaces:**
- `configure(committed_backpack_state, build_state: RunBuildState, route_state: RunRouteState, fate_controller: FateController) -> void`
- `begin_rest(session: RestBackpackSession) -> bool`
- `commit(chest_count: int = 0, boss_reward_pending: bool = false, combination_pending: bool = false) -> bool`
- `committed_backpack_state()` returns a defensive `BackpackState` copy.
- `commit_failures(...) -> Array[StringName]` provides deterministic reason codes without mutation.

- [ ] **Step 1: Implement validation-only failure collection**

```gdscript
func commit_failures(chest_count: int = 0, boss_reward_pending: bool = false, combination_pending: bool = false) -> Array[StringName]:
    var failures: Array[StringName] = []
    if _session == null:
        failures.append(&"missing_session")
        return failures
    failures.append_array(_session.commit_failures(chest_count, boss_reward_pending, combination_pending))
    if _fate_controller == null or not _fate_controller._can_commit_pending():
        failures.append(&"fate_pending")
    if _route_state == null or _route_state.provisional_school_id() == &"" or not _route_state.is_school_unvisited(_route_state.provisional_school_id()) or _route_state.active_school_id() != &"" or _route_state.is_final_binding_eligible():
        failures.append(&"route_pending")
    return failures
```

`commit_failures()` must not consume RNG, emit domain mutations, or alter session/Fate/route state.

- [ ] **Step 2: Implement validate-all-then-commit**

```gdscript
func commit(chest_count: int = 0, boss_reward_pending: bool = false, combination_pending: bool = false) -> bool:
    if _committed_this_rest or not commit_failures(chest_count, boss_reward_pending, combination_pending).is_empty():
        return false
    var candidate_state = _session.state
    var resolution = _session.current_resolution()
    if candidate_state == null or resolution == null or not bool(resolution.valid):
        return false

    # No mutation occurs before every input is validated. Route commit has no signal
    # and cannot fail after the exact provisional route was just validated.
    if not _route_state.commit_provisional_next_school():
        return false
    _committed_backpack_state = candidate_state.copy_value()
    _build_state.set_committed_backpack_modifiers(resolution.modifiers)
    if not _fate_controller._commit_pending():
        return false

    _committed_this_rest = true
    _session = null
    return true
```

Set `_committed_this_rest` before any externally observable coordinator success signal if one is added; do not add a second build/route authority.

- [ ] **Step 3: Prove successful state**

Success test must assert:
- coordinator’s committed backpack matches the finalized session state by value but is copy-isolated;
- `RunBuildState.get_committed_backpack_modifiers()` equals `session.current_resolution().modifiers` fields;
- exactly the pending Fate is committed once;
- provisional route becomes active and provisional becomes empty;
- a second `commit()` returns false with all committed state unchanged.

---

### Task 4: Adversarial hardening and clean re-attack

**Files:**
- Create: `tests/unit/test_rest_commit_coordinator_adversarial.gd`
- Create after valid adversarial GREEN: `tests/unit/test_rest_commit_coordinator_clean_reattack.gd`
- Modify production only for a reproduced valid finding.

**Interfaces:** Same T12 public/internal boundary.

- [ ] **Step 1: Attack authority and atomicity**

Add cases for:
- non-empty buffer, pending bag, pending item preview, whole-layout mode and pending combination each block commit without changing any committed state;
- chest/boss pending flags block commit;
- stale/previously committed Fate blocks commit;
- changed/revisited provisional route blocks commit;
- defensive `committed_backpack_state()` cannot mutate coordinator authority;
- `RestCommitCoordinator` exposes no generic `force_commit`, `set_route`, `set_fate`, or geometry mutation API;
- Fate `_commit_pending()` cannot commit an unoffered/stale candidate;
- commit-time `RunBuildState.fate_changed` observer sees route, backpack modifier snapshot, and committed Fate already coherent;
- all legal next-school candidates across representative route prefixes commit correctly without changing school identity/Stage rules.

- [ ] **Step 2: Run full verification after every valid finding**

Required workflow evidence: Base reuse manifest PASS, Godot 4.7.1 import PASS, main-scene smoke PASS, full GUT PASS.

- [ ] **Step 3: Perform minimum five whole-state adversarial loops**

Each loop re-attacks atomicity, authority duplication, stale state, defensive copies, T05/T07 commit blockers, route legality, Fate uniqueness, and no T13/T14 scope leakage. Continue beyond five if a new valid finding appears.

- [ ] **Step 4: Add final compact clean re-attack suite**

The clean suite must cover one successful full transaction, every independent input-gate family, duplicate commit, defensive state, and absence of authority bypasses. Full CI must be fresh on the exact final head.

---

### Task 5: PR, merge, readback, and human-canon sync

**Files:**
- No unrelated runtime changes.
- Update Notion Home / Production Handoff only after GitHub integration succeeds.

- [ ] **Step 1: Review exact diff**

Expected T12 scope is coordinator + Fate migration + T12 tests + this plan. MainController/UI/StageFlow remain untouched unless a test proves a T12-only integration necessity.

- [ ] **Step 2: Verify PR gates**

Confirm exact head SHA, fresh CI success, review/thread state, current `main`, mergeability, and no unrelated open-PR collision.

- [ ] **Step 3: SHA-lock merge current-task PR**

Use the exact verified head. No force push, direct-main write, or ruleset bypass.

- [ ] **Step 4: Post-merge readback**

Verify new `main` SHA and read T12 production files from `main`.

- [ ] **Step 5: Sync Notion**

Set `T12 INTEGRATED / T13 NEXT` with exact automated evidence. Keep playable MainController integration, persistent Workbench UI/input, Human Usability/Player Experience, Windows/device, and Android/export as NOT_RUN unless separately executed.
