# PR #135 Current-Main Reconciliation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconcile the user-approved PR #135 runtime package onto current `main` without modifying its owner branch, while preserving the merged screen Blueprint and protected game-state owners.

**Architecture:** A new branch starts at `origin/main` `7b94efa90ec8c577edf0317163c4cf6b30a32531`. The PR #135 exact head `d65a712d441d3ca854ee8ae2edff468bb4974983` is a read-only, user-authorized source of material deltas, not the new canonical baseline. Reconciliation retains current-main Blueprint/contract files, uses the existing Godot CanvasLayer/Control and GUT stack, and preserves MainController, RunBuildState, Workbench, Fate, route, and existing save ownership boundaries.

**Tech Stack:** Godot 4.7.1 CI pin / Godot 4.7.x, GDScript, GUT 9.7.1, Git protected PR flow, existing approved repository raster assets.

**Spec:** `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`; user-approved read-only source specifications at PR #135 `docs/superpowers/specs/2026-08-30-dec037-runtime-migration-design.md`, `2026-08-30-dec039-horde-basic-weapons-design.md`, `2026-08-31-dec040-four-school-encounter-and-ninjutsu-design.md`, and `2026-09-01-dec042-title-actions-awakening-codex-design.md`.

## Global Constraints

- The user explicitly authorized PR #135 package handoff, reconciliation, validation, and protected integration on 2026-09-01 KST; retain the owner PR and branch unchanged.
- Preserve current `NS-BLUEPRINT-001`, the project work contract, protected 3×3 initial usable board/6×6 technical outer board, Workbench/Fate atomic boundary, existing economy/route authority, and fixed-ninja identity.
- Preserve normal Core enemies as pursuit/contact pressure only; no opening normal projectile, talisman, or floor-zone spam. Elite/Boss actors alone own telegraphed patterns.
- Normal battle HUD stays top-only: health, Dash charges, elapsed time, and settings/pause. No manual-attack button or lower skill tray.
- Reuse existing floor/prop/player visual assets and only adopt a PR #135 raster if its SHA-256, source, approval, actual consumer, and manifest entry are consistent. Do not generate a new image in this package.
- Use Godot built-in CanvasLayer/Control/Container nodes. Do not add a third-party UI/gameplay addon, second wave system, new autoload, or a second persistent save/meta authority.
- CI remains pinned to Godot 4.7.1 and GUT 9.7.1. The newer official 4.7.2 maintenance release is observed but is not a silent project upgrade.
- All persistent Godot Scene/Script/Resource/project mutations run only through the connected HiGodot authoring authority once a Ninja Survival session is verified. Hera is live QA/observability only and must never target another project.
- Runtime render, Human Usability, Player Experience, device/export, and release evidence are distinct and remain `NOT_RUN` until actually observed.

---

### Task 1: Lock the current-main reconciliation boundary with a failing test

**Files:**
- Create: `tests/integration/test_pr135_reconciliation_contract.gd`
- Create: `docs/operations/receipts/2026-09-01-pr135-current-main-reconciliation-preflight.json`
- Create: this plan

**Interfaces:**
- Consumes: current-main Blueprint, current `Main` scene, read-only PR #135 exact head.
- Produces: one test-owned statement that the current branch must expose the title, automatic-combat, and dedicated encounter runtime consumers without deleting the Blueprint owner.

- [x] **Step 1: Write the failing current-main surface test**

```gdscript
extends GutTest

func test_reconciled_runtime_exposes_user_approved_front_door_and_auto_combat_consumers() -> void:
	assert_true(ResourceLoader.exists("res://scenes/ui/title_screen.tscn"))
	assert_true(ResourceLoader.exists("res://scripts/combat/basic_weapon_controller.gd"))
	assert_true(ResourceLoader.exists("res://scripts/enemies/school_encounter_actor.gd"))
	assert_true(ResourceLoader.exists("res://scripts/core/ninjutsu_loadout_state.gd"))
	assert_true(FileAccess.file_exists("res://docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md"))
```

- [x] **Step 2: Run the focused test before importing production delta**

Run: Godot 4.7.1 headless GUT for `test_pr135_reconciliation_contract.gd`.

Expected: failure because title/weapon/encounter/loadout resources do not yet exist on exact current `main`; Blueprint resource assertion stays true.

- [x] **Step 3: Record the expected failure as TDD evidence**

Record the focused run output and retain the test unchanged until the reconciled runtime exists.

### Task 2: Apply the approved PR #135 material to the new current-main integration branch

**Files:**
- Modify: current runtime source/scene/test/data paths selected from PR #135 only.
- Preserve: `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`, `docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md`, current Blueprint review/spec/plan, and all unrelated current-main paths.

**Interfaces:**
- Consumes: Task 1 test, read-only PR #135 `d65a712…`, current `MainController`, `WaveSpawner`, `HUDController`, `SchoolCircuitController`, catalog, Scene, and save owners.
- Produces: three automatic starting patterns (katana, shuriken, selected starter ninjutsu), invulnerable Dash, uncapped lifecycle-gated normal horde, four-school Core/Elite/Boss composition, Title/Continue/Awakening/Codex front door, and top-only battle HUD.

- [x] **Step 1: Apply the read-only source delta without touching the owner branch**

Use a no-commit merge from exact head `d65a712…` in this branch only. Resolve each conflict by keeping current-main authority unless the source delta is necessary for the approved behavior. Do not rebase, force-push, close, or edit PR #135.

- [x] **Step 2: Preserve current-main documentation and ownership protections**

Verify these paths remain present after the merge operation:

```powershell
Test-Path docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md
Test-Path docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md
git diff --name-status origin/main...HEAD
```

Expected: no deletion of the merged Blueprint, its plan/spec/review, project work contract, or unrelated owner paths.

- [x] **Step 3: Make only reconciliation corrections exposed by current-main conflicts**

Resolve the known `ACTIVE_CONTEXT.md` conflict as a mutable router update, retain current Blueprint state, and only add PR #135 implementation state after tests and asset integrity prove it. Keep `MainController` as durable transition owner, `TitleScreen` as presentation owner, and existing Workbench/Fate/route authority singular.

- [x] **Step 4: Save and inspect the exact source diff**

Use HiGodot readback for affected Scene/Script resources, then inspect:

```powershell
git diff --check
git status --short
```

Expected: only the user-approved runtime package, its tests/provenance/docs, and this reconciliation record differ from current main.

### Task 3: Prove automatic-combat, horde, and encounter behavior from focused tests

**Files:**
- Test: `tests/integration/test_player_dash_runtime.gd`
- Test: `tests/integration/test_opening_horde_attack_rhythm.gd`
- Test: `tests/unit/test_basic_weapon_controller.gd`
- Test: `tests/integration/test_four_school_battle_contract.gd`
- Test: `tests/unit/test_school_encounter_actor.gd`
- Test: `tests/unit/test_ninjutsu_loadout_state.gd`

**Interfaces:**
- Consumes: Task 2 source/scene integration.
- Produces: focused evidence that Dash is invulnerable evasion, normal enemies begin as dense contact pressure, the player begins with katana/shuriken/one ninjutsu, and Elite/Boss have dedicated telegraphed actor paths.

- [x] **Step 1: Run each focused suite individually**

Run each listed suite through GUT 9.7.1 after import. Do not replace a failing behavior assertion with a looser string/path assertion.

- [x] **Step 2: Correct only validated integration defects**

For each failure, identify the owner (player, WaveSpawner, weapon, Ninjutsu loadout, encounter actor, or UI presentation), write a narrow regression test before the correction if the failure is not already covered, then implement via HiGodot and rerun the focused suite.

- [x] **Step 3: Re-run the Task 1 reconciliation test**

Expected: the resource/owner boundary test becomes green without deleting `NS-BLUEPRINT-001`.

### Task 4: Prove title, HUD, asset, and persistence consumer integrity

**Files:**
- Test: `tests/integration/test_title_screen.gd`
- Test: `tests/integration/test_main_title_resume_flow.gd`
- Test: `tests/integration/test_title_actions.gd`
- Test: `tests/unit/test_codex_presentation.gd`
- Test: `tests/unit/test_encounter_asset_manifest.gd`
- Test: `tests/unit/test_hud_combat_surface.gd`
- Modify: exact current owner manifests/context only when test-backed implementation facts differ.

**Interfaces:**
- Consumes: Task 2 front-door/HUD/assets and existing wallet/checkpoint/catalog owners.
- Produces: correct wordmark plus separate medal title composition, New/Continue/Awakening/Codex actions, compact top HUD, and manifest-to-consumer integrity.

- [x] **Step 1: Run title/HUD/asset-focused suites**

Run the listed tests using GUT 9.7.1. Validate that no bottom skill tray/manual attack surface is introduced and `각성` remains player-facing copy while the internal wallet identifier preserves compatibility.

- [x] **Step 2: Read asset hashes from disk and manifest**

Compute SHA-256 for every adopted PR #135 PNG and compare each one with the current manifest/test source. A mismatch is a blocker: preserve the candidate and do not claim it is registered/implemented.

- [x] **Step 3: Keep evidence ceilings accurate**

Update `ACTIVE_CONTEXT`, visual handoff, and manifest only after exact source/test evidence. Keep render/Human/device/release facts as `NOT_RUN` unless directly executed later in this plan.

### Task 5: Complete machine, runtime, adversarial, and protected integration gates

**Files:**
- Create: one current-main reconciliation adversarial review record only after final code/test candidate exists.
- Modify: `docs/ACTIVE_CONTEXT.md` and relevant owner records only for verified outcome/state routing.

**Interfaces:**
- Consumes: Tasks 1–4 final candidate.
- Produces: exact-head PR, CI evidence, merge/readback, task-owned cache cleanup, and accurate remaining-gate report.

- [x] **Step 1: Run static/import/runtime machine gates**

Run `git diff --check`, Godot 4.7.1 import, headless main-scene smoke, full GUT, and the repository Windows internal build CI path. Treat missing renderer/session evidence as `NOT_RUN` rather than PASS.

- [x] **Step 2: Run Ninja Survival live QA only in a verified HiGodot session**

Before live run, prove the connected session project path equals this isolated worktree and record a source-delta fingerprint. Run normal title → Stage selection → Core pressure input paths, collect runtime UI/scene/diagnostic evidence and a screenshot if the game is rendered, then confirm source delta is unchanged during QA. If no Ninja session is available, defer only live QA; do not use a different project session.

- [x] **Step 3: Perform five whole-scope adversarial loops**

Attack and validate: authority/document loss, normal-core early-hazard regression, Dash/weapon pattern regression, title/checkpoint/wallet ownership drift, asset/provenance/consumer drift, GUT/import/runtime evidence overclaim, and stale-main/owner-PR divergence. Fix only validated findings, rerun affected checks, and continue until no blocker remains.

- [x] **Step 4: Commit, push, and open a protected current-main PR**

Commit the reconciled delta. Push without force. Open a new PR that declares the exact absorbed-owner source, retained owner docs, full verification results, evidence ceiling, and rollback. Check all required checks at that PR's exact head.

- [x] **Step 5: Merge only after exact-head safety checks, then read back new main**

Confirm no unresolved review thread, no P0/P1 finding, required checks are successful at exact head, and repository protections permit merge. Merge without bypass, fetch the new main, confirm the exact files/manifest/Blueprint state, clean task-owned temporary GUT/import caches, and recalculate remaining in-scope work.
