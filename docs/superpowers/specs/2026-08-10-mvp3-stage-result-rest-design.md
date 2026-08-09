# MVP-3 Stage, Result, Rest, Shop, and Fate Design

## Status

Approved design for MVP-3. This spec starts from `main` at `e0150fa83512fb01c01569ed2b7a925dec81ec60`, after MVP-2 four-school combat identities were merged.

The user approved the design section-by-section. The selected architecture is the recommended isolated-subsystem approach rather than a monolithic MVP-3 manager or scene-per-step flow.

## Goal

Validate the core build-decision loop:

`fight -> midboss -> understand results -> spend/reshape build -> accept a fate tradeoff -> preview next fight -> re-enter combat`

MVP-3 succeeds when, after each five-minute combat segment, the player can look at concrete contribution data and make a meaningful decision about what to strengthen before the next segment.

The target slice contains three combat segments and three rests. It ends after the third rest preview rather than pulling the 20-minute final boss/final-result loop forward from MVP-5.

## Scope

MVP-3 includes:

- three five-minute combat segments,
- one simple midboss archetype reused at 5/10/15 combat minutes with tiered stats,
- card-style intermediate results,
- five contribution axes,
- GOLD as a separate run currency,
- a real shop with three offers, buy, sell, and paid reroll,
- a non-spatial owned-item list that becomes backpack content in MVP-4,
- eight initial shop items,
- five fate choices with visible benefit and cost,
- one fate choice required at each rest, with choices accumulating for the run,
- a next-combat preview,
- deterministic growth hints,
- automated tests with an injectable segment duration.

### Explicit exclusions

Do not add:

- the backpack grid,
- item rotation, size, shape, placement, or adjacency logic,
- backpack set bonuses,
- deep combination-ninjutsu mechanics,
- a general loot-drop inventory pipeline,
- shop level,
- discounts,
- buyback,
- offer locking,
- complex weighted shop probability tables,
- complex fate branching,
- permanent progression or Ninja Soul,
- a 20-minute final boss,
- final rank/result/ending screens,
- a visible debug time-skip UI,
- unrelated refactors,
- new shared `project.godot` InputMap entries or autoloads unless implementation proves they are strictly necessary and the user separately approves that change.

## Product decisions already approved

- Midboss depth: one simple archetype, numerically stronger at 5/10/15 minutes.
- Boss transition: at the five-minute boundary, stop new normal waves, keep living normal enemies for boss pressure, and require the boss kill before rest.
- Shop: GOLD economy plus actual buy/sell/reroll.
- Shop inventory: real reusable item definitions now; spatial backpack behavior is deferred to MVP-4.
- Owned-item capacity: 6 total items.
- Duplicate cap: at most 2 copies of one item id.
- Shop offers: 3 per rest.
- Fate: 3 candidates at each rest, one mandatory selection, selected fates persist and do not reappear.
- Contribution contract: damage, healing, defense, status, kill/combo.
- Rest sequence: `RESULT -> SHOP -> FATE -> PREVIEW`.
- Third preview ends the MVP-3 slice with `MVP-3 LOOP COMPLETE` and restart rather than starting a fourth combat segment.

## Architecture

Keep `MainController` as composition/orchestration only. Do not turn it into the owner of stage, shop, fate, item, or telemetry rules.

### `StageFlowController`

Owns the run phase and segment clock.

States:

`SCHOOL_SELECT -> COMBAT -> BOSS -> RESULT -> SHOP -> FATE -> PREVIEW`

`PREVIEW` returns to `COMBAT` after rests 1 and 2. After rest 3 it enters terminal MVP-3 completion state instead.

Responsibilities:

- start the first segment only after school selection,
- advance the combat clock only in `COMBAT`,
- stop normal spawning at the segment boundary,
- request one boss spawn,
- wait for boss death,
- snapshot the segment result after all boss-death rewards/events are registered,
- pause gameplay for rest,
- advance rest states only through their valid UI actions,
- reset segment-only telemetry when starting a new segment,
- preserve run-level build, school resource, score, stylish state, GOLD, owned items, and fate state,
- terminate the slice after the third preview.

Production `segment_duration_seconds` is `300.0`. Tests may construct/configure the controller with a shorter duration. No production debug control changes this value during play.

The cumulative combat milestones are therefore 5:00, 10:00, and 15:00 of combat time. Boss and rest time do not advance the combat clock.

### `RunBuildState`

Owns run-level build/economy state:

- integer GOLD balance,
- owned item ids/counts,
- selected fate ids,
- derived `RunModifierSet`,
- pending per-rest shop state where appropriate.

It is the single source of truth for whether a purchase, sale, or fate change is legal.

Whenever owned items or fates change, it recomputes modifiers from source data. It never repeatedly mutates an already-modified value.

### `RunModifierSet`

A derived immutable-style snapshot used by player/school combat code.

Supported channels for MVP-3:

- `move_speed_pct`,
- `max_health_flat`,
- `max_health_pct`,
- `damage_taken_pct`,
- `healing_pct`,
- `normal_kill_gold_pct`,
- `school_damage_pct`,
- `school_resource_gain_pct`,
- `ultimate_charge_gain_pct`,
- `ultimate_damage_pct`,
- `evasion_chance`,
- school-token-specific fields for Bongma familiar interval, Cheonsul reaction damage, Guiin melee radius, and Heukyeong marked-target critical chance.

Percentage contributions in the same channel are additive. A normal multiplier is computed as `1.0 + summed_pct`, then clamped to a safe non-negative range where needed.

Player maximum HP is resolved as:

`roundi((base_max_health + max_health_flat) * (1.0 + max_health_pct))`

Movement is resolved from the player's base move speed times the final movement multiplier.

Selling/removing a source triggers a full recomputation. This avoids stacking-order bugs.

### `ShopController`

Owns shop offer generation and per-rest reroll cost progression. It delegates balance/item legality to `RunBuildState`.

Responsibilities:

- produce exactly 3 distinct item ids per offer roll,
- never include an item already at its two-copy cap,
- allow repeats across separate rerolls/rests,
- reject unaffordable or capacity-invalid purchases without changing state,
- sell one owned copy at its fixed sell value,
- charge reroll before replacing offers,
- reset reroll price when entering a new rest.

No weighted rarity table is required in MVP-3. Eligible items may be selected uniformly.

### `FateController`

Owns the five-fate catalog and per-rest candidate generation.

Responsibilities:

- exclude already selected fate ids,
- show exactly 3 candidates,
- require one selection,
- add the selected fate to `RunBuildState`,
- never allow replacement/removal during the run.

There are five total fates. At rest 3, exactly three unselected fates remain and all three are shown.

### `CombatContributionTracker`

Owns segment telemetry plus the frozen result snapshot.

Segment axes:

- actual damage dealt,
- actual healing received,
- actual incoming damage prevented,
- successful status/reaction application events,
- kills and maximum combo.

It also snapshots:

- segment GOLD earned,
- reward-orb collection delta if available from the existing DDD tracker,
- deterministic growth hints.

A result snapshot is immutable from the moment the boss-death transition completes. Later shop/fate/healing changes must not rewrite the previous segment result.

### `CombatResolver`

A small focused helper used by school runtime attacks so modifiers and damage telemetry share one path.

Responsibilities:

- accept base school damage plus damage kind (`normal`, `ultimate`, or school-specific subtype),
- apply `school_damage_pct` and, for ultimate damage, `ultimate_damage_pct`,
- apply school-token-specific damage modifiers where relevant,
- convert the final positive hit to an integer,
- call the target damage API,
- record the target's actual HP loss in `CombatContributionTracker`.

`EnemyChaser.take_damage()` may be extended to return actual HP loss while preserving compatibility with callers that ignore the return value.

Status application/reaction events remain owned by the school runtime that knows whether the application actually succeeded; that runtime records the event through the tracker only after success.

### `RestFlowUI`

A dedicated full-screen rest overlay, separate from the compact combat HUD.

It renders only the state selected by `StageFlowController`:

- result cards,
- shop,
- fate candidates,
- next-combat preview,
- terminal MVP-3 completion panel.

It emits intent signals. It does not directly mutate GOLD, inventory, fate, timers, enemies, or school state.

## Existing-system integration

### `MainController`

Main keeps the existing responsibilities for wiring enemy death, GameState, CombatDDD, school selection, player death, school host, HUD, and reward orbs.

MVP-3 adds wiring between the independent controllers. Main must not contain the shop catalog, fate catalog, timer state machine, or modifier math.

Boss death still passes through the normal enemy-death path exactly once so it continues to contribute to:

- `GameState` kill count/score,
- MVP-1 combo/stylish behavior,
- active school `on_enemy_died`,
- reward-orb spawning.

GOLD differs by enemy type:

- normal enemy: exactly `+1 GOLD`,
- stage boss: exactly `+25 GOLD`.

A boss does not receive the normal `+1` in addition to its `+25`.

### `WaveSpawner`

Use the existing `set_spawning_enabled(bool)` boundary.

At a five-minute threshold:

1. set normal spawning disabled,
2. leave currently living normal enemies active,
3. spawn one stage boss,
4. remain in `BOSS` until that boss dies.

When the boss dies and the rest snapshot is captured, remaining normal enemies are removed without emitting kill rewards, score, combo, school kill-resource, or GOLD. This prevents stale normal mobs from carrying into the next segment while still preserving their intended pressure during the boss fight.

Pending reward orbs are not converted into free rewards. They may remain paused and resume on the next combat segment; only actually collected orbs contribute to the segment in which collection occurred.

### School runtime pause semantics

Rest must pause the selected school runtime without semantically deactivating/resetting the chosen school.

Do not use a reset path that clears school resource merely because rest began. Spirit, reaction count, Gwihyeol, and other run-level school resources persist across rests unless the school's own rules consume them.

Enemy-bound effects on enemies removed after boss death naturally disappear with those enemies.

### `PlayerController`

Add the minimum reusable runtime-stat surface needed by approved items/fates:

- apply/reapply a `RunModifierSet`,
- `heal(amount)` returning/emitting actual healing,
- damage resolution that can apply evasion and damage-taken modifiers,
- reporting requested/applied/prevented incoming damage for defense telemetry.

Damage-prevention telemetry counts only prevented incoming damage:

- reduction: requested damage minus post-reduction applied damage,
- evade: the entire requested damage,
- no invented defense value when no damage event occurred.

Changing maximum HP is not damage and does not count as defense. If effective max HP falls below current HP after selling an item or selecting a fate, current HP clamps to the new max.

## Stage and boss behavior

### Combat segments

Segments are:

- Segment 1: combat minutes 0-5,
- Segment 2: combat minutes 5-10,
- Segment 3: combat minutes 10-15.

Normal wave behavior otherwise remains the current MVP-2 behavior. MVP-3 does not introduce a second regular-enemy archetype or a general difficulty director.

### Boss archetype

Use one simple chaser-style boss scene derived from the existing enemy contract rather than three bespoke bosses.

The boss is visibly larger than a normal enemy and is identifiable as a stage boss for GOLD/flow logic.

Initial tuning defaults are data, not architectural invariants:

| Tier | Max HP | Move speed | Contact damage | Visual scale |
| --- | ---: | ---: | ---: | ---: |
| 1 | 200 | 70 | 15 | 1.6x |
| 2 | 350 | 80 | 20 | 1.8x |
| 3 | 500 | 90 | 25 | 2.0x |

The boss uses the same contact cooldown unless playtesting shows a blocking issue. Do not add bespoke boss phases/patterns in MVP-3.

## GOLD economy

### Income

- normal kill: `1 GOLD`,
- boss kill: `25 GOLD`,
- GOLD persists across rests/segments,
- SCORE remains independent and is never spent.

The `행운 부적` modifier applies to normal-kill GOLD only. It does not alter the fixed 25-GOLD boss reward.

Because normal kills have a base reward of 1, percentage GOLD bonuses use a deterministic fractional carry. Example: one `행운 부적` produces `1.25` reward credit per normal kill; integer GOLD is granted when accumulated credit crosses a whole number, preserving exactly +25% over repeated kills without random rounding.

### Shop prices

Item prices are fixed by definition:

- light/common utility: 20G,
- specialized: 30G,
- strong/school-specific: 40G.

Selling returns exactly half the fixed base price:

- 20G item -> 10G,
- 30G item -> 15G,
- 40G item -> 20G.

No purchase-price history or buyback list is needed.

### Reroll

Within one rest:

`5G -> 10G -> 15G -> 15G -> ...`

Entering the next rest resets the first reroll to 5G.

If GOLD is insufficient, reroll is rejected and both offers and reroll index remain unchanged.

### Inventory constraints

- total owned item count: maximum 6,
- same item id: maximum 2,
- a rejected purchase changes neither GOLD nor inventory,
- selling one copy immediately removes one copy's modifier contribution and refunds its sell value.

The item list is intentionally non-spatial. MVP-4 adds backpack position/size/adjacency to the same item definitions rather than replacing the economy model.

## Item data contract

Each `ItemDefinition` contains at least:

- stable `id`,
- display name,
- base price,
- derived fixed sell price,
- tags,
- modifier/effect kind,
- modifier/effect value,
- optional school-specific payload.

MVP-4 may extend this definition with footprint/shape/placement/adjacency metadata.

## Initial shop pool

### 1. `체술단련` — 20G

- movement speed `+10%` per copy.

### 2. `호신 부적` — 20G

- maximum HP `+20` flat per copy,
- on purchase, also heal exactly the amount by which effective max HP increased, capped at the new maximum,
- selling removes the max-HP contribution and clamps current HP if needed.

### 3. `행운 부적` — 20G

- normal-enemy kill GOLD `+25%` per copy,
- uses deterministic fractional carry,
- does not modify the fixed boss reward.

### 4. `인법단련` — 30G

- school normal/ultimate direct damage `+12%` per copy through the common school-damage channel.

### 5. `깨달음` — 30G

- school resource gain `+20%` per copy.

This applies only where the school runtime receives/generates its own resource or counter. It does not invent a resource event that the school did not already have.

### 6. `재생의 두루마리` — 30G

- whenever combat resumes from a rest, heal `20%` of current effective maximum HP per copy,
- actual healing only; overheal is discarded,
- this start-of-segment healing belongs to the new segment telemetry after that segment tracker has been reset.

It does not trigger before the very first combat segment because it cannot be owned before the first shop.

### 7. `오의 비전서` — 40G

- gain toward ultimate readiness `+25%` per copy where the school has a numeric resource/counter gain event,
- ultimate direct damage `+0%`; this item accelerates readiness only.

If a school has a discrete integer counter, fractional gain is retained by that runtime or an equivalent deterministic accumulator rather than randomly rounded.

### 8. `유파 증표` — 40G

One generic item id whose effect resolves from the selected school:

- 봉마류: familiar attack interval `-15%` per copy,
- 천술류: WET+SHOCK primary and chain reaction damage `+20%` per copy,
- 귀인류: representative melee attack radius `+15%` per copy,
- 흑영류: attacks against a currently marked target gain `+15 percentage points` critical chance per copy; critical hits deal `2.0x` final Heukyeong attack damage.

Critical chance is checked only for Heukyeong attacks that qualify under the token rule. It is not introduced as a universal crit framework in MVP-3.

## Fate pool

Fate is a run-rule tradeoff, not a free stat card. The UI must show both benefit and cost before selection.

All fate percentage changes feed the same recomputed `RunModifierSet` used by items.

### `살육의 길`

- school damage `+20%`,
- healing effectiveness `-40%`.

### `수호의 길`

- incoming damage `-20%`,
- healing effectiveness `+30%`,
- school damage `-10%`.

### `그림자의 길`

- movement speed `+15%`,
- evasion chance `+10 percentage points`,
- maximum HP `-15%`.

### `금기의 길`

- school resource gain `+25%`,
- school-owned status/reaction damage/effect magnitude `+20%` where such an effect exists,
- incoming damage `+15%`.

For schools without a status/reaction magnitude, the resource benefit still applies; do not synthesize a fake status system.

### `봉인의 길`

- ultimate readiness gain `+30%`,
- ultimate direct damage `+25%`,
- non-ultimate school direct damage `-15%`.

No selected fate can appear again. Three distinct candidates are shown at each rest, and the player cannot proceed without choosing exactly one.

## Rest flow

Gameplay is paused throughout rest. The player, enemies, school runtime processing, normal spawning, boss processing, and stage clock do not advance. UI remains active.

### 1. RESULT

Show a card-style summary with:

- damage dealt,
- healing received,
- damage prevented,
- status/reaction events,
- kills,
- maximum combo,
- segment GOLD earned,
- reward-orb collection delta when available,
- 1-2 growth hints.

If healing/defense has no real event, display `기여 없음` rather than inventing a number or pretending a mechanic exists.

`Continue` advances to SHOP. RESULT itself has no build mutation.

### 2. SHOP

Show:

- current GOLD,
- 3 offers,
- owned item list with counts,
- buy action per offer,
- sell action per owned copy/type,
- current reroll cost,
- `Next` button.

Buying/selling/rerolling may be repeated while legal. The player may buy nothing and continue.

### 3. FATE

Show 3 unselected fate cards. Each card includes title, benefit, and cost.

There is no skip. Selecting one applies it immediately and enables progression to PREVIEW.

### 4. PREVIEW

Show a compact summary of:

- next segment number,
- next boss tier,
- newly bought/sold item changes from this rest,
- newly selected fate,
- current cumulative fates,
- current GOLD,
- one-line description of the next combat expectation.

After rests 1 and 2, `Start Combat` resumes gameplay and starts the next five-minute segment.

After rest 3, PREVIEW becomes terminal `MVP-3 LOOP COMPLETE` and offers restart. It does not start a segment 4.

## Combat HUD

Keep the existing MVP-2 HUD. Add only compact run-flow information:

- segment indicator, e.g. `SEGMENT 1/3`,
- remaining segment combat time, e.g. `04:32`,
- GOLD.

Large result/shop/fate/preview panels do not live inside `HUDController`.

## Contribution telemetry

### Damage

Count actual target HP lost, not requested/raw damage.

Example: a target at 3 HP receives a requested 20-damage hit; contribution is 3.

### Healing

Count only actual HP restored after cap.

Example: player missing 5 HP receives a 20 heal; contribution is 5.

### Defense

Count prevented incoming damage caused by current run modifiers:

- reduction contributes the rounded/actual amount prevented,
- a successful evade contributes the full requested incoming damage.

Max-HP clamping is not defense.

### Status/reaction

Count a successful school-owned status application or reaction event once when the runtime confirms it occurred.

Examples include Cheonsul elemental application/reaction and Heukyeong mark application. Damage from the event still contributes separately to damage.

### Kill/combo

Track segment kill count and the segment maximum combo. Existing overall MVP-1 DDD state is not reset just to produce a segment result; the contribution tracker stores its own segment deltas/maximums.

## Growth hints

Hints are deterministic, short, and based only on observed contribution plus current build state. They are not random flavor text.

Rules:

- pick the strongest non-zero contribution axis as the primary hint source,
- add a second hint only if another non-zero axis or an owned-item/fate synergy creates a clear recommendation,
- never fabricate a healing/defense recommendation from a zero-event axis,
- phrase recommendations as build directions, not guaranteed shop contents.

Examples:

- high damage -> `현재 화력을 유지할 피해/유파 강화가 잘 맞습니다`,
- high status -> `상태·반응 빈도 또는 효과를 키우는 선택이 잘 맞습니다`,
- meaningful prevented damage -> `생존 투자 효율이 실제로 나오고 있습니다`,
- high kill/combo with lower direct damage -> `이동·공격 주기를 유지해 콤보 흐름을 강화할 수 있습니다`.

## Error and boundary behavior

- Before school selection, the stage clock is stopped and no combat GOLD can be earned.
- Only one boss may exist for the active milestone.
- Crossing a timer threshold cannot spawn duplicate bosses on later frames.
- Boss death must be processed exactly once.
- Normal spawning remains disabled throughout `BOSS` and rest.
- Rest cannot begin before the boss is dead.
- The result snapshot happens after boss kill/score/GOLD/combo/school callbacks have been registered.
- Removing leftover normal enemies at rest entry must not trigger their normal death rewards.
- Shop purchase failure is atomic: no GOLD loss and no inventory mutation.
- Reroll failure is atomic: no GOLD loss, no offer mutation, no reroll-index advance.
- Selling fails cleanly if the requested item is not owned.
- Fate selection fails cleanly for an already-selected or non-offered fate.
- `Start Combat` is valid only in PREVIEW after a fate has been selected for that rest.
- Player death during `COMBAT` or `BOSS` always wins over pending stage transitions and goes to the existing game-over path.
- No shop/fate/rest reward is granted after death.
- Existing `ui_accept` game-over restart precedence remains intact.
- Rest pause must not erase selected-school identity or run-level school resource.

## Testing strategy

The repository keeps both unit and integration GUT layers.

### Unit tests

Cover at least:

- `StageFlowController` legal/illegal transitions,
- production default segment duration is 300 seconds,
- short injected duration reaches BOSS exactly once,
- boss kill advances to RESULT and snapshots after reward registration,
- third preview terminates the MVP-3 loop,
- GOLD normal/boss rewards are distinct,
- fractional normal-kill GOLD carry,
- shop 3-offer uniqueness,
- purchase affordability,
- 6-item capacity,
- 2-copy duplicate cap,
- sell refund and modifier removal,
- reroll cost sequence/reset/failure atomicity,
- all eight item modifier calculations,
- recomputation after buy/sell,
- max-HP increase heal and decrease clamp,
- rest-start regeneration heal actual amount,
- all five fate modifiers,
- fate candidate exclusion and mandatory choice,
- damage/heal/defense actual-value telemetry,
- status event counting,
- deterministic growth-hint selection,
- boss tier data.

### School regression tests

For all four schools:

- school still activates after selection,
- base combat continues to damage/kill enemies,
- school resource/ultimate readiness still functions,
- rest pause/resume preserves school identity/resource,
- common school-damage modifier changes actual damage,
- school-resource/ultimate-charge modifiers affect qualifying gain events,
- the relevant `유파 증표` effect works,
- existing ultimate behavior is not broken.

### Integration tests

At least one accelerated main-scene path must exercise:

`school select -> COMBAT -> timer threshold -> BOSS -> boss death -> RESULT -> SHOP -> FATE -> PREVIEW -> next COMBAT`

Also cover:

- a full accelerated three-segment path ending at `MVP-3 LOOP COMPLETE`,
- player death during normal combat,
- player death during boss combat,
- shop buy/sell/reroll reflected in preview and next-combat modifiers,
- result snapshot does not change after rest mutations.

### Manual acceptance

Run the normal main scene and confirm:

- school selection still gates combat,
- HUD shows segment/time/GOLD without obscuring existing school/combo information,
- at the real 5:00 combat threshold normal spawning stops and one boss appears,
- living normal enemies remain dangerous during the boss fight,
- boss defeat enters a readable result screen,
- result values match observable actions at a sanity-check level,
- shop clearly communicates insufficient GOLD, capacity, and duplicate-cap failures,
- buy/sell/reroll are understandable without hidden controls,
- fate cards clearly show both upside and downside,
- combat is inert during rest,
- `Start Combat` resumes correctly,
- game over/restart still works.

The full 15-minute production-time loop is desirable for final tuning, but automated acceptance uses injected time and must not depend on waiting 15 real minutes.

## Compatibility and repository safety

Implementation must preserve MVP-0/1/2 behavior unless this spec explicitly changes it.

Expected work should remain in scenes/scripts/tests/docs. Avoid `project.godot` so the user's local Godot AI/Hera/GUT plugin state remains isolated. Never stage or clean unrelated local plugin files.

Do not merge/integrate the feature branch without explicit user approval after implementation, review, regression checks, and CI evidence.

## MVP-3 acceptance summary

MVP-3 is complete when all of the following are true:

1. a selected school can play three five-minute combat segments,
2. each segment ends in a required tiered midboss kill,
3. each boss kill produces an immutable contribution result,
4. each rest allows a real GOLD shop with buy/sell/reroll,
5. owned reusable items modify subsequent combat and obey capacity/duplicate limits,
6. each rest requires one new benefit-plus-cost fate from three unselected candidates,
7. item/fate modifiers work across all four schools without collapsing their runtime boundaries,
8. next-combat preview communicates the build changes,
9. the third preview ends with `MVP-3 LOOP COMPLETE`,
10. existing movement, game over, DDD, school selection, school combat, and restart behavior regressions pass,
11. unit/integration tests pass in CI,
12. backpack spatial mechanics and the 20-minute final loop remain deferred.
