# Integrated Human Blueprint PDF Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` in an isolated worktree. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish one downloadable PDF that preserves the existing Human Blueprint and adds current wireframes, flow maps, and user-locked visual references.

**Architecture:** A small PDF composer receives the historical 28-page PDF and an explicit companion-page specification. It generates three front-matter pages, retains the historical page objects unchanged, then appends seven current-main visual companion pages. A dedicated manifest owns source hashes, locked asset provenance, artifact hash, page count, and evidence boundaries.

**Tech Stack:** Python 3, ReportLab 4.4.9, pypdf 6.14.2, Pillow 12.3.0, Malgun Gothic, Poppler (`pdfinfo`, `pdftoppm`), GitHub repository binary path.

**Spec:** `docs/superpowers/specs/2026-09-02-integrated-human-blueprint-pdf-design.md`

## Global Constraints

- Start from fresh `origin/main` and use an isolated worktree; preserve the existing PDF and all unrelated worktrees.
- Reuse only the locked/current assets enumerated in the design; do not generate a new image binary.
- Use a failing test before production composer code; test real output with pypdf.
- Write the temporary PDF beside the final output and atomically replace the final only after a PDF header check.
- Keep source/contract/static, PDF render, runtime, Human, and device evidence separate.
- Keep final artifact under `exports/` because this project already owns human downloadable PDF derivatives there.

---

### Task 1: Create the integration contract and RED test

**Files:**
- Create: `docs/superpowers/specs/2026-09-02-integrated-human-blueprint-pdf-design.md`
- Create: `docs/superpowers/plans/2026-09-02-integrated-human-blueprint-pdf.md`
- Create: `tools/test_export_integrated_human_blueprint_pdf.py`

**Interfaces:**
- Consumes: historical PDF path and locked asset paths from the design.
- Produces: a failing test requiring `export_integrated_pdf(...)` and `COMPANION_PAGE_COUNT`.

- [x] **Step 1: Write the contract and failing test.**

```python
result = module.export_integrated_pdf(
    historical_pdf=historical_pdf,
    output=output,
    source_commit="0" * 40,
    generated_at="2026-09-02T00:00:00+09:00",
)
assert result.page_count >= 38
```

- [x] **Step 2: Run the test to verify it fails because the composer does not exist.**

Run: `python -m unittest tools/test_export_integrated_human_blueprint_pdf.py -v`

Expected: `FAIL` stating that `tools/export_integrated_human_blueprint_pdf.py` is absent.

### Task 2: Compose preservation-first integrated PDF

**Files:**
- Create: `tools/export_integrated_human_blueprint_pdf.py`
- Test: `tools/test_export_integrated_human_blueprint_pdf.py`

**Interfaces:**
- Consumes: `historical_pdf: Path`, `output: Path`, `source_commit: str`, `generated_at: str`.
- Produces: `ExportResult(page_count: int, output_sha256: str, historical_page_count: int, companion_page_count: int)`.

- [x] **Step 1: Implement the minimum `export_integrated_pdf` API.**

```python
def export_integrated_pdf(*, historical_pdf: Path, output: Path,
                          source_commit: str, generated_at: str) -> ExportResult:
    ...
```

- [x] **Step 2: Create 3 guide pages and 7 companion pages with ReportLab, then append original PDF pages with pypdf.**

```python
for page in guide_pages + companion_pages:
    draw_page(canvas, page)
for page in PdfReader(historical_pdf).pages:
    writer.add_page(page)
```

- [x] **Step 3: Run the focused test and confirm it passes.**

Run: `python -m unittest tools/test_export_integrated_human_blueprint_pdf.py -v`

Expected: `PASS`; output begins `%PDF-`, contains 38+ pages, preserves original 28-page text, and includes required integration copy.

### Task 3: Register the artifact and navigation

**Files:**
- Create: `docs/publication/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_PDF_MANIFEST.json`
- Modify: `docs/PDF_EXPORT.md`
- Modify: `docs/DOCUMENTATION_MAP.md`
- Modify: `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`
- Modify: `docs/ACTIVE_CONTEXT.md`
- Create: `exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf`

**Interfaces:**
- Consumes: exporter result, source hashes, locked asset provenance.
- Produces: one current-reader route with historical snapshot retained.

- [x] **Step 1: Generate the PDF after the source contract commit.**

Run: `python tools/export_integrated_human_blueprint_pdf.py --historical-pdf ... --output ... --source-commit <source-commit> --generated-at <timestamp>`

- [x] **Step 2: Record exact artifact/source/generator hashes and 10 asset bindings in the manifest.**

```json
{"role":"DOWNLOADABLE_INTEGRATED_HUMAN_REVIEW_DERIVATIVE","sync_status":"CURRENT_ON_BRANCH_PENDING_MAIN_PUBLICATION"}
```

- [x] **Step 3: Add new PDF to reader routes while preserving the historical 28-page snapshot route.**

### Task 4: Validate, review, and publish

**Files:**
- Create: `docs/reviews/2026-09-02-integrated-human-blueprint-pdf-adversarial-review.md`
- Modify: `docs/ACTIVE_CONTEXT.md`

**Interfaces:**
- Consumes: final artifact, source, manifest, page renders, current documentation routes.
- Produces: five whole-scope review loops and evidence ceiling.

- [x] **Step 1: Execute focused and existing PDF tests, static link/hash checks, `pdfinfo`, pypdf semantic checks, and `git diff --check`.**
- [x] **Step 2: Render all PDF pages with `pdftoppm`; visually inspect every new page and representative preserved pages.**
- [x] **Step 3: Record five full adversarial loops covering preservation, asset provenance, wireframe completeness, download route, evidence boundaries, and long-term regeneration.**
- [ ] **Step 4: Commit source, artifact, manifest, review, tests, and routes; push branch; create PR; verify exact-head CI; merge normally; fresh-read `main`.**
