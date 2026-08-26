# GPT Work Image Goal Handoff — 2026-08-26

> Purpose: durable handoff for continuing Ninja Survival / 닌자의 신 visual-asset planning and production in ChatGPT Work without relying on the prior chat transcript.

```yaml
handoff_status: READY_FOR_GPT_WORK
prepared_at: 2026-08-26_KST
project: NINJA_SURVIVAL
repository: alsdmlals4-eng/ninja-survival-godot
prepared_from_main: 3c3e622aa8932cda7e9e926bf95aba3bd5122631
protected_open_pr: 49
protected_pr_state: OPEN_DRAFT_READ_ONLY_FOR_VISUAL_WORK
current_product_sequence: T12 -> T13 -> T14_CHEONSUL_SLICE -> T15_HUMAN_QA -> T16_REMAINING_SCHOOLS -> T17_FOUR_SCHOOL_CIRCUIT -> T18_FINAL_CALAMITY -> T19_FULL_RUN
image_goal_rule: ACTUAL_GAME_CONSUMER_REQUIRED
image_batch_default: 3_WHEN_ONE_APPROVED_GOAL_PACKET_SUPPORTS_IT
new_image_generation_on_resume: FORBIDDEN_UNTIL_GOAL_TEXT_AND_USER_REQUEST
trace_visual_rule_current_user_override: ONE_STAGE_ONLY
```

## 1. Authority and fresh-read order

On GPT Work resume, do not reconstruct current truth from this handoff alone. Read in this order:

1. latest user instruction in the Work thread,
2. repository `AGENTS.md`,
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`,
4. `docs/ACTIVE_CONTEXT.md`,
5. this handoff,
6. `docs/CURRENT_VISUAL_HANDOFF.md` only as older visual history where it does not conflict with this handoff or newer user instruction,
7. current repository `main` + open PR inventory,
8. actual code / Scene / Resource / tests,
9. Notion `닌자 서바이벌 · Home`, `02 · 비주얼 바이블`, `03 · UI · 생존 Flow Map`, `04 · 에셋 라이브러리`, `06 · Production · Handoff`,
10. current Base owners when relevant.

If GitHub and Notion differ materially, set `CONTEXT_DRIFT_RECHECK_REQUIRED` before mutation.

## 2. Current product/runtime boundary

Current main observed during handoff: `3c3e622aa8932cda7e9e926bf95aba3bd5122631`.

T12 PR #49 `T12: atomic Workbench Fate route commit` is OPEN / DRAFT / NOT MERGED. Visual/Image Goal work must not modify, rebase, close, merge or absorb PR #49.

Current intended product sequence remains:

```text
T12 atomic Workbench + Fate + route commit
-> T13 Persistent Workbench route-preview UI/input
-> T14 Cheonsul one-school release-near Vertical Slice
-> T15 Human QA gate
-> T16 remaining three schools
-> T17 four-school circuit
-> T18 final calamity
-> T19 full-run verification
```

The first release-near encounter slice is **천술류**. Do not multiply all four schools before the T15 Human QA gate.

## 3. Current visual decisions — newest user-approved state

### Master direction

- Presentation / key art / lore: hand-drawn ink codex + mature dark painterly anime ninja fantasy.
- In-game: animation-forward 2–3 head SD anime + C-leaning dark painterly DNA.
- Core palette: black / deep navy / charcoal + restrained red / warm gold.
- Readability of player / enemy / hazard / projectile / pickup outranks decorative density.

### Runtime protagonist

One fixed ninja identity for the whole Run:

- same face,
- same hair,
- same body proportion,
- same core outfit identity,
- same base sword language unless product data deliberately changes equipment.

School traces change **surrounding presentation only**, not the body/face/costume identity.

### Latest trace simplification — USER OVERRIDE

Older `MAIN_SCHOOL_STAGE_3_ONLY` visual-expansion material is superseded for current image production by the newest user decision:

```text
SCHOOL_TRACE_VISUALS = ONE_STAGE_ONLY
```

Current simple trace language:

- 봉마류: small cute spirit-like shikigami floating near the player; multiple different spirit appearances are allowed; do not multiply talismans for level progression.
- 천술류: chakra energy spreading around the same character.
- 귀인류: blood-red energy gathering on the sword the player is already holding.
- 흑영류: black/dark energy appearing on the ground around the same character.

Trace explanation sheets are not the production priority. Use these only when a real runtime consumer exists.

## 4. Visual Master / reference status

### Visual Master — approved reference

The user explicitly chose the **first progression image** over later Lv1/Lv3 sheets as the strongest overall visual direction.

Current local-session source observed during handoff:

```yaml
role: VISUAL_MASTER_REFERENCE_ONLY
local_path: /mnt/data/37ec8a48-936a-4a60-ad5c-d2410bc9b052.png
dimensions: 1672x941
mode: RGBA
sha256: efd1c90ae4849a709ce08d6f6777ce938768a8b223d885aa106f82f7dd51b125
notion_durable_original: NOT_REGISTERED_IN_THIS_HANDOFF
runtime_asset: false
```

Use it for growth fantasy, palette, IP continuity and overall emotional target. Do not treat the five figures as five runtime characters or as a sprite atlas.

## 5. Current generated production-candidate inventory

These files were generated in the prior chat. Their bytes are currently known only through that chat/runtime unless separately uploaded later. Do not claim durable availability from this Markdown record alone.

### A. Player base candidate — USER APPROVED

```yaml
status: APPROVED
implementation_ready: NO
local_path: /mnt/data/3d_어두운_닌자_검사_캐릭터_sprites.png
dimensions: 1254x1254
mode: RGBA
sha256: ea5f851f2e051a991f095f18d480e1e480d9495d4c4d3a9cb6d026b1a20d9316
actual_consumer: scenes/player/player.tscn
current_consumer_visual: Polygon2D_placeholder
notion_registered_original: NO
runtime_implemented: NO
runtime_verified: NO
reuse_decision: REUSE_AS_IS_AS_IDENTITY_ANCHOR
```

The user liked and approved this player design. Future Move / Attack / Hit images must preserve this exact character identity.

### B. Generic enemy candidate 01 — USER APPROVED

```yaml
status: APPROVED
implementation_ready: NO
local_path: /mnt/data/붉은_불꽃의_요괴_닌자습격.png
dimensions: 1254x1254
mode: RGBA
sha256: 30ce5c2bb23f7ecc8d138c629b67c87747cf0a34eae825145f76c349bb742fc7
reuse_decision: ADAPT
```

### C. Generic enemy candidate 02 — USER APPROVED

```yaml
status: APPROVED
implementation_ready: NO
local_path: /mnt/data/붉은_눈의_그림자_요괴_pstmt.png
dimensions: 1254x1254
mode: RGBA
sha256: ff7b59dafb5fa65a801d8eaf09aa9c47ef8ea7ff53b8d049e92663fbb791c75b
reuse_decision: ADAPT
```

### D. Generic enemy candidate 03 — USER APPROVED

```yaml
status: APPROVED
implementation_ready: NO
local_path: /mnt/data/저주받은_붉은_등불_요괴.png
dimensions: 1254x1254
mode: RGBA
sha256: f733fa41b76b963c81d923307dec324c5c904259ea721ea0152c1f2c8bffebc6
reuse_decision: ADAPT
```

Important: the three generic enemy candidates were approved as useful enemy designs, but **must not be silently mapped to Cheonsul Core Monster IDs**. Exact Cheonsul roles remain separate canon.

### E. Elite three-design sheet — DRAFT / NOT YET APPROVED

```yaml
status: DRAFT
local_path: /mnt/data/a_clean_digital_illustration_game_asset_sheet_on.png
dimensions: 1536x1024
mode: RGBA
sha256: ffce9c7defe79412ad1bbb34f036e4a08a978ce1aa87e6c0628c83eaf25ac5a0
reuse_decision: REUSE_WITH_EDIT
```

It contains three elite-looking candidates in one composite image. It is **not** three independent runtime-ready sprite files and did not receive a user approval after generation.

The user's correction is explicit: this general corrupted-yokai direction may be used for **Elite**, not for a generic Stage Boss.

## 6. Boss boundary — protected

School Bosses are school-specific.

Current exact encounter roster from `EncounterCatalog`:

### 봉마류
- Core: `seal_chaser` / 봉인 추적자
- Core: `shikigami_handler` / 식신 사역자
- Core: `barrier_carrier` / 결계 운반자
- Elite: `mobile_array_caster` / 이동진 술사
- Boss: `hundred_demon_array_master` / 백귀진 주재자

### 천술류
- Core: `fire_mark_caster` / 화인 술사
- Core: `water_vein_caster` / 수맥 술사
- Core: `lightning_chain_caster` / 뇌쇄 술사
- Elite: `five_element_tuner` / 오행 조율자
- Boss: `heavenly_change_taoist` / 천변 도사

### 귀인류
- Core: `surge_fighter` / 쇄도 권객
- Core: `pressure_monk` / 압박 승병
- Core: `ghost_blood_chaser` / 귀혈 추적자
- Elite: `melee_chaos_captain` / 난전 대장
- Boss: `ghost_general` / 귀신장

### 흑영류
- Core: `shuriken_scout` / 표창 척후
- Core: `poison_shadow_assassin` / 독영 살수
- Core: `dark_mark_pursuer` / 암표 추격자
- Elite: `shadow_chief` / 그림자 두령
- Boss: `night_executioner` / 야행 처형자

Do not use one generic `stage_boss` visual for all schools in final Slice content.

## 7. Current actual image consumers / placeholders

Repository `assets/sprites/` contains no production sprites; only `.gitkeep` was present at this handoff.

Current real placeholder consumers:

```text
scenes/player/player.tscn                 -> Polygon2D placeholder
scenes/enemies/enemy_basic.tscn          -> Polygon2D placeholder
scenes/enemies/stage_boss.tscn           -> Polygon2D generic legacy placeholder
scenes/schools/bongma_familiar.tscn      -> Polygon2D placeholder
scenes/projectiles/projectile_basic.tscn -> Polygon2D placeholder
scenes/rewards/reward_orb.tscn           -> Polygon2D placeholder
```

Cheonsul runtime currently uses procedural/placeholder visuals:

- Flame field: generated `Polygon2D` circle.
- Status display: text Label badge for BURN / WET / SHOCK.

Current HUD / REST / School Selection UI are mainly native Godot Labels / Buttons / Containers, not image-driven skins. ItemDefinition currently has no icon/texture field. Therefore decorative HUD art and full backpack icon production are not P0 yet.

## 8. Remaining Image Goal queue

### IMG-01 — Player Runtime Core — P0

**Player/Product Goal:** Player silhouette/action remains readable under enemy and VFX pressure.

**Actual Consumer:** `scenes/player/player.tscn`.

**Existing Reference:** approved player base candidate; `REUSE_AS_IS` as identity anchor.

**Required new image batch — 3:**

1. Move
2. Attack
3. Hit

Base/Idle is already approved and must not be redrawn without a revision finding.

**Must Preserve:** exact approved face, hair, outfit, sword, body proportion, palette.

**Must Not Introduce:** trace layers, alternate weapons, school costume variants, new protagonist identity.

**Acceptance:** same character in all three; readable at actual runtime scale; transparent; animation-consumable composition.

### IMG-02 — Common Combat Objects — P0

**Actual Consumers:** `projectile_basic.tscn`, `reward_orb.tscn`, planned T14 Trace pickup scene.

**Required assets — 3:**

1. basic projectile
2. Reward Orb
3. school Trace world pickup

Trace must be visually distinct from RewardOrb and must not look like a direct-stat power pickup.

### IMG-03 — Cheonsul Encounter Roster — P0/P1

First production school only.

**Required assets — 5:**

1. 화인 술사
2. 수맥 술사
3. 뇌쇄 술사
4. 오행 조율자 — Elite
5. 천변 도사 — Boss

Efficient generation packaging: first batch 3 Core, then batch 2 Elite/Boss after Core review.

Do not map the existing three generic approved enemies to these IDs without an explicit ADAPT decision.

### IMG-04 — Cheonsul Telegraph / VFX — P0/P1

**Actual/runtime target:** T14 Cheonsul slice; current placeholders already exist in `CheonsulRuntime` / `EnemyEffectBadge`.

Required assets:

1. elemental arc projectile
2. telegraphed elemental zone atlas (warning / active / expiry)
3. elemental mark/link
4. wet+shock reaction impact
5. BURN/WET/SHOCK status badge icon sheet

Telegraph readability is more important than effect density.

### IMG-05 — Four School Emblems — P1

**Consumer:** current `school_selection_ui.tscn`, later Route Preview/HUD/Workbench.

Required assets — 4:

- 봉마류
- 천술류
- 귀인류
- 흑영류

Current generated sheet emblems are reference material, not separated production files.

### IMG-06 — Cheonsul Battlefield — P1 / GATED

Do not generate until T14 battlefield Scene/camera/consumer contract exists.

Planned assets:

1. battlefield ground/tile
2. ruin/environment prop atlas
3. boss-approach/arena visual layer

### IMG-07 / IMG-08 — Workbench item icons — P1 / GATED_BY_T13

Do not generate before T13 gives items a real icon/texture consumer.

Initial 10-item slice only: Universal 7 + Cheonsul 3. Split into two 5-asset packets when the consumer exists.

Do not pre-produce all 19 base items before this gate.

## 9. Deferred / not current Image Goals

Do not prioritize now:

- Lv1/Lv3 trace comparison sheets,
- school explanation infographics,
- all four schools' full encounter rosters,
- Bongma familiar variants before Cheonsul Slice/Human gate unless a current runtime test requires them,
- full 19-item icon set,
- five bag illustrations,
- decorative HUD frames,
- generated button skins,
- final calamity visuals,
- Final Binding environment,
- title/loading/Steam capsule/marketing package.

## 10. Image-production operating rule for GPT Work

For each Goal:

```text
fresh-read current canon + consumer
-> Existing Solution First
-> Goal text brief
-> user reviews/approves Goal
-> generate only the requested batch
-> result review
-> explicit approval/revision
-> durable Notion original registration
-> mark IMPLEMENTATION_READY only when source bytes/provenance/consumer are resolved
-> write Codex Integration Goal
-> Codex import/wire/run/test/capture
-> runtime verification
```

User efficiency preference for current visual production:

```text
DEFAULT_GENERATION_BATCH = 3
```

This overrides the older one-result-per-generation handoff only when the three images belong to one approved Goal packet. Do not use batching to silently expand scope.

## 11. Codex Integration Goal queue

### CODEX-IMG-01 — Player Runtime Art Integration

Goal: replace player visual placeholder with approved player runtime art while preserving movement/combat/collision behavior.

Inputs:
- approved player base,
- approved Move / Attack / Hit,
- Notion registered original records,
- `scenes/player/player.tscn`,
- `scripts/player/player_controller.gd`,
- `scripts/combat/auto_attack_controller.gd`.

Scope:
- import,
- resource settings,
- Sprite2D/AnimatedSprite2D or justified equivalent,
- state wiring,
- scale/pivot,
- placeholder removal,
- exact tests,
- real run,
- screenshot evidence.

Non-scope:
- PR #49,
- combat-balance change,
- route/Fate/Workbench changes,
- school mechanic redesign.

Acceptance:
- approved art appears in actual gameplay,
- no clipping/stretch,
- collision/movement/autoattack regression = 0,
- runtime screenshot exists,
- actual target-scale readability reviewed.

### CODEX-IMG-02 — Common Combat Object Integration

Import/wire approved basic projectile + RewardOrb + Trace pickup visuals, preserving gameplay behavior and ensuring distinct silhouettes.

### CODEX-IMG-03 — Cheonsul Encounter Art Integration

Create/use distinct T14 Cheonsul Core×3 / Elite / Boss Scene consumers and wire approved art to the exact EncounterCatalog IDs.

### CODEX-IMG-04 — Cheonsul Telegraph/VFX Integration

Replace/augment current Polygon2D and Label placeholders with approved assets while preserving fair-telegraph contracts.

### CODEX-IMG-05 — School Emblem Integration

Wire four approved emblem files to school selection and later Route/HUD consumers without encoding game rules in art.

### CODEX-IMG-06 — Cheonsul Environment Integration

Only after T14 battlefield Scene/camera contract exists.

### CODEX-IMG-07/08 — Workbench Icon Integration

Only after T13 establishes item icon/texture consumers and exact item-cell layout.

## 12. Notion / binary transfer status at sender close

Current Notion visual authority pages:

- Human Home: `3c41b237-eb1c-81aa-a4e0-e208ba4fb15e`
- Visual Bible: `3c01b237-eb1c-8116-9028-c8c8c427e467`
- UI Flow Map: `3c01b237-eb1c-81a2-b859-c8155c90ca75`
- Asset Library page: `3c01b237-eb1c-81e6-9d5b-c467b5ad2b1e`
- Production Handoff: `3c01b237-eb1c-81b4-a3f5-ec575f3c77b5`

Legacy Hybrid previews in Notion remain `LEGACY_PREVIEW_NEEDS_ORIGINAL`.

The newly approved player/enemy PNG originals from this chat were **not durably uploaded to Notion or repository before this handoff document was created**. Their hashes and temporary local paths are recorded above only for traceability. GPT Work must not claim `Notion Registered`, `IMPLEMENTATION_READY`, or `Implemented` until actual original bytes are available in the new workspace and durable registration/readback succeeds.

## 13. Next exact action in GPT Work

```text
1. Fresh-read current main/open PR/Notion pages.
2. Confirm this handoff is not superseded.
3. Resolve durable bytes for the approved player base and three approved generic enemies.
4. Register the approved player base as a Notion original asset.
5. Present IMG-01 Move / Attack / Hit text brief using the approved player base as the hard identity anchor.
6. Wait for user approval/request.
7. Generate exactly the approved 3-image IMG-01 batch.
8. Review -> approve/revise -> Notion register originals.
9. Produce CODEX-IMG-01 handoff for Godot integration.
```

Do not generate a new image merely because the Work session has started.

## 14. Evidence ceiling

```text
PRODUCT_CANON: CURRENT_READBACK_CONFIRMED_AT_HANDOFF
PROJECT_MAIN: 3c3e622aa8932cda7e9e926bf95aba3bd5122631
T12: OPEN_DRAFT_PR_49_NOT_MERGED
PLAYER_BASE_IMAGE: USER_APPROVED_CHAT_ASSET_NOT_IMPLEMENTED
GENERIC_ENEMY_3: USER_APPROVED_CHAT_ASSETS_NOT_IMPLEMENTED
ELITE_3_COMPOSITE: DRAFT_NOT_USER_APPROVED
NEW_CHAT_IMAGES_NOTION_ORIGINAL_REGISTRATION: NOT_DONE
GAMEPLAY_PRODUCTION_SPRITES_IN_REPOSITORY: NONE_AT_HANDOFF
T14_CHEONSUL_RELEASE_NEAR_SLICE: NOT_RUN
HUMAN_USABILITY: NOT_RUN
PLAYER_EXPERIENCE: NOT_RUN
ANDROID_EXPORT: NOT_RUN
```
