# MVP-2 Manual Play Tuning Amendment

## Status

Approved in-scope tuning after Windows manual play of the four-school MVP-2 slice. The player confirmed that all four schools were implemented and felt materially different, then identified three balance/usability issues and requested WASD movement.

This amendment refines the approved MVP-2 spec without expanding into later progression systems.

## Changes

### Live restart

Add an always-available `RESTART` button to the HUD during active gameplay. The button and game-over `ui_accept` share the same `MainController._restart_run()` scene-reload path, returning to the four-school selection screen.

### Movement

Keep existing `ui_left/right/up/down` movement and add physical `W/A/S/D` movement. Do not add shared InputMap entries to `project.godot`; combine the existing UI-action vector with physical WASD key state in `PlayerController` so local plugin-only `project.godot` state remains isolated.

### Cheonsul ultimate reliability

Keep `REACTION 0 / 3` and all damage/timing values. The observed issue is target churn between alternating WET and SHOCK casts. On an automatic SHOCK cast, prioritize the nearest valid enemy that already carries WET; if no WET target exists, fall back to the normal nearest-enemy target. This improves reaction/ultimate reliability without converting the mechanic into passive charge.

### Heukyeong ultimate accessibility

Keep per-enemy burst threshold at 3 marks. Change total active-mark requirement for `암영처형` from 6 to 3. Because an enemy bursts and clears when a hit reaches 3 marks, a two-enemy MVP wave cannot sustain 6 active marks; a threshold of 3 makes the ultimate reachable in the current enemy-density slice while preserving mark-management behavior.

## Regression requirements

- Existing arrow-key movement still works after WASD support is added.
- Opposing arrow/WASD directions cancel and combined diagonal movement remains normalized.
- The restart button is wired while the player is alive; game-over Enter restart still uses the same scene reload path.
- Cheonsul SHOCK target preference must produce reaction progress when a live WET target exists, without changing non-recursive chain rules.
- Heukyeong must be able to reach ultimate-ready state with two live enemies and three total active marks.
- Existing MVP-0/MVP-1/MVP-2 regression tests remain green.
