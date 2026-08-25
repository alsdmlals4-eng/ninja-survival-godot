# VISUAL HANDOFF POST-MERGE RECEIPT — 2026-08-25

> Role: durable sender packet for the completed Hybrid Visual session. This file owns **handoff / resume / post-merge / image-delivery / Base-learning status only**. Product/runtime canon authority remains unchanged.

```yaml
handoff_packet_status: PACKET_READY
transfer_status: PENDING_RECEIVER_ACK
prepared_from_main_sha: c52d5b19e091e05b5b2720d513f1f14a85ca2f4f
prepared_at: 2026-08-25_KST
project: NINJA_SURVIVAL
workstream: HYBRID_VISUAL_DIRECTION_AND_NOTION_DELIVERY
last_safe_checkpoint: PROJECT_VISUAL_CLOSEOUT_PLUS_BASE_BCP032_IMPLEMENTED
next_safe_action: FRESH_READ_THEN_PREPARE_REVISED_1_TO_3_TEXT_BRIEF_ONLY
approval_required_before_resume_generation: true
retry_safe_for_completed_uploads_or_pr_writes: false
verify_before_retry: true
```

## 1. Sender checkpoint

### Project repository

- visual closeout PR #50: merged.
- visual closeout merge: `5b7c86e25c53e4a2667f1a70dc59938fc60c4c9a`.
- post-merge receipt commit on project main: `c52d5b19e091e05b5b2720d513f1f14a85ca2f4f`.
- visual handoff owner: `docs/CURRENT_VISUAL_HANDOFF.md`.
- project problem/solution/lesson owner: `docs/learning/2026-08-25-hybrid-visual-and-notion-delivery-lessons.md`.
- separate T12 implementation PR #49 remains **OPEN / DRAFT / READ_ONLY / NO MUTATION** for this visual handoff.

### Base learning lifecycle

BCP `BCP-2026-032-ai-visual-continuity-and-notion-preview-fallback` completed its full lifecycle:

- proposal PR #683: merged.
- approval PR #686: approved for implementation.
- active implementation PR #703: exact reconciled head `4b3b92b9cd7e83d65de571c5b28aab9bfc089ec9`, six approved files only, exact-head workflows GREEN, squash-merged as Base main commit `5b241fce6623d4b0a152bff59ad6a257a18704ed`.
- BCP closeout PR #706: Registry + proposal-local implementation receipt only, merged as `e5a0fb524a90d5373ab3f3e64ff3bbc100f9fa24`.
- Base Registry status: `IMPLEMENTED`, implementation PR `#703`.
- reusable Base Case: `docs/knowledge/cases/AI_VISUAL_CONTINUITY_AND_NOTION_PREVIEW_FALLBACK_CASE.md`.
- stale/diverged implementation draft #689: closed unmerged, historical Existing-Solution-First evidence only.
- stale fresh attempt #701: closed unmerged, superseded by #703.

Project-only values were **not** promoted to Base: school names, exact school motifs, starting-school Stage-3 rule, 2–3-head SD ratio, project palette/logo/key-art layout, project Notion IDs.

## 2. Current visual canon to preserve

### Surface split

- **Presentation / key art / lore / marketing:** hand-drawn ink codex + dark painterly anime ninja fantasy.
- **Gameplay:** animation-forward 2–3-head SD anime + C-leaning dark painterly DNA, with restrained ink/rough-edge cues so it remains the same IP.

### Persistent protagonist contract

The runtime protagonist is **one fixed ninja identity**.

```text
fixed face / hair / body / core outfit / core silhouette
+ acquired school item layers
+ aura / energy layers
+ companion / shadow layers
= one accumulated ninja identity
```

Do not redraw the four schools as four replacement protagonists for runtime use.

All four traces must coexist cleanly. Strongest **Trace Stage 3 visual expression is reserved for the starting/main school**; other acquired schools remain supporting layers so the final composite does not become visual clutter.

### Exact project-only school motifs

- 봉마류 = **부적 + 식신**
- 천술류 = **차크라 기운**
- 귀인류 = **오니가면 + 귀기**
- 흑영류 = **그림자 + 어둠**

These exact motifs are project canon and must not be replaced by generic elemental skins.

## 3. Image inventory and Notion audit

Notion Visual Bible page: `02 · 비주얼 바이블` / page id `3c01b237-eb1c-8116-9028-c8c8c427e467`.

All three current images were fetched after placement and resolve as **Notion-owned `prod-files-secure` image blocks**:

1. **Hybrid Key Visual**
   - role: `APPROVED_MASTER_BRIDGE`
   - delivery: `SERVER_READBACK_PASS`
   - use: Presentation ↔ gameplay style bridge.
2. **Four-school full-body Presentation sheet**
   - role: `APPROVED_SUPPORTING_REFERENCE`
   - delivery: `SERVER_READBACK_PASS`
   - warning: silhouettes/motifs reference only; **not four runtime protagonists**.
3. **SD / Action / Icon three-panel sheet**
   - role: `WORKING_REFERENCE_ONLY`
   - delivery: `SERVER_READBACK_PASS`
   - valid: animation-forward SD direction and three-panel production structure.
   - superseded in detail by fixed-character additive-trace rules and the exact current motifs above.

```yaml
visual_audit_required: true
upload_attach: PASS
page_destination_readback: PASS
attachment_or_image_readback: PASS
approval_scope_confirmed: PASS
supersession_checked: PASS
human_visible_browser_android_ios: NOT_RUN
high_res_pixel_equivalent_notion_delivery: NOT_PROVEN
runtime_product_asset_integration: NOT_RUN
```

The Notion images are **low-resolution durable previews**. Server readback is not proof of high-resolution source preservation or actual browser/Android/iOS pixel rendering.

## 4. Side effects already applied — do not repeat blindly

- project PR #50 merged.
- project post-merge receipt commit `c52d5b19...` exists.
- Notion Hybrid Key Visual preview attached/read back.
- Notion four-school Presentation preview attached/read back.
- Notion SD/Action/Icon working preview attached/read back.
- project problem/solution/lesson file recorded.
- Base BCP-032 proposal/approval/implementation/closeout completed.
- Base active owners now include the generic persistent-character additive-layer gate and bounded inline-SVG raster preview fallback.

Before retrying any upload, PR write, Base promotion or image placement, **fresh-read the destination first**. Duplicate side effects are not considered retry-safe.

## 5. Front-door supersession / stale-field handling

Fresh chats must not rebuild current visual truth from older front-door sentences alone.

- `AGENTS.md` Visual §11 still contains the earlier painterly master-style baseline. Treat it as a protected baseline/negative contract; **current detailed visual authority is the latest user-approved rules + `docs/CURRENT_VISUAL_HANDOFF.md` + Notion Visual Bible + this receipt**.
- `docs/ACTIVE_CONTEXT.md` contains pre-closeout self-referential `current_completed_main` and supplementary-image upload/readback fields. Those **SHA/image-status fields are superseded by this receipt**. Its product/T12 domain status remains useful unless newer product work supersedes it.
- `docs/CURRENT_VISUAL_HANDOFF.md` contains the durable current visual rules. Any pre-merge `current_completed_main` observation inside it is historical preparation context, not the receiver's current-main authority.
- Receiver must always re-fetch project `main`, open PR inventory and current Base `main` before mutation.

This supersession is deliberately narrow: it does **not** change combat, route, economy, Workbench, T12 or other product/runtime canon.

## 6. Protected scopes

Do not mutate without a new explicit scope:

- PR #49 T12 implementation branch/worktree.
- closed historical PR #43/#44 branches.
- project product/runtime canon unrelated to visual continuation.
- exact project-only school motifs and starting-school Stage-3 visual rule.
- already approved Hybrid Key Visual role.
- Base BCP-032 implementation unless a new Base change proposal is separately justified.

## 7. Pending decision gate

No image should be generated automatically at resume.

The next visual package is the **revised 1–3 set**:

1. fixed-character SD accumulated-trace sheet,
2. same-character SD action / animation key-pose sheet,
3. school skill / symbol icon rough.

First produce a **text brief** that explicitly tests the four-trace final composite and the dominant starting-school Stage-3 hierarchy. Then stop for user approval before generation.

Safe work while approval is pending:

- fresh-read project/Base/Notion authority,
- inspect approved reference images,
- research/benchmark if decision-relevant,
- prepare/revise the text brief,
- identify implementation consumers.

Not safe without approval:

- generating replacement images,
- changing the fixed-character identity,
- changing school motifs,
- expanding the image package or product scope.

## 8. Receiver fresh-read order

A new chat must read in this order before continuing visual work:

1. current project `AGENTS.md`
2. latest user instruction
3. current project `main` + open PR inventory
4. `docs/CURRENT_CONFIRMED_DECISIONS.md`
5. `docs/CURRENT_VISUAL_HANDOFF.md`
6. this receipt
7. `docs/ACTIVE_CONTEXT.md` with the narrow stale-field rules above
8. Notion `02 · 비주얼 바이블`
9. Notion `01 · 프로젝트 전체 작업계획`
10. current Base `main`; when visual production/delivery applies, consume the current Base visual/Notion owners rather than this receipt's historical Base SHA.

## 9. Receiver ACK contract

Sender ends at:

```yaml
handoff_packet_status: PACKET_READY
transfer_status: PENDING_RECEIVER_ACK
```

The new chat changes this conceptually to `TRANSFER_ACCEPTED` only after it has independently confirmed:

```yaml
receiver_ack:
  current_project_main_refetched: REQUIRED
  prepared_main_vs_observed_main_compared: REQUIRED
  current_open_pr_inventory_read: REQUIRED
  protected_pr49_confirmed_read_only: REQUIRED
  current_visual_handoff_read: REQUIRED
  notion_visual_bible_read: REQUIRED
  three_image_delivery_status_understood: REQUIRED
  pending_generation_approval_understood: REQUIRED
  already_applied_side_effects_understood: REQUIRED
  current_base_main_refetched: REQUIRED_WHEN_BASE_RULES_AFFECT_TASK
```

If project main, visual canon, Notion image state, PR ownership or Base owners changed materially after packet preparation, set `CONTEXT_DRIFT_RECHECK_REQUIRED` and reconcile before acting.

## 10. Evidence ceiling at handoff

```text
PROJECT_VISUAL_CANON_AND_HANDOFF: VERIFIED_AT_REPOSITORY_AND_NOTION_SERVER_LEVEL
BASE_BCP032_PROMOTION: IMPLEMENTED_AND_REGISTRY_CLOSED
NOTION_LOW_RES_PREVIEW_DELIVERY: PASS
NOTION_HIGH_RES_PIXEL_EQUIVALENT: NOT_PROVEN
BROWSER_ANDROID_IOS_PIXEL_RENDER: NOT_RUN
IN_GAME_SD_RUNTIME_ASSET_IMPLEMENTATION: NOT_RUN
HUMAN_USABILITY: NOT_RUN
PLAYER_EXPERIENCE: NOT_RUN
T12_PRODUCT_IMPLEMENTATION: SEPARATE_OPEN_DRAFT_PR_49
```

The next chat should preserve these ceilings rather than promoting planning/server evidence into runtime or human-visible proof.
