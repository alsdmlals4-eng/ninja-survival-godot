# T13 Persistent Workbench Route UI Design

## Goal

Implement the smallest reusable Workbench presentation and input surface for the T12 transaction: the player can inspect legal next-school choices, make one clearly provisional route choice, make one pending Fate choice, and request the existing atomic commit.

## Confirmed context

- `RunRouteState` owns unvisited/provisional/active/cleared school facts.
- `FateController` owns pending Fate validation; `RestCommitCoordinator` owns the final all-or-nothing tuple commit.
- `RestBackpackSession` owns the six-slot buffer and every backpack edit legality rule.
- Current `MainController` still runs the protected MVP-3 linear REST loop and does not yet construct the T12 spatial REST transaction. Forcing that wiring here would absorb T14 encounter/branch integration.

## Player experience

At the Workbench, a player sees only schools that can legally be visited next. Each card says what kind of danger and reward language to expect, without exposing exact combat tuning. Selecting a card says "provisional" immediately; selecting Fate is also visibly pending. The final button asks the coordinator to commit, and is unavailable while the existing transaction is incomplete.

## Selected approach

Extend `RestFlowUI` with a focused `WorkbenchView` rather than create a second overlay. The view receives read-only route/Fate/readiness snapshots, dynamically builds route and Fate buttons, keeps normal Control focus navigation, and exposes every action as a signal. It does not reference `RunRouteState`, `FateController`, `RestBackpackSession`, or `RestCommitCoordinator` directly.

This is preferred over embedding rules in UI because it preserves the T12 owner boundary. It is preferred over wiring the old stage loop now because the loop lacks the actual spatial REST transaction and would falsely present an end-to-end T13/T14 flow.

## UI contract

`RestFlowUI.show_workbench(route_snapshot, fate_candidate_ids, fate_definitions, pending_fate_id, readiness_failures)` renders:

- exactly `unvisited_school_ids` route cards;
- selected/provisional route state from `provisional_school_id`;
- each school's fixed Korean identity, risk, gimmick, reward, and tag text;
- Fate cards from supplied candidate IDs;
- a human-readable unresolved-work summary derived from supplied failure codes;
- a final commit button disabled when no provisional route, no selected pending Fate, or any readiness failure exists.

Signals:

- `workbench_route_selected_requested(school_id)`;
- existing `fate_selected_requested(fate_id)`;
- `workbench_commit_requested()`.

The caller re-renders updated snapshots after an accepted intent. UI signals never mutate a domain object. `show_workbench` must be safe to call repeatedly and replace dynamic children without accumulating stale focus or signals.

## Input and accessibility

- Route/Fate/commit choices are standard `Button` controls, so mouse, touch, keyboard, and gamepad focus share the same control path.
- When displayed, focus moves to the first route card; after route refresh it stays on the matching provisional card where possible.
- Buttons use the project default InputMap; this package adds no new action mappings.
- Touch target/device suitability is only code-level control-path coverage. Human/device evidence remains NOT_RUN.

## Scope and exclusions

In scope: `RestFlowUI`, its scene, focused integration tests, and documentation needed to state T13's new UI boundary.

Out of scope: backpack board rendering/edit controls, shop/chest/boss-reward presentation, MainController's T14 branch/encounter integration, new combat content, save/meta systems, assets, balance, PR #49, and claims of Human Usability or end-to-end playable Run success.

## Acceptance and verification

1. Only legal unvisited school cards appear; exact hidden HP/DPS/spawn/timing values never appear.
2. A provisional selection is visible but remains a UI snapshot; emitting route/Fate/commit signals mutates no domain state.
3. Commit is unavailable until caller supplies both pending route/Fate and an empty readiness-failure list.
4. Mouse/touch button presses and focus navigation exercise the same emitted-intent contracts.
5. Existing REST views/tests remain valid; new focused UI tests, full GUT, Godot import, and main-scene smoke pass.

## Revisit condition

T14 must connect this contract to a real post-clear Workbench session and prove the full branch/commit path. If that exposes a missing presentation field, add it to a read-only snapshot instead of moving legality into UI.
