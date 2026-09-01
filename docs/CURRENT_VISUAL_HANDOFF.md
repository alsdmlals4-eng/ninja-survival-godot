# CURRENT VISUAL HANDOFF — Ninja Survival / 닌자의 신

> Updated: 2026-09-02 KST
> Purpose: next-chat resume router for the approved visual direction and current image-production state.
> Product/runtime authority remains `AGENTS.md` → `docs/CURRENT_CONFIRMED_DECISIONS.md` → `docs/ACTIVE_CONTEXT.md` → actual code/data/tests. This file owns the **current visual continuation state only**.

> Screen-first coverage owner: `docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md`.
> It separates whole-screen references from runtime components and does not
> authorize image generation from a gap.

## 2026-09-02 current-main reconciliation evidence boundary

The user-locked title/logo/medal, basic-weapon, and three Bongma encounter binaries listed below were byte-read back against their recorded SHA-256 values on a fresh current-main integration candidate. Their declared consumers passed focused asset/title/encounter checks before PR creation; the post-merge main full GUT suite passed (`605/605`, `6,789` assertions). A fresh Godot 4.7.1 session rendered the title and Stage selector with no source errors.

PR #139 exact-head CI, the squash merge `3428f916f20f545284c337c7eb41b0eacf268351`, and a fresh post-merge main machine readback are complete; the original PR source stays read-only. Human Usability, player experience, device/export, and balance remain `NOT_RUN`. The three new Bongma actor binaries improve that Stage's bespoke coverage; the four-school data roster does **not** yet mean every Core/Elite/Boss has an individually locked in-game illustration. Existing generic/candidate bindings remain an explicit follow-up gap.

## 2026-08-28 DEC-034 — generate then user-lock

Once fresh-read identifies a concrete runtime consumer, screen-reference, or planning-board brief, generate **one** candidate without asking for a separate pre-generation approval. After viewing it, the user alone chooses `LOCK`, `REVISE`, or `REJECT`.

This does not authorize chat-start generation, gap-only/orphan art, or replacement of an approved asset. A candidate remains `GENERATED_EXPLORATION` until `LOCK`; durable repository source/manifest, actual consumer integration, and runtime/Human evidence gates stay unchanged.

## 2026-08-31 user-locked title front door, title logo, and four-traditions medal

`NINJA_RUNTIME_TITLE_SCREEN_MOONLIT_NINJA_02` and
`NINJA_RUNTIME_TITLE_FOUR_TRADITIONS_MEDAL_02` replace the previous
single baked-key-art composition. They remain presentation-only title assets,
not an in-combat unit, player skin, Stage reward, or four-character selection
surface.

| Field | Medal-free backdrop |
| --- | --- |
| Asset ID | `NINJA_RUNTIME_TITLE_SCREEN_MOONLIT_NINJA_02` |
| Local source | `assets/runtime/ui/title_screen_moonlit_ninja_v2.png` |
| SHA-256 | `86f86da33986499bfd98aa003ba52ac65105136197d4530aa3335c9b8f2e030c` |
| Metadata | PNG, 1672×941, opaque 16:9 painterly ink key art; fixed ninja and moon stay on the right and the left becomes an uninterrupted dark title field. |
| User approval | `LOCK` / `승인`, 2026-08-31 KST |
| Runtime consumer | `scenes/ui/title_screen.tscn` → `TitleScreen/Backdrop` |
| Machine evidence | Godot 4.7.1 import, editor parse, 300-frame main-scene smoke, focused title/start GUT `3/3`, `68` assertions, and full GUT `586/586`, `6587` assertions passed on the isolated branch. |
| Render/Human/device evidence | `NOT_RUN`: no exact Ninja Survival live-editor session is currently attached; machine checks do not establish visual usability or player experience. |

| Field | Separate four-traditions medal |
| --- | --- |
| Asset ID | `NINJA_RUNTIME_TITLE_FOUR_TRADITIONS_MEDAL_02` |
| Local source | `assets/runtime/ui/title_four_traditions_medal_v2.png` |
| SHA-256 | `26520188d71f9565fef0263062dcbab6ce23f4998371f55af765c034257c61cc` |
| Metadata | PNG, 1254×1254, RGBA transparent title emblem. Four joined fragments share gold seams and one center core: 봉마=seal/familiar, 천술=reaction geometry, 귀인=oni, 흑영=shadow/shuriken. It is not a selectable character panel. |
| User approval | `LOCK` / `승인`, 2026-08-31 KST |
| Runtime consumer | `scenes/ui/title_screen.tscn` → `TitleScreen/TitleMedal`, a smaller aspect-preserving overlay immediately right of the logo with pointer input ignored. |
| Machine evidence | Godot 4.7.1 import, editor parse, 300-frame main-scene smoke, focused title/start GUT `3/3`, `68` assertions, and full GUT `586/586`, `6587` assertions passed on the isolated branch. |
| Render/Human/device evidence | `NOT_RUN`: no exact Ninja Survival live-editor session is currently attached; machine checks do not establish visual usability or player experience. |

The former baked-medal backdrop `NINJA_RUNTIME_TITLE_SCREEN_FOUR_TRADITIONS_MEDAL_01` remains a `USER_LOCKED` historical provenance and rollback source. It has no direct current-title consumer after the separate-medal transition.

`NINJA_RUNTIME_TITLE_LOGO_NINJA_GOD_01` is the approved transparent title mark;
the supplied GRIMOIRE logo was hierarchy reference only, not copied source or
runtime content.

| Field | Recorded value |
| --- | --- |
| Local source | `assets/runtime/ui/title_logo_ninja_god_v1.png` |
| SHA-256 | `c946ae4b08fd77f1e36bc25b22d0d41fdd5060fc80e98faeb9e6f2d2ac9a7a5b` |
| Metadata | PNG, 1672×941, RGBA transparent `닌자의 신` wordmark; sampled alpha `0..255`, all four corner alphas `0`; navy ink/stone-gold lettering with crescent and red seal |
| User approval | `LOCK` / `확정하자`, 2026-08-31 KST |
| Runtime consumer | `scenes/ui/title_screen.tscn` → `TitleScreen/LogoLockup/TitleLogo`, aspect-preserving and immediately left of the separately positioned four-piece medal |
| Machine evidence | Godot 4.7.1 import, editor parse, 300-frame main-scene smoke, focused title/start/MVP-2 GUT `15/15`, `193` assertions, and full GUT `580/580`, `6455` assertions passed on the isolated branch. PR #135 head `ddeaf55` then passed GitHub GUT and Windows internal-build checks. |
| Render/Human/device evidence | `NOT_RUN`: the exact Ninja Survival editor session is not connected; import or headless tests do not establish visual readability. |

`새 게임` emits only a presentation intent. `MainController` asks for
confirmation when a Continue record exists, then hides the title and exposes
the existing Stage selector; it does not enable combat until a Stage choice
arrives through the existing path. No false save/settings/store ownership or
Ninja Soul settlement affordance was added; DEC-042 adds the separately
validated Continue action below.

### 2026-09-01 DEC-042 — retained title art, expanded action surface

The locked backdrop, wordmark, and four-piece medal above are reused without
new source images or byte changes. The medal remains a smaller independent
overlay beside the wordmark. The left title action column now presents `새 게임`,
`이어하기`, `각성`, `도감`, `조작 방법`, `설정`, and `종료`; its local modal
surfaces do not replace the painterly title composition with a new art style.

`이어하기` is enabled only for a validated Workbench checkpoint. `새 게임` asks
for confirmation before removing an existing record. `각성` presents the
existing retry balance using the player-facing name only, while `도감` is a
read-only text-native catalog for enemy, ninjutsu, equipment, bag, and
combination facts. No lore promise text, separate school-choice panel, player
skin, or in-combat title asset was added.

Machine scope rechecked this surface with focused title/resume/retry regression
GUT `25/25`, `296` assertions, full GUT `604/604`, `6784` assertions, and a
headless main-scene smoke on Godot `4.7.1`. Exact live render, Human
Usability/Player Experience, complete keyboard/gamepad/touch visual review,
and device/export validation remain `NOT_RUN`.

## 2026-08-28 DEC-035 — migration-first repository-only visual ownership

The former Notion Visual Bible and Asset Library are preserved read-only under
`docs/migration/notion/`. Post-merge remote readback is complete: Notion is
`HISTORICAL_REFERENCE_ONLY` and must not be used as an asset gate for new work.
After user `LOCK`, durable visual ownership is
repository source + SHA-256/provenance manifest + explicit consumer + applicable
import/runtime evidence. The migration snapshots are provenance receipts only;
they neither block nor satisfy a current asset gate.

## 2026-08-31 user-locked DEC-040 corrupted-yokai enemy roster reference

The user locked `DEC040_FOUR_SCHOOL_CORRUPTED_YOKAI_ROSTER_01` after reviewing
the four-school roster-board candidate. It is a repository-local
`USER_LOCKED_PLANNING_REFERENCE_NOT_RUNTIME`, with the following source receipt:

| Field | Locked value |
| --- | --- |
| Local source | `docs/visual/enemy-references/four-school-corrupted-yokai-roster-v1.png` |
| SHA-256 | `a49717d3783dd47593f26f9d9f5ed04c49de57aa5aa8c506b811f27b280ed9da` |
| Metadata | PNG, 1254×1254, opaque four-quadrant planning board |
| Approval | User `LOCK`, 2026-08-31 KST |
| Human/planning consumer | `docs/superpowers/specs/2026-08-31-dec040-four-school-encounter-and-ninjutsu-design.md` and the following DEC-040 runtime-asset briefs |
| Godot consumer | None. This board is not a `Texture2D`, scene binding, or runtime proof. |

**Locked enemy contract.** Future enemy cutouts must read first as either an
**intruded/corrupted ninja** or a hostile **yokai**. Clean ordinary ninja,
samurai, or player-like human silhouettes are not valid enemy art. Every
runtime enemy needs an unmistakably hostile non-human cue at gameplay scale:
for example a cracked mask or lantern face, glowing eye socket, talisman
intrusion, horn, claw, warped limb, cursed armour fissure, or supernatural
shadow body. The four school accents remain 봉마=sealed blue/gold, 천술=
blue/amber, 귀인=crimson/black, and 흑영=violet/black.

Each roster quadrant pairs a compact Core Monster with a distinctly broader
Elite/Boss silhouette. This proves the visual direction only: it does not
promote the board's eight displayed figures, any character cutout, spell,
telegraph, old generic-enemy texture, stat, spawn rule, or Godot consumer.
### 2026-08-31 individually locked DEC-040 Bongma runtime assets

`NINJA_RUNTIME_ENCOUNTER_BONGMA_MOBILE_ARRAY_CASTER_01` remains the first runtime
asset promoted from this direction. The two later locked sources extend only
the same Bongma encounter family, not the whole DEC-040 asset batch:

| Field | Recorded value |
| --- | --- |
| Local source | `assets/runtime/encounters/actors/mobile_array_caster.png` |
| SHA-256 | `1e145d6e00a0322c894cc3b1384a65c9d225b16a700093dd76eb205efd62fbfd` |
| Metadata | PNG, 1024×1536, RGBA transparent cutout; transparent corners and alpha range checked before repository copy |
| Approval | User `LOCK` / `승인`, 2026-08-31 KST |
| Runtime consumer | `EncounterCatalog` → `SchoolEncounterActor/Visual`, only when the actor ID is `mobile_array_caster` |
| Machine evidence | Godot import plus focused source/manifest/binding contract `2/2`, `14` assertions passed on the isolated branch |
| Render/Human/device evidence | `NOT_RUN` — the currently discoverable live Godot session belongs to another project, so no Ninja visual/runtime claim is inferred |

| Field | Boss locked value | Familiar locked value |
| --- | --- | --- |
| Asset ID | `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_ARRAY_MASTER_01` | `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_FAMILIAR_01` |
| Local source | `assets/runtime/encounters/actors/hundred_demon_array_master.png` | `assets/runtime/encounters/summons/bongma_hundred_demon_familiar.png` |
| SHA-256 | `b97f20076b64e0e84eef2714e5d5551a49648ea97b0583226b31f220d5b9527c` | `50cbecfe6982e53537d4caaa731bc06c3e56c95bbf0be6084c2550571176ea75` |
| Metadata | 1254×1254 RGBA transparent Boss cutout; blue eye, array frame, bound fox shikigami | 1254×1254 RGBA transparent floating fox-mask shikigami cutout |
| Approval | User `LOCK` / `승인`, 2026-08-31 KST | User `LOCK` / `승인`, 2026-08-31 KST |
| Runtime consumer | `EncounterCatalog` → `SchoolEncounterActor/Visual`, only `hundred_demon_array_master`, scale `0.09` | `SchoolEncounterActor/EncounterProxy/Visual`, only Bongma `summon_or_proxy`, scale `0.03`, no tint |
| Scope guard | Existing Boss patterns, timing, hazards, rewards and gates are unchanged | Existing delayed proxy arming, lifetime, radius and damage are unchanged; existing player-side `BongmaFamiliar` is untouched |
| Machine evidence | Godot import plus focused source/manifest/scale contract `4/4`, `29` asserts; full GUT `578/578`, `6408` asserts | Godot import plus focused delayed-proxy source/scale/no-tint contract `5/5`, `23` asserts; full GUT `578/578`, `6408` asserts |
| Render/Human/device evidence | `NOT_RUN` | `NOT_RUN` |

This promotion does not approve a whole family: the remaining 18 actor, 12
ninjutsu and shared telegraph candidates must each be generated, reviewed,
user-locked, registered, imported and render-checked independently.

## 2026-08-30 user-locked auto-combat battlefield planning reference

`SCRREF-BATTLE-AUTOCOMBAT-03` is now a repository-local
`USER_LOCKED_PLANNING_REFERENCE_NOT_RUNTIME` with source, SHA-256, approval,
and GDD/PDF consumer recorded in `docs/visual/screen-references/README.md`.

- Background contract: continuous moonlit cracked-stone floor only, without
  baked architecture, tree clusters, lantern rows, horizon, or arena boundary.
- Prop contract: lanterns, dead trees, stones, and shrubs are sparse independent
  objects with their own contact shadows and must not be painted into the tile
  background.
- Gameplay contract: the fixed ninja, enemies, blue-to-amber Cheonsul setup and
  reaction, red danger telegraph, and top-only automatic-combat HUD remain the
  readable foreground.
- Runtime boundary at planning-reference lock: no implementation was implied.
  The later user `LOCK` for the runtime floor candidate is tracked separately
  below; it does not promote the prop or shadow candidates.

## 2026-08-30 user-locked runtime floor tile — current isolated branch

The user locked the first runtime asset derived from the continuous-floor
contract: `NINJA_RUNTIME_BATTLEFIELD_FLOOR_TILE_01`.

| Asset | SHA-256 | Exact current-branch consumer | Approval and evidence state |
| --- | --- | --- | --- |
| `moonlit_battlefield_floor_tile_v1.png` | `ceb6e50ce6acc650f4a6e534ae2244e5f0aeae498fa9cefa150c98b2f510d700` | `Main/BattlefieldBackdrop` (`Parallax2D`) → `FloorTile` | `USER_LOCKED`; implemented and scoped live render/input verified on the isolated branch; not merged; Human Usability, Player Experience, and device/export evidence `NOT_RUN` |

`Parallax2D.repeat_size` is set to the native 1254×1254 source size and keeps
the floor behind gameplay. The prior moonlit backdrop source remains preserved
for provenance and rollback, but is no longer the direct `Main` consumer on
this branch. Combat, route, reward, input, and player/enemy ownership remain
unchanged.

The user batch-locked the two companion assets on 2026-08-30:

| Asset | Repository source | Consumer | Current state |
| --- | --- | --- | --- |
| `NINJA_RUNTIME_BATTLEFIELD_PROP_ATLAS_01` | `assets/runtime/visual-core/moonlit_battlefield_prop_atlas_v1.png` | `Main/BattlefieldProps` → lantern, dead tree, rocks, talisman stele | `USER_LOCKED` → `IMPLEMENTED_ON_CURRENT_BRANCH` → `SCOPED_LIVE_RENDER_INPUT_VERIFIED`; separate repeat layer, no collision or gameplay ownership; each atlas region clips filtered sampling to prevent neighboring-prop bleed |
| `NINJA_RUNTIME_CONTACT_SHADOW_01` | `assets/runtime/visual-core/runtime_contact_shadow_v1.png` | `Player`, `EnemyBasic`, `StageBoss` → `GroundShadow` | `USER_LOCKED` → `IMPLEMENTED_ON_CURRENT_BRANCH` → `SCOPED_LIVE_RENDER_INPUT_VERIFIED`; visual-only child behind each unit sprite |

The current isolated branch passed import/parse, headless scene checks, the
focused Main test, and full GUT `523/523` with `5832` assertions. On
2026-08-30 KST, a Ninja Survival Godot 4.7.1 editor opened this exact
worktree, rendered the school-selection scene, selected Cheonsul through the
visible button, and reached automatic combat with a clean live diagnostic
readback. The observed floor repeated continuously to the viewport edges;
lantern, dead tree, rocks, and talisman stele remained sparse independent
props; Player `GroundShadow` was visible at `z_index = -1` with the locked
texture. This is scoped `RUNTIME_RENDER_INPUT` evidence only. The temporary
local bridge and its generated sidecars were removed after the check;
screenshots were not promoted to project assets. Human Usability, Player
Experience, and device/export evidence remain `NOT_RUN`. No asset is merged
yet.

## 2026-08-28 current combat visual grammar — approved, implementation deferred

- **Cheonsul:** blue plus amber/orange is the primary status/reaction family. It must not drift into the violet/black family reserved for Heukyeong.
- **Cheonsul setup seal:** a short, fixed blue seal at the automatic `WET` cast point is the approved player-created setup condition. Its boundary and expiry cue must distinguish it from an enemy hazard; automatic `SHOCK` turns a prepared group inside it into the amber/orange higher-value chain. Exact values and runtime implementation remain deferred.
- **Status information:** show compact, silhouette-distinct icons rather than persistent written status badges. Color alone is insufficient; implementation must retain a focus/help description path for validation.
- **Enemy HP:** hide all HP bars by default. Only the enemy just damaged may reveal its bar. The reveal duration is intentionally undecided until Human Usability observation.
- **Character/style guardrail:** retain the single black/navy ninja identity with restrained red cord and warm-gold details. The supplied four-school SD sheet may inform icon/action density only; it must not become four runtime protagonists or simultaneous four Stage-3 forms.
- **`PROJECT_CORE_SCENE_VISUAL_BOARD` revised candidate:** the user selected the four-panel A composition: school selection → Cheonsul core action → Trace-to-Boss gate → Result/Persistent Workbench. From the previous board, **only the compact status-icon grammar remains valid**; character poses, environments, panel compositions, UI treatment and all other visual elements were redesigned. The new candidate is `GENERATED_EXPLORATION`, not an approved Project Asset, runtime texture, UI implementation, Scene completion, or Human/Player evidence. Do not register it as a repository Project Asset or use it in a runtime consumer unless the user separately promotes it through the asset gate.

The Hybrid Master Style remains approved. The user retains the revised board as a **REFERENCE_ONLY GENERATED_EXPLORATION** while planning review proceeds; it does not promote Trace-versus-reward readability, Workbench grid treatment, or any runtime asset. Those surfaces remain **NOT_IMPLEMENTATION_READY**. Failure/retry remains a separate consumer contract and is intentionally excluded from this four-panel board.

## Current IMG-02 runtime visual core — merged 2026-08-27

Issue [#83](https://github.com/alsdmlals4-eng/ninja-survival-godot/issues/83)
and PR [#84](https://github.com/alsdmlals4-eng/ninja-survival-godot/pull/84)
are merged. The runtime implementation baseline is
`03005e7dcc1a2e0b6ee57b4f6ebed9b481ee2fbc`; every future task must still
fresh-read the current `origin/main` rather than treating this SHA as a live
branch pointer.

Seven PNG originals are now stored in their exact project-local runtime paths.
Their former Notion Asset Library records are preserved as sanitized migration
snapshots. Local files were rechecked by SHA-256 against their approved record,
with dimensions/alpha/consumer evidence retained in the runtime manifest.

| Asset | Runtime consumer | Local runtime source | Migration snapshot |
| --- | --- | --- | --- |
| Cursed Lantern | `EnemyBasic/Visual` variant pool | `assets/runtime/visual-core/cursed_lantern_v1.png` | `migration/notion/assets/3c81b237-eb1c-8114-9768-cb6f6b42db3c.notion.md` |
| Shadow Beast | `EnemyBasic/Visual` variant pool | `assets/runtime/visual-core/shadow_beast_v1.png` | `migration/notion/assets/3c81b237-eb1c-8187-827c-d5bf3b51907e.notion.md` |
| Flame Ninja | `EnemyBasic/Visual` variant pool | `assets/runtime/visual-core/flame_ninja_v1.png` | `migration/notion/assets/3c81b237-eb1c-819b-ac22-df2c6a99b984.notion.md` |
| Cheonsul stage boss | `StageBoss/Visual` | `assets/runtime/visual-core/cheonsul_stage_boss_v1.png` | `migration/notion/assets/3c91b237-eb1c-8162-84b6-ee6d8c2e7149.notion.md` |
| Talisman trace visual | `TracePickup/TraceVisual` | `assets/runtime/visual-core/talisman_projectile_v1.png` | `migration/notion/assets/3c91b237-eb1c-8125-a3da-db4a959dd387.notion.md` |
| Golden reward orb | `RewardOrb/Visual` | `assets/runtime/visual-core/golden_reward_orb_v1.png` | `migration/notion/assets/3c91b237-eb1c-81b7-a686-e2423308102b.notion.md` |
| Bongma familiar | `BongmaFamiliar/Visual` | `assets/runtime/visual-core/bongma_familiar_v1.png` | `migration/notion/assets/3c91b237-eb1c-8102-a8c4-fe46dfc41e8f.notion.md` |

## DEC-039 basic weapon effects — user locked, current isolated branch

`NINJA_RUNTIME_BASIC_WEAPON_EFFECTS_01` is a 1774×887 transparent atlas at
`assets/runtime/visual-core/basic_weapon_effects_v1.png` with SHA-256
`728aff2ed85e233a0adcc195406a9a101b0933da8990078cced1af59c9eaf58a`.
The left katana region is rendered briefly by `BasicWeaponController`; the
right shuriken region is clipped by `ShurikenProjectile`. These effects make
automatic base weapons readable without modifying the single Ninja's body
pose. The asset is user locked and bound on the current isolated branch, but
is not merged and has no Human/device/balance verdict.

## IMG-03 runtime battlefield backdrop — merged 2026-08-27

Issue [#87](https://github.com/alsdmlals4-eng/ninja-survival-godot/issues/87)
adds one bounded battlefield background to the existing `Main` scene. It is
behind gameplay at `Main/BattlefieldBackdrop` (`z_index = -10`) and does not
change combat, route, reward, or school authority. Its normal gameplay center
stays deliberately open; moonlit shrine architecture and restrained Cheonsul
edge sigils supply the visual context.

| Asset | Runtime consumer | Local runtime source | Migration snapshot |
| --- | --- | --- | --- |
| Moonlit Battlefield | `Main/BattlefieldBackdrop` | `assets/runtime/visual-core/moonlit_battlefield_backdrop_v1.png` | `migration/notion/assets/3c91b237-eb1c-8109-addc-db3659476e4d.notion.md` |

The local original is an opaque 1672×941 PNG with SHA-256
`e5ec25a1429399be7a6ae3f930a5162ab4a935083051f7c2388724921ed9b0fd`.
Its former Asset Library record is preserved in the migration archive. PR [#88](https://github.com/alsdmlals4-eng/ninja-survival-godot/pull/88)
is merged; its historical merge SHA is `5a52a30aa6c38cfed17e46d550eef27ab06e53f7`.

On the 2026-08-30 isolated branch, this historical source is retained but
superseded as the direct `Main` consumer by the separately user-locked repeating
floor tile described above. This does not rewrite the historical PR receipt.

`EnemyBasic/Visual` selects only the three approved generic-enemy textures;
no school rule, combat value, reward rule, or route authority moved into the
visual script. The four newly made originals preserve the approved dark
moonlit, painterly-anime/ink direction while their runtime scale stays bounded
by their existing Sprite2D consumers.

## IMG-04 Cheonsul field visual — merged 2026-08-27

Issue [#90](https://github.com/alsdmlals4-eng/ninja-survival-godot/issues/90)
adds one transparent field texture to the **existing** runtime visual owner:
`Cheonsul/FlameFieldVisual`. It replaces only the former `Polygon2D` drawing
node with a `Sprite2D`; its 90px radius, damage, statuses, target selection,
timing, and 0.60-second lifetime stay owned by the existing runtime logic.

| Asset | Runtime consumer | Local runtime source | Migration snapshot |
| --- | --- | --- | --- |
| Cheonsul Flame Field | `Cheonsul/FlameFieldVisual` | `assets/runtime/visual-core/cheonsul_flame_field_v1.png` | `migration/notion/assets/3c91b237-eb1c-8179-8c10-d307b4764ad8.notion.md` |

The local original is a transparent 1269×1240 PNG with SHA-256
`cbb4b1e697f69bf37731f14a32c8ad3890d1557c5ee7ea2ebeb4b2f4f81b3e68`.
The former Asset Library record is preserved in the migration archive. PR [#91](https://github.com/alsdmlals4-eng/ninja-survival-godot/pull/91)
is squash-merged; its merge SHA is `6d538fcf933e2fbcca50f8e6d369d165efac620c`.

Exact PR-head CI passed `gut` and the Windows internal-build artifact. Fresh
post-merge Godot 4.7.1 evidence passed import, editor parse, a five-second
headless main-scene smoke, and full GUT `494/494` with `5386` assertions.

Evidence boundary: Hera was connected to a different project, so this package
does **not** claim a live visual render, Human Usability, Player Experience,
or device/export pass. PR #49 was not changed.

## 0. Current IMG-01 source receipt — 2026-08-26

The user-approved fixed-player Move / Attack / Hit v1 images remain immutable
visual provenance. Their baked checkerboard prevents runtime use. The approved
v2 alpha-remediated derivatives are stored as exact project-local PNGs; their
former Asset Library records are preserved as migration snapshots:

| Variant | Local v2 source | SHA-256 | Migration snapshot |
| --- | --- | --- | --- |
| Move | `docs/assets/approved/img-01-player-runtime-core/player_runtime_move_v2_alpha.png` | `a56f79918bd9ebe451cbca092cb9828c512a710c1762600a070eeba68e01fb2a` | `migration/notion/assets/3c81b237-eb1c-815e-9e9e-eb4c8b0c2911.notion.md` |
| Attack | `docs/assets/approved/img-01-player-runtime-core/player_runtime_attack_v2_alpha.png` | `75c6d31237ebf8cd1760c89d90d2a85ebae5c2802cb615816b1be8fb7f7836cd` | `migration/notion/assets/3c81b237-eb1c-81e3-a121-c2904209f2eb.notion.md` |
| Hit | `docs/assets/approved/img-01-player-runtime-core/player_runtime_hit_v2_alpha.png` | `f00c2f6fd09e6c52e1dce8abe6f493e76245d2dbc818ee4ac5db1b98f5b23d60` | `migration/notion/assets/3c81b237-eb1c-8195-8819-dc9e3e763587.notion.md` |

All v2 files are 1254×1254 32bpp ARGB PNGs with transparent corners. The
repository source, SHA-256 and migration snapshot retain the source-level
alpha/provenance record; no external dual-storage gate remains.

### IMG-01 runtime wiring receipt — PR #59 / unmerged

- Fresh Issue [#58](https://github.com/alsdmlals4-eng/ninja-survival-godot/issues/58)
  branch: `codex/img-01-runtime-visuals-58`, based on merged `main`
  `c9956130ec0631603cc4bd03b619795917874bc7`.
- Current PR head: resolve it from the live [PR #59](https://github.com/alsdmlals4-eng/ninja-survival-godot/pull/59)
  before relying on this receipt; the PR check is the exact-head authority.
- `Player/Visual` now consumes only these three v2 sources as a `Sprite2D` at
  `Vector2(0.05, 0.05)`. Move is default; Attack is a visual-only relay from
  a selected school's non-zero resolved action; Hit is a visual-only response
  to non-zero, non-evaded Player damage. Legacy AutoAttack stays disabled.
- The exact-head GUT check on PR #59 passed Base manifest, Godot 4.7.1 import,
  main-scene smoke, and the full current GUT suite.
- Live runtime/render/input observation on 2026-08-26 KST used the exact PR
  #59 worktree. The selection screen and combat view rendered the approved v2
  Sprite2D without checkerboard or clipping; Move, successful Bongma and
  Cheonsul actions, and non-zero Player Hit selected their intended textures.
  `ui_right` moved Player `(0, 0)` to `(132, 0)` while Camera2D kept the
  player-centered view. Runtime log and diagnostics had no errors or warnings.
- Evidence ceiling: source/static/import/smoke/GUT and this scoped live
  runtime/render/input evidence are PASS on the unmerged PR head. Human
  Usability, Player Experience, device, and export remain **NOT_RUN**. PR #49
  remains read-only.

## Historical repository / concurrency snapshot — not current authority

- Completed `main` observed for this visual handoff: `c0440e7043bcf3bb678f5cb7d1653883f93c07a2`.
- Open T12 implementation PR: **#49 `T12: atomic Workbench Fate route commit`**.
- PR #49 is a separate implementation workstream and is **READ_ONLY / NO MUTATION** for visual work.
- PR #49 changed files were checked; this visual handoff does not own its scripts/tests/plan.
- Visual/document work should start from then-current completed `main`, re-read this file + repository Master GDD, and avoid taking over unrelated PRs.

## 2. Approved hybrid visual architecture

The user approved a two-surface visual system that must still look like one IP.

### Presentation / key art / lore

**Hand-drawn ink codex / painterly ninja fantasy**:

- paper / ink wash / pencil / brush texture,
- dark moonlit ninja fantasy,
- premium painterly anime proportions,
- circular brush stroke / moon framing,
- Korean brush-calligraphy title language,
- black / deep navy / charcoal + red + warm gold,
- school accents are secondary to silhouette and motif.

Use for title/key art, school explanation, lore/trace, loading/chapter art, planning/PPT, marketing explanation.

### In-game

**Animation-forward 2–3 head SD anime + C-leaning dark painterly DNA**:

- one readable chibi/anime player silhouette,
- clear cel-animation-like planes and fast readable actions,
- simplified detail compared with key art,
- restrained ink/rough-edge texture so gameplay and presentation do not look like different games,
- readability of player/enemy/hazard/projectile/pickup is above decorative density.

Do **not** turn in-game art into four different player characters.

## 3. Core runtime character identity — USER APPROVED

### ONE_CHARACTER_IDENTITY

The player character remains **one fixed ninja identity** across the whole Run:

- same face,
- same hair,
- same body proportion,
- same core outfit identity,
- same base weapon language unless gameplay data explicitly changes equipment.

School progression must not replace the player's body/identity with four school-specific protagonists.

### TRACE_AS_LAYER

Collecting school traces adds **items / aura / companion / shadow effects** around the same character.

The visual result should read as:

`one ninja -> accumulated traditions -> one completed ninja`

not:

`four unrelated school costumes combined`.

### FOUR_SCHOOLS_COMBINE_CLEANLY

A full four-school state must remain visually coherent. Use layer priority, size and location so effects do not compete:

- body-mounted accents are limited,
- large effects prefer separate spatial zones (feet / back / side companion / hands / weapon),
- the face and core silhouette remain readable,
- accumulated traces must look intentional rather than loot clutter.

### MAIN_SCHOOL_STAGE_3_ONLY

The strongest **Trace Stage 3** visual expression is available **only for the school chosen as the Run's starting/main school**.

Other schools may accumulate recognizable supporting trace layers but must not all reach simultaneous full Stage-3 dominance.

This rule prevents four maximal school identities from visually fighting on one character and preserves a readable "main tradition + learned traditions" hierarchy.

## 4. Approved school visual motifs

These motifs are the current user-approved visual shorthand. Do not substitute generic element colors as the school identity.

### 봉마류

- primary visual motifs: **부적 + 식신**,
- talismans can mount on outfit/gear in restrained numbers,
- shikigami should preferably occupy a side/companion silhouette zone,
- supports prepared-space / mobile-stronghold identity.

### 천술류

- primary visual motif: **차크라 기운**,
- use flowing energy around hands / feet / weapon / behind-body path rather than one giant full-body circle,
- must remain compatible with other accumulated trace layers,
- supports setup / ordered reaction / field-transformation identity.

### 귀인류

- primary visual motifs: **오니가면 + 귀기**,
- oni mask should not permanently erase the fixed protagonist face; prefer waist / shoulder / back carry or an emphasized activation moment,
- demonic aura communicates dangerous close-range pressure,
- avoid reducing the school to generic low-HP berserker language.

### 흑영류

- primary visual motifs: **그림자 + 어둠**,
- place darkness in ground shadow / back silhouette / afterimage zones,
- avoid covering equipment and hit/hazard readability,
- supports stealth / threat-priority / execution identity.

## 5. Current image inventory and authority level

### A. Hybrid Key Visual — APPROVED MASTER BRIDGE

Purpose:
- connects mature painterly/ink presentation art with the same project's gameplay language,
- central ninja + four school languages + moon/ink circle + `닌자의 신` calligraphy.

Notion:
- `02 · 비주얼 바이블` contains a **Notion-native low-resolution preview attachment**.
- server readback resolved to Notion-owned `prod-files-secure`: **PASS**.
- original generated high-resolution image in the originating chat remains the quality reference.
- actual browser/mobile pixel observation: NOT_RUN in this handoff.

### B. Four-school full-body silhouette sheet — APPROVED SUPPORTING REFERENCE

Purpose:
- compare school clothing, silhouette and motif languages for Presentation/Lore design.

Important limitation:
- the four figures are **not four in-game player protagonists**.
- runtime uses ONE_CHARACTER_IDENTITY.

Notion:
- low-resolution Notion-native preview attached to the Visual Bible.
- destination fetch resolved the block to Notion-owned `prod-files-secure`: **SERVER_READBACK_PASS**.
- browser/mobile pixel observation: NOT_RUN.

### C. SD / action / icon three-panel sheet — WORKING REFERENCE, DETAILS SUPERSEDED

Reusable:
- SD scale direction,
- action exaggeration / readability idea,
- school skill-icon grouping,
- trace layering as a visual progression concept.

Superseded details to correct in the next visual session:
- one fixed base character must be more explicit,
- Trace Stage 3 only for the starting/main school,
- all four traces must combine naturally,
- exact motifs are 봉마=부적/식신, 천술=차크라 기운, 귀인=오니가면/귀기, 흑영=그림자/어둠.

Notion:
- low-resolution working-reference preview attached to the Visual Bible.
- destination fetch resolved the block to Notion-owned `prod-files-secure`: **SERVER_READBACK_PASS**.
- it remains WORKING_REFERENCE, not approved final runtime art.
- browser/mobile pixel observation: NOT_RUN.

## 6. Historical Notion visual authority — retired by DEC-035

Primary visual page:
- **`닌자 서바이벌 · Home` → `02 · 비주얼 바이블`**
- Notion page ID: `3c01b237-eb1c-8116-9028-c8c8c427e467`

Human Home:
- `닌자 서바이벌 · Home`
- currently describes the Hybrid Master Style and links to the Visual Bible.

Project work control:
- `01 · 프로젝트 전체 작업계획`
- should contain this closeout state and the next visual resume gate.

These pages are historical visual receipts only. The repository Master GDD and
this handoff are the active human-facing visual owners; actual runtime art
implementation remains code/assets/runtime evidence.

## 7. Next visual work — safe resume point

### 2026-09-01 `NS-BLUEPRINT-001` screen-blueprint continuation

The current editable flow/wireframe owner is
`docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`. It maps the player journey,
six screen hierarchies, top-only battle HUD, and actual/planned consumers
without changing visual canon, asset provenance, or implementation truth.

The Blueprint found that `SCRREF-BATTLE-AUTOCOMBAT-03` already has the exact
user-locked planning role for continuous floor, sparse props, grounded units,
and top-only automatic-combat HUD. Therefore this package generated **no**
duplicate battle/HUD image. A future image remains conditional on a verified
actual consumer gap, one text brief, one candidate, and user `LOCK`.

Its planned Title screen notes the wordmark/medal/key-art lineage in open PR
#135 as read-only reference only; it does not claim a merged current-main
Title consumer. Runtime visual, Human Play, device/export, and release
evidence remain `NOT_RUN`.

The existing eight runtime originals are final for their present consumer
contracts. Do not regenerate or replace them merely to make a new sheet.

The first new visual task must begin with a fresh implementation read and a
specific Godot consumer contract. Dynamic trace effects (ward, elemental
reaction, sword aura and shadow ground aura) remain excluded: they do not yet
have an approved texture consumer, and must not be created as orphan art.

When a new consumer is approved, preserve the fixed-character trace-layer
rules and make the smallest needed asset set:

1. same player identity; school identity stays in layers/effect grammar;
2. Stage-3 intensity only for the starting/main school;
3. four simultaneous traces must retain silhouette/readability;
4. keep explanatory Korean text out of runtime image pixels.

Image process for any new pack remains:

`current consumer contract -> text brief -> generate one candidate -> user LOCK/REVISE/REJECT -> exact repository-local source + SHA-256/provenance manifest -> runtime validation`.

## 8. Quality and evidence bar

Before creating any new asset, read current `AGENTS.md`,
`CURRENT_CONFIRMED_DECISIONS.md`, `ACTIVE_CONTEXT.md`, this handoff,
`docs/design/NINJA_SURVIVAL_MASTER_GDD.md`, the repository asset
manifest/provenance, and the actual consumer scene/script. Preserve the
four-school philosophies and Hybrid Master Style; do not copy a reference
image's distinct expression.

The target is not merely a matching prompt style. It is **one coherent
character identity, readable school motifs, bounded runtime scale, durable
repository provenance, and proof at the consumer that actually uses the asset**.

## 9. Evidence ceiling at current closeout

Verified:
- seven IMG-02 originals are on merged project-local runtime paths;
- every asset is mapped to an actual Godot Sprite2D consumer;
- exact PR-head CI and fresh post-merge Godot 4.7.1 automated evidence passed
  as recorded in the current IMG-02 section.
- the IMG-03 local original is on its merged runtime path; its exact
  integration state must still be resolved from current GitHub main.

Not verified / not claimed:
- live render/input observation in this Ninja Survival project;
- Human Usability, Player Experience, or device/export validation;
- dynamic trace VFX or a full four-school composite under runtime conditions.
