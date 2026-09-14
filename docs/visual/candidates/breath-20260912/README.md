# Cheonsul breath candidate

Status: USER_APPEARANCE_APPROVED / ALIGNED / BRANCH_IMPLEMENTED / FIXTURE_RENDERED.
The latest user accepted the displayed blue-white/gold direction and continued.
`.gdignore` excludes retained production sources from game import. Runtime binding
is `assets/runtime/visual-core/cheonsul_breath_v1.png`; asset registration is owned
by `docs/assets/approved/img-02-runtime-visual-core/RUNTIME_VISUAL_CORE_MANIFEST.md`.
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

### Mechanical registration and runtime readback, 2026-09-12

Restricted Aseprite1.3.18.5-dev imported each627px cell into a separate canvas,
then translated copies onto700px cells: (10,15),(37,15),(10,16),(37,16).
Nominal common emission pivot64,350; artwork itself was not redrawn/resized.
`breath-motion-v1.aseprite` and raw `breath-motion-v1.json` preserve editable
frames and100/125/125/150ms state hints. Game logic owns actual1.5s duration,
begin100ms, alternating sustain125ms, final150ms fading; cancellation hides
immediately rather than displaying a damaging-looking lingering cast.
Runtime export2800x700 SHA256:
`b151f40c0def23e2719ba7cc5e9d3a797f618704899d2691cecba10b901a9199`.
At320/600 scale with65% alpha the effect follows the player without changing
the cast direction. Capture: `docs/reviews/breath-runtime-20260912.png`.
This is fixture-render evidence, not full-run/input/Human/device acceptance.

Validated tooling failure: adding a frame after importing copied the previous
cel, and import drawImage composited new art over it. Rejected first export.
Fix: create all blank frames first, then import each cell; inspect all four
outputs (especially end) before promotion. Failed local output goes to manual
deletion review, never shipped. Raw source hash remains unchanged.

### Original candidate inspection (historical)

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
