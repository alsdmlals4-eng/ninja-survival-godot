# T15 · 천술류 Human QA 결과 기록

## 실행 정보

| 항목 | 값 |
| --- | --- |
| 기준 리비전 | `25e2bf3a5ecd026f56428e75f18389da2c430c40` |
| 엔진 | Godot 4.7.1 |
| 자동 기준선 | import PASS · editor parse PASS · five-second main smoke PASS · GUT 485/485 tests · 5301 assertions |
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
| Mouse | NOT_RUN | NOT_RUN | NOT_RUN |  |
| Keyboard/gamepad-focus | NOT_RUN | NOT_RUN | NOT_RUN |  |
| Physical touch | NOT_RUN | NOT_RUN | NOT_RUN | 실제 터치 장비 확인 필요 |

## 현재 게이트 상태

`BLOCKED_ON_DIRECT_HUMAN_SESSION`.

자동 테스트와 AI 관찰은 위 표의 사람 항목을 대체하지 않는다. 사람 세션에서 `FAIL` 또는 `UNCLEAR`가 나오면 공유 골격의 원인을 먼저 재현·수정·재검증하고, 필요한 모든 사람 항목이 직접 기록되기 전에는 T16을 열지 않는다.
