# MVP-4 Backpack / Combination Basics Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved MVP-4 spatial backpack / combination loop so boss/shop/chest rewards enter a six-slot REST work buffer, the player builds a valid 6x6 spatial loadout with rotation/adjacency/special-bag effects, explicit combinations commit atomically, and the Persistent Workbench can be completed by mouse, keyboard/gamepad, and touch before Fate commits the next-combat build.

**Architecture:** Preserve `MainController` as composition root and MVP-3 as the rollback baseline. Introduce a UI-independent spatial domain (`BackpackState`, `BackpackResolver`, `RestBackpackSession`, `CombinationResolver`) and keep `RunBuildState` responsible only for GOLD/Fate plus the final committed backpack modifier snapshot. `RestFlowUI` remains the outer RESULT/FATE/PREVIEW/COMPLETE surface; a focused `RestWorkbenchUI` + `BackpackBoardUI` own display/input intent only. Acquisition controllers validate buffer capacity and money before one atomic mutation; UI never recomputes legality or modifiers.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1, `Resource`/`RefCounted` domain data, `Node` controllers, `CanvasLayer`/`Control` UI, GitHub Actions Ubuntu verification.

## Global Constraints

- Planning baseline: `main@655ec26a5ac9946c0ec08f81f389ddfe66e72b65` after PR #7.
- Local project root when BUILD is authorized: `C:/Users/user/Documents/GitHub/Ninza/ninja-survival-godot`.
- **Do not start production implementation until the user explicitly says `기획 완료`.** This plan is implementation-ready documentation only.
- Canonical design: `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`.
- Traceability packet: `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md`.
- Every production behavior change follows strict TDD: write focused RED → run and observe expected failure → minimal GREEN → focused regression → full relevant regression → commit.
- Board is exactly `6x6`; starting active area is exactly `4x3`; REST work buffer is exactly `6` item slots.
- Bags and items rotate only in 90-degree quarter turns. Regular MVP-4 items are rectangular; selected bags may be L/T shaped.
- Item adjacency is orthogonal edge sharing only. A same-pair same-synergy relation applies once regardless of number of touching edges.
- A special bag applies once to an item when at least one item cell overlaps that bag; distinct special-bag instances may each apply once.
- Work-buffer items contribute zero combat, adjacency, special-bag, and combination effects.
- Fate entry is blocked until boss reward is handled, chest count is zero, work buffer is empty, no pending bag/combo exists, all placements are legal, and active bag cells are connected.
- Combination is explicit and atomic: sources remain until a legal result placement is committed; completed combination is not placement Undo/Redo history.
- Whole-layout translation uses an explicit visible mutually exclusive `전체 이동 모드`; arrows/D-pad navigate focus/cells in normal mode and translate the whole layout only in that mode.
- Touch must have a complete tap-select → tap-place path; precision drag, hover, or long-press may not be required.
- Preserve MVP-0~3 combat, four-school identity, DDD, result telemetry, GOLD/Fate behavior unless this approved MVP-4 contract explicitly replaces a boundary.
- Existing `owned_items: Dictionary` is not the MVP-4 spatial source of truth. Do not preserve immediate item-to-combat modifier activation as a hidden second authority.
- Do not add a new save system, autoload, deep rarity, 2nd/3rd-tier combinations, arbitrary polyomino regular items, deep set/curse, MVP-5 final loop, or unrelated refactors.
- Do not modify `.github/workflows/gut.yml` unless an actual verification gap is proven separately. Current CI already imports, smoke-runs main scene, and runs the full GUT tree.
- Do not modify `project.godot` merely to add Workbench keys. Current project has no shared InputMap; use `Control` GUI events / `_unhandled_key_input` / explicit UI buttons unless an unavoidable cross-scene need is demonstrated and separately approved.
- Never stage local `addons/`, `.godot/`, unrelated plugin files, or use `git add .`, `git add -A`, or destructive clean commands.
- Google Sheet sync is not a BUILD dependency; its current write blocker remains external and must not be “fixed” by weakening GitHub canon.

## Initial MVP-4 content defaults

These are `RECOMMENDED_DEFAULT` authoring values for the first implementation/playtest. They are deliberately tunable and do not change the approved spatial rules.

### Item footprints

| id | display | size | primary role |
|---|---|---|---|
| `taijutsu_training` | 체술단련 | 1x1 | existing move-speed item |
| `protection_talisman` | 호신 부적 | 1x2 | existing HP item |
| `fortune_talisman` | 행운 부적 | 1x1 | existing GOLD item |
| `ninjutsu_training` | 인법단련 | 1x2 | existing school-damage item |
| `enlightenment` | 깨달음 | 1x1 | existing school-resource item |
| `regeneration_scroll` | 재생의 두루마리 | 1x2 | existing rest-heal item |
| `ultimate_treatise` | 오의 비전서 | 1x2 | existing ultimate-readiness item |
| `school_emblem` | 유파 증표 | 2x2 | existing selected-school item |
| `katana` | 일본도 | 1x3 | weapon/combo ingredient |
| `shuriken` | 수리검 | 1x1 | compact weapon |
| `bomb` | 폭탄 | 2x2 | explosive/combo ingredient |
| `water_style` | 수둔 | 1x2 | ninjutsu/combo ingredient |
| `lightning_style` | 뇌둔 | 1x2 | ninjutsu/combo ingredient |
| `fire_style` | 화둔 | 1x2 | ninjutsu/combo ingredient |
| `stealth_art` | 은신술 | 1x2 | utility/combo ingredient |
| `poison_needles` | 독침술 | 1x2 | status-oriented item |
| `barrier_art` | 결계술 | 2x2 | defense-oriented item |
| `greater_summoning_circle` | 대형 소환진 | 2x3 | large high-budget item |
| `forbidden_talisman` | 금기의 부적 | 1x3 | high-budget risk item |

Representative combinations stay exactly:

- `water_style + stealth_art -> water_mist`
- `katana + lightning_style -> thunder_blade`
- `bomb + fire_style -> explosive_bomb`

### Purchasable bags

| id | cells relative to origin | role |
|---|---|---|
| `small_pouch` | `(0,0),(1,0)` | cheap 2-cell expansion |
| `long_pouch` | `(0,0),(1,0),(2,0)` | 3-cell strip |
| `square_pouch` | `(0,0),(1,0),(0,1),(1,1)` | compact 2x2 |
| `tactical_t_pouch` | `(0,0),(1,0),(2,0),(1,1)` | representative T bag |
| `ninjutsu_l_pouch` | `(0,0),(0,1),(0,2),(1,2)` | representative L special bag; overlapping `ninjutsu` items receive the configured small auxiliary effect |

The basic starting ninja bag is a non-shop 4x3 bag instance. Place it initially at `Vector2i(1, 1)` on the 6x6 board so the first state has movement room in every direction; this is an implementation default, not a new product rule.

---

## File Structure

### New spatial/data domain

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

### New acquisition / presentation

- `scripts/core/rest_reward_controller.gd`
- `scripts/ui/backpack_board_ui.gd`
- `scripts/ui/rest_workbench_ui.gd`
- `scenes/ui/backpack_board_ui.tscn`
- `scenes/ui/rest_workbench_ui.tscn`

### Existing files modified by approved integration

- `scripts/data/item_definition.gd`
- `scripts/data/mvp3_catalog.gd` only where compatibility delegation is required; new MVP-4 content belongs in `mvp4_catalog.gd`
- `scripts/core/run_build_state.gd`
- `scripts/core/shop_controller.gd`
- `scripts/core/stage_flow_controller.gd`
- `scripts/core/main_controller.gd`
- `scripts/ui/rest_flow_ui.gd`
- `scenes/ui/rest_flow_ui.tscn`
- `scenes/main/main_scene.tscn`
- existing enemy/spawner files only for the minimum elite identity/timing hook proven necessary
- `tests/unit/test_script_contracts.gd`

### Focused tests

- `tests/unit/test_mvp4_catalog.gd`
- `tests/unit/test_backpack_state.gd`
- `tests/unit/test_backpack_resolver.gd`
- `tests/unit/test_rest_backpack_session.gd`
- `tests/unit/test_combination_resolver.gd`
- `tests/unit/test_rest_reward_controller.gd`
- existing `tests/unit/test_run_build_state.gd`
- existing `tests/unit/test_shop_controller.gd`
- existing `tests/unit/test_stage_flow_controller.gd`
- `tests/integration/test_mvp4_workbench_ui.gd`
- `tests/integration/test_mvp4_input_parity.gd`
- `tests/integration/test_mvp4_stage_rest_loop.gd`
- `tests/integration/test_mvp4_four_school_builds.gd`

---

### Task 1: Add spatial authoring and runtime data contracts

**Traceability:** `T01 / REQ-MVP4-01 / V01`

**Files:**
- Modify: `scripts/data/item_definition.gd`
- Create: `scripts/data/bag_definition.gd`
- Create: `scripts/data/item_instance.gd`
- Create: `scripts/data/bag_instance.gd`
- Create: `scripts/data/combination_definition.gd`
- Create: `scripts/data/mvp4_catalog.gd`
- Create: `tests/unit/test_mvp4_catalog.gd`
- Modify: `tests/unit/test_script_contracts.gd`

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
# item_instance.gd / bag_instance.gd
extends RefCounted
class_name ItemInstance # BagInstance in the sibling file
var instance_id: int
var definition_id: StringName
var origin: Vector2i
var rotation_quarters: int = 0
func copy_value():
    # returns independent instance with identical scalar fields
```

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

- [ ] **Step 1: Write RED data-contract tests.** Add explicit assertions that all 19 base item ids, five purchasable bag ids, the basic 4x3 bag, and three combination ids are unique and defined; rectangular item rotation swaps width/height; L/T bag rotation normalizes coordinates to non-negative origin; every source/result reference resolves.

```gdscript
func test_non_square_item_rotates_90_degrees() -> void:
    var item = MVP4Catalog.build_items()[&"katana"]
    assert_eq(item.footprint(0).size(), 3)
    assert_true(item.footprint(0).has(Vector2i(0, 2)))
    assert_true(item.footprint(1).has(Vector2i(2, 0)))

func test_combination_references_are_resolvable() -> void:
    var items := MVP4Catalog.build_items()
    for combo in MVP4Catalog.build_combinations().values():
        assert_true(items.has(combo.source_a))
        assert_true(items.has(combo.source_b))
        assert_true(items.has(combo.result_item))
```

- [ ] **Step 2: Run focused RED.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_mvp4_catalog.gd -gexit
```

Expected: missing MVP-4 classes/catalog or missing new fields; failure must not be a parse typo.

- [ ] **Step 3: Implement the minimum contracts and catalog.** Preserve existing MVP-3 effect fields and item ids; add spatial fields without changing current MVP-3 behavior before a spatial commit exists.

- [ ] **Step 4: Run focused GREEN and script contracts.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_mvp4_catalog.gd -gexit
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_script_contracts.gd -gexit
```

- [ ] **Step 5: Commit only Task 1 paths.**

```bash
git add scripts/data/item_definition.gd scripts/data/bag_definition.gd scripts/data/item_instance.gd scripts/data/bag_instance.gd scripts/data/combination_definition.gd scripts/data/mvp4_catalog.gd tests/unit/test_mvp4_catalog.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-4 spatial data contracts"
```

---

### Task 2: Make `BackpackState` the spatial source of truth

**Traceability:** `T02 / REQ-MVP4-02 / V02`

**Files:**
- Create: `scripts/backpack/backpack_state.gd`
- Create: `tests/unit/test_backpack_state.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**

```gdscript
extends RefCounted
class_name BackpackState

const BOARD_SIZE := Vector2i(6, 6)
var bags: Dictionary = {}      # int -> BagInstance
var items: Dictionary = {}     # int -> ItemInstance
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

- [ ] **Step 1: Write RED state tests** for starting basic bag at `(1,1)`, monotonically unique instance ids, independent deep copies, exact item/bag lookup/removal, and no definition/effect calculation in this class.

```gdscript
func test_copy_is_independent() -> void:
    var original := BackpackState.new().create_starting_state()
    var copy := original.copy_value()
    copy.get_bag(1).origin += Vector2i.RIGHT
    assert_ne(copy.get_bag(1).origin, original.get_bag(1).origin)
```

- [ ] **Step 2: Run RED** with `test_backpack_state.gd`; confirm the class is missing.
- [ ] **Step 3: Implement state storage/copy only.** Do not put collision/connectivity rules here.
- [ ] **Step 4: Run GREEN + `test_mvp4_catalog.gd`.**
- [ ] **Step 5: Commit.**

```bash
git add scripts/backpack/backpack_state.gd tests/unit/test_backpack_state.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add backpack spatial state"
```

---

### Task 3: Implement deterministic geometry, connectivity, adjacency and modifier resolution

**Traceability:** `T03 / REQ-MVP4-02 / V03`

**Files:**
- Create: `scripts/backpack/backpack_resolution.gd`
- Create: `scripts/backpack/backpack_resolver.gd`
- Create: `tests/unit/test_backpack_resolver.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**

```gdscript
extends RefCounted
class_name BackpackResolution
var valid: bool = true
var failure_code: StringName = &""
var failure_cells: Array[Vector2i] = []
var active_cells: Dictionary = {}          # Vector2i -> bag instance id
var item_cells: Dictionary = {}            # Vector2i -> item instance id
var adjacency_pairs: Array[Vector2i] = []  # canonicalized instance-id pairs
var special_bag_hits: Dictionary = {}      # item id -> Array[bag id]
var modifiers: RunModifierSet
```

```gdscript
extends RefCounted
class_name BackpackResolver
func resolve(state: BackpackState, item_defs: Dictionary, bag_defs: Dictionary, selected_school_id: StringName) -> BackpackResolution
func can_place_item(state: BackpackState, candidate: ItemInstance, item_defs: Dictionary, bag_defs: Dictionary) -> BackpackResolution
func can_place_bag(state: BackpackState, candidate: BagInstance, item_defs: Dictionary, bag_defs: Dictionary) -> BackpackResolution
func translated_state(state: BackpackState, delta: Vector2i, item_defs: Dictionary, bag_defs: Dictionary) -> Dictionary
```

`translated_state()` returns `{ "valid": bool, "state": BackpackState|null, "resolution": BackpackResolution }`; never mutate the input state.

- [ ] **Step 1: Write RED tests for hard geometry.** Cover out-of-board, inactive item cells, bag overlap, item overlap, disconnected bag islands, legal connected bag extension, item 90° rotation, whole-layout all-or-nothing translation.
- [ ] **Step 2: Write RED relation tests.** Cover orthogonal adjacency once per pair, diagonal exclusion, one-cell special-bag activation, one item hit by two distinct special bags, and deterministic identical output from copied state.

```gdscript
func test_diagonal_items_are_not_adjacent() -> void:
    var state := _state_with_items(Vector2i(1,1), Vector2i(2,2))
    var result := resolver.resolve(state, items, bags, &"bongma")
    assert_eq(result.adjacency_pairs.size(), 0)

func test_disconnected_bag_is_invalid() -> void:
    var candidate := BagInstance.new()
    candidate.definition_id = &"small_pouch"
    candidate.origin = Vector2i(5, 5)
    var result := resolver.can_place_bag(state, candidate, items, bags)
    assert_false(result.valid)
    assert_eq(result.failure_code, &"bag_disconnect")
```

- [ ] **Step 3: Run RED** and confirm failures are rule absence, not fixtures.
- [ ] **Step 4: Implement minimum deterministic resolver** using normalized footprint cells, set/dictionary occupancy, BFS/DFS for 4-neighbor active-cell connectivity, canonical pair ids for adjacency, then derive modifiers from only valid placed items plus special-bag auxiliary effects.
- [ ] **Step 5: Run GREEN plus existing `test_run_build_state.gd` to expose unintended modifier regressions early.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/backpack/backpack_resolution.gd scripts/backpack/backpack_resolver.gd tests/unit/test_backpack_resolver.gd tests/unit/test_script_contracts.gd
git commit -m "feat: resolve backpack geometry and relationships"
```

---

### Task 4: Add REST edit session, work buffer, preview and Undo/Redo

**Traceability:** `T04 / REQ-MVP4-03 / V04`

**Files:**
- Create: `scripts/backpack/build_preview_snapshot.gd`
- Create: `scripts/backpack/rest_backpack_session.gd`
- Create: `tests/unit/test_rest_backpack_session.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**

```gdscript
extends RefCounted
class_name BuildPreviewSnapshot
var resolution: BackpackResolution
var modifier_delta: RunModifierSet
var commit_failures: Array[StringName] = []
```

```gdscript
extends RefCounted
class_name RestBackpackSession
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

- [ ] **Step 1: Write RED buffer tests:** capacity six; placed→buffer disables it from resolver output; buffer→board requires legal placement; buffer item cannot be combination-active.
- [ ] **Step 2: Write RED edit-history tests:** move/rotate/place/buffer transitions enter Undo/Redo; purchase/sale/chest/combine/Fate are absent from edit history; redo clears after a new edit.
- [ ] **Step 3: Write RED input-mode tests:** normal mode rejects `translate_whole_layout`; enter mode allows one-cell atomic translation; exit restores normal; failed translation does not modify state or exit the visible mode.
- [ ] **Step 4: Run RED**, implement minimum session snapshots as deep `BackpackState` copies, and run GREEN.
- [ ] **Step 5: Regression-run Tasks 2–3 tests.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/backpack/build_preview_snapshot.gd scripts/backpack/rest_backpack_session.gd tests/unit/test_rest_backpack_session.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add REST backpack edit session"
```

---

### Task 5: Implement explicit atomic combinations and progressive hint state

**Traceability:** `T05 / REQ-MVP4-04 / V05`

**Files:**
- Create: `scripts/backpack/combination_resolver.gd`
- Create: `tests/unit/test_combination_resolver.gd`
- Modify: `scripts/backpack/rest_backpack_session.gd`
- Modify: `scripts/data/mvp4_catalog.gd`

**Interfaces:**

```gdscript
extends RefCounted
class_name CombinationResolver

enum HintStage { UNDISCOVERED, INGREDIENT_OWNED, READY, DISCOVERED }

func eligible_pairs(state: BackpackState, resolution: BackpackResolution, combos: Dictionary) -> Array[Dictionary]
func hint_stage(combo_id: StringName, state: BackpackState, resolution: BackpackResolution, discovered: Dictionary, combos: Dictionary) -> HintStage
func begin_result_preview(session: RestBackpackSession, combo_id: StringName, source_a_instance: int, source_b_instance: int) -> bool
func commit_result(session: RestBackpackSession, origin: Vector2i, rotation_quarters: int = 0) -> bool
func cancel_result(session: RestBackpackSession) -> void
```

- [ ] **Step 1: Write RED tests:** diagonal ingredients fail; buffer ingredient fails; READY requires valid orthogonal adjacency; invalid result placement preserves both sources; cancel preserves both; legal result placement consumes exactly two once and creates exactly one result; repeated commit is ignored; first success marks recipe discovered.
- [ ] **Step 2: Run RED.**
- [ ] **Step 3: Implement pending-combination transaction inside the session, but keep pair discovery/rule checks in `CombinationResolver`.** No source removal before legal result commit.
- [ ] **Step 4: Run GREEN and `test_rest_backpack_session.gd`.**
- [ ] **Step 5: Commit.**

```bash
git add scripts/backpack/combination_resolver.gd scripts/backpack/rest_backpack_session.gd scripts/data/mvp4_catalog.gd tests/unit/test_combination_resolver.gd
git commit -m "feat: add atomic backpack combinations"
```

---

### Task 6: Migrate combat modifiers from owned-count authority to committed spatial snapshot

**Traceability:** `T06 / REQ-MVP4-05 / V06`

**Files:**
- Modify: `scripts/core/run_build_state.gd`
- Modify: `tests/unit/test_run_build_state.gd`
- Modify: `scripts/data/run_modifier_set.gd` only if a copy/add helper is needed

**Interfaces:**

```gdscript
# run_build_state.gd target API
func set_committed_backpack_modifiers(modifiers: RunModifierSet) -> void
func get_committed_backpack_modifiers() -> RunModifierSet
func get_modifiers() -> RunModifierSet
```

`get_modifiers()` returns `committed_backpack_modifiers + selected Fate modifiers`, then applies existing caps/mappings. `owned_items` may remain temporarily only as migration compatibility for old tests/code until Task 11 removes all runtime consumers; it must not contribute to final combat modifiers after this task.

- [ ] **Step 1: Write RED tests:** setting a committed spatial snapshot changes returned modifiers; changing an uncommitted preview does not; buffer-only items cannot change the committed snapshot; Fate still combines with the spatial snapshot; selling/removing in REST changes only preview until commit.
- [ ] **Step 2: Run RED.**
- [ ] **Step 3: Implement `_committed_backpack_modifiers` and a single additive snapshot-combine path.** Do not repeatedly mutate already-modified values.
- [ ] **Step 4: Run GREEN and all existing school modifier tests (`test_mvp3_four_school_modifiers.gd` plus four school unit suites).**
- [ ] **Step 5: Commit.**

```bash
git add scripts/core/run_build_state.gd scripts/data/run_modifier_set.gd tests/unit/test_run_build_state.gd
git commit -m "refactor: commit spatial backpack modifiers"
```

---

### Task 7: Add atomic boss/shop/chest acquisition into the REST session

**Traceability:** `T07 / REQ-MVP4-06 / V07`

**Files:**
- Create: `scripts/core/rest_reward_controller.gd`
- Create: `tests/unit/test_rest_reward_controller.gd`
- Modify: `scripts/core/shop_controller.gd`
- Modify: `tests/unit/test_shop_controller.gd`
- Modify: `scripts/data/mvp4_catalog.gd`

**Interfaces:**

```gdscript
extends Node
class_name RestRewardController

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

`ShopController` remains offer/reroll logic; it no longer calls `RunBuildState.buy_item()` to create immediate combat ownership. `RestRewardController` performs the atomic cross-boundary checks and places item instances into session buffer / a bag into `pending_bag`.

- [ ] **Step 1: RED boss reward:** exactly 3 distinct options; at least one candidate tagged for selected school; choice requires one free buffer slot; invalid/repeated choice does not duplicate reward.
- [ ] **Step 2: RED chest:** one token opens exactly two seeded item instances only when two buffer slots are free; failed open preserves token and buffer.
- [ ] **Step 3: RED shop:** three distinct item offers + one bag offer; item purchase checks GOLD and buffer before spend; bag purchase checks GOLD and one-bag-per-rest cap before spend; reroll stays `5→10→15`; purchase does not alter committed combat modifier snapshot.
- [ ] **Step 4: Run RED, implement minimum transaction ordering, run GREEN.**
- [ ] **Step 5: Regression-run existing shop/GOLD tests.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/core/rest_reward_controller.gd scripts/core/shop_controller.gd scripts/data/mvp4_catalog.gd tests/unit/test_rest_reward_controller.gd tests/unit/test_shop_controller.gd
git commit -m "feat: route REST rewards into workbench"
```

---

### Task 8: Upgrade stage flow to elite → boss → result → boss reward → workbench

**Traceability:** `T08 / REQ-MVP4-07 / V08`

**Files:**
- Modify: `scripts/core/stage_flow_controller.gd`
- Modify: `tests/unit/test_stage_flow_controller.gd`
- Modify the existing enemy/spawner integration file(s) identified by current `MainController` wiring only after the RED test proves the exact hook; do not add a second wave system.

**Target state machine:**

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
```

Add `@export var elite_time_seconds: float = 180.0` or equivalent per-segment elapsed threshold while preserving production segment duration `300.0`. Tests may inject smaller values.

- [ ] **Step 1: RED timing tests:** elite signal fires once when elapsed time crosses the injected elite threshold; does not pause COMBAT clock; boss signal fires once at segment end; missing elite kill does not fabricate chest reward.
- [ ] **Step 2: RED phase tests:** `BOSS -> RESULT -> BOSS_REWARD -> REST -> FATE -> PREVIEW/COMPLETE`; invalid phase transitions return false; REST cannot skip forced boss reward.
- [ ] **Step 3: Run RED.**
- [ ] **Step 4: Implement the minimum state machine and one-shot elite flag.** Elite identity/reward callback is wired through the existing enemy-death path so DDD/kill ownership remains single-source.
- [ ] **Step 5: Run GREEN and existing accelerated MVP-3 stage-loop tests; update only assertions intentionally superseded by the new states.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/core/stage_flow_controller.gd tests/unit/test_stage_flow_controller.gd <only-the-proven-existing-spawner-or-enemy-files>
git commit -m "feat: add MVP-4 elite and REST phases"
```

The angle-bracket token above is an execution instruction to substitute the exact RED-proven existing file list before running `git add`; it must never be copied verbatim into the shell command.

---

### Task 9: Build the Persistent Workbench and board presentation without domain ownership

**Traceability:** `T09 / REQ-MVP4-08 / V09`

**Files:**
- Create: `scripts/ui/backpack_board_ui.gd`
- Create: `scripts/ui/rest_workbench_ui.gd`
- Create: `scenes/ui/backpack_board_ui.tscn`
- Create: `scenes/ui/rest_workbench_ui.tscn`
- Create: `tests/integration/test_mvp4_workbench_ui.gd`
- Modify: `scripts/ui/rest_flow_ui.gd`
- Modify: `scenes/ui/rest_flow_ui.tscn`

**Interfaces:**

```gdscript
# backpack_board_ui.gd
extends Control
class_name BackpackBoardUI
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
# rest_workbench_ui.gd
extends Control
class_name RestWorkbenchUI
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

The render model contains only serialized display state from session/resolver/reward controllers. UI scripts must not call geometry/modifier rule helpers to decide validity.

- [ ] **Step 1: RED scene-contract test:** instantiate Workbench at representative desktop size; verify central board exists with 36 focusable cell controls; GOLD/chest/buffer/commit summary are simultaneously visible; Result/Fate/Preview outer views still exist.
- [ ] **Step 2: RED feedback test:** render one legal and one invalid preview model and assert outline/icon/text nodes reflect the provided state; render adjacency/special-bag/combo flags and assert they are visible without deriving them from coordinates.
- [ ] **Step 3: Run RED.**
- [ ] **Step 4: Build Control/Container scenes with placeholder-safe text/shapes only.** Keep polish P3 effects out.
- [ ] **Step 5: Run GREEN plus existing `test_mvp3_rest_flow_ui.gd` after updating only the superseded SHOP-view expectation.**
- [ ] **Step 6: Commit.**

```bash
git add scripts/ui/backpack_board_ui.gd scripts/ui/rest_workbench_ui.gd scenes/ui/backpack_board_ui.tscn scenes/ui/rest_workbench_ui.tscn scripts/ui/rest_flow_ui.gd scenes/ui/rest_flow_ui.tscn tests/integration/test_mvp4_workbench_ui.gd
git commit -m "feat: add persistent REST workbench UI"
```

---

### Task 10: Complete keyboard/gamepad/touch parity and responsive adapters

**Traceability:** `T10 / REQ-MVP4-09 / V10`

**Files:**
- Modify: `scripts/ui/backpack_board_ui.gd`
- Modify: `scripts/ui/rest_workbench_ui.gd`
- Modify: `scenes/ui/backpack_board_ui.tscn`
- Modify: `scenes/ui/rest_workbench_ui.tscn`
- Create: `tests/integration/test_mvp4_input_parity.gd`

**Required behavior:**

- normal arrow/D-pad navigation changes focused/selected cell and never moves canonical layout;
- visible `전체 이동` action switches to `WHOLE_LAYOUT_MOVE`, then arrows/D-pad emit only layout deltas;
- mode exit/cancel returns to normal focus semantics and a modal/bottom-sheet cannot leave a hidden move mode active;
- touch has tap-select → tap-place and visible directional buttons for whole-layout mode;
- rotate/Undo/Redo/combine/cancel are visible controls;
- interactive touch targets are at least approximately 48dp equivalent in the intended Android layout;
- board remains central while secondary Android content moves into a bottom-sheet/short-tab surface;
- color-only meaning is forbidden; use outline/icon/text fallbacks.

- [ ] **Step 1: Write RED input tests** that synthesize GUI/key actions against the instantiated board and assert the emitted intent signal changes by mode, with no double emission.

```gdscript
func test_directional_input_has_one_meaning_per_mode() -> void:
    board.focus_cell(Vector2i(2, 2))
    _send_right_key(board)
    assert_eq(layout_move_deltas.size(), 0)
    board._on_whole_layout_mode_pressed()
    _send_right_key(board)
    assert_eq(layout_move_deltas, [Vector2i.RIGHT])
```

- [ ] **Step 2: Write RED responsive tests** at e.g. `1280x720`, `1920x1080`, `800x1280` synthetic control sizes: board must remain inside viewport, no required action has zero/negative rect, and Android adapter keeps primary board plus reachable secondary controls.
- [ ] **Step 3: Run RED.**
- [ ] **Step 4: Implement explicit focus neighbors, mode indicator/border, touch buttons and responsive container switching.** Do not add project-wide InputMap actions.
- [ ] **Step 5: Run GREEN and Workbench tests.**
- [ ] **Step 6: Record human QA as still `HUMAN_NOT_RUN`—automated geometry does not prove usability.**
- [ ] **Step 7: Commit.**

```bash
git add scripts/ui/backpack_board_ui.gd scripts/ui/rest_workbench_ui.gd scenes/ui/backpack_board_ui.tscn scenes/ui/rest_workbench_ui.tscn tests/integration/test_mvp4_input_parity.gd
git commit -m "feat: add workbench input parity"
```

---

### Task 11: Wire the full MVP-4 REST loop through `MainController`

**Traceability:** `T11 / REQ-MVP4-10 / V11`

**Files:**
- Modify: `scripts/core/main_controller.gd`
- Modify: `scenes/main/main_scene.tscn`
- Modify: `scripts/ui/rest_flow_ui.gd`
- Modify: `scenes/ui/rest_flow_ui.tscn`
- Modify: `scripts/core/stage_flow_controller.gd` only if wiring exposes a missing narrow signal
- Create: `tests/integration/test_mvp4_stage_rest_loop.gd`
- Create: `tests/integration/test_mvp4_four_school_builds.gd`

**Composition contract:**

```text
MVP4Catalog
→ BackpackState(committed run spatial state)
→ BackpackResolver
→ RestBackpackSession(per REST working copy)
→ RestRewardController + ShopController
→ RestWorkbenchUI intents
→ Fate commit gate
→ resolver final snapshot
→ RunBuildState.set_committed_backpack_modifiers(...)
→ existing school/player runtime consumes RunBuildState.get_modifiers()
```

- [ ] **Step 1: RED accelerated end-to-end test:** select school → accelerated elite signal → simulate elite kill/token → accelerated boss → result → forced boss reward → REST → chest/shop/buffer/placement → optional combination → commit checklist → Fate → next preview/combat. Assert one reward per event and no immediate modifier activation before commit.
- [ ] **Step 2: RED blocker cases:** nonzero chest, nonempty buffer, pending bag, invalid/disconnected placement, pending combination each keep phase in REST and expose one matching recovery code.
- [ ] **Step 3: RED four-school regression:** a committed spatial snapshot plus each school emblem/Fate mapping still produces intended school-specific modifier channels without changing the four runtime identities.
- [ ] **Step 4: Run RED.**
- [ ] **Step 5: Wire controllers/signals in `MainController` and scene.** Remove runtime dependence on the old count-based `owned_items` path only after the new tests are green; do not leave both as active modifier authorities.
- [ ] **Step 6: Run GREEN, then all existing MVP-0~3 integration tests.**
- [ ] **Step 7: Commit.**

```bash
git add scripts/core/main_controller.gd scripts/core/stage_flow_controller.gd scripts/ui/rest_flow_ui.gd scenes/ui/rest_flow_ui.tscn scenes/main/main_scene.tscn tests/integration/test_mvp4_stage_rest_loop.gd tests/integration/test_mvp4_four_school_builds.gd
git commit -m "feat: integrate MVP-4 backpack loop"
```

---

### Task 12: Full verification, adversarial review, human QA handoff and traceability closure

**Traceability:** `T12 / REQ-MVP4-11 / V12`

**Files:**
- Modify after evidence exists: `docs/traceability/2026-08-11-mvp4-backpack-combination-traceability.md`
- Modify after evidence exists: `docs/ACTIVE_CONTEXT.md`
- Modify only if acceptance evidence changes design status: canonical spec/decision files first, then this packet
- No production code unless a concrete verification finding requires a TDD fix cycle.

- [ ] **Step 1: Run fresh import.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --import
```

Expected: exit 0, no script parse errors.

- [ ] **Step 2: Run main-scene smoke exactly like CI.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --scene res://scenes/main/main_scene.tscn --quit-after 120 2>&1 | tee smoke-output.log
! grep -E "SCRIPT ERROR:|ERROR:" smoke-output.log
```

- [ ] **Step 3: Run full GUT tree exactly like CI.**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit 2>&1 | tee gut-output.log
! grep -E "SCRIPT ERROR:|ERROR:" gut-output.log
grep -q "test_script_contracts.gd" gut-output.log
```

- [ ] **Step 4: Adversarial review the exact implementation diff** against AC-01..AC-15. Attack at minimum: duplicate spatial authorities, partial transactions, disconnected bag escapes, diagonal adjacency leakage, hidden whole-layout mode, drag-only required action, stale modifier activation, chest/boss duplication, Undo crossing irreversible boundaries, and MVP-3 regressions.

- [ ] **Step 5: For every valid finding, add a failing regression test before the production fix.** Re-run focused RED→GREEN and the full suite.

- [ ] **Step 6: Open implementation PR and wait only for required checks, not for a new product decision.** Under active continuous-work/approved-item merge authority, merge only when exact head is mergeable, required CI is success, unresolved threads are zero, and there is no P0/P1/user-decision finding.

- [ ] **Step 7: Human Windows QA matrix.** Run at least:
  1. mouse drag + click-select path;
  2. keyboard path including normal focus vs `전체 이동 모드`;
  3. gamepad path with the same mode transition;
  4. narrow and wide window sizes;
  5. one invalid placement recovery, one combination cancel, one chest-block recovery, and one successful Fate commit.

Record observed behavior, not “PASS” from assumption.

- [ ] **Step 8: Human Android QA when an authorized device/export route exists.** Verify tap-select→tap-place, whole-layout direction buttons, bottom-sheet/short-tab access, approximate 48dp hit areas, and no clipped commit/recovery action. If the route is unavailable, record `BLOCKED_UNVERIFIED`; do not fail unrelated Windows/domain work and do not claim Android PASS.

- [ ] **Step 9: Update traceability.** Set each V-id to the actual evidence state, map merged implementation paths, and set `coverage_status: CONVERGED` only if every requirement has merged code + executed required verification and there are no unmapped items. Human Android evidence may remain an explicit blocker if it is part of the required release gate.

- [ ] **Step 10: Post-merge re-query `main`, open PRs, exact post-merge CI and active docs.** Run a canonical freshness pass so old “rotation excluded” / old stage terminology / `owned_items`-as-authority language cannot reappear as current guidance.

---

## Execution order and checkpoints

Use the following sequence. Do not parallelize tasks that mutate the same domain authority.

```text
T01 data contracts
→ T02 state
→ T03 resolver
→ T04 REST session
→ T05 combination
→ T06 committed modifiers
→ T07 acquisition
→ T08 stage flow
→ T09 workbench UI
→ T10 input/responsive
→ T11 full integration
→ T12 validation/closure
```

After each task:

1. focused RED evidence must exist before production code;
2. focused GREEN must pass;
3. relevant prior-task regression must pass;
4. inspect exact diff for scope creep;
5. commit only the listed paths;
6. request/re-run an independent review gate before moving past a major boundary (`T03`, `T07`, `T10`, `T11`).

## Self-review of this plan

- Spec coverage: AC-01..AC-15 are all mapped in the L3 packet and to T01–T12.
- Placeholder scan: no implementation behavior is deferred with `TODO/TBD`; the only runtime file-name substitution is explicitly constrained to the exact existing spawner/enemy hook proven by RED in Task 8.
- Type consistency: `BackpackState` → `BackpackResolver` → `RestBackpackSession` → committed `RunModifierSet` is used consistently across tasks.
- Authority: UI renders snapshots/emits intent; spatial rules remain in resolver/session; combat modifiers remain in `RunBuildState` after commit.
- Transaction safety: boss/shop/chest/combine/Fate boundaries are fail-closed and duplicate guarded.
- Input ambiguity: whole-layout movement is explicitly mode-gated and mutually exclusive with normal directional navigation.
- Regression boundary: MVP-3 main is the rollback baseline; no new save/InputMap/CI architecture is assumed.
- Human evidence: Windows/Android usability is not inferred from automated tests.

**Plan status:** `IMPLEMENTATION_READY_AFTER_EXPLICIT_기획_완료 / PRODUCTION_NOT_STARTED`.