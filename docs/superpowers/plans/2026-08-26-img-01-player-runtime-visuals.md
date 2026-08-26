# IMG-01 Player Runtime Visuals Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the player placeholder with approved v2 poses and show truthful Move, Attack, and Hit feedback from existing runtime events.

**Architecture:** `Player/Visual` becomes a `Sprite2D` with a small pose controller. A visual-only `player_action_resolved` signal starts in the selected school runtime, relays through `SchoolRuntimeHost`, and `MainController` connects it to the player visual; damage feedback stays at `PlayerController.damage_resolved`.

**Tech Stack:** Godot 4.x, GDScript, `.tscn`, GUT 9.7.1, GitHub Actions GUT workflow.

**Spec:** `docs/superpowers/specs/2026-08-26-img-01-player-runtime-visuals-design.md`

## Global Constraints

- Use only the approved v2 alpha sources under `docs/assets/approved/img-01-player-runtime-core/`; preserve all v1 originals.
- Keep `Player/Visual` as the Scene node name. Do not change collision, movement, combat values, economy, route state, UI, or PR #49.
- Never enable legacy `AutoAttack` to produce a visual cue.
- Every new GDScript starts with a short Korean role comment on line one.
- A cue is visual-only and follows a real non-zero successful school action; Hit follows only resolved non-zero player damage.
- CI/import/smoke/GUT and human runtime evidence are separate gates.

---

### Task 1: Lock the player-pose contract with focused tests

**Files:**
- Create: `tests/unit/test_player_visual_controller.gd`
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `tests/unit/test_script_contracts.gd`

**Interfaces:**
- Produces: `show_attack()`, `show_hit()`, `advance_pose(delta)`, and `current_pose()` on `PlayerVisualController`.

- [ ] **Step 1: Write the failing pose tests**

```gdscript
func test_hit_overrides_attack_and_returns_to_move() -> void:
	var visual := VisualScript.new()
	visual.move_texture = GradientTexture2D.new()
	visual.attack_texture = GradientTexture2D.new()
	visual.hit_texture = GradientTexture2D.new()
	add_child_autofree(visual)
	visual.show_attack()
	assert_eq(visual.current_pose(), visual.Pose.ATTACK)
	visual.show_hit()
	assert_eq(visual.current_pose(), visual.Pose.HIT)
	visual.advance_pose(visual.hit_hold_seconds)
	assert_eq(visual.current_pose(), visual.Pose.MOVE)
```

Assert that `Player/Visual` is a `Sprite2D`, retains existing collision/camera/AutoAttack contracts, uses the three v2 textures, and has `Vector2(0.05, 0.05)` scale.

- [ ] **Step 2: Run the focused test and prove it fails**

Run:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -gtest=res://tests/unit/test_player_visual_controller.gd -gexit
```

Expected: FAIL because the controller script does not exist.

- [ ] **Step 3: Add script-contract coverage**

Assert that `SchoolRuntimeBase` and `SchoolRuntimeHost` expose `player_action_resolved`, and the player visual exposes all four pose methods.

- [ ] **Step 4: Commit only the failing tests**

```powershell
git add tests/unit/test_player_visual_controller.gd tests/integration/test_main_scene.gd tests/unit/test_script_contracts.gd
git commit -m "test: define IMG-01 player visual contract"
```

### Task 2: Implement the pose controller and Scene swap

**Files:**
- Create: `scripts/player/player_visual_controller.gd`
- Modify: `scenes/player/player.tscn`

**Interfaces:**
- Consumes: exported `Texture2D` resources and `PlayerController.damage_resolved`.
- Produces: `Pose.MOVE`, `Pose.ATTACK`, `Pose.HIT` and a `Sprite2D` named `Visual`.

- [ ] **Step 1: Implement the minimal controller**

Start with `# 플레이어 승인 포즈의 상태 전환과 우선순위를 관리한다.` and implement:

```gdscript
enum Pose { MOVE, ATTACK, HIT }
@export var move_texture: Texture2D
@export var attack_texture: Texture2D
@export var hit_texture: Texture2D
@export var attack_hold_seconds := 0.18
@export var hit_hold_seconds := 0.16
var _pose := Pose.MOVE
var _remaining := 0.0

func show_attack() -> void:
	if _pose == Pose.HIT:
		return
	_set_pose(Pose.ATTACK, attack_hold_seconds)

func show_hit() -> void:
	_set_pose(Pose.HIT, hit_hold_seconds)

func advance_pose(delta: float) -> void:
	if _pose == Pose.MOVE:
		return
	_remaining = maxf(_remaining - maxf(delta, 0.0), 0.0)
	if _remaining <= 0.0:
		_set_pose(Pose.MOVE, 0.0)
```

In `_ready`, select Move and connect the parent `PlayerController`. The damage callback invokes Hit only when `resolved > 0` and `evaded` is false. `_process(delta)` delegates to `advance_pose(delta)`.

- [ ] **Step 2: Replace only the placeholder node**

Replace the `Polygon2D` named `Visual` with a `Sprite2D` of the same name. Add ext-resources for controller and v2 PNGs, set Move initially, assign all three exports, and set `scale = Vector2(0.05, 0.05)`. Do not alter collision, Camera2D, or AutoAttack.

- [ ] **Step 3: Run focused tests**

Run the Task 1 test and:

```powershell
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests/integration -gtest=res://tests/integration/test_main_scene.gd -gexit
```

Expected: PASS.

- [ ] **Step 4: Commit**

```powershell
git add scripts/player/player_visual_controller.gd scenes/player/player.tscn
git commit -m "feat: render approved IMG-01 player poses"
```

### Task 3: Relay only real school actions to the player visual

**Files:**
- Modify: `scripts/schools/school_runtime_base.gd`
- Modify: `scripts/schools/school_runtime_host.gd`
- Modify: `scripts/schools/bongma_familiar.gd`, `scripts/schools/bongma_runtime.gd`
- Modify: `scripts/schools/cheonsul_runtime.gd`, `scripts/schools/guiin_runtime.gd`, `scripts/schools/heukyeong_runtime.gd`
- Modify: `scripts/core/main_controller.gd`
- Modify: the matching school unit tests and `tests/unit/test_school_runtime_host.gd`

**Interfaces:**
- Produces: `signal player_action_resolved` on Base and Host; `signal attack_resolved` on `BongmaFamiliar`.
- Consumes: `PlayerVisualController.show_attack()` from `MainController`.

- [ ] **Step 1: Write failing signal tests**

Use the existing GUT fixture/watcher pattern:

```gdscript
watch_signals(runtime)
assert_eq(runtime.apply_flame_cast(Vector2.ZERO), 1)
assert_signal_emitted(runtime, "player_action_resolved")

watch_signals(runtime)
assert_eq(runtime.apply_flame_cast(Vector2(9999, 9999)), 0)
assert_signal_not_emitted(runtime, "player_action_resolved")
```

Add the same success/zero-result checks for Guiin pulse and Heukyeong needle; watch `BongmaFamiliar.attack_resolved`; select a Host runtime and assert one relay.

- [ ] **Step 2: Run focused school tests and confirm failure**

Run the edited Bongma, Cheonsul, Guiin, Heukyeong, and Host unit scripts individually through the project GUT route. Expected: failures only for the missing signals.

- [ ] **Step 3: Implement side-effect-free successful-action emission**

Add to Base:

```gdscript
signal player_action_resolved

func emit_player_action_resolved() -> void:
	if active:
		player_action_resolved.emit()
```

Relay in `SchoolRuntimeHost._connect_runtime`. Emit once after Cheonsul gets a hit and Guiin gets `hit_count > 0`. Emit from Heukyeong `apply_needle_hit` only after `actual_damage > 0`, without changing its boolean return.

For Bongma, keep `attack_once() -> Node`, but save the actual result of `deal_school_damage`/ `take_damage`; emit `attack_resolved` only when it is greater than zero. Connect each familiar in `BongmaRuntime._spawn_familiar` to Base emission.

In `MainController`, add a typed `$Player/Visual` reference and connect Host action resolution to `player_visual.show_attack` beside existing runtime wiring.

- [ ] **Step 4: Run focused tests**

Run all Task 3 school scripts, the pose script, Host script, and main-scene script. Expected: PASS with existing damage/cooldown/target assertions unchanged.

- [ ] **Step 5: Commit**

```powershell
git add scripts/schools scripts/core/main_controller.gd tests/unit tests/integration/test_main_scene.gd
git commit -m "feat: relay school actions to player visuals"
```

### Task 4: Verify and record the evidence ceiling

**Files:**
- Modify: `docs/CURRENT_VISUAL_HANDOFF.md`
- Modify: `docs/assets/approved/img-01-player-runtime-core/README.md`
- Modify: Notion Production Handoff

**Interfaces:**
- Consumes: exact commit, CI run, and observed manual Godot evidence.
- Produces: a precise receipt without promoting unrun evidence.

- [ ] **Step 1: Run regression validation**

Run `git diff --check`, the full GUT route in `.github/workflows/gut.yml`, Godot import, and main-scene smoke when the current shared-host route is available. Otherwise use exact-head CI and mark local runtime evidence separately.

- [ ] **Step 2: Perform manual Godot review**

Confirm Move has no checkerboard; each school’s real successful action triggers brief Attack; actual player damage triggers Hit and wins overlap; every pose returns to Move; collision/camera/input have no regression.

- [ ] **Step 3: Update evidence after observation only**

Record source continuity, exact PR head, CI links, and each evidence class. Use `NOT_RUN` for any manual check not observed.

- [ ] **Step 4: Commit and open a fresh Issue #58 PR**

```powershell
git add docs
git commit -m "docs: record IMG-01 runtime visual evidence"
```

Open a fresh PR; do not merge without explicit user approval.
