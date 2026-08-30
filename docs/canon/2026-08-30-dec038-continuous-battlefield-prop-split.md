# DEC-038 — 연속 전장 바닥과 독립 소품 분리

> **Reference asset status:** `USER_LOCKED_PLANNING_REFERENCE_NOT_RUNTIME`
> **Derived runtime asset status:** `USER_LOCKED_IMPLEMENTED_ISOLATED_BRANCH_MACHINE_AND_SCOPED_RUNTIME_RENDER_INPUT_VERIFIED_NOT_MERGED`
> **Decision date:** 2026-08-30 KST
> **Scope owner:** `docs/visual/screen-references/README.md`
> **Human consumers:** `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md` page 10 and its exported PDF
> **Runtime status:** the planning reference itself is not a runtime asset; separately user-locked derived assets are implemented on the current isolated branch.

## User decision

The user approved the revised auto-combat in-game battle reference after asking
that the background itself be an endlessly continuing floor, while lanterns,
trees, and similar scenery are added later as small individual elements.

## Locked reference receipt

| Field | Value |
| --- | --- |
| Asset ID | `SCRREF-BATTLE-AUTOCOMBAT-03` |
| Repository source | `docs/visual/screen-references/scrref-battle-autocombat-continuous-floor-v3.png` |
| SHA-256 | `68727c87b5f81dee18f06bb0955d37314a3e0ec03f04fe9dd33f842df0dd6eac` |
| Approval | User `LOCK`, 2026-08-30 KST |
| Consumer | Human blueprint page 10 and the generated human-review PDF |
| Godot consumer | Planning-reference PNG: none. Derived floor/prop/shadow sources are bound on the current isolated branch below. |

## Visual rule

1. **Base layer:** A moonlit navy/charcoal cracked-stone floor can continue
   beyond all camera edges. It is the only background layer and keeps broad,
   uninterrupted movement lanes.
2. **Prop layer:** Paper lanterns, dead trees, rocks, shrubs, and analogous
   scenery are sparse individual props. Each requires its own transparency,
   footprint/contact shadow, and later spawn/occlusion decision; none are baked
   into the seamless background texture.
3. **Readability:** The fixed player ninja, enemies, pickups, blue-to-amber
   Cheonsul reaction, and red danger telegraph sit above the floor with clear
   contact shadows. The automatic-combat HUD remains top-only: health,
   dash-charge, elapsed-time slot, and settings; it does not add a bottom skill
   hotbar.
4. **No accidental rules:** This decision defines visual separation only. It
   does not decide prop collision, navigation obstruction, spawn density,
   rewards, encounters, or combat effects.

## Current isolated-branch runtime boundary

The planning-reference PNG above remains a human-review source only and has no
Godot consumer. Its user-locked visual contract was separately derived into
the following runtime sources on the current isolated branch:

| Runtime source | Exact consumer | State |
| --- | --- | --- |
| `assets/runtime/visual-core/moonlit_battlefield_floor_tile_v1.png` | `Main/BattlefieldBackdrop` (`Parallax2D`) → `FloorTile` | repeating continuous floor behind gameplay |
| `assets/runtime/visual-core/moonlit_battlefield_prop_atlas_v1.png` | `Main/BattlefieldProps` → lantern, dead tree, rocks, talisman stele | sparse visual-only prop layer; no collision or gameplay ownership |
| `assets/runtime/visual-core/runtime_contact_shadow_v1.png` | `Player`, `EnemyBasic`, `StageBoss` → `GroundShadow` | visual-only contact shadow at `z_index = -1` |

`assets/runtime/visual-core/moonlit_battlefield_backdrop_v1.png` remains
preserved for provenance and rollback, but is no longer the direct `Main`
consumer on this branch. The runtime assets, SHA-256 receipts, scoped Godot
render/input observation, and evidence ceiling are recorded in
`docs/assets/approved/img-02-runtime-visual-core/RUNTIME_VISUAL_CORE_MANIFEST.md`
and `docs/CURRENT_VISUAL_HANDOFF.md`.

This isolated-branch implementation has machine and scoped runtime
render/input evidence only. Human Usability, Player Experience, and
device/export remain `NOT_RUN`; merge and post-merge readback remain pending.

## External-reference disposition

- **ADOPT:** Survivor-like combat readability benefits from a continuous
  navigable arena surface where player, enemy, hazard, and build effects remain
  visually prior to scenery.
- **ADAPT:** Use the project’s own moonlit Korean ninja-fantasy stone floor,
  school colors, and SD combat hierarchy.
- **REJECT:** Copying any reference game’s props, HUD, map decoration,
  artwork, layouts, or tuning.

The linked Steam descriptions for [Halls of Torment](https://store.steampowered.com/app/2218750/Halls_of_Torment/)
and [Soulstone Survivors](https://store.steampowered.com/app/2066020/Soulstone_Survivors/Official)
were used only as genre/context references; their concrete presentation is not
an asset or UI source for this project.

## Revisit condition

Re-open this decision only when a concrete runtime consumer has an approved
scope for tiled background traversal or independent decorative props. User
visual approval alone does not prove a live Godot composition or player-facing
experience.
