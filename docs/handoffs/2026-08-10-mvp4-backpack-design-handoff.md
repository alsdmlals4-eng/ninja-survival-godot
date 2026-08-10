# 2026-08-10 MVP-4 Backpack Design Handoff

> Session boundary snapshot. This file is a resume router, not a second design canon.
> Product decisions live in `docs/CURRENT_CONFIRMED_DECISIONS.md`.
> Current implementation/verification state lives in `docs/ACTIVE_CONTEXT.md`.

## Current state

- Project: `alsdmlals4-eng/ninja-survival-godot`
- Main baseline observed: `7ef8eeaec1e5e4bad65a7bf00061274b60641e6a`
- MVP-3: integrated on main.
- MVP-4: design in progress; implementation has **not** started.
- No MVP-4 implementation branch/PR existed at handoff start.
- Handoff branch: `docs/mvp4-handoff-20260810`

## What this session accomplished

The session continued MVP-4 brainstorming from the live planning sheet and current MVP-3 code, while benchmarking backpack-genre conventions before material design choices.

Approved design areas now include:

- 6x6 total backpack board with 4x3 starting usable space.
- Bag purchases expand usable cells; bags must stay orthogonally connected.
- Whole usable layout can be translated by keyboard arrows.
- Both bags and items rotate in 90-degree increments.
- Regular items are rectangular in MVP-4; some bags may use L/T shapes.
- Larger items receive higher effect budgets but are harder to place.
- Orthogonal item adjacency only; same pair/same rule triggers once.
- Special bag effect activates with even one-cell overlap and can stack across different bag instances.
- Six-slot temporary storage doubles as a rest-only work buffer and must be empty before combat.
- Acquisition structure is `boss + shop + chest`.
- One elite/midboss appears around the 3-minute mark; killing it grants a chest token.
- Segment boss appears around the 5-minute mark.
- Boss reward = 3 choose 1; shop = 3 normal item offers + 1 bag offer; chest = 2 random items.
- Combination requires actual backpack placement and orthogonal adjacency, explicit combine action, preview placement, and atomic consume only on successful result placement.
- Recipe hints use progressive discovery.
- Architecture direction is `BackpackState + BackpackResolver + RunBuildState integration`.
- Rest flow is `RESULT → BOSS_REWARD → REST workbench → FATE → PREVIEW/COMPLETE`.

See `docs/CURRENT_CONFIRMED_DECISIONS.md` for the detailed consolidated rules.

## Important scope evolution

Older project docs still say rotation and complex backpack shapes are excluded and refer to 5/10/15-minute midboss checks.

Those lines are now stale for MVP-4. The latest approved direction is:

- item rotation: **included**;
- bag rotation: **included**;
- selected non-rectangular bag shapes: **included**;
- arbitrary complex item polyomino/deep shape system: still **not required** for MVP-4;
- combat cadence: **elite around 3 minutes, boss around 5 minutes per segment**.

Do not silently restore the older exclusions.

## Where brainstorming stopped

Design Sections 1–5 were approved at the conversation level:

1. architecture/responsibility boundaries;
2. 6x6 board, bags, rotation, connection, whole-layout movement;
3. item/effect-budget/adjacency rules;
4. proposed MVP-4 item/combo/bag pool;
5. boss/chest/shop/rest transaction and data-flow rules.

The next planned section is:

**Section 6 — Rest Workbench UI / input / visual feedback / combination-hint presentation.**

After that, close:

- invalid-state and transaction error handling;
- deterministic RNG/testability boundaries;
- unit/integration test matrix;
- Godot manual QA / player-feel acceptance;
- MVP-4 completion gate;
- complete-design final approval.

Only then write the canonical design spec and ask the user to review it before `writing-plans` / implementation planning.

## First action for the next session

1. Re-read `AGENTS.md`.
2. Read `docs/CURRENT_CONFIRMED_DECISIONS.md`.
3. Read `docs/ACTIVE_CONTEXT.md`.
4. Re-check current GitHub `main` and any newly opened MVP-4 PR/branch.
5. Re-check the current Base main and relevant feature-design/handoff contract if material.
6. Perform a fresh benchmark of backpack-game rest-workbench UX before asking the next design question.
7. Continue Section 6 only; do not implement yet.

## Current code integration hotspots

Before eventual implementation, inspect current main versions of:

- `scripts/core/run_build_state.gd`
- `scripts/data/item_definition.gd`
- `scripts/data/mvp3_catalog.gd`
- `scripts/core/shop_controller.gd`
- `scripts/core/stage_flow_controller.gd`
- `scripts/ui/rest_flow_ui.gd`
- `scripts/core/main_controller.gd`

Key mismatch to solve later: current MVP-3 ownership is non-spatial and purchases immediately affect modifiers, while approved MVP-4 requires instance-based spatial ownership and valid placement before activation.

## Verification / evidence ceiling

```yaml
mvp4_product_decisions: PARTIALLY_APPROVED_DESIGN_IN_PROGRESS
mvp4_written_spec: NOT_WRITTEN
mvp4_implementation: NOT_STARTED
mvp4_tests: NOT_RUN
mvp4_godot_runtime: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_ci: NOT_RUN
```

No MVP-4 implementation PASS claim is valid yet.

## Base / operating-system note

Current project `docs/BASE_RULES_VERSION.md` points to an older Base commit from 2026-07-10. Current Base main observed during this handoff was `637dad32c773c56a27d44d847518580848dee493` and already contains:

- continuous-work execution/recovery;
- project context/handoff responsibility;
- L2 Game Feature Design Spec hierarchy.

This session **reused** those patterns for handoff; it did not perform a full Base sync and did not create a new Base proposal.

## User-specific working rule to preserve

For material MVP-4 questions or work, perform fresh backpack-genre / current-practice benchmarking first, then distinguish:

```text
benchmark fact
→ adapt for Ninja Survival
→ do not copy / limitation
```

## Stop condition

This handoff intentionally stops before UI design completion and before any MVP-4 implementation. The next session can resume from Section 6 without repeating already-approved decisions.
