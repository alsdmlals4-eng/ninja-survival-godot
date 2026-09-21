# Ninja Survival · Project Work Contract

```yaml
contract_role: PROJECT_NATIVE_BASE_ADAPTATION
status: ACTIVE_LEAN_ADAPTATION_USER_APPROVED_2026_09_20
base_observation:
  repository: alsdmlals4-eng/Base
  observed_main: 23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef
  disposition: ADAPT
full_base_adapter:
  canonical_path: skills/PROJECT_BASE_ADAPTER.json
  state: NOT_INSTALLED_SEPARATE_ONBOARDING_REQUIRED
  boundary_state: PROJECT_BASE_ADAPTER_NOT_INSTALLED
current_autonomy_ceiling: APPROVED_CURRENT_TASK_THROUGH_NORMAL_PR_MERGE
```

## 1. Purpose and boundary

### Historical 2026-09-12 continuous implementation selective adoption

Fresh remote Base observation: `d830c0f6967678eed3c208ac6b24f9cd1b262ec3`.
Read `continuous-work-execution.md`, `running-adversarial-review-and-refinement`
and `FULL_ADVERSARIAL_REVIEW_LOOP_POLICY.md`. ADAPT continuous execution of
approved implementation through user-testable delivery; partial green tests do
not close the whole-game queue. The then-selected five-loop exception is superseded
by the user-approved 2026-09-20 two-review contract in section 7. Do not install a
full adapter. Blocked art/Human/device evidence does not prevent safe logic work.
Current-task PR147 may continue; other open PRs remain read-only. Exact-head
checks, review and branch protection still gate integration.

### 2026-09-12 user-managed deletion review

Do not directly delete obsolete project outputs. Verify consumers, ownership,
Git state and recoverability first, then move confirmed disposable local outputs
to `C:/Users/user/Documents/GitHub/Ninza/DELETE_REVIEW/ninja-survival-godot/<date>/`.
Provide a clickable folder/README link with original paths, counts, sizes and
reason. The user performs final deletion. Keep this payload outside Git.
Do not move live assets, dirty worktrees, approval/provenance evidence or uncertain
user files merely because they look old. Git worktree/branch cleanup requires
separate verification; do not move registered worktrees as ordinary directories.

### 2026-09-10 selective art/motion routing

Current Base observed at `2f93e872d9ed4fa18018ac759b01acd7d34e9b58`.
Read owners: `ART_DIRECTION_AND_ASSET_PLANNING_GUIDE.md` section 11,
`ANIMATION_AND_PRESENTATION_METHOD.md`, and
`ANIMATION_PRESENTATION_SKILL_MATRIX.md`. Their conditional Aseprite selection
and state/event/pivot contracts are ADAPT for the user-requested replanning.
This observation does not replace the original adoption record or install the
full adapter. The historical five-review exception was replaced by the approved
2026-09-20 contract in section 7; retain this section's art/motion boundaries only.

Transport comparison: available restricted Aseprite MCP is selected for allowed
candidate operations; official batch CLI is a conditional fallback only within
reviewed local permissions; manual editing is a fallback for unsupported art
operations. Do not build another bridge or infer a live-editor connection.
Sources read: https://www.aseprite.org/docs/cli/ and
https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html.

Read local tool contract at
`C:/Users/user/.local/share/aseprite-local/LOCAL_USAGE.md` before calls.
Current transport probe: `ninja-replan-20260910-probe/transport-probe.aseprite`,
16×16 RGB, one frame at 100ms; create and metadata calls succeeded. This proves
only those operations. New frames/art, export, Godot integration, performance
and Human evidence remain unverified. Existing `PlayerVisualController` is a
two-texture MOVE/HIT presentation; actual motion needs a newly specified state
family. `BasicWeaponController` owns automatic katana/shuriken timing; sprite
durations must not become a second damage or movement authority.

This document is the single project-local owner for **how** Ninja Survival
accepts and executes Base-derived work practices. It does not own a game rule,
balance value, scene state, asset approval, or implementation claim.

The project keeps its native owners.

| Fact | Existing owner |
|---|---|
| latest user direction and repository safety | `AGENTS.md` |
| approved product meaning and protected scope | `docs/CURRENT_CONFIRMED_DECISIONS.md` and dated `docs/canon/**` |
| mutable resume state and current gate | `docs/ACTIVE_CONTEXT.md` |
| human-readable game understanding | `docs/design/NINJA_SURVIVAL_HUMAN_GDD.md` and `docs/design/NINJA_SURVIVAL_MASTER_GDD.md` |
| visual direction, asset status, provenance, and consumer | `docs/CURRENT_VISUAL_HANDOFF.md`, `docs/visual/**`, and asset manifests |
| actual product behavior | `scripts/**`, `scenes/**`, `data/**`, `tests/**`, and executed evidence |
| historical Notion material | `docs/migration/notion/**` as `HISTORICAL_REFERENCE_ONLY` |

Base supplies reusable operating patterns. A newer Base observation never
silently overrides approved Ninja Survival canon, implementation evidence, or
the project authority order.

## 2. Mandatory entry sequence

Every non-trivial task uses this sequence before a proposal or mutation.

```text
latest user request
→ project AGENTS and current authority map
→ current completed main and relevant open/recent PR inventory
→ current decisions, dated canon, Active Context, and actual consumer
→ project-local existing solution
→ current Base owner when the concern is materially shared
→ targeted primary/official external evidence when the decision needs it
→ ADOPT / ADAPT / REJECT and feasibility judgement
→ approval boundary
→ isolated BUILD and exact evidence
```

[문서 지도](../DOCUMENTATION_MAP.md) owns the detailed project read path. This contract
adds the execution gate; it does not duplicate the product documentation.

최신 Base는 발견·비교 대상이지 자동 적용 권한이 아니다. 현재 채택 내용과
관찰 이력은 [Base 채택 기록](../BASE_RULES_VERSION.md)에 남긴다. 같은 작업에서는
변경된 owner와 직접 의존성만 다시 읽고, 새 범위·실패·정본 변경 때 조사 범위를 넓힌다.

Before new creation, classify only the current scope's relevant context,
configuration, entrypoint, document, and generated material as
`ACTIVE_OWNER`, `COMPATIBILITY`, `ARCHIVE`, `OBSOLETE_CANDIDATE`, or
`UNKNOWN_UNVERIFIED`.

## 3. Five-phase project mapping

| Base phase | Project-native owners and required inputs | Result and re-open rule |
|---|---|---|
| `PHASE_1_PLANNING_CO_DESIGN` | Current decision ledger, applicable dated canon, Human/Master GDD, visual handoff, and latest user direction | Player-facing meaning, protected strengths, explicit non-scope, and unresolved core decisions are identified. A core-meaning conflict returns here. |
| `PHASE_2_PREPRODUCTION_REVIEW` | Existing implementation, scene/data/save/input owners, planning or implementation contract, approved references, and targeted benchmarks | Reuse disposition, actual consumer coverage, feasibility, acceptance, rollback, and evidence ceiling are reviewed. A design/readability/flow conflict returns here. |
| `PHASE_3_INGAME_INPUT_PREPARATION` | Approved asset manifest/provenance, UI copy, data contract, VFX/audio/localization requirements, deterministic test inputs, and runtime QA scenarios | Only inputs with an actual consumer are ready for Godot implementation. A missing or unsuitable asset/data/input returns here. |
| `PHASE_4_GODOT_IMPLEMENTATION_AND_MACHINE_CLOSEOUT` | Exact project revision, `scripts/**`, `scenes/**`, `data/**`, `tests/**`, workflows, and a fresh isolated branch | Implement the approved scope, run focused/full applicable checks, complete exact-head PR/CI evidence, and perform post-merge main readback. A code/wiring/runtime/build defect returns here. |
| `PHASE_5_USER_VERTICAL_SLICE_VALIDATION` | One exact build/candidate, a representative player flow, and user-requested observation questions | Record actual Human Usability, Player Experience, device, or final-user evidence separately. No lower evidence class becomes a Phase 5 result. |

The entry fresh-read is an operating envelope, not a sixth product phase. A
bounded finding reopens the earliest affected phase only; it does not restart
unaffected product work.

## 4. Work-item contract and dependency language

Use an existing project plan, implementation contract, review record, issue, or
PR description. Do not create a separate task database. When the field is
relevant, the owner records:

```text
outcome / why_now / authority_owner / actual_consumer /
protected_scope / explicit_non_scope / reuse_disposition /
dependencies / acceptance_criteria / validation / evidence_ceiling /
rollback / project_only_lessons / base_promotion_candidates
```

| Term | Meaning |
|---|---|
| `BLOCKS` | The successor cannot start safely until this output is accepted. |
| `INFORMS` | The result affects a later decision, while bounded investigation may proceed. |
| `USES_OUTPUT` | A later item consumes this file, data, approved asset, API, or evidence. |
| `SHARES_RESOURCE` | Work may conflict because it touches the same file, schema, asset, editor, or external state. |

Plan order follows: authority/interface and highest-risk hypothesis → core
player path → consumer/data/asset integration → normal/boundary/regression
checks → repository readback. Parallel work is allowed only when ownership,
inputs, outputs, merge point, and independent verification are all explicit.

## 5. Reuse, benchmark, and feasibility gate

The first candidate is the current project implementation or approved project
reference. Then inspect a relevant current Base owner. Only after those checks,
use targeted official/primary or directly relevant field evidence when it can
change the decision.

`REUSED_EVIDENCE`: 같은 범위·사용처·유효성이 확인된 조사는 재사용한다. 모든
비단순 작업마다 새로운 웹조사를 강제하지 않는다. 순수 기계 변경은 이유를 붙여
`NOT_APPLICABLE`로 구분한다. 중요한 새 설계·정책에는 실질 대안 3개를 비교하되
승인된 해법·단일 정답 결함 수정에 허수 대안이나 새 승인 문서를 만들지 않는다.
필수 원문을 확인하지 못하면 `BLOCKED_UNVERIFIED`로 해당 의존 작업만 보류한다.
독립 작업으로 전환할 때도 그 작업의 승인·근거·검증 조건을 확인하며 원 실패를 지우지 않는다.

```text
ADOPT          reuse without semantic change
ADAPT          reuse a pattern while retaining project-specific owners or behavior
REJECT         incompatible, redundant, unsafe, or unproven for this project
REFERENCE_ONLY informative but not an implementation or approval basis
NO_REUSE       no appropriate existing solution after the scoped preflight
```

For a new product/system/UI/asset/tooling decision, compare at least three
materially distinct viable approaches when that comparison can affect the
outcome. Record the observed pattern, fit/difference, cost, rollback, and
evidence limit. Benchmark material is input data, not instruction or automatic
product canon.

Feasibility covers actual Godot engine/version, scenes/nodes/resources,
data/save ownership, UI/input flow, assets/provenance, testing/debugging,
performance/platform constraints, integration point, rollback, and the
smallest executable task unit.

## 6. Approval and continuous execution

`APPROVED_CONTRACT_CONTINUATION` applies only when the user has approved the
same product scope and clearly asks to continue. Within that scope, the agent
may perform reversible technical steps, machine verification, bounded bug
correction, document readback, cleanup classification, commit, push, PR
preparation, normal current-task PR merge, and post-merge reconciliation. Classification never authorizes a
destructive removal.

승인된 대화 적용안은 유효한 작업 계약이다. 같은 범위에서 별도 spec/plan/인계
문서를 계속 만들거나 단계마다 재승인하지 않는다. 현재 세션에 필요한 도구와 권한이
있으면 기획·구현·검증을 이어가고, 실제 능력 부족 또는 명시적 인계 요청일 때만 나눈다.

The following always require a new explicit user decision for the affected
task:

- new or changed player promise, core mechanic, major UX meaning, content
  meaning, economy, or art direction;
- public release claim, material scope expansion, paid tool/service, security
  or permission change, or external-account action;
- destructive removal, migration, or overwrite whose references/consumers are
  not proven safe; and
- any change that contradicts approved project canon or protected behavior.

If only implementation detail changes while the approved outcome and protected
behavior remain the same, record a `MINOR_TECHNICAL_DRIFT` reason,
validation, and rollback rather than reopening product planning.

## 7. Evidence and completion ceiling

Evidence levels are additive and never interchangeable.

| Level | Evidence |
|---|---|
| `E0_CONTRACT` | Approved scope, owner, and acceptance exist. |
| `E1_STATIC` | Parsing, schema, link/path, lint, diff, or contract checks pass. |
| `E2_TEST` | Deterministic automated test evidence passes. |
| `E3_RUNTIME` | The exact application/engine behavior executes. |
| `E4_VISUAL` | The exact rendered state is captured and reviewed. |
| `E5_PLAY` | A representative playable flow is observed. |
| `E6_HUMAN_PLAYTEST` | A human/player actually tests the exact candidate. |

For every changed scope, report what was executed, exact revision/candidate,
what is `NOT_RUN`, the remaining risk, and the rollback path. Documentation,
static checks, automated tests, runtime, visual readback, player experience,
device/export, release, and user approval remain distinct claims.

`REMAINING_WORK_RECALCULATION_REQUIRED`: 완료 전 승인 범위·실제 사용처·정본·검증을
다시 대조한다. 전체 적대적 검토는 **같은 승인 계약의 후보 계보에서 정확히 2회**다.
계획·구현·세션 재개·병합 전후마다 예산을 초기화하지 않는다. 1회차는 전체 후보를
공격하고 유효 finding을 교정·검증하며, 2회차는 교정된 전체 후보와 변경하지 않은
사용처까지 확인한다. 적어도 한 회차는 실제 변경된 결과를 검토한다.
2회 이후에는 결함별 수정·영향 회귀검사·정본 readback만 계속한다. 미해결 blocker나
필수 acceptance 미충족은 완료·병합을 막는다. 추가 전체 검토나 범위 확대가 정말
필요하면 사용자 결정으로 올리며, 이름을 바꾼 세 번째 전체 감사를 자동 실행하지 않는다.
이는 2026-09-20 사용자 승인으로 이전 프로젝트 5회 예외를 대체한 운영 변경이다.
과거 5회/6회 기록은 역사적 수행 증거로 보존한다. 횟수만으로 품질을 보증하지 않는다.

중간 변경은 영향 검사, 통합 경계는 관련 회귀검사, 병합 전은 repository 필수 검사를
실행한다. CI·저장 호환성·보안·필수 runtime acceptance는 검토 예산과 별개다.
문서 변경에 새 Godot 실행·이미지 제작·PDF 재발행을 강제하지 않는다.
최종 보고는 결과·이유·확인 방법·남은 위험을 중심으로 하고 상세 증거는 기존 기록/PR에 둔다.

## 8. Git, cleanup, and learning boundaries

Use current completed `main` as the new-work baseline. Open/draft/ready PRs
outside the explicitly approved workstream are read-only. Use an isolated
branch/worktree, exact-head checks, protected PR flow, merge, and new-main
readback. Do not direct-push `main`, force-push, bypass rules, or absorb an
unrelated PR.

이번 승인 작업에서 최신 main으로부터 만든 단일 current-task PR만 exact HEAD의
필수 checks·독립 검토·unresolved thread·ruleset을 확인한 뒤 정상 병합할 수 있다.
기존 draft/다른 작업 PR은 이 예외에 포함되지 않는다. 병합 후 fresh main의 tree와
변경 owner를 readback한다. 로컬 main이 다른 worktree에서 사용 중이면 이동시키지
않고 이번 격리 worktree와 원격 main을 비교한다.

Never remove a file only because its name, date, extension, or age looks old.
An `OBSOLETE_CANDIDATE` may become a removal only after:

```text
references and consumers = 0
→ affected documentation/generated views/validation route reread
→ recoverable user-deletion review handoff
→ user performs final deletion
```

Uncertain source, consumer, provenance, or generated state remains
`UNKNOWN_UNVERIFIED` and is preserved. Project-specific lessons remain in the
project. A Base promotion candidate needs repeated cross-project value,
current-owner collision review, explicit Base scope, and its own approved Base
change path; it is never promoted merely because one Ninja Survival task used
it successfully.

## 9. Full Base adapter boundary

`skills/PROJECT_BASE_ADAPTER.json` is not installed in this project. The Base
validator currently reports that absence. This is an intentional, recorded
boundary for the thin adaptation: it is neither product failure nor validation
success.

A future full onboarding is a separate governance package only if the project
needs Base-shared route execution strongly enough to justify its maintenance.
It must first establish and merge a project-local legacy policy source and
Skill Registry baseline, then perform a second, fresh-main adapter migration
and generated-view validation. It must not be folded into gameplay work or
used to replace these project-native owners.

## 10. 조건부 스킬 연결 — 별도 설치·복제 없음

프로젝트 전용 SKILL/Registry를 새로 만들지 않는다. 아래는 공용 지침을 참고하는
선택 경로이지 full Base adapter 실행/검증 성공 선언이 아니다. 앱의 시스템·개발자
필수 지침이 우선하며, 프로젝트 문구로 이를 무효화하거나 플러그인을 비활성화하지 않는다.
설치된 스킬은 실제 목록에서 이름·경로·가용성을 확인하고 적용 시 본문과 필수 참조를 읽는다.

| 현재 작업 | 최소 경로 | 적용하지 않을 것 |
|---|---|---|
| 새 변경의 의도·범위·승인 | 이 계약 §2/§6 → 필요 시 Base `skills/managing-project-intake-and-work-contract/SKILL.md`; 설치된 brainstorming의 해당 변경 규모 경로 | 이미 승인한 방향을 다시 인터뷰·문서 승인하기 |
| 승인 계획 실행 | 기존 계획/대화 승인안 → 설치된 executing-plans; 변경한 코드에는 TDD, 실패에는 systematic-debugging | 같은 승인에 별도 계획/작업 DB를 중복 생성하기 |
| 운영 규칙·참조 변경 | 이 계약 → Base `skills/managing-game-project-operating-system/SKILL.md`의 audit/reconcile/verify만 선택 | full adapter·Registry·대시보드 자동 설치 |
| 플레이 경험을 바꾸는 기능 | §11 → Base `skills/analyzing-and-refining-game-concepts/references/concept-evidence-and-gates.md`의 Fun verification lifecycle | 순수 문서 수정에 새 플레이테스트 요구하기 |
| 효과·비주얼·UI | §11 → Base `docs/knowledge/game-development/EXPERIENCE_TO_PRESENTATION_GUIDE.md`와 `skills/auditing-and-refining-ui-art/references/project-adapter-contract.md` §10–11 | 모든 상태·자산·효과 추가, 분석 서버·새 감독 스킬 |
| 실제 이미지/PDF 작업 | 프로젝트 시각/발행 정본 → 설치된 imagegen/pdf 스킬 | 문서 연결 교정만으로 이미지 생성·PDF 재발행하기 |
| Godot 저작·실행 | 실제 project.godot·채택 엔진/도구·GUT·현재 세션 확인 → 필요한 live-editor/QA 스킬 | 문서 작업에 엔진 업데이트·플러그인 설치 |
| 검토·완료 | §7 → 필요한 verification-before-completion/requesting-code-review; Base `docs/operations/FULL_ADVERSARIAL_REVIEW_LOOP_POLICY.md` | 같은 계약의 전체 검토 예산 초기화 |

Base 경로는 프로젝트 내부 경로가 아니다. [Base main](https://github.com/alsdmlals4-eng/Base/tree/main)에서
현재 원문을 발견하고 [채택 기록](../BASE_RULES_VERSION.md)과 비교한다. 현재 기획/구현/자산
결정이나 기존 pin을 바꾸는 drift는 자동 흡수하지 않는다. 로컬 Base 경로·과거 SHA를
실행 환경으로 고정하지 않는다. 필요한 원문 접근 실패 시 해당 의존 작업만 보류한다.

## 11. 닌자의 신 재미 검증과 표현 명세 연결

2026-09-20 사용자 추가 요청으로 Base #885 방법을 **프로젝트 네이티브 절차에 선택 채택**한다.
새 게임 규칙·재미 점수·새 감독 Skill을 만들지 않는다. 플레이어 경험에 영향을 주는
기능/시스템/UI/VFX 변경에 적용하며, 작은 변경은 기존 계획/검증 기록에 짧게 연결한다.
기계적 문서 변경은 사유 있는 `NOT_APPLICABLE`; 동일 조건의 유효한 근거는 `REUSED_EVIDENCE`다.

| 단계 | 기존 owner에 남길 최소 내용 |
|---|---|
| 기획 | Requirement/기존 기능 ID → 승인 경험 원본의 경로·절 → 경험 가설과 반증. 핵심/보조/중립/충돌/미검증을 구분하며 분류만으로 삭제하지 않음 |
| 설계 | 같은 ID → 입력·상태·규칙·선택·정보·피드백, 실패·취소·복귀, 가장 작은 대표 구간과 확인 질문 |
| 구현 | 실제 코드/Scene/데이터/승인 자산 consumer·이벤트와 연결. 아직 없는 연결은 `PLANNED`; 링크만으로 구현됐다고 하지 않음 |
| 검증 | 기준/후보 exact revision, 입력·seed·설정·해상도·대표 상황, 정상/혼잡/중단/반복 조건. 자동 검사·실행·행동 관찰·자기보고·필요 로그를 구분 |
| 교정 | 이해 실패 / 규칙·선택 실패 / 표현·감각 실패 / 반복 피로 / 빌드 결함을 구분 → 기존 Decision의 KEEP/CHANGE/DEFER/RETEST → 최소 수정·영향 검사 |

### 프로젝트 정본·실제 사용처·검증 위치

아래는 기존 기능에 적용할 **관찰 질문이며 통과 결과나 새 밸런스 기준이 아니다**.
main과 승인된 개발 브랜치는 구분한다. 예를 들어 PR #147의 수동 오의·신규 저장
구현을 main에 있다고 간주하지 않고, 재개 시 그 PR의 승인 원본과 실제 consumer를 다시 확인한다.

| 기능/경험 원본 | 실제 구현/표현 경로 | 확인과 반증의 예 |
|---|---|---|
| [DEC-037 이동·무적 대시](../canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md) | `scripts/player/player_controller.gd`, `tests/integration/test_player_dash_runtime.gd` | 기계: 승인 피해 판정/충전 경계. 실행: 위험 예고와 이동·대시 표시 일치. 사람: 피한 이유를 이해하는가; 표시만 보고 무적 범위를 오해하면 반증 |
| [DEC-039 군중·기본무기](../canon/2026-08-30-dec039-horde-basic-weapons-and-starting-ninjutsu.md), [DEC-040 전투 설계](../superpowers/specs/2026-08-31-dec040-four-school-encounter-and-ninjutsu-design.md) | `scripts/combat/basic_weapon_controller.gd`, `scripts/enemies/encounter_pattern_controller.gd`, `tests/integration/test_opening_horde_attack_rhythm.gd` | 군중을 해치우는 성취와 회피 판단을 질문. 효과가 위험 신호를 가리거나 시작부터 패턴 혼잡이 생기면 원인을 구분. 적 수/빈도를 여기서 새로 정하지 않음 |
| [DEC-037 가방·원자적 Workbench](../canon/2026-08-30-dec037-player-control-stage-3x3-backpack.md) | `scripts/backpack/backpack_state.gd`, `tests/unit/test_backpack_state.gd`; 나머지 거래/UI owner는 해당 작업에서 실제 호출 경로 확인 | 기계: preview 전투력·실패 시 불변·확정 경계. 실행/사람: 배치 선택의 결과를 이해하는가; 미리보기를 구매/확정으로 오해하거나 반복 정리만 피로하면 반증 |
| 화면/효과의 일관성 | [화면 블루프린트](../visual/NINJA_SURVIVAL_SCREEN_BLUEPRINT.md), [시각 정본](../CURRENT_VISUAL_HANDOFF.md), 승인 manifest 및 해당 화면 소비자 | 실제 표시 크기·배경·긴 한국어·지원 입력에서 정보 우선순위와 상태 구분 확인. 단독 이미지 품질은 게임 내 가독성 증거가 아님 |

각 구현 작업은 위 예시를 그대로 복사하지 말고 해당 Requirement에 **규칙 효과와 표현 효과**를
분리해 확정한다. 발동 조건·대상·계산식·지속/중첩·실패는 도메인/데이터가 소유한다.
UI/VFX/소리는 그 확정 결과를 읽고 피해·비용·보상·저장을 재계산하지 않는다.
필요 상태·정보 공개/보호·발생 시점·강도·동시 효과 우선순위·중단/복귀·지원 입력·
승인 자산 상태군·실제 사용처·확인 방법을 기존 기능 명세에 연결한다. 무관한 필드는 생략한다.

요구사항 → 구현/자산 → 검증과, 화면/검증 → 구현 → 승인 원본의 **양방향 연결**을
exact revision에서 확인한다. 경로 존재뿐 아니라 실제 호출/표시·의미가 맞아야 한다.
필수 미정값은 owner·영향·다음 행동을 남겨 해당 의존 작업만 보류한다.

`DOC / MACHINE / RUNTIME / HUMAN / USER_APPROVAL / RELEASE`는 별개다.
자동 테스트·AI 검토·로그·문서 링크 통과로 HUMAN 또는 `FUN_PASS`를 만들지 않는다.
오래 플레이함/높은 재도전율을 몰입·만족으로 단정하지 않으며 첫 노출과 반복 피로를 나눈다.
사람 검증이 없다는 이유로 승인된 구현 전체를 순환 차단하지 않지만 필요한 사람/출시
검증은 `NOT_RUN`으로 유지한다. 이해했지만 재미없다는 반례에 효과·보상 추가를 기본 처방하지 않는다.
핵심 경험·경제·주요 UX·아트·비용·보안·파괴적 교정은 새 결정이 필요하다.

적용 상태: 이 절은 절차/정본 연결이다. 위 기능의 이번 runtime·Human·재미 검증은 `NOT_RUN`.
전체 검토는 §7의 동일 계약 2회 예산을 공유하며 재미 검증 때문에 다시 시작하지 않는다.
