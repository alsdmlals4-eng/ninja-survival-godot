# P0 Screen Design References

GitHub Issue #98의 화면 우선 시각 커버리지 자료다. v1은 병합 전
**REJECTED** 되었다. 포스터형 성인 비율과 사선 전장 구도가 실제 탑뷰
뱀서라이크·SD 캐릭터 정본과 어긋났기 때문이다. 아래 v2만 현재 유효하다.
이 PNG들은
**제작·기획 시각자료**이며, runtime texture나 이미 승인된 runtime asset의
교체본이 아니다. 모든 게임 내 문구와 동적 수치는 Godot Control/Label에서
계속 렌더해야 한다.

| ID | Target screen(s) | Local source | SHA-256 | Status |
| --- | --- | --- | --- | --- |
| `SCRREF-SCHOOL-SELECT-02` | `SCR-SCHOOL-SELECT` | `scrref-school-select-v2-sd.png` | `8dd2a751b230c0b74104a59daa1cfee933c4b0c57ecdc10dc90de22b20d0f24b` | `LOCAL_REVIEWED_NOTION_PENDING` |
| `SCRREF-BATTLE-CHEONSUL-02` | `SCR-BATTLE-CHEONSUL` | `scrref-battle-cheonsul-v2-topdown-sd.png` | `0d179dce4108043c251cb51d88c554493e1a9e90a5fab3bb5b91b8ab41afa61d` | `LOCAL_REVIEWED_NOTION_PENDING` |
| `SCRREF-WORKBENCH-02` | `SCR-ROUTE-WORKBENCH`, `SCR-FATE`, `SCR-NEXT-PREVIEW` | `scrref-workbench-v2-sd.png` | `dd3b90ed11b242d3f09de4748f65d0a12ff44f8eede0eba7b4e013c22d3cf9a8` | `LOCAL_REVIEWED_NOTION_PENDING` |
| `SCRREF-RESULT-02` | `SCR-RESULT` | `scrref-result-v2-sd.png` | `d125a2e04c467baff7450d98b28b8325b425140fd6b7406ee6d540d8b65330e4` | `LOCAL_REVIEWED_NOTION_PENDING` |
| `SCRREF-GAME-OVER-02` | `SCR-GAME-OVER` | `scrref-game-over-v2-topdown-sd.png` | `00382fe0e3a649b3594e2e78eae500ef4354ecd616b9502f5d29c7da1de07ca7` | `LOCAL_REVIEWED_NOTION_PENDING` |

All five files are 1672×941 PNGs. They were generated with the built-in image
generation tool on 2026-08-28, visually inspected, and checked against the
supplied SD style sheet: top-down survival readability, one-ninja identity,
black/deep-navy base and school effects/icons rather than class protagonists.

## Notion native-original receipt

The replacement v2 local binaries must be attached to the Notion Visual Bible
and freshly read back before this table may claim `DUAL_STORED_REFERENCE`.
The five v1 Notion attachments are superseded design history, not active
references and not runtime assets.

## Usage boundary

- `SCRREF-BATTLE-CHEONSUL-02` guides visual hierarchy only: steep top-down
  open combat center, small SD player/enemy/hazard hierarchy, and bounded HUD
  zones.
- `SCRREF-SCHOOL-SELECT-02` guides four equal school-choice **symbols**;
  it deliberately creates no four-player-character selection.
- `SCRREF-WORKBENCH-02` guides information order only: reward → backpack →
  route/Fate → commit. It does not add a new backpack UI implementation.
- `SCRREF-RESULT-02` and `SCRREF-GAME-OVER-02` guide outcome/retry hierarchy;
  their abstract glyphs are not in-game text or icon assets.
- No image in this folder is connected to a Godot runtime consumer yet. This is
  intentional: a design reference must not be silently promoted as a texture.

## Evidence boundary

Repository-local and Notion native-original storage are complete. Neither
generated reference proves live Godot composition, Human Usability, Player
Experience, or device/export validation.
