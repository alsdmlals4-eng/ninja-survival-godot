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
6. `canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md` (조작 닌자·Stage/Phase·3×3 시작 가방의 최신 공개 경험 결정)
7. `design/NINJA_SURVIVAL_HUMAN_GDD.md` (28쪽 사람용 게임 경험 블루프린트 원고) → `../exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf` (다운로드용 파생본); `implementation/2026-08-30-player-control-stage-backpack-blueprint-spec.md`는 user final PDF review 전 runtime 이행 경계를 소유한다.
8. `design/NINJA_SURVIVAL_MASTER_GDD.md`는 기술 canon·구현 계약을 확인할 때 읽는다.
9. `implementation/2026-08-29-four-school-circuit-implementation-contract.md`
10. `planning/2026-08-29-phase2-four-school-definition-of-ready.md`
11. `canon/2026-08-29-dec036-human-player-validation-deferred-from-current-build-gate.md`
12. `ACTIVE_CONTEXT.md`
13. `traceability/2026-08-22-dec026-post-gate-traceability.md`
14. `planning/2026-08-22-dec026-phase-b-definition-of-ready.md` (historical)
15. 실제 `../scripts/**`, `../scenes/**`, `../data/**`, `../tests/**`, `../.github/workflows/**`
16. `design/NINJA_SURVIVAL_MASTER_GDD.md`, `CURRENT_VISUAL_HANDOFF.md`, asset manifest/provenance
17. L1+ proposal 또는 mutation 전, work ordering, reuse, approval, evidence, cleanup, and learning boundary는 `operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md`를 읽는다. 이 문서는 procedural adapter이며 제품/canon owner가 아니다.
18. 현재 작업에 Base freshness가 materially 필요할 때 최신 Base owner

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

### A. Reader GDD와 기술 Master GDD

`design/NINJA_SURVIVAL_HUMAN_GDD.md`는 사람이 바로 읽는 28쪽 게임 경험 블루프린트 원고다. 사람이 바로 열람·다운로드할 때는 이 원고를 기준으로 발행한 `../exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf`를 사용한다. PDF는 독립 정본이 아니며 발행/검수 상태는 `PDF_EXPORT.md`와 publication manifest가 소유한다. `DEC-037`은 플레이어 공개 용어/가방 시작 규칙을, companion spec은 final PDF review 전 runtime 이행 경계를 소유한다.

`design/NINJA_SURVIVAL_MASTER_GDD.md`는 제품 canon, 구현 계약, 증거 경계를 소유하는 기술 정본이다. Human GDD가 기술 정본의 내용을 이해하기 쉽게 풀어 쓸 수는 있지만, 수치·상태·권한이 충돌할 경우 기술 정본과 최신 승인 결정이 우선한다.

**최상위 Acceptance Criterion:**

> Human GDD만 보면 어떤 게임을 어떤 선택으로 플레이하는지 이해할 수 있고, 기술 Master GDD와 AI/System Workspace를 보면 그것을 실제로 구현·검증하는 데 필요한 세부 데이터가 부족하지 않아야 한다.

Human GDD는 다음 순서가 읽혀야 한다.

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

Human GDD에서 직접 보여야 하는 정보:

- 한 줄 제품 약속 / 플레이어 판타지
- Core Gameplay Loop와 전체 Run Flow
- 4유파의 위험 처리 철학
- 5분 전장 cadence
- 정확히 3×3 시작 / 가방 확장 / 6×6 기술적 외곽 상한 / 회전 / 직교 인접 / 조합 / Workbench / Fate 핵심 규칙
- 기존 4×3 시작은 구현 migration baseline인 역사 정보이며, 사람용 시작 규칙으로 다시 제시하지 않음
- 사람이 판단해야 하는 주요 수치·경제·콘텐츠 상한
- 사람이 알아야 할 수준의 구현 구조 / 현재 구현 현실 / 다음 Gate / Human evidence ceiling

Human GDD 금지:

- raw SHA / PR 번호 / CI receipt / 포트 / local tool routing을 주 reading flow에 노출
- `소개 몇 줄 + 상세 링크 목록`으로 축소
- 핵심 데이터를 상세 페이지에만 숨김
- 승인되지 않은 예시 이미지를 정본 Asset으로 승격
- 별도 복사 데이터를 유지해 정본 drift 생성

### B. Repository detail canon / manifests — 기술 상세 정본

Human GDD에 보이는 정보를 더 자세히 authoring하는 repository owner다.

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

사람용 원고는 Human GDD에만 유지하고, 기술 데이터/상태는 Master GDD와 repository canon/manifest가 소유한다.

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
| `design/NINJA_SURVIVAL_HUMAN_GDD.md` | 사람용 게임 설명 원고 | CURRENT · 핵심 재미/흐름/선택/구현 구조를 쉬운 말로 설명 |
| `../exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf` | 사람이 내려받아 읽는 28쪽 게임 경험 Blueprint snapshot | ALWAYS_SYNC · Human GDD/source generator 변경 시 재발행; user final review는 별도 |
| `design/NINJA_SURVIVAL_MASTER_GDD.md` | 기술 canon·구현 계약·증거 경계 | CURRENT · Human GDD와 중복 소유하지 않음 |
| `PDF_EXPORT.md` + `publication/NINJA_SURVIVAL_HUMAN_GDD_PDF_MANIFEST.json` | PDF 발행/신선도/검수 상태 | CURRENT publication contract |
| `canon/2026-08-28-dec034-generate-then-approve-visual-workflow.md` | concrete consumer/board 후 1개 후보 생성과 사용자 LOCK 기준 | CURRENT · chat-start/gap-only 생성 금지 |
| `canon/2026-08-28-dec035-repository-only-project-record.md` | preservation-first Notion migration / repository-only cutover | CURRENT · final remote readback complete |
| `canon/2026-08-29-dec036-human-player-validation-deferred-from-current-build-gate.md` | current implementation gate에서 Human/Player 검수 deferment | CURRENT · NOT_RUN evidence를 PASS로 바꾸지 않음 |
| `implementation/2026-08-29-four-school-circuit-implementation-contract.md` | 네 유파 shared circuit의 구현 scope·owner·acceptance | PROPOSED · user contract approval 대기 |
| `planning/2026-08-29-phase2-four-school-definition-of-ready.md` | current package의 Phase 2 preproduction verdict | READY_FOR_USER_IMPLEMENTATION_CONTRACT_APPROVAL |
| `reviews/2026-08-29-four-school-contract-adversarial-review.md` | contract/DOR 적대적 검토 evidence | CURRENT · 5 whole-state loops |
| `migration/notion/MIGRATION_MANIFEST.md` | former Notion structure, work-product and asset continuity audit | CURRENT MIGRATION ARCHIVE · not active canon |
| `visual/SCREEN_SURFACE_AND_VISUAL_COVERAGE.md` | canonical screen-first visual coverage and Codex handoff | CURRENT · consumer/board first, user LOCK 전 candidate only |
| `visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` | 28쪽 Human Blueprint/PDF를 보존한 current-main screen atlas: editable player-flow, wireframe, locked-reference visual atlas, HUD-priority, and consumer links | CURRENT_MAIN_RECONCILED · links owners; does not replace canon, manifests, runtime render, Human, or device evidence |
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
