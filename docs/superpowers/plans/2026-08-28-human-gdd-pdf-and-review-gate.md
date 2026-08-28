# Human GDD PDF and Review Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the current human-facing Master GDD downloadable as a verified PDF and make fresh-read, web research, feasibility review, and adversarial review mandatory before future non-trivial work.

**Architecture:** `docs/design/NINJA_SURVIVAL_MASTER_GDD.md` remains the sole human-readable source. A small local ReportLab exporter creates the committed `exports/NINJA_SURVIVAL_MASTER_PRODUCTION_GDD_20260828.pdf`; documentation links point readers to that artifact rather than creating a second editable owner. `AGENTS.md` and the mutable routers record the required review gate without changing product rules or Godot runtime behavior.

**Tech Stack:** Markdown, Python 3, ReportLab, pypdf, Poppler (`pdfinfo`, `pdftoppm`), GitHub repository artifacts.

**Spec:** `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`, `docs/ACTIVE_CONTEXT.md`, and the user's 2026-08-28 direction to always research, adversarially review, and feasibility-check work.

**Tracking:** GitHub Issue #120.

## Global Constraints

- Treat `docs/design/NINJA_SURVIVAL_MASTER_GDD.md` as the editable human GDD authority; the PDF is a generated distribution artifact.
- Preserve repository-only documentation ownership; do not restore Notion as an active owner.
- Use no paid service or new online dependency.
- Do not claim game runtime, Human Usability, Player Experience, device, or Android evidence from document export evidence.
- Before every non-trivial task, fresh-read current authority, inspect applicable implementation, run current web research, record feasibility limits, and complete at least five whole-scope adversarial loops.
- Keep unrelated open PRs read-only and work only from fresh completed `origin/main`.

---

### Task 1: Define one source and the mandatory review gate

**Files:**
- Modify: `AGENTS.md`
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Modify: `docs/ACTIVE_CONTEXT.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Modify: `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`

**Interfaces:**
- Consumes: current repository-only owner policy and Master GDD decision.
- Produces: a stable rule that makes the Markdown source authoritative and the PDF downloadable/generated, plus a project-wide review-gate contract.

- [x] **Step 1: Add the review-gate wording**

Add a rule requiring fresh internal reads, current web research from primary sources where applicable, concrete Godot/code/data/runtime feasibility confirmation, explicit evidence limits, and five validated full-scope adversarial loops before declaring a non-trivial task complete.

- [x] **Step 2: Link the human GDD to its PDF artifact**

Add a relative Markdown link from the Master GDD and documentation map to `exports/NINJA_SURVIVAL_MASTER_PRODUCTION_GDD_20260828.pdf`, explicitly labelling the Markdown as the source and the PDF as the downloadable human edition.

- [x] **Step 3: Verify authority consistency**

Run:

```powershell
rg -n "mandatory review|PDF|NINJA_SURVIVAL_MASTER_GDD.pdf|NOT_RUN" AGENTS.md docs/CURRENT_CONFIRMED_DECISIONS.md docs/ACTIVE_CONTEXT.md docs/DOCUMENTATION_MAP.md docs/design/NINJA_SURVIVAL_MASTER_GDD.md
```

Expected: all active routers point to the same GDD source and do not elevate document evidence to game-play evidence.

### Task 2: Provide a repeatable Korean PDF exporter

**Files:**
- Create: `tools/export_human_gdd_pdf.py`
- Create: `docs/PDF_EXPORT.md`

**Interfaces:**
- Consumes: UTF-8 Master GDD Markdown via `--source`.
- Produces: a Korean-capable PDF at the exact path passed with `--output`.

- [x] **Step 1: Implement the minimal converter**

Implement `python tools/export_human_gdd_pdf.py --source <markdown> --output <pdf>` using local ReportLab and the installed Malgun Gothic fonts. Support headings, paragraphs, bullet lists, quotations, fenced code blocks, and simple GDD tables without network access.

- [x] **Step 2: Exercise the production command**

Run:

```powershell
python tools/export_human_gdd_pdf.py --source docs/design/NINJA_SURVIVAL_MASTER_GDD.md --output exports/NINJA_SURVIVAL_MASTER_PRODUCTION_GDD_20260828.pdf --source-branch <branch> --source-commit <40-character-sha> --generated-at <ISO-8601-time>
```

Expected: exit code 0 and a non-empty PDF at the exact output path.

- [x] **Step 3: Add regeneration and evidence instructions**

Document the exact command, the source/artifact authority boundary, `pdfinfo`/pypdf structural checks, and render inspection with `pdftoppm` in `docs/PDF_EXPORT.md`.

### Task 3: Validate the downloadable artifact

**Files:**
- Create: `exports/NINJA_SURVIVAL_MASTER_PRODUCTION_GDD_20260828.pdf`
- Create: `tmp/pdfs/*` (untracked verification output only)

**Interfaces:**
- Consumes: exporter output from Task 2.
- Produces: structural, textual, and rendered-page evidence for the committed PDF.

- [x] **Step 1: Check PDF structure and text**

Run `pdfinfo` and use pypdf to assert a positive page count, title metadata, and the Korean title `닌자의 신` in extracted text.

- [x] **Step 2: Render every page**

Run `pdftoppm -png` for the first, a table-dense middle, and the last page. Inspect the rendered images for Korean glyph substitution, clipped headers/footers, column overflow, and unreadably small table text.

- [x] **Step 3: Correct only validated export defects**

If an inspected defect exists, make the smallest exporter/layout correction, re-export, re-run structural checks, and re-inspect the affected pages. Otherwise retain the minimal exporter.

### Task 4: Close with research, adversarial review, and repository delivery

**Files:**
- Modify: files from Tasks 1–3 only when a validated finding requires it.

**Interfaces:**
- Consumes: current official PDF-library evidence, repository source, and rendered PDF evidence.
- Produces: a focused branch/PR with exact-head checks and a post-merge main readback.

- [x] **Step 1: Perform five whole-scope adversarial loops**

For each loop, attack the authority boundary, Korean rendering, table/layout readability, downloadability/tracking, source-to-artifact freshness, and evidence-label discipline. Record only validated findings and retest each correction.

- [ ] **Step 2: Run exact-head checks**

Run the source/link scan, Python syntax check, production export, `pdfinfo`, pypdf text assertion, and rendered-page visual inspection on the final commit head.

- [ ] **Step 3: Deliver safely**

Commit focused changes, push the current-task branch, create a dedicated PR, run the required exact-head checks, squash merge only after successful checks, then fetch and read back the resulting `origin/main` identity and PDF/document destinations.
