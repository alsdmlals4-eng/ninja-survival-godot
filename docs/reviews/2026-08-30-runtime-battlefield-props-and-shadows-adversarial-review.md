# Runtime Battlefield Props and Ground Shadows — Adversarial Review

> Date: 2026-08-30 KST
> Scope: user-locked `NINJA_RUNTIME_BATTLEFIELD_PROP_ATLAS_01` and
> `NINJA_RUNTIME_CONTACT_SHADOW_01` only. The already-locked repeated floor
> tile remains its own prior scope.

## Approved boundary

- Add four sparse, non-colliding environment props above the repeated floor
  and below all gameplay units.
- Add one visual-only contact shadow source to Player, EnemyBasic, and
  StageBoss scenes; keep their existing visual scripts and all game rules.
- Do not add a spawner, collision geometry, terrain rule, gameplay stat,
  asset variant, UI control, or new persistent state.

## Five full-scope adversarial loops

| Loop | Attack | Validated correction / retained decision | Evidence |
| --- | --- | --- | --- |
| 1 | Could approved candidates be copied under the wrong identity or without provenance? | Copied only the two user-locked sources, recorded exact SHA-256, dimensions/alpha, owner, and consumer. | Manifest readback and hash checks match `0fff1d…4f98` and `fbba12…5458`. |
| 2 | Could scenery become a finite baked background or cover units? | Added `Main/BattlefieldProps` as a separate `Parallax2D`, matching the floor repeat size; set `z_index = -5` between floor `-10` and units `0`. | Focused Main test asserts repeat, order, four exact children, regions, and atlas source. |
| 3 | Could linear/mipmapped atlas sampling bleed a neighboring prop into a selected quadrant, include all four props at once, collide, or acquire hidden game authority? | Each Sprite2D selects one deterministic quadrant and sets `region_filter_clip_enabled = true`; no prop has a script, collider, or gameplay node. | Review P1 RED: four clip assertions failed; corrected focused test passes and scene/fixture inspection confirms the boundary. |
| 4 | Could shadows draw over faces or affect physics / auto-combat? | Added only `GroundShadow` Sprite2D children at relative `z_index = -1`; movement, collision masks, scripts, and visual controllers stay untouched. | Focused test checks Player, EnemyBasic, and StageBoss source/ordering; full GUT passes. |
| 5 | Could a partial check conceal regression in the larger four-school circuit? | A pre-existing MVP-3 fixture used randomized rewards while assuming every item fit the start board; fixed the fixture RNG to a reproducible seed without changing production randomness, then reran the complete suite. | Fixture 3 consecutive passes; GUT 9.7.1: 67 scripts, 523/523 tests, 5832 assertions, zero failures. |

## Evidence ceiling

- Godot 4.7.1 import/parse: pass.
- Headless runtime-source harness: pass after the expected pre-implementation
  resource failure.
- Focused Main scene test: 13/13 tests, 176 assertions: pass.
- Existing MVP-3 workbench/orb fixture: 5/5 tests, 87 assertions, three
  consecutive runs: pass after its test-only fixed RNG seed.
- Full GUT: 523/523 tests, 5832 assertions: pass.
- `hera status` found only an editor for `Switchy Express: Cargo Puzzle`;
  Ninja Survival live render/input, Human Usability, Player Experience, and
  device/export are **NOT_RUN**.

## Result and next safe work

Both assets are `USER_LOCKED`, repository-owned, and implemented only on the
current isolated branch. The package is machine verified but not merged. The
next safe work is an exact Ninja Survival live-editor render check before any
claim about final composition, player readability, or device quality.
