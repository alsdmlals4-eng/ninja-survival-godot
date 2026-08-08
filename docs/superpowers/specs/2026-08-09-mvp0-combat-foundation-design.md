# MVP-0 Combat Foundation Design

## Approval

- Approval reference: user approved the proposed `MVP-0 vertical slice + GUT` design and explicitly activated `[연속작업] 진행해` on 2026-08-09.
- Continuous work state: `CONTINUOUS_WORK_ACTIVE` for this approved MVP-0 scope only.
- Work mode sequence: `PLAN -> BUILD -> REVIEW`.

## Goal

Create the smallest runnable Godot combat slice that proves the player can move, enemies can chase, automatic attacks can kill enemies, score/HP feedback updates, and player death produces a game-over state.

This is a validation slice, not the full planning MVP.

## Player Experience

The player should immediately understand the basic loop without tutorials or finished art:

1. Move in eight directions.
2. Enemies approach the player.
3. The character automatically fires at the nearest enemy.
4. Hits remove enemies and increase the visible score/kill count.
5. Enemy contact drains HP.
6. At zero HP, gameplay stops and a clear game-over message appears.

The slice should feel readable and responsive enough to become the foundation for MVP-1 kill-combo and reward-absorption feedback.

## Benchmarking conclusion

- Must reflect: minimal controls, immediate attack/hit/kill feedback, readable reward feedback.
- Conditional: short reward rhythm may be represented only by score/kill feedback in MVP-0.
- Excluded: backpack management, school-specific mechanics, fate choices, shop loops, deep progression, complex enemies.
- Risks: copying survivor-game conventions without preserving the project's ninjutsu/build identity; MVP-0 must stay deliberately shallow so later systems can provide that identity.
- Validation method: Godot runtime smoke test plus focused GUT unit tests for deterministic logic.

## Architecture

Use small Godot scenes and scripts with explicit responsibilities. Avoid a large global manager, event bus, data framework, or premature Resource/JSON abstraction in MVP-0.

`main_scene.tscn` owns composition and high-level run state. `player.tscn`, `enemy_basic.tscn`, and `projectile_basic.tscn` own their local behavior. `game_state.gd` owns score/kill state only. `hud.tscn` displays HP, score, and game-over feedback. `auto_attack_controller.gd` owns target selection and projectile spawning.

Use Godot 4.x/GDScript idioms. Player and enemy movement use `CharacterBody2D`. Input uses built-in `ui_left`, `ui_right`, `ui_up`, `ui_down`, and `ui_accept` actions so MVP-0 does not need a custom input-map edit.

## Components

### `scripts/core/game_state.gd`

Owns `score` and `kill_count` and emits a score update signal. `register_kill(points)` is the only MVP-0 mutation entry point.

### `scripts/player/player_controller.gd`

Owns player HP and movement. Reads eight-direction input, normalizes via `Input.get_vector`, moves with `move_and_slide`, applies damage through `take_damage(amount)`, and emits `health_changed` / `died` signals.

### `scripts/enemies/enemy_chaser.gd`

Owns enemy HP, simple player tracking, contact-damage cooldown, and death signaling. The enemy is added to the `enemies` group so the auto-attack controller can discover candidates without hard references.

### `scripts/combat/auto_attack_controller.gd`

Runs a fixed attack interval. It finds the nearest valid enemy and spawns one projectile toward it. If no valid enemy exists, it does nothing. Nearest-target selection is exposed as a deterministic method so GUT can test it directly.

### `scripts/combat/projectile.gd`

Moves in a fixed direction, damages an enemy on overlap, and frees itself after impact or lifetime expiry.

### `scenes/main/main_scene.tscn`

Composes GameState, Player, HUD, a simple arena background, and several initial enemies. Connects enemy death to score registration and player death to the game-over state. `ui_accept` restarts after game over.

### `scenes/ui/hud.tscn`

Shows `HP`, `KILLS/SCORE`, and the game-over/restart prompt. It contains no gameplay rules.

## Data flow

```text
Input -> PlayerController -> CharacterBody2D movement
EnemyChaser -> PlayerController.take_damage -> health_changed -> HUD
AutoAttackController -> nearest enemy -> Projectile -> EnemyChaser.take_damage
EnemyChaser.died -> Main -> GameState.register_kill -> score_changed -> HUD
PlayerController.died -> Main -> game_over -> HUD
ui_accept while game_over -> reload current scene
```

## Error and edge handling

- No target: auto attack skips the shot.
- Freed/invalid target: target selection ignores invalid nodes.
- Zero-length aim vector: projectile is not spawned.
- Damage at or below zero HP: death is emitted once.
- Enemy contact damage is cooldown-gated to prevent frame-rate-dependent HP loss.
- Projectiles self-delete after a short lifetime to prevent accumulation.
- Runtime scene wiring remains intentionally simple; no save data is created.

## Visual scope

Use placeholder geometry/colors only. Do not start polished art, animation, VFX production, or school-specific visual language in this Goal.

## Testing strategy

GUT tests focus on deterministic behavior that does not require visual judgment:

- GameState increments kill count and score.
- Player damage clamps HP and emits death only at zero.
- Nearest-target selection chooses the closest valid enemy and returns null when empty.
- Enemy damage reaches zero and emits one death signal.

Runtime checks cover scene wiring, movement feel, camera follow, projectile collision, contact damage cadence, HUD readability, game-over, and restart.

The local GUT plugin is user-confirmed enabled/approved. Exact installed GUT version is not yet repository-verifiable; tests therefore use only stable core `GutTest` assertions. Godot is user-confirmed at 4.7.1. Official GUT documentation currently maps the 9.7.x line to Godot 4.7.x, but this task does not upgrade or replace the user's installed plugin.

## Integration safety

The user's local project may now contain plugin-generated changes to `project.godot` and `addons/` that are not present on GitHub. To avoid overwriting local plugin activation, this branch does not replace plugin configuration.

The main scene can be run directly during verification. Setting `application/run/main_scene` in `project.godot` is an integration step after local Git status/plugin changes are reconciled.

## Completion criteria

MVP-0 is complete only when fresh runtime evidence shows all of the following:

- Godot opens the project without blocking errors.
- Player moves in eight directions and camera follows.
- Enemies approach the player.
- Automatic projectiles target enemies.
- Hits can kill enemies and score/kill UI updates.
- Enemy contact can reduce HP.
- HP reaching zero displays game over.
- `ui_accept` restarts the run after game over.
- GUT tests pass on the user's Godot 4.7.1 environment.

Repository/code review without those runtime checks is not sufficient to claim completion.

## Explicit exclusions

- Kill-combo/stylish score/reward absorption (MVP-1)
- Four schools and their ninjutsu (MVP-2)
- Stage/rest/result systems (MVP-3)
- Backpack/combination systems (MVP-4)
- Final boss/meta reward loop (MVP-5)
- Full art, audio, animation, balancing, save system, economy, or complex enemy patterns
