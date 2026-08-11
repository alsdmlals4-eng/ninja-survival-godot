# MVP-4 Backpack / Survivors Benchmark & Industry Review

```yaml
research_id: RES-2026-08-11-MVP4-BACKPACK-SURVIVORS
feature: MVP-4 Backpack / Combination Basics
status: CURRENT_PLANNING_EVIDENCE
work_mode: PLAN
observed_at: 2026-08-11
project_baseline: ac497904ad002974515c890dc55a4378f6e82680
related_decision: DEC-2026-08-11-002
owner_boundary: EVIDENCE_AND_RECOMMENDATION_ONLY
product_authority: docs/CURRENT_CONFIRMED_DECISIONS.md
```

## 1. Research question

MVP-4의 공간 백팩이 단순한 “테트리스 모양 스탯창”이 되지 않으면서도, 5분 전투 뒤 REST의 판단 시간이 과도하게 늘어나지 않게 하려면 아이템의 공간 의존도, 태그, 획득 가중치, 편집 UX를 어느 정도로 설계해야 하는가?

현재 프로젝트 정본은 이미 다음을 승인했다.

- `6x6` 보드 / 시작 `4x3` 활성 영역.
- 아이템·가방 회전과 bag/item layer 분리.
- 직교 인접 시너지와 특수 가방 overlap.
- 6-slot REST work buffer.
- boss reward / shop / chest의 서로 다른 획득 역할.
- 전투와 REST의 분리.
- Persistent Workbench와 Undo/Redo.
- 대표 1차 조합 3종.

따라서 이번 조사는 이 구조를 다시 고르는 것이 아니라 **아이템 콘텐츠의 공간 의존도와 가독성을 어떻게 채울지**를 판단한다.

## 2. Comparable evidence

### 2.1 Backpack Battles — `ADAPT`

Source:
- Official Steam announcements, Patch 1.1, 2026-03-27: https://steamcommunity.com/app/2427700/announcements/

Observed fact:
- Patch 1.1은 bag-only / item-only edit mode를 추가했다.
- 하단 toolbar에서 Undo/Redo를 사용할 수 있게 했다.
- 아이템/가방 편집과 storage 관리의 마찰을 낮추는 QoL을 추가했다.
- 릴리스 뒤에도 수치 밸런스를 작은 단위로 반복 조정하고 있다.

Project applicability:
- Ninja Survival의 승인된 bag/item layer 분리, 명시적 Undo/Redo, Persistent Workbench는 유지 가치가 높다.
- 공간 전략이 깊어질수록 **편집 자체의 마찰을 별도로 줄여야 한다**는 근거로 사용한다.

Do not copy:
- PvP/비동기 대전용 메타 밸런스 피로도.
- 수백 종 아이템 규모와 복잡한 recipe breadth.

### 2.2 Backpack Hero — `ADAPT`

Sources:
- Official Steam store: https://store.steampowered.com/app/1970580/Backpack_Hero/
- Official Steam announcement, 2024-12-20: https://steamcommunity.com/app/1970580/announcements/

Observed fact:
- 게임의 핵심 설명은 아이템의 배치 위치가 성능에 영향을 준다는 점을 전면에 둔다.
- 2024-12-20 공식 업데이트에서 여러 아이템에 `item grouping`이 추가됐다.

Project applicability:
- Ninja Survival도 “아이템을 획득했다”보다 “어디에 두었는가”가 다음 전투 성능을 바꾸어야 한다.
- 보상/상점 후보는 완전 무작위만 쓰기보다 현재 유파·태그·조합 방향과 **약하게 연결된 가중치**를 사용해 빌드의 연속성을 만든다.

Do not copy:
- 모든 아이템을 고강도 위치 퍼즐로 만들지 않는다.
- 영구 storage/긴 정리 시간은 MVP-4 범위가 아니다.

### 2.3 Deep Rock Galactic: Survivor — `ADAPT`

Source:
- Official Steam announcements, 2026 Heavy Duty / Tag System Expansion: https://steamcommunity.com/app/2321470/allnews/

Observed fact:
- 개발팀은 새로운 tags와 tag synergy upgrade cards를 추가해 build options와 variation을 늘렸다고 설명한다.
- overclock 선택이 관련 tag를 더하고, 같은 tag 방향을 쌓으면 대응 upgrade card가 등장하는 구조를 사용한다.

Project applicability:
- Ninja Survival의 `유파 / 공격 방식 / 기능 / 속성 / 장비` 태그를 **효과 계산용 내부 문자열이 아니라 플레이어가 읽는 빌드 언어**로 사용한다.
- 동일 태그는 보상 가중, 상점 가중, 조합 힌트, UI 설명에서 같은 의미를 유지한다.

Do not copy:
- 태그 종류를 콘텐츠 수보다 빠르게 늘리지 않는다.
- 태그만 맞추면 자동 정답 빌드가 되는 강한 추천 알고리즘은 피한다.

### 2.4 Sproggiwood postmortem — `AVOID / ADAPT`

Source:
- Game Developer, “Design Postmortem: Story-Driven Roguelike, Sproggiwood”: https://www.gamedeveloper.com/design/design-postmortem-story-driven-roguelike-sproggiwood

Observed fact:
- 개발자는 체계적이고 균형 잡힌 enchantment 설계가 결과적으로 아이템을 서로 비슷하게 느끼게 했다고 회고한다.
- 해결 교훈으로 작은 양의 asymmetry와 고유하고 테마적인 아이템을 권한다.

Project applicability:
- 19종을 모두 동일한 “칸 수 × 퍼센트” 공식으로 만들지 않는다.
- `금기의 부적`, 3개 조합 결과처럼 소수의 **기억나는 비대칭 outlier**를 둔다.
- 다만 모든 아이템을 예외 규칙으로 만들지 않는다.

### 2.5 Resogun postmortem — `AVOID`

Source:
- Game Developer, “The game is the boss: A Resogun postmortem”: https://www.gamedeveloper.com/business/the-game-is-the-boss-a-i-resogun-i-postmortem

Observed fact:
- 개발팀은 phase 사이 weapon shop이 액션의 상승 흐름을 끊고 구매 결정을 강제해 pacing을 심하게 훼손했다고 판단해 제거했다.

Project applicability:
- Ninja Survival은 전투 중 상점/백팩/조합을 끼워 넣지 않는다.
- 승인된 `~5분 boss → result/reward → REST Workbench` 경계 안에서 고밀도 결정을 처리한다.

Do not copy:
- “상점이 나쁘다”로 일반화하지 않는다. 문제는 **결정의 위치와 pacing**이다.

## 3. Cross-comparison

| Decision axis | Backpack pattern | Survivor-like pattern | Industry risk | Ninja Survival recommendation |
|---|---|---|---|---|
| item readability | 위치가 강한 의미를 가짐 | 짧은 시간에 빌드 방향을 읽어야 함 | 모든 아이템이 예외면 인지 부하 | 19종 중 8종만 강한 공간효과 |
| standalone value | 시너지 전에도 쓸 수 있는 조각 필요 | 업그레이드 선택 즉시 효용 필요 | 조합 재료가 죽은 슬롯이 되면 불쾌 | 19종 전부 단독 효용 보장 |
| memorable items | 독특한 배치/recipe | 강한 power spike | 지나친 대칭은 samey | 금기의 부적 + 조합 결과를 asymmetric outlier로 사용 |
| build coherence | placement / grouping | tag synergy | 추천이 너무 강하면 자동 빌드 | 유파·태그·recipe에 약한 weighted bias |
| editing friction | Undo/Redo, bag/item mode | 선택 속도 중요 | 깊이와 조작 피로 혼동 | Persistent board + explicit controls + Undo/Redo 유지 |
| pacing | 운영 단계가 전투와 분리 | 짧은 combat/build cadence | 전투 중 메뉴가 몰입 파괴 | combat 중 편집 금지, boss 후 REST 집중 |

## 4. Decision recommendation

### Recommended — Hybrid spatial dependency

```yaml
base_items: 19
strong_spatial_items_initial: 8
simple_or_one_condition_items_initial: 11
combo_results: 3
purchasable_bags: 5
special_effect_bags: 1
rarity_system: NONE_MVP4
combat_midrun_inventory_edit: FORBIDDEN
```

Rules:

1. 모든 base item은 혼자 배치해도 의미 있는 기본 효과를 가진다.
2. 초기 19종 중 정확히 8종만 “위치가 크게 성능을 바꾸는 strong spatial item”으로 둔다.
3. 나머지 11종은 단순하거나 조건이 하나뿐인 읽기 쉬운 조각으로 둔다.
4. 조합 재료는 조합 전에도 정상 아이템으로 기능한다.
5. 3개 조합 결과는 원본 합계에 숫자만 더한 것이 아니라 여러 기존 modifier 축을 묶어 플레이 스타일이 바뀌는 결과로 만든다.
6. 태그는 reward/shop weighting, combo hint, UI 설명이 공유하는 vocabulary다.
7. 편집 복잡도가 올라갈수록 UI 마찰은 낮춘다. 공간 깊이를 얻기 위해 조작 난이도를 올리지 않는다.
8. 전투 리듬을 보호하기 위해 모든 공간 편집은 REST에 남긴다.

## 5. Evidence classification

```yaml
facts:
  - Backpack Battles Patch 1.1 added bag/item-only edit modes and toolbar Undo/Redo.
  - Backpack Hero official update states that several items received item grouping.
  - DRG Survivor official update expanded tags/tag synergies to add build options and variation.
  - Sproggiwood postmortem reports samey items after highly systematized balancing and recommends doses of asymmetry.
  - Resogun postmortem reports an implemented weapon shop was removed because it damaged pacing.
inferences_for_ninja_survival:
  - exactly 8 of 19 strong-spatial items is an initial authoring balance, not an external fact.
  - weighted school/tag/recipe bias is a project-specific adaptation, not copied probability data.
  - first-REST time targets are formative project thresholds, not industry standards.
benchmark_only_decision: false
```

## 6. Risks and test signals

- **Too spatial-heavy:** first REST time rises, invalid placement retries spike, players explain choices as “정리하느라 바빴다”.
- **Too spatial-light:** players ignore adjacency and describe the board as inventory capacity only.
- **Recommendation overfit:** the same recipe or school cluster appears every run and chest/shop/boss feel interchangeable.
- **Asymmetry dominance:** one outlier becomes automatic pick regardless footprint/opportunity cost.

Initial response order:

```text
readability / cue quality
→ individual spatial bonus tuning
→ offer weight tuning
→ footprint tuning
→ only then reconsider board/core rules
```

Do not remove rotation, adjacency, 6x6 board, or Persistent Workbench as the first balance response.
