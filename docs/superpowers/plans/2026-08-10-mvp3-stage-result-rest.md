# MVP-3 Stage, Result, Rest, Shop, and Fate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved MVP-3 build-decision loop so a selected school plays three five-minute combat segments, defeats a tiered midboss after each segment, reads an immutable contribution result, uses a real GOLD shop, accepts one accumulating fate tradeoff, previews the next fight, and ends after the third rest without pulling MVP-4 backpack geometry or the MVP-5 final loop forward.

**Architecture:** Keep `MainController` as the composition root. Add focused run-state, stage-flow, shop, fate, contribution, and combat-resolution units. Recompute build modifiers from owned items and fates instead of mutating live stats cumulatively. Keep the four MVP-2 school runtimes isolated behind `SchoolRuntimeBase`; expose only narrow run-system/modifier hooks. Use one dedicated full-screen `RestFlowUI` for RESULT/SHOP/FATE/PREVIEW while the existing HUD stays compact.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1, Godot `Node`/`Resource`/`RefCounted`/`CanvasLayer` scenes, GitHub Actions Ubuntu verification.

## Global Constraints

- Baseline is merged MVP-2 `main` commit `e0150fa83512fb01c01569ed2b7a925dec81ec60`.
- Implementation branch is `feat/mvp3-stage-result-rest`; final merge remains a user-only decision.
- Production combat segment duration is exactly `300.0` seconds; tests inject shorter durations instead of adding a visible debug skip.
- The stage clock advances only in `COMBAT`; boss and rest time do not advance it.
- Rest order is exactly `RESULT -> SHOP -> FATE -> PREVIEW`; after rest 3, PREVIEW ends in `MVP-3 LOOP COMPLETE` instead of starting segment 4.
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

## Implementation-level decisions locked by the approved spec

These are concrete mechanics needed to make the approved design unambiguous without expanding product scope:

1. `RunModifierSet` includes `non_ultimate_school_damage_pct` so `봉인의 길` can penalize normal school direct damage while `ultimate_power_pct` separately strengthens ultimate output.
2. Heukyeong marks gain an MVP-3 base lifetime of `8.0` seconds. This is necessary because `오의 비전서` was approved to extend Heukyeong mark duration; the existing MVP-2 permanent-mark behavior is intentionally replaced and regression-tested.
3. For Heukyeong, generic ultimate-readiness gain is converted into mark-duration extension. `오의 비전서 +25%` and `봉인의 길 +30%` therefore preserve the existing `active marks >= 3` readiness rule instead of inventing a universal meter.
4. Heukyeong mark gain uses deterministic fractional credit for school-resource bonuses so `깨달음`/`금기의 길` are not no-ops while visible marks remain integers.
5. Growth-hint ranking uses deterministic normalized scores: `damage/25`, `healing/10`, `defense/10`, `status_events*2`, and `max_combo`. The highest non-zero score drives the primary hint; a second hint appears only for a meaningful second non-zero axis or a clear owned-item/fate synergy.
6. `CombatDDDTracker` processing is paused during rest so the existing combo timer does not decay while the player is reading menus. Its run-level counters are never reset at segment boundaries.
7. The eight item definitions and five fate definitions are programmatic catalog data for MVP-3. Do not create a large `.tres` asset graph yet; MVP-4 may move/extend definitions if spatial authoring benefits from resources.

---

## File Structure

**New data/runtime contracts**
- `scripts/data/item_definition.gd` — reusable item definition.
- `scripts/data/fate_definition.gd` — reusable fate definition.
- `scripts/data/run_modifier_set.gd` — derived modifier snapshot.
- `scripts/data/mvp3_catalog.gd` — eight item + five fate definitions.
- `scripts/core/run_build_state.gd` — GOLD, inventory, fates, modifier recomputation.
- `scripts/core/shop_controller.gd` — three-offer shop and reroll state.
- `scripts/core/fate_controller.gd` — candidate generation and mandatory selection.
- `scripts/core/stage_flow_controller.gd` — phase/segment clock state machine.
- `scripts/combat/combat_contribution_tracker.gd` — segment telemetry + immutable snapshot.
- `scripts/combat/combat_resolver.gd` — modifier-aware school damage and telemetry.

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

### Task 1: Define reusable item, fate, and modifier data contracts

**Files:**
- Create: `scripts/data/item_definition.gd`
- Create: `scripts/data/fate_definition.gd`
- Create: `scripts/data/run_modifier_set.gd`
- Create: `scripts/data/mvp3_catalog.gd`
- Create: `tests/unit/test_mvp3_catalog.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**

`ItemDefinition extends Resource` exposes:

```gdscript
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

`FateDefinition extends Resource` exposes stable id/name/benefit/cost plus a dictionary of modifier contributions.

`RunModifierSet extends RefCounted` contains exactly these MVP-3 channels initialized to neutral zero values:

```gdscript
var move_speed_pct := 0.0
var max_health_flat := 0.0
var max_health_pct := 0.0
var damage_taken_pct := 0.0
var healing_pct := 0.0
var normal_kill_gold_pct := 0.0
var school_damage_pct := 0.0
var non_ultimate_school_damage_pct := 0.0
var school_resource_gain_pct := 0.0
var ultimate_charge_gain_pct := 0.0
var ultimate_power_pct := 0.0
var school_status_effect_pct := 0.0
var evasion_chance := 0.0
var rest_start_heal_pct := 0.0
var bongma_familiar_interval_pct := 0.0
var cheonsul_reaction_damage_pct := 0.0
var guiin_melee_radius_pct := 0.0
var heukyeong_marked_crit_bonus := 0.0
var heukyeong_mark_duration_pct := 0.0
```

Catalog stable item ids:

```text
taijutsu_training
protection_talisman
fortune_talisman
ninjutsu_training
enlightenment
regeneration_scroll
ultimate_treatise
school_emblem
```

Catalog stable fate ids:

```text
slaughter_path
guardian_path
shadow_path
forbidden_path
seal_path
```

- [ ] **Step 1: Write RED catalog/contract tests**

Assert all four scripts exist and instantiate. Assert exactly eight unique item ids and five unique fate ids. Assert prices/effects from the approved design, and `sell_price()` is exactly half of 20/30/40. Assert every `RunModifierSet` channel starts at zero.

Representative assertions:

```gdscript
var items := CatalogScript.build_items()
assert_eq(items.size(), 8)
assert_eq(items[&"taijutsu_training"].base_price, 20)
assert_almost_eq(items[&"taijutsu_training"].effect_value, 0.10, 0.001)
assert_eq(items[&"ultimate_treatise"].base_price, 40)
assert_eq(items[&"school_emblem"].effect_kind, &"school_emblem")

var fates := CatalogScript.build_fates()
assert_eq(fates.size(), 5)
assert_almost_eq(fates[&"slaughter_path"].modifiers[&"school_damage_pct"], 0.20, 0.001)
assert_almost_eq(fates[&"seal_path"].modifiers[&"non_ultimate_school_damage_pct"], -0.15, 0.001)
```

- [ ] **Step 2: Run focused RED**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_mvp3_catalog.gd -gexit
```

Expected: missing MVP-3 data resources/contracts.

- [ ] **Step 3: Implement minimal Resource/RefCounted classes and programmatic catalog**

Use `ItemDefinition.new()` / `FateDefinition.new()` helpers in `MVP3Catalog`. Keep all names, prices, values, benefit/cost text, and ids in this one catalog. Do not add JSON/tres loaders.

- [ ] **Step 4: Run focused GREEN and script-contract regression**

Expected: catalog test and `test_script_contracts.gd` pass.

- [ ] **Step 5: Commit**

```bash
git add scripts/data/item_definition.gd scripts/data/fate_definition.gd scripts/data/run_modifier_set.gd scripts/data/mvp3_catalog.gd tests/unit/test_mvp3_catalog.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 build data contracts"
```

---

### Task 2: Add run-level GOLD, inventory, fate, and modifier state

**Files:**
- Create: `scripts/core/run_build_state.gd`
- Create: `tests/unit/test_run_build_state.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**

```gdscript
signal gold_changed(gold: int)
signal inventory_changed
signal fate_changed(fate_id: StringName)
signal item_purchased(item_id: StringName)
signal item_sold(item_id: StringName)

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

State includes integer `gold`, `owned_items`, `selected_fates`, selected school id, and `_normal_gold_fraction`.

- [ ] **Step 1: Write RED economy/inventory tests**

Cover:
- no negative grant/spend mutation,
- normal kill exactly +1 at neutral modifiers,
- boss exactly +25 and never luck-modified,
- one/two fortune talismans preserve fractional +25%/+50% across repeated kills,
- item buy deducts fixed price,
- capacity 6 and duplicate cap 2 reject atomically,
- sale refunds 50% and removes one copy,
- non-owned sale is atomic,
- selected fate cannot be selected twice.

Representative fractional test:

```gdscript
state.grant_gold(100)
assert_true(state.buy_item(&"fortune_talisman"))
var before := state.gold
for _i in range(4):
    state.grant_normal_kill_gold()
assert_eq(state.gold - before, 5)
```

- [ ] **Step 2: Write RED modifier-recompute tests for all eight items and five fates**

Assert recomputation from source state rather than cumulative mutation. Key cases:
- two `체술단련` => `move_speed_pct == 0.20`, then selling one => `0.10`,
- `호신 부적` => `max_health_flat == 20`,
- `행운 부적` => `normal_kill_gold_pct == 0.25`,
- `인법단련` => `school_damage_pct == 0.12`,
- `깨달음` => `school_resource_gain_pct == 0.20`,
- `재생의 두루마리` => `rest_start_heal_pct == 0.20`,
- `오의 비전서` => `ultimate_charge_gain_pct == 0.25` for Bongma/Cheonsul/Guiin,
- `오의 비전서` on Heukyeong moves that +0.25 into `heukyeong_mark_duration_pct` and leaves generic ultimate-charge zero,
- `유파 증표` maps to only the selected school's specific channel,
- fate channels match approved values,
- `봉인의 길` creates `ultimate_charge_gain_pct +0.30`, `ultimate_power_pct +0.25`, `non_ultimate_school_damage_pct -0.15`,
- Heukyeong converts any accumulated readiness gain to mark-duration extension after all items/fates are summed.

- [ ] **Step 3: Run RED**

Expected: `RunBuildState` missing.

- [ ] **Step 4: Implement state mutation with one `_recompute_modifiers()` source of truth**

Do not mutate Player or school runtimes here. `buy_item()`/`sell_item()`/`select_fate()` change only run state and derived modifiers. Player-specific purchase heal is handled by Main when it observes a successful protection-talisman purchase and sees effective max HP change.

Use clamped helper math for chance fields:

```gdscript
modifiers.evasion_chance = clampf(modifiers.evasion_chance, 0.0, 0.95)
modifiers.heukyeong_marked_crit_bonus = clampf(modifiers.heukyeong_marked_crit_bonus, 0.0, 1.0)
```

- [ ] **Step 5: Run GREEN + all earlier unit tests**

- [ ] **Step 6: Commit**

```bash
git add scripts/core/run_build_state.gd tests/unit/test_run_build_state.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 run build state"
```

---

### Task 3: Implement the three-offer shop and reroll economy

**Files:**
- Create: `scripts/core/shop_controller.gd`
- Create: `tests/unit/test_shop_controller.gd`
- Modify: `tests/unit/test_script_contracts.gd`

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

- [ ] **Step 1: Write RED deterministic offer tests**

With a seeded RNG, assert:
- exactly three distinct ids,
- ids already at duplicate cap are excluded,
- new rest resets reroll index and creates fresh offers,
- repeat items across separate rolls are allowed,
- invalid offer index fails without mutation.

- [ ] **Step 2: Write RED transaction/reroll tests**

Assert buy delegates to build state and removes no offer merely because a purchase failed. Successful purchase may leave the offer visible but disabled/invalid once its cap is reached; a later reroll replaces all three. Assert exact costs `5, 10, 15, 15`, and insufficient GOLD preserves wallet, offers, and reroll index.

`rest_changes` records concise strings for successful buys/sales only, for PREVIEW use; failed attempts do not enter history.

- [ ] **Step 3: Run RED, implement minimal controller, run GREEN**

Uniformly sample the current eligible id list using the injected RNG; do not add rarity weights.

- [ ] **Step 4: Commit**

```bash
git add scripts/core/shop_controller.gd tests/unit/test_shop_controller.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 shop economy"
```

---

### Task 4: Implement mandatory three-card fate selection

**Files:**
- Create: `scripts/core/fate_controller.gd`
- Create: `tests/unit/test_fate_controller.gd`
- Modify: `tests/unit/test_script_contracts.gd`

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

- [ ] **Step 1: Write RED tests**

Cover exactly 3 unique unselected candidates, already-selected exclusion, non-offered rejection, duplicate-choice rejection, mandatory `can_continue == false` before a choice, and at rest 3 the remaining three fates are all offered.

- [ ] **Step 2: Run RED, implement seeded candidate selection, run GREEN**

`choose()` calls `RunBuildState.select_fate()` exactly once and emits only on success.

- [ ] **Step 3: Commit**

```bash
git add scripts/core/fate_controller.gd tests/unit/test_fate_controller.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 fate selection"
```

---

### Task 5: Add actual-value combat contribution telemetry

**Files:**
- Create: `scripts/combat/combat_contribution_tracker.gd`
- Create: `tests/unit/test_combat_contribution_tracker.gd`
- Modify: `scripts/enemies/enemy_chaser.gd`
- Modify: `tests/unit/test_enemy_chaser.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**

`EnemyChaser.take_damage(amount: int) -> int` returns actual HP lost. Existing callers may ignore the return value.

`CombatContributionTracker` exposes:

```gdscript
func reset_segment(base_combo: int, base_reward_count: int, base_gold: int) -> void
func record_damage(actual: int) -> void
func record_healing(actual: int) -> void
func record_defense(prevented: int) -> void
func record_status_event(count: int = 1) -> void
func record_kill(current_combo: int) -> void
func freeze_snapshot(current_reward_count: int, current_gold: int, build_state: RunBuildState = null) -> Dictionary
func get_snapshot() -> Dictionary
```

- [ ] **Step 1: Write RED enemy actual-damage tests**

```gdscript
var enemy := EnemyScript.new()
enemy.max_health = 20
add_child_autofree(enemy)
assert_eq(enemy.take_damage(7), 7)
assert_eq(enemy.take_damage(99), 13)
assert_eq(enemy.take_damage(1), 0)
```

Preserve one `died` emission and queued deletion behavior.

- [ ] **Step 2: Write RED tracker tests**

Cover damage/healing/defense/status accumulation, segment kill/max-combo recording, GOLD/reward deltas, zero-value no-ops, snapshot immutability, and reset between segments.

Growth hint tests use the locked normalized ranking. Example:

```gdscript
tracker.record_damage(100) # score 4
tracker.record_status_event(1) # score 2
var snapshot := tracker.freeze_snapshot(0, 0)
assert_eq(snapshot["growth_hints"][0], "현재 화력을 유지할 피해/유파 강화가 잘 맞습니다")
```

For zero healing/defense, snapshot values are zero; UI later renders `기여 없음`.

- [ ] **Step 3: Run RED**

- [ ] **Step 4: Implement `EnemyChaser.take_damage` return value and focused tracker**

Use `before := health`; after clamped subtraction return `before - health`. Do not move score/GOLD/death policy into EnemyChaser.

- [ ] **Step 5: Run GREEN + existing enemy/school tests**

- [ ] **Step 6: Commit**

```bash
git add scripts/combat/combat_contribution_tracker.gd scripts/enemies/enemy_chaser.gd tests/unit/test_combat_contribution_tracker.gd tests/unit/test_enemy_chaser.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 contribution telemetry"
```

---

### Task 6: Add player modifier, healing, evasion, and defense-reporting surface

**Files:**
- Modify: `scripts/player/player_controller.gd`
- Modify: `tests/unit/test_player_controller.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**

Add signals:

```gdscript
signal healing_resolved(actual: int)
signal damage_resolved(requested: int, applied: int, prevented: int, evaded: bool)
```

Add:

```gdscript
func apply_run_modifiers(modifiers: RunModifierSet) -> void
func heal(amount: int) -> int
func take_damage(amount: int) -> int
func set_rng_seed(seed_value: int) -> void
```

- [ ] **Step 1: Write RED max-HP/movement tests**

Capture immutable base stats after `_ready()`. Assert:

```text
base max 100 + 20 flat, -15% fate => roundi(120 * 0.85) = 102
base move 240 with +10% +15% => 300
```

Selling/removing a max-HP source and reapplying modifiers clamps current HP to the new effective max but does not emit/record combat damage.

- [ ] **Step 2: Write RED healing tests**

`heal(20)` while missing 5 returns/emits 5. Healing multiplier applies before cap; non-positive heal returns 0. No revive after `_dead`.

- [ ] **Step 3: Write RED damage-reduction/evasion tests**

Use seeded RNG plus a test helper or injectable RNG state. Damage ordering:

1. reject non-positive/dead,
2. roll evasion,
3. if not evaded compute `roundi(requested * max(1 + damage_taken_pct, 0))`,
4. clamp applied damage to current HP,
5. defense telemetry basis is requested minus **post-modifier requested application**, not overkill. Overkill is not “defense”.

Emit `damage_resolved(requested, applied_before_hp_cap, prevented, evaded)` where `applied_before_hp_cap` is the modifier-resolved amount; health still clamps at zero. This keeps defense about mitigation/evasion rather than target HP scarcity.

- [ ] **Step 4: Implement minimal stat surface and run GREEN**

Keep movement input logic unchanged except replacing `move_speed` live use with the effective recomputed value stored back into `move_speed`. Store `_base_move_speed` and `_base_max_health` once.

- [ ] **Step 5: Commit**

```bash
git add scripts/player/player_controller.gd tests/unit/test_player_controller.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 player run modifiers"
```

---

### Task 7: Add modifier-aware school damage resolver and runtime hooks

**Files:**
- Create: `scripts/combat/combat_resolver.gd`
- Create: `tests/unit/test_combat_resolver.gd`
- Modify: `scripts/schools/school_runtime_base.gd`
- Modify: `scripts/schools/school_runtime_host.gd`
- Modify: `tests/unit/test_school_runtime_host.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**

`CombatResolver`:

```gdscript
func configure(tracker: CombatContributionTracker) -> void
func set_modifiers(modifiers: RunModifierSet) -> void
func deal_school_damage(target: Node, base_damage: float, damage_kind: StringName = &"normal", extra_multiplier: float = 1.0) -> int
```

Damage ordering:

```gdscript
var value := base_damage * (1.0 + modifiers.school_damage_pct)
if damage_kind == &"ultimate":
    value *= 1.0 + modifiers.ultimate_power_pct
else:
    value *= 1.0 + modifiers.non_ultimate_school_damage_pct
value *= maxf(extra_multiplier, 0.0)
var requested := maxi(roundi(value), 1)
var actual := int(target.take_damage(requested))
tracker.record_damage(actual)
return actual
```

`SchoolRuntimeBase` adds:

```gdscript
var combat_resolver: CombatResolver
var contribution_tracker: CombatContributionTracker
var run_modifiers: RunModifierSet

func configure_run_systems(resolver: CombatResolver, tracker: CombatContributionTracker) -> void
func apply_run_modifiers(modifiers: RunModifierSet) -> void
```

`SchoolRuntimeHost` forwards these contracts to all runtime children and can reapply modifiers to the active runtime after every build mutation.

- [ ] **Step 1: Write RED resolver tests**

Cover normal damage, ultimate damage, `봉인의 길` normal penalty, overkill actual-damage recording, invalid target no-op, and extra multiplier.

- [ ] **Step 2: Write RED base/host forwarding tests**

Assert old `configure(player, world)` still works and new hooks do not alter one-shot school selection semantics.

- [ ] **Step 3: Run RED, implement resolver/hooks, run GREEN**

Use a neutral new `RunModifierSet` when no modifier has been supplied so isolated legacy runtime tests remain valid.

- [ ] **Step 4: Commit**

```bash
git add scripts/combat/combat_resolver.gd scripts/schools/school_runtime_base.gd scripts/schools/school_runtime_host.gd tests/unit/test_combat_resolver.gd tests/unit/test_school_runtime_host.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 combat resolver"
```

---

### Task 8: Implement the stage phase state machine

**Files:**
- Create: `scripts/core/stage_flow_controller.gd`
- Create: `tests/unit/test_stage_flow_controller.gd`
- Modify: `tests/unit/test_script_contracts.gd`

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

- [ ] **Step 1: Write RED state tests**

Cover default `300.0`, no clock before selection, exact threshold emits one `boss_requested`, later `_process()` calls in BOSS cannot emit a second boss, illegal transitions fail, boss result only from BOSS, FATE->PREVIEW requires fate-selected flag, and third PREVIEW -> COMPLETE with one `run_completed`.

- [ ] **Step 2: Write injected-duration RED test**

Set `segment_duration_seconds = 0.05`, start combat, process `0.05`, assert BOSS once. Do not sleep/wait real time.

- [ ] **Step 3: Implement narrow state machine and run GREEN**

`segment_index` advances only when `start_next_combat()` succeeds after rests 1/2. Segment 3 preview transitions to COMPLETE instead.

- [ ] **Step 4: Commit**

```bash
git add scripts/core/stage_flow_controller.gd tests/unit/test_stage_flow_controller.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 stage flow controller"
```

---

### Task 9: Add one tiered stage-boss scene

**Files:**
- Create: `scripts/enemies/stage_boss.gd`
- Create: `scenes/enemies/stage_boss.tscn`
- Create: `tests/unit/test_stage_boss.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**

`StageBoss extends EnemyChaser`:

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

- [ ] **Step 1: Write RED tier tests**

Instantiate the scene, configure each tier **before adding to the tree**, then assert inherited `_ready()` initializes health to the configured maximum and visual scale is applied. Invalid tier returns false and does not partially mutate.

- [ ] **Step 2: Run RED, implement scene/script, run GREEN**

Reuse the same collision/contact behavior as `enemy_basic.tscn`; do not add boss-specific attacks.

- [ ] **Step 3: Commit**

```bash
git add scripts/enemies/stage_boss.gd scenes/enemies/stage_boss.tscn tests/unit/test_stage_boss.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 tiered stage boss"
```

---

### Task 10: Route Bongma through run modifiers and contribution tracking

**Files:**
- Modify: `scripts/schools/bongma_runtime.gd`
- Modify: `scripts/schools/bongma_familiar.gd`
- Modify: `tests/unit/test_bongma_runtime.gd`
- Modify: `tests/unit/test_bongma_familiar.gd`

**Behavior:**

- Spirit gain uses both resource and ultimate-readiness channels:

```gdscript
var gain_multiplier := (1.0 + run_modifiers.school_resource_gain_pct) * (1.0 + run_modifiers.ultimate_charge_gain_pct)
```

- Familiar interval is multiplied by `max(1.0 + bongma_familiar_interval_pct, 0.05)` after selecting base/ward/ultimate interval.
- Familiar attacks use `CombatResolver` when configured; isolated legacy tests may fall back to `take_damage(damage)` with neutral behavior.
- During `백귀야행`, familiar hits use damage kind `ultimate`; otherwise `normal`. This makes `봉인의 길` observable without inventing a new hit.

- [ ] **Step 1: Write RED modifier tests**

Assert `깨달음`, `오의 비전서`, and `봉인의 길` accelerate spirit gains; `유파 증표` lowers familiar interval; `인법단련` raises actual familiar damage; `봉인의 길` lowers normal familiar damage but raises familiar damage during ultimate.

- [ ] **Step 2: Run RED, implement minimal optional resolver wiring, run GREEN**

Keep `BongmaFamiliar.configure(player, interval, damage)` backward-compatible by adding optional resolver/damage-kind provider arguments after existing parameters rather than breaking every isolated caller.

- [ ] **Step 3: Run full Bongma + MVP-2 regressions and commit**

```bash
git add scripts/schools/bongma_runtime.gd scripts/schools/bongma_familiar.gd tests/unit/test_bongma_runtime.gd tests/unit/test_bongma_familiar.gd
git commit -m "feat: apply MVP-3 modifiers to Bongma"
```

---

### Task 11: Route Cheonsul through modifiers, readiness progress, and status telemetry

**Files:**
- Modify: `scripts/schools/cheonsul_runtime.gd`
- Modify: `tests/unit/test_cheonsul_runtime.gd`

**Behavior:**

- Replace integer-only readiness accumulation with float progress while preserving HUD compatibility:

```gdscript
var reaction_count: float = 0.0
const REACTION_MAXIMUM := 3.0
```

- Each successful WET->SHOCK reaction adds:

```gdscript
1.0 * (1.0 + school_resource_gain_pct) * (1.0 + ultimate_charge_gain_pct)
```

clamped to 3.0.
- Flame initial/burn/chain/reaction/ultimate damage uses `CombatResolver`.
- WET+SHOCK primary and chain damage get extra multiplier:

```gdscript
(1.0 + cheonsul_reaction_damage_pct) * (1.0 + school_status_effect_pct)
```

- Successful burn/token applications and actual WET+SHOCK reactions call `contribution_tracker.record_status_event()` once per successful event; damage is separately counted by resolver.
- `오행폭주` uses `ultimate` damage kind.

- [ ] **Step 1: Write RED tests for fractional readiness and damage mappings**

At +25% readiness, two reactions create 2.5 progress; third clamps at 3.0. Verify reaction damage responds to school emblem/금기의 길 and ultimate damage responds to 봉인의 길.

- [ ] **Step 2: Write RED telemetry tests**

Assert invalid token/no-op application does not count; successful token/reaction events do.

- [ ] **Step 3: Implement and run GREEN**

Preserve automatic SHOCK prioritization of existing WET targets and non-recursive chain logic.

- [ ] **Step 4: Commit**

```bash
git add scripts/schools/cheonsul_runtime.gd tests/unit/test_cheonsul_runtime.gd
git commit -m "feat: apply MVP-3 modifiers to Cheonsul"
```

---

### Task 12: Route Guiin through modifiers and contribution tracking

**Files:**
- Modify: `scripts/schools/guiin_runtime.gd`
- Modify: `tests/unit/test_guiin_runtime.gd`

**Behavior:**

- Gwihyeol gains multiply by resource/readiness modifiers, but decay remains unchanged.
- `유파 증표` multiplies final pulse radius by `1 + guiin_melee_radius_pct`.
- Preserve the existing local combat math in `current_pulse_damage()` (berserker/high-Gwihyeol/ultimate); feed that base final school value into the resolver so run modifiers apply once.
- Pulse uses damage kind `ultimate` while `ultimate_time_remaining > 0`, otherwise `normal`.
- Only enemies with actual damage >0 count as hit/resource gain.

- [ ] **Step 1: Write RED modifier tests**

Cover radius expansion, `깨달음`/`오의 비전서` gain acceleration, normal school damage modifier, and `봉인의 길` lower normal but higher ultimate pulse output.

- [ ] **Step 2: Implement minimal resolver/gain hooks and run GREEN**

Do not change base 0.90/80/10, low-HP 110/15, high-Gwihyeol 1.20x, or ultimate 0.45/130/1.25 rules.

- [ ] **Step 3: Commit**

```bash
git add scripts/schools/guiin_runtime.gd tests/unit/test_guiin_runtime.gd
git commit -m "feat: apply MVP-3 modifiers to Guiin"
```

---

### Task 13: Add Heukyeong mark lifetime and modifier mappings

**Files:**
- Modify: `scripts/schools/heukyeong_runtime.gd`
- Modify: `tests/unit/test_heukyeong_runtime.gd`

**Behavior:**

Add:

```gdscript
const BASE_MARK_DURATION := 8.0
var _mark_gain_credit := 0.0
```

Each mark state stores `remaining`. `_process(delta)` decrements mark time only while runtime processing is active; expired marks and badges are removed.

Effective duration:

```gdscript
BASE_MARK_DURATION * (1.0 + run_modifiers.heukyeong_mark_duration_pct)
```

Mark gain uses deterministic fractional credit:

```gdscript
_mark_gain_credit += float(base_mark_gain) * (1.0 + run_modifiers.school_resource_gain_pct)
var whole_gain := floori(_mark_gain_credit)
_mark_gain_credit -= whole_gain
```

Then apply whole marks to the target. Keep burst threshold 3 and ultimate readiness `get_total_active_marks() >= 3`.

`유파 증표` adds `heukyeong_marked_crit_bonus` to the existing marked-target critical chance, clamped to 1.0. It does not change unmarked base crit chance.

Damage:
- needle hit => normal resolver,
- burst => normal resolver with `(1 + school_status_effect_pct)`,
- shadow execution => ultimate resolver with `(1 + school_status_effect_pct)`.

- [ ] **Step 1: Replace the old permanent-mark assertion with RED expiry tests**

Remove/replace `test_marks_do_not_expire_with_time_and_charge_is_live_total`. New exact behavior:

```gdscript
runtime.apply_needle_hit(enemy, false)
runtime._attack_remaining = 999.0
runtime._process(7.99)
assert_eq(runtime.get_mark_count(enemy), 1)
runtime._process(0.01)
assert_eq(runtime.get_mark_count(enemy), 0)
```

- [ ] **Step 2: Write RED extended-duration/readiness tests**

One +25% `오의 비전서` => 10.0-second marks. Add `봉인의 길` +30% readiness to confirm duration sums to +55% when both sources exist. Rest pause itself is tested later at integration level by disabling runtime processing.

- [ ] **Step 3: Write RED fractional-mark/crit/status/ultimate tests**

Assert school-resource bonus eventually creates extra integer mark through credit, school emblem raises only marked crit chance, 금기의 길 boosts burst/execution status damage, and 봉인의 길 makes ultimate execution stronger while normal needle damage gets its normal penalty.

- [ ] **Step 4: Implement and run GREEN**

Preserve invalid-enemy pruning, badge lifecycle, burst reset, seeded RNG reproducibility, and exact 3-live-mark ultimate threshold.

- [ ] **Step 5: Commit**

```bash
git add scripts/schools/heukyeong_runtime.gd tests/unit/test_heukyeong_runtime.gd
git commit -m "feat: apply MVP-3 modifiers to Heukyeong"
```

---

### Task 14: Add compact combat HUD and full-screen rest-flow UI

**Files:**
- Modify: `scripts/ui/hud.gd`
- Modify: `scenes/ui/hud.tscn`
- Create: `tests/integration/test_mvp3_hud.gd`
- Create: `scripts/ui/rest_flow_ui.gd`
- Create: `scenes/ui/rest_flow_ui.tscn`
- Create: `tests/integration/test_mvp3_rest_flow_ui.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**HUD interfaces:**

```gdscript
func set_stage(segment: int, total: int = 3) -> void
func set_stage_time(seconds_remaining: float) -> void
func set_gold(gold: int) -> void
```

Formatting:

```text
SEGMENT 1/3
TIME 04:32
GOLD 37
```

Time uses `ceili(max(seconds_remaining, 0))`, integer minutes and two-digit seconds.

**RestFlowUI intent signals:**

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

Rendering methods accept plain dictionaries/ids/definitions and never mutate game state directly.

- [ ] **Step 1: Write RED HUD tests**

Assert the three new labels/methods and exact formatting while all MVP-1/2 labels remain present.

- [ ] **Step 2: Write RED rest UI structure/intent tests**

Scene has one full-screen panel with state containers for RESULT/SHOP/FATE/PREVIEW/COMPLETE. Only the requested state is visible. Verify button presses emit intent signals with ids/indexes but do not require controller objects.

RESULT rendering must show `기여 없음` for zero healing/defense. SHOP shows GOLD, 3 offer buttons, owned list, reroll cost and Next. FATE shows 3 cards with benefit and cost and has no skip. PREVIEW shows changes/fate/current GOLD and Start Combat. COMPLETE shows `MVP-3 LOOP COMPLETE` and restart.

- [ ] **Step 3: Implement placeholder/card UI with readable built-in Controls**

No custom art/animation. Use `PanelContainer`, `MarginContainer`, `VBoxContainer`, `HBoxContainer`, `Label`, `Button`, and `ScrollContainer` only as needed.

- [ ] **Step 4: Run GREEN + older HUD regressions**

- [ ] **Step 5: Commit**

```bash
git add scripts/ui/hud.gd scenes/ui/hud.tscn tests/integration/test_mvp3_hud.gd scripts/ui/rest_flow_ui.gd scenes/ui/rest_flow_ui.tscn tests/integration/test_mvp3_rest_flow_ui.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-3 combat and rest UI"
```

---

### Task 15: Integrate stage, economy, telemetry, shop, fate, and pause/resume in Main

**Files:**
- Modify: `scripts/core/main_controller.gd`
- Modify: `scenes/main/main_scene.tscn`
- Modify: `tests/integration/test_main_scene.gd`
- Modify only if approved stage behavior requires it: `tests/integration/test_mvp1_combat_loop.gd`, `tests/integration/test_mvp2_four_schools.gd`
- Create: `tests/integration/test_mvp3_stage_loop.gd`

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

`MainController` gets exported `stage_boss_scene: PackedScene` and onready references for the new nodes.

- [ ] **Step 1: Write RED main-node/start-stage integration assertions**

Before school selection:
- stage phase `SCHOOL_SELECT`,
- timer does not move,
- combat remains disabled as MVP-2 already requires,
- GOLD remains zero.

After selection:
- `RunBuildState.selected_school_id` is set before modifier sync,
- `StageFlow.start_after_school_selection()` enters COMBAT,
- player/school/enemies/spawner/DDD are active,
- HUD shows segment/time/GOLD,
- legacy AutoAttack remains disabled.

- [ ] **Step 2: Write RED timer->boss transition test with accelerated duration**

Set `StageFlow.segment_duration_seconds = 0.05` before selection. After threshold:
- phase BOSS,
- WaveSpawner no longer spawns new normals,
- living normal enemies remain active,
- exactly one `StageBoss` tier 1 exists and targets player,
- later frames do not duplicate it.

- [ ] **Step 3: Write RED boss-death settlement-order test**

On boss death exactly once:

```text
GameState.register_kill(100)
CombatDDD.register_kill()
SchoolRuntimeHost.forward_enemy_died(boss)
RunBuildState.grant_boss_gold()        # 25 only
ContributionTracker.record_kill(current_combo)
reward orb spawn
snapshot after all above
StageFlow.enter_result_after_boss()
cleanup remaining normal enemies with queue_free only
pause gameplay
render RESULT
```

Assert snapshot contains the boss kill/GOLD but cleanup gives no score/combo/school resource/GOLD. A repeated death callback remains idempotent via existing death metadata.

- [ ] **Step 4: Write RED normal-kill and telemetry wiring tests**

Normal death grants +1/luck-adjusted GOLD and contribution kill. School resolver records damage. Player `healing_resolved` and `damage_resolved` feed healing/defense tracker. Reward collection delta is captured by snapshot.

- [ ] **Step 5: Implement `_sync_run_modifiers()` and purchase-heal semantics**

Recommended orchestration:

```gdscript
func _sync_run_modifiers() -> void:
    var modifiers := run_build_state.get_modifiers()
    combat_resolver.set_modifiers(modifiers)
    player.apply_run_modifiers(modifiers)
    school_host.apply_run_modifiers(modifiers)
```

For successful `호신 부적` purchase:
1. record effective max HP before purchase,
2. buy through ShopController/RunBuildState,
3. sync modifiers,
4. compute new effective max HP minus old,
5. call `player.heal(increase)` only if positive.

Because rest snapshot is already frozen, this healing cannot rewrite prior RESULT.

- [ ] **Step 6: Implement phase-specific processing control**

`COMBAT`:
- player active,
- selected school host/runtime active by process mode,
- existing normals active,
- WaveSpawner process+spawning enabled,
- CombatDDD active,
- reward orbs active.

`BOSS`:
- same gameplay active,
- WaveSpawner process may remain active or disabled, but `set_spawning_enabled(false)` is mandatory,
- stage timer frozen by StageFlow phase.

`RESULT/SHOP/FATE/PREVIEW`:
- player/enemies/school host processing disabled without calling semantic `deactivate()`,
- spawner disabled,
- CombatDDD disabled so combo timer does not decay,
- reward orbs disabled,
- Main/UI/new controller nodes remain active.

Game over:
- existing `_on_player_died()` remains highest priority,
- call `StageFlow.mark_game_over()`,
- semantic `school_host.deactivate()` is allowed because the run is over,
- no rest/shop/fate reward may occur afterward.

- [ ] **Step 7: Wire RESULT -> SHOP -> FATE -> PREVIEW UI intents**

RESULT continue calls stage transition and `shop_controller.begin_rest()`. SHOP intents delegate to ShopController, resync modifiers on success, rerender shop, and Next enters FATE with `fate_controller.begin_rest()`. FATE click must be a current candidate and, after successful selection, resync modifiers and enter PREVIEW. PREVIEW Start Combat only succeeds for rests 1/2.

- [ ] **Step 8: Resume next segment in exact order**

Before combat resumes:
1. `ContributionTracker.reset_segment(...)`,
2. clear prior shop rest changes only after PREVIEW payload has been built,
3. apply rest-start heal `roundi(player.max_health * modifiers.rest_start_heal_pct)` via `player.heal()` so actual healing belongs to new segment,
4. remove any stale boss node,
5. re-enable gameplay/spawner/DDD/orbs,
6. enter next COMBAT.

Third PREVIEW instead renders COMPLETE; no heal or segment 4 is started.

- [ ] **Step 9: Run accelerated one-cycle and full three-cycle GREEN tests**

One-cycle path:

```text
select -> COMBAT -> threshold -> BOSS -> kill -> RESULT -> SHOP -> FATE -> PREVIEW -> COMBAT 2
```

Full accelerated path repeats through tier 3 and ends COMPLETE.

- [ ] **Step 10: Commit**

```bash
git add scripts/core/main_controller.gd scenes/main/main_scene.tscn tests/integration/test_main_scene.gd tests/integration/test_mvp3_stage_loop.gd
git commit -m "feat: integrate MVP-3 stage and rest loop"
```

Only include older MVP-1/MVP-2 integration test files in this commit if they required an explicit approved stage-flow adaptation.

---

### Task 16: Verify all four schools under real run modifiers and close adversarial findings

**Files:**
- Create: `tests/integration/test_mvp3_four_school_modifiers.gd`
- Modify: focused production/test files only for accepted findings.
- Add generated source-side `.gd.uid` files after Godot 4.7.1 import where appropriate.
- Never stage `project.godot` or `addons/`.

- [ ] **Step 1: Add cross-school integration coverage**

For each school, select it in a main-scene instance and verify:
- base offense still damages/kills,
- existing resource/readiness still functions,
- apply `인법단련` and actual school damage rises,
- apply `오의 비전서` and its approved readiness mapping is non-no-op,
- apply `유파 증표` and its school-specific channel is observable,
- apply `봉인의 길`: normal school damage decreases while ultimate output/readiness improves,
- rest process pause/resume preserves school identity/resource,
- existing ultimate can still execute.

- [ ] **Step 2: Add immutable-result/rest-mutation integration test**

Freeze a segment result, then buy/sell, heal, select fate, reroll, and assert the stored RESULT dictionary is byte/value-equivalent to the original snapshot.

- [ ] **Step 3: Add game-over priority tests in COMBAT and BOSS**

Assert death prevents RESULT/shop/fate transition and uses the existing restart path.

- [ ] **Step 4: Run full local/remote-capable regression commands**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --import
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --scene res://scenes/main/main_scene.tscn --quit-after 120
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Require no `SCRIPT ERROR:` / `ERROR:` in smoke and all GUT tests green.

- [ ] **Step 5: Run the Compound/adversarial review**

Attack at least these failures and classify every finding as `MUST_FIX`, `SHOULD_FIX`, `USER_DECISION_REQUIRED`, `DEFER`, `REJECTED_CRITIQUE`, `BLOCKED_UNVERIFIED`, or `ALLOWED_LEGACY`:

1. timer advancing before selection or during boss/rest,
2. duplicate boss spawn at exact/overshoot threshold,
3. boss receiving 26 GOLD instead of 25,
4. leftover normal cleanup granting rewards,
5. combo timer decaying during rest,
6. rest pause semantically deactivating/resetting school resource,
7. result snapshot changing after shop/fate/heal,
8. failed buy/reroll/fate mutation changing wallet/offers/state,
9. 7th inventory item or 3rd duplicate entering inventory,
10. stale/duplicate fate candidate,
11. fractional GOLD/mark/readiness progress rounding nondeterministically,
12. `봉인의 길` penalizing ultimate damage accidentally or failing to improve Bongma ultimate output,
13. Heukyeong mark-duration mapping remaining a no-op,
14. status/reaction events double-counting damage as status contribution,
15. overkill counted as actual dealt damage,
16. max-HP clamp counted as defense,
17. game-over racing a stage transition,
18. live reward orb moving/collecting during rest,
19. `project.godot`/`addons/` entering the diff,
20. backpack/final-loop scope accidentally entering MVP-3.

For accepted `MUST_FIX`/`SHOULD_FIX`, add a regression test first, apply the minimal fix, and rerun the affected suite.

- [ ] **Step 6: Exact-head GitHub Actions gate**

Because the workflow runs on pull requests and main pushes, open/update the feature PR after implementation if needed to trigger CI. Require the exact feature HEAD to pass:
- checkout,
- Godot 4.7.1 install,
- GUT 9.7.1 install,
- project import,
- main-scene smoke,
- full GUT.

Do not reuse CI evidence from an earlier HEAD.

- [ ] **Step 7: Windows local metadata gate**

On the user's Windows checkout, preserve the known local plugin state. Run Godot 4.7.1 import/full GUT, inspect `git status --short`, and stage only source/test `.gd.uid` metadata that belongs to MVP-3. Explicitly reject `project.godot`, `addons/`, and unrelated files.

- [ ] **Step 8: Manual acceptance gate**

Run normal production timing for at least the first boundary and verify:

```text
1. school selection still gates combat
2. HUD shows SEGMENT/TIME/GOLD without hiding existing feedback
3. real 5:00 combat time stops new normal waves and spawns exactly one tier-1 boss
4. surviving normals remain dangerous during boss fight
5. boss death opens readable RESULT
6. RESULT values are directionally consistent with play
7. shop buy/sell/reroll and failure messages are understandable
8. fate cards show upside + downside and cannot be skipped
9. combat is inert throughout rest
10. PREVIEW communicates changes before restart of combat
11. game over/restart still works
```

A full real-time 15-minute run is a tuning/acceptance follow-up, not a CI requirement.

- [ ] **Step 9: Ready-for-review report**

Report:
- Superpowers skills used,
- files inspected/changed and why,
- implementation summary,
- exact verification evidence,
- untested/manual-only items,
- user Godot check steps,
- remaining risks,
- Compound Review mistakes/near-misses, lessons, prevention checklist, Base-promotion candidates, project-only rule candidates.

Only after all required gates are satisfied should the branch be presented as ready for merge review. **Do not merge without explicit user approval.**
