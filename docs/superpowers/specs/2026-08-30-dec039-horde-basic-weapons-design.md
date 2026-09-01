# DEC-039 Horde and Basic Weapons Design

> **Status:** `USER_APPROVED / USER_LOCKED_ASSET / IMPLEMENTED_UNMERGED_POST_OVERRIDE_VERIFICATION_PENDING`
> **Canon owner:** `docs/canon/2026-08-30-dec039-horde-basic-weapons-and-starting-ninjutsu.md`
> **Baseline:** fresh `origin/main` `9855f9a5fa2e4297e3171a1b1903d3517719ad93`; implementation branch contains the unmerged DEC-037 dash commit.

## Goal

Make the first seconds of a selected Stage feel like survival against an approaching crowd without restoring a manual attack loop or confusing basic weapons with school techniques.

```text
select Stage
-> WaveSpawner fills 10 normal enemies around the Ninja, outside a visible approach distance
-> enemies walk inward using existing EnemyChaser behavior
-> katana close-range effect + shuriken projectile + selected starter ninjutsu resolve automatically
-> kills open the existing reward / Elite / Trace / Boss lifecycle
```

## Technical design

### WaveSpawner remains the sole normal-spawn owner

`WaveSpawner` gains these exported, scene-authored pressure fields:

| field | initial value | meaning |
| --- | ---: | --- |
| `minimum_active_enemies` | `10` | strict normal-enemy floor while spawning is enabled |
| `batch_size` | `3` | normal timed reinforcement size |
| `wave_interval` | `1.0 s` | reinforcement cadence |
| `minimum_spawn_distance` | `420 px` | annulus inner edge around current player position |
| `maximum_spawn_distance` | `560 px` | annulus outer edge |

`ensure_minimum_active()` fills only the shortfall up to the 10-enemy floor. It is called immediately after combat selection and on subsequent process frames while normal spawning is enabled. Scheduled `spawn_wave()` adds `batch_size` every interval with **no normal-enemy maximum cap**, until an existing lifecycle owner disables normal spawning. Each spawn samples `angle = randf_range(0, TAU)` and `distance = randf_range(minimum, maximum)`; there is no cardinal direction list or four-enemy scene preload.

The random generator stays owned by `WaveSpawner`, and test fixtures set its seed through a narrow test-visible configuration method. The method validates positive interval, `minimum active >= 0`, and `0 < minimum distance <= maximum distance`; invalid profiles fail closed without partial mutation.

### Three concurrent automatic attack patterns

`BasicWeaponController` replaces the disabled generic `AutoAttack` consumer.

| pattern | owner | initial cadence/range | damage route | render |
| --- | --- | --- | --- | --- |
| katana | `BasicWeaponController` | `0.65 s`, closest three valid enemies in `112 px` | `CombatResolver.deal_basic_weapon_damage` | left atlas region, short effect-only Sprite |
| shuriken | `BasicWeaponController` + `BasicProjectile` | `0.75 s`, one closest valid target | resolver carried by `ShurikenProjectile` | right atlas region, moving sprite |
| starter ninjutsu | selected `SchoolRuntimeBase` subclass | existing cadence/range | existing `deal_school_damage` | existing school-owned visuals |

The exact 3-target katana cap is an initial bounded crowd-clear primitive, not an unlocked multi-sword weapon or a generic school attack. The existing selected-school runtime remains one exact active child; selection never activates a second school technique.

`BasicProjectile.configure()` accepts an optional `CombatResolver` and uses it when present. Existing users without a resolver remain backwards-compatible direct damage users until separately migrated. `CombatResolver.deal_basic_weapon_damage()` validates targets, records actual HP loss in the existing contribution tracker, and deliberately does not apply school-only modifier fields.

`MainController` configures the basic controller with the resolver and toggles it together with combat. It never moves weapon cadence or damage calculations into the UI.

### Visual behavior

`PlayerVisualController` has only `MOVE` and `HIT`. `SchoolRuntimeHost.player_action_resolved` remains a runtime signal but is no longer connected to `PlayerVisualController`. The player scene removes only the attack texture property/reference; it keeps the approved source file unmodified on disk. The separate weapon visuals make automatic damage readable without pretending the player manually inputs each attack.

## Explicit exclusions

- No manual attacks, aiming reticle, skill buttons, player attack animation, or automatic ultimate input.
- No new `RunModifierSet` field, generic weapon item, scroll inventory, scroll choice UX, scroll rarity, or scroll combination system.
- No second wave owner, deterministic cardinal spawn queue, direct Main-controlled normal spawn loop, or random spawning while Boss/Result/Workbench blocks normal spawns. The user-approved uncapped normal count is intentional; lifecycle gates, observed performance, and Player balance remain separate concerns.
- No Human/Player/balance/device claim from automated or scoped live observation.

## Feasibility and rollback

The package reuses the existing Godot 4.x `Node`/`Area2D`/`Sprite2D`/`RandomNumberGenerator` stack, `WaveSpawner`, `EnemyChaser`, `CombatResolver`, automatic `SchoolRuntimeHost`, and current contact shadows. The only new bitmap is user-locked and repository-local. Reverting the package restores the prior scene/script consumers and does not change route, save, Backpack, Fate, economy, or checkpoint schemas.

The user-defined Japanese katana/shuriken identity is product authority. The repeat targeted benchmark confirms the broader auto-survivor horde pattern but does not prescribe this game's weapon names, count, art, or tuning; no material external evidence is used to override the user decision.
