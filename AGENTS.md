# Repository Guidelines — Ninja Survival / 닌자의 신

This guide applies to GPT/ChatGPT, Codex and delegated agents working on `alsdmlals4-eng/ninja-survival-godot`.

## 1. Project identity

This repository is the Godot 4.x / GDScript rebuild of `닌자 서바이벌 (닌자의 신)`.

The Unity archive is reference material only. Do not line-by-line port Unity C#/MonoBehaviour/Prefab structures into the Godot product.

Authoritative local project root:

`C:/Users/user/Documents/GitHub/Ninza/ninja-survival-godot`

Do not use historical foreign-project paths embedded in old generic contracts.

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

## 3. Delivery-contract boundary

The repository still stores the byte-exact historical adapter:

`PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`.

Do not edit its bytes merely to make it look current or project-specific.

When the user supplies a newer task execution contract in the current chat, latest user instruction wins for that task. Treat the newer contract as an execution overlay unless the user separately authorizes replacing the repository-stored contract source.

Core phase rule remains:

```text
PLAN / canon / product decision
-> explicit product decisions complete for the implementation package
-> fresh final planning review / Definition of Ready
-> Phase-B PASS
-> BUILD / TDD package
-> exact verification
-> review / merge
-> post-merge readback
```

Do not infer `planning complete` from an old Phase-B record after material product decisions changed.

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
-> final result / Ninja Soul
```

`~20 minutes` is the target active-combat time through the fourth school Boss, not the entire Run end.

Full current detail:

- `docs/canon/2026-08-21-dec014-025-product-canon.md`
- `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`

## 5. Current implementation reality

- MVP-0 basic combat: integrated.
- MVP-1 combat DDD: integrated.
- MVP-2 four-school shallow runtime: integrated.
- MVP-3 result/GOLD/Shop/Fate/three-segment runtime: integrated rollback/regression baseline.
- **MVP-4 T01 spatial data contracts/catalog: integrated.**
- **MVP-4 T02 BackpackState committed spatial state: integrated.**
- **MVP-4 T03 BackpackResolver deterministic spatial resolution: integrated.**
- **MVP-4 T04 RestBackpackSession REST edit-session domain engine: integrated.**
- **MVP-4 T05 CombinationResolver first-tier atomic combination transaction: integrated.**
- Workbench UI / committed spatial combat integration: not started.
- DEC-014~025 school-circuit/trace/final-calamity runtime: not started.
- DEC-026 encounter/pattern runtime: not started.
- release-near Vertical Slice human QA for current canon: NOT_RUN.

T01 proves the data foundation. T02 proves committed spatial-state primitives. T03 proves deterministic connectivity/adjacency/special-bag/spatial-modifier resolution and read-only previews. T04 proves the REST edit-session domain engine. T05 proves recipe eligibility/progressive hints and source-preserving atomic first-tier 2→1 combination. None proves playable Workbench UI, committed combat integration or Human experience.

T01 merged as PR #27 / `7c9206702526f99dfadf44a617cd150853ec733f`. Exact final PR-head evidence: Godot 4.7.1 import PASS, main-scene smoke PASS, GUT `263/263` tests and `1829` assertions PASS.

T02 merged as PR #29 / `126e6c942d74f97166ef0c881afc5d79cae3d274`. Exact final PR-head `60adbb99886c96c687b20befe4a61e5e3bcb71f1` evidence: Godot 4.7.1 import PASS, main-scene smoke PASS, GUT `274/274` tests and `1915` assertions PASS, T02 focused `11/11` PASS.

T03 merged as PR #31 / `2dcf055d82df02d44335f209897436572efa6739`. Exact final PR-head `e0dacee9048a01e799012b8aca12760e07ca47ea` evidence: Godot 4.7.1 import PASS, main-scene smoke PASS, GUT `292/292` tests and `2026` assertions PASS, T03 focused `18/18` PASS.

T04 merged as PR #33 / `d07f16d6bae90a09bba0a5f0b8991216d006c966`. Exact final PR-head `6972e14cfa94dcce4d372a632db6d5e74809ee62` evidence: Godot 4.7.1 import PASS, main-scene smoke PASS, GUT `309/309` tests and `2202` assertions PASS, T04 focused `17/17` PASS.

T05 merged as PR #35 / `8cefce75456f8b72a8f69559857676cca67a6c5d`. Exact final PR-head `d14ff2e8702d610de1678c22737982bd5b73e22a` evidence: Godot 4.7.1 import PASS, main-scene smoke PASS, GUT `329/329` tests and `2322` assertions PASS, T05 focused `20/20` PASS.

## 6. Current planning / implementation gate

DEC-026 is **APPROVED** and the fresh post-DEC-026 Phase-B Definition of Ready is **PASS**.

T01, T02, T03, T04 and T05 are complete. Current production execution begins at:

**T06 — committed RunBuildState migration, from fresh merged `main`, TDD first.**

Remaining executable order:

`T06 -> T07 -> T08 -> T09 -> T10 -> T11 -> T12 -> T13 -> T14 -> T15 Human QA gate`.

Do not jump directly to T08. T06 must make one finalized spatial snapshot the committed combat modifier authority without double-applying legacy MVP-3 item modifiers. Do not pull T07 acquisition transactions or Workbench UI authority into T06.

Current planning owners:

- `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
- `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`
- `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
- `docs/superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`

## 7. MVP-4 implementation boundary

### Integrated T01

- existing `ItemDefinition` extended rather than duplicated
- `RunModifierSet` supported-field authority
- bounded `SpatialRuleDefinition`
- one starting 4x3 bag + five purchasable `BagDefinition`s
- 19 base acquisition items + 3 combination-result lookup definitions
- 8 strong-spatial base-item contracts
- 3 `CombinationDefinition`s
- explicit base/result acquisition boundaries
- catalog validation for unsupported fields and non-numeric modifier payloads
- existing MVP-3 item values and sell runtime preserved

A stricter exported typed-Dictionary experiment caused an actual Godot import regression and was rejected. Runtime-compatible generic Dictionary storage remains protected by catalog validation and tests.

### Integrated T02

- `ItemInstance` and `BagInstance` value objects reference T01 definition IDs rather than duplicating item/bag authority
- one `BackpackState` owns committed 6x6 board facts
- centered starting 4x3 active area from the starting bag
- shared monotonic item/bag instance IDs
- origin and normalized quarter-turn rotation
- atomic item/bag add, move, remove and rotate
- inactive-cell, bounds, item-item and bag-bag collision rejection
- bag expansion/shrink active-area facts and prevention of orphaned committed items
- public item/bag collection views are defensive snapshots
- `copy_value()` preserves snapshot isolation
- T04 adds only validated `restore_item_instance()` / `restore_bag_instance()` owner paths so buffered/reconstructed existing instances retain identity without exposing live interiors

Adversarial review found and fixed a live collection-view mutation bypass before T02 merge; T04 later verified restore paths reject shared item/bag ID collisions and preserve atomic ID advancement.

### Integrated T03

- `BackpackResolution` is a copied result value with validity/failure metadata, active/item cells, canonical adjacency pairs, special-bag hits and a derived `RunModifierSet`
- `BackpackResolver` reads T02 defensive snapshots and does not mutate committed state
- 4-neighbor BFS enforces connected active-cell layouts
- item adjacency is orthogonal and canonical once per distinct item pair even across multiple touching edges
- T01 spatial rules remain data-driven with `ANY` selector semantics and `PER_DISTINCT_NEIGHBOR` caps
- one neighbor matching both tag and explicit definition id counts once
- special-bag effects activate on one-cell-or-more overlap and apply once per distinct bag instance
- static payload and selected-school emblem payload are resolved into deterministic modifier snapshots
- candidate item/bag placement and whole-layout translation previews are read-only/all-or-nothing
- corrupt/missing definition inputs fail closed; failure cells and snapshots are deterministic

Adversarial review found and fixed a diagnostic contract defect where null state was initially reported as `missing_candidate`; state/candidate failures are now distinct.

### Integrated T04

- `RestBackpackSession` owns a copy of committed T02 state rather than mutating the source
- exact six-slot REST work buffer; board -> buffer disables effects and legal buffer -> board preserves stable instance identity
- `BuildPreviewSnapshot` holds defensive preview state and copied T03 resolution/modifier output
- selected-school context is included in build preview resolution
- backpack edit actions are deep-snapshot undoable/redoable; a new edit clears redo
- non-history pending-bag acquisition cuts prior edit history so undo cannot silently erase/refund an irreversible acquisition
- whole-layout movement is an explicit mutually-exclusive mode and uses T03 all-or-nothing translation
- pending item preview and active whole-layout mode block later commit readiness until explicitly resolved/exited
- session state/buffer/pending-bag/preview views are defensive copies

Adversarial review found and fixed three T04 control-state gaps: an uncommitted visible preview could pass commit readiness, whole-layout mode initially allowed per-item edits, and active whole-layout mode initially did not block later commit.

### Integrated T05

- `CombinationResolver` reuses T01 recipe definitions instead of creating a second recipe catalog
- only T03-valid orthogonally adjacent on-board source pairs are eligible; buffer sources are excluded
- progressive `UNDISCOVERED / INGREDIENT_OWNED / READY / DISCOVERED` hint stages are deterministic
- reversed source arguments are canonicalized to recipe A/B while stable source IDs are preserved
- pending result preview does not consume source items
- invalid result placement and cancel preserve both sources
- success removes exactly two sources and creates exactly one result only after candidate-state placement and T03 resolution succeed
- failed commit preserves future instance-ID cursor and pending state
- success marks discovery once and repeated commit is ignored
- success is an irreversible history barrier while cancel preserves prior edit history
- pending combination blocks parallel REST edits and later Fate commit
- pending/discovery views are defensive snapshots
- state replacement remains in `RestBackpackSession` through underscore-prefixed internal project-contract methods; GDScript does not enforce access privacy

Adversarial review found and fixed two T05 authority defects: public session transaction methods could bypass recipe authority, and stale discovery memory could resurrect a recipe removed from current authority.

### Next T06-T07 direction

- T06 committed `RunBuildState` modifier migration: one finalized T01~T05 spatial snapshot becomes combat modifier authority without legacy double application
- T07 reward/shop/chest transaction foundation

Old T08-T12 from the 2026-08-11 plan remain superseded for execution. Use the current post-DEC-026 plan for T08+.

## 8. Historical PR/branch protection

- Open/draft/ready PRs are read-only by default unless the user explicitly names the PR and allowed action.
- Follow-up work normally targets merged `main` truth.
- PR #17 is **closed / unmerged / historical**. Do not reopen, merge or use it as a prerequisite.
- old `impl/mvp4-t01-spatial-data-contracts` is historical, not a current implementation branch.
- PR #27 is merged T01 evidence.
- PR #29 is merged T02 evidence.
- PR #31 is merged T03 evidence.
- PR #33 is merged T04 evidence.
- PR #35 is merged T05 evidence.
- Future production work starts from fresh merged `main` after current readback.

Do not rewrite historical PRs/handoffs just to make timestamps/status prose appear current.

## 9. Godot rules

- Engine target: Godot 4.x; current tested authority is Godot 4.7.1 unless later approved otherwise.
- Language: GDScript.
- Prefer Scene/Node/signal/Resource/RefCounted composition appropriate to Godot.
- Keep state ownership singular; UI must not duplicate domain/economy/geometry/combat authority.
- Do not expose live mutable interiors that let consumers bypass the owning domain object's validated mutation path.
- Treat underscore-prefixed GDScript methods as project-internal contracts, not language-enforced privacy; do not claim stronger encapsulation than tests and ownership rules provide.
- Do not add a second wave system while the current WaveSpawner API is sufficient.
- Do not add a new autoload/save/meta-power system without a demonstrated requirement and approval.
- Do not claim local plugin/provider integration from historical branches; verify current `project.godot` and actual environment.

## 10. Protected spatial rules

Do not regress these approved MVP-4 decisions:

- 6x6 total board / 4x3 starting active area
- bag purchase expands usable area
- item and bag 90-degree rotation
- rectangular regular items; selected L/T bag shapes
- orthogonal adjacency
- special-bag one-cell-overlap activation
- six-slot REST work buffer
- explicit atomic first-tier combinations
- Boss / Shop / Chest acquisition pillars
- preview/uncommitted items contribute zero combat power
- committed spatial snapshot becomes combat authority
- whole-layout movement mode is explicit/visible
- mouse, keyboard/gamepad-focus and touch each have a complete path

## 11. Four-school product identity

- **봉마:** mobile stronghold; prepare space and let familiars/barriers fight.
- **천술:** statuses + ordered elemental reactions.
- **귀인:** dangerous close-range presence; low HP alone is not the universal identity.
- **흑영:** threat-priority mark/execution; indirect targeting remains auto-combat compatible.

Current MVP-2 implementations are migration baselines, not wholesale deletion targets.

## 12. Trace / route rules

Current trace authority:

- Elite kill -> chest token + trace AVAILABLE.
- trace is non-expiring Run progression and separate from RewardOrb.
- recovery does not give ORB/STYLE/GOLD.
- Boss needs Elite + trace + time + warning gates.
- Boss clear + branch return -> STABILIZED.
- STABILIZED opens a tradition acquisition package; it does not auto-buff the school.
- actual power remains backpack acquisition/placement/adjacency/combination.

Current route authority:

- choose only among unvisited schools,
- Stage number and school identity are separate axes,
- Workbench route selection is provisional,
- Fate atomically commits build + Fate + next school,
- clear order is retained for final support callbacks.

## 13. Benchmarking / alternative review

For L1+ product/system decisions:

1. inspect current project canon and implementation first,
2. compare at least three materially distinct valid approaches when the decision warrants it,
3. use official/primary/current benchmark evidence as evidence, not authority,
4. record `ADOPT / ADAPT / REJECT`, trade-offs, long-term cost and rollback conditions,
5. run the required adversarial review loop before clean exit.

Do not copy another game's surface implementation/content directly.

## 14. Adversarial review

For L1+ review/correction work, use the current Base requirement:

- minimum 5 full loops,
- attack whole approved scope,
- validate findings against sources/runtime,
- apply approved bounded correction,
- rerun regression/evidence checks,
- attack the improved state again,
- continue past 5 if a valid blocker/MUST_FIX remains.

Do not count superficial rereads as full loops.

## 15. Test / evidence rules

Automated evidence classes remain separate:

- import/parse
- headless main-scene smoke
- focused GUT
- full GUT regression
- runtime/manual evidence
- human player-experience evidence
- device/export evidence

Do not promote one class into another.

Current CI source-fidelity protections must be preserved:

- vendored GUT must be reused rather than overlaid,
- nested `addons/gut/gut` must fail,
- `UID duplicate detected` during import must fail,
- script/error output must not be silently treated as green.

## 16. Human Vertical Slice rule

Placeholder/card/text UI is acceptable for spikes and automated technical evidence.

It cannot close final player-experience PASS.

Before multiplying content across four school battlefields, build one representative **release-near** school slice:

`school signature <=30 sec -> Core pressure -> Elite -> trace -> Boss -> reward -> Persistent Workbench -> next-route preview`.

Use production-candidate UI/UX, character/enemy visual language, animation/VFX and audio feedback sufficient to judge the intended experience.

Measure:

- first-impression school readability,
- combat tension curve,
- telegraph fairness,
- trace clarity,
- Workbench comprehension/fatigue,
- backpack decision value,
- Korean text/layout readability.

Scale to all four schools only after this slice passes or the failed assumptions are corrected.

## 17. Cost rule

Default to zero incremental monetary cost. Do not introduce pay-as-you-go APIs, paid runners, extra SaaS subscriptions or metered services unless the user explicitly changes that policy.

## 18. Reporting requirements

Every material implementation/review report must distinguish:

- sources inspected
- actual files changed
- why they changed
- verification executed
- evidence ceiling / NOT_RUN
- remaining risks/blockers
- rollback path
- adversarial review result
- reusable Base-promotion candidates vs project-only lessons

Never claim a test, runtime, render, merge, Notion sync or readback that was not actually executed.