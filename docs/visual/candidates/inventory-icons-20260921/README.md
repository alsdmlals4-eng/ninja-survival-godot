# Inventory atlas candidate · 2026-09-21

Latest follow-up: the user requested actual image connection. The unchanged
cutout is now assets/runtime/ui/inventory-icons-v1.png and assigned by Main;
bag offer/pending controls are connected too. Runtime trial is authorized,
final visual LOCK remains pending. Receipt: ../player-idle-20260921/README.md.
The creation-time statements below describe the earlier candidate-only checkpoint.

State: CANDIDATE / USER_LOCK_PENDING. One appearance atlas, one background
extraction. Not eight approved assets, not24 individually painted ninjutsu icons.
No production scene resource assignment. Explicit QA preview injection only.
Consumer prepared: Main.inventory_icon_atlas → StartLoadoutUI (gear/draft/books in bag cells),
RestFlowUI (board/buffer), SelectedRestScreen (book/equipment/forge offers).
Each of24 ninjutsu uses its school's shared cover plus real name/effect data;
base katana/shuriken/ninja_suit have dedicated icons. Other six weapon designs
are not covered and must not silently reuse an incorrect weapon silhouette.
The eighth bag drawing is atlas preparation only; no bag-purchase button consumes
it yet. Independent review confirmed this limit and no new P0/P1/P2 mapping/save
finding. Runtime preview766371 shows draft/gear/board consumers, not production LOCK.

## Source and extraction

Built-in image_gen, no external API. Generated files retained at
`C:/Users/user/.codex/generated_images/01a04af3-2ac6-72b2-af89-ea12e783328f/`.
- `exec-ac6b7a74-b2ea-45dc-bca9-f311391265b8.png` → chroma-source.png;
  SHA256 `6decaf09dba3ec1a3dceef9bfc5c3d23edf4827e2330d377270043e814f793f3`.
- `exec-8b7fb484-14ae-4bf0-b54b-7cbc137e408c.png` → atlas-cutout.png;
  SHA256 `c2d51fff848148484f7f628d3436c61f25a629c117e4653342b24dddee246d8d`.

RGBA1254×1254;1,043,908 fully transparent pixels;2,673 alpha255 pixels,388,843
alpha253 pixels,48,461 alpha254 pixels. No opaque green pixels under the measured
g>150, g>1.5r, g>1.5b threshold. Corners transparent. Many near-opaque interiors
and faint edge alpha remain; background extraction slightly changed line/detail,
so pixel-identical extraction is NOT claimed. No programmatic image editing.
Restricted Aseprite metadata read on a staged copy:1254×1254 RGB(A),1 frame100ms,
one layer, no tags. Static icons do not need fabricated animation frames.
Candidate root: C:/Users/user/.local/share/aseprite-local/candidates/ninja-inventory-20260921.
Source rectangles are runtime AtlasTexture metadata, not destructive crops.

## Exact generation prompt

Use case: stylized-concept. Asset type: one production inventory atlas candidate for Korean dark moonlit ninja fantasy Godot game, painterly anime hand-painted item icons. Create a square image containing a STRICT 4 columns x 2 rows grid of EIGHT isolated inventory objects, equal invisible cells with generous empty margins, no grid lines, no text, no labels, no frame, no UI. EVERY background pixel must be flat uniform opaque chroma key vivid green #00FF00, no gradients, no shadows, no transparency yet. Item objects must contain no green hues. Row1 left to right: Japanese katana black scabbard red cord warm antique-gold fittings; four-point steel shuriken; folded black navy ninja outfit with red belt gold trim; small dark leather backpack. Row2 left to right: bound dark-blue spellbook with gold paper-talisman seal emblem for summoning/barriers; deep-blue spellbook with blue/orange spiral elemental emblem; dark-red spellbook with horned crimson oni mask emblem; black violet spellbook with silver eye and dagger emblem. Consistent camera and lighting, chunky readable silhouettes, restrained materials, premium brush-painted anime, black deep navy red warm gold palette. Each object fully within its own cell and centered. Each icon must remain identifiable at 48px. Avoid ornate tiny details, human figures, dramatic bloom, green item details, glows crossing cell boundaries. This is a single unified atlas, not a screenshot or infographic.

## Exact extraction prompt

Use case: background-extraction. Edit target: the supplied inventory atlas. Remove only the green chroma-key background everywhere, including shuriken central hole and gaps, output genuine transparent RGBA alpha. Preserve exactly all eight existing objects, appearance, size, order, placement, whole1254x1254 canvas and 4x2 cell organization. Do not redraw, relight or stylize. Remove green edge fringe. No checkerboard pattern, no colored replacement background, no shadow or extra pixels. Keep opaque object interiors. This is extraction not a new design.

## Research disposition

[Backpack Battles official store](https://store.steampowered.com/app/2427700/Backpack_Battles/):
ADAPT inventory image identity combined with information; no copied art/layout.
[Godot Control](https://docs.godotengine.org/en/stable/classes/class_control.html):
ADOPT native tooltip hit testing. Static source atlas plus explicit metadata is
selected over per-widget copied images or dynamically generated icons, preserving
single source/provenance and names/effects as separate presentation data.
