# PROJECT_UNDERSTANDING_VISUAL_PACK — 닌자의 신

```yaml
status: CURRENT_STRUCTURED_PLANNING_SPEC
updated_at: 2026-08-28 KST
visual_board_status: REVISED_FOUR_PANEL_GENERATED_EXPLORATION_REFERENCE_ONLY
visual_board_composition: SCHOOL_SELECTION_TO_CHEONSUL_ACTION_TO_TRACE_BOSS_TO_RESULT_WORKBENCH
previous_board_retained_element: STATUS_ICON_GRAMMAR_ONLY
runtime_asset_status: NOT_CREATED
godot_implementation_status: NOT_IMPLEMENTED
human_player_evidence: NOT_RUN
```

This document owns exact screen meaning. Generated image pixels do not own text, UI labels, game rules, or state transitions.

The user has retained the revised four-panel board as a planning reference while product-design review proceeds. It remains `GENERATED_EXPLORATION`, not an approved Project Asset, runtime implementation, Scene completion, or Human/Player evidence.

## Visual grammar used for every proposed scene

- One fixed black/deep-navy ninja with restrained red cord and warm-gold details; schools add effects, not replacement protagonists.
- Presentation surfaces may use dark parchment and restrained ink/brush framing. Gameplay retains readable 2–3 head SD, steep top-down combat language.
- Cheonsul status/reaction uses blue + amber/orange. Heukyeong retains purple + black. Do not use purple as the default Cheonsul language.
- Status is a compact, silhouette-distinct icon. Do not rely on a persistent written status badge.
- Enemy HP bars are hidden by default; only the enemy that just took damage may expose one. Duration is intentionally undecided pending Human Usability observation.

## 2026-08-28 revised board composition — user-selected A

The user rejected every substantive element of the first generated board except the compact status-icon grammar. The revised candidate therefore reuses only that grammar and redraws character pose, environment, panel layout, UI treatment and all other visual content.

1. `school_selection`
2. `cheonsul_core_action`
3. `trace_boss_gate`
4. `result_workbench`

`failure_retry` remains an actual consumer/specification below, but is deliberately not a panel in this four-panel core-loop board.

## `school_selection`

- **Actual consumer:** `SchoolSelectionUI`.
- **Player goal:** choose one unvisited school battlefield and understand that it changes the danger language, not the protagonist identity.
- **Primary action:** inspect four equal school symbols, then select one route.
- **Meaningful choice:** pick the next school’s threat pattern and reward-access timing while retaining all earlier build commitments.
- **Required information:** visited/unvisited state, school motif, provisional choice state, and a readable transition into the first encounter.
- **Expected feedback:** selected seal gains clear focus and route confirmation without implying an irreversible Fate commit before Workbench.
- **Target emotion:** poised curiosity; “I choose the next danger.”
- **Next scene:** `cheonsul_core_action` for the selected Cheonsul slice.
- **Current evidence:** `SchoolSelectionUI`, P0 v2 `SCRREF-SCHOOL-SELECT-02`, approved one-character rule.
- **Undecided:** final copy, focus animation, and input-scale validation.

## `cheonsul_core_action`

- **Actual consumer:** `Main` + combat HUD + Cheonsul Vertical Slice controller.
- **Player goal:** survive pressure while setting up and observing an ordered elemental reaction.
- **Primary action:** move the fixed SD ninja, position in the arena, and use/observe blue setup followed by amber/orange reaction.
- **Meaningful choice:** take a safe line or hold enemies for a stronger reaction window; use space without letting visual effects hide a telegraph.
- **Required information:** player/enemy/hazard/projectile hierarchy, compact status icons, recently hit enemy HP only, and the next immediate threat.
- **Expected feedback:** blue/amber reaction read, icon state change, hit effect, and exactly one damage-triggered enemy HP bar.
- **Target emotion:** controlled field transformation under pressure.
- **Next scene:** Elite → Trace → Boss gate, then Result on Boss clear.
- **Current evidence:** Cheonsul controller/domain lifecycle, `Main` combat composition, P0 v2 battle reference, approved 2026-08-28 visual grammar.
- **Undecided:** exact icon set, reveal duration, actual-size legibility, sound/haptic feedback, and live telegraph fairness.

## `result_workbench`

- **Actual consumer:** `ResultView` → `RestFlowUI` / Persistent Workbench.
- **Player goal:** understand what was earned, arrange the current build, preview an unvisited route, and decide when to commit Fate.
- **Primary action:** acknowledge a reward, place/rotate items on the 6×6 backpack, inspect adjacency/combination feedback, choose a provisional route and final Fate commit.
- **Meaningful choice:** immediate placement value versus future board shape; a provisional route versus the final all-or-none commit.
- **Required information:** reward source, 6×6 grid, six REST slots, committed versus preview state, provisional route, Fate readiness and commit boundary.
- **Expected feedback:** legal/illegal placement, adjacency/combination preview, pending route/Fate distinction, and atomic commit result.
- **Target emotion:** earned calm followed by deliberate build authorship.
- **Next scene:** next chosen school after Fate commit.
- **Current evidence:** T12/T13 merged machine scope, `RestFlowUI`, current canon, P0 v2 Workbench reference.
- **Undecided:** final HUD density, exact interaction animation, keyboard/gamepad/touch usability, and Player Experience proof.

## `trace_boss_gate`

- **Actual consumer:** Cheonsul lifecycle controller and the existing `Main` combat/result transition path.
- **Player goal:** recognize that an Elite creates a chest token and a non-expiring Trace, then recover that Trace before the Boss warning and dual gate can resolve.
- **Primary action:** defeat the Elite, collect/acknowledge the chest token, recover Trace, survive/prepare through the Boss warning, then enter the Boss encounter.
- **Meaningful choice:** preserve position and build readiness through escalating pressure; Trace recovery is Run progression, not a direct free-power reward.
- **Required information:** Elite state, Trace availability/recovery, Boss warning, and clear separation from ordinary reward-orb feedback.
- **Expected feedback:** chest token/Trace state changes and a readable Boss-gate transition without conflating Trace with ORB/STYLE/GOLD.
- **Target emotion:** “I unlocked the right to face this test; now I must be ready.”
- **Next scene:** Boss action → Result/Workbench on clear; `failure_retry` on defeat.
- **Current evidence:** T10/T14 lifecycle-domain and machine-slice contracts; the revised planning board now gives this transition its own panel, but human readability remains unverified.
- **Undecided:** final icon/telegraph language and exact screen treatment.

## `failure_retry`

- **Actual consumer:** `GameOverPanel`.
- **Player goal:** recognize a learnable failure and immediately find the retry path.
- **Primary action:** read the defeated state and select retry.
- **Meaningful choice:** no new meta choice is implied; the learning is returned to the next combat/route/build attempt.
- **Required information:** one obvious retry affordance and a concise visual recall of the relevant threat/icon language.
- **Expected feedback:** failure state separates from Result/reward, then restarts without suggesting unearned progress.
- **Target emotion:** brief setback, clear renewed intent.
- **Next scene:** a new run’s school selection or defined retry start, according to actual game-state rules.
- **Current evidence:** `GameOverPanel`, P0 v2 Game Over reference.
- **Undecided:** exact retry destination, loss summary, and whether the board’s portal motif supports rather than confuses failure reading.

## Board review findings

- The revised board uses the selected A order: school selection, Cheonsul action, Trace → Boss, Result/Workbench. The only retained visual solution from the earlier board is the requested status-icon grammar.
- It is not a composition lock: Trace must still be visually distinguishable from ordinary reward feedback, the Workbench grid must still be checked against the actual 6×6 contract, and failure/retry remains a separate consumer contract rather than a board panel.
- The board must never be counted as four shipped assets or as Godot/Human/Player validation.
