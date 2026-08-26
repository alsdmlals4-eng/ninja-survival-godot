# IMG-01 Player Runtime Core — Approved Source Record

GitHub Issue: [#56](https://github.com/alsdmlals4-eng/ninja-survival-godot/issues/56)

These three PNGs are the user-approved visual sources for the fixed player
character's Move, Attack, and Hit key poses. They are source records only:
no Godot Scene, Resource, script, or runtime binding is included here.

| Variant | File | SHA-256 | Asset Library record |
| --- | --- | --- | --- |
| Move | `player_runtime_move_v1.png` | `65eb090b47c271c22d3143aceb30537ded5ba0f6f9f24a8ea2a69f55bf20143d` | [Notion](https://app.notion.com/p/3c81b237eb1c815e9e9eeb4c8b0c2911) |
| Attack | `player_runtime_attack_v1.png` | `d6a67ce3b1e96bd1faf8b95b8c3e6cf7f3a7e6f4440b839862fa86c9367f4df2` | [Notion](https://app.notion.com/p/3c81b237eb1c81e3a121c2904209f2eb) |
| Hit | `player_runtime_hit_v1.png` | `dea069af019eacafbee8ed1ad06e9f2a840ea3bef064bcda6781942fa4653efa` | [Notion](https://app.notion.com/p/3c81b237eb1c81958819dc9e3e763587) |

## Runtime gate

All files are 1254×1254 RGB/24bpp PNGs. Their checkerboard background is
baked into the pixels; none has an alpha channel. The files are visually
approved, but are not `IMPLEMENTATION_READY` or `RUNTIME_VERIFIED`.

Before CODEX-IMG-01 can import them, create an approved transparent-background
revision, verify that alpha is present, and then perform the normal Godot
integration and runtime-validation work.
