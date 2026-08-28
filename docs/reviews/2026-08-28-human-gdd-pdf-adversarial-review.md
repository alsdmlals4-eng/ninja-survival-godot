# Human Master GDD PDF · Adversarial Review

## Scope and inputs

- **Issue:** #120 — Human Master GDD PDF publication and review gate
- **Approved scope:** downloadable human GDD PDF; durable fresh-read/web research/feasibility/adversarial-review policy; no Godot gameplay, scene, data, asset, or runtime behavior change
- **Baseline `main`:** `ef3887f14b3317099d011dc8364d70468fe918bb`
- **Source-GDD commit:** `ef3887f14b3317099d011dc8364d70468fe918bb`
- **Open PR inventory:** draft PR #49 only; historical/superseded T12 reference; read-only and untouched
- **Notion:** `HISTORICAL_REFERENCE_ONLY`; no Notion read/write is applicable under DEC-035
- **External evidence:** [ReportLab fonts](https://docs.reportlab.com/reportlab/userguide/ch3_fonts/) and [tables](https://docs.reportlab.com/reportlab/userguide/ch7_tables/), read 2026-08-28

## Existing-solution and alternative study

| option | decision | player/project value | cost / risk / rollback |
| --- | --- | --- | --- |
| local ReportLab + installed Malgun Gothic + Poppler | `ADOPT` | Korean GDD can be generated, inspected, and versioned without leaving the repository | zero incremental cost; Windows font path is explicit; delete the derivative/manifest and retain the Markdown source to roll back |
| Pandoc/HTML or DOCX→PDF conversion | `REJECT` | potentially richer Markdown fidelity | unavailable in the current verified toolchain; adds an unverified renderer/dependency surface |
| browser/SaaS PDF conversion | `REJECT` | convenient visual layout tooling | additional credential/network/cost/privacy surface; conflicts with zero-incremental-cost default |

`BETTER_ALTERNATIVE_SEARCH`: no current alternative reduces total lifetime cost while preserving Korean glyph verification and deterministic local validation. `LONG_TERM_PLAN_FIT`: the Markdown source remains sole editable authority; the PDF and manifest are discardable derivatives.

## Incident / solution / lesson

| ID | class | validated issue | correction | lesson / Base promotion |
| --- | --- | --- | --- | --- |
| `INC-120-01` | `COMPLEMENT_GAP` | Markdown parser handled only HTTP links, so repository-relative links appeared as raw `[label](path)` text in the PDF | expand exporter link parsing; add real-output regression test | `NO_BASE_PROMOTION`: Base already owns derivative freshness; the parser/path is project-specific |
| `INC-120-02` | `MUST_FIX` | table-header Paragraphs retained dark body ink on a navy header band, failing human readability | add a dedicated white bold header style; add regression test | `NO_BASE_PROMOTION`: the exact visual grammar and exporter are project-specific |
| `INC-120-03` | `ALLOWED_LEGACY` | Poppler reported missing system-font alias mappings during render | retain a manifest note; all 15 actual PNG renders show no glyph loss or overlap | do not treat a local renderer warning as a PDF defect without visible/structural evidence |
| `INC-120-04` | `POST_MERGE_PROVENANCE_CONFLICT` | PR #121 was squash-merged, so its former branch commit was no longer an ancestor of the completed `main`; the PDF remained readable, but its source receipt no longer named the durable main ancestor | regenerate the derivative and manifest from completed `main` `ef3887f14b3317099d011dc8364d70468fe918bb`; retain only this follow-up as the current-task correction | a generated derivative's recorded source commit must remain an ancestor of post-merge `main`, not merely contain equivalent content |

## Full-scope adversarial loops

Every loop re-attacked the full approved scope: user intent, source ownership, current main/open PRs, Notion boundary, external evidence, toolchain/rights/cost, Markdown→PDF behavior, tests, artifact/manifest freshness, visual layout, evidence ceiling, rollback, and delivery path.

| loop | representative attack / validation / outcome | changes and regression evidence | clean candidate |
| --- | --- | --- | --- |
| 1 | Could a PDF become a second editable GDD or bypass the repository-only Notion decision? **Validated:** risk if source/artifact roles were not explicit. | Markdown remains source; `AGENTS.md`, router fields, README, map, and export contract mark PDF derivative-only; no Notion mutation. | no — PDF not yet tracked/generated |
| 2 | Could Korean text or source identity disappear in a generated file? **Validated:** a missing exporter had to fail first. | TDD red `FileNotFoundError`, then green real-output test for Korean title/content, valid PDF header, pages, and source SHA. | no — visual layout unverified |
| 3 | Could repository-relative links or header labels make the human PDF unreadable? **Validated:** raw Markdown links leaked into the PDF. | TDD red/green link regression test; local links render as labels; pypdf raw-link count is zero. | no — header contrast still unverified |
| 4 | Could table headers become unreadable or page flow hide clipping/blank pages? **Validated:** dark text on navy headers. | TDD red/green contrast regression test; 15/15 pages render at 144 dpi, no zero-byte/blank pages; all pages 1–15 visually inspected. | no — artifact/manifest/exact state not yet recorded |
| 5 | Could generated bytes go stale, overclaim Human/runtime evidence, collide with PR #49, or require costly tooling? **Validated:** all are guarded by manifest, evidence ceiling, read-only PR rule, and local stack. | manifest records source/generator/PDF SHA-256 and review classes; Issue #120 tracks scope; current open-PR check shows only untouched #49. | yes |
| 6 | Could squash merge leave the delivery receipt pointing to a non-durable branch commit? **Validated:** PR #121's source receipt had that provenance mismatch. | regenerate from completed `main`; require `git merge-base --is-ancestor <source-commit> HEAD` and re-run PDF contract/render checks before the narrow correction PR. | no — follow-up merge/readback pending |

## Exact validation evidence

- `python -m unittest tools/test_export_human_gdd_pdf.py -v`: `3/3` passed.
- `python -m py_compile tools/export_human_gdd_pdf.py tools/test_export_human_gdd_pdf.py`: passed.
- `pdfinfo`: file opens; title `닌자의 신 - Master GDD`; 15 landscape-A4 pages.
- pypdf contract: Korean title and source commit present; raw Markdown links `0`; blank pages `0`.
- `pdftoppm -png -r 144`: 15 PNG files, all `1684×1191`, zero zero-byte pages.
- Codex visual inspection: all rendered pages 1–15 inspected after the exporter update; post-merge source metadata is re-rendered and rechecked on the title/metadata page. Header/footer, Korean glyphs, tables, code, link labels, page flow, and whitespace are legible; no overlap/cropping finding remains.
- **Not run / not implied:** Human visual review, Godot runtime, Human Usability, Player Experience, device/export, release readiness, and `pdffonts` inventory (tool unavailable).

## Remaining-work recalculation

- Required source/artifact/manifest/test/render work for Issue #120: `0` only after this narrow provenance-correction PR receives exact-head validation, safe merge, and completed-`main` readback.
- Future requirement: any Master GDD or exporter change must regenerate this PDF and manifest under `ALWAYS_SYNC_ON_MASTER_GDD_OR_EXPORTER_CHANGE`.
- `CLEAN_REVIEW_EXIT`: candidate only until the exact current-task PR is merged and new `main` is read back.
