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

### Current mutable state

6. `ACTIVE_CONTEXT.md`

### Current migration coverage

7. `traceability/2026-08-21-dec014-025-migration-traceability.md`

### Protected old spatial detail

8. `superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
9. `superpowers/plans/2026-08-11-mvp4-backpack-combination.md` — **T01-T07 detail only for current execution planning**
10. `planning/2026-08-11-mvp4-phase-b-definition-of-ready.md` — historical technical detail / prior DoR; fresh Phase-B is required after DEC-026

### Actual implementation evidence

11. `../scripts/**`
12. `../scenes/**`
13. `../tests/**`
14. `../.github/workflows/gut.yml`

## 2. Current product / migration documents

| Document | Role | Current state |
|---|---|---|
| `CURRENT_CONFIRMED_DECISIONS.md` | mutable approved-decision/protected-scope router | CURRENT |
| `canon/2026-08-21-dec014-025-product-canon.md` | implementation-facing mirror of approved Notion DEC-014~025 | CURRENT |
| `ACTIVE_CONTEXT.md` | resume/current-state router | CURRENT |
| `traceability/2026-08-21-dec014-025-migration-traceability.md` | current reuse/supersession/migration coverage | CURRENT / GAP |
| `superpowers/plans/2026-08-21-dec014-025-canon-rebaseline.md` | this documentation/authority rebaseline execution package | CURRENT PACKAGE |
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
| `planning/2026-08-11-mvp4-phase-b-definition-of-ready.md` | prior technical DoR and data-contract reasoning; not current Phase-B PASS for DEC-014~025 |
| `planning/2026-08-11-mvp4-content-data-contract.md` | old spatial data-authoring detail where not superseded |

If an old document says `three segments`, `third Fate -> COMPLETE`, `20m = full Run`, or PR #17/T01 is the next execution prerequisite, current DEC-014~025 canon/Active Context wins.

## 4. Historical execution/handoff documents

Dated handoffs and PR-era status docs are evidence, not mutable current-state authority.

Important classification:

- PR #17 provider adoption: **closed / unmerged / historical**.
- PR #18/#19: merged CI-fidelity/handoff history; the CI protection they introduced remains useful.
- old `impl/mvp4-t01-spatial-data-contracts`: historical prepared baseline, not current production branch.

Do not reopen historical PRs or rewrite old handoffs simply to make their timestamps look current.

## 5. Current Plan/Build gate

```text
DEC-014~025 canon rebaseline
-> DEC-026 concrete encounter/pattern decision
-> recalculate detailed T08+ implementation plan
-> fresh Phase-B Definition of Ready on latest main
-> Phase-C fresh production branch/packages
```

T01-T07 spatial-domain direction may be reused in that fresh plan; no gameplay implementation completion is claimed by the current documentation package.

## 6. Notion role

Notion is the human-facing overall product/visual/flow/work-control surface for this project.

Current important pages:

- Project Home — `닌자 서바이벌 (닌자의 신)`
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

Documentation can prove current product intent and implementation boundaries only.

Actual current evidence remains:

- MVP-0~3 runtime integrated/regression baseline,
- MVP-4 spatial runtime NOT_STARTED,
- new school-circuit/trace/final-calamity runtime NOT_STARTED,
- release-near human QA NOT_RUN,
- Android/export NOT_RUN/NOT_READY.

## 8. Next document to create

Do **not** create a detailed executable new T08+ gameplay plan yet.

Next material product artifact is DEC-026 in the planning/Notion product flow. After DEC-026 approval, create the fresh detailed implementation plan and Phase-B record from latest merged main.
