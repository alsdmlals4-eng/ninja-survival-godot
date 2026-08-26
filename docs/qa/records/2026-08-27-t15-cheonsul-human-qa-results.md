# T15 · 천술류 Human QA 결과 기록

## 실행 정보

| 항목 | 값 |
| --- | --- |
| 기준 리비전 | `25e2bf3a5ecd026f56428e75f18389da2c430c40` |
| 엔진 | Godot 4.7.1 |
| 자동 기준선 | import PASS · editor parse PASS · five-second main smoke PASS · GUT 485/485 tests · 5301 assertions |
| PR #69 post-merge `main` (`e2cfe445`) | import PASS · editor parse PASS · five-second main smoke PASS · focused GUT 8/8 tests · 38 assertions · full GUT 488/488 tests · 5321 assertions |
| Hera 라이브 에이전트 | `LIVE_HERA_NOT_CONNECTED` — 최신 작업 공간의 직접 런타임 UI 관찰에 사용하지 않음 |
| 사람 참가자 | NOT_RUN |
| 세션 일시 | NOT_RUN |

## 사람 플레이 판정

프로토콜: `docs/qa/2026-08-27-t15-cheonsul-human-qa-protocol.md`

| 항목 | 참가자 답/행동 | 직접 관찰 | 판정 | 분류/후속 |
| --- | --- | --- | --- | --- |
| 30초 정체성 | NOT_RUN | NOT_RUN | NOT_RUN |  |
| Core 반응 이해 | NOT_RUN | NOT_RUN | NOT_RUN |  |
| Elite→Trace→Boss 긴장 | NOT_RUN | NOT_RUN | NOT_RUN |  |
| 예고 공정성 | NOT_RUN | NOT_RUN | NOT_RUN |  |
| Trace 목적 | NOT_RUN | NOT_RUN | NOT_RUN |  |
| Workbench 의미 | NOT_RUN | NOT_RUN | NOT_RUN | 현재 Boss 보상은 읽기 전용 경계 |
| 백팩·경로 판단 | NOT_RUN | NOT_RUN | NOT_RUN | GOOD_DEPTH / BAD_FRICTION 미판정 |
| 한국어 가독성 | NOT_RUN | NOT_RUN | NOT_RUN |  |
| 유파 기능 도움말 | NOT_RUN | 자동 UI 회귀: 열기·선택 차단·닫기·포커스 복귀 PASS | NOT_RUN | 실제 유파별 기능 설명/가독성/터치 경험은 사람 세션에서 판정 필요 |
| Mouse | NOT_RUN | NOT_RUN | NOT_RUN |  |
| Keyboard/gamepad-focus | NOT_RUN | NOT_RUN | NOT_RUN |  |
| Physical touch | NOT_RUN | NOT_RUN | NOT_RUN | 실제 터치 장비 확인 필요 |

## 현재 게이트 상태

`HUMAN_QA_DEFERRED_BY_CURRENT_USER`.

사용자 제공 Work → Codex 실행 계약에 따라 현재 병합/자동화 단계에서는 사람 세션을 요구하지 않는다. 자동 테스트와 AI 관찰은 위 표의 사람 항목을 대체하지 않으며, 이후 Human QA를 재개할 때 `FAIL` 또는 `UNCLEAR`가 나오면 공유 골격의 원인을 먼저 재현·수정·재검증한다.

## 사용자 지시 반영 — 유파 기능 도움말

사용자가 네 유파의 실제 구현 방식을 선택 전에 읽을 수 있는 도움말 팝업을 지시했다. 이 보조 수단은 첫 30초 무설명 정체성 판정을 오염시키지 않도록, 프로토콜에서 첫 실행 뒤 별도 사용성 확인으로 분리한다. 자동 UI 회귀가 통과해도 설명의 이해·가독성·터치 경험은 사람 증거가 필요하다.
