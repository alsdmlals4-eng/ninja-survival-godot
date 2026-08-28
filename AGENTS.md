# Repository Guidelines — Ninja Survival / 닌자의 신

This guide applies to GPT/ChatGPT, Codex and delegated agents working on `alsdmlals4-eng/ninja-survival-godot`.

## 1. Project identity

This repository is the Godot 4.x / GDScript rebuild of `닌자 서바이벌 (닌자의 신)`.

The Unity archive is reference material only. Do not line-by-line port Unity C#/MonoBehaviour/Prefab structures into the Godot product.

Project repository: `alsdmlals4-eng/ninja-survival-godot`.

The last recorded local project root is `C:/Users/user/Documents/GitHub/Ninza/ninja-survival-godot`, but local path/tool/session facts must be re-read before local mutation. Do not revive retired per-project Godot binary/port assumptions from historical records.

## 2. Authority order

Use the following order when sources differ:

1. latest user instruction in the current task/chat
2. this `AGENTS.md` and project safety/engine/data rules
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. `docs/canon/2026-08-21-dec014-025-product-canon.md` + `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
5. `docs/ACTIVE_CONTEXT.md` for mutable resume state
6. current migration traceability / approved implementation plan
7. actual code / Scene / data / assets / tests for implementation reality
8. project-adopted Base patterns
9. current Base remote
10. benchmarks / external evidence / historical notes / assumptions

`docs/ACTIVE_CONTEXT.md` is a state router, not a replacement for Decision/Canon owners.

## 2.1 Repository-only documentation policy — DEC-035

The user retired Notion from active project work on 2026-08-28 KST. This
policy supersedes every operational Notion requirement below, while preserving
old Notion references only as historical receipts.

- Repository: the single active owner for human-readable GDD/Flow/Visual
  Bible, structured canon, asset provenance, code, data, Scene/Resource,
  tests, production handoff, and runtime evidence.
- Existing Notion pages/attachments: `HISTORICAL_REFERENCE_ONLY`; do not
  read, write, upload, attach, search, or require a readback from them for
  current/future work.
- A new asset is durable only after its repository source, SHA-256/provenance
  manifest, explicit approval state, actual consumer, and applicable
  import/runtime evidence are recorded in the repository. Historical Notion
  attachments neither block nor satisfy a future asset gate.
- Google Sheets: migration compatibility only when unique unmigrated material
  exists; do not introduce a new external owner.

## 3. Delivery-contract boundary

The repository stores the historical adapter `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`. Do not edit it merely to look current.

When the user supplies a newer task execution contract in the current chat, the latest user instruction wins for that task. Treat the newer contract as an execution overlay unless the user separately authorizes replacing the repository-stored historical adapter.

Core phase rule:

```text
PLAN / canon / product decision
-> explicit product decisions complete for the package
-> Definition of Ready / implementation-ready gate
-> BUILD / TDD or acceptance-evidence package
-> exact verification
-> adversarial review
-> PR / merge
-> post-merge repository readback
```

Do not infer current readiness from an old Phase-B record after material product decisions or implementation state changed.

## 4. Current product target

```text
starting school
-> choose one unvisited school battlefield
-> Core Monsters / Stage gimmick
-> ~3 min school Elite
-> chest token + school trace
-> trace recovery
-> Boss warning / dual gate
-> school Boss around five-minute boundary
-> RESULT / Boss Reward
-> return to four-school joint branch
-> trace STABILIZED / tradition access package opens
-> Persistent Workbench
-> provisional next-school selection
-> Shop / Chest / Backpack / Combination
-> Fate atomically commits build + Fate + next route
-> clear all four schools exactly once
-> Final Binding Workbench
-> separate final calamity Boss
-> final result / Ninja Soul / legend
```

`~20 minutes` is the target active-combat time through the fourth school Boss, not the entire Run end.

Current product canon:

- `docs/canon/2026-08-21-dec014-025-product-canon.md`
- `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`

## 5. Current implementation reality — T12~T16 merged machine scope

`265bab32da087c070ea2ea0d98a3bdace1e10f7f` is the historical T11 reactivation baseline, not the current implementation frontier. Before mutation, always fresh-read the remote default branch; do not turn this document's own revision into a durable current-main pointer.

Current facts:

- MVP-0 basic combat: integrated.
- MVP-1 combat DDD: integrated.
- MVP-2 four-school shallow runtime: integrated migration baseline.
- MVP-3 result/GOLD/Shop/Fate/three-segment runtime: integrated rollback/regression baseline.
- T01~T05 spatial data / BackpackState / resolver / REST session / atomic first-tier combination: merged.
- T06 committed `RunBuildState` modifier authority: merged.
- T07 Boss/Shop/Chest spatial acquisition transaction foundation: merged.
- T08 `RunRouteState` four-school route domain: merged.
- T09 encounter definitions + Stage profiles: merged.
- T10 Elite -> Trace -> Boss lifecycle/domain gate: merged.
- T11 tradition access packages + Boss/Shop/Chest lane-first reward selection: merged.
- T12 atomic Workbench + Fate + next-route commit: merged by PR #61 (`41202283b75921efb7691e77c3de1502d77410d1`), automated evidence only.
- T13 Persistent Workbench route-preview UI/input presentation: merged by PR #63 (`71152c7aa9dff4cc05eec76d4d2d70be47755f6c`).
- T14 Cheonsul release-near lifecycle/Workbench entry slice: merged by PR #66 (`51e39737f272db0962a3dabada51bae10cd1fa97`), automated evidence only.
- T15 starting-school Korean function help: merged by PR #69 (`e2cfe4452e1de5a224f5cd7dee8e47a104c868e0`), machine verified only.
- T16 in-combat current-school help: merged by PR #73 (`63fcf81fdf4b5d1bbff14b5721a13f7c1afe1497`), machine/runtime-input evidence only; visible modal semantics remain unconfirmed.
- Human Usability / Player Experience / device / Android-export validation: `NOT_RUN`.

T01~T16 source/test evidence proves only its actual automated, domain, machine-input, or explicitly recorded runtime scope. It does not prove that the intended new Run is playable end-to-end or fun/readable to a human.

## 6. Current next product gate — User vertical-slice validation

The next product gate is the approved Cheonsul Human vertical-slice validation: school readability, Core → Elite → Trace → Boss tension, telegraph fairness, Trace purpose, Workbench comprehension/fatigue, Korean readability, and complete mouse/keyboard-gamepad/touch paths. This gate remains `NOT_RUN`; do not infer a pass from T12~T16 automation.

PR #43 and #44 are closed historical WIP. Draft PR #49 is a superseded T12 reference. All three are read-only: do not reopen, merge, rebase, or resume them as current authority.

If a later task touches an already-merged T12~T16 area:

```text
fetch then-current completed main
-> re-read Base + project authority
-> inspect #43/#44/#49 read-only only when relevant
-> compare actual current code/tests/canon
-> create a fresh current-task branch/PR
-> TDD / exact-head verification / merge / readback
```

The protected atomic Workbench boundary remains:

- Workbench route remains provisional before commit.
- Final backpack snapshot + pending Fate + provisional next school must commit all-or-none.
- Existing domain owners remain singular; do not move geometry/economy/route/Fate authority into UI.
- follow-up UI, encounter, or full-run behavior is not silently absorbed into a transaction-only scope.

## 7. Protected spatial / Workbench rules

Do not regress these approved MVP-4 decisions:

- fixed 6x6 total board / centered 4x3 starting active area
- bag purchase expands usable area
- item and bag 90-degree rotation
- rectangular regular items; selected L/T bag shapes
- orthogonal adjacency
- special-bag activation on one-cell-or-more overlap
- six-slot REST work buffer
- explicit atomic first-tier combinations
- Boss / Shop / Chest acquisition pillars
- preview/uncommitted items contribute zero combat power
- one committed spatial modifier snapshot is combat authority
- whole-layout movement mode is explicit/visible
- mouse, keyboard/gamepad focus and touch each need a complete core path

Architecture direction:

`definitions -> BackpackState -> BackpackResolver -> RestBackpackSession/CombinationResolver -> committed RunBuildState -> combat`.

UI renders snapshots and emits intents; domain objects own legality, economy, route and transaction rules.

## 8. Four-school product identity

The four schools are not elemental skins. They are distinct ways of handling danger:

- **봉마류:** mobile stronghold — prepare space and let familiars/barriers fight.
- **천술류:** statuses + ordered elemental reactions — set up and transform the field.
- **귀인류:** dangerous close-range presence — sustain risky proximity for power; low HP alone is not the universal identity.
- **흑영류:** threat-priority mark/execution — indirectly influence which dangerous target dies first while staying auto-combat compatible.

Current MVP-2 implementations are migration baselines, not wholesale deletion targets.

## 9. Trace / route / reward rules

Trace authority:

- Elite kill -> chest token + trace `AVAILABLE`.
- Trace is non-expiring Run progression and separate from RewardOrb.
- Recovery does not give ORB/STYLE/GOLD or direct combat power.
- Boss requires Elite + trace + time + warning gates.
- Boss clear + branch return -> `STABILIZED`.
- `STABILIZED` opens a tradition acquisition package.
- Actual power still comes from acquire -> backpack placement -> adjacency -> combination -> committed modifier snapshot.

Route authority:

- choose only among unvisited schools,
- school identity and Stage 1..4 are separate axes,
- Workbench route selection is provisional,
- Fate is the final build + Fate + route commit boundary after T12 migration,
- clear order is retained for final support callbacks.

Reward authority:

- keep the existing 19 base-acquisition item IDs, 3 first-tier combinations and 5 purchasable bags unless explicitly changed,
- access packages control eligibility/timing, not automatic school stats,
- Boss reward preserves readable continuity / newly liberated tradition / bridge-universal lanes when possible,
- Shop/Chest use lane-first selection and canonical item-ID dedupe rather than one flat oversized pool.

## 10. Encounter / Vertical Slice rules

DEC-026 selected **shared attack primitives + school-owned encounter compositions**.

Per school authoring target:

- Core Monster x3
- Elite x1
- Boss x1
- bounded gimmick/pattern library

Stage budget:

- Stage 1: base signature, max 1 major hazard
- Stage 2: one interaction pattern, max 1 advanced gimmick at once
- Stage 3: one synergy/field layer, max 2 advanced gimmicks at once
- Stage 4: mastery mix + one Boss capstone, still max 2 advanced gimmicks at once

Before multiplying full production content across four schools, prove one **release-near Cheonsul slice**:

`signature <=30 sec -> Core pressure -> ~3m Elite -> trace -> ~5m Boss -> reward -> Persistent Workbench -> next-route preview`.

Human validation must measure school readability, tension curve, telegraph fairness, trace clarity, Workbench comprehension/fatigue, backpack decision value, and Korean readability.

## 11. Visual direction and image gate

Current user-approved master style reference is the **first image supplied in the 2026-08-25 approval turn**.

Approved style traits:

- dark moonlit ninja fantasy
- premium painterly anime illustration
- strong silhouette/readability
- ink/brush framing and Korean brush-calligraphy title language
- black / deep navy / red / warm gold core palette
- school-specific gold, elemental blue/orange, red, purple/black accents
- dramatic but readable VFX and battlefield density

The denser parchment infographic references are useful for **supporting explanatory layouts**, not the master game-art style.

Do not generate or edit another project image unless the user explicitly asks. Image workflow:

```text
current canon + visual canon + actual consumer/planning-board brief
-> text brief
-> generate exactly one candidate
-> STOP
-> user LOCK / REVISE / REJECT
```

A chat image is not a durable project asset until user `LOCK`, repository
source/manifest provenance, and its applicable consumer/evidence gates succeed.

## 12. Repository GDD / AI-System separation

`docs/design/NINJA_SURVIVAL_MASTER_GDD.md` is the self-contained
human-readable game-learning surface, not a raw production dashboard.

The repository GDD should directly show:

- one-line promise / player fantasy
- full Run Flow
- four-school philosophies
- backpack/combination/Fate core data and decisions
- world/story premise needed to understand `닌자의 신`
- approved visual direction / actual approved visual anchor when durably attached
- AI interpretation for user correction
- human edit guide
- compact implementation/evidence ceiling and next product gate

Raw SHA, full PR/CI history, local path/ports/tool routing and detailed Txx
receipts belong in repository production-handoff/evidence documents.

## 13. Historical PR / branch protection

- Open/draft/ready PRs are read-only by default unless current-task continuation or explicit named authorization allows mutation.
- PR #17: closed/unmerged historical.
- PR #27/#29/#31/#33/#35 and T06~T11 implementation PRs: merged historical evidence.
- PR #43: closed/unmerged T12 WIP; historical reference only.
- PR #44: closed/unmerged front-door WIP; historical reference only.
- Do not use old implementation branches as resume baselines.
- New production work starts from fresh completed `main`.
- No force push, direct-main push, admin/ruleset bypass, or unrelated PR takeover.

## 14. Godot / toolchain rules

- Engine family: Godot 4.x / GDScript.
- The latest merged T11 evidence used Godot 4.7.1; that is an evidence identity, not proof that the current local shared host pin is still 4.7.1.
- Before local Godot authoring/runtime, use the current Base fresh-shell route: exact project location -> git fetch -> safe ff-only reconciliation when clean -> official update check -> safe reviewed update when eligible -> exact Editor/project/session identity -> implementation/test/runtime.
- Do not multiply per-project Godot binaries or ports by default. Current shared-host policy uses approved exact pins and exact project/editor/session isolation; local facts must be directly read before mutation.
- GUT remains the project deterministic GDScript test framework where adopted.
- Do not claim HiGodot/Godot AI/Hera/provider connection from historical records; verify callable/current session state.
- Do not add a second wave system while current WaveSpawner responsibilities are sufficient.
- Do not add a new autoload/save/meta-power system without demonstrated need and approval.

## 15. Benchmarking / Existing Solution First

For L1+ product/system/UX decisions:

1. inspect current project canon and implementation,
2. inspect existing internal solution and current Base owner,
3. compare at least three materially distinct viable approaches when decision-relevant,
4. use current official/primary evidence plus success/failure or mixed cases,
5. classify evidence as `ADOPT / ADAPT / TEST / REJECT / REFERENCE_ONLY`,
6. search again for a better alternative when new evidence/finding appears,
7. judge long-term fit, maintenance cost, rollback and revisit conditions.

Do not copy another game's surface content, trade dress, exact UI or tuning.

## 16. Adversarial review / evidence rules

For L1+ changes use current Base `running-adversarial-review-and-refinement` semantics:

- minimum 5 full whole-state loops,
- each loop re-attacks the full approved scope,
- validate the critique before changing anything,
- fix only validated findings,
- verify/regress the changed state,
- search for a better alternative and recheck long-term fit,
- continue beyond 5 while any valid blocker/MUST_FIX remains.

Evidence classes remain separate:

- source/contract/static evidence
- import/parse
- headless main-scene smoke
- focused/full GUT
- live runtime/render/input
- Human Usability
- Player Experience
- device/export/platform

Do not promote one class into another. `NOT_RUN` is not PASS.

## 17. Cost rule

Default to zero incremental monetary cost. Do not introduce pay-as-you-go APIs, paid runners, additional SaaS subscriptions or separately metered services without explicit user approval.

## 18. Completion / reporting

`planned work = 0` is only a completion candidate.

Before completion:

```text
remaining-work recalculation
-> implementation/canon/repository-consumer/PR/evidence correction rescan
-> valid finding? fix + verify + recalc
-> final post-change adversarial loop lineage
-> minimum five full loops and clean exit
-> exact PR head gate
-> merge when authorized
-> new main readback
-> repository destination readback
-> remaining work = 0 for current scope
```

Every material completion report must distinguish:

- approved scope / exclusions / protected items
- actual changed surfaces
- BEFORE -> AFTER -> expected effect -> trade-off
- alternatives and benchmark disposition
- Implementation Reality evidence level
- adversarial findings and corrections
- exact PR/merge/new-main identity when applicable
- repository readback
- `NOT_RUN` / blockers
- next product gate / revisit conditions

Never claim a test, runtime, render, merge, repository asset registration, or
human validation that was not actually executed.
