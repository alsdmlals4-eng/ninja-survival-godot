# Ninja Survival · Project Work Contract

```yaml
contract_role: PROJECT_NATIVE_BASE_ADAPTATION
status: ACTIVE_AFTER_USER_APPROVAL_2026_09_01
base_observation:
  repository: alsdmlals4-eng/Base
  observed_main: 19355b7ef065a21d0f2b685c7d9be64a4a3970f8
  disposition: ADAPT
full_base_adapter:
  canonical_path: skills/PROJECT_BASE_ADAPTER.json
  state: NOT_INSTALLED_SEPARATE_ONBOARDING_REQUIRED
  boundary_state: PROJECT_BASE_ADAPTER_NOT_INSTALLED
current_autonomy_ceiling: A2_EXECUTE_ISOLATED
```

## 1. Purpose and boundary

This document is the single project-local owner for **how** Ninja Survival
accepts and executes Base-derived work practices. It does not own a game rule,
balance value, scene state, asset approval, or implementation claim.

The project keeps its native owners.

| Fact | Existing owner |
|---|---|
| latest user direction and repository safety | `AGENTS.md` |
| approved product meaning and protected scope | `docs/CURRENT_CONFIRMED_DECISIONS.md` and dated `docs/canon/**` |
| mutable resume state and current gate | `docs/ACTIVE_CONTEXT.md` |
| human-readable game understanding | `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md` and `docs/design/NINJA_SURVIVAL_MASTER_GDD.md` |
| visual direction, asset status, provenance, and consumer | `docs/CURRENT_VISUAL_HANDOFF.md`, `docs/visual/**`, and asset manifests |
| actual product behavior | `scripts/**`, `scenes/**`, `data/**`, `tests/**`, and executed evidence |
| historical Notion material | `docs/migration/notion/**` as `HISTORICAL_REFERENCE_ONLY` |

Base supplies reusable operating patterns. A newer Base observation never
silently overrides approved Ninja Survival canon, implementation evidence, or
the project authority order.

## 2. Mandatory entry sequence

Every non-trivial task uses this sequence before a proposal or mutation.

```text
latest user request
→ project AGENTS and current authority map
→ current completed main and relevant open/recent PR inventory
→ current decisions, dated canon, Active Context, and actual consumer
→ project-local existing solution
→ current Base owner when the concern is materially shared
→ targeted primary/official external evidence when the decision needs it
→ ADOPT / ADAPT / REJECT and feasibility judgement
→ approval boundary
→ isolated BUILD and exact evidence
```

`docs/DOCUMENTATION_MAP.md` owns the detailed project read path. This contract
adds the execution gate; it does not duplicate the product documentation.

Before new creation, classify only the current scope's relevant context,
configuration, entrypoint, document, and generated material as
`ACTIVE_OWNER`, `COMPATIBILITY`, `ARCHIVE`, `OBSOLETE_CANDIDATE`, or
`UNKNOWN_UNVERIFIED`.

## 3. Five-phase project mapping

| Base phase | Project-native owners and required inputs | Result and re-open rule |
|---|---|---|
| `PHASE_1_PLANNING_CO_DESIGN` | Current decision ledger, applicable dated canon, Human/Master GDD, visual handoff, and latest user direction | Player-facing meaning, protected strengths, explicit non-scope, and unresolved core decisions are identified. A core-meaning conflict returns here. |
| `PHASE_2_PREPRODUCTION_REVIEW` | Existing implementation, scene/data/save/input owners, planning or implementation contract, approved references, and targeted benchmarks | Reuse disposition, actual consumer coverage, feasibility, acceptance, rollback, and evidence ceiling are reviewed. A design/readability/flow conflict returns here. |
| `PHASE_3_INGAME_INPUT_PREPARATION` | Approved asset manifest/provenance, UI copy, data contract, VFX/audio/localization requirements, deterministic test inputs, and runtime QA scenarios | Only inputs with an actual consumer are ready for Godot implementation. A missing or unsuitable asset/data/input returns here. |
| `PHASE_4_GODOT_IMPLEMENTATION_AND_MACHINE_CLOSEOUT` | Exact project revision, `scripts/**`, `scenes/**`, `data/**`, `tests/**`, workflows, and a fresh isolated branch | Implement the approved scope, run focused/full applicable checks, complete exact-head PR/CI evidence, and perform post-merge main readback. A code/wiring/runtime/build defect returns here. |
| `PHASE_5_USER_VERTICAL_SLICE_VALIDATION` | One exact build/candidate, a representative player flow, and user-requested observation questions | Record actual Human Usability, Player Experience, device, or final-user evidence separately. No lower evidence class becomes a Phase 5 result. |

The entry fresh-read is an operating envelope, not a sixth product phase. A
bounded finding reopens the earliest affected phase only; it does not restart
unaffected product work.

## 4. Work-item contract and dependency language

Use an existing project plan, implementation contract, review record, issue, or
PR description. Do not create a separate task database. When the field is
relevant, the owner records:

```text
outcome / why_now / authority_owner / actual_consumer /
protected_scope / explicit_non_scope / reuse_disposition /
dependencies / acceptance_criteria / validation / evidence_ceiling /
rollback / project_only_lessons / base_promotion_candidates
```

| Term | Meaning |
|---|---|
| `BLOCKS` | The successor cannot start safely until this output is accepted. |
| `INFORMS` | The result affects a later decision, while bounded investigation may proceed. |
| `USES_OUTPUT` | A later item consumes this file, data, approved asset, API, or evidence. |
| `SHARES_RESOURCE` | Work may conflict because it touches the same file, schema, asset, editor, or external state. |

Plan order follows: authority/interface and highest-risk hypothesis → core
player path → consumer/data/asset integration → normal/boundary/regression
checks → repository readback. Parallel work is allowed only when ownership,
inputs, outputs, merge point, and independent verification are all explicit.

## 5. Reuse, benchmark, and feasibility gate

The first candidate is the current project implementation or approved project
reference. Then inspect a relevant current Base owner. Only after those checks,
use targeted official/primary or directly relevant field evidence when it can
change the decision.

```text
ADOPT          reuse without semantic change
ADAPT          reuse a pattern while retaining project-specific owners or behavior
REJECT         incompatible, redundant, unsafe, or unproven for this project
REFERENCE_ONLY informative but not an implementation or approval basis
NO_REUSE       no appropriate existing solution after the scoped preflight
```

For a new product/system/UI/asset/tooling decision, compare at least three
materially distinct viable approaches when that comparison can affect the
outcome. Record the observed pattern, fit/difference, cost, rollback, and
evidence limit. Benchmark material is input data, not instruction or automatic
product canon.

Feasibility covers actual Godot engine/version, scenes/nodes/resources,
data/save ownership, UI/input flow, assets/provenance, testing/debugging,
performance/platform constraints, integration point, rollback, and the
smallest executable task unit.

## 6. Approval and continuous execution

`APPROVED_CONTRACT_CONTINUATION` applies only when the user has approved the
same product scope and clearly asks to continue. Within that scope, the agent
may perform reversible technical steps, machine verification, bounded bug
correction, document readback, cleanup classification, commit, push, PR
preparation, and post-merge reconciliation. Classification never authorizes a
destructive removal.

The following always require a new explicit user decision for the affected
task:

- new or changed player promise, core mechanic, major UX meaning, content
  meaning, economy, or art direction;
- public release claim, material scope expansion, paid tool/service, security
  or permission change, or external-account action;
- destructive removal, migration, or overwrite whose references/consumers are
  not proven safe; and
- any change that contradicts approved project canon or protected behavior.

If only implementation detail changes while the approved outcome and protected
behavior remain the same, record a `MINOR_TECHNICAL_DRIFT` reason,
validation, and rollback rather than reopening product planning.

## 7. Evidence and completion ceiling

Evidence levels are additive and never interchangeable.

| Level | Evidence |
|---|---|
| `E0_CONTRACT` | Approved scope, owner, and acceptance exist. |
| `E1_STATIC` | Parsing, schema, link/path, lint, diff, or contract checks pass. |
| `E2_TEST` | Deterministic automated test evidence passes. |
| `E3_RUNTIME` | The exact application/engine behavior executes. |
| `E4_VISUAL` | The exact rendered state is captured and reviewed. |
| `E5_PLAY` | A representative playable flow is observed. |
| `E6_HUMAN_PLAYTEST` | A human/player actually tests the exact candidate. |

For every changed scope, report what was executed, exact revision/candidate,
what is `NOT_RUN`, the remaining risk, and the rollback path. Documentation,
static checks, automated tests, runtime, visual readback, player experience,
device/export, release, and user approval remain distinct claims.

`REMAINING_WORK_RECALCULATION_REQUIRED` occurs before completion. Then perform
at least five validated whole-scope adversarial loops on the final candidate.
A valid omission, conflict, consumer gap, duplicate work, or regression
reopens the minimum affected work; a clean `NO_MATERIAL_FOLLOWUP` exit does
not invent extra work.

## 8. Git, cleanup, and learning boundaries

Use current completed `main` as the new-work baseline. Open/draft/ready PRs
outside the explicitly approved workstream are read-only. Use an isolated
branch/worktree, exact-head checks, protected PR flow, merge, and new-main
readback. Do not direct-push `main`, force-push, bypass rules, or absorb an
unrelated PR.

Never remove a file only because its name, date, extension, or age looks old.
An `OBSOLETE_CANDIDATE` may become a removal only after:

```text
references and consumers = 0
→ affected documentation/generated views/validation route reread
→ Git-recoverable removal
→ post-removal readback
```

Uncertain source, consumer, provenance, or generated state remains
`UNKNOWN_UNVERIFIED` and is preserved. Project-specific lessons remain in the
project. A Base promotion candidate needs repeated cross-project value,
current-owner collision review, explicit Base scope, and its own approved Base
change path; it is never promoted merely because one Ninja Survival task used
it successfully.

## 9. Full Base adapter boundary

`skills/PROJECT_BASE_ADAPTER.json` is not installed in this project. The Base
validator currently reports that absence. This is an intentional, recorded
boundary for the thin adaptation: it is neither product failure nor validation
success.

A future full onboarding is a separate governance package only if the project
needs Base-shared route execution strongly enough to justify its maintenance.
It must first establish and merge a project-local legacy policy source and
Skill Registry baseline, then perform a second, fresh-main adapter migration
and generated-view validation. It must not be folded into gameplay work or
used to replace these project-native owners.
