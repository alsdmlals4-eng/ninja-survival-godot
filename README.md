# Ninja Survival Godot — 닌자의 신

Godot 4.x / GDScript로 재구성 중인 `닌자 서바이벌 (닌자의 신)` 저장소다. Unity 버전은 별도 아카이브 참고자료이며, 현재 구현 정본은 이 Godot 저장소다.

## 사람용 기획서

읽기용 원고는 `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md`이며, 기술 정본은 `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`에 분리해 둔다. 이 source update의 [PDF 재발행은 main source merge 뒤 진행 중](docs/publication/NINJA_SURVIVAL_HUMAN_GDD_PDF_MANIFEST.json)이다. 이전 PDF snapshot을 current로 취급하지 말고 manifest가 `CURRENT`가 된 뒤 내려받는다.

## 제품 약속

> 네 유파 전장을 돌며 전승 접근권을 복구하고, 공간·회전·인접 기반 백팩 빌드를 완성해 난세 재앙핵을 평정하는 2D 서바이벌 로그라이크.

플레이어 감정 목표:

`살아남는다 -> 강해진다 -> 자기 방식을 만든다 -> 네 유파를 다시 잇는다 -> 이번 전선을 평정한다 -> 전설이 된다`.

## 최신 Run 목표

```text
시작 유파
-> 미방문 유파 전장 선택
-> Core Monster + Stage 기믹
-> 약 3분 유파 Elite
-> 상자 토큰 + 유파 흔적
-> 흔적 회수
-> Boss 접근 경고/이중 Gate
-> 약 5분 유파 Boss
-> RESULT / Boss Reward
-> 4유파 공동 지부 귀환
-> 흔적 STABILIZED / 전승 접근 package OPEN
-> Persistent Workbench
-> 다음 미방문 유파 provisional 선택
-> Shop / Chest / Backpack / Combination
-> Fate가 build + Fate + next route atomic commit
-> 네 유파를 정확히 한 번씩 반복
-> Final Binding Workbench
-> 별도 최종전 `난세 재앙핵`
-> 최종 결과 / Ninja Soul / 전설
```

`약 20분`은 네 번째 유파 Boss까지의 active-combat 목표치다. 전체 Run 종료 시점이 아니다.

## 현재 구현 상태

현재 product implementation 기준:

`63fcf81fdf4b5d1bbff14b5721a13f7c1afe1497` — `T16: add in-combat current school help`.

| 영역 | 상태 |
|---|---|
| MVP-0 기본 전투 | integrated |
| MVP-1 전투 DDD | integrated |
| MVP-2 4유파 얕은 runtime | integrated migration baseline |
| MVP-3 결과/GOLD/상점/Fate/3세그먼트 | integrated rollback/regression baseline |
| T01 공간 데이터 계약/catalog | integrated |
| T02 BackpackState | integrated |
| T03 BackpackResolver | integrated |
| T04 RestBackpackSession | integrated |
| T05 CombinationResolver | integrated |
| T06 committed RunBuildState modifier authority | integrated |
| T07 Boss/Shop/Chest spatial acquisition transactions | integrated |
| T08 RunRouteState four-school route domain | integrated |
| T09 encounter definitions + Stage profiles | integrated |
| T10 Elite → Trace → Boss lifecycle gate | integrated |
| T11 tradition access packages + reward lanes | integrated |
| T12 Atomic Workbench + Fate + next-route commit | integrated (machine evidence) |
| T13 Persistent Workbench route UI/input | integrated (machine evidence) |
| T14 Cheonsul release-near lifecycle slice | integrated (automated evidence only) |
| T15/T16 유파 기능 도움말 / 전투 중 현재 유파 도움말 | integrated (machine evidence) |
| Human Usability / Player Experience | NOT_RUN |
| device / Android export | NOT_RUN |

T01~T16의 자동화/도메인 증거는 해당 범위의 구현·회귀 증거다. 실제 플레이 가능한 새 Run, 완성 후보 UI/Visual/Animation/VFX/Audio, Human/Device PASS를 뜻하지 않는다.

2026-08-25 pause 때 닫힌 PR #43(T12)과 #44(front-door docs)는 **closed-unmerged historical/WIP**다. 재개 시 그대로 이어서 병합하지 않고 최신 completed `main`에서 여전히 유효한 부분만 재사용한다.

## 핵심 시스템

### 자동 생존 전투 + DDD

- 8방향 이동
- 자동 기본 공격/전투 인법
- 수동 보법/오의
- 처치 콤보 / MAX COMBO
- stylish score
- 보상 흡수 피드백
- 결과 기여도 추적

### 4유파 — 서로 다른 위험 처리 방식

- **봉마류:** 이동형 진지. 식신·결계로 공간을 준비하고 대신 싸우게 한다.
- **천술류:** 상태를 만들고 순서/조합으로 원소 반응을 일으킨다.
- **귀인류:** 위험한 근접 체류를 유지해 난전 지속력과 폭발력을 얻는다.
- **흑영류:** 위험한 표적을 표식·우선순위·처형으로 먼저 제거한다.

유파는 색/스킬명만 다른 스킨이 아니다. 같은 공통 전투/백팩 프레임 안에서 플레이어가 위험을 처리하는 판단을 다르게 만드는 것이 목표다.

### 공간 백팩 / Persistent Workbench

보호된 규칙:

- 6x6 전체 보드
- 4x3 시작 사용 영역
- 가방 구매로 사용 영역 확장
- 아이템/가방 90도 회전
- 일반 아이템은 직사각형 중심, 선택적 L/T형 가방
- 직교 인접 시너지
- 특수 가방 one-cell-overlap activation
- 6-slot REST 작업 버퍼
- explicit atomic 1차 조합
- Boss / Shop / Chest 획득 역할 분리
- preview와 실제 combat commit 분리

Architecture:

`definitions -> BackpackState -> BackpackResolver -> RestBackpackSession/CombinationResolver -> committed RunBuildState -> combat`.

**T06에서 확정된 핵심**은 최종 committed spatial snapshot이 전투 modifier의 단일 authority라는 점이다. 기존 `owned_items`는 경제/판매 호환 정보로 남을 수 있지만 전투력을 중복 적용하지 않는다.

### 흔적 / 전승 접근 / Reward Lane

```text
Elite kill
-> chest token + trace AVAILABLE
-> trace RECOVERED
-> Boss gate
-> Boss clear + branch return
-> trace STABILIZED
-> tradition access package OPEN
```

흔적 자체는 자동 버프가 아니다. 전승 접근권은 어떤 아이템이 등장할 수 있는지를 넓히고, 실제 힘은 획득한 아이템의 백팩 배치·인접·조합이 만든다.

첫 authoring 모델은 기존 19 base acquisition item을 유지한 `Universal 7 + 4유파 x 3` access package다. Boss/Shop/Chest는 하나의 평평한 전역 목록보다 lane/pool을 먼저 선택해 큰 카테고리가 확률을 독점하지 않게 한다.

### Route / Fate

- 다음 유파는 미방문 유파 중 선택한다.
- school identity와 Stage 1~4 difficulty/gimmick-depth는 별도 축이다.
- Workbench에서 다음 유파 선택은 provisional이다.
- 승인된 최종 구조에서는 Fate가 **최종 build + Fate + next route**를 atomic commit한다.
- clear order는 최종전의 유파 지원 callback 순서에 연결된다.

## 다음 제품 Gate

현재 다음 Gate는 **사용자 Vertical Slice 검증**이다. T12~T16은 최신 completed `main`에 통합되었지만, 자동 증거는 Human Usability·Player Experience·디바이스/Android export PASS가 아니다.

현재 internal Windows build는 자동 빌드/다운로드 검증용이며, 공개 배포나 Android 릴리스를 뜻하지 않는다. 적/Boss/VFX의 최종 시각 자산과 실제 플레이 감각은 별도 사용자 검증에서 확인한다.

## Human play evidence

placeholder/card/text UI는 기술 Spike와 자동 테스트에 사용할 수 있지만 Player Experience PASS에는 사용할 수 없다.

4유파 전체 콘텐츠를 복제하기 전에 천술류로 다음 release-near Slice를 먼저 증명한다:

`30초 내 유파 시그니처 -> Core -> ~3분 Elite -> trace -> ~5분 Boss -> reward -> Workbench -> next-route preview`.

검증 축:

- 첫 30초 유파 정체성 가독성
- Core→Elite→Boss tension curve
- telegraph fairness
- trace 이해
- 백팩/Route 이해
- Workbench 피로
- Korean readability
- 배치 변경이 다음 전투 기대를 실제로 바꾸는가

## 현재 승인 Visual 방향

2026-08-25 사용자 승인 기준 **첫 번째 제공 이미지의 그림체**가 현재 master style reference다.

- 어두운 달빛 닌자 판타지
- 프리미엄 painterly anime illustration
- 검정/남색/붉은색/금색 중심
- 먹·붓·캘리그래피 프레이밍
- 읽히는 캐릭터/적 실루엣과 과하지 않은 VFX
- 봉마 금색 / 천술 원소 청·주황 / 귀인 적색 / 흑영 보라·흑색 accent

밀도 높은 양피지 인포그래픽 구성은 학습/설명용 보조 표현으로 활용할 수 있지만 master gameplay art style은 아니다.

새 이미지 생성은 사용자 명시 요청이 있을 때만 `text brief -> 승인 -> 1건 생성 -> 결과 승인` 순서로 진행한다.

## 정본 / 사람용 workspace

- 제품/시스템 structured canon: repository Markdown/data/code/test
- 사람용 전체 게임 Flow·핵심 시스템·Visual 방향: Notion `닌자 서바이벌 · Home` 및 관련 Domain
- 상세 구현 증거/운영 상태: Project Registry/System + `Production · Handoff`
- Google Sheets: unique unmigrated material이 있을 때만 migration compatibility source

Human Home은 raw PR/SHA/포트/내부 라우팅을 나열하는 개발 dashboard가 아니라, **게임 전체를 이해하고 비교·수정할 수 있는 사용자용 게임 지도**로 유지한다.

## 읽기 순서

1. `AGENTS.md`
2. `docs/CURRENT_CONFIRMED_DECISIONS.md`
3. `docs/ACTIVE_CONTEXT.md`
4. `docs/canon/2026-08-21-dec014-025-product-canon.md`
5. `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
6. `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`
7. `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
8. `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`
9. 실제 `scripts/`, `scenes/`, `data/`, `tests/`, workflow
10. 정확한 Notion Human Home / Production Handoff / Visual surface
11. 현재 작업에 영향을 주는 최신 Base owner

문서와 구현이 다르면 구현 사실은 실제 code/test/runtime evidence로 확인하고, 앞으로 구현할 제품 행동은 최신 승인 Decision/Canon을 따른다.
