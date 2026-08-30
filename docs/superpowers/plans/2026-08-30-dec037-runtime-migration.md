# DEC-037 Runtime Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the approved direct-control Ninja, two-charge dash, top-only automatic-combat HUD, public Stage/Phase language, and exact centered 3x3 starting backpack true in the Godot runtime while preserving all existing route, economy, spatial, Fate, combination, and combat-modifier ownership boundaries.

**Architecture:** `PlayerController` receives normalized movement/dash intent and remains the sole movement/dash owner. `HUDController` renders the compact combat state and emits settings/touch intents only. `MainController` wires the existing school circuit, player, HUD, and selection view without moving domain state into UI. A pure `StagePhasePresentation` adapter translates current circuit lifecycle states into player-facing text. The catalog retains its 6x6 outer board but replaces the free twelve-cell start footprint with a centered nine-cell 3x3 footprint.

**Tech Stack:** Godot 4.7 / GDScript / GUT

**Spec:** `docs/superpowers/specs/2026-08-30-dec037-runtime-migration-design.md`

## Global Constraints

- Build from the current DEC-037 worktree and preserve the dirty user root untouched.
- Do not rename `school_id`, `RunRouteState.stage_index()`, existing checkpoint keys, or route/economy/Fate authorities. `stage_index()` remains internal route depth; it must not be reused as the battle Phase display.
- Do not add a manual attack, aiming, skill bar, ultimate button, dash immunity, dash collision bypass, stamina economy, save-format migration, new autoload, or a second wave system.
- `PlayerController` is the only code permitted to consume/recover dash charges. The HUD and touch controls must only send intent or render state.
- Maintain `CharacterBody2D.move_and_slide()` for normal and dash locomotion, so collision behavior and current combat consumers are retained.
- A normal combat screen must expose only `DASH`, `PLAY`, and `설정` in its persistent top bar. Terminal Game Over is an allowed overlay; the settings sheet is a temporary overlay.
- Keep the existing approved player, floor, independent props, and contact shadows. This DEC-037 package creates no raster art; any newly discovered required VFX/image needs its own candidate-and-user-lock gate.
- Tests must use the project’s current GUT conventions. Every test is added or rewritten before its production change in the same task.

---

## Task 1: Add a pure Stage/Phase presentation boundary

**Files:**
- Create: `scripts/ui/stage_phase_presentation.gd`
- Create: `tests/unit/test_stage_phase_presentation.gd`
- Modify: `scripts/core/main_controller.gd`

- [ ] **Step 1: Write the failing presentation tests.**

  Create `test_stage_phase_presentation.gd`, preload `StagePhasePresentation`, and require every live `SchoolCircuitController` state to map to the approved Korean public copy. The tests must also prove unknown and non-combat inputs fail closed rather than inventing a fifth Phase:

  ```gdscript
  func test_cheonsul_core_maps_to_public_stage_and_phase_one() -> void:
      var view := StagePhasePresentation.describe(&"cheonsul", &"core")
      assert_eq(view, {
          "visible": true,
          "stage": "스테이지 · 천술류 전장",
          "phase": "페이즈 1 · Core 압박",
      })

  func test_all_live_circuit_states_have_only_approved_phase_labels() -> void:
      var expected := {
          &"core": "페이즈 1 · Core 압박",
          &"elite_warning": "페이즈 2 · Elite 접근",
          &"elite_active": "페이즈 2 · Elite 접근",
          &"trace_available": "페이즈 3 · Trace 회수",
          &"trace_recovered": "페이즈 3 · Trace 회수",
          &"boss_warning": "페이즈 3 · Trace 회수",
          &"boss_active": "페이즈 4 · Boss 결전",
      }
      for circuit_state in expected:
          assert_eq(StagePhasePresentation.describe(&"bongma", circuit_state)["phase"], expected[circuit_state])

  func test_unknown_stage_or_circuit_state_hides_presentation() -> void:
      assert_eq(StagePhasePresentation.describe(&"unknown", &"core"), {"visible": false, "stage": "", "phase": ""})
      assert_eq(StagePhasePresentation.describe(&"cheonsul", &"cleared"), {"visible": false, "stage": "", "phase": ""})
  ```

- [ ] **Step 2: Run the new test and confirm it fails because the adapter does not exist.**

  Run only `tests/unit/test_stage_phase_presentation.gd` through the project’s documented GUT command. Record the expected missing-script/class failure without classifying it as a passing test.

- [ ] **Step 3: Implement the small pure adapter.**

  Add `class_name StagePhasePresentation`, constants for the four public Stage names and the approved state-to-Phase dictionary, and a single `static func describe(school_id: StringName, circuit_state: StringName) -> Dictionary`. Return exactly:

  ```gdscript
  {"visible": false, "stage": "", "phase": ""}
  ```

  for an unknown school, a terminal state such as `cleared`, or any unrecognized lifecycle state. Never call `RunRouteState.stage_index()` in this class. In `main_controller.gd`, preload the adapter near existing script preloads; no controller wiring happens until Task 6.

- [ ] **Step 4: Re-run the focused presentation test.**

  Require every mapping assertion to pass and run `git diff --check` before committing.

- [ ] **Step 5: Commit the pure boundary.**

  ```bash
  git add scripts/ui/stage_phase_presentation.gd tests/unit/test_stage_phase_presentation.gd scripts/core/main_controller.gd
  git commit -m "feat: add public stage phase presentation"
  ```

## Task 2: Make the catalog’s starting backpack exactly 3x3

**Files:**
- Modify: `scripts/data/mvp4_catalog.gd`
- Modify: `scripts/backpack/backpack_state.gd`
- Modify: `tests/unit/test_mvp4_catalog.gd`
- Modify: `tests/unit/test_mvp4_catalog_validation.gd`
- Modify: `tests/unit/test_backpack_state.gd`
- Modify: relevant current REST/checkpoint tests found by `rg -n "12|4x3|active_cells" tests`

- [ ] **Step 1: Rewrite the failing catalog/state tests first.**

  Rename the catalog and state examples to say `3x3` and assert the actual nine-cell centered region, not only a count:

  ```gdscript
  func test_catalog_has_five_purchasable_bags_plus_one_starting_3x3_bag() -> void:
      var bags := MVP4Catalog.build_bags()
      var starting_bag = bags[MVP4Catalog.STARTING_BAG_ID]
      assert_eq(starting_bag.base_price, 0)
      assert_eq(starting_bag.cells.size(), 9)
      assert_true(starting_bag.cells.has(Vector2i(0, 0)))
      assert_true(starting_bag.cells.has(Vector2i(2, 2)))
      assert_false(starting_bag.cells.has(Vector2i(3, 2)))

  func test_starting_state_has_centered_3x3_active_area_and_stable_starting_bag() -> void:
      var active_cells: Dictionary = _starting_state().get_active_cells()
      assert_eq(active_cells.size(), 9)
      assert_true(active_cells.has(Vector2i(1, 1)))
      assert_true(active_cells.has(Vector2i(3, 3)))
      assert_false(active_cells.has(Vector2i(4, 3)))
      assert_false(active_cells.has(Vector2i(0, 0)))
  ```

  Preserve assertions that the technical board remains `Vector2i(6, 6)`, an item outside the active 3x3 is rejected without mutation, and the starting bag cannot be removed. Update expansion counts from the old twelve-cell baseline: a `small_pouch` at `(0, 0)` makes eleven active cells, and a disjoint `square_pouch` at `(4, 4)` makes fifteen. Keep existing rotation, adjacency, REST buffer, combination, and checkpoint-copy tests intact.

- [ ] **Step 2: Run the catalog/state/REST-focused tests and confirm the 12-cell expectations fail.**

  Run the exact affected unit files. If a test currently uses a location that is now outside the 3x3 for an unrelated defensive-copy purpose, relocate its fixture to a legal cell while retaining the defensive-copy assertion.

- [ ] **Step 3: Implement only the catalog footprint migration.**

  Change the catalog construction and validator to:

  ```gdscript
  _add_bag(bags, STARTING_BAG_ID, "기본 가방", 0, _rectangle_cells(Vector2i(3, 3)))
  # ...
  if starting.cells.size() != 9:
      errors.append("Starting bag must contain 9 cells")
  ```

  Keep `BackpackState.BOARD_SIZE == Vector2i(6, 6)` and `STARTING_BAG_ORIGIN == Vector2i(1, 1)`. Do not alter shop bag IDs, prices, item definitions, spatial legality, or checkpoint schema. Only change `backpack_state.gd` if its own code carries an explicit twelve-cell assumption; otherwise tests are the proof that its existing generic state construction remains correct.

- [ ] **Step 4: Run focused verification.**

  Pass catalog validation, catalog, backpack state, REST session, and relevant checkpoint/retry tests. Confirm no test uses the old start count by running:

  ```bash
  rg -n "4x3|12 cells|cells.size\(\), 12|active_cells\(\).size\(\), 12" tests scripts
  ```

  Any match must be reviewed; retain only historical comments that cannot influence behavior, otherwise migrate it to the nine-cell contract.

- [ ] **Step 5: Commit the footprint migration.**

  ```bash
  git add scripts/data/mvp4_catalog.gd scripts/backpack/backpack_state.gd tests/unit
  git commit -m "feat: start runs with a centered 3x3 backpack"
  ```

## Task 3: Declare one named movement and dash input contract

**Files:**
- Modify: `project.godot`
- Modify: `tests/unit/test_player_controller.gd`
- Create: `tests/unit/test_input_map_contract.gd`

- [ ] **Step 1: Add failing InputMap contract tests.**

  The test must load project settings and prove that the five named actions exist: `move_left`, `move_right`, `move_up`, `move_down`, and `dash`. Assert the bindings represent the approved keyboard/gamepad contract without relying on the old UI-only actions:

  ```gdscript
  func test_dec037_movement_and_dash_actions_are_declared() -> void:
      for action_name in [&"move_left", &"move_right", &"move_up", &"move_down", &"dash"]:
          assert_true(InputMap.has_action(action_name), "%s must be a named input action" % action_name)

  func test_dash_has_keyboard_and_gamepad_bindings() -> void:
      var events := InputMap.action_get_events(&"dash")
      assert_true(events.any(func(event: InputEvent) -> bool: return event is InputEventKey))
      assert_true(events.any(func(event: InputEvent) -> bool: return event is InputEventJoypadButton))
  ```

  Update `test_player_controller.gd` to call a parameterized resolver such as `resolve_movement_direction(action_direction, pointer_direction)` rather than passing physical-key booleans. Its expected diagonal and opposing-direction behavior must stay normalized and deterministic.

- [ ] **Step 2: Run the InputMap/player resolver tests and confirm the missing named actions fail.**

- [ ] **Step 3: Add the action map in `project.godot`.**

  Create an `[input]` section using Godot serializable `InputEventKey` and `InputEventJoypad*` objects:

  ```ini
  [input]

  move_left={
  "deadzone": 0.5,
  "events": [Object(InputEventKey,"physical_keycode":65), Object(InputEventKey,"physical_keycode":4194311), Object(InputEventJoypadMotion,"axis":0,"axis_value":-1.0), Object(InputEventJoypadButton,"button_index":13)]
  }
  ```

  Use the Godot editor’s serialized form for all five actions instead of hand-inventing incompatible property names: A/Left, D/Right, W/Up, S/Down, left-stick axes plus D-pad, and Shift/Space plus south face button for `dash`. Preserve existing `ui_*` actions; they remain available for focus/dialog navigation.

- [ ] **Step 4: Re-run focused input tests and a headless import parse.**

  The test validates meaningful binding families, not a platform-specific keycode ordering. Verify `project.godot` imports under the current Godot binary before committing.

- [ ] **Step 5: Commit the shared input contract.**

  ```bash
  git add project.godot tests/unit/test_input_map_contract.gd tests/unit/test_player_controller.gd
  git commit -m "feat: declare direct movement input actions"
  ```

## Task 4: Implement controller-owned direct movement, pointer target, and dash

**Files:**
- Modify: `scripts/player/player_controller.gd`
- Modify: `tests/unit/test_player_controller.gd`
- Create: `tests/integration/test_player_dash_runtime.gd`

- [ ] **Step 1: Write the failing controller behavior tests.**

  Add explicit cases for the state contract and ensure damage behavior does not change during an active dash:

  ```gdscript
  func test_dash_consumes_one_of_two_charges_and_emits_read_only_state() -> void:
      var player := _spawn_player()
      player.set_movement_intent(Vector2.RIGHT)
      watch_signals(player)
      assert_true(player.request_dash())
      assert_eq(player.current_dash_charges(), 1)
      assert_signal_emitted_with_parameters(player, "dash_state_changed", [1, 2])

  func test_dash_rejects_zero_direction_dead_player_and_empty_charges_without_mutation() -> void:
      var player := _spawn_player()
      assert_false(player.request_dash())
      assert_eq(player.current_dash_charges(), 2)
      # Consume both valid charges, then assert a third request is false.
      # Kill the player with take_damage and assert a request remains false.

  func test_dash_recharges_one_charge_after_one_point_five_seconds() -> void:
      var player := _spawn_player()
      player.set_movement_intent(Vector2.RIGHT)
      assert_true(player.request_dash())
      player.advance_dash_for_test(1.49)
      assert_eq(player.current_dash_charges(), 1)
      player.advance_dash_for_test(0.01)
      assert_eq(player.current_dash_charges(), 2)

  func test_active_dash_prevents_damage_only_during_the_dash_window() -> void:
      var player := _spawn_player()
      player.set_movement_intent(Vector2.RIGHT)
      assert_true(player.request_dash())
      assert_eq(player.take_damage(10), 0)
      assert_eq(player.health, 100)
      player.advance_dash_for_test(0.20)
      assert_eq(player.take_damage(10), 10)
      assert_eq(player.health, 90)
  ```

  Add pointer tests: a target farther than `POINTER_ARRIVAL_RADIUS` creates a normalized direction; a target within that radius returns `Vector2.ZERO`; clearing the target restores action movement. Add a small integration test that steps an actual `CharacterBody2D` in a collision world and proves the dash uses the current collision movement path instead of changing the collision layer/mask or teleporting.

- [ ] **Step 2: Run player/dash tests and confirm they fail before behavior exists.**

- [ ] **Step 3: Implement the narrow controller interface.**

  Add exported/tunable constants at the top of `PlayerController`:

  ```gdscript
  const MAX_DASH_CHARGES := 2
  const DASH_DURATION_SECONDS := 0.20
  const DASH_SPEED_MULTIPLIER := 3.0
  const DASH_RECHARGE_SECONDS := 1.5
  const POINTER_ARRIVAL_RADIUS := 12.0

  signal dash_state_changed(charges: int, maximum_charges: int)
  signal dash_started(direction: Vector2)
  ```

  Add public movement adapters with no UI dependency:

  ```gdscript
  func set_movement_intent(direction: Vector2) -> void:
      _movement_intent = direction.limit_length(1.0)

  func set_pointer_target(world_position: Vector2) -> void:
      _pointer_target = world_position
      _has_pointer_target = true

  func clear_pointer_target() -> void:
      _has_pointer_target = false

  func current_dash_charges() -> int:
      return _dash_charges

  func request_dash() -> bool:
      if _dead or _dash_charges <= 0 or _resolved_direction == Vector2.ZERO:
          return false
      _dash_charges -= 1
      _dash_remaining = DASH_DURATION_SECONDS
      _dash_direction = _resolved_direction
      dash_started.emit(_dash_direction)
      dash_state_changed.emit(_dash_charges, MAX_DASH_CHARGES)
      return true
  ```

  In `_physics_process(delta)`, read `Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")`, resolve an optional pointer direction, and call `request_dash()` only for `Input.is_action_just_pressed(&"dash")`. During active dash set velocity to `_dash_direction * move_speed * DASH_SPEED_MULTIPLIER`, decrement `_dash_remaining`, and still call `move_and_slide()`. Outside a dash set velocity from the resolved direction and `move_speed`. Restore each missing charge at 1.5-second intervals only while alive; emit `dash_state_changed` after every charge mutation and emit initial `2/2` in `_ready`/retry restoration.

  **2026-08-30 user-directed override:** `take_damage` checks `_dash_remaining` after invalid/dead rejection and before modifier evasion. During the active 0.20-second dash it resolves the full requested damage as `0` with `evaded=true`; on expiry it immediately resumes the normal damage path. It still must not change collision state, and must not export a generic test-only production mutator.

- [ ] **Step 4: Implement pointer input collection at the gameplay boundary.**

  In `MainController` (or a dedicated local input adapter child if that is required by the actual scene), consume unhandled pointer events only when combat is enabled, the settings view is closed, and the event is not handled by a Control. Convert `event.position` through the player camera/canvas transform into world coordinates, call `player.set_pointer_target(...)` on left press/drag, `player.clear_pointer_target()` on left release, and `player.request_dash()` on right press after setting a valid pointer direction. This code must not mutate player velocity or charges.

  Add a focused integration assertion that an HUD/Settings Control click leaves the player pointer target unchanged. Input source must be disabled when game is over or combat is disabled.

- [ ] **Step 5: Re-run movement/dash tests and import parse.**

  Require the original movement-modifier, health, damage, retry, and auto-attack-related player tests to remain green along with the new focused suites.

- [ ] **Step 6: Commit controller behavior.**

  ```bash
  git add scripts/player/player_controller.gd scripts/core/main_controller.gd tests/unit/test_player_controller.gd tests/integration/test_player_dash_runtime.gd
  git commit -m "feat: add direct movement and two charge dash"
  ```

## Task 5: Replace the normal combat surface with top bar, settings, and device touch inputs

**Files:**
- Modify: `scenes/ui/hud.tscn`
- Modify: `scripts/ui/hud.gd`
- Modify: `tests/integration/test_mvp1_hud.gd`
- Modify: `tests/integration/test_mvp2_hud.gd`
- Modify: `tests/integration/test_mvp3_hud.gd`
- Create: `tests/unit/test_hud_combat_surface.gd`

- [ ] **Step 1: Write failing HUD state and layout tests.**

  Assert the normal-combat node contract and public intent signals rather than implementation-specific offsets:

  ```gdscript
  func test_combat_top_bar_shows_dash_play_and_settings_only() -> void:
      var hud := _spawn_hud()
      hud.show_combat_hud(true)
      assert_true(hud.get_node("CombatTopBar/DashLabel").visible)
      assert_true(hud.get_node("CombatTopBar/PlayLabel").visible)
      assert_true(hud.get_node("CombatTopBar/SettingsButton").visible)
      assert_eq(hud.combat_persistent_control_names(), ["DashLabel", "PlayLabel", "SettingsButton"])

  func test_dash_and_play_are_render_only() -> void:
      var hud := _spawn_hud()
      hud.set_dash_state(1, 2)
      hud.set_play_time(134.0)
      assert_eq(hud.dash_text(), "DASH 1 / 2")
      assert_eq(hud.play_text(), "PLAY 02:14")

  func test_settings_emits_resume_help_and_restart_intents() -> void:
      var hud := _spawn_hud()
      watch_signals(hud)
      hud.open_settings()
      hud.press_resume_for_test()
      assert_signal_emitted(hud, "resume_requested")
      # Repeat for current_tradition_help_requested and restart_requested.
  ```

  Also assert there is no `UltimateButton`, test jump button, permanent HP/score/combo/style/reward/resource/gold label, school-help button, or lower skill button in the normal combat tree. Preserve an explicit test that `GameOverPanel` appears for the terminal state and that its retry path remains functional.

- [ ] **Step 2: Run the HUD tests and confirm legacy HUD expectations fail.**

  Update legacy MVP HUD tests to verify retained data/domain signal wiring indirectly through current behavior or new presentation methods; remove assertions that require prohibited persistent combat controls.

- [ ] **Step 3: Rebuild `hud.tscn` around the compact public surface.**

  Replace the normal persistent controls with:

  ```text
  HUD (CanvasLayer)
  ├── CombatTopBar (MarginContainer)
  │   └── Row (HBoxContainer)
  │       ├── DashLabel
  │       ├── StagePhaseLabel
  │       ├── PlayLabel
  │       └── SettingsButton
  ├── SettingsPanel (Control, initially hidden, process_mode=WHEN_PAUSED)
  │   └── Dialog (ResumeButton, TraditionHelpButton, RestartButton)
  ├── TouchControls (Control, device-only and hidden unless touch is available)
  │   ├── MovePad (TouchScreenButton / directional action buttons)
  │   └── DashButton (TouchScreenButton action=dash)
  └── GameOverPanel
  ```

  The visible top row must contain the required left/center/right content `DASH`, `PLAY`, and `설정`; `StagePhaseLabel` is compact contextual text, not a new lower combat bar. Do not draw custom vector assets for touch controls. Use standard Godot Controls/`TouchScreenButton` paths and current UI theme/style. Touch controls are movement input affordances, never attack/skill buttons.

- [ ] **Step 4: Implement HUD as presentation plus intent.**

  Replace old combat methods with the following public surface and signals:

  ```gdscript
  signal settings_requested
  signal resume_requested
  signal current_tradition_help_requested
  signal restart_requested

  func set_dash_state(charges: int, maximum_charges: int) -> void:
      dash_label.text = "DASH %d / %d" % [maxi(charges, 0), maxi(maximum_charges, 1)]

  func set_play_time(elapsed_seconds: float) -> void:
      var total_seconds := maxi(floori(elapsed_seconds), 0)
      play_label.text = "PLAY %02d:%02d" % [total_seconds / 60, total_seconds % 60]

  func set_stage_phase(stage_text: String, phase_text: String, visible: bool) -> void:
      stage_phase_label.visible = visible
      stage_phase_label.text = "%s · %s" % [stage_text, phase_text] if visible else ""
  ```

  `show_combat_hud(enabled)` must hide the top bar and touch controls outside enabled combat. `open_settings`, `close_settings`, `show_game_over`, and `hide_game_over` must set input/focus predictably. The HUD must never access `PlayerController`, `RunRouteState`, `BackpackState`, `Fate`, economy, or school runtime objects.

- [ ] **Step 5: Re-run focused HUD tests and import the scene.**

  Verify settings controls work while `SceneTree.paused` is true and that resuming restores the previous focus/visible combat top bar. Confirm touch nodes are absent from desktop non-touch normal layout, but their named actions can be tested with synthetic input.

- [ ] **Step 6: Commit HUD migration.**

  ```bash
  git add scenes/ui/hud.tscn scripts/ui/hud.gd tests/integration/test_mvp1_hud.gd tests/integration/test_mvp2_hud.gd tests/integration/test_mvp3_hud.gd tests/unit/test_hud_combat_surface.gd
  git commit -m "feat: show automatic combat through compact top hud"
  ```

## Task 6: Wire the runtime without changing route or combat owners

**Files:**
- Modify: `scripts/core/main_controller.gd`
- Modify: `scripts/ui/school_selection_ui.gd`
- Modify: `scenes/ui/school_selection_ui.tscn`
- Modify: `tests/integration/test_main_scene.gd`
- Modify: `tests/integration/test_school_circuit_main_runtime.gd`
- Modify: `tests/unit/test_school_selection_ui.gd`

- [ ] **Step 1: Write failing orchestration and wording tests.**

  Add tests that select a school and prove that public copy says Stage while domain identity stays unchanged:

  ```gdscript
  func test_school_selection_uses_stage_copy_but_emits_unchanged_school_id() -> void:
      var selection := _spawn_selection()
      assert_eq(selection.title_text(), "스테이지 선택")
      watch_signals(selection)
      selection.choose_for_test(&"cheonsul")
      assert_signal_emitted_with_parameters(selection, "school_selected", [&"cheonsul"])

  func test_circuit_phase_updates_public_hud_without_mutating_route_depth() -> void:
      var main := await _spawn_started_school_main(&"cheonsul")
      var before := main.school_circuit.route_state.stage_index()
      main._on_school_circuit_phase_changed(&"boss_active")
      assert_eq(main.hud.stage_phase_text(), "스테이지 · 천술류 전장 · 페이즈 4 · Boss 결전")
      assert_eq(main.school_circuit.route_state.stage_index(), before)
  ```

  Add integration coverage that `PlayerController.dash_state_changed` is connected to `hud.set_dash_state`, the run elapsed timer drives `PLAY` upward rather than an old five-minute countdown, settings pauses/resumes gameplay through `MainController`, and the automatic attack/school runtime nodes remain active without a manual ultimate button.

- [ ] **Step 2: Run the selected integration tests and observe expected old-HUD failures.**

- [ ] **Step 3: Refactor `MainController` to be the thin orchestrator.**

  Replace legacy calls such as `hud.set_stage(...)`, `hud.set_stage_time(...)`, `hud.show_combat_controls(...)`, and persistent `show_school_help(...)` with these boundaries:

  ```gdscript
  player.dash_state_changed.connect(hud.set_dash_state)
  hud.settings_requested.connect(_on_settings_requested)
  hud.resume_requested.connect(_on_resume_requested)
  hud.current_tradition_help_requested.connect(_on_current_tradition_help_requested)
  hud.restart_requested.connect(_restart_run)

  func _on_school_circuit_phase_changed(phase: StringName) -> void:
      var view := StagePhasePresentation.describe(school_host.selected_school_id, phase)
      hud.set_stage_phase(view["stage"], view["phase"], view["visible"])
  ```

  Introduce `_run_play_elapsed_seconds` that increments only while actual combat is enabled and the run is not paused/game-over. Feed `hud.set_play_time(_run_play_elapsed_seconds)`; retain the separate circuit elapsed values because their timing remains a Boss/encounter domain input. `_on_settings_requested` pauses the tree after HUD opens its `WHEN_PAUSED` panel. Resume restores prior combat state. Help delegates to existing `school_selection.open_runtime_school_help(...)` using the settings panel opener/focus target. Restart delegates to the existing restart flow; no HUD mutation of domain state.

  In `_set_combat_enabled`, set `hud.show_combat_hud(enabled and not game_over)` and hide Stage/Phase outside active school combat. Preserve game-over, retry, school selection, trace, Boss, Workbench, Fate, and automatic school runtime connections.

- [ ] **Step 4: Change only public selection wording.**

  In `school_selection_ui.tscn`, change the title and button copy from the public word `유파 선택` to `스테이지 선택` and from bare tradition choices to `스테이지 · <tradition> 전장`, while preserving `school_selected(school_id)` and all four existing IDs. `SchoolSelectionUI` keeps the current tradition help text/owner. Do not rename files/classes/nodes merely for public wording.

- [ ] **Step 5: Run the focused integration tests.**

  Require selection, circuit, main scene, and MVP HUD tests to pass. Verify a direct call to a phase change never writes route state. Verify Play time advances from zero, pauses in settings, and never counts down. Verify no source still invokes prohibited `ultimate_requested`, test-jump, combat-guide, or legacy stage-time UI functions:

  ```bash
  rg -n "show_combat_controls|set_stage_time|ultimate_requested|TestEliteButton|TestBossButton|CombatGuideLabel" scripts scenes tests
  ```

  Review every match; delete/replace any live consumer that violates the DEC-037 public combat surface, while retaining only intentionally historical test descriptions if non-behavioral.

- [ ] **Step 6: Commit runtime wiring.**

  ```bash
  git add scripts/core/main_controller.gd scripts/ui/school_selection_ui.gd scenes/ui/school_selection_ui.tscn tests/integration/test_main_scene.gd tests/integration/test_school_circuit_main_runtime.gd tests/unit/test_school_selection_ui.gd
  git commit -m "feat: present school combat as stages and phases"
  ```

## Task 7: Verify full DEC-037 behavior and record implementation evidence

**Files:**
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Modify: `docs/ACTIVE_CONTEXT.md`
- Modify only if the current repository canon convention requires it: `docs/canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md`

- [ ] **Step 1: Run the complete automated verification stack on the exact branch head.**

  Execute the project-authoritative commands for:

  1. Godot import/editor parse;
  2. headless main-scene smoke;
  3. focused GUT suites created/changed by Tasks 1–6;
  4. the complete GUT suite;
  5. `git diff --check` and a tracked-file status readback.

  Record command, exact branch head, exit result, and actual GUT counts in the task evidence/PR body. Do not derive runtime-render, Human Usability, Player Experience, Android/device/export, balance, merge, or release PASS from these results.

- [ ] **Step 2: Run a scoped live Godot observation.**

  Open the exact worktree in the verified Godot editor session and observe only these checkable facts: keyboard movement, two dash charge decrement/recovery, dash collision stop, zero-direction rejection, pointer movement/dash, top-bar-only normal combat, settings pause/resume/help/restart, Stage/Phase transitions, automatic attack after movement, and centered 3x3 initial backpack expansion. Capture runtime evidence only for behaviors actually observed; keyboard/pointer runtime observation does not prove touch or device validation.

- [ ] **Step 3: Execute five whole-scope adversarial review loops.**

  For each loop, inspect all changed code/scene/input/catalog/tests against the approved scope, validate a finding before editing, make only a validated correction, rerun affected focused tests, and re-evaluate a better long-term alternative. Cover these attack angles in order:

  1. ownership regression: UI/dash cannot mutate route, Fate, economy, spatial state, or combat modifiers;
  2. interaction conflict: UI clicks/touch focus cannot cause movement and settings/game-over cannot accept dash;
  3. collision/damage: dash does not clip, teleport, grant immunity, or fail retry reset;
  4. public language: Stage versus Phase cannot expose stale `SEGMENT`, legacy five-minute countdown, or rename internal route depth;
  5. spatial persistence: 3x3 start, 6x6 ceiling, expansion, REST/combination and checkpoint copies remain legal/atomic.

  Continue beyond five if any valid blocker or must-fix remains. Each valid fix is committed separately with a focused verification note.

- [ ] **Step 4: Update current state records honestly.**

  Change the existing DEC-037 status records from implementation-spec review to implementation reality only after the exact verification above. State the exact code/test evidence available and preserve separate fields for scoped runtime observation and `NOT_RUN` human/device/export evidence. Do not alter the decision’s approval owner, expand the canon scope, or claim user approval of visual assets that were not newly created.

- [ ] **Step 5: Commit verified docs and prepare the isolated delivery branch.**

  ```bash
  git add docs/CURRENT_CONFIRMED_DECISIONS.md docs/ACTIVE_CONTEXT.md docs/canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md
  git commit -m "docs: record DEC-037 implementation evidence"
  git status --short
  git log -1 --oneline
  ```

  Only stage the canon file if it was genuinely required to clarify implementation/evidence state. Before PR creation, run the project-required exact-head checks, inspect the full branch diff, request adversarial/code review according to repository policy, and open a new PR from this fresh branch. Do not touch historical PR #49 or the dirty primary checkout.

## Final Acceptance Checklist

- [ ] `PlayerController` owns a two-charge, 0.20-second, 3x speed, 1.5-second-per-charge dash and uses `move_and_slide()`.
- [ ] Keyboard, pointer, gamepad, and device touch routes converge into named movement/dash intents; UI interactions cannot issue gameplay pointer moves.
- [ ] Automatic attacks and school reactions still own their existing effects; no lower skill/ultimate hotbar survives normal combat.
- [ ] Normal combat exposes `DASH`, `PLAY`, and `설정` in the compact top bar; settings owns only resume/help/restart intents.
- [ ] Player-facing copy calls the destination a Stage and lifecycle progress Phase 1–4, while `RunRouteState.stage_index()` remains untouched route depth.
- [ ] The baseline usable backpack is exactly a centered 3x3 nine-cell region inside the preserved 6x6 outer board, and existing bag/REST/combination/checkpoint behavior remains protected.
- [ ] Exact automated checks, scoped runtime observation, five adversarial loops, PR review/CI, merge, and post-merge main readback are recorded separately. Human usability, player-experience, device/export, balance, and release remain `NOT_RUN` unless the exact evidence is later executed.
