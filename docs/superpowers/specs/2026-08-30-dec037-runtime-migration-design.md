# DEC-037 Runtime Migration Design

> **Status:** `USER_APPROVED_DESIGN / IMPLEMENTATION_SPEC_PENDING_USER_REVIEW`
> **Canon owner:** `docs/canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md`
> **Baseline:** `origin/main` `9855f9a5fa2e4297e3171a1b1903d3517719ad93`
> **Scope:** the first fresh-main runtime package after Human Blueprint publication: direct movement and dash, top-only combat HUD, public Stage/Phase presentation, and exact 3×3 starting backpack.

## 1. Goal

Make the approved public contract true in the Godot runtime without moving route, economy, spatial legality, Fate, combination, or combat-modifier authority into UI:

```text
one fixed Ninja is directly moved
-> automatic attacks and tradition effects react to position and committed build
-> the player reads Stage, lifecycle Phase, dash charges, and Run time
-> the player starts with exactly a 3×3 usable backpack
-> bags extend usable space inside the retained 6×6 technical ceiling
```

## 2. Included and excluded behavior

### Included

- Keyboard, mouse/pointer, gamepad, and touch paths feed one movement/dash intent contract.
- `PlayerController` owns dash charges, recovery, active-dash movement, and dash state signals.
- Combat HUD shows only top-level dash charges, active-play time, and a settings entry during normal combat.
- Settings presents `계속`, `현재 전승 도움말`, and `Run 재시작`; it is an intent surface, not a new gameplay owner.
- Player-facing destination wording is `스테이지`; per-battle progression is `페이즈 1–4`.
- The starting bag is a centered 3×3, nine-cell usable region; the technical outer board remains 6×6.
- Catalog, resolver/session, checkpoint/retry, HUD, and integration tests protect the migrated behavior.

### Explicit exclusions

- No manual basic attack, aim reticle, skill hotbar, new ultimate button, or automatic-reaction ownership change.
- No dash invulnerability, collision bypass, damage immunity, attack cancel, stamina economy, or new combat stat.
- No Final Binding, final calamity, full Ninja Soul true-end settlement, Human Usability, Player Experience, device/export, or release claim.
- No new raster asset is required. The approved player, floor, prop, and contact-shadow sources remain the visual baseline.
- No destructive rename of internal `school` identifiers, route snapshots, or existing save/checkpoint keys.

## 3. Design decisions

### 3.1 Direct movement and dash

`PlayerController` stays the only movement owner. It continues to use `CharacterBody2D` velocity and `move_and_slide()`; input adapters only supply direction and one dash request.

The first runtime tuning is deliberately narrow and data-visible:

| field | value | reason |
| --- | --- | --- |
| maximum dash charges | `2` | matches the requested charge-count display and allows one corrective escape without creating a stamina UI |
| dash duration | `0.20 s` | an identifiable reposition burst rather than a replacement movement mode |
| dash speed multiplier | `3.0×` current resolved move speed | preserves build-derived move-speed authority |
| recharge | one charge every `1.5 s` | readable recovery without a new resource type |
| allowed direction | non-zero current movement or pointer direction | prevents idle dash with undefined gameplay direction |
| collision | existing `move_and_slide()` collision response | prevents clipping and preserves enemy/body interaction rules |
| damage behavior | no immunity or prevention | avoids silently changing survival/economy balance |

The controller exposes a read-only presentation signal:

```gdscript
signal dash_state_changed(charges: int, maximum_charges: int)
signal dash_started(direction: Vector2)

func request_dash() -> bool
func current_dash_charges() -> int
```

Only the controller mutates these values. HUD code renders the signal payload and sends `dash_requested`; it never decrements or restores a charge.

### 3.2 Input convergence

`project.godot` owns named action bindings. `PlayerController` uses the actions and public pointer-target methods instead of polling separate hard-coded physical keys.

| player path | movement | dash | boundary |
| --- | --- | --- | --- |
| keyboard | Arrow keys and WASD through `move_left/right/up/down` | Left Shift or Space through `dash` | no manual attack binding |
| mouse/pointer | left press/drag supplies a world target; player stops inside a 12-pixel arrival radius | right press requests dash toward the active pointer direction | clicks consumed by UI do not set a target |
| gamepad | left stick and D-pad use the same move actions | south face button uses `dash` | deadzone belongs to InputMap |
| touch | device-only lower-left movement pad sends move actions | device-only lower-right dash button sends `dash` | these are movement inputs, not a skill hotbar |

The pointer path uses a target direction only while the target remains farther than the arrival radius. The touch path uses action buttons so it supports simultaneous movement plus dash, consistent with Godot gameplay touch input.

### 3.3 Top-only combat HUD and settings

Normal combat presents exactly this compact top bar:

```text
left:   DASH 2 / 2
center: PLAY 02:14
right:  설정
```

Existing persistent health, score, combo, style, reward, school resource, ultimate, test, and combat-guide surfaces do not remain in the normal combat layout. Game-over remains a terminal overlay.

Selecting `설정` opens a pause panel owned by `MainController` through UI intents. The panel has exactly three actions:

1. `계속` resumes the current game state.
2. `현재 전승 도움말` uses the existing selected-tradition help owner.
3. `Run 재시작` delegates to the existing restart intent.

Settings may not mutate Stage, Phase, backpack, route, Fate, economy, or dash values.

### 3.4 Stage and Phase presentation

Internal route depth and public lifecycle progress are separate concepts.

- `RunRouteState.stage_index()` remains the route/economy/checkpoint index. It is not renamed or displayed as the in-battle Phase.
- A pure presentation adapter maps `SchoolCircuitController.phase_changed` states to public Phase labels:

| circuit state | public display |
| --- | --- |
| `core` | `페이즈 1 · Core 압박` |
| `elite_warning`, `elite_active` | `페이즈 2 · Elite 접근` |
| `trace_available`, `trace_recovered`, `boss_warning` | `페이즈 3 · Trace 회수` |
| `boss_active` | `페이즈 4 · Boss 결전` |

The same adapter maps the selected tradition to the public Stage title, for example `스테이지 · 천술류 전장`. Workbench and terminal states hide the combat presentation rather than inventing another Phase.

### 3.5 Exact 3×3 starting backpack

`MVP4Catalog.STARTING_BAG_ID` remains `starting_ninja_bag`. Its definition changes from the legacy 4×3 twelve-cell rectangle to a nine-cell 3×3 rectangle. `BackpackState.STARTING_BAG_ORIGIN` remains `Vector2i(1, 1)`, preserving a centered usable region inside the 6×6 technical board.

The migration keeps all current spatial rules intact:

- item and bag quarter rotation,
- orthogonal adjacency,
- one-cell-or-more special-bag overlap,
- six-slot REST buffer,
- explicit combination transaction,
- preview combat power equals zero,
- committed snapshot remains sole item/spatial combat authority,
- final backpack plus Fate plus provisional next Stage remains atomic.

Catalog validation changes its starting-bag assertion from 12 to 9 cells. Tests demonstrate that legal first items fit the 3×3 starting region, out-of-region placement remains atomic, a purchased bag expands the active-cell set, and checkpoint/session copies preserve the exact 3×3 layout.

## 4. File and ownership plan

| surface | responsibility | change type |
| --- | --- | --- |
| `project.godot` | InputMap action declarations | named input bindings only |
| `scripts/player/player_controller.gd` | movement, dash runtime state, pointer target | authoritative movement behavior |
| `scenes/player/player.tscn` | existing player/camera structure | attach only approved input-facing support nodes if needed |
| `scripts/ui/hud.gd` | top-bar rendering and settings intents | presentation only |
| `scenes/ui/hud.tscn` | top bar, settings panel, device-only touch controls | visual/input surface only |
| `scripts/ui/stage_phase_presentation.gd` | pure Stage/Phase text mapping | no route or combat mutation |
| `scripts/core/main_controller.gd` | connects controller, circuit, HUD, settings, elapsed presentation | orchestration only |
| `scripts/data/mvp4_catalog.gd` | starting bag footprint and validation | catalog definition |
| `scripts/backpack/backpack_state.gd` | centered start construction | state construction only |
| `tests/unit/*`, `tests/integration/*` | behavior and authority regression | test-first proof |
| current decision/context/GDD records | implementation/evidence status | documentation after code evidence exists |

## 5. Error and rollback behavior

- A dash request with zero charge, a dead player, a settings-paused game, or zero direction returns `false` and leaves charge state unchanged.
- Pointer input inside a UI control does not set or replace a player movement target.
- Unknown school/circuit states map to no Phase text; they never invent a visible Phase 5.
- A malformed 3×3 restore snapshot fails closed through the existing checkpoint/backpack validators.
- Old internal route `stage_index`, `school_id`, checkpoint field names, and reward-lane inputs are not renamed in this package, so rollback remains a normal branch revert rather than a save migration.

## 6. Acceptance evidence

### Automated

- Unit tests prove two-charge dash consumption/recharge, nonzero direction, no damage immunity, and dead-player rejection.
- Unit tests prove input direction convergence and pointer arrival stopping behavior.
- HUD tests prove the normal combat surface contains only dash/play/settings, settings emits intents, and no manual skill hotbar survives.
- Presentation tests prove every live SchoolCircuit state maps to the approved Stage/Phase text without changing route depth.
- Backpack/catalog/session/checkpoint tests prove exactly nine start cells, retained 6×6 ceiling, legal expansion, and atomic rejection of invalid placements.
- Main integration tests prove only `PlayerController` changes dash state, HUD observes it, and automatic attack/tradition owners remain connected.

### Runtime and evidence ceiling

- Godot import/editor parse, main-scene headless smoke, focused and full GUT, plus scoped live input/render observation are required before PR.
- Human Usability, Player Experience, device/Android export, balance validation, merge, and release remain separate evidence classes and may not be claimed from automated or scoped runtime results.

## 7. Sequence after this specification

1. Write a task-level implementation plan with test-first steps and exact files.
2. Build each task in a fresh DEC-037 worktree with focused verification and a review gate.
3. Run full exact-head verification, adversarial review, PR CI, merge, and post-merge main readback.
4. Continue to the next approved product package only after the merged state is recorded and no current-scope blocker remains.
