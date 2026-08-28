# Human Player GDD PDF · Adversarial Review

## Scope and inputs

- **Issue:** #123 — player-facing human GDD PDF
- **Approved scope:** a Korean reader-facing GDD and downloadable PDF that explains the game, choices, and current Godot implementation in plain language; no gameplay/runtime/asset/balance change
- **Completed-main Human-GDD source:** `f96d3a7fb269d3c4c45533addbee22355a59d154`
- **Technical authority:** `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`, approved canon, decision ledger, and actual code/data/Scene/test evidence
- **Open PR inventory before this publication:** draft PR #49 only; historical/superseded and untouched
- **External evidence:** [Godot Nodes and Scenes](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html), [Godot Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html), [ReportLab fonts](https://docs.reportlab.com/reportlab/userguide/ch3_fonts/), and [ReportLab tables](https://docs.reportlab.com/reportlab/userguide/ch7_tables/), read 2026-08-28

## Existing-solution and alternative study

| option | decision | human value | cost / risk / rollback |
| --- | --- | --- | --- |
| Retitle the technical Master GDD PDF | `REJECT` | preserves every detail | source registry, SHA, conflicts, test ceilings, and implementation receipts still obstruct a first read |
| Separate Human GDD source + existing local exporter | `ADOPT` | clear player story, choices, implementation overview, and truthful status in one short document | no new dependency; technical Master GDD stays authoritative; delete the derivative and retain both Markdown sources to roll back |
| Presentation-only lore/visual booklet | `REJECT` | emotionally appealing overview | fails the approved requirement to explain core systems and how the game is built |

**Feasibility disposition:** `ADOPT`. Godot's model supports a reader explanation that distinguishes scene/node behavior from data resources, and the local ReportLab/embedded-Korean-font pipeline can render the document without paid services. The document describes this project's observed architecture; it does not claim a generic engine implementation template.

## Incident / solution / lesson

| ID | class | validated issue | correction | lesson / Base promotion |
| --- | --- | --- | --- | --- |
| `INC-123-01` | `AUDIENCE_CONFLICT` | the earlier download was a technical Master GDD and exposed implementation-contract detail to a human reader | create a separate Human GDD source; preserve the technical Master GDD as the implementation/canon owner | `NO_BASE_PROMOTION`: human/technical split names and content are project-specific |
| `INC-123-02` | `READABILITY_DEFECT` | the first reader preview ended with a mostly empty fifth page containing only a closing paragraph | integrate the closing message into the current-status section; re-render as a compact four-page guide | `NO_BASE_PROMOTION`: this was a one-document content-flow correction |
| `INC-123-03` | `MUST_FIX` | Korean text inside inline code spans used Courier and rendered as missing glyphs | choose the embedded Korean font for non-ASCII inline code; add a real-output red/green regression test | `NO_BASE_PROMOTION`: the fix belongs to this project-owned ReportLab exporter; promote only if Base adopts a shared multilingual exporter |

## Full-scope adversarial loops

Every loop re-attacks the approved reader experience, technical truth, source ownership, actual implementation evidence, Korean rendering, layout, links, cost/rights, provenance, and evidence ceiling.

| loop | attack / validation | result | disposition |
| --- | --- | --- | --- |
| 1 | Could a player-facing document become a renamed technical ledger? | Validated risk in the existing PDF. New source omits SHA, PR, CI, conflict IDs, and internal paths while retaining the implementation explanation. | corrected |
| 2 | Could the explanation invent Godot behavior or hide current gaps? | Cross-read Main scene, combat, route, encounter, Workbench, and source GDD. Each reader status is labelled current implementation, foundation, next production, or later scope. | corrected |
| 3 | Could a short document be visually wasteful or harder to scan than the old one? | Render inspection found the closing page was mostly empty. The closing was folded into the status page; four-page preview is visually compact. | corrected |
| 4 | Could Korean labels disappear in an apparently successful PDF? | Visual review found missing glyphs for inline Korean code; a focused test first failed, then passed after the font fallback correction. | corrected |
| 5 | Could the human link, PDF, manifest, or source receipt remain stale after the replacement? | Exact-head checks confirm all public routes name only the new Human GDD/PDF; SHA-256 values match; `f96d3a7…` is a completed-main ancestor; all four final pages render. | corrected; post-merge readback pending |

## Exact validation evidence

- bundled-Python exporter tests: `5/5` passed, including reader identity and Korean inline-code glyph regression tests
- `py_compile`: exporter and test module passed
- pypdf contract: 4 pages; player-facing title; eight required reader sections; Korean `닌자소울`; no raw Markdown, missing-glyph squares, or blank page
- `pdfinfo`: the final PDF opens as landscape A4 with the player-facing title
- `pdftoppm -png -r 144`: 4/4 non-empty PNGs; all 4 pages visually inspected after the final export
- `git diff --check`: passed; public-route scan found no prior Master-PDF filename or manifest reference outside historical/review material
- **Not run / not implied:** Human review, Godot runtime, Human Usability, Player Experience, device/export, and release readiness

## Remaining-work recalculation

- Reader-source, public-route, PDF, manifest, test, render, and adversarial-review work: `0` after this publication PR receives exact-head checks, safe squash merge, and completed-main readback.
- The next Human GDD or exporter change must re-run this publication contract. A technical-canon change requires a Human-GDD meaning check before any re-export.

## Evidence boundary

This review and its PDF checks do not prove a playable full Run, Human Usability, Player Experience, touch/gamepad/device/export quality, or release readiness. The reader document must retain that distinction.
