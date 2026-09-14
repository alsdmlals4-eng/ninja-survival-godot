# ACTIVE_CONTEXT

## Latest increment — preparation values admitted to profile2, 2026-09-14

RestBackpackSession serializes confirmed backpack/buffer/pending_bag/preserve_buffer,
rejects transient preview/whole-layout/combination states and validates before restore.
Instance IDs remain unique; restored baseline clears edit history and invalidates old
commit-coordinator generation. This sub-owner does not adopt combat/economy.
RunResumeCodec now admits a 12-field post-school preparation with matching selected
bundle/access/reward state. Route is derived from the last departure plus its one school
clear, not duplicated or merged into the retry checkpoint. Prior trace decisions and
starting draft are preserved. Only empty pending_fate is admitted until Fate owner wiring.
Actual profile2 file write/reopen/idempotent replay is covered on gut-only storage.
Combined reward/spatial restore test preserves a purchased unplaced bag and forbids
another purchase/reward claim. RED missing session/codec paths, GREEN focused checks;
full102scripts/812tests/11821assertions PASS exit0,
`ninja-preparation-profile-full-20260914.log`. Earlier full811tests was the sub-owner scope.
Source commit27cefdb exact-head GitHub GUT/Windows SUCCESS; newer change needs current CI.
Main still uses the legacy entry. Remaining R01: recovery selection, retry eligibility
union and nondestructive legacy migration; R02 needs business transaction/Fate wiring.
Full five-loop project closure, runtime full-run, Human/device/release remain NOT_RUN.
Evidence supplement source records updated here; monthly PDF still v0.3 pending rebundle.

## Latest increment — reward/shop serialization and selected acquisition, 2026-09-14

RestRewardController/ShopController now export and validate/restore value snapshots:
fixed boss offers, consumed flag, chest count, shop offers/lanes/bag purchase limit,
reroll index, text history and shared RNG seed/state as exact decimal strings.
Restore performs no draw, acquire, spend or notification. Prepared access is required;
fresh configured selected owners restore without calling begin_rest. Gold/inventory,
pending bag and profile2 preparation transactions are NOT included by this sub-owner API.
RED missing API2tests, then selected acquisition test reproduced dropped replacement
manuals, then fresh-owner restore test reproduced missing lane setup. Corrections verified:
focused14tests/303assertions; full102scripts/809tests/11770assertions PASS exit0,
`ninja-reward-persistence-full-20260914.log`. Existing main entry not migrated.
Shop/reward filter now chooses legacy versus selected canonical acquisition from the
actual backpack contract. Old katana/shuriken/bomb do not leak into new selectable runs.
No new image or player-save mutation. Whole-scope review, profile2 preparation, Main,
Human/device and release remain open; continue session pending-bag persistence next.

## Latest increment — temporary profile I/O failure coverage, 2026-09-14

Approved R01 continuation: RunResumeStore now owns narrow open/store/flush operations.
It checks store_string's result before flush, closes the handle explicitly and distinguishes
temporary_open_failed / temporary_write_failed / temporary_flush_failed. Tests inject
open, partial-write, flush and temporary-readback failures using a real gut-only file.
Old bytes, balance, caller request and receipt remain unchanged; candidate remnants are
preserved and block overwrite on retry. RED 1/9 failed before implementation; GREEN9/9,
143assertions. Full102scripts/806tests/11571assertions PASS, exit0, log
`ninja-profile-temporary-full-20260914.log`. This is failure simulation, not power-loss proof.
Fresh prior head d556637 CI GUT and Windows SUCCESS; current increment needs exact-head CI.
Base remote still d830c0f; project five-loop/full-scope gate remains in force and unfinished.

Reward owner readback: RestRewardController owns chest count, boss offer IDs/lanes and
pending choice; ShopController owns offers/lanes/bag limit/reroll tier; both share an RNG.
Existing begin_rest rerolls and resets state, so cannot be used as preparation restore.
Selected acquisition catalog mapping, explicit RNG persistence and pending-bag ownership
must be resolved in R01 preparation serialization before Main uses profile2. No new
generic dictionary escape hatch or second save system. R01 and whole-game remain open.

## Latest increment — monthly evidence supplement / chroma pipeline, 2026-09-14

User requested future chroma-background generation followed by removal and a separate
project-named monthly AI work evidence PDF. Owners: CURRENT_VISUAL_HANDOFF and
operations/AI_WORK_EVIDENCE.md; no new raster generated or existing asset replaced.
The September issue covers four verified September14 commits through 8e2558c only,
with exact-head GitHub run34786019166 logs, source hashes and explicit missing prompt
screenshots/account/receipts. It is retrospective, partial, unsubmitted, not date certification.
Generator refuses overwrite; v0.1/v0.2 draft formatting corrections are superseded by v0.3.
Nine-page layout was rendered/read; text-log evidence is never described as screenshots.
No agreement/email originals were read, no external submission or payment action occurred.
Game implementation remains at the following R01 frontier; this increment changes evidence
operations and image policy, not Main/runtime. Continue preparation/reward owner inspection.

## Latest increment — selected departure profile persistence, 2026-09-14

Follow-up failure-injection readback: previous rename, candidate promote, promote rollback,
failed-canonical quarantine and canonical rollback failures are exercised via the existing
store I/O boundary. Failed promote + failed rollback previously removed the candidate;
now both `.previous` and `.tmp` remain with recovery_required. No automatic recovery choice.
Final full102scripts/805tests/11529assertions PASS, exit0,
`ninja-profile-rename-full-gut-20260914.log`. Earlier failed test-fixture typed-array assignment
was corrected before rerun; the failed receipt is not promoted to PASS. Previous checkpoint
commit587a0dc GitHub GUT and Windows internal artifact both SUCCESS. Latest source receipt
must be read from current PR head; neither this test count nor CI is whole-game approval.

R01 now accepts a validated non-null active run at a departure boundary. Codec checks
origin versus battlefield (different is legal), route mirrors, phase, resolved traces,
equipment, placed/active books, carried-buffer identity, Fate IDs, economy receipt shape,
resource caps and recomputed spatial modifiers. Twenty-four clear orders reach a valid
final departure in domain tests; this is NOT twenty-four played runs.
Buffer inspection reproduced ignored malformed/duplicate/unabsorbed/unchosen-free books;
the existing cross-owner gate now rejects them without mutating the candidate.
Disk replay reproduced int/float request-digest drift after JSON reload; store canonicalizes
numeric request identity and uses full precision for profile writes. Fractional charge,
replay, invalid-origin rejection and settled-run exclusion are tested on dedicated gut paths.
Full102scripts/803tests/11496assertions PASS, exit0:
`ninja-selected-checkpoint-full-gut-20260914.log` in local temporary evidence.

R01 still open: preparation/reward-state persistence, retry qualification union across a
rollback, all I/O failure injections, recovery and non-destructive legacy migration.
Non-null preparation explicitly returns preparation_validation_pending. Main still uses
the legacy entry/resume path; default-game cutover, live full-run and Human/device gates
remain NOT_RUN. No player save touched. PR147 continues; no main merge claim.
Next read RestRewardController/ShopController persistence owners before finalizing the
preparation reward_state schema; do not hide unresolved reward ownership in a generic dict.

## Earlier increment — R01 profile envelope and durable transaction foundation, 2026-09-14

User approved R01~R10 execution. RunResumeCodec now validates schema2 empty-run profiles:
strict numeric fields, content contract, unique transaction/settlement IDs, receipt digest/
revision and unlock/settlement receipt linkage. Pending transaction validation is internal
to store candidate preparation; disk decode/readback always use strict receipt validation.
RunResumeStore reuses existing tmp/previous/write/readback machinery in explicit profile
mode; v1 write/clear/reconfigure APIs cannot mutate a profile. Request digest distinguishes
same-ID replay from conflict; stale revision and caller receipt mutation fail closed.
Tested disk roundtrip, replay, conflict, missing-directory write failure, canonical readback
rollback and cleanup-warning success using dedicated gut paths. Full101scripts/798tests/
10592assertions PASS, exit0, `ninja-profile-transaction-full-gut-20260914.log`.

R01 is NOT complete: non-null active_run intentionally returns active_run_validation_pending.
Next: checkpoint/preparation domain cross-validation, all rename/rollback failure injection,
recovery selection, legacy-wallet migration, then business transaction facades and Main.
The store does not enforce purchase/settlement pricing; those remain their domain owners.
Cross-process writer exclusion/crash-proof durability NOT_VERIFIED. No actual player save
or main entry switched; no new autoload, artwork, paid dependency or project deletion.


## Earlier planning request — remaining-work specifications, 2026-09-14

The preceding planning turn requested remaining work and implementation/design input.
The later execution approval at the top of this file supersedes that turn-only boundary.
Read `docs/design/NINJA_SURVIVAL_IMPLEMENTATION_PACKET.md` section J first: R01~R10 map
single profile2, preparation transactions, Main entry, reward pools, meta/menus, encounters,
combat contract regressions, art/audio, device/performance and final delivery.
Source baseline c360486; fetched main b5c2dd6; PR147 Draft head c360486 GitHub GUT and
Windows internal build both SUCCESS on readback. PR135/49 untouched/read-only.
No game code, image, player save or deletion is part of this document change.
Verified source gaps: legacy Main starter, legacy reward filters, codex excludes selectable,
no profile2. Existing final boss/24effects/8weapons are reuse+integration, not blank rewrites.
Base observed d830c0f; native contract/five-loop requirement retained, no adapter upgrade.
Next implementation priority after this planning task: R01 profile2 codec/store transactions.


## Latest increment — legacy wallet validation before profile2 migration, 2026-09-13

Reproduced numeric coercion accepting1.5/string/bool/future schema and null causing an
engine error. Strict decode now rejects malformed/nonfinite/lossy values before integer
conversion; malformed JSON uses parser error return without an engine exception. Original
bytes remain untouched. Reconfigure failure formerly changed balance/path before I/O;
now adopts only a successful candidate and keeps the previous usable binding on failure.
Full100scripts/792tests/10524assertions PASS, exit0:
`ninja-wallet-input-full-gut-20260913.log`. Tests use dedicated gut paths, not player saves.
Prior b3bb667 exact-head GitHub GUT/Windows artifact both SUCCESS. Current save work is
input safety only; one-file profile2 atomic durability and Main adoption still NOT_IMPLEMENTED.
Do not describe this v1 write path as atomic or crash-proof. Existing owners remain singular.


## Latest increment — start bundle cross-owner gate, 2026-09-13

RestCommitCoordinator validates selected bag geometry, actual placed spell IDs, restored
trace access, equipment and loadout origin as one side-effect-free build bundle. Existing
domain validators remain owners. StartLoadoutSession includes initial access and returns
only a validated bundle. Four-school JSON roundtrips, absent-book power, forged access,
wrong origin, invalid gear and legacy/malformed catalog boundary are covered; existing
60start-pair regression remains. Full100scripts/790tests/10494assertions PASS, exit0,
`ninja-selected-bundle-full-gut-20260913.log` (local temporary evidence).
This is NOT the persistent transaction: wallet/checkpoint profile2, preparation UI commit,
default Main cutover and whole Run remain required. No human/render/release claim.


## Latest increment — selected trace access and validated restore, 2026-09-13

TraditionAccessState separates stabilized material packages from absorbed book access.
Starting-school trace enhances one equipped candidate item; foreign traces absorb OR
enhance once. Stale equipment revision, invalid choice and repeated consumption leave
both candidates unchanged. Selected material IDs follow the independent catalog.
JSON restore derives unlocks from decisions, validates school sets/equipment record/rank,
and rejects malformed or forged unlocks before any mutation. Legacy initialization stays.
Full100scripts/789tests/10445assertions PASS, exit0:
`ninja-selected-trace-restore-full-gut-20260913.log` (temporary local evidence).
Head888ac5d GitHub GUT and Windows artifact checks both passed. This increment is domain
and machine evidence, NOT profile2 disk durability, Main cutover, Human or release evidence.
Next: selected preparation cross-owner validation and single-profile atomic persistence.
Five whole-game review loops, runtime full-run and user-facing default wiring remain open.


## Latest increment — RunBuildState equipment owner, 2026-09-13

RunBuildState validates/copies the committed equipment snapshot and derives outfit
reduction once alongside bag/Fate modifiers. Preview mutations and malformed slots do
not affect combat. Actual Player100damage resolves92 with outfit rank1; repeated apply
does not stack reduction. Checkpoint preserves equipment; legacy restore/codec cannot
silently drop or interpret it. This is in-memory ownership, NOT profile2 persistence.
Full99scripts/784tests/10374assertions PASS (`ninja-equipment-owner-full-gut-20260913.log`).
Previous combination head649682b has both GitHub GUT and Windows artifact checksSUCCESS.
Current full-game next dependency: selected preparation equipment/books/route transaction,
single profile2 wallet/checkpoint durability, then default Main cutover and complete Run.
Unseen-art/Human/device gates and five whole-scope reviews remain open. No deletion.


## Latest increment — conditional combination consumers, 2026-09-13

Thunder first melee hit damages at most2other targets/120/6 with1s cooldown. Explosive
shares one claim per projectile volley,96/12 with4s cooldown; pierce/bomb damage uses
the same actual-hit signal. Combination damage bypasses weapon/manual/school multipliers
and ultimate/direct-ninjutsu feedback, while owned nonultimate Bongma kill credit remains.
Water mist requires actual surviving HP loss,1s+20%/3s cooldown through existing Player boon;
static8% remains resolver-owned. Pause/source removal and ultimate exclusions are separate.
RED found a death callback attaching a new combo retroactively; generation check rejects it.
Full99scripts/782tests/10350assertions PASS (`ninja-combination-reentrant-full-gut-20260913.log`).
OpenGL MATERIAL_RUNTIME_PASS includes real timed thunder secondary6 and unequip cessation.
New proc art/fullMain/profile2/Human and five whole-scope review completion NOT_RUN.
Next: RunBuildState equipment ownership/selected preparation and single profile2 transaction.


## Latest increment — selected support geometry and weapon passives, 2026-09-13

Selected catalog includes19remapped supports/3results/48book definitions. Legacy catalogs
remain unchanged; selected bag rejects physical weapon IDs. Actual preparation combination
uses new recipe owner; illegal output placement consumes nothing; results are unique.
BasicWeaponController derives committed melee/projectile manual bonuses from validated
canonical bag definitions, caps60%, isolates source edits and excludes ninjutsu/ultimate.
Full99scripts/778tests/10314assertions PASS (`ninja-selected-materials-full-gut-20260913.log`).
OpenGL exact-project process MATERIAL_RUNTIME_PASS checks118→120→100 damage across manual,
combination and unequip. This is isolated runtime evidence, not full Main/user visual QA.
Next: conditional combo lightning/explosion/mist effects, preparation/profile2/Main binding.
Hera currently targets GRIMOIRE PID11900; untouched. Unknown generated files preserved.
Whole-game queue and five whole-scope reviews remain open; no release/main merge claim.


## Latest increment — owned nonultimate kill resource, 2026-09-13

Bongma now accepts owned dot/clone/reaction death contexts alongside normal/weapon/direct
injutsu, matching R-ULTIMATE. Unknown/ultimate/stale context remains excluded; one-second
limit and enemy death claim preserve deduplication. Focused RED confirmed three omitted
routes before correction. Full98scripts/773tests/10255assertions PASS
(`ninja-bongma-owned-kills-full-gut-20260913.log`). No Main/profile2/art promotion.
Continue selected support catalog/equipment/preparation/profile2 integration, then complete
Run acceptance and five whole-scope reviews. Whole-game completion remains unclaimed.


## Latest increment — selected restore boundary, 2026-09-13

Explicit selectable-v2 restore validates original two picks, active/placement equality,
unlocks and four/one limits before mutation. Legacy restore still rejects this contract.
Malformed scalar/object contract tests found an engine Variant comparison error; a type
guard fixes rejection without mutation or signals. Empty placed books restore no hidden starter.
Full98scripts/772tests/10230assertions PASS (`ninja-selected-restore-hardened-full-gut-20260913.log`).
This is an in-memory restore API, NOT profile2 file persistence or Main cutover.
Confirmed follow-up: selected bag catalog currently excludes support materials; apply
R-COMBINATION remapping before selected preparation integration, never legacy weapon IDs.
Single wallet/checkpoint profile2, complete selected Run and whole-scope reviews remain open.


## Latest increment — all24 effect routes and60pair smoke, 2026-09-13

All24 selected books now have mechanical consumers, NOT final-art/game-complete.
Water first-entry damage/inside slow/wet lifetime; ordered wet→shock bounded reaction;
Cheonsul read-only status/quarter-charge notification; thunder dash arms one direct hit;
talisman wheel3orbiters/radius90/max2hits with0.5gap. Technical orbit test values PI/s,
contact24, sample0.025; visual/balance lock not claimed. No hidden full-disc damage.
60start pairs each advance10s real actors and cleanup; focused40tests/495assertions PASS.
Definition cache reduced same focused suite31.685s→1.914s (local observation, not FPS claim).
Full98scripts/770tests/10175assertions PASS (`ninja-all-books-sixty-pairs-full-gut-20260913.log`).
Next approved work: selected loadout restore + single profile2 transaction, equipment/build
commit and Main start/preparation/route integration. Ordinary Main still legacy until these
boundaries pass. Ultimate60pair/fullRun/render/Human/5whole-scope reviews remain pending.


## Latest increment — clone, seal chain and suppression, 2026-09-13

Selected effects now20/24;4remain (talisman wheel, water bind, lightning chain, thunder step).
Clone uses fixed-origin bounded3ticks with clone damage kind and sword-only skip consumption.
Seal chain connects at most3targets within140, first12/followups8, bind0.6;
suppression waits0.2 then fixed-radius100 hit16/bind0.4. Source removal cancels controls.
EnemyChaser owns transient movement multiplier without changing base speed; elite/boss
bind becomes20%/10% slow; core rebind protection2s; strongest slow capped40%.
Pattern clocks remain independent; idle control processing enabled only while needed.
Full98scripts/762tests/9841assertions PASS (`ninja-control-corrected-full-gut-20260913.log`).
These3effects GPU-specific final render/input NOT_RUN; generic existing visual only.
Whole approved game queue remains active; selected Main/profile2/complete Run still pending.


## Latest increment — flame mark and breath status readback, 2026-09-13

Selected effects now17/24;7remain. Flame direct6/radius90 every1.8s plus burn3s/2per1s;
burn/poison share the clock algorithm but keep independent source maps and expiry.
Cheonsul reads selected burn for breath+2 without copying status/hidden elemental alternation.
Main wires the provider but does not enable selectable-v2 for ordinary new-game yet.
Full97scripts/754tests/9797assertions PASS (`ninja-flame-full-gut-20260913.log`),
OpenGL FLAME_RUNTIME_PASS direct/burn/unequip; human/final art/complete new Run NOT_RUN.
Remaining:3Bongma controls/orbit,3Cheonsul water/lightning/dash token,1Heukyeong clone.
Then selected start/profile2/UI and complete Run integration; all approved work remains active.


## Latest increment — poison mist and summon suppression, 2026-09-13

Selected effects now16/24;8remain. Poison mist is target-centered radius96,
zone2s, poison3s/4damage per1s, cooldown5s. Refresh preserves tick phase;
sword form consumes lifetime without damage/backlog. Unequip/stage clear cancels
status; damage callbacks cannot restart a cleared generation in the same tick.
Existing selected familiar now survives sword form with frozen attack cooldown.
Full97scripts/751tests/9779assertions PASS (ninja-poison-lifecycle-full-gut-20260913.log).
OpenGL real-process poison delayed tick/unequip PASS; final-art/readability NOT_RUN.
PR147 continuation only; default Main cutover/profile2/end-to-end selected Run and
five whole-approved-scope review loops remain incomplete. No merge/release claim.
Next: remaining status/control books, their ultimate consumers, profile2/UI integration.


## Latest increment — chain execution, 2026-09-13

Selected effects now15/24;9remain. Chain execution selects mark→lowHP ratio→
distance→stableID, ordinary HP<=15% execution, heavy17.5 rounded damage,
max2followups within140 only after confirmed kill. Class and role protect bosses.
Final full97scripts/747tests/9763assertions PASS. Execution-specific GPU smoke
not run; normal-speed full new-mode run and final visuals still not proven.

## Latest correction — selected combined caps, 2026-09-13

Selected Loadout rules now cap combined movement at1.6x and add equipment/
book mitigation before the60% cap. Empty selected loadout retains these rules;
legacy contracts keep their old calculations until explicit migration.
Final local full97scripts/744tests/9750assertions PASS, no logged engine errors.
Selected effect count remains14/24. Remaining10: seal chain/talisman wheel/
suppression seal/flame mark/water bind/lightning chain/thunder step/poison mist/
chain execution/shadow clone. Then tag damage, gear/economy/profile2, default
Main starting draft and complete normal-speed new-mode run remain open.
New art/Human/device/export and five whole-approved-scope review gate are not complete.

## Latest increment — selected familiar, 2026-09-13

Selected effects now14/24;10remain. Existing BongmaFamiliar scene supplies
follow/attack behavior; selected controller owns membership and0.7s cadence.
Its own process attack clock is disabled; range320/follow maximum180/damage8.
Unequip/sword-only/stage/death clears the owned summon and re-equip preserves
the ID cooldown. Full742tests/9741assertions PASS; real process spawn/cadence/
unequip GPU smoke PASS. Existing sprite is fallback, not new art approval.

## Latest increment — selected needle/dart and mark, 2026-09-13

Selected effect consumers now cover13/24;11remain. Needle/dart use first swept
circle intersection, fixed launch aim, lifetimes and direct_injutsu damage.
Needle grants8s priority-only mark, no legacy crit/burst; unequip/stage/death
clears it. Marks expire during sword form and freeze only during pause.
GPU real-process needle and dart smoke both PASS; final full count below is
740tests/9722assertions PASS. Heukyeong origin queries selected mark without
copying it, enabling existing direct-hit charge bonus and ultimate bonus.
No new art/cutover/release claim.

## Latest increment — wind projectile, 2026-09-13

Follow-up: final calamity entry now resets per-book clocks only after successful
final Workbench commit. Actual four-school→final Main test reproduced the old
0.01s clock leak and now passes. Full734tests/9693assertions PASS.

Selected book consumers now cover11/24;13remain. Wind uses swept movement with
per-target dedupe, full lifetime clamp and direct_injutsu damage. Final local
GUT97scripts/734tests/9692assertions PASS; GPU real-process wind smoke PASS.
The detailed Korean wind receipt at the end supersedes the counts below.
Main default cutover/profile2/remaining effects/full-run/Human gates remain open.

## Latest — support books and actual lifecycle consumers, 2026-09-13

Continue without routine approval as explicitly requested. This turn completed
successive logic increments:4support books →2fixed ward books → Main cleanup/
Stage reset → common school Loadout binding/intrinsic suppression.
Selected effect consumers now cover10/24 books (4offense,6support);14remain.
Player owns transient damage reduction/shield/speed resolution, controller owns
conditions/durations; no save schema fields or new autoload. Ward family takes
maximum rather than sum; total transient reduction capped60%. Reduction precedes
shield; dash invulnerability does not spend shield; real dash-end emits once.
Main now clears transient effects when combat stops and reconfigures the cast
consumer on successful school entry. All school runtimes suppress intrinsic
attacks when bound to selected mode; their charge/ultimate ownership remains.
Default starting UI/profile path still legacy; do not claim selected full-run.
Final local full GUT97scripts/731tests/9673assertions PASS; GPU physics/process
support smoke PASS using `tools/qa_selected_books_runtime.gd -- --support`.
No new art, visual approval, normal-speed Human test or main merge. Full five
whole-scope review loops still open, not inferred from targeted correction passes.
Next ready work:14effect implementations and shared status/projectile consumers;
then start/Main/gear/economy/profile2 integration and full-run acceptance.

## Latest — four selected offensive books, 2026-09-13 continuation

Current WIP now consumes Guiin pulse/afterimage line/ring/kick cone definitions.
The remaining new-effect count is20, not23. Fixed origin/direction, per-cast line
hit dedupe, exact scheduled ring/kick ticks, Loadout signal cancellation,
reentrant-call guard and configure-time Stage reset are implemented.
Main binds Guiin to Loadout: selectable mode suppresses its legacy free pulse
while school-owned charge remains. Default Main start/profile still legacy.
Actual GPU-backed engine process smoke with production Player/Enemy passed:
`tools/qa_selected_books_runtime.gd`; no Main/save writes and no art-quality claim.
First full regression717tests/9608assertions passed; later visual-cancellation
regression reproduced and corrected, final run receipt follows in review owner.
Whole-game queue remains open:20effects, tags, other school intrinsic suppression,
Stage lifecycle consumer wiring, gear/Workbench/profile2, normal-speed full run,
visual assets/Human/device and full five-loop closeout. Do not mark P03 complete.

## Latest — selected-book combat consumer WIP, 2026-09-13

User clarified the loop means benchmark → specify → implement → verify/correct,
not repeated checks alone. Existing Implementation Packet records the next plan.
NinjutsuAutoController now has an opt-in selectable-v2 branch consuming only
guiin_ghost_blood_wave config (0.9s/80radius/10damage), with initial cooldown,
0.12s no-target retry, committed membership and retained unequip cooldown.
Legacy starter handling stays unchanged. Unsupported new books do not fall
through to generic attacks. Target must belong to the configured world.
RED reproduced starter skip; focused2tests/22assertions then full96scripts/
708tests/9563assertions passed with Godot4.7.1/GUT9.7.1.
This is WIP, not P03 completion: remaining23 effects, tag-modifier integration,
intrinsic-attack suppression, reused Stage timer-reset, Main/profile2 cutover,
new render/input evidence and five full adversarial loops remain open.
No new assets, production save-format change, merge or Human approval.

## Latest — plan-first start-loadout preparation, 2026-09-13

User approved the proposed plan-first continuation. Implemented an isolated
start preparation session/UI: two seeded three-choice rounds, two real1×2
starting books on the existing3×3 board, move/rotate, restart without reroll,
three external equipment slots, explicit single confirmation and defensive
snapshots. Book item records project the existing24 Ninjutsu definitions;
free/paid acquisition variants do not add new skills or enter legacy rewards.
BackpackState keeps an explicit selectable-books-v2 mode through copy/JSON;
schema1 refuses this mode even for an empty board. Existing geometry/copy/
resolver and old-save defaults remain intact. This slice supports books only;
new support/combination economy is not yet mapped into its catalog.

Correction: `MVP4Catalog.build_bags()` already has3×3 starting area. Earlier
status text saying the geometry itself was not implemented was stale; the
new start-book/selection integration was missing. Treat old entries below as
increment history, not current geometry authority.

Fresh local full GUT:96scripts/707tests/9548assertions PASS, including new
60-pair real geometry/confirmation coverage. Actual GPU pointer draft/move/
confirm PASS; keyboard selection/confirm integration PASS. Capture:
`reviews/start-loadout-preparation-20260913.png`. Native functional layout,
not final art, human approval or device QA. Hera reported no live editor;
render used the verified Godot4.7.1 CLI, no editor-attachment claim.
Default wallet/resume hashes remain equal to the prior isolation baseline.

Main is intentionally unchanged until24-effect consumers and profile2 are ready.
No default-new-game cutover, new-save transaction, combat-pair validation,
whole-game completion or merge. Next: effect consumers + committed equipment/
Workbench/profile2, then attach this prepared snapshot to real Main atomically.
Current branch/remote and CI evidence are recorded after exact-head verification;
PR147 remains the current continuation and other PRs stay read-only.

## Latest — whole-run continuation, 2026-09-12

Delivery readback: code/data headca44becd1366c97a771b2275e44fdc74adb57051 equals
its remote task branch and passed remote GUT + Windows internal build in run
34672556291. Protected main remainsb5c2dd61cd589ebd218d1b4da3f016fb94a02126;
PR147 is still Draft/unmerged, other PRs unchanged. Base remote remainsd830c0f,
not silently replacing the adopted project-native contract.700-test local run
and this CI are not a final whole-scope acceptance gate.
Finished isolated Main fixtures952files/38720bytes moved, not deleted, to
`C:/Users/user/Documents/GitHub/Ninza/DELETE_REVIEW/ninja-survival-godot/2026-09-12/gut-main-isolated-20260912`.
Three owned ultimate-render wallet fixtures also moved into existing
`full-route-runtime-fixtures` (now17payloads/19445bytes). READMEs explain disposal.
Default player wallet/resume, untracked Godot imports and other worktrees remain.

Latest P01/P03 preparation: NinjutsuCatalog contains24 known IDs/six per school,
typed tags and copied effect parameters from current R-NINJUTSU. Original12 IDs
and legacy lane mapping preserved; nonexistent asset paths stay empty. New12
records are not exposed as available in the player codex before runtime hookup.
NinjutsuLoadoutState now owns deterministic3-choice/two-round draft, unique
picks, zero preview power, explicit placed-ID commit and4active/1unlocked-foreign
limits. All60 unordered start pairs reached and committed in domain fixtures.
Schema1 explicitly refuses selectable-v2 data instead of stripping its meaning.
94scripts/700tests/8611assertions PASS with parse/error scan. Actual Main still
uses the legacy start/placement path: no24-effect,3x3start, new draft UI, schema2
or60-combat-pair acceptance claim. Next: bind book definitions/geometry and effect
consumers, then atomic profile2 and actual start/Workbench UI. Exactdf8b5b5 remote
checks passed; this increment requires own CI. Player default wallet/resume hashes
remain identical to the storage-isolation baseline after the700-test suite.

Newest save-safety prerequisite: existing RunResumeStore now readbacks/decodes
temporary and canonical bytes, rolls back old canonical on failed new readback,
and preserves failed/unresolved temporary candidates instead of silently
overwriting them.94scripts/694tests/7637assertions PASS; injected readback failures
and previous-cleanup warning covered. This is shared I/O preparation only, NOT
profile2 wallet/checkpoint atomic cutover, recovery UI or filesystem crash-proof
evidence. Exactced53fc both remote checks passed. Main's currently ignored
checkpoint-save failure and two-file retry remain explicit profile2 integration
gaps; do not claim whole-run durable settlement. P03 data/book preparation still
precedes the complete P04 schema2 cutover per implementation packet.

Newest Heukyeong increment: execution_charge is separate from live marks;
0.125/sec nearby charge, marked owned direct weapon/injutsu damage+0.25/max1sec.
Paired resolver event IDs capture pre-impact marks and actual damage, including
lethal cleanup, excluding normal DoT/summons/reactions/bursts/ultimate. Needle
explicitly labels direct_injutsu; other new books still need source classification.
Ultimate costs3 before effects, visible320 targets sorted boss/final->elite->normal,
distance then stable instanceID, at most3, damage26/18/18 plus fixed marked4.
Marks remain; no status multiplier and no implicit instant kill. Full94scripts/
691tests/7608assertions PASS; actual Main/button/noncombat and GPU role-fixture
damage checks passed. `reviews/heukyeong-execution-runtime-20260912.png` inspected:
existing hit feedback only, final execution VFX/production role art NOT verified.
Exact874d576 CI both passed. New increment needs own CI, no merge. Next focus:
profile2 transaction boundary, equipment/build/Workbench wiring,24books/start
selection and trace choices, settlement, then full normal-speed acceptance.

Newest Cheonsul increment:94scripts/686tests/7570assertions PASS including error
scan. Nearby live same-world targets gate0.125/sec base charge; wet->shock adds
0.25/max1persec, modifiers once, no paused/dead/active-breath charge. Preparation
cancels breath. A reproduced callback bug revived canceled breath during burn
processing; generation checks now prevent pending ticks from restarting it.
Real GPU Main button/breath/preparation-cleanup verified and capture inspected:
`reviews/cheonsul-breath-lifecycle-20260912.png`. Legacy automatic elemental casts
still await24-book cutover. Exact4fbed23 remote GUT/Windows checks passed; current
increment needs own CI. No full normal-speed/Human/device/whole-scope closure.

Newest Bongma increment:94scripts/682tests/7538assertions PASS with parse/error
scan. Living same-world target<=480 gates5/sec charge; owned nonultimate kills
give2 at most once/sec with death-ID dedupe. Resolver scopes synchronous damage
ownership and restores nested contexts. Ultimate pays100 only after two valid
dedicated familiars exist, immediate8damage each,0.5sec attacks for6sec, target320,
follow<=180 with separate formation positions. Legacy base familiar stays normal;
its removal depends on the24-book cutover, not this increment. Pause/death/
preparation/duplicate input/range/other-world cases covered. Actual Main GPU
capture `reviews/bongma-dedicated-familiars-20260912.png` inspected; HUD activation
and preparation cleanup verified. Legacy tiny art is not new-asset/Human approval.
Exact0fdc357 both remote checks passed. Bongma increment needs own CI; no merge.
Next: Cheonsul charge and lifecycle, Heukyeong ultimate, then remaining equipment/
profile2/24-book/trace integration and normal-speed full-run validation.

Current local increment: persistent six-slot buffer is connected to real Circuit
departure, retry, JSON save/load and following preparations; held items remain
outside resolved combat power. Existing stricter legacy RestBackpackSession mode
is retained by default. Known item IDs/unique instance IDs/next-ID/collision/
capacity/rotation are validated before replacement. Checkpoint capture/read now
copy RefCounted backpack/items/modifiers explicitly rather than aliasing objects.

Actual preparation now renders the existing spatial ShopController's three offers,
purchase, increasing-price reroll, and explicit selected-buffer sale. This is the
legacy item economy consumer, NOT the new external-equipment/profile2 cutover.
Full buffer blocks purchase without debit; explicit sale frees room for a chest.
Live GPU pointer selection/sale and exact refund verified using isolated QA paths,
without expanding the fixture board. See `reviews/preparation-shop-buffer-selected-20260912.png`.
UI remains provisional/plain and scroll-heavy; no Human/accessibility pass.
Latest full run after rotation-button correction and storage isolation:94scripts/
675tests/7475assertions PASS, including parse/error scan. Added a test-only storage
helper at36 Main entrypoints; explicit fixture paths remain intact. Actual default
wallet/resume SHA-256 stayed unchanged across this full run. Generated files in
`user://gut_main_isolated_20260912` are owned QA disposal candidates, not profiles.
Exact e9da812 remote checks passed. New increment needs its own CI; no merge;
whole-scope five-loop closure remains open.

Next: equipment/build/preparation/profile2 atomic binding; remaining school
charges/ultimates and24books/start choices/trace branch; final settlement and
normal-speed full-run validation. The entries below are historical increments,
not overriding current status. Buffer wiring is no longer an unimplemented item.

Latest Guiin refinement:93scripts/666tests/7358assertions PASS. Replaced hit/kill
charge and decay with4/sec for a living target<=480 plus4/sec for danger<=110;
modifiers apply once, no gain while paused/dead/form active. Form activation
requires a visible target<=168. Temporary sword inherits only current melee rank
(20/23/26/29/32 at ranks0..4), not the old weapon damage/shape. Tested all4melee
types×5ranks. Exact21ccd94 passed both remote checks; new changes need own CI.
Real GPU Main capture `reviews/guiin-sword-runtime-20260912.png` inspected:
actual HUD/input/sword-only mode, legacy art; tiny detailed actors remain a visual
quality issue. New equipment/profile2 integration, other school charges/ultimates,
24books/start choices/buffer/trace/full normal-speed flow remain open.

Newest local continuation:93scripts/662tests/7210assertions PASS. Guiin manual
input now starts a6second temporary sword profile (20damage,0.325sec,168range,
150degree cone), immediate strike, frozen original weapon clocks, no projectile
or school-damage channels. Already-fired owned projectiles are cleared so early
mode exit cannot revive them. Damaging auto-book casts pause; original profile
restores on expiration, preparation, death/deactivation and scene exit. Actual
Main input/preparation integration tested. Normal legacy Guiin resource gain/
decay and book behavior are still pending replacement, as are new charge rules,
damage tags, defensive books and exact new art. No Guiin render/Human pass.
Previous e3c2c49 exact head passed remote GUT/Windows artifact checks. Work remains
on current task branch; full implementation and five-loop completion stay open.

Continuation checkpoint: whole-run increment `efbf249` was pushed and its exact
head passed both remote checks (GUT and Windows internal build). No merge.
Latest local continuation:93scripts/659tests/7182assertions PASS, including error
scan. Hit protection0.35sec and entry protection1sec are wired into actual Main;
pause freezes protection, blocked hits do not extend it. Existing forced-death
fixtures now advance protection first; incoming-horde fixture disables outgoing
damage to keep its crowd alive and tests max1resolved hit/frame.

Equipment catalog/loadout:9definitions, external3slots, unique owned types,
per-instance ranks, replacement-before-sale and price-based proceeds. BasicWeapon
consumer now accepts validated copied equipment snapshots:4melee shapes,
kunai2shot, shortbow1pierce, fixed-position delayed powder blast. Projectile hit
sets prevent repeat contact/deferred-deletion double hits. These new equipment
profiles are component-tested, NOT yet Main/Workbench/shop/save-bound; no new
weapon visual approval or runtime-render claim. Next bind single RunBuildState
owner, preparation economics and profile2 together; old schema1 must not silently
discard new equipment or auto-convert changed inventory meanings.

ResumeStore now rejects invalid encoded candidates before touching the valid
record; previous-backup cleanup failure reports a warning instead of falsely
reporting committed data as rolled back. These fixes do not complete profile2
atomic wallet/settlement or crash/power-loss verification.

CONTINUOUS_WORK_ACTIVE. Base remote d830c0f freshly read; selective adoption in
the native work contract, not full adapter replacement. Current task remains
PR147/codex/replanning-art-motion-20260910; other PRs read-only.

Local implementation: foreign battlefield Elite/Boss progression no longer
requires an origin-only legacy scroll. Final preparation commits build/Fate
without a nonexistent fifth route. Fate pool with two remaining candidates stays
selectable. Actual Main now reaches a final calamity actor and completion view.
Final actor reuses existing school patterns/approved runtime assets provisionally,
HP1800 and clear-order quarters; theme changes wait for pattern/projectile/proxy
completion and never heal or clamp damage. New art is NOT approved by this wiring.

Earlier full GUT:92scripts/645tests/7055assertions PASS, engine-error scan included.
Earlier transient live-orb assertion failed; isolated and full reruns passed.
Real GPU Main fixture reached final preparation/battle/completion, with accelerated
time, forced kills and test-only expanded board. It exposed and fixed repeat-floor
negative-origin gaps and overflowing UI (native scroll, paths preserved). New
save-path injection isolates this fixture before Main ready. Dash now traverses
enemies while retaining terrain and restores exact masks. Origin identity remains
fixed; HUD uses current battlefield. First final-theme pattern gets0.2sec extra.
Actors/VFX remain tiny/overlapping. Terminal save/settlement, normal-speed runtime,
equipment/24books/draft/trace/save/ultimates/art queue remains.
No five-loop completion, merge or full-game completion claimed.

## Latest — breath rendering and basic combat continuation, 2026-09-12

IN_PROGRESS. User approved displayed breath appearance and resumed implementation.
VFX registered in existing Runtime Visual Core Manifest; aligned4frame Aseprite
source+JSON retained. Runtime follows player/fixed direction, pause freezes,
dash/deactivate/death hide, expiration fades; recast opacity reset regression added.
Godot4.7.1 OpenGL/NVIDIA3050 actual fixture capture:
`reviews/breath-runtime-20260912.png`; real existing scenes, no Main/profile/wallet.
Not a human test or full-run capture. Existing actors remain tiny/low-contrast.
Hera now points to GRIMOIRE; session list contains other projects only. No mutations
to them. Own CLI fixture used instead, no claim of Ninja live-editor attachment.

R-INPUT continuation: stationary dash uses last movement orDOWN; active reentry
and direct paused requests reject without spending. Katana120degree front cone
removes3target cap; shuriken targeting limited480; paused/dead direct weapon calls
reject. Stable instance-ID distance ties. Full GUT91scripts/637tests/6936assertions
passed after RED failures; error/warning scan included. No final5-loop or merge.

Remaining: equipment3slots/8weapons/outfit and committed-preview transaction,
24books/start2draft/bag rules, new charge/other ultimates, schema2 wallet+save,
trace/route/economy/UI, collision-through dash and hit/entry protection, complete
art and end-to-end/Human/device validation. Basic-weapon VFX cone agreement still
needs render review; old slash asset was not newly approved. Continue approved work.

## Latest — integration continuation checkpoint, 2026-09-12

User authorizes all previously listed implementation work through integration
validation. Work remains IN_PROGRESS, not complete and not ready to merge.
Breath additions: actual automatic-weapon direction before first movement,
visible-in-viewport activation eligibility, geometry/death/pause/deactivation
tests, and real Main HUD button -> Host -> breath -> dash cancellation test.
Godot4.7.1/GUT9.7.1:91 scripts,629/629 tests,6896 assertions, no error/warning.
One intermediate run skipped a test script due to type inference errors;
its602-test green banner was REJECTED. Explicit types corrected the fixture;
final scan checked engine errors, warnings and expected script coverage.
Candidate `visual/candidates/breath-20260912/README.md` owns new VFX provenance,
alpha checks and required alignment. It is NOT_LOCKED and not bound to runtime.
No claim of full-run/new-design integration, render/Human/device pass or five-loop
completion. Other equipment/book/save/trace/UI packages listed below remain open.
Current Hera pid37728 belongs to OMENWARD, not this project; no mutation there.
Next: approve/refine breath appearance, align/export, exact Ninja render session;
continue equipment/start draft/24book/ultimate/save/route/UI packages as authorized.

Cleanup readback: local date folder currently contains breath-test-download;
the historical README mentioned below was not found. Do not repeat its claimed
counts as current or infer deletion. No disposable files deleted this turn.

## Latest — implementation resumed, 2026-09-12

Latest user explicitly requested remaining implementation inspection and execution.
This supersedes planning-only continuation below, not final art/Blueprint approval.
Current-task Draft147 now contains a local Cheonsul forward-breath logic increment:
fixed movement-facing direction, moving origin, six ticks, range/cone targeting,
status bonus without consumption, dash cancellation and pause request guard.
GUT on Godot 4.7.1 / GUT 9.7.1: 623/623 tests, 6860 assertions (91 scripts).
An additional RED test exposed status expiry during large-delta catch-up; corrected
by advancing status time before each tick. Runtime visual/Human validation NOT_RUN.
Not merged/pushed for this increment. Full five-loop completion gate remains open.
Remaining breath work: auto-weapon-facing fallback before first movement, visible
target policy, dedicated VFX, expanded death/angle/range boundaries and final review.
Remaining product work: equipment slots/24 books/start draft, charge redesign,
other ultimates, schema2 persistence, trace/route/economy, UI/art and full-run QA.
Do not interpret passing legacy-catalog tests as these packages being implemented.

## Latest — user-managed cleanup, 2026-09-12

User requests confirmed disposable files gathered for manual deletion, never
directly deleted by the agent. Local review folder:
`C:/Users/user/Documents/GitHub/Ninza/DELETE_REVIEW/ninja-survival-godot/2026-09-12/`.
Its README owns exact local sources/counts/reasons. Original dirty checkout,
assets/provenance/PDF publications and registered worktrees remain preserved.
Planning continuation is unchanged: integrate legacy book/route/economy and visuals.

## Latest — breath / sword-only ultimate revision

User replaces Cheonsul area blast with forward elemental breath and Guiin radial
pulse with stronger sword-only offense. R-ULTIMATE contains proposed geometry,
timing, non-sword attack suppression and restore semantics. Temporary Guiin sword
for every melee loadout is direction-approved by the user's 2026-09-12 continuation.
The former asynchronous question is resolved; no art LOCK is implied.
Checkpoint fields now separate persistent charge from temporary effects.
No code/image/PDF changes. Next: integrate legacy book/route/economy text and
visuals before final Blueprint publication; runtime checks remain NOT_RUN.

## Current — three equipment slots / ninja outfit / one-item trace upgrade

Latest user moved katana, shuriken and ninja outfit outside backpack. The 8/9-cell
start below is historical: two starting books now use 4/9 cells. Updated owners:
Detailed Rules R-EQUIPMENT/R-LOADOUT/R-TRACE and Implementation Packet.
Stage trace upgrade forfeits that school's ninjutsu access and upgrades one item.
Starting-school exception is USER_APPROVED: retain access/books, enhancement only.
R-NINJUTSU now specifies 24 effects; R-WEAPON-CONTENT specifies eight weapons;
R-COMBINATION specifies three support recipes without consuming equipped gear.
These are delegated review specs, not runtime/asset/final approval. Actual current
catalog remains twelve and old acquisition lanes; do not confuse source tables
with implemented definitions. R-ULTIMATE now specifies independent combat charge,
school bonuses and book-independent manual effects for all 60 starting spell pairs.
This is delegated review design only; pair-wise execution remains NOT_RUN.
73-page PDF is preserved previous publication, not this revision; its live source
hash comparison is now stale. No gameplay mutation or merge. Next: synchronize
remaining book/economy/art and route/save boundaries, then export/review. No repeat
question about the starting-school exception is needed.

## Historical approval — starting contents use backpack, 2026-09-11

User approved the prior revision direction and explicitly rejected free intrinsic
starting spells/equipment. All four initial contents (katana, shuriken, two picked
ninjutsu books) occupy the 3×3 bag. The approved direction plus recommended 8/9-cell
initial packing lives at the top of the change analysis below. Reconcile detailed
rules, item/activation contracts, initial-arrangement screen, packet and the next
PDF together; do not resume the old bag-free automatic-weapon implementation.
Final art/cutout/motion work and revised Blueprint remain pending; no game mutation.

## Follow-up review — tags / draft / trace / player, 2026-09-11

The user requests five tag families, two three-choice starting-ninjutsu picks,
more weapons/ninjutsu and a more appealing anime player. Absorb-versus-strengthen
after Stage clear is explicitly under consideration, not final approval.
Current change proposal: `research/2026-09-11-tags-draft-and-trace-review.md`.
The 73-page PDF below remains the previous review snapshot, not a publication of
this follow-up. Reconcile rules, packet, visual tables and PDF after resolving
these product choices; do not start the previous P01 unchanged.
Player appearance: `visual/candidates/player-refinement-20260911/README.md`.
Appearance source prepared, but clean-cutout QA failed; no runtime asset LOCK.
Weapon/ninjutsu additional imagery and player motion remain pending.

## Active task override — 2026-09-11

- Scope: HUMAN_BLUEPRINT_AND_IMPLEMENTATION_INPUT_PREPARATION. Latest user
  explicitly reopened needed image/atlas production; the image pause below is
  historical. No new game implementation, save migration, canonical asset LOCK
  or combined Draft PR #147 merge is authorized by this preparation task.
- Reader source: `design/NINJA_SURVIVAL_HUMAN_BLUEPRINT.md`; detailed rules remain
  `design/NINJA_SURVIVAL_DETAILED_RULES.md`; technical handoff is
  `design/NINJA_SURVIVAL_IMPLEMENTATION_PACKET.md`.
- Current bounded workflow: user review of the new standalone PDF at
  `../exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_20260911.pdf`. Source/asset checks
  and player Aseprite pixel comparison are separate from gameplay verification.
  Review/delivery evidence: `reviews/2026-09-11-human-blueprint-review.md`.
  Final design and asset LOCK pending; next safe product work after approval
  is P01 in the implementation packet, not automatic merge of combined PR #147.
- Working location: rediscover current continuation worktree/PR before mutation;
  do not infer main from the old checkout or dated PR evidence below.

## Active task override — 2026-09-10

- Latest scope: PLANNING_ONLY_DELEGATED_DETAIL_SELECTION. The user asked to
  review planning before images, then delegated Internet-informed detailed rules.
- Current detail owner: `design/NINJA_SURVIVAL_DETAILED_RULES.md`;
  DELEGATED_DESIGN / SPECIFIED_FOR_REVIEW, not implemented or Human approved.
- Next: read the detail owner and its review record, then refine implementation
  readiness and representative-slice requirements within planning. Do not resume
  floor repair, image generation, asset binding or save migration in this step.
- Delivery/readback for this documentation package:
  `reviews/2026-09-10-detailed-rules-review.md`.
- Resume: PLANNING_REOPENED_BY_USER; read the dated restart entry in Decisions.
- Scope confirmed: full product reassessment, including genre/core; existing
  elements are reusable inputs evaluated through evidence, not deletion targets.
- Research: docs/research/2026-09-10-full-product-reassessment.md (PARTIALLY_DECIDED).
- Approved: A+B = auto ordinary attacks; direct movement, invulnerable dash,
  pattern counterplay and ultimate timing. No manual ordinary attack mode.
- Blueprint: dated A+B section in docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md
  defines representative decisions, input/HUD gaps, motion and acceptance targets.
- Current branch implementation: E / pad Y / top-button ultimate request, existing
  runtime readiness and failure feedback. See `reviews/2026-09-10-manual-ultimate-review.md`
  for exact tests, live input capture, limitations and delivery status.
- Delivery: Draft PR #147; implementation `33ece77` passed GUT and Windows
  internal build CI. Resolve current final-head checks from that PR; not merged.
- Deferred implementation follow-up: repair/verify the observed battlefield
  coverage gap when runtime work resumes. The latest planning-only request
  overrides this as an immediate action. New art remains candidate-only.
- Candidate: docs/visual/candidates/ab-gameplay-composition-v1.png; one generated
  and visually inspected composition, no baked UI, no runtime binding or motion.
  Prompt/source/hash and concerns are in its adjacent candidate receipt.
- Old images: REFERENCE_ONLY_FOR_NEW_CYCLE; existing runtime binding remains.
- Existing PDF: historical design/reference, not the new Blueprint approval gate.
- Read baseline: origin/main b5c2dd61cd589ebd218d1b4da3f016fb94a02126.
- Open PRs observed: #135 and #49; both read-only. #135 overlaps visual, combat,
  scene and decision files; its selected earlier changes already have #139 lineage.
- Base observed: 2f93e872d9ed4fa18018ac759b01acd7d34e9b58; selective routing only.
- Aseprite: CLIENT_DISCOVERED and CALL_VERIFIED by candidate-only canvas creation
  and metadata readback (16×16, RGB, one 100ms frame). This is a transport probe,
  not image, motion, export, runtime or Human completion.
- New game design/art direction: control boundary approved; new art not locked.
- Resolved source finding: MainController/HUD/project input now connect to the
  existing school ultimates on this branch (not merged main). Cheonsul may be charged
  yet reject activation when no status-bearing target exists. Do not invent a
  new resource owner or report readiness as guaranteed successful activation.
- Research evidence: official product comparison, professional sources and small
  response sample; full redesign/Human/device validation NOT_RUN. Bounded live
  E/button activation was observed; live paused-input QA was blocked by the
  temporary inspector pausing with SceneTree. Automated modal checks are separate.

The older router block below is the previous cycle's evidence snapshot. Its
resume/next-gate/style statements do not override this active-task entry.

```yaml
project: NINJA_SURVIVAL
state_router_updated_at: 2026-09-02 KST
reactivation_reason: USER_APPROVED_PLANNING_CANON_AND_HUMAN_HOME_ALIGNMENT
completed_main_at_reactivation: 265bab32da087c070ea2ea0d98a3bdace1e10f7f
current_completed_main: RESOLVE_FROM_REPOSITORY_DEFAULT_BRANCH
current_completed_main_resolution: FRESH_GITHUB_DEFAULT_BRANCH_READ_REQUIRED
last_completed_main_read: 57ba43973c5e1b67c82b52921014db0a97a63378
last_completed_main_read_receipt: PR129_SQUASH_MERGE_POST_MAIN_READBACK_2026_08_29_KST
completed_main_label: T12_TO_T16_AND_PHASE2_FOUR_SCHOOL_MACHINE_SCOPE_RECONCILED
resume_state: FOUR_SCHOOL_CIRCUIT_MACHINE_IMPLEMENTED_MERGED_MAIN_PR129
next_product_gate: STATUS_ICON_ASSET_LOCK_OR_SEPARATE_FINAL_PACKAGE_DEFINITION
current_master_gdd: docs/design/NINJA_SURVIVAL_MASTER_GDD.md
current_human_gdd: docs/design/NINJA_SURVIVAL_HUMAN_GDD.md
current_human_blueprint_spec: docs/implementation/2026-08-30-player-control-stage-backpack-blueprint-spec.md
current_player_control_stage_backpack_canon: docs/canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md
human_blueprint_runtime_authority: USER_FINAL_PDF_REVIEW_PENDING
player_facing_vocabulary: STAGE_AND_PHASE
backpack_starting_usable_area: EXACT_3X3
human_player_gdd_pdf: exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf
human_player_gdd_pdf_manifest: docs/publication/NINJA_SURVIVAL_HUMAN_GDD_PDF_MANIFEST.json
human_player_gdd_pdf_status: CURRENT_ON_BRANCH_PENDING_MAIN_PUBLICATION_DD047E45E70091D1B4851E0042931D1235BEE6B2
current_integrated_human_blueprint_pdf: exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf
current_integrated_human_blueprint_pdf_manifest: docs/publication/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_PDF_MANIFEST.json
current_integrated_human_blueprint_pdf_status: ARTIFACT_CURRENT_ON_MAIN_POST_READBACK_E39ADE1CEF351ED0323FD450F051EA3439D706C0_38_PAGES_PRESERVED_28_PLUS_CURRENT_VISUAL_COMPANION
current_integrated_human_blueprint_pdf_baseline_main: 16cf7a6bb2a8676ad979985605d66f1ca3edd28c
current_integrated_human_blueprint_pdf_main_readback: PR_145_E39ADE1CEF351ED0323FD450F051EA3439D706C0_SHA256_DFF66D9E1937D2E1335406CF82D16F18A9309715C30A6B355A107AEADE2931A0
current_integrated_human_blueprint_pdf_scope: THREE_GUIDE_PAGES_PLUS_UNCHANGED_HISTORICAL_28_PAGE_OBJECTS_PLUS_SEVEN_CURRENT_MAIN_WIREFRAME_FLOW_LOCKED_IMAGE_PAGES
current_integrated_human_blueprint_pdf_evidence: FOCUSED_EXPORT_TEST_PASSED_PDFINFO_PYPDF_FULL_38_PAGE_RENDER_AND_CODEX_VISUAL_INSPECTION_PASSED_HUMAN_REVIEW_NOT_RUN
mandatory_work_gate: FRESH_READ_REUSE_FIRST_TARGETED_WEB_RESEARCH_FEASIBILITY_AND_ADVERSARIAL_REVIEW_UNTIL_CLEAN
current_project_work_contract: docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md
current_base_observation: 19355b7ef065a21d0f2b685c7d9be64a4a3970f8
base_adaptation_state: ADAPT_ACTIVE
full_base_adapter_state: NOT_INSTALLED_SEPARATE_ONBOARDING_REQUIRED
repository_only_policy: docs/canon/2026-08-28-dec035-repository-only-project-record.md
notion_usage: HISTORICAL_REFERENCE_ONLY_MIGRATION_COMPLETE
notion_migration_manifest: docs/migration/notion/MIGRATION_MANIFEST.md
latest_docs_alignment_plan: docs/superpowers/plans/2026-08-25-planning-canon-human-home-alignment.md
current_visual_handoff: docs/CURRENT_VISUAL_HANDOFF.md
current_screen_visual_coverage: docs/visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md
current_screen_blueprint: docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md
current_screen_blueprint_state: CURRENT_MAIN_RECONCILIATION_MERGED_MAIN_PR143
current_screen_blueprint_predecessor_pr: PR_137
current_screen_blueprint_predecessor_exact_pr_head: b54819336c75aab6d60606821a6a734049406f2e
current_screen_blueprint_predecessor_merge: e6cbaedfa558f9646dc7cd960c2ef06ac67a9549
current_screen_blueprint_reconciliation_baseline: 477ac7343bd655278d4f045d3152f6b7e4214062
current_screen_blueprint_reconciliation_pr: PR_143
current_screen_blueprint_reconciliation_exact_pr_head: 7316c7aafd445815d1d86668dd2cee15312e9b12
current_screen_blueprint_reconciliation_merge: 77fc0509662b0ec580425ec4b38e76c254b78903
current_screen_blueprint_reconciliation_ci: GUT_AND_WINDOWS_INTERNAL_BUILD_ARTIFACT_SUCCESS
current_screen_blueprint_reconciliation_main_readback: TREE_EQUIVALENT_TO_EXACT_PR_HEAD
current_screen_blueprint_reconciliation_plan: docs/superpowers/plans/2026-09-02-blueprint-regression-repair.md
current_screen_blueprint_reconciliation_review: docs/reviews/2026-09-02-blueprint-regression-repair-adversarial-review.md
current_screen_blueprint_visual_input: REUSES_FIVE_LOCKED_SCREEN_REFERENCES_NO_NEW_IMAGE_BINARY
current_title_medal_secondary_scale: DEC043_USER_APPROVED_SEPARATE_MEDAL_APPROX_NIN_GLYPH_HEIGHT_MERGED_MAIN_PR141_D0E49D0685803849E9013F482F7452830ABBF5D4
current_title_medal_secondary_scale_branch: PR141_MERGED_REMOTE_BRANCH_DELETED
current_title_medal_secondary_scale_plan: docs/superpowers/plans/2026-09-02-title-medal-scale.md
current_title_medal_secondary_scale_review: docs/reviews/2026-09-02-title-medal-secondary-scale-adversarial-review.md
current_title_medal_secondary_scale_machine_evidence: RED_FOCUSED_GUT_0_OF_1_45_OF_48_THEN_GREEN_1_OF_1_48_GODOT_4_7_1_IMPORT_EDITOR_PARSE_MAIN_SMOKE_FULL_GUT_605_OF_605_6794_PASS
current_title_medal_secondary_scale_remote_ci_and_readback: PR141_GUT_AND_WINDOWS_INTERNAL_BUILD_ARTIFACT_PASS_MERGED_MAIN_D0E49D0685803849E9013F482F7452830ABBF5D4_TREE_IDENTICAL_TO_EXACT_PR_HEAD
current_title_medal_secondary_scale_render_human_device: NOT_RUN_NO_EXACT_NINJA_SURVIVAL_HERA_EDITOR_SESSION
pr135_owner_branch: READ_ONLY_USER_APPROVED_SOURCE
pr135_owner_exact_head: d65a712d441d3ca854ee8ae2edff468bb4974983
pr135_current_main_reconciliation: MERGED_MAIN_PR139_3428F916F20F545284C337C7EB41B0EACF268351_POST_MERGE_MACHINE_VERIFIED
pr135_reconciliation_contract: docs/operations/receipts/2026-09-01-pr135-current-main-reconciliation-preflight.json
pr135_reconciliation_plan: docs/superpowers/plans/2026-09-01-pr135-current-main-reconciliation.md
pr135_local_machine_evidence: PRE_MERGE_FOCUSED_GUT_55_OF_55_585_ASSERTS_PR139_EXACT_HEAD_GUT_AND_WINDOWS_INTERNAL_BUILD_SUCCESS_POST_MERGE_GODOT_4_7_1_IMPORT_MAIN_SMOKE_FULL_GUT_605_OF_605_6789_ASSERTS_PASS
pr135_scoped_runtime_evidence: FRESH_EDITOR_TITLE_STAGE_SELECTOR_INPUT_MAP_AND_INITIAL_HORDE_TREE_OBSERVED_NO_SOURCE_ERRORS
pr135_reconciliation_evidence_ceiling: MERGED_MAIN_AND_POST_MERGE_MACHINE_READBACK_COMPLETE_HUMAN_PLAYER_DEVICE_EXPORT_AND_BALANCE_GATES_NOT_RUN
pr135_human_player_device_export_balance: NOT_RUN
current_implementation_contract: docs/implementation/2026-08-29-four-school-circuit-implementation-contract.md
current_phase2_definition_of_ready: docs/planning/2026-08-29-phase2-four-school-definition-of-ready.md
current_contract_adversarial_review: docs/reviews/2026-08-29-four-school-contract-adversarial-review.md
current_phase2_execution_adversarial_review: docs/reviews/2026-08-29-four-school-circuit-execution-adversarial-review.md
human_player_build_gate: DEFERRED_BY_DEC036_NOT_RUN
historical_closed_wip:
  - PR_43_T12_ATOMIC_WORKBENCH
  - PR_44_FRONT_DOOR_DOCS
other_workstream_read_only:
  - PR_49_T12_ATOMIC_WORKBENCH_FATE_ROUTE_COMMIT_SUPERSEDED_BY_PR_61
mvp0_to_mvp3_runtime: INTEGRATED_BASELINE
mvp4_t01_to_t11_domain_chain: INTEGRATED_ON_COMPLETED_MAIN
playable_new_four_school_run: MACHINE_CIRCUIT_THROUGH_FINAL_BINDING_ELIGIBILITY_VERIFIED_MERGED_MAIN_57BA439_HUMAN_NOT_RUN
persistent_workbench_route_ui_input: INTEGRATED_ON_MAIN_71152C7AA9DFF4CC05EEC76D4D2D70BE47755F6C
release_near_cheonsul_slice: MERGED_MAIN_51E39737F272DB0962A3DABADA51BAE10CD1FA97_AUTOMATED_EVIDENCE_ONLY
t15_school_function_help: MERGED_MAIN_E2CFE4452E1DE5A224F5CD7DEE8E47A104C868E0_MACHINE_VERIFIED_HUMAN_QA_DEFERRED_BY_CURRENT_USER
t16_in_combat_school_help: MERGED_MAIN_63FCF81FDF4B5D1BBFF14B5721A13F7C1AFE1497_MACHINE_VERIFIED_RUNTIME_INPUT_DELIVERED_HUD_MODAL_VISUAL_SEMANTICS_NOT_CONFIRMED
windows_internal_build: MERGED_MAIN_0F085FC4FEFF25353C049749BF34236A89C01BE4_CI_ARTIFACT_AND_LOCAL_EXPORT_RUNTIME_SMOKE_PASS
windows_internal_build_boundary: INTERNAL_VALIDATION_ONLY_NOT_PUBLIC_RELEASE_OR_DEVICE_EXPORT
human_usability: NOT_RUN
player_experience: NOT_RUN
device_export_android: NOT_RUN
current_visual_style: HYBRID_MASTER_PRESENTATION_INK_CODEx_GAMEPLAY_ANIME_SD_C_LEANING
runtime_character_visual_identity: ONE_FIXED_CHARACTER_PLUS_TRACE_LAYERS
trace_stage3_visual_rule: STARTING_MAIN_SCHOOL_ONLY
cheonsul_visual_palette: BLUE_PLUS_AMBER_ORANGE_PRIMARY
heukyeong_visual_palette: PURPLE_PLUS_BLACK_RESERVED
combat_status_presentation: ICON_FIRST_APPROVED_RUNTIME_ASSET_PARTIAL_LEGACY_TEXT_BADGE_REMAINS
enemy_hp_presentation: HIDDEN_BY_DEFAULT_SHOW_ONLY_RECENTLY_HIT_ENEMY_MACHINE_IMPLEMENTED_MERGED_MAIN_57BA439
historical_visual_keyvisual_notion_preview: SERVER_READBACK_PASS_LOW_RES_RETIRED
historical_visual_supplementary_previews: SERVER_READBACK_PASS_LOW_RES_RETIRED
img_02_runtime_visual_core: MERGED_MAIN_03005E7_SEVEN_APPROVED_PNGS_LOCAL_SOURCES_CURRENT_HISTORICAL_NOTION_ATTACHMENTS_RETIRED
img_02_automated_evidence: GODOT_4_7_1_IMPORT_EDITOR_PARSE_MAIN_SMOKE_GUT_492_OF_492_5373_ASSERTIONS_PASS
img_02_live_render: NOT_RUN_HERA_CONNECTED_TO_DIFFERENT_PROJECT
img_03_runtime_battlefield_backdrop: MERGED_MAIN_5A52A30_LOCAL_SOURCE_CURRENT_HISTORICAL_NOTION_ATTACHMENT_RETIRED
img_03_automated_evidence: GODOT_4_7_1_IMPORT_EDITOR_PARSE_MAIN_SMOKE_GUT_493_OF_493_5380_ASSERTIONS_PASS
img_03_live_render: NOT_RUN_DESKTOP_VISUAL_TARGET_CHANGED
runtime_battlefield_floor_tile_01: USER_LOCKED_IMPLEMENTED_ISOLATED_BRANCH_MACHINE_AND_SCOPED_RUNTIME_RENDER_INPUT_VERIFIED_NOT_MERGED
runtime_battlefield_prop_shadow_batch: USER_LOCKED_IMPLEMENTED_ISOLATED_BRANCH_MACHINE_AND_SCOPED_RUNTIME_RENDER_INPUT_VERIFIED_NOT_MERGED
runtime_battlefield_prop_shadow_review: docs/reviews/2026-08-30-runtime-battlefield-props-and-shadows-adversarial-review.md
local_shared_godot_exact_pin: GODOT_4.7.1_STABLE_OFFICIAL_A13DA4FEB_FRESH_LOCAL_VERIFIED_2026_08_27_KST
local_editor_session: HEADLESS_EDITOR_PARSE_PR129_HEAD_PASS
phase2_shared_four_school_circuit: MACHINE_IMPLEMENTED_MERGED_MAIN_PR129
phase2_trace_and_recent_hit_hp: MACHINE_IMPLEMENTED_MERGED_MAIN_PR129
phase2_workbench_reward_board_combination_route_fate: MACHINE_IMPLEMENTED_MERGED_MAIN_PR129
phase2_economy_checkpoint_retry: MACHINE_IMPLEMENTED_MERGED_MAIN_PR129
phase2_status_icon_runtime_asset: PARTIAL_AWAITING_USER_LOCKED_ASSET
phase2_final_binding_and_true_run_settlement: OUT_OF_SCOPE_NOT_IMPLEMENTED
phase2_machine_evidence: GODOT_4_7_1_LOCAL_EDITOR_PARSE_PASS_HEADLESS_MAIN_SMOKE_PASS_GUT_521_OF_521_5769_ASSERTIONS_GITHUB_GUT_AND_WINDOWS_PASS_PR129
```

## 2026-09-01 screen Blueprint — historical predecessor

`NS-BLUEPRINT-001` is the editable screen-flow/wireframe/consumer-link
surface at `docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md`. It records the
Title → Stage → Core/Elite/Trace/Boss → Result → Workbench/Fate journey, six
screen hierarchies, top-only battle HUD, and the dynamic-UI versus image/VFX
boundary. The six-whole-scope-loop review is
`docs/reviews/2026-09-01-screen-blueprint-adversarial-review.md`.

PR #137 was squash-merged at
`e6cbaedfa558f9646dc7cd960c2ef06ac67a9549` after the exact PR head
`b54819336c75aab6d60606821a6a734049406f2e` passed the `gut` and Windows
internal-build-artifact checks. Fresh `main` readback confirmed the merged tree
is identical to that PR head.

The predecessor package reused the already user-locked `SCRREF-BATTLE-AUTOCOMBAT-03` for
continuous-floor, sparse-prop, grounded-unit, top-HUD composition and created
**no** new image binary. PR #135 title assets/functions remain open-PR,
read-only references rather than current-main implementation truth. The
Blueprint has repository/documentation and exact-PR-head CI evidence only;
Godot runtime/render, Human Play, Player Experience, touch/gamepad, and
device/export evidence remain `NOT_RUN`.

## 2026-09-02 screen Blueprint — current-main reconciliation merged

The user reported that the newer screen Blueprint had regressed relative to
the prior reader-facing Blueprint. The merged atlas at
`docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` therefore preserves the 28-page
Human Blueprint/PDF as the first reader route, restores a five-image locked
reference atlas, and updates stale `planned` Title/3×3/Stage/Phase wording
against current main `477ac7343bd655278d4f045d3152f6b7e4214062`.

PR #143 squash-merged this documentation-only package at
`77fc0509662b0ec580425ec4b38e76c254b78903` after exact head
`7316c7aafd445815d1d86668dd2cee15312e9b12` passed `gut` and Windows internal
build checks; fresh `origin/main` tree readback was equivalent to that head.
No scene, script, save structure or image binary changed. Live render, Human
Play, Player Experience, touch/gamepad and device/export remain `NOT_RUN`.

## Purpose

This is the mutable resume router. Product rules live in `docs/CURRENT_CONFIRMED_DECISIONS.md` and dated canon files. Implementation facts live in actual code/scenes/data/tests and executed evidence. Human-facing game understanding lives in `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`. Current visual continuation lives in `docs/CURRENT_VISUAL_HANDOFF.md`; DEC-035 preserves and maps the former Notion surface before repository-only cutover.

Do not reconstruct current state from older handoff sentences or closed branches without first reading current completed `main`, current open-PR inventory and this router.

## Current read order

1. `AGENTS.md`
2. latest user instruction / active task contract
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. `docs/CURRENT_VISUAL_HANDOFF.md` when the task touches art / visual / asset / presentation
5. `docs/canon/2026-08-21-dec014-025-product-canon.md`
6. `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
7. `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`
8. `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
9. `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`
10. actual `scripts/`, `scenes/`, `data/`, `tests/`, workflows
11. `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`, `docs/CURRENT_VISUAL_HANDOFF.md`, relevant asset manifests/provenance
12. current Base owners when Base freshness materially affects the task

Closed PR #43/#44 may be inspected only as historical/WIP evidence. They are not resume baselines. Draft PR #49 is a read-only, superseded T12 reference. PR #61 is merged T12 history; current production work begins from its completed `main`.

## Current product direction

`닌자의 신 / 닌자 서바이벌` is a 2D survival roguelike where the player:

```text
starts from one ninja school
-> freely chooses among unvisited school battlefields
-> learns that school's Core/Elite/Boss encounter language
-> recovers its trace and opens tradition acquisition access
-> returns to the shared frontier branch
-> rebuilds a 6x6 spatial backpack through reward/shop/chest/rotation/adjacency/combination
-> provisionally chooses the next school
-> commits build + Fate + route together
-> clears all four schools exactly once
-> enters Final Binding Workbench
-> defeats the separate calamity core with the player-built backpack power
-> receives final result / Ninja Soul / legend callback
```

`~20 minutes` targets active combat through the fourth school Boss, not the whole Run.

## Current four-school identity

- **봉마류:** mobile stronghold — prepare space, familiars/barriers fight for you.
- **천술류:** setup + ordered elemental/status reactions transform the field. Strong chained reactions are spatially guided by player movement and grouping while basic combat stays automatic (DEC-027; implementation deferred).
- **천술류 공간 조건:** a short fixed blue setup seal remains at the automatic `WET` cast point; automatic `SHOCK` should prefer its prepared group for the higher-value amber/orange chain (DEC-028; exact values and implementation deferred).
- **귀인류:** sustain dangerous close-range presence for power; not universally low-HP-only.
- **흑영류:** mark/priority/execution removes dangerous targets first through auto-combat-compatible indirect control.

### 2026-08-28 DEC-029 validation-scope override

- The user selected the all-four-school boundary: do not start Human/Player validation after Cheonsul alone.
- First implement and machine-verify the shared Core → Elite → Trace → Boss → Result/Reward → Workbench → next-unvisited-school lifecycle for Bongma, Cheonsul, Guiin and Heukyeong.
- Preserve shared encounter/route/Backpack/Workbench owners; do not create four independent engines.
- Final Binding Workbench, final calamity and final ending remain a separately reviewed later package under DEC-030.

### 2026-08-28 DEC-030 first Human validation endpoint

- The user selected the endpoint before the final package: the first four-school Human/Player validation ends after the fourth Boss Result/Reward confirms existing `final_binding_eligible`.
- No Final Binding Scene, final calamity Boss, support callback, final result or placeholder ending is included in this contract.
- The product's final-calamity promise remains protected for a later separately reviewed package; this decision only prevents it from silently expanding the current four-school contract.

### 2026-08-28 DEC-031 default Run-end + one emergency retry — PARTIALLY SUPERSEDED

- Default death ends the Run. One explicit retry per Run may restore the last successful Workbench checkpoint and restart the same active school from `0:00`.
- Failed-school transient GOLD/rewards/Trace/progress are lost. Currency and durable settlement semantics are owned by DEC-033; no automatic revive or retry recharge is allowed.
- Current-task branch implementation restores the committed checkpoint in-place after one paid retry. It is machine-verified only; Human/Player/device evidence remains `NOT_RUN`.

### 2026-08-28 DEC-032 optional expanded school help

- Do not force a first-30-second tutorial prompt, card or action marker. A player who wants clarification may open a longer Korean explanation for the currently selected school through the existing combat help route.
- The explanation must connect actual risk processing, what to watch, movement/positioning intent, and an observable success signal without promising unimplemented mechanics or moving auto-combat authority into UI.
- Optional help is not evidence that an unassisted first-30-second reading works. Human/Player evidence remains `NOT_RUN`.

### 2026-08-28 DEC-033 Run-end Ninja Soul settlement

- GOLD is transient Run economy: normal enemies have recommended 20% chance for 1G; Elite gives 5G; a school Boss gives 10G. Exact normal chance is a data-tunable balance recommendation, not validation evidence.
- Persistent Ninja Soul is settled once only at Run end: distinct school Boss clears give 2 each and progress rank C/B/A/S gives 0/1/2/4 for 0/1/2–3/4 Boss clears.
- Elite grants no Ninja Soul. Boss eligibility survives a retry only as an idempotent settlement ledger; retry uses 1 persistent Ninja Soul, remains one per Run, and needs a valid Workbench checkpoint.
- Fourth-Boss `final_binding_eligible` is only the first Human Slice endpoint, not true Run end; it grants no Ninja Soul until the separately reviewed final package resolves the Run.

### 2026-08-28 DEC-034 generate-then-approve visual workflow

- After a fresh consumer or planning-board brief exists, generate one visual candidate without a separate pre-generation approval prompt. The user then chooses `LOCK`, `REVISE`, or `REJECT`.
- Do not generate at chat start, for a vague gap, or to replace an approved asset. Candidate images are not project assets/runtime evidence before `LOCK` and the normal provenance/consumer gates still apply.

### 2026-08-28 DEC-035 repository-only project record

- The current Notion structure and work products are preserved in `docs/migration/notion/`. The source remains intact and has not been modified or deleted.
- Repository Master GDD, current decision ledger, visual handoff, asset provenance/manifest, code, tests, and evidence are the active owners. Post-merge main readback is complete; Notion is `HISTORICAL_REFERENCE_ONLY`.

## Current integrated implementation truth

### MVP-0~3

Integrated and retained as rollback/regression baselines where newer behavior has not deliberately replaced them.

### T01~T05

Integrated spatial foundation:

- definitions/catalog
- committed `BackpackState`
- deterministic `BackpackResolver`
- REST `RestBackpackSession`
- atomic first-tier `CombinationResolver`

### T06

Committed spatial modifier snapshot became the single item/spatial combat modifier authority without legacy double application.

### T07

Boss/Shop/Chest acquisition transactions route acquired items/bags through bounded spatial REST transaction ownership.

### T08

`RunRouteState` owns provisional/active/cleared schools, Stage 1..4 progression and clear order; revisits are rejected and fourth clear leads to Final Binding eligibility.

### T09

Four-school encounter definitions and shared Stage profiles are data/domain integrated, including bounded DEC-026 primitive vocabulary and Cheonsul first-slice data.

### T10

Elite warning/active -> chest token + non-expiring trace -> trace recovery -> Boss warning/dual gate -> Boss active/clear lifecycle is domain integrated.

### T11

Run-level tradition access and reward lanes are integrated over the existing canonical 19 base-acquisition item IDs:

- Universal 7 + school package 3 x 4 authoring model
- starting-school access
- stabilization opens package
- Boss continuity / newly liberated tradition / bridge-universal lanes
- Shop/Chest lane-first selection
- canonical item-ID dedupe

T11 exact merged evidence recorded in Production Handoff:

`Godot 4.7.1 import PASS -> main smoke PASS -> GUT 447/447 -> 4985 assertions -> T11 core 9/9 + adversarial 8/8 + clean re-attack 5/5`.

Evidence ceiling: domain/automated scope only.

## T12 merged status

**MERGED TO `main` AT `41202283b75921efb7691e77c3de1502d77410d1`.**

PR #61 `T12: atomically commit Workbench snapshot, Fate, and route` is merged production history. Its post-merge automated evidence is `Godot 4.7.1 import PASS -> main-scene smoke PASS -> GUT 471/471 -> 5168 assertions`; this is not Human, Player Experience, device, or end-to-end Run evidence.

PR #49 `T12: atomic Workbench Fate route commit` and historical PR #43 remain read-only WIP/reference only. Do not reopen, rebase, merge or absorb either branch.

Current approved T12 outcome remains:

- Workbench route stays provisional until commit.
- finalized backpack snapshot + one pending Fate + one provisional unvisited school commit all-or-none.
- validation failure mutates none of committed backpack/Fate/route state.
- success commits once; duplicate commit is rejected.
- UI/MainController migration remains T13 unless a current test proves a smaller integration necessity.

## 2026-08-25 planning/documentation alignment

User approved `Planning Canon & Human Home Alignment`.

This alignment package established the durable project front door after T11. It is completed history. Its scope-local instruction to avoid additional image generation was later superseded by explicit user approvals for the Hybrid Visual work.

Implementation/decision locator:

`docs/superpowers/plans/2026-08-25-planning-canon-human-home-alignment.md`.

## Historical Notion authority / Human Home — migrated by DEC-035

Human Home purpose:

`30-second promise -> full Run Flow -> four schools -> backpack/combination/Fate core data -> world/final goal -> approved visual direction -> AI interpretation -> edit guide -> compact evidence ceiling -> drilldown`.

Raw SHA, full PR/CI history, local path/ports/tool routing and detailed Txx receipts stay in Project Registry/System and `06 · Production · Handoff`.

## Visual decision — 2026-08-25 · current

Current visual authority is `docs/CURRENT_VISUAL_HANDOFF.md` + `docs/design/NINJA_SURVIVAL_MASTER_GDD.md`.

### Hybrid surface split

- Presentation / key art / lore: hand-drawn ink codex + dark painterly anime ninja fantasy.
- In-game: animation-forward **2–3 head SD anime** with C-leaning dark painterly DNA and restrained ink/rough-edge cues.

### Runtime character identity

The player remains **one fixed ninja identity**. School traces add items / aura / companion / shadow effects instead of replacing the character body/face/costume identity.

All four traces must combine naturally. The strongest Trace Stage 3 expression is reserved for the **starting/main school**; other school traces remain supporting layers.

### 2026-08-28 combat readability lock

- 천술류의 상태/반응 주색은 청색 + 호박/주황이다. 보라/검정은 흑영류의 시각 언어로 남긴다.
- 전투 상태는 단어 배지 대신 색과 형태가 구분되는 작은 아이콘으로 제시한다.
- 적 HP 바는 평상시 표시하지 않고, 피격 직후의 적 하나만 표시한다. 표시 지속 시간은 Human Usability 검증 전까지 확정하지 않는다.
- 사용자가 A 구성을 선택한 개정 `PROJECT_CORE_SCENE_VISUAL_BOARD`는 `학교 선택 → 천술 핵심 행동 → [Trace → Boss] → Result/Workbench`의 네 패널을 사용한다. 이전 보드에서는 상태 아이콘 문법만 유지하고 나머지 구도·캐릭터·환경·UI는 다시 설계했다. 이 보드는 여전히 `GENERATED_EXPLORATION`이며 런타임 asset, UI 구현 또는 사용자 검증 증거가 아니다.

Approved school motifs:

- 봉마류: 부적 + 식신
- 천술류: 차크라 기운
- 귀인류: 오니가면 + 귀기
- 흑영류: 그림자 + 어둠

### Current image authority

- Hybrid Key Visual: APPROVED MASTER BRIDGE; historical Notion low-res preview server readback exists but is no longer an active gate.
- Four-school full-body silhouette sheet: APPROVED SUPPORTING REFERENCE; not four runtime protagonists.
- SD/action/icon three-panel sheet: WORKING_REFERENCE; structure reusable but exact trace details superseded by current fixed-character/main-school-Stage-3 rules.
- SCRREF-BATTLE-AUTOCOMBAT-03: USER_LOCKED_PLANNING_REFERENCE_NOT_RUNTIME; human blueprint page 10 is its consumer. It locks continuous floor + sparse independent-prop direction. The later user-locked `NINJA_RUNTIME_BATTLEFIELD_FLOOR_TILE_01`, `NINJA_RUNTIME_BATTLEFIELD_PROP_ATLAS_01`, and `NINJA_RUNTIME_CONTACT_SHADOW_01` are implemented on the current isolated branch; the floor/prop layer replaces the old direct backdrop binding without deleting the historical source. Prop sprites and ground shadows are visual-only and remain unmerged pending a later package decision.
- IMG-02 runtime visual core: merged at `03005e7dcc1a2e0b6ee57b4f6ebed9b481ee2fbc` with seven approved repository-local PNG sources. Actual consumers are three generic EnemyBasic variants, Cheonsul StageBoss, ProjectileBasic, RewardOrb and BongmaFamiliar.
- IMG-03 moonlit battlefield backdrop: merged at `5a52a30aa6c38cfed17e46d550eef27ab06e53f7` with its opaque repository-local PNG. It is retained as a historical/provenance/rollback source; on the current isolated branch it is no longer the direct `Main/BattlefieldBackdrop` consumer. The separately locked floor tile, sparse prop atlas, and contact shadow supply that visual-only consumer layer without changing game-rule authority; they remain unmerged pending the later package decision.
- IMG-04 Cheonsul flame field: merged at `6d538fcf933e2fbcca50f8e6d369d165efac620c` with its transparent repository-local PNG. Its sole consumer is the existing `Cheonsul/FlameFieldVisual`; it changes no combat, route, reward, or school-rule authority.

No corrected trace-layer/action/icon sheet is a pending implementation task by itself. The next visual task begins only after a fresh consumer contract identifies the smallest missing runtime asset; dynamic trace VFX remain intentionally uncreated until then.

## Local/toolchain evidence ceiling

The IMG-02 package used a fresh local Godot 4.7.1 readback. Import, editor
parse, five-second headless main-scene smoke and full GUT `492/492` with
`5373` assertions passed after merge. Exact PR-head GitHub CI also passed GUT
and the Windows internal-build artifact.

Hera's only discovered live editor belonged to another project, so no Ninja
Survival live-render/input claim is made. Historical Project Registry values
for dedicated executable/ports are not current execution authority.

```text
LOCAL_SYNC: POST_MERGE_READBACK_PASS
GODOT_RUN: HEADLESS_MAIN_SMOKE_PASS
GODOT_EDITOR_SESSION: NOT_RUN_FOR_NINJA_SURVIVAL
HUMAN_PLAY: NOT_RUN
DEVICE_EXPORT: NOT_RUN
HISTORICAL_NOTION_ATTACHMENT_RECEIPTS: RETIRED_REFERENCE_ONLY
```

## T13 merged status

T13 Issue #62 / PR #63 is merged to `main` at `71152c7aa9dff4cc05eec76d4d2d70be47755f6c`; its documentation readback PR #64 advances the completed-main reference to `33242876d1b930906416323076e0b55e79896ef7`. T13 adds only the reusable `RestFlowUI` Workbench route-preview and intent contract: legal unvisited-school cards, pending Fate presentation, human-readable readiness state, and standard pointer/touch/focus input. It does not wire the protected MVP-3 loop to the T12 transaction; T14 owns that real session/encounter integration.

## T14 merged status

Issue #65 / PR #66 is squash-merged to GitHub `main` at `51e39737f272db0962a3dabada51bae10cd1fa97`. T14 connects the Cheonsul selection path to the protected route/encounter/Workbench owners: first-school route commit, Elite → chest token + Trace, explicit Trace recovery, Boss warning/spawn gate, Boss-clear route stabilization, mandatory Boss-reward-pending Workbench entry, and provisional route/Fate intent refresh. `EncounterCatalog` is the runtime source for the Core/Elite/Boss role IDs and Elite/Boss HUD display names bound to existing enemy representations; its fan/zone/mark pattern definitions are not newly implemented or claimed as live behavior. Cheonsul combat RewardOrbs stay active despite the legacy MVP-3 stage-flow phase remaining idle. Boss-reward candidates are readable but selection/board placement remain unavailable, so commit stays disabled; no build power, Fate, or next route is auto-committed. Exact PR head local evidence and fresh isolated post-merge evidence each passed Godot 4.7.1 import, editor parse, five-second main-scene smoke, and full GUT `485/485` with `5301` assertions. GitHub Actions run `32983817646` remained queued and was cancelled; a follow-up PR synchronization run was not created, so this router does not claim remote-CI success. These are automated-only evidence; new image generation, raster asset work, human usability, player experience, device/export, and visual live validation remain `NOT_RUN`.

The active package also closes a relevant T12 safety gap: a successful `RestCommitCoordinator` cannot be reconfigured to begin another commit. Existing session-reinitialization protection was already enforced by the generation check.

## Remaining product sequence

```text
T12~T16 machine scope + Cheonsul first authoring baseline
-> current-task four-school shared-chassis/circuit implementation + machine evidence
-> exact-head review + PR/merge/readback
-> optional later Human/Player validation through fourth-Boss Final Binding eligibility (DEC-036 deferred / NOT_RUN)
-> separately reviewed Final Binding / final calamity package
-> full-Run verification only after that package
```

DEC-029/030/031/032/033 define the four-school shared-chassis package and its final-package boundary. DEC-036 moves Human/Player observation out of the current implementation gate; it stays `NOT_RUN` and cannot be inferred from automation. The failure rule remains default Run end with one Ninja-Soul-gated school retry.
# 2026-09-13 연속 구현 추가 — 풍주

선택형 인법 실제 효과 연결은 11/24, 나머지13종은 미완료다.
풍주: 3초 주기, 고정 시전 방향, 600속도/360거리/48폭/0.6초, 적당14피해1회.
기존 시전 레코드에 이동 구간 판정과 기존 대체 Sprite 이동을 연결했다. 최종 VFX 승격은 아니다.
전체 GUT 97scripts/734tests/9692assertions PASS, 실제 엔진 process 지연 명중 smoke PASS.
Main 기본 시작 모드 전환/profile2/나머지 효과/정상 속도 전체 런/Human 검증은 아직 남는다.
아래 이전 10/24 기록은 앞선 증분의 영수증이다.
