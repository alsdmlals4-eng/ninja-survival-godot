# 닌자의 신 · World / Run Current Override · DEC-014~018

상태: `CURRENT_OVERRIDE / APPROVED_BY_USER_2026-08-20`
기준 branch: `docs/world-core-planning-20260820`

이 문서는 `docs/CURRENT_CONFIRMED_DECISIONS.md` 및 2026-08-20 선행 planning 문서 안에 남아 있는 과거 DEC-006/012/013 해석 중 **DEC-014~018과 충돌하는 부분만 보정하는 최신 복구 checkpoint**다. 기존 MVP-4 백팩/Workbench/거래/조합 규칙은 변경하지 않는다.

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

### 4. 유파 흔적

- 각 유파 전장에서 해당 유파 흔적을 회수한다.
- 흔적은 Run 전용 전승 잔향이며 Boss 격파 후 공동 지부에서 안정화되어 남은 Run 동안 작은 유파 방향 효과를 제공한다.
- 4흔적은 마지막 휴식에서 모두 결속된다.
- 네 전승 중 하나의 면모를 `최종 전승 발현`으로 전면화하는 선택을 한다.

### 5. 최종재앙

- Final Boss working concept: `난세 재앙핵`.
- 원인: **4유파의 내분·경쟁적 금기술 사용 → 봉인/요맥 붕괴 → 요기 과포화 → 요괴/잠식 확대 → 4유파 전승 잔향과 요기가 응집**.
- 특정 유파나 단일 흑막이 난세 전체의 원인은 아니다.
- Final Boss:
  - Phase 1: 유파 잔향을 한 번에 하나씩.
  - Phase 2: 서로 다른 두 유파 기믹의 충돌.
  - Phase 3: 요기 과포화 자체의 고유 재앙 패턴.
- 플레이어의 4흔적은 `네 전승을 안정화·결속한 상태`, Final Boss는 `네 전승이 충돌·왜곡된 상태`라는 대비를 만든다.

## 명시적 supersede / amend

- `DEC-006`의 `같은 지부 주변 공간을 4단계로 확장` 해석 → **SUPERSEDED_BY_DEC-014**.
- `DEC-012`의 `선택한 플레이어 유파에 대응하는 제1 보스 1종` 해석 → **SUPERSEDED_BY_DEC-014**. 현재는 방문한 유파마다 해당 유파 전용 Boss.
- `DEC-013`의 `20분 후 바로 Run 최종 결과` 해석 → **AMENDED_BY_DEC-014**. 20분은 4유파 순회 완료 목표이고, 이후 마지막 휴식 + 별도 Final Boss.
- `DEC-015`의 과거 고정 ring 제안 → **SUPERSEDED_BY_DEC-015 APPROVED FREE ROUTE**.
- `DEC-017`은 공통 적 역할만으로 전장을 구성하는 과거 제안을 보정하고 유파별 전용 생태계를 우선한다.

## Production gate

- 이 문서는 planning-only다.
- 제품 코드/Scene/Resource/runtime은 사용자가 **`기획 완료`**를 명시하기 전 수정하지 않는다.

## 상세 owner

- `docs/planning/2026-08-20-four-school-circuit-final-boss-amendment.md`
- `docs/planning/2026-08-20-four-school-route-order-planning.md`
- `docs/planning/2026-08-20-school-traces-ecosystems-progressive-gimmicks.md`
- `docs/planning/2026-08-20-final-calamity-yoki-schism-planning.md`
