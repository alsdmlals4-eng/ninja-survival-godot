# T15 · 천술류 Human QA 결과 기록

## 실행 정보

| 항목 | 값 |
| --- | --- |
| 기준 리비전 | `25e2bf3a5ecd026f56428e75f18389da2c430c40` |
| 엔진 | Godot 4.7.1 |
| 자동 기준선 | import PASS · editor parse PASS · five-second main smoke PASS · GUT 485/485 tests · 5301 assertions |
| PR #69 post-merge `main` (`e2cfe445`) | import PASS · editor parse PASS · five-second main smoke PASS · focused GUT 8/8 tests · 38 assertions · full GUT 488/488 tests · 5321 assertions |
| 현재 `main` (`2b0019c`) | PR #70 문서 readback merge 뒤 GitHub Actions GUT SUCCESS. 런타임 소스는 PR #69의 병합본과 동일 |
| Hera 라이브 에이전트 | `LIVE_HERA_NOT_CONNECTED` — 최신 작업 공간의 직접 런타임 UI 관찰에 사용하지 않음 |
| 사람 참가자 | NOT_RUN |
| 세션 일시 | NOT_RUN |

## 2026-08-28 · fresh-main 직접 런타임 진단 (사람 판정 대체 금지)

대상은 current GitHub `main` `977158acce4dd7cd27eb82d9ae3699673f4e1029`의
분리 작업공간에서 실행한 Godot 4.7.1 DEBUG 창이다. 이 revision은 T16 이후의
문서/시각 커버리지 정본까지 포함하지만, 이번 진단에서 제품 런타임 코드는
바꾸지 않았다. Hera는 이 편집기에 연결되지 않았으므로 Windows 직접 화면/입력
관찰만 사용했다.

| 경로 | 직접 관찰 사실 | 증거 상태 |
| --- | --- | --- |
| 선택 화면 | 네 유파의 한 줄 전투 철학과 각 `기능 도움말` 버튼이 한 화면에 보였고, 천술류 행은 “속성 상태를 겹쳐 반응을 터뜨린다”라고 표시됐다. | OBSERVED |
| 천술류 시작 | 키보드 `2` 뒤 `SCHOOL 천술류`, `REACTION 0 / 3`, `천술류: 원소 반응을 준비하세요.`와 전장/적 표현이 표시됐다. | OBSERVED |
| 선택 화면 도움말 | 천술류 도움말은 선택 화면을 유지한 채 BURN → WET/SHOCK → 반응 → 오행폭주 설명과 `닫기` 제어를 표시했다. | OBSERVED |
| 모달 입력 경계 | 모달을 연 상태에서 `2`를 보내도 모달과 선택 화면은 유지됐다. `Escape` 뒤 모달은 닫혔고 천술류 도움말 버튼의 포커스 테두리가 보였다. | OBSERVED |
| 정지 입력 한계 | 입력 지속을 보장하지 않는 자동 진단에서 정지 상태는 짧은 시간 뒤 Game Over로 전환했다. 이는 이동/생존 밸런스, telegraph 공정성 또는 `BAD_FRICTION`의 판정 근거가 아니다. | LIMITATION / HUMAN_RECHECK_REQUIRED |
| 물리 gamepad/touch | 연결된 물리 gamepad 또는 터치 장비가 없어 직접 관찰하지 못했다. | NOT_RUN |

이 관찰은 실제 참가자의 이해, 감정, 한국어 가독성 답변, 물리 입력 완주 또는
Human Usability / Player Experience PASS를 의미하지 않는다. 직접 참가자 세션의
모든 필수 표가 채워질 때까지 T15 게이트는 닫혀 있다.

## 2026-08-27 · 에이전트 직접 런타임 관찰 (사람 판정 대체 금지)

대상은 정확한 `main` `2b0019c73674177dc5ed99eb79dfd6b838e1d2ba`로 연 `Ninja Survival Godot (DEBUG)` 창이다. 이 기록은 Windows 화면/입력 관찰이며, 참가자의 이해·감정·가독성 답변이 아니다.

| 경로 | 직접 관찰 사실 | 증거 상태 |
| --- | --- | --- |
| 도움말 마우스 열기 | `천술류 기능 도움말`을 클릭하면 BURN → WET/SHOCK → 오행폭주 설명이 한 모달에 표시됐고, 유파 선택 화면은 뒤에 남았다. | OBSERVED |
| 모달 키보드 차단 | 모달 중 `2`를 입력해도 모달은 유지되고 전투로 전환되지 않았다. | OBSERVED |
| 닫기·포커스·키보드 선택 | `Escape`는 모달을 닫고 천술류 도움말 버튼의 포커스 테두리를 보였다. 닫은 뒤 `2`는 천술류 전투 화면으로 전환했다. | OBSERVED |
| 마우스 선택 | 재시작 뒤 천술류 선택 행을 클릭하면 `SCHOOL 천술류`, `REACTION 0 / 3`, `SEGMENT 1/4` HUD가 표시된 전투 화면으로 전환했다. | OBSERVED |
| 첫 전투 생존 | 정지 상태에서 단발 `Right` 입력만 보낸 관찰 run은 약 3초 뒤 Game Over 화면을 보였다. 이 자동 도구는 키 지속 누름을 보장하지 않으므로, 이 결과만으로 밸런스/이동 결함 또는 `BAD_FRICTION`을 확정하지 않는다. 실제 참가자 세션에서 이동 지속·초기 위험 인지와 함께 재판정한다. | LIMITATION / HUMAN_RECHECK_REQUIRED |
| 물리 gamepad/touch | 연결된 물리 장치가 없어 직접 관찰하지 못했다. | NOT_RUN |

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
| 유파 기능 도움말 | NOT_RUN | 자동 UI 회귀 + 에이전트 Windows 직접 열기·선택 차단·닫기·포커스 복귀 OBSERVED | NOT_RUN | 실제 유파별 기능 설명/가독성/터치 경험은 사람 세션에서 판정 필요 |
| Mouse | NOT_RUN | 에이전트 직접 클릭으로 도움말 열기와 천술류 선택 전환 OBSERVED | NOT_RUN | 사람 조작감/오입력 여부는 별도 |
| Keyboard/gamepad-focus | NOT_RUN | 키보드 `2` 모달 차단, `Escape` 닫기, 닫은 뒤 `2` 선택 OBSERVED; 물리 gamepad NOT_RUN | NOT_RUN | gamepad 물리 경로는 실제 장치 필요 |
| Physical touch | NOT_RUN | NOT_RUN | NOT_RUN | 실제 터치 장비 확인 필요 |

## 현재 게이트 상태

`HUMAN_QA_DEFERRED_BY_CURRENT_USER`.

사용자 제공 Work → Codex 실행 계약에 따라 현재 병합/자동화 단계에서는 사람 세션을 요구하지 않는다. 자동 테스트와 AI 관찰은 위 표의 사람 항목을 대체하지 않으며, 이후 Human QA를 재개할 때 `FAIL` 또는 `UNCLEAR`가 나오면 공유 골격의 원인을 먼저 재현·수정·재검증한다.

## 사용자 지시 반영 — 유파 기능 도움말

사용자가 네 유파의 실제 구현 방식을 선택 전에 읽을 수 있는 도움말 팝업을 지시했다. 이 보조 수단은 첫 30초 무설명 정체성 판정을 오염시키지 않도록, 프로토콜에서 첫 실행 뒤 별도 사용성 확인으로 분리한다. 자동 UI 회귀가 통과해도 설명의 이해·가독성·터치 경험은 사람 증거가 필요하다.
