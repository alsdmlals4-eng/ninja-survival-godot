# IMG-02 Runtime Visual Core Manifest

> GitHub Issues: #83, #87, #90
> Local source root: `assets/runtime/visual-core/`
> Approval: user pre-authorized automatic visual production on 2026-08-26; this
> package is limited to existing Godot consumers.
> Migration state: the former Notion records are preserved as sanitized
> repository snapshots under `docs/migration/notion/assets/`; local binary,
> SHA-256 and actual-consumer evidence are the active ownership record.

## Runtime assets

| Asset ID | Local source | SHA-256 | Metadata | Consumer | Status |
| --- | --- | --- | --- | --- | --- |
| `NINJA_RUNTIME_TITLE_LOGO_NINJA_GOD_01` | `assets/runtime/ui/title_logo_ninja_god_v1.png` | `c946ae4b08fd77f1e36bc25b22d0d41fdd5060fc80e98faeb9e6f2d2ac9a7a5b` | PNG, 1672×941, RGBA transparent `닌자의 신` title logo; sampled alpha `0..255`, every corner alpha `0`; dark navy ink, stone-gold lettering, crescent, and red seal | `scenes/ui/title_screen.tscn` → `TitleScreen/LogoLockup/TitleLogo` | `USER_LOCKED` → `CANON_REGISTERED` → `IMPLEMENTED` → `MACHINE_VERIFIED` 2026-08-31; source copied hash-identically; Godot 4.7.1 import/editor parse/300-frame main smoke, focused title/start/MVP-2 GUT `15/15` / `193`, and full GUT `580/580` / `6455` pass; runtime-render/Human/device evidence `NOT_RUN` |
| `NINJA_RUNTIME_TITLE_SCREEN_MOONLIT_NINJA_02` | `assets/runtime/ui/title_screen_moonlit_ninja_v2.png` | `86f86da33986499bfd98aa003ba52ac65105136197d4530aa3335c9b8f2e030c` | PNG, 1672×941, opaque 16:9 painterly title backdrop; the moonlit fixed ninja, moon and distant temples remain while the left title field has no baked medal | `scenes/ui/title_screen.tscn` → `TitleScreen/Backdrop` | `USER_LOCKED` → `CANON_REGISTERED` → `IMPLEMENTED` → `MACHINE_VERIFIED` 2026-08-31; built-in image-model edit of the user-locked v1 backdrop; Godot import/editor parse/300-frame main smoke, focused title/start GUT `3/3` / `68`, full GUT `586/586` / `6587` pass; runtime-render/Human/device evidence `NOT_RUN` |
| `NINJA_RUNTIME_TITLE_FOUR_TRADITIONS_MEDAL_02` | `assets/runtime/ui/title_four_traditions_medal_v2.png` | `26520188d71f9565fef0263062dcbab6ce23f4998371f55af765c034257c61cc` | PNG, 1254×1254, RGBA transparent standalone title medal; four readable traditions join in gold seams around one core: seal/familiar, reaction geometry, oni, shadow/shuriken | `scenes/ui/title_screen.tscn` → `TitleScreen/TitleMedal` | `USER_LOCKED` → `CANON_REGISTERED` → `IMPLEMENTED` → `MACHINE_VERIFIED` 2026-08-31; built-in image model, alpha-corner sample `0/0/1/0`; Godot import/editor parse/300-frame main smoke, focused title/start GUT `3/3` / `68`, full GUT `586/586` / `6587` pass; runtime-render/Human/device evidence `NOT_RUN` |
| `NINJA_RUNTIME_TITLE_SCREEN_FOUR_TRADITIONS_MEDAL_01` | `assets/runtime/ui/title_screen_four_traditions_medal_v1.png` | `346cb396a0d9236c5818933e2e46dde4f0b904cdf56d58104f175e1c536ece9f` | PNG, 1672×941, opaque 16:9 historical title-screen key art with a baked four-piece medal | historical provenance/rollback only after DEC-041 v2 separate-medal transition; no direct current consumer | `USER_LOCKED` → `CANON_REGISTERED` → `HISTORICAL_ROLLBACK_SOURCE`; previous machine evidence is retained as history and does not prove the v2 composition |
| `NINJA_RUNTIME_BATTLEFIELD_FLOOR_TILE_01` | `assets/runtime/visual-core/moonlit_battlefield_floor_tile_v1.png` | `ceb6e50ce6acc650f4a6e534ae2244e5f0aeae498fa9cefa150c98b2f510d700` | PNG, 1254×1254, opaque top-down cracked-stone floor tile | `scenes/main/main_scene.tscn` → `Main/BattlefieldBackdrop/FloorTile` | `USER_LOCKED` 2026-08-30; implemented on the current isolated branch; full GUT and scoped live render/input verified; not merged; Human/device evidence `NOT_RUN` |
| `NINJA_RUNTIME_BATTLEFIELD_PROP_ATLAS_01` | `assets/runtime/visual-core/moonlit_battlefield_prop_atlas_v1.png` | `0fff1db64a034374d281ba000f751f6cf9efb87bea94ad6612e002cce6a34f98` | PNG, 1265×1243, RGBA transparent four-region sparse-prop atlas; every consumer clips filtered sampling to its assigned region | `scenes/main/main_scene.tscn` → `Main/BattlefieldProps/{Lantern,DeadTree,Rocks,TalismanStele}` | `USER_LOCKED` 2026-08-30; implemented on the current isolated branch; full GUT and scoped live render/input verified; not merged; Human/device evidence `NOT_RUN` |
| `NINJA_RUNTIME_CONTACT_SHADOW_01` | `assets/runtime/visual-core/runtime_contact_shadow_v1.png` | `fbba1279ff8dc257a7c5d382be89335f3bf9b31de6463d89bcccd88ed69f5458` | PNG, 1254×1254, RGBA transparent soft horizontal contact-shadow source | `Player`, `EnemyBasic`, `StageBoss` → `GroundShadow` | `USER_LOCKED` 2026-08-30; implemented on the current isolated branch; full GUT and scoped live render/input verified; not merged; Human/device evidence `NOT_RUN` |
| `NINJA_RUNTIME_BASIC_WEAPON_EFFECTS_01` | `assets/runtime/visual-core/basic_weapon_effects_v1.png` | `728aff2ed85e233a0adcc195406a9a101b0933da8990078cced1af59c9eaf58a` | PNG, 1774×887, RGBA transparent two-region atlas: left katana slash, right black-steel shuriken | `scripts/combat/basic_weapon_controller.gd` → temporary katana effect; `scenes/projectiles/shuriken_projectile.tscn` → `Visual` right-region clip | `USER_LOCKED` 2026-08-30; isolated-branch implementation; Godot import/parse/main smoke + full GUT `555/555`, `6130` asserts pass; scoped desktop crowd/HUD render observed; not merged; individual weapon-readability/Human/device/balance `NOT_RUN` |
| `NINJA_RUNTIME_ENCOUNTER_BONGMA_MOBILE_ARRAY_CASTER_01` | `assets/runtime/encounters/actors/mobile_array_caster.png` | `1e145d6e00a0322c894cc3b1384a65c9d225b16a700093dd76eb205efd62fbfd` | PNG, 1024×1536, RGBA transparent cutout; built-in image model; final prompt and alpha receipt below | `SchoolEncounterActor/Visual` when `definition.actor_id == mobile_array_caster` | `USER_LOCKED` 2026-08-31; source hash, import and shared focused actor-manifest binding `4/4`, `29` asserts verified; exact-head full GUT `578/578`, `6408` asserts; runtime/Human/device `NOT_RUN` |
| `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_ARRAY_MASTER_01` | `assets/runtime/encounters/actors/hundred_demon_array_master.png` | `b97f20076b64e0e84eef2714e5d5551a49648ea97b0583226b31f220d5b9527c` | PNG, 1254×1254, RGBA transparent Boss cutout; alpha `0..255`, non-transparent bbox `(0,0,1221,1253)`; built-in image model | `EncounterCatalog` → `SchoolEncounterActor/Visual` only for `hundred_demon_array_master`, scale `0.09` | `USER_LOCKED` 2026-08-31; source copied hash-identically; Godot import and focused source/manifest/binding `4/4`, `29` asserts; exact-head full GUT `578/578`, `6408` asserts; runtime/Human/device `NOT_RUN` |
| `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_FAMILIAR_01` | `assets/runtime/encounters/summons/bongma_hundred_demon_familiar.png` | `50cbecfe6982e53537d4caaa731bc06c3e56c95bbf0be6084c2550571176ea75` | PNG, 1254×1254, RGBA transparent familiar cutout; alpha `0..255`, non-transparent bbox `(113,94,1191,1227)`; built-in image model | `SchoolEncounterActor/EncounterProxy/Visual` for a Bongma `summon_or_proxy`, scale `0.03`, no tint | `USER_LOCKED` 2026-08-31; source copied hash-identically; Godot import and focused delayed-proxy binding `5/5`, `23` asserts; exact-head full GUT `578/578`, `6408` asserts; runtime/Human/device `NOT_RUN` |
| `NINJA_RUNTIME_BATTLEFIELD_MOONLIT_01` | `assets/runtime/visual-core/moonlit_battlefield_backdrop_v1.png` | `e5ec25a1429399be7a6ae3f930a5162ab4a935083051f7c2388724921ed9b0fd` | PNG, 1672×941, opaque 16:9 background | historical `Main/BattlefieldBackdrop` direct binding; no current-branch direct consumer | generated v1; migration snapshot preserved; merged main; retained as historical source after the current-branch floor replacement |
| `NINJA_RUNTIME_CHEONSUL_FLAME_FIELD_01` | `assets/runtime/visual-core/cheonsul_flame_field_v1.png` | `cbb4b1e697f69bf37731f14a32c8ad3890d1557c5ee7ea2ebeb4b2f4f81b3e68` | PNG, 1269×1240, RGBA transparent runtime field texture | `scripts/schools/cheonsul_runtime.gd` → runtime `Cheonsul/FlameFieldVisual` | generated v1; migration snapshot preserved; merged main `6d538fc…` |
| `NINJA_RUNTIME_BOSS_CHEONSUL_01` | `assets/runtime/visual-core/cheonsul_stage_boss_v1.png` | `d787a4f4d1f646f14641b624a489dbb57dede57cfad8fd2625c8bfe227a9a39f` | PNG, 1224×1285, RGBA, transparent corners | `scenes/enemies/stage_boss.tscn` → `StageBoss/Visual` | generated v1; migration snapshot preserved |
| `NINJA_RUNTIME_PROJECTILE_TALISMAN_01` | `assets/runtime/visual-core/talisman_projectile_v1.png` | `bdaa04e5ed46442fa4672838d5f4f340a324caf6de6e7b85dee3becd8de9a809` | PNG, 1536×1024, RGBA, transparent corners | active `scenes/rewards/trace_pickup.tscn` → `TraceVisual` | generated v1; migration snapshot preserved; the retired generic basic-projectile scene is not repurposed as the DEC-039 shuriken |
| `NINJA_RUNTIME_REWARD_ORB_01` | `assets/runtime/visual-core/golden_reward_orb_v1.png` | `1464d9526123148443a8907a2110c539a2b6f446604cd7cc259f70e6ad7dcd1c` | PNG, 1278×1230, RGBA, transparent corners | `scenes/rewards/reward_orb.tscn` → `RewardOrb/Visual` | generated v1; migration snapshot preserved |
| `NINJA_RUNTIME_FAMILIAR_BONGMA_01` | `assets/runtime/visual-core/bongma_familiar_v1.png` | `64f1b9da399ba66db8e23ec8ae4251436dfe01ab00ef5fc44fa58c747b0818da` | PNG, 1536×1024, RGBA, transparent corners | `scenes/schools/bongma_familiar.tscn` → `BongmaFamiliar/Visual` | generated v1; migration snapshot preserved |
| `NINJA_GENERIC_YOKAI_CURSED_LANTERN_01` | `assets/runtime/visual-core/cursed_lantern_v1.png` | `57fa26d65cabf29d2b1bfb5eab90e27ea717a4647ee1a43f083b421d0318d618` | PNG, 1254×1254, RGBA, transparent corners | `scenes/enemies/enemy_basic.tscn` → variant pool | approved original; exact SHA verified |
| `NINJA_GENERIC_YOKAI_SHADOW_BEAST_01` | `assets/runtime/visual-core/shadow_beast_v1.png` | `97124c7e935efc667f8205143ea46a89a9be6ecc3a8af4a74ed60634f29c89e1` | PNG, 1254×1254, RGBA, transparent corners | `scenes/enemies/enemy_basic.tscn` → variant pool | approved replacement; exact SHA verified |
| `NINJA_GENERIC_YOKAI_FLAME_NINJA_01` | `assets/runtime/visual-core/flame_ninja_v1.png` | `d4660883354ffe1e6e854541237c69b9e087fbb1edc2ce9d76239d29c257839e` | PNG, 1254×1254, RGBA, transparent corners | `scenes/enemies/enemy_basic.tscn` → variant pool | approved replacement; exact SHA verified |

### DEC-041 v2 title asset receipts

- User approval: `USER_LOCKED` — user message `승인`, 2026-08-31 KST.
- Generation method: built-in image model; no paid API, third-party asset, or external binary was introduced.
- Backdrop edit source: the user-locked
  `title_screen_four_traditions_medal_v1.png`; the approved edit removes only
  its baked medal and preserves the moonlit ninja, moon, distant temples,
  painterly ink framing, and dark navy title field.
- Medal prompt contract: a one-to-one transparent circular title emblem with
  four gold-joined segments — 봉마 seal/familiar, 천술 reaction geometry,
  귀인 oni, and 흑영 shadow/shuriken — without text, UI frame, character, or
  background.
- Source handling: both generated files were copied without overwrite into
  their repository-local v2 paths; SHA-256 readback matches the locked source
  receipt. The v1 baked-medal background remains a rollback/provenance source
  and is not deleted.
- Actual composition: `TitleScreen/Backdrop` owns only the medal-free key art;
  `TitleScreen/TitleMedal` is a smaller `TextureRect` overlay immediately right
  of the existing title logo, with pointer input ignored.

### DEC-040 locked runtime asset receipts

- Asset ID: `NINJA_RUNTIME_ENCOUNTER_BONGMA_MOBILE_ARRAY_CASTER_01`
- User approval: `USER_LOCKED` — user message `승인`, 2026-08-31 KST.
- Generation method: built-in image model.
- Source handling: generated source was checked as `1024×1536` RGBA; alpha extrema
  `0..254`, each corner alpha `0`, and the copied repository file has the exact
  SHA-256 above. The approved source was copied once into the canonical catalog
  path without replacing an existing project file.
- Consumer intent: `EncounterCatalog.actor_definition_for(&"mobile_array_caster")`
  supplies this exact path to `SchoolEncounterActor/Visual`. It is a Bongma
  Elite (mid-boss), not a generic Core pool member and not a Boss.
- Final prompt:

```text
Use case: stylized-concept
Asset type: Godot 2D survival-action game runtime enemy candidate, single transparent PNG cutout for the Bongma school Elite named "Mobile Array Caster".
Primary request: Create exactly one full-body corrupted ninja-yokai Elite, distinct from a normal Core enemy and not a giant generic boss. A mid-boss silhouette: tall hovering exorcist in damaged black and deep-navy shrine robes, asymmetrical brass talisman frames, torn sealing papers, one small bound shikigami mask orbiting at the shoulder, a portable broken barrier-ring behind the back. The face is a cracked wooden demon mask with one cold blue eye; long clawed hands. It should look like an enemy that lays down a telegraphed moving seal zone.
Scene/backdrop: genuinely transparent RGBA background only; no floor, no scenery, no parchment, no UI.
Style/medium: premium dark moonlit Korean ninja fantasy; painterly anime ink rendering with readable C-leaning SD runtime proportions, closely aligned to a black/deep-navy/red/warm-gold game palette; restrained blue Bongma accent; crisp separated silhouette, practical for a contact shadow beneath at runtime.
Composition/framing: one centered whole character in a clear 3/4 top-down gameplay-facing stance; entirely inside canvas with generous transparent margin; no cropped limbs; strong silhouette at small size.
Lighting/mood: cold moonlit rim light, controlled blue spectral glow only around the sealing papers and small companion.
Constraints: one character only; transparent background; no text, no letters, no logo, no watermark, no border, no pasted UI, no multi-panel sheet, no player ninja, no generic wolf or lantern, no visible baked ground shadow. Avoid photorealism, over-detailed key-art composition, chibi baby proportions, bright rainbow effects, and copied characters.
```

- Asset IDs: `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_ARRAY_MASTER_01`
  and `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_FAMILIAR_01`.
- User approval: `USER_LOCKED` — user message `승인`, 2026-08-31 KST.
- Generation method: built-in image model. The user-provided array-caster
  illustration remained a reference only; neither new runtime source is a copy
  of it.
- Source handling: both candidate files passed direct RGBA alpha inspection
  before promotion. The Boss has alpha `0..255`, corner alpha `0,0,1,0`, and
  the Familiar has alpha `0..255`, corner alpha `0,0,0,0`. Each canonical
  repository file was copied once without replacing an existing source and has
  the exact SHA-256 recorded in the table above.
- Consumer intent: `EncounterCatalog.actor_definition_for(&"hundred_demon_array_master")`
  supplies the Boss cutout to `SchoolEncounterActor/Visual`; only that actor
  receives the intentional `0.09` presentation scale. `summon_or_proxy`
  requests made by a Bongma `SchoolEncounterActor` use the independent Familiar
  cutout at `0.03` scale with `Color.WHITE`, preserving its blue eye and paper
  accents. It is not the existing player-side `BongmaFamiliar` source.
- Final Boss prompt:

```text
Godot 2D survival-action runtime Boss cutout, exactly one transparent PNG: a
corrupted fox-oni masked Bongma ritualist in deep navy and black torn shrine
robes, red cords and warm bronze mobile seal-array frame, blue spectral eye,
talismans and one small bound fox shikigami. Premium painterly anime ink with
readable SD runtime proportions, whole figure inside the canvas, no ground,
text, logo, UI, watermark, or copied character.
```

- Final Familiar prompt:

```text
Godot 2D survival-action summon cutout, exactly one transparent PNG: a small
floating bound fox-mask shikigami with one blue eye, folded navy paper-robes,
torn talisman wings/tails, a tiny gold bell and red cords. Match the Bongma
Boss palette and painterly anime-ink SD runtime style; no ground, text, logo,
UI, watermark, or copied character.
```

## Binding rules

- The one fixed player identity and its existing IMG-01 source textures remain
  preserved. DEC-039 removes only the current `Player/Visual` Attack consumer;
  Move/Hit remain the player-body runtime states, and separate weapon effects
  render automatic attacks.
- The generic enemy trio remains a generic corrupted-yokai pool; none is a
  school Boss or maps to a school identity.
- This package adds the existing Cheonsul flame-field visual consumer only. It
  does not add dynamic ward, reaction, Guiin sword aura, or Heukyeong
  ground-shadow texture consumers.
- `EnemyVisualVariant` selects from the three already approved generic-yokai
  textures only and does not change enemy stats, spawn counts, or combat rules.
- `NINJA_RUNTIME_BATTLEFIELD_MOONLIT_01` remains an immutable historical
  source in the repository, but the current isolated-branch `Main` scene no
  longer consumes it directly. `Parallax2D` repeats
  `NINJA_RUNTIME_BATTLEFIELD_FLOOR_TILE_01` behind gameplay instead.
- The 2026-08-30 sparse-prop atlas and contact-shadow image candidates are
  now user-locked assets. `BattlefieldProps` is a separate repeating visual
  layer over the floor and below units; its four `Sprite2D` children use the
  atlas regions with `region_filter_clip_enabled = true`, without colliders,
  scripts, or gameplay authority.
- `GroundShadow` is a `Sprite2D` child of the Player, generic EnemyBasic, and
  StageBoss scenes. It renders behind each existing `Visual` sprite and does
  not alter movement, collision, damage, target selection, or stats.
- `NINJA_RUNTIME_BASIC_WEAPON_EFFECTS_01` is one user-locked atlas with two
  bounded consumers. Its left region is an ephemeral katana effect owned by
  `BasicWeaponController`; its right region is clipped by `ShurikenProjectile`.
  Neither changes the player body pose, existing selected-school ninjutsu
  ownership, enemy movement, route, reward, Backpack, or Fate authority.
- `NINJA_RUNTIME_ENCOUNTER_BONGMA_MOBILE_ARRAY_CASTER_01` is the first
  individually user-locked DEC-040 actor asset. `SchoolEncounterActor` uses
  the fixed catalog path whenever the `mobile_array_caster` definition is
  configured; it does not call the generic enemy variant selector. The other
  DEC-040 actor, ninjutsu, and telegraph paths remain unapproved future
  candidates and retain only the implementation's existing fallback behavior;
  they are not represented as registered runtime art.
- `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_ARRAY_MASTER_01` is a Boss-only
  actor cutout. It does not alter the Boss's health, move speed, patterns,
  telegraph duration, rewards, Trace gate, Workbench gate, collisions or
  normal-enemy horde behavior.
- `NINJA_RUNTIME_ENCOUNTER_BONGMA_HUNDRED_DEMON_FAMILIAR_01` replaces only the
  visible source of an already-existing Bongma `summon_or_proxy` delayed hazard.
  Its arm time, life, radius, damage resolution and other-school generic
  fallback behavior remain unchanged.

## Evidence required before durable closeout

1. Godot import, parser, main-scene smoke, and full GUT on the exact PR head.
2. Repository source, SHA-256, explicit user approval and actual consumer for
   every generated image. Historical migration snapshots remain provenance
   receipts where they existed before DEC-035; they are not a gate for new
   repository-owned images.
3. After merge, exact new-main readback and post-merge Godot verification.
