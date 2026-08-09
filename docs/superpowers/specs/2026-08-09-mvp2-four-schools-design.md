# MVP-2 Four Schools Design

## Status

Approved design for the MVP-2 four-school combat slice. This spec follows MVP-1 on `main` at `eabc438006fd04a95660d0f964036dc76bfc0434` and intentionally stays inside the live planning sheet's MVP-2 depth.

## Goal

Validate that the four ninja schools feel materially different during the same survival-combat loop without building their full skill pools or later progression systems.

The four target emotions are:

- **봉마류 (Bongma):** build a small summon/ward formation and let it fight with you.
- **천술류 (Cheonsul):** control groups through visible elemental states and reactions.
- **귀인류 (Guiin):** stay dangerously close and become stronger under pressure.
- **흑영류 (Heukyeong):** attack from range, stack visible marks, and detonate them.

MVP-2 succeeds when four short runs produce clearly different combat rhythms even with placeholder visuals and rough balance.

## Scope

Each school receives exactly:

1. one representative combat ninjutsu,
2. one always-on support ninjutsu,
3. one simplified unique resource/rule,
4. one basic ultimate,
5. one representative synergy that is visible during normal combat.

MVP-0 movement, camera, health, enemy chasing, death/restart and MVP-1 kill-combo, stylish score, reward-orb and timed-wave behavior remain intact.

### Explicit exclusions

Do not add the full skill pool, skill drafting/level-up choices, backpack, fate, shop, stage clock, bosses, result screens, permanent progression, full status framework, final art/audio, or balance passes. Do not add school switching during a run.

## Approach

Use a **shared school host plus four isolated runtime modules**. Do not put all school logic into one large controller, and do not duplicate the Player scene four times.

This keeps existing movement/health/camera behavior shared while allowing each school to own its combat loop and tests.

## Start-of-run selection

The main scene opens with combat inactive and a four-card selection overlay:

- `1 — 봉마류` — 소환과 결계로 진지를 만든다
- `2 — 천술류` — 속성 상태를 겹쳐 반응을 터뜨린다
- `3 — 귀인류` — 가까이 붙고 위험할수록 강해진다
- `4 — 흑영류` — 원거리 표식을 쌓아 연쇄 폭발시킨다

Each card is a Godot `Button`; mouse click and keys `1`-`4` choose the same school. Selection is one-shot for the current run. After a valid selection the overlay hides, the selected runtime activates, and combat starts.

Before selection:

- player movement is disabled,
- initial enemies are disabled,
- wave spawning is disabled,
- the default MVP-0 auto attack cannot fire,
- school runtimes do not process,
- HUD and selection UI remain active.

After selection, player/enemies/waves activate. The legacy `AutoAttackController` remains in the Player scene for regression compatibility but stays disabled during the run; the chosen school's representative combat ninjutsu is the run's basic automatic offense.

## Input

No shared `project.godot` InputMap changes are required.

- Selection overlay consumes keyboard keys `1`-`4` directly and also supports button click.
- While alive and after selection, `ui_accept` attempts the selected school's ultimate.
- At game over, the existing `ui_accept` behavior remains restart and takes precedence over ultimate input.

An ultimate attempt that is not ready has no gameplay effect.

## Runtime architecture

### `SchoolRuntimeBase`

A small shared Node contract. It owns no school-specific rules. It defines the interface used by the host:

- `configure(player: PlayerController, world: Node2D) -> void`
- `activate() -> void`
- `deactivate() -> void`
- `on_enemy_died(enemy: Node) -> void`
- `try_use_ultimate() -> bool`
- `is_ultimate_ready() -> bool`

Shared signals:

- `resource_changed(label: String, current: float, maximum: float)`
- `ultimate_ready_changed(ready: bool)`
- `school_feedback(text: String)`

Runtime-owned attack/effect nodes normally remain below the runtime so disabling it freezes them. `EnemyEffectBadge` is the deliberate exception: it is attached to an enemy for positioning, but the owning runtime tracks every badge it creates and removes/clears them on deactivate or when the enemy becomes invalid.

### `SchoolRuntimeHost`

A Node under Main containing the four runtime children. It is the only object MainController talks to for school behavior.

Responsibilities:

- map one stable school id to one runtime,
- activate exactly one runtime once,
- expose selected school id/name,
- forward enemy-death events to the active runtime,
- forward ultimate input to the active runtime,
- forward resource/ultimate/feedback signals to HUD,
- reject a second selection until scene reload.

Stable ids are `bongma`, `cheonsul`, `guiin`, and `heukyeong` as `StringName` values.

### `SchoolSelectionUI`

A `CanvasLayer` that emits `school_selected(school_id: StringName)` once. It contains the four visible cards and handles `1`-`4` while visible. Invalid/repeated input is ignored.

### `EnemyEffectBadge`

A minimal shared child UI attached to an enemy only when a school needs readable enemy state. It displays compact state text above the enemy, for example `BURN/WET`, `SHOCK`, or `MARK 2`.

It does not own combat logic. Cheonsul and Heukyeong runtimes own their own dictionaries keyed by enemy instance id and update/remove badges as state changes. Dead/invalid enemies are pruned safely.

## MainController integration

MainController remains composition/orchestration only.

It will:

1. start the scene in selection mode,
2. receive one school id from `SchoolSelectionUI`,
3. activate that school in `SchoolRuntimeHost`,
4. keep the legacy default auto attack disabled for the run,
5. activate player, existing enemies, and `WaveSpawner`,
6. continue registering GameState kills and MVP-1 combo/orb feedback,
7. additionally forward enemy deaths to the active school runtime,
8. forward `ui_accept` to the school's ultimate while alive,
9. disable school runtime/effects with the rest of gameplay on game over,
10. reload the scene on `ui_accept` at game over so the player returns to school selection.

Enemy wiring for wave-spawned enemies stays centralized in MainController.

## HUD

Keep all existing MVP-1 HUD information. Add a compact school block:

- `SCHOOL <name>`
- `<RESOURCE LABEL> current / max` or a short rule-state value
- `ULT READY` / `ULT charging`
- one transient feedback line for events such as `백귀야행`, `WET + SHOCK`, `귀인화`, or `MARK BURST`

The school feedback line clears after exactly `1.0 s` using the same generation-guard pattern as the MVP-1 combo-title feedback so an older timeout cannot erase newer feedback.

## Shared damage rule

Existing `EnemyChaser.take_damage()` accepts integer damage. Whenever a school applies multipliers that produce a floating-point result, the final positive hit is converted with `roundi()` and clamped to at least `1`. Tests assert the resulting integer damage, not floating-point internals.

## School 1 — 봉마류

### Combat ninjutsu: 공격형 식신

A `BongmaFamiliar` Node2D follows the player and attacks the nearest valid enemy automatically.

Baseline:

- one familiar,
- attack interval: `0.70 s`,
- damage: `8`,
- familiar follows when farther than `72 px` from the player,
- target search uses the existing `enemies` group and ignores dead/invalid nodes.

Attacks are represented with simple placeholder geometry/brief hit feedback; no complex summon AI or pathfinding is added.

### Support ninjutsu: 영력 순환

Always active:

- spirit maximum is `120`,
- passive spirit regeneration is `5 / s`.

### Unique resource: 영력

- starts at `0 / 120`,
- `+10` for each enemy kill,
- `+5 / s` from 영력 순환,
- clamps to `[0, 120]`.

### Representative synergy: 소환 + 결계

To make the formation bonus observable instead of permanently active, the MVP runtime automatically places a stationary 봉인진 at the player's current position every `8.0 s`. Each ward:

- has radius `140 px`,
- lasts `4.0 s`,
- does not follow the player after placement,
- allows any familiar currently inside it to use a `0.50 s` attack interval instead of `0.70 s`.

Only one normal ward exists at a time. Manual ward placement and deeper installation controls are deferred.

### Ultimate: 백귀야행

Ready at `100` spirit. Activation:

- consumes exactly `100` spirit,
- lasts `6.0 s`,
- adds one temporary second familiar,
- all familiars use `0.30 s` attack interval while the ultimate is active regardless of ward position,
- temporary familiar is removed at the end,
- spirit continues normal regeneration/kill gain during the effect,
- cannot activate again while already active.

## School 2 — 천술류

### Combat ninjutsu: 화둔·염옥진

Every `1.80 s`, place a short-lived flame field at the nearest enemy's current position.

Field:

- radius `90 px`,
- initial damage `6` to enemies inside,
- applies `BURN` for `3.0 s`,
- burn ticks once per second for `2` damage,
- field visual lifetime `0.60 s`.

### Support ninjutsu: 오행순환

Successful 염옥진 casts alternate a secondary elemental token applied to hit enemies:

`WET -> SHOCK -> WET -> SHOCK ...`

This is an MVP device for testing elemental reaction rhythm; it is not a claim that the final 화둔 skill intrinsically applies water/lightning.

`WET` and unreacted `SHOCK` each last `4.0 s`; reapplying the same token refreshes its duration. Applying `SHOCK` to an enemy that currently has `WET`:

- consumes that enemy's `WET` and `SHOCK` tokens after the reaction,
- deals `10` reaction damage to it,
- deals `6` chain damage to other valid enemies within `120 px`,
- chain damage does **not** apply tokens or recursively trigger reactions,
- shows `WET + SHOCK`,
- increments the run's reaction counter.

Applying `WET` to an enemy that already has `SHOCK` does not trigger the representative reaction; the next qualifying `SHOCK` application can do so while WET remains valid.

오행순환's representative synergy is the visible wet-to-shock chain reaction. No generalized elemental-combination engine is introduced.

### Unique rule/resource: 오행 반응

HUD shows `REACTION n / 3`.

- starts at `0 / 3`,
- each WET+SHOCK reaction adds `1`,
- clamps at `3`,
- reaching `3` makes the ultimate ready.

### Ultimate: 오행폭주

When reaction count is `3`, activation succeeds only if at least one valid enemy currently carries a Cheonsul status. On success it:

- damages every currently valid enemy carrying any Cheonsul status for `18`,
- clears Cheonsul statuses/badges from affected enemies,
- resets reaction count to `0`,
- shows `오행폭주`.

If no valid status-bearing enemy exists, the attempt does nothing and preserves the `3 / 3` charge.

## School 3 — 귀인류

### Combat ninjutsu: 혈난무

An automatic melee pulse centered on the player.

Baseline:

- interval `0.90 s`,
- radius `80 px`,
- damage `10` to each valid enemy inside.

### Support ninjutsu: 광전사

When current HP is at or below `50%` of max HP:

- 혈난무 radius becomes `110 px`,
- base pulse damage becomes `15` before later multipliers.

No new armor, healing, shield, invulnerability, or defensive subsystem is introduced in MVP-2.

### Unique resource: 귀혈

- starts at `0 / 100`,
- `+4` per enemy successfully damaged by 혈난무,
- `+12` per enemy kill,
- after no gain for `1.0 s`, decays at `6 / s`,
- clamps to `[0, 100]`.

At `75+` 귀혈, the representative `근접 + 생존` synergy applies a `1.20x` multiplier to current 혈난무 damage after the normal/광전사 base value.

### Ultimate: 귀인화

Ready at `100` 귀혈. Activation:

- consumes the full `100`,
- lasts `6.0 s`,
- attack interval becomes `0.45 s`,
- radius becomes at least `130 px`,
- damage receives a further `1.25x` multiplier after normal/광전사/귀혈 calculations,
- 귀혈 continues normal gain/decay from `0` while the effect is active,
- cannot activate again while active.

Final damage uses the shared integer rounding rule.

## School 4 — 흑영류

### Combat ninjutsu: 만천화우

Every `1.10 s`, attack up to the three nearest valid enemies within the normal active enemy set.

Each needle hit:

- base damage `6`,
- base critical chance `20%`,
- if the target already has at least one mark, critical chance becomes `40%`,
- critical damage multiplier is `2.0x`,
- normal hit adds `1` mark,
- critical hit adds `2` marks total.

Runtime uses its own `RandomNumberGenerator`; tests can set its seed for deterministic behavior.

### Support ninjutsu: 암살교범

The increased critical chance against already-marked targets is the always-on support effect. It makes marked targets easier to accelerate toward detonation.

### Unique resource/rule: 암영표식

Each enemy has `0-3` marks, shown with `MARK 1` or `MARK 2` before detonation. Marks have no time expiry in MVP-2; they are removed only by burst, ultimate, enemy death, runtime deactivation, or scene reload.

When a hit reaches or exceeds `3` marks:

- deal `16` mark-burst damage,
- reset that enemy to `0` marks,
- show `MARK BURST`.

The ultimate charge is the total number of currently active marks across valid enemies. HUD shows `MARKS n / 6`. Mark bursts can therefore lower charge again; readiness reflects current battlefield setup rather than permanent accumulation.

### Representative synergy: 원거리 + 암살

Marked enemies have the higher critical chance described above, which in turn adds marks faster and produces more frequent bursts.

### Ultimate: 암영처형

Ready while total active marks are at least `6`. Activation:

- hits every valid marked enemy once,
- damage to each is `14 + (4 * current mark count)`,
- clears all marks/badges after damage,
- shows `암영처형`,
- readiness immediately becomes false after marks are cleared.

Boss-specific bonus damage is deferred because MVP-2 has no boss system.

## Damage and existing DDD behavior

School damage calls the existing enemy damage contract; enemy death remains owned by `EnemyChaser` and MainController's existing death wiring.

Every school kill must still:

- increment GameState kill/score,
- register the MVP-1 combo/stylish kill,
- spawn exactly one reward orb,
- count toward wave pressure normally,
- forward the death once to the active school runtime for school-resource effects.

School mechanics must not directly register a kill themselves, preventing double counting.

## Lifecycle and cleanup

All runtime loops guard invalid/dead enemies. State dictionaries prune invalid nodes before calculations. Repeated death signals, repeated selection, and repeated ultimate input must be idempotent or ignored.

On runtime deactivate, school-specific state and any enemy-attached badges created by that runtime are cleared. On player death:

- MainController keeps the existing game-over guard,
- WaveSpawner is disabled,
- the selected runtime is deactivated/disabled,
- school-spawned children stop processing with their parent runtime,
- existing reward orbs stop with gameplay,
- HUD game-over panel remains active,
- Enter reloads the scene and returns to school selection.

## Scene/file direction

Expected focused additions:

- `scripts/schools/school_runtime_base.gd`
- `scripts/schools/school_runtime_host.gd`
- `scripts/schools/bongma_runtime.gd`
- `scripts/schools/cheonsul_runtime.gd`
- `scripts/schools/guiin_runtime.gd`
- `scripts/schools/heukyeong_runtime.gd`
- `scripts/schools/bongma_familiar.gd`
- `scripts/ui/school_selection_ui.gd`
- `scripts/ui/enemy_effect_badge.gd`
- corresponding minimal scenes under `scenes/schools/` and `scenes/ui/`
- focused unit/integration tests under `tests/`

Existing files should be changed only where required for composition: primarily `main_controller.gd`, `main_scene.tscn`, and HUD script/scene. Avoid unrelated refactors.

## TDD strategy

The baseline is the merged MVP-1 suite: `68` tests and `307` assertions.

Implementation must proceed RED -> GREEN in small slices:

1. selection UI and one-shot school host contract,
2. Bongma resource/familiar/ward/ultimate,
3. Cheonsul status/reaction/ultimate,
4. Guiin melee/gwihyeol/low-HP/ultimate,
5. Heukyeong marks/critical/detonation/ultimate,
6. HUD school feedback,
7. Main integration and regressions.

Tests should prefer deterministic direct method calls and seeded RNG over frame timing where possible.

### Required integration coverage

- scene starts with combat inactive and selector visible,
- each of four ids activates exactly its matching runtime,
- second selection is rejected,
- legacy auto attack remains disabled after school selection,
- existing and wave-spawned enemies still receive player targeting/death wiring,
- every school-caused kill still produces exactly one GameState kill, one DDD kill registration, and one reward orb,
- school feedback does not erase newer feedback due to an old timeout,
- game over disables the active school runtime/effects and clears enemy-attached school badges,
- Enter at game over restarts to selection mode,
- all MVP-0/MVP-1 tests remain green unless an old test is intentionally updated to reflect the approved start-selection flow.

## Manual acceptance

Run four short sessions, selecting each school from a fresh start.

### Shared

- selection appears before combat,
- mouse and `1`-`4` selection work,
- selection cannot change mid-run,
- existing HP/KILLS/COMBO/STYLE/ORBS continue working,
- waves continue,
- game over freezes combat,
- Enter restarts to school selection.

### Bongma

- familiar visibly follows and attacks for the player,
- spirit rises over time and on kills,
- stationary ward windows visibly improve familiar rhythm while the familiar remains inside,
- 백귀야행 creates a temporary second familiar and obvious attack-speed burst.

### Cheonsul

- flame fields and BURN are visible,
- WET/SHOCK badges are readable,
- WET + SHOCK produces obvious non-recursive chain reaction feedback,
- three reactions ready 오행폭주 and the ultimate clears/explodes current elemental states.

### Guiin

- offense is close-range pulses rather than ranged shots,
- gwihyeol builds from close combat and decays when disengaged,
- low HP visibly increases pulse size/damage feel,
- 귀인화 produces an obvious short melee frenzy.

### Heukyeong

- ranged multi-target attacks visibly create marks,
- marks accelerate critical/burst rhythm,
- 3 marks detonate,
- enough live marks ready 암영처형 and it clears marked targets in a visible chain.

The acceptance question is not numerical balance. It is whether the four runs feel like summon formation, elemental control, risky melee, and mark assassination respectively.

## Adversarial review targets

Before readiness, explicitly attack these failure modes:

- selection accidentally allows combat to begin before choice,
- second selection leaves multiple runtimes processing,
- old AutoAttackController fires alongside school offense,
- death callbacks double-count kills/resources,
- school state holds freed enemy references,
- Bongma ward bonus is accidentally permanent instead of positional/time-bounded,
- Cheonsul chained damage recursively creates unintended reactions,
- Guiin resource continues processing after death,
- Heukyeong random tests are flaky or marks survive freed enemies,
- ultimate input triggers restart or vice versa,
- old HUD timer clears newer school feedback,
- school-spawned children or enemy badges continue after game over,
- local `project.godot`/`addons/` state leaks into the feature branch.

## Completion gate

MVP-2 is ready for integration only when:

- all four school loops are implemented at this shallow depth,
- full GUT regression is green on the exact PR head,
- Godot 4.7.1 import and main-scene smoke pass,
- adversarial findings contain no unresolved `MUST_FIX`,
- Windows local import/GUT pass with project-only UID metadata reconciled,
- manual four-school acceptance passes,
- PR diff contains no local plugin configuration or addon files.
