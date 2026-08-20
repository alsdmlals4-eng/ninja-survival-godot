# 닌자의 신 · 유파 흔적 획득 / Elite → Boss 전환 기획

상태: `APPROVED_BY_USER_CONTINUATION_2026-08-20`
결정 ID: `DEC-2026-08-20-024`
기준 branch: `docs/world-core-planning-20260820`

선행 정본:

- `docs/planning/2026-08-20-current-canon-checkpoint-dec014-023.md`
- `docs/planning/2026-08-20-school-traces-ecosystems-progressive-gimmicks.md`
- `docs/planning/2026-08-20-run-cadence-planning.md`
- `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
- `scripts/core/stage_flow_controller.gd`
- `scripts/combat/reward_orb.gd`

이 문서는 planning-only다. 제품 코드·Scene·Resource·runtime은 수정하지 않는다.

---

## DEC-2026-08-20-024 · Elite가 흔적을 드롭하고, 근접 자동 흡수 후 Boss 접근이 열린다

### 최종 한 줄

**약 3분 유파 Elite를 격파하면 상자 토큰은 즉시 지급되고 비만료 유파 흔적이 전장에 나타난다. 흔적은 별도 버튼 없이 플레이어에게 접근해 근접 자동 흡수되며, 회수 뒤 해당 Stage의 기존 유파 기믹이 Boss 예고 형태로 고조된다. 유파 Boss는 `시간 조건 + Elite 격파 + 흔적 회수`를 모두 만족한 뒤에만 등장한다.**

### 목표

- 3분 Elite, 상자 토큰, 유파 흔적, 4분대 Boss 경고, 5분대 결산을 하나의 읽기 쉬운 전투 흐름으로 묶는다.
- 흔적을 메뉴 체크박스가 아니라 플레이어가 전장에서 직접 회수한 전승으로 느끼게 한다.
- 현재 자동전투 조작 원칙을 지키며 별도 상호작용 버튼을 추가하지 않는다.
- 필수 진행 오브젝트의 유실·만료·중복으로 Run이 막히지 않게 한다.
- 흔적 회수를 이용한 무한 GOLD/DDD 파밍을 막는다.

---

## 비교 대안

### A · Elite 사망 즉시 흔적 자동 획득

장점:

- 유실과 소프트락 위험이 가장 낮다.
- 구현 상태가 단순하다.
- 전투 흐름이 끊기지 않는다.

문제:

- `흔적을 회수했다`는 공간적·시각적 사건이 약하다.
- 상자 토큰과 흔적이 동시에 UI 숫자로만 들어와 두 보상의 의미가 섞인다.
- 전승을 되찾는 세계관 감정이 단순 kill reward로 축소된다.

비채택.

### B · 비만료 흔적 드롭 → 추적 이동 → 근접 자동 흡수 · **채택**

- Elite 사망 위치에 흔적이 짧게 모습을 드러낸다.
- 잠시 뒤 플레이어를 향해 부드럽게 이동한다.
- 플레이어와 충분히 가까워지면 별도 버튼 없이 자동 흡수된다.
- 흔적은 시간 만료하지 않고 DDD 보상 구슬과 다른 domain object로 관리한다.

장점:

- 회수 순간이 눈에 보인다.
- 추가 버튼이나 정밀 클릭이 필요 없다.
- 비만료·추적·오프스크린 안내로 필수 진행 유실을 막을 수 있다.
- 기존 RewardOrb의 이동/근접 판정 원리는 재사용할 수 있으나, 흔적의 진행 권한은 별도로 둔다.

채택.

### C · 흔적 제단에서 일정 시간 머물러 안정화

장점:

- 흔적을 회수하는 의식과 유파 전장 판타지가 강하다.
- 전장 기믹을 제단 방어와 결합할 수 있다.

문제:

- 한 지점에 머물도록 강제해 서바이버 이동 재미와 충돌한다.
- 근접·원거리·장악·처형 유파의 공정성이 달라진다.
- 별도 진행 게이지와 방어 규칙이 필요하다.

비채택.

### D · 일반 적이 흔적 조각을 드롭하고 Elite가 마지막 조각을 제공

장점:

- 전장 전체에 흔적 회수 목표가 분산된다.
- 처치 진행과 유파 탐색을 긴밀하게 연결할 수 있다.

문제:

- 드롭 RNG·조각 수·진행 게이지가 추가된다.
- 5분 전투가 `조각 파밍`으로 읽힐 위험이 있다.
- 빌드 화력 차이에 따라 Boss 진입 시간이 지나치게 흔들린다.

장기 Challenge 변형 후보로만 보존한다.

---

## 확정 전투 Flow

```text
유파 전장 진입
↓
0:00~2:40
유파별 Core Monster + Stage 기믹
↓
약 2:40
Elite 경고
↓
약 2:50~3:00
해당 유파 Elite 등장
↓
Elite 격파
├─ 상자 토큰 +1 즉시 지급
├─ 신규 일반 적 spawn 일시 중지
└─ 해당 유파 흔적 출현
↓
흔적: 짧은 정착 연출 → 플레이어 추적 → 근접 자동 흡수
↓
TRACE RECOVERED
├─ 아직 직접 전투 modifier 없음
├─ 해당 Stage의 Boss 접근 조건 1개 충족
└─ 기존 유파 기믹을 Boss 예고형 cadence로 재개
↓
약 4:20 이후 + 흔적 회수 완료
Boss 경고
↓
약 4:30 이후
해당 유파 Boss 등장
↓
5:00대 결산 목표 / 미처치 시 soft overtime
↓
Boss 격파 → RESULT → Boss Reward → 공동 지부
↓
지부 귀환 시 흔적 안정화
↓
해당 유파 signature access package OPEN
```

### 시간 규칙

- 전투 시계는 Elite, 흔적 출현, 흔적 회수 중에도 멈추지 않는다.
- Boss 경고의 가장 이른 시작 목표는 약 `4:20`이다.
- Boss의 가장 이른 등장 목표는 약 `4:30`이다.
- Boss 경고는 약 `10초`의 읽기 시간을 기본값으로 둔다.
- 플레이어가 4:20 이후 흔적을 회수하면 즉시 Boss 경고를 시작하고 약 10초 뒤 Boss를 등장시킨다.
- Elite가 늦게 죽거나 흔적 회수가 늦어지면 Boss도 늦어진다.
- `5:00`은 hard fail이 아니며 조건 미완료/보스 생존 시 soft overtime으로 넘어간다.
- Elite와 유파 Boss는 동시에 활성화하지 않는다.

---

## Elite 보상과 흔적을 분리한다

### 상자 토큰

- Elite 실제 격파 시 즉시 `chest token +1`을 지급한다.
- 상자 토큰은 물리 드롭으로 만들지 않는다.
- 상자 토큰은 기존 승인대로 다음 Workbench에서 `token 1 → item 2`의 수량/랜덤 보상으로 사용한다.
- 중복 death signal이나 repeated settlement로 두 번 지급되지 않는다.

### 유파 흔적

- 같은 Elite 격파 사건이 해당 유파 흔적 1개를 전장에 생성한다.
- 흔적은 상자 토큰과 달리 **필수 진행 오브젝트**다.
- 흔적 회수는 Boss 접근을 열지만, 그 순간 해당 유파 스탯·기술을 자동 적용하지 않는다.
- Boss 격파 후 지부에서 안정화되어야 해당 유파 전승 아이템의 Run 접근 package가 열린다.

### 두 보상의 표현 순서

```text
ELITE DOWN
→ CHEST TOKEN +1
→ 유파 흔적 출현
→ TRACE RECOVERED
→ BOSS APPROACH
```

상자 토큰과 흔적을 같은 팝업 숫자로 합치지 않는다.

---

## 흔적 Pickup 규칙

초기 authoring 기본값은 다음과 같다. 수치는 `RECOMMENDED_DEFAULT`이며 플레이테스트로 조정할 수 있다.

```yaml
trace_settle_seconds: 0.40
trace_homing_delay_seconds: 0.75
trace_homing_speed_px_per_second: 260
trace_pickup_radius_px: 48
trace_lifetime: INFINITE_UNTIL_COLLECTED_OR_RUN_END
trace_fast_homing_after_seconds: 6.0
trace_fast_homing_speed_px_per_second: 520
manual_interact_button: NONE
```

### 동작

1. Elite 사망 위치에 흔적이 나타나 `0.40초` 정도 유파 문양과 실루엣을 보여준다.
2. `0.75초` 뒤 플레이어를 향해 이동한다.
3. 플레이어와 `48px` 이내가 되면 자동 흡수한다.
4. 6초가 지나도 회수되지 않으면 추적 속도를 높인다.
5. 흔적은 벽·적·위험 영역에 막히지 않는 presentation layer 이동을 우선한다.
6. 화면 밖에 있으면 방향 화살표와 유파 문양을 표시한다.
7. 색상만으로 유파와 회수 상태를 구분하지 않는다.

### 유실 방지

- 흔적은 시간 만료하지 않는다.
- 흔적 view node가 예상치 못하게 사라져도 domain의 `trace_available=true`가 유지되며 안전 위치에 view를 재생성할 수 있어야 한다.
- 동일 유파/동일 Stage의 흔적은 한 번만 회수할 수 있다.
- player death 또는 Run 종료 시에만 미회수 흔적 상태를 폐기한다.
- 흔적 회수 이벤트는 idempotent해야 한다.

### 기존 RewardOrb와의 관계

현재 RewardOrb는 5초 lifetime, DDD 보상 수 증가, 일반 전투 presentation을 가진다. 흔적은 이를 그대로 상속하지 않는다.

재사용 가능:

- target 추적 이동 수학
- collect radius 판정
- 수집 완료 후 view 정리 패턴

재사용 금지:

- 5초 lifetime
- `reward_count` 증가
- GOLD/STYLE/ORB 보상 처리
- 필수 진행 권한

즉 공통 `proximity collectible` 원리는 흡수하되, `RewardOrb`와 `SchoolTracePickup`은 서로 다른 domain event다.

---

## Trace Recovery Window · 파밍과 답답함 방지

Elite 사망부터 흔적 회수까지는 짧은 **Recovery Window**다.

- 신규 일반 적 spawn을 일시 중지한다.
- 이미 살아 있는 일반 적과 기존 위험 영역은 즉시 삭제하지 않는다.
- 흔적은 플레이어에게 이동하므로 위험 한가운데로 정밀하게 들어갈 필요가 없다.
- 전투 시계는 계속 흐른다.
- 신규 적이 계속 나오지 않으므로 흔적을 일부러 피하며 GOLD/DDD를 무한 파밍할 이득이 없다.
- 흔적 회수 후 짧은 전환 피드백 뒤 신규 spawn과 Stage 기믹을 `BossApproachProfile`로 재개한다.

Recovery Window는 별도 휴식 화면이 아니며 백팩 편집·상점·Fate를 열지 않는다.

---

## 흔적 회수 후 기믹 고조

흔적 회수는 새로운 Gimmick Tier를 몰래 추가하지 않는다.

```text
SchoolEncounterDefinition
+ StageDifficultyProfile.gimmick_tier
+ BossApproachProfile
= 흔적 회수 후 전장
```

`BossApproachProfile`은 현재 Stage에서 이미 소개한 유파 기믹을 Boss 문법으로 다시 조합한다.

- Stage 1: 기본 유파 기믹을 한 번 더 명확하게 반복.
- Stage 2: 이미 소개된 두 요소의 첫 상호작용.
- Stage 3: 기존 연계의 Boss 예고형 조합.
- Stage 4: 숙련형 조합을 사용하되 동시에 읽어야 할 고급 기믹은 최대 2개.

유파별 예고 방향:

- **봉마:** 현재 Tier의 결계/봉인점을 하나의 이동 동선 문제로 재배치.
- **천술:** 현재 Tier에서 배운 원소 영역 1~2개의 반응 지점을 명확히 예고.
- **귀인:** 접근을 유도하는 압박 뒤 큰 이탈 창을 보여 Boss의 근접 리듬을 예고.
- **흑영:** 위험 표적·표식·처형 경고의 우선순위를 읽게 하는 짧은 척살 sequence.

이 구간은 Boss의 새 규칙을 먼저 보여 주는 tutorial preview이지 별도 미니보스가 아니다.

---

## Boss 이중 Gate

Boss는 다음 조건을 모두 만족해야 한다.

```yaml
elite_defeated: true
school_trace_recovered: true
boss_earliest_time_reached: true
boss_warning_completed: true
boss_not_already_spawned: true
```

### 늦은 진행

- 4:20에 Elite가 살아 있으면 `ELITE OVERTIME` 상태를 표시하고 Boss를 겹쳐 소환하지 않는다.
- Elite 사망 후 흔적이 나타나며 Recovery Window를 거친다.
- 4:20 이후 흔적을 회수하면 즉시 10초 Boss 경고를 시작한다.
- 5:00을 넘으면 HUD는 `OVERTIME · 흔적 회수`, `OVERTIME · BOSS WARNING`, `OVERTIME · 유파 BOSS` 중 실제 milestone을 표시한다.

### Boss 시작 시

- 신규 일반 적 spawn은 기존 Boss 규칙대로 중단한다.
- 남은 일반 적을 무조건 즉시 삭제할지는 Boss별 encounter budget에서 결정하되, 첫 Vertical Slice는 Boss 가독성을 위해 소수만 보존하거나 정리하는 방향을 우선한다.
- 흔적은 이미 회수된 상태이므로 Boss 전장에 pickup이 남지 않는다.

---

## 흔적의 세 상태

```text
AVAILABLE
Elite 격파 후 전장에 존재, 아직 Boss gate 미충족

RECOVERED
플레이어가 전장에서 흡수, Boss 접근 가능, 아직 전승 아이템 접근권 없음

STABILIZED
유파 Boss 격파 후 공동 지부 귀환, 해당 유파 signature access package OPEN
```

- `RECOVERED`와 `STABILIZED`를 합치지 않는다.
- Boss 격파 전에 Run이 끝나면 회수한 흔적도 현재 Run 진행으로 확정되지 않는다.
- Boss Reward는 흔적 안정화와 연결된 새 유파 후보를 보여줄 수 있지만, 안정화 transaction은 Boss 사망 settlement와 지부 진입 사이 정확히 한 번만 발생해야 한다.
- 시작 유파의 signature package는 기존 DEC-021A대로 Run 시작부터 열려 있다.

---

## 상태·책임 경계

### 상위 Run Flow

`StageFlowController`는 계속 `COMBAT / BOSS / RESULT / REST` 같은 큰 단계만 소유한다.

현재 runtime처럼 전투 타이머 0만으로 Boss를 요청하는 구조는 최신 기획과 맞지 않으며 향후 migration 대상이다.

### Stage 내부 Milestone

별도 `SchoolEncounterController` 또는 동등한 domain unit가 다음 substate를 소유한다.

```text
WAVES
→ ELITE_WARNING
→ ELITE_ACTIVE
→ TRACE_AVAILABLE
→ BOSS_APPROACH
→ BOSS_WARNING
→ BOSS_ACTIVE
→ RESOLVED
```

권장 책임:

- Elite/Boss spawn gate
- 흔적 availability/recovery 검증
- Recovery Window spawn policy
- BossApproachProfile 적용
- overtime milestone
- duplicate settlement 방지

### RunTraceState

- 방문 유파
- recovered trace set
- stabilized trace set
- 평정 순서
- 열린 signature access package
- Final Boss의 4유파 ally callback readiness

### Pickup View

- 위치·이동·유파 문양·흡수 VFX만 담당한다.
- 흔적 보유 여부와 Boss gate를 직접 변경하지 않고 `pickup_requested(trace_id)` intent만 보낸다.
- domain이 유효성을 확인한 뒤 한 번만 `trace_recovered`를 확정한다.

### Chest Token

상자 토큰은 흔적 state와 별도 owner가 관리한다. Elite 사망 한 번으로 두 결과가 생성되지만 서로의 성공/실패를 대신하지 않는다.

---

## UI / 피드백

HUD는 새 대형 패널 대신 Stage milestone을 간결하게 보여준다.

```text
ELITE APPROACHING
ELITE
TRACE AVAILABLE · 봉마
TRACE RECOVERED · 봉마
BOSS APPROACHING
OVERTIME · TRACE
OVERTIME · BOSS
```

필수 표현:

- 상자 토큰과 흔적은 서로 다른 아이콘·음향·문구.
- 흔적은 유파 문양 + 형태 + 짧은 텍스트로 구분하며 색상 단독 의존 금지.
- 화면 밖 흔적 방향 표시.
- 회수 순간 현재 Run의 흔적 슬롯 1개가 채워지는 피드백.
- `RECOVERED`일 때 아직 전승 접근권이 열리지 않았음을 혼동시키지 않도록 `Boss 평정 후 안정화` 예고를 짧게 제공.
- Boss 경고는 화면 중앙을 장시간 가리지 않고 전투 telegraph보다 낮은 우선순위로 표시.

---

## 5회 적대적 검토

### Loop 1 · 보상 의미 충돌

위험: Elite 사망 시 상자 토큰과 흔적을 동시에 얻어 무엇이 무엇인지 모를 수 있다.

수정: 토큰은 즉시 계정형 피드백, 흔적은 별도 전장 오브젝트와 흡수 순간으로 시간차를 둔다.

### Loop 2 · 필수 Pickup 소프트락

위험: 흔적이 만료·장애물 고착·화면 밖 유실되면 Boss가 나오지 않는다.

수정: 비만료, collision-free 추적, 빠른 추적 fail-safe, 오프스크린 방향, domain 상태 기반 view 재생성.

### Loop 3 · 흔적 지연 파밍

위험: 플레이어가 Boss를 늦추며 일반 적 GOLD/DDD를 무한 획득할 수 있다.

수정: TRACE_AVAILABLE 동안 신규 일반 적 spawn을 중지하고 전투 시계는 계속 흐르게 한다.

### Loop 4 · 조작·접근성 과부하

위험: 전투 중 상호작용 버튼이나 정밀 클릭을 추가하면 이동/보법/오의 조작과 충돌한다.

수정: 48px 근접 자동 흡수, 플레이어 추적, 버튼 없음, 색상 외 문양·형태·방향 피드백.

### Loop 5 · 기믹 과밀

위험: 흔적을 먹은 뒤 새 규칙까지 추가하면 4분대가 갑자기 다른 게임처럼 변한다.

수정: 새 Gimmick Tier 금지. 현재 Stage에서 이미 배운 규칙을 BossApproachProfile로 재조합하며 Stage 4도 고급 기믹 최대 2개를 유지한다.

---

## 검증 계약

### 자동 테스트

1. Elite warning/spawn은 Stage당 정확히 한 번.
2. Elite death settlement는 chest token 1개와 trace 1개를 정확히 한 번 생성.
3. repeated death signal로 토큰·흔적 중복 없음.
4. 흔적은 lifetime 경과로 삭제되지 않음.
5. 추적 delay/속도 전환/48px 자동 흡수가 deterministic하게 동작.
6. trace pickup intent는 동일 trace ID에 한 번만 commit.
7. TRACE_AVAILABLE 동안 신규 normal spawn이 중지되고 기존 적은 유지.
8. 흔적 회수 후 BossApproachProfile과 normal spawn이 재개.
9. 시간만 충족하고 흔적이 없으면 Boss spawn 불가.
10. 흔적만 회수하고 earliest time 전이면 Boss spawn 불가.
11. 세 gate 충족 후 warning 1회, Boss spawn 1회.
12. 늦은 흔적 회수 시 즉시 warning을 시작하고 lead time 뒤 Boss spawn.
13. 5:00 이후 hard fail 없이 실제 overtime milestone 유지.
14. trace RECOVERED만으로 signature access package가 열리지 않음.
15. Boss settlement + 지부 안정화 후 package가 정확히 한 번 열림.
16. 흔적 흡수가 reward orb count, GOLD, STYLE을 증가시키지 않음.
17. 네 유파와 Stage 1~4 조합에서 같은 generic milestone contract 사용.

### Human usability

- Elite 격파 직후 상자 토큰과 흔적의 차이를 설명 없이 구분하는가.
- 흔적 회수가 정밀 조작이나 불필요한 되돌아가기로 느껴지지 않는가.
- Boss가 왜 아직 등장하지 않았는지 HUD만 보고 이해하는가.
- 3분 Elite 이후 4분대 Boss 접근이 숨 고르기이면서도 전투 리듬을 잃지 않는가.
- Stage 4에서도 흔적·적 telegraph·유파 기믹이 서로 가려지지 않는가.

### Player experience

- 흔적을 회수하는 순간 `유파 전승을 되찾았다`는 감정이 드는가.
- 회수 전후로 Boss가 가까워진다는 긴장 상승을 느끼는가.
- 흔적이 자동 버프가 아니라 이후 백팩 선택권을 여는 진행이라는 점을 이해하는가.
- 흔적을 일부러 피하며 파밍하는 행동이 이득이 되지 않는가.

---

## 명시적 보호 / 보정

- DEC-016의 `전장 후반부 흔적 회수`를 **Elite 격파 후 비만료 근접 자동 흡수**로 구체화한다.
- DEC-011/013의 `3분 Elite → 4분대 Boss 경고 → 5분대 결산 → soft overtime`을 유지한다.
- DEC-017의 유파별 Elite/Boss/기믹 생태계를 유지한다.
- 흔적은 Boss를 약화시키는 열쇠나 즉시 전투 버프가 아니다.
- 흔적 pickup은 백팩 칸을 차지하지 않는다.
- 새 상호작용 버튼, 제단 점유, 조각 파밍, 새 전투 중 선택 화면을 추가하지 않는다.
- 현재 RewardOrb의 5초 lifetime과 DDD 보상 등록을 흔적에 복사하지 않는다.
- 제품 구현·Godot 실행·GUT PASS를 이 문서가 주장하지 않는다.

## 롤백 / 재검토 조건

다음 Human play evidence가 반복되면 먼저 수치/피드백을 조정한다.

1. 흔적이 지나치게 자동으로 들어와 회수 감정이 없다 → settle/homing delay를 늘리되 비만료와 fail-safe는 유지.
2. 회수가 귀찮다 → 추적 속도·pickup radius를 늘린다.
3. 흔적이 적 공격에 가려진다 → presentation layer, offscreen indicator, outline을 강화한다.
4. Elite 이후 전투가 너무 비어 보인다 → TRACE_AVAILABLE에는 spawn 중지를 유지하되 기존 적 보존 수나 회수 후 BossApproach cadence를 조정한다.
5. Boss가 지나치게 늦어진다 → Elite HP/cadence와 warning lead를 먼저 조정하며 trace gate 자체는 제거하지 않는다.
6. 8초/10초 warning이 길다 → Boss warning lead만 조정한다.

근접 자동 흡수 자체가 반복적으로 불필요하다고 확인될 때만 A안의 즉시 획득으로 후퇴한다.
