# Ninja Survival Consumer-Linked Screen Blueprint Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Produce one editable, consumer-linked Ninja Survival Blueprint with flow maps, six screen wireframes, HUD visibility rules, visual-input classification, and evidence-correct documentation routing.

**Architecture:** `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` is the single new Blueprint owner for screen composition and player-flow explanation. It links product canon, existing visual handoff, locked references, manifests, and actual Godot consumers without taking over their rule, provenance, or implementation authority. The package is documentation-only; it reuses the existing user-locked battle reference and creates no new image binary.

**Tech Stack:** Markdown, Mermaid code blocks, fixed-width text wireframes, Git, existing repository document routing.

**Spec:** `docs/superpowers/specs/2026-09-01-blueprint-wireframe-flow-design.md`

## Global Constraints

- Start from isolated branch `codex/blueprint-wireframe-flow-137` at main baseline `afbba903d5fcf32b8ecc8082c59baecb01e895c5`; never modify `main` or an unrelated/open PR.
- Product/canon authority remains `AGENTS.md`, current decisions, dated canon, and actual Godot code/scenes/data/tests; this Blueprint only owns editable flow and screen-composition linkage.
- Preserve fixed one-ninja identity, automatic Japanese sword/shuriken/one-ninjutsu combat, invulnerable Dash, top-only normal HUD, continuous floor/sparse props, and no bottom skill tray.
- DEC-037 owns the public exact 3x3 start and 6x6 technical outer board; legacy 4x3 runtime is documented as deferred migration, not changed by this documentation package.
- Dynamic menus, cards, tabs, counters, and Korean runtime copy are `GODOT_UI`/`TEXT_LAYER`, not new bitmap assets.
- Reuse `SCRREF-BATTLE-AUTOCOMBAT-03`; do not generate a duplicate battle/HUD image. A future image requires an actual missing consumer, brief, one candidate, and user `LOCK`.
- No task claims runtime render, player experience, device/export, Human usability, or release evidence from document/static checks.
- Preserve uncertain assets and all unrelated worktrees/PRs. Only clean this package's own clean temporary worktrees after post-merge readback.

---

### Task 1: Create the Blueprint foundation and player-flow maps

**Files:**
- Create: `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Test: document static-path and required-section checks

**Interfaces:**
- Consumes: `docs/superpowers/specs/2026-09-01-blueprint-wireframe-flow-design.md`, `docs/canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md`, `docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md`, `docs/CURRENT_VISUAL_HANDOFF.md`, and actual `Main`, `HUD`, `RestFlowUI`, `SchoolSelectionUI` consumer names.
- Produces: `NS-BLUEPRINT-001`, an additive visual/UX Blueprint referenced by the documentation map and usable by later screen, asset, and implementation work.

- [x] **Step 1: Write the Blueprint metadata, authority boundary, and read order**

Create `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` with the identifier `NS-BLUEPRINT-001`, `status: CURRENT_BLUEPRINT_PREPRODUCTION`, the exact baseline SHA, links to the product/visual/asset/implementation owners, and an explicit statement that it is not game-rule canon, an asset manifest, or runtime evidence.

- [x] **Step 2: Add the full player-journey Mermaid map**

Add an editable Mermaid `flowchart TD` that covers the title routes, starting Stage selection, Core crowd pressure, Elite clear, Trace recovery, Boss warning/encounter, result/reward, Workbench placement, provisional next Stage, Fate commit, and both failure/limited checkpoint-retry paths. Mark `Continue` as a validated checkpoint continuation and never a mid-combat replay.

- [x] **Step 3: Add the battle-state Mermaid map**

Add a second editable Mermaid flow using `CorePressure`, `EliteActive`, `TraceAvailable`, `TraceRecovered`, `BossWarning`, `BossActive`, `Result`, and `GameOver` states. Label the evidence boundary so state names describe intended/owned gameplay lifecycle rather than new implementation proof.

- [x] **Step 4: Route readers to the new Blueprint**

In `docs/DOCUMENTATION_MAP.md`, add exactly one authority-map row that describes the Blueprint as the editable player-flow/wireframe/consumer-link surface. Do not change the Human GDD, Master GDD, DEC-037, asset manifest, or screen-coverage owners.

- [x] **Step 5: Run the foundation static check**

Run:

```powershell
git diff --check
rg -n "NS-BLUEPRINT-001|flowchart TD|CURRENT_BLUEPRINT_PREPRODUCTION" docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md docs/DOCUMENTATION_MAP.md
rg -n "3x3|6x6|SCRREF-BATTLE-AUTOCOMBAT-03|not.*runtime" docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md
```

Expected: no whitespace error; exactly one Blueprint file and one documentation-map route identify the new owner; the public backpack and reference boundaries are present.

- [x] **Step 6: Commit the foundation**

```powershell
git add docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md docs/DOCUMENTATION_MAP.md
git commit -m "docs: add screen blueprint flow foundation"
```

### Task 2: Add six screen wireframes and the top-only HUD contract

**Files:**
- Modify: `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`
- Test: required-screen, prohibited-element, and consumer-name checks

**Interfaces:**
- Consumes: `NS-BLUEPRINT-001` foundation from Task 1; actual names `Main/SchoolSelectionUI`, `Main/HUD`, `RestFlowUI/ResultView`, and `RestFlowUI/WorkbenchView`.
- Produces: six fixed-width wireframes and an event-visibility matrix that downstream Godot work can map to Controls without using a bitmap UI.

- [x] **Step 1: Add `BP-TITLE-01` and `BP-SCHOOL-SELECT-01` wireframes**

Use fixed-width text boxes to define the 16:9 title safe area (wordmark, separate four-piece medal, ordered actions, local modal layer) and starting Stage selection (four danger-philosophy cards/symbols, visited state, help, focus). Label the title consumer as planned/release-surface and PR #135 as read-only reference, never current-main implementation evidence.

- [x] **Step 2: Add `BP-BATTLE-HUD-01` and `BP-TRACE-GATE-01` wireframes**

Show a continuous battlefield center with a small grounded ninja and crowded pursuing corrupted ninja/yokai. Show only life, Dash charges, elapsed time, and pause/settings in the normal upper HUD. Add annotated transient overlays for Elite clear, Trace available/recovered, Boss warning, boss life, and active telegraph. State explicitly: no lower skill tray, no routine enemy HP bars, no generic early projectile/field spam.

- [x] **Step 3: Add `BP-RESULT-01` and `BP-WORKBENCH-01` wireframes**

Show result source/reward hierarchy and the Workbench sequence reward → 3x3 usable starting area/6x6 technical board → six REST slots → rotation/adjacency/combination preview → provisional next Stage → Fate commit. Label the commit as an existing protected all-or-none boundary; do not depict it as a UI-owned transaction.

- [x] **Step 4: Add per-screen interaction and input table**

For all six screens, state player question, primary action, keyboard/controller focus route, pointer/touch equivalent, feedback state, and actual/planned Godot consumer. Keep dynamic labels and counters text-native. Mark touch/gamepad visual evidence as `NOT_RUN` where no actual observation exists.

- [x] **Step 5: Add the HUD visibility matrix**

Create a Core opening / crowd pressure / Elite-Trace / Boss table with persistent, event-only, and forbidden information. The table must preserve the user's no-bottom-skill, no-early-spam, Dash-as-invulnerable-evasion, and hit-only target-HP decisions.

- [x] **Step 6: Run the wireframe static check**

Run:

```powershell
rg -n "BP-TITLE-01|BP-SCHOOL-SELECT-01|BP-BATTLE-HUD-01|BP-TRACE-GATE-01|BP-RESULT-01|BP-WORKBENCH-01" docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md
rg -n "bottom skill|no.*bottom|Dash|Trace|Fate|GODOT_UI|TEXT_LAYER|NOT_RUN" docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md
git diff --check
```

Expected: all six identifiers, the protected HUD rules, and input/evidence boundaries are visible; no whitespace error.

- [x] **Step 7: Commit the wireframes**

```powershell
git add docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md
git commit -m "docs: add Ninja Survival screen wireframes"
```

### Task 3: Add consumer/asset matrix, benchmark disposition, and visual cross-links

**Files:**
- Modify: `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`
- Modify: `docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md`
- Modify: `docs/CURRENT_VISUAL_HANDOFF.md`
- Test: consumer-mode, locked-reference, and no-duplicate-generation checks

**Interfaces:**
- Consumes: Task 1 flow, Task 2 wireframes, `SCRREF-BATTLE-AUTOCOMBAT-03`, existing runtime visual manifests, and the benchmark disposition defined in the approved specification.
- Produces: a cross-linked screen/asset/UI/VFX map that makes asset need versus existing source unambiguous without changing any image binary or provenance record.

- [x] **Step 1: Add the screen-to-consumer matrix**

For each Blueprint screen, list the consumer name, consumer mode (`GODOT_UI`, `TEXT_LAYER`, `EXISTING_APPROVED_RASTER`, `PLANNING_REFERENCE`, `RUNTIME_VFX`, or `PLANNED_CONSUMER`), existing source, missing state if any, and the exact evidence ceiling. Keep title marked planned while its open PR remains read-only.

- [x] **Step 2: Add the visual-input ledger and no-duplicate decision**

Classify current floor/props/contact shadows, player/enemy/Boss sprites, existing wordmark/medal title lineage, Controls/text, and runtime telegraphs. Add an explicit reuse row for `SCRREF-BATTLE-AUTOCOMBAT-03` and state that no duplicate `SCRREF-BATTLE-HORDE-HUD-01` is produced. A future new image needs a demonstrated actual consumer gap, short brief, one candidate, and user lock.

- [x] **Step 3: Add the benchmark decision table**

Record the twelve inspected games as source patterns with the selected `ADOPT`, `ADAPT`, `REJECT`, or `REFERENCE_ONLY` disposition. Capture only reusable pattern-level findings: automatic combat/movement focus, horde pressure, route/build decision depth, boss telegraph, dynamic UI separation, and early-hazard restraint. Do not copy any game’s names, content, trade dress, item taxonomy, or tuning.

- [x] **Step 4: Cross-link from the existing visual owners**

Add one concise continuation/reference entry in `docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md` and one safe-resume entry in `docs/CURRENT_VISUAL_HANDOFF.md`. Both entries must point to `NS-BLUEPRINT-001`, preserve their existing ownership, state that the Blueprint is documentation/preproduction only, and state that no new image binary was generated by this package.

- [x] **Step 5: Run the visual-routing static check**

Run:

```powershell
rg -n "NS-BLUEPRINT-001|SCRREF-BATTLE-AUTOCOMBAT-03|no duplicate|GENERATED_CANDIDATE|LOCK" docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md docs/CURRENT_VISUAL_HANDOFF.md
rg -n "GODOT_UI|TEXT_LAYER|EXISTING_APPROVED_RASTER|RUNTIME_VFX|PLANNED_CONSUMER" docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md
git diff --check
```

Expected: the locked source is reused, dynamic UI is not turned into bitmap work, and all three owners agree on documentation-only status.

- [x] **Step 6: Commit the consumer and visual routing**

```powershell
git add docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md docs/CURRENT_VISUAL_HANDOFF.md
git commit -m "docs: map blueprint consumers and visual inputs"
```

### Task 4: Validate the whole Blueprint package and record adversarial review

**Files:**
- Create: `docs/reviews/2026-09-01-screen-blueprint-adversarial-review.md`
- Modify: `docs/ACTIVE_CONTEXT.md`
- Modify: `docs/superpowers/plans/2026-09-01-blueprint-wireframe-flow.md`
- Test: static package checks and five validated whole-scope review loops

**Interfaces:**
- Consumes: Tasks 1–3 and the approved specification.
- Produces: evidence-correct preproduction review lineage, a current resume pointer, completed plan checkboxes, and a package ready for PR review without asserting runtime or user acceptance.

- [x] **Step 1: Perform five whole-scope adversarial loops**

Write `docs/reviews/2026-09-01-screen-blueprint-adversarial-review.md` with five rows. Attack, validate, and record at minimum: duplicate-owner/document drift; user-direction regression (3x3, Stage/Phase, one ninja, auto attacks); fake image/runtime promotion; HUD clutter/early-hazard regression; and incorrect PR/current-main or evidence claims. Each row needs evidence inspected, correction made or reason no correction was needed, and result.

- [x] **Step 2: Update the mutable resume router**

Add a compact current-task entry to `docs/ACTIVE_CONTEXT.md` that records `NS-BLUEPRINT-001` as documentation/preproduction complete pending exact PR-head checks, notes that no new image was generated, identifies `SCRREF-BATTLE-AUTOCOMBAT-03` as reused, and preserves `NOT_RUN` for runtime/Human/device evidence.

- [x] **Step 3: Mark the completed plan steps**

Change every completed checkbox in this plan from `- [ ]` to `- [x]`. Do not mark an image-generation/lock task because this plan deliberately has no new image generation task.

- [x] **Step 4: Run the final static verification**

Run:

```powershell
git diff --check
rg -n "NS-BLUEPRINT-001|CURRENT_BLUEPRINT_PREPRODUCTION|SCRREF-BATTLE-AUTOCOMBAT-03|NOT_RUN" docs/ACTIVE_CONTEXT.md docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md docs/CURRENT_VISUAL_HANDOFF.md docs/reviews/2026-09-01-screen-blueprint-adversarial-review.md
rg -n -- "- \[ \]" docs/superpowers/plans/2026-09-01-blueprint-wireframe-flow.md
git status --short
```

Expected: no whitespace error; all required owner/evidence statements exist; Task 1–4 checkboxes are checked while Task 5 remains pending its protected PR route; only the scoped documentation paths have changes since the last task commit.

- [x] **Step 5: Commit and synchronize the complete Blueprint package**

```powershell
git add docs/ACTIVE_CONTEXT.md docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md docs/CURRENT_VISUAL_HANDOFF.md docs/reviews/2026-09-01-screen-blueprint-adversarial-review.md docs/superpowers/plans/2026-09-01-blueprint-wireframe-flow.md
git commit -m "docs: complete consumer-linked screen blueprint"
git push
```

### Task 5: Prepare exact-head review and protected integration route

**Files:**
- Modify: no repository file unless a validation finding requires a scoped correction
- Test: exact-head GitHub PR/CI readback, then fresh `main` reconciliation only after authorized merge

**Interfaces:**
- Consumes: final commit from Task 4 and protected repository rules.
- Produces: a proposed PR whose exact head can be independently checked; no direct-main push, force push, ruleset bypass, or unrelated PR mutation.

- [ ] **Step 1: Inspect final diff and current remote divergence**

Run:

```powershell
git fetch origin --prune
git diff --check origin/main...HEAD
git log --oneline origin/main..HEAD
git status --short
```

Expected: only scoped Blueprint/documentation commits are ahead, the branch is clean, and no whitespace error exists.

- [ ] **Step 2: Create a protected pull request**

Create one PR from `codex/blueprint-wireframe-flow-137` to current `main`. Its body must identify the exact baseline, documentation-only scope, reused locked reference, no new image binary, evidence ceiling, and `NOT_RUN` runtime/Human/device limits. Do not merge it in this task unless the user separately authorizes the merge action.

- [ ] **Step 3: Check CI at the exact head**

After the PR is created, read its `headRefOid`, inspect all checks for that exact OID, and distinguish a successful document/static check from runtime/Human validation. If a check reports a validated documentation issue, return to the affected task and correct only that finding.

- [ ] **Step 4: Report the integration gate**

Report the PR URL, exact head SHA, checks actually observed, remaining `NOT_RUN` evidence, and the next safe image action: only a verified visual-consumer gap can trigger one candidate and user `LOCK`.
