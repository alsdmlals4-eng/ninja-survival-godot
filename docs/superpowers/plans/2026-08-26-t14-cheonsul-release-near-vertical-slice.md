# T14 천술류 릴리스 근접 세로 슬라이스 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 기존 T09~T13 도메인을 조립해 천술류 한 유파가 Elite, Trace, Boss, Workbench 미리보기까지 실제 상태로 진행되게 한다.

**Architecture:** `CheonsulVerticalSliceController`는 기존 `StageEncounterState`, `RunRouteState`, `RestRewardController`, `RestBackpackSession`, `RestCommitCoordinator`를 조립하는 런타임 조정자이며, 각 도메인 규칙의 소유권은 이전하지 않는다. 또한 `EncounterCatalog`의 천술류 역할 식별자를 읽어 기존 일반 적·정예·보스 표현에만 연결한다. `MainController`는 천술류 선택 때만 이를 구성하고, 기존 MVP-3 선택 경로는 바꾸지 않는다. Workbench는 실제 Boss 보상 대기 상태와 경로/Fate 임시 선택을 표시하되, 아직 없는 배낭 보드 UI를 자동화하지 않는다.

**Tech Stack:** Godot 4.x, GDScript, GUT, 현재 main의 Scene/Resource/Signal 구조.

**Spec:** `docs/superpowers/specs/2026-08-26-t14-cheonsul-release-near-vertical-slice-design.md`

## Global Constraints

- 모든 새 GDScript 첫 줄에는 파일 역할을 설명하는 짧은 한국어 주석을 둔다.
- `StageEncounterState`, `RunRouteState`, `RestBackpackSession`, `RestCommitCoordinator`, `RestRewardController`의 단일 소유권을 이전하지 않는다.
- 첫 학교 진입은 `RunRouteState`의 임시 선택/확정만 사용하고, T12 원자 커밋은 Boss 뒤 다음 경로에만 사용한다.
- Boss 보상·배낭 배치·Fate·다음 유파를 자동 확정하지 않는다.
- 신규 이미지, 이미지 생성, 저장 시스템, 새 Wave 시스템, PR #49 변경은 금지한다.
- 기존 비천술류 MVP-3 테스트와 런타임 경로를 보존한다.

---

## 파일 구조

- Create: `scripts/core/cheonsul_vertical_slice_controller.gd` — 천술류 생명주기와 기존 도메인의 신호 조립.
- Create: `tests/unit/test_cheonsul_vertical_slice_controller.gd` — 순수 도메인 조립 및 게이트 계약.
- Modify: `scripts/core/main_controller.gd` — 천술류 선택에서 조정자를 생성/제거하고 적 사망·시간·Trace 입력·Workbench 표시를 위임.
- Modify: `scripts/ui/rest_flow_ui.gd` — 실제 Boss 보상 대기와 배낭 미해결 사유를 Workbench에 읽기 쉬운 한국어로 표시.
- Modify: `scenes/ui/rest_flow_ui.tscn` — 위 상태 문구를 위한 단일 읽기 전용 라벨.
- Modify: `tests/integration/test_mvp3_rest_flow_ui.gd` — 보상 대기 상태와 기존 카드/입력 회귀.
- Modify: `tests/integration/test_mvp3_stage_loop.gd` — MainController를 거치는 천술류 선택·보상 오브·Elite/Trace/Boss/Workbench 회귀 계약.
- Modify: `docs/ACTIVE_CONTEXT.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md` — PR 전에는 T14 구현 상태와 남은 Human QA를 정확히 기록.

### Task 1: 천술류 조정자의 실패 계약 작성

**Files:**
- Create: `tests/unit/test_cheonsul_vertical_slice_controller.gd`
- Create: `scripts/core/cheonsul_vertical_slice_controller.gd`

**Interfaces:**
- Consumes: `RunRouteState.set_provisional_next_school`, `RunRouteState.commit_provisional_next_school`, `StageEncounterState.sync_elapsed`, `mark_elite_cleared`, `recover_trace`, `mark_boss_cleared`.
- Produces: `begin_first_school() -> bool`, `sync_elapsed(elapsed_seconds: float) -> bool`, `mark_elite_defeated() -> bool`, `recover_trace() -> bool`, `mark_boss_defeated() -> bool`, `get_snapshot() -> Dictionary`, phase signals.

- [x] **Step 1: Write the failing first-school and Boss gate tests**

```gdscript
func test_first_school_is_committed_without_using_rest_commit() -> void:
	var slice := CheonsulVerticalSliceController.new()
	assert_true(slice.begin_first_school())
	assert_eq(slice.route_state.active_school_id(), &"cheonsul")
	assert_eq(slice.route_state.cleared_school_ids(), [])

func test_boss_requires_elite_trace_and_timing() -> void:
	var slice := CheonsulVerticalSliceController.new()
	slice.begin_first_school()
	slice.sync_elapsed(270.0)
	assert_false(slice.get_snapshot().get("boss_requested", false))
	assert_true(slice.mark_elite_defeated())
	assert_true(slice.recover_trace())
	slice.sync_elapsed(280.0)
	assert_true(slice.get_snapshot().get("boss_requested", false))
```

- [x] **Step 2: Run test to verify it fails**

Run: `& $env:GODOT_CONSOLE --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/unit -ginclude_subdirs -gtest=test_cheonsul_vertical_slice_controller.gd -gexit`

Expected: FAIL because `CheonsulVerticalSliceController` does not exist.

- [x] **Step 3: Write minimal implementation**

```gdscript
# 천술류 세로 슬라이스의 기존 도메인 조정을 담당한다.
extends RefCounted
class_name CheonsulVerticalSliceController

signal phase_changed(phase: StringName)
signal chest_token_granted(amount: int)
signal trace_recovery_requested
signal boss_spawn_requested
signal boss_cleared

var route_state := RunRouteState.new()
var encounter_state := StageEncounterState.new()

func begin_first_school() -> bool:
	return route_state.set_provisional_next_school(&"cheonsul") and route_state.commit_provisional_next_school()
```

Forward every `StageEncounterState` signal. Map only state changes into public signals and never mirror timing or route rules.

- [x] **Step 4: Run focused test to verify it passes**

Run the command from Step 2.

Expected: PASS; failed gate calls leave `RunRouteState` and `StageEncounterState` unchanged.

- [x] **Step 5: Commit**

```bash
git add scripts/core/cheonsul_vertical_slice_controller.gd tests/unit/test_cheonsul_vertical_slice_controller.gd
git commit -m "feat: add Cheonsul slice lifecycle adapter"
```

### Task 2: Boss-to-Workbench real state contract

**Files:**
- Modify: `scripts/core/cheonsul_vertical_slice_controller.gd`
- Modify: `tests/unit/test_cheonsul_vertical_slice_controller.gd`
- Modify: `tests/integration/test_mvp3_stage_loop.gd`

**Interfaces:**
- Consumes: `RestBackpackSession`, `RestRewardController.begin_rest`, `RestRewardController.boss_reward_options`, `RunRouteState.mark_active_school_cleared`.
- Produces: `configure_workbench(...)`, `begin_workbench() -> bool`, `workbench_snapshot() -> Dictionary`; the snapshot contains `route_snapshot`, `boss_reward_options`, `boss_reward_pending`, `readiness_failures`.

- [x] **Step 1: Write the failing Boss completion test**

```gdscript
func test_boss_clear_marks_cheonsul_cleared_and_exposes_pending_reward() -> void:
	var fixture := CheonsulSliceFixture.new()
	var slice := fixture.make_slice()
	fixture.advance_through_boss_request(slice)
	assert_true(slice.mark_boss_defeated())
	assert_eq(slice.route_state.cleared_school_ids(), [&"cheonsul"])
	var workbench := slice.workbench_snapshot()
	assert_true(workbench.get("boss_reward_pending", false))
	assert_true((workbench.get("boss_reward_options", []) as Array).size() > 0)
	assert_true((workbench.get("readiness_failures", []) as Array).has(&"boss_reward_pending"))
```

- [x] **Step 2: Run focused test to verify it fails**

Run: `& $env:GODOT_CONSOLE --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gtest=test_cheonsul_vertical_slice -gexit`

Expected: FAIL because no Workbench state is produced.

- [x] **Step 3: Write minimal composition**

Configure the existing committed backpack/session/resolver/reward owners with catalog definitions. Only after `StageEncounterState.mark_boss_cleared()` succeeds, call `RunRouteState.mark_active_school_cleared()` and `RestRewardController.begin_rest(...)`. Do not call `choose_boss_reward`, session placement APIs, Fate selection, or `RestCommitCoordinator.commit` automatically. Preserve the existing stable `boss_reward_pending` and later session-buffer failure codes instead of inventing a parallel readiness owner.

- [x] **Step 4: Run focused test to verify it passes**

Run the command from Step 2.

Expected: PASS; calling Boss completion out of order creates neither a cleared school nor a rest session.

- [x] **Step 5: Commit**

```bash
git add scripts/core/cheonsul_vertical_slice_controller.gd tests/unit/test_cheonsul_vertical_slice_controller.gd tests/integration/test_mvp3_stage_loop.gd
git commit -m "feat: connect Cheonsul boss reward to Workbench state"
```

### Task 3: MainController selective runtime composition

**Files:**
- Modify: `scripts/core/main_controller.gd`
- Modify: `tests/integration/test_mvp3_stage_loop.gd`

**Interfaces:**
- Consumes: Task 1/2 controller public API, existing `WaveSpawner`, `HUDController`, `RestFlowUI`.
- Produces: Cheonsul selection path that enables combat, updates phase feedback, handles Elite/Boss enemy deaths through the slice, and opens Workbench after Boss clear.

- [x] **Step 1: Write the failing selective-routing tests**

```gdscript
func test_cheonsul_selection_starts_slice_but_bongma_starts_legacy_stage_flow() -> void:
	var controller := await _make_main_controller()
	controller._on_school_selected(&"cheonsul")
	assert_not_null(controller.cheonsul_slice)
	assert_false(controller.stage_flow.phase == StageFlowController.Phase.COMBAT)

func test_non_cheonsul_boss_still_uses_legacy_settlement() -> void:
	var controller := await _make_main_controller()
	controller._on_school_selected(&"bongma")
	assert_null(controller.cheonsul_slice)
	assert_eq(controller.stage_flow.phase, StageFlowController.Phase.COMBAT)
```

- [x] **Step 2: Run integration test to verify it fails**

Run: `& $env:GODOT_CONSOLE --headless -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_mvp3_stage_loop.gd -gexit`

Expected: FAIL because MainController has no slice branch.

- [x] **Step 3: Write narrow MainController branch**

In `_on_school_selected`, keep school selection, modifier synchronization, and HUD setup shared. For `&"cheonsul"`, create/start the slice and enable combat without calling `stage_flow.start_after_school_selection()`. In a runtime time hook, feed monotonic combat elapsed time to the slice. Spawn existing configured Elite/Boss representation only after slice signals request it; tag spawned nodes with slice-role metadata so `_on_enemy_died` routes them to `mark_elite_defeated` or `mark_boss_defeated`. Keep ordinary deaths, score, DDD, and existing MVP-3 Boss settlement unchanged for non-slice paths.

- [x] **Step 4: Run integration test to verify it passes**

Run the command from Step 2.

Expected: PASS; non-Cheonsul regression test observes the original `StageFlow` phase.

- [x] **Step 5: Commit**

```bash
git add scripts/core/main_controller.gd tests/integration/test_mvp3_stage_loop.gd
git commit -m "feat: route Cheonsul combat through vertical slice"
```

### Task 4: Trace recovery and Workbench readback UI

**Files:**
- Modify: `scripts/core/main_controller.gd`
- Modify: `scripts/ui/rest_flow_ui.gd`
- Modify: `scenes/ui/rest_flow_ui.tscn`
- Modify: `tests/integration/test_mvp3_rest_flow_ui.gd`
- Modify: `tests/integration/test_mvp3_stage_loop.gd`

**Interfaces:**
- Consumes: Task 2 `workbench_snapshot()`, Task 3 phase signals, `RestFlowUI.show_workbench`.
- Produces: `RestFlowUI.show_workbench(..., workbench_context := {})` with optional `boss_reward_pending` and `boss_reward_options`; existing five-argument call remains valid.

- [x] **Step 1: Write failing UI test**

```gdscript
func test_workbench_shows_pending_boss_reward_without_enabling_commit() -> void:
	var ui := await _make_rest_flow_ui()
	ui.show_workbench(_route_snapshot(), _fates(), _fate_defs(), &"", [&"boss_reward_pending"], {
		"boss_reward_pending": true,
		"boss_reward_options": [&"fire_talisman"],
	})
	assert_string_contains(ui.workbench_reward_status_label.text, "보스 보상")
	assert_true(ui.workbench_commit_button.disabled)
```

- [x] **Step 2: Run UI test to verify it fails**

Run: `& $env:GODOT_CONSOLE --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/integration -ginclude_subdirs -gtest=test_mvp3_rest_flow_ui.gd -gexit`

Expected: FAIL because the sixth Workbench context argument and display label do not exist.

- [x] **Step 3: Write minimal read-only feedback and Trace input**

Add an optional final `workbench_context: Dictionary = {}` parameter, clear the label on all legacy calls, and display only Korean status text such as `보스 보상 선택·배치가 남아 있습니다.`. Keep the existing `boss_reward_pending` Korean failure mapping. Add one explicitly displayed Trace-recovery action/interaction in MainController that calls only `slice.recover_trace()` when the slice requests it; no shortcut may call it in another phase.

- [x] **Step 4: Run UI and slice integration tests to verify they pass**

Run both focused commands from Tasks 3 and 4.

Expected: PASS; T13 pointer/touch/focus tests continue to use standard Buttons and no legacy card is stale.

- [x] **Step 5: Commit**

```bash
git add scripts/core/main_controller.gd scripts/ui/rest_flow_ui.gd scenes/ui/rest_flow_ui.tscn tests/integration/test_mvp3_rest_flow_ui.gd tests/integration/test_mvp3_stage_loop.gd
git commit -m "feat: show Cheonsul Trace and Workbench readiness"
```

### Task 5: Documentation, complete verification, and review gate

**Files:**
- Modify: `docs/ACTIVE_CONTEXT.md`
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Modify: this plan

- [x] **Step 1: Update plan checkboxes and project routers**

Mark only completed plan steps. Record the exact limited result: technical Cheonsul lifecycle/Workbench entry is implemented; Boss reward placement UI and human/device/export evaluation remain `NOT_RUN` or pending.

- [x] **Step 2: Run import, main-scene smoke, and complete GUT**

```powershell
& $env:GODOT_CONSOLE --headless --import --path .
& $env:GODOT_CONSOLE --headless --path . --editor --quit
& $env:GODOT_CONSOLE --headless --path . --quit-after 5
& $env:GODOT_CONSOLE --headless -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Observed 2026-08-26 KST: Godot 4.7.1 import, editor parse, and five-second main-scene smoke each exited `0`; full GUT passed `485/485` tests and `5301` assertions. This is not human-play evidence.

- [x] **Step 3: Perform the required adversarial passes**

For five full passes inspect: first-school route exception, Boss gate, trace-before-Boss, Workbench no-auto-commit, non-Cheonsul MVP-3 regression, UI keyboard/pointer/touch contract, and documentation claims. Each valid finding requires a focused test, fix, regression, then the five-pass count restarts. Put the five clean pass headings in the PR description.

- [x] **Step 4: Commit documentation**

```bash
git add docs/ACTIVE_CONTEXT.md docs/CURRENT_CONFIRMED_DECISIONS.md docs/superpowers/plans/2026-08-26-t14-cheonsul-release-near-vertical-slice.md
git commit -m "docs: record T14 Cheonsul slice evidence"
```

- [x] **Step 5: Request independent code review and prepare a fresh PR**

Do not modify PR #49. Create a fresh PR linked to GitHub Issue #65 from the T14 branch. Include changed files, scope/exclusions, exact verification evidence, five adversarial passes, and explicit `NOT_RUN` human/device/export evidence. Reconcile with latest `origin/main` using fast-forward-only logic before final head verification.

Delivered: Issue #65 / PR #66 was squash-merged to `main` at `51e39737f272db0962a3dabada51bae10cd1fa97`. Exact PR-head and isolated post-merge checks each passed Godot 4.7.1 import, editor parse, five-second main smoke, and full GUT `485/485` / `5301` assertions. The queued GitHub Actions run `32983817646` was cancelled and no replacement PR synchronization run was created; remote-CI success is not claimed.

## Plan self-review

- Spec coverage: Tasks 1–3 cover route/lifecycle composition and Boss gating; Task 4 covers Trace/Workbench feedback; Task 5 records proof and deferred board interaction.
- Placeholder scan: no `TBD`, `TODO`, vague test, or undefined later interface remains. `CheonsulSliceFixture` is local test setup and must be defined in Task 2's test file before use.
- Type consistency: `workbench_snapshot()` supplies the optional final `show_workbench` context used only by Task 4; all earlier five-argument T13 calls remain source-compatible.
- Runtime catalog boundary: this package binds `EncounterCatalog` Core/Elite/Boss role IDs and Elite/Boss HUD display names to existing enemy representations; the catalog's fan/zone/mark primitive behaviors are not newly implemented or claimed as live pattern evidence here.

## 2026-08-26 adversarial clean-pass lineage

1. **첫 학교 경로 예외:** `test_cheonsul_vertical_slice_controller.gd`로 첫 임시 경로 확정이 T12 Rest commit을 우회해도 활성 학교만 만들고 clear order를 바꾸지 않음을 재검증했다. 깨끗함.
2. **Elite/Trace/Boss 이중 게이트:** 같은 도메인 계약에서 시간만, Trace만, Elite만으로 Boss를 요청하지 못하고 명시 회수 뒤에만 경고/요청이 생김을 재검증했다. 깨끗함.
3. **Workbench 원자 경계:** Boss-clear Workbench, 읽기 전용 보상 대기, Fate/경로 임시 의도 UI를 `test_cheonsul_vertical_slice_controller.gd`와 `test_mvp3_rest_flow_ui.gd`로 재공격했다. 보상 선택·배치·Fate·route 자동 커밋은 없음. 깨끗함.
4. **MVP-3 회귀 및 보상 오브:** `test_mvp3_stage_loop.gd`로 비천술류 기존 stage flow와 천술류의 legacy-stage-flow-idle 보상 오브 활성 상태를 함께 재검증했다. 깨끗함.
5. **카탈로그/문서 과장 방지:** `EncounterCatalog` preload·Core/Elite/Boss ID 메타 결합, 금지된 자동 보상/커밋 호출 부재, `NOT_RUN` 및 패턴 미구현 문구를 소스/문서 스캔으로 재검증했다. 깨끗함.
