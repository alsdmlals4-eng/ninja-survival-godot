# Player appearance refinement — candidate review

2026-09-11 · requirement NS-PLAYER-APPEARANCE-02.
State: APPEARANCE_REVIEW_ONLY / TECHNICAL_REVISION_REQUIRED / USER_LOCK_PENDING.
No runtime binding, canonical promotion or motion completion. `.gdignore` blocks
accidental Godot import. Existing player atlas and historical approved files stay unchanged.

Consumer intent: `scenes/player/player.tscn` / PlayerVisualController idle/move/hit
replacement family after approval and motion preparation, plus starting-school
selection portrait. Current delivered texture is only an appearance review source;
the camera/pivot/scale and missing movement states are not runtime-ready.

Reference: user-provided
`C:/Users/user/Desktop/비교샷/닌자/KakaoTalk_20260826_193205188_12.png`.
Transfer: handsome anime face, large eyes, black ponytail, navy scarf, gold-edged
armor and red cords, approximately four-head SD body. Avoid: plain realistic body,
attack animations on the body, aura baked into sprites, giant cape, changing the
one-character identity between schools. Third-party game art not used as image input.
User-provided reference use is authorized for this task; independent release-rights
clearance is NOT_RUN, not automatically proved by generation.

Generator: built-in image_gen. No CLI API, paid dependency or programmatic pixel edit.
Generated source folder:
`C:/Users/user/.codex/generated_images/01a04af3-2ac6-72b2-af89-ea12e783328f/`.

1. `exec-f033fe56-6e77-496c-8fe7-2466ee3e7b6c.png`: copied unchanged as
   `player-appearance-review.png`. 1024×1536 RGBA; alpha extrema 0..254.
   SHA-256: `97ccf3878858ef583ef92d45eaaef33283348282cbec041db54120fd074be033`.
   Face/costume are materially closer to supplied reference. Rejected as final
   sprite because colored translucent halo extends outside the physical figure,
   margin is short and camera is closer to a portrait than overhead gameplay.
2. `exec-74fcf048-6928-4eb0-b4aa-1417c47b2d3e.png`: cleanup edit, RGB with visible
   checkerboard baked into pixels; TECHNICAL_REJECT. Not copied to project.
3. `exec-972fb2f5-7783-4cb1-ae25-328149fb6d9d.png`: fresh transparent retry from
   text. Visual inspection finds mature/taller proportions and halo, inconsistent
   with the reference direction. REJECTED_RETRY, not selected or copied.

The two retries correct the same deliverable; they are not independent approved
character variants. Do not use a file extension or presence of an alpha channel
as proof that the background is a clean cutout. Read-only Pillow inspected modes,
dimensions and extrema; no pixel/alpha rewriting was performed.

## Generation prompt (selected appearance source)

Use case: stylized-concept. Generate ONE polished transparent-background full-body game character asset candidate for the user's own dark ninja survivor game, closely following the supplied character reference as the appearance and costume anchor. The reference is not a background. The hero should look handsome, charismatic, premium anime, with crisp large reddish-brown almond eyes, sharp clean eyebrows, appealing face, voluminous angular black bangs and a high sweeping black ponytail. Approximately FOUR heads tall, refined anime SD proportions as in reference, NOT realistic adult proportions, NOT tiny baby chibi. Black and deep navy ninja robes; restrained warm gold trims and one distinctive gold-edged shoulder guard, gold-edged black wrist guards; dark navy scarf with compact trailing ends; red braided waist cord and small red ankle ties. Rich but readable layered clothing, reduce tiny tassels to keep silhouette legible at 90px character height. Full body, three-quarter idle/ready standing pose facing slightly screen-right, head turned enough to read both eyes, slight elevated game camera angle about 20 degrees looking down, weight clearly on feet with one foot ahead. Sword sheathed at hip, hands relaxed and ready, NO drawn weapon swing and NO attack pose: auto weapons are separate VFX in this game. Consistent cool upper-left moonlight with small warm gold edge accents, clean ink contours, polished anime cel-painterly shading; not muddy hyperreal rendering. Genuine transparent RGBA background, alpha zero around figure, no ground, no baked shadow, no checkerboard, no UI or labels, no border, no magic aura or giant cape. Entire hair/scarf/sheath/feet contained with at least 8% transparent padding. One character only, 1024x1536 portrait composition. This is the proposed idle texture and appearance anchor, not a poster or turnaround sheet. Preserve reference identity and palette, adapted pose for future runtime sprite use.

## Remaining

Review appearance, then correct transparent silhouette/camera while retaining
the selected identity. Prepare actual motion states only after appearance LOCK.
New weapon/ninjutsu icon and VFX families are still pending, not manufactured by
this character call. The corresponding design proposal is
`../../../research/2026-09-11-tags-draft-and-trace-review.md`.
