# MVP-1 Combat DDD Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add kill-combo feedback, stylish score, non-progression reward-orb absorption, and a simple capped timed wave rhythm on top of the verified MVP-0 combat loop.

**Architecture:** Add three focused gameplay units: `CombatDDDTracker` owns combo/style/reward counters, `RewardOrb` owns only homing/collection presentation, and `WaveSpawner` owns only timed capped enemy creation. `MainController` remains the composition root that wires deaths, tracker updates, reward spawning, wave-spawned enemies, HUD signals, and game-over freeze without owning combo or wave calculations.

**Tech Stack:** Godot 4.7.1 Standard, GDScript, GUT 9.7.1, GitHub Actions Ubuntu runner.

## Global Constraints

- Godot 4.7.1 + GDScript only.
- MVP-1 grants no combat power, XP, gold, permanent progression, or shop currency.
- Combo failure has no penalty; it only resets the current combo.
- Reward collection uses distance-based `Node2D` behavior, not a new collision/pickup layer.
- Initial combo window is exactly `2.5` seconds.
- Kill stylish score is `100 + 20 * (combo_count - 1)`.
- Reward collection adds exactly `25` stylish score.
- Combo title thresholds are exactly `3 -> 그림자 연쇄`, `6 -> 닌자 난무`, `10 -> 백귀 격파`.
- Title feedback clears exactly `1.0` second after display.
- Wave interval is `5.0` seconds, batch size `2`, active-enemy cap `8`, spawn distance `320.0` pixels.
- Main scene starts with the existing four enemies.
- Replace MVP-0 instant one-for-one replacement with timed waves; do not keep both systems active.
- Existing game-over freeze and Enter restart behavior must remain intact.
- Do not commit local Godot AI/Hera/GUT plugin activation or `addons/` contents.

---

### Task 1: Combat DDD tracker

**Files:**
- Create: `scripts/combat/combat_ddd_tracker.gd`
- Create: `tests/unit/test_combat_ddd_tracker.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- Produces class `CombatDDDTracker extends Node`.
- Produces `register_kill() -> void`.
- Produces `register_reward_collected() -> void`.
- Produces state properties `combo_count`, `max_combo`, `stylish_score`, `reward_count`, `combo_time_remaining`.
- Produces signals `combo_changed(current: int, maximum: int)`, `stylish_score_changed(score: int)`, `reward_count_changed(count: int)`, `title_triggered(title: String)`.

- [ ] **Step 1: Add RED contract and behavior tests**

Create `tests/unit/test_combat_ddd_tracker.gd` with deterministic calls to `register_kill()`, `register_reward_collected()`, and `_process(delta)`. Required assertions:

```gdscript
extends GutTest

const TrackerScript = preload("res://scripts/combat/combat_ddd_tracker.gd")

func test_first_kill_starts_combo_and_scores_base() -> void:
    var tracker = TrackerScript.new()
    add_child_autofree(tracker)
    tracker.register_kill()
    assert_eq(tracker.combo_count, 1)
    assert_eq(tracker.max_combo, 1)
    assert_eq(tracker.stylish_score, 100)
    assert_eq(tracker.combo_time_remaining, 2.5)

func test_kill_inside_window_increments_combo_and_step_bonus() -> void:
    var tracker = TrackerScript.new()
    add_child_autofree(tracker)
    tracker.register_kill()
    tracker._process(1.0)
    tracker.register_kill()
    assert_eq(tracker.combo_count, 2)
    assert_eq(tracker.stylish_score, 220)
    assert_eq(tracker.combo_time_remaining, 2.5)

func test_timeout_resets_current_combo_but_preserves_maximum() -> void:
    var tracker = TrackerScript.new()
    add_child_autofree(tracker)
    tracker.register_kill()
    tracker.register_kill()
    tracker._process(2.5)
    assert_eq(tracker.combo_count, 0)
    assert_eq(tracker.max_combo, 2)

func test_kill_after_timeout_restarts_at_one() -> void:
    var tracker = TrackerScript.new()
    add_child_autofree(tracker)
    tracker.register_kill()
    tracker._process(3.0)
    tracker.register_kill()
    assert_eq(tracker.combo_count, 1)
    assert_eq(tracker.max_combo, 1)
    assert_eq(tracker.stylish_score, 200)

func test_title_thresholds_emit_exactly_once_on_threshold_kill() -> void:
    var tracker = TrackerScript.new()
    add_child_autofree(tracker)
    var titles: Array[String] = []
    tracker.title_triggered.connect(func(title: String): titles.append(title))
    for _i in range(10):
        tracker.register_kill()
    assert_eq(titles, ["그림자 연쇄", "닌자 난무", "백귀 격파"])

func test_reward_collection_adds_counter_and_style_only() -> void:
    var tracker = TrackerScript.new()
    add_child_autofree(tracker)
    tracker.register_reward_collected()
    assert_eq(tracker.reward_count, 1)
    assert_eq(tracker.stylish_score, 25)
    assert_eq(tracker.combo_count, 0)
```

Extend `tests/unit/test_script_contracts.gd` so the new script is required and its methods/properties exist.

- [ ] **Step 2: Push RED and verify failure is missing tracker implementation**

Expected: Godot/GUT runs, existing MVP-0 tests remain green, and the new tracker tests fail because the production script/API is absent or incomplete. Parser/workflow failures do not count as valid RED.

- [ ] **Step 3: Implement the minimal tracker**

Create `scripts/combat/combat_ddd_tracker.gd` with this shape:

```gdscript
extends Node
class_name CombatDDDTracker

signal combo_changed(current: int, maximum: int)
signal stylish_score_changed(score: int)
signal reward_count_changed(count: int)
signal title_triggered(title: String)

const COMBO_TITLES := {
    3: "그림자 연쇄",
    6: "닌자 난무",
    10: "백귀 격파",
}

@export var combo_window: float = 2.5
@export var kill_style_base: int = 100
@export var combo_step_bonus: int = 20
@export var reward_style_bonus: int = 25

var combo_count: int = 0
var max_combo: int = 0
var stylish_score: int = 0
var reward_count: int = 0
var combo_time_remaining: float = 0.0

func _process(delta: float) -> void:
    if delta <= 0.0 or combo_count == 0:
        return
    combo_time_remaining = maxf(combo_time_remaining - delta, 0.0)
    if combo_time_remaining <= 0.0:
        combo_count = 0
        combo_changed.emit(combo_count, max_combo)

func register_kill() -> void:
    if combo_time_remaining <= 0.0:
        combo_count = 1
    else:
        combo_count += 1
    combo_time_remaining = combo_window
    max_combo = maxi(max_combo, combo_count)
    stylish_score += kill_style_base + combo_step_bonus * (combo_count - 1)
    combo_changed.emit(combo_count, max_combo)
    stylish_score_changed.emit(stylish_score)
    if COMBO_TITLES.has(combo_count):
        title_triggered.emit(COMBO_TITLES[combo_count])

func register_reward_collected() -> void:
    reward_count += 1
    stylish_score += reward_style_bonus
    reward_count_changed.emit(reward_count)
    stylish_score_changed.emit(stylish_score)
```

- [ ] **Step 4: Verify Task 1 GREEN**

Expected: tracker tests and prior MVP-0 tests pass.

- [ ] **Step 5: Commit**

```bash
git add scripts/combat/combat_ddd_tracker.gd tests/unit/test_combat_ddd_tracker.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add combat DDD tracker"
```

---

### Task 2: Reward orb absorption

**Files:**
- Create: `scripts/combat/reward_orb.gd`
- Create: `scenes/rewards/reward_orb.tscn`
- Create: `tests/unit/test_reward_orb.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- Produces class `RewardOrb extends Node2D`.
- Produces `configure(new_target: Node2D) -> void`.
- Produces signal `collected(orb: RewardOrb)`.
- Exposes `move_speed`, `collect_radius`, `lifetime`, and `target`.

- [ ] **Step 1: Add RED reward-orb tests**

Required assertions:

```gdscript
extends GutTest

const OrbScript = preload("res://scripts/combat/reward_orb.gd")

func test_configure_stores_target() -> void:
    var orb = OrbScript.new()
    var target = Node2D.new()
    add_child_autofree(orb)
    add_child_autofree(target)
    orb.configure(target)
    assert_eq(orb.target, target)

func test_orb_moves_toward_target() -> void:
    var orb = OrbScript.new()
    var target = Node2D.new()
    add_child_autofree(orb)
    add_child_autofree(target)
    orb.global_position = Vector2.ZERO
    target.global_position = Vector2(100, 0)
    orb.move_speed = 100.0
    orb.collect_radius = 1.0
    orb.configure(target)
    orb._physics_process(0.25)
    assert_gt(orb.global_position.x, 0.0)
    assert_lt(orb.global_position.x, 100.0)

func test_collection_emits_once_when_inside_radius() -> void:
    var orb = OrbScript.new()
    var target = Node2D.new()
    add_child_autofree(orb)
    add_child_autofree(target)
    orb.collect_radius = 18.0
    orb.global_position = Vector2.ZERO
    target.global_position = Vector2(10, 0)
    var count := 0
    orb.collected.connect(func(_orb): count += 1)
    orb.configure(target)
    orb._physics_process(0.016)
    orb._physics_process(0.016)
    assert_eq(count, 1)
    assert_true(orb.is_queued_for_deletion())

func test_invalid_target_cleans_up_without_collection() -> void:
    var orb = OrbScript.new()
    add_child_autofree(orb)
    var count := 0
    orb.collected.connect(func(_orb): count += 1)
    orb._physics_process(0.016)
    assert_eq(count, 0)
    assert_true(orb.is_queued_for_deletion())
```

Also test lifetime expiry using `_physics_process()` with a delta greater than lifetime.

- [ ] **Step 2: Verify RED**

Expected: reward-orb tests fail because the resource/API does not exist.

- [ ] **Step 3: Implement `RewardOrb` and placeholder scene**

Use a one-shot `_collected` guard, decrement lifetime each physics frame, validate target with `is_instance_valid`, use `global_position.move_toward(target.global_position, move_speed * delta)`, then compare distance against `collect_radius`. The scene is a `Node2D` with the script plus a small `Polygon2D` placeholder visual; no collision node is added.

- [ ] **Step 4: Verify Task 2 GREEN**

Expected: reward-orb tests plus all earlier tests pass.

- [ ] **Step 5: Commit**

```bash
git add scripts/combat/reward_orb.gd scenes/rewards/reward_orb.tscn tests/unit/test_reward_orb.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add reward orb absorption"
```

---

### Task 3: Timed capped wave spawner

**Files:**
- Create: `scripts/spawning/wave_spawner.gd`
- Create: `tests/unit/test_wave_spawner.gd`
- Modify: `tests/unit/test_script_contracts.gd`
- Modify: `tests/integration/test_enemy_pressure.gd`

**Interfaces:**
- Produces class `WaveSpawner extends Node`.
- Produces `configure(new_spawn_parent: Node, new_anchor: Node2D) -> void`.
- Produces `spawn_wave() -> int` returning the number actually spawned.
- Produces `set_spawning_enabled(value: bool) -> void`.
- Produces signal `enemy_spawned(enemy: Node)`.
- Exposes `enemy_scene`, `wave_interval=5.0`, `batch_size=2`, `max_active_enemies=8`, `spawn_distance=320.0`.

- [ ] **Step 1: Replace old instant-replacement pressure test with RED wave expectations**

Change `tests/integration/test_enemy_pressure.gd` so a killed enemy is not immediately replaced, then a wave spawn restores pressure in a batch. Add focused unit tests with a lightweight PackedScene built from `EnemyChaser` or the real enemy scene:

```gdscript
func test_spawn_wave_adds_two_below_cap() -> void:
    var spawner = _make_spawner()
    assert_eq(spawner.spawn_wave(), 2)
    assert_eq(_living_enemies().size(), 2)

func test_spawn_wave_only_fills_remaining_capacity() -> void:
    var spawner = _make_spawner()
    spawner.max_active_enemies = 3
    _add_enemy()
    _add_enemy()
    assert_eq(spawner.spawn_wave(), 1)
    assert_eq(_living_enemies().size(), 3)

func test_spawn_wave_does_nothing_at_cap() -> void:
    var spawner = _make_spawner()
    spawner.max_active_enemies = 2
    _add_enemy()
    _add_enemy()
    assert_eq(spawner.spawn_wave(), 0)

func test_disabled_spawner_does_not_spawn() -> void:
    var spawner = _make_spawner()
    spawner.set_spawning_enabled(false)
    assert_eq(spawner.spawn_wave(), 0)
```

Verify deterministic cardinal rotation by checking the first two spawned positions against anchor + `(320, 0)` and anchor + `(0, 320)`.

- [ ] **Step 2: Verify RED**

Expected: old one-for-one behavior and missing `WaveSpawner` cause only the new/changed wave tests to fail; existing unrelated tests remain green.

- [ ] **Step 3: Implement `WaveSpawner` minimally**

Use `SPAWN_DIRECTIONS = [RIGHT, DOWN, LEFT, UP]`, an internal `_time_remaining`, and `get_tree().get_nodes_in_group("enemies")` filtered for valid/non-queued nodes. `spawn_wave()` computes capacity, instantiates at most `min(batch_size, capacity)`, adds each enemy to `spawn_parent`, positions it relative to `anchor`, emits `enemy_spawned`, and returns the count. `_process(delta)` decrements the timer only while enabled and configured; reaching zero calls `spawn_wave()` and resets to `wave_interval`.

- [ ] **Step 4: Verify Task 3 GREEN**

Expected: wave unit tests and revised pressure integration test pass, and no test expects instant one-for-one replacement anymore.

- [ ] **Step 5: Commit**

```bash
git add scripts/spawning/wave_spawner.gd tests/unit/test_wave_spawner.gd tests/unit/test_script_contracts.gd tests/integration/test_enemy_pressure.gd
git commit -m "feat: add timed enemy wave spawning"
```

---

### Task 4: DDD HUD feedback

**Files:**
- Modify: `scripts/ui/hud.gd`
- Modify: `scenes/ui/hud.tscn`
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- Adds `set_combo(current: int, maximum: int) -> void`.
- Adds `set_stylish_score(score: int) -> void`.
- Adds `set_reward_count(count: int) -> void`.
- Adds `show_combo_title(title: String) -> void`.

- [ ] **Step 1: Add RED HUD contract/integration assertions**

Require nodes `ComboLabel`, `StyleLabel`, `RewardLabel`, `ComboTitleLabel`, and methods above. Assert:

```gdscript
hud.set_combo(4, 7)
assert_eq(combo_label.text, "COMBO x4  MAX 7")
hud.set_combo(0, 7)
assert_eq(combo_label.text, "")
hud.set_stylish_score(345)
assert_eq(style_label.text, "STYLE 345")
hud.set_reward_count(3)
assert_eq(reward_label.text, "ORBS 3")
hud.show_combo_title("그림자 연쇄")
assert_eq(title_label.text, "그림자 연쇄")
await get_tree().create_timer(1.1).timeout
assert_eq(title_label.text, "")
```

- [ ] **Step 2: Verify RED**

Expected: only new HUD contracts/nodes fail.

- [ ] **Step 3: Implement HUD text feedback**

Add the four labels under the existing score area. In `HUDController`, use a monotonically increasing `_title_generation` integer: each `show_combo_title()` increments it, captures the generation, awaits `get_tree().create_timer(1.0).timeout`, and clears only if the captured generation is still current. This prevents an older timeout from clearing a newer title.

- [ ] **Step 4: Verify Task 4 GREEN**

Expected: HUD tests and prior tests pass.

- [ ] **Step 5: Commit**

```bash
git add scripts/ui/hud.gd scenes/ui/hud.tscn tests/integration/test_main_scene.gd tests/unit/test_script_contracts.gd
git commit -m "feat: show combat DDD feedback in HUD"
```

---

### Task 5: Main-scene DDD integration

**Files:**
- Modify: `scripts/core/main_controller.gd`
- Modify: `scenes/main/main_scene.tscn`
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `tests/integration/test_enemy_pressure.gd`

**Interfaces consumed:**
- `CombatDDDTracker.register_kill()` / `register_reward_collected()` and its four signals.
- `RewardOrb.configure(player)` and `collected(orb)`.
- `WaveSpawner.configure(main, player)`, `enemy_spawned(enemy)`, and spawning enable state.

- [ ] **Step 1: Add RED integration assertions**

Require main nodes `CombatDDD` and `WaveSpawner`, and an exported `reward_orb_scene` on `MainController`. Test enemy death behavior in one frame-safe sequence:

```gdscript
var tracker = main.get_node("CombatDDD")
var enemy = _living_enemies(main)[0]
var death_position = enemy.global_position
var kills_before = main.get_node("GameState").kill_count
enemy.take_damage(enemy.max_health)
await get_tree().process_frame
assert_eq(main.get_node("GameState").kill_count, kills_before + 1)
assert_eq(tracker.combo_count, 1)
var orbs = get_tree().get_nodes_in_group("reward_orbs")
assert_eq(orbs.size(), 1)
assert_almost_eq(orbs[0].global_position.x, death_position.x, 0.1)
```

Then move the orb/player close enough or invoke its physics step and assert `reward_count == 1` and HUD `ORBS 1` / style increase. Assert a wave-spawned enemy has `target == player`. Assert after player death both `WaveSpawner` and any live orb have `PROCESS_MODE_DISABLED` while `MainController` remains able to handle `ui_accept` restart as before.

- [ ] **Step 2: Verify RED**

Expected: integration tests fail because main scene/controller still use the MVP-0 one-for-one replacement path and lack tracker/orb/wave bindings.

- [ ] **Step 3: Integrate the new systems and remove instant replacement**

In `MainController`:

- remove `_spawn_replacement_enemy()` and `_spawn_direction_index`,
- replace exported `enemy_scene`/`enemy_spawn_distance` with `@export var reward_orb_scene: PackedScene`,
- add `@onready var combat_ddd: CombatDDDTracker = $CombatDDD` and `@onready var wave_spawner: WaveSpawner = $WaveSpawner`,
- connect tracker signals to HUD setters/title display,
- configure `wave_spawner` with `self` and `player`, connect `enemy_spawned` to `_wire_enemy`,
- in `_on_enemy_died(enemy)`, capture `enemy.global_position` before deletion, register ordinary and DDD kill, then call `_spawn_reward_orb(position)`,
- `_spawn_reward_orb` instantiates `reward_orb_scene`, adds it to main, places it at death position, configures player, connects `collected` to `_on_reward_collected`,
- `_on_reward_collected(_orb)` calls `combat_ddd.register_reward_collected()`,
- keep `_stop_gameplay()` generic so `CombatDDD`, `WaveSpawner`, player, enemies and orbs all disable; preserve only `GameState` and `HUD` as before.

In `main_scene.tscn` add the tracker script resource, wave spawner script resource, reward orb PackedScene resource, `CombatDDD` node, `WaveSpawner` node with enemy scene assigned, and `reward_orb_scene` binding on `Main`.

- [ ] **Step 4: Verify Task 5 GREEN**

Expected: full GUT suite passes locally/CI; no one-for-one replacement remains.

- [ ] **Step 5: Commit**

```bash
git add scripts/core/main_controller.gd scenes/main/main_scene.tscn tests/integration/test_main_scene.gd tests/integration/test_enemy_pressure.gd
git commit -m "feat: integrate MVP-1 combat DDD loop"
```

---

### Task 6: Final regression, resource metadata, and PR verification

**Files:**
- Add generated `.gd.uid` sidecars for new scripts after Godot 4.7.1 import.
- Add any generated `.import` metadata only for source assets that Godot actually creates and that are outside `.godot/`.
- Do not add `addons/`, `.godot/`, or local plugin sections from `project.godot`.

**Interfaces:** No new gameplay API; this task validates the final candidate.

- [ ] **Step 1: Run full remote verification on the feature branch**

Required gates:

```text
Godot 4.7.1 headless import: PASS
main_scene.tscn smoke: PASS with no SCRIPT ERROR / ERROR
GUT full suite: PASS
```

- [ ] **Step 2: Run adversarial review against the approved design**

Attack at least these failure modes:

- combo timer resets incorrectly at exact boundary,
- title timeout clears a newer title,
- one orb can collect twice,
- invalid orb target grants reward,
- wave cap counts queued-for-deletion enemies incorrectly,
- old instant replacement remains active alongside waves,
- game over leaves spawner/orb processing,
- restart carries DDD counters across reload,
- reward modifies combat stats/economy by accident,
- local plugin configuration leaks into repository files.

Every accepted MUST_FIX/SHOULD_FIX receives a regression test before the fix.

- [ ] **Step 3: Generate/track Godot metadata from Windows import**

After remote GREEN, the user runs the standard serial Godot 4.7.1 import on the local branch. Stage only newly generated source-side `.gd.uid`/relevant `.import` metadata. Verify `project.godot` plugin diff and `addons/` remain unstaged.

- [ ] **Step 4: Final Windows manual acceptance**

Verify:

```text
1. repeated kills visibly increase COMBO
2. no kill for >2.5s clears current COMBO
3. combo 3/6/10 title text appears and clears
4. defeated enemy drops a visible orb that homes to player
5. ORBS and STYLE increase on collection without player power/stat change
6. enemies arrive in timed batches rather than instant one-for-one replacement
7. active enemies do not exceed 8 under normal wave behavior
8. HP/game-over behavior still works
9. Enter restart still works and DDD counters reset
```

- [ ] **Step 5: Final CI on the exact metadata-inclusive head**

Do not reuse an earlier run. Require import, smoke, and full GUT success on the exact final commit.

- [ ] **Step 6: Finish branch**

Use `superpowers:finishing-a-development-branch`. Under continuous-work mode, prepare the PR and recommended integration path automatically, but do not cross a genuinely user-only scope/risk decision.
