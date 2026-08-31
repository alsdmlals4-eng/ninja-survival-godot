# DEC-039 군중·기본무기 adversarial review

```yaml
review_scope: DEC-039 horde, katana, shuriken, selected starter ninjutsu, player visual separation
review_state: FIVE_WHOLE_SCOPE_LOOPS_COMPLETE
superseded_in_part: NORMAL_ENEMY_CAP_18_REPLACED_BY_USER_APPROVED_UNCAPPED_HORDE_2026_08_31_KST
current_follow_up_review: docs/reviews/2026-08-31-dec039-uncapped-horde-adversarial-review.md
code_head: PRE_UNCAPPED_AMENDMENT_HISTORICAL
machine_evidence: GODOT_4_7_1_EDITOR_IMPORT_PARSE_MAIN_SMOKE_FULL_GUT_555_OF_555_6130_ASSERTS_PASS
scoped_runtime: DESKTOP_STAGE_SELECTION_TOP_HUD_HORDE_APPROACH_GAME_OVER_RENDER_OBSERVED_2026_08_31_KST
human_player_device_balance: NOT_RUN
```

## Loop 1 — random-annulus floor/cap attack

**Attack.** Try to recreate the retired four-cardinal normal spawn, underfill
the opening crowd, overshoot the normal cap, or spawn while the normal-spawn
permission is off.

**Evidence.** `WaveSpawner` owns seeded annular sampling and tags only its
normal-enemy children. `test_wave_spawner.gd` verifies exactly 10 initial
normal enemies, `420..560` distance, missing-only replacement, cap 18, disabled
no-op, timed batch and invalid-profile atomicity. `test_enemy_pressure.gd`
verifies that a killed normal returns to the floor.

**Disposition.** `CLEAN`. The only remaining `Vector2.RIGHT` positions are
intentional Elite/Boss encounter placements; normal spawning has no four-way
queue or preplaced normal children.

## Loop 2 — lifecycle ownership and normal-spawn gate attack

**Attack.** Try to make `MainController` a second normal-wave owner or let
minimum-floor restoration punch through Elite/Trace/Boss/Result/Game Over
permissions.

**Evidence.** `MainController` calls `ensure_minimum_active()` only when
combat is enabled; `SchoolCircuitController` and
`CheonsulVerticalSliceController` retain the authoritative
`normal_spawn_permission_changed` signal. Boss and Game Over paths still call
`WaveSpawner.set_spawning_enabled(false)`. Full lifecycle and stage-loop tests
pass.

**Disposition.** `CLEAN`. `WaveSpawner` remains an actuator, not a lifecycle
or reward/route owner.

## Loop 3 — basic weapon / school / modifier boundary attack

**Attack.** Try to activate multiple schools, use a school-only modifier for
a base weapon, bypass contribution accounting, or redirect the shuriken to a
legacy generic projectile.

**Evidence.** `BasicWeaponController` owns only katana cadence/nearest-three
close targets and one shuriken target. `CombatResolver.deal_basic_weapon_damage`
records actual damage without school-only fields. The projectile carries the
resolver. Unit and integration tests confirm the bound, the one selected school
runtime, and no manual-ultimate route.

**Disposition.** `CLEAN`. The two common base weapons and one selected starter
ninjutsu remain separate concurrent patterns.

## Loop 4 — stale generic attack and body-pose reentry attack

**Attack.** Search all active scripts/scenes/tests for the old generic talisman
`AutoAttack` launcher and for a school action restoring the player ATTACK pose.

**Validated finding.** The retired generic controller, scene, and its unit test
were still unreferenced but present. They could make the obsolete talisman
basic attack look supported again.

**Correction.** Deleted the inactive `AutoAttackController`, its
`projectile_basic.tscn`, and the redundant test. Kept the approved talisman PNG
only as Trace visual provenance. `PlayerVisualController` now exposes Move/Hit
only; `SchoolRuntimeHost.player_action_resolved` no longer drives a body pose.

**Regression.** Full GUT after the deletion passes `555/555`, `6130` asserts.

## Loop 5 — actual render, player-value, and evidence-ceiling attack

**Attack.** Run the exact worktree, select Stage 1 and Stage 2, inspect the
top-only HUD, floor, many-direction crowd approach, and terminal visual state.
Then test whether that limited observation can be called a balance or readable
weapon-effect pass.

**Evidence.** Desktop runtime displayed the Stage selection screen, Stage/Phase
top HUD, multiple approaching normal enemies, and Game Over overlay. In an
idle and a single short pointer-move observation, Game Over occurred at about
`PLAY 00:03`.

**Disposition.** `REVISIT_AT_PLAYER_BALANCE_GATE`, not a machine blocker. The
user-approved 10-normal random-horde rule is implemented, but this observation
does not prove a fun initial tension curve, effective continuous movement/dash
escape, or individual short-lived katana/shuriken readability. Those remain
Human/Player/balance evidence, all `NOT_RUN`.

## Clean exit

No unresolved code/canon/consumer ownership blocker remains for the DEC-039
machine package. The retained risk is explicitly a Player-balance/readability
gate, not a claim that the current numbers are tuned or release-ready.

## 2026-08-31 remediation review — Core pressure and title simplification

```yaml
review_scope: Core contact-only opening pressure and forced-overlap contact staggering; Elite/Boss special-pattern boundary; title promise removal; Guide/Settings presentation paths
review_state: FIVE_WHOLE_SCOPE_LOOPS_COMPLETE
machine_evidence: GODOT_4_7_1_EDITOR_PARSE_300_FRAME_MAIN_SMOKE_FULL_GUT_586_OF_586_6575_ASSERTS_PASS
live_render_human_player_device_balance: NOT_RUN
```

### Loop 1 — Core special-pattern re-entry attack

**Attack.** Reintroduce a `ranged` Core tag, a Core pattern definition, or a
floor/flight primitive through the four-school catalog.

**Evidence.** The 12 Core definitions now have no pattern definitions or
`ranged` tag. `test_encounter_catalog.gd` and
`test_encounter_catalog_adversarial.gd` reject any Core that violates this
contact-only boundary.

**Disposition.** `CLEAN`. The dense normal horde keeps pursuit/contact pressure
without a starting projectile, talisman or damaging floor zone.

### Loop 2 — runtime controller re-entry attack

**Attack.** Make a valid Core definition silently instantiate an
`EncounterPatternController`, execute a projectile, or retain a prior special
controller when its definition changes.

**Evidence.** `SchoolEncounterActor` clears its controller for Core definitions
and only configures the controller for Elite/Boss roles.
`test_school_encounter_actor.gd` asserts a Core has no controller and no
projectile attack.

**Disposition.** `CLEAN`. The data rule is enforced at the actual runtime
consumer boundary rather than by documentation alone.

### Loop 3 — Elite/Boss fairness regression attack

**Attack.** Simplify all roles so far that Elite/Boss lose their distinct
telegraph/recovery patterns, or allow a special pattern without a readable
warning/recovery path.

**Evidence.** Catalog validation still requires at least two Elite patterns,
three Boss patterns, and positive telegraph/recovery values. The focused
catalog/actor suites and the full GUT run preserve the line-dash, telegraphed
zone and delayed-proxy checks.

**Disposition.** `CLEAN`. Special attacks move upward to dedicated encounters;
they are not deleted from the Elite/Boss gameplay contract.

### Loop 4 — title ownership and stale-text attack

**Attack.** Keep the redundant promise label, let a secondary title button
start combat, or replace the user-locked title asset with an unapproved medal
scale candidate.

**Evidence.** `PromiseLabel` is absent. The `조작 방법` and `설정` buttons open
only their own panels before a Stage selection; `시작하기` remains the sole
Stage-selector intent. Title tests recheck the existing locked title/logo
SHA-256 values, so the smaller-medal candidate remains non-runtime until a
user `LOCK`.

**Disposition.** `CLEAN` for the implemented text/menu scope. Medal scaling is
explicitly `AWAITING_USER_LOCK`, not silently promoted.

### Loop 5 — whole-build and horde non-regression attack

**Attack.** Break uncapped horde refill, opening-hit staggering, dash,
automatic katana/shuriken/ninjutsu, title Stage gating, or parse/main startup
while applying the Core and title changes.

**Validated finding.** The initial stagger was first wired only to the retired
Core pattern-controller path, so it could not delay the Core contact attack and
the earlier two-second test could finish before a normal horde reached the
player.

**Correction and evidence.** `WaveSpawner` now assigns five `0.0` through
`1.2` second initial contact slots, and `EnemyChaser` consumes that value as
its first contact cooldown. The integration test forces all ten opening Cores
onto the Ninja, requires real damage to occur, and rejects more than two
damage resolutions in one physics frame. Godot 4.7.1 editor parse and a
300-frame headless main-scene smoke passed. The full suite passed `586/586`
tests with `6575` assertions, including `test_opening_horde_attack_rhythm.gd`,
`test_wave_spawner.gd`, dash, weapon/loadout, title and four-school circuit
coverage.

**Disposition.** `CLEAN` for automated scope. Human fairness, the new rendered
title flow, dense-horde performance and actual player balance remain separate
`NOT_RUN` gates.
