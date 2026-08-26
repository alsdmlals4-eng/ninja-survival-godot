# T16 · 전투 중 현재 유파 기능 도움말 검증 기록

## 승인 범위

- 선택 전 도움말의 문구와 모달을 단일 원본으로 유지한다.
- 유파 선택 뒤, 전투 HUD에서 현재 유파 도움말을 다시 열 수 있다.
- 도움말은 전투 상태·학교 선택·Fate·경로를 변경하지 않는다.
- 전투 비활성화와 Game Over에서는 HUD 진입점과 열린 모달을 함께 닫는다.

## 자동 검증

| 검증 | 결과 |
| --- | --- |
| red → green: 선택 뒤 천술류 도움말 재열기·Escape·포커스 복귀 | PASS |
| red → green: Game Over 시 HUD 진입점·열린 모달 종료 | PASS |
| focused GUT | 25/25 tests · 176 assertions PASS |
| Godot import | PASS |
| Godot editor parse | PASS |
| five-second main-scene smoke | PASS |
| full GUT | 491/491 tests · 5352 assertions PASS |

## 직접 런타임 관찰

새 작업 공간의 Godot 편집기에서 현재 씬 실행을 시작하고, 새 `Ninja Survival Godot (DEBUG)` 창에 키보드 `2`를 보냈다. HUD 도움말 버튼의 실제 클릭 시각 검증은 별도 Godot 프로젝트 창이 대상 창의 전면을 점유해 두 번 차단됐다. 따라서 이 기록은 HUD 버튼의 화면상 클릭·모달 렌더를 `NOT_VISUALLY_CONFIRMED`로 남긴다. 자동 통합 테스트는 HUD 버튼 → MainController → 현재 선택 유파 → 기존 모달의 전체 연결을 검증한다.

사람 사용성, 물리 gamepad, 터치, 기기/export 증거는 이 변경으로도 `NOT_RUN`이다.
