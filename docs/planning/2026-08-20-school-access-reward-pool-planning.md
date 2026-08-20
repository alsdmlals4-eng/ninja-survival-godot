# 닌자의 신 · 유파 전승 접근 / 보상 풀 희석 방지 기획

상태: `APPROVED_BY_USER_2026-08-20`
기준 branch: `docs/world-core-planning-20260820`
선행 owner:
- `docs/planning/2026-08-20-trace-build-freedom-school-boss-allies.md`
- `docs/planning/2026-08-11-mvp4-content-balance-v1.md`

제품 코드·Scene·Resource·runtime은 사용자가 `기획 완료`를 선언하기 전 수정하지 않는다.

---

## DEC-2026-08-20-021 · 흔적은 대표 전승 풀을 열고, 보상은 pool-first weighting으로 희석을 막는다

상태: `APPROVED_BY_USER_2026-08-20`

### 목표

DEC-019의 `흔적 = 자동 강화가 아닌 전승 접근권`을 실제 획득 풀 규칙으로 내린다.

핵심 원칙:

1. 플레이어 전투력의 최종 결정권은 백팩에 있다.
2. 흔적 획득은 해당 유파를 사용할 **선택권**을 열지만 사용을 강제하지 않는다.
3. 새 유파를 열었다고 전체 보상 풀이 평평하게 합쳐져 현재 빌드 후보가 사라지지 않게 한다.
4. 유파별 아이템 수가 달라져도 큰 카탈로그를 가진 유파가 확률을 독점하지 않게 한다.
5. 기존 Boss Reward / Shop / Chest 세 획득 축을 유지하고 새 성장 화면을 만들지 않는다.

## 비교 대안

### A · 흔적 획득 즉시 해당 유파 전체 아이템을 평면 풀에 합류

장점:
- 가장 단순하다.
- 획득한 유파의 모든 기술을 즉시 볼 수 있다.

문제:
- 3~4번째 유파부터 전체 pool이 급격히 커져 현재 빌드 강화 후보가 희석된다.
- 장기적으로 유파별 item 수가 달라지면 item 수가 많은 유파가 보상을 더 많이 점유한다.
- 자유도가 오히려 `원하는 것을 못 보는 RNG`로 바뀔 수 있다.

비채택.

### B · 대표 전승 3종 + pool-first weighting · **채택**

- 시작 유파의 대표 전승 pool은 Run 시작부터 개방.
- 다른 유파는 해당 Boss 격파 + 흔적 안정화 후 **대표 인법/장비/전승 3종**이 현재 Run pool에 개방된다.
- 보상 생성은 모든 item을 한 배열에 넣고 바로 뽑지 않는다.
- 먼저 `어떤 목적/pool에서 뽑을지`를 정하고, 그 다음 해당 pool 안에서 item을 선택한다.

장점:
- 새 유파가 보상에서 보이지 않는 문제를 방지.
- 현재 빌드 강화 후보를 보호.
- 유파별 카탈로그 크기가 달라도 pool 단위 확률을 독립적으로 제어 가능.
- 기존 19-item Vertical Slice에 바로 대응 가능.

### C · 흔적 → Gateway 3종 → 그중 하나를 채용하면 전체 유파 pool 개방

장점:
- 실제로 그 유파를 쓰기로 한 플레이어만 pool을 확장하므로 희석 억제가 매우 강함.

문제:
- `해방`과 `실제 사용권` 사이에 숨은 두 번째 gate가 생김.
- Boss를 평정했는데 일부 기술이 다시 잠겨 있다는 감각을 줄 수 있음.
- 첫 제품에는 불필요한 상태 단계.

장기 specialist/deep-school content가 매우 커질 때 재검토.

### D · Boss 후 `추가 사용할 유파`를 별도 메뉴에서 선택

장점:
- 확률 제어는 쉬움.

문제:
- 백팩에서 무엇을 채용할지 결정하기 전에 별도 class-selection decision을 추가함.
- `흔적을 열되 실제 사용은 백팩 자유` 원칙과 충돌.

비채택.

---

## MVP-4 19종을 이용한 첫 Vertical Slice 접근 분류

기존 19종의 효과/footprint/가격/조합 규칙은 유지한다. 아래 분류는 **획득 가능 시점**을 위한 authoring default다.

### 항상 개방 · Universal 7

1. `fortune_talisman` · 행운 부적
2. `ninjutsu_training` · 인법단련
3. `regeneration_scroll` · 재생의 두루마리
4. `ultimate_treatise` · 오의 비전서
5. `school_emblem` · 유파 증표
6. `forbidden_talisman` · 금기의 부적
7. `bomb` · 폭탄

기존 affinity 태그는 그대로 유지할 수 있다. `Universal`은 affinity가 없다는 뜻이 아니라 **Run 시작부터 획득 pool에 들어갈 수 있음**을 뜻한다.

### 봉마 전승 대표 3

- `enlightenment` · 깨달음
- `barrier_art` · 결계술
- `greater_summoning_circle` · 대형 소환진

### 천술 전승 대표 3

- `water_style` · 수둔
- `lightning_style` · 뇌둔
- `fire_style` · 화둔

### 귀인 전승 대표 3

- `taijutsu_training` · 체술단련
- `protection_talisman` · 호신 부적
- `katana` · 일본도

### 흑영 전승 대표 3

- `shuriken` · 수리검
- `stealth_art` · 은신술
- `poison_needles` · 독침술

### 교차 유파 조합의 의미

이 분류는 기존 3개 조합을 경로/백팩 판단과 연결한다.

- `수둔 + 은신술 → 물안개`: 천술 + 흑영 전승을 모두 열면 구성하기 쉬워진다.
- `일본도 + 뇌둔 → 뇌명도`: 귀인 + 천술 전승의 교차 조합.
- `폭탄 + 화둔 → 폭렬탄`: Universal 폭탄 + 천술 전승.

조합 결과는 기존 결정대로 acquisition pool에 직접 들어가지 않고, 백팩 안에서 명시적 조합으로만 만든다.

위 7+3+3+3+3 구조는 **첫 Vertical Slice용 초기 분류**다. 장기 콘텐츠가 늘어나면 모든 유파 아이템을 3종으로 영구 제한하지 않는다. 그때도 `signature/core pool`을 먼저 열고 specialist pool 확장 규칙을 별도 검토한다.

---

## 획득처별 Pool-First 규칙

### 1. Boss Reward · quality / choice

기존 `3 options → choose 1`을 유지한다.

Boss 격파 직후 3개의 의미를 다음처럼 authoring한다.

- **Slot A · 현재 빌드 연속성**
  - 현재 백팩의 상위 active tags / 시작 유파 / 이미 채용 중인 유파를 우선.
  - `새 유파를 열었으니 무조건 갈아타라`는 압력을 막는다.

- **Slot B · 방금 해방한 유파 전승**
  - 해당 Boss의 흔적이 안정화되며 열린 대표 3종에서 최소 1개를 보장.
  - 이미 모두 보유/중복상한 문제라면 해당 유파와 연결되는 합법 후보로 fallback.

- **Slot C · 가교 / 범용**
  - Universal item, recipe completion, 현재 빌드와 새 유파 사이의 bridge candidate를 우선.

정확히 매번 `현재/신규/가교` 문구를 카드에 붙일 필요는 없지만 첫 온보딩에서는 작은 tag/icon으로 의미를 읽게 하는 것을 권장한다.

### 2. Shop · control / economy

아이템 3개 + bag 1개 구조, reroll `5G → 10G → 15G`를 유지한다.

각 아이템 offer는 전체 item 배열에서 직접 뽑지 않고 **lane/pool을 먼저 선택**한다.

초기 lane weight `RECOMMENDED_DEFAULT`:

```yaml
active_build_pool: 0.45
latest_liberated_school_pool: 0.25
other_unlocked_school_pool: 0.15
universal_pool: 0.15
```

- `latest_liberated_school_pool` 강조는 해당 Boss 직후 첫 휴식에서만 기본 적용한다.
- 이후에는 그 유파를 `other_unlocked_school_pool`로 이동시킨다.
- `other_unlocked_school_pool`에서 먼저 school을 선택한 뒤 그 school의 item을 고른다. **아이템 수가 많은 school이 확률을 자동 독점하지 않는다.**
- pool 선택 후 기존 `recipe_completion`, `matches_active_build_tag`, `duplicate penalty` 가중치를 적용한다.

### 3. Chest · quantity / randomness

Chest는 Shop의 curated copy가 되지 않는 기존 원칙을 유지한다.

초기 구조:

```yaml
universal_pool: 0.45
unlocked_school_pool: 0.55
```

- school lane이 선택되면 현재 개방된 school 중 하나를 먼저 선택하고, 그 school 안에서 item을 draw한다.
- current-build bias는 Shop/Boss보다 훨씬 작게 유지한다.
- recipe completion 전용 보장은 하지 않는다.
- 기존 `token 1 → item 2`, 같은 chest 안 id 중복 금지 권장을 유지한다.

---

## 시작 유파 / 흔적 / Pool 상태

```text
Run start
Universal pool = OPEN
Starting school signature pool = OPEN
Other 3 school signature pools = LOCKED

School Boss defeated + trace stabilized
→ that school signature pool = OPEN
→ Boss Reward Slot B guarantees one candidate from it
→ first Rest Shop gives temporary latest-liberated weighting

Player may:
- ignore it and strengthen current build
- take one or more of that school
- combine multiple schools
```

흔적 자체는 장비가 아니므로 백팩 칸을 차지하지 않는다.

---

## 장기 확장 규칙

유파별 콘텐츠가 대표 3종보다 커질 때도 **flat global pool**로 합치지 않는다.

권장 확장 구조:

```text
UniversalPool
SchoolPool[bongma]
SchoolPool[cheonsul]
SchoolPool[guiin]
SchoolPool[heukyeong]
Bridge/Recipe logic
        +
AcquisitionSourceProfile
        +
Current Backpack Tags
        ↓
Reward Candidates
```

유파별 specialist item이 매우 많아질 경우:
- `core/signature`와 `specialist` 2층을 검토할 수 있다.
- 단, `흔적은 얻었지만 아무 기술도 못 쓴다`는 상태는 만들지 않는다.

---

## 5회 적대적 검토

### Loop 1 · Pool dilution

문제: 4유파가 모두 열리면 원하는 현재 빌드 후보가 사라질 수 있다.

수정: global flat draw 금지. acquisition source가 먼저 lane/pool을 선택하고 item은 그 안에서 draw.

### Loop 2 · 새 유파가 보상에서 안 보임

문제: 흔적을 얻었는데 RNG 때문에 새 유파 기술을 한 번도 못 보면 해방 감정이 약하다.

수정: Boss Reward Slot B에서 방금 해방한 유파 대표 후보를 최소 1개 보장. 첫 Rest Shop에도 temporary weighting.

### Loop 3 · 새 유파 사용 강제

문제: 새 학교 보장이 매번 기존 빌드 후보를 밀어내면 사실상 pivot 강요.

수정: Slot A는 현재 빌드 연속성을 별도 보장하고 Slot C는 가교/범용. 사용 여부는 선택.

### Loop 4 · 다유파가 자동 최적해

문제: 유파를 많이 열수록 단순히 선택지가 많아져 다유파가 항상 우월할 수 있다.

수정: `사용 유파 수 +N%` 같은 자동 보너스 금지. 실제 효율은 footprint, adjacency, combo, effect budget으로 비용을 지불해야 한다. 단일 유파 심화도 같은 예산 규칙으로 경쟁.

### Loop 5 · 경로 순서 고정 메타

문제: 특정 교차 조합을 빨리 만들기 위해 항상 같은 유파부터 가는 정답 route가 생길 수 있다.

수정:
- Boss Reward Slot A로 기존 빌드 강화 루트를 항상 유지.
- Universal/bridge item을 활용해 한 유파가 없어도 Run이 기능하도록 함.
- StageDifficultyProfile로 늦게 방문한 유파는 강해지므로 early unlock의 이득과 encounter 난이도 선택이 trade-off가 되게 함.
- 플레이테스트에서 특정 first/second route 승률이 과도하게 높으면 item unlock 자체를 막기보다 reward weight / combo budget을 먼저 조정.

---

## 성공 기준

- 흔적을 얻은 직후 새 유파 기술을 **보고 선택할 기회**가 있다.
- 새 유파를 무시해도 현재 빌드 강화 경로가 정상 작동한다.
- 4유파가 모두 열린 후에도 Shop/Boss Reward에서 현재 빌드 관련 후보를 충분히 볼 수 있다.
- 유파별 item 수가 늘어도 catalog size가 확률을 직접 지배하지 않는다.
- `흔적 → 기술 자동 장착/자동 버프`가 발생하지 않는다.
- 단일 유파/2유파/다유파 빌드가 모두 공간·조합 비용을 지불하며 경쟁한다.

## DEC-021 최종 한 줄

**`유파 흔적은 해당 유파의 대표 전승 아이템을 Run 획득 풀에 개방한다. Boss Reward는 현재 빌드/해방 유파/가교의 세 의미를 보호하고, Shop/Chest는 pool-first two-stage sampling을 사용해 유파가 늘어나도 보상 풀이 평평하게 희석되지 않게 한다. 실제 채용과 강화는 끝까지 백팩 배치·인접·조합이 결정한다.`**
