# ACTIVE_CONTEXT

> 현재 세션/브랜치에서 다음 작업자가 질문 없이 재개하기 위한 압축 라우터다.
> 제품 결정 전문은 `docs/CURRENT_CONFIRMED_DECISIONS.md`를 본다.
> MVP-4 상세 규칙은 `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`를 본다.
> 과거 대화·Handoff보다 현재 GitHub/프로젝트/현재 정본을 우선한다.

Last updated: 2026-08-11 06:13 KST

## Baseline

```yaml
project: alsdmlals4-eng/ninja-survival-godot
main_sha_observed: 9b85cf65a3ca4278f7d8ec1a7e527ecc857cbad1
active_design_branch: docs/mvp4-design-finalization-20260811
active_design_pr: 7
active_design_pr_state: OPEN_DRAFT_WRITTEN_SPEC_REVIEW
prior_handoff_pr_5: MERGED_CLOSED
prior_state_reconciliation_pr_6: CLOSED_SUPERSEDED_BY_7
mvp4_implementation_branch: NONE
mvp4_implementation_pr: NONE
base_repo: alsdmlals4-eng/Base
base_main_observed: 315c66eea9614c284b9c11c4d522141065dfa4b0
project_base_rules_last_explicit_sync: 499c20eb9b449241864f5ada0c915fba8a7806ac
full_base_rule_sync: NOT_RUN
project_sheet_sync: GITHUB_UPDATE_PENDING_SHEET
project_sheet_write: BLOCKED_USER_ACTION_403
```

## Current stage

`MVP-4 Backpack / Combination Basics — DESIGN_COMPLETE_PENDING_WRITTEN_SPEC_REVIEW`

Implementation status: `NOT_STARTED`

The previous integrated runtime milestone remains MVP-3 on project `main@9b85cf65...`. Draft PR #7 contains documentation/design work only; it does not claim MVP-4 runtime implementation.

## Progress classification

### COMPLETED_VERIFIED

- MVP-0 basic combat foundation integrated.
- MVP-1 combat DDD integrated.
- MVP-2 four shallow schools integrated.
- MVP-3 stage result/rest/shop/fate integrated.
- MVP-4 design Sections 1–5 previously approved and recorded.
- `DEC-2026-08-11-001`: integrated Persistent Workbench approach approved by the user.
- Section 6 UI/input/preview/combination-hint direction closed using the approved Persistent Workbench plus in-scope safety defaults.
- Transaction failure, deterministic testability, automated test matrix, human QA scope, and completion criteria are defined.
- `docs/CURRENT_CONFIRMED_DECISIONS.md` updated on Draft PR #7.
- `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` written on Draft PR #7.
- written spec placeholder/contradiction/scope/ambiguity self-review completed with no surviving MUST_FIX finding.
- README / PROJECT_BRIEF / DESIGN_INTENT / SYSTEM_MAP / DOCUMENTATION_MAP / BASE_RULES_VERSION freshness gaps identified and reconciled on Draft PR #7.
- stale PR #6 closed as superseded because PR #7 absorbs its `ACTIVE_CONTEXT` correction and advances the state further.

### IN_PROGRESS

- Draft PR #7 exact-head CI/status/thread/adversarial diff review.
- Superpowers brainstorming `user reviews written spec` gate.

### READY_NEXT

1. Re-query Draft PR #7 exact HEAD, changed files, CI runs, and review threads.
2. Run adversarial diff/freshness review against current main and current Base relevance.
3. Present the written spec to the user for review.
4. Only after written-spec approval: invoke Superpowers `writing-plans` and create `docs/superpowers/plans/2026-08-11-mvp4-backpack-combination-implementation.md`.
5. Still do not implement production code until the project instruction's explicit planning-complete transition condition is satisfied.

### BLOCKED / DEFERRED

#### Google Sheets synchronization

Project GDD Sheets still contain stale older timing/rotation wording in multiple tabs.

A write attempt on 2026-08-11 returned Google Sheets API `403 PERMISSION_DENIED`.

```yaml
classification: LOCAL_TASK_BLOCKER
state: GITHUB_UPDATE_PENDING_SHEET
required_user_action: grant the connected Google account edit permission to the project spreadsheet or reconnect a writer-capable account
independent_work: CONTINUE
```

Do not report Sheets as `SYNCED` until write + reread evidence succeeds.

### NOT_STARTED

- MVP-4 production code.
- BackpackState / BackpackResolver / RestBackpackSession implementation.
- ItemInstance / BagInstance / BagDefinition runtime model.
- elite-at-~3-min runtime implementation.
- boss reward / chest runtime implementation.
- Persistent Workbench UI implementation.
- MVP-4 unit/integration/runtime/human tests.
- MVP-4 implementation plan.
- MVP-4 implementation PR/merge.

## Critical approved decisions to preserve

- fixed `6x6` total board, starting `4x3` usable area;
- buy/place bags to expand usable cells;
- keyboard whole-layout translation;
- both bags and items rotate 90 degrees;
- regular items remain rectangular for MVP-4, while some bags may be L/T-shaped;
- special bag effect applies when an item overlaps even one cell;
- item adjacency is orthogonal only, pair effect once;
- 6-slot temporary storage doubles as a rest-only work buffer and must be empty before combat;
- acquisition pillars are boss + shop + chest;
- around the 3-minute mark: one elite/midboss appears; killing it grants one chest token;
- around the 5-minute mark: segment boss appears;
- boss reward is 3 choose 1, shop is 3 item + 1 bag, chest gives 2 random items;
- combination requires real backpack placement + orthogonal adjacency, explicit combine action, preview placement, then atomic consume on success;
- architecture direction is `BackpackState + BackpackResolver + RestBackpackSession + RunBuildState integration`;
- Fate is the final rest commit boundary;
- `DEC-2026-08-11-001`: REST uses an integrated Persistent Workbench with the backpack board continuously central; Windows uses rail/panel adaptation and Android uses bottom-sheet/short-tab adaptation while preserving identical domain semantics;
- required REST actions have complete mouse, keyboard/gamepad-focus, and touch paths; drag/hover/long-press alone cannot be mandatory;
- valid/invalid/synergy/recipe states do not rely on color alone.

## Current implementation mismatch — expected, not a completed bugfix

Current MVP-3 runtime still has:

- non-spatial `RunBuildState.owned_items` count ownership;
- shop purchase immediately entering owned items and recomputing modifiers;
- `StageFlowController` phases `RESULT → SHOP → FATE → PREVIEW`;
- `RestFlowUI` separate Result/Shop/Fate/Preview views;
- no BackpackState/Resolver/RestBackpackSession;
- no ~3 minute elite/chest token or forced boss reward layer.

These are MVP-4 implementation targets. Do not label them fixed until actual production code and tests exist.

## Benchmarking summary

Fresh research was rechecked on 2026-08-11 before closing Section 6.

- Backpack Battles / Backpack Hero / God of Weapons: use limited inventory placement as build strategy evidence, not as copy targets.
- Godot 4.7 Control/Input: supports explicit focus neighbors and drag/drop/accessibility paths used to shape the input contract.
- Microsoft XAG UI navigation/focus: supports predictable navigation and visible focus principles.
- Android accessibility guidance: supports approximately 48dp interactive touch targets.

Limitations and adaptation decisions are recorded in the written design spec. External benchmark facts do not override project canon.

## Base status

Latest Base main observed in this session: `315c66eea9614c284b9c11c4d522141065dfa4b0`.

The latest commit after the previously observed `7ce3fb64...` operationalizes external source-context scanning/auto-merge but does not alter MVP-4 project authority or the External Process Overlay boundary.

The project has **not** performed a full Base rule synchronization from its older explicit project baseline `499c20e...`. `docs/BASE_RULES_VERSION.md` now separates the last project sync from latest remote observation instead of implying they are the same.

## Verification state

```yaml
mvp4_product_design: COMPLETE_PENDING_WRITTEN_SPEC_REVIEW
mvp4_decision_sync_on_design_branch: PASS
mvp4_written_design_spec: WRITTEN_SELF_REVIEW_PASS
mvp4_user_written_spec_review: PENDING
mvp4_design_pr: OPEN_DRAFT_7
mvp4_design_pr_exact_head_review: IN_PROGRESS
mvp4_implementation_plan: NOT_WRITTEN
mvp4_code: NOT_STARTED
mvp4_gut_tests: NOT_RUN
mvp4_godot_runtime: NOT_RUN
mvp4_human_qa: NOT_RUN
mvp4_android_device_qa: NOT_RUN
sheet_sync: BLOCKED_USER_ACTION_403
```

No MVP-4 runtime PASS claim is valid yet.

## Protected scope

- Do not implement MVP-4 before written-spec review and the project's explicit planning-complete transition.
- Do not silently revert rotation / non-rectangular bag / one-cell special-bag overlap / Persistent Workbench decisions.
- Do not turn UI into the authority for backpack, economy, reward, combination, or Fate rules.
- Do not commit local `addons/` or local plugin activation in `project.godot`.
- Do not use `git add .`, `git add -A`, destructive clean/reset operations in local execution.
- Do not treat blocked Sheet write as a reason to stop independent design/PR validation work.

## Resume read order

1. current GitHub main + open PR list
2. `AGENTS.md`
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. this file
5. `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
6. `MVP_ROADMAP.md`
7. current MVP-3 implementation hotspots
8. project GDD Sheets when writer/read access is available
9. current Base main only for relevant contract drift

## Next executable step

**Adversarially validate Draft PR #7, then stop at the user written-spec review gate. Do not write the implementation plan or production code yet.**