# T12 Atomic Workbench + Fate + Next-Route Commit — Fresh Resume Plan

> **For agentic workers:** REQUIRED SUB-SKILL: use `superpowers:executing-plans` in this session. All production behavior changes follow RED -> GREEN -> regression.

**Goal:** Implement DEC-025 so one Workbench transaction validates and commits the finalized backpack snapshot, one pending Fate, and one provisional unvisited school as one coherent all-or-none domain boundary.

**Architecture:** Preserve existing owners. `RestBackpackSession` remains pending spatial/edit readiness authority, `RunRouteState` remains route authority, `RunBuildState` remains committed combat/Fate state authority, and `FateController` gains a pending-selection compatibility path. A focused `RestCommitCoordinator` composes those owners without moving their rules into UI/MainController. Closed PR #43 is read-only WIP evidence; only still-valid tests/behavior are adapted into this fresh branch.

**Tech Stack:** Godot 4.7.1 CI identity, GDScript, GUT 9.7.1, GitHub Actions.

**Spec:** `docs/CURRENT_CONFIRMED_DECISIONS.md` §9 + `docs/canon/2026-08-21-dec014-025-product-canon.md` DEC-025 + `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md` T12.

## Global constraints

- Current product implementation baseline is T11; this package advances only T12.
- Route remains provisional throughout Workbench and can be replaced before commit.
- Finalized T04 backpack/session state + one pending Fate + one provisional unvisited school are validated before committed mutation.
- Validation failure mutates none of committed backpack, Fate, route, or T06 committed modifiers.
- Success commits exactly once; duplicate commit is rejected.
- Existing T02/T03/T04/T05/T06/T07/T08/T11 owners remain singular.
- Existing 19 base items, 3 first-tier combinations, 5 purchasable bags and tuning remain unchanged.
- Current pre-T13 `FateController.choose()` compatibility behavior remains available for the existing MainController; new T12 consumers use `choose_pending()`.
- T13 Persistent Workbench UI/input and T14 playable encounter migration are excluded.
- No Human Usability / Player Experience / device / Android claim is made from automated T12 evidence.

## Alternative study

1. **Dedicated RestCommitCoordinator — ADOPT.** Small composition owner; keeps existing domain authorities singular and defers UI migration to T13.
2. **Move backpack/route mutation into FateController — REJECT.** Makes Fate an over-broad transaction/geometry/route authority.
3. **Sequential commit in MainController/UI — REJECT.** Prematurely absorbs T13 and risks externally visible half-committed state.

## Task 1 — RED: pending Fate + atomic coordinator contract

**Files**
- Create: `tests/unit/test_rest_commit_coordinator.gd`
- Modify: `tests/unit/test_fate_controller.gd`

**Interfaces required by tests**
- `FateController.choose_pending(fate_id: StringName) -> bool`
- `FateController._can_commit_pending() -> bool`
- `FateController._commit_pending() -> bool`
- `RestCommitCoordinator.configure(committed_backpack_state, build_state, route_state, fate_controller) -> void`
- `RestCommitCoordinator.begin_rest(session) -> bool`
- `RestCommitCoordinator.commit_failures(chest_count := 0, boss_reward_pending := false, combination_pending := false) -> Array[StringName]`
- `RestCommitCoordinator.commit(...) -> bool`
- `RestCommitCoordinator.committed_backpack_state()` defensive copy

- [ ] Add RED tests adapted from closed PR #43 for pending Fate, missing Fate/route atomic failure, unresolved buffer failure, successful latest-route/backpack/Fate commit, duplicate rejection, defensive committed backpack view.
- [ ] Open a current-task draft PR so CI runs on the test-only head.
- [ ] Verify RED fails for the intended missing `RestCommitCoordinator` / missing pending-Fate API, while import/main smoke remain meaningful.

## Task 2 — GREEN: pending Fate compatibility path

**Files**
- Modify: `scripts/core/fate_controller.gd`
- Test: `tests/unit/test_fate_controller.gd`

- [ ] Add `_pending_for_atomic_commit` state reset by `begin_rest()`.
- [ ] Preserve `choose()` as current MainController immediate-commit compatibility path.
- [ ] Add `choose_pending()` that validates offered/uncommitted Fate without mutating `RunBuildState`.
- [ ] Add underscore-prefixed `_can_commit_pending()` and `_commit_pending()` coordinator bridge; no generic public commit bypass.
- [ ] Run exact PR-head CI; require full regression GREEN before next task.

## Task 3 — GREEN: RestCommitCoordinator

**Files**
- Create: `scripts/core/rest_commit_coordinator.gd`
- Test: `tests/unit/test_rest_commit_coordinator.gd`

- [ ] Store a defensive committed backpack baseline in `configure()`.
- [ ] `begin_rest()` accepts one T04 session only when required owners are configured.
- [ ] `commit_failures()` composes T04 readiness plus pending Fate and legal provisional route checks without mutation.
- [ ] `commit()` revalidates, captures candidate backpack/resolution, commits route and committed backpack modifiers, then commits Fate as the first externally observable final-state signal.
- [ ] Mark transaction committed, detach session, reject duplicates.
- [ ] Return defensive committed backpack copies.
- [ ] Run full exact-head CI GREEN.

## Task 4 — adversarial hardening

**Files**
- Create/modify T12-focused unit tests only as findings require.
- Production changes only for validated findings.

Minimum full-loop attacks:
1. every independent Workbench blocker + failure immutability;
2. stale/abandoned/legacy Fate paths + lifecycle/reuse;
3. synchronous observer coherence + T07 acquired-instance identity/cursor preservation;
4. all legal current-cleared -> next-school contexts + stage non-advance + scope containment;
5. final whole-state clean re-attack, including duplicate commit and absence of generic authority bypass.

- [ ] Each loop re-runs import/main smoke/full GUT on the changed exact head.
- [ ] Continue beyond five while any valid blocker/MUST_FIX remains.

## Task 5 — current routers, PR, merge, Notion readback

**Files**
- Modify only current router/evidence docs required to move T12 from NEXT to INTEGRATED after production evidence exists.

- [ ] Confirm no T13/UI/MainController/StageFlow gameplay scope leakage in final diff.
- [ ] Update `ACTIVE_CONTEXT.md`, `CURRENT_CONFIRMED_DECISIONS.md`, `DOCUMENTATION_MAP.md`, `SYSTEM_MAP.md`, `MVP_ROADMAP.md` only where current-state routing requires it; preserve historical records.
- [ ] Verify exact PR head: Base reuse manifest, Godot import, main smoke, full GUT, reviews/comments/threads, mergeability, latest-main freshness.
- [ ] SHA-lock squash merge current-task PR.
- [ ] Verify new main + post-merge main CI.
- [ ] Update Notion Human Home only with human-level `T12 integrated / T13 next`; put exact PR/SHA/CI evidence in Registry/Planning/Production.
- [ ] Final destination readback and remaining-work recalculation. Current package closes only when required T12 work = 0.
