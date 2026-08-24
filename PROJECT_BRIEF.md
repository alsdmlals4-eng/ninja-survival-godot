# PROJECT_BRIEF

## 프로젝트 한 줄 설명

`닌자의 신 / 닌자 서바이벌`은 네 유파 전장을 자유 순서로 평정하고, 유파 전승에서 얻은 인법·장비를 6x6 백팩에 배치·회전·인접·조합해 자기만의 닌자 방식을 완성하는 2D 서바이벌 로그라이크다.

## 플레이어 판타지

플레이어는 태어날 때부터 선택된 구원자가 아니라 4유파 공동 전선 지부에 남은 **미완성 닌자**다.

한 Run에서 살아남고, 네 유파의 전투 언어를 익히고, 전승 접근권을 복구하고, 제한된 백팩 공간에 자기 방식의 인법·도구 체계를 완성한다. 마지막에는 네 유파를 다시 잇고 난세 재앙핵을 평정해 후대가 `닌자의 신`이라 부를 만한 전설이 된다.

감정선:

`살아남는다 -> 강해진다 -> 자기 방식을 만든다 -> 네 전승을 다시 잇는다 -> 난세를 평정한다 -> 전설이 된다`.

## 장르 / 차별점

- 2D 탑다운 서바이벌 로그라이크
- 자동 기본 공격 + 수동 이동/보법/오의
- 4유파별 다른 위험 처리 방식
- 5분 유파 전장 cadence
- 6x6 공간 백팩 빌드
- 아이템/가방 회전·직교 인접·명시적 조합
- 전투 결과가 다음 Workbench·Route·Fate 판단으로 연결되는 반복 구조

핵심 판매 포인트는 `Vampire Survivors식 자동전투` 자체가 아니라:

> **4유파의 서로 다른 생존 철학을 익히고, 제한된 공간을 실제 전투 빌드판으로 사용하며, 다음 전장의 위험을 보고 자기 닌자 방식을 계속 재조립하는 것.**

## 전체 Run Flow

```text
시작 유파 선택
-> 미방문 유파 전장 선택
-> Core Monster + Stage 기믹
-> 약 3분 Elite
-> 상자 토큰 + 유파 흔적
-> 흔적 회수
-> Boss 접근 경고
-> 약 5분 유파 Boss
-> RESULT / Boss Reward
-> 공동 지부 귀환 / 흔적 STABILIZED / 전승 package OPEN
-> Persistent Workbench
   ├─ Boss Reward
   ├─ Shop
   ├─ Chest
   ├─ Backpack / Bag
   └─ Combination
-> 다음 미방문 유파 provisional 선택
-> Fate가 build + Fate + next route atomic commit
-> 네 유파를 정확히 한 번씩 반복
-> Final Binding Workbench
-> 별도 최종전 `난세 재앙핵`
-> 최종 결과 / Ninja Soul / 전설
```

`약 20분`은 네 번째 유파 Boss까지의 active-combat 목표치다. Final Binding과 최종 Boss는 추가 시간이다.

## 4유파

| 유파 | 위험 처리 철학 | 플레이 감정 | 백팩에서 좋은 관계 |
|---|---|---|---|
| 봉마류 | 공간을 준비하고 대신 싸우게 한다 | 이동형 진지 / 안정 / 지속 장악 | 소환 + 설치/결계 |
| 천술류 | 상태를 만들고 순서대로 반응시킨다 | setup → 반응 연쇄 / 전장 변환 | 서로 다른 원소·상태 |
| 귀인류 | 위험한 근접 체류를 유지한다 | 난전 / 압박 감수 / 돌파 | 근접 무기 + 생존/회복 |
| 흑영류 | 위험 표적을 먼저 제거한다 | 표식 / 우선순위 / 처형 | 투척·원거리 + 표식/독/처형 |

유파별 완전 독립 게임 시스템을 4개 만들지 않는다. 공통 전투·백팩·Workbench 프레임을 공유하고, 각 유파의 얕은 고유 앵커와 콘텐츠 조합으로 차이를 만든다.

## 공간 백팩 / Workbench 핵심 데이터

- 전체 보드: `6x6`
- 시작 활성 영역: `4x3`
- 가방 구매/배치로 활성 셀 확장
- 아이템·가방 `90도 회전`
- 일반 아이템은 직사각형 중심
- 선택적 L/T형 가방
- 시너지 판정: `직교 인접`
- 특수 가방: item 1칸 이상 overlap 시 효과
- REST 작업 버퍼: `6 slots`
- 1차 조합: 실제 유효 배치 + 직교 인접 + 명시 조합 + 결과 배치 성공 후 exact `2 -> 1` atomic 교체
- 획득 축: Boss / Shop / Chest
- preview/uncommitted power: 전투력 0
- committed spatial modifier snapshot: 전투력 single authority

## 흔적 / 전승 접근

```text
Elite kill
-> trace AVAILABLE
-> RECOVERED
-> Boss
-> branch return
-> STABILIZED
-> 해당 유파 tradition access package OPEN
```

흔적은 직접 공격력/체력 버프가 아니다. 어떤 전승 아이템이 Boss/Shop/Chest에 등장할 수 있는지를 연다.

첫 authoring 모델:

- Universal 7
- 봉마 3
- 천술 3
- 귀인 3
- 흑영 3

기존 총 19 base-acquisition item, 3 first-tier combinations, 5 purchasable bags의 identity와 multi-school affinity를 유지한다.

## Encounter / Stage 구조

유파별 첫 콘텐츠 상한:

- Core Monster x3
- Elite x1
- Boss x1
- bounded gimmick library

Stage 번호는 유파 identity와 별개다.

- Stage 1: base signature
- Stage 2: interaction
- Stage 3: synergy/field
- Stage 4: mastery + Boss capstone
- 동시 advanced gimmick 기본 cap: `2`

첫 release-near Vertical Slice는 **천술류**를 우선한다.

## 조작 방향

전투:

- 이동: 수동
- 기본 공격 / 전투 인법 / 장비 / 소환·장판: 자동
- 보법 / 오의: 수동

Workbench:

- item/bag 이동·회전
- six-slot buffer
- 구매/판매/상자
- 조합
- route preview/provisional selection
- Fate commit

Mouse, keyboard/gamepad focus, touch 모두 핵심 완료 경로를 가져야 한다.

## 메타 방향

Ninja Soul은 Run 판단을 무력화하는 영구 공격력/체력 누적보다 다음을 우선한다.

- 인법/장비/가방 시작 선택 폭
- 조합 힌트/도감
- 수평 해금
- convenience
- challenge condition

**Run의 힘은 Run에서 만든다.**

## 현재 비목표 / 첫 Slice 범위 보호

현재 프로젝트를 “콘텐츠가 많아야 완성”으로 오해하지 않는다. 다음은 T14~T15 대표 Slice가 사람 검증을 통과하기 전 기본 비목표다.

- 2차/3차 조합과 깊은 recipe tree를 먼저 늘리지 않는다.
- 일반 아이템을 임의 복잡 polyomino 체계로 확대하지 않는다.
- 깊은 세트·저주·희귀도 하위 시스템을 새 코어처럼 추가하지 않는다.
- 4유파의 전체 스킬풀·몬스터·Boss를 T15 전에 한꺼번에 production 제작하지 않는다.
- `보유한 유파 수 -> +N%` 같은 자동 다유파 power bonus를 추가하지 않는다.
- 공동 지부를 기지건설·경영·복잡한 자원경제 게임으로 확장하지 않는다.
- 전투 중 실시간 백팩 편집을 허용하지 않는다.
- Workbench를 mouse drag-only UX로 만들지 않는다.
- 결과/성장 추천을 강제 정답이나 AI 추천 점수로 만들지 않는다.
- 정교한 엔딩 분기와 대규모 정치 동맹 지도를 첫 Vertical Slice에 추가하지 않는다.
- 장식적 UI·VFX·아이템 수를 늘리는 것으로 핵심 재미 검증을 대체하지 않는다.

**재검토 조건:** T14~T15에서 현재 bounded 시스템만으로 유파 차이·공간 선택·다음 전투 기대가 충분히 전달되지 않는다는 Human evidence가 반복될 때만 필요한 축을 다시 연다.

## 현재 구현 현실

2026-08-25 재개 시 completed `main`:

`265bab32da087c070ea2ea0d98a3bdace1e10f7f` — T11.

- MVP-0~3 baseline: integrated
- T01~T11 domain/automated scope: integrated on merged main
- T12 atomic Workbench+Fate+next-route commit: `NOT_MERGED / NEXT FRESH PACKAGE`
- T13 persistent Workbench route UI/input: not integrated
- T14 Cheonsul release-near playable slice: not run
- Human/Player/device/export: not run

닫힌 PR #43/#44는 current authority가 아니라 historical/WIP reference다.

## 현재 승인 Visual 방향

2026-08-25 사용자가 **첫 번째 제공 이미지의 그림체**를 master style reference로 승인했다.

핵심:

- dark moonlit ninja fantasy
- premium painterly anime illustration
- ink/brush/calligraphy framing
- black/deep navy/red/warm-gold base
- school-specific accent colors
- strong silhouette and readable effects

양피지형 인포그래픽은 설명·학습용 supporting surface로는 쓸 수 있지만 master gameplay art style은 아니다.

새 이미지는 사용자 명시 요청 전에는 생성하지 않는다.

## MVP / Vertical Slice 성공 질문

1. 첫 30초에 선택 유파의 위험 처리 방식이 읽히는가?
2. 자동전투가 수동 이동/보법/오의와 함께 즉시 손맛과 판단을 주는가?
3. Core→Elite→Trace→Boss의 5분 리듬이 긴장과 결산을 만드는가?
4. 전승 접근 보상이 현재 빌드를 깊게 할지 새 유파를 섞을지 고민하게 하는가?
5. 6x6 공간·회전·인접·조합이 단순 아이템 등급보다 기억에 남는 결정을 만드는가?
6. Workbench가 관리 피로보다 다음 전투 기대를 크게 만드는가?
7. 다음 유파 선택이 현재 백팩과 실제 trade-off를 만드는가?
8. 최종 Binding/Boss가 네 유파 학습과 자기 빌드의 climax로 느껴지는가?
9. 한 판 후 다른 시작 유파·순서·조합을 시험하고 싶어지는가?

## 정본

- 현재 결정: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- mutable resume router: `docs/ACTIVE_CONTEXT.md`
- 제품 canon: `docs/canon/2026-08-21-dec014-025-product-canon.md`
- encounter canon: `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
- current migration plan: `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`
- 실제 구현: `scripts/`, `scenes/`, `data/`, `tests/`
- 사람용 전체 그림: Notion `닌자 서바이벌 · Home`