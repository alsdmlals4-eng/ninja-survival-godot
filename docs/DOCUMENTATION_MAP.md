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
13. old `superpowers/plans/2026-08-11-mvp4-backpack-combination.md` — **T03-T07 reusable detail only**
14. actual `../scripts/**`, `../scenes/**`, `../tests/**`, `../.github/workflows/gut.yml`

## 2. Current product / migration / implementation documents

| Document | Role | Current state |
|---|---|---|
| `CURRENT_CONFIRMED_DECISIONS.md` | mutable approved-decision/protected-scope router | CURRENT / T02 MERGED / T03 NEXT |
| `canon/2026-08-21-dec014-025-product-canon.md` | implementation-facing product canon | CURRENT |
| `canon/2026-08-22-dec026-encounter-pattern-budget.md` | encounter/pattern canon | CURRENT / APPROVED |
| `ACTIVE_CONTEXT.md` | resume/current-state router | CURRENT / T02 MERGED / T03 NEXT |
| `traceability/2026-08-22-dec026-post-gate-traceability.md` | current reuse/supersession/migration coverage | CURRENT |
| `planning/2026-08-22-dec026-phase-b-definition-of-ready.md` | fresh implementation readiness | CURRENT / PASS |
| `superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md` | current T08+ migration plan after DEC-026 | CURRENT |
| `SYSTEM_MAP.md` | responsibility and migration map | CURRENT |
| `../MVP_ROADMAP.md` | staged validation roadmap | CURRENT |
| `../README.md` | human/agent project entry summary | CURRENT |

## 3. T01/T02 implementation evidence

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

T02 proves committed state primitives: 6x6 board, centered 4x3 start, stable item/bag identity, origin/rotation, atomic transitions, collision/active-area facts and defensive snapshot/copy isolation.

It does **not** prove T03 adjacency/connectivity/special-bag resolution, REST editing, Workbench interaction, combination flow, combat integration or player experience.

## 4. Historical-but-still-useful MVP-4 documents

| Document | Current use |
|---|---|
| `superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` | protected 6x6/4x3/rotation/adjacency/Workbench behavior |
| `traceability/2026-08-11-mvp4-backpack-combination-traceability.md` | historical AC/T01-T12 mapping; T08+ superseded for execution |
| `superpowers/plans/2026-08-11-mvp4-backpack-combination.md` | T01/T02 historical implementation direction; T03-T07 detail reusable; old T08-T12 historical |
| `planning/2026-08-11-mvp4-phase-b-definition-of-ready.md` | prior technical DoR/data-contract reasoning; not current Phase-B owner |
| `planning/2026-08-11-mvp4-content-data-contract.md` | approved spatial data-authoring detail; T01 implemented, still useful for T03/T07 validation intent |

If an old document says `three segments`, `third Fate -> COMPLETE`, `20m = full Run`, DEC-026 is pending, T01/T02 are not implemented, or BackpackState does not exist, current Decision/Canon/Active Context and actual main win.

## 5. Historical execution/handoff documents

- PR #17 provider adoption: **closed / unmerged / historical**.
- PR #18/#19: merged CI-fidelity/handoff history.
- PR #21~#26: merged planning/reconciliation history.
- PR #27: merged T01 implementation evidence.
- PR #28: post-T01 current-router synchronization.
- PR #29: merged T02 implementation evidence.
- old `impl/mvp4-t01-spatial-data-contracts`: historical prepared baseline, not current production branch.

Do not reopen historical PRs or rewrite old handoffs simply to make their timestamps/status prose appear current.

## 6. Current Plan/Build gate

```text
DEC-014~025 APPROVED
-> DEC-026 APPROVED
-> fresh Phase-B PASS
-> T01 Spatial Data Contracts INTEGRATED
-> T02 BackpackState INTEGRATED
-> T03 BackpackResolver NEXT
-> T04~T14 approved execution chain
-> T15 Human QA gate
```

Do not create another competing pre-T03 plan. T03 uses the already-approved spatial spec, T01 catalog, T02 committed state and fresh Phase-B boundary.

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
- BackpackResolver/REST session/Workbench player interaction NOT_STARTED.
- school-circuit/trace/final-calamity runtime NOT_STARTED.
- release-near Human QA NOT_RUN.
- Android/export NOT_RUN/NOT_READY.

## 9. Next execution artifact

The next production artifact is **T03 BackpackResolver** from fresh merged `main`, RED first. T03 consumes T02 facts and resolves connected usable layout, orthogonal adjacency, special-bag overlap and deterministic spatial modifiers without re-authoring item/bag identity or mutating committed state.
