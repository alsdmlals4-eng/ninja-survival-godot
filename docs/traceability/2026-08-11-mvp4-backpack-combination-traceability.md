# MVP-4 Backpack / Combination Basics — Feature Spec Traceability Packet

## 1. Packet identity

```yaml
packet_id: MVP4-TRACE-2026-08-11-001
work_level: L3
design_spec_id: MVP-4-BACKPACK-COMBINATION
canonical_design_spec_path: docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md
approval_reference: user written-spec approval in project chat on 2026-08-11; PR #7 design checkpoint merged as 655ec26a5ac9946c0ec08f81f389ddfe66e72b65
source_commit: 655ec26a5ac9946c0ec08f81f389ddfe66e72b65
created_at: 2026-08-11
updated_at: 2026-08-11
coverage_status: GAP
```

`GAP` is intentional: the L2 design is approved, but MVP-4 production implementation and executed MVP-4 verification do not exist yet. This packet must not be promoted to `CONVERGED` from plan files or test definitions alone.

## 2. Canonical authority

```yaml
canonical_sources:
  - source_id: MVP4-DESIGN
    path: docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md
    section_or_record: Sections 0-23 / AC-01..AC-15
    authority: approved detailed feature behavior, rules, UX, acceptance criteria
  - source_id: MVP4-DECISIONS
    path: docs/CURRENT_CONFIRMED_DECISIONS.md
    section_or_record: MVP-4 — Backpack / Combination Basics
    authority: current approved product decisions including DEC-2026-08-11-001
  - source_id: PROJECT-RULES
    path: AGENTS.md
    section_or_record: current project execution and MVP constraints
    authority: repository execution, safety, engine and scope constraints
  - source_id: MVP-ROADMAP
    path: MVP_ROADMAP.md
    section_or_record: MVP-4
    authority: staged MVP boundary
  - source_id: ACTIVE-STATE
    path: docs/ACTIVE_CONTEXT.md
    section_or_record: current implementation/verification state
    authority: mutable live-state router only
protected_scope:
  - fixed 6x6 board and 4x3 starting active area
  - 90-degree bag/item rotation
  - orthogonal item adjacency and one-cell special-bag overlap activation
  - 6-slot REST work buffer that must be empty before Fate/combat commit
  - explicit atomic combination transaction and progressive hints
  - boss reward + shop + chest acquisition pillars
  - approximately 3-minute elite and approximately 5-minute segment boss cadence
  - Persistent Workbench with mouse, keyboard/gamepad and touch completion paths
  - mutually exclusive visible whole-layout movement mode for directional input
excluded_scope:
  - 2nd/3rd-tier combinations
  - arbitrary polyomino regular items
  - deep set/curse/rarity systems
  - new save system
  - MVP-5 final boss/final result/Ninja Soul work
  - final UI art and animation production
```

## 3. Traceability matrix

| decision_id | requirement_id | requirement summary | acceptance_criteria_ids | task_ids | implementation_paths | verification_ids | status |
|---|---|---|---|---|---|---|---|
| DEC-2026-08-11-001 | REQ-MVP4-01 | Spatial data contracts: item/bag definitions and runtime instances carry stable footprint/rotation/effect identity | AC-01, AC-02, AC-13 | T01 | `scripts/data/item_definition.gd`, `scripts/data/bag_definition.gd`, `scripts/data/item_instance.gd`, `scripts/data/bag_instance.gd`, `scripts/data/combination_definition.gd`, `scripts/data/mvp4_catalog.gd` | V01 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-02 | `BackpackState` owns the 6x6 board placements while `BackpackResolver` deterministically validates occupancy, active cells, connectivity, adjacency and special-bag overlap | AC-01..AC-05, AC-13 | T02, T03 | `scripts/backpack/backpack_state.gd`, `scripts/backpack/backpack_resolver.gd` | V02, V03 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-03 | REST editing is isolated in `RestBackpackSession`: 6-slot buffer, previews, Undo/Redo, whole-layout mode and atomic edit history | AC-01, AC-02, AC-06, AC-10, AC-14, AC-15 | T04 | `scripts/backpack/rest_backpack_session.gd`, `scripts/backpack/build_preview_snapshot.gd` | V04 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-04 | Representative combinations require valid orthogonal ingredients, explicit action and legal result placement before atomic source consumption; hints progress by discovery state | AC-09, AC-14 | T05 | `scripts/backpack/combination_resolver.gd`, `scripts/backpack/rest_backpack_session.gd`, `scripts/data/mvp4_catalog.gd` | V05 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-05 | `RunBuildState` consumes committed spatial modifier snapshots plus Fate; buffer/unplaced items never change combat runtime modifiers | AC-06, AC-08, AC-13 | T06 | `scripts/core/run_build_state.gd`, `scripts/data/run_modifier_set.gd`, `scripts/backpack/backpack_resolver.gd` | V06 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-06 | Boss reward, shop and chest acquisition are distinct atomic REST transactions; purchased/reward items enter workbench flow rather than immediate combat effects | AC-07, AC-08, AC-14 | T07 | `scripts/core/shop_controller.gd`, `scripts/core/rest_reward_controller.gd`, `scripts/data/mvp4_catalog.gd` | V07 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-07 | Each five-minute segment emits an elite opportunity around minute 3, then segment boss, result, forced boss reward and Persistent Workbench before Fate | AC-07, AC-11, AC-14 | T08 | `scripts/core/stage_flow_controller.gd`, `scripts/core/main_controller.gd`, stage enemy integration | V08 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-08 | Persistent Workbench keeps the board central, exposes legality/synergy/combo/commit information and never owns domain rules | AC-01, AC-03..AC-05, AC-11 | T09 | `scripts/ui/rest_workbench_ui.gd`, `scripts/ui/backpack_board_ui.gd`, `scenes/ui/rest_workbench_ui.tscn`, `scenes/ui/backpack_board_ui.tscn`, `scripts/ui/rest_flow_ui.gd`, `scenes/ui/rest_flow_ui.tscn` | V09 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-09 | Core REST completion has equivalent mouse, keyboard/gamepad and touch paths; layout-move mode is visible/mutually exclusive; Android controls meet touch-target guidance | AC-12, AC-15 | T10 | Workbench/board UI files above; no required shared `project.godot` InputMap mutation | V10 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-10 | Fate entry is a commit boundary gated by no chest, empty buffer, no pending bag/combo, legal placements and connected bags; full MVP-3 behavior remains regression-protected | AC-06, AC-07, AC-11, AC-14 | T11 | `scripts/core/main_controller.gd`, `scripts/core/stage_flow_controller.gd`, `scripts/ui/rest_flow_ui.gd`, relevant scenes | V11 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-11 | Exact-head CI, focused deterministic GUT coverage, responsive UI checks and human Windows/Android usability evidence remain separate gates | AC-12, AC-13, AC-15 | T12 | `.github/workflows/gut.yml` unchanged unless a demonstrated verification gap requires a separate approved change; test files only | V12 | APPROVED |

## 4. Verification evidence

| verification_id | requirement_ids | method | exact command·environment | artifact·result | status |
|---|---|---|---|---|---|
| V01 | REQ-MVP4-01 | catalog/data contract GUT | `Godot 4.7.1 --headless --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_mvp4_catalog.gd -gexit` | implementation not started | NOT_RUN |
| V02 | REQ-MVP4-02 | backpack state GUT | same runner with `tests/unit/test_backpack_state.gd` | implementation not started | NOT_RUN |
| V03 | REQ-MVP4-02 | resolver geometry/relationship GUT | same runner with `tests/unit/test_backpack_resolver.gd` | implementation not started | NOT_RUN |
| V04 | REQ-MVP4-03 | REST session/history/mode GUT | same runner with `tests/unit/test_rest_backpack_session.gd` | implementation not started | NOT_RUN |
| V05 | REQ-MVP4-04 | combination transaction GUT | same runner with `tests/unit/test_combination_resolver.gd` | implementation not started | NOT_RUN |
| V06 | REQ-MVP4-05 | build-state commit/modifier GUT | same runner with `tests/unit/test_run_build_state.gd` | implementation not started | NOT_RUN |
| V07 | REQ-MVP4-06 | acquisition/shop/chest GUT | same runner with `tests/unit/test_rest_reward_controller.gd` and `tests/unit/test_shop_controller.gd` | implementation not started | NOT_RUN |
| V08 | REQ-MVP4-07 | stage flow GUT | same runner with `tests/unit/test_stage_flow_controller.gd` and accelerated integration loop | implementation not started | NOT_RUN |
| V09 | REQ-MVP4-08 | Workbench scene/UI integration GUT | same runner with `tests/integration/test_mvp4_workbench_ui.gd` | implementation not started | NOT_RUN |
| V10 | REQ-MVP4-09 | input/responsive integration + human device pass | GUT UI tests plus manual Windows mouse/keyboard/gamepad and Android touch task | no MVP-4 build/device evidence yet | BLOCKED_UNVERIFIED |
| V11 | REQ-MVP4-10 | end-to-end accelerated stage→rest→Fate loop | same runner with `tests/integration/test_mvp4_stage_rest_loop.gd` and regression suite | implementation not started | NOT_RUN |
| V12 | REQ-MVP4-11 | exact-head CI + smoke + full GUT + human evidence review | GitHub Actions `.github/workflows/gut.yml`, then recorded human QA matrix | implementation not started | NOT_RUN |

## 5. Coverage gaps

```yaml
unmapped_items: []
unknowns:
  - exact human REST-duration success threshold remains a design hypothesis and must be measured, not invented in implementation
  - Android real-device/export evidence may remain BLOCKED_UNVERIFIED if the execution environment lacks an authorized Android export/device route
  - Google Sheet canonical-summary synchronization remains GITHUB_UPDATE_PENDING_SHEET / BLOCKED_USER_ACTION after observed 403 write denial
```

All approved requirements have planned Task and Verification links, but there is no implementation evidence. Therefore `coverage_status` remains `GAP`.

## 6. Convergence rules

- Promote to `CONVERGED` only when every requirement above points to actual merged implementation paths and executed verification evidence, and there are no unmapped items.
- A written plan, created test file or green focused test alone does not establish convergence.
- A UI screenshot cannot replace domain deterministic tests; automated tests cannot replace human usability evidence for input parity/readability.
- If the approved L2 Spec changes, update the Spec/Decision first, then recalculate this packet.
- If human QA exposes a core UX/product conflict, return to PLAN and classify it `USER_DECISION_REQUIRED`; do not silently retune the core contract in BUILD.

## 7. Phase ownership

```text
approved L2 Spec
→ this L3 traceability packet
→ Superpowers implementation plan
→ user explicit `기획 완료`
→ authorized BUILD executor
→ RED → GREEN → regression per task
→ exact-head REVIEW + human evidence
→ traceability convergence recalculation
```

Production implementation is explicitly **NOT_STARTED** at packet creation time.