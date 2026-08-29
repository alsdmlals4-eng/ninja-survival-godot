# Repository Guidelines — Ninja Survival / 닌자의 신

This guide applies to GPT/ChatGPT, Codex and delegated agents working on `alsdmlals4-eng/ninja-survival-godot`.

## 1. Project identity

This repository is the Godot 4.x / GDScript rebuild of `닌자 서바이벌 (닌자의 신)`.

The Unity archive is reference material only. Do not line-by-line port Unity C#/MonoBehaviour/Prefab structures into the Godot product.

Do not preserve local path, editor version, port, PR number, SHA, or current task frontier in this file. Re-read those facts from the current repository and tool session.

## 2. Authority order and bootstrap

Use the following order when sources differ.

1. latest user instruction in the current task/chat
2. this `AGENTS.md` and project safety/engine/data rules
3. `docs/CURRENT_CONFIRMED_DECISIONS.md`
4. current product canon under `docs/canon/`
5. `docs/ACTIVE_CONTEXT.md` for mutable resume state
6. current migration/implementation plan and handoff
7. actual code, Scene, Resource, data, assets, tests and runtime evidence
8. project-adopted Base contracts
9. current Base completed main
10. current official/primary research, directly relevant field evidence, historical notes and assumptions

`docs/ACTIVE_CONTEXT.md` is the state router. This file must not duplicate a changing implementation frontier or historical PR ledger.

Before mutation, fresh-read:

```text
latest completed default branch
→ current open/recent same-goal PRs
→ this AGENTS.md
→ CURRENT_CONFIRMED_DECISIONS / canon / ACTIVE_CONTEXT
→ actual implementation consumers and tests
→ current adopted Base owners required by the goal
```

Do not infer current readiness from memory, a historical T-number, or an old PR.

## 3. Repository-only documentation policy — DEC-035

- `REPOSITORY_HUMAN_FACING_CANON`: Master GDD, Flow, Visual Bible, approved decisions, visual locks, asset/provenance and story/product explanation.
- `REPOSITORY_STRUCTURED_CANON`: Markdown, JSON, game data, GDScript, Scene, Resource, config and tests.
- `REPOSITORY_RUNTIME_TRUTH`: actual Godot execution, logs, screenshots/video and human/device evidence.
- Notion is `HISTORICAL_REFERENCE_ONLY` after the recorded migration. Do not use it as current truth, approval owner, write target or completion gate. A user-authorized bounded archive migration may read unique material and must close with repository destination readback.
- Google Sheets is migration compatibility only when unique unmigrated material exists.

A new asset is durable only after repository source, SHA-256/provenance, approval state, actual consumer and applicable import/runtime evidence are recorded. Historical attachments neither block nor satisfy a current asset gate.

## 4. Product direction and protected invariants

Current detailed product truth belongs to current Decisions, canon, Active Context and actual implementation. Preserve these high-level invariants unless the user makes a new product decision.

### Four-school identity

- **봉마류:** mobile stronghold using familiars and barriers.
- **천술류:** ordered status and elemental reaction setup.
- **귀인류:** dangerous close-range presence and sustained proximity; low HP alone is not the universal identity.
- **흑영류:** threat-priority marking and execution compatible with auto combat.

The schools are distinct ways of handling danger, not elemental skins.

### Run and route

```text
starting school
→ unvisited school battlefield
→ Core pressure / school gimmick
→ Elite
→ chest token + trace
→ trace recovery
→ Boss warning / gate
→ Boss
→ result / reward
→ four-school branch
→ Persistent Workbench
→ provisional next route
→ Shop / Chest / Backpack / Combination
→ Fate atomically commits build + Fate + route
→ clear all four schools once
→ Final Binding Workbench
→ final calamity Boss
→ final result / Ninja Soul / legend
```

- choose only among unvisited schools
- Workbench route remains provisional before Fate
- final backpack snapshot, pending Fate and next route commit all-or-none
- UI renders snapshots and emits intents; domain objects own legality, economy, route and transaction rules

### Backpack and acquisition

- fixed 6x6 total board with centered 4x3 starting active area
- bag purchase expands usable area
- item and bag 90-degree rotation
- rectangular regular items and approved L/T bag shapes
- orthogonal adjacency
- special-bag activation on one-cell-or-more overlap
- six-slot REST work buffer
- explicit atomic first-tier combinations
- Boss / Shop / Chest acquisition pillars
- preview/uncommitted items contribute zero combat power
- one committed spatial modifier snapshot is combat authority
- mouse, keyboard/gamepad and touch each need a complete visible path

Architecture direction:

```text
definitions
→ BackpackState
→ BackpackResolver
→ RestBackpackSession / CombinationResolver
→ committed RunBuildState
→ combat
```

### Trace, encounter and content budget

- Elite kill makes a non-expiring Run trace available.
- Trace recovery is progression, not direct ORB/STYLE/GOLD or combat power.
- Boss requires the current approved Elite/trace/time/warning gates.
- `STABILIZED` opens a tradition acquisition package; power still comes through acquisition, placement, adjacency, combination and commit.
- Use shared attack primitives with school-owned encounter compositions.
- Prove one release-near Cheonsul vertical slice before multiplying full production content across all schools.
- Human validation must cover school readability, tension curve, telegraph fairness, trace clarity, Workbench comprehension/fatigue, backpack decision value and Korean readability.

Do not add a second wave system, new autoload/save/meta-power authority, or broad framework without demonstrated need, current feasibility evidence and approval.

## 5. Work style and implementation feasibility

```text
IMPLEMENTATION_FEASIBILITY_BEFORE_COMMITMENT
CURRENT_OFFICIAL_PRIMARY_RESEARCH_REQUIRED
DIRECTLY_RELEVANT_FIELD_EVIDENCE_REQUIRED
ACTUAL_PROJECT_STRUCTURE_FEASIBILITY_REQUIRED
LONG_TERM_QUALITY_OVER_LOCAL_SPEED
ROOT_CAUSE_AND_REUSE_BEFORE_REPEATED_MANUAL_PATCH
MINIMUM_SUFFICIENT_COMPLEXITY
SPECULATIVE_OVERENGINEERING_REJECTED
PLAYABLE_OR_OPERATIONAL_VALUE_OVER_DOCUMENT_VOLUME
```

For every material planning, system, data, UX, visual, implementation or workflow decision:

1. inspect current canon, actual implementation and reusable project/Base owners
2. run targeted current Internet research using official/primary sources and directly relevant successful, failed or mixed field cases
3. compare materially distinct viable approaches when the choice affects product or architecture
4. assess player value and 1-person-development fit
5. verify the actual Godot Scene/node/Resource/script/data/state/signal/save/consumer boundary
6. verify tests, debugging, runtime/render/input, performance, platform, rights, cost, security, migration and rollback
7. classify the result `FEASIBLE | PARTIAL | BLOCKED_UNVERIFIED`

A purely mechanical change whose result cannot be changed by external facts may record `MECHANICAL_NO_EXTERNAL_DEPENDENCY`. Do not use that exemption for gameplay, UX, runtime assets, dependencies, platforms, rights, safety or architecture.

Prefer the root-cause fix and reusable verification when a small local patch would create repeated work or canon drift. Reject speculative abstraction, duplicate owners, broad cleanup and document/tool growth without current playable or operational value.

## 6. Visual direction and candidate-first image workflow

The current master style remains the repository-approved dark moonlit ninja fantasy direction: premium painterly anime illustration, strong silhouette/readability, ink/brush framing, Korean brush-calligraphy title language, black/deep navy/red/warm gold core palette and school-specific accents. Repository Visual owners and approved binaries are authoritative; historical chat previews are not.

When a real or explicitly planned screen, Scene, UI slot, object, state, release surface or production review deliverable needs an image, use:

```text
CANDIDATE_FIRST_VISUAL_PRODUCTION
VISUAL_NEED_CONFIRMED
→ CURRENT_PROJECT_AND_VISUAL_CANON_READBACK
→ ACTUAL_OR_EXPLICITLY_PLANNED_CONSUMER_REQUIRED
→ EXISTING_APPROVED_ASSET_AND_CANDIDATE_REUSE_CHECK
→ BOUNDED_BRIEF_READY
→ IMAGE_MODEL_GENERATES_ONE_CANDIDATE
→ OBJECTIVE_QA_AND_BOUNDED_CORRECTION
→ PRESENT_FOR_USER_FINAL_LOCK
```

- Re-read current project decisions, approved visual anchors, existing candidates, actual/planned consumer, dimensions and Keep/Avoid/Do Not Drift before generation.
- Do not require a duplicate per-image preapproval after this preflight. Produce one bounded candidate, then let the user `LOCK / REVISE / REJECT / RETAIN_AS_REFERENCE` after seeing it.
- Use the host image generation/editing model. Do not substitute SVG/vector, HTML/Canvas, Python drawing or Godot primitives.
- Do not automatically chain into another character, screen, state family or asset package. One objective-defect correction may stay inside the same bounded deliverable.

```text
NEEDED
→ BRIEF_READY
→ GENERATED_CANDIDATE
→ USER_FINAL_LOCKED
→ CANON_REGISTERED
→ IMPLEMENTED
→ RUNTIME_VERIFIED
```

```text
GENERATED_CANDIDATE != USER_FINAL_LOCKED
USER_FINAL_LOCKED != PROJECT_ASSET_APPROVED
CANDIDATE_PRODUCTION_IS_NOT_IMPLEMENTATION_AUTHORITY
```

A candidate or visual lock does not bypass exact Blueprint/Decision implementation approval, repository asset registration, provenance/SHA-256, Codex implementation or runtime evidence.

## 7. Automation and learning

Apply `MINIMIZE_USER_INTERVENTION_WITH_SAFE_FINAL_CONTROL`.

Agents should continue fresh-read, reuse search, research, alternative comparison, bounded candidate preparation, safe document/test correction, readback, regression checks and remaining-work recalculation without asking the user for mechanical decisions already resolved by current evidence.

Escalate core gameplay meaning, economy, narrative identity, Art Direction, major scope/cost, external release, security/permissions, irreversible deletion, safety, or objective ties that need user taste. Visual final lock remains a user decision.

Use:

```text
INCIDENT_SOLUTION_LESSON_AUTOMATION_LOOP
problem → reproducible evidence → root cause → correction → regression prevention → project owner/readback → reusable lesson → Base BCP when cross-project evidence exists
```

Conversation memory is not learned canon. Persist reusable learning in repository owners, tests, validators, templates, checklists or an approved Base proposal.

## 8. Implementation and evidence boundary

- Work/ChatGPT owns planning, research, review, candidate visual preparation, repository documentation and Codex handoff unless the current task contract says otherwise.
- Codex owns actual Godot product code, Scene/Resource/data wiring, runtime UI, save/load, build/export and implementation tests when the current project contract assigns that role.
- Current source/contract/static, import/parse, headless, focused/full GUT, live runtime/render/input, Human Usability, Player Experience and device/export evidence are separate classes.
- `NOT_RUN` is not PASS. A generated image, passing parser or PDF is not runtime, UX, device or release evidence.

## 9. Adversarial review and correction

Every material changed state must run the current Base whole-state review contract.

```text
ACTUAL_POST_COMPLETION_ADVERSARIAL_REVIEW_REQUIRED
FULL_LOOP_COUNT_MINIMUM: 5
EXECUTION_EVIDENCE_REQUIRED
CORRECT_VALIDATED_FINDINGS
NO_REVIEW_COMPLETION_CLAIM_WITHOUT_EVIDENCE
CLEAN_REVIEW_EXIT
```

Each full loop:

```text
FULL_SCOPE_REVIEW
→ FIND
→ VALIDATE_CRITIQUE
→ CORRECT_VALIDATED_FINDINGS
→ VERIFY_AND_REGRESSION_RECHECK
→ BETTER_ALTERNATIVE_SEARCH
→ LONG_TERM_PLAN_FIT_RECHECK
→ RE_ATTACK
```

Record input head, evidence delta, findings, validated findings, corrections, verification, better alternative, long-term fit, unresolved items and output head. Continue beyond five while a valid blocker, regression, stale reference or evidence-ceiling violation remains.

## 10. PR, branch and tool protection

- Open/draft/ready PRs are read-only unless current-task continuation or explicit named authorization allows mutation.
- Start new product work from fresh completed default branch.
- No force push, direct-main push, admin/ruleset bypass or unrelated PR takeover.
- Verify current Godot/editor/project/session identity before local mutation; historical version and path records are evidence only.
- Use GUT where adopted and run the smallest relevant Godot check plus required exact-head CI.
- Do not claim HiGodot/Godot AI/Hera/provider availability from history; verify the current callable session.
- Default to zero incremental monetary cost. Do not add paid APIs, runners, SaaS or dependencies without explicit approval.

## 11. Completion and reporting

`planned work = 0` is only a completion candidate.

```text
remaining-work recalculation
→ implementation/canon/consumer/PR/evidence correction rescan
→ valid finding? correct + verify + recalc
→ final whole-state adversarial lineage
→ minimum five full loops and clean exit
→ exact PR head gate
→ merge when authorized
→ new main readback
→ repository destination readback
→ remaining work = 0 for current scope
```

Every material report distinguishes approved scope/exclusions, actual changes, before/after/effect/trade-off, alternatives, Implementation Reality evidence, adversarial findings and corrections, exact PR/merge/main identity, repository readback, `NOT_RUN` items and the next product gate.

Never claim a test, runtime, render, merge, asset registration or human validation that was not actually executed.
