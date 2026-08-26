# IMG-01 Player Runtime Core — Approved Source Record

GitHub Issue: [#56](https://github.com/alsdmlals4-eng/ninja-survival-godot/issues/56)

These three PNGs are the user-approved visual sources for the fixed player
character's Move, Attack, and Hit key poses. Version 1 is the immutable
visual-provenance original. Version 2 is the user-approved alpha-remediated
derivative. No Godot Scene, Resource, script, or runtime binding is included
here.

| Variant | File | SHA-256 | Asset Library record |
| --- | --- | --- | --- |
| Move | `player_runtime_move_v1.png` | `65eb090b47c271c22d3143aceb30537ded5ba0f6f9f24a8ea2a69f55bf20143d` | [Notion](https://app.notion.com/p/3c81b237eb1c815e9e9eeb4c8b0c2911) |
| Attack | `player_runtime_attack_v1.png` | `d6a67ce3b1e96bd1faf8b95b8c3e6cf7f3a7e6f4440b839862fa86c9367f4df2` | [Notion](https://app.notion.com/p/3c81b237eb1c81e3a121c2904209f2eb) |
| Hit | `player_runtime_hit_v1.png` | `dea069af019eacafbee8ed1ad06e9f2a840ea3bef064bcda6781942fa4653efa` | [Notion](https://app.notion.com/p/3c81b237eb1c81958819dc9e3e763587) |

## Approved transparent derivatives — v2

The v2 files preserve the approved v1 compositions and convert the baked
near-neutral checkerboard background to alpha. Each was inspected as a
1254×1254 32bpp ARGB PNG with a transparent corner, and its exact binary is
also attached to the corresponding Notion Asset Library record.

| Variant | File | SHA-256 | Drive transport/backup |
| --- | --- | --- | --- |
| Move | `player_runtime_move_v2_alpha.png` | `a56f79918bd9ebe451cbca092cb9828c512a710c1762600a070eeba68e01fb2a` | [Drive](https://drive.google.com/file/d/1QV0xI1Si6EZWnmJcNgHnVNqTi4P1Ycz-/view?usp=drivesdk) |
| Attack | `player_runtime_attack_v2_alpha.png` | `75c6d31237ebf8cd1760c89d90d2a85ebae5c2802cb615816b1be8fb7f7836cd` | [Drive](https://drive.google.com/file/d/1r_4P05Y-J0vWLOgezPUcq2LnUKg-i3R_/view?usp=drivesdk) |
| Hit | `player_runtime_hit_v2_alpha.png` | `f00c2f6fd09e6c52e1dce8abe6f493e76245d2dbc818ee4ac5db1b98f5b23d60` | [Drive](https://drive.google.com/file/d/1slTo4i3EglNuieVw4yWDz_1-qpm6Bwek/view?usp=drivesdk) |

## Runtime gate

The v1 originals are 1254×1254 RGB/24bpp PNGs with checkerboard baked into
the pixels. The v2 derivatives have real alpha and meet the source-level
transparent-background requirement. They remain source records, not evidence
of a Godot import or of runtime behavior.

IMG-01 wiring is currently in unmerged [PR #59](https://github.com/alsdmlals4-eng/ninja-survival-godot/pull/59)
at `394c0e3592495a3834e64ee32d51d13a34add914`. It imports only the v2
derivatives, wires the intended `Player/Visual` consumer, and has exact-head
Godot 4.7.1 import, main-scene smoke, and full GUT evidence in
[workflow 32969670717](https://github.com/alsdmlals4-eng/ninja-survival-godot/actions/runs/32969670717).

This is not live runtime evidence. `RUNTIME_VERIFIED`, Human Usability,
Player Experience, device, and export remain **NOT_RUN** until the Ninja
Survival editor and game are observed. Preserve v1 in both storage systems as
provenance; do not replace or delete it.
