# P0 Screen Design References

GitHub Issue #98의 화면 우선 시각 커버리지 자료다. 이 PNG들은
**제작·기획 시각자료**이며, runtime texture나 이미 승인된 runtime asset의
교체본이 아니다. 모든 게임 내 문구와 동적 수치는 Godot Control/Label에서
계속 렌더해야 한다.

| ID | Target screen(s) | Local source | SHA-256 | Status |
| --- | --- | --- | --- | --- |
| `SCRREF-SCHOOL-SELECT-01` | `SCR-SCHOOL-SELECT` | `scrref-school-select-v1.png` | `b4e00a058888b3b1a86094bb10cac51d508a426cb0c5b3477663bb15cfcf1665` | `REFERENCE_READY_LOCAL` |
| `SCRREF-BATTLE-CHEONSUL-01` | `SCR-BATTLE-CHEONSUL` | `scrref-battle-cheonsul-v1.png` | `11b6e60e388488940893e00d502b6fbe5d578ea097a9c585b92ae2162680be73` | `REFERENCE_READY_LOCAL` |
| `SCRREF-WORKBENCH-01` | `SCR-ROUTE-WORKBENCH`, `SCR-FATE`, `SCR-NEXT-PREVIEW` | `scrref-workbench-v1.png` | `942171e15f9d151840179af19af4217bb73ea542e21456d6c2f1d25fb4f35193` | `REFERENCE_READY_LOCAL` |
| `SCRREF-RESULT-01` | `SCR-RESULT` | `scrref-result-v1.png` | `1190161d06d1e91a6b28d04c450dfaae9b563d4736ad3e74bb2cb51adcabaf58` | `REFERENCE_READY_LOCAL` |
| `SCRREF-GAME-OVER-01` | `SCR-GAME-OVER` | `scrref-game-over-v1.png` | `efbf4b08a396b7b20a218a5237a63a945a7d153d8bfa5d24161a92a2d47e5cf0` | `REFERENCE_READY_LOCAL` |

All five files are 1672×941 PNGs. They were generated with the built-in image
generation tool on 2026-08-28, visually inspected, and checked against the
approved moonlit painterly/ink, one-ninja-identity, readable-combat direction.

## Usage boundary

- `SCRREF-BATTLE-CHEONSUL-01` guides visual hierarchy only: open combat center,
  readable player/enemy/hazard hierarchy, and bounded HUD zones.
- `SCRREF-SCHOOL-SELECT-01` guides the four equal school-choice cards only; it
  does not create four player protagonists.
- `SCRREF-WORKBENCH-01` guides information order only: reward → backpack →
  route/Fate → commit. It does not add a new backpack UI implementation.
- `SCRREF-RESULT-01` and `SCRREF-GAME-OVER-01` guide outcome/retry hierarchy;
  their abstract glyphs are not in-game text or icon assets.
- No image in this folder is connected to a Godot runtime consumer yet. This is
  intentional: a design reference must not be silently promoted as a texture.

## Evidence boundary

Repository-local binary storage is complete. Notion native original-binary
attachment is required before the set can be called dual-stored; the state is
recorded in Notion after attachment destination readback. Neither generated
reference proves live Godot composition, Human Usability, Player Experience,
or device/export validation.
