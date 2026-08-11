# MVP-4 Content Data Readiness Contract

```yaml
planning_contract_id: DATA-CONTRACT-2026-08-11-MVP4
status: PHASE_A_TECHNICAL_RECOMMENDATION
related_decision: DEC-2026-08-11-002
related_balance_data: docs/planning/2026-08-11-mvp4-content-balance-v1.md
implementation_status: NOT_STARTED
phase_b_status: MUST_REVALIDATE_BEFORE_BUILD
```

## 1. Problem this contract closes

DEC-002의 first-pass content는 다음을 요구한다.

- 일부 base item이 2개 이상의 `RunModifierSet` field를 동시에 제공한다.
- 8개 strong-spatial item이 인접 tag/id, distinct-neighbor count, once/cap 조건에 따라 modifier를 추가한다.
- 3개 combo result가 여러 modifier 축을 동시에 제공한다.
- reward weighting이 school affinity / combo-core / active tag를 읽는다.

현재 MVP-3 `ItemDefinition`의 `effect_kind + effect_value` 한 쌍만으로는 이 내용을 모두 표현할 수 없다. 현재 MVP-4 implementation plan의 T01도 footprint/tag를 추가하지만 multi-modifier/spatial-rule encoding을 아직 명시하지 않는다.

이 차이를 구현자의 item-id 하드코딩으로 메우지 않는다.

## 2. Data-authority requirements

Phase B에서 exact Godot 4.7.1 API 형태를 확정하되 다음 의미 계약은 고정한다.

### 2.1 Static modifier payload

모든 item definition은 최종적으로 **0개 이상 modifier field/value pair**를 데이터로 표현할 수 있어야 한다.

Recommended semantic shape:

```text
static_modifier_payload:
  <RunModifierSet field>: <float delta>
  ...
```

Requirements:

- key는 실제 `RunModifierSet` field만 허용한다.
- unknown field는 silent ignore가 아니라 catalog/test failure 대상으로 둔다.
- 순서와 무관하게 동일 결과를 내야 한다.
- 같은 definition 안에서 같은 field가 두 번 정의되는 표현은 허용하지 않는다.

### 2.2 Legacy compatibility

기존 MVP-3의 `effect_kind/effect_value`는 Task 1 전환 중 회귀 보호를 위해 남길 수 있다.

권장 fallback 의미:

```text
if static_modifier_payload is non-empty:
    static_modifier_payload is the static-effect authority
else:
    legacy effect_kind/effect_value is adapted to one-entry payload
```

**두 경로를 동시에 더하지 않는다.** 동일 아이템 효과가 두 번 적용되는 dual authority를 금지한다.

기존 8개 MVP-3 아이템의 값은 migration regression test로 고정한다.

### 2.3 Spatial rule descriptor

`BackpackResolver` 안에서 다음과 같은 item-id 분기를 늘리지 않는다.

```text
if item_id == katana ...
if item_id == shuriken ...
```

대신 strong-spatial item은 definition/catalog가 다음 의미를 데이터로 제공한다.

```yaml
spatial_rule:
  relationship: ORTHOGONAL_ADJACENCY
  required_neighbor_tags: []
  required_neighbor_definition_ids: []
  match_semantics: ANY
  aggregation: ONCE_IF_ANY | PER_DISTINCT_NEIGHBOR
  max_matches: 1
  modifier_payload: {}
```

Initial examples:

```yaml
katana:
  required_neighbor_tags: [element_style]
  aggregation: ONCE_IF_ANY
  max_matches: 1
  modifier_payload:
    non_ultimate_school_damage_pct: 0.08

shuriken:
  required_neighbor_tags: [ninjutsu]
  aggregation: PER_DISTINCT_NEIGHBOR
  max_matches: 3
  modifier_payload:
    non_ultimate_school_damage_pct: 0.03

greater_summoning_circle:
  required_neighbor_definition_ids: [school_emblem, barrier_art]
  aggregation: ONCE_IF_ANY
  max_matches: 1
  modifier_payload:
    ultimate_charge_gain_pct: 0.12
```

Rules:

- contact edge count does not multiply matches.
- distinct neighbor instance is the counting unit for `PER_DISTINCT_NEIGHBOR`.
- one neighbor matching multiple required tags still counts once for one rule evaluation.
- rule result is deterministic and UI-independent.

### 2.4 Special bag descriptor

현재 planned `BagDefinition`의

```text
affected_item_tag
auxiliary_effect_kind
auxiliary_effect_value
```

는 MVP-4의 **특수 가방 1종** 요구에는 충분하다.

`ninjutsu_l_pouch`:

```yaml
affected_item_tag: ninjutsu
auxiliary_effect_kind: school_resource_gain_pct
auxiliary_effect_value: 0.04
```

여기서는 불필요한 generic rule engine을 추가하지 않는다. 향후 여러 종류의 복잡한 special bag이 실제로 필요할 때 별도 확장을 검토한다.

### 2.5 Acquisition metadata

별도 rarity를 만들지 않는다.

Reward weighting에 필요한 정보는 가능한 한 기존/DEC-002 tags에서 파생한다.

```text
affinity_bongma
affinity_cheonsul
affinity_guiin
affinity_heukyeong
combo_core
```

`high_value`는 별도 영구 tag가 아니라 first-pass weighting에서 `price >= 40 OR footprint cells >= 4`로 파생한다.

### 2.6 Combo-result acquisition exclusion

3개 combo result는 `MVP4Catalog`의 전체 item lookup에는 존재해야 하지만 boss/shop/chest base acquisition pool에는 들어가면 안 된다.

권장 경계:

```text
all_item_definitions
base_acquisition_item_ids
combination_result_item_ids
```

`RestRewardController`가 모든 item dictionary를 그대로 random pool로 사용하지 않도록 RED test를 둔다.

## 3. Determinism requirements

Reward weighting과 spatial resolution 모두 seed 기반 테스트가 재현 가능해야 한다.

- candidate id ordering을 canonicalize한 뒤 weighted selection에 넣는다.
- dictionary iteration order에 결과가 의존하지 않게 한다.
- adjacency pair는 canonical instance-id ordering으로 deduplicate한다.
- weighted candidate의 최종 weight는 `minimum..maximum` clamp 후 사용한다.
- zero/negative effective weight candidate는 first-pass 규칙상 만들지 않는다.

## 4. Required Phase B checks

`기획 완료` 뒤 Phase B에서 다음을 모두 닫아야 한다.

1. Godot 4.7.1에서 선택한 concrete data representation이 Resource/RefCounted/catalog build 방식과 호환되는가.
2. `RunModifierSet` field validation이 한 군데에 모여 있는가.
3. legacy `effect_kind/effect_value`와 multi payload가 double-apply되지 않는가.
4. strong-spatial 8종을 resolver의 item-id hardcode 없이 표현 가능한가.
5. special bag은 현재 단순 contract로 충분하며 과설계하지 않았는가.
6. combo result가 base acquisition pool에서 자동 제외되는가.
7. reward weighting이 seed/injection 가능하고 candidate ordering이 deterministic한가.
8. T01/T03/T07 RED tests가 위 계약을 직접 증명하는가.

하나라도 닫히지 않으면 Phase B `MUST_FIX`이며 Phase C로 넘어가지 않는다.

## 5. Planned RED evidence additions

### T01 catalog

- multi-axis item payload가 정확한 field/value를 반환.
- unknown modifier field를 가진 catalog fixture는 validation failure.
- 기존 MVP-3 8종의 legacy 값이 migration 후 동일.
- combo result ids는 all-item lookup에는 있고 base acquisition ids에는 없음.

### T03 resolver

- katana: element-style neighbor 1개/2개 모두 spatial bonus 1회.
- shuriken: 3 distinct ninjutsu neighbors까지 증가, 4번째는 cap.
- shared edge가 2개여도 same neighbor는 1회.
- same geometry/input은 반복 resolve에서 byte-equivalent semantic output.

### T07 rewards

- current-school guaranteed option.
- fixed seed + same state → same 3 boss options.
- combo result never appears in boss/shop/chest.
- chest recipe-completion bonus는 0이고 boss/shop과 역할이 섞이지 않음.

## 6. Scope guard

이 contract는 새로운 product feature가 아니다.

```yaml
new_rarity: false
new_acquisition_pillar: false
new_combo_tier: false
new_combat_system: false
new_save_schema: false
resolver_item_id_hardcode: forbidden
```

목표는 이미 승인된 DEC-002 콘텐츠를 **데이터 중심, deterministic, testable**하게 구현할 수 있도록 Phase B의 기술 선택 범위를 좁히는 것이다.
