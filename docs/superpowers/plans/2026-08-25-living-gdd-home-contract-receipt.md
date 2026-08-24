# Living GDD + Visual Dashboard Alignment Receipt

## Goal

Apply the user-approved Project Home contract to `NINJA_SURVIVAL` without inventing new game rules:

> Human Project Home is a project-specific **Living GDD + Visual Dashboard**, while Detail Canon, AI/System Workspace and GitHub keep their distinct authority and implementation/evidence responsibilities.

## Baseline

- GitHub main at task start: `33f4b96bf78e63c27fe4024f817fc8963b4ebb3e`.
- Latest product implementation package: T11.
- Next product gate: fresh T12 Atomic Workbench + Fate + next-route commit.
- User-supplied images in this task: examples for information density/layout, **not automatically approved assets**.
- Master style was already approved before this task; no new art-style decision or image generation was required.

## Notion Human Home changes

`닌자 서바이벌 · Home` was rebuilt around:

1. `PROJECT NORTH STAR`
2. `HOW THE GAME WORKS`
3. `HOW IT SHOULD LOOK`
4. `CORE GAME DATA`
5. `CONTENT & DESIGN`
6. `DEVELOPMENT REALITY`
7. `DETAIL LIBRARY & AI WORKSPACE`

Top-level acceptance:

> Main Home alone must let a human judge what game is being made and how it should be made; AI/System Workspace must retain all implementation/verification detail needed by agents.

Home directly exposes:

- project identity / player fantasy,
- explanatory Visual GDD and full Run flow,
- 5-minute school encounter cadence,
- four-school danger-handling philosophies,
- 6x6 backpack / rotation / adjacency / combination / Workbench / Fate relationships,
- human-relevant economy/content bounds,
- current visual direction,
- human-level implementation reality and Human QA ceiling.

Raw SHA/PR/CI/port/tool routing remains outside the main Home reading flow.

## Canonical linked views

Two project-filtered views were created instead of duplicating data:

- `ASSET LIBRARY · Master` -> Ninja + Approved + APPROVED gallery.
- `CORE SYSTEM · Master` -> Ninja + CONFIRMED human-facing table.

The views hide machine/internal fields and expose human-facing fields only.

## Repository corrections

Three active routing documents were found stale and corrected:

- `docs/DOCUMENTATION_MAP.md`
- `docs/SYSTEM_MAP.md`
- `docs/BASE_RULES_VERSION.md`

Validated stale findings included active `T05/T06 NEXT` and `route runtime NOT_STARTED` language despite T06~T11 already being integrated.

`BASE_RULES_VERSION.md` now separates:

- historical full/local Base sync,
- historical T01-era Base observation,
- fresh 2026-08-25 Base observation,
- current project state.

Fresh Base main observed during this task:

`3c3376845b9a1b7921a4260aa6259cd61533ffc4`

Its current Human Home policy explicitly guards Living GDD, top Visual GDD, human-relevant outputs on Home, AI Workspace completeness and Home↔Detail↔AI↔runtime traceability.

## Alternative review

- Copy human tables into Home as a second dataset — **REJECT**: drift / duplicate canon.
- Keep a short Home and link everything — **REJECT**: fails self-contained understanding.
- Project-filtered Linked Views over Master DBs — **ADOPT**.

Notion official guidance confirms linked databases expose the same source content across pages, while filters/sorts/view settings remain contextual to the linked view.

## Adversarial review

1. **Authority/router:** stale `DOCUMENTATION_MAP` found and corrected.
2. **Human/System split:** Home has no raw PR/SHA/port in the main reading flow; no blocker.
3. **Data/canon accuracy:** 19/3/5 content bounds, shop/chest/boss reward, encounter timing and school content budget rechecked; no mismatch.
4. **Visual approval:** examples were not promoted; only Approved Asset view can surface canon assets; no new generation.
5. **Maintenance/duplicate canon:** Linked View approach selected over copy tables/link-hub approaches.
6. **Whole-state re-attack:** `SYSTEM_MAP` and `BASE_RULES_VERSION` stale active state were corrected; final candidate is docs-only.

## Evidence ceiling

Verified in this task:

- Notion Home destination readback.
- two linked Master DB views created with project/status filters.
- six L2 child pages preserved.
- current Base main fresh observation.
- repository diff limited to routing/version documentation.

Not run / not claimed:

- new gameplay runtime behavior,
- local Godot Editor authoring session,
- Human Usability / Player Experience,
- device / Android export,
- durable Notion upload of the previously approved chat image binary.

## Next product gate

This information-architecture/documentation package does not advance gameplay implementation.

Next separate product package remains:

`T12 — Atomic Workbench + Fate + next-route commit`.