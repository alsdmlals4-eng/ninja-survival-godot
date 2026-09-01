# DEC-039 Horde and Basic Weapons Implementation Plan

> **For the executing agent:** execute task by task in this isolated worktree. Use test-first changes, retain unrelated dirty artifacts, and do not move or modify historical PR #49.

**Goal:** Replace cardinal low-density normal spawns with uncapped random annular horde pressure, implement automatic katana/shuriken alongside the selected starter ninjutsu, and make weapon effects—not a player attack pose—express attacks.

**Architecture:** `WaveSpawner` is still the only normal-enemy source. `BasicWeaponController` is the only base-weapon cadence/targeting owner. `CombatResolver` records all base-weapon damage. `SchoolRuntimeHost` still selects exactly one existing school runtime. Player visual code only renders move/hit.

**Tech Stack:** Godot 4.7.1, GDScript, GUT, existing scene/resources, user-locked transparent PNG atlas.

---

## Task 1: Random annular horde ownership in WaveSpawner

**Files:**
- Modify: `scripts/spawning/wave_spawner.gd`
- Modify: `scenes/main/main_scene.tscn`
- Modify: `scripts/core/main_controller.gd`
- Modify: `tests/unit/test_wave_spawner.gd`
- Modify: `tests/integration/test_mvp2_four_schools.gd`

1. Add RED tests: a valid 10-floor profile fills exactly 10 on selection; every spawn sits inside the configured annulus; no test assumes four cardinal directions; disabled spawners stay empty; timed batches continue beyond the minimum without a maximum cap; invalid profile values do not partially mutate active values.
2. Run the focused WaveSpawner/MVP2 suite and confirm the cardinal implementation fails the new floor/annulus expectation.
3. Implement a seeded `RandomNumberGenerator`, profile validation, random annular location helper, strict `ensure_minimum_active()`, and scheduled uncapped `spawn_wave()`. Delete the four-direction constant and remove the four preplaced cardinal enemy scene instances. Call the floor fill only after normal combat becomes enabled.
4. Re-run the focused suite and inspect that Boss/Result normal-spawn blocks still use `set_spawning_enabled(false)`.

## Task 2: Base weapon damage boundary and visual consumers

**Files:**
- Add: `scripts/combat/basic_weapon_controller.gd`
- Modify: `scripts/combat/combat_resolver.gd`
- Modify: `scripts/combat/projectile.gd`
- Add: `scenes/projectiles/shuriken_projectile.tscn`
- Modify: `scenes/player/player.tscn`
- Modify: `scripts/core/main_controller.gd`
- Modify: `tests/unit/test_combat_resolver.gd`
- Add/Modify: `tests/unit/test_basic_weapon_controller.gd`, `tests/unit/test_projectile.gd`
- Modify: `tests/integration/test_main_scene.gd`, `tests/integration/test_mvp2_four_schools.gd`, `tests/integration/test_mvp3_stage_loop.gd`, `tests/unit/test_script_contracts.gd`

1. Add RED tests for a basic damage contribution entry, katana selection limited to three valid close enemies, shuriken target/direction, resolver propagation through a projectile, and inactive base weapons before Stage selection.
2. Implement `CombatResolver.deal_basic_weapon_damage()` without silently applying school-only modifiers. Extend projectile configuration with optional resolver support while preserving callers without it.
3. Implement independent katana and shuriken timers in `BasicWeaponController`; use only the locked atlas for a short katana effect and a region-clipped Shuriken projectile visual. Configure it from `MainController`, enable it only during combat, and prove all four selections activate the base controller plus exactly one school runtime.
4. Run changed unit/integration tests and review every damage path for direct player/UI ownership leakage.

## Task 3: Remove the player attack pose without removing approved history

**Files:**
- Modify: `scripts/player/player_visual_controller.gd`
- Modify: `scenes/player/player.tscn`
- Modify: `scripts/core/main_controller.gd`
- Modify: `tests/unit/test_player_visual_controller.gd`
- Modify: `tests/integration/test_main_scene.gd`

1. Add RED test: school action signal does not change the player out of `MOVE`, while resolved non-evaded damage still shows `HIT` and returns to `MOVE`.
2. Remove the ATTACK pose/property/connection and replace the player child with the explicit basic-weapon controller. Keep the former approved PNG file untouched and make no asset deletion.
3. Verify the main scene owns `BasicWeapons`, shuriken uses the locked right atlas region, and the player has no attack-texture property.

## Task 4: Asset provenance and current state records

**Files:**
- Modify: `docs/assets/approved/img-02-runtime-visual-core/RUNTIME_VISUAL_CORE_MANIFEST.md`
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Modify: `docs/ACTIVE_CONTEXT.md`

1. Record the copied PNG source, exact SHA-256, RGBA dimensions, user lock, and real consumers only after the scene/script bindings are present.
2. Record the implementation truth, benchmark disposition, exact test/runtime evidence, and unverified Human/Player/device/balance boundaries. Do not promote a generated/locked asset to merge or runtime evidence before those checks occur.

## Task 5: Verification, adversarial review, and delivery preparation

1. Run Godot import/editor parse, headless main-scene smoke, changed focused GUT suites, and full GUT on the exact head. Preserve the actual test/assertion counts.
2. Launch the exact worktree in the live editor and observe: post-selection 10+ random-distance enemies approach, katana/shuriken effects appear independently of player pose, starter ninjutsu is active, normal-spawn blocks during Boss/Result, and dash still avoids active-window damage.
3. Run at least five whole-scope adversarial loops: spawn ownership/caps, annulus safety and timing, weapon-versus-school separation, modifier/contribution ownership, visual/readability/no-attack-pose, and regression/rollback. Validate every finding before fixing it and re-run affected checks.
4. Inspect the exact tracked diff, request required review, commit only intended paths, and prepare a fresh PR. Do not claim merge, Human Usability, Player Experience, balance, device/export, or release until separately evidenced.

## Acceptance checklist

- [x] no cardinal spawn queue or four preplaced normal enemies remain;
- [x] combat selection immediately establishes at least 10 normal enemies inside a random annulus, and timed reinforcement continues with no normal-enemy maximum cap;
- [x] katana, shuriken, and exactly one selected-school starter ninjutsu all run automatically;
- [x] basic weapon damage is routed through `CombatResolver` and contribution tracking;
- [x] weapon/effect sprites are separate from the player move/hit sprite, which has no attack pose;
- [x] locked asset provenance and real consumers are repository-recorded;
- [x] exact automated and scoped runtime evidence are recorded separately from `NOT_RUN` Human/Player/device/balance evidence.
