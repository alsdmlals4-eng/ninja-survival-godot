# Player idle and runtime image connection receipt — 2026-09-21

State: RUNTIME_REVIEW_REQUESTED_NOT_FINAL_LOCK. User requested missing images,
idle motion and school actors connected to actual play; final appearance approval
and human experience remain separate. No prior approved raster was overwritten.

## New idle asset
- Source: chroma-source.png (opaque green intermediate).
- Runtime: assets/runtime/visual-core/player-idle-v1.png (1254×1254 RGBA).
- Consumer: scenes/player/player.tscn -> PlayerVisualController IDLE.
- Standing still uses this pose and a2.4s procedural breathing cycle; movement
  restores the original MOVE texture and damage uses the original HIT texture.
  This is one pose plus procedural motion, not a complete multi-frame idle/walk set.
- Aseprite inspected the candidate copy:1254×1254 RGB/RGBA, one frame100ms,
  one layer, no animation tags. No invented motion export.
- Image generator first returned transparency despite requesting green. A second
  real image edit created the visible green intermediate; a third removed it.
  The extraction redrew some details/position: do not claim pixel-identical masking.
- Tool originals remain in the task generated_images folder, filenames:
  exec-9811c84c-aa6e-4c87-bb39-8cd7549be9df.png (initial);
  exec-c8790ba5-3ea1-4b5c-a59e-a7e43eef80fc.png (green);
  exec-9e955137-cf7e-4a45-81e0-90bd14b601ae.png (alpha).
- SHA256 green:5ECA975B333CDC625F72E52E78EC58219C6E19914B885DF4AE5956BB4C051771
- SHA256 runtime:C6809E585DEB9A8E635B1051623C9D396C7EFCB615CBA846D29160C35B808B2D
- Reproducible player import mipmaps and linear mip filtering reduce48-64px
  minification shimmer; moving/hit original PNG hashes are unchanged.

## Reused assets, not newly generated
Sept11 enemy candidates and provenance remain in ../blueprint-20260911.
Copied unchanged into assets/runtime/encounters/sheets; row229×229, five actors,
columns idle / walk contactA / walk contactB / prepare / release / death.
SchoolActorMotion binds18 missing actors; original dedicated Bongma Elite and
Boss take precedence. Death frame is not connected; no damage/pattern changes.
Bongma:DA5ECDD45A12F62C8829A3568E24336500311D6525E9DB7BE5A5D29AB30BE1C3
Cheonsul:CEAF4A9BD5B5CEAF551B6605E1FB8858FEF4DF679D670497A73B78F6B2A94710
Guiin:7AA8369B84A965D9223B0B685978D18D81F37885BC62EE5A5783C4FB80BFDCCC
Heukyeong:6F34BA8353DDAE2F4178A2CEFE36E998AD69E0BEFD83A5D4B32CB8713886E7D7

Inventory source ../inventory-icons-20260921/atlas-cutout.png copied unchanged
to assets/runtime/ui/inventory-icons-v1.png, Main.inventory_icon_atlas.
SHA256:C2D51FFF848148484F7F628D3436C61F25A629C117E4653342B24DDDEE246D8D.
Three base equipment + four shared school book covers + bag offer/pending controls.
Not24 distinct ninjutsu icons and not all nine equipment variants.
Prior candidate-only readmes describe creation-time status; this receipt records
only the user's later explicit runtime connection request.

## Exact generation prompts

### Standing derivative

Use case: identity-preserve. Game asset: standing idle pose derivative of the supplied existing runtime ninja. Input image is the exact identity/style reference. Preserve his handsome youthful anime face, huge black tied ponytail, navy scarf, black and gold ninja outfit, red ropes, sheathed Japanese sword, compact roughly four-heads-tall proportions and crisp painted outlines. Change only pose: full body standing alert with both feet planted, relaxed closed hands by sides, looking to screen right in three-quarter view at the same slightly elevated gameplay camera. Absolutely no running, attack, dust, scenery, letters, UI, floor or cast shadow. Entire character including hair, scarf and feet inside the middle 75% of square canvas with ample empty margins. This will be the idle state next to the exact current run/hit textures at 64px gameplay size, so simplify tiny filigree and keep strong silhouette. Background must be perfectly flat chroma green #00FF00 edge-to-edge, no gradients or green reflected light, no green within character. Single character, single pose, square asset.

### Chroma intermediate

Edit target: the supplied standing ninja image. Change ONLY the empty/transparent background to one completely opaque, perfectly uniform pure green chroma key RGB(0,255,0), hexadecimal #00FF00. The output must visibly have a solid bright green background, NOT a transparent/black/checkerboard background. Preserve every character pixel, shape, facial expression, pose, clothing, position, scale and full canvas dimensions. No new objects, no lighting changes, no shadow, no crop. This chroma-key intermediate is explicitly required by the user before a separate background-removal step.

### Background extraction

Use case: background-extraction. Edit target is the supplied ninja on solid green. Remove ONLY the green chroma background into genuine zero-alpha transparency. Preserve the exact full canvas, full character pose, proportions, feet, all clothing and face colors, crisp silhouette and placement. Do not redesign or add any detail. Clean green spill at edges without erasing navy cloth or dark hair. Fully opaque character interior, transparent empty area, no shadow, no glow, no checkerboard painted into pixels. Output PNG with real alpha.
