# Repository Guidelines

This guide applies to Codex, GPT/ChatGPT, and delegated subagents working on `ninja-survival-godot`.

## Project Identity

`ninja-survival-godot` is the Godot 4.x rebuild of the existing Unity prototype `닌자 서바이벌`.

The Unity archive is reference material only. Future implementation must use Godot Scene/Node/GDScript structure.

## Rule Priority

1. Latest user instruction
2. This `AGENTS.md`
3. `docs/BASE_RULES_VERSION.md`
4. `docs/DOCUMENTATION_MAP.md`
5. Project-local Base rules
6. Project-specific docs and README
7. Current Issue / Goal
8. Actual repository files

## Superpowers Replacement Workflow

Follow this order before implementation:

```text
User idea or opinion → clarification questions and discussion → confirmed specification → high-quality working prompt → work starts → Compound Review
```

Codex prompts should start with `@Superpowers` when the plugin is callable.

Required Codex prompt opening:

```text
@Superpowers Use this repository's spec-first workflow.
Do not edit files immediately.
First read AGENTS.md, docs/BASE_RULES_VERSION.md, docs/DOCUMENTATION_MAP.md, project-local Base rules, current Issue/Goal, and relevant files.
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

## Current Planning MVP Scope

The older initial MVP scope is now treated as `MVP-0: basic combat foundation`.

The current planning MVP is a staged validation slice, not a finished game. It validates whether these systems connect:

- Basic combat foundation
- Combat DDD: kill combo, stylish score, reward absorption feedback
- Four shallow ninja schools: 봉마류, 천술류, 귀인류, 흑영류
- Stage structure: 5/10/15 minute mid-boss checks and a 20 minute final boss target
- Stage-end result cards for damage, healing, defense, status application, and combo/kill contribution
- Rest phase: combat summary, loot, backpack cleanup, combination hints, shop/upgrade, fate/mission choice, next-stage preview
- Backpack basics: temporary storage, slot limit, adjacency synergy, combination hints
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
- Complex backpack shapes, rotation, deep set effects, and deep curse systems
- Full ending branches or ending CGs
- Complete shop economy, reroll economy, or final balance tuning
- Polished UI animation and full art production
- Complex boss pattern sets

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
