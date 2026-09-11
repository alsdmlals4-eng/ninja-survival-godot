# Cheonsul breath candidate

Status: GENERATED_CANDIDATE / APPEARANCE_REVIEW_PENDING / ALIGNMENT_REQUIRED.
No asset approval or runtime binding. `.gdignore` prevents accidental import.
Consumer: CheonsulRuntime presentation for R-ULTIMATE. Existing vfx.png contains
individual motifs, not a continuous directional breath. Old flame-field texture
is a ground area and cannot communicate this attack.

One 2x2 sheet: begin, sustain A, sustain B, end (also dash-cancel).
Identical left-origin/right-facing pivots, equal cells, transparent RGBA,
blue-white flowing energy with restrained amber threads, painterly anime ink
edges. No character, ground, UI, symbols, checkerboard or radial explosion.
Gameplay owns fixed direction/moving origin, 1.5s duration and six damage ticks.
Art must not conceal enemy telegraphs. No extra element rules.

Aseprite is selected after alpha/cell/pivot inspection for equal-frame import,
timing and PNG+JSON export; not for creating art or automatic pixel conversion.
Existing composition and motif sheet were inspected as style references only.
Use built-in image model, not paid CLI fallback. Preserve source and provenance.
Final LOCK and runtime visual QA remain separate gates.

## Generation and inspection

Built-in image model, 2026-09-12. Original preserved:
`C:/Users/user/.codex/generated_images/01a04af3-2ac6-72b2-af89-ea12e783328f/exec-288d6fa6-d2dd-4d4d-a498-60867bb15138.png`.
Repository candidate: `breath-atlas-v1.png`.
SHA256: `d525b70f2fbdd78c5b8cae75bab581ac8e84ad28dcb20f056c49734a258a879d`.
Actual size1254x1254 (requested1024x1024);2x2 cells627x627.
Measured alpha:871483 zero,701033 partial,0 fully opaque pixels;
0 pixels alpha>32 on central row/column. No fake checkerboard observed.
Visual review: blue-white/amber flow fits the brief; emission pivots and extents
are not uniform. ALIGNMENT_REQUIRED before motion export; no raw four-cell
animation or proof of exact cone coverage. Enemy-telegraph readability NOT_RUN.

### Exact prompt

Use case: stylized-concept. Create one production-candidate game VFX sprite atlas for Cheonsul elemental breath in Ninja Survival, a dark moonlit painterly anime ninja survivor game. Genuinely transparent RGBA background, no checkerboard printed, no black/white opaque background. 1024x1024 square, exactly 2x2 equal 512x512 cells, no grid lines/text. Frames in reading order: small initial directional breath, full sustain A, full sustain B slightly changing internal curling flow but same silhouette, thin dissolving end/cancel wisps. Each cell uses identical emission pivot at local (64,256), directed horizontally right; energetic outward flowing cone approximately 60 degrees, extent no farther than local x448, all wisps within cell and 32px clear outer margin. Medium-density semi-transparent blue-white ink-brush elemental vapor braided with a few restrained amber fire streaks, crisp stylized readable edges, premium hand-painted 2D anime VFX, no 3D render or glossy plastic. Dynamic forward exhalation, not separate projectiles, not circular blast, not a ground magic circle, not dragons. Sustain A/B visually continuous at the pivot. Empty space between strands leaves underlying enemy attack warnings visible. In-game world effect intended length320; no characters, background, floor, UI, letters, runes or watermark. This is a single coherent 4-state family, not four different attacks.
