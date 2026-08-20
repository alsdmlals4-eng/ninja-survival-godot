# 닌자의 신 · Current Canon Checkpoint · DEC-014~023

상태: `CURRENT_OVERRIDE / USER_CONTINUATION_APPROVED_2026-08-20`
기준 branch: `docs/world-core-planning-20260820`

이 문서는 2026-08-20 Run/세계관/유파/백팩 연속 기획의 최신 복구 checkpoint다. 충돌 시 이 문서와 아래 상세 owner가 과거 2026-08-20 planning 메모보다 우선한다.

제품 코드·Scene·Resource·runtime은 이 checkpoint로 수정하지 않는다.

## 현재 Run 구조

```text
무너진 4유파 공동 지부
→ 시작 유파 선택
→ 미방문 유파 전장 자유 선택
→ Stage 1~4 번호 기반 수치 + 기믹 보정
→ 유파별 전용 Monster 3 + Elite 1 + Boss 1
→ 흔적 회수 / Boss 평정 / 지부 귀환
→ 기존 Boss Reward / Persistent Workbench / Fate
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
- DEC-021의 7+3×4를 아이템 소속표로 읽는 해석 → `AMENDED_BY_DEC-021A`.
- 과거 `최종 전승 발현 대형 버프 1택` 해석 → `SUPERSEDED_BY_DEC-022_FINAL_WORKBENCH`.
- 최초 MVP-2의 `흑영 표식 무기한` 문구 → `SUPERSEDED_BY_APPROVED_MVP3_MARK_LIFETIME / RECONCILED_BY_DEC-023`.
- `docs/planning/2026-08-20-world-run-current-override-dec014-018.md`와 `docs/planning/2026-08-20-current-canon-checkpoint-dec014-022.md`는 이 checkpoint로 대체된다.

## 미확정 / 임의 변경 금지

- 4유파 완성형 전체 스킬 pool과 signature 3종 이후 specialist roster는 미확정이다.
- 독무·번개걸음은 후속 후보이며 MVP-4 조합으로 승격하지 않는다.
- 정확한 Stage scale, Shop lane weights, Final Boss 수치는 플레이테스트용 `RECOMMENDED_DEFAULT`로 관리한다.
- 흑영 표식의 8초 정본은 확정됐지만 만료 경고 VFX와 강제 보스 전환 중 timer pause는 해당 Visual/Boss 구현 시 검증해야 한다.

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

## Production gate

이 checkpoint는 planning-only다. 사용자가 최신 전체 기획에 대해 다시 `기획 완료`를 선언하고 구현 계약이 갱신되기 전에는 제품 코드·Scene·Resource·runtime을 변경하지 않는다.
