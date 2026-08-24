# DOCUMENTATION_MAP

## 목적

현재 작업자가 어떤 문서를 어떤 목적으로 읽어야 하는지와 역사 문서를 현재 실행 정본으로 오해하지 않도록 라우팅한다.

## 1. Mandatory current read path

1. `../AGENTS.md`
2. active user/chat instruction
3. `BASE_RULES_VERSION.md` when Base freshness matters
4. `CURRENT_CONFIRMED_DECISIONS.md`
5. `canon/2026-08-21-dec014-025-product-canon.md`
6. `canon/2026-08-22-dec026-encounter-pattern-budget.md`
7. `ACTIVE_CONTEXT.md`
8. `traceability/2026-08-22-dec026-post-gate-traceability.md`
9. `planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
10. `superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`
11. `superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
12. `planning/2026-08-11-mvp4-content-data-contract.md`
13. old `superpowers/plans/2026-08-11-mvp4-backpack-combination.md` — **T05-T07 reusable detail only**
14. actual `../scripts/**`, `../scenes/**`, `../tests/**`, `../.github/workflows/gut.yml`

## 2. Current product / migration / implementation documents

| Document | Role | Current state |
|---|---|---|
| `CURRENT_CONFIRMED_DECISIONS.md` | mutable approved-decision/protected-scope router | CURRENT / T04 MERGED / T05 NEXT |
| `canon/2026-08-21-dec014-025-product-canon.md` | implementation-facing product canon | CURRENT |
| `canon/2026-08-22-dec026-encounter-pattern-budget.md` | encounter/pattern canon | CURRENT / APPROVED |
| `ACTIVE_CONTEXT.md` | resume/current-state router | CURRENT / T04 MERGED / T05 NEXT |
| `traceability/2026-08-22-dec026-post-gate-traceability.md` | current reuse/supersession/migration coverage | CURRENT |
| `planning/2026-08-22-dec026-phase-b-definition-of-ready.md` | fresh implementation readiness | CURRENT / PASS |
| `superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md` | current T08+ migration plan after DEC-026 | CURRENT |
| `SYSTEM_MAP.md` | responsibility and migration map | CURRENT |
| `../MVP_ROADMAP.md` | staged validation roadmap | CURRENT |
| `../README.md` | human/agent project entry summary | CURRENT |

## 3. T01/T02/T03/T04 implementation evidence

### T01 — Spatial Data Contracts / Catalog

PR #27 merged as `7c9206702526f99dfadf44a617cd150853ec733f`.

Owners introduced/extended:

- `scripts/data/item_definition.gd`
- `scripts/data/run_modifier_set.gd`
- `scripts/data/spatial_rule_definition.gd`
- `scripts/data/bag_definition.gd`
- `scripts/data/combination_definition.gd`
- `scripts/data/mvp4_catalog.gd`
- `tests/unit/test_mvp4_catalog.gd`
- `tests/unit/test_mvp4_catalog_validation.gd`

Evidence: `Godot 4.7.1 import PASS -> main smoke PASS -> GUT 263/263 PASS -> 1829 assertions PASS`.

### T02 — BackpackState

PR #29 merged as `126e6c942d74f97166ef0c881afc5d79cae3d274`.

Owners introduced:

- `scripts/data/item_instance.gd`
- `scripts/data/bag_instance.gd`
- `scripts/backpack/backpack_state.gd`
- `tests/unit/test_backpack_state.gd`

Evidence: exact head `60adbb99886c96c687b20befe4a61e5e3bcb71f1` -> `Godot 4.7.1 import PASS -> main smoke PASS -> GUT 274/274 PASS -> 1915 assertions PASS -> T02 focused 11/11 PASS`.

T02 proves committed state primitives: 6x6 board, centered 4x3 start, stable item/bag identity, origin/rotation, atomic transitions, collision/active-area facts and defensive snapshot/copy isolation. T04 later adds only validated stable-instance restore owner paths, preserving T02 authority.

### T03 — BackpackResolver

PR #31 merged as `2dcf055d82df02d44335f209897436572efa6739`.

Owners introduced:

- `scripts/backpack/backpack_resolution.gd`
- `scripts/backpack/backpack_resolver.gd`
- `tests/unit/test_backpack_resolver.gd`
- `tests/unit/test_backpack_resolver_adversarial.gd`

Evidence: exact head `e0dacee9048a01e799012b8aca12760e07ca47ea` -> `Godot 4.7.1 import PASS -> main smoke PASS -> GUT 292/292 PASS -> 2026 assertions PASS -> T03 focused 18/18 PASS`.

T03 proves deterministic connected-layout, orthogonal-adjacency, data-driven spatial-rule, special-bag overlap and modifier-snapshot resolution plus read-only placement/translation previews.

### T04 — RestBackpackSession

PR #33 merged as `d07f16d6bae90a09bba0a5f0b8991216d006c966`.

Owners introduced/extended:

- `scripts/backpack/build_preview_snapshot.gd`
- `scripts/backpack/rest_backpack_session.gd`
- `scripts/backpack/backpack_state.gd` validated restore owner paths
- `tests/unit/test_rest_backpack_session.gd`
- `tests/unit/test_rest_backpack_session_adversarial.gd`

Evidence: exact head `6972e14cfa94dcce4d372a632db6d5e74809ee62` -> `Godot 4.7.1 import PASS -> main smoke PASS -> GUT 309/309 PASS -> 2202 assertions PASS -> T04 focused 17/17 PASS`.

T04 proves the REST edit-session domain engine: six-slot buffer, defensive preview, selected-school modifier context, edit history/undo-redo, explicit whole-layout mode/atomic translation and commit-readiness controls.

It does **not** prove T05 combination transactions, actual Workbench UI/input UX, committed combat integration or player experience.

## 4. Historical-but-still-useful MVP-4 documents

| Document | Current use |
|---|---|
| `superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` | protected 6x6/4x3/rotation/adjacency/Workbench behavior |
| `traceability/2026-08-11-mvp4-backpack-combination-traceability.md` | historical AC/T01-T12 mapping; T08+ superseded for execution |
| `superpowers/plans/2026-08-11-mvp4-backpack-combination.md` | T01/T02/T03/T04 historical implementation direction; T05-T07 detail reusable; old T08-T12 historical |
| `planning/2026-08-11-mvp4-phase-b-definition-of-ready.md` | prior technical DoR/data-contract reasoning; not current Phase-B owner |
| `planning/2026-08-11-mvp4-content-data-contract.md` | approved spatial data-authoring detail; T01 implemented, still useful for T05/T07 validation intent |

If an old document says `three segments`, `third Fate -> COMPLETE`, `20m = full Run`, DEC-026 is pending, T01/T02/T03/T04 are not implemented, or BackpackState/Resolver/RestBackpackSession do not exist, current Decision/Canon/Active Context and actual main win.

## 5. Historical execution/handoff documents

- PR #17 provider adoption: **closed / unmerged / historical**.
- PR #18/#19: merged CI-fidelity/handoff history.
- PR #21~#26: merged planning/reconciliation history.
- PR #27: merged T01 implementation evidence.
- PR #28: post-T01 current-router synchronization.
- PR #29: merged T02 implementation evidence.
- PR #30: post-T02 current-router synchronization.
- PR #31: merged T03 implementation evidence.
- PR #32: post-T03 current-router synchronization.
- PR #33: merged T04 implementation evidence.
- old `impl/mvp4-t01-spatial-data-contracts`: historical prepared baseline, not current production branch.

Do not reopen historical PRs or rewrite old handoffs simply to make their timestamps/status prose appear current.

## 6. Current Plan/Build gate

```text
DEC-014~025 APPROVED
-> DEC-026 APPROVED
-> fresh Phase-B PASS
-> T01 Spatial Data Contracts INTEGRATED
-> T02 BackpackState INTEGRATED
-> T03 BackpackResolver INTEGRATED
-> T04 RestBackpackSession INTEGRATED
-> T05 CombinationResolver NEXT
-> T06~T14 approved execution chain
-> T15 Human QA gate
```

Do not create another competing pre-T05 plan. T05 uses the already-approved spatial spec, T01 combination data, T02 committed state, T03 deterministic resolver, T04 edit session and fresh Phase-B boundary.

## 7. Notion role

Notion is the human-facing overall product/visual/flow/work-control surface for this project.

Current important pages:

- Project Home — `닌자 서바이벌 · Home`
- `01 · 프로젝트 전체 작업계획`
- `02 · 비주얼 바이블`
- `03 · UI · 생존 Flow Map`
- `04 · 에셋 라이브러리`
- `05 · Reference · Benchmark 도서관`
- `06 · Production · Handoff`
- `08 · 핵심 시스템 · 상세`
- `09 · 세계관 · 핵심 스토리`

When GitHub implementation/evidence changes, update Notion status/handoff from the actual merged SHA and read back both sides before reporting `SYNCED`.

## 8. Current evidence ceiling

- MVP-0~3 runtime integrated/regression baseline.
- T01 spatial data contracts/catalog integrated with automated Godot/GUT evidence.
- T02 committed BackpackState integrated with automated Godot/GUT evidence.
- T03 deterministic BackpackResolver integrated with automated Godot/GUT evidence.
- T04 REST edit-session domain engine integrated with automated Godot/GUT evidence.
- T05 combination transaction NOT_STARTED.
- actual Workbench player interaction / committed spatial combat integration NOT_STARTED.
- school-circuit/trace/final-calamity runtime NOT_STARTED.
- release-near Human QA NOT_RUN.
- Android/export NOT_RUN/NOT_READY.

## 9. Next execution artifact

The next production artifact is **T05 CombinationResolver** from fresh merged `main`, RED first. T05 consumes T01/T02/T03/T04 facts and owns eligible orthogonal source pairs, progressive hint stages and an atomic pending-result transaction. It must preserve both sources until legal result placement succeeds and must not pull T06 combat authority or economy/UI responsibilities forward.
