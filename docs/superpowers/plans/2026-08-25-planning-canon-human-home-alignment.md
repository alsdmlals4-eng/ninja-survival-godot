# Planning Canon & Human Home Alignment Implementation Plan

> **Execution route:** Superpowers brainstorming approval gate → writing-plans → executing-plans → current Base adversarial/validation/PR gates.

**Goal:** Reconcile Ninja Survival front-door planning canon with merged T11 reality and rebuild the Notion Human Home as a self-contained player-facing game-flow/learning surface without mixing AI/System operations into it.

**Architecture:** Keep `main` code/runtime as implementation authority; update only active repository routers/front doors that materially misroute new work; keep closed PR #43/#44 read-only; project human-readable game meaning into the existing Human Home while exact implementation receipts remain in System/Production surfaces.

**Baseline:** completed `main` `265bab32da087c070ea2ea0d98a3bdace1e10f7f` (`T11: add tradition access reward lanes`).

**Spec owners:** `docs/canon/2026-08-21-dec014-025-product-canon.md`, `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`, `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`, and the user-approved 2026-08-25 alignment design.

## Global Constraints

- T01~T11 are merged-domain/automated-evidence facts only; do not promote them to playable Workbench, Human Usability, Player Experience, device, Android/export, or release readiness.
- Closed PR #43 and #44 remain historical/WIP read-only evidence; no reopen/merge/rebase/takeover.
- T12 gameplay/code implementation is out of scope.
- Human Home is self-contained game-flow/system/learning projection; raw SHA, PR/CI history, local Godot path/ports, internal routing and detailed Txx evidence remain System/Production drilldown.
- Existing Flow/System/World/Production pages remain detailed owners; do not create duplicate canon.
- Approved current visual style is the first user-supplied 2026-08-25 image. Record the style decision without further image generation.
- Do not claim durable Notion visual attachment without actual upload + attach + readback.
- Zero incremental paid cost.

## Task 1 — Repository front doors → T11

- [x] Re-read active front doors from exact T11 baseline.
- [x] Inspected closed PR #44 read-only and reused only still-valid T11 reconciliation material on a fresh branch.
- [x] Changed current resume routing to `T11 merged / T12 NOT_MERGED / fresh package next`.
- [x] Preserved T01~T11 domain boundaries and Human/Player/device evidence ceilings.
- [x] Restored bounded first-slice non-goals after review found scope guards weakened.
- [x] Removed ambiguous README wording that could read as `T06 current` rather than T06's historical responsibility.
- [x] Made `ACTIVE_CONTEXT` post-merge durable by removing transient “current docs branch” routing.

Changed front doors:

- `AGENTS.md`
- `README.md`
- `PROJECT_BRIEF.md`
- `MVP_ROADMAP.md`
- `docs/ACTIVE_CONTEXT.md`
- `docs/CURRENT_CONFIRMED_DECISIONS.md`

## Task 2 — Notion Human Home projection

- [x] Rebuilt `닌자 서바이벌 · Home` as a self-contained human-facing learning surface.
- [x] Put full Run Flow and five-minute battlefield cadence directly on Home.
- [x] Put four-school philosophy and 6x6/4x3/rotation/adjacency/buffer/combination core data directly on Home.
- [x] Put Workbench/Fate/route and world/`닌자의 신` meaning directly on Home.
- [x] Kept implementation status compact and raw evidence in Production/System.
- [x] Preserved six L2 Domain child pages during replace/readback.
- [x] Verified Home contains no raw T11 SHA, Godot Port, or PR-number log in the main reading surface.

## Task 3 — Approved visual style, no new generation

- [x] Recorded the first user-supplied image as the current master style reference in Visual Bible.
- [x] Recorded dark moonlit ninja fantasy / painterly anime / ink-brush-calligraphy / black-navy-red-gold language and school accents.
- [x] Recorded dense parchment infographic as supporting explanatory style, not master gameplay art style.
- [x] Generated no further image after the user's stop instruction.
- [x] Kept chat-image binary attachment as `BLOCKED_TOOL_SURFACE`; no false Notion upload claim.

## Task 4 — Planning/System/Production reactivation sync

- [x] Prepended current reactivation state to `01 · 프로젝트 전체 작업계획` while preserving pause history.
- [x] Kept PR #43/#44 as closed-unmerged historical WIP.
- [x] Set next product gate to a fresh T12 package from then-current completed main.
- [x] Updated Project Registry to `ACTIVE`, pre-merge `REPO_UPDATE_REQUIRED`, `Godot Binding State=DEFERRED`, `Godot Runtime State=NOT_RUN`.
- [x] Cleared retired per-project dedicated Godot executable/slot/ports from active binding metadata without inventing a replacement local session.
- [x] Prepended reactivation state to Production Handoff.
- [x] Added current benchmark synthesis to Ninja Reference/Benchmark.
- [x] Read back Human Home, Visual Bible, Planning, Production, Registry and Benchmark destinations.

## Task 5 — Review / PR / merge / post-merge

- [x] Candidate vs exact T11 main: repository delta is docs-only; no code/data/scene/test/workflow changes.
- [x] **Loop 1:** authority/state — Project Brief non-goal regression found and fixed.
- [x] **Loop 2:** Human/System split — no blocking finding.
- [x] **Loop 3:** market/identity — ambiguous README T06 wording found and fixed.
- [x] **Loop 4:** IRG/tool/evidence ceiling — no blocking finding.
- [x] **Loop 5:** long-term/completion — execution-plan state drift found and fixed.
- [x] **Loop 6:** whole-state re-attack — transient branch routing in `ACTIVE_CONTEXT` found and made post-merge durable.
- [ ] **Loop 7:** final whole-state clean re-attack after all corrections.
- [ ] Create one current-task PR from `docs/planning-home-alignment-20260825`.
- [ ] Verify exact PR head, current `main`, mergeability, checks/reviews/threads/rules.
- [ ] Merge without force/direct-main/admin/ruleset bypass if gates permit.
- [ ] Read back new `main` and changed repository front doors.
- [ ] Update Notion Registry/Planning/Production to merged identity and `SYNCED`.
- [ ] Re-fetch Human Home/Visual/Production/Registry and recalculate remaining work.
- [ ] Final post-merge adversarial/progress readback and completion report.

## Current Evidence Ceiling Before PR

```yaml
repository_baseline_main: 265bab32da087c070ea2ea0d98a3bdace1e10f7f
candidate_branch: docs/planning-home-alignment-20260825
repository_change_class: DOCS_ONLY
runtime_code_changed: false
notion_human_home_readback: PASS
notion_visual_bible_readback: PASS
notion_planning_readback: PASS
notion_production_readback: PASS
notion_registry_readback: PASS
notion_benchmark_readback: PASS
approved_visual_style_recorded: PASS
approved_visual_binary_attached_to_notion: BLOCKED_TOOL_SURFACE
local_godot_editor_session: NOT_RUN_NOT_REQUIRED_FOR_DOCS_ALIGNMENT
human_usability: NOT_RUN
player_experience: NOT_RUN
device_android_export: NOT_RUN
```
