# DOCUMENTATION_MAP

## 목적

현재 작업자가 **어떤 문서를 어떤 목적으로 읽어야 하는지**와 역사 문서를 현재 실행 정본으로 오해하지 않도록 라우팅한다.

## 1. Mandatory current read path

### Repository / execution rules

1. `../AGENTS.md`
2. active user/chat instruction
3. `BASE_RULES_VERSION.md` when Base freshness matters

### Current product decisions

4. `CURRENT_CONFIRMED_DECISIONS.md`
5. `canon/2026-08-21-dec014-025-product-canon.md`
6. `canon/2026-08-22-dec026-encounter-pattern-budget.md`

### Current mutable state

7. `ACTIVE_CONTEXT.md`

### Current migration / readiness / execution coverage

8. `traceability/2026-08-22-dec026-post-gate-traceability.md`
9. `planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
10. `superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`

### Protected old spatial detail

11. `superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
12. `planning/2026-08-11-mvp4-content-data-contract.md`
13. `superpowers/plans/2026-08-11-mvp4-backpack-combination.md` — **T01-T07 detail only for current execution**

### Actual implementation evidence

14. `../scripts/**`
15. `../scenes/**`
16. `../tests/**`
17. `../.github/workflows/gut.yml`

## 2. Current product / migration documents

| Document | Role | Current state |
|---|---|---|
| `CURRENT_CONFIRMED_DECISIONS.md` | mutable approved-decision/protected-scope router | CURRENT |
| `canon/2026-08-21-dec014-025-product-canon.md` | implementation-facing product canon | CURRENT |
| `canon/2026-08-22-dec026-encounter-pattern-budget.md` | encounter/pattern canon | CURRENT / APPROVED |
| `ACTIVE_CONTEXT.md` | resume/current-state router | CURRENT / T01 NEXT |
| `traceability/2026-08-22-dec026-post-gate-traceability.md` | current reuse/supersession/migration coverage | CURRENT |
| `planning/2026-08-22-dec026-phase-b-definition-of-ready.md` | fresh implementation readiness | CURRENT / PASS |
| `superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md` | current T08+ migration plan after DEC-026 | CURRENT |
| `SYSTEM_MAP.md` | responsibility and migration map | CURRENT |
| `../MVP_ROADMAP.md` | staged validation roadmap | CURRENT |
| `../README.md` | human/agent project entry summary | CURRENT |

## 3. Historical-but-still-useful MVP-4 documents

These are not deleted because they contain approved low-level spatial contracts and implementation reasoning.

| Document | Current use |
|---|---|
| `superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` | protected 6x6/4x3/rotation/adjacency/Workbench behavior |
| `traceability/2026-08-11-mvp4-backpack-combination-traceability.md` | historical AC/T01-T12 mapping; T08+ superseded for execution |
| `superpowers/plans/2026-08-11-mvp4-backpack-combination.md` | T01-T07 technical details reusable; T08-T12 historical |
| `planning/2026-08-11-mvp4-phase-b-definition-of-ready.md` | prior technical DoR/data-contract reasoning; not current Phase-B owner |
| `planning/2026-08-11-mvp4-content-data-contract.md` | approved spatial data-authoring detail where not superseded |

If an old document says `three segments`, `third Fate -> COMPLETE`, `20m = full Run`, DEC-026 is still pending, or PR #17/T01 historical branch is a prerequisite, current Decision/Canon/Active Context/post-DEC-026 owners win.

## 4. Historical execution/handoff documents

Dated handoffs and PR-era status docs are evidence, not mutable current-state authority.

Important classification:

- PR #17 provider adoption: **closed / unmerged / historical**.
- PR #18/#19: merged CI-fidelity/handoff history; the CI protection they introduced remains useful.
- PR #21~#25: merged planning/evidence history; their dated statements remain historical evidence while current routers own present state.
- old `impl/mvp4-t01-spatial-data-contracts`: historical prepared baseline, not current production branch.

Do not reopen historical PRs or rewrite old handoffs simply to make their timestamps look current.

## 5. Current Plan/Build gate

```text
DEC-014~025 canon rebaseline
-> DEC-026 APPROVED
-> T08+ migration plan RECALCULATED
-> fresh Phase-B Definition of Ready PASS
-> T01 Spatial Data Contracts from fresh merged main
-> T01~T14 TDD packages
-> T15 Human QA gate
```

T01-T07 spatial-domain direction is reused from the approved old spatial design/data contract. T08+ uses the current post-DEC-026 plan. No gameplay implementation completion is implied by planning readiness.

## 6. Notion role

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

When a Notion decision changes implementation meaning, mirror it into GitHub decision/canon/traceability before BUILD.

When GitHub implementation/evidence changes, update Notion status/handoff from the actual merged SHA and read back both sides before reporting `SYNCED`.

## 7. Current evidence ceiling

Documentation can prove current product intent, DEC-026 approval and Phase-B readiness only.

Actual current evidence remains:

- MVP-0~3 runtime integrated/regression baseline,
- MVP-4 spatial runtime NOT_STARTED,
- new school-circuit/trace/final-calamity runtime NOT_STARTED,
- DEC-026 encounter runtime NOT_STARTED,
- release-near human QA NOT_RUN,
- Android/export NOT_RUN/NOT_READY.

## 8. Next execution artifact

Do **not** create another competing pre-T01 plan.

The next production artifact is **T01 spatial data contracts/catalog implementation** from fresh merged `main`, using the approved 2026-08-11 spatial spec/data contract plus the fresh 2026-08-22 Phase-B owner. RED/GREEN execution evidence and post-merge readback determine when T01 is complete.
