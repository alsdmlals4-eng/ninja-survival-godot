# P0 Screen Design References

GitHub Issue #98의 화면 우선 시각 커버리지 자료다. v1은 병합 전
**REJECTED** 되었다. 포스터형 성인 비율과 사선 전장 구도가 실제 탑뷰
뱀서라이크·SD 캐릭터 정본과 어긋났기 때문이다. 아래 v2만 현재 유효하다.
이 PNG들은
**제작·기획 시각자료**이며, runtime texture나 이미 승인된 runtime asset의
교체본이 아니다. 모든 게임 내 문구와 동적 수치는 Godot Control/Label에서
계속 렌더해야 한다.

| ID | Target screen(s) | Local source | SHA-256 | Status | Current documentation consumer |
| --- | --- | --- | --- | --- | --- |
| `SCRREF-SCHOOL-SELECT-02` | `SCR-SCHOOL-SELECT` | `scrref-school-select-v2-sd.png` | `8dd2a751b230c0b74104a59daa1cfee933c4b0c57ecdc10dc90de22b20d0f24b` | `DUAL_STORED_REFERENCE` | `NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` Visual Atlas; integrated Human Blueprint Stage companion |
| `SCRREF-BATTLE-CHEONSUL-02` | `SCR-BATTLE-CHEONSUL` | `scrref-battle-cheonsul-v2-topdown-sd.png` | `0d179dce4108043c251cb51d88c554493e1a9e90a5fab3bb5b91b8ab41afa61d` | `DUAL_STORED_REFERENCE` | visual coverage comparison only |
| `SCRREF-BATTLE-AUTOCOMBAT-03` | `SCR-BATTLE-AUTOCOMBAT-CONTINUOUS-FLOOR` | `scrref-battle-autocombat-continuous-floor-v3.png` | `68727c87b5f81dee18f06bb0955d37314a3e0ec03f04fe9dd33f842df0dd6eac` | `USER_LOCKED_PLANNING_REFERENCE_NOT_RUNTIME` | Human GDD/PDF page 10; Screen Blueprint Visual Atlas; integrated Human Blueprint battle companion |
| `SCRREF-WORKBENCH-02` | `SCR-ROUTE-WORKBENCH`, `SCR-FATE`, `SCR-NEXT-PREVIEW` | `scrref-workbench-v2-sd.png` | `dd3b90ed11b242d3f09de4748f65d0a12ff44f8eede0eba7b4e013c22d3cf9a8` | `DUAL_STORED_REFERENCE` | `NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` Visual Atlas; integrated Human Blueprint Workbench companion |
| `SCRREF-RESULT-02` | `SCR-RESULT` | `scrref-result-v2-sd.png` | `d125a2e04c467baff7450d98b28b8325b425140fd6b7406ee6d540d8b65330e4` | `DUAL_STORED_REFERENCE` | `NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` Visual Atlas; integrated Human Blueprint Result companion |
| `SCRREF-GAME-OVER-02` | `SCR-GAME-OVER` | `scrref-game-over-v2-topdown-sd.png` | `00382fe0e3a649b3594e2e78eae500ef4354ecd616b9502f5d29c7da1de07ca7` | `DUAL_STORED_REFERENCE` | `NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` Visual Atlas; integrated Human Blueprint Game Over companion |

The five v2 files are 1672×941 PNGs. They were generated with the built-in
image generation tool on 2026-08-28, visually inspected, and checked against
the supplied SD style sheet: top-down survival readability, one-ninja identity,
black/deep-navy base and school effects/icons rather than class protagonists.

## 2026-08-30 locked auto-combat continuous-floor reference

The user chose `LOCK` after reviewing the revised auto-combat battle candidate.
Its repository source, exact SHA-256, approval state, and human-facing consumer
are now recorded here.

| Field | Locked value |
| --- | --- |
| Asset ID | `SCRREF-BATTLE-AUTOCOMBAT-03` |
| Local source | `scrref-battle-autocombat-continuous-floor-v3.png` |
| SHA-256 | `68727c87b5f81dee18f06bb0955d37314a3e0ec03f04fe9dd33f842df0dd6eac` |
| Approval | User `LOCK`, 2026-08-30 KST |
| Status | `USER_LOCKED_PLANNING_REFERENCE_NOT_RUNTIME` |
| Producer | Built-in image generation edit of the prior auto-combat battle candidate; user-requested infinite-floor and separate-prop revision |
| Human consumer | `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md` page 10, `exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf`, `exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf` battle companion, and `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` Visual Atlas |
| Godot consumer | Planning-reference PNG: none. The separately user-locked derived floor, prop atlas, and contact-shadow sources are bound on the current isolated branch; see `docs/CURRENT_VISUAL_HANDOFF.md`. |

**Locked visual contract.** The background is only a continuous, walkable,
moonlit cracked-stone floor that can extend beyond every camera edge. It has no
baked walls, shrine buildings, tree clusters, lantern rows, horizon, or fixed
room boundary. Lanterns, trees, stones, and shrubs are sparse independent props
with their own footprint/contact shadow; the two illustrative props in this
reference are not a final density or spawn-table decision. Player, enemies, and
hazards stay readable against the floor through their own short contact shadows
and high-contrast gameplay signals.

This is a user-locked planning reference, not a runtime texture itself. The
reference binary remains outside the Godot scene. A later, separately
user-locked derived runtime package has now created the tile, prop atlas, and
contact-shadow sources; it binds them only on the current isolated branch and
records its exact consumers, source receipts, and scoped runtime evidence in
`docs/CURRENT_VISUAL_HANDOFF.md`. That evidence does not become Human
Usability, Player Experience, device/export, or merged-main evidence.

## 2026-08-28 current Cheonsul override

`SCRREF-BATTLE-CHEONSUL-02` remains a `DUAL_STORED_REFERENCE` for its steep
top-down composition, open combat center, small SD hierarchy, and bounded HUD
zones. Its violet-forward Cheonsul reaction treatment and any persistent
written-status / always-visible-enemy-HP implication are **SUPERSEDED** by the
current combat grammar:

- Cheonsul reaction/status primary family = blue + amber/orange.
- Heukyeong retains violet + black ownership.
- Status = compact silhouette-distinct icon, not a persistent written badge.
- Enemy HP = hidden by default; only the enemy just damaged may show a bar.

This is a scope-specific visual interpretation correction. It does not alter
the binary, SHA-256, Notion attachment, runtime consumer state, or approval of
the reference's composition role.

## Notion native-original receipt

The exact v2 local binaries were attached to the Notion Visual Bible and fresh
readback resolved every attachment to a Notion-owned `prod-files-secure` image
URL. The five v1 Notion attachments are superseded design history, not active
references and not runtime assets.

| ID | Notion `file_upload_id` |
| --- | --- |
| `SCRREF-SCHOOL-SELECT-02` | `3c91b237-eb1c-81a3-9dbc-00b23a0270ef` |
| `SCRREF-BATTLE-CHEONSUL-02` | `3c91b237-eb1c-8179-80b9-00b2391e87d9` |
| `SCRREF-WORKBENCH-02` | `3c91b237-eb1c-815a-a180-00b2a9ddc5e1` |
| `SCRREF-RESULT-02` | `3c91b237-eb1c-8124-bacd-00b2e646f533` |
| `SCRREF-GAME-OVER-02` | `3c91b237-eb1c-8173-bf02-00b276b85ed3` |

## Usage boundary

- `SCRREF-BATTLE-CHEONSUL-02` guides visual hierarchy only: steep top-down
  open combat center, small SD player/enemy/hazard hierarchy, and bounded HUD
  zones.
- `SCRREF-BATTLE-AUTOCOMBAT-03` is the locked human-blueprint reference for
  seamless floor continuity, sparse independent props, grounded units, and
  top-only automatic-combat HUD. It supersedes `SCRREF-BATTLE-CHEONSUL-02`
  only for this narrower background/prop interpretation; it does not replace a
  runtime texture or change any combat rule.
- `SCRREF-SCHOOL-SELECT-02` guides four equal school-choice **symbols**;
  it deliberately creates no four-player-character selection.
- `SCRREF-WORKBENCH-02` guides information order only: reward → backpack →
  route/Fate → commit. It does not add a new backpack UI implementation.
- `SCRREF-RESULT-02` and `SCRREF-GAME-OVER-02` guide outcome/retry hierarchy;
  their abstract glyphs are not in-game text or icon assets.
- No image **in this screen-reference folder** is connected to a Godot runtime
  consumer. This is intentional: the planning reference is not silently
  promoted as a texture. The separately user-locked runtime-derived sources
  live under `assets/runtime/visual-core/` and are documented in the current
  visual handoff.

## Evidence boundary

Repository-local and Notion native-original storage are complete. Neither
generated reference proves live Godot composition, Human Usability, Player
Experience, or device/export validation.
