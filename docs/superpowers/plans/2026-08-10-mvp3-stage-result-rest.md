# MVP-3 Stage, Result, Rest, Shop, and Fate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved MVP-3 build-decision loop so a selected school plays three five-minute combat segments, defeats a tiered midboss after each segment, reads an immutable contribution result, uses a real GOLD shop, accepts one accumulating fate tradeoff, previews the next fight, and ends after the third rest without pulling MVP-4 backpack geometry or the MVP-5 final loop forward.

**Architecture:** Keep `MainController` as the composition root. Add focused run-state, stage-flow, shop, fate, contribution, and combat-resolution units. Recompute build modifiers from owned items and fates instead of mutating live stats cumulatively. Keep the four MVP-2 school runtimes isolated behind `SchoolRuntimeBase`; expose only narrow run-system/modifier hooks. Use one dedicated full-screen `RestFlowUI` for RESULT/SHOP/FATE/PREVIEW/COMPLETE while the existing HUD stays compact.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1, Godot `Node`/`Resource`/`RefCounted`/`CanvasLayer` scenes, GitHub Actions Ubuntu verification.

## Global Constraints

- Baseline is merged MVP-2 `main` commit `e0150fa83512fb01c01569ed2b7a925dec81ec60`.
- Implementation branch is `feat/mvp3-stage-result-rest`; final merge remains a user-only decision.
- Production combat segment duration is exactly `300.0` seconds; tests inject shorter durations instead of adding a visible debug skip.
- The stage clock advances only in `COMBAT`; boss and rest time do not advance it.
- Rest order is exactly `RESULT -> SHOP -> FATE -> PREVIEW`; for segment 3 the final preview payload is rendered in the terminal COMPLETE panel and no fourth combat begins.
- Do not implement backpack grid/shape/rotation/adjacency, deep combinations, permanent progression, final boss/final result, weighted shop tables, shop level, discounts, buyback, offer locking, complex boss phases, or unrelated refactors.
- GOLD remains separate from existing `GameState` score. Normal kill grants 1 GOLD; stage boss grants 25 GOLD and does not also grant the normal +1.
- Owned inventory limit is 6 total copies and 2 copies per item id.
- Shop has exactly 3 distinct eligible offers; reroll costs `5 -> 10 -> 15 -> 15...` within a rest and resets next rest.
- Fate shows exactly 3 distinct unselected candidates and requires one choice. Selected fates persist and never reappear.
- Contribution data is actual applied values, not requested values. Result snapshots are immutable after boss-death settlement.
- Preserve existing `GameState`, MVP-1 DDD, reward-orb, selection, movement, four-school identity, ultimate, game-over, and restart behavior unless the approved MVP-3 design explicitly changes a boundary.
- Do not add shared `project.godot` InputMap entries or autoloads. Avoid any repository change to `project.godot` unless a genuinely unavoidable need is separately approved.
- Never stage local `project.godot`, `addons/`, `.godot/`, or unrelated plugin files. Never use `git add .`, `git add -A`, or `git clean` in the user's local checkout.
- Every behavior change follows RED -> minimal GREEN -> regression -> focused commit.

## Benchmarking conclusion

- **Must reflect:** short readable combat result -> quick build choice -> visible fate tradeoff -> concise preview -> immediate next combat rhythm. Results are evidence for the next choice, not a long accounting screen.
- **Conditional:** backpack-inspired item identity may exist now so MVP-4 can reuse the same item definitions, but no spatial puzzle or adjacency logic is implemented in MVP-3.
- **Excluded:** copying benchmark-game UI layouts, content, exact economy values, rarity systems, item pools, or boss patterns.
- **Risks:** rest becoming management-heavy, result cards becoming information-dense, shop economy overpowering school identity, and modifier plumbing breaking established four-school behavior.
- **Validation method:** deterministic unit tests, accelerated end-to-end GUT integration tests, exact-head CI import/smoke/full-suite verification, and a manual production-time five-minute boundary sanity check.

## Locked implementation details

These details resolve implementation ambiguity without expanding the approved product scope.

1. `RunModifierSet` includes `non_ultimate_school_damage_pct` so `봉인의 길` can penalize non-ultimate direct school damage independently of `ultimate_power_pct`.
2. Heukyeong marks gain an MVP-3 base lifetime of `8.0` seconds. `오의 비전서` and `봉인의 길` readiness bonuses extend mark lifetime instead of creating a universal ultimate meter.
3. Heukyeong mark gain uses deterministic fractional credit for `school_resource_gain_pct`; visible marks remain integer.
4. `CombatDDDTracker` processing pauses during rest. Its run-level combo/style/orb counters never reset at segment boundaries.
5. `CombatContributionTracker.reset_segment()` starts segment `kills=0` and `max_combo=0`; it does **not** seed max combo from the previous segment. Each new kill records the current overall DDD combo and raises segment max only from kills that occur in this segment.
6. Growth-axis normalized scores are `damage/25`, `healing/10`, `defense/10`, `status_events*2`, `max_combo`. Tie priority is `damage -> healing -> defense -> status -> combo` to make tests deterministic.
7. Primary growth hint is the strongest non-zero axis. A second axis hint appears only when the second normalized score is at least `1.0` and at least `50%` of the primary score. If no second axis qualifies, one build-synergy hint may be used when current modifiers reinforce the primary axis; otherwise only one hint is shown. Never exceed two hints.
8. `PlayerController.take_damage()` returns actual HP lost. Its `damage_resolved(requested, resolved, prevented, evaded)` signal reports `resolved` as the post-modifier damage amount **before HP clamp**, so overkill is not misclassified as defense. `prevented = requested - resolved` for mitigation, or the full requested amount for evasion.
9. `StageFlowController.start_after_school_selection()` copies the current `segment_duration_seconds` into `segment_time_remaining`, so tests may set an injected duration before starting the run.
10. On segment 3, successful fate selection still builds the same preview summary, but `continue_to_preview(true)` transitions directly to `COMPLETE` and emits `run_completed`. `RestFlowUI.show_complete(summary)` is therefore the third/final preview and has restart instead of Start Combat.
11. Catalog data stays programmatic in MVP-3. Do not build a large `.tres` graph yet.

## Exact MVP-3 catalog

### Items

| Stable id | Display name | Price | Effect per copy |
|---|---|---:|---|
| `taijutsu_training` | 체술단련 | 20G | move speed `+10%` |
| `protection_talisman` | 호신 부적 | 20G | max HP `+20` flat; on purchase heal effective max-HP increase |
| `fortune_talisman` | 행운 부적 | 20G | normal-kill GOLD `+25%`, fractional carry |
| `ninjutsu_training` | 인법단련 | 30G | school direct damage `+12%` |
| `enlightenment` | 깨달음 | 30G | school resource/counter gain `+20%` |
| `regeneration_scroll` | 재생의 두루마리 | 30G | on post-rest combat resume heal `20%` effective max HP |
| `ultimate_treatise` | 오의 비전서 | 40G | ultimate-readiness gain `+25%`; Heukyeong maps this to mark duration |
| `school_emblem` | 유파 증표 | 40G | selected-school-specific effect below |

`school_emblem` mapping per copy:
- Bongma: familiar attack interval `-15%`.
- Cheonsul: WET+SHOCK primary and chain reaction damage `+20%`.
- Guiin: melee radius `+15%`.
- Heukyeong: marked-target critical chance `+15 percentage points`; qualifying critical hit stays `2.0x`.

### Fates

| Stable id | Display name | Benefit | Cost |
|---|---|---|---|
| `slaughter_path` | 살육의 길 | school damage `+20%` | healing efficiency `-40%` |
| `guardian_path` | 수호의 길 | incoming damage `-20%`, healing `+30%` | school damage `-10%` |
| `shadow_path` | 그림자의 길 | move `+15%`, evasion `+10pp` | max HP `-15%` |
| `forbidden_path` | 금기의 길 | school resource gain `+25%`, qualifying status/reaction effect `+20%` | incoming damage `+15%` |
| `seal_path` | 봉인의 길 | ultimate readiness `+30%`, ultimate power `+25%` | non-ultimate direct school damage `-15%` |

`forbidden_path` status-effect channel applies only to Cheonsul reaction damage and Heukyeong burst/execution status damage. It does not invent a status mechanic for Bongma or Guiin.

`seal_path` ultimate-power mapping:
- Bongma: familiar hits during `백귀야행`.
- Cheonsul: `오행폭주` direct damage.
- Guiin: pulse damage while `귀인화` is active.
- Heukyeong: `암영처형` direct damage.

---

## File Structure

**New data/runtime contracts**
- `scripts/data/item_definition.gd`
- `scripts/data/fate_definition.gd`
- `scripts/data/run_modifier_set.gd`
- `scripts/data/mvp3_catalog.gd`
- `scripts/core/run_build_state.gd`
- `scripts/core/shop_controller.gd`
- `scripts/core/fate_controller.gd`
- `scripts/core/stage_flow_controller.gd`
- `scripts/combat/combat_contribution_tracker.gd`
- `scripts/combat/combat_resolver.gd`

**New stage/rest presentation**
- `scripts/enemies/stage_boss.gd`
- `scenes/enemies/stage_boss.tscn`
- `scripts/ui/rest_flow_ui.gd`
- `scenes/ui/rest_flow_ui.tscn`

**Modified existing systems**
- `scripts/enemies/enemy_chaser.gd`
- `scripts/player/player_controller.gd`
- `scripts/schools/school_runtime_base.gd`
- `scripts/schools/school_runtime_host.gd`
- `scripts/schools/bongma_runtime.gd`
- `scripts/schools/bongma_familiar.gd`
- `scripts/schools/cheonsul_runtime.gd`
- `scripts/schools/guiin_runtime.gd`
- `scripts/schools/heukyeong_runtime.gd`
- `scripts/core/main_controller.gd`
- `scripts/ui/hud.gd`
- `scenes/ui/hud.tscn`
- `scenes/main/main_scene.tscn`
- relevant existing unit/integration tests only where approved contracts change.

**New focused tests**
- `tests/unit/test_mvp3_catalog.gd`
- `tests/unit/test_run_build_state.gd`
- `tests/unit/test_shop_controller.gd`
- `tests/unit/test_fate_controller.gd`
- `tests/unit/test_combat_contribution_tracker.gd`
- `tests/unit/test_combat_resolver.gd`
- `tests/unit/test_stage_flow_controller.gd`
- `tests/unit/test_stage_boss.gd`
- `tests/integration/test_mvp3_hud.gd`
- `tests/integration/test_mvp3_rest_flow_ui.gd`
- `tests/integration/test_mvp3_stage_loop.gd`
- `tests/integration/test_mvp3_four_school_modifiers.gd`

---

### Task 1: Define reusable item, fate, modifier, and catalog contracts

**Files:** Create `scripts/data/item_definition.gd`, `scripts/data/fate_definition.gd`, `scripts/data/run_modifier_set.gd`, `scripts/data/mvp3_catalog.gd`, `tests/unit/test_mvp3_catalog.gd`; modify `tests/unit/test_script_contracts.gd`.

**Interfaces:**

```gdscript
# item_definition.gd
extends Resource
class_name ItemDefinition
@export var id: StringName
@export var display_name: String
@export var base_price: int
@export var tags: Array[StringName] = []
@export var effect_kind: StringName
@export var effect_value: float
@export var school_payload: Dictionary = {}
func sell_price() -> int:
    return base_price / 2
```

```gdscript
# fate_definition.gd
extends Resource
class_name FateDefinition
@export var id: StringName
@export var display_name: String
@export var benefit_text: String
@export var cost_text: String
@export var modifiers: Dictionary = {}
```

`RunModifierSet extends RefCounted` contains neutral-zero fields:

```text
move_speed_pct, max_health_flat, max_health_pct, damage_taken_pct, healing_pct,
normal_kill_gold_pct, school_damage_pct, non_ultimate_school_damage_pct,
school_resource_gain_pct, ultimate_charge_gain_pct, ultimate_power_pct,
school_status_effect_pct, evasion_chance, rest_start_heal_pct,
bongma_familiar_interval_pct, cheonsul_reaction_damage_pct,
guiin_melee_radius_pct, heukyeong_marked_crit_bonus, heukyeong_mark_duration_pct
```

Also add `copy_values() -> RunModifierSet`; consumers treat returned snapshots as read-only.

- [ ] **Step 1: Write RED catalog/contract tests.** Assert four scripts exist, eight unique item ids/five unique fate ids exist, every exact catalog value above is correct, sell price is 10/15/20, all modifier fields initialize to zero, and `copy_values()` produces an independent equal snapshot.
- [ ] **Step 2: Run focused RED.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_mvp3_catalog.gd -gexit
```

Expected: missing MVP-3 resources/contracts.
- [ ] **Step 3: Implement minimal Resource/RefCounted classes and `MVP3Catalog.build_items()/build_fates()`.** Use only programmatic definitions; no JSON/tres loader.
- [ ] **Step 4: Run focused GREEN plus `test_script_contracts.gd`.**
- [ ] **Step 5: Commit.**

```bash
git add scripts/data/item_definition.gd scripts/data/fate_definition.gd scripts/data/run_modifier_set.gd scripts/data/mvp3_catalog.gd tests/unit/test_mvp3_catalog.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 build data contracts"
```

---

### Task 2: Add run-level GOLD, inventory, fate, and modifier state

**Files:** Create `scripts/core/run_build_state.gd`, `tests/unit/test_run_build_state.gd`; modify `tests/unit/test_script_contracts.gd`.

**Interfaces:**

```gdscript
signal gold_changed(gold: int)
signal inventory_changed
signal fate_changed(fate_id: StringName)
signal item_purchased(item_id: StringName)
signal item_sold(item_id: StringName)

var selected_school_id: StringName = &""
func configure(item_defs: Dictionary, fate_defs: Dictionary) -> void
func set_selected_school(school_id: StringName) -> void
func grant_gold(amount: int) -> int
func try_spend_gold(amount: int) -> bool
func grant_normal_kill_gold() -> int
func grant_boss_gold() -> int
func buy_item(item_id: StringName) -> bool
func sell_item(item_id: StringName) -> bool
func select_fate(fate_id: StringName) -> bool
func item_count(item_id: StringName) -> int
func total_item_count() -> int
func has_fate(fate_id: StringName) -> bool
func get_modifiers() -> RunModifierSet
```

`get_modifiers()` returns `copy_values()` of the internally derived modifier snapshot.

- [ ] **Step 1: Write RED economy/inventory tests.** Cover neutral normal kill +1, fixed boss +25, no 26G boss path, fractional fortune carry (+25%/+50%), atomic insufficient-spend/buy failures, 6 total/2 duplicate caps, 50% sale, non-owned sale, and duplicate fate rejection.
- [ ] **Step 2: Write RED modifier-recompute tests for all catalog entries.** Two copies stack additively; selling recomputes from source state. Verify school emblem mappings and all five fate mappings. For Heukyeong, after summing all sources, move `ultimate_charge_gain_pct` into `heukyeong_mark_duration_pct` and zero generic readiness. Other schools retain generic readiness.
- [ ] **Step 3: Run RED.**
- [ ] **Step 4: Implement one `_recompute_modifiers()` source of truth.** Clamp evasion to `[0,0.95]` and marked crit bonus to `[0,1]`. Keep already-earned fractional GOLD carry when an item is later sold; it represents reward credit earned on prior kills.
- [ ] **Step 5: Run GREEN + earlier unit tests.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/core/run_build_state.gd tests/unit/test_run_build_state.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 run build state"
```

---

### Task 3: Implement three-offer shop and reroll economy

**Files:** Create `scripts/core/shop_controller.gd`, `tests/unit/test_shop_controller.gd`; modify `tests/unit/test_script_contracts.gd`.

**Interfaces:**

```gdscript
signal offers_changed(offer_ids: Array[StringName])
signal transaction_failed(reason: String)
var offer_ids: Array[StringName] = []
var rest_changes: Array[String] = []
func configure(build_state: RunBuildState, item_defs: Dictionary, rng: RandomNumberGenerator = null) -> void
func begin_rest() -> void
func buy_offer(index: int) -> bool
func sell_item(item_id: StringName) -> bool
func reroll() -> bool
func get_reroll_cost() -> int
```

- [ ] **Step 1: Write RED seeded-offer tests.** Exactly three distinct ids; two-copy-capped ids excluded; repeat across separate rolls allowed; invalid index atomic; `begin_rest()` clears `rest_changes`, resets reroll to 5G, and creates a new roll.
- [ ] **Step 2: Write RED transaction/reroll tests.** Failed purchase/reroll changes neither wallet, inventory, offers, reroll index nor change history. Reroll sequence is `5,10,15,15`. Successful buy/sale appends one concise PREVIEW change string.
- [ ] **Step 3: Run RED, implement uniform eligible-item sampling with injected RNG, run GREEN.** Successful purchase may leave its offer visible; it becomes unavailable if cap/space now blocks it until reroll.
- [ ] **Step 4: Commit.**

```bash
git add scripts/core/shop_controller.gd tests/unit/test_shop_controller.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 shop economy"
```

---

### Task 4: Implement mandatory three-card fate selection

**Files:** Create `scripts/core/fate_controller.gd`, `tests/unit/test_fate_controller.gd`; modify `tests/unit/test_script_contracts.gd`.

**Interfaces:**

```gdscript
signal candidates_changed(candidate_ids: Array[StringName])
signal fate_selected(fate_id: StringName)
var candidate_ids: Array[StringName] = []
var selected_this_rest: StringName = &""
func configure(build_state: RunBuildState, fate_defs: Dictionary, rng: RandomNumberGenerator = null) -> void
func begin_rest() -> void
func choose(fate_id: StringName) -> bool
func can_continue() -> bool
```

- [ ] **Step 1: Write RED tests.** Exactly 3 unique unselected candidates, non-offered/already-selected rejection, one choice per rest, no skip, and third rest shows the exact remaining three.
- [ ] **Step 2: Run RED, implement seeded uniform candidate selection, run GREEN.** `choose()` calls `RunBuildState.select_fate()` once and emits only on success.
- [ ] **Step 3: Commit.**

```bash
git add scripts/core/fate_controller.gd tests/unit/test_fate_controller.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 fate selection"
```

---

### Task 5: Add actual-value combat contribution telemetry

**Files:** Create `scripts/combat/combat_contribution_tracker.gd`, `tests/unit/test_combat_contribution_tracker.gd`; modify `scripts/enemies/enemy_chaser.gd`, `tests/unit/test_enemy_chaser.gd`, `tests/unit/test_script_contracts.gd`.

**Interfaces:**

`EnemyChaser.take_damage(amount: int) -> int` returns actual HP lost; callers may ignore it.

```gdscript
func reset_segment(base_reward_count: int, base_gold: int) -> void
func record_damage(actual: int) -> void
func record_healing(actual: int) -> void
func record_defense(prevented: int) -> void
func record_status_event(count: int = 1) -> void
func record_kill(current_combo: int) -> void
func freeze_snapshot(current_reward_count: int, current_gold: int, build_state: RunBuildState = null) -> Dictionary
func get_snapshot() -> Dictionary
```

- [ ] **Step 1: Write RED enemy actual-damage tests.** A 20-HP enemy hit for 7 then 99 returns 7 then 13; post-death hit returns 0; death still emits once.
- [ ] **Step 2: Write RED tracker tests.** Reset yields local kills/max combo 0. Record damage/heal/defense/status, and on each segment kill use current overall combo to update segment max. Snapshot stores reward/GOLD deltas and is deep-duplicated/frozen; later record calls are ignored until reset.
- [ ] **Step 3: Write RED growth-hint tests.** Use locked normalization/tie priority. Axis messages are:
  - damage: `현재 화력을 유지할 피해/유파 강화가 잘 맞습니다`
  - healing: `회복 기여가 실제로 나오고 있습니다. 회복 효율을 유지할 선택이 잘 맞습니다`
  - defense: `생존 투자 효율이 실제로 나오고 있습니다`
  - status: `상태·반응 빈도 또는 효과를 키우는 선택이 잘 맞습니다`
  - combo: `이동·공격 주기를 유지해 콤보 흐름을 강화할 수 있습니다`

  A second axis hint must satisfy score `>=1.0` and `>=50%` of primary. If no second axis qualifies, current build may provide one synergy hint only when the primary axis has an already-positive matching modifier: damage -> school/school-specific offensive modifier; healing -> healing/rest-heal; defense -> damage reduction/evasion/max-HP; status -> status/reaction/mark-specific modifier; combo -> move speed/familiar interval/melee radius. Otherwise return one hint.
- [ ] **Step 4: Run RED.**
- [ ] **Step 5: Implement Enemy return value and tracker.** Use `before := health`; return `before - health`. Tracker snapshot uses `duplicate(true)` for immutable dictionary/array values.
- [ ] **Step 6: Run GREEN + existing enemy/school regressions.**
- [ ] **Step 7: Commit.**

```bash
git add scripts/combat/combat_contribution_tracker.gd scripts/enemies/enemy_chaser.gd tests/unit/test_combat_contribution_tracker.gd tests/unit/test_enemy_chaser.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 contribution telemetry"
```

---

### Task 6: Add player modifiers, healing, evasion, and defense reporting

**Files:** Modify `scripts/player/player_controller.gd`, `tests/unit/test_player_controller.gd`, `tests/unit/test_script_contracts.gd`.

**Interfaces:**

```gdscript
signal healing_resolved(actual: int)
signal damage_resolved(requested: int, resolved: int, prevented: int, evaded: bool)
func apply_run_modifiers(modifiers: RunModifierSet) -> void
func heal(amount: int) -> int
func take_damage(amount: int) -> int
func set_rng_seed(seed_value: int) -> void
```

- [ ] **Step 1: Write RED max-HP/movement tests.** Capture `_base_max_health`/`_base_move_speed` once at ready. `100 + 20 flat` with `-15% max HP` resolves to 102. `240` move with +10% +15% resolves to 300. Reapply after removal clamps current HP without `damage_resolved`.
- [ ] **Step 2: Write RED healing tests.** Healing applies `max(1 + healing_pct,0)` before HP cap; returns/emits actual HP restored; non-positive/dead player returns 0.
- [ ] **Step 3: Write RED damage tests.** Order: reject invalid -> evasion roll -> resolve modifier amount -> health clamp. On mitigation, `resolved = maxi(roundi(requested * max(1 + damage_taken_pct,0)),0)`, `prevented=max(requested-resolved,0)`. On evade, resolved 0/prevented requested. `take_damage()` returns `min(resolved, health_before)` actual HP lost; signal still emits pre-HP-cap `resolved`, preventing overkill from appearing as defense.
- [ ] **Step 4: Implement minimal stat surface.** Production RNG randomizes once; tests can seed. Movement input logic stays unchanged.
- [ ] **Step 5: Run GREEN and commit.**

```bash
git add scripts/player/player_controller.gd tests/unit/test_player_controller.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 player run modifiers"
```

---

### Task 7: Add modifier-aware school damage resolver and runtime hooks

**Files:** Create `scripts/combat/combat_resolver.gd`, `tests/unit/test_combat_resolver.gd`; modify `scripts/schools/school_runtime_base.gd`, `scripts/schools/school_runtime_host.gd`, `tests/unit/test_school_runtime_host.gd`, `tests/unit/test_script_contracts.gd`.

**Interfaces:**

```gdscript
func configure(tracker: CombatContributionTracker) -> void
func set_modifiers(modifiers: RunModifierSet) -> void
func deal_school_damage(target: Node, base_damage: float, damage_kind: StringName = &"normal", extra_multiplier: float = 1.0) -> int
```

Resolver order:

```gdscript
var value := base_damage * maxf(1.0 + modifiers.school_damage_pct, 0.0)
if damage_kind == &"ultimate":
    value *= maxf(1.0 + modifiers.ultimate_power_pct, 0.0)
else:
    value *= maxf(1.0 + modifiers.non_ultimate_school_damage_pct, 0.0)
value *= maxf(extra_multiplier, 0.0)
if value <= 0.0:
    return 0
var requested := maxi(roundi(value), 1)
var actual := int(target.take_damage(requested))
tracker.record_damage(actual)
return actual
```

`SchoolRuntimeBase` adds `combat_resolver`, `contribution_tracker`, neutral `run_modifiers`, `configure_run_systems(resolver, tracker)`, and `apply_run_modifiers(modifiers)`. Host forwards both hooks while preserving one-shot selection.

- [ ] **Step 1: Write RED resolver tests.** Normal/ultimate paths, seal normal penalty, overkill actual recording, zero/invalid target, extra multiplier.
- [ ] **Step 2: Write RED base/host forwarding tests.** Existing `configure(player, world)` stays compatible.
- [ ] **Step 3: Implement neutral fallbacks, run GREEN, commit.**

```bash
git add scripts/combat/combat_resolver.gd scripts/schools/school_runtime_base.gd scripts/schools/school_runtime_host.gd tests/unit/test_combat_resolver.gd tests/unit/test_school_runtime_host.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 combat resolver"
```

---

### Task 8: Implement the stage phase state machine

**Files:** Create `scripts/core/stage_flow_controller.gd`, `tests/unit/test_stage_flow_controller.gd`; modify `tests/unit/test_script_contracts.gd`.

**Interfaces:**

```gdscript
enum Phase { SCHOOL_SELECT, COMBAT, BOSS, RESULT, SHOP, FATE, PREVIEW, COMPLETE, GAME_OVER }
signal phase_changed(phase: Phase)
signal segment_time_changed(segment: int, remaining: float)
signal boss_requested(tier: int)
signal run_completed
@export var segment_duration_seconds: float = 300.0
var phase := Phase.SCHOOL_SELECT
var segment_index := 1
var segment_time_remaining := 300.0
func start_after_school_selection() -> bool
func enter_result_after_boss() -> bool
func continue_to_shop() -> bool
func continue_to_fate() -> bool
func continue_to_preview(fate_selected: bool) -> bool
func start_next_combat() -> bool
func mark_game_over() -> void
```

- [ ] **Step 1: Write RED transition tests.** No clock before selection; `start_after_school_selection()` copies current configured duration; exact/overshoot threshold enters BOSS and emits one boss request; BOSS later frames cannot duplicate; illegal transitions fail; boss result only from BOSS; RESULT->SHOP->FATE legal; FATE requires selected flag.
- [ ] **Step 2: Write final-rest RED test.** For segments 1/2, FATE->PREVIEW then `start_next_combat()` increments segment and reloads current injected duration. For segment 3, `continue_to_preview(true)` transitions directly from FATE to COMPLETE, emits `run_completed` exactly once, and `start_next_combat()` fails.
- [ ] **Step 3: Write short-duration RED test.** Set duration `0.05` before start; process exactly/over threshold with no real wait.
- [ ] **Step 4: Implement narrow state machine, run GREEN, commit.**

```bash
git add scripts/core/stage_flow_controller.gd tests/unit/test_stage_flow_controller.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 stage flow controller"
```

---

### Task 9: Add one tiered stage-boss scene

**Files:** Create `scripts/enemies/stage_boss.gd`, `scenes/enemies/stage_boss.tscn`, `tests/unit/test_stage_boss.gd`; modify `tests/unit/test_script_contracts.gd`.

```gdscript
const TIER_STATS := {
    1: {"max_health": 200, "move_speed": 70.0, "contact_damage": 15, "visual_scale": 1.6},
    2: {"max_health": 350, "move_speed": 80.0, "contact_damage": 20, "visual_scale": 1.8},
    3: {"max_health": 500, "move_speed": 90.0, "contact_damage": 25, "visual_scale": 2.0},
}
func configure_tier(tier: int) -> bool
func is_stage_boss() -> bool:
    return true
```

- [ ] **Step 1: Write RED tier tests.** Configure before add-to-tree, then inherited ready health equals tier max; speed/contact/visual scale exact; invalid tier atomic.
- [ ] **Step 2: Implement `StageBoss extends EnemyChaser` and a scene reusing normal collision/contact behavior.** Boss spawn position in Main is deterministic: `player.global_position + Vector2.RIGHT * wave_spawner.spawn_distance`.
- [ ] **Step 3: Run GREEN and commit.**

```bash
git add scripts/enemies/stage_boss.gd scenes/enemies/stage_boss.tscn tests/unit/test_stage_boss.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 tiered stage boss"
```

---

### Task 10: Route Bongma through run modifiers and contribution tracking

**Files:** Modify `scripts/schools/bongma_runtime.gd`, `scripts/schools/bongma_familiar.gd`, `tests/unit/test_bongma_runtime.gd`, `tests/unit/test_bongma_familiar.gd`.

- Spirit gain multiplier: `(1 + school_resource_gain_pct) * (1 + ultimate_charge_gain_pct)`.
- Familiar interval: chosen base/ward/ultimate interval times `max(1 + bongma_familiar_interval_pct,0.05)`.
- `BongmaFamiliar.configure(player, interval, damage, resolver: CombatResolver = null)` remains backward-compatible; add `set_damage_kind(kind: StringName)`.
- Runtime refreshes familiar damage kind to `ultimate` only while `백귀야행` is active; otherwise `normal`.
- Resolver records actual familiar damage; no resolver falls back to old direct `take_damage()` behavior for isolated legacy tests.

- [ ] **Step 1: Write RED tests.** Enlightenment/treatise/seal accelerate spirit; emblem lowers interval; ninjutsu training raises actual hit; seal lowers normal hit but raises ultimate familiar hit.
- [ ] **Step 2: Implement minimal hooks and run Bongma/MVP-2 GREEN.**
- [ ] **Step 3: Commit.**

```bash
git add scripts/schools/bongma_runtime.gd scripts/schools/bongma_familiar.gd tests/unit/test_bongma_runtime.gd tests/unit/test_bongma_familiar.gd
git commit -m "feat: apply MVP-3 modifiers to Bongma"
```

---

### Task 11: Route Cheonsul through modifiers, readiness progress, and status telemetry

**Files:** Modify `scripts/schools/cheonsul_runtime.gd`, `tests/unit/test_cheonsul_runtime.gd`.

- `reaction_count` becomes float progress with `REACTION_MAXIMUM := 3.0`; HUD rounds only for display.
- Successful WET->SHOCK gain is `1.0 * (1 + school_resource_gain_pct) * (1 + ultimate_charge_gain_pct)`, clamped 3.
- Flame/burn/reaction/chain/ultimate damage uses resolver.
- WET+SHOCK primary+chain use extra `(1 + cheonsul_reaction_damage_pct) * (1 + school_status_effect_pct)`.
- Burn damage does not receive the forbidden-path status multiplier; approved mapping is reaction only.
- Successful burn/token applications and actual reactions record status events once; invalid/no-op calls do not.
- `오행폭주` uses ultimate damage kind.

- [ ] **Step 1: Write RED fractional-readiness/damage tests.** +25% yields 2.5 after two reactions, third clamps 3; emblem/forbidden boost reaction; seal boosts ultimate.
- [ ] **Step 2: Write RED status telemetry tests.** Preserve SHOCK targeting and non-recursive chain behavior.
- [ ] **Step 3: Implement, run full Cheonsul GREEN, commit.**

```bash
git add scripts/schools/cheonsul_runtime.gd tests/unit/test_cheonsul_runtime.gd
git commit -m "feat: apply MVP-3 modifiers to Cheonsul"
```

---

### Task 12: Route Guiin through modifiers and contribution tracking

**Files:** Modify `scripts/schools/guiin_runtime.gd`, `tests/unit/test_guiin_runtime.gd`.

- Gwihyeol gains multiply by resource/readiness channels; decay is unchanged.
- Emblem multiplies final melee radius by `1 + guiin_melee_radius_pct`.
- Preserve existing local berserker/high-Gwihyeol/ultimate math in `current_pulse_damage()`; resolver applies run-wide modifiers once afterward.
- Pulse damage kind is ultimate while `ultimate_time_remaining > 0`, normal otherwise.
- Only an enemy with actual damage >0 contributes hit-based Gwihyeol gain.

- [ ] **Step 1: Write RED radius/gain/normal-vs-ultimate modifier tests.** Keep baseline .90/80/10, berserker 110/15, high Gwihyeol 1.20x, ultimate .45/130/1.25 unchanged.
- [ ] **Step 2: Implement, run Guiin GREEN, commit.**

```bash
git add scripts/schools/guiin_runtime.gd tests/unit/test_guiin_runtime.gd
git commit -m "feat: apply MVP-3 modifiers to Guiin"
```

---

### Task 13: Add Heukyeong mark lifetime and modifier mappings

**Files:** Modify `scripts/schools/heukyeong_runtime.gd`, `tests/unit/test_heukyeong_runtime.gd`.

```gdscript
const BASE_MARK_DURATION := 8.0
var _mark_gain_credit := 0.0
```

Each enemy mark state stores `remaining`. Active processing decrements it; expiry removes marks/badge. Effective duration is `8.0 * (1 + heukyeong_mark_duration_pct)`.

Mark gain uses deterministic fractional credit:

```gdscript
_mark_gain_credit += float(base_mark_gain) * maxf(1.0 + run_modifiers.school_resource_gain_pct, 0.0)
var whole_gain := floori(_mark_gain_credit)
_mark_gain_credit -= whole_gain
```

Needle -> normal resolver. Burst -> normal resolver with `(1 + school_status_effect_pct)`. Shadow execution -> ultimate resolver with `(1 + school_status_effect_pct)`. Emblem adds marked-target critical chance only, clamped 1.

- [ ] **Step 1: Replace the MVP-2 permanent-mark test with RED exact 8.0-second expiry.** At 7.99 mark exists, next .01 removes it.
- [ ] **Step 2: Write RED duration tests.** Treatise alone -> 10.0s; treatise + seal readiness => +55%, 12.4s total.
- [ ] **Step 3: Write RED fractional mark, marked crit, forbidden burst/execution, seal normal-vs-ultimate tests.** Preserve seeded RNG, badge pruning, burst reset, and ultimate threshold >=3 live marks.
- [ ] **Step 4: Implement, run Heukyeong GREEN, commit.**

```bash
git add scripts/schools/heukyeong_runtime.gd tests/unit/test_heukyeong_runtime.gd
git commit -m "feat: apply MVP-3 modifiers to Heukyeong"
```

---

### Task 14: Add compact combat HUD and full-screen rest-flow UI

**Files:** Modify `scripts/ui/hud.gd`, `scenes/ui/hud.tscn`; create `tests/integration/test_mvp3_hud.gd`, `scripts/ui/rest_flow_ui.gd`, `scenes/ui/rest_flow_ui.tscn`, `tests/integration/test_mvp3_rest_flow_ui.gd`; modify `tests/unit/test_script_contracts.gd`.

**HUD:**

```gdscript
func set_stage(segment: int, total: int = 3) -> void
func set_stage_time(seconds_remaining: float) -> void
func set_gold(gold: int) -> void
```

Exact format: `SEGMENT 1/3`, `TIME 04:32`, `GOLD 37`. Time uses ceiling of non-negative seconds.

**Rest UI intents:**

```gdscript
signal result_continue_requested
signal shop_buy_requested(index: int)
signal shop_sell_requested(item_id: StringName)
signal shop_reroll_requested
signal shop_continue_requested
signal fate_selected_requested(fate_id: StringName)
signal preview_start_requested
signal restart_requested
```

**Rendering methods:**

```gdscript
func show_result(snapshot: Dictionary) -> void
func show_shop(gold: int, offer_ids: Array[StringName], item_defs: Dictionary, owned_items: Dictionary, reroll_cost: int, message: String = "") -> void
func show_fate(candidate_ids: Array[StringName], fate_defs: Dictionary) -> void
func show_preview(summary: Dictionary) -> void
func show_complete(summary: Dictionary) -> void
func hide_all() -> void
```

- [ ] **Step 1: Write RED HUD tests.** Preserve all MVP-1/2 labels/methods.
- [ ] **Step 2: Write RED RestFlowUI tests.** One full-screen panel with RESULT/SHOP/FATE/PREVIEW/COMPLETE containers; only active container visible. Button presses emit intents only. RESULT renders zero heal/defense as `기여 없음`. SHOP has exactly 3 offer controls, owned list, reroll, Next. FATE has exactly 3 cards with benefit+cost and no skip. PREVIEW has Start Combat. COMPLETE contains the final preview summary + `MVP-3 LOOP COMPLETE` + restart, no Start Combat.
- [ ] **Step 3: Implement readable placeholder Controls only; no custom art/animation.**
- [ ] **Step 4: Run GREEN + old HUD regressions and commit.**

```bash
git add scripts/ui/hud.gd scenes/ui/hud.tscn tests/integration/test_mvp3_hud.gd scripts/ui/rest_flow_ui.gd scenes/ui/rest_flow_ui.tscn tests/integration/test_mvp3_rest_flow_ui.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 combat and rest UI"
```

---

### Task 15: Integrate stage, economy, telemetry, shop, fate, and pause/resume in Main

**Files:** Modify `scripts/core/main_controller.gd`, `scenes/main/main_scene.tscn`, `tests/integration/test_main_scene.gd`; create `tests/integration/test_mvp3_stage_loop.gd`; modify older integration tests only where the approved stage flow changes their setup.

**Scene additions:**

```text
Main
  GameState
  CombatDDD
  RunBuildState
  ShopController
  FateController
  StageFlow
  ContributionTracker
  CombatResolver
  Player
  WaveSpawner
  SchoolRuntimeHost
  ...existing initial enemies...
  HUD
  RestFlowUI
  SchoolSelectionUI
```

Main exports `stage_boss_scene: PackedScene` and configures both catalogs/controllers in `_ready()`.

- [ ] **Step 1: Write RED start integration.** Before selection StageFlow is SCHOOL_SELECT, timer frozen, combat disabled, GOLD 0. After selection: set build-state school id -> sync modifiers -> StageFlow start -> gameplay active, AutoAttack still disabled, HUD stage/time/GOLD correct. Initial contribution baseline uses current reward count and GOLD.
- [ ] **Step 2: Write RED accelerated timer->boss test.** Inject .05 before selection. Threshold enters BOSS, disables new normal spawn, keeps living normals active, spawns exactly one tier-1 boss at player + right * spawn distance, wires target/death, and never duplicates.
- [ ] **Step 3: Write RED death-settlement tests.** Normal death: existing score/DDD/school callback + normal GOLD + contribution kill + orb. Boss death: existing score/DDD/school callback + **25 boss GOLD only** + contribution kill + orb, then freeze snapshot, then transition RESULT, then queue-free remaining normals without rewards. Repeated callback remains idempotent.
- [ ] **Step 4: Wire player/telemetry.** `healing_resolved(actual)` -> tracker healing; `damage_resolved(... prevented ...)` -> tracker defense. Resolver owns school damage tracking. Reward delta comes from DDD snapshot counters.
- [ ] **Step 5: Implement `_sync_run_modifiers()`.** Get one copied modifier snapshot; set resolver/player/host. Consumers never mutate it.
- [ ] **Step 6: Implement protection-talisman purchase heal.** Record effective max before successful purchase, sync, then heal positive max increase. Tracker is frozen in SHOP, so this cannot change prior RESULT.
- [ ] **Step 7: Implement phase-specific processing.**
  - COMBAT: player, active school, normals, WaveSpawner/spawning, DDD, reward orbs active.
  - BOSS: same gameplay active but `WaveSpawner.set_spawning_enabled(false)`; stage clock frozen by phase.
  - RESULT/SHOP/FATE/PREVIEW/COMPLETE: player/enemies/school-host processing paused without `deactivate()`, spawner disabled, DDD paused, reward orbs paused; Main/controllers/UI remain active.
  - GAME_OVER: `StageFlow.mark_game_over()`, semantic school deactivation allowed, all gameplay stopped, no rest reward; existing restart precedence retained.
- [ ] **Step 8: Wire rest intents.** RESULT Next -> StageFlow SHOP + `ShopController.begin_rest()`. Shop actions delegate and resync/rerender on success. SHOP Next -> FATE + `FateController.begin_rest()`. Fate success -> resync and build preview summary.
- [ ] **Step 9: Build exact PREVIEW summary.** Include latest result headline, successful shop change strings, newly selected fate, all selected fates, current GOLD, and next boss tier values (`HP/contact damage`) for segments 1/2. On segment 3 use the same summary as COMPLETE and no next-combat expectation.
- [ ] **Step 10: Resume segments 2/3 in exact order.** `StageFlow.start_next_combat()` first establishes next segment; `ContributionTracker.reset_segment(current_reward_count,current_gold)` unfreezes new telemetry; then rest-start heal `roundi(player.max_health * rest_start_heal_pct)` so actual restoration belongs to new segment; remove stale boss reference; enable gameplay/spawner/DDD/orbs; render HUD. Do not clear run-level score/style/school resource/GOLD/items/fates.
- [ ] **Step 11: Segment-3 fate success.** Build final preview summary, call `continue_to_preview(true)` which enters COMPLETE directly, keep gameplay paused, call `RestFlowUI.show_complete(summary)`, and expose restart only. No regeneration heal and no segment 4.
- [ ] **Step 12: Run accelerated one-cycle and full three-cycle tests.** One-cycle path: `select -> COMBAT -> BOSS -> RESULT -> SHOP -> FATE -> PREVIEW -> COMBAT 2`. Full path ends COMPLETE after tier 3.
- [ ] **Step 13: Commit.**

```bash
git add scripts/core/main_controller.gd scenes/main/main_scene.tscn tests/integration/test_main_scene.gd tests/integration/test_mvp3_stage_loop.gd
git commit -m "feat: integrate MVP-3 stage and rest loop"
```

Only add older integration files if they actually required approved setup adaptation.

---

### Task 16: Cross-school regression, adversarial review, CI, and readiness gate

**Files:** Create `tests/integration/test_mvp3_four_school_modifiers.gd`; modify only focused production/tests for accepted findings; add project source/test `.gd.uid` files after Godot 4.7.1 import when appropriate. Never stage `project.godot` or `addons/`.

- [ ] **Step 1: Add four-school integration coverage.** For every school: selection/base offense/readiness/ultimate still work; `인법단련` raises actual damage; `오의 비전서` mapping is non-no-op; emblem mapping observable; seal lowers non-ultimate damage while improving readiness/ultimate; process pause/resume preserves identity/resource.
- [ ] **Step 2: Add immutable-result mutation test.** Freeze snapshot, then buy/sell/heal/reroll/select fate and assert prior result dictionary remains equal to a deep duplicate.
- [ ] **Step 3: Add game-over priority tests in COMBAT and BOSS.** Death prevents RESULT/shop/fate transition and uses existing restart path.
- [ ] **Step 4: Run full verification.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --import
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --scene res://scenes/main/main_scene.tscn --quit-after 120
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Require no smoke `SCRIPT ERROR:`/`ERROR:` and all GUT tests green.

- [ ] **Step 5: Run Compound/adversarial attacks and classify every finding.** Use `MUST_FIX`, `SHOULD_FIX`, `USER_DECISION_REQUIRED`, `DEFER`, `REJECTED_CRITIQUE`, `BLOCKED_UNVERIFIED`, or `ALLOWED_LEGACY`. Attack at least:
  1. timer before selection/during BOSS/rest,
  2. duplicate boss at threshold/overshoot,
  3. boss 26G bug,
  4. cleanup rewards,
  5. DDD combo decay during rest,
  6. rest semantic deactivation/reset,
  7. mutable result snapshot,
  8. failed shop/fate atomicity,
  9. 7th item/3rd duplicate,
  10. stale/duplicate fate candidate,
  11. nondeterministic fractional carry,
  12. seal hurting ultimate or failing Bongma ultimate benefit,
  13. Heuk mark-duration no-op,
  14. status telemetry double-count semantics,
  15. overkill counted as dealt damage,
  16. overkill/max-HP clamp counted as defense,
  17. game-over/stage transition race,
  18. reward orb moving/collecting during rest,
  19. `project.godot`/`addons/` leakage,
  20. MVP-4/MVP-5 scope leakage.

For accepted MUST_FIX/SHOULD_FIX: write regression test first, minimal fix, focused rerun, then full rerun.

- [ ] **Step 6: Exact-head GitHub Actions gate.** Open/update the feature PR if needed to trigger workflow. Require checkout, Godot 4.7.1, GUT 9.7.1, import, smoke, full GUT success on the exact final feature SHA. Do not reuse earlier CI evidence.
- [ ] **Step 7: Windows local metadata gate.** Preserve known local plugin state. Run Godot 4.7.1 import/full GUT, inspect `git status --short`, stage only MVP-3 source/test `.gd.uid` files explicitly, reject `project.godot`, `addons/`, unrelated files.
- [ ] **Step 8: Manual production-time acceptance.** Verify selection gate; HUD SEGMENT/TIME/GOLD; real 5:00 stops new waves and spawns one boss; old normals remain during boss; readable RESULT; directionally credible contribution; shop failures clear; fate upside/downside and no skip; inert rest; preview/complete; game-over/restart. A full real-time 15-minute run is tuning follow-up, not CI requirement.
- [ ] **Step 9: Ready-for-review report.** Include Superpowers usage, files inspected/changed/reasons, implementation summary, exact verification, manual-only items, user Godot check steps, risks, Compound Review mistakes/lessons/prevention/Base-promotion/project-only candidates.

Only present the branch as merge-ready after these gates. **Do not merge without explicit user approval.**
