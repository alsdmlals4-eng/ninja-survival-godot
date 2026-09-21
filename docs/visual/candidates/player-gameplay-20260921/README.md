# Player gameplay camera revision — NS-PLAYER-APPEARANCE-02

State: APPEARANCE_REVIEW_ONLY / TECHNICAL_REVISION_REQUIRED / USER_LOCK_PENDING.
Not a runtime replacement. One appearance candidate with background-processing steps.
Consumer after approval: scenes/player/player.tscn / PlayerVisualController;
48–64px visible body height in the actual moonlit floor scene. Current approved
textures remain unchanged. This does not complete idle/move/dash/hit/death motion.

Reason: the Sep11 candidate still has halo/camera issues; actual Sep21 Main render
729423 shows a tiny low-contrast figure. Preserve the supplied handsome anime ninja
identity but use a genuinely elevated gameplay camera and simpler broad shading.
No attack pose: katana/shuriken remain separate automatic weapon effects.

Input: docs/assets/approved/player-base-original/ninja_player_base_original.png,
the user's costume/identity reference, viewed before generation. Target: one idle
full-body candidate, four-head anime SD proportion, 35–40 degree elevated camera,
three-quarter facing screen-right, compact navy scarf, black ponytail, red cords,
warm gold armor trim. Orthographic; grounded feet; fully contained with12% padding.
Broad moonlit planes, clear face and silhouette; no aura, halo, shadow, environment,
text, UI, sheet, extra character or drawn sword. Uniform solid magenta #FF00FF
chroma background; no magenta in the character. Subsequent background extraction
must preserve identity/camera/pose and deliver actual alpha, not a checkerboard.

Tool route: built-in image_gen, no paid API/CLI or installation. Source and cutout
are retained separately. Read-only dimension/alpha inspection and visual review
follow. Output success is not final art approval, animation, Aseprite export or
runtime evidence. Production motion and binding remain dependent on visual LOCK.

## Outputs and inspection

Built-in image_gen only; three operations on the same candidate, not three designs.
All1254x1254. Original user reference SHA256:
EA5F851F2E051A991F095F18D480E1E480D9495D4C4D3A9CB6D026B1A20D9316.

| Local file | Generated original basename | SHA256 |
|---|---|---|
| initial-direct-alpha.png | exec-52ab4e00-6a01-4d42-b5e9-79b0473a3ba7.png | 6c1c00e602431a8dcb12d03741924a7ac3494fd04adbac04c9f7c8e830524ef2 |
| chroma-source.png | exec-088d8d49-f86b-4cbb-8007-45d65f0f1281.png | 13ca587e4c77c51d62a13c3144691ba57b67a91af84aed138ff5ac27c747e0dc |
| player-cutout.png | exec-b3ba5a25-dbf0-4530-8044-80121d8d70c3.png | ba7111801f52eccb10a3a8e1f9adc71a5bf4cd628c116c8bad09887884b02935 |

Originals remain in C:/Users/user/.codex/generated_images/01a04af3-2ac6-72b2-af89-ea12e783328f/.
The first operation incorrectly returned direct alpha despite the requested key.
The second creates a magenta RGB source; corners237,13,240 and239,29,239 show that
it is not mathematically uniform #FF00FF. Third performs image-tool extraction.
The extraction also alters shading slightly; do not describe it as pixel-identical.

Read-only alpha inspection:1,209,130 fully transparent pixels;363,386 nonzero.
Alpha>=16 bbox293,64..957,1195; nonzero bbox39,21..1199,1221 indicates faint stray
alpha outside the intended figure.5 visible magenta-threshold pixels. This is
not a fully cleaned production cutout. Source is retained; no procedural repaint.
Godot isolated light/dark preview at280/96/64 canvas pixels executed exit0 and
was visually inspected. At small sizes thin detail aliases and facial detail is
lost. preview.png is a test render, not actual Main integration or asset approval.
Required next: alpha-fringe/padding cleanup, small-size filtering/readability,
user appearance decision, then genuine state family/motion/pivot preparation.
Aseprite local usage was inspected: deployed tools do not offer chroma cleanup;
no arbitrary CLI/Lua, new bridge, installation or fake animation was attempted.

## Exact prompts

1. Use case: identity-preserve. Edit the supplied user's ninja character into ONE production gameplay sprite appearance candidate, not a poster. Preserve his handsome anime face, reddish-brown eyes, angular black bangs and high black ponytail, black/navy ninja costume, compact navy scarf, red braided waist/ankle cords and restrained warm gold shoulder/wrist armor trim. Change the camera to a clearly elevated 35–40 degree orthographic top-down game view, three-quarter facing screen-right: visible top of head and shoulders, foreshortened legs, but readable face. Four-head-tall refined anime SD proportions, not tall adult, not baby chibi. Whole character in a neutral ready standing pose with grounded feet and hands relaxed; sword SHEATHED, no attack motion. Simplify microscopic trim into broad beautiful crisp cel-painterly planes so the character remains readable at 48–64 pixels height. Cool moonlight highlights ON the costume, not an external luminous halo. Single character centered in a square frame with at least12% empty padding around hair/scarf/sheath/feet. Background must be one perfectly flat solid chromakey MAGENTA #FF00FF for later removal; no magenta in the subject, no colored spill, no gradients. No ground, no contact shadow, no aura, no smoke, no glow, no text, no UI, no frame, no multiple views. This is one game-ready camera/style candidate, retaining the provided identity and costume.

2. Precise background-only edit, same single candidate: preserve this exact ninja identity, pose, camera, size, hair, costume, face and painted detail. Replace the transparent/black surrounding area with an OPAQUE uniform solid bright magenta RGB255,0,255 chroma-key studio background. The entire canvas outside the figure must be solid magenta, including between limbs and hair gaps. This intermediate image MUST NOT have transparency or black backdrop. No magenta reflections or rim spill onto the character; no shadow, no ground, no gradient, no checkerboard. Do not restyle or redraw the character. This opaque magenta intermediate is explicitly required by the user's chroma-key pipeline before a later separate extraction step.

3. Use case: background-extraction. Extract this EXACT single ninja character from its solid magenta chromakey background onto genuine transparent RGBA. Remove only the magenta background, including enclosed gaps. Keep the same exact character identity, pose, face, costume, hair silhouette, camera angle, scale, framing and all subject colors. Do not repaint, add highlights, shadows or an aura. Clean anti-aliased edges without pink fringe, opaque checkerboard, white halo or background color. All background pixels alpha zero. Preserve the original full-body framing and original canvas dimensions. This is the final background removal step of the same one candidate, not a new design.
