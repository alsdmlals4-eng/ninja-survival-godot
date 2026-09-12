# Detailed rules planning review — 2026-09-10

## 2026-09-12 whole-run implementation loop — still active

Approved scope includes all four battlefields, preparation/shop/backpack and final
calamity. This increment is not completion of the approved equipment/book/save
redesign. Fresh Base remote d830c0f selective adoption is recorded in the native
work contract. No other PR or Base checkout was mutated.

Validated failures and changes:
- Real Main's second-school Elite stalled on origin-only scroll eligibility.
  Separate optional legacy origin reward from battlefield progression; do not
  grant foreign books. Keep player origin modifiers fixed and render actual
  battlefield identity in HUD.
- Five Fate definitions left only two candidates at preparation4; old sampler
  returned an empty array. Offer remaining unique candidates, no new Fate IDs.
- Final preparation required an impossible fifth route. Explicit final mode of
  the existing commit coordinator retains session/reward/Fate validation and
  one-shot commit; route remains four clears, never stage5.
- Actual final actor uses clear-order HP quarters,1800 initial HP, existing
  three-pattern school compositions and existing art as provisional reuse.
  Transition waits until attack/projectile/proxy completion, skips crossed HP
  quarters, never heals. First pattern per theme gains0.2sec reading time.
- Main creates that actor after final build commit and shows a Korean completion
  screen on death. This does NOT implement terminal soul payout/profile-v2 yet.
- Dash collision ignores enemy bodies but retains terrain(mask16), then restores
  exact prior masks. Player scene mask18 distinguishes terrain from enemies.
- GPU inspection exposed clipped preparation controls and incomplete floor.
  Keep all existing UI paths, replace the layout-only Margin container with a
  focus-following ScrollContainer; retain font readability. Floor now covers the
  positive repeat canvas from(0,0), without adding brute-force repeats.

Alternatives: ADAPT existing coordinator + explicit final transaction mode;
REJECT simulated fifth school; DEFER separate final-workbench system (duplicate
authority). ADOPT native scroll/focus; REJECT shrinking text to fit; DEFER a new
multi-panel redesign until equipment/book consumers are present.
Primary references:
https://docs.godotengine.org/en/stable/classes/class_scrollcontainer.html
https://docs.godotengine.org/en/stable/tutorials/2d/2d_parallax.html
The latter explicitly explains negative texture placement causing repeat gaps.

Evidence: focused RED failures were observed before the corresponding fixes.
Latest full GUT:92scripts/645tests/7055assertions, zero failures/errors/warnings.
An earlier full run had a transient pre-existing orb lifetime assertion; isolated
and later full runs passed. Do not erase that observation or claim flake-free.
GPU fixture `tools/qa_full_route_render.gd` uses real Main, title/start selection,
four lifecycle sequences, final actor and completion view. It accelerates time,
forces kills and legally expands the test-only board; it is NOT a normal-speed
or normal-capacity playtest. Wallet/resume paths are isolated before Main ready.
First capture wrongly bypassed title dismissal; rejected and corrected to use
new-game/selection flow. Later capture exposed real floor/UI defects, corrected.
Retained screenshots: `full-route-final-preparation-20260912.png`,
`full-route-final-battle-20260912.png`, `full-route-complete-20260912.png`.

Open: final battle readability/telegraph geometry, new equipment/24books/start
draft, trace choice, profile-v2/settlement, remaining ultimates, normal-speed
combat, Human/device/export. Actors/VFX remain tiny/overlapping in GPU capture.
No final five full-scope clean loops, independent completion review or merge.
Reusable lesson: test actual screen entry and end-of-pool/final-route boundaries;
scene instantiation + direct callbacks can pass while title overlays hide play.
Base promotion is a candidate only, not performed.

## 2026-09-12 second implementation checkpoint — not a completion gate

Approved continuation: breath presentation and R-INPUT alignment. Source head
0659189; main b5c2dd61. RED: missing visible breath2tests; fade/recast opacity1;
stationary/reentrant/paused dash4; cone/crowd/ranged/pause weapons4. Each verified
failing before implementation. Final91scripts/637tests/6936assertions PASS with
full output engine-error/warning scan. Scope remains WIP, no5full-scope loops claim.

ADAPT existing Sprite2D ownership and fixed sheet cells, no second animation timer
owning damage. REJECT raw unregistered2x2 frames (pivot jumps); DEFER new particle
system (extra authoring/ownership for no proven benefit). Official region reference:
https://docs.godotengine.org/en/stable/classes/class_atlastexture.html . Existing
Sprite2D hframes is sufficient after equal-cell mechanical registration.

Validated artifact defect: Aseprite newFrame copied populated previous cel;
drawImage import composited rather than replaced it. First export REJECTED after
visual inspection. All blank frames created before imports fixed contamination.
Keep this order/check in future project motion work; Base promotion remains a
candidate, not an unreviewed shared-tool mutation. Recast retained faded opacity
also reproduced RED, corrected reset. No paid dependency or global tool changes.

Actual GPU render from tools/qa_breath_render.gd uses real existing player/enemy
scenes and consumer but no MainController/wallet. Screenshot shows correct forward
origin and translucent flow; old actor size/contrast remains deficient. Do not
equate fixture rendering with integrated gameplay or Human readability PASS.

## 2026-09-12 implementation checkpoint (not completion review)

Input b83b6e9 plus prior uncommitted breath increment; fetched main b5c2dd61,
Base2f93e872 unchanged. Current continuation PR147;135/49 read-only.
Scope requested: all remaining implementation through integration. Actual changed
scope this checkpoint: breath logic, player/weapon facing, regression tests,
authority routers and one quarantined candidate. Other packages not completed.

Validated findings: no weapon-facing fallback before movement; hidden targets
spend charge; old tiny viewport fixture cannot exercise visible-range semantics.
RED:25 tests,23 passing,2 failures. Added real1152x648 SubViewport fixture;
setting canvas transform before tree entry caused engine errors, corrected order.
Later explicit Viewport/Transform2D types fixed test-script parse failures.
Discarded602-test green banner because91-script coverage fell to90; error scan
and inventory are required alongside exit status. Final91scripts/629tests/6896
assertions pass. Includes pause/deactivation, world geometry after offscreen move,
death,30/31-degree and320/321-distance boundaries and Main button/dash integration.

Approaches: ADAPT existing runtime + stateless canvas transform visibility;
DEFER VisibleOnScreenNotifier (extra per-enemy scene state unnecessary here);
REJECT fixed screen/world-coordinate bounds (camera zoom/translation mismatch).
Official source: https://docs.godotengine.org/en/4.7/classes/class_canvasitem.html
and https://docs.godotengine.org/en/stable/tutorials/2d/2d_transforms.html.
CI-pinned4.7.1 retained; no shared engine update or added paid dependency.

Visual finding: new1254px candidate has alpha/cell separation but inconsistent
emission pivots and extent. ALIGNMENT_REQUIRED, not production-ready. Existing
old field art is wrong semantics, rejected as replacement breath. Current Hera
is another project, no live mutation performed. Full new-design integration,
render/Human/device checks and five whole-state completion loops NOT_COMPLETE.
This is a WIP evidence checkpoint, not a clean exit or merge recommendation.
Project lesson: GUT green/exit0 can accompany a skipped parse-error script;
retain explicit error/warning and expected script/test-count readback. No Base
promotion performed without a separate cross-project evidence package.

## Scope and authority

User: “상세 규칙 및 기획사항은 네가 인터넷 조사,벤치마킹 및 권장안대로 판단해서 정리해줘”.
The immediately preceding planning-before-images constraint remains active.
Outcome: a repository-native detailed design selected under delegated judgement,
not runtime implementation, per-rule Human approval or balanced production data.

- Current task branch: `codex/replanning-art-motion-20260910`, PR #147 (Draft).
- Input head: `28e4ac06309fe980c47150a740b34c1da3cbb67d`.
- Fetched completed main: `b5c2dd61cd589ebd218d1b4da3f016fb94a02126`.
- Base observed: `2f93e872d9ed4fa18018ac759b01acd7d34e9b58`.
- Other open PRs #135/#49: read-only; no takeover or mutation.
- Project native thin contract retained; project minimum five reviews overrides
  current Base two-round policy. No Base/Notion/Sheets mutation.
- Authority owner: [NS-DESIGN-RULES](../design/NINJA_SURVIVAL_DETAILED_RULES.md).
- Discovery/routing: Decisions, Active Context, Documentation Map, roadmap,
  research and screen/visual handoff updated by reference, not duplicate rulebooks.
- Publication: new planning source in Markdown; milestone PDF not generated in
  this planning-only update. Existing Human GDD/PDF/image bytes remain unchanged.

## Evidence and feasibility boundary

Read current AGENTS and task overlay, decision/context and adopted work contract,
old product/encounter canon, basic weapon/player/combat owners, ninjutsu catalog,
loadout/auto controller, spatial catalog, economy, wallet and checkpoint codec.
Prior research's 15-game comparison and mixed response sample remain bounded
historical research. Targeted official comparison refreshed for this decision.

Reused Base concept/system/difficulty, design-document and adversarial methods.
Rule owner includes choices, alternatives, source URLs, rollback and tests needed.
No new paid tool, engine, external service, autoload, data owner or global skill.
Game AI Pro body re-fetch timed out: not used as direct substantive evidence.
Public-source research is not direct comparison-game play or user research PASS.

Feasibility: existing owner paths identified; cross-school loadout, state effects,
reaction conflicts, atomic save migration and performance remain future work.
Do not use prior 618-test input-package evidence as verification of new rules.

## Whole-state review lineage

Scope of every round: delegated intent and preserved A+B; all rules R-INPUT
through R-PRESENTATION; existing owner fit; alternatives and long-term cost;
edge cases/economy/save/rollback; changed and untouched consumers; image/runtime
pause; documentation status, links, IDs and protected-file diff.
These are whole-state rounds, not one discipline assigned to each round.

1. Input: first 316-line rules draft plus seven router changes. Full design/routing
   attacked against observed catalogs and source. Validated: bomb equipment could
   evade the advertised attack count; materials and spell scrolls could be confused;
   duplicate bonus caps were unspecified; water-mist AI targeting changes added
   unnecessary state ownership. Corrected: explicit equipment channel, separate
   19-item/8-scroll pools, bounded duplicate effects, movement-based recovery effect.
   Rechecked prior control, route, saves and production pause; no runtime change.

2. Input rules SHA-256 `A77E2DF7027DB916DDAD8B936736E7B162D2EF6D6620AA2B4C494E2A0AEB74DC`.
   Re-attacked the whole scope above, including acquisition order, intrinsic
   weapons, bonus stacking, menu/save ownership and rollout boundaries. Static
   checks read nine documents, checked detail links/encoding/fences, twelve
   catalog IDs and ten rule groups; runtime/art/PDF diff was empty.
   Validated finding: summon slot lifetime and shared enemy pattern shapes were
   underspecified. Added explicit primitive values, temporary familiar lifetime,
   owner-death cleanup and fail-closed safety check. Refreshed Spell Disk as the
   stronger free-synergy alternative; retained limited composition because no
   evidence justifies a general trigger engine. Originality remains a hypothesis.

3. Input rules SHA-256 `62A87B21CA57CFDDF051271B4BEE629607F26C0B42F4069DC6E61E275589E74D`.
   Full-state contract/consumer/research/recovery re-attack and nine-document
   static checks repeated. Validated a concrete fairness contradiction: a radius
   96 zone plus player radius 14 at speed 240 requires 0.4583 seconds to exit,
   but the draft fixed its target only 0.3 seconds before damage. Corrected to
   a minimum 0.65-second lock and path/speed + 0.15-second margin, scheduled
   before telegraph starts. Rejected simply reducing the hazard radius because
   slowed/obstructed movement still needs the same geometric safety contract.
   Other systems/control/asset pause remained unchanged. Arithmetic evidence is
   not a live fairness/Human PASS.

4. Input rules SHA-256 `C9F01D3F3BEBD2F5550B175CD35251F911A16F8F21F06C348F8362310A8A31C9`.
   Re-attacked the whole state: starter/off-school access, attack channels,
   recipe replacement, resource ownership, route gates, temporary summons,
   walking escape, settlement/retry, save rollback and production boundaries.
   No further validated blocker within this planning scope. Rechecked the
   simpler numeric-only and unrestricted-trigger alternatives: neither improves
   the selected bounded design without losing the stated goal or adding cost.
   Nine-document static checks passed; the escape-time arithmetic passed.
   This does not resolve the explicitly deferred reaction/migration specifications.

5. Same rules hash, final full-state re-attack against all ten rule groups and
   seven routing surfaces. Rechecked the distinction between spawn permission
   and population caps, first-stage pattern sequencing, four-stage/final timing,
   intrinsic weapons versus materials, and delegated design versus implementation.
   No additional validated MUST_FIX found. Fresh fetch confirmed unchanged main
   and PR #147 input head; #135/#49 remain separate and read-only. Final static
   checks passed. No new evidence supports expanding into assets/runtime or
   merging the combined Draft PR. Exit is clean for detailed planning only.

## Verification and delivery boundary

- Nine changed/new Markdown documents read; detail-owner local links, balanced
  fences, encoding, twelve catalog IDs and ten rule groups checked successfully.
- `git diff --check`: PASS. Runtime/code/art/PDF changes in this update: none.
- Arithmetic: 110 / 240 + 0.15 = 0.608333 seconds; default 0.65-second fixed
  warning exceeds this unblocked example only, not every possible scene.
- Final rules SHA-256: `C9F01D3F3BEBD2F5550B175CD35251F911A16F8F21F06C348F8362310A8A31C9`.
- Exact commit/push/CI readback is attached to the current PR after publication;
  this receipt does not self-claim an as-yet uncreated commit hash or CI result.
- Godot import/GUT/live runtime/device/new-rule balance: NOT_RUN in this update.
  Any repository CI result proves only the checks actually executed, not these
  new, unimplemented rules. Draft #147 is not merged by this planning delivery.

## Learning and residual work

PROJECT_ONLY: distinguish inventory equipment labels, intrinsic weapons and
active scrolls; preserve semantic scope through authoritative catalog/consumer
mapping. Source count is not distinct gameplay count. These are not new Base
rules: existing concept/consumer/evidence practices already cover them.
No new reusable automation or Base promotion is justified from this single review.

Next: detail reaction ownership/migration and representative-slice inputs;
images and implementation remain paused. No existing asset or historical PDF
was removed. User experience, final art, runtime, performance, platform and
balance of the new design: NOT_RUN. Combined PR #147 remains Draft/unmerged.
