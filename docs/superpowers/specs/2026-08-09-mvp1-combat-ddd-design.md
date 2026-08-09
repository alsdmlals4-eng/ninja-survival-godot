# MVP-1 Combat DDD Design

## Goal

Add the first combat-feedback layer on top of the verified MVP-0 loop without introducing real progression, economy, schools, backpack, fate, or stage/result systems.

The MVP-1 slice must make repeated kills feel immediately more satisfying through:

- short-window kill combo feedback,
- stylish score and combo titles,
- a non-progression reward orb that visibly drops and is absorbed,
- a simple timed spawn-wave rhythm that keeps combat pressure readable.

This phase validates DDD feedback only. It must not grant combat power, XP, gold, permanent progression, or shop currency.

## Source Alignment

The live planning sheet defines MVP-1 as: kill combo, stylish score, reward absorption, and a simple spawn wave. It also states that early combo rewards should focus on display/feedback rather than performance bonuses.

The approved reward approach is therefore:

- each enemy death creates one small reward orb,
- the orb visually travels toward the player and is collected,
- collection increments a DDD reward counter and adds presentation-oriented stylish score,
- collection does not modify health, damage, attack speed, XP, gold, or any future economy value.

## Scope

### Included

1. Kill combo tracking with a generous reset window.
2. Maximum combo tracking for the current run.
3. Stylish score derived from kills and reward collection.
4. Short ninja-style title feedback at combo thresholds.
5. Reward orb spawn, homing movement, collection, and counter feedback.
6. Simple timed spawn waves with an active-enemy cap.
7. HUD feedback for combo, stylish score, reward count, and short title flashes.
8. Unit/integration GUT coverage and the existing Godot 4.7.1 CI gates.

### Explicitly excluded

- XP and level-up progression,
- gold or shop economy,
- attack/defense bonuses from combo,
- combo failure penalties,
- schools/ninjutsu/ultimate mechanics,
- backpack or rest flow,
- stage timers/boss milestones/results screen,
- audio/art polish beyond placeholder Godot geometry and text feedback.

## Architecture

### `CombatDDDTracker`

Add a dedicated Node responsible only for DDD run-state. It keeps DDD concerns separate from the existing `GameState`, which remains the owner of ordinary kill count and score.

State:

- `combo_count: int = 0`
- `max_combo: int = 0`
- `stylish_score: int = 0`
- `reward_count: int = 0`
- `combo_time_remaining: float = 0.0`

Initial tuning constants:

- `combo_window = 2.5` seconds
- kill stylish base = `100`
- combo step bonus = `20` per combo count above 1
- reward-orb collection stylish bonus = `25`

Behavior:

- `register_kill()` increments combo if the previous combo window is still active; otherwise it starts a new combo at 1.
- Every kill refreshes the full 2.5-second window.
- `max_combo` is updated immediately.
- stylish score gains `100 + 20 * (combo_count - 1)` for that kill.
- `_process(delta)` reduces the remaining combo window. When it reaches zero, current combo resets to zero; `max_combo` is preserved.
- `register_reward_collected()` increments `reward_count` and adds 25 stylish points.

Signals expose state to the HUD without direct UI dependencies.

### Combo titles

Titles are presentation-only and emitted when a kill reaches the threshold exactly:

- combo 3: `그림자 연쇄`
- combo 6: `닌자 난무`
- combo 10: `백귀 격파`

No higher gameplay effect is attached to them. If a future phase needs more titles, it extends a threshold table instead of changing combo mechanics.

### `RewardOrb`

Add a lightweight `Area2D` reward object with placeholder visual geometry.

Responsibilities:

- spawn at the defeated enemy's last global position,
- receive a player target,
- move toward that target every physics frame at a fixed speed,
- when close enough, emit `collected` and queue itself for deletion,
- never change player stats directly.

Initial tuning:

- move speed: `360.0`
- collect radius: `18.0`
- lifetime safety timeout: `5.0` seconds

The orb starts homing immediately. There is intentionally no pickup-radius stat or manual collection mechanic in MVP-1.

### `WaveSpawner`

Replace the MVP-0 one-for-one replacement behavior with a simple timed batch rhythm.

Initial behavior:

- main scene begins with the existing four enemies,
- every `5.0` seconds, the spawner attempts to create a batch of `2` enemies,
- active enemies are capped at `8`,
- spawn positions rotate through the existing four cardinal directions at the existing 320-pixel distance,
- if the cap would be exceeded, spawn only the number needed to reach the cap,
- no difficulty scaling, elite types, random tables, or boss logic.

The spawner emits an `enemy_spawned(enemy)` signal. `MainController` remains responsible for wiring targets/death callbacks so gameplay composition stays centralized.

This wave behavior keeps pressure sustained while making arrivals visibly rhythmic instead of instantly replacing every kill.

### `MainController`

`MainController` remains the composition root and gains only orchestration responsibilities:

- on enemy death:
  - capture the death position,
  - register ordinary kill/score with `GameState`,
  - register DDD kill with `CombatDDDTracker`,
  - spawn one reward orb at the death position,
- on reward collection:
  - register reward collection with `CombatDDDTracker`,
- on wave-spawner enemy creation:
  - wire target and death callback using the existing enemy wiring path,
- on game over:
  - disable gameplay children exactly as MVP-0 does, including wave spawning and existing orbs,
  - keep HUD/main input alive so Enter restart remains functional.

`MainController` must not own combo calculations or wave-timer calculations.

### HUD

Extend the existing HUD with minimal text-only feedback:

- existing HP line,
- existing kills/score line,
- new `COMBO xN` label that is hidden or blank at combo 0,
- new `STYLE N` label,
- new `ORBS N` label,
- one short title label used for threshold text.

The title label is shown when a title signal arrives and automatically clears after about 1.0 second. This is visual feedback only; no animation system is required.

## Data Flow

Enemy death flows as:

`EnemyChaser.died -> MainController -> GameState.register_kill + CombatDDDTracker.register_kill + RewardOrb spawn`

Reward collection flows as:

`RewardOrb.collected -> MainController -> CombatDDDTracker.register_reward_collected`

Wave creation flows as:

`WaveSpawner timer -> enemy instantiate -> enemy_spawned -> MainController._wire_enemy`

HUD updates flow only through tracker/game-state signals. The HUD does not inspect gameplay nodes for state.

## Failure / Edge Handling

- Non-positive `delta` does not advance combo timeout.
- A kill after the combo window expires starts again at combo 1.
- Combo timeout resets only the current combo; maximum combo and stylish score remain.
- Reward orb with an invalid/dead target cleans itself up without granting a reward.
- Reward collection is single-shot; one orb cannot increment the counter twice.
- Wave spawning does nothing after game over.
- Wave spawning respects the enemy cap even if previous enemies are still alive.
- An invalid enemy/reward PackedScene fails safely without crashing the main loop.
- Restart reloads all DDD counters back to their scene defaults.

## Testing Strategy

### Unit tests

`CombatDDDTracker`:

- first kill starts combo 1,
- kill inside 2.5 seconds increments combo,
- timeout resets current combo,
- kill after timeout starts combo 1,
- max combo survives timeout,
- stylish score formula is deterministic,
- title signals fire exactly at 3/6/10,
- reward collection increments reward count and stylish score.

`RewardOrb`:

- configured target is stored,
- orb moves toward target,
- collection emits once and consumes the orb,
- invalid target does not grant collection,
- lifetime expiry consumes the orb.

`WaveSpawner`:

- one wave creates a batch of two when below cap,
- wave creates only the remaining capacity near cap,
- wave creates nothing at cap,
- spawn direction rotates deterministically,
- disabled/game-over state produces no spawn.

### Integration tests

- main scene contains tracker, wave spawner, reward scene binding, and extended HUD,
- enemy death increments normal kill state and DDD combo,
- enemy death creates exactly one reward orb,
- collecting the orb updates DDD reward state/HUD,
- wave spawn routes new enemies through normal target/death wiring,
- game over freezes waves/orbs and still allows restart path,
- existing MVP-0 movement/combat/contact-damage tests remain green.

### Runtime verification

CI remains:

1. Godot 4.7.1 headless import,
2. main-scene headless smoke,
3. full GUT suite.

Windows manual acceptance after remote GREEN:

- repeated kills visibly increase combo,
- pausing kills for more than the combo window clears current combo,
- threshold title text appears,
- orb visibly leaves a defeated enemy and homes into the player,
- orb counter/style score increase without changing combat power,
- enemies arrive in small timed batches instead of instant one-for-one replacement,
- game over and Enter restart still work.

## Acceptance Criteria

MVP-1 is complete only when all of the following hold:

1. A normal combat run can produce and lose a kill combo visibly.
2. Stylish score and max/current combo are deterministic and test-covered.
3. Reward orbs visibly spawn and absorb, but grant no progression or combat stat.
4. Simple waves maintain pressure while respecting the active cap.
5. Game-over/restart behavior from MVP-0 has no regression.
6. Godot 4.7.1 import, smoke, and the full GUT suite pass on the final candidate.
7. Windows manual play confirms the DDD feedback loop.

## Deferred Decisions

The following are deliberately deferred to later MVP phases rather than left ambiguous:

- whether absorbed rewards later become XP, gold, or another resource,
- exact sound/VFX for kills, titles, and orb pickup,
- result-screen rank thresholds,
- combo contribution to final rank,
- dynamic wave difficulty and enemy composition,
- combo/performance bonuses.
