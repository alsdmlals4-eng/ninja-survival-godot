# MVP-3 Stage, Result, Rest, Shop, and Fate Design

## Status

Approved design for MVP-3. This spec starts from `main` at `e0150fa83512fb01c01569ed2b7a925dec81ec60`, after MVP-2 four-school combat identities were merged.

The selected approach is an isolated-subsystem architecture: `MainController` remains composition/orchestration while stage flow, build state, shop, fate, telemetry, combat resolution, and rest UI have separate responsibilities.

## Goal

Validate the build-decision loop:

`fight -> midboss -> understand results -> spend/reshape build -> accept a fate tradeoff -> preview next fight -> re-enter combat`

MVP-3 succeeds when the player can use concrete contribution data from the previous segment to decide what to strengthen before the next one.

The slice contains three five-minute combat segments and three rests. It ends after the third rest preview. The 20-minute final boss/final-result/Ninja Soul loop remains MVP-5 work.

## Scope

MVP-3 includes:

- three five-minute combat segments,
- one simple midboss archetype reused at 5/10/15 combat minutes with tiered stats,
- card-style intermediate results,
- five contribution axes,
- GOLD as a separate run currency,
- a real shop with three offers, buy, sell, and paid reroll,
- a non-spatial owned-item list reused by MVP-4 backpack work,
- eight initial shop items,
- five fate choices with visible benefit and cost,
- one mandatory fate choice at each rest, accumulated for the run,
- a next-combat preview,
- deterministic growth hints,
- automated tests with an injectable segment duration.

### Explicit exclusions

Do not add:

- backpack grid, item rotation, size, shape, placement, adjacency, or set bonuses,
- deep combination-ninjutsu mechanics,
- a general combat loot-drop inventory pipeline,
- shop level, discounts, buyback, offer locking, or weighted shop tables,
- complex fate branching,
- permanent progression or Ninja Soul,
- a 20-minute final boss or final rank/result/ending screen,
- a visible debug time-skip UI,
- unrelated refactors,
- new shared `project.godot` InputMap entries or autoloads unless implementation proves they are strictly necessary and the user separately approves that change.

## Approved product decisions

- Midboss depth: one simple archetype, numerically stronger at 5/10/15 minutes.
- Boss transition: at the five-minute boundary stop new normal waves, keep living normal enemies for boss pressure, and require the boss kill before rest.
- Shop: GOLD economy plus actual buy/sell/reroll.
- Inventory: real reusable item definitions now; spatial backpack behavior is deferred to MVP-4.
- Owned-item capacity: 6 total items.
- Duplicate cap: at most 2 copies of one item id.
- Shop offers: 3 per rest.
- Fate: 3 candidates at each rest, one mandatory selection, selected fates persist and do not reappear.
- Contribution contract: damage, healing, defense, status, kill/combo.
- Rest sequence: `RESULT -> SHOP -> FATE -> PREVIEW`.
- Third preview ends with `MVP-3 LOOP COMPLETE` and restart instead of starting a fourth segment.

## Architecture

### `StageFlowController`

Owns run phase and combat clock.

States:

`SCHOOL_SELECT -> COMBAT -> BOSS -> RESULT -> SHOP -> FATE -> PREVIEW`

`PREVIEW` returns to `COMBAT` after rests 1 and 2. After rest 3 it enters terminal completion state.

Responsibilities:

- start segment 1 only after school selection,
- advance combat time only in `COMBAT`,
- stop normal spawning at a five-minute boundary,
- request exactly one boss,
- wait for boss death,
- snapshot the segment after boss-death rewards/callbacks complete,
- pause gameplay for rest,
- advance rest states only through valid UI actions,
- reset segment telemetry before the next combat begins,
- preserve run-level score, DDD state, school resource, HP, GOLD, items, and fates,
- terminate after the third preview.

Production `segment_duration_seconds` is `300.0`. Tests may inject a shorter value. Boss/rest time does not advance the combat clock, so the milestones are 5:00, 10:00, and 15:00 of combat time.

### `RunBuildState`

Single source of truth for:

- integer GOLD balance,
- owned item ids/counts,
- selected fate ids,
- derived `RunModifierSet`.

All purchases, sales, and fate mutations are validated here or through a narrow method that delegates to it.

Modifiers are always recomputed from owned items + selected fates. Never repeatedly mutate already-modified runtime values.

### `RunModifierSet`

Derived modifier snapshot consumed by player/school systems.

MVP-3 channels:

- `move_speed_pct`,
- `max_health_flat`,
- `max_health_pct`,
- `damage_taken_pct`,
- `healing_pct`,
- `normal_kill_gold_pct`,
- `school_damage_pct`,
- `school_resource_gain_pct`,
- `ultimate_charge_gain_pct`,
- `ultimate_power_pct`,
- `school_status_effect_pct`,
- `evasion_chance`,
- Bongma familiar-interval modifier,
- Cheonsul reaction-damage modifier,
- Guiin melee-radius modifier,
- Heukyeong marked-target critical-chance modifier,
- Heukyeong mark-duration modifier.

Contributions within one percentage channel are additive. Distinct channels are then applied in a fixed order. For example, an ultimate hit resolves as:

`base_damage * (1 + school_damage_pct) * (1 + ultimate_power_pct)`

Player maximum HP resolves as:

`roundi((base_max_health + max_health_flat) * (1 + max_health_pct))`

Movement resolves from base move speed times the movement multiplier. Incoming damage and healing use their corresponding final multipliers.

Recomputing after a sale/removal prevents order-dependent stacking bugs.

### `ShopController`

Owns offer generation and reroll progression. It delegates wallet/inventory legality to `RunBuildState`.

Rules:

- exactly 3 distinct item ids per roll,
- exclude an item already at its two-copy cap,
- repeats are allowed across different rolls/rests,
- uniform selection is sufficient; no rarity weights,
- purchase failure is atomic,
- sale removes one owned copy and refunds its fixed sell value,
- reroll cost resets at each new rest.

For deterministic tests, candidate generation accepts an injected/seeded `RandomNumberGenerator` or equivalent deterministic picker.

### `FateController`

Owns five fate definitions and candidate generation.

Rules:

- exclude already selected fate ids,
- offer exactly 3 distinct candidates,
- require exactly one selection,
- selected fate is added to `RunBuildState` immediately,
- no removal/replacement during the run.

At rest 3 exactly three unselected fates remain, so all three are shown.

Candidate generation is seedable/injectable for tests.

### `CombatContributionTracker`

Owns segment telemetry and the frozen result snapshot.

Axes:

- actual damage dealt,
- actual healing received,
- actual incoming damage prevented,
- successful status/reaction application events,
- kills and segment maximum combo.

Also snapshot:

- segment GOLD earned,
- reward-orb collection delta when available,
- deterministic growth hints.

A result snapshot is immutable after boss-death transition completion. Shop/fate/healing mutations during rest cannot rewrite it.

### `CombatResolver`

Small shared damage helper used by school runtime attacks and their spawned attack nodes.

Responsibilities:

- accept base school damage and damage kind (`normal`, `ultimate`, or school subtype),
- apply run modifiers,
- apply school-specific token/fate effects where relevant,
- convert the final positive hit to an integer,
- call the target damage API,
- record actual target HP loss in `CombatContributionTracker`.

`EnemyChaser.take_damage()` may return actual HP loss while preserving callers that ignore the return value.

Status/reaction application remains owned by the runtime that knows whether it actually succeeded; successful events are then recorded in telemetry.

### `RestFlowUI`

Dedicated full-screen rest overlay, separate from combat HUD.

It renders only the current stage-flow state:

- result cards,
- shop,
- fate candidates,
- next-combat preview,
- terminal MVP-3 completion panel.

It emits intent signals only. It does not mutate economy, inventory, fate, enemies, timers, or school state directly.

## Existing-system integration

### `MainController`

Keep existing wiring responsibilities for GameState, CombatDDD, enemy death, school selection/host, player death, HUD, and reward orbs.

MVP-3 adds composition/wiring between the new focused controllers. Main must not contain the shop catalog, fate catalog, timer state machine, or modifier math.

Boss death still passes through the normal enemy-death path exactly once, preserving:

- GameState kill/score,
- MVP-1 combo/stylish behavior,
- active school `on_enemy_died`,
- reward-orb spawning.

GOLD differs by enemy type:

- normal enemy: exactly `+1 GOLD`,
- stage boss: exactly `+25 GOLD`.

A boss does not also receive the normal +1 reward.

### `WaveSpawner`

Use the existing `set_spawning_enabled(bool)` boundary.

At a five-minute threshold:

1. disable new normal spawning,
2. leave living normal enemies active,
3. spawn one stage boss,
4. stay in `BOSS` until it dies.

After boss death and snapshot creation, remove remaining normal enemies without emitting kill rewards, score, combo, school kill-resource, or GOLD. This preserves boss-fight pressure without carrying stale mobs into the next segment.

Pending reward orbs are not converted into free rewards. They remain paused and may resume next segment; only actually collected orbs count in the segment where collection occurs.

### School runtime pause semantics

Rest pauses the selected runtime by process state, not by semantic deactivation/reset.

Do not call a path that clears school identity/resource merely because rest begins. Spirit, reaction count, Gwihyeol, mark-related run state that is not tied to removed enemies, and other persistent runtime resources remain unless their own rules consume them.

Enemy-bound marks/statuses naturally disappear when their enemy is removed.

### `PlayerController`

Add only the reusable surface needed for approved effects:

- apply/reapply `RunModifierSet`,
- `heal(amount)` returning/emitting actual healing,
- incoming-damage resolution with evasion and damage-taken modifiers,
- requested/applied/prevented damage reporting for defense telemetry.

Defense contribution is actual prevented damage only:

- reduction: requested minus applied,
- evade: full requested damage,
- no damage event: zero contribution.

Changing maximum HP is not defense. If max HP falls below current HP after sale/fate recomputation, current HP clamps to the new maximum.

Evasion uses an injectable/seeded random source for tests; production uses normal runtime randomness.

## Stage and boss behavior

### Combat segments

- Segment 1: combat minutes 0-5,
- Segment 2: combat minutes 5-10,
- Segment 3: combat minutes 10-15.

Normal wave behavior otherwise stays at the current MVP-2 level. MVP-3 does not add another regular-enemy archetype or a difficulty director.

### Boss archetype

One chaser-style boss scene reuses the existing enemy contract. It is larger than a normal enemy and explicitly identifiable as a stage boss for flow/GOLD logic.

Initial tuning defaults:

| Tier | Max HP | Move speed | Contact damage | Visual scale |
| --- | ---: | ---: | ---: | ---: |
| 1 | 200 | 70 | 15 | 1.6x |
| 2 | 350 | 80 | 20 | 1.8x |
| 3 | 500 | 90 | 25 | 2.0x |

These are tuning constants, not architecture. Keep the current contact cooldown unless playtesting finds a blocker. No bespoke phases/patterns in MVP-3.

## GOLD economy

### Income

- normal kill: `1 GOLD`,
- boss kill: `25 GOLD`,
- GOLD persists across segments/rests,
- SCORE is separate and never spent.

`행운 부적` modifies normal-kill GOLD only; boss reward remains fixed at 25G.

Percentage normal-kill GOLD bonuses use deterministic fractional carry. One `행운 부적` creates 1.25 reward credit per normal kill; whole GOLD is paid when accumulated credit crosses an integer boundary. This preserves exact long-run +25% without random rounding.

### Prices and sales

Fixed prices:

- 20G utility,
- 30G specialized,
- 40G strong/school-specific.

Sell value is exactly 50% of fixed base price:

- 20G -> 10G,
- 30G -> 15G,
- 40G -> 20G.

No buyback or purchase-price history.

### Reroll

Within one rest:

`5G -> 10G -> 15G -> 15G -> ...`

Next rest resets to 5G.

Insufficient GOLD rejects the reroll with no wallet, offer, or reroll-index change.

### Inventory constraints

- maximum 6 owned item copies total,
- maximum 2 copies of one item id,
- rejected purchase changes neither GOLD nor inventory,
- sale immediately recomputes modifiers.

This list is intentionally non-spatial. MVP-4 adds footprint/position/adjacency to the same items.

## `ItemDefinition` contract

At minimum:

- stable id,
- display name,
- base price,
- derived sell price,
- tags,
- effect/modifier kind,
- effect value,
- optional school-specific payload.

MVP-4 may extend this definition with backpack geometry/adjacency metadata.

## Initial shop pool

### `체술단련` — 20G

Movement speed `+10%` per copy.

### `호신 부적` — 20G

Maximum HP `+20` flat per copy. On purchase, heal exactly the effective max-HP increase, capped at the new maximum. Selling removes the contribution and clamps current HP if required.

### `행운 부적` — 20G

Normal-enemy kill GOLD `+25%` per copy via deterministic fractional carry. Boss GOLD stays fixed.

### `인법단련` — 30G

School direct damage `+12%` per copy through `school_damage_pct`. This includes school attacks that occur during an ultimate; the separate ultimate-power channel may additionally apply when appropriate.

### `깨달음` — 30G

School resource/counter gain `+20%` per copy where the school actually has a qualifying gain event. It does not invent events.

### `재생의 두루마리` — 30G

Whenever combat resumes from a rest, heal `20%` of effective max HP per copy. Overheal is discarded. The tracker resets before this heal, so actual restored HP belongs to the new segment.

It cannot trigger before segment 1 because it cannot be owned before the first shop.

### `오의 비전서` — 40G

Improves the selected school's existing ultimate-readiness mechanism by `+25%` per copy without introducing a universal ultimate meter.

Mapping:

- 봉마류: spirit gains that contribute to ultimate readiness `+25%` per copy,
- 천술류: reaction readiness gain `+25%` per copy using deterministic fractional progress,
- 귀인류: Gwihyeol gains `+25%` per copy,
- 흑영류: because readiness depends on active marks rather than a numeric gain meter, mark duration `+25%` per copy so marks remain simultaneously active longer and the existing three-mark readiness rule remains intact.

This explicit Heukyeong mapping prevents the item from becoming a no-op while preserving the MVP-2 ultimate condition.

### `유파 증표` — 40G

One generic item id resolved from selected school:

- 봉마류: familiar attack interval `-15%` per copy,
- 천술류: WET+SHOCK primary and chain reaction damage `+20%` per copy,
- 귀인류: representative melee radius `+15%` per copy,
- 흑영류: attacks against a currently marked target gain `+15 percentage points` critical chance per copy; qualifying critical hits deal `2.0x` final Heukyeong attack damage.

Critical chance exists only inside this Heukyeong-specific rule in MVP-3; do not create a universal crit framework.

## Fate pool

Fate is a benefit-plus-cost run rule, not a free stat card. UI shows both sides before selection.

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
- qualifying school status/reaction effect `+20%`,
- incoming damage `+15%`.

`school_status_effect_pct` is consumed only by a runtime with a qualifying effect:

- 천술류: elemental reaction damage,
- 흑영류: mark-based execution/burst damage,
- 봉마류/귀인류: no artificial status system is created; they receive the resource benefit where applicable but no fake status bonus.

### `봉인의 길`

- ultimate readiness gain `+30%`,
- ultimate power `+25%`,
- non-ultimate school direct damage `-15%`.

`ultimate_power_pct` strengthens the primary offensive output while the ultimate is active or executed:

- 봉마류: familiar damage dealt during `백귀야행`,
- 천술류: `오행폭주` direct damage,
- 귀인류: its existing ultimate offensive output,
- 흑영류: its existing shadow-execution ultimate damage.

This prevents Bongma's non-single-hit ultimate from receiving no benefit.

No selected fate may appear again. Exactly three distinct unselected candidates are shown per rest, and the player cannot proceed without choosing one.

## Rest flow

Gameplay is inert throughout rest: player, enemies, selected school processing, spawner, boss, and stage clock are paused. UI remains active.

### RESULT

Show cards for:

- actual damage dealt,
- actual healing,
- actual damage prevented,
- status/reaction event count,
- kills,
- maximum combo,
- segment GOLD earned,
- reward-orb collection delta when available,
- 1-2 growth hints.

If healing/defense has no real event, show `기여 없음` rather than a fabricated mechanic.

MVP-3 has no combat item-drop pipeline, so do not fabricate a `key loot` item. The result's key reward summary is the real segment GOLD/orb reward data.

`Continue` advances to SHOP without changing the build.

### SHOP

Show current GOLD, three offers, owned items/counts, buy/sell controls, reroll cost, and `Next`.

The player may buy/sell/reroll repeatedly while legal or skip purchases entirely.

### FATE

Show three unselected fate cards with title, benefit, and cost. There is no skip. Selecting one applies it and permits PREVIEW.

### PREVIEW

Show:

- next segment number,
- next boss tier,
- this rest's item buy/sell changes,
- newly selected fate,
- cumulative fates,
- current GOLD,
- one-line next-combat expectation.

After rests 1 and 2, `Start Combat` resumes the next segment.

After rest 3, show `MVP-3 LOOP COMPLETE` with restart; do not start segment 4.

## Combat HUD

Keep existing MVP-2 HUD. Add only:

- `SEGMENT n/3`,
- remaining segment combat time, e.g. `04:32`,
- GOLD.

Large rest panels remain in `RestFlowUI`, not `HUDController`.

## Contribution telemetry

### Damage

Count actual target HP lost, not requested damage. A target at 3 HP hit for 20 contributes 3 damage.

### Healing

Count actual HP restored after cap. A player missing 5 HP healed for 20 contributes 5.

### Defense

Count incoming damage actually prevented by run modifiers:

- reduction contributes requested minus applied,
- successful evade contributes the full requested amount.

Max-HP clamping is not defense.

### Status/reaction

Count one successful school-owned application/reaction event when the runtime confirms it. Cheonsul elemental applications/reactions and Heukyeong mark applications qualify. Event damage also contributes separately to damage.

### Kill/combo

Track segment kill count and segment maximum combo. Existing overall MVP-1 DDD state is not reset; the contribution tracker stores segment-local deltas/maximums.

## Growth hints

Hints are deterministic and based only on observed contribution plus current build state.

Rules:

- strongest non-zero axis drives the primary hint,
- add a second hint only when another non-zero axis or owned-item/fate synergy creates a clear recommendation,
- never derive healing/defense advice from a zero-event axis,
- recommend a build direction, not a shop item guaranteed to appear.

Representative messages:

- high damage: `현재 화력을 유지할 피해/유파 강화가 잘 맞습니다`,
- high status: `상태·반응 빈도 또는 효과를 키우는 선택이 잘 맞습니다`,
- meaningful defense: `생존 투자 효율이 실제로 나오고 있습니다`,
- high kill/combo with lower direct damage: `이동·공격 주기를 유지해 콤보 흐름을 강화할 수 있습니다`.

## Boundary and failure behavior

- Before school selection, stage clock is stopped and no combat GOLD is earned.
- Only one boss exists for the active milestone.
- A threshold cannot spawn duplicate bosses on later frames.
- Boss death is processed exactly once.
- Normal spawning stays disabled during `BOSS` and rest.
- Rest cannot begin before boss death.
- Result snapshot occurs after boss kill/score/GOLD/combo/school callbacks.
- Cleanup of leftover normal enemies never emits normal rewards.
- Purchase failure is atomic.
- Reroll failure is atomic.
- Selling a non-owned item fails without mutation.
- Fate selection fails for an already selected or non-offered fate.
- `Start Combat` is valid only in PREVIEW after that rest's fate is selected.
- Player death during `COMBAT` or `BOSS` always wins over pending stage transitions and uses existing game-over flow.
- No shop/fate/rest reward is granted after death.
- Existing `ui_accept` game-over restart precedence remains intact.
- Rest pause never erases selected-school identity or persistent school resource.

## Testing strategy

Keep both unit and integration GUT layers.

### Unit tests

Cover at least:

- legal/illegal stage transitions,
- production default duration = 300 seconds,
- injected short duration reaches BOSS exactly once,
- boss kill advances to RESULT after reward registration,
- third preview terminates the slice,
- normal/boss GOLD distinction,
- fractional normal-kill GOLD carry,
- three-offer uniqueness,
- affordability/capacity/duplicate-cap failures,
- sale refund and modifier removal,
- reroll sequence/reset/failure atomicity,
- all eight item mappings,
- modifier recomputation after buy/sell,
- max-HP purchase heal and sell/fate clamp,
- rest-start regeneration actual healing,
- all five fate modifier mappings,
- fate candidate exclusion/mandatory choice,
- actual-value damage/heal/defense telemetry,
- status event counting,
- deterministic growth hints,
- boss tier data.

### School regression tests

For all four schools:

- selection/activation still works,
- base combat still kills enemies,
- existing resource/ultimate readiness still works,
- rest pause/resume preserves school identity/resource,
- school-damage modifier changes actual damage,
- qualifying resource/ultimate-readiness modifiers work,
- `오의 비전서` has a non-no-op mapping,
- `유파 증표` school-specific effect works,
- `봉인의 길` ultimate-power benefit is observable,
- existing ultimate behavior is not broken.

### Integration tests

At least one accelerated main-scene path covers:

`school select -> COMBAT -> timer threshold -> BOSS -> boss death -> RESULT -> SHOP -> FATE -> PREVIEW -> next COMBAT`

Also cover:

- full accelerated three-segment path ending at `MVP-3 LOOP COMPLETE`,
- player death in normal combat,
- player death in boss combat,
- buy/sell/reroll reflected in preview and next-combat modifiers,
- result snapshot unchanged by later rest mutations.

### Manual acceptance

Normal main-scene sanity check:

- school selection still gates combat,
- HUD shows segment/time/GOLD without hiding existing school/combo data,
- at real 5:00 combat time normal spawning stops and exactly one boss appears,
- living normal enemies remain active during the boss fight,
- boss defeat enters readable RESULT,
- displayed contribution is directionally consistent with observable play,
- shop failures clearly communicate insufficient GOLD/capacity/duplicate cap,
- buy/sell/reroll require no hidden controls,
- fate cards clearly show upside and downside,
- combat is inert during rest,
- `Start Combat` resumes correctly,
- game over/restart still works.

Automated acceptance uses injected time and must not require waiting 15 real minutes. A full production-time 15-minute run is for final tuning, not CI.

## Compatibility and repository safety

Preserve MVP-0/1/2 behavior unless this spec explicitly changes it.

Expected implementation stays in scenes/scripts/tests/docs. Avoid `project.godot` so local Godot AI/Hera/GUT plugin state remains isolated. Never stage or clean unrelated local plugin files.

Do not merge/integrate the feature branch without explicit user approval after implementation, adversarial review, regression checks, and CI evidence.

## Acceptance summary

MVP-3 is complete when:

1. a selected school can play three five-minute combat segments,
2. each segment ends in a required tiered midboss kill,
3. each boss kill produces an immutable contribution result,
4. each rest provides a real GOLD shop with buy/sell/reroll,
5. reusable items modify subsequent combat and obey 6-item/2-copy limits,
6. each rest requires one new benefit-plus-cost fate from three unselected candidates,
7. item/fate modifiers have meaningful mappings across all four schools without collapsing runtime boundaries,
8. preview communicates the build change before next combat,
9. third preview ends with `MVP-3 LOOP COMPLETE`,
10. movement, game over, DDD, selection, school combat, and restart regressions pass,
11. unit/integration tests pass in CI,
12. backpack spatial mechanics and the 20-minute final loop remain deferred.
