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
| `NINJA_RUNTIME_BATTLEFIELD_MOONLIT_01` | `assets/runtime/visual-core/moonlit_battlefield_backdrop_v1.png` | `e5ec25a1429399be7a6ae3f930a5162ab4a935083051f7c2388724921ed9b0fd` | PNG, 1672×941, opaque 16:9 background | `scenes/main/main_scene.tscn` → `Main/BattlefieldBackdrop` | generated v1; migration snapshot preserved; merged main |
| `NINJA_RUNTIME_CHEONSUL_FLAME_FIELD_01` | `assets/runtime/visual-core/cheonsul_flame_field_v1.png` | `cbb4b1e697f69bf37731f14a32c8ad3890d1557c5ee7ea2ebeb4b2f4f81b3e68` | PNG, 1269×1240, RGBA transparent runtime field texture | `scripts/schools/cheonsul_runtime.gd` → runtime `Cheonsul/FlameFieldVisual` | generated v1; migration snapshot preserved; merged main `6d538fc…` |
| `NINJA_RUNTIME_BOSS_CHEONSUL_01` | `assets/runtime/visual-core/cheonsul_stage_boss_v1.png` | `d787a4f4d1f646f14641b624a489dbb57dede57cfad8fd2625c8bfe227a9a39f` | PNG, 1224×1285, RGBA, transparent corners | `scenes/enemies/stage_boss.tscn` → `StageBoss/Visual` | generated v1; migration snapshot preserved |
| `NINJA_RUNTIME_PROJECTILE_TALISMAN_01` | `assets/runtime/visual-core/talisman_projectile_v1.png` | `bdaa04e5ed46442fa4672838d5f4f340a324caf6de6e7b85dee3becd8de9a809` | PNG, 1536×1024, RGBA, transparent corners | `scenes/projectiles/projectile_basic.tscn` → `ProjectileBasic/Visual` | generated v1; migration snapshot preserved |
| `NINJA_RUNTIME_REWARD_ORB_01` | `assets/runtime/visual-core/golden_reward_orb_v1.png` | `1464d9526123148443a8907a2110c539a2b6f446604cd7cc259f70e6ad7dcd1c` | PNG, 1278×1230, RGBA, transparent corners | `scenes/rewards/reward_orb.tscn` → `RewardOrb/Visual` | generated v1; migration snapshot preserved |
| `NINJA_RUNTIME_FAMILIAR_BONGMA_01` | `assets/runtime/visual-core/bongma_familiar_v1.png` | `64f1b9da399ba66db8e23ec8ae4251436dfe01ab00ef5fc44fa58c747b0818da` | PNG, 1536×1024, RGBA, transparent corners | `scenes/schools/bongma_familiar.tscn` → `BongmaFamiliar/Visual` | generated v1; migration snapshot preserved |
| `NINJA_GENERIC_YOKAI_CURSED_LANTERN_01` | `assets/runtime/visual-core/cursed_lantern_v1.png` | `57fa26d65cabf29d2b1bfb5eab90e27ea717a4647ee1a43f083b421d0318d618` | PNG, 1254×1254, RGBA, transparent corners | `scenes/enemies/enemy_basic.tscn` → variant pool | approved original; exact SHA verified |
| `NINJA_GENERIC_YOKAI_SHADOW_BEAST_01` | `assets/runtime/visual-core/shadow_beast_v1.png` | `97124c7e935efc667f8205143ea46a89a9be6ecc3a8af4a74ed60634f29c89e1` | PNG, 1254×1254, RGBA, transparent corners | `scenes/enemies/enemy_basic.tscn` → variant pool | approved replacement; exact SHA verified |
| `NINJA_GENERIC_YOKAI_FLAME_NINJA_01` | `assets/runtime/visual-core/flame_ninja_v1.png` | `d4660883354ffe1e6e854541237c69b9e087fbb1edc2ce9d76239d29c257839e` | PNG, 1254×1254, RGBA, transparent corners | `scenes/enemies/enemy_basic.tscn` → variant pool | approved replacement; exact SHA verified |

## Binding rules

- The one fixed player identity and its existing IMG-01 Move/Attack/Hit textures
  are untouched.
- The generic enemy trio remains a generic corrupted-yokai pool; none is a
  school Boss or maps to a school identity.
- This package adds the existing Cheonsul flame-field visual consumer only. It
  does not add dynamic ward, reaction, Guiin sword aura, or Heukyeong
  ground-shadow texture consumers.
- `EnemyVisualVariant` selects from the three already approved generic-yokai
  textures only and does not change enemy stats, spawn counts, or combat rules.

## Evidence required before durable closeout

1. Godot import, parser, main-scene smoke, and full GUT on the exact PR head.
2. Repository source, SHA-256 and migration snapshot for every generated image.
3. After merge, exact new-main readback and post-merge Godot verification.
