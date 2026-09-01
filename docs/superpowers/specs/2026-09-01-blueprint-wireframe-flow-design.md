# 닌자의 신 — 소비처 연결형 블루프린트·와이어프레임·플로우 설계 명세

```yaml
id: NS-BLUEPRINT-001
status: SPECIFICATION_REVIEW_PENDING
date: 2026-09-01 KST
baseline_main: afbba903d5fcf32b8ecc8082c59baecb01e895c5
authority:
  product: docs/CURRENT_CONFIRMED_DECISIONS.md + docs/canon/**
  mutable_state: docs/ACTIVE_CONTEXT.md
  visual: docs/CURRENT_VISUAL_HANDOFF.md + docs/visual/** + approved manifests
  implementation: scenes/** + scripts/** + data/** + tests/**
  execution: docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md
scope_state: USER_APPROVED_BLUEPRINT_AWAITING_SPEC_REVIEW
minor_technical_drift_2026_09_01:
  finding: SCRREF-BATTLE-AUTOCOMBAT-03 is already user-locked for the exact continuous-floor and top-HUD planning role.
  correction: reuse the locked reference; do not generate a duplicate Battle HUD candidate.
  rollback: additive documentation-only correction; no asset or runtime consumer changes.
```

## 1. Outcome and boundary

Create one repository-native, text-editable Blueprint that connects the
player journey, wireframes, Godot consumers, visual-input needs, and evidence
ceilings for the current Ninja Survival direction. It must make the next
screen, image, and implementation decision inspectable without becoming a
second game-rule canon, asset provenance manifest, task database, or fake
runtime proof.

This package is planning/preproduction work. It does **not**:

- merge, rebase, or alter open PR #135 or any other existing PR;
- replace the approved title wordmark, four-traditions medal, runtime visual
  core, or registered asset provenance;
- change combat, route, economy, save, Workbench atomicity, or Godot scene
  behavior;
- promote a generated image to a durable repository asset before explicit
  user `LOCK`; or
- claim Human Usability, Player Experience, device/export, or release proof.

## 2. Confirmed player-facing direction

The Blueprint must preserve these user-approved product choices and identify
any current document/implementation mismatch without silently changing it.

| Topic | Confirmed direction |
| --- | --- |
| Combat agency | Player moves and uses invulnerable Dash evasion; Japanese sword, shuriken, and one starting ninjutsu auto-attack. |
| Crowd pressure | Enemies enter at random positions beyond a player-safe radius; at least ten pursue during normal pressure; no design maximum is imposed. |
| Enemy hierarchy | Core enemies create chase/contact pressure. One Core type may use readable ranged pressure only after its gated encounter introduction. Elite and Boss own telegraphed patterns. |
| Early difficulty | Regular opening enemies do not fill the arena with talisman projectiles or persistent hazard fields. |
| HUD | No bottom skill bar. Normal HUD is top-only: life, Dash charges, elapsed time, pause/settings. Elite/Trace/Boss information appears only when relevant. |
| Visual split | Key art/title uses moonlit painterly ninja/ink language. Runtime uses small top-down SD units, continuous floor, sparse modular props, grounded contact shadows, and high-signal effects. |
| Player identity | One black/deep-navy ninja stays visually fixed; four schools appear as acquired trace/effect layers rather than replacement protagonists. |
| Backpack | Player-facing beginning is exactly 3x3 usable space, growing toward a 6x6 technical outer board, as owned by DEC-037. Existing 4x3 runtime baseline references are a separately deferred migration boundary, not a silent code change in this package. |
| Title and menu | Wordmark + separately placed four-piece medal; 새 게임, 이어하기, 각성, 도감, 조작 방법, 설정, 종료. `각성` is player copy; legacy technical wallet identifiers remain compatibility-only. |
| Codex | Read-only explanations for 적, 인법서, 장비, 가방, 조합; not a Run journal or new progression system. |

## 3. Benchmark synthesis and decision record

Twelve materially relevant games were inspected as patterns, not content or
trade-dress sources: Vampire Survivors, Brotato, Halls of Torment, Death Must
Die, Soulstone Survivors, 20 Minutes Till Dawn, Nordic Ashes, Rogue: Genesia,
Army of Ruin, Yet Another Zombie Survivors, Deep Rock Galactic: Survivor, and
Magic Survival.

| Pattern | Disposition | Ninja Survival fit / implementation boundary |
| --- | --- | --- |
| automatic weapons with movement-led survival | `ADOPT` | Preserve automatic sword/shuriken/ninjutsu; player skill remains spacing and Dash timing. |
| continuously accumulating horde pressure | `ADOPT` | Use current enemy/wave ownership; do not introduce a second wave system. |
| compact top-only play HUD | `ADAPT` | Normal play shows only life, Dash, time, pause/settings; event information is temporal. |
| enemy danger telegraph before an elite/boss pattern | `ADOPT` | Telegraph must be spatial, brief, and visually distinct from player attacks. |
| route choice between combat, shop, rest, boss | `ADAPT` | Reuse school route/Workbench/Fate ownership; a Blueprint does not change provisional-route atomicity. |
| build-changing selection | `ADAPT` | Spatial item placement, adjacency, bags, combinations, and Fate carry the project-specific choice. |
| persistent lower skill tray | `REJECT` | Auto-attacks are read in the battlefield, not manually triggered from a bottom bar. |
| early ordinary-enemy projectile/field spam | `REJECT` | Core opening pressure teaches crowd movement first; complex fields are Elite/Boss ownership. |
| bitmap-only dynamic buttons/cards | `REJECT` | Menu, tabs, cards, counters, focus, localization, and value state remain Godot Control/text surfaces. |

Primary/direct source examples that informed the pattern read: [Soulstone
Survivors official site](https://soulstonesurvivors.com/), [Rogue: Genesia
official site](https://puls.games/rogue-genesia), [20 Minutes Till Dawn on
Steam](https://store.steampowered.com/app/1966900/20_Minutes_Till_Dawn/),
[Death Must Die on Steam](https://store.steampowered.com/app/2334730/Death_Must_Die/),
[Yet Another Zombie Survivors on Steam](https://store.steampowered.com/app/2163330/Yet_Another_Zombie_Survivors/),
and [Magic Survival on Google Play](https://play.google.com/store/apps/details?id=com.vkslrzm.Zombie).

## 4. Blueprint owner and output shape

After this specification is approved, the single new human-readable source
will be:

```text
docs/visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md
```

It will link existing canon, visual handoff, screen coverage, asset manifests,
and implementation consumers instead of reproducing their contents. The
Blueprint contains these text-native sections:

1. scope, authority, evidence ceiling, and non-scope;
2. full player journey flow map;
3. battle lifecycle flow, including Core → Elite → Trace → Boss;
4. six screen wireframes and per-screen interaction map;
5. runtime HUD visibility rules and event escalation rules;
6. screen-to-Godot consumer map and input obligations;
7. visual-input ledger that separates existing assets, Godot UI, runtime VFX,
   and one candidate image request;
8. benchmark disposition, feasibility, rollback, and validation plan.

Mermaid and fixed-width text wireframes are the editable source. A generated
pixel reference may illustrate one approved consumer but never replaces the
wireframe, labels, logic, or screen state.

## 5. Player journey and required screen wireframes

### 5.1 Top-level player journey

```text
Title
 ├─ New Game → starting-school selection → battle
 ├─ Continue → validated Workbench checkpoint → fresh next-stage battle
 ├─ Awakening → read-only balance / retry explanation
 ├─ Codex → enemy / ninjutsu / equipment / bag / combination knowledge
 └─ Guide / Settings / Quit → local modal → return to title

Battle
 ├─ Core crowd pressure → level/build feedback
 ├─ Elite clear → chest token + Trace AVAILABLE
 ├─ Trace recovery → Boss eligibility
 ├─ Boss warning / dual gate → boss pattern encounter
 └─ Boss result → reward → Workbench

Workbench
 ├─ item/bag placement and rotation
 ├─ adjacency / combination preview
 ├─ provisional next-school selection
 └─ Fate atomic commit → next stage
```

### 5.2 Wireframe targets

| Screen ID | Purpose | Required visible hierarchy | Actual / planned consumer |
| --- | --- | --- | --- |
| `BP-TITLE-01` | First entry and utility access | wordmark, separate medal, ordered menu, local modals | planned `TitleScreen`; PR #135 is read-only design reference, not current-main proof |
| `BP-SCHOOL-SELECT-01` | choose next danger | school symbols, visited state, provisional-choice explanation, help | `Main/SchoolSelectionUI` |
| `BP-BATTLE-HUD-01` | survive/read pressure | top-only HUD, grounded player/enemy read, event-only threat band | `Main/HUD`, `Main`, combat actors |
| `BP-TRACE-GATE-01` | understand progress gate | Elite clear, chest token, Trace, Boss warning separation | `Main` lifecycle / HUD feedback owner |
| `BP-RESULT-01` | understand earned outcome | reward source, reward choice/acknowledgement, Workbench handoff | `RestFlowUI/ResultView` |
| `BP-WORKBENCH-01` | author the next build | 3x3-to-6x6 growth framing, six REST slots, rotate, adjacency, commit boundary | `RestFlowUI/WorkbenchView` |

### 5.3 Battle HUD visibility contract

| State | Persistent information | Event-only information | Explicit exclusion |
| --- | --- | --- | --- |
| Core opening | life, Dash charges, elapsed time, pause/settings | short spawn/introduction cue when needed | bottom skills, routine enemy HP bars, wide hazard panels |
| Crowd pressure | same four anchors | hit-only target HP; short build/reward feedback | persistent status paragraphs, normal-core telegraph clutter |
| Elite / Trace | same four anchors | Elite marker, Trace available/recovered confirmation | misleading direct-power reward interpretation |
| Boss warning / Boss | same four anchors | warning banner, boss life/pattern telegraph while active | generic Core projectile field reused as boss signal |

## 6. Visual-input decision and one-image gate

### Existing reusable inputs

- The approved runtime floor tile, contact shadow, sparse prop atlas, player,
  and runtime visual core are reused through their existing manifest/consumer
  owners.
- Title wordmark, moonlit backdrop, and four-traditions medal remain approved
  assets in the existing title-package lineage; this Blueprint does not create
  replacements.
- Dynamic button, tab, card, counter, and localization text stay Godot UI.

### Reused planning reference and future candidate boundary

`SCRREF-BATTLE-AUTOCOMBAT-03` already has the exact needed human consumer and
user `LOCK` state for continuous floor, sparse independent props, grounded
units, and top-only automatic-combat HUD. The Blueprint must link to that
existing reference and must **not** generate a duplicate `SCRREF-BATTLE-HORDE-HUD-01`.

The first new image is permitted only if an actual post-Blueprint runtime or
screen review identifies a missing visual consumer that existing locked or
approved sources cannot satisfy. The owner then records the consumer and a
text brief before exactly one candidate is generated:

```text
actual visual-consumer gap → text brief → one GENERATED_CANDIDATE
→ user LOCK / REVISE / REJECT
```

Only `LOCK` permits a repository copy, SHA-256/provenance record, planning
reference registration, and later implementation-consumer test. A locked
planning reference remains distinct from a runtime asset and from live visual
or Human play evidence.

## 7. Feasibility and implementation boundary

The Blueprint is feasible without a new dependency, autoload, save system,
second wave system, paid service, or external owner.

| Concern | Existing owner to reuse | Required proof after later implementation |
| --- | --- | --- |
| battle presentation | `main_scene.tscn`, `HUD`, actors, current VFX consumers | parser/import + headless main smoke + focused UI/runtime checks |
| Dash / movement input | Player/input owners | movement and invulnerable-Dash regression test; runtime-input observation remains separate |
| Elite/Trace/Boss gate | lifecycle/domain controllers | focused lifecycle tests and Main integration route |
| backpack / Fate | `BackpackState`, Workbench, route/Fate owners | focused domain and UI tests; preserve atomicity |
| title actions | title/MainController package if separately adopted | exact current-task branch/PR verification; PR #135 is not mutated by this scope |
| candidate image | existing screen-reference/provenance route | user lock, file hash, actual declared consumer, import/readback when applied |

## 8. Acceptance, rollback, and evidence ceiling

### Acceptance for the Blueprint package

1. One Blueprint has a unique role and links rather than duplicates existing
   owners.
2. The complete title → battle → Elite/Trace/Boss → result → Workbench/Fate
   journey is represented as editable flow.
3. All six wireframes declare purpose, player question, primary action,
   information hierarchy, input path, and actual/planned Godot consumer.
4. HUD rules visibly protect the no-bottom-skill and event-only danger rules.
5. Existing assets versus Godot UI versus runtime VFX are unambiguous, and
   the existing locked battle reference is reused rather than duplicated.
6. The DEC-037 3x3-to-6x6 player direction is represented accurately while
   its runtime migration remains explicitly deferred.
7. Benchmark records contain `ADOPT / ADAPT / REJECT` decisions and sources.

### Rollback

The Blueprint and a later image candidate are additive. Reverting the
Blueprint commit removes no existing product owner or runtime resource. A
rejected candidate is never registered/promoted; a locked but unsuitable
planning reference can be unlinked in a later Git-recoverable change after
consumer/reference checks.

### Evidence ceiling at this phase

`E0_CONTRACT` and `E1_STATIC` are the maximum targets for the Blueprint
document itself. No execution in this package proves the artwork reads in the
actual Godot renderer, that the HUD works with player input, that the crowd is
performant, or that a human player understands the flow. Those remain later
`E3_RUNTIME`, `E4_VISUAL`, `E5_PLAY`, and `E6_HUMAN_PLAYTEST` gates.

## 9. Planned sequence after specification approval

```text
approve this specification
→ write reviewed implementation plan
→ create Blueprint source + cross-links
→ static/link validation and five whole-scope adversarial loops
→ reuse SCRREF-BATTLE-AUTOCOMBAT-03 as the battle visual anchor
→ runtime/screen review finds a real visual-consumer gap only if one exists
→ then, and only then, one candidate → user LOCK / REVISE / REJECT
```
