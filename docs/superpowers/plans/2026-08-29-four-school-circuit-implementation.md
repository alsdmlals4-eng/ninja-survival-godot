# 네 유파 Circuit 구현계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` for inline, task-by-task execution. Each task uses TDD and receives an independent review gate.

**Goal:** 한 명의 닌자가 네 유파를 미방문 순서대로 통과하고, Elite → Trace → Boss → 보상 → Workbench/Fate/다음 경로 확정까지의 승인된 machine-playable circuit을 구현한다.

**Architecture:** `SchoolCircuitController`는 `StageEncounterState`와 `RunRouteState`를 조립하는 학교 중립 coordinator이다. 기존 `RestBackpackSession`, `CombinationResolver`, `RestCommitCoordinator`, `RunBuildState`, `FateController`는 규칙을 계속 소유한다. `MainController`와 UI는 snapshot을 표시하고 intent만 전달하며, 공통 circuit은 `EncounterCatalog`의 네 유파 definition을 소비한다.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1 (local temporary runner and repository CI), existing GitHub Actions Windows internal-build workflow.

**Spec:** `docs/implementation/2026-08-29-four-school-circuit-implementation-contract.md`

## Global Constraints

- 모든 새 GDScript의 첫 줄은 역할을 설명하는 짧은 한국어 주석이다.
- `StageEncounterState`, `RunRouteState`, `RestBackpackSession`, `CombinationResolver`, `RestCommitCoordinator`, `RunBuildState`의 단일 규칙 소유권을 이동하지 않는다.
- UI는 snapshot과 intent만 소유한다. route, Fate, backpack, economy, retry legality는 UI가 직접 변경하지 않는다.
- fixed 6×6 / centered 4×3 / rotation / orthogonal adjacency / 6-slot REST buffer / preview combat power zero / atomic commit 규칙을 보존한다.
- 새 Wave system, 별도 유파 전투 engine, Final Binding/final calamity/true Run-end Soul credit, raster asset batch, PR #49 변경은 범위 밖이다.
- Human Usability, Player Experience, device/export는 DEC-036에 따라 `NOT_RUN`이며 기계 검증으로 승격하지 않는다.

---

## File structure and dependency map

- Create: `scripts/core/school_circuit_controller.gd` — school-neutral lifecycle and existing Workbench-domain composition.
- Create: `scripts/data/run_economy_policy.gd` — seeded G policy data and validated reward receipt constants.
- Create: `scripts/core/ninja_soul_wallet.gd`, `scripts/core/run_settlement_ledger.gd`, `scripts/core/run_checkpoint.gd` — retry-only persistent boundary, idempotent Boss eligibility, successful-commit snapshot.
- Create: `scripts/rewards/trace_pickup.gd`, `scenes/rewards/trace_pickup.tscn` — separate in-world Trace settle/homing/recovery object.
- Create: `scripts/ui/status_icon_presenter.gd`, `scripts/ui/recent_hit_hp_presenter.gd` — semantic status icon and only-most-recently-hit HP presentation.
- Create: `scripts/ui/backpack_board_ui.gd`, `scripts/ui/rest_workbench_ui.gd` and matching scenes — input adapters over existing REST/combination snapshots.
- Modify: `scripts/core/main_controller.gd`, `scripts/core/run_build_state.gd`, `scripts/ui/hud.gd`, `scripts/ui/rest_flow_ui.gd`, `scenes/main/main_scene.tscn`, `scenes/ui/hud.tscn`, `scenes/ui/rest_flow_ui.tscn`, `scripts/enemies/enemy_chaser.gd` — only to compose the new owners and forward signals.
- Test: new focused unit and integration GUT files named after each new owner, plus existing `test_mvp3_stage_loop.gd`, `test_mvp3_rest_flow_ui.gd`, `test_main_scene.gd`, and script-contract coverage.

## Task 1: Establish the school-neutral lifecycle (I-01)

**Files:**
- Create: `tests/unit/test_school_circuit_controller.gd`
- Create: `scripts/core/school_circuit_controller.gd`
- Modify: `scripts/core/main_controller.gd`, `tests/integration/test_mvp3_stage_loop.gd`, `tests/unit/test_script_contracts.gd`

**Interfaces:**
- Consumes: `EncounterCatalog.build_school_encounters()`, `StageEncounterState`, `RunRouteState`, `RestRewardController`, `RestBackpackSession`, `RestCommitCoordinator`, `FateController`.
- Produces: `configure_workbench(...) -> bool`, `begin_school(school_id: StringName) -> bool`, `sync_elapsed(seconds: float) -> bool`, `mark_elite_defeated() -> bool`, `mark_boss_defeated() -> bool`, `get_snapshot() -> Dictionary`, and role/spawn/phase signals.

- [ ] Write the failing controller test proving each school can become active exactly once, exposes its own Core/Elite/Boss IDs, and refuses an already-cleared or unknown school.
- [ ] Run the focused GUT file and verify a semantic RED failure because `SchoolCircuitController` does not exist.
- [ ] Implement the minimum coordinator: it commits only the first active route via `RunRouteState`; it forwards `StageEncounterState` signals; it reads each role from `EncounterCatalog`; it never owns economy, backpack legality, Fate or route clear rules.
- [ ] Run the focused file GREEN, then extend the integration test to select each school through `MainController` and prove no legacy-only `StageFlowController` branch owns the selected school.
- [ ] Commit the isolated lifecycle change with its test evidence.

## Task 2: Make Elite Trace and combat information observable (I-02)

**Files:**
- Create: `scripts/rewards/trace_pickup.gd`, `scenes/rewards/trace_pickup.tscn`, `scripts/ui/status_icon_presenter.gd`, `scripts/ui/recent_hit_hp_presenter.gd`
- Create: `tests/unit/test_trace_pickup.gd`, `tests/unit/test_status_icon_presenter.gd`, `tests/unit/test_recent_hit_hp_presenter.gd`
- Modify: `scripts/core/main_controller.gd`, `scripts/enemies/enemy_chaser.gd`, `scripts/ui/hud.gd`, `scenes/main/main_scene.tscn`, `scenes/ui/hud.tscn`, `tests/integration/test_mvp3_stage_loop.gd`

**Interfaces:**
- Consumes: Elite lifecycle trace signal, Player `Node2D` position, Enemy damage/health state, school-neutral semantic statuses.
- Produces: Trace’s `recovered` signal only after 0.35s settle and 96px reach followed by 0.40s homing; `RecentHitHpPresenter.record_hit(enemy)` and `StatusIconPresenter.set_statuses(statuses)`.

- [ ] Write failing tests for Trace’s no-early-recovery, no-orb/no-gold/no-modifier behavior, recovery at the specified reach, and removal on retry.
- [ ] Run them RED; then implement the separate Trace node and wire only its recovery event to `SchoolCircuitController`.
- [ ] Write failing presentation tests: status values render semantic icon tokens without persistent BURN/WET/SHOCK/MARK text; a second hit replaces the first target; death/queue-free/timer expiry clears the bar at 1.25s.
- [ ] Run them RED, implement minimal presenters and Enemy damage signal forwarding, then run focused GREEN plus existing Cheonsul/Heukyeong regressions.
- [ ] Commit the Trace and information-grammar change with scoped tests.

## Task 3: Connect Boss candidates to legal spatial Workbench input (I-03)

**Files:**
- Create: `scripts/ui/backpack_board_ui.gd`, `scripts/ui/rest_workbench_ui.gd`, `scenes/ui/backpack_board_ui.tscn`, `scenes/ui/rest_workbench_ui.tscn`, `tests/integration/test_mvp4_workbench_input.gd`
- Modify: `scripts/ui/rest_flow_ui.gd`, `scenes/ui/rest_flow_ui.tscn`, `scripts/core/main_controller.gd`, `tests/integration/test_mvp3_rest_flow_ui.gd`, `tests/unit/test_rest_commit_coordinator.gd`

**Interfaces:**
- Consumes: immutable `RestBackpackSession` snapshots, `RestRewardController.choose_boss_reward`, `RestBackpackSession` placement/rotation/remove operations, `CombinationResolver`, `RestCommitCoordinator` readiness/commit outcome.
- Produces: pointer, focus-confirm, and touch intents; visible Korean failure feedback; no direct mutation outside domain calls.

- [ ] Write focused failures that a Boss reward must be chosen before route/Fate/commit can become enabled, a chosen reward enters only the REST buffer, and each input route sends the same domain intent.
- [ ] Run RED; implement only snapshot-driven buttons/grid adapters with no game-rule fields in the UI.
- [ ] Add failing atomicity tests for illegal placement, incomplete buffer, stale/reentrant session and failed combination; each must preserve committed modifiers, Fate and route.
- [ ] Implement the smallest UI forwarding/refresh logic that passes, run focused GUT and legacy T13 Workbench pointer/touch/focus tests.
- [ ] Commit the legal Workbench input path with full rejection-state coverage.

## Task 4: Implement deterministic G, checkpoint, and one retry (I-04)

**Files:**
- Create: `scripts/data/run_economy_policy.gd`, `scripts/core/ninja_soul_wallet.gd`, `scripts/core/run_settlement_ledger.gd`, `scripts/core/run_checkpoint.gd`
- Create: `tests/unit/test_run_economy_policy.gd`, `tests/unit/test_ninja_soul_wallet.gd`, `tests/unit/test_run_settlement_ledger.gd`, `tests/unit/test_run_checkpoint.gd`
- Modify: `scripts/core/run_build_state.gd`, `scripts/core/main_controller.gd`, `tests/unit/test_run_build_state.gd`, `tests/integration/test_mvp3_stage_loop.gd`

**Interfaces:**
- Consumes: seeded `RandomNumberGenerator`, normal/Elite/Boss death roles, successful `RestCommitCoordinator` result, death/restart orchestration.
- Produces: `grant_normal_kill_gold(rng)`, `grant_elite_clear_gold()`, `grant_school_boss_clear_gold()`, source-specific receipt, wallet `spend(1)`, idempotent Boss eligibility and restore-only retry checkpoint.

- [ ] Write the seed-fixed RED tests for normal 20% × 1G, Elite 5G, Boss 10G; ensure former unconditional 1G/25G output fails the new tests.
- [ ] Implement data-policy-only credit operations; run GREEN and current item/Fate modifier regressions.
- [ ] Write RED tests for one debit only, no retry without a successful-commit checkpoint, duplicate Boss idempotency, and retry reset of current-school transient data while retaining checkpoint-before state.
- [ ] Implement the minimal wallet/ledger/checkpoint owners and compose them from `MainController`; never credit Ninja Soul at fourth Boss.
- [ ] Run focused/integration GREEN and commit the retry/economy boundary.

## Task 5: Prove the four-school circuit end-to-end under the machine harness (I-05)

**Files:**
- Create: `tests/integration/test_four_school_circuit.gd`
- Modify: `scripts/core/main_controller.gd`, `scripts/core/school_circuit_controller.gd`, relevant focused tests only when a verified integration defect requires it.

**Interfaces:**
- Consumes: Task 1–4 public APIs and shared `EncounterCatalog` definitions.
- Produces: deterministic different-order runs reaching `RunRouteState.final_binding_eligible == true` after exactly four distinct Boss clears, with each Workbench transaction atomic.

- [ ] Write the RED test that clears all four schools in at least two different valid orders and asserts every composition ID, one Trace per Elite, one stabilization per Boss, and final-binding eligibility only after the fourth clear.
- [ ] Run RED; fill only missing composition/wiring defects found by that test.
- [ ] Run GREEN with existing legacy combat/route/backpack suites; add no Final Binding scene, final Boss or true settlement.
- [ ] Commit the machine circuit acceptance proof.

## Task 6: Exact-head verification, documentation, and adversarial closeout (I-06)

**Files:**
- Modify: `docs/ACTIVE_CONTEXT.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, `docs/traceability/2026-08-29-four-school-circuit-implementation-traceability.md`, `docs/reviews/2026-08-29-four-school-circuit-implementation-adversarial-review.md`, this plan

- [ ] Refresh the active context and evidence ceiling without calling human/player/device evidence PASS.
- [ ] Run Godot 4.7.1 import, editor parse, headless main-scene smoke, every focused GUT suite and full GUT from the exact branch head.
- [ ] Open a PR for Issue #126, wait for exact-head GitHub GUT and Windows internal-build checks, and request independent code review.
- [ ] Execute at least five whole-state adversarial loops: authority drift, route/atomicity bypass, Trace-orb contamination, retry duplication, and forbidden final package/asset scope.
- [ ] Correct only validated findings, rerun affected checks, merge only after all required exact-head checks are green, and complete post-merge main/readback.

## Plan self-review

- Contract coverage: I-01 through I-06 map one-to-one to the approved contract order; Final Binding and true Soul credit are explicitly excluded.
- Ownership: every new UI unit emits intents only; existing domain owners retain legality and commit authority.
- Evidence: plan requires RED→GREEN per production change and keeps Human/Player/device evidence separate.
- Feasibility: Godot 4.7.1 local import/editor/smoke completed before this plan; official Godot docs confirm per-instance seeded `RandomNumberGenerator` and custom `Resource` data are supported by this engine version.
