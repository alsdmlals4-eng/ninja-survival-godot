# MVP-0 Combat Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and verify a minimal Godot 4.7.1 combat slice with movement, enemy chase, automatic projectiles, HP/kill feedback, game over, restart, and GUT coverage for deterministic logic.

**Architecture:** Keep gameplay responsibilities in small Godot scenes/scripts. Use a lightweight `GameState` for score only, local player/enemy health, a dedicated nearest-target auto-attack controller, and a scene-level controller for composition. Use GitHub Actions as an independent Linux verification executor because this chat cannot invoke the user's Windows Godot process directly.

**Tech Stack:** Godot 4.7.1 Standard, GDScript, GUT 9.7.1 in CI, GitHub Actions Ubuntu runner.

## Global Constraints

- Godot 4.x + GDScript only.
- Current user runtime target: Godot 4.7.1.
- User-confirmed local tools: Godot AI 3.1.3, Hera enabled/approved, GUT enabled/approved.
- Do not overwrite or vendor the user's local plugin configuration into production commits.
- MVP-0 only: no kill-combo/stylish score, schools, rest loop, backpack, fate, meta progression, polished art, or complex enemy patterns.
- Use built-in `ui_left`, `ui_right`, `ui_up`, `ui_down`, `ui_accept` input actions to avoid custom input-map edits.
- Do not claim MVP-0 complete without fresh automated test evidence and user/local runtime evidence.
- `project.godot` main-scene/plugin reconciliation is an integration gate after local plugin changes are known.

---

### Task 1: Add independent Godot/GUT verification harness

**Files:**
- Create: `.github/workflows/gut.yml`
- Create: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- Consumes: repository `project.godot` and future `tests/unit` scripts.
- Produces: a GitHub Actions job that installs Godot 4.7.1 and GUT 9.7.1 temporarily, imports the project, and runs GUT.

- [ ] **Step 1: Add the CI harness**

```yaml
name: GUT

on:
  push:
  pull_request:

permissions:
  contents: read

jobs:
  gut:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - name: Install Godot 4.7.1
        run: |
          curl -L --fail -o godot.zip https://github.com/godotengine/godot-builds/releases/download/4.7.1-stable/Godot_v4.7.1-stable_linux.x86_64.zip
          unzip -q godot.zip
          chmod +x Godot_v4.7.1-stable_linux.x86_64
      - name: Install GUT 9.7.1 for CI
        run: |
          curl -L --fail -o gut.zip https://github.com/bitwes/Gut/archive/refs/tags/v9.7.1.zip
          unzip -q gut.zip
          mkdir -p addons
          cp -R Gut-9.7.1/addons/gut addons/gut
      - name: Import project
        run: ./Godot_v4.7.1-stable_linux.x86_64 --headless --editor --path . --quit-after 2
      - name: Run GUT
        run: ./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -ginclude_subdirs -gexit
```

- [ ] **Step 2: Write the first RED contract test**

```gdscript
extends GutTest

const REQUIRED_SCRIPTS := [
    "res://scripts/core/game_state.gd",
    "res://scripts/player/player_controller.gd",
    "res://scripts/enemies/enemy_chaser.gd",
    "res://scripts/combat/auto_attack_controller.gd",
    "res://scripts/combat/projectile.gd",
]

func test_mvp0_script_resources_exist() -> void:
    for path in REQUIRED_SCRIPTS:
        assert_true(ResourceLoader.exists(path), "Missing MVP-0 script: %s" % path)
```

- [ ] **Step 3: Push and verify RED**

Expected: workflow executes successfully as a harness but GUT reports the contract test failing because the five production scripts do not exist. A workflow/config failure does not count as valid RED; fix the harness until the assertion itself is the failure.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/gut.yml tests/unit/test_script_contracts.gd
git commit -m "test: add Godot 4.7 GUT verification harness"
```

---

### Task 2: Create minimum script interfaces, then drive behavior RED

**Files:**
- Create: `scripts/core/game_state.gd`
- Create: `scripts/player/player_controller.gd`
- Create: `scripts/enemies/enemy_chaser.gd`
- Create: `scripts/combat/auto_attack_controller.gd`
- Create: `scripts/combat/projectile.gd`
- Modify: `tests/unit/test_script_contracts.gd`
- Create: `tests/unit/test_game_state.gd`
- Create: `tests/unit/test_player_controller.gd`
- Create: `tests/unit/test_enemy_chaser.gd`
- Create: `tests/unit/test_auto_attack_controller.gd`
- Create: `tests/unit/test_projectile.gd`

**Interfaces:**
- `GameState.register_kill(points: int = 100) -> void`
- `PlayerController.take_damage(amount: int) -> void`
- `PlayerController.is_dead() -> bool`
- `EnemyChaser.set_target(new_target: Node2D) -> void`
- `EnemyChaser.take_damage(amount: int) -> void`
- `EnemyChaser.is_dead() -> bool`
- `AutoAttackController.find_nearest_target(candidates: Array, origin: Vector2) -> Node2D`
- `BasicProjectile.configure(new_direction: Vector2, new_speed: float, new_damage: int) -> void`

- [ ] **Step 1: Add only enough script shells to make the existence contract GREEN**

Each file gets only its correct base type and `class_name`, for example:

```gdscript
extends Node
class_name GameState
```

Do not add gameplay behavior yet.

- [ ] **Step 2: Run GUT and verify the existence contract GREEN**

Expected: `test_mvp0_script_resources_exist` passes.

- [ ] **Step 3: Extend the contract test to require the planned API**

Use `load(path).new()` and `has_method(...)`, plus `_has_property(instance, name)` implemented from `get_property_list()`. Assert every interface listed above exists.

Expected before interface implementation: assertion failures for missing methods/properties, not parser errors.

- [ ] **Step 4: Add minimal no-op interfaces to make contract tests GREEN**

Example minimal shape:

```gdscript
extends Node
class_name GameState

signal score_changed(score: int, kill_count: int)

var score: int = 0
var kill_count: int = 0

func register_kill(_points: int = 100) -> void:
    pass
```

Other scripts receive their exported fields, signals, and no-op methods with safe default return values only.

- [ ] **Step 5: Add behavior tests and verify RED**

`test_game_state.gd`:

```gdscript
extends GutTest
const GameStateScript = preload("res://scripts/core/game_state.gd")

func test_register_kill_increments_count_and_score() -> void:
    var state = GameStateScript.new()
    add_child_autofree(state)
    state.register_kill(125)
    assert_eq(state.kill_count, 1)
    assert_eq(state.score, 125)
```

`test_player_controller.gd`:

```gdscript
extends GutTest
const PlayerScript = preload("res://scripts/player/player_controller.gd")

func test_damage_reduces_health_and_clamps_at_zero() -> void:
    var player = PlayerScript.new()
    player.max_health = 30
    add_child_autofree(player)
    player.take_damage(12)
    assert_eq(player.health, 18)
    player.take_damage(99)
    assert_eq(player.health, 0)
    assert_true(player.is_dead())
```

`test_enemy_chaser.gd`:

```gdscript
extends GutTest
const EnemyScript = preload("res://scripts/enemies/enemy_chaser.gd")

func test_damage_kills_enemy_at_zero_health() -> void:
    var enemy = EnemyScript.new()
    enemy.max_health = 20
    add_child_autofree(enemy)
    enemy.take_damage(20)
    assert_eq(enemy.health, 0)
    assert_true(enemy.is_dead())
```

`test_auto_attack_controller.gd`:

```gdscript
extends GutTest
const AutoAttackScript = preload("res://scripts/combat/auto_attack_controller.gd")

func test_nearest_target_returns_closest_node() -> void:
    var controller = AutoAttackScript.new()
    add_child_autofree(controller)
    var far_target = Node2D.new()
    far_target.position = Vector2(100, 0)
    add_child_autofree(far_target)
    var near_target = Node2D.new()
    near_target.position = Vector2(20, 0)
    add_child_autofree(near_target)
    assert_eq(controller.find_nearest_target([far_target, near_target], Vector2.ZERO), near_target)

func test_nearest_target_returns_null_for_empty_list() -> void:
    var controller = AutoAttackScript.new()
    add_child_autofree(controller)
    assert_null(controller.find_nearest_target([], Vector2.ZERO))
```

`test_projectile.gd`:

```gdscript
extends GutTest
const ProjectileScript = preload("res://scripts/combat/projectile.gd")

func test_configure_normalizes_direction_and_sets_combat_values() -> void:
    var projectile = ProjectileScript.new()
    add_child_autofree(projectile)
    projectile.configure(Vector2(10, 0), 600.0, 12)
    assert_eq(projectile.direction, Vector2.RIGHT)
    assert_eq(projectile.speed, 600.0)
    assert_eq(projectile.damage, 12)
```

Expected: behavior assertions fail because no-op implementations do not mutate state/select targets/configure values.

- [ ] **Step 6: Commit RED tests and interface shells**

```bash
git add scripts tests/unit
git commit -m "test: define MVP-0 gameplay contracts"
```

---

### Task 3: Implement deterministic gameplay logic

**Files:**
- Modify: `scripts/core/game_state.gd`
- Modify: `scripts/player/player_controller.gd`
- Modify: `scripts/enemies/enemy_chaser.gd`
- Modify: `scripts/combat/auto_attack_controller.gd`
- Modify: `scripts/combat/projectile.gd`

**Interfaces:** Keep Task 2 signatures unchanged.

- [ ] **Step 1: Implement `GameState.register_kill` minimally**

```gdscript
func register_kill(points: int = 100) -> void:
    kill_count += 1
    score += max(points, 0)
    score_changed.emit(score, kill_count)
```

- [ ] **Step 2: Implement player initialization, movement, and damage**

Use `Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")`, `velocity = direction * move_speed`, and `move_and_slide()`. Initialize `health = max_health` in `_ready()`. Ignore non-positive damage and additional damage after death; clamp health at zero and emit death once.

- [ ] **Step 3: Implement enemy health, chase, and contact cooldown**

Track a `Node2D` target. Move toward it in `_physics_process`. Gate contact damage with a countdown timer, call `target.take_damage(contact_damage)` only when in range and ready, and emit `died(self)` once before `queue_free()`.

- [ ] **Step 4: Implement nearest-target selection and auto-fire**

Filter invalid/non-`Node2D` candidates and candidates whose `is_dead()` returns true. Compare `distance_squared_to`. Fire only when the projectile scene exists, target direction is non-zero, and the owner is a `Node2D`.

- [ ] **Step 5: Implement projectile configuration/movement/hit/lifetime**

Normalize direction in `configure`, move in `_physics_process`, damage bodies that expose `take_damage`, then `queue_free`. Expire projectiles after a short lifetime.

- [ ] **Step 6: Run GUT and verify GREEN**

Expected: all Task 2 deterministic tests pass with zero test failures and no unexpected parser/runtime errors.

- [ ] **Step 7: Commit**

```bash
git add scripts tests/unit
git commit -m "feat: implement MVP-0 combat logic"
```

---

### Task 4: Build scene composition under integration tests

**Files:**
- Create: `scripts/core/main_controller.gd`
- Create: `scripts/ui/hud.gd`
- Create: `scenes/player/player.tscn`
- Create: `scenes/enemies/enemy_basic.tscn`
- Create: `scenes/projectiles/projectile_basic.tscn`
- Create: `scenes/ui/hud.tscn`
- Create: `scenes/main/main_scene.tscn`
- Create: `tests/integration/test_main_scene.gd`

**Interfaces:**
- Main scene contains nodes named `GameState`, `Player`, `HUD`.
- Player contains enabled `Camera2D` and `AutoAttack`.
- HUD exposes `set_health(current, maximum)`, `set_score(score, kills)`, `show_game_over()`.

- [ ] **Step 1: Write integration resource/structure tests first**

```gdscript
extends GutTest

const MAIN_SCENE := "res://scenes/main/main_scene.tscn"

func test_main_scene_has_core_nodes() -> void:
    assert_true(ResourceLoader.exists(MAIN_SCENE))
    var packed: PackedScene = load(MAIN_SCENE)
    var main = packed.instantiate()
    add_child_autofree(main)
    assert_not_null(main.get_node_or_null("GameState"))
    assert_not_null(main.get_node_or_null("Player"))
    assert_not_null(main.get_node_or_null("HUD"))
    assert_not_null(main.get_node_or_null("Player/Camera2D"))
    assert_not_null(main.get_node_or_null("Player/AutoAttack"))
```

Run only this integration directory and verify RED because the scene does not yet exist.

- [ ] **Step 2: Create minimal placeholder scenes**

Use `Polygon2D` plus `CollisionShape2D` for player/enemy/projectile visuals. No external art dependency. Player and enemy roots are `CharacterBody2D`; projectile root is `Area2D`; HUD root is `CanvasLayer`; main root is `Node2D`.

- [ ] **Step 3: Make the structure test GREEN**

The scene must parse and instantiate headlessly with the required nodes present.

- [ ] **Step 4: Add integration behavior tests**

Assert initial enemy count is non-zero, GameState score updates HUD text after `register_kill`, player damage updates HP text, and lethal damage makes the game-over panel visible.

Expected: RED until `main_controller.gd` and `hud.gd` wire signals/state correctly.

- [ ] **Step 5: Implement main/HUD wiring minimally**

Main connects player health/death and GameState score signals, spawns several enemies around the player, sets enemy targets, pauses on death, and handles `ui_accept` to reload. HUD only formats labels and toggles the game-over container.

- [ ] **Step 6: Run all GUT tests and verify GREEN**

Expected: unit + integration suites pass headlessly.

- [ ] **Step 7: Commit**

```bash
git add scenes scripts tests
git commit -m "feat: compose runnable MVP-0 combat scene"
```

---

### Task 5: Headless smoke test, review, and integration handoff

**Files:**
- Modify only if review finds a scope-local defect.
- Do not modify `project.godot` until local plugin-generated changes are reconciled.

- [ ] **Step 1: Run project import and direct scene smoke test**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --editor --path . --quit-after 2
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . res://scenes/main/main_scene.tscn --quit-after 120
```

Expected: no parse errors, missing-resource errors, or crash. The second command is a structural smoke test only; it does not prove player feel.

- [ ] **Step 2: Run full GUT suite again**

```bash
./Godot_v4.7.1-stable_linux.x86_64 --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Expected: zero failures.

- [ ] **Step 3: Perform adversarial review**

Check for: duplicated state ownership, frame-rate-dependent damage, invalid target references, project.godot/plugin overwrite risk, paused-tree restart failure, projectiles accumulating, tests that pass without exercising real behavior, scope creep into MVP-1+.

- [ ] **Step 4: Apply only scope-local MUST_FIX/technical SHOULD_FIX findings and re-run Step 1-2**

No new gameplay feature is added during review.

- [ ] **Step 5: Open PR with exact verification evidence**

PR body records Godot/GUT versions, workflow run, automated test counts, untested visual/feel items, and local Windows verification commands.

- [ ] **Step 6: Local integration gate**

Before setting `application/run/main_scene`, inspect the user's local `git status` and plugin-related `project.godot`/`addons` changes. Preserve Godot AI 3.1.3, Hera, and GUT activation. Then either merge a non-conflicting main-scene setting or set it in the editor and commit the reconciled `project.godot` intentionally.

- [ ] **Step 7: User runtime acceptance**

Fresh Windows Godot 4.7.1 evidence must verify eight-direction movement, camera follow, enemy chase, automatic hit/kill, visible score/HP update, contact damage cadence, game-over display, and restart. Only then mark MVP-0 complete.
