# Blueprint candidate production receipt — 2026-09-11

Scope: new planning/approval candidates only. `.gdignore` prevents accidental
Godot import/export before asset LOCK. No existing game asset was replaced.

- 14 PNG families: player; four school enemy atlases (3 core + elite + boss
  per school); final boss; 12 ninjutsu icons; 16 VFX motifs; 29 equipment/UI
  icons plus one empty cell; floor; three props; title background; wordmark
  and medal; target combat composition.
- The combat composition is a target illustration, not a separable runtime
  texture or actual screenshot. Other families are intended game candidates.
- All required alpha checks passed. Adaptive region boundaries contain no
  pixels with alpha >32. This threshold is not proof of zero faint fringes,
  grounded feet, natural motion or readability at gameplay scale.
- New spaced generations replaced dense/crossing sheets. Reference-based
  editing repeatedly baked the displayed checkerboard into RGB; those outputs
  are not copied here. Fresh transparent generations solved the alpha issue.
  Tool-source originals remain unchanged outside the repository.
- `manifest.json` owns current source hashes, frame regions, actual intended
  consumer paths, logical IDs and PENDING approval. `provenance.json` stores
  prompts and source locations; no other game's art was copied.
- `motion/player-motion.aseprite` has 12 real frames. Timed PNG/JSON export
  has been compared with the source: all alpha and visible pixels match for
  every frame. Aseprite 1.3.18.5-dev through restricted candidate operations.
  Packed export is 1454×1090, replacing a 4366-wide rows export. JSON line
  endings alone were normalized to LF for portable hashing; raster pixels
  are unchanged. No tool binary or shared deployment was modified.
  `motion/contract.json` binds hashes and proposed state clips, including
  the four enemy families. It is not a Godot runtime or animation UX pass.
- Enemy state rows are not six running frames: idle, two walking contacts,
  preparation, release, death. Recovery uses idle; hit is an existing tint
  overlay and must not interrupt pattern clocks. Final boss uses the same
  six-state interpretation. Actual foot pivots and in-between frames remain
  implementation visual-QA work after LOCK.
- Floor repetition, camera-scale grounding, sound readiness, live motion,
  gameplay performance, device and Human UX are NOT_RUN. Do not promote
  these candidates to ASSET_READY/IMPLEMENTED merely because the PDF exists.

Reproduce inspection with `tools/inspect_blueprint_assets.py`, pixel comparison
with `tools/verify_blueprint_motion.py`, and regression with
`python -m unittest discover -s tools -p test_blueprint_preparation.py`.
The producer environment provides Pillow, numpy, ReportLab, pypdf and pdfplumber.
No Aseprite binary or paid service is distributed with this packet.
