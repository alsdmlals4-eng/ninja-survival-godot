# Ninja Survival Godot

`닌자 서바이벌`의 Godot 4.x 재구현 저장소다.

기존 Unity 구현은 별도 아카이브 저장소에 보존하고, 이 저장소에서는 Godot + GDScript 기준으로 재설계한다.

## 관련 저장소

- Unity 보존 저장소: `alsdmlals4-eng/ninja-survival-unity-archive-Unity-`
- Godot 전환 저장소: `alsdmlals4-eng/ninja-survival-godot`

## 핵심 방향

- Unity 코드를 그대로 번역하지 않는다.
- Unity 구현은 참고 자료로만 사용한다.
- Godot 4.x의 Scene/Node/GDScript 구조에 맞춰 재설계한다.
- MVP는 완성판이 아니라 핵심 재미 검증판이다.
- 각 Codex Goal은 작게 쪼개되, 전체 기획 MVP는 전투 DDD, 4유파, 휴식/백팩/운명/결과 루프까지 연결되는지 검증한다.

## 핵심 소개

`닌자 서바이벌`은 유파 인법을 모으고 백팩에 배치해 나만의 닌자 빌드를 완성하는 2D 서바이벌 로그라이크다.

보조 세계관 방향은 분열된 닌자 유파의 힘을 계승해 혼란한 세계를 바로잡는 인법 조합 로그라이크다.

## 현재 단계

- MVP-0 기본 전투 기반: integrated.
- MVP-1 전투 DDD: integrated.
- MVP-2 4유파 얕은 구현: integrated.
- MVP-3 스테이지 결과/휴식/상점/운명: integrated.
- MVP-4 백팩/조합: **design complete, written-spec review pending; implementation not started**.
- MVP-5 최종 루프: not started.

구현/검증 상태는 `docs/ACTIVE_CONTEXT.md`, 현재 승인된 설계 결정은 `docs/CURRENT_CONFIRMED_DECISIONS.md`를 우선한다.

## 현재 MVP 정의

현재 MVP는 `MVP-0`부터 `MVP-5`까지 나누어 검증한다.

| 단계 | 목표 | 핵심 검증 |
|---|---|---|
| MVP-0 | 기본 전투 기반 | 이동, 카메라, 적 추적, 자동 공격, 피격/처치, 게임오버 |
| MVP-1 | 전투 DDD | 처치 콤보, 스타일리쉬 점수, 보상 흡수감 |
| MVP-2 | 4유파 얕은 구현 | 봉마류/천술류/귀인류/흑영류의 플레이 감정 차이 |
| MVP-3 | 스테이지/결과/휴식 | 5분 전투 세그먼트, 중간 결과, 휴식 판단, 운명 선택 |
| MVP-4 | 백팩/조합 기초 | 6x6 보드, 4x3 시작 공간, 가방 확장, 회전, 인접 시너지, 작업 버퍼, 조합 |
| MVP-5 | 최종 루프 | 20분 구조, 최종 보스, 최종 결과, 닌자소울 획득 |

## MVP에 포함되는 핵심 시스템

- 8방향 이동과 자동 공격 전투
- 처치 콤보와 스타일리쉬 점수
- 보상 흡수 피드백
- 4유파 선택과 얕은 고유 시스템
- 각 5분 전투 세그먼트의 약 3분대 엘리트/중간보스와 5분대 세그먼트 보스
- 딜량, 힐량, 방어량, 상태이상 부여, 콤보/처치 기여도 결과 카드
- 보스 보상 `3 choose 1`
- 휴식 Persistent Workbench: 상자, 상점, 백팩, 6-slot 작업 버퍼, 조합
- 백팩: 고정 6x6 보드, 4x3 시작 공간, 가방 확장, 아이템/가방 90도 회전, 직교 인접 시너지, 일부 L/T형 가방
- 명시적 1차 조합과 단계적 조합 힌트
- 운명 선택: 보상과 대가가 함께 있는 한 판 규칙 변경
- 최종 결과: 닌자 랭크, 스타일리쉬 점수, MVP 인법/장비, 운명 결과, 짧은 결말문, 닌자소울

## MVP에서 제외되는 것

- 4유파 전체 스킬풀
- 2차/3차 조합
- 임의의 복잡한 일반 아이템 polyomino 시스템
- 깊은 세트/저주 시스템
- 정교한 엔딩 분기와 엔딩 CG
- 완전한 상점 경제와 최종 리롤 밸런스
- 화려한 UI/애니메이션 전체 제작
- 복잡한 보스 패턴 전체

MVP-4에는 **아이템/가방 90도 회전과 선택적 비정형 가방이 포함**된다. 과거의 회전 제외 문구를 복원하지 않는다.

## 현재 읽기 순서

1. `AGENTS.md`
2. `docs/CURRENT_CONFIRMED_DECISIONS.md`
3. `docs/ACTIVE_CONTEXT.md`
4. `MVP_ROADMAP.md`
5. `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` — written-spec review branch에서 사용
6. 실제 코드/Scene/Test

## 실행 기준

Godot 4.x 기준으로 `project.godot`을 연다. 실제 MVP-4 구현은 written-spec review와 후속 implementation plan이 승인되기 전 시작하지 않는다.