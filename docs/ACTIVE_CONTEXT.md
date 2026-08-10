# ACTIVE_CONTEXT

> 현재 세션/브랜치에서 다음 작업자가 질문 없이 재개하기 위한 압축 라우터다.
> 제품 결정 전문은 `docs/CURRENT_CONFIRMED_DECISIONS.md`를 본다.
> 과거 대화보다 현재 GitHub/프로젝트/현재 정본을 우선한다.

Last updated: 2026-08-10 11:53 KST

## Baseline

```yaml
project: alsdmlals4-eng/ninja-survival-godot
main_sha: 7ef8eeaec1e5e4bad65a7bf00061274b60641e6a
current_handoff_branch: docs/mvp4-handoff-20260810
active_product_pr: NONE
mvp4_implementation_branch: NONE
mvp4_implementation_pr: NONE
base_repo: alsdmlals4-eng/Base
base_main_observed: 637dad32c773c56a27d44d847518580848dee493
project_base_rules_file_points_to: 499c20eb9b449241864f5ada0c915fba8a7806ac
```

## Current stage

`MVP-4 Backpack / Combination Basics — design in progress`

Implementation status: `NOT_STARTED`

The previous integrated milestone is MVP-3. Project `main@7ef8ee...` contains the stage result/rest/shop/fate loop that MVP-4 will extend.

## Progress classification

### COMPLETED_VERIFIED

- MVP-0 basic combat foundation integrated.
- MVP-1 combat DDD integrated.
- MVP-2 four shallow schools integrated.
- MVP-3 stage result/rest/shop/fate integrated on `main@7ef8ee...`.
- MVP-4 design Sections 1–5 have been discussed and approved at the product-rule level; consolidated approved decisions are in `docs/CURRENT_CONFIRMED_DECISIONS.md`.

### IN_PROGRESS

- MVP-4 design is not yet closed.
- Remaining design work starts with **Section 6: Rest Workbench UI / input / visual feedback / combination-hint presentation**, followed by error handling, test matrix, human QA, and final completion gate.

### READY_NEXT

1. Re-read `AGENTS.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, this file, and the handoff snapshot.
2. Before the next material design question, perform fresh backpack-genre / industry benchmarking as requested by the user.
3. Continue brainstorming with one material question/design section at a time.
4. Finish the remaining design sections.
5. Present the complete MVP-4 design for final approval.
6. Only after final design approval, write the canonical MVP-4 design spec under `docs/superpowers/specs/` using the current Base L2 Game Feature Design Spec hierarchy as a reference where useful.
7. Self-review the written spec for placeholder/contradiction/scope/ambiguity issues.
8. Ask the user to review the written spec.
9. Only after written-spec approval, transition to `writing-plans` and create the implementation plan.

### BLOCKED / USER_DECISION_REQUIRED

None for the next design step.

A new user decision is required only if the next work changes already-approved core rules or expands scope materially.

### NOT_STARTED

- MVP-4 production code.
- BackpackState / BackpackResolver / RestBackpackSession implementation.
- Item/Bag instance model.
- Elite-at-3-min runtime implementation.
- Boss reward / chest runtime implementation.
- REST workbench UI implementation.
- MVP-4 tests / runtime QA.
- implementation PR and merge.

## Critical approved decisions to preserve

See `docs/CURRENT_CONFIRMED_DECISIONS.md`. The most regression-sensitive decisions are:

- fixed `6x6` total board, starting `4x3` usable area;
- buy/place bags to expand usable cells;
- keyboard whole-layout translation;
- **both bags and items rotate 90 degrees**;
- regular items remain rectangular for MVP-4, while some bags may be L/T-shaped;
- special bag effect applies when an item overlaps even **one cell**;
- item adjacency is orthogonal only, pair effect once;
- 6-slot temporary storage doubles as a rest-only work buffer and must be empty before combat;
- acquisition pillars are **boss + shop + chest**;
- around the 3-minute mark: one elite/midboss appears; killing it grants one chest token;
- around the 5-minute mark: segment boss appears;
- boss reward is 3 choose 1, shop is 3 item + 1 bag, chest gives 2 random items;
- combination requires real backpack placement + orthogonal adjacency, explicit combine action, preview placement, then atomic consume on success;
- architecture direction is `BackpackState + BackpackResolver + RunBuildState integration`;
- Fate is the final rest commit boundary.

## Repository truth and known drift

### Project docs that are stale relative to current approvals

`AGENTS.md` and `MVP_ROADMAP.md` still contain older exclusions such as item rotation / complex backpack shapes being excluded, and older `5/10/15-minute midboss` terminology.

Do **not** interpret those older lines as overturning the newer approved MVP-4 decisions. They need a synchronization pass before implementation planning.

### Base drift

`docs/BASE_RULES_VERSION.md` still records Base commit `499c20e...` from 2026-07-10, while current Base `main` observed during this handoff is `637dad3...`.

Relevant newer Base capabilities already exist:

- continuous-work execution/recovery contracts;
- `maintaining-project-context-and-handoff` owner;
- L2 `GAME_FEATURE_DESIGN_SPEC` hierarchy implemented by BCP-2026-011.

This handoff uses those patterns by REUSE, but **full Base rule synchronization is NOT_RUN** and should not be falsely claimed.

## Existing implementation surfaces to inspect before coding

Current MVP-3 files that MVP-4 is expected to integrate with:

- `scripts/core/run_build_state.gd`
  - current inventory source is non-spatial `owned_items: Dictionary` with count-based modifiers.
- `scripts/data/item_definition.gd`
  - no spatial footprint/rotation data yet.
- `scripts/data/mvp3_catalog.gd`
  - existing 8 reusable item definitions and fates.
- `scripts/core/shop_controller.gd`
  - currently buying directly calls RunBuildState and activates ownership immediately.
- `scripts/core/stage_flow_controller.gd`
  - current phases are RESULT → SHOP → FATE → PREVIEW; MVP-4 design changes this to RESULT → BOSS_REWARD → REST workbench → FATE.
- `scripts/ui/rest_flow_ui.gd`
  - current UI swaps separate Result/Shop/Fate/Preview views and must not become the authority for grid rules.
- `scripts/core/main_controller.gd`
  - current orchestrator immediately syncs modifiers after shop actions; MVP-4 design moves rest editing to preview-only calculations until commit.

## Verification state

```yaml
handoff_document_creation: IN_PROGRESS_ON_DOC_BRANCH
mvp4_code_tests: NOT_RUN
mvp4_godot_runtime: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_exact_head_ci: NOT_RUN
mvp4_written_design_spec: NOT_WRITTEN
mvp4_implementation_plan: NOT_WRITTEN
```

Do not report any MVP-4 implementation or verification as PASS.

## Benchmarking contract for resume

The user explicitly requested:

> Before questions or work, benchmark other backpack-genre games and current industry practices first.

For each material design choice, record mentally or in the eventual spec:

```text
benchmark fact
→ what Ninja Survival should adopt/adapt
→ what should not be copied
→ limitations / validation need
```

Previously referenced examples include Backpack Battles, Backpack Hero, God of Weapons, and Backpack Brawl. Re-check current sources rather than assuming old notes are current.

## Base / project learning classification

```yaml
PROJECT_ONLY:
  - all MVP-4 backpack geometry, budgets, item pool, reward cadence, combination rules
  - elite around 3 minutes and boss around 5 minutes
BASE_CANDIDATE:
  - none identified that need a new Base proposal
REUSE:
  - maintaining-project-context-and-handoff
  - current Base feature-design-spec hierarchy for the eventual written spec
NO_PROMOTION:
  - backpack product rules are project-specific
```

No Base `[수정제안서]` is required from this checkpoint.

## Protected scope

- Do not implement MVP-4 before final design approval + written spec review.
- Do not silently revert the approved rotation / non-rectangular bag / one-cell special-bag overlap decisions.
- Do not commit local `addons/` or local plugin activation in `project.godot`.
- Do not use `git add .`, `git add -A`, or destructive clean operations in local execution.
- Do not merge an MVP-4 or handoff PR without the project's required explicit integration approval.

## Resume read order

1. `AGENTS.md`
2. `docs/CURRENT_CONFIRMED_DECISIONS.md`
3. `docs/ACTIVE_CONTEXT.md`
4. `docs/handoffs/2026-08-10-mvp4-backpack-design-handoff.md`
5. `MVP_ROADMAP.md` — read with the documented stale-scope warning
6. `docs/superpowers/specs/2026-08-10-mvp3-stage-result-rest-design.md`
7. current MVP-3 code surfaces listed above
8. current planning Google Sheet tabs if available: MVP범위 / 백팩 / 인법과조합 / 휴식구간흐름 / 결과화면구조 / 상태와태그

## Next executable step

**Continue MVP-4 design, not implementation.**

Start with a fresh benchmark of rest-workbench inventory UX, then present/resolve **Section 6 — Rest Workbench UI, inputs, preview feedback, and recipe-hint presentation**. After that close error handling/test/completion criteria and request final design approval.
