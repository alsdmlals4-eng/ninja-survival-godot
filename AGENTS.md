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
- Keep the first Godot MVP small.
- Preserve user-made art and gameplay intent from the Unity archive.
- Do not claim the Godot port is complete unless actual Godot files were created and tested.

## Initial MVP Scope

Include:

- Player 8-direction movement
- Camera follow
- One low-rank enemy chase behavior
- Automatic projectile attack
- Enemy hit/removal
- Score UI
- Basic game over flow

Exclude for MVP 1:

- Backpack system
- Ninja school selection
- Ninjutsu combination
- Ultimate/step technique progression
- Rest phase
- Store/upgrades
- Full animation set
- Advanced infinite map

## Expected Structure

```text
scenes/
  main/
  player/
  enemies/
  projectiles/
  ui/
  stages/
scripts/
  core/
  player/
  enemies/
  combat/
  ui/
  data/
data/
  player/
  enemies/
  weapons/
  stages/
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
