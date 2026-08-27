# T16 · 전투 중 현재 유파 도움말 · Machine Input Packet

## 목적

전투 중인 플레이어가 유파 선택을 다시 하지 않고도, 현재 유파의 기능과 구현 방식을 즉시 다시 확인한다. 이 패킷은 이미 병합된 T16의 실제 구조·검증 증거·사람 검증 경계를 한 곳에서 재개 가능하게 정리한다. 새 기능, 자산 또는 게임 규칙을 제안하지 않는다.

## 정본과 기준선

| 항목 | 실제 값 |
| --- | --- |
| T16 구현 병합 main | `63fcf81fdf4b5d1bbff14b5721a13f7c1afe1497` |
| 현재 GitHub main | `29dc9828537ca4cc795bb2f971e72b71df10a22e` |
| 63fc → 29dc 실제 diff | `docs/ACTIVE_CONTEXT.md` 한 파일만 변경 — 런타임 소스 동일 |
| T16 PR | #73, 최종 head `9bfa35194f67ebb17125a8aea7e6f7dcf587af8b` |
| 보호 대상 | PR #49는 read-only, 변경·병합·재개 금지 |
| 정본 순서 | 현재 사용자 지시 → `AGENTS.md` → 결정/캐논 → 실제 코드·테스트·실행 증거 |

## Current Playable Slice

```yaml
slice_id: T16_IN_COMBAT_CURRENT_SCHOOL_HELP_MACHINE_SLICE
player_promise: "전투 중에도 지금 선택한 유파가 실제로 어떻게 작동하는지 한 번의 도움말로 다시 알 수 있다."
starting_context: "유파를 하나 선택해 전투가 활성화된 main scene."
player_action_or_choice: "HUD의 '<현재 유파> 기능 도움말'을 누르고 Escape 또는 닫기를 누른다."
meaningful_tradeoff: "새 화면이나 재선택 흐름을 만들지 않고, 기존 선택 도움말 모달을 재사용해 읽기와 전투 상태 보존을 함께 지킨다."
expected_result: "현재 선택 유파의 제목과 설명이 열리고, 닫은 뒤 HUD 버튼으로 포커스가 돌아간다."
failure_and_learning: "선택 유파가 없거나 전투가 비활성화·Game Over면 진입점과 열린 모달이 사라져 잘못된 상태를 만들지 않는다."
reward_and_feedback: "즉시 읽을 수 있는 현재 유파 이름·기능 설명과 명시적 닫기/Escape 반응."
systems_touched:
  - HUDController SchoolHelpButton and intent signal
  - MainController combat-state forwarding
  - SchoolSelectionUI reusable HelpDialog
  - unit and integration GUT coverage
approved_scope:
  - "선택 후 전투 HUD에서 현재 유파 도움말 재열기"
  - "기존 도움말 문구/모달의 단일 소유 유지"
  - "Escape와 버튼 포커스 복귀"
  - "전투 비활성화와 Game Over에서 진입점·모달 종료"
explicit_non_scope:
  - "유파 재선택, 전투 규칙·밸런스·경로·Fate 변경"
  - "새 이미지, VFX, 오디오, 유료 의존성"
  - "터치·물리 gamepad·기기 export 또는 사람 사용성 PASS 주장"
protected_scope:
  - "SchoolSelectionUI.school_selected는 유일한 선택 commit signal"
  - "UI는 intent/표현만 담당하며 선택·전투 상태 권한을 소유하지 않음"
  - "PR #49 read-only 경계"
current_blockers:
  - "Hera live editor에 닌자서바이벌 세션이 연결되지 않음"
  - "직접 실행은 했으나 캡처 접근성 한계로 HUD 모달의 시각 의미는 미확정"
  - "Human/Player Experience 및 device/export 검증은 현재 사용자 지시로 보류"
acceptance_criteria:
  - "선택 후 HUD 버튼이 보이고 현재 유파명으로 표기된다"
  - "HUD intent는 현재 선택 유파의 기존 HelpDialog만 연다"
  - "도움말은 두 번째 선택 commit, 게임 규칙, 전투 상태를 만들지 않는다"
  - "Escape/닫기 시 HUD opener에 포커스가 돌아간다"
  - "Game Over/전투 비활성화 시 버튼과 열린 모달이 함께 닫힌다"
```

## 실제 구조 확인

```text
HUD SchoolHelpButton
  -> HUDController.school_help_requested (intent only)
  -> MainController._on_school_help_requested()
  -> SchoolSelectionUI.open_runtime_school_help(selected_school_id, hud.school_help_button)
  -> existing HelpDialog
```

- `scripts/ui/hud.gd`: 전투가 활성화된 선택 유파명으로만 버튼을 보이고, 클릭 시 신호만 낸다.
- `scripts/core/main_controller.gd`: 선택 유파가 없거나 Game Over/비활성 전투면 요청을 거절한다. 전투 종료 시 버튼과 모달을 함께 숨긴다.
- `scripts/ui/school_selection_ui.gd`: 기존 `HelpDialog` 하나를 재사용한다. 런타임 도움말은 재선택을 허용하지 않으며 Escape/닫기 뒤 HUD opener에 포커스를 복귀한다.

## Machine Evidence

| 증거 | 결과 | 범위 |
| --- | --- | --- |
| focused GUT | 25/25 tests · 176 assertions PASS | 도움말 재열기, Escape, 포커스 복귀, Game Over 종료 |
| Godot import | PASS | T16 merge main 63fc |
| Godot editor parse | PASS | T16 merge main 63fc |
| main-scene smoke | PASS (5 sec) | T16 merge main 63fc |
| full GUT | 491/491 tests · 5352 assertions PASS | T16 merge main 63fc |
| current-source-equivalent full GUT re-run | PASS (Godot 4.7.1 exit 0) | 63fc source; current main differs only in `docs/ACTIVE_CONTEXT.md` |
| GitHub Actions GUT | SUCCESS, PR #73 final head | 구현 head 독립 검증 |
| 직접 Debug 실행 | INPUT_DELIVERED | current main 29dc에서 `2` → HUD 예상 위치 클릭 → Escape; 시각 의미는 미확정 |

## 증거 경계와 다음 검증

- **Verified:** 자동 테스트가 버튼 노출·intent·현재 유파 제목·비재선택·Game Over 종료를 실제 노드 상태로 검증한다. current main의 런타임 창에 키 입력·클릭·Escape 전달도 오류 없이 완료했다.
- **Not visually confirmed:** 이 환경 캡처는 게임 모달의 접근 가능한 텍스트/Control 트리를 제공하지 않아, 화면상 버튼/모달/닫힘 렌더를 PASS로 승격하지 않는다.
- **Deferred:** Human Usability, Player Experience, physical gamepad/touch, device/export.

사람 검증을 재개할 때의 최소 패킷:

1. Godot에서 `Run Project`를 실행하고 유파 하나를 선택한다.
2. 전투 HUD의 `<선택 유파> 기능 도움말`을 연다.
3. 제목·설명이 선택 유파와 일치하고, 전투 규칙/선택이 바뀌지 않는지 확인한다.
4. Escape와 `닫기` 각각에서 HUD 버튼으로 포커스가 돌아오는지 확인한다.
5. Game Over로 진입해 버튼과 열린 모달이 함께 사라지는지 확인한다.

이 다섯 단계는 사람/기기 증거가 실제로 생길 때만 PASS로 기록한다.

## 현재 범위의 결론

T16 구현 자체는 병합·자동 검증까지 완료됐다. 남은 것은 새 코드가 아니라, 보류 중인 사람/기기 검증과 이후 별도 범위로 승인될 제품 게이트다. 이 패킷은 그 경계를 정직하게 유지하며 다음 재개가 구현 완료 상태를 다시 추측하지 않도록 한다.
