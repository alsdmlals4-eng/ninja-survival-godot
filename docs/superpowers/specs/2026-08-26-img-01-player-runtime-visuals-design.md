# IMG-01 Player Runtime Visuals — Design

GitHub Issue: [#58](https://github.com/alsdmlals4-eng/ninja-survival-godot/issues/58)

## Goal and player experience

Replace the blue placeholder square with the approved fixed-ninja visual and
give the player immediate, truthful visual feedback: the Move pose establishes
identity, Attack acknowledges a successful school-owned action, and Hit makes
actual damage readable. The visual must never imply an action that gameplay did
not resolve.

## Sources and authority

Use only the approved v2 transparent sources recorded in
`docs/assets/approved/img-01-player-runtime-core/README.md`:

- `player_runtime_move_v2_alpha.png`
- `player_runtime_attack_v2_alpha.png`
- `player_runtime_hit_v2_alpha.png`

The v1 PNGs remain immutable visual provenance. The v2 source files are
1254×1254 32bpp ARGB and are local-plus-Notion dual-stored. This design does
not authorize new image generation, re-cropping, replacement, or deletion.

## Chosen approach

Use one visual-only action cue through the existing school-runtime boundary:

```text
actual successful school action
-> SchoolRuntimeBase.player_action_resolved
-> SchoolRuntimeHost.player_action_resolved
-> PlayerVisualController.show_attack()

actual non-zero player damage
-> PlayerController.damage_resolved
-> PlayerVisualController.show_hit()
```

`Player/Visual` remains the public Scene node name used by the existing scene
contract test, but changes from `Polygon2D` to `Sprite2D` and gains a small
`PlayerVisualController` script. The first line of that new GDScript must be a
short Korean role comment.

The initial reviewed display scale is `Vector2(0.05, 0.05)`. It is based on
the alpha bounds of the approved PNGs and must be checked in a live Godot view;
the collision circle remains unchanged.

## Action-cue rules

- The cue is **visual-only**. It cannot alter targeting, damage, cooldowns,
  rewards, state, collision, or route/economy authority.
- Each selected school emits one cue only after at least one intended action
  resolves non-zero gameplay damage or an equivalent confirmed school action.
- Failed target selection, zero actual damage, evasion, prevention, inactive
  schools, and disabled combat do not emit it.
- 봉마류 forwards a confirmed familiar hit through its owning runtime. This is
  still a player-owned school action, not a new generic auto-attack.
- 천술류 emits after a cast resolves at least one hit; 귀인류 after a melee pulse
  resolves at least one hit; 흑영류 after an individual needle resolves damage.
- The Host relays only its active runtime, preserving the one-selected-school
  model.

## Pose state rules

- `MOVE` is the default and returns after a temporary pose expires.
- `ATTACK` holds for a short exported duration (initial value: `0.18` seconds)
  after an action cue.
- `HIT` holds for a short exported duration (initial value: `0.16` seconds)
  only when `PlayerController.damage_resolved` reports resolved damage greater
  than zero and no evasion.
- `HIT` overrides `ATTACK`; it restarts its own hold window. No stack, queue,
  animation tree, autoload, or sprite-sheet system is introduced.
- On expiry the controller restores `MOVE`. A new `ATTACK` can restart its own
  hold only when `HIT` is not active.

## Affected surfaces

- `scenes/player/player.tscn`
- new `scripts/player/player_visual_controller.gd`
- `scripts/schools/school_runtime_base.gd`
- `scripts/schools/school_runtime_host.gd`
- the four active school-runtime paths and, for 봉마류, its familiar handoff
- focused visual/action-cue GUT tests and
  `tests/integration/test_main_scene.gd`
- `docs/CURRENT_VISUAL_HANDOFF.md`, Production Handoff, and Issue #58 evidence

## Exclusions

- Do not enable the legacy `AutoAttack` node; it is not the active school
  combat authority.
- Do not change Player movement, collision, health, damage resolution, school
  balance, enemy logic, UI, backpack, Fate, route state, or PR #49.
- Do not claim runtime verification from static/source tests alone.

## Acceptance and verification

1. The Player Scene preserves `Player/Visual` while rendering the approved
   Move v2 texture at the reviewed scale.
2. An active school emits a player visual action cue only for a real successful
   action, with no gameplay side effect.
3. Attack and Hit pose priority/reset behavior is deterministic in focused GUT
   coverage.
4. Existing gameplay tests retain their expected outcomes.
5. Exact-head CI passes Base manifest, Godot import, main-scene smoke, and full
   GUT.
6. Manual Godot review confirms Move/Attack/Hit readability, no clipping or
   opaque checkerboard, and no new errors. This human/runtime evidence is
   separate from CI and remains `NOT_RUN` until actually performed.

## Risks and revisit trigger

The approved key poses are not a sprite sheet. They are intentionally used as
brief state-feedback frames for this slice, not as continuous locomotion. If
their scale, silhouette, or repeated attack hold makes combat hard to read,
stop after evidence capture and move sprite-sheet/cropping decisions into a
separate approved art package rather than silently modifying the approved PNGs.
