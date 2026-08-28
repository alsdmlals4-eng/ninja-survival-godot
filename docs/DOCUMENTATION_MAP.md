# DOCUMENTATION_MAP

## 목적

현재 작업자가 **어떤 정보를 어디서 읽고 수정해야 하는지** 빠르게 판단하고, 역사 문서·AI 작업 로그·사람용 기획면·실제 구현 증거가 서로 정본을 침범하지 않도록 라우팅한다.

이 문서는 제품 규칙 자체의 정본이 아니라 **정본 위치와 읽기 순서를 설명하는 navigation contract**다.

## 1. Mandatory current read path

새 작업은 과거 handoff 문장만으로 현재 상태를 복원하지 않는다.

1. `../AGENTS.md`
2. 현재 사용자 지시 / active task contract
3. `CURRENT_CONFIRMED_DECISIONS.md`
4. `canon/2026-08-21-dec014-025-product-canon.md`
5. `canon/2026-08-22-dec026-encounter-pattern-budget.md`
6. `design/NINJA_SURVIVAL_MASTER_GDD.md` (사람이 읽는 통합 GDD와 AI 구현계약의 공통 진입면) → `../exports/NINJA_SURVIVAL_MASTER_PRODUCTION_GDD_20260828.pdf` (다운로드용 파생본)
7. `ACTIVE_CONTEXT.md`
8. `traceability/2026-08-22-dec026-post-gate-traceability.md`
9. `planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
10. `superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md`
11. 실제 `../scripts/**`, `../scenes/**`, `../data/**`, `../tests/**`, `../.github/workflows/**`
12. `design/NINJA_SURVIVAL_MASTER_GDD.md`, `CURRENT_VISUAL_HANDOFF.md`, asset manifest/provenance
13. 현재 작업에 Base freshness가 materially 필요할 때 최신 Base owner

## 2. Current product / implementation router

마지막 제품 구현 baseline은 **T16 전투 중 현재 유파 도움말까지 merged machine scope**다. PR #77 직전 GitHub `main` (`f77a1c…`)은 그 뒤의 문서 증거 정정이었다. 문서가 병합되면 SHA가 다시 바뀌므로 작업 전 GitHub `main`을 fresh-read하며, 두 SHA 축을 같은 의미로 취급하지 않는다.

```text
MVP-0~3 baseline · INTEGRATED
-> T01~T05 spatial / backpack / REST / combination · INTEGRATED
-> T06 committed RunBuildState modifier authority · INTEGRATED
-> T07 Boss/Shop/Chest spatial acquisition foundation · INTEGRATED
-> T08 RunRouteState / four-school route domain · INTEGRATED
-> T09 encounter definitions + Stage profiles · INTEGRATED
-> T10 Elite -> Trace -> Boss lifecycle gate · INTEGRATED
-> T11 tradition access packages + reward lanes · INTEGRATED
-> T12 Atomic Workbench + Fate + next-route commit · INTEGRATED
-> T13 Persistent Workbench route-preview UI/input · INTEGRATED
-> T14 Cheonsul lifecycle / Boss-clear Workbench machine slice · INTEGRATED
-> T15 starting-school Korean function-help machine slice · INTEGRATED
-> T16 combat HUD current-school help reopen machine slice · INTEGRATED
-> User vertical-slice validation · DEFERRED / NOT_RUN
-> remaining schools / full circuit / final calamity / full-run verification · SEPARATE FUTURE SCOPE
```

Important:

- latest product implementation merge is `63fcf81…` (T16 help); `f77a1c…` is the documented pre-PR #77 GitHub-main readback, not a durable current-main claim.
- closed PR #43 (T12 WIP) and #44 (old front-door docs) are **closed / unmerged / historical read-only**.
- PR #49 and closed #43/#44 remain historical read-only; they are not resume baselines.
- Human Usability / Player Experience / device / Android evidence are not implied by T01~T16 automated evidence.

## 3. Authority map — Repository GDD / Detail Canon / AI Workspace / GitHub

### A. Repository Master GDD — 사람용 Living GDD + Visual Dashboard

`design/NINJA_SURVIVAL_MASTER_GDD.md`는 링크 허브나 raw 개발 dashboard가 아니다. 사람이 바로 열람·다운로드할 때는 이 정본을 기준으로 발행한 `../exports/NINJA_SURVIVAL_MASTER_PRODUCTION_GDD_20260828.pdf`를 사용한다. PDF는 독립 정본이 아니며 발행/검수 상태는 `PDF_EXPORT.md`와 publication manifest가 소유한다.

**최상위 Acceptance Criterion:**

> Master GDD만 보면 무엇을 만들 게임인지와 어떻게 만들 것인지 판단할 수 있고, AI/System Workspace를 보면 그것을 실제로 구현·검증하는 데 필요한 세부 데이터가 부족하지 않아야 한다.

Master GDD는 다음 순서가 읽혀야 한다.

```text
PROJECT NORTH STAR
-> HOW THE GAME WORKS
-> HOW IT SHOULD LOOK
-> CORE GAME DATA
-> CONTENT & DESIGN
-> DEVELOPMENT REALITY
-> DETAIL LIBRARY & AI WORKSPACE
```

최상단 시각자료는 장식용 Concept Art보다 **게임 구조·시스템·화면·플레이 방법을 설명하는 Visual GDD**를 우선한다.

Master GDD에서 직접 보여야 하는 정보:

- 한 줄 제품 약속 / 플레이어 판타지
- Core Gameplay Loop와 전체 Run Flow
- 4유파의 위험 처리 철학
- 5분 전장 cadence
- 6x6 / 4x3 / 회전 / 직교 인접 / 조합 / Workbench / Fate 핵심 규칙
- 사람이 판단해야 하는 주요 수치·경제·콘텐츠 상한
- 현재 승인 Visual 방향과 승인 Asset linked view
- 사람이 알아야 할 수준의 구현 현실 / 다음 Gate / Human evidence ceiling

Master GDD 금지:

- raw SHA / PR 번호 / CI receipt / 포트 / local tool routing을 주 reading flow에 노출
- `소개 몇 줄 + 상세 링크 목록`으로 축소
- 핵심 데이터를 상세 페이지에만 숨김
- 승인되지 않은 예시 이미지를 정본 Asset으로 승격
- 별도 복사 데이터를 유지해 정본 drift 생성

### B. Repository detail canon / manifests — 사람용 상세 정본

Master GDD에 보이는 정보를 더 자세히 authoring하는 repository owner다.

Notion Detail Pages / Master Databases are preserved first through the
read-only migration archive at `migration/notion/`. The archive is not a
second canon owner; after its final remote-readback completion it is
`HISTORICAL_REFERENCE_ONLY`. Repository canon, visual docs, asset
manifest/provenance, planning and evidence docs own the active role.

주요 surface:

- `01 · Direction · Planning`
- `02 · Combat · Schools · Backpack`
  - `08 · 핵심 시스템 · 상세`
- `03 · World · Story · Content`
  - `09 · 세계관 · 핵심 스토리`
- `04 · Visual · UX · Assets`
  - `02 · 비주얼 바이블`
  - `03 · UI · 생존 Flow Map`
  - `04 · 에셋 라이브러리`
- `05 · Production · Validation`
- `06 · Reference · Benchmark`

사람용 요약은 Master GDD에서 repository canon/manifest를 링크하며, 중복 data
view를 유지하지 않는다.

### C. AI/System Workspace — AI 구현·검증 작업면

사람이 게임을 이해하기 위해 볼 필요가 없는 다음 정보는 Project Registry/System, Production Handoff, repository planning/evidence에 충분히 보존한다.

- schema / field ID / internal ID
- source mapping / source path / source SHA
- assumption / provenance / unresolved conflict
- implementation status / task log / handoff
- PR / issue / test / CI / validation evidence
- tool/runtime/session binding

단, 사람에게 필요한 유파·시스템·경제·아이템·콘텐츠·Visual 데이터까지 AI/System으로 숨기지 않는다.

### D. GitHub — implementation reality

GitHub repository는 다음의 구현 사실 정본이다.

- Markdown structured canon
- JSON / data
- GDScript code
- Scene / Resource
- tests / workflow
- 실제 merged implementation evidence

기존 Notion 문구는 historical receipt일 뿐이다. 구현 사실은
code/data/test/runtime evidence로 재확인하고, 앞으로 만들 제품 행동은 최신
approved Decision/Canon을 따른다.

## 4. Current product canon owners

| Document | Role | Current state |
|---|---|---|
| `CURRENT_CONFIRMED_DECISIONS.md` | mutable approved-decision / protected-scope ledger | CURRENT · T12~T16 machine scope integrated / human gate deferred |
| `ACTIVE_CONTEXT.md` | mutable resume-state router | CURRENT · T16 help merged / human gate deferred |
| `design/NINJA_SURVIVAL_MASTER_GDD.md` | 사람용 GDD + AI 구현계약 공통 정본 진입면 | CURRENT · current canon/implementation/evidence ceiling을 구분 |
| `../exports/NINJA_SURVIVAL_MASTER_PRODUCTION_GDD_20260828.pdf` | 사람이 내려받아 읽는 Master GDD snapshot | ALWAYS_SYNC · Markdown source/generator 변경 시 재발행; Human visual review는 별도 |
| `PDF_EXPORT.md` + `publication/NINJA_SURVIVAL_MASTER_GDD_PDF_MANIFEST.json` | PDF 발행/신선도/검수 상태 | CURRENT publication contract |
| `canon/2026-08-28-dec034-generate-then-approve-visual-workflow.md` | concrete consumer/board 후 1개 후보 생성과 사용자 LOCK 기준 | CURRENT · chat-start/gap-only 생성 금지 |
| `canon/2026-08-28-dec035-repository-only-project-record.md` | preservation-first Notion migration / repository-only cutover | CURRENT · final remote readback complete |
| `migration/notion/MIGRATION_MANIFEST.md` | former Notion structure, work-product and asset continuity audit | CURRENT MIGRATION ARCHIVE · not active canon |
| `visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md` | canonical screen-first visual coverage and Codex handoff | CURRENT · consumer/board first, user LOCK 전 candidate only |
| `canon/2026-08-21-dec014-025-product-canon.md` | four-school / route / trace / Workbench / final-binding product canon | CURRENT |
| `canon/2026-08-22-dec026-encounter-pattern-budget.md` | encounter / gimmick / pattern budget canon | CURRENT · APPROVED |
| `traceability/2026-08-22-dec026-post-gate-traceability.md` | reuse / supersession / migration coverage | CURRENT DESIGN CONTEXT |
| `planning/2026-08-22-dec026-phase-b-definition-of-ready.md` | approved domain-sequence readiness record | HISTORICAL GATE CONTEXT; re-check before new package |
| `superpowers/plans/2026-08-22-dec026-t08-plus-migration-plan.md` | post-DEC-026 package sequence | CURRENT MIGRATION CONTEXT |
| `../MVP_ROADMAP.md` | staged validation roadmap | CURRENT |
| `../README.md` | repository human/agent entry summary | CURRENT |

## 5. Historical-but-useful material

Historical documents remain useful as evidence or detailed rationale but cannot override current Decision/Canon/Active Context or actual merged main.

Examples:

- `superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` — protected 6x6/4x3/rotation/adjacency/Workbench rationale.
- `planning/2026-08-11-mvp4-content-data-contract.md` — spatial authoring rationale.
- old `superpowers/plans/2026-08-11-mvp4-backpack-combination.md` — lower-level historical implementation detail; old T08+ sequence is superseded.
- PR #17 — closed/unmerged provider-adoption history.
- PR #27~#42 — merged T01~T11 implementation evidence.
- PR #43 — closed/unmerged T12 WIP, read-only comparison material.
- PR #44 — closed/unmerged old front-door WIP.
- PR #45/#46 — Planning Canon + Human Home alignment and execution-receipt correction; docs/Notion work, not new gameplay implementation.

Do not rewrite historical artifacts merely to make their old status sentences look current.

## 6. Current evidence ceiling

Verified implementation scope:

- MVP-0~3 integrated baseline.
- T01~T16 domain/UI/help machine evidence integrated on the last product implementation baseline.

Not yet proven by that evidence:

- intended new four-school Run end-to-end playability
- human-validated Persistent Workbench UI/input
- release-near Cheonsul Slice Human Usability / Player Experience
- device / Android export readiness
- final full-run experience

`NOT_RUN` is not PASS.

## 7. Next product gate

**User vertical-slice validation** remains deferred / `NOT_RUN`.

The current machine evidence does not prove live-render semantics, Human Usability, Player Experience, touch/gamepad completion, device/export, or the full four-school Run. Do not begin remaining-school production until a separate scope decision reopens that product gate.
