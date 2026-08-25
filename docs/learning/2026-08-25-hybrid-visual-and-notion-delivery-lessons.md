# 2026-08-25 Hybrid Visual + Notion Delivery — Incident / Solution / Lesson

## Status

- Project: NINJA_SURVIVAL / 닌자의 신
- Scope: visual direction, image-production continuity, Notion durable preview delivery
- Evidence class: project-specific observation + reproduced connector invocation/readback
- This document is **not** runtime gameplay proof.

## Incident A — school identity drifted toward four different protagonists

### Symptom

Early school character sheets made 봉마류 / 천술류 / 귀인류 / 흑영류 visually distinct by presenting four separate full-body characters. The result was strong as a Presentation reference, but it created a product risk: the in-game Run could look like the protagonist is replaced per school instead of one ninja accumulating four traditions.

### Root cause

The visual brief optimized school-level silhouette differentiation before explicitly locking the protagonist identity ownership rule.

Without an explicit invariant, school identity could be expressed through:

- body/face replacement,
- costume replacement,
- school-specific protagonist silhouette,

instead of through bounded additive visual layers.

### User correction / approved solution

Keep one player identity and move school expression into layered visual channels:

```text
fixed protagonist
+ school item motif
+ aura / energy motif
+ companion / shadow motif
= accumulated tradition state
```

Approved school motifs:

- 봉마류: 부적 + 식신
- 천술류: 차크라 기운
- 귀인류: 오니가면 + 귀기
- 흑영류: 그림자 + 어둠

The strongest Trace Stage 3 visual belongs only to the **starting/main school**. Other schools remain supporting layers so four traditions can coexist naturally.

### Guardrails

Before future in-game character art approval, explicitly inspect:

1. Is the same face/hair/body/core outfit still readable?
2. Can all four traces coexist without covering the player silhouette?
3. Does one main school remain visually dominant when Stage 3 applies?
4. Are school differences carried by motif/effect/action language rather than four different bodies?
5. Does the design still read at small SD gameplay scale?

### Lesson

When a game has **one persistent protagonist + multiple learned factions/classes/traditions**, visual variation should first define **identity ownership** and **additive layer ownership** before making faction character sheets.

Faction differentiation and protagonist continuity are separate requirements. Solving only the first can create a technically attractive but product-inconsistent result.

---

## Incident B — key art and in-game rendering risked looking like different games

### Symptom

The approved key art / presentation direction is mature, ink-heavy, painterly anime. The intended in-game view needs smaller, more animated SD characters for readability and production practicality.

A direct style switch risks an IP discontinuity: marketing art and gameplay could look unrelated.

### Solution

Use a **Hybrid Master Style** with shared visual DNA rather than forcing one rendering density everywhere.

Shared invariants:

- face / hair / core outfit identity,
- weapon language,
- school motifs,
- black / deep navy / charcoal + red / warm gold base,
- circular brush/moon framing in presentation surfaces,
- restrained ink / rough-edge cues in gameplay,
- readable silhouettes above decorative density.

Surface-specific rendering:

- Presentation/Lore/Marketing: painterly hand-drawn ink codex.
- Gameplay: animation-forward 2–3 head SD anime with C-leaning dark painterly DNA.

### Lesson

Cross-surface style consistency should be defined by **identity invariants and motif invariants**, not by forcing identical rendering detail.

A game can use painterly key art and SD gameplay successfully if shared identity/motif/palette/hierarchy rules are explicit and checked.

---

## Incident C — Notion connector had no direct local-binary image input

### Symptom

The approved image existed as a local generated PNG. The current Notion `create-attachment` callable surface accepted:

- small UTF-8 text content, or
- a publicly reachable direct HTTPS `source_url`.

It did not expose a direct local binary file parameter.

A Google Drive upload was attempted as transport, but the Drive file remained private; Notion's server-side fetch could not use it as a public direct source.

### Existing Base route consulted

Current Base already documents a stronger verified route:

`docs/knowledge/game-development/NOTION_CONNECTOR_IMAGE_DELIVERY_CORRECTION_2026-08-22.md`

which prefers connector transport → Notion `create-attachment` → returned `file-upload://` → destination readback, and explicitly keeps client-visible verification separate.

### Bounded fallback reproduced in this project

For **preview-only** delivery, a small raster derivative was embedded inside a UTF-8 SVG document:

```text
approved local PNG
-> downscale/compress preview
-> embed raster as data URI inside SVG
-> Notion create-attachment(content=<svg...>)
-> status=uploaded
-> use returned file-upload:// source directly in Visual Bible
-> fetch destination
-> require Notion-owned prod-files-secure readback
```

This worked for low-resolution preview attachments without requiring public external hosting.

### Evidence

- Hybrid Key Visual preview: Notion-native attachment readback previously resolved to `prod-files-secure`.
- Four-school Presentation supporting preview: `create-attachment(content SVG)` returned `status=uploaded` during closeout.
- SD/action/icon working preview: `create-attachment(content SVG)` returned `status=uploaded` during closeout.
- Final destination readback of the latter two must be checked before completion claim.
- Browser/Android/iOS pixel rendering remains NOT_RUN unless directly observed.

### Limitations / do not overgeneralize

This SVG-inline route is **not a replacement for full-quality binary delivery**:

- connector inline content has a size ceiling,
- preview must be downscaled/compressed,
- high-resolution pixel-equivalent upload is not proven,
- SVG/data-URI rendering behavior may differ across future connector/client versions,
- server readback is not human-visible render evidence.

Use it only when a low-resolution durable preview is actually sufficient.

### Reuse classification

- Project: `ADOPT` as a bounded preview fallback.
- Base candidate: `ADAPT` as an additional fallback branch under the existing Notion image-delivery contract, not as the primary route.

### Lesson

When a connector supports **text attachments but not local binary attachments**, a self-contained text media container can sometimes bridge preview delivery. The key is to label the evidence ceiling precisely: **durable low-res preview**, not full-quality asset delivery.

---

## Completion / recurrence checklist

For future approved visual batches:

```text
current visual canon
-> exact image authority state (APPROVED / SUPPORTING / WORKING)
-> durable Notion destination needed?
-> strongest available typed binary route first
-> preview fallback only when quality ceiling is acceptable
-> returned file-upload source consumed directly
-> destination fetch/readback
-> human-visible client observation only when rendering is part of acceptance
-> update CURRENT_VISUAL_HANDOFF
```

Do not let a successful attachment call silently promote a superseded working image into final art authority.

## Base promotion candidates

1. **Persistent-character / additive-tradition visual layering principle**
   - generalize without Ninja Survival school names or motifs.
   - candidate owner: visual/game-art workflow knowledge, not runtime class architecture.
2. **Inline SVG embedded-raster Notion preview fallback**
   - generalize only as bounded preview fallback under existing Notion image-delivery contract.
   - must preserve `READBACK_PASS != HUMAN_VISIBLE_PASS` and high-resolution limitation.

User requested Base promotion during project closeout on 2026-08-25. Base proposal/implementation lifecycle must remain separated according to `managing-base-change-proposals`.
