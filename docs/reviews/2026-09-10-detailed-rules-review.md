# Detailed rules planning review — 2026-09-10

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
