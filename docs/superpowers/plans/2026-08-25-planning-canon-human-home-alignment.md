# Planning Canon & Human Home Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reconcile the Ninja Survival front-door planning canon with merged T11 reality and rebuild the Notion Human Home as a self-contained player-facing game-flow/learning surface without mixing AI/System operations into it.

**Architecture:** Keep `main` code/runtime as the implementation authority and reuse the existing Notion shallow IA. Update only active repository routers/front doors that materially misroute new work, keep closed PR #43/#44 read-only, and project human-readable game meaning into the existing Human Home while leaving exact implementation receipts in System/Production surfaces.

**Tech Stack:** GitHub Markdown, Notion Human Home/System/Production surfaces, Mermaid, existing Base v9.x project operating contracts.

**Spec:** `docs/canon/2026-08-21-dec014-025-product-canon.md` + `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md` + `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md` + user-approved 2026-08-25 Planning Canon & Human Home Alignment design.

## Global Constraints

- Baseline is completed `main` `265bab32da087c070ea2ea0d98a3bdace1e10f7f` unless a newer completed main appears before merge.
- T01~T11 are merged-domain/automated-evidence facts; this package must not promote them to playable Workbench, Human Usability, Player Experience, device, Android/export, or release readiness.
- Closed PR #43 (T12) and #44 (front-door docs) remain read-only historical/WIP evidence; no reopen, merge, rebase, or branch takeover.
- T12 gameplay/code implementation is out of scope for this package.
- Human Home is self-contained game-flow/system/learning projection; raw SHA, PR/CI history, local Godot path/ports, internal routing, and detailed Txx evidence remain System/Production drilldown.
- Existing `03 · UI · 생존 Flow Map`, `08 · 핵심 시스템 · 상세`, world/story pages, and Production Handoff remain the detailed owners; do not create duplicate canon.
- Approved current visual style is the first user-supplied 2026-08-25 image: dark moonlit ninja fantasy, brush-calligraphy/ink, premium illustrated poster language. Record the style decision without generating further images.
- Do not claim a durable Notion visual attachment unless an actual upload + attach + readback succeeds.
- Zero incremental paid cost.

---

### Task 1: Reconcile active repository front doors to T11

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `PROJECT_BRIEF.md`
- Modify: `MVP_ROADMAP.md`
- Modify: `docs/ACTIVE_CONTEXT.md`
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`

**Interfaces:**
- Consumes: merged T11 `main`, DEC-014~026 canon, closed PR #43/#44 read-only evidence.
- Produces: cold-start routing that identifies T11 as merged baseline and T12 as the next unimplemented product package, without reviving closed WIP branches.

- [ ] **Step 1:** Re-read all six files from the exact baseline branch and classify stale status sentences versus still-current design/canon content.
- [ ] **Step 2:** Reuse only still-valid portions of closed PR #44; change any `T12 OPEN DRAFT` language to `T12 NOT_MERGED / NEXT FRESH PACKAGE`, because #43 is now closed-unmerged.
- [ ] **Step 3:** Preserve historical receipts and protected T01~T11 domain boundaries while removing active `T05/T06 NEXT` misrouting from front doors.
- [ ] **Step 4:** Mark Human/Player/device/export/playable Workbench evidence as `NOT_RUN`/not integrated where appropriate.
- [ ] **Step 5:** Read back the branch versions and search for active stale `T06 NEXT`, `T05_INTEGRATED_READY_FOR_T06`, or claims that T12 is open/merged.

### Task 2: Rebuild the existing Notion Human Home projection

**Surfaces:**
- Modify: `닌자 서바이벌 · Home`
- Preserve/detail-link: `03 · UI · 생존 Flow Map`
- Preserve/detail-link: `08 · 핵심 시스템 · 상세`
- Preserve/detail-link: `09 · 세계관 · 핵심 스토리`
- Preserve/detail-link: `06 · Production · Handoff`
- Preserve: Project Registry/System record as operational master.

**Interfaces:**
- Consumes: current canon, current Flow Map, school/backpack/world detail owners, T11 evidence ceiling.
- Produces: `30초 전체 약속 → 전체 Run Flow → 4유파 → 6x6 백팩/조합/Fate → 최종 목표 → AI가 이해한 핵심 → 수정 방법 → drilldown` Human Home.

- [ ] **Step 1:** Remove raw T01~T11 implementation-history prose and code-owner details from the Human Home body while keeping a short human-readable implementation/evidence ceiling.
- [ ] **Step 2:** Put the full run flow directly on Home: starting school → unvisited school → Core/Elite/trace/Boss → branch Workbench → provisional next school → Fate commit → four-school clear → Final Binding → calamity core → Ninja Soul/legend.
- [ ] **Step 3:** Put the four school philosophies directly on Home: 봉마 mobile stronghold, 천술 ordered reaction, 귀인 dangerous close-range presence, 흑영 threat-priority execution.
- [ ] **Step 4:** Put the project-specific core backpack data directly on Home: 6x6 board, 4x3 start, bag expansion, 90° rotation, orthogonal adjacency, six-slot buffer, explicit first-tier combination, Boss/Shop/Chest acquisition, Fate commit.
- [ ] **Step 5:** Keep current status compact: T11 domain baseline merged; T12 fresh implementation package next; playable release-near slice/Human/device NOT_RUN. Link Production Handoff for raw receipts.
- [ ] **Step 6:** Preserve AI interpretation and human edit guide, but remove internal operational metadata from the main reading flow.
- [ ] **Step 7:** Fetch the exact Home again and verify no duplicate canon, stale T06 router, or operational metadata contamination remains.

### Task 3: Record the approved visual-style decision without generating new images

**Surfaces:**
- Modify: `02 · 비주얼 바이블` or its project-filtered visual canon record/surface.
- Optional durable asset attachment only if the current Notion tool surface can actually upload the existing user-supplied image and read it back.

**Interfaces:**
- Consumes: user statement `현재 승인된 그림체는 1번째 이미지 그림체다` and the first supplied image in the current conversation.
- Produces: a human-readable current style North Star, not a runtime asset claim.

- [ ] **Step 1:** Record the approved style traits: dark moonlit ninja fantasy, high-contrast ink/brush framing, premium painterly anime illustration, black/red/gold core palette with school accents, calligraphic Korean title treatment, readable silhouettes/effects.
- [ ] **Step 2:** Record negative constraints inferred from the approved comparison: do not use the denser parchment infographic look as the master art style; use infographic/presentation compositions only as supporting explanatory surfaces.
- [ ] **Step 3:** Attempt no new image generation.
- [ ] **Step 4:** If durable binary upload is not callable from the current tool surface, explicitly keep the visual file attachment `BLOCKED_TOOL_SURFACE` rather than pretending the chat file is attached to Notion.

### Task 4: Sync planning/work-control state after reactivation

**Surfaces:**
- Modify: `01 · 프로젝트 전체 작업계획`
- Modify if needed: Project Registry/System record status fields/notes without exposing them on Human Home.

**Interfaces:**
- Consumes: current user reactivation instruction and fresh merged main.
- Produces: clear distinction between reactivated planning/documentation work and still-unimplemented T12 gameplay work.

- [ ] **Step 1:** Replace the obsolete blanket `PAUSED / no new work` state with `REACTIVATED_FOR_PLANNING_ALIGNMENT` (or equivalent human-readable status) while preserving the 2026-08-25 pause event as history.
- [ ] **Step 2:** Keep #43/#44 as closed-unmerged historical references and name fresh-current-main as the only mutation baseline.
- [ ] **Step 3:** Set next product implementation gate to fresh T12, not the closed branch.
- [ ] **Step 4:** Read back System/Planning surfaces and verify Human Home does not inherit raw operational details.

### Task 5: Review, PR, merge, and post-merge readback

**Surfaces:**
- Current branch: `docs/planning-home-alignment-20260825`
- New current-task PR only.

**Interfaces:**
- Consumes: Tasks 1-4 candidate state.
- Produces: merged-main documentation truth + synced Notion human/system projections.

- [ ] **Step 1:** Compare branch to exact current `main`; verify docs/Notion-only scope and no gameplay code change.
- [ ] **Step 2:** Run at least five full-scope adversarial review loops covering authority, stale consumer/reference, Human/System split, market/identity distortion, evidence ceiling, duplicate canon, long-term maintenance, and better alternatives.
- [ ] **Step 3:** Correct every validated blocking finding and re-read affected destinations.
- [ ] **Step 4:** Create one current-task PR from the fresh branch, document T11 baseline, #43/#44 read-only handling, Notion sync, visual-style decision, IRG ceiling, and rollback.
- [ ] **Step 5:** Check current repository rules/checks/reviews/threads for the exact PR head. Do not reuse stale green evidence from another SHA.
- [ ] **Step 6:** Merge only if current-task PR gates permit it; no force, direct-main push, admin/ruleset bypass, or unrelated PR mutation.
- [ ] **Step 7:** Fetch new `main`, read back changed repository files, re-fetch Human Home/Planning/Production/Visual surfaces, and recalculate remaining work.
- [ ] **Step 8:** Report BEFORE → AFTER → expected effects → trade-offs, exact merge/readback evidence, `NOT_RUN` items, and the next fresh T12 implementation gate.
