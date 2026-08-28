# Human Player GDD PDF Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish a Korean player-facing GDD PDF that explains the game's fun, core systems, and current Godot implementation in plain language without turning the technical GDD into a second source of truth.

**Architecture:** Keep `docs/design/NINJA_SURVIVAL_MASTER_GDD.md` as the technical product/implementation contract. Add `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md` as a curated reader source, extend the existing ReportLab exporter only to support a document-specific title/header, then publish the PDF only after the reader source exists on completed `main`.

**Tech Stack:** Markdown, Python 3, ReportLab, pypdf, Poppler, GitHub pull requests.

**Spec:** User-approved current-chat request plus `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`, `AGENTS.md`, and `docs/PDF_EXPORT.md`.

## Global Constraints

- The human GDD is explanatory; it does not become implementation authority or claim Human Usability, Player Experience, device/export, or release readiness.
- Preserve approved gameplay canon: four distinct schools, automatic combat with movement/positioning agency, Core -> Elite -> Trace -> Boss, spatial Workbench/Fate commit, GOLD and Ninja Soul rules.
- Explain actual implementation with Godot Scene/Node/Resource ownership in Korean, but omit SHAs, PR numbers, test logs, conflict IDs, and internal paths from the reader-facing PDF.
- Keep the technical Master GDD and existing implementation evidence as the durable technical owners.
- Use the bundled Python runtime; add no paid service or new dependency.
- Publish from a source commit that is an ancestor of completed `main`; do not repeat a squashed-branch provenance receipt.

---

### Task 1: Add reader-source and title-parameter behavior

**Files:**
- Create: `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md`
- Modify: `tools/export_human_gdd_pdf.py`
- Modify: `tools/test_export_human_gdd_pdf.py`

**Interfaces:**
- Consumes: technical Master GDD facts and the existing `export_pdf()` API.
- Produces: human-reader source Markdown and optional `document_title`/`header_label` arguments that retain Master-GDD defaults for existing callers.

- [x] **Step 1: Write the failing title-identity test**

Add a test that calls:

```python
exporter.export_pdf(
    source_path,
    output_path,
    source_branch="main",
    source_commit="0123456789abcdef0123456789abcdef01234567",
    generated_at="2026-08-28T00:00:00+09:00",
    document_title="닌자의 신 - 플레이어용 게임 기획서",
    header_label="닌자의 신 | 플레이어용 게임 기획서",
)
```

Assert that `PdfReader(...).metadata.title` and extracted page text contain the supplied player-facing title, which the current exporter cannot do.

- [x] **Step 2: Run the focused test and verify RED**

Run:

```powershell
& $runtimePython -m unittest tools.test_export_human_gdd_pdf.HumanGddPdfExporterTests.test_export_uses_reader_facing_document_identity -v
```

Expected: `TypeError` for the missing keyword arguments.

- [x] **Step 3: Implement the smallest compatible title/header parameters**

Add optional keyword-only `document_title` and `header_label` values to `export_pdf()`; put them on the ReportLab document for metadata and `page_decor()`. Add matching optional CLI arguments. Keep the current Master-GDD values as defaults.

- [x] **Step 4: Run the focused test and complete exporter regression tests**

Run:

```powershell
& $runtimePython -m unittest tools\test_export_human_gdd_pdf.py -v
```

Expected: all existing tests plus the new title-identity test pass.

- [x] **Step 5: Write the reader source**

Create a concise Korean reader GDD with these exact sections: `이 게임은 무엇인가`, `한 판은 어떻게 흐르는가`, `네 유파는 무엇이 다른가`, `전투에서 내가 하는 판단`, `전투 뒤의 선택: 보상·백팩·Fate`, `보상과 재도전`, `어떻게 구현하고 있는가`, `현재 어디까지 왔는가`.

For every implementation explanation, mark it as `현재 구현됨`, `기반 구현됨`, or `다음 제작 범위` in plain Korean; do not include code paths or internal receipt identifiers.

- [x] **Step 6: Commit reader source and exporter behavior**

```powershell
git add docs/design/NINJA_SURVIVAL_HUMAN_GDD.md tools/export_human_gdd_pdf.py tools/test_export_human_gdd_pdf.py
git commit -m "docs: add human player GDD source"
```

### Task 2: Merge the durable reader source before publication

**Files:**
- No additional files beyond Task 1.

**Interfaces:**
- Consumes: Task 1 exact branch head and required CI checks.
- Produces: a completed-`main` ancestor that contains the human reader source and title-capable exporter.

- [x] **Step 1: Run exact-head checks**

Run `git diff --check`, the complete exporter test module, `py_compile`, and a temporary PDF export using the player title/header.

- [x] **Step 2: Push and create a focused source PR**

Create a PR limited to Task 1. Do not modify draft PR #49.

- [x] **Step 3: Merge only after required checks pass and read back `origin/main`**

Squash merge the source PR, fetch remote, and record its completed-main SHA for publication. The later PDF manifest must cite this SHA.

### Task 3: Publish the actual human PDF from completed main

**Files:**
- Create: `exports/NINJA_SURVIVAL_HUMAN_GDD_20260828.pdf`
- Create: `docs/publication/NINJA_SURVIVAL_HUMAN_GDD_PDF_MANIFEST.json`
- Modify: `README.md`
- Modify: `docs/PDF_EXPORT.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Modify: `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`
- Modify: `docs/ACTIVE_CONTEXT.md`
- Modify: `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Delete: `exports/NINJA_SURVIVAL_MASTER_PRODUCTION_GDD_20260828.pdf`
- Delete: `docs/publication/NINJA_SURVIVAL_MASTER_GDD_PDF_MANIFEST.json`

**Interfaces:**
- Consumes: reader source and exporter from completed `main`.
- Produces: the only download link labelled as human/player GDD and a SHA-verified publication manifest.

- [x] **Step 1: Start a fresh publication branch from the Task 2 completed main**

Verify the reader source exists at `origin/main`, then create `codex/human-player-gdd-publish-<issue>` from that exact ref.

- [x] **Step 2: Generate the PDF and publication manifest**

Use the completed-main SHA as `--source-commit`, pass the player title/header, compute source/generator/artifact SHA-256 values, and write the human-GDD manifest with `human_visual_review: NOT_RUN`.

- [x] **Step 3: Point all human download routes to the new artifact**

Make README, documentation map, active context, decision ledger, PDF export contract, and technical Master GDD call the reader GDD a derivative from `NINJA_SURVIVAL_HUMAN_GDD.md`. Remove the old technically dense download artifact/manifest to prevent user confusion.

- [x] **Step 4: Validate the final artifact**

Run the full exporter tests, `py_compile`, `pdfinfo`, pypdf assertions for the eight Korean section headings/no raw Markdown/no blank page, SHA manifest checks, and render all pages with `pdftoppm`. Visually inspect title, system-explanation, and final-status pages.

- [x] **Step 5: Run five whole-scope adversarial loops and record only validated findings**

Attack reader/technical authority separation, gameplay canon accuracy, implementation-status honesty, first-session comprehension, Korean readability, content overload, source provenance, PDF layout, cost/rights, broken links, stale artifacts, and evidence ceilings. Correct a valid finding and re-run only affected validation.

- [ ] **Step 6: Commit, PR, verify, squash merge, and completed-main readback**

Publish only after checks pass, confirm the manifest source SHA is an ancestor of post-merge `main`, and leave unrelated open PRs read-only.
