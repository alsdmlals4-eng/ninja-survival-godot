# MVP-4 Backpack / Combination Basics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved MVP-4 spatial backpack / combination loop so boss/shop/chest rewards enter a six-slot REST work buffer, the player builds a valid 6x6 loadout with rotation/adjacency/special-bag effects, explicit combinations commit atomically, and the Persistent Workbench is completable by mouse, keyboard/gamepad, and touch before Fate commits the next-combat build.

**Architecture:** Keep `MainController` as composition root and MVP-3 as rollback baseline. Add a UI-independent spatial domain (`BackpackState`, `BackpackResolver`, `RestBackpackSession`, `CombinationResolver`) and make `RunBuildState` combine only the **committed** backpack modifier snapshot with Fate. `RestFlowUI` remains the outer RESULT/FATE/PREVIEW/COMPLETE surface while `RestWorkbenchUI` + `BackpackBoardUI` render snapshots and emit intent. Acquisition and combination transactions validate all prerequisites before one state mutation.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1, `Resource`/`RefCounted` domain data, `Node` controllers, `CanvasLayer`/`Control` UI, GitHub Actions Ubuntu verification.

## Global Constraints

- Planning baseline is `main@655ec26a5ac9946c0ec08f81f389ddfe66e72b65` after PR #7.
- Canonical design is `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`.
- Traceability is `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md`.
- Local project root, once BUILD is authorized, is `C:/Users/user/Documents/GitHub/Ninza/ninja-survival-godot`.
- **Production implementation MUST NOT begin until the user explicitly declares `기획 완료`.** The current deliverable is planning only.
- Every behavior change uses strict TDD: focused RED → observe expected failure → minimal GREEN → focused regression → prior-task regression → commit.
- Board is exactly `6x6`; starting active area is exactly `4x3`; REST work buffer is exactly `6` item slots.
- Bags and items rotate by 90-degree quarter turns. Regular MVP-4 items are rectangular; selected bags may be L/T-shaped.
- Item adjacency is orthogonal edge sharing only; a same-pair/same-synergy relation applies once regardless of touching-edge count.
- A special bag applies once to an item when at least one item cell overlaps it; distinct bag instances may each apply once.
- Buffer items contribute zero combat, adjacency, special-bag, and combination effects.
- Fate entry requires: boss reward handled, chest count `0`, buffer `0`, no pending bag, all placements valid, connected active bag cells, no pending combination.
- Combination is explicit and atomic: sources remain until a legal result placement is committed; completed combination is not Undo/Redo history.
- Whole-layout translation is available only in a visible mutually exclusive `전체 이동 모드`; normal arrows/D-pad navigate focus/cells.
- Touch has a complete tap-select → tap-place path; precision drag, hover, or long-press is never mandatory.
- Preserve MVP-0~3 combat, four-school identity, DDD, result telemetry, GOLD/Fate behavior unless the approved MVP-4 contract explicitly replaces a boundary.
- Existing `RunBuildState.owned_items` is not allowed to remain a second combat-modifier authority after spatial commit integration.
- Do not add a save system, autoload, deep rarity, 2nd/3rd-tier combination, arbitrary polyomino regular items, deep set/curse, MVP-5 final loop, or unrelated refactor.
- Do not modify `.github/workflows/gut.yml` without a separately demonstrated verification gap. Current CI imports, smoke-runs main scene, then runs full GUT.
- Do not add shared `project.godot` InputMap entries for Workbench by default. Current project has no InputMap section; prefer `Control` GUI events, `_unhandled_key_input`, and visible UI actions.
- Never stage local `addons/`, `.godot/`, unrelated plugin files, or use `git add .`, `git add -A`, or destructive clean/reset operations.
- Google Sheet write `403` is an external documentation-sync blocker, not a reason to weaken GitHub canon or stop independent implementation work after `기획 완료`.

## Initial Authoring Defaults

These are `RECOMMENDED_DEFAULT` values for the first implementation/playtest, not immutable product rules.

### Item footprints

| id | size |
|---|---|
| `taijutsu_training` | 1x1 |
| `protection_talisman` | 1x2 |
| `fortune_talisman` | 1x1 |
| `ninjutsu_training` | 1x2 |
| `enlightenment` | 1x1 |
| `regeneration_scroll` | 1x2 |
| `ultimate_treatise` | 1x2 |
| `school_emblem` | 2x2 |
| `katana` | 1x3 |
| `shuriken` | 1x1 |
| `bomb` | 2x2 |
| `water_style` | 1x2 |
| `lightning_style` | 1x2 |
| `fire_style` | 1x2 |
| `stealth_art` | 1x2 |
| `poison_needles` | 1x2 |
| `barrier_art` | 2x2 |
| `greater_summoning_circle` | 2x3 |
| `forbidden_talisman` | 1x3 |

Representative combinations remain:

- `water_style + stealth_art -> water_mist`
- `katana + lightning_style -> thunder_blade`
- `bomb + fire_style -> explosive_bomb`

### Bag footprints

| id | cells relative to origin |
|---|---|
| `small_pouch` | `(0,0),(1,0)` |
| `long_pouch` | `(0,0),(1,0),(2,0)` |
| `square_pouch` | `(0,0),(1,0),(0,1),(1,1)` |
| `tactical_t_pouch` | `(0,0),(1,0),(2,0),(1,1)` |
| `ninjutsu_l_pouch` | `(0,0),(0,1),(0,2),(1,2)` |

The non-shop starting 4x3 ninja bag begins at `Vector2i(1, 1)` as an implementation default so the initial board can demonstrate whole-layout translation in every direction.

## File Structure

**New data/domain**
- `scripts/data/bag_definition.gd`
- `scripts/data/item_instance.gd`
- `scripts/data/bag_instance.gd`
- `scripts/data/combination_definition.gd`
- `scripts/data/mvp4_catalog.gd`
- `scripts/backpack/backpack_state.gd`
- `scripts/backpack/backpack_resolution.gd`
- `scripts/backpack/backpack_resolver.gd`
- `scripts/backpack/build_preview_snapshot.gd`
- `scripts/backpack/rest_backpack_session.gd`
- `scripts/backpack/combination_resolver.gd`

**New reward/enemy/UI**
- `scripts/core/rest_reward_controller.gd`
- `scripts/enemies/stage_elite.gd`
- `scenes/enemies/stage_elite.tscn`
- `scripts/ui/backpack_board_ui.gd`
- `scripts/ui/rest_workbench_ui.gd`
- `scenes/ui/backpack_board_ui.tscn`
- `scenes/ui/rest_workbench_ui.tscn`

**Existing integration surfaces**
- `scripts/data/item_definition.gd`
- `scripts/core/run_build_state.gd`
- `scripts/core/shop_controller.gd`
- `scripts/core/stage_flow_controller.gd`
- `scripts/core/main_controller.gd`
- `scripts/spawning/wave_spawner.gd`
- `scripts/enemies/stage_boss.gd` only if a shared elite/boss identity helper is demonstrably needed; otherwise leave unchanged
- `scripts/ui/rest_flow_ui.gd`
- `scenes/ui/rest_flow_ui.tscn`
- `scenes/main/main_scene.tscn`
- `tests/unit/test_script_contracts.gd`

**Focused tests**
- `tests/unit/test_mvp4_catalog.gd`
- `tests/unit/test_backpack_state.gd`
- `tests/unit/test_backpack_resolver.gd`
- `tests/unit/test_rest_backpack_session.gd`
- `tests/unit/test_combination_resolver.gd`
- `tests/unit/test_rest_reward_controller.gd`
- existing `tests/unit/test_run_build_state.gd`
- existing `tests/unit/test_shop_controller.gd`
- existing `tests/unit/test_stage_flow_controller.gd`
- existing `tests/unit/test_wave_spawner.gd`
- `tests/unit/test_stage_elite.gd`
- `tests/integration/test_mvp4_workbench_ui.gd`
- `tests/integration/test_mvp4_input_parity.gd`
- `tests/integration/test_mvp4_stage_rest_loop.gd`
- `tests/integration/test_mvp4_four_school_builds.gd`

---

### Task 1: Spatial data contracts and MVP-4 catalog

**Traceability:** `T01 / REQ-MVP4-01 / V01`

**Files:** Modify `scripts/data/item_definition.gd`, `tests/unit/test_script_contracts.gd`; create `scripts/data/bag_definition.gd`, `scripts/data/item_instance.gd`, `scripts/data/bag_instance.gd`, `scripts/data/combination_definition.gd`, `scripts/data/mvp4_catalog.gd`, `tests/unit/test_mvp4_catalog.gd`.

**Interfaces:**

```gdscript
# item_definition.gd additions
@export var footprint_size: Vector2i = Vector2i.ONE
@export var adjacency_tags: Array[StringName] = []
@export var combination_tags: Array[StringName] = []
func footprint(rotation_quarters: int) -> Array[Vector2i]
```

```gdscript
# bag_definition.gd
extends Resource
class_name BagDefinition
@export var id: StringName = &""
@export var display_name: String = ""
@export var base_price: int = 0
@export var cells: Array[Vector2i] = []
@export var affected_item_tag: StringName = &""
@export var auxiliary_effect_kind: StringName = &""
@export var auxiliary_effect_value: float = 0.0
func footprint(rotation_quarters: int) -> Array[Vector2i]
```

```gdscript
# item_instance.gd
extends RefCounted
class_name ItemInstance
var instance_id: int = 0
var definition_id: StringName = &""
var origin: Vector2i = Vector2i.ZERO
var rotation_quarters: int = 0
func copy_value() -> ItemInstance
```

`BagInstance` has the same scalar fields and returns `BagInstance` from `copy_value()`.

```gdscript
# combination_definition.gd
extends Resource
class_name CombinationDefinition
@export var id: StringName = &""
@export var source_a: StringName = &""
@export var source_b: StringName = &""
@export var result_item: StringName = &""
@export var undiscovered_hint: String = ""
```

- [ ] **Step 1: Write RED tests** proving 19 base-item ids, 5 purchasable bags, one 4x3 basic bag and 3 combinations are unique/resolvable; non-square item rotation swaps footprint axes; L/T bag rotations normalize to non-negative local coordinates.

```gdscript
func test_katana_rotates_from_vertical_to_horizontal() -> void:
    var katana = MVP4Catalog.build_items()[&"katana"]
    assert_true(katana.footprint(0).has(Vector2i(0, 2)))
    assert_true(katana.footprint(1).has(Vector2i(2, 0)))

func test_every_combination_reference_resolves() -> void:
    var items := MVP4Catalog.build_items()
    for combo in MVP4Catalog.build_combinations().values():
        assert_true(items.has(combo.source_a))
        assert_true(items.has(combo.source_b))
        assert_true(items.has(combo.result_item))
```

- [ ] **Step 2: Run RED.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_mvp4_catalog.gd -gexit
```

Expected failure: missing MVP-4 classes/catalog or spatial fields, not a syntax error.

- [ ] **Step 3: Implement the minimum contracts/catalog.** Preserve existing MVP-3 effect fields and ids; spatial fields must not alter current combat before a committed backpack exists.
- [ ] **Step 4: Run GREEN and `test_script_contracts.gd`.**
- [ ] **Step 5: Commit only listed paths.**

```bash
git add scripts/data/item_definition.gd scripts/data/bag_definition.gd scripts/data/item_instance.gd scripts/data/bag_instance.gd scripts/data/combination_definition.gd scripts/data/mvp4_catalog.gd tests/unit/test_mvp4_catalog.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-4 spatial data contracts"
```

---

### Task 2: `BackpackState` spatial source of truth

**Traceability:** `T02 / REQ-MVP4-02 / V02`

**Files:** Create `scripts/backpack/backpack_state.gd`, `tests/unit/test_backpack_state.gd`; modify `tests/unit/test_script_contracts.gd`.

```gdscript
extends RefCounted
class_name BackpackState
const BOARD_SIZE := Vector2i(6, 6)
var bags: Dictionary = {}
var items: Dictionary = {}
var next_instance_id: int = 1
func create_starting_state() -> BackpackState
func add_item(definition_id: StringName, origin: Vector2i, rotation_quarters: int = 0) -> int
func add_bag(definition_id: StringName, origin: Vector2i, rotation_quarters: int = 0) -> int
func remove_item(instance_id: int) -> ItemInstance
func remove_bag(instance_id: int) -> BagInstance
func get_item(instance_id: int) -> ItemInstance
func get_bag(instance_id: int) -> BagInstance
func copy_value() -> BackpackState
```

- [ ] **Step 1: RED tests** for the starting 4x3 bag at `(1,1)`, monotonic instance ids, deep-copy independence, lookup/removal, and absence of collision/modifier calculation in this class.
- [ ] **Step 2: Run RED.**
- [ ] **Step 3: Implement storage/copy only.**
- [ ] **Step 4: Run GREEN + Task 1 regression.**
- [ ] **Step 5: Commit.**

```bash
git add scripts/backpack/backpack_state.gd tests/unit/test_backpack_state.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add backpack spatial state"
```

---

### Task 3: Deterministic geometry, connectivity, adjacency and special-bag resolution

**Traceability:** `T03 / REQ-MVP4-02 / V03`

**Files:** Create `scripts/backpack/backpack_resolution.gd`, `scripts/backpack/backpack_resolver.gd`, `tests/unit/test_backpack_resolver.gd`; modify `tests/unit/test_script_contracts.gd`.

```gdscript
class_name BackpackResolution
extends RefCounted
var valid: bool = true
var failure_code: StringName = &""
var failure_cells: Array[Vector2i] = []
var active_cells: Dictionary = {}
var item_cells: Dictionary = {}
var adjacency_pairs: Array[Vector2i] = []
var special_bag_hits: Dictionary = {}
var modifiers: RunModifierSet
```

```gdscript
class_name BackpackResolver
extends RefCounted
func resolve(state: BackpackState, item_defs: Dictionary, bag_defs: Dictionary, selected_school_id: StringName) -> BackpackResolution
func can_place_item(state: BackpackState, candidate: ItemInstance, item_defs: Dictionary, bag_defs: Dictionary) -> BackpackResolution
func can_place_bag(state: BackpackState, candidate: BagInstance, item_defs: Dictionary, bag_defs: Dictionary) -> BackpackResolution
func translated_state(state: BackpackState, delta: Vector2i, item_defs: Dictionary, bag_defs: Dictionary) -> Dictionary
```

- [ ] **Step 1: RED geometry tests** for board bounds, inactive item cells, bag overlap, item overlap, disconnected active cells, legal connected extension, item rotation and all-or-nothing whole-layout translation.
- [ ] **Step 2: RED relationship tests** for orthogonal adjacency once/pair, diagonal exclusion, one-cell special-bag hit, one item hit by two distinct bags, deterministic copied-state output.
- [ ] **Step 3: Run RED.**
- [ ] **Step 4: Implement normalized footprints, occupancy maps and 4-neighbor BFS connectivity.** Canonicalize pair ids so touching two edges does not double count.
- [ ] **Step 5: Run GREEN + `test_run_build_state.gd` regression.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/backpack/backpack_resolution.gd scripts/backpack/backpack_resolver.gd tests/unit/test_backpack_resolver.gd tests/unit/test_script_contracts.gd
git commit -m "feat: resolve backpack geometry and relationships"
```

---

### Task 4: REST session, six-slot buffer, preview, history and whole-layout mode

**Traceability:** `T04 / REQ-MVP4-03 / V04`

**Files:** Create `scripts/backpack/build_preview_snapshot.gd`, `scripts/backpack/rest_backpack_session.gd`, `tests/unit/test_rest_backpack_session.gd`; modify `tests/unit/test_script_contracts.gd`.

```gdscript
class_name RestBackpackSession
extends RefCounted
const BUFFER_CAPACITY := 6
enum InputMode { NORMAL, WHOLE_LAYOUT_MOVE }
var state: BackpackState
var buffer: Array[ItemInstance] = []
var pending_bag: BagInstance
var input_mode: InputMode = InputMode.NORMAL
func begin(committed_state: BackpackState, resolver: BackpackResolver, item_defs: Dictionary, bag_defs: Dictionary, selected_school_id: StringName) -> void
func preview_item(instance_id: int, origin: Vector2i, rotation_quarters: int) -> BuildPreviewSnapshot
func commit_item_preview() -> bool
func rotate_item(instance_id: int) -> bool
func move_item_to_buffer(instance_id: int) -> bool
func place_buffer_item(buffer_index: int, origin: Vector2i, rotation_quarters: int = 0) -> bool
func set_pending_bag(bag: BagInstance) -> bool
func place_pending_bag(origin: Vector2i, rotation_quarters: int = 0) -> bool
func enter_whole_layout_move_mode() -> bool
func translate_whole_layout(delta: Vector2i) -> bool
func exit_whole_layout_move_mode() -> void
func undo() -> bool
func redo() -> bool
func commit_failures(chest_count: int, boss_reward_pending: bool, combination_pending: bool) -> Array[StringName]
```

- [ ] **Step 1: RED buffer tests:** capacity six; board→buffer disables effects; buffer→board requires legal placement.
- [ ] **Step 2: RED history tests:** move/rotate/place/buffer transitions are undoable; purchase/sale/chest/combine/Fate are not; new edit clears redo.
- [ ] **Step 3: RED mode tests:** normal mode rejects whole-layout translation; explicit mode accepts it; failed translation is atomic and keeps the visible mode; exit restores normal semantics.
- [ ] **Step 4: Run RED, implement deep-state edit snapshots, run GREEN.**
- [ ] **Step 5: Run Tasks 2–3 regression.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/backpack/build_preview_snapshot.gd scripts/backpack/rest_backpack_session.gd tests/unit/test_rest_backpack_session.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add REST backpack edit session"
```

---

### Task 5: Explicit atomic combinations and progressive hints

**Traceability:** `T05 / REQ-MVP4-04 / V05`

**Files:** Create `scripts/backpack/combination_resolver.gd`, `tests/unit/test_combination_resolver.gd`; modify `scripts/backpack/rest_backpack_session.gd`, `scripts/data/mvp4_catalog.gd`.

```gdscript
class_name CombinationResolver
extends RefCounted
enum HintStage { UNDISCOVERED, INGREDIENT_OWNED, READY, DISCOVERED }
func eligible_pairs(state: BackpackState, resolution: BackpackResolution, combos: Dictionary) -> Array[Dictionary]
func hint_stage(combo_id: StringName, state: BackpackState, resolution: BackpackResolution, discovered: Dictionary, combos: Dictionary) -> HintStage
func begin_result_preview(session: RestBackpackSession, combo_id: StringName, source_a_instance: int, source_b_instance: int) -> bool
func commit_result(session: RestBackpackSession, origin: Vector2i, rotation_quarters: int = 0) -> bool
func cancel_result(session: RestBackpackSession) -> void
```

- [ ] **Step 1: RED tests** for diagonal failure, buffer-source failure, READY only under valid orthogonal adjacency, invalid result placement preserving both sources, cancel preserving sources, legal commit consuming exactly two once and creating one result, repeated commit ignored, first success marking discovery.
- [ ] **Step 2: Run RED.**
- [ ] **Step 3: Implement pending combination transaction; never remove a source before result placement succeeds.**
- [ ] **Step 4: Run GREEN + Task 4 regression.**
- [ ] **Step 5: Commit.**

```bash
git add scripts/backpack/combination_resolver.gd scripts/backpack/rest_backpack_session.gd scripts/data/mvp4_catalog.gd tests/unit/test_combination_resolver.gd
git commit -m "feat: add atomic backpack combinations"
```

---

### Task 6: Commit spatial modifiers into `RunBuildState`

**Traceability:** `T06 / REQ-MVP4-05 / V06`

**Files:** Modify `scripts/core/run_build_state.gd`, `tests/unit/test_run_build_state.gd`; modify `scripts/data/run_modifier_set.gd` only for a required copy/add helper.

```gdscript
func set_committed_backpack_modifiers(modifiers: RunModifierSet) -> void
func get_committed_backpack_modifiers() -> RunModifierSet
func get_modifiers() -> RunModifierSet
```

- [ ] **Step 1: RED tests** proving committed spatial snapshot affects combat modifiers, uncommitted preview/buffer does not, Fate still combines, and old `owned_items` count cannot contribute as a second source.
- [ ] **Step 2: Run RED.**
- [ ] **Step 3: Add `_committed_backpack_modifiers` and a single additive recomputation path; retain `owned_items` only if a temporary compatibility caller still needs it, never as modifier authority.**
- [ ] **Step 4: Run GREEN + existing four-school modifier regression.**
- [ ] **Step 5: Commit.**

```bash
git add scripts/core/run_build_state.gd scripts/data/run_modifier_set.gd tests/unit/test_run_build_state.gd
git commit -m "refactor: commit spatial backpack modifiers"
```

---

### Task 7: Atomic boss/shop/chest acquisition into the REST session

**Traceability:** `T07 / REQ-MVP4-06 / V07`

**Files:** Create `scripts/core/rest_reward_controller.gd`, `tests/unit/test_rest_reward_controller.gd`; modify `scripts/core/shop_controller.gd`, `tests/unit/test_shop_controller.gd`, `scripts/data/mvp4_catalog.gd`.

```gdscript
class_name RestRewardController
extends Node
signal rewards_changed
signal transaction_failed(reason: StringName)
func configure(build_state: RunBuildState, session: RestBackpackSession, item_defs: Dictionary, bag_defs: Dictionary, rng: RandomNumberGenerator) -> void
func begin_rest(segment_index: int, selected_school_id: StringName, chest_tokens: int) -> void
func boss_reward_options() -> Array[StringName]
func choose_boss_reward(index: int) -> bool
func chest_count() -> int
func open_chest() -> bool
func buy_shop_item(index: int) -> bool
func buy_shop_bag() -> bool
func sell_item(instance_id: int) -> bool
func reroll_shop() -> bool
func has_pending_boss_reward() -> bool
```

- [ ] **Step 1: RED boss reward:** 3 distinct options, at least one school-related candidate, one free buffer slot required, repeated choice cannot duplicate.
- [ ] **Step 2: RED chest:** one token → exactly two seeded items only with two free buffer slots; failed open preserves token.
- [ ] **Step 3: RED shop:** 3 distinct item offers + 1 bag; purchase validates GOLD and capacity before spend; bag purchase validates one-bag/rest cap; reroll remains 5→10→15; purchase does not change committed combat modifiers.
- [ ] **Step 4: Run RED; implement validation-before-mutation ordering; run GREEN.**
- [ ] **Step 5: Existing shop/GOLD regression.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/core/rest_reward_controller.gd scripts/core/shop_controller.gd scripts/data/mvp4_catalog.gd tests/unit/test_rest_reward_controller.gd tests/unit/test_shop_controller.gd
git commit -m "feat: route REST rewards into workbench"
```

---

### Task 8: Add exact elite cadence and MVP-4 phase flow

**Traceability:** `T08 / REQ-MVP4-07 / V08`

**Files:**
- Create `scripts/enemies/stage_elite.gd`
- Create `scenes/enemies/stage_elite.tscn`
- Create `tests/unit/test_stage_elite.gd`
- Modify `scripts/core/stage_flow_controller.gd`
- Modify `tests/unit/test_stage_flow_controller.gd`
- Modify `scripts/core/main_controller.gd`
- Modify `scripts/spawning/wave_spawner.gd`
- Modify `tests/unit/test_wave_spawner.gd`
- Do **not** modify `scripts/enemies/stage_boss.gd` unless a new RED test proves a shared identity API is required.

**Target phase/signal contract:**

```gdscript
enum Phase {
    SCHOOL_SELECT,
    COMBAT,
    BOSS,
    RESULT,
    BOSS_REWARD,
    REST,
    FATE,
    PREVIEW,
    COMPLETE,
    GAME_OVER,
}
signal elite_requested(segment: int)
signal boss_requested(tier: int)
@export var elite_time_seconds: float = 180.0
@export var segment_duration_seconds: float = 300.0
```

```gdscript
# stage_elite.gd
extends EnemyChaser
class_name StageElite
var segment_index: int = 1
func configure_segment(new_segment: int) -> void:
    segment_index = maxi(new_segment, 1)
func is_stage_elite() -> bool:
    return true
```

`MainController` preloads `res://scenes/enemies/stage_elite.tscn`, spawns one on `elite_requested` at the same `wave_spawner.spawn_distance` boundary used by the boss, and keeps normal wave spawning enabled during the elite. Elite death passes through existing `_on_enemy_died` exactly once; that path grants one chest token through `RestRewardController` (or a narrow pending-token counter owned by it) without granting boss GOLD. The existing StageBoss path remains the five-minute gate.

- [ ] **Step 1: RED timing tests:** elite signal fires once when elapsed segment time crosses injected elite threshold, COMBAT continues, boss fires once at segment end.
- [ ] **Step 2: RED `StageElite` tests:** identity true, segment configuration stable, normal `EnemyChaser` death contract retained.
- [ ] **Step 3: RED integration seam:** `_on_enemy_died` distinguishes elite from stage boss; elite kill creates exactly one chest token; elite spawn without kill creates none; normal kill creates none.
- [ ] **Step 4: RED phase tests:** `BOSS -> RESULT -> BOSS_REWARD -> REST -> FATE -> PREVIEW/COMPLETE`; REST cannot skip forced boss reward.
- [ ] **Step 5: Run RED.**
- [ ] **Step 6: Implement one-shot elite flag in `StageFlowController`, exact scene spawn/wiring in `MainController`, and only the minimal `WaveSpawner` API needed to preserve normal spawning during elite and stop it for the boss.**
- [ ] **Step 7: Run GREEN + existing MVP-3 accelerated stage-loop regression, updating only assertions superseded by BOSS_REWARD/REST.**
- [ ] **Step 8: Commit exact paths.**

```bash
git add scripts/enemies/stage_elite.gd scenes/enemies/stage_elite.tscn tests/unit/test_stage_elite.gd scripts/core/stage_flow_controller.gd tests/unit/test_stage_flow_controller.gd scripts/core/main_controller.gd scripts/spawning/wave_spawner.gd tests/unit/test_wave_spawner.gd
git commit -m "feat: add MVP-4 elite and REST phases"
```

---

### Task 9: Persistent Workbench and board presentation

**Traceability:** `T09 / REQ-MVP4-08 / V09`

**Files:** Create `scripts/ui/backpack_board_ui.gd`, `scripts/ui/rest_workbench_ui.gd`, `scenes/ui/backpack_board_ui.tscn`, `scenes/ui/rest_workbench_ui.tscn`, `tests/integration/test_mvp4_workbench_ui.gd`; modify `scripts/ui/rest_flow_ui.gd`, `scenes/ui/rest_flow_ui.tscn`.

```gdscript
class_name BackpackBoardUI
extends Control
signal cell_action_requested(cell: Vector2i)
signal item_selected(instance_id: int)
signal bag_selected(instance_id: int)
signal rotate_requested
signal whole_layout_mode_requested(enabled: bool)
signal whole_layout_direction_requested(delta: Vector2i)
signal cancel_requested
func render(snapshot: Dictionary) -> void
func focus_cell(cell: Vector2i) -> void
```

```gdscript
class_name RestWorkbenchUI
extends Control
signal chest_open_requested
signal shop_item_buy_requested(index: int)
signal shop_bag_buy_requested
signal shop_reroll_requested
signal sell_item_requested(instance_id: int)
signal buffer_item_selected(index: int)
signal combine_requested(combo_id: StringName)
signal fate_commit_requested
func render(model: Dictionary) -> void
```

- [ ] **Step 1: RED scene test:** instantiate desktop Workbench; assert central board contains 36 cell controls and GOLD/chest/buffer/commit summary remain present.
- [ ] **Step 2: RED feedback test:** provided legal/invalid/adjacency/special-bag/combo snapshot changes outline/icon/text nodes; UI never derives legality from coordinates.
- [ ] **Step 3: Run RED.**
- [ ] **Step 4: Implement placeholder-safe `Control`/`Container` scenes and signal-only interaction.** Keep decorative polish out.
- [ ] **Step 5: Run GREEN + existing rest UI regression with only superseded SHOP-screen assumptions changed.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/ui/backpack_board_ui.gd scripts/ui/rest_workbench_ui.gd scenes/ui/backpack_board_ui.tscn scenes/ui/rest_workbench_ui.tscn scripts/ui/rest_flow_ui.gd scenes/ui/rest_flow_ui.tscn tests/integration/test_mvp4_workbench_ui.gd
git commit -m "feat: add persistent REST workbench UI"
```

---

### Task 10: Keyboard/gamepad/touch parity and responsive adapters

**Traceability:** `T10 / REQ-MVP4-09 / V10`

**Files:** Modify the four Workbench/board UI files from Task 9; create `tests/integration/test_mvp4_input_parity.gd`.

- [ ] **Step 1: RED mode-input test:** normal directional input changes board focus and emits zero layout deltas; after visible `전체 이동` activation the same input emits exactly one delta and does not change focus; cancel restores normal behavior.

```gdscript
func test_direction_has_exactly_one_meaning_per_mode() -> void:
    board.focus_cell(Vector2i(2, 2))
    _send_right_key(board)
    assert_eq(layout_move_deltas.size(), 0)
    board.enter_whole_layout_mode_for_test()
    _send_right_key(board)
    assert_eq(layout_move_deltas, [Vector2i.RIGHT])
```

- [ ] **Step 2: RED touch test:** tap-select + tap-place exposes the same placement intent without drag; visible direction buttons expose whole-layout deltas; required actions have positive hit rectangles meeting the chosen ~48dp-equivalent layout target.
- [ ] **Step 3: RED responsive test** at synthetic `1280x720`, `1920x1080`, `800x1280`: board remains in viewport; required controls have nonzero rect; Android adapter keeps board central and secondary content reachable.
- [ ] **Step 4: Run RED.**
- [ ] **Step 5: Implement explicit focus neighbors, mode label/border, touch direction controls and container adapter switching.** No project-wide InputMap mutation.
- [ ] **Step 6: Run GREEN + Task 9 regression.** Record human usability as `HUMAN_NOT_RUN`.
- [ ] **Step 7: Commit.**

```bash
git add scripts/ui/backpack_board_ui.gd scripts/ui/rest_workbench_ui.gd scenes/ui/backpack_board_ui.tscn scenes/ui/rest_workbench_ui.tscn tests/integration/test_mvp4_input_parity.gd
git commit -m "feat: add workbench input parity"
```

---

### Task 11: Full MVP-4 composition and commit boundary

**Traceability:** `T11 / REQ-MVP4-10 / V11`

**Files:** Modify `scripts/core/main_controller.gd`, `scripts/core/stage_flow_controller.gd`, `scripts/ui/rest_flow_ui.gd`, `scenes/ui/rest_flow_ui.tscn`, `scenes/main/main_scene.tscn`; create `tests/integration/test_mvp4_stage_rest_loop.gd`, `tests/integration/test_mvp4_four_school_builds.gd`.

**Composition:**

```text
MVP4Catalog
→ committed BackpackState
→ BackpackResolver
→ RestBackpackSession working copy
→ RestRewardController + ShopController
→ RestWorkbenchUI intents
→ Fate commit checklist
→ final BackpackResolution.modifiers
→ RunBuildState.set_committed_backpack_modifiers(...)
→ existing player/school/combat consumers
```

- [ ] **Step 1: RED accelerated loop:** school → elite signal → elite kill/token → boss → result → forced boss reward → REST → chest/shop/buffer/placement → optional combo → checklist → Fate → preview/next combat; assert no immediate modifier activation before commit.
- [ ] **Step 2: RED blockers:** each of chest>0, buffer>0, pending bag, invalid/disconnected placement, pending combo keeps phase in REST and exposes the matching recovery code.
- [ ] **Step 3: RED four-school regression:** committed spatial snapshot + school emblem/Fate mappings still affect only the intended existing modifier channels.
- [ ] **Step 4: Run RED.**
- [ ] **Step 5: Wire controllers/signals and remove every runtime modifier consumer of old count-based item authority.** Do not leave dual authority.
- [ ] **Step 6: Run GREEN + all existing MVP-0~3 integration tests.**
- [ ] **Step 7: Commit.**

```bash
git add scripts/core/main_controller.gd scripts/core/stage_flow_controller.gd scripts/ui/rest_flow_ui.gd scenes/ui/rest_flow_ui.tscn scenes/main/main_scene.tscn tests/integration/test_mvp4_stage_rest_loop.gd tests/integration/test_mvp4_four_school_builds.gd
git commit -m "feat: integrate MVP-4 backpack loop"
```

---

### Task 12: Full verification, adversarial review, human QA and traceability closure

**Traceability:** `T12 / REQ-MVP4-11 / V12`

**Files:** Update `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md` and `docs/ACTIVE_CONTEXT.md` only after evidence exists. Production files change only through a new RED→GREEN cycle for a validated finding.

- [ ] **Step 1: Fresh import.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --import
```

- [ ] **Step 2: Main-scene smoke matching CI.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --scene res://scenes/main/main_scene.tscn --quit-after 120 2>&1 | tee smoke-output.log
! grep -E "SCRIPT ERROR:|ERROR:" smoke-output.log
```

- [ ] **Step 3: Full GUT matching CI.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit 2>&1 | tee gut-output.log
! grep -E "SCRIPT ERROR:|ERROR:" gut-output.log
grep -q "test_script_contracts.gd" gut-output.log
```

- [ ] **Step 4: Adversarially attack the exact diff** for duplicate authorities, partial transactions, disconnected bag escapes, diagonal adjacency leakage, hidden whole-layout mode, drag-only required action, stale modifier activation, duplicate chest/boss reward, Undo crossing irreversible boundaries, and MVP-3 regressions.
- [ ] **Step 5: Every valid implementation finding gets a failing regression test before its production fix.** Re-run focused and full suites.
- [ ] **Step 6: Open implementation PR only after local verification.** Exact-head merge gate: mergeable, required CI success, unresolved threads 0, no P0/P1 or user-decision finding.
- [ ] **Step 7: Human Windows QA:** mouse path; keyboard normal↔whole-layout mode; gamepad same mode; narrow/wide windows; invalid-placement recovery; combination cancel; chest-block recovery; successful Fate commit.
- [ ] **Step 8: Human Android QA if an authorized device/export route exists:** tap-select→tap-place, whole-layout direction buttons, bottom-sheet/short-tab access, touch hit areas, no clipped commit/recovery. If route is unavailable, record `BLOCKED_UNVERIFIED`; never claim Android PASS.
- [ ] **Step 9: Recalculate traceability from merged implementation + executed evidence.** `CONVERGED` requires every requirement mapped to actual merged implementation and required executed evidence; plans/test definitions alone never qualify.
- [ ] **Step 10: Post-merge canonical freshness pass** on `main`, open PRs, post-merge CI and active docs. Search specifically for stale current guidance such as “rotation excluded”, old `5/10/15 midboss`, and `owned_items` as modifier authority.

---

## Execution Order and Review Checkpoints

```text
T01 data contracts
→ T02 state
→ T03 resolver
→ T04 REST session
→ T05 combination
→ T06 committed modifiers
→ T07 acquisition
→ T08 elite/stage flow
→ T09 workbench UI
→ T10 input/responsive
→ T11 full composition
→ T12 validation/closure
```

After every task: focused RED observed → focused GREEN → relevant prior-task regression → exact diff scope review → commit only explicit paths. Run an independent review gate after T03, T07, T10, and T11.

## Self-Review

- Spec coverage: AC-01..AC-15 map through the L3 packet to T01–T12.
- Placeholder scan: **no executable placeholder tokens remain**. Task 8 names the exact existing owners `scripts/spawning/wave_spawner.gd`, `scripts/core/main_controller.gd`, and the new `StageElite` files.
- Type consistency: `BackpackState → BackpackResolver → RestBackpackSession → committed RunModifierSet` is stable across tasks.
- Authority: UI renders snapshots/emits intent; resolver/session own spatial rules; RunBuildState owns committed combat modifiers + Fate.
- Transaction safety: reward/combination/Fate paths validate before mutation and include duplicate guards.
- Input ambiguity: explicit mutually exclusive whole-layout mode is tested at session and UI levels.
- Rollback: MVP-3 integrated runtime remains the safe baseline until MVP-4 merge.
- Human evidence: Windows/Android usability is never inferred from GUT.
- Phase boundary: written spec is approved, L3/plan may be integrated, but production remains blocked until explicit `기획 완료`.

**Plan status:** `IMPLEMENTATION_READY_AFTER_EXPLICIT_기획_완료 / PRODUCTION_NOT_STARTED`.