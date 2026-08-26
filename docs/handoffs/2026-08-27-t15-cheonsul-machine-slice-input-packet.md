# T15 Cheonsul Machine Slice · Work Production Input Packet

## Packet status

```yaml
project_identity: NINJA_SURVIVAL
repository: alsdmlals4-eng/ninja-survival-godot
slice_id: T15_CHEONSUL_SCHOOL_FUNCTION_HELP_MACHINE_SLICE
exact_project_baseline: 25e2bf3a5ecd026f56428e75f18389da2c430c40
implementation_head: f60504b57dfea84c3b20e43b93e62f68b3222104
merged_main: e2cfe4452e1de5a224f5cd7dee8e47a104c868e0
work_packet_timing: RECONCILED_AFTER_EXISTING_IMPLEMENTATION
readiness: READY_FOR_SINGLE_CODEX_WINDOW
human_qa: DEFERRED_BY_CURRENT_USER
```

This packet does not claim that the preceding implementation was built from this document. It reconciles the already approved, existing PR #69 into the user's current Work → Codex completion contract before its machine-only closeout.

## Player outcome

```yaml
player_promise: "유파를 고르기 전에 실제 전투 방식부터 짧고 정확하게 읽는다."
starting_context: "게임 시작의 유파 선택 화면"
player_action_or_choice:
  - "유파별 기능 도움말을 연다"
  - "실제 구현된 전투 규칙을 읽는다"
  - "닫기 또는 ui_cancel 후 원하는 유파를 한 번 선택한다"
meaningful_tradeoff: "도움말은 선택 전 이해를 돕지만, 선택 자체나 전투/보상/경로 상태를 바꾸지 않는다."
expected_result: "도움말을 읽은 뒤에도 오직 원래 선택 버튼 또는 1~4 숫자 입력만 유파 선택을 확정한다."
failure_and_learning: "설명이 실제 runtime과 다르거나 모달 뒤 선택이 새면 GUT 회귀로 고정하고 UI owner만 수정한다."
reward_and_feedback: "선택 전에는 명확한 한국어 설명, 선택 후에는 기존 유파 전투 진입 피드백을 그대로 사용한다."
```

## Approved scope

- `SchoolSelectionUI`의 네 기존 유파 선택 경로에 각각 독립된 `기능 도움말` 진입점을 추가한다.
- 하나의 재사용 팝업은 현재 구현된 기능만 설명한다.
- 팝업은 유파 선택 signal을 내지 않으며, 열린 동안 직접 선택 버튼과 1~4 숫자 선택을 차단한다.
- `닫기`와 `ui_cancel`은 팝업을 닫고 여는 버튼으로 keyboard/gamepad focus를 돌린다.
- 선택·차단·닫기·포커스 회귀, Godot import/parse/smoke/full GUT, GitHub/Notion readback을 수행한다.

## Explicit non-scope and protected scope

```yaml
explicit_non_scope:
  - new raster image, VFX asset, audio binary, or paid dependency
  - combat tuning or four-school runtime redesign
  - Boss reward selection, backpack placement, Fate/route commit, or auto-commit
  - T16 remaining-school content and device/export claims
protected_scope:
  - SchoolSelectionUI.school_selected is the only selection commit signal
  - current school runtime mechanics and existing Korean combat feedback
  - T12/T13 domain/UI ownership boundaries
  - PR #49 remains read-only
  - approved Hybrid Visual direction and original-first asset policy
```

## Reuse and alternatives

| Option | Disposition | Reason |
| --- | --- | --- |
| Existing `SchoolSelectionUI` Buttons + one modal | **ADOPT** | Keeps one selection owner and reuses pointer/touch/focus Button behavior without new state authority. |
| Add static explanations to the selection-button labels | **REJECT** | Would make four selection rows long and cannot carry the exact current mechanics without harming scanability. |
| Add a separate Codex/help Scene or web-style encyclopedia | **REJECT** | Adds navigation and lifecycle scope with no new playable value for this entry slice. |
| Generate icon/art sheets for the four help cards | **REJECT** | This slice has no visual consumer requirement beyond the existing UI; it would create asset approval/import work without improving the tested selection contract. |

`REUSE_LEARNING_HANDOFF: NO_NEW_REUSE_LEARNING` — this is a project-local UI boundary correction, not evidence for a new Base module.

## UI, data, and state contract

```yaml
owner: SchoolSelectionUI
inputs:
  - existing selection Button.pressed
  - help Button.pressed
  - ui_cancel while help is open
  - key 1..4 while help is closed
state:
  selected: false until valid selection commit
  help_open: false until a valid help Button opens the modal
  help_opener: exact Button that opened the modal
outputs:
  - help title/body rendered from current-runtime-only help data
  - school_selected(school_id) emitted once only by valid selection
invariants:
  - help open never changes selected or emits school_selected
  - help_open blocks every selection route
  - closing help restores opener focus when the Button is still valid
```

## Actual runtime text sources

| School | Required current-runtime-only explanation |
| --- | --- |
| 봉마류 | SPIRIT regeneration/kill gain, ward attack-speed window, 100-SPIRIT 백귀야행 temporary familiar. |
| 천술류 | flame/BURN, alternating WET and SHOCK, WET → SHOCK reaction, three-reaction 오행폭주 readiness. |
| 귀인류 | nearby automatic pulse, GWIHYEOL gain/decay, high-meter damage, low-health radius, 귀인화. |
| 흑영류 | multiple nearby targets, marks, MARK BURST at three marks, total-mark 암영처형 readiness. |

## Asset, audio, VFX, and accessibility disposition

```yaml
visual_requirements: []
approved_visual_assets_consumed: []
audio_requirements: []
approved_audio_assets_or_procedural_specs: []
vfx_and_feedback_requirements:
  - existing text-only gameplay feedback remains authoritative
localization_and_accessibility_requirements:
  - Korean title and body text
  - Button path shared by mouse, touch, keyboard, and gamepad-focus activation
  - ui_cancel and visible close action
provenance_and_rights_records: NOT_APPLICABLE_NO_NEW_BINARY_ASSET
```

## Acceptance and machine QA

```yaml
implementation_acceptance:
  - four help entry buttons exist
  - one reusable HelpDialog renders the chosen school's title and current mechanics
  - opening/closing help has no school-selection side effect
  - modal blocks selection Button and numeric routes until closed
  - opener focus returns after close
deterministic_test_requirements:
  - res://tests/unit/test_school_selection_ui.gd
runtime_qa_scenarios:
  - Godot import, editor parse, five-second main smoke
  - full GUT from exact head
  - Hera only if this exact project exposes a live agent session
build_or_export_checks: NOT_RUN_OUT_OF_SCOPE
rollback: "Revert the single PR #69 squash commit; no save, asset, or data migration exists."
unresolved_nonblocking:
  - LIVE_HERA_NOT_CONNECTED for this exact project
blocking_missing_inputs: []
evidence_ceiling:
  - HUMAN_USABILITY_EVIDENCE: DEFERRED_BY_CURRENT_USER
  - PLAYER_EXPERIENCE_EVIDENCE: NOT_RUN
  - PHYSICAL_TOUCH_EXPERIENCE: NOT_RUN
  - DEVICE_EXPORT: NOT_RUN
```

## User vertical-slice validation packet

```yaml
project: NINJA_SURVIVAL
slice_id: T15_CHEONSUL_SCHOOL_FUNCTION_HELP_MACHINE_SLICE
build_or_scene: res://scenes/main/main_scene.tscn
exact_commit_or_build_identity: e2cfe4452e1de5a224f5cd7dee8e47a104c868e0
launch_route: "Godot Editor → Run Project"
prerequisites: "None beyond the project-local Godot 4.7.1 environment"
representative_play_window: "Start screen: open one help popup, close it, then select a school"
expected_action_choice_result: "Help explains but does not select; only the subsequent deliberate selection starts combat"
expected_visual_audio_feedback: "Korean title/body popup and existing selection/combat feedback; no new asset or audio"
success_markers:
  - "No school starts when help opens or closes"
  - "1..4 do nothing while help is visible"
  - "Close returns focus to the help opener"
known_not_run:
  - Human comprehension and Korean readability judgement
  - Physical touch hardware
  - Player Experience, device, export, and live-Hera evidence
evidence_capture: "Note the school opened, whether any selection leaked, and one sentence that was unclear"
feedback_questions:
  - "도움말을 보고 각 유파가 어떻게 싸우는지 한 문장으로 설명할 수 있었나요?"
  - "닫은 뒤 원하는 유파를 고르는 흐름이 자연스러웠나요?"
  - "읽기 어렵거나 과장된 설명이 있었나요?"
machine_evidence: "Godot 4.7.1 import PASS · editor parse PASS · five-second main smoke PASS · focused GUT 8/8 / 38 · full GUT 488/488 / 5321 · GitHub Actions gut SUCCESS on final PR head b716b98"
next_decisions: "Human feedback에서 실제 문제를 발견할 때만 T15 후속 수정 범위를 연다; T16은 별도 현재 범위 승인 없이는 시작하지 않는다"
```
