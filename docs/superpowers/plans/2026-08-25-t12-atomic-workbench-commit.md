# T12 Atomic Workbench + Fate + Next-Route Commit Implementation Plan

> **Execution status:** Tasks 1-4 are implementation-complete through five clean adversarial loops. Task 5 PR closeout, merge/readback, and Notion sync remain.

**Goal:** Implement DEC-025 so one Workbench transaction validates and commits the finalized backpack snapshot, one pending Fate, and one provisional unvisited school all-or-none.

**Architecture:** Preserve existing domain owners. `RestBackpackSession` owns pending spatial edits and commit-readiness. `RunRouteState` owns provisional/active route facts. `FateController` now exposes an explicit T12 `choose_pending()` path plus internal `_can_commit_pending()` / `_commit_pending()` bridge, while its pre-T12 `choose()` immediate-commit path is retained as a **temporary compatibility adapter for the current MainController until T13**. `RestCommitCoordinator` is the focused DEC-025 final transaction boundary: it pre-validates Workbench + pending Fate + provisional route, then commits the T02 `BackpackState` snapshot, T06 committed modifier snapshot, Fate, and route exactly once. UI/MainController migration remains T13.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1, GitHub Actions.

**Spec:** `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md` + `docs/canon/2026-08-21-dec014-025-product-canon.md` DEC-025 + `docs/CURRENT_CONFIRMED_DECISIONS.md`.

## Global Constraints

- Route selection remains provisional throughout Workbench and may change before atomic commit.
- New DEC-025 consumers must use `FateController.choose_pending()`; the legacy `choose()` path exists only to preserve the current pre-T13 MainController flow.
- `RestCommitCoordinator` is the sole new final REST transaction boundary; it does not absorb T02/T03/T04/T05/T06/T07/T08/T11 authority.
- Failed validation mutates none of committed backpack, selected Fate, or route state.
- Successful commit applies exactly once; duplicate commit is rejected.
- Existing 19 items, 3 combinations, 5 purchasable bags and current tuning values are unchanged.
- T13 persistent Workbench UI/input + live MainController migration and T14 playable encounter integration are excluded.
- Automated domain evidence does not claim Human/Player Experience, Windows/device, or Android/export validation.

---

## Task 1 — RED: atomic commit contract

- [x] Added `tests/unit/test_rest_commit_coordinator.gd`.
- [x] Added pending Fate expectations and all-or-none snapshots.
- [x] RED head `51507c6bdf829102d691b2ae8acf4a57ebc39824` proved the coordinator was absent and Fate still committed immediately while import/main smoke and pre-T12 behavior otherwise remained available.

### RED finding that changed the migration tactic

The first naive GREEN made `FateController.choose()` pending-only. T12 core passed, but the full suite exposed a real live-consumer collision: the current MainController still calls `choose()` and has no T13 Workbench route-selection input yet. Migrating MainController here would have required inventing/absorbing T13 behavior.

**Decision:** preserve `choose()` as an explicit legacy compatibility adapter and add `choose_pending()` for the approved T12 atomic path. This keeps DEC-025’s new final transaction semantics without breaking the current playable MVP-3 consumer before its scheduled T13 migration.

---

## Task 2 — GREEN: Fate pending-selection path

- [x] `FateController.choose()` remains the pre-T13 immediate compatibility path.
- [x] Added `choose_pending(fate_id)` which validates an offered, uncommitted Fate but does not mutate `RunBuildState`.
- [x] Added `_can_commit_pending()` and `_commit_pending()` as underscore-prefixed coordinator bridges; no generic public `commit_fate` bypass exists.
- [x] `begin_rest()` abandons an uncommitted pending selection without committing it.
- [x] Unit tests distinguish legacy and atomic semantics explicitly.

First valid GREEN head: `a9286e206a252243a35b65948c2053f780d04581` — Godot import PASS, main smoke PASS, GUT **456/456**, **5061 assertions**.

---

## Task 3 — GREEN: RestCommitCoordinator all-or-none boundary

- [x] Added `scripts/core/rest_commit_coordinator.gd`.
- [x] `configure(committed_backpack_state, build_state, route_state, fate_controller)` stores a defensive baseline.
- [x] `begin_rest(session)` validates runtime dependencies.
- [x] `commit_failures(chest_count, boss_reward_pending, combination_pending)` is validation-only and composes T04 readiness + pending Fate + provisional route checks.
- [x] `commit()` validates all inputs before mutation, then commits route → defensive backpack snapshot/T06 modifier snapshot → pending Fate; the only externally observable commit signal used here is `RunBuildState.fate_changed`, whose observers see the already-coherent tuple.
- [x] Successful commit detaches the session and rejects duplicate commit.
- [x] `committed_backpack_state()` returns a defensive copy.

### Compatibility rationale

Alternatives considered:
1. **Chosen:** separate `RestCommitCoordinator` + explicit `choose_pending()` while retaining a temporary legacy `choose()` adapter.
2. Put backpack/route commit into `FateController` — rejected because Fate would become an over-broad authority.
3. Sequentially commit in MainController/UI — rejected because failures could expose half-committed state and would prematurely absorb T13.

---

## Task 4 — adversarial hardening

### Loop 1 — atomicity and authority

- [x] Head `c4debb40a9bd82b0186cf46b6b40a638aa7d9c87`.
- [x] Godot import PASS · main smoke PASS · GUT **466/466** · **5420 assertions**.
- [x] Attacked: buffer, pending bag, item preview, whole-layout, pending combination, chest/boss/combination blockers; stale/abandoned Fate; legacy-vs-pending boundary; failed-preview recovery; coherent `fate_changed`; route prefixes; final binding; defensive views; no generic bypass.

### Loop 2 — lifecycle and reuse

- [x] An initial test assumption that a prior committed-backpack argument must be non-null was rejected because the approved DoR does not define that as a T12 required input; production was not changed.
- [x] Valid head `eca49a157464c1fcfd2f279a6b577330cb5954d0`.
- [x] Godot import PASS · main smoke PASS · GUT **471/471** · **5495 assertions**.
- [x] Attacked: missing runtime dependencies, repeated validation purity, post-commit session detachment, legitimate next-rest coordinator reuse, repeated failure→later valid commit.

### Loop 3 — reentrancy and T07 identity

- [x] Two test-side errors were corrected without production changes: nonexistent item ID `movement_tabi` → canonical `shuriken`, and nonexistent buffer-preview method → actual T04 `place_buffer_item()` API.
- [x] Valid head `077daca15e3f02657555b9f18490e81cb3ca3828`.
- [x] Godot import PASS · main smoke PASS · GUT **476/476** · **5544 assertions**.
- [x] Attacked: synchronous commit/begin-rest reentrancy, T07 acquired item instance ID + monotonic cursor preservation, exact backpack+Fate modifier composition, pending intent signal semantics.

### Loop 4 — route contexts and scope containment

- [x] Head `d6af9873d235a76790a0f2e994b3fd3b06fed2fa`.
- [x] Godot import PASS · main smoke PASS · GUT **481/481** · **5768 assertions**.
- [x] Attacked all **12** legal current-cleared-school → next-school contexts (4×3), provisional replacement, failed revisit preservation, selected-school identity/stage non-advance, and source-level absence of T13 UI/Main/reward/stageflow authority absorption.

### Loop 5 — final clean whole-state re-attack

- [x] Added `tests/unit/test_rest_commit_coordinator_clean_reattack.gd`.
- [x] Head `fa1c4114965a53e37fd9a819d4b6620d55a020bf`.
- [x] Godot import PASS · main smoke PASS · GUT **486/486** · **5880 assertions**.
- [x] Clean suite **5/5 PASS** covering a full post-clear transaction, independent blocker families, legacy-vs-pending compatibility, T07 identity + coherent observer + defensive snapshot, duplicate commit, and authority/scope containment.
- [x] No new valid finding appeared; minimum five whole-state adversarial loops are complete.

---

## Task 5 — PR, merge, readback, and human-canon sync

- [ ] Review exact PR diff and verify no MainController/UI/StageFlow/T13/T14 scope leakage.
- [ ] Run final exact-head verification and check current `main`, mergeability, open PR collision, reviews/comments/threads.
- [ ] Update PR #43 body with RED→GREEN, compatibility finding, adversarial evidence, and evidence ceiling.
- [ ] Mark ready and SHA-lock squash merge with exact verified head; no force/direct-main/ruleset bypass.
- [ ] Verify new `main` SHA and read T12 production files back from `main`.
- [ ] Sync Notion Home + Production Handoff to `T12 INTEGRATED / T13 NEXT` with exact evidence and compatibility-adapter note.
- [ ] Keep playable T13 integration, Human Usability/Player Experience, Windows/device, and Android/export as NOT_RUN unless separately executed.
