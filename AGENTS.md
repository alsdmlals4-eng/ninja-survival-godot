# 닌자의 신 — 프로젝트 AI 작업 안내

대상: alsdmlals4-eng/ninja-survival-godot, Godot 4.x / GDScript.
Unity archive는 참고 자료이며 그대로 포팅할 설계 원본이 아니다.
이 파일은 항상 필요한 경계와 읽기 경로만 소유한다. 기획 수치·구현 이력·상세 절차는 복제하지 않는다.

## 1. 먼저 읽을 것

1. 최신 사용자 요청과 이 파일을 읽는다.
2. [현재 결정](docs/CURRENT_CONFIRMED_DECISIONS.md)과 [재개 상태](docs/ACTIVE_CONTEXT.md)에서 승인 범위·현재 작업을 찾는다. 관련된 canon만 읽는다.
3. 원격 최신 main, 현재 브랜치·미커밋 변경, 실제 대상 코드·씬·데이터·자산 사용처·테스트, 같은 작업의 열린/최근 PR을 대조한다.
4. [프로젝트 작업 계약](docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md)을 적용한다. [Base 채택 기록](docs/BASE_RULES_VERSION.md)과 최신 Base의 차이를 구분한다.
5. [문서 지도](docs/DOCUMENTATION_MAP.md)와 작업 계약의 조건부 스킬 표에서 이번 작업에 필요한 경로만 선택한다. 선택한 지침은 끝까지 읽되 전체 skills·과거 문서·PDF를 매번 읽지 않는다.

충돌 우선순위: 최신 사용자 지시 → 프로젝트 안전·엔진·데이터 경계 → 현재 승인 결정과 해당 canon → 승인 작업 계약 → Active Context/실제 구현 증거 → 채택한 Base → 최신 Base 원격 → 외부 사례·과거 대화.
실제 코드가 다르다는 이유로 승인 기획을 바꾸지 않는다. 결정은 의도를, 코드와 실행 증거는 구현 현실을 증명한다. 차이는 기록하고 승인 범위에서 교정한다.

## 2. 계획·승인·계속 작업

- 새 변경은 의도, 현재 상태, 바꿀 것/보호할 것, 구현 방법, 완료·검증 기준을 먼저 짧게 설명하고 승인받는다. 읽기 전용 조사에는 변경 승인을 만들지 않는다.
- 같은 승인 범위의 ‘진행해’·‘계속해’·‘재개’는 기존 승인과 계획을 복원해 이어간다. 구현·교정·검증·허용된 정상 병합마다 재승인하지 않는다.
- 기획 핵심·주요 UX·저장 호환성·범위·비용·보안·파괴적 변경은 다시 결정받는다. 파일에서 확인할 사실이나 범위 안 기술 판단은 사용자에게 떠넘기지 않는다.
- 기존 구현·승인 자산·유효한 조사부터 재사용한다. 새 판단에 근거가 부족하거나 바뀐 경우만 추가 조사한다. 실패한 필수 근거에 의존하는 작업만 보류하고 독립 승인 작업은 계속한다.
- 플레이 경험을 바꾸는 기능은 [작업 계약의 재미 검증](docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md#11-닌자의-신-재미-검증과-표현-명세-연결)으로 경험 가설·규칙/표현·실제 사용처·반증을 연결한다. 자동 검사 통과는 재미 통과가 아니다.

## 3. 보호할 내용

- 제품 규칙은 [Decision ledger](docs/CURRENT_CONFIRMED_DECISIONS.md)와 연결된 canon을 따른다. [DEC-037](docs/canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md)의 공간/Workbench 보호 규칙을 변경 없이 유지한다. UI는 표시·입력 의도만, 도메인은 합법성·경제·경로·원자적 확정을 소유한다.
- 게임 코드·씬·데이터·저장 호환성·엔진 pin·승인 자산을 운영 규칙 정리나 최신 Base 동기화에 끼워 바꾸지 않는다. 중복 wave/autoload/save 체계를 필요·승인 없이 만들지 않는다.
- 이미지 작업은 [시각 정본](docs/CURRENT_VISUAL_HANDOFF.md)과 [DEC-034](docs/canon/2026-08-28-dec034-generate-then-approve-visual-workflow.md)의 실제 사용처·후보·LOCK·등록·런타임 검증 경계를 따른다. 생성 성공은 사용자 승인이나 게임 연결 완료가 아니다.
- [저장소 전용 정책](docs/canon/2026-08-28-dec035-repository-only-project-record.md)을 유지한다. 이관 완료 Notion은 역사 자료이며 다시 검색·수정·완료 확인을 요구하지 않는다. PDF/채팅/기억은 독립 정본이 아니다.
- 설치 플러그인·전역 설정·외부 계정·신규 과금은 임의로 바꾸지 않는다. 기본 추가 금전 비용은 0이다.
- 다른 PR·작업 폴더·사용자 변경·출처 불명 파일은 보호한다. 오래된 이름만으로 삭제하지 않는다. 폐기 후보는 사용처·복구 경로 확인 후 사용자 삭제 검토로 넘긴다.

## 4. 검증·Git·보고

- 변경에 맞는 검사를 실행한다. Godot 작업일 때만 정확한 project.godot·엔진·편집기/실행 세션을 확인한다. 문서만 바꿀 때 불필요한 엔진·도구 설치를 요구하지 않는다.
- 검토 예산과 완료 절차는 [작업 계약](docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md)이 소유한다. 필수 테스트·CI·실제 실행이 필요한 acceptance는 생략하지 않는다.
- 정적 검사, 자동 테스트, runtime/input, render, Human/Player, 기기/export, 출시를 구분한다. 실행하지 않은 것은 NOT_RUN; 문서·테스트 통과로 다른 증거를 대신하지 않는다.
- 새 작업은 최신 완료 main에서 격리한다. 이번 승인 작업의 명확한 PR만 exact-head 검사·review·미해결 thread·ruleset 확인 후 정상 병합하고 새 main을 재확인한다. 다른 open/draft PR은 읽기 전용이다. force push·direct-main push·admin/ruleset 우회는 금지한다.
- 현재 상태·다음 작업은 기존 Active Context에, 일지는 기존 기록에 날짜별로 누적한다. 전체 PDF는 검토·의미 있는 마일스톤·최종 인도 때 갱신하고 중간 수정마다 새 보고서를 만들지 않는다.
- 한국어로 결과 → 이유/작동 방식 → 직접 확인 방법 → 검증·남은 위험 순으로 짧게 보고한다. 상세 증거는 저장소/PR에 연결하고 작은 작업마다 장문의 고정 목차를 반복하지 않는다.
