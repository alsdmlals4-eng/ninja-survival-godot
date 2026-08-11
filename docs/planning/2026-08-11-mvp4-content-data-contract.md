# MVP-4 Content Data Readiness Contract

```yaml
planning_contract_id: DATA-CONTRACT-2026-08-11-MVP4
status: PHASE_B_VALIDATED
related_decision: DEC-2026-08-11-002
related_balance_data: docs/planning/2026-08-11-mvp4-content-balance-v1.md
phase_b_record: docs/planning/2026-08-11-mvp4-phase-b-definition-of-ready.md
implementation_status: NOT_STARTED
phase_b_status: PASS
validated_against_project_main: 11a81208ec9ad7ca9f4a044d3226e1be0ea25f76
validated_godot_engine: 4.7.1
```

## 1. Problem this contract closes

DEC-2026-08-11-002 requires:

- base items with one or more static `RunModifierSet` deltas;
- strong-spatial items whose orthogonal neighbors add bounded modifiers;
- 3 combo results with multi-axis modifier payloads;
- reward weighting based on affinity / combo-core / active build tags;
- deterministic seeded reward and resolver evidence.

MVP-3 `ItemDefinition.effect_kind + effect_value` cannot encode this safely by itself. The implementation must not compensate with item-ID branches or a second hidden combat authority.

## 2. Concrete Phase-B representation

### 2.1 `RunModifierSet` owns supported modifier fields

Add to `scripts/data/run_modifier_set.gd`:

```gdscript
const SUPPORTED_FIELDS: Array[StringName] = [
    &"move_speed_pct",
    &"max_health_flat",
    &"max_health_pct",
    &"damage_taken_pct",
    &"healing_pct",
    &"normal_kill_gold_pct",
    &"school_damage_pct",
    &"non_ultimate_school_damage_pct",
    &"school_resource_gain_pct",
    &"ultimate_charge_gain_pct",
    &"ultimate_power_pct",
    &"school_status_effect_pct",
    &"evasion_chance",
    &"rest_start_heal_pct",
    &"bongma_familiar_interval_pct",
    &"cheonsul_reaction_damage_pct",
    &"guiin_melee_radius_pct",
    &"heukyeong_marked_crit_bonus",
    &"heukyeong_mark_duration_pct",
]

static func is_supported_field(field_name: StringName) -> bool
func add_delta(field_name: StringName, amount: float) -> bool
```

Requirements:

- this list is the single modifier-field validation authority;
- unknown fields fail catalog/test validation and are never silently ignored;
- `add_delta()` returns `false` for unsupported fields and performs no mutation;
- order of payload entries does not change the result.

### 2.2 `ItemDefinition` static modifier payload

Add:

```gdscript
var static_modifier_payload: Dictionary[StringName, float] = {}
var spatial_rules: Array[SpatialRuleDefinition] = []
```

Legacy compatibility rule:

```text
if static_modifier_payload is non-empty:
    static_modifier_payload is the static-effect authority
else if effect_kind names a supported RunModifierSet field:
    adapt effect_kind/effect_value to one static entry
else:
    no static modifier entry
```

`school_emblem` keeps its existing selected-school `school_payload` behavior. It is conditional school data, not a second copy of the static payload.

**Never add legacy and static payloads together.** Existing MVP-3 eight-item values are migration regression targets.

### 2.3 Bounded generic `SpatialRuleDefinition`

Create `scripts/data/spatial_rule_definition.gd`:

```gdscript
extends Resource
class_name SpatialRuleDefinition

enum Aggregation {
    ONCE_IF_ANY,
    PER_DISTINCT_NEIGHBOR,
}

var required_neighbor_tags: Array[StringName] = []
var required_neighbor_definition_ids: Array[StringName] = []
var aggregation: Aggregation = Aggregation.ONCE_IF_ANY
var max_matches: int = 1
var modifier_payload: Dictionary[StringName, float] = {}
```

MVP-4 deliberately does **not** add an arbitrary relationship DSL. All item spatial rules use the already-approved orthogonal item adjacency relationship.

Match semantics:

- tag/id requirements use `ANY` semantics;
- contact edge count never multiplies one neighbor instance;
- one neighbor matching multiple requirements still counts once for one rule;
- `PER_DISTINCT_NEIGHBOR` counts distinct neighbor instances up to `max_matches`;
- every `modifier_payload` key must pass `RunModifierSet.is_supported_field()`;
- resolver behavior must be independent of item ID.

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
  required_neighbor_definition_ids: [school_emblem]
  required_neighbor_tags: [barrier]
  aggregation: ONCE_IF_ANY
  max_matches: 1
  modifier_payload:
    ultimate_charge_gain_pct: 0.12
```

The first authoring default remains 8 strong-spatial items, inside the approved 7–9 tuning range.

### 2.4 Special bag descriptor

Keep the existing planned simple contract:

```text
affected_item_tag
auxiliary_effect_kind
auxiliary_effect_value
```

For `ninjutsu_l_pouch`:

```yaml
affected_item_tag: ninjutsu
auxiliary_effect_kind: school_resource_gain_pct
auxiliary_effect_value: 0.04
```

One MVP-4 special bag does not justify a second generic rule engine.

### 2.5 Acquisition metadata and pool boundaries

Do not add rarity.

Affinity/combo/build metadata stays tag-based:

```text
affinity_bongma
affinity_cheonsul
affinity_guiin
affinity_heukyeong
combo_core
```

`high_value` remains derived for boss weighting from `price >= 40 OR footprint cells >= 4`.

`MVP4Catalog` must expose explicit boundaries:

```gdscript
static func build_items() -> Dictionary
static func build_bags() -> Dictionary
static func build_combinations() -> Dictionary
static func base_acquisition_item_ids() -> Array[StringName]
static func combination_result_item_ids() -> Array[StringName]
```

- `build_items()` contains the 19 base items plus 3 combo-result definitions for lookup.
- `base_acquisition_item_ids()` contains only the 19 directly acquirable base items.
- boss/shop/chest may not construct pools by blindly iterating all item definitions.

## 3. Deterministic reward requirements

For every weighted draw:

1. start from explicit eligible IDs;
2. remove ineligible IDs;
3. canonical-sort IDs by `StringName` text;
4. calculate source-specific weight;
5. clamp to the approved min/max;
6. use injected/seeded `RandomNumberGenerator`;
7. remove selected IDs for without-replacement draws.

Dictionary iteration order must never determine result identity.

The reusable weighted-selection helper may live in `MVP4Catalog` or `RestRewardController`, but only one authority may exist.

## 4. Phase-B validation results

```yaml
checks:
  concrete_godot_representation: PASS
  run_modifier_field_validation_single_owner: PASS
  legacy_no_double_apply_contract: PASS
  strong_spatial_without_item_id_hardcode: PASS
  simple_special_bag_contract_sufficient: PASS
  combo_result_base_pool_exclusion: PASS
  deterministic_weighted_candidate_order: PASS
  t01_t03_t07_red_coverage_defined: PASS
open_must_fix: 0
```

Godot 4.7 documentation supports custom `Resource` classes, typed arrays and typed dictionaries. The catalog is code-authored, so this contract does not require Inspector-authored nested generic data.

## 5. Required RED evidence

### T01 catalog / data

- 19 base item IDs + 3 combo-result IDs unique/resolvable.
- 5 purchasable bags + starting 4x3 bag unique/resolvable.
- multi-axis static payload exact values.
- unsupported modifier key makes catalog validation fail.
- existing MVP-3 eight-item values unchanged through adapter semantics.
- combo-result IDs exist in lookup but never in base acquisition IDs.
- every spatial rule modifier key validates.

### T03 resolver

- katana: one or multiple matching element-style neighbors → one bonus application.
- shuriken: distinct ninjutsu neighbors accumulate to max 3.
- same neighbor sharing multiple edges counts once.
- same neighbor matching multiple declared requirements counts once.
- no strong-spatial item requires resolver `if item_id == ...` behavior.
- identical state/catalog inputs produce equivalent deterministic modifier output.

### T07 rewards

- boss options are 3 distinct IDs and include at least one current-school-affinity candidate.
- fixed seed + same state produces identical ordered boss options.
- combo results never appear in boss/shop/chest.
- chest recipe-completion bonus remains zero.
- source weighting rules remain distinct.
- canonical candidate ordering occurs before random selection.

## 6. Scope guard

```yaml
new_rarity: false
new_acquisition_pillar: false
new_combo_tier: false
new_combat_system: false
new_save_schema: false
new_relationship_dsl: false
resolver_item_id_hardcode: forbidden
dual_modifier_authority: forbidden
```

This contract is a technical encoding of already-approved DEC-2026-08-11-002 content. It is not a new product feature.

## 7. Phase transition

```yaml
phase_b_status: PASS
phase_c_authorized: true
next_execution: T01 focused RED
runtime_evidence: NOT_RUN
human_evidence: NOT_RUN
```

Phase C must still verify the fresh local execution identity before authoring and cannot claim runtime success from this planning validation.