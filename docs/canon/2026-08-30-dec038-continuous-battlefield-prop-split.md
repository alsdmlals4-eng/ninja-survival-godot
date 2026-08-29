# DEC-038 — 연속 전장 바닥과 독립 소품 분리

> **Status:** `USER_LOCKED_PLANNING_REFERENCE_NOT_RUNTIME`  
> **Decision date:** 2026-08-30 KST  
> **Scope owner:** `docs/visual/screen-references/README.md`  
> **Human consumers:** `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md` page 10 and its exported PDF  
> **Runtime status:** `NOT_IMPLEMENTED`

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
| Godot consumer | None |

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

## Existing-runtime boundary

`assets/runtime/visual-core/moonlit_battlefield_backdrop_v1.png` remains the
existing opaque texture consumed by `Main/BattlefieldBackdrop`. DEC-038 does
not copy, replace, import, or bind a runtime asset. A future implementation
package must create a seamless background and transparent prop family as
separate sources, define their actual Godot consumers, and obtain source,
import, runtime-render, Human Usability, Player Experience, and relevant
device/export evidence independently.

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
