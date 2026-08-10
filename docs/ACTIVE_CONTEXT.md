# ACTIVE_CONTEXT

> 현재 세션/브랜치에서 다음 작업자가 질문 없이 재개하기 위한 압축 라우터다.
> 제품 결정 전문은 `docs/CURRENT_CONFIRMED_DECISIONS.md`를 본다.
> 과거 대화보다 현재 GitHub/프로젝트/현재 정본을 우선한다.

Last updated: 2026-08-10 12:48 KST

## Baseline

```yaml
project: alsdmlals4-eng/ninja-survival-godot
main_sha: 9b85cf65a3ca4278f7d8ec1a7e527ecc857cbad1
current_handoff_branch: NONE_MERGED_TO_MAIN
handoff_pr: 5
handoff_pr_state: MERGED_CLOSED
handoff_merge_commit: 9b85cf65a3ca4278f7d8ec1a7e527ecc857cbad1
handoff_post_merge_ci: PASS_RUN_31352074021
active_product_pr: NONE
mvp4_implementation_branch: NONE
mvp4_implementation_pr: NONE
base_repo: alsdmlals4-eng/Base
base_main_observed: 3ff790116bc08f49e126cd286ec453bf6e46376e
base_bcp_013: SUBMITTED_ON_MAIN
project_base_rules_file_points_to: 499c20eb9b449241864f5ada0c915fba8a7806ac
```

## Current stage

`MVP-4 Backpack / Combination Basics — design in progress`

Implementation status: `NOT_STARTED`

The previous integrated runtime milestone is MVP-3. Project `main@9b85cf65...` also contains the merged MVP-4 design/handoff checkpoint from PR #5; no MVP-4 production code is claimed by that documentation merge.

## Progress classification

### COMPLETED_VERIFIED

- MVP-0 basic combat foundation integrated.
- MVP-1 combat DDD integrated.
- MVP-2 four shallow schools integrated.
- MVP-3 stage result/rest/shop/fate integrated.
- MVP-4 design Sections 1–5 have been discussed and approved at the product-rule level; consolidated approved decisions are in `docs/CURRENT_CONFIRMED_DECISIONS.md`.
- MVP-4 handoff/continuation documentation was squash-merged through PR #5 to `main@9b85cf65a3ca4278f7d8ec1a7e527ecc857cbad1`.
- The post-merge `main` GUT workflow run `31352074021` completed successfully.
- `AGENTS.md`, `MVP_ROADMAP.md`, and `docs/DOCUMENTATION_MAP.md` on main now include the approved MVP-4 rotation/shape/timing synchronization from PR #5.

### IN_PROGRESS

- MVP-4 design is not yet closed.
- Remaining design work starts with **Section 6: Rest Workbench UI / input / visual feedback / combination-hint presentation**, followed by error handling, test matrix, human QA, and final completion gate.

### READY_NEXT

1. Re-read `AGENTS.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, this file, and `docs/handoffs/2026-08-10-mvp4-backpack-design-handoff.md` from current main.
2. Re-query latest main/open PRs before resuming; do not assume the saved SHA is still current.
3. Before the next material design question, perform fresh backpack-genre / industry benchmarking as requested by the user.
4. Continue brainstorming with one material question/design section at a time.
5. Finish the remaining design sections.
6. Present the complete MVP-4 design for final approval.
7. Only after final design approval, write the canonical MVP-4 design spec under `docs/superpowers/specs/` using the current Base L2 Game Feature Design Spec hierarchy as a reference where useful.
8. Self-review the written spec for placeholder/contradiction/scope/ambiguity issues.
9. Ask the user to review the written spec.
10. Only after written-spec approval, transition to `writing-plans` and create the implementation plan.

### BLOCKED / USER_DECISION_REQUIRED

- No current handoff-integration blocker remains; PR #5 is merged.
- No user decision is required to continue the next design section.

A new product decision is required only if the next work changes already-approved core rules or expands scope materially. Any future PR merge still requires explicit project integration approval.

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

### Project documentation synchronization

PR #5 is merged. Current `main@9b85cf65...` contains the synchronized `AGENTS.md`, `MVP_ROADMAP.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, handoff snapshot, and documentation map. The older rotation exclusion and older `5/10/15-minute midboss` wording are no longer the current main guidance.

The current decision source is `docs/CURRENT_CONFIRMED_DECISIONS.md` on main. The dated handoff remains a historical snapshot; this `ACTIVE_CONTEXT.md` is the mutable continuation-state router.

### Base drift

`docs/BASE_RULES_VERSION.md` still records Base commit `499c20e...` from 2026-07-10, while current Base `main` observed during this reconciliation is `3ff790116bc08f49e126cd286ec453bf6e46376e`.

Relevant newer Base capabilities already exist:

- continuous-work execution/recovery contracts;
- `maintaining-project-context-and-handoff` owner;
- L2 `GAME_FEATURE_DESIGN_SPEC` hierarchy implemented by BCP-2026-011.

From this project handoff, Base BCP-2026-013 `Post-Merge Continuation-State Reconciliation` was submitted and merged to Base main as a proposal. Its status remains `SUBMITTED`; it has not changed active Base behavior yet.

This handoff uses the existing Base patterns by REUSE, but **full Base rule synchronization is NOT_RUN** and should not be falsely claimed.

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
handoff_document_creation: INTEGRATED_ON_MAIN
handoff_pr_created: PASS
handoff_pr_merged: PASS
handoff_merge_commit: 9b85cf65a3ca4278f7d8ec1a7e527ecc857cbad1
handoff_post_merge_ci: PASS_RUN_31352074021
base_bcp_013_submission: MERGED_TO_BASE_MAIN_3ff790116bc08f49e126cd286ec453bf6e46376e
base_bcp_013_status: SUBMITTED
base_post_merge_ci: PASS_RUN_31352996749
mvp4_code_tests: NOT_RUN
mvp4_godot_runtime: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_exact_head_ci: NOT_RUN
mvp4_written_design_spec: NOT_WRITTEN
mvp4_implementation_plan: NOT_WRITTEN
```

Do not report any MVP-4 implementation or runtime verification as PASS.

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
  - BCP-2026-013 post-merge continuation-state reconciliation: SUBMITTED
REUSE:
  - maintaining-project-context-and-handoff
  - current Base feature-design-spec hierarchy for the eventual written spec
NO_PROMOTION:
  - backpack product rules are project-specific
```

No additional Base `[수정제안서]` is identified from this checkpoint beyond BCP-2026-013.

## Protected scope

- Do not implement MVP-4 before final design approval + written spec review.
- Do not silently revert the approved rotation / non-rectangular bag / one-cell special-bag overlap decisions.
- Do not commit local `addons/` or local plugin activation in `project.godot`.
- Do not use `git add .`, `git add -A`, or destructive clean operations in local execution.
- Do not merge an MVP-4 or handoff/state PR without the project's required explicit integration approval.

## Resume read order

1. current GitHub `main` + open PR list
2. `AGENTS.md` from current main
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. `docs/ACTIVE_CONTEXT.md`
5. `docs/handoffs/2026-08-10-mvp4-backpack-design-handoff.md`
6. `MVP_ROADMAP.md`
7. `docs/superpowers/specs/2026-08-10-mvp3-stage-result-rest-design.md`
8. current MVP-3 code surfaces listed above
9. current planning Google Sheet tabs if available: MVP범위 / 백팩 / 인법과조합 / 휴식구간흐름 / 결과화면구조 / 상태와태그

## Next executable step

**Continue MVP-4 design, not implementation.**

Start with a fresh benchmark of rest-workbench inventory UX, then present/resolve **Section 6 — Rest Workbench UI, inputs, preview feedback, and recipe-hint presentation**. After that close error handling/test/completion criteria and request final design approval.
