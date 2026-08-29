# Human Game Blueprint Revision Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish a visually structured 28-page Korean human game-experience blueprint that makes the controlled ninja, 3×3 backpack growth, and Stage/Phase vocabulary unmistakable without claiming unbuilt runtime behavior.

**Architecture:** `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md` is the page-by-page human source. The exporter recognizes explicit page markers and renders the source as a landscape-A4 visual blueprint using only repository-approved player and screen-reference images; generic Markdown export remains supported for its existing tests. The adjacent specification owns implementation boundary and later runtime acceptance.

**Tech Stack:** Markdown, Python 3, ReportLab, pypdf, Poppler.

**Spec:** `docs/implementation/2026-08-30-player-control-stage-backpack-blueprint-spec.md`

## Global Constraints

- Human-facing text uses `스테이지` and `페이즈`; legacy `school` names stay internal until a separately approved runtime migration.
- The opening usable backpack is exactly `3×3`; `6×6` is the technical expansion ceiling, not the apparent starting board.
- The PDF uses existing approved/repository screen references only; new image generation is out of scope.
- PDF/export verification cannot claim Godot runtime, Human Usability, Player Experience, device/export, or release evidence.
- The user must final-review the PDF before runtime implementation begins.

---

### Task 1: Lock the paired source and review-page contract

**Files:**
- Create: `docs/implementation/2026-08-30-player-control-stage-backpack-blueprint-spec.md`
- Modify: `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md`
- Test: `tools/test_export_human_gdd_pdf.py`

**Interfaces:**
- Consumes: the approved 2026-08-30 user decisions and current project screen/asset sources.
- Produces: exactly 28 ordered `<!-- BLUEPRINT_PAGE: NN / 28 -->` source sections.

- [ ] **Step 1: Write the failing test**

```python
page_markers = re.findall(r"<!-- BLUEPRINT_PAGE: (\\d{2}) / 28 -->", source)
self.assertEqual(page_markers, [f"{index:02d}" for index in range(1, 29)])
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m unittest tools/test_export_human_gdd_pdf.py -v`
Expected: FAIL because the older short GDD has no explicit 28-page review contract.

- [ ] **Step 3: Write minimal implementation**

```markdown
<!-- BLUEPRINT_PAGE: 03 / 28 -->
# 당신은 한 명의 닌자를 움직인다
> **검수 질문** · 전투에서 내가 직접 바꾸는 것이 무엇인지 보이는가?
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m unittest tools/test_export_human_gdd_pdf.py -v`
Expected: source-page assertion passes; the PDF-page assertion remains red until Task 2.

### Task 2: Render explicit blueprint pages without breaking generic export

**Files:**
- Modify: `tools/export_human_gdd_pdf.py`
- Test: `tools/test_export_human_gdd_pdf.py`

**Interfaces:**
- Consumes: ordered blueprint marker source and relative Markdown image paths.
- Produces: `export_pdf(...)` renders 28 numbered landscape-A4 pages for a blueprint source; ordinary Markdown keeps the legacy flowable route.

- [ ] **Step 1: Write the failing test**

```python
self.assertEqual(len(reader.pages), 28)
self.assertIn("01 / 28", rendered_text)
self.assertIn("28 / 28", rendered_text)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `python -m unittest tools/test_export_human_gdd_pdf.py -v`
Expected: FAIL with the existing four-page export.

- [ ] **Step 3: Write minimal implementation**

```python
if "<!-- BLUEPRINT_PAGE:" in source.read_text(encoding="utf-8"):
    export_blueprint_pdf(...)
else:
    export_markdown_pdf(...)
```

- [ ] **Step 4: Run test to verify it passes**

Run: `python -m unittest tools/test_export_human_gdd_pdf.py -v`
Expected: all exporter tests pass.

### Task 3: Publish and synchronize the reader artifact

**Files:**
- Modify: `README.md`, `docs/DOCUMENTATION_MAP.md`, `docs/PDF_EXPORT.md`, `docs/ACTIVE_CONTEXT.md`, `docs/CURRENT_CONFIRMED_DECISIONS.md`
- Modify: `docs/publication/NINJA_SURVIVAL_HUMAN_GDD_PDF_MANIFEST.json`
- Create: `exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf`

**Interfaces:**
- Consumes: the exact source/generator/PDF SHA-256 values and render evidence.
- Produces: one current publication pointer for the new blueprint; the 20260828 snapshot remains historical.

- [ ] **Step 1: Generate the PDF from the paired Markdown source**

```powershell
python tools\export_human_gdd_pdf.py --source docs\design\NINJA_SURVIVAL_HUMAN_GDD.md --output exports\NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf --source-branch codex/human-game-blueprint-revision-132 --source-commit <current-head> --generated-at <KST-timestamp>
```

- [ ] **Step 2: Verify structure and rendering**

```powershell
pdfinfo exports\NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf
pdftoppm -png -r 144 exports\NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf <render-prefix>
```

- [ ] **Step 3: Record evidence without overclaiming runtime verification**

```json
"human_visual_review": "NOT_RUN",
"evidence_ceiling": "Publication checks do not prove Godot runtime or Player Experience."
```

### Task 4: Whole-scope adversarial review and source readback

**Files:**
- Create: `docs/reviews/2026-08-30-human-game-blueprint-adversarial-review.md`
- Test: `tools/test_export_human_gdd_pdf.py`

**Interfaces:**
- Consumes: rendered pages, manifest evidence, and the approved specification.
- Produces: five full review loops with validated findings, correction status, and `NOT_RUN` evidence boundary.

- [ ] **Step 1: Reattack the full scope five times**

```text
player-control clarity -> 3x3 growth truth -> Stage/Phase consistency -> page/scene continuity -> publication/evidence boundary
```

- [ ] **Step 2: Re-run source, PDF, and renderer checks after corrections**

Run: `python -m unittest tools/test_export_human_gdd_pdf.py -v`; `pdfinfo`; `pypdf`; full-page PNG rendering.
Expected: each check has fresh recorded output; no claim is derived from a prior run.

- [ ] **Step 3: Recalculate remaining work**

```text
Current scope: human blueprint/source/publication = complete candidate only when all five review loops are clean.
Next authority: user final PDF review before runtime migration.
```
