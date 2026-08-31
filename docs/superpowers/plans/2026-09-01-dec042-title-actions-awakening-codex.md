# DEC-042 Title Actions, Awakening, and Codex Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Deliver a title menu with safe checkpoint-only Continue, player-facing Awakening wording, a data-derived enemy/ninjutsu/equipment Codex, and fully connected title actions.

**Architecture:** TitleScreen stays presentation-only and emits intents. MainController retains Run/route/combat ownership and owns one project-local resume store. A codec turns the existing in-memory committed checkpoint into validated JSON primitives and back; current build, route, ledger, circuit, loadout, and catalogue domains remain final restore owners. Codex text is a read-only view of the current catalogues.

**Tech Stack:** Godot 4.7.1, GDScript, FileAccess/DirAccess, GUT 9.7.1.

**Spec:** docs/superpowers/specs/2026-09-01-dec042-title-actions-awakening-codex-design.md

## Global Constraints

- Do not add an autoload, paid dependency, web service, second wallet, discovery system, or raster asset.
- Preserve NinjaSoulWallet, user://ninja_soul_wallet_v1.json, balance/debit semantics, Stage selection gate, and Workbench atomicity.
- Player-facing permanent-currency copy is exactly 각성; technical wallet identifiers remain unchanged.
- Persist only after successful Workbench commit and post-commit checkpoint capture; never serialize transient battlefield state or pending Workbench edits.
- TitleScreen must not write a file, mutate Run state, spend Awakening, select a Stage, or instantiate combat.
- Invalid resume files are unavailable but never silently deleted.
- Reuse the locked title background, wordmark, and four-part medal without creating image assets.
- New behavior is red-green tested through the project Godot console before production implementation.

---

### Task 1: Build a JSON-safe committed-checkpoint codec and durable store

**Files:**

- Create: scripts/core/run_resume_codec.gd
- Create: scripts/core/run_resume_store.gd
- Modify: scripts/data/run_modifier_set.gd
- Modify: scripts/backpack/backpack_state.gd
- Modify: scripts/core/ninjutsu_loadout_state.gd
- Modify: scripts/core/run_checkpoint.gd
- Create: tests/unit/test_run_resume_codec.gd
- Create: tests/unit/test_run_resume_store.gd
- Modify: tests/unit/test_ninja_soul_retry.gd

**Consumes:** RunBuildState.get_checkpoint_snapshot(), RunRouteState.get_route_snapshot(), RunSettlementLedger.get_snapshot(), SchoolCircuitController.get_checkpoint_snapshot(), NinjutsuLoadoutState.get_snapshot().

**Produces:**

    class_name RunResumeCodec
    const SCHEMA_VERSION := 1
    static func encode_checkpoint(checkpoint_snapshot: Dictionary) -> Dictionary
    static func decode_checkpoint(payload: Dictionary) -> Dictionary

    class_name RunResumeStore
    const STATUS_MISSING: StringName = &"missing"
    const STATUS_VALID: StringName = &"valid"
    const STATUS_INVALID: StringName = &"invalid"
    func save_checkpoint(checkpoint_snapshot: Dictionary) -> Dictionary
    func load_checkpoint() -> Dictionary
    func clear() -> bool

- [ ] **Step 1: Write failing codec tests.**

  Create test_run_resume_codec.gd with a real committed fixture containing nonzero RunModifierSet values, a placed bag/item, route clear order, ledger IDs, and starter Ninjutsu. Assert that encoded data contains only JSON primitives/arrays/dictionaries and decoded data passes existing domain restore validation after reconstruction.

      func test_codec_round_trips_a_committed_checkpoint_without_object_values() -> void:
          var codec = load(CODEC_PATH).new()
          var encoded: Dictionary = codec.encode_checkpoint(_make_checkpoint_fixture())
          assert_eq(encoded.get("schema_version"), 1)
          assert_true(_is_json_safe(encoded))
          var decoded: Dictionary = codec.decode_checkpoint(encoded)
          assert_true(decoded.get("ok", false))
          assert_true(_build.can_restore_from_checkpoint(decoded.get("checkpoint", {}).get("build", {})))

  Add independent tests for unsupported schema, duplicate/unknown IDs, missing modifier fields, invalid backpack cells, and pending loadout entries. Each must return ok false and no partial checkpoint.

- [ ] **Step 2: Verify RED.**

  Run:

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_run_resume_codec.gd -gexit

  Expected: GUT fails because run_resume_codec.gd does not exist.

- [ ] **Step 3: Implement the minimum codec boundary.**

  Add RunModifierSet.to_persistent_snapshot() and RunModifierSet.from_persistent_snapshot(snapshot) that enumerate only SUPPORTED_FIELDS and reject missing/unknown/nonnumeric fields. Add BackpackState.to_persistent_snapshot() / from_persistent_snapshot(snapshot), representing each bag/item with primitive definition ID, instance ID, origin x/y, and rotation. Preserve next_instance_id and validate every catalog ID and placement through existing legality methods.

  Add NinjutsuLoadoutState.can_restore_from_snapshot(snapshot) and restore_from_snapshot(snapshot). Validate the origin starter plus active/pending lanes against NinjutsuCatalog before emitting loadout_changed.

  Extend RunCheckpoint.capture with optional loadout_snapshot: Dictionary = {} and return loadout in get_snapshot. Existing callers with the former arity remain valid.

  Make the codec return exactly one of these shapes:

      { "schema_version": 1, "checkpoint": { "build": ..., "route": ..., "eligible_school_boss_ids": ..., "circuit": ..., "loadout": ... } }

      { "ok": true, "checkpoint": reconstructed_checkpoint }
      { "ok": false, "reason": StringName(...) }

  Decode must not return a mixed/partially reconstructed checkpoint.

- [ ] **Step 4: Verify codec GREEN.**

  Re-run the exact focused command in Step 2. Expected: all codec cases pass without parser errors.

- [ ] **Step 5: Write failing durable-store tests.**

  Create test_run_resume_store.gd using only user://gut_dec042_resume_primary.json, user://gut_dec042_resume_backup.json, and user://gut_dec042_resume_temp.json. In after_each remove only these exact paths.

  Test MISSING with no paths, valid primary round trip, corrupt primary fallback to valid backup, invalid primary with no valid backup returning INVALID, invalid source remaining on disk, and clear deleting only configured valid paths.

      func test_corrupt_primary_falls_back_to_last_known_valid_backup() -> void:
          assert_true(_store.save_checkpoint(_fixture()).get("ok", false))
          _write_text(_primary_path, "not json")
          var loaded: Dictionary = _store.load_checkpoint()
          assert_eq(loaded.get("status"), &"valid")
          assert_true(loaded.get("used_backup", false))

- [ ] **Step 6: Verify durable-store RED.**

  Run:

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_run_resume_store.gd -gexit

  Expected: GUT fails because run_resume_store.gd does not exist.

- [ ] **Step 7: Implement the durable store.**

  Implement RunResumeStore as RefCounted with test-injectable primary/backup/temp paths and production defaults user://ninja_run_resume_v1.json and user://ninja_run_resume_v1.backup.json. It encodes before writing; writes/flushed a temp file; parses and validates temp readback; preserves a valid primary as backup; then replaces primary. It tries primary then backup on load, returns explicit status, and never deletes malformed data while loading.

- [ ] **Step 8: Verify store plus existing retry regression.**

  Run:

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_run_resume_store.gd -gtest=res://tests/unit/test_ninja_soul_retry.gd -gexit

  Expected: all store cases and existing wallet/checkpoint retry tests pass.

- [ ] **Step 9: Commit the isolated persistence boundary.**

      git add scripts/core/run_resume_codec.gd scripts/core/run_resume_store.gd scripts/data/run_modifier_set.gd scripts/backpack/backpack_state.gd scripts/core/ninjutsu_loadout_state.gd scripts/core/run_checkpoint.gd tests/unit/test_run_resume_codec.gd tests/unit/test_run_resume_store.gd tests/unit/test_ninja_soul_retry.gd
      git commit -m "feat: persist committed run checkpoints safely"

### Task 2: Derive read-only enemy, Ninjutsu, and equipment Codex entries

**Files:**

- Create: scripts/ui/codex_presentation.gd
- Create: tests/unit/test_codex_presentation.gd

**Consumes:** EncounterCatalog, NinjutsuCatalog, MVP4Catalog and current definition objects.

**Produces:**

    class_name CodexPresentation
    static func build_entries() -> Dictionary
    static func category_entries(category_id: StringName) -> Array[Dictionary]

- [ ] **Step 1: Write failing Codex-presentation tests.**

  Assert the result has enemies, ninjutsu, and equipment; all current actor/ninjutsu/item/bag IDs appear once in the correct category; every entry has id, title, subtitle, and nonempty description; and building entries does not alter catalog counts or a supplied RunBuildState snapshot.

      func test_codex_entries_are_complete_read_only_views_of_current_catalogues() -> void:
          var before_items := MVP4Catalog.build_items().size()
          var entries := CodexPresentation.build_entries()
          assert_eq(entries.get("enemies", []).size(), EncounterCatalog.build_actor_definitions().size())
          assert_eq(entries.get("ninjutsu", []).size(), NinjutsuCatalog.build_definitions().size())
          assert_eq(MVP4Catalog.build_items().size(), before_items)

- [ ] **Step 2: Verify RED.**

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_codex_presentation.gd -gexit

  Expected: GUT fails because codex_presentation.gd does not exist.

- [ ] **Step 3: Implement bounded derived text.**

  Return sorted primitive dictionaries only. Derive actor descriptions from role and current patterns; derive Ninjutsu descriptions from school_id, acquisition_lane, and primitive_id; derive equipment descriptions from item/bag footprints, tags, modifiers, and combinations. Use controlled Korean labels for known data values and a safe generic Korean description for supported unknown values. Never invent lore or numbers.

- [ ] **Step 4: Verify GREEN and commit.**

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_codex_presentation.gd -gexit
      git add scripts/ui/codex_presentation.gd tests/unit/test_codex_presentation.gd
      git commit -m "feat: derive title codex entries from game catalogues"

### Task 3: Expand TitleScreen and change visible Ninja Soul copy to Awakening

**Files:**

- Modify: scenes/ui/title_screen.tscn
- Modify: scripts/ui/title_screen.gd
- Modify: scripts/ui/hud.gd
- Modify: tests/integration/test_title_screen.gd
- Modify: tests/integration/test_title_start_gate.gd
- Modify: tests/unit/test_hud_combat_surface.gd

**Produces:**

    signal new_game_requested
    signal continue_requested
    signal exit_confirmed
    func set_continue_available(available: bool, reason: String = "") -> void
    func set_awakening_balance(balance: int) -> void
    func set_codex_entries(entries_by_category: Dictionary) -> void

- [ ] **Step 1: Write failing title/HUD behavior tests.**

  Require seven menu actions: NewGameButton, ContinueButton, AwakeningButton, CodexButton, GuideButton, SettingsButton, ExitButton. Require disabled Continue reason, exactly one visible title modal, Codex default enemy selection, and focus return to the invoking control. Require title signals only—not domain mutation—and Game Over strings containing 각성 1 while rejecting former player-facing retry copy.

      func test_title_emits_continue_only_when_available_action_is_pressed() -> void:
          title.set_continue_available(true)
          watch_signals(title)
          title.continue_button.emit_signal("pressed")
          assert_signal_emitted(title, "continue_requested")

- [ ] **Step 2: Verify RED.**

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_title_screen.gd -gtest=res://tests/integration/test_title_start_gate.gd -gtest=res://tests/unit/test_hud_combat_surface.gd -gexit

  Expected: tests fail for absent nodes, signals, setters, and former retry text.

- [ ] **Step 3: Implement presentation only.**

  Add the seven actions in approved order and local overwrite/exit confirmation, Awakening, and tabbed list/detail Codex panels. Use one helper that hides competing panels, makes modal backdrop consume pointer input, and restores explicit focus. Wire new game/continue/exit to signals only. set_continue_available controls disabled/reason text; set_awakening_balance displays read-only balance; set_codex_entries populates tabs. Retain guide/settings. Replace HUD retry text with 각성 but change no wallet implementation.

- [ ] **Step 4: Verify GREEN and commit.**

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_title_screen.gd -gtest=res://tests/integration/test_title_start_gate.gd -gtest=res://tests/unit/test_hud_combat_surface.gd -gexit
      git add scenes/ui/title_screen.tscn scripts/ui/title_screen.gd scripts/ui/hud.gd tests/integration/test_title_screen.gd tests/integration/test_title_start_gate.gd tests/unit/test_hud_combat_surface.gd
      git commit -m "feat: add title actions awakening and codex panels"

### Task 4: Connect persisted committed checkpoints through MainController

**Files:**

- Modify: scripts/core/main_controller.gd
- Modify: scripts/core/school_circuit_controller.gd
- Modify: tests/integration/test_title_start_gate.gd
- Create: tests/integration/test_title_resume_main_controller.gd

**Consumes:** Task 1 codec/store, Task 2 CodexPresentation, Task 3 signals/setters, existing build/route/ledger/circuit/loadout restore validators.

- [ ] **Step 1: Write failing MainController integration tests.**

  Use an injected temporary RunResumeStore path. Cover no-record disabled Continue, valid committed checkpoint enabling Continue, valid Continue restoring build/route/backpack/loadout before title hides/combat enables, invalid data preserving visible title and disabled combat, and successful Workbench commit calling durable persistence only after _capture_run_checkpoint().

      func test_continue_restores_committed_checkpoint_before_hiding_title() -> void:
          var main := await _instantiate_main_with_resume(_valid_checkpoint())
          assert_false(main._combat_enabled)
          main.title_screen.continue_requested.emit()
          await get_tree().process_frame
          assert_true(main._combat_enabled)
          assert_false(main.title_screen.visible)
          assert_eq(main.school_circuit.route_state.active_school_id(), &"cheonsul")

- [ ] **Step 2: Verify RED.**

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_title_resume_main_controller.gd -gtest=res://tests/integration/test_title_start_gate.gd -gexit

  Expected: failure because MainController does not configure/store/resume title state.

- [ ] **Step 3: Implement MainController/circuit cold restore.**

  Create/configure one RunResumeStore in _setup_mvp3_nodes. Include ninjutsu_loadout.get_snapshot() in _capture_run_checkpoint(). Persist only after the post-commit capture point. At title setup supply real Continue availability, Awakening balance, and Codex entries.

  Add SchoolCircuitController.restore_from_persistent_checkpoint(checkpoint) that accepts decoded data only after configuration and begin_school(active_school_id) succeed, restores committed backpack, resets encounter state to Core, and emits the existing phase route. MainController validates/restores build, route, ledger, and loadout before circuit restoration. Any failure frees only new transient circuit/runtime nodes, leaves title visible, leaves combat disabled, and refreshes Continue as unavailable. Success clears stale encounter nodes, resets counters, syncs modifiers, restores player state, hides auxiliary UI, hides title, and enables combat.

  Connect new_game_requested to confirmed record clear plus existing Stage selector, continue_requested to safe restore, and exit_confirmed to get_tree().quit().

- [ ] **Step 4: Verify GREEN and commit.**

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_title_resume_main_controller.gd -gtest=res://tests/integration/test_title_start_gate.gd -gexit
      git add scripts/core/main_controller.gd scripts/core/school_circuit_controller.gd tests/integration/test_title_start_gate.gd tests/integration/test_title_resume_main_controller.gd
      git commit -m "feat: continue committed runs from title screen"

### Task 5: Record exact evidence and complete adversarial verification

**Files:**

- Modify: docs/CURRENT_CONFIRMED_DECISIONS.md
- Modify: docs/ACTIVE_CONTEXT.md
- Modify: docs/CURRENT_VISUAL_HANDOFF.md
- Create: docs/reviews/2026-09-01-dec042-title-actions-adversarial-review.md
- Modify: tests/integration/test_title_screen.gd

- [ ] **Step 1: Write failing title-document contract test.**

  Extend test_title_screen.gd to require the title handoff/decision record to name the current actions, 각성, the three Codex categories, separate locked title asset consumers, and no new raster asset.

- [ ] **Step 2: Verify RED.**

      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/integration/test_title_screen.gd -gexit

  Expected: failure while durable records lack final implementation facts.

- [ ] **Step 3: Update records and write five adversarial whole-scope loops.**

  Move DEC-042 status only as evidence permits; preserve asset SHA/provenance; document actual consumers. Review and correct only validated findings for duplicate ownership, corrupt resume safety, wallet compatibility, title focus/modal leakage, Codex truthfulness, Workbench atomicity, gameplay regression, and no-new-asset scope. Keep live-render, Human, Player Experience, device/export, balance, and release evidence NOT_RUN unless executed.

- [ ] **Step 4: Run full validation.**

      Get-PSDrive -Name C | Select-Object Used,Free
      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --import
      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --editor --headless --path . --quit
      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --scene res://scenes/main/main_scene.tscn --quit-after 300
      & 'C:\Users\user\.cache\omenward-tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
      git diff --check

  Expected: all commands exit 0, and smoke/GUT output contains no SCRIPT ERROR: or ERROR: diagnostics.

- [ ] **Step 5: Commit, push, and read exact PR head.**

      git add docs/CURRENT_CONFIRMED_DECISIONS.md docs/ACTIVE_CONTEXT.md docs/CURRENT_VISUAL_HANDOFF.md docs/reviews/2026-09-01-dec042-title-actions-adversarial-review.md tests/integration/test_title_screen.gd
      git commit -m "docs: record title action verification evidence"
      git push origin codex/dec037-runtime-migration-135
      gh pr view 135 --json headRefOid,statusCheckRollup,url

## Plan self-review

| Specification requirement | Planned task |
| --- | --- |
| Checkpoint-only durable Continue, backup/corruption safety, primitive-only storage | Task 1 and Task 4 |
| Existing wallet persistence plus player-facing Awakening vocabulary | Task 3 and Task 4 |
| Read-only derived enemy/ninjutsu/equipment Codex | Task 2 and Task 3 |
| Full title menu, modal and focus behavior, guide/settings/exit | Task 3 and Task 4 |
| No duplicate authority, autoload, asset, or cost | Global constraints and Tasks 1–4 |
| Exact automated evidence and five whole-scope reviews | Task 5 |

Placeholder scan: no incomplete requirement or unspecified validation step remains. Task 1–3 introduce every interface Task 4 consumes.
