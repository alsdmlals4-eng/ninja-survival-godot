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
| full GUT | 491/491 tests PASS (assertion total omitted: earlier receipts disagree while CI confirms the test count) |
| current-source-equivalent full GUT re-run | PASS (Godot 4.7.1 exit 0 on 63fc source; 63fc → current main changes only `docs/ACTIVE_CONTEXT.md`) |

## 직접 런타임 관찰

`origin/main` 29dc9828537ca4cc795bb2f971e72b71df10a22e에서 Godot 4.7.1의 새 최상위 Debug 창을 열고, Computer Use로 키보드 `2` → HUD 예상 위치 클릭 → `Escape`를 순서대로 전달했다. 각 입력 호출은 오류 없이 완료됐다. 29dc는 T16 구현 병합본 63fc와 비교해 `docs/ACTIVE_CONTEXT.md`만 다르므로, 실행된 런타임 소스는 T16 구현과 동일하다.

그러나 이 환경의 캡처에는 게임 Control 트리나 모달의 접근 가능한 텍스트가 노출되지 않았다. 그러므로 이 기록은 **입력 전달**만 `PASS`로 기록하며, HUD 버튼의 화면상 클릭·도움말 모달 렌더·닫힘은 여전히 `NOT_VISUALLY_CONFIRMED`다. Hera에는 닌자서바이벌 편집기 세션이 연결되지 않아, 다른 프로젝트 인스턴스를 증거로 사용하지 않았다. 자동 통합 테스트는 HUD 버튼 → MainController → 현재 선택 유파 → 기존 모달의 전체 연결을 검증한다.

사람 사용성, 물리 gamepad, 터치, 기기/export 증거는 이 변경으로도 `NOT_RUN`이다.
