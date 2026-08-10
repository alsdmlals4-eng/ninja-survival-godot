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

`GAP` is intentional: the L2 design is approved, but MVP-4 production implementation and executed MVP-4 verification do not exist yet. A plan or test definition cannot promote this packet to `CONVERGED`.

## 2. Canonical authority

```yaml
canonical_sources:
  - source_id: MVP4-DESIGN
    path: docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md
    section_or_record: Sections 0-23 / AC-01..AC-15
    authority: approved detailed behavior, rules, UX and acceptance criteria
  - source_id: MVP4-DECISIONS
    path: docs/CURRENT_CONFIRMED_DECISIONS.md
    section_or_record: MVP-4 — Backpack / Combination Basics
    authority: current approved decisions including DEC-2026-08-11-001
  - source_id: PROJECT-RULES
    path: AGENTS.md
    section_or_record: current project execution and MVP constraints
    authority: execution, safety, engine and scope constraints
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
  - orthogonal adjacency and one-cell special-bag overlap activation
  - 6-slot REST work buffer, empty before Fate/combat commit
  - explicit atomic combination transaction and progressive hints
  - boss reward + shop + chest acquisition pillars
  - approximately 3-minute elite and approximately 5-minute segment boss cadence
  - Persistent Workbench with mouse, keyboard/gamepad and touch completion paths
  - mutually exclusive visible whole-layout movement mode
excluded_scope:
  - 2nd/3rd-tier combinations
  - arbitrary polyomino regular items
  - deep set/curse/rarity systems
  - new save system
  - MVP-5 final boss/final result/Ninja Soul work
  - final UI art and animation production
```

## 3. Traceability matrix

| decision_id | requirement_id | requirement summary | acceptance_criteria_ids | task_ids | planned implementation paths | verification_ids | status |
|---|---|---|---|---|---|---|---|
| DEC-2026-08-11-001 | REQ-MVP4-01 | Item/bag definitions and runtime instances carry stable footprint, rotation and effect identity | AC-01, AC-02, AC-13 | T01 | `scripts/data/item_definition.gd`; `scripts/data/bag_definition.gd`; `scripts/data/item_instance.gd`; `scripts/data/bag_instance.gd`; `scripts/data/combination_definition.gd`; `scripts/data/mvp4_catalog.gd` | V01 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-02 | `BackpackState` owns placements; `BackpackResolver` deterministically validates occupancy, active cells, connectivity, adjacency and special-bag overlap | AC-01..AC-05, AC-13 | T02, T03 | `scripts/backpack/backpack_state.gd`; `scripts/backpack/backpack_resolution.gd`; `scripts/backpack/backpack_resolver.gd` | V02, V03 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-03 | `RestBackpackSession` owns 6-slot buffer, previews, Undo/Redo, whole-layout mode and edit history | AC-01, AC-02, AC-06, AC-10, AC-14, AC-15 | T04 | `scripts/backpack/rest_backpack_session.gd`; `scripts/backpack/build_preview_snapshot.gd` | V04 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-04 | Combination requires legal orthogonal ingredients, explicit action and legal result placement before atomic source consumption; hints progress by discovery | AC-09, AC-14 | T05 | `scripts/backpack/combination_resolver.gd`; `scripts/backpack/rest_backpack_session.gd`; `scripts/data/mvp4_catalog.gd` | V05 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-05 | `RunBuildState` consumes committed spatial modifier snapshot + Fate; buffer/uncommitted items never change combat runtime modifiers | AC-06, AC-08, AC-13 | T06 | `scripts/core/run_build_state.gd`; `scripts/data/run_modifier_set.gd`; `scripts/backpack/backpack_resolver.gd` | V06 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-06 | Boss reward, shop and chest are distinct atomic REST transactions; acquisitions enter Workbench rather than immediate combat effects | AC-07, AC-08, AC-14 | T07 | `scripts/core/rest_reward_controller.gd`; `scripts/core/shop_controller.gd`; `scripts/data/mvp4_catalog.gd` | V07 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-07 | Each five-minute segment emits one elite opportunity around minute 3, then boss, result, forced boss reward and REST before Fate | AC-07, AC-11, AC-14 | T08 | `scripts/core/stage_flow_controller.gd`; `scripts/core/main_controller.gd`; `scripts/enemies/stage_elite.gd`; `scenes/enemies/stage_elite.tscn` | V08 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-08 | Persistent Workbench keeps board central, displays legality/synergy/combo/commit state and never owns domain rules | AC-01, AC-03..AC-05, AC-11 | T09 | `scripts/ui/rest_workbench_ui.gd`; `scripts/ui/backpack_board_ui.gd`; `scenes/ui/rest_workbench_ui.tscn`; `scenes/ui/backpack_board_ui.tscn`; `scripts/ui/rest_flow_ui.gd`; `scenes/ui/rest_flow_ui.tscn` | V09 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-09 | Mouse, keyboard/gamepad and touch can all complete REST; whole-layout mode is visible/mutually exclusive; Android controls meet touch-target guidance | AC-12, AC-15 | T10 | `scripts/ui/rest_workbench_ui.gd`; `scripts/ui/backpack_board_ui.gd`; `scenes/ui/rest_workbench_ui.tscn`; `scenes/ui/backpack_board_ui.tscn`; no required shared `project.godot` InputMap mutation | V10 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-10 | Fate is gated by zero chest/buffer/pending transaction and legal connected placements; MVP-3 behavior stays regression-protected | AC-06, AC-07, AC-11, AC-14 | T11 | `scripts/core/main_controller.gd`; `scripts/core/stage_flow_controller.gd`; `scripts/ui/rest_flow_ui.gd`; `scenes/ui/rest_flow_ui.tscn`; `scenes/main/main_scene.tscn` | V11 | APPROVED |
| DEC-2026-08-11-001 | REQ-MVP4-11 | Exact-head CI, deterministic GUT, responsive UI checks and Windows/Android human evidence remain separate gates | AC-12, AC-13, AC-15 | T12 | existing `.github/workflows/gut.yml` remains unchanged unless a separately proven verification gap exists; evidence updates go to this packet and `docs/ACTIVE_CONTEXT.md` | V12 | APPROVED |

Read-only existing dependencies for T08:

- `scripts/spawning/wave_spawner.gd`: existing `spawn_distance` and normal spawn enable/disable API are reused; no planned modification.
- `scripts/enemies/stage_boss.gd`: existing five-minute boss identity/tier behavior is preserved; no planned modification.

### Acceptance-criteria coverage check

```yaml
AC-01: REQ-MVP4-01, REQ-MVP4-02, REQ-MVP4-03, REQ-MVP4-08
AC-02: REQ-MVP4-01, REQ-MVP4-03
AC-03: REQ-MVP4-02, REQ-MVP4-08
AC-04: REQ-MVP4-02, REQ-MVP4-08
AC-05: REQ-MVP4-02, REQ-MVP4-08
AC-06: REQ-MVP4-03, REQ-MVP4-05, REQ-MVP4-10
AC-07: REQ-MVP4-06, REQ-MVP4-07, REQ-MVP4-10
AC-08: REQ-MVP4-05, REQ-MVP4-06
AC-09: REQ-MVP4-04
AC-10: REQ-MVP4-03
AC-11: REQ-MVP4-07, REQ-MVP4-08, REQ-MVP4-10
AC-12: REQ-MVP4-09, REQ-MVP4-11
AC-13: REQ-MVP4-01, REQ-MVP4-02, REQ-MVP4-05, REQ-MVP4-11
AC-14: REQ-MVP4-03, REQ-MVP4-04, REQ-MVP4-06, REQ-MVP4-07, REQ-MVP4-10
AC-15: REQ-MVP4-03, REQ-MVP4-09, REQ-MVP4-11
unmapped_acceptance_criteria: []
```

## 4. Verification evidence

| verification_id | requirement_ids | method | exact planned evidence | current result | status |
|---|---|---|---|---|---|
| V01 | REQ-MVP4-01 | catalog/data GUT | `tests/unit/test_mvp4_catalog.gd` under Godot 4.7.1 + GUT 9.7.1 | implementation not started | NOT_RUN |
| V02 | REQ-MVP4-02 | state GUT | `tests/unit/test_backpack_state.gd` | implementation not started | NOT_RUN |
| V03 | REQ-MVP4-02 | geometry/relation GUT | `tests/unit/test_backpack_resolver.gd` | implementation not started | NOT_RUN |
| V04 | REQ-MVP4-03 | session/history/mode GUT | `tests/unit/test_rest_backpack_session.gd` | implementation not started | NOT_RUN |
| V05 | REQ-MVP4-04 | combination transaction GUT | `tests/unit/test_combination_resolver.gd` | implementation not started | NOT_RUN |
| V06 | REQ-MVP4-05 | committed modifier GUT | existing `tests/unit/test_run_build_state.gd` + four-school modifier regression | implementation not started | NOT_RUN |
| V07 | REQ-MVP4-06 | acquisition GUT | `tests/unit/test_rest_reward_controller.gd` + existing `tests/unit/test_shop_controller.gd` | implementation not started | NOT_RUN |
| V08 | REQ-MVP4-07 | cadence/elite/stage GUT | existing `tests/unit/test_stage_flow_controller.gd`; new `tests/unit/test_stage_elite.gd`; unchanged existing `tests/unit/test_wave_spawner.gd` regression; accelerated integration loop | implementation not started | NOT_RUN |
| V09 | REQ-MVP4-08 | Workbench UI integration | `tests/integration/test_mvp4_workbench_ui.gd` | implementation not started | NOT_RUN |
| V10 | REQ-MVP4-09 | input/responsive GUT + human device pass | `tests/integration/test_mvp4_input_parity.gd`; manual Windows mouse/keyboard/gamepad; Android touch task | no MVP-4 build/device evidence | BLOCKED_UNVERIFIED |
| V11 | REQ-MVP4-10 | accelerated end-to-end/regression | `tests/integration/test_mvp4_stage_rest_loop.gd`; `tests/integration/test_mvp4_four_school_builds.gd`; existing MVP-0~3 regression | implementation not started | NOT_RUN |
| V12 | REQ-MVP4-11 | exact-head CI + smoke + full GUT + human evidence review | existing GitHub Actions `.github/workflows/gut.yml`, then recorded human QA matrix | implementation not started | NOT_RUN |

## 5. Coverage gaps

```yaml
unmapped_items: []
unknowns:
  - exact human REST-duration success threshold remains a design hypothesis and must be measured, not invented
  - Android real-device/export evidence may remain BLOCKED_UNVERIFIED if no authorized Android route exists
  - Google Sheet synchronization remains GITHUB_UPDATE_PENDING_SHEET / BLOCKED_USER_ACTION_403
```

All approved requirements and AC-01..AC-15 have planned Task and Verification links. There is still no implementation evidence, so `coverage_status` remains `GAP`.

## 6. Convergence rules

- Promote to `CONVERGED` only when every requirement points to actual merged implementation paths and executed required evidence, with no unmapped item.
- Written plan, created test file, or a green focused test alone does not establish convergence.
- UI screenshots cannot replace domain deterministic tests; automated tests cannot replace human usability evidence for input parity/readability.
- If approved L2 behavior changes, update Decision + L2 Spec first, then recalculate this packet and the Plan.
- If human QA exposes a core UX/product conflict, return to PLAN and classify it `USER_DECISION_REQUIRED` rather than silently changing the core contract in BUILD.

## 7. Phase ownership

```text
approved L2 Spec
→ this L3 packet
→ Superpowers implementation plan
→ explicit user `기획 완료`
→ authorized BUILD executor
→ RED → GREEN → regression per task
→ exact-head REVIEW + human evidence
→ traceability convergence recalculation
```

Production implementation is explicitly **NOT_STARTED** at this packet revision.