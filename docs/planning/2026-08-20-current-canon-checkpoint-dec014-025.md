# 닌자의 신 · Current Canon Checkpoint · DEC-014~025

상태: `CURRENT_OVERRIDE / USER_CONTINUATION_APPROVED_2026-08-20`
기준 branch: `docs/world-core-planning-20260820`

이 문서는 2026-08-20 Run/세계관/유파/백팩 연속 기획의 최신 복구 checkpoint다. 충돌 시 이 문서와 아래 상세 owner가 과거 2026-08-20 planning 메모보다 우선한다.

제품 코드·Scene·Resource·runtime은 이 checkpoint로 수정하지 않는다.

## 현재 Run 구조

```text
무너진 4유파 공동 지부
→ 시작 유파 선택
→ Stage 1 위험·보상 Route Preview
→ 미방문 유파 전장 선택 / 명시 출격 확인
→ Stage 1~4 번호 기반 수치 + 기믹 보정
→ 유파별 전용 Core Monster 3종
→ 약 3분 유파 Elite
   ├─ 상자 토큰 +1
   └─ 비만료 유파 흔적 출현
→ 흔적 추적 이동 / 근접 자동 흡수
→ 기존 유파 기믹의 BossApproachProfile
→ 약 4분대 경고 / 유파 Boss
→ Boss 평정
→ RESULT / 기존 Boss Reward
→ 공동 지부 귀환 / 흔적 안정화
→ Persistent Workbench
   ├─ Shop / Chest / Backpack / Combination
   └─ 미방문 유파 위험·보상 Preview / provisional route 선택
→ Fate가 백팩 + 운명 + 다음 유파를 함께 commit
→ Final Preview / 다음 COMBAT
→ 4유파 모두 한 번씩 완료 · 약 20분 active combat
→ 4흔적 결속 / 최종 결속 Workbench
→ 별도 Final Boss `난세 재앙핵`
→ 평정 순서대로 4유파 동맹 콜백 각 1회
→ 플레이어 백팩 빌드가 최종 평정
```

## DEC-014 · 4유파 순회 + 별도 Final Boss

- 한 Run에서 봉마·천술·귀인·흑영 전장을 각각 정확히 1회 방문한다.
- 약 20분은 네 번째 유파 Boss까지 처리한 4유파 순회 active-combat 목표다.
- 네 번째 Boss 뒤 마지막 휴식과 별도 Final Boss가 존재한다.

## DEC-015 · 다음 유파 자유 선택 + Stage 보정

- 다음 전장은 미방문 유파 중 자유 선택한다.
- `school_id`는 전장/적/Elite/Boss/기믹 정체성을 정한다.
- `stage_index 1~4`는 HP·피해·spawn·cadence와 유파 기믹 깊이를 정한다.
- 고정 순회와 24개 순열별 수작업 stat table은 사용하지 않는다.

## DEC-016 / 019 / 021A · 흔적, 전승 접근, 기존 아이템 정본

- 흔적은 Run 전용 전승 잔향이며 백팩 칸을 차지하지 않는다.
- 흔적은 해당 유파 기술을 자동 장착하거나 스탯을 자동 강화하지 않는다.
- Boss 평정과 흔적 안정화는 해당 유파 signature access package를 연다.
- 실제 사용은 기존 아이템을 획득해 백팩에 배치·인접·조합해야 발생한다.
- 기존 19종 아이템, 3조합, 5가방, 가격, footprint, 효과, 태그, affinity는 `2026-08-11-mvp4-content-balance-v1.md`를 보호한다.
- `always-open 7 + signature package 3×4`는 첫 Vertical Slice 접근 시점 기본값이지 아이템 소속표가 아니다.
- affinity는 다대다이며 접근 package/보상 lane과 독립이다.

## DEC-017 · 유파별 전용 Encounter 생태계

- 각 유파는 Core Monster 3종 + Elite 1종 + Boss 1종 + 기믹 library를 가진다.
- 내부 Swarm/Priority/Anchor chassis는 재사용할 수 있으나 행동 의미·비주얼·기믹은 유파별로 달라야 한다.
- Stage가 뒤일수록 `기본 → 상호작용 → 연계 → 숙련형`으로 기믹이 깊어진다.
- Stage 4에서도 동시에 읽어야 하는 고급 기믹은 기본 최대 2개다.

## DEC-018 · 난세 재앙핵

- 원인: 4유파 내분·경쟁적 금기술 사용 → 봉인/요맥 붕괴 → 요기 과포화 → 요괴/잠식 확대 → 왜곡된 4유파 전승 잔향 응집.
- 단일 흑막이나 특정 유파 하나가 난세 전체의 원인이 아니다.
- Final Boss는 유파 잔향 단독 → 두 유파 충돌 → 요기 과포화 고유 재앙으로 상승한다.

## DEC-020 · 4유파 동맹 콜백

- 유파 Boss/대표는 단순 처치·소멸보다 잠식/내분에서 해방·제압·정화되는 해석을 우선한다.
- Final Boss에서 평정 순서대로 각 1회 지원한다.
- 지원은 백팩 채용 여부와 무관한 세계 진행 보상이다.
- 별도 소환 버튼 없이 자동/상황 trigger로 위험 완화와 짧은 공격 창만 제공한다.
- 실제 승리와 결정타는 플레이어가 담당한다.

## DEC-021 · Pool-first reward

- Boss Reward는 현재 빌드 연속성 / 방금 해방한 유파 / 가교·범용의 의미를 보호한다.
- Shop/Chest는 flat global draw가 아니라 pool/lane을 먼저 선택한 뒤 item을 선택한다.
- 같은 item이 여러 lane 자격을 얻어도 canonical ID로 중복 제거한다.
- 접근 package와 기존 affinity를 혼동하지 않는다.
- DEC-024의 안정화 순서와 호환하기 위해, Boss 격파 직후 강제 Boss Reward 1회에는 해당 유파 signature package의 Slot B 후보를 만드는 `BOSS_REWARD_PROVISIONAL_ACCESS`만 허용한다.
- full package는 공동 지부 귀환에서 흔적이 STABILIZED된 뒤에만 이후 Shop/Chest/Boss Reward pool에 OPEN한다.

## DEC-022 · 최종 결속 Workbench

- 4흔적 결속은 별도 최종 버프나 특성 트리가 아니다.
- 4번째 Boss 뒤 기존 Boss Reward 3택을 처리하고 공동 지부의 마지막 Persistent Workbench로 들어간다.
- 현재 메타 해금 범위 안에서 네 유파 signature access package가 모두 열린다.
- 기존 item 3 + bag 1 Shop, Stage 4 chest, 6-slot buffer, 백팩 편집, 기존 3조합, 네 번째 Fate를 사용한다.
- 무료 아이템 4개, 무한 reroll, 새 화폐, 새 final-only roster, 별도 다섯 번째 Fate를 추가하지 않는다.
- Shop 3 item offer의 의미는 현재 빌드 / 조합·배치 완성 / 정규화된 4유파 선택지를 우선한다.
- 4흔적 결속은 Final Boss 진입과 동맹 callback readiness를 확정할 뿐 직접 modifier를 주지 않는다.

## DEC-023 · 흑영 암영표식 지속시간 정본 보정

- 최초 MVP-2의 `표식 무기한` 문구는 후속 승인 MVP-3 설계·구현으로 대체됐다.
- 암영표식은 대상별 **기본 8.0초 갱신형**이다.
- 1~2중첩에 새 표식을 부여하면 남은 시간이 현재 유효 지속시간 전체로 갱신된다.
- 지속시간 종료 시 해당 대상의 모든 미폭발 표식과 배지가 일괄 제거되며 피해·Burst를 발생시키지 않는다.
- 살아 있고 유효한 대상의 활성 표식만 암영처형 준비 합계에 포함한다.
- 오의 비전서와 봉인의 길 준비 보정은 기존 `heukyeong_mark_duration_pct`를 통해 지속시간을 늘린다.
- 초기 예: 기본 8.0초 / 오의 비전서 1개 10.0초 / 오의 비전서 1개 + 봉인의 길 보정 12.4초.
- 암영처형 준비 기준은 후속 수동 조정대로 활성 표식 합계 `3`을 유지한다.
- Stage가 올라간다고 플레이어 표식 지속시간을 숨겨서 단축하지 않으며, 일반 적·Elite·Boss에 표식 완전 면역을 기본 부여하지 않는다.
- 최종 Visual 단계에서는 만료 약 2초 전 색상 외 맥동/외곽선 변화로 경고하는 방향을 우선한다.

## DEC-024 · 유파 흔적 획득 / Elite → Boss 전환

- 약 3분 유파 Elite 실제 격파 시 상자 토큰을 즉시 1개 지급하고, 해당 유파 흔적을 Elite 사망 위치에 생성한다.
- 상자 토큰은 계정형 Run 보상이며 물리 드롭으로 만들지 않는다.
- 흔적은 필수 진행 오브젝트이며 시간 만료하지 않는다.
- 흔적은 짧은 정착 연출 뒤 플레이어를 추적하고 `48px` 근접 시 별도 버튼 없이 자동 흡수한다.
- 초기 authoring 기본값은 settle `0.40초`, homing delay `0.75초`, speed `260px/s`, 6초 뒤 fast homing `520px/s`다.
- 흔적이 `TRACE_AVAILABLE`인 동안 신규 일반 적 spawn을 중지하고 기존 적·위험 영역은 유지한다. 전투 시계는 계속 흐른다.
- 흔적 회수 후 신규 spawn과 Stage 기믹을 `BossApproachProfile`로 재개한다.
- BossApproachProfile은 새 Gimmick Tier를 추가하지 않고 현재 Stage에서 이미 학습한 유파 기믹을 Boss 예고형으로 재조합한다.
- Boss는 `Elite 격파 + 흔적 회수 + 약 4:20 earliest time + Boss warning 완료`를 모두 만족해야 등장한다.
- 약 4:20 이후 늦게 흔적을 회수하면 즉시 약 10초 Boss 경고를 시작한다.
- 5:00은 hard fail이 아니며 실제 milestone에 따라 `OVERTIME · TRACE / BOSS WARNING / BOSS`를 표시한다.
- 흔적은 `AVAILABLE → RECOVERED → STABILIZED`의 세 상태를 가진다.
- `RECOVERED`는 Boss gate만 열며 전투 modifier나 전승 아이템 접근권을 주지 않는다.
- Boss 격파 후 RESULT와 기존 Boss Reward를 처리하고 공동 지부로 귀환할 때 `STABILIZED`가 되어 해당 유파 signature access package를 연다.
- 현재 RewardOrb의 추적/근접 판정 원리는 재사용할 수 있으나 5초 lifetime, DDD reward count, GOLD/STYLE 처리는 흔적에 재사용하지 않는다.
- 상위 StageFlow와 별도로 `SchoolEncounterController` 또는 동등한 unit가 `WAVES → ELITE_WARNING → ELITE_ACTIVE → TRACE_AVAILABLE → BOSS_APPROACH → BOSS_WARNING → BOSS_ACTIVE → RESOLVED`를 소유한다.

## DEC-025 · 다음 유파 위험·보상 Preview / Commit

- 다음 유파 선택에는 미방문 후보의 위험·보상 Preview 카드를 사용한다.
- 공통 Stage header는 `다음 출격 N/4`, 위험 I~IV, `기본/상호작용/연계/숙련`, 상대 내구·피해·spawn 압박을 표시한다.
- 각 유파 카드에는 전투 철학, 현재 Stage 추가 기믹, Monster/Elite/Boss 핵심 위험, 흔적 안정화 후 열리는 대표 전승, 현재 백팩 tag/recipe 연결, 최종전 지원 순서를 표시한다.
- 정확한 HP·피해 multiplier, spawn 시각표, attack cooldown, Shop/Chest 결과, 승률·추천 점수는 표시하지 않는다.
- 첫 전장은 시작 유파 선택 뒤 별도 Route Preview에서 명시적으로 확정한다.
- Stage 2~4의 route는 Persistent Workbench 안에서 provisional selection하며 Fate 전까지 무료로 변경할 수 있다.
- Fate가 committed backpack snapshot, selected Fate, next school, next stage를 하나의 transaction으로 확정한다.
- route를 선택하지 않은 상태에서는 Fate commit을 거절하고 route panel로 focus를 돌린다.
- Stage 4는 남은 유파 1개를 자동 provisional select하되 카드와 추가 기믹은 자동 확장해 보여준다.
- Route History Strip은 평정 순서와 Final Boss 4유파 지원 순서를 기억시킨다.
- UI는 `RouteSelectionSnapshot`을 렌더링하고 intent만 emit하며 위험·tag·recipe·방문 가능성을 재계산하지 않는다.
- Windows는 4/3/2/1 후보에 맞는 grid/detail layout, Android는 1-card pager + 명시 이전/다음 + 고정 confirm을 기본으로 한다.
- hover, swipe, long-press, 색상만으로 핵심 정보를 전달하지 않는다.

## 시작 유파 기술 보호

| 유파 | 전투 인법 | 보조 인법 | 고유 축 | 오의 |
|---|---|---|---|---|
| 봉마 | 공격형 식신 | 영력 순환 | 영력 | 백귀야행 |
| 천술 | 화둔·염옥진 | 오행순환 | 오행 반응 | 오행폭주 |
| 귀인 | 혈난무 | 광전사 | 귀혈 | 귀인화 |
| 흑영 | 만천화우 | 암살교범 | 암영표식 | 암영처형 |

- 시작 기술 kit와 백팩 인법/장비는 별도 계층이다.
- 다른 유파 흔적이 시작 runtime을 교체하지 않는다.

## 명시적 supersede / amend

- DEC-006의 같은 지부 주변 4단계 전장 해석 → `SUPERSEDED_BY_DEC-014`.
- DEC-012의 선택 유파 대응 단일 Boss 해석 → `SUPERSEDED_BY_DEC-014/017`.
- DEC-013의 20분 직후 Run 종료 해석 → `AMENDED_BY_DEC-014`.
- DEC-015의 고정 순환 제안 → `SUPERSEDED_BY_DEC-015_FREE_ROUTE`.
- DEC-016의 흔적 자동 유파 강화 해석 → `AMENDED_BY_DEC-019`.
- DEC-016의 모호한 `전장 후반부 흔적 회수` → `SPECIFIED_BY_DEC-024_ELITE_DROP_AND_PROXIMITY_ABSORB`.
- DEC-021의 7+3×4를 아이템 소속표로 읽는 해석 → `AMENDED_BY_DEC-021A`.
- DEC-021의 Boss Reward Slot B와 DEC-024 안정화 순서의 모호성 → `RECONCILED_BY_DEC-025_PROVISIONAL_BOSS_REWARD_ACCESS`.
- 과거 `최종 전승 발현 대형 버프 1택` 해석 → `SUPERSEDED_BY_DEC-022_FINAL_WORKBENCH`.
- 최초 MVP-2의 `흑영 표식 무기한` 문구 → `SUPERSEDED_BY_APPROVED_MVP3_MARK_LIFETIME / RECONCILED_BY_DEC-023`.
- `Fate 종료 뒤 처음 route 선택` 해석 → `SUPERSEDED_BY_DEC-025_WORKBENCH_PROVISIONAL_ROUTE`.
- 현재 runtime의 `timer 0 → 즉시 Boss request`, 3 segment 고정, route state 부재는 향후 migration 대상이다.
- `docs/planning/2026-08-20-world-run-current-override-dec014-018.md`, `docs/planning/2026-08-20-current-canon-checkpoint-dec014-022.md`, `docs/planning/2026-08-20-current-canon-checkpoint-dec014-023.md`, `docs/planning/2026-08-20-current-canon-checkpoint-dec014-024.md`는 이 checkpoint로 대체된다.

## 미확정 / 임의 변경 금지

- 4유파 완성형 전체 스킬 pool과 signature 3종 이후 specialist roster는 미확정이다.
- 독무·번개걸음은 후속 후보이며 MVP-4 조합으로 승격하지 않는다.
- 정확한 Stage scale, Shop lane weights, Final Boss 수치는 플레이테스트용 `RECOMMENDED_DEFAULT`로 관리한다.
- 흑영 표식 만료 경고 VFX와 강제 보스 전환 중 timer pause는 해당 Visual/Boss 구현 시 검증해야 한다.
- 흔적 pickup의 정확한 최종 실루엣·음향·유파별 VFX는 Visual 단계에서 확정한다.
- Elite/Boss의 최종 이름과 아트는 working name을 그대로 확정하지 않는다.
- Route Preview 카드의 최종 아트·spacing·animation은 Visual/UI 단계에서 확정한다.
- Route Preview는 정확한 수치표나 AI 추천 점수로 확대하지 않는다.

## 상세 owner

- `docs/planning/2026-08-20-four-school-circuit-final-boss-amendment.md`
- `docs/planning/2026-08-20-four-school-route-order-planning.md`
- `docs/planning/2026-08-20-school-traces-ecosystems-progressive-gimmicks.md`
- `docs/planning/2026-08-20-final-calamity-yoki-schism-planning.md`
- `docs/planning/2026-08-20-trace-build-freedom-and-school-boss-allies.md`
- `docs/planning/2026-08-20-school-access-reward-pool-planning.md`
- `docs/planning/2026-08-20-dec021-item-canon-access-affinity-amendment.md`
- `docs/planning/2026-08-20-final-binding-workbench-planning.md`
- `docs/planning/2026-08-20-heukyeong-mark-duration-canon-reconciliation.md`
- `docs/planning/2026-08-20-school-trace-acquisition-encounter-flow.md`
- `docs/planning/2026-08-20-next-school-route-preview-planning.md`

## Production gate

이 checkpoint는 planning-only다. 사용자가 최신 전체 기획에 대해 다시 `기획 완료`를 선언하고 구현 계약이 갱신되기 전에는 제품 코드·Scene·Resource·runtime을 변경하지 않는다.
