# 닌자의 신 · World / Run Current Override · DEC-014~021

상태: `CURRENT_OVERRIDE / APPROVED_BY_USER_2026-08-20`
기준 branch: `docs/world-core-planning-20260820`

이 문서는 `docs/CURRENT_CONFIRMED_DECISIONS.md` 및 2026-08-20 선행 planning 문서 안에 남아 있는 과거 해석 중 **DEC-014~021과 충돌하는 부분만 보정하는 최신 복구 checkpoint**다. 기존 MVP-4 백팩/Workbench/거래/조합 규칙은 변경하지 않는다.

## 최신 우선권

### 1. 공동 지부의 역할

- 공동 지부는 20분 내내 같은 주변 맵에서 싸우는 단일 전장이 아니다.
- **Run 시작/귀환/Workbench/Fate/메타 복구 허브**다.
- 플레이어는 공동 지부에서 미방문 유파 전장을 선택해 출격하고, 각 유파 Boss 격파 후 다시 귀환한다.

### 2. 4유파 자유 순회

- 봉마·천술·귀인·흑영 4유파 전장을 한 Run에서 각각 정확히 1회 방문한다.
- 다음 전장은 **미방문 유파 중 자유 선택**한다.
- 방문 유파는 `SchoolEncounterDefinition`, 몇 번째 방문인지는 `StageDifficultyProfile(1~4)`가 결정한다.
- 약 20분은 4번째 유파 Boss까지 처리한 **4유파 순회 active-combat 목표치**다.
- 4번째 Boss 후 마지막 휴식과 별도 Run 최종보스가 존재한다.

### 3. 유파별 전용 생태계

- 각 유파는 전용 Core Monster 3종 + Elite 1종 + Boss 1종 + 기믹 라이브러리를 가진다.
- 공통 Swarm/Priority/Anchor chassis는 내부 재사용 가능하지만 행동 의미·비주얼·기믹은 유파별로 다르다.
- Stage가 뒤일수록 stat 보정뿐 아니라 유파 기믹이 `기본 → 상호작용 → 연계 → 숙련형`으로 깊어진다.
- Stage 4에서도 동시에 읽어야 하는 고급 기믹은 기본 최대 2개로 제한한다.

### 4. 유파 흔적 · 백팩 선택 자유

- 각 유파 전장에서 해당 유파 흔적을 회수한다.
- 흔적은 Run 전용 전승 잔향이며 Boss 격파 후 공동 지부에서 안정화된다.
- **DEC-019 우선:** 흔적 자체가 해당 유파 스탯/태그를 자동 강화하지 않는다.
- 흔적 안정화는 해당 유파의 인법·장비·조합 재료가 현재 Run의 기존 보상/상점 풀에 등장할 수 있는 **전승 접근권**을 연다.
- 실제 전투력은 백팩에 무엇을 획득·배치·인접·조합했는지가 결정한다.
- 플레이어는 시작 유파 심화, 방금 해방한 유파 채용, 2유파/다유파 혼합 중 자유롭게 선택한다.
- 4흔적은 마지막 휴식에서 모두 결속되지만, 결속이 백팩을 대체하는 대형 자동 버프가 되지 않는다.

### 5. 전승 접근 / 보상 풀 · DEC-021

- 첫 Vertical Slice의 19개 기본 획득 아이템은 **Universal 7 + 유파 대표 3종 × 4**의 접근 구조를 초기 authoring default로 사용한다.
- Run 시작: Universal + 시작 유파 대표 pool만 OPEN.
- 다른 유파 Boss 격파 + 흔적 안정화: 해당 유파 대표 pool OPEN.
- 흔적을 얻었다고 아이템이 자동 장착/활성화되지 않는다.
- 실제 사용은 기존 Boss Reward / Shop / Chest에서 획득한 뒤 백팩에 넣어야 발생한다.
- Boss Reward 3개 의미를 기본적으로 `현재 빌드 연속성 / 방금 해방한 유파 / 가교·범용`으로 보호한다.
- Shop/Chest는 모든 열린 item을 한 global flat array에서 바로 draw하지 않고 **pool/lane을 먼저 선택한 뒤 item을 선택**한다.
- 유파별 catalog size가 달라도 item 수가 많은 유파가 확률을 자동 독점하지 않게 한다.
- Shop은 current build를 가장 강하게 curate하고, 방금 해방한 유파는 첫 Rest에서 temporary boost를 받는다.
- Chest는 Shop보다 randomness를 유지하고 recipe completion 보장을 두지 않는다.
- `사용 유파 수 +N%` 같은 자동 다유파 보너스는 금지한다. 단일/혼합 빌드의 실제 효율 차이는 footprint, adjacency, combination, effect budget에서 발생해야 한다.

### 6. 최종재앙

- Final Boss working concept: `난세 재앙핵`.
- 원인: **4유파의 내분·경쟁적 금기술 사용 → 봉인/요맥 붕괴 → 요기 과포화 → 요괴/잠식 확대 → 4유파 전승 잔향과 요기가 응집**.
- 특정 유파나 단일 흑막이 난세 전체의 원인은 아니다.
- Final Boss:
  - Phase 1: 유파 잔향을 한 번에 하나씩.
  - Phase 2: 서로 다른 두 유파 기믹의 충돌.
  - Phase 3: 요기 과포화 자체의 고유 재앙 패턴.
- 플레이어의 4흔적은 `네 전승을 안정화·결속한 상태`, Final Boss는 `네 전승이 충돌·왜곡된 상태`라는 대비를 만든다.

### 7. 해방된 4유파의 최종전 지원

- 각 유파 Boss/대표는 단순 처치·소멸보다 **잠식/내분에서 해방·제압·정화**되는 해석을 우선한다.
- 해방된 네 유파 Boss/대표는 난세 재앙핵 최종전에서 **각자 한 번씩** 개입한다.
- 지원 여부는 플레이어가 해당 유파 인법을 백팩에 채용했는지와 무관하다. `전승 사용`은 빌드 선택이고 `유파 해방`은 세계 진행이다.
- 별도 소환 버튼 4개나 동료 관리 UI를 만들지 않고, 자동/상황 트리거의 짧은 전투 콜백을 우선한다.
- 각 지원은 `위험 완화 + 짧은 공격 창 + 서사 콜백`이며 필수 파훼나 자동 승리가 아니다.
- 기본 지원 순서는 플레이어가 유파를 평정한 순서를 따른다. 네 지원의 기대 전투가치는 정규화해 특정 방문 순서가 고정 정답이 되지 않게 한다.
- 봉마: 결계/식신으로 전장 안정.
- 천술: 요기/위험 영역을 반응으로 정류.
- 귀인: 정면 돌파로 강한 압박을 끊고 공격 창 생성.
- 흑영: 재앙핵의 순간적 약점을 표식해 취약 창 생성.
- 실제 최종 Boss 처치와 결정타의 주체는 플레이어의 백팩 빌드다.

## 명시적 supersede / amend

- `DEC-006`의 `같은 지부 주변 공간을 4단계로 확장` 해석 → **SUPERSEDED_BY_DEC-014**.
- `DEC-012`의 `선택한 플레이어 유파에 대응하는 제1 보스 1종` 해석 → **SUPERSEDED_BY_DEC-014**. 현재는 방문한 유파마다 해당 유파 전용 Boss.
- `DEC-013`의 `20분 후 바로 Run 최종 결과` 해석 → **AMENDED_BY_DEC-014**. 20분은 4유파 순회 완료 목표이고, 이후 마지막 휴식 + 별도 Final Boss.
- `DEC-015`의 과거 고정 ring 제안 → **SUPERSEDED_BY_DEC-015 APPROVED FREE ROUTE**.
- `DEC-016`의 `흔적 자체가 해당 유파를 자동 강화` 해석 → **AMENDED_BY_DEC-019**. 흔적은 전승 접근권이며 실제 파워는 백팩 선택으로 만든다.
- `DEC-017`은 공통 적 역할만으로 전장을 구성하는 과거 제안을 보정하고 유파별 전용 생태계를 우선한다.
- 최종전의 `4유파 재결속`은 **DEC-020**의 각 1회 동맹 지원으로 전투에서 직접 표현한다.
- `DEC-021`은 전승 접근권의 실제 획득 규칙을 `대표 pool 개방 + pool-first weighting`으로 구체화하며, global flat reward pool을 비채택한다.

## Production gate

- 이 문서는 planning-only다.
- 제품 코드/Scene/Resource/runtime은 사용자가 **`기획 완료`**를 명시하기 전 수정하지 않는다.

## 상세 owner

- `docs/planning/2026-08-20-four-school-circuit-final-boss-amendment.md`
- `docs/planning/2026-08-20-four-school-route-order-planning.md`
- `docs/planning/2026-08-20-school-traces-ecosystems-progressive-gimmicks.md`
- `docs/planning/2026-08-20-final-calamity-yoki-schism-planning.md`
- `docs/planning/2026-08-20-trace-build-freedom-school-boss-allies.md`
- `docs/planning/2026-08-20-school-access-reward-pool-planning.md`
