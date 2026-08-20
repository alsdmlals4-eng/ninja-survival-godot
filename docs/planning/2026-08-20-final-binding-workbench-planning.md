# 닌자의 신 · 최종 결속 Workbench 기획

상태: `APPROVED_BY_USER_2026-08-20`
기준 branch: `docs/world-core-planning-20260820`

선행 정본:
- `docs/planning/2026-08-11-mvp4-content-balance-v1.md`
- `docs/planning/2026-08-20-dec021-item-canon-access-affinity-amendment.md`
- `docs/planning/2026-08-20-trace-build-freedom-school-boss-allies.md`
- `docs/planning/2026-08-20-final-calamity-yoki-schism-planning.md`

이 문서는 planning-only다. 제품 코드·Scene·Resource·runtime은 수정하지 않는다.

---

## DEC-2026-08-20-022 · 4흔적 결속은 별도 강화 트리가 아니라 마지막 Persistent Workbench다

상태: `APPROVED_BY_USER_2026-08-20`

### 목표

4유파 순회를 끝낸 플레이어가 `난세 재앙핵`에 들어가기 전에:

- 기존 백팩 빌드를 끝까지 다듬고,
- 이미 정한 19종 아이템과 3개 조합을 활용하며,
- 단일 유파 심화 / 2유파 혼합 / 다유파 혼합 중 자기 답을 선택하고,
- 네 유파가 다시 결속했다는 서사를 확인하게 한다.

핵심 원칙:

> **최종전의 힘도 백팩에서 만든다.**

4흔적은 새 특성 트리, 자동 스탯 버프, 무료 기술 장착이 아니다.

---

## 비교 대안

### A · 4흔적 중 하나를 골라 대형 최종 버프

장점:
- 이해가 빠르다.
- 최종전 직전 강해졌다는 감각이 분명하다.

문제:
- 백팩 밖에 별도 파워 축이 생긴다.
- 특정 Boss 패턴에 맞는 정답 흔적이 생기기 쉽다.
- 20분 동안 만든 배치/조합보다 마지막 카드 선택이 더 중요해질 수 있다.

비채택.

### B · 기존 Persistent Workbench를 `최종 결속 Workbench`로 확장 · **채택**

- 기존 RESULT → Boss Reward → Workbench → Fate 흐름을 유지한다.
- 네 유파의 접근 잠금이 모두 풀린 상태에서 기존 Shop/Chest/Backpack/Combination을 마지막으로 사용한다.
- 별도 재화·새 아이템·새 강화판을 추가하지 않는다.
- 4흔적 결속은 최종 Boss 진입 조건과 4유파 동맹 콜백 상태를 확정한다.

장점:
- 게임의 판매 포인트인 백팩 판단을 마지막까지 유지한다.
- 기존 19종·3조합·5가방을 그대로 사용한다.
- 순혈/혼합 빌드를 모두 허용한다.
- 새 시스템 제작량이 가장 적다.

### C · 4유파 전체 카탈로그에서 원하는 아이템을 자유 구매

장점:
- 최종 빌드 완성 가능성이 높다.

문제:
- RNG와 경로 선택의 의미를 지운다.
- 최종 휴식이 긴 카탈로그 쇼핑 화면으로 변한다.
- GOLD가 충분하면 사실상 원하는 정답 빌드를 보장한다.

비채택.

---

## 최종 Flow

```text
4번째 유파 Boss 격파
→ RESULT
→ 기존 Boss Reward 3 options → choose 1
→ 공동 지부 귀환
→ 4흔적 결속 연출/상태 확정
→ 최종 결속 Workbench
   ├─ Stage 4 chest token 처리
   ├─ 기존 Shop · item 3 + bag 1
   ├─ Backpack 재배치 / 회전 / 전체 이동
   ├─ Work Buffer 6 slots
   ├─ 기존 3개 조합
   └─ 기여도/조합 가능성 확인
→ 기존 네 번째 Fate 선택 · commit boundary
→ Final Preview
→ 난세 재앙핵
→ 평정 순서대로 4유파 동맹 콜백
→ 플레이어 백팩 빌드가 최종 평정
```

- 4번째 Boss Reward도 기존 `3개 중 1개` 규칙을 바꾸지 않는다.
- 최종 Workbench를 이유로 무료 아이템 4개를 지급하지 않는다.
- 별도 다섯 번째 Fate나 `결속 전용 Fate`를 추가하지 않는다.

---

## 최종 결속 Workbench에서 달라지는 것

### 1. 접근 상태

- 현재 메타에서 해금된 콘텐츠 범위 안에서 봉마·천술·귀인·흑영 signature access package가 모두 OPEN이다.
- 기존 affinity는 다대다로 유지한다.
- 시작 유파 runtime은 바뀌지 않는다.

### 2. Shop 후보 의미

기존 `item 3 + bag 1`, reroll `5G → 10G → 15G`를 유지한다.

최종 휴식의 3개 item offer는 첫 authoring에서 다음 의미를 보호한다.

- **Slot A · 현재 빌드 연속성**
  - 현재 백팩의 주요 태그, 시작 유파, 이미 사용 중인 인법/장비를 우선한다.
- **Slot B · 조합/배치 완성 가능성**
  - 보유 재료의 기존 3개 조합 완성, 강한 인접 시너지, 공간 빈칸에 합법적으로 들어갈 후보를 우선한다.
  - 합법 후보가 없으면 현재 빌드 연속성으로 fallback한다.
- **Slot C · 4유파 결속 선택지**
  - 열린 유파 package 중 하나를 먼저 균등/정규화 선택한 뒤 해당 pool 안에서 후보를 뽑는다.
  - 특정 유파 item 수가 많다고 자동 독점하지 않는다.

같은 item ID가 여러 slot/lane 자격을 가져도 최종 후보는 ID 기준으로 중복 제거한다.

### 3. Chest

- Stage 4에서 얻은 chest token만 기존 규칙대로 처리한다.
- `token 1 → item 2`, buffer 빈 슬롯 2개 미만이면 개봉 불가, token 미소비를 유지한다.
- 이전 Stage의 미개봉 token을 최종 휴식까지 이월하는 새 저장 규칙은 추가하지 않는다.

### 4. Combination

사용 가능한 조합은 기존 3개뿐이다.

- 수둔 + 은신술 → 물안개
- 일본도 + 뇌둔 → 뇌명도
- 폭탄 + 화둔 → 폭렬탄

- 독무·번개걸음은 후속 후보로 유지한다.
- 조합은 실제 백팩 안에서 유효 배치 + 직교 인접 + 명시적 조합을 요구한다.
- 최종 휴식이라고 조합 재료 조건이나 공간 비용을 면제하지 않는다.

### 5. 4흔적 결속

4흔적은:

- Final Boss 진입 조건,
- 해방된 4유파가 다시 한 전선에 섰다는 서사 증거,
- 최종전 동맹 콜백 4회의 준비 상태,
- 평정 순서 기록

을 확정한다.

4흔적은:

- 백팩 칸을 차지하지 않고,
- 자동 공격력/체력/유파 피해를 주지 않으며,
- 특정 유파 기술을 자동 장착하지 않는다.

### 6. 동맹 표시

최종 Workbench에는 평정한 순서대로 네 유파 문양/대표자의 `지원 준비 완료` 상태를 보여줄 수 있다.

- 별도 소환 버튼은 없다.
- 지원 순서 변경 UI도 만들지 않는다.
- 전투 지원의 실제 trigger는 DEC-020 Final Boss encounter가 소유한다.
- 이 표시는 전투력 계산이 아니라 여정 기억과 서사 예고다.

---

## Commit / Final Boss 진입 Gate

다음을 모두 만족해야 Final Preview와 난세 재앙핵으로 진행한다.

```yaml
four_school_traces_bound: true
four_school_route_complete: true
boss_reward_resolved: true
unopened_current_rest_chest_tokens: 0
work_buffer_items: 0
pending_bag: false
backpack_placement_valid: true
bag_connectivity_valid: true
pending_combination: false
fourth_fate_selected: true
```

- 구매나 조합 자체는 필수가 아니다.
- 이미 완성된 빌드는 아무것도 사지 않고 배치만 확인한 뒤 출격할 수 있다.
- 유효한 후보가 없다고 진행을 막지 않는다.

---

## 데이터/책임 경계

```text
ItemCanon
  이름 / 효과 / footprint / price / tags / affinities / recipes

RunAccessState
  starting_school
  stabilized_traces
  opened_signature_packages

BackpackState + Resolver
  배치 / 회전 / 인접 / 조합 / 유효성

FinalWorkbenchContext
  four_traces_bound
  final_shop_profile
  route_order
  ally_callback_readiness

→ UI Snapshot
```

UI는 후보 확률, 조합 자격, 배치 유효성을 재계산하지 않는다. Domain snapshot을 표시하고 intent만 반환한다.

---

## 5회 적대적 검토

### Loop 1 · 마지막 버프가 백팩을 무력화하는가

위험: 4흔적 결속이 큰 자동 강화가 되면 마지막 카드가 20분 빌드보다 중요해진다.

수정: 결속은 접근/진입/동맹 상태. 전투 수치는 기존 아이템과 백팩에서만 만든다.

### Loop 2 · 4유파가 모두 열려 선택 과부하가 생기는가

위험: 최종 휴식에서 19종 전체 목록을 직접 고르면 분석 시간이 과도해진다.

수정: 전체 카탈로그 선택 금지. 기존 item 3 + bag 1과 pool-first 후보 생성만 사용한다.

### Loop 3 · 조합 완성 Slot이 정답을 강제하는가

위험: Slot B가 항상 레시피를 완성하면 조합이 자동 선택이 된다.

수정: 합법적 조합/공간/중복상한을 먼저 검사하고, 강제 지급이 아니라 후보 1개를 제시한다. 플레이어는 거절할 수 있다.

### Loop 4 · 다유파가 순혈보다 항상 강한가

위험: 모든 유파가 열리므로 여러 색을 섞는 것이 자동 우위가 될 수 있다.

수정: `사용 유파 수 +N%` 보너스 금지. 혼합은 footprint·인접·재료 확보 비용을 지불하며 단일 유파 심화와 같은 효과 예산으로 비교한다.

### Loop 5 · 동맹이 주인공을 빼앗는가

위험: 4유파 지원이 Final Boss를 대신 잡으면 백팩 완성 의미가 사라진다.

수정: 동맹은 각 1회 위험 완화/공격 창만 제공한다. 실제 피해 누적·회피·결정타는 플레이어가 담당한다.

---

## 플레이테스트 / 롤백 조건

- 최종 휴식이 반복적으로 2분을 크게 넘고 피로가 높으면 전체 접근을 다시 잠그지 말고 후보 lane·조합 힌트를 더 선명하게 한다.
- Slot B가 사실상 항상 같은 조합을 강제하면 guarantee를 weighting으로 낮춘다.
- 혼합 빌드가 순혈 빌드를 지속적으로 압도하면 유파 수 보너스를 추가하지 말고 개별 아이템/조합 예산을 조정한다.
- 최종 Shop 한 번이 이전 20분보다 승패를 더 크게 결정하면 무료 지급/추가 offer/reroll을 늘리지 않고 최종 후보 가중치를 완화한다.
- 동맹 콜백 후 Boss가 과도하게 무력화되면 지원 피해가 아니라 취약 시간/위험 완화 시간을 줄인다.

## 완료 기준

1. 기존 19종·3조합·5가방 외 새 roster를 요구하지 않는다.
2. 단일 유파 심화와 혼합 빌드가 모두 합법하다.
3. 4흔적만으로 전투 modifier가 자동 적용되지 않는다.
4. 마지막 휴식도 기존 Workbench transaction/validation 규칙을 따른다.
5. 최종 Boss 진입 전 buffer·chest·pending transaction이 모두 해소된다.
6. 4유파 동맹 지원은 준비 상태만 표시하고 전투 trigger는 Final Boss가 소유한다.
7. 제품 구현/테스트/인간 QA는 이 기획 승인과 별개로 `NOT_STARTED / NOT_RUN`이다.

## 최종 한 줄

**네 유파의 결속은 새 강화 화면이 아니라, 모든 전승 접근권이 열린 마지막 Persistent Workbench에서 기존 아이템·배치·조합으로 자기 닌자 빌드를 완성하고 난세 재앙핵에 출격하는 순간이다.**