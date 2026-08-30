# CURRENT VISUAL HANDOFF — Ninja Survival / 닌자의 신

> Updated: 2026-08-30 KST
> Purpose: next-chat resume router for the approved visual direction and current image-production state.
> Product/runtime authority remains `AGENTS.md` → `docs/CURRENT_CONFIRMED_DECISIONS.md` → `docs/ACTIVE_CONTEXT.md` → actual code/data/tests. This file owns the **current visual continuation state only**.

> Screen-first coverage owner: `docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md`.
> It separates whole-screen references from runtime components and does not
> authorize image generation from a gap.

## 2026-08-28 DEC-034 — generate then user-lock

Once fresh-read identifies a concrete runtime consumer, screen-reference, or planning-board brief, generate **one** candidate without asking for a separate pre-generation approval. After viewing it, the user alone chooses `LOCK`, `REVISE`, or `REJECT`.

This does not authorize chat-start generation, gap-only/orphan art, or replacement of an approved asset. A candidate remains `GENERATED_EXPLORATION` until `LOCK`; durable repository source/manifest, actual consumer integration, and runtime/Human evidence gates stay unchanged.

## 2026-08-28 DEC-035 — migration-first repository-only visual ownership

The former Notion Visual Bible and Asset Library are preserved read-only under
`docs/migration/notion/`. Post-merge remote readback is complete: Notion is
`HISTORICAL_REFERENCE_ONLY` and must not be used as an asset gate for new work.
After user `LOCK`, durable visual ownership is
repository source + SHA-256/provenance manifest + explicit consumer + applicable
import/runtime evidence. The migration snapshots are provenance receipts only;
they neither block nor satisfy a current asset gate.

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
