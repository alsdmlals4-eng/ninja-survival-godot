# MVP-2 Four Schools Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved MVP-2 four-school combat slice so one school is selected at run start and Bongma, Cheonsul, Guiin, and Heukyeong each produce a visibly distinct shallow combat loop while preserving MVP-0/MVP-1 behavior.

**Architecture:** Add a one-shot `SchoolSelectionUI`, a shared `SchoolRuntimeHost`, and four isolated school runtime nodes behind the exact `SchoolRuntimeBase` contract. `MainController` remains orchestration-only: it owns selection/start/game-over/death forwarding, while each runtime owns its attacks, resource state, badges, and ultimate. Existing `PlayerController`, `EnemyChaser`, `GameState`, `CombatDDDTracker`, reward orbs, and `WaveSpawner` remain the canonical contracts.

**Tech Stack:** Godot 4.7.1, GDScript, GUT 9.7.1, GitHub Actions, existing Node2D/CanvasLayer scenes.

## Global Constraints

- Baseline is merged MVP-1: `68` tests and `307` assertions on `main` commit `eabc438006fd04a95660d0f964036dc76bfc0434`.
- Do not add the full skill pool, skill drafting/level-up choices, backpack, fate, shop, stage clock, bosses, result screens, permanent progression, full status framework, final art/audio, or balance passes.
- Do not add school switching during a run.
- Do not change shared `project.godot` InputMap; use direct `1`-`4` key handling for selection and existing `ui_accept` for ultimate/restart.
- Keep `AutoAttackController` in `Player` for compatibility but disable it for all MVP-2 runs.
- School mechanics damage enemies only through `EnemyChaser.take_damage(int)` and never register kills directly.
- Float-derived positive damage uses `max(roundi(value), 1)`.
- Runtime state must prune freed enemies, clear runtime-owned badges on deactivate, and stop processing at game over.
- Keep local `project.godot` plugin configuration and `addons/` out of the feature branch.

---

## File Structure

**New shared school files**
- `scripts/schools/school_runtime_base.gd` — school runtime interface/signals and active lifecycle.
- `scripts/schools/school_runtime_host.gd` — one-shot school selection and forwarding.
- `scripts/ui/school_selection_ui.gd` — four-card mouse/keyboard selector.
- `scenes/ui/school_selection_ui.tscn` — selection overlay.
- `scripts/ui/enemy_effect_badge.gd` — text-only enemy state badge.
- `scenes/ui/enemy_effect_badge.tscn` — badge visual.

**New Bongma files**
- `scripts/schools/bongma_runtime.gd` — spirit, ward timing, familiar lifecycle, ultimate.
- `scripts/schools/bongma_familiar.gd` — following/nearest-target attack loop.
- `scenes/schools/bongma_familiar.tscn` — familiar placeholder visual.

**New Cheonsul files**
- `scripts/schools/cheonsul_runtime.gd` — flame-field casts, BURN/WET/SHOCK timers, reaction charge, ultimate.

**New Guiin files**
- `scripts/schools/guiin_runtime.gd` — melee pulse, low-HP modifier, gwihyeol gain/decay, ultimate.

**New Heukyeong files**
- `scripts/schools/heukyeong_runtime.gd` — seeded critical rolls, marks, burst, ultimate.

**Modified composition/UI files**
- `scripts/core/main_controller.gd` — selection-mode orchestration and school event forwarding.
- `scenes/main/main_scene.tscn` — host/runtimes/selector and scene bindings.
- `scripts/ui/hud.gd` — school/resource/ultimate/transient feedback methods.
- `scenes/ui/hud.tscn` — school HUD labels.
- `tests/unit/test_script_contracts.gd` — new resource/interface contracts.

**New tests**
- `tests/unit/test_school_runtime_host.gd`
- `tests/unit/test_school_selection_ui.gd`
- `tests/unit/test_bongma_runtime.gd`
- `tests/unit/test_bongma_familiar.gd`
- `tests/unit/test_cheonsul_runtime.gd`
- `tests/unit/test_guiin_runtime.gd`
- `tests/unit/test_heukyeong_runtime.gd`
- `tests/integration/test_mvp2_hud.gd`
- `tests/integration/test_mvp2_four_schools.gd`

---

### Task 1: Shared Runtime Host and Selection UI

**Files:**
- Create: `scripts/schools/school_runtime_base.gd`
- Create: `scripts/schools/school_runtime_host.gd`
- Create: `scripts/ui/school_selection_ui.gd`
- Create: `scenes/ui/school_selection_ui.tscn`
- Create: `tests/unit/test_school_runtime_host.gd`
- Create: `tests/unit/test_school_selection_ui.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- Produces `SchoolRuntimeBase.configure(player: PlayerController, world: Node2D) -> void`.
- Produces `SchoolRuntimeBase.activate() -> void`, `deactivate() -> void`, `on_enemy_died(enemy: Node) -> void`, `try_use_ultimate() -> bool`, `is_ultimate_ready() -> bool`.
- Produces signals `resource_changed(label: String, current: float, maximum: float)`, `ultimate_ready_changed(ready: bool)`, `school_feedback(text: String)`.
- Produces `SchoolRuntimeHost.configure(player: PlayerController, world: Node2D) -> void`.
- Produces `SchoolRuntimeHost.select_school(school_id: StringName) -> bool`, `forward_enemy_died(enemy: Node) -> void`, `try_use_ultimate() -> bool`, `deactivate() -> void`.
- Produces properties `selected_school_id: StringName`, `selected_school_name: String`, `active_runtime: SchoolRuntimeBase`.
- Produces signal `school_selected(school_id: StringName)` from `SchoolSelectionUI`.

- [ ] **Step 1: Write failing script-contract and host tests**

Add resource constants to `test_script_contracts.gd` and assert that the base/host/selector resources exist and expose the interfaces above. In `test_school_runtime_host.gd`, use four stub runtimes named `Bongma`, `Cheonsul`, `Guiin`, `Heukyeong` and verify one-shot activation:

```gdscript
func test_select_school_activates_exact_runtime_once() -> void:
    var host := SchoolRuntimeHost.new()
    var bongma := StubSchoolRuntime.new()
    bongma.name = "Bongma"
    var cheonsul := StubSchoolRuntime.new()
    cheonsul.name = "Cheonsul"
    var guiin := StubSchoolRuntime.new()
    guiin.name = "Guiin"
    var heukyeong := StubSchoolRuntime.new()
    heukyeong.name = "Heukyeong"
    host.add_child(bongma)
    host.add_child(cheonsul)
    host.add_child(guiin)
    host.add_child(heukyeong)

    assert_true(host.select_school(&"guiin"))
    assert_eq(host.selected_school_id, &"guiin")
    assert_eq(host.active_runtime, guiin)
    assert_eq(guiin.activate_calls, 1)
    assert_false(host.select_school(&"bongma"))
    assert_eq(bongma.activate_calls, 0)
    host.free()
```

Also assert invalid ids return `false`, forwarding reaches only the active runtime, and `deactivate()` stops the active runtime once.

- [ ] **Step 2: Write failing selector tests**

Instantiate `SchoolSelectionUI`, attach four Buttons named `BongmaButton`, `CheonsulButton`, `GuiinButton`, `HeukyeongButton`, call `_ready()`, then verify button press emits exactly one stable id and hides/locks the selector. Add deterministic direct key-event tests:

```gdscript
func test_key_three_selects_guiin_once() -> void:
    var ui := _make_selector()
    var ids: Array[StringName] = []
    ui.school_selected.connect(func(id: StringName): ids.append(id))
    var event := InputEventKey.new()
    event.pressed = true
    event.keycode = KEY_3

    ui._unhandled_input(event)
    ui._unhandled_input(event)

    assert_eq(ids, [&"guiin"])
    assert_false(ui.visible)
    ui.free()
```

- [ ] **Step 3: Run RED suite**

Run:

```bash
Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_school_runtime_host.gd -gexit
Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_school_selection_ui.gd -gexit
```

Expected: FAIL because the shared scripts/scenes do not exist.

- [ ] **Step 4: Implement `SchoolRuntimeBase` minimally**

Use this concrete skeleton:

```gdscript
extends Node
class_name SchoolRuntimeBase

signal resource_changed(label: String, current: float, maximum: float)
signal ultimate_ready_changed(ready: bool)
signal school_feedback(text: String)

var player: PlayerController
var world: Node2D
var active: bool = false

func configure(new_player: PlayerController, new_world: Node2D) -> void:
    player = new_player
    world = new_world

func activate() -> void:
    active = true
    process_mode = Node.PROCESS_MODE_INHERIT

func deactivate() -> void:
    active = false
    process_mode = Node.PROCESS_MODE_DISABLED

func on_enemy_died(_enemy: Node) -> void:
    pass

func try_use_ultimate() -> bool:
    return false

func is_ultimate_ready() -> bool:
    return false
```

- [ ] **Step 5: Implement host mapping and forwarding**

`SchoolRuntimeHost` must resolve exactly these child names and labels:

```gdscript
const SCHOOL_NAMES := {
    &"bongma": "봉마류",
    &"cheonsul": "천술류",
    &"guiin": "귀인류",
    &"heukyeong": "흑영류",
}

func _runtime_for(id: StringName) -> SchoolRuntimeBase:
    var child_name := {
        &"bongma": "Bongma",
        &"cheonsul": "Cheonsul",
        &"guiin": "Guiin",
        &"heukyeong": "Heukyeong",
    }.get(id, "")
    return get_node_or_null(NodePath(child_name)) as SchoolRuntimeBase
```

`select_school()` rejects if a school is already selected, configures/activates exactly one runtime, connects/forwards its three signals, and leaves all other runtime children disabled.

- [ ] **Step 6: Implement selector scene/script**

`school_selection_ui.tscn` is a full-screen `CanvasLayer` with centered `PanelContainer`, title `유파 선택`, four vertical Buttons carrying the exact approved card copy. `SchoolSelectionUI._choose(id)` must guard `_selected`, emit once, set `visible = false`, and ignore further input.

- [ ] **Step 7: Run focused tests and full regression**

Run both new unit files plus the complete test directory. Expected: all new tests PASS and baseline 68 tests remain green.

- [ ] **Step 8: Commit**

```bash
git add scripts/schools/school_runtime_base.gd scripts/schools/school_runtime_host.gd scripts/ui/school_selection_ui.gd scenes/ui/school_selection_ui.tscn tests/unit/test_school_runtime_host.gd tests/unit/test_school_selection_ui.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add MVP-2 school selection runtime"
```

---

### Task 2: Bongma Familiar, Spirit, Ward, and Ultimate

**Files:**
- Create: `scripts/schools/bongma_familiar.gd`
- Create: `scripts/schools/bongma_runtime.gd`
- Create: `scenes/schools/bongma_familiar.tscn`
- Create: `tests/unit/test_bongma_familiar.gd`
- Create: `tests/unit/test_bongma_runtime.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- `BongmaFamiliar.configure(player: PlayerController, attack_interval: float, damage: int) -> void`.
- `BongmaFamiliar.set_attack_interval(seconds: float) -> void`.
- `BongmaFamiliar.attack_once() -> Node` returns the damaged enemy or `null`.
- `BongmaRuntime extends SchoolRuntimeBase`; exposes `spirit: float`, `spirit_maximum: float = 120.0`, `ward_center: Vector2`, `ward_time_remaining: float`, `ultimate_time_remaining: float` for deterministic tests.
- Runtime owns spawned familiar nodes and ward placeholder geometry.

- [ ] **Step 1: Write failing familiar tests**

Verify nearest-target selection, follow threshold `72 px`, base interval `0.70`, damage `8`, invalid/dead targets ignored, and `attack_once()` damages exactly one nearest enemy.

- [ ] **Step 2: Write failing runtime tests**

Cover exact numbers:

```gdscript
func test_spirit_regens_and_kill_adds_ten() -> void:
    var runtime := _make_runtime()
    runtime.activate()
    runtime._process(2.0)
    assert_almost_eq(runtime.spirit, 10.0, 0.001)
    runtime.on_enemy_died(Node.new())
    assert_almost_eq(runtime.spirit, 20.0, 0.001)
    runtime.free()

func test_ward_is_stationary_four_second_window_every_eight_seconds() -> void:
    var runtime := _make_runtime()
    runtime.activate()
    runtime.player.global_position = Vector2(40, 20)
    runtime._process(8.0)
    assert_eq(runtime.ward_center, Vector2(40, 20))
    runtime.player.global_position = Vector2(200, 200)
    runtime._process(1.0)
    assert_eq(runtime.ward_center, Vector2(40, 20))
    assert_almost_eq(runtime.ward_time_remaining, 3.0, 0.001)
```

Also test ward interval changes familiar `0.70 -> 0.50` only while inside active ward, spirit clamps to 120, ultimate needs 100, consumes exactly 100, spawns temporary second familiar, uses `0.30`, lasts 6 seconds, and cannot be retriggered while active.

- [ ] **Step 3: Run RED tests**

Expected: scripts absent/resource contract failure.

- [ ] **Step 4: Implement `BongmaFamiliar`**

Use `get_tree().get_nodes_in_group("enemies")`, squared-distance nearest-target search, `move_toward()` toward the player only when distance exceeds 72, and call only `target.take_damage(damage)` when target exposes the method.

- [ ] **Step 5: Implement `BongmaRuntime`**

Define constants exactly:

```gdscript
const SPIRIT_MAX := 120.0
const SPIRIT_REGEN := 5.0
const KILL_SPIRIT := 10.0
const WARD_INTERVAL := 8.0
const WARD_DURATION := 4.0
const WARD_RADIUS := 140.0
const ULTIMATE_COST := 100.0
const ULTIMATE_DURATION := 6.0
```

Activation creates one familiar. `_process(delta)` handles positive delta only, spirit regen, ward interval/duration, ultimate duration, and familiar interval refresh. Deactivate frees familiars/ward visuals and calls `super.deactivate()`.

- [ ] **Step 6: Run focused and regression tests**

Expected: Bongma tests PASS; all earlier tests PASS.

- [ ] **Step 7: Commit**

```bash
git add scripts/schools/bongma_familiar.gd scripts/schools/bongma_runtime.gd scenes/schools/bongma_familiar.tscn tests/unit/test_bongma_familiar.gd tests/unit/test_bongma_runtime.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add Bongma summon combat loop"
```

---

### Task 3: Cheonsul Elemental State and Reaction Loop

**Files:**
- Create: `scripts/ui/enemy_effect_badge.gd`
- Create: `scenes/ui/enemy_effect_badge.tscn`
- Create: `scripts/schools/cheonsul_runtime.gd`
- Create: `tests/unit/test_cheonsul_runtime.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- `EnemyEffectBadge.set_text(text: String) -> void`.
- `CheonsulRuntime.apply_flame_cast(center: Vector2) -> int` returns number of enemies hit.
- `CheonsulRuntime.apply_token(enemy: Node2D, token: StringName) -> bool` returns whether WET+SHOCK reaction fired.
- Expose `reaction_count: int`, and state dictionaries keyed by enemy instance id internally.

- [ ] **Step 1: Write failing badge and Cheonsul tests**

Cover flame radius 90 / initial damage 6, BURN 3 seconds with 2 damage at 1-second ticks, WET/SHOCK 4 seconds, same-token refresh, `WET -> SHOCK` reaction, no reaction for `SHOCK -> WET`, non-recursive 6 chain damage within 120, counter clamp 3, ultimate success/failure semantics, state cleanup on death/deactivate.

Use direct method calls instead of waiting for 1.8-second cast timers whenever behavior can be tested synchronously.

- [ ] **Step 2: Run RED test**

Expected: missing runtime/badge resources.

- [ ] **Step 3: Implement badge**

`enemy_effect_badge.tscn` is a `Label` offset above an enemy. Script exposes only:

```gdscript
extends Label
class_name EnemyEffectBadge

func set_text(value: String) -> void:
    text = value
```

- [ ] **Step 4: Implement Cheonsul state records deterministically**

Store per-enemy dictionaries containing `burn_remaining`, `burn_tick_remaining`, `wet_remaining`, `shock_remaining`, and optional badge reference. `_process(delta)` prunes invalid enemies before ticking. Chain damage calls `take_damage(6)` directly and never calls `apply_token()`.

- [ ] **Step 5: Implement automatic cast and ultimate**

Automatic cast every `1.80` seconds targets nearest current enemy position and hits all valid enemies within `90`. Successful casts alternate secondary token `WET`, then `SHOCK`. `try_use_ultimate()` returns false without `reaction_count == 3` or without any valid status-bearing enemy; on success deals 18 to all status-bearing enemies, clears status/badges, resets charge, emits feedback.

- [ ] **Step 6: Run focused/full regression**

Expected: all Cheonsul and prior tests PASS.

- [ ] **Step 7: Commit**

```bash
git add scripts/ui/enemy_effect_badge.gd scenes/ui/enemy_effect_badge.tscn scripts/schools/cheonsul_runtime.gd tests/unit/test_cheonsul_runtime.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add Cheonsul reaction combat loop"
```

---

### Task 4: Guiin Melee, Gwihyeol, Berserker, and Ultimate

**Files:**
- Create: `scripts/schools/guiin_runtime.gd`
- Create: `tests/unit/test_guiin_runtime.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- `GuiinRuntime.perform_melee_pulse() -> int` returns number of enemies damaged.
- Expose `gwihyeol: float`, `time_since_gain: float`, `ultimate_time_remaining: float`.
- `current_pulse_interval() -> float`, `current_pulse_radius() -> float`, `current_pulse_damage() -> int` are deterministic calculation helpers.

- [ ] **Step 1: Write failing exact-number tests**

Cover baseline `0.90 s / 80 px / 10`, low HP `<= 50%` gives `110 px / 15`, each hit +4 gwihyeol, kill +12, no decay until 1.0 seconds since last gain, then 6/s decay, 75+ multiplier `1.20x`, ultimate at 100 consumes all, lasts 6 seconds, interval 0.45, radius min 130, final 1.25 multiplier and `roundi`.

Example integer assertion:

```gdscript
func test_low_hp_high_gwihyeol_ultimate_damage_rounds_once() -> void:
    var runtime := _make_runtime()
    runtime.player.health = 50
    runtime.player.max_health = 100
    runtime.gwihyeol = 100.0
    assert_true(runtime.try_use_ultimate())
    runtime.gwihyeol = 75.0
    assert_eq(runtime.current_pulse_damage(), 23) # roundi(15 * 1.20 * 1.25)
    runtime.free()
```

- [ ] **Step 2: Run RED test**

Expected: runtime missing.

- [ ] **Step 3: Implement calculation helpers first**

Use one ordering only: choose base from HP, multiply by 1.20 if current gwihyeol >=75, multiply by 1.25 while ultimate active, then round once and clamp to >=1.

- [ ] **Step 4: Implement pulse/resource process**

Pulse gets current `enemies` nodes, filters by radius, damages each once, and adds 4 per successful damage call. `on_enemy_died()` adds 12. Resource gain resets `time_since_gain=0`; positive `_process(delta)` advances timer and decays only after the first 1 second without gain.

- [ ] **Step 5: Implement ultimate lifecycle/deactivate**

`try_use_ultimate()` succeeds only at 100 and inactive, consumes to zero, starts 6 seconds, emits `귀인화`. Deactivate prevents further resource/pulse processing.

- [ ] **Step 6: Run focused/full regression and commit**

```bash
git add scripts/schools/guiin_runtime.gd tests/unit/test_guiin_runtime.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add Guiin berserker combat loop"
```

---

### Task 5: Heukyeong Marks, Criticals, Burst, and Ultimate

**Files:**
- Create: `scripts/schools/heukyeong_runtime.gd`
- Create: `tests/unit/test_heukyeong_runtime.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- `HeukyeongRuntime.set_rng_seed(seed_value: int) -> void`.
- `HeukyeongRuntime.attack_once() -> Array[Node]` returns targets hit.
- `HeukyeongRuntime.apply_needle_hit(enemy: Node2D, force_critical: Variant = null) -> bool` returns whether hit was critical; optional test override avoids seed-coupling for exact mark tests.
- `HeukyeongRuntime.get_mark_count(enemy: Node) -> int`.
- `HeukyeongRuntime.get_total_active_marks() -> int`.

- [ ] **Step 1: Write failing mark/critical tests**

Cover up to three nearest targets, base damage 6, 20% unmarked / 40% marked critical probability selection, critical 2x damage, normal +1 mark, critical +2 total marks, 3+ triggers 16 burst/reset, marked target support effect, no mark expiry, invalid-enemy pruning, charge as current live marks, ultimate threshold 6 and exact `14 + 4 * marks` damage.

Use `force_critical` for exact damage/mark behavior and a separate seeded RNG test proving reproducible sequences.

- [ ] **Step 2: Run RED test**

Expected: runtime missing.

- [ ] **Step 3: Implement nearest-three and seeded RNG**

Sort valid Node2D enemies by squared distance and slice the first three. Critical roll uses the runtime-owned `RandomNumberGenerator.randf()` and threshold based on pre-hit mark count.

- [ ] **Step 4: Implement marks/badges/burst**

Track instance-id -> `{enemy, marks, badge}`. On 3 or more marks, call `take_damage(16)`, clear marks/badge, emit `MARK BURST`. Prune invalid enemy entries before charge calculations.

- [ ] **Step 5: Implement ultimate**

`is_ultimate_ready()` is `get_total_active_marks() >= 6`. On success snapshot valid marked enemies, damage each with `14 + 4 * marks`, clear all marks/badges, emit `암영처형`, and return true.

- [ ] **Step 6: Run focused/full regression and commit**

```bash
git add scripts/schools/heukyeong_runtime.gd tests/unit/test_heukyeong_runtime.gd tests/unit/test_script_contracts.gd
git commit -m "feat: add Heukyeong mark combat loop"
```

---

### Task 6: MVP-2 HUD Feedback

**Files:**
- Modify: `scripts/ui/hud.gd`
- Modify: `scenes/ui/hud.tscn`
- Create: `tests/integration/test_mvp2_hud.gd`

**Interfaces:**
- `HUDController.set_school(name: String) -> void`.
- `HUDController.set_school_resource(label: String, current: float, maximum: float) -> void`.
- `HUDController.set_ultimate_ready(ready: bool) -> void`.
- `HUDController.show_school_feedback(text: String) -> void`.

- [ ] **Step 1: Write failing HUD integration tests**

Load `hud.tscn`, assert `SchoolLabel`, `SchoolResourceLabel`, `UltimateLabel`, `SchoolFeedbackLabel`, methods above, exact formatting, and generation-safe feedback timeout.

Use formatting rule:

```gdscript
func set_school_resource(label: String, current: float, maximum: float) -> void:
    school_resource_label.text = "%s %d / %d" % [label, roundi(current), roundi(maximum)]
```

For labels, `set_school("봉마류") -> "SCHOOL 봉마류"`; ultimate is `ULT READY` or `ULT charging`.

- [ ] **Step 2: Run RED test**

Expected: missing labels/methods.

- [ ] **Step 3: Add labels and methods**

Place school block below existing ORBS but away from combo title. Add independent `_school_feedback_generation` and exact 1.0-second guarded timer so the old school feedback timeout cannot clear newer feedback.

- [ ] **Step 4: Run focused/full regression and commit**

```bash
git add scripts/ui/hud.gd scenes/ui/hud.tscn tests/integration/test_mvp2_hud.gd
git commit -m "feat: add MVP-2 school HUD feedback"
```

---

### Task 7: Main Scene Integration and Run Lifecycle

**Files:**
- Modify: `scripts/core/main_controller.gd`
- Modify: `scenes/main/main_scene.tscn`
- Create: `tests/integration/test_mvp2_four_schools.gd`
- Modify: `tests/integration/test_main_scene.gd`
- Modify only where approved behavior changed: existing integration tests that assume combat begins immediately.

**Interfaces:**
- Main gets `@onready var school_host: SchoolRuntimeHost = $SchoolRuntimeHost`.
- Main gets `@onready var school_selection: SchoolSelectionUI = $SchoolSelectionUI`.
- Player auto attack resolved at `$Player/AutoAttack`.
- `_on_school_selected(school_id: StringName) -> void` starts combat exactly once.
- `_set_combat_enabled(enabled: bool) -> void` controls player, initial/current enemies, and wave spawner while leaving HUD/selection/Main alive.

- [ ] **Step 1: Write failing start-gate integration test**

Load main scene, wait one frame, assert selector visible, player processing disabled, all initial enemies disabled, wave spawning disabled, `$Player/AutoAttack` disabled, and no selected school.

- [ ] **Step 2: Write failing selection/lifecycle integration tests**

For each stable id, invoke selection and verify exactly matching runtime is active and combat resumes. Assert second selection rejected; auto attack remains disabled; wave-spawned enemy receives player target and death callback; school ultimate uses `ui_accept` only while alive; game over deactivates runtime and Enter reloads to a fresh selector.

- [ ] **Step 3: Write kill-path regression test**

Use a school-caused `enemy.take_damage()` path and assert one death produces exactly one GameState kill, one combo increment, and one reward orb. Do not make the school runtime call GameState/DDD directly.

- [ ] **Step 4: Run RED integration tests**

Expected: scene lacks host/selector and Main starts combat immediately.

- [ ] **Step 5: Wire scene resources**

Add ext_resources and nodes:

```text
Main
  GameState
  CombatDDD
  Player
  WaveSpawner
  SchoolRuntimeHost
    Bongma
    Cheonsul
    Guiin
    Heukyeong
  EnemyEast/West/South/North
  HUD
  SchoolSelectionUI
```

Runtime children begin disabled. Bind Bongma familiar scene and Cheonsul/Heukyeong badge scene through exported `PackedScene` properties rather than hard-coded loads.

- [ ] **Step 6: Update MainController orchestration**

At `_ready()` connect host signals to HUD, connect selector to `_on_school_selected`, configure host, explicitly disable `$Player/AutoAttack`, and call `_set_combat_enabled(false)`. On valid selection: host selects school, HUD gets school name, selector is already hidden, and `_set_combat_enabled(true)` resumes player/enemies/spawner without enabling AutoAttack.

On enemy death, preserve this order:

```gdscript
game_state.register_kill(100)
combat_ddd.register_kill()
school_host.forward_enemy_died(enemy)
_spawn_reward_orb(death_position)
```

On alive `ui_accept`, call `school_host.try_use_ultimate()`. At game over, restart check remains first and school ultimate is not called.

- [ ] **Step 7: Update old tests only for the approved selection gate**

Old tests may explicitly activate a school before asserting enemy pressure or combat behavior. Do not weaken their movement/damage/DDD expectations.

- [ ] **Step 8: Run import, smoke, full GUT**

Run:

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --import
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . --scene res://scenes/main/main_scene.tscn --quit-after 120
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Expected: import PASS, no `SCRIPT ERROR:`/`ERROR:` in smoke, every test PASS.

- [ ] **Step 9: Commit**

```bash
git add scripts/core/main_controller.gd scenes/main/main_scene.tscn tests/integration/test_mvp2_four_schools.gd tests/integration/test_main_scene.gd tests/integration/test_enemy_pressure.gd tests/integration/test_mvp1_combat_loop.gd
git commit -m "feat: integrate MVP-2 four-school run flow"
```

Only add old integration files that actually required approved start-gate adaptation.

---

### Task 8: Adversarial Review, Metadata Reconciliation, and Readiness Gate

**Files:**
- Test-only changes as findings require.
- Generated project script `.gd.uid` files for new project/test scripts after Windows Godot 4.7.1 import.
- Never stage `project.godot` or `addons/`.

**Interfaces:**
- No new product interface; this task validates the exact PR candidate.

- [ ] **Step 1: Run adversarial attacks before readiness**

Attack these exact failures with tests or direct review:

1. combat processing before selection,
2. second selection causing two runtimes,
3. legacy AutoAttack firing with school offense,
4. duplicate death/resource counting,
5. freed-enemy dictionary entries,
6. Bongma ward bonus outside 4-second positional window,
7. recursive Cheonsul reactions,
8. Guiin process/resource continuing after death/deactivate,
9. Heukyeong RNG flakiness and stale marks,
10. ultimate/restart input collision,
11. stale HUD school-feedback timer clearing newer feedback,
12. school children/badges processing after game over,
13. `project.godot` or `addons/` appearing in diff.

Classify each finding as `MUST_FIX`, `SHOULD_FIX`, `USER_DECISION_REQUIRED`, `DEFER`, `REJECTED_CRITIQUE`, `BLOCKED_UNVERIFIED`, or `ALLOWED_LEGACY` and apply in-scope technical fixes immediately.

- [ ] **Step 2: Re-run exact remote regression after findings**

Require Godot 4.7.1 import, main-scene smoke, and all GUT tests green on the exact feature HEAD.

- [ ] **Step 3: Windows local metadata gate**

On the user's Windows checkout, switch to `feat/mvp2-four-schools` while preserving local `project.godot`/`addons/`, run Godot 4.7.1 import and full GUT, then inspect `git status --short`. Stage only project/test `.gd.uid` files explicitly; reject any addon UID or `project.godot` leak.

- [ ] **Step 4: Push metadata commit and re-run exact-head CI**

Recommended commit message:

```bash
git commit -m "chore(godot): track MVP-2 script resource UIDs"
```

Require final PR diff contains no `addons/` and no `project.godot`.

- [ ] **Step 5: Manual four-school Windows acceptance**

Run four fresh sessions and verify the approved manual checklist: selection gate/shared HUD/waves/game-over/restart plus Bongma summon+ward+백귀야행, Cheonsul burn+WET/SHOCK+오행폭주, Guiin melee+gwihyeol+low-HP+귀인화, Heukyeong marks+burst+암영처형.

- [ ] **Step 6: Ready-for-review gate**

Only mark the PR ready when exact-head CI is green, Windows local import/GUT passes, manual four-school acceptance passes, no unresolved `MUST_FIX` exists, and repository hygiene is clean. Final merge remains a user decision.
