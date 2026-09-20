# DOCUMENTATION_MAP

## Current continuation — 2026-09-20

PR147 implementation is resumed under the approved September14/20 continuation.
Read [Active Context](ACTIVE_CONTEXT.md) for the current bounded R01 scope and
[Implementation Packet](design/NINJA_SURVIVAL_IMPLEMENTATION_PACKET.md) section J
for R01→R02→R03 dependencies. Dated planning pauses below are historical, not a
current implementation stop. Candidate art still requires its separate approval gate.

## Latest equipment revision — publication pending

Current rules: Detailed Rules R-EQUIPMENT/R-LOADOUT/R-TRACE and Implementation Packet.
Three gear slots, zero gear bag cells, two initial books use four cells. Screen
Blueprint now describes gear/bag separation. Research page retains superseded
8/9-cell history only. Existing 73-page PDF/manifest are preserved prior publication;
live source comparison is STALE until the complete revised book is exported/reviewed.

## 목적

### Latest follow-up — 2026-09-11 tag/draft/trace revision

`research/2026-09-11-tags-draft-and-trace-review.md` owns proposed changes requested
after the 73-page publication. The PDF below is the prior review snapshot and
does not yet include those proposals. Rules/packet/PDF need reconciliation after
product review; implementation readiness is reopened. Player appearance attempt:
`visual/candidates/player-refinement-20260911/README.md` (technical rework required).

### 2026-09-11 human Blueprint preparation overlay

Latest reader-facing source: `design/NINJA_SURVIVAL_HUMAN_BLUEPRINT.md`.
Downloadable derived view: `../exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_20260911.pdf`.
Publication source/hash binding: `publication/NINJA_SURVIVAL_HUMAN_BLUEPRINT_20260911_MANIFEST.json`.
Current inspection/delivery: `reviews/2026-09-11-human-blueprint-review.md`.
It includes the detailed-rule owner and `design/NINJA_SURVIVAL_IMPLEMENTATION_PACKET.md`
as derived publication sections, not new competing rules. Images in
`visual/candidates/blueprint-20260911/` are candidates, not approved runtime assets.
The latest user permits needed image production; the pause in the historical
2026-09-10 entry below no longer applies. Historical exported PDFs remain preserved.

### Historical 2026-09-10 cycle routing (planning pause superseded)

NS-DESIGN-RULES: `design/NINJA_SURVIVAL_DETAILED_RULES.md` is the single new-cycle
detailed-rule owner, authored under delegated planning judgement. Publication:
repository-native review source now; milestone PDF after design/visual review,
not an automatic replacement of the historical integrated Human Blueprint.
Its rules are DELEGATED_DESIGN, tuning values are initial tests, and implementation
readiness is separate. Current review evidence:
`reviews/2026-09-10-detailed-rules-review.md`. That task was planning-only;
its image/implementation pause was superseded by the later approved continuation.

Bounded input implementation/evidence: `reviews/2026-09-10-manual-ultimate-review.md`.
Execution checklist: `superpowers/plans/2026-09-10-manual-ultimate-input.md`.

Read the dated replanning entries in Decisions, Active Context and Visual Handoff
first. The A+B automatic-attack/manual-movement-dash-ultimate boundary is approved.
The dated first section of `visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md` now owns its
representative screen flow, motion contracts and implementation handoff. Its one
new image is candidate-only, not an approved replacement or actual runtime capture.
The prior Human GDD and PDF remain unchanged historical reader artifacts for this
replanning cycle. They do not yet include the new A+B supplement. Historical
current-main/T16 labels below are not the latest implementation frontier.

현재 작업자가 **어떤 정보를 어디서 읽고 수정해야 하는지** 빠르게 판단하고, 역사 문서·AI 작업 로그·사람용 기획면·실제 구현 증거가 서로 정본을 침범하지 않도록 라우팅한다.

이 문서는 제품 규칙 자체의 정본이 아니라 **정본 위치와 읽기 순서를 설명하는 navigation contract**다.

## 1. Current-authority read path

[AGENTS](../AGENTS.md) → [현재 결정](CURRENT_CONFIRMED_DECISIONS.md)·[재개 상태](ACTIVE_CONTEXT.md)
→ 최신 원격 main·관련 PR·실제 변경 대상/사용처·테스트
→ [프로젝트 작업 계약](operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md)
→ [채택한 Base와 drift](BASE_RULES_VERSION.md) → 이번 작업의 최소 분야 owner/스킬.

같은 작업 안에서는 바뀐 owner와 직접 의존성만 다시 확인한다. 아래 표는 조건부
목적지이며 매번 모든 행을 읽는 체크리스트가 아니다. 과거 대화나 낡은 현재 상태
요약으로 main·진행 중 PR·승인 상태를 대신하지 않는다.

| 이번에 필요한 정보 | 다음 책임 원본 |
|---|---|
| 기획·규칙·보호 범위 | 현재 결정이 가리키는 dated canon. 공간/조작은 [DEC-037](canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md), 기존 제품/전투는 DEC-014~026 및 이후 승인 결정으로 차이를 확인 |
| 구현/계속 작업 | Active Context의 승인 계획과 실제 코드·씬·데이터·테스트. 이전 Phase 기록을 현재 실행 권한으로 사용하지 않음 |
| 운영·조사·승인·검토·정상 병합 | 프로젝트 작업 계약 §2~10; Base 경로는 공용 원격 소속이며 프로젝트 내부 누락 파일로 오해하지 않음 |
| 재미 검증·효과·비주얼·UI 명세 | [작업 계약 §11](operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md#11-닌자의-신-재미-검증과-표현-명세-연결) → 해당 기능의 승인 경험 원본·실제 consumer·검증 기록. 자동 검사를 사람의 재미 증거로 쓰지 않음 |
| 이미지·스타일·승격 | [시각 정본](CURRENT_VISUAL_HANDOFF.md) → 관련 manifest/실제 슬롯 → DEC-034와 최신 사용자 이미지 지침 |
| 사람이 게임 전체를 읽는 자료 | [Human GDD](design/NINJA_SURVIVAL_HUMAN_GDD.md), [통합 블루프린트](../exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf); 보존 snapshot과 최신 구현을 구분 |
| 기술 상세·publication 검사 | [Master GDD](design/NINJA_SURVIVAL_MASTER_GDD.md), [PDF 발행](PDF_EXPORT.md)과 해당 manifest·exporter |
| 과거 이관 증거 | [이관 manifest](migration/notion/MIGRATION_MANIFEST.md). 이관 완료 Notion은 HISTORICAL_REFERENCE_ONLY이며 재조회하지 않음 |

## 2. 구현 상태와 이력의 경계

현재 구현은 매번 fresh main과 실제 consumer에서 확인한다. T12~T16·PR #129 등은
누적 이력이며 ‘마지막 구현’의 영구 포인터가 아니다. 2026-09-20 운영 감사 시 main에는
PR #139의 선택 통합, PR #141의 메달 조정, PR #143~146의 블루프린트 보강이 존재했다.
3×3 가방은 결정뿐 아니라 main catalog와 BackpackState 테스트에 연결돼 있다.

PR #147의 재기획/오의/저장 작업은 별도 미병합 구현이며 main 사실로 승격하지 않는다.
재개할 때 PR 상태·현재 HEAD·승인 원본을 다시 확인한다. 다른 open/draft/ready PR은
읽기 전용이며 이 지도는 그 PR을 병합하거나 변경할 권한을 주지 않는다.
Human Usability·Player Experience·기기·출시는 별도 실제 검증 없이는 NOT_RUN이다.

## 3. Authority map — Repository GDD / Detail Canon / AI Workspace / GitHub

### A. Reader GDD와 기술 Master GDD

`design/NINJA_SURVIVAL_HUMAN_GDD.md`는 사람이 바로 읽는 28쪽 게임 경험 블루프린트 원고다. 기본 열람·다운로드는 기존 28쪽을 보존한 `../exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf`를 사용한다. 이 통합본은 current-main screen wireframe·flow·user-locked visual companion을 더하지만 원고/기술 정본을 대체하지 않는다. `../exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf`는 historical snapshot으로 남긴다. 발행/검수 상태는 `PDF_EXPORT.md`와 각각의 publication manifest가 소유한다. `DEC-037`은 플레이어 공개 용어/가방 시작 규칙을, companion spec은 final PDF review 전 runtime 이행 경계를 소유한다.

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

## 4. Product owners and historical evidence

이 표는 위치 안내다. 현재 진행·승인·검증 상태를 별도로 복제하지 않는다.
현재 상태는 Decisions/Active Context와 최신 main에서 확인하고, 이번 작업의 승인·검토
예산은 [작업 계약](operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md)을 따른다.

| Document | Role | Current state |
|---|---|---|
| `CURRENT_CONFIRMED_DECISIONS.md` | mutable approved-decision / protected-scope ledger | 현재 승인 owner; 최신 절과 실제 main을 대조 |
| `ACTIVE_CONTEXT.md` | mutable resume-state router | 현재 재개 owner; 과거 snapshot은 이력 |
| `design/NINJA_SURVIVAL_HUMAN_GDD.md` | 사람용 게임 설명 원고 | CURRENT · 핵심 재미/흐름/선택/구현 구조를 쉬운 말로 설명 |
| `../exports/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_20260902.pdf` | 사람이 내려받아 읽는 기본 통합 Blueprint: 3쪽 읽기 지도 + 보존 28쪽 + 7쪽 wireframe/flow/locked visual companion | PR145 main 발행 기록; 신선도는 publication manifest/실제 파일로 확인, runtime/Human/device evidence는 별도 |
| `../exports/NINJA_SURVIVAL_HUMAN_GDD_20260830.pdf` | historical 28쪽 게임 경험 Blueprint snapshot | RETAINED · 기존 레이아웃/검수 snapshot을 보존하며 통합본의 pages 4–31에 다시 포함 |
| `design/NINJA_SURVIVAL_MASTER_GDD.md` | 기술 canon·구현 계약·증거 경계 | CURRENT · Human GDD와 중복 소유하지 않음 |
| `PDF_EXPORT.md` + `publication/NINJA_SURVIVAL_HUMAN_GDD_PDF_MANIFEST.json` + `publication/NINJA_SURVIVAL_HUMAN_BLUEPRINT_INTEGRATED_PDF_MANIFEST.json` | PDF 발행/신선도/검수 상태 | CURRENT contract; 통합본은 기존 snapshot·wireframe·flow·locked assets의 결합 상태도 기록 |
| `canon/2026-08-28-dec034-generate-then-approve-visual-workflow.md` | concrete consumer/board 후 1개 후보 생성과 사용자 LOCK 기준 | CURRENT · chat-start/gap-only 생성 금지 |
| `canon/2026-08-28-dec035-repository-only-project-record.md` | preservation-first Notion migration / repository-only cutover | CURRENT · final remote readback complete |
| `canon/2026-08-29-dec036-human-player-validation-deferred-from-current-build-gate.md` | current implementation gate에서 Human/Player 검수 deferment | CURRENT · NOT_RUN evidence를 PASS로 바꾸지 않음 |
| `implementation/2026-08-29-four-school-circuit-implementation-contract.md` | 네 유파 shared circuit의 구현 scope·owner·acceptance | HISTORICAL IMPLEMENTATION EVIDENCE · PR129 machine scope 병합; 새 작업 승인 대기 아님 |
| `planning/2026-08-29-phase2-four-school-definition-of-ready.md` | 당시 Phase 2 preproduction verdict | HISTORICAL GATE EVIDENCE · 당시 승인 대기 상태를 현행으로 재사용하지 않음 |
| `reviews/2026-08-29-four-school-contract-adversarial-review.md` | 당시 contract/DOR 적대적 검토 evidence | HISTORICAL REVIEW EVIDENCE · 당시 5회 기록은 현행 검토 요구가 아님 |
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
