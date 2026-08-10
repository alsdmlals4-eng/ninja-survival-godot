# Repository Guidelines

This guide applies to Codex, GPT/ChatGPT, and delegated subagents working on `ninja-survival-godot`.

## Project Identity

`ninja-survival-godot` is the Godot 4.x rebuild of the existing Unity prototype `닌자 서바이벌`.

The Unity archive is reference material only. Future implementation must use Godot Scene/Node/GDScript structure.

## Rule Priority

1. Latest user instruction
2. This `AGENTS.md`
3. `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`
4. `docs/BASE_RULES_VERSION.md`
5. `docs/CURRENT_CONFIRMED_DECISIONS.md` for the latest approved project/product decisions
6. `docs/DOCUMENTATION_MAP.md`
7. Project-local Base rules
8. Project-specific docs and README
9. Current Issue / Goal
10. Actual repository files

For resume/handoff work, also read `docs/ACTIVE_CONTEXT.md` when it exists. It is a state router, not a substitute for the decision/document owners above.

## Active Delivery Contract — v4.5 r2

The active project execution/delivery contract is:

`PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`

```yaml
contract_version: 4.5
revision: 2026-08-11-r2
source_bytes: 77734
source_lf_count: 2849
source_sha256: 3f898b7e2749a2e1900e9df48183f02d4fbc735fd0e80297f28bb09317144de4
source_git_blob_sha1: de7c6f818a4c96d2a02edea5eaff33bb1c39e8da
contract_role: ACTIVE_PROJECT_THIN_ADAPTER_EXECUTION_AND_DELIVERY_CONTRACT
```

The tracked r2 file is the byte-exact source authority. Do not rewrite it merely to make it look project-specific.

### Ninja Survival path override

The r2 source contains these historical foreign-project values in §4:

`C:/Users/user/Documents/GitHub/Ninza/Switchy-Express-Cargo-Puzzle`

For this repository they are classified:

`STALE_FOREIGN_PROJECT_INPUT / NON_EXECUTABLE_FOR_NINJA_SURVIVAL`

The authoritative project-local and Godot checkout for Ninja Survival is:

`C:/Users/user/Documents/GitHub/Ninza/ninja-survival-godot`

Do not execute PowerShell/Codex/Godot commands against the Switchy path when working on this repository. This bounded project override is authoritative because the r2 contract itself places latest user instruction and project `AGENTS.md` / project safety-engine-data contracts above the execution contract. All other r2 phase/gate semantics remain active.

### r2 phase transition

```text
PHASE A — GPT CHAT PLANNING
→ explicit user declaration `기획 완료`
→ PHASE B — FINAL PLANNING REVIEW / DEFINITION OF READY
→ PHASE B PASS
→ PHASE C — POWERSHELL / CODEX / GODOT BUILD
→ TDD task execution
```

`기획 완료` ends Phase A; it does **not** mean “start T01 production code immediately.” Phase B must re-query current repository/Base/connected-state evidence, re-read the approved canon and implementation plan, classify stale/current/conflicting material, validate dependencies/order/protected scope, run the required adversarial/Superpowers review, and close Definition of Ready. Only Phase B PASS authorizes Phase C.

The user instruction that adopted this r2 contract and authorized continuous work permits the documentation/canon replacement and its PR validation/merge. It is not itself the separate `기획 완료` declaration.

## Superpowers Replacement Workflow

Follow this order before implementation:

```text
User idea or opinion → clarification questions and discussion → confirmed specification → high-quality working prompt → work starts → Compound Review
```

Codex prompts should start with `@Superpowers` when the plugin is callable.

Required Codex prompt opening:

```text
@Superpowers Use this repository's spec-first workflow and active v4.5 r2 delivery contract.
Do not edit files immediately.
First read AGENTS.md, PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md, docs/BASE_RULES_VERSION.md, docs/DOCUMENTATION_MAP.md, docs/CURRENT_CONFIRMED_DECISIONS.md, docs/ACTIVE_CONTEXT.md, project-local Base rules, current Issue/Goal, and relevant files.
Confirm that Phase B Definition of Ready has passed before entering Phase C production BUILD.
Then summarize the goal, player experience, implementation scope, excluded scope, likely changed files, risks, completion criteria, and test checklist.
Proceed only within the confirmed scope.
At the end, run Compound Review and report mistakes, lessons, prevention rules, and Base-promotion candidates.
```

## Godot Rules

- Use Godot 4.x and GDScript.
- Do not write Unity/C#/MonoBehaviour/Prefab-based implementation plans for the Godot version.
- Do not directly translate Unity C# line by line.
- Use Godot Nodes, Scenes, signals, resources, and JSON/data files where appropriate.
- Keep each Codex Goal small, even if the full planning MVP is broader.
- Preserve user-made art and gameplay intent from the Unity archive.
- Do not claim the Godot port is complete unless actual Godot files were created and tested.

## Benchmarking Rule

Before new planning or implementation work, check the current benchmark notes and record:

```md
## Benchmarking conclusion

- Must reflect:
- Conditional:
- Excluded:
- Risks:
- Validation method:
```

Do not copy benchmarked games directly. Convert observed patterns into the confirmed `닌자 서바이벌` loop.

For material MVP-4 backpack questions, the user explicitly requires fresh backpack-genre/current-practice benchmarking before the next question or design action. Distinguish benchmark fact, Ninja Survival adaptation, and what must not be copied.

## Current Planning MVP Scope

The older initial MVP scope is now treated as `MVP-0: basic combat foundation`.

The current planning MVP is a staged validation slice, not a finished game. It validates whether these systems connect:

- Basic combat foundation
- Combat DDD: kill combo, stylish score, reward absorption feedback
- Four shallow ninja schools: 봉마류, 천술류, 귀인류, 흑영류
- Stage structure: 5-minute combat segments, one elite/midboss around the 3-minute mark, a segment boss around the 5-minute mark, and a 20-minute final boss target for the later final-loop slice
- Stage-end result cards for damage, healing, defense, status application, and combo/kill contribution
- Rest phase: combat summary, loot, backpack cleanup, combination hints, shop/upgrade, fate/mission choice, next-stage preview
- Backpack basics: temporary storage/work buffer, usable-space limit, bag expansion, item/bag rotation, adjacency synergy, selected non-rectangular bag shapes, combination hints
- Fate choices that change the rules of the current run
- Final result: ninja rank, stylish score, MVP ninjutsu/equipment, fate result, short ending text, Ninja Soul reward

Do not implement this full planning MVP in one Codex task. Split it into staged Goals documented in `MVP_ROADMAP.md`.

## MVP Stage Order

1. `MVP-0` Basic combat foundation
2. `MVP-1` Combat DDD feedback
3. `MVP-2` Four shallow ninja schools
4. `MVP-3` Stage result and rest-loop skeleton
5. `MVP-4` Backpack and combination basics
6. `MVP-5` Final run loop and meta reward skeleton

## Explicit MVP Exclusions

For the current staged MVP, exclude:

- Full skill pools for all four schools
- Second/third-stage combinations
- Arbitrary complex item polyomino/deep shape systems beyond the approved MVP-4 rectangular items and selected L/T bag shapes
- Deep set effects and deep curse systems
- Full ending branches or ending CGs
- Complete shop economy, reroll economy, or final balance tuning
- Polished UI animation and full art production
- Complex boss pattern sets

MVP-4 specifically **does include 90-degree rotation for both items and bags** plus selected non-rectangular bag shapes. Do not restore the older rotation exclusion; see `docs/CURRENT_CONFIRMED_DECISIONS.md`.

Use card/text/placeholder UI where it is enough to validate the loop.

## Expected Structure

```text
scenes/
  main/
  player/
  enemies/
  projectiles/
  ui/
  stages/
  rest/
  results/
scripts/
  core/
  player/
  enemies/
  combat/
  ui/
  data/
  schools/
  rest/
  results/
data/
  player/
  enemies/
  weapons/
  ninjutsu/
  schools/
  stages/
  fates/
assets/
  sprites/
  animations/
  audio/
docs/
```

## Reporting Requirements

Every implementation report must include:

- Superpowers usage
- Files inspected
- Files changed
- Change reason
- Implementation summary
- Verification performed
- Untested items
- User check steps in Godot
- Remaining risks
- Compound Review

## Compound Review

At the end of every execution-review cycle, report:

- Mistakes or near-misses
- Lessons learned
- Prevention checklist
- One prevention sentence for the next Codex prompt
- Base-promotion candidates
- Project-only rule candidates
