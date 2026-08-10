---
contract_name: PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION
contract_version: '4.5'
status: ACTIVE_BASE_CURRENT_MAIN_THIN_ADAPTER_GODOT_DELIVERY_CONTRACT
revision: '2026-08-11-r2'
execution_scope_guard: INSTRUCTION_DOCUMENT_UPDATE_ONLY_UNLESS_EXPLICIT_FUTURE_EXECUTION_REQUEST
planning_phase_policy: GPT_CHAT_PLANNING_COMPLETE_BEFORE_POWERSHELL_CODEX_GODOT_BUILD
planning_completion_trigger: USER_EXPLICIT_PLANNING_COMPLETE_DECLARATION
grill_me_approval_batch_max: 10
grill_me_batch_close_policy: SYNC_CANON_AND_SHEET_THEN_PLANNING_PR_REVIEW_ADVERSARIAL_LOOP
numeric_detail_policy: GPT_RECOMMENDED_WITH_BENCHMARK_AND_TUNING_RANGE
planning_conflict_policy: GRILL_ME_MANDATORY_USER_APPROVAL
current_conversation_merge_policy: RECOMMENDED_AUTO_APPROVAL_WITHIN_ALREADY_APPROVED_SCOPE
open_draft_pr_inventory_required: true
tdd_required_every_task: true
powershell_codex_default_command: "codex.cmd -a never -s workspace-write"
powershell_manual_approval_prompt_max: 2
powershell_session_policy: EPHEMERAL_CLOSE_AND_FRESH_START_EACH_EXECUTION_BLOCK
user_action_blocker_policy: GPT_SOLVES_WHEN_POSSIBLE_ELSE_REQUEST_EXACT_USER_ACTION_AT_END
bcp_project_source_policy: PROPOSAL_FIRST_NO_ACTIVE_BASE_RULE_MUTATION_UNTIL_SEPARATELY_APPROVED_IMPLEMENTATION
skill_absorption_policy: PARTIAL_ABSORPTION_ALLOWED_WITH_FUNCTION_LEVEL_CLASSIFICATION
language: ko-KR
base_repository: https://github.com/alsdmlals4-eng/Base
base_snapshot_observed_when_v4_5_written: 7ce3fb64fa6303c5da6c7fc27c979f7233b761ac
base_snapshot_policy: ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK
base_repository_review_policy: RECURSIVE_INVENTORY_THEN_RELEVANCE_DRIVEN_DEEP_READ
adapter_policy: THIN_ADAPTER_DO_NOT_DUPLICATE_BASE_CANON
usage: >
  최신 Base의 PLAN→BUILD→REVIEW, Registry 기반 최소 Skill 라우팅, Existing Solution First,
  승인 Decision 재사용, EXTERNAL_PROCESS_OVERLAY, BCP-020 플레이어 경험 증거 Gate,
  on-demand Codex, HiGodot/GUT/Hera 역할 분리, public REMOTE_CI, Windows/Android 공용 코어,
  Visual Requirement/Asset Vault, exact validation target PR Gate, merged-main readback,
  사용자 로컬 Fetch/Pull까지 하나의 증거 기반 생명주기로 수행한다.
core_gates:
  - CURRENT_BASE_MAIN_REFETCH_AND_AUTHORITY_RECOVERY
  - BASE_REPOSITORY_WIDE_INVENTORY_AND_RELEVANCE_DRIVEN_DEEP_READ
  - BASE_SKILL_REGISTRY_AND_WORK_MODE_ROUTING
  - THIN_ADAPTER_NO_BASE_CANON_DUPLICATION
  - EXTERNAL_PROCESS_OVERLAY_AUTHORITY_BOUNDARY
  - PROJECT_GITHUB_AND_GOOGLE_SHEET_WHOLE_STATE_RECOVERY
  - ENTRY_STATE_RECONCILIATION_BLOCKING_GATE
  - WHOLE_PROJECT_AUDIT_FIRST
  - PLANNING_FIRST
  - GPT_CHAT_PLANNING_COMPLETE_BEFORE_LOCAL_BUILD_GATE
  - GAME_DETAIL_PLANNING_STRUCTURE_IMPROVEMENT_FIRST_GATE
  - CORE_FUN_GOAL_AND_SYSTEM_ALIGNMENT_GATE
  - BENCHMARK_AND_INDUSTRY_COMPARISON_GATE
  - EXISTING_SOLUTION_FIRST
  - PREVIOUS_CONTRACT_AND_STRENGTH_PRESERVATION
  - CORE_REQUIREMENT_TRACEABILITY
  - GRILL_ME_CONFLICT_APPROVAL_GATE
  - TEN_DECISION_MAX_BATCH_AND_EARLY_CHECKPOINT_GATE
  - IMMEDIATE_CANON_AND_SHEET_DECISION_SYNC
  - PLAYER_EXPERIENCE_EVIDENCE_GATE
  - FIRST_SESSION_REPRESENTATIVE_EXPERIENCE_GATE
  - DECISION_SCREEN_COMPREHENSION_GATE
  - MINIGAME_NARRATIVE_FUNCTION_GATE_WHEN_APPLICABLE
  - VISUAL_REQUIREMENT_DELETE_TEST_GATE
  - PROJECT_LOCAL_ASSET_VAULT_PROMOTION_GATE
  - LOCAL_GODOT_REFERENCE_LIBRARY_GATE
  - SHARED_AUDIO_VAULT_FIRST_AND_PROVENANCE_GATE
  - ASSET_PROVENANCE_AND_GODOT_IMPORT_GATE
  - HIGODOT_SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY
  - GUT_FOR_GODOT_4_7_X_FORMAL_TEST_AUTHORITY_WHEN_ADOPTED
  - HERA_LIVE_QA_AND_ZERO_SOURCE_DELTA_GATE
  - TEST_FIRST_EVERY_TASK
  - WINDOWS_ANDROID_SHARED_CORE_GATE
  - BUILD_SIZE_AND_PERCEIVED_QUALITY_GATE
  - RUNNABLE_BY_USER_ONE_CLICK_PROJECT_PLAY_GATE
  - ZERO_BUDGET_PUBLIC_REMOTE_CI_GATE
  - ACTIONS_RISK_TIER_AND_SINGLE_CI_GATE
  - FULL_SHA_ACTION_SUPPLY_CHAIN_GATE
  - ON_DEMAND_CODEX_HANDOFF
  - ADVERSARIAL_MULTI_PASS_REVIEW
  - EVIDENCE_BEFORE_COMPLETION
  - EXACT_VALIDATION_TARGET_AND_STRICT_UP_TO_DATE_PR_GATE
  - APPROVED_ITEM_INHERITS_MERGE_AUTHORITY
  - OPEN_DRAFT_PR_FULL_INVENTORY_GATE
  - POWERSHELL_CODEX_MAX_TWO_USER_APPROVAL_GATE
  - POWERSHELL_FRESH_SESSION_RESTART_GATE
  - MERGED_MAIN_READBACK
  - PROJECT_SOURCE_BCP_PROPOSAL_GATE
  - PARTIAL_SKILL_ABSORPTION_GATE
  - FUNCTION_LEVEL_VALIDITY_CLASSIFICATION_GATE
  - USER_ACTION_REQUIRED_LAST_GATE
  - OPTIONAL_SKILL_CREATION_CONSOLIDATION_FIRST
  - BASE_CHANGE_PROPOSAL_PROMOTION_GATE
  - SAFE_LOCAL_FAST_FORWARD_ONLY_SYNC
  - GODOT_CLEAN_MAIN_RUNTIME_GATE
---

# 프로젝트 총기획·검수·구현·병합·로컬 실행 통합 작업지시문 v4.5

## 0. v4.5의 역할 — Base 복제본이 아니라 프로젝트 Thin Adapter

v4.5는 v4.4의 프로젝트 고유 요구·경로·안전 경계를 보존하면서, Base가 이미 소유하는 세부 절차를 이 파일에 다시 복사하지 않는다.

**핵심 원칙**

```text
이 파일이 Base current main의 운영 절차와 충돌
→ Base current authority가 우선

이 파일이 프로젝트 고유 값·경로·보호 요구·명시 승인과 관련
→ 이 파일과 프로젝트 정본이 우선

외부 process framework가 실행 절차를 추가
→ EXTERNAL_PROCESS_OVERLAY로만 합성
→ 프로젝트/Base 정본 권한은 획득하지 않음
```

v4.4에서 관찰했던 Base 구조·Skill 수·Action pin·릴리스 상태는 역사적 증거다.
v4.5는 그것을 현재 사실로 하드코딩하지 않는다.

현재 v4.5 작성 시점에 관찰한 Base `main`:

```yaml
base_main_observed:
  sha: 7ce3fb64fa6303c5da6c7fc27c979f7233b761ac
  meaning: HISTORICAL_OBSERVATION_ONLY
  use_as_permanent_authority: false
```

매 작업 시작 시 실제 Base `main`을 다시 조회한다.

### 0.1 지시 범위 경계 — 문서 작성과 실제 실행을 분리

이 작업지시문을 작성·갱신하는 요청에서는 **지시문 범위를 넘어 실제 저장소·PR·Base·Godot·PowerShell·Codex 작업을 실행하지 않는다.**

```yaml
instruction_authoring_request:
  may_edit_instruction_document: true
  may_research_and_compare: true
  may_inspect_attached_or_explicitly_requested_sources: true
  may_execute_project_build_or_repo_mutation: false
  may_merge_or_close_prs: false
  may_run_powershell_codex_godot: false
```

실제 실행은 사용자가 별도의 실행 요청을 하거나, 이 계약의 실행 단계에 명시적으로 진입했을 때만 허용한다.

### 0.2 프로젝트 작업 순서 — 절대 순서

프로젝트의 정상 작업 순서는 다음 세 단계다.

```text
PHASE A — GPT CHAT PLANNING
1. 게임 세부기획서 작업구조 개선
2. 기획 작업
3. 필요한 이미지 생성·검토
4. Grill Me로 기획 충돌 승인
5. 주요 승인 Decision을 GitHub 정본·계획 데이터·연결 Google Sheet에 즉시 동기화
6. 최대 10건 승인 배치마다 planning/document PR 검수·적대적 검토·필요시 병합
7. 사용자와 함께 기획 전체를 닫음

USER GATE
→ 사용자가 명시적으로 “기획 완료” 선언

PHASE B — FINAL PLANNING REVIEW
8. 전체 기획 정본 재조회
9. 기능 단위 분해
10. 이미 반영됨 / 현재에도 유효 / 충돌·구형 분류
11. 벤치마킹·현업 비교
12. 작업순서·의존성·보호범위 최종 확정
13. 적대적 검토·브레인스토밍·Superpowers 검증
14. 구현 패키지 Definition of Ready 닫기

PHASE C — POWERSHELL / CODEX / GODOT BUILD
15. PowerShell에서 Codex 실행
16. HiGodot/GUT/Hera 역할 경계에 따라 구현·테스트·QA
17. PR·exact validation target·ci-gate·적대적 검토
18. 승인 범위 안이면 자동 병합
19. merged-main readback
20. 사용자 로컬 Fetch/Pull 및 Godot Project Play
```

**중요:** PHASE A/B가 끝나기 전에는 PowerShell/Codex/Godot persistent implementation을 시작하지 않는다.
기획 중 10건 승인 배치 병합은 기획 정본·Decision·문서 변경을 닫는 것이며, Godot BUILD 시작 승인이 아니다.

---

## 1. 최초 진입 순서

작업 시작 시 다음 순서로 읽는다.

```text
Base current main SHA
→ recursive tracked-file inventory 또는 동등한 전체 범위 증거
→ START_HERE.md
→ AGENTS.md
→ docs/OPERATING_MODEL.md
→ docs/WORK_MODE_AND_SKILL_ROUTING.md
→ docs/DOCUMENTATION_MAP.md
→ skills/SKILL_REGISTRY.json
→ docs/generated/BASE_ACTIVE_SKILLS.md
→ 현재 요청에 필요한 책임 원본·Skill·mode·reference·Template·Test
→ 동일 Goal의 열린·최근 병합 PR
→ 대상 프로젝트 AGENTS/START_HERE/Active Context/Decision/Sheet/정본
→ 실제 코드·데이터·Scene·Resource·자산·테스트
```

`Base를 전부 살펴본다`는 의미:

```text
전체 저장소 범위와 권한 지도를 먼저 복원
+
현재 작업과 관계 있는 owner·consumer·test·recent PR을 깊게 읽음
```

다음을 의미하지 않는다.

```text
모든 Skill 본문을 무조건 컨텍스트에 로드
모든 과거 문서를 current authority로 취급
README 몇 개만 읽고 전체 검토 완료 주장
```

활성 Skill 수는 Registry 관찰값일 뿐 설계 목표가 아니다.
Skill 수를 유지하려고 필요한 독립 Skill을 금지하거나, 숫자를 늘리기 위해 중복 Skill을 만들지 않는다.

---

## 2. 권위 순서

현재 실행의 사실·결정 권위는 다음 순서로 해석한다.

1. 사용자의 최신 명시 지시와 승인된 결정
2. 현재 환경의 system/developer/security 실행 제약
3. 프로젝트 `AGENTS.md`, 보안·엔진·데이터 계약
4. 프로젝트 Active Context와 승인된 실행 계약
5. `CURRENT_CONFIRMED_DECISIONS` 및 등록된 분야 정본
6. 실제 코드·데이터·Scene·Resource·자산·테스트
7. 프로젝트에 채택된 Base Adapter/lock/snapshot
8. Base remote current `main`
9. 외부 공식·전문가·현업·플레이어 근거
10. 과거 draft·과거 prompt·검색 캐시·추정

외부 근거는 프로젝트 정본을 대체하지 않는다.
반대로 프로젝트 문서가 실제 코드·데이터와 충돌하면 충돌을 숨기지 않는다.

---

## 3. EXTERNAL_PROCESS_OVERLAY — Superpowers 등 외부 프로세스 합성

Base current `docs/CAPABILITY_COMPOSITION_MAP.md`의 계약을 따른다.

```yaml
external_process_overlay:
  authority: EXECUTION_PROCESS_ONLY
  overlay_name_or_source:
  applied_process_skills_or_gates: []
  approval_state: NEW_APPROVAL | REUSED_APPROVAL | NOT_REQUIRED | BLOCKED
  approval_reference:
  conflict_state: NONE | OVERLAY_CONFLICT | BLOCKED_UNVERIFIED
  extra_evidence: []
```

예:

- Superpowers brainstorming
- writing-plans
- test-driven-development
- systematic-debugging
- requesting-code-review
- verification-before-completion
- 기타 system/developer가 요구하는 실행 프로세스

규칙:

1. 외부 프로세스는 **현재 실행 방법**을 강화할 수 있다.
2. 프로젝트 정본·`CURRENT_CONFIRMED_DECISIONS`를 소유하거나 덮어쓰지 않는다.
3. Base의 안전·증거·보호 Gate를 약화하지 않는다.
4. 정확히 같은 승인 범위는 `REUSED_APPROVAL`로 처리한다.
5. 기술 재검증 때문에 같은 기획 승인을 다시 요구하지 않는다.
6. 범위·코어·보호 행동·사용자 결정이 실제로 바뀌면 새 승인 Gate를 연다.
7. 외부 Skill을 읽은 것과 실제 실행한 것을 구분한다.
8. 충돌은 `OVERLAY_CONFLICT`로 기록하고 안전하게 해소할 수 없으면 `BLOCKED_UNVERIFIED`.
9. 외부 프로세스를 썼다는 이유만으로 Base Skill을 새로 만들지 않는다.

실행 보고에는 최소 다음을 남긴다.

```yaml
external_process_execution:
  overlay_name_or_source:
  read_skills: []
  actually_executed_skills_or_gates: []
  approval_reference:
  approval_reused:
  extra_evidence: []
  unresolved_overlay_conflict:
```

---

## 4. 프로젝트 입력 계약

아래 값은 v4.4의 프로젝트 고유 입력을 보존한다.
작업 시작 시 실제 환경과 대조하며, 빈 값은 자동으로 채워졌다고 추정하지 않는다.

```yaml
mode: AUTO | AUDIT_ONLY | PLAN_AND_IMPLEMENT | REVIEW_ONLY | MERGE_AND_DELIVER

base_repository: "https://github.com/alsdmlals4-eng/Base"
base_branch: "main"
base_snapshot_observed_when_v4_5_written: "7ce3fb64fa6303c5da6c7fc27c979f7233b761ac"
base_snapshot_policy: ALWAYS_REFETCH_CURRENT_MAIN_BEFORE_WORK
base_repository_review_policy: RECURSIVE_INVENTORY_THEN_RELEVANCE_DRIVEN_DEEP_READ

project_repository:
project_default_branch: "main"

project_local_path: "C:/Users/user/Documents/GitHub/Ninza/Switchy-Express-Cargo-Puzzle"
canonical_local_checkout: "C:/Users/user/Documents/GitHub/Ninza/Switchy-Express-Cargo-Puzzle"
godot_project_path: "C:/Users/user/Documents/GitHub/Ninza/Switchy-Express-Cargo-Puzzle"

godot_executable:
godot_target_family: "4.7.x"
godot_recommended_exact_version_observed_at_v4_5_update: "4.7.1-stable"
godot_exact_version_to_verify:
godot_project_file: "project.godot"
startup_scene:
application_run_main_scene:

higodot:
  canonical_source_repository: "hi-godot/godot-ai"
  pinned_version_or_commit:
  adoption_record:
  authority: SOLE_PERSISTENT_GODOT_AUTHORING_AUTHORITY
  authoring_scope:
    - scene
    - node
    - script
    - resource
    - theme
    - animation
    - signal
    - project_settings
    - input_map
    - autoload
    - godot_project_filesystem
  adoption_status: NOT_VERIFIED

gut:
  canonical_source_repository: "bitwes/Gut"
  expected_version_when_godot_4_7_x: "9.7.1"
  source_branch_or_release: "godot_4_7"
  pinned_source_commit:
  license_expected: "MIT"
  authority: DETERMINISTIC_GDSCRIPT_TEST_AUTHORITY_WHEN_ADOPTED
  adoption_record:
  adoption_status: NOT_VERIFIED

hera_agent:
  canonical_asset_store: "https://store.godotengine.org/asset/notnull92/hera-agent-godot/"
  canonical_source:
  exact_cli_version:
  exact_addon_version:
  role: LIVE_QA_AND_OBSERVABILITY_ONLY
  persistent_source_mutation: FORBIDDEN
  transport: LOCALHOST_ONLY
  acceptance_source_delta: NONE
  adoption_status: NOT_VERIFIED

github:
  gh_cli_expected_installed: true
  gh_version:
  gh_auth_status:
  repository_visibility:
  actions_budget_usd: 0
  default_ci_mode: REMOTE_CI
  allowed_runner_class: STANDARD_GITHUB_HOSTED
  forbidden_by_budget:
    - LARGER_RUNNER
    - GPU_RUNNER
    - PAID_CUSTOM_IMAGE
  required_check: ci-gate
  merge_method_preference: squash
  local_user_handoff: FETCH_ORIGIN_THEN_PULL_ORIGIN

target_platforms:
  - Windows
  - Android

shared_core_policy: SINGLE_GAME_LOGIC_AND_DATA_CORE
platform_separation_policy: INPUT_UI_PLATFORM_INTEGRATION_AND_DELIVERY_PROFILE_ONLY
windows_export_required: true
android_export_required: true
target_resolutions: []
target_aspect_ratios: []
input_methods:
  - keyboard_mouse
  - gamepad_when_applicable
  - touch
  - android_back
accessibility_requirements: []

build_size_policy:
  objective: PRESERVE_PERCEIVED_QUALITY_WHILE_REMOVING_WASTED_BYTES
  measure_separately:
    - DOWNLOAD
    - INSTALLED
    - RUNTIME
    - PATCH
  font_policy: UNIFY_FAMILY_AND_THEME_ROLES_NOT_FORCE_SINGLE_FILE
  platform_delivery_profiles: WINDOWS_AND_ANDROID_SEPARATE

project_google_sheet:
google_sheet_required_tabs_or_ranges: []
decision_ledger_source:
unresolved_items_source:
image_review_sheet_tab_or_range:
entry_state_reconciliation_required: true

project_asset_vault:
  local_root: "<project-root>/.asset-vault/"
  godot_local_projection: "res://assets/_vault_local/"
  tracked_manifest: "ASSET_MANIFEST.yml"
  approval_boundary: PROJECT_ASSET_APPROVED
  tracked_promotion_required: true

local_godot_reference_library:
  path: "C:/Users/user/Documents/GitHub/Godot_Reference"
  authority: REFERENCE_ONLY
  expected_categories:
    - Templates
    - Official_Demos
    - Plugins_Reference
    - Sandbox
    - Archive/Source_Zips
  known_reference_candidates:
    - godot-demo-projects-master
    - loading_serialization
    - gui_multiple_resolutions
    - 3d_graphics_settings
    - Global-Asset-Manager-2.0.1
    - Maaack_Game_Template_if_present

shared_audio_vault_path: "C:/Users/user/Documents/GitHub/shered audio vault"
shared_audio_vault_access: READ_ONLY_SOURCE_LIBRARY
shared_audio_vault_first: true
audio_runtime_reference_policy: COPY_APPROVED_ASSETS_INTO_RES_NOT_ABSOLUTE_PATH

current_goal:
requested_deliverables:
vertical_slice_scope:

protected_decisions: []
protected_behaviors: []
protected_files_or_assets: []
explicit_exclusions: []

planning_first: true
test_first_every_task: true
numeric_detail_policy: GPT_RECOMMENDED_WITH_EVIDENCE_AND_TUNING_RANGE
planning_conflict_policy: GRILL_ME_AND_REQUIRE_USER_APPROVAL
grill_me_approval_batch_max: 10
benchmark_policy: OFFICIAL_AND_PROFESSIONAL_RESEARCH_REQUIRED_WHEN_DECISION_RELEVANT

codex_handoff_policy: ON_DEMAND_CODEX_HANDOFF
codex_handoff_trigger: USER_REQUESTED_CODEX_HANDOFF
codex_package_definition_of_ready: REQUIRED
codex_preflight_policy: OPTIONAL_RISK_BASED
gpt_godot_preproduction_allowed: true

new_skill_policy: CONSOLIDATION_FIRST_BUT_ALLOWED_WITH_INDEPENDENT_BOUNDARY
base_promotion_policy: BCP_PROPOSAL_THEN_SEPARATE_APPROVED_IMPLEMENTATION_PR

implementation_authority: APPROVED_CANON_AND_RECOMMENDED_NON_CONFLICTING_DETAILS
merge_authority: APPROVED_ITEM_INHERITS_MERGE_AUTHORITY
merge_reapproval_required_for_same_approved_scope: false
post_merge_local_sync_authority: AUTHORIZED_AFTER_MERGE
godot_launch_authority: AUTHORIZED_AFTER_LOCAL_SYNC
```

### 4.1 경로 해석

- `project_local_path` = Git 저장소 루트.
- `godot_project_path` = 실제 `project.godot`이 존재하는 폴더.
- 둘이 같아도 정상.
- 로컬 경로는 사용자 환경 입력이며 Base 공용 정본으로 승격하지 않는다.
- `shared_audio_vault_path`의 `shered` 표기는 v4.4의 사용자 원문을 그대로 보존한다.

### 4.2 보호 입력

```text
[핵심 내용]

```

프로젝트 목적·확정 방향·필수 경험·기능·콘텐츠·금지 사항·완료 기준은 의미를 삭제하거나 약화하지 않는다.

---

## 5. Work Mode·Skill 라우팅

Base current Registry를 자동 라우팅 권위로 사용한다.

```text
요청
→ PLAN | BUILD | REVIEW
→ 작업 수준 L0~L4
→ primary discipline 최대 1개
→ 필요한 foundation/validation/handoff만 추가
→ 각 Skill에서 필요한 mode만 실행
→ 실제 사용한 Skill/mode와 결과 기록
```

규칙:

- 사용자가 Skill 이름을 기억할 필요가 없다.
- `load_by_default=false`는 자동 선택 금지가 아니다.
- trigger 불일치 Skill을 관성적으로 로드하지 않는다.
- Skill을 읽은 것과 실행한 것을 구분한다.
- 새 범위·새 실패·정본 변경이 생기면 라우팅을 재계산한다.
- 외부 process overlay는 Base Skill 라우팅을 대체하지 않는다.

---

## 6. 전체 생명주기

```text
CURRENT BASE RECOVERY
→ PROJECT WHOLE-STATE RECOVERY
→ ENTRY STATE RECONCILIATION
→ PLAN
→ BENCHMARK
→ EXISTING SOLUTION FIRST
→ GRILL ME ONLY FOR MATERIAL PLANNING CONFLICT
→ APPROVED DECISION SYNC
→ BUILD
→ TEST-FIRST / VALIDATION
→ PLAYER-EXPERIENCE EVIDENCE AS APPLICABLE
→ ADVERSARIAL ATTACK
→ VALIDATE CRITIQUE
→ APPROVED MINIMAL FIX
→ REGRESSION RECHECK
→ EXACT CURRENT PR VALIDATION TARGET
→ REQUIRED CI-GATE
→ MERGE WITH REUSED APPROVAL
→ NEW MAIN READBACK
→ POST-MERGE ADVERSARIAL RECHECK
→ SAFE BRANCH CLEANUP
→ LOCAL FETCH/PULL
→ GODOT PROJECT PLAY
→ FINAL EVIDENCE REPORT
```

한 시점의 주 Work Mode는 하나다.
복합 작업은 `PLAN → BUILD → REVIEW`로 전환한다.

---

## 7. 프로젝트 전체 복원

작업 시작 전에 다음을 서로 대조한다.

```yaml
repository:
  current_main_sha:
  current_branch:
  working_tree_state:
  open_same_goal_prs:
  recently_merged_same_goal_prs:

project:
  current_confirmed_decisions:
  active_context:
  current_goal:
  next_work:
  blocked_items:
  actual_code_data_scene_resource_state:

sheet:
  exact_url:
  relevant_tabs_or_ranges:
  decision_ids:
  unresolved_items:
  image_review_status:
  reread_status:

entry_reconciliation:
  claimed_state:
  observed_state:
  result: READY | REVISE | BLOCKED_UNVERIFIED
```

검색·대화 기록만으로 프로젝트 전체 상태를 추정하지 않는다.

---

### 7.1 핵심 요구 추적표 — v4.4 보호 계약 복원

모든 핵심 요구·승인 Decision·보호 항목을 구현·검증·병합·로컬 실행까지 추적한다.

| 요구/Decision ID | 원문 요구·결정 | 책임 정본 | 계획/데이터 | 실제 구현 | 시각/컴포넌트 | 테스트·실행 증거 | 상태 |
|---|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  | `PENDING` |

허용 상태:

```text
CONFIRMED
SPECIFIED
APPROVED
CANON_SYNCED
SHEET_SYNCED
IMPLEMENTED
RUNTIME_VALIDATED
HUMAN_VALIDATED
MERGED
LOCAL_RUN_VALIDATED
DEFERRED_WITH_REASON
OUT_OF_SCOPE_CONFIRMED
USER_DECISION_REQUIRED
BLOCKED_UNVERIFIED
```

모든 핵심 요구가 위 상태 중 하나로 닫히지 않으면 전체 완료가 아니다.
`CANON_SYNCED`와 `SHEET_SYNCED`는 가능한 경우 같은 Decision ID를 사용한다.

## 8. 기획 우선·핵심 게임 모델

구현 전에 최소 다음을 닫는다.

```yaml
project_goal:
pointed_fun:
core_loop:
session_loop:
meta_loop:
core_systems: []
supporting_systems: []
player_verbs: []
meaningful_choices: []
failure_learning:
reward_structure:
protected_identity:
```

### 8.1 기획 우선 Hard Gate

기획이 미완료인 상태에서는 구현 편의를 이유로 세부 방향을 확정하지 않는다.

```text
기획 구조
→ 핵심 재미·목표·시스템
→ 기능 단위 명세
→ 데이터·수치 권장안
→ 충돌 Decision
→ 이미지/UX 근거
→ 승인·정본 동기화
→ 전체 기획 완료 선언
→ 최종 검수
→ 구현
```

### 8.2 상세 데이터·수치 — GPT 권장안 기본

세부 수치·밸런스·간격·쿨다운·보상량·확률·UI dimension 등 **프로젝트 코어를 바꾸지 않는 조정 가능 수치**는 GPT가 권장안을 만든다.

```yaml
numeric_recommendation:
  decision_or_feature_id:
  recommended_value:
  recommended_range:
  benchmark_or_industry_basis:
  player_experience_rationale:
  risk:
  tuning_signal:
  rollback_or_adjustment_rule:
```

수치가 핵심 재미·경제 구조·플레이어 약속·보호 동작과 충돌하면 `PLANNING_CONFLICT`로 승격하고 Grill Me 승인을 받는다.

질문:

- 이 기능이 핵심 재미를 강화하는가?
- 플레이어의 행동·선택·결과가 명확한가?
- 핵심 시스템과 보조 시스템을 혼동하지 않았는가?
- 기능 제거 시 프로젝트 정체성이 깨지는가?
- 단순 기능 추가보다 더 작은 해법이 있는가?

---

## 9. 벤치마킹·현업 조사

중요 결정은 최신 외부 근거를 사용한다.

우선순위:

1. 공식 문서·공식 릴리스·공식 저장소
2. 유지되는 오픈소스/업스트림
3. 현업 엔지니어링 문서·공개 postmortem
4. 유사 게임 실제 플레이·패치·개발자 설명
5. 플레이어 행동/리뷰
6. 커뮤니티 의견

앞으로 **Grill Me 질문을 만들 때와 중요한 작업 권장안을 만들 때마다** 관련 벤치마킹·현업 비교를 함께 검토한다.

```yaml
benchmark_recommendation:
  feature_or_decision_id:
  project_current_direction:
  comparable_titles_or_products: []
  official_or_professional_sources: []
  industry_pattern:
  player_response_when_available:
  what_to_copy: []
  what_not_to_copy: []
  gpt_recommendation:
  why_this_fits_project:
  uncertainty:
```

단순 유행 추종이 아니라 현재 프로젝트의 강점·비용·플랫폼·제작 규모와 비교한다.
Grill Me 선택지에는 가능한 경우 각 선택의 **벤치마크 근거 / 현업 관행 / 프로젝트 적합성 / 비용·위험**을 짧게 붙인다.

각 근거는 다음을 분리한다.

```yaml
evidence:
  source:
  date:
  claim:
  fact_or_inference: FACT | INFERENCE
  project_applicability:
  conflict_with_current_canon:
  decision_changed:
```

`BENCHMARK_ONLY_DECISION`은 금지한다.
비교 대상의 기능을 그대로 복사하지 않는다.

### 9.1 v4.5 작성 시 재확인한 공개 기준

아래는 **2026-08-11 관찰값**이며 실행 시 재검증한다.

- Godot 4.7.1-stable: 2026-07-14 maintenance stable.
- Godot 4.8: v4.5 작성 시 archive에서 dev 계열.
- GUT 9.7.1 `godot_4_7`: Godot 4.7.x 대상.
- public repository + standard GitHub-hosted runner: GitHub Actions 사용은 무료.
- GitHub Actions는 full-length commit SHA pin이 immutable 사용의 권장 안전 경계.
- Required status check는 현재 요구되는 최신 validation target에서 성공해야 한다.

공식 재검증 출발점:

```text
GitHub Actions billing
https://docs.github.com/en/billing/concepts/product-billing/github-actions

GitHub-hosted runners
https://docs.github.com/en/actions/reference/runners/github-hosted-runners

GitHub Actions secure use
https://docs.github.com/en/actions/reference/security/secure-use

GitHub required status checks
https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-required-status-checks

Godot 4.7.1 release
https://godotengine.org/article/maintenance-release-godot-4-7-1/

Godot release archive
https://godotengine.org/download/archive/

GUT
https://github.com/bitwes/Gut
```

---

## 10. Existing Solution First

새 MCP·addon·CLI·framework·Skill·mode·tool·system을 만들기 전에 다음을 조사한다.

```text
프로젝트 기존 구현
→ Base current owner/mode/reference
→ Local Godot Reference Library
→ Godot 공식 데모·템플릿
→ Godot Asset Library
→ 유지되는 외부 대안
→ LICENSE / maintenance / compatibility / adoption cost
→ REUSE | EXTEND | TRIAL | REJECT | BUILD_NEW
```

`BUILD_NEW`는 기본값이 아니다.

필수 기록:

```yaml
existing_solution_disposition:
  searched_sources: []
  candidates: []
  selected:
  rejected_with_reason: []
  build_new_justification:
  rollback:
```

---

## 11. Grill Me·Decision 승인

사용자에게 올리는 것은 **중요 기획 충돌·방향 선택**이다.

자동 권장 가능:

- 가역적 수치
- 기술 기본값
- 범위 안의 구현 세부
- 명백한 오류 수정

사용자 결정 필요:

- 프로젝트 코어 변경
- 핵심 재미 방향 변경
- MVP/Vertical Slice 범위 의미 변화
- 중요한 UX·보상·경제·서사 선택
- 호환성 파괴
- 보호 대상 삭제
- 승인 범위 확대

Decision batch:

```yaml
max_decisions_per_batch: 10
early_checkpoint_allowed: true
early_checkpoint_when:
  - high_risk_conflict
  - core_direction_changed
  - session_or_context_end_risk
  - canon_impact_is_large
  - contradictions_accumulate
  - next_decision_depends_on_prior_user_choice
```

### 11.1 Grill Me 질문 규칙

각 중요한 충돌 질문에는 가능하면 다음을 제공한다.

1. 현재 프로젝트 정본의 상태
2. 충돌 지점
3. GPT 권장안
4. 대안
5. 벤치마킹/현업 비교
6. 각 선택의 비용·위험
7. 추천 선택이 보호하는 기존 강점
8. Decision ID

### 11.2 승인 즉시 정본 동기화

승인되면 가능한 즉시 같은 Decision ID로 다음을 동기화한다.

```text
GitHub 권위 문서
→ 계획/기획 데이터
→ 연결된 Google Sheet의 대응 tab/range
→ Decision ledger / change record
```

```yaml
decision_sync:
  decision_id:
  approved_choice:
  github_canon_locations: []
  planning_data_locations: []
  google_sheet_url:
  sheet_tab_or_range:
  commit_or_pr:
  sync_result:
  reread_result:
```

연결된 Sheet를 찾을 수 있고 권한이 있으면 GPT가 직접 찾아 반영한다.
사용자 행동만으로 가능한 경우에만 blocker로 남긴다.

### 11.3 최대 10건 승인 배치 종료 프로토콜

승인 10건은 **최대 배치 크기**다. 고위험 충돌·세션 종료 위험·정본 영향이 크면 그 전에 닫을 수 있다.

```text
approved Decision IDs inventory
→ canon + planning data + Sheet sync
→ reread
→ planning/document change diff
→ TDD/contract check where applicable
→ PR inventory
→ planning PR create/update
→ required checks
→ adversarial review loop
→ critique validation
→ approved minimal fix
→ recheck
→ current conversation auto-merge rule 적용 가능 여부 판정
→ merge when eligible
→ new main readback
→ remaining Draft/Open PR reread
```

이 배치 병합은 **기획 결과의 정본화**이며 PHASE C 구현을 시작시키지 않는다.

---

## 12. 승인·병합 권한

### 12.0 현재 대화의 병합 승인 계약

이 작업지시문을 작성한 **현재 대화에서 사용자가 이미 승인한 범위**는 권장안대로 자동 병합 승인된 것으로 취급한다.

```yaml
current_conversation_merge_approval:
  scope: ALREADY_USER_APPROVED_ITEMS_IN_THIS_CONVERSATION
  merge_reapproval: NOT_REQUIRED
  recommended_low_risk_pr_merge: AUTO_APPROVED_AFTER_ALL_GATES
  planning_conflict_auto_approval: FORBIDDEN
  scope_expansion_auto_approval: FORBIDDEN
```

이 권한은 다른 대화·미래 프로젝트에 영구 승계되지 않는다.
새 기획 충돌은 반드시 Grill Me로 승인받는다.

자동 병합에서 제외:

- proposal-only
- reference-only
- `DO_NOT_MERGE`
- 실험/PoC 보존 PR
- 필수 검증 미완료
- stale base / strict-up-to-date 미충족
- unresolved review thread
- 승인 범위 밖 diff
- P0/P1 적대적 finding 미해결
- 사용자 행동이 필요한 미검증 위험

### 12.1 같은 승인 범위

사용자의 명시 승인이 무엇을 가리키는지 명확하면:

```text
APPROVAL
→ BUILD
→ VERIFY
→ PR
→ exact current validation target
→ ci-gate
→ adversarial review
→ merge
→ readback
```

다시 묻지 않는다.

금지:

```text
같은 범위인데 “정말 진행할까요?”
같은 범위인데 “PR 올릴까요?”
같은 범위인데 “병합할까요?”
HEAD가 바뀌었다는 이유만으로 기획 승인 재요청
```

### 12.2 HEAD/base가 변경된 경우

사용자 승인은 유지될 수 있지만 기술 검증은 다시 만든다.

```yaml
validation_identity:
  review_head_sha:
  base_sha:
  merge_base_sha:
  test_merge_sha:
  merge_group_sha:
  ci_validation_target_sha:
```

현재 저장소가 실제로 요구하는 SHA를 검증한다.

---

## 13. BCP-020 PLAYER_EXPERIENCE_EVIDENCE_GATE

Base current의 플레이어 경험 계약을 프로젝트에 적용한다.

네 증거를 하나의 `validation passed`로 뭉뚱그리지 않는다.

| 증거 | 증명 | 증명하지 않음 |
|---|---|---|
| `TECH_EVIDENCE` | 코드·데이터·Schema·엔진 실행의 기술 상태 | 사람이 이해/재미/기억을 얻는지 |
| `UI_EVIDENCE` | 렌더·입력·포커스·해상도·시각 상태 | 처음 보는 사용자가 다음 행동을 찾는지 |
| `HUMAN_USABILITY_EVIDENCE` | 사람이 조작·정보 구조·다음 행동을 이해하는지 | 의도한 감정·고민·기억이 생기는지 |
| `PLAYER_EXPERIENCE_EVIDENCE` | 의도한 고민·감정·선택·보상·기억이 실제 플레이에 생기는지 | 장기 유지율·판매 성과 |

사람 관찰을 실행하지 않았으면:

```yaml
HUMAN_USABILITY_EVIDENCE: NOT_RUN
PLAYER_EXPERIENCE_EVIDENCE: NOT_RUN
```

자동 테스트·렌더 캡처·텍스트 검사로 위 두 상태를 `PASS`로 올리지 않는다.

사람 검증을 했다면:

```yaml
human_test:
  participant_context:
  prior_exposure:
  task:
  questions:
  observed_actions:
  answers:
  failure_points:
  sample_limitations:
```

---

## 14. FIRST SESSION / FIRST 10 MINUTES CONTRACT

`FIRST_10_MINUTES`는 고정 시간 제한이 아니라 **대표 경험의 압축판 기본값**이다.

장르·세션 길이에 따라 시간 창은 조정할 수 있지만 다음 흐름은 관찰 가능해야 한다.

```text
대표 문제
→ 대표 행동
→ 첫 의미 있는 선택
→ 첫 관찰 가능한 결과
→ 다음 질문
```

```yaml
first_session_contract:
  representative_problem:
  representative_action:
  first_meaningful_choice:
  first_observable_result:
  next_question_created:
  time_window: FIRST_10_MINUTES_DEFAULT | PROJECT_ADAPTED
```

공포·미스터리처럼 정보를 숨기는 것은 허용한다.
그러나 **지금 무엇을 시도할 수 있는지**까지 숨기지 않는다.

---

## 15. DECISION SCREEN COMPREHENSION GATE

핵심 의사결정 화면은 다음 네 질문을 답할 수 있어야 한다.

```text
현재 상황은 무엇인가
무엇을 선택할 수 있는가
선택에 필요한 정보는 무엇인가
선택하면 어떤 비용·위험·결과가 예상되는가
```

검증:

```yaml
decision_screen:
  current_situation_readable:
  available_choices_readable:
  needed_information_readable:
  cost_risk_result_readable:
  intentionally_hidden_information:
  hidden_information_does_not_hide_action_purpose:
```

장식·애니메이션 품질은 이 Gate를 대신하지 않는다.

---

## 16. MINIGAME_NARRATIVE_FUNCTION_GATE

**프로젝트 코어가 아닌 별도 미니게임 후보**에만 적용한다.

```yaml
minigame_narrative_function:
  main_game_information_used:
  player_decision_tested:
  narrative_or_system_result_changed:
  failure_learning:
  rule_learning_time:
  reusability:
  content_cost:
  flow_interrupt_cost:
```

통과 방향:

- 본편 정보·규칙이 실제 판단에 쓰인다.
- 성공/실패가 사건·자원·기록·다음 선택을 바꾼다.
- 실패가 다음 시도 학습을 남긴다.
- 공통 프레임/데이터 변형으로 재사용 가능성을 검토한다.
- 더 짧은 선택지/공통 상호작용이 같은 경험을 낼 수 있는지 비교한다.

**주의**

퍼즐·전투·제작 자체가 프로젝트 코어면 이를 미니게임으로 낮춰 평가하지 않는다.

```text
CORE PUZZLE / CORE COMBAT / CORE CRAFTING
→ CORE_INTERACTION_EVIDENCE
→ project core contract
```

---

## 17. Visual Requirement Gate

이미지를 만들기 전에 다음 순서로 판단한다.

```text
필요성
→ Delete Test
→ 기존 승인 자산 재사용 가능성
→ UI/게임플레이/서사에서의 역할
→ 중요도 P0~P3
→ 제작 방식
→ 승인
→ 프로젝트 Asset Vault promote
```

이미지가 없어도 경험·정보 구조가 유지되면 장식 자산일 수 있다.

`DRAFT`, `placeholder`, 임시 생성 이미지를 최종 승인 자산처럼 사용하지 않는다.

---

## 18. Asset Vault·Reference Library·Audio Vault

### 프로젝트 Asset Vault

```text
candidate
→ provenance
→ rights/license
→ technical validation
→ user/project approval
→ PROJECT_ASSET_APPROVED
→ tracked promotion
→ Godot res:// consumption
```

`res://assets/_vault_local/`은 local-only 후보 공간이다.
tracked Scene/Resource가 local-only 후보에 영구 의존하지 않는다.

### Local Godot Reference

```text
REFERENCE_ONLY
```

참고 자료의 발견은 active adoption이 아니다.

검증:

- upstream
- version/commit
- license
- Godot compatibility
- 실제 소비 경로
- 제거/rollback

### Shared Audio Vault

원본 Vault는 읽기 전용 source library로 취급한다.

```text
shared vault
→ rights/hash review
→ approved copy
→ project res://
→ import/loop/volume validation
```

production runtime에서 외부 절대 경로를 참조하지 않는다.

---

## 19. UI 컴포넌트 Gate

UI 변경은 최소 다음을 정의한다.

```yaml
component:
  purpose:
  states:
    - default
    - hover_or_focus
    - pressed
    - disabled
    - loading_when_applicable
    - error_when_applicable
  input:
    keyboard_mouse:
    gamepad:
    touch:
    android_back:
  focus_behavior:
  accessibility:
  responsive_behavior:
  motion:
  audio_haptic_feedback:
```

체크:

- 정보 우선순위
- 다음 행동 발견 가능성
- 입력 장벽
- 해상도/비율
- 한글/CJK
- reduced motion
- 오류/빈 상태/복구
- focus
- touch target

---

## 20. HiGodot·GUT·Hera 책임 분리

이 섹션은 v4.4의 프로젝트 고유 채택 정책을 보존한다.
실제 프로젝트 adoption record가 다르면 프로젝트 정본이 우선한다.

### HiGodot

```text
SOLO PERSISTENT GODOT AUTHORING AUTHORITY
```

채택된 경우 persistent Godot 변경:

- Scene
- Node
- Script
- Resource
- Theme
- Animation
- Signal
- Project settings
- Input Map
- Autoload

를 다른 도구가 우회 저작하지 않는다.

### GUT

Godot 4.7.x에서 formal adoption이 있을 때:

```text
GUT 9.7.1 / godot_4_7
→ deterministic GDScript test authority
```

GUT은 production authoring 권위가 아니다.

### Hera

```text
LIVE_QA_AND_OBSERVABILITY_ONLY
```

- persistent source mutation 금지
- acceptance 후 tracked source delta = NONE
- exact CLI/addon pair 검증
- localhost transport 정책 확인

---

## 21. Godot 버전·실행

버전을 추측하지 않는다.

확인:

```text
project.godot
Godot binary
CI
export presets
project docs
plugin compatibility
```

v4.5 작성 시 외부 기준:

```yaml
godot:
  target_family_from_project_contract: 4.7.x
  observed_stable_reference: 4.7.1-stable
  observed_release_date: 2026-07-14
  current_4_8_archive_state_when_v4_5_written: dev
```

업그레이드 전 백업/Git 복구 경로를 유지한다.

---

## 22. Windows·Android Shared Core

게임 로직과 데이터를 플랫폼별로 복제하지 않는다.

```text
SINGLE GAME LOGIC / DATA CORE
├─ Windows adapter
│  ├─ keyboard/mouse
│  ├─ gamepad
│  └─ desktop delivery
└─ Android adapter
   ├─ touch
   ├─ android back
   ├─ lifecycle
   └─ mobile delivery
```

분리할 것:

- input
- UI layout/responsive
- platform integration
- export/delivery
- performance profile

공유할 것:

- 게임 규칙
- 상태 모델
- 핵심 데이터
- 세이브 의미
- 보상/경제의 기본 의미

---

## 23. Build Size·체감 품질

각각 따로 측정한다.

```yaml
size:
  download:
  installed:
  runtime_memory:
  patch_delta:
```

최적화는 다음을 보호한다.

- 핵심 화면 품질
- 오디오 식별성
- 텍스트 가독성
- CJK/emoji/fallback
- startup latency
- 모바일 발열
- patch size

금지:

```text
모든 texture 동일 해상도
모든 audio 동일 압축
font 파일 하나로 강제
설치 크기만 줄이고 first-session download/runtime 악화
```

---

## 24. 구현 준비 Gate

BUILD 전에:

```yaml
implementation_ready:
  approved_scope:
  approval_reference:
  protected_items:
  exact_baseline_sha:
  existing_solution_disposition:
  acceptance_criteria:
  rollback:
  affected_consumers:
  test_plan:
  applicable_human_or_player_evidence:
  godot_authoring_route:
```

불완전하면 BUILD로 넘어가지 않는다.

---

## 25. 구현 원칙·Test First

### 25.1 격리 작업

- 최신 `origin/main` 또는 current remote main을 기준으로 별도 branch/worktree를 사용한다.
- Base와 프로젝트 변경을 같은 PR에 섞지 않는다.
- 동일 Goal PR이 있으면 중복 PR을 만들지 않는다.
- 예상 파일과 실제 changed files를 계속 대조한다.
- 관련 없는 BOM/format/file-mode cleanup을 기능 변경에 섞지 않는다.

### 25.2 작업마다 TDD 항상 적용

모든 작업은 TDD 또는 그 작업 유형에 맞는 **test-first 증거**를 먼저 만든다.

| 작업 유형 | 먼저 만드는 실패 증거·수용 기준 |
|---|---|
| 코드·게임 로직 | 실패 단위·통합·회귀 |
| 데이터·밸런스 | schema·범위·불변식·시뮬레이션 실패 |
| Scene·Resource | 로드·참조·signal·state transition |
| UI·입력 | state·focus·resolution·input scenario |
| 이미지·애니메이션 | size·style·readability·frame·import acceptance |
| 문서·기획 | 누락·충돌을 재현하는 audit/checklist/contract |
| CI·배포 | failing validation job 또는 재현 절차 |
| PR hygiene | stale/duplicate/mergeability/required-check expected failure |

```text
요구/Decision
→ RED
→ failure reason verification
→ minimal GREEN
→ related regression
→ adversarial case
→ exact validation target
```

자동 테스트가 불가능한 작업도 **관찰 가능한 실패 조건과 수용 기준을 먼저** 작성한다.

### 25.3 TDD 증거 기록

```yaml
tdd_unit:
  id:
  requirement_or_decision_id:
  red_test_or_acceptance:
  red_result:
  failure_reason_verified:
  minimal_change:
  green_result:
  regression_suite:
  adversarial_case:
  evidence_location:
  commit_sha:
```

테스트를 나중에 추가하고 TDD를 했다고 주장하지 않는다.

### 25.4 최소 변경·Godot 안전

- 목표에 필요한 파일만 수정한다.
- save schema·public interface·Resource path를 무단 변경하지 않는다.
- Scene/Resource 텍스트 대량 치환을 기본값으로 두지 않는다.
- NodePath, UID, signal, owner, ext/sub resource를 검증한다.
- autoload/InputMap 중복 등록을 막는다.
- 현재 Godot 버전에 없는 API를 추측하지 않는다.
- deprecated 제거 시 모든 active consumer를 추적한다.

### 25.5 기본 RED→GREEN 루프

모든 실질 변경은 가능한 한 다음을 따른다.

```text
RED
→ verify failure reason
→ minimal GREEN
→ refactor only if needed
→ exact regression
```

회귀 테스트가 없던 정책/계약 문제라면 먼저 failing contract를 만든다.

금지:

- 테스트를 작성했지만 RED를 확인하지 않음
- unrelated 실패를 목표 실패라고 오인
- 테스트 통과를 런타임/사람 검증으로 과장

---

## 26. PowerShell·Codex 실행 프로토콜

Codex/Godot 구현은 **PHASE A 기획 완료 + 사용자 기획 완료 선언 + PHASE B 최종 검수** 뒤에만 실행한다.

### 26.1 기본 실행 명령

사용자가 지정한 기본 명령:

```powershell
codex.cmd -a never -s workspace-write
```

이 명령은 런타임에서 설치된 Codex CLI가 실제로 지원하는지 먼저 확인한다.
지원하지 않으면 추측해서 변형하지 않고 blocker 처리한다.

### 26.2 승인 클릭 최소화

Codex 자체는 `-a never`로 내부 승인 프롬프트를 만들지 않는 것을 기본으로 한다.

사용자 `[승인]` 요청은 **최대 2개**의 상위 단계 Gate로 제한한다.

```text
[승인 1/2]
기획 완료 + 최종 구현 패키지 잠금 + PowerShell/Codex BUILD 시작

[승인 2/2]
사용자 로컬에서만 가능한 privileged/manual action 또는 최종 수동 전달 Gate가 실제로 필요할 때
```

두 번째 승인이 필요하지 않으면 억지로 만들지 않는다.
GitHub PR 병합은 현재 대화의 이미 승인된 범위에서 별도 `[승인]` 횟수로 계산하지 않는다.

### 26.3 Full-auto 원칙

직접 해결 가능한 작업은 GPT/Codex가 직접 수행한다.

- 파일 조사
- 코드/문서 수정
- 테스트
- Git 작업
- PR 상태 확인
- benchmark/review
- rerun
- merged-main readback

사용자만 할 수 있는 작업을 제외하고 “직접 해주세요”로 넘기지 않는다.

### 26.4 Ephemeral execution session

PowerShell/Codex/Godot 실행 블록이 끝나면 해당 세션 상태를 영구 권위로 사용하지 않는다.

```text
finish block
→ save evidence
→ close Codex process when applicable
→ close Godot/editor/test process when applicable
→ close PowerShell block when applicable
→ next block starts with fresh repo/process/session read
```

다음 실행은 **처음부터 다시 시작한다고 생각하고** 다음을 재검증한다.

```yaml
fresh_execution_identity:
  current_main_sha:
  branch:
  working_tree:
  codex_version_and_args:
  godot_version:
  godot_process:
  gut_discovery:
  hera_transport:
  exact_target:
```

stale PID/session/editor state를 현재 성공 증거로 사용하지 않는다.

### 26.5 Codex 인계

Codex는 기본 의무 단계가 아니다.

```text
USER_REQUESTED_CODEX_HANDOFF
AND package DoR closed
→ handoff
```

인계 패키지:

```yaml
codex_package:
  repository:
  base_sha:
  target_branch:
  goal:
  approved_scope:
  approval_reference:
  protected_paths:
  current_actual_state:
  affected_files:
  acceptance_criteria:
  tests:
  godot_authoring_boundary:
  rollback:
  required_post_build_review:
```

Codex도 실제 repo/project/Godot 상태를 다시 읽는다.
GPT의 예상 상태를 사실로 가정하지 않는다.

---

## 27. 다층 검증

### 27.1 Contract

- 승인 목표
- 범위
- 보호 대상
- 실제 diff
- 책임 원본

### 27.2 Reference freshness

- 정본 변경
- active consumers
- untouched consumers
- Registry
- Template
- Test
- generated derivative
- manifest/hash

### 27.3 Static

- syntax
- schema
- import
- path
- ID
- data
- asset provenance

### 27.4 Runtime

- startup
- main scene
- interaction
- error path
- save/load
- clean import

### 27.5 UI / Accessibility

- input
- focus
- text
- resolution
- motion
- alternate path

### 27.6 Performance

적용되는 변경에서:

- frame time
- CPU/GPU
- memory
- loading
- network
- mobile thermal

### 27.7 Human/Player

BCP-020 증거층을 별도로 기록한다.

### 27.8 Regression

대표 정상·경계·반례·기존 기능.

---

## 28. 적대적 검토 루프

기본:

```text
attack
→ validate-critique
→ refine-approved-findings
→ regression-recheck
→ decision-report
```

저장소 전체 감사:

```text
repository-scope-map
→ canonical-authority-map
→ full-file-inventory
→ stale-and-duplicate-attack
→ untouched-consumer-attack
→ derivative-and-prompt-drift-attack
→ validate-critique
→ legacy-classification
→ approved-minimal-fix
→ regression-and-freshness-recheck
```

### 28.1 단계별 중요 Skill/프로세스 적용

각 주요 단계에서 필요에 따라 다음을 실제로 적용하고 실행 보고에 남긴다.

```text
brainstorming / design exploration
→ planning / writing-plans
→ TDD
→ systematic debugging when failure appears
→ adversarial review
→ critique validation
→ code/document review
→ verification-before-completion
→ post-merge reconciliation
```

Superpowers 등 외부 프레임워크는 `EXTERNAL_PROCESS_OVERLAY`로 기록한다.
Skill을 단순히 읽은 것과 실제 적용한 것을 구분한다.

### 28.2 1인 개발용 GPT 역할 분리 검토 — v4.4 보호 계약

별도의 인간 독립 리뷰어가 없을 때도 구현자 설명을 그대로 성공 증거로 사용하지 않는다.

```text
GPT REVIEWER ROLE
+ USER PLANNING DECISION AUTHORITY
+ OBJECTIVE TEST / CI / GODOT / SHA EVIDENCE
```

새 검토 패킷을 구성한다.

```yaml
gpt_role_separated_review:
  requirements_or_plan:
  decision_ids: []
  approval_reference:
  base_sha:
  head_sha:
  changed_file_inventory: []
  protected_contracts: []
  tdd_evidence:
  test_commands_and_results:
  godot_runtime_evidence:
  windows_android_evidence:
  visual_asset_audio_acceptance:
  known_deferred_items: []
  implementer_claims: LABELED_NOT_INDEPENDENT_EVIDENCE
```

규칙:

- 같은 GPT가 구현과 리뷰를 모두 수행할 수 있으므로 완전한 독립 리뷰라고 과장하지 않는다.
- 구현 이유를 방어하기보다 요구·diff·정본·객관 증거를 공격한다.
- 이전 답변의 “성공” 선언보다 GUT·CI·Godot 로그·현재 SHA를 우선한다.
- 사실 / 추론 / 권장안을 분리한다.
- 새 기획 P0/P1 충돌은 Grill Me로 사용자에게 올린다.
- 현재 대화의 자동 병합 승인은 **이미 승인된 범위의 병합 권한**이지 새 기획 충돌의 자동 승인 권한이 아니다.

완료 상태:

```text
GPT_ROLE_REVIEW_COMPLETE
USER_DECISION_COMPLETE_OR_NOT_REQUIRED
OBJECTIVE_TEST_EVIDENCE_COMPLETE
```

**항상 확인할 공격 대상:**

```text
왜곡
충돌
누락
오래된 가정
중복
권위 역전
untouched consumer
불필요한 복잡성
보완 가능성
더 나은 현업 대안
플레이어 경험 증거 과장
```

필수 공격 렌즈:

### 요구·정본
- 핵심 내용 누락
- Decision 부활
- 중복 정본
- 오래된 prompt가 current authority처럼 작동

### 구조·데이터
- 중복 시스템
- schema drift
- save/config 호환성
- 고아 참조

### 플레이어 경험
- 행동 목적 모호
- 첫 선택/결과 부재
- 비용·위험·보상 오해
- 자동 증거로 사람 경험을 과장

### UI·접근성
- 오류/빈 상태
- focus
- 입력
- 해상도
- CJK
- motion

### 자산·권리
- Draft 최종화
- provenance
- license
- IP imitation
- local absolute path

### Godot·플랫폼
- clean import
- startup
- export
- Android lifecycle
- merged-main runtime

### Git·CI·보안
- 승인 범위 밖 diff
- credential/cache
- immutable Action pin
- least privilege
- Required Check target
- strict up-to-date
- unresolved thread
- main movement during review

### 외부 Process Overlay
- overlay가 canon을 덮어쓰는가
- 같은 승인을 다시 요구하는가
- Base Gate를 약화하는가
- 읽은 Skill을 실행했다고 허위 보고하는가

---

## 29. GitHub Actions·CI

public repository에서 standard GitHub-hosted runner는 `REMOTE_CI` 기본이다.

비용 절감:

```text
테스트 삭제 X
→ change risk classification
→ duplicate run cancellation
→ selective expensive dependency
→ single stable ci-gate
```

공급망:

```text
uses: owner/action@<reviewed full-length SHA>
least-privilege permissions
fork / pull_request_target / secret trust boundary review
```

Base current main이 Action pin의 정본이다.
이 thin adapter에 checkout/setup-node SHA를 복제하지 않는다.

---

## 30. Base Repository Setting 정합성 상태

v4.5 작성 시 Base에서 확인된 상태:

```yaml
base_repository_governance:
  protected_ruleset:
    name: solo-main-safety
    required_check: ci-gate
    protected_merge_method: squash
  repository_level_observed:
    squash: enabled
    merge_commit: enabled
    rebase: enabled
  desired_defense_in_depth:
    squash: enabled
    merge_commit: disabled
    rebase: disabled
  tracking_issue: "https://github.com/alsdmlals4-eng/Base/issues/277"
  live_setting_write_status: BLOCKED_UNVERIFIED
```

Issue #277이 해결되기 전에는 repository-level merge/rebase가 꺼졌다고 주장하지 않는다.

이 차이는 Base의 protected Ruleset이 현재 squash를 강제한다는 사실과 별개다.

---

## 31. exact validation target / strict up-to-date

병합 전:

```text
current PR head
current base main
merge-base
test merge / merge queue if applicable
required ci validation target
```

를 다시 읽는다.

**중요**

검증 중 `main`이 전진하면:

```text
OLD GREEN != CURRENT GREEN
```

strict up-to-date 정책을 우회하지 않는다.

```text
new main read
→ conflict/consumer comparison
→ rebase/reconstruct
→ adversarial diff
→ new exact validation
→ ci-gate
→ merge
```

---

## 32. Open/Draft PR 전체 감사와 변경 단위

### 32.1 작업 시작·배치 종료·병합 후 Open/Draft PR 전체 확인

현재 프로젝트의 **모든 Open/Draft PR**을 조회한다.
same-goal PR만 보는 것으로 끝내지 않는다.

각 PR에 대해:

```yaml
pr_audit:
  number:
  title:
  draft_or_open:
  purpose:
  changed_scope:
  base_sha:
  head_sha:
  current_main_compatibility:
  duplicate_or_overlap:
  proposal_only:
  reference_only:
  do_not_merge:
  ci_status:
  required_check:
  unresolved_threads:
  adversarial_findings:
  user_approval_scope:
  risk:
  disposition:
```

Disposition:

```text
MERGE_ELIGIBLE
SYNC_WITH_MAIN_THEN_REVERIFY
KEEP_OPEN_WITH_REASON
PROPOSAL_ONLY_DO_NOT_MERGE
REFERENCE_ONLY_DO_NOT_MERGE
BLOCKED_VALIDATION
SUPERSEDED_CLOSE
STALE_CLOSE
USER_DECISION_REQUIRED
```

### 32.2 자동 병합 가능 PR

다음을 모두 만족하면 최신 main과 동기화하고 검증한 뒤 병합한다.

- 이미 사용자 승인 범위
- 저위험
- 목적·변경 범위가 명확
- current main 충돌 없음
- 중복 PR 아님
- 모든 필수 검증 PASS
- exact current validation target PASS
- 적대적 검토 P0/P1 없음
- unresolved thread 없음
- proposal-only/reference-only/DO_NOT_MERGE 아님

### 32.3 병합 금지 PR

다음은 자동 병합하지 않는다.

- proposal-only
- reference-only
- `DO_NOT_MERGE`
- 증거 수집용 보존 PR
- 검증 부족
- stale base인데 재검증 안 됨
- 승인 범위 밖
- 중요한 충돌 미승인
- protected behavior 침범

이유와 후속 조치를 기록한다.

### 32.4 병합 후 재감사

한 PR을 병합한 뒤:

```text
new main reread
→ all remaining Open/Draft PR reread
→ base drift
→ stale/duplicate/superseded
→ cleanup
→ required follow-up
```

### 32.5 PR 변경 단위

Google의 small change 관행과 Base의 하나의 Goal/활성 PR 원칙을 참고한다.

하나의 PR은 가능한 한:

```text
한 독립 문제
한 승인/rollback 경계
관련 regression
```

을 갖는다.

다음을 섞지 않는다.

- unrelated dependency update
- formatting/BOM cleanup
- 별도 policy
- unrelated refactor
- 새 사용자 결정

---

## 33. 병합 후

병합 성공 응답만 믿지 않는다.

```text
new main SHA
→ merged files reread
→ current decisions
→ affected canon
→ consumers/tests
→ open/recent PRs
→ branch cleanup
→ applicable Sheet readback
→ post-merge adversarial review
```

실행하지 않은 branch cleanup을 완료라고 보고하지 않는다.

---

## 34. 로컬 전달

사용자 로컬 정상 경로:

```text
GitHub Desktop
→ Fetch origin
→ Pull origin
→ local main SHA 확인
→ Godot
→ Run Project
```

dirty/diverged 상태에서 force/reset으로 덮지 않는다.

---

## 35. Godot Project Play 완료 Gate

개별 Scene 실행만으로 완료하지 않는다.

필수:

```text
application/run/main_scene
→ startup
→ 대표 문제
→ 대표 행동
→ 첫 선택
→ 첫 결과
→ 성공/실패
→ 복귀 또는 다음 흐름
```

가능하면 Windows·Android 각 delivery profile에서 확인한다.

### 35.1 완성형 Vertical Slice 기준 — v4.4 보호 계약

Vertical Slice가 완료되려면 최소 다음이 실제로 연결되어야 한다.

```yaml
vertical_slice_complete:
  representative_problem:
  representative_player_action:
  meaningful_choice:
  system_response:
  first_result:
  success_failure_or_resolution:
  feedback_and_reward:
  return_or_next_flow:
  save_or_state_continuity_when_applicable:
  windows_run:
  android_run_or_explicit_not_run:
  tech_evidence:
  ui_evidence:
  human_usability_evidence:
  player_experience_evidence:
```

개별 Scene·기능·mock 화면만 동작하는 상태는 Vertical Slice 완료가 아니다.

### 35.2 로컬 접근이 없는 에이전트

사용자 Windows 로컬에는 접근할 수 없지만 GitHub에는 접근 가능한 경우:

1. 원격 조사·PR·CI·병합·merged-main readback까지만 실제 수행한다.
2. 로컬 Fetch/Pull·PowerShell·Godot 실행을 했다고 주장하지 않는다.
3. `LOCAL_SYNC_BLOCKED_NO_LOCAL_ACCESS`, `GODOT_RUN_BLOCKED_NO_LOCAL_ACCESS`를 기록한다.
4. 정확한 사용자 작업 명령·기대 SHA·성공 판정을 **최종 User Action Required 섹션에 모아** 제공한다.
5. 사용자가 결과를 제공하면 그 증거로 후속 판정을 한다.

---

## 36. Base 승격

프로젝트에서 발견한 재사용 후보:

```text
project evidence
→ function-level classification
→ repeated/generalizable pattern
→ [수정제안서]/BCP - [프로젝트명] project-source proposal
→ evidence pack
→ proposal/index registration
→ proposal PR
→ review/approval
→ separate approved Base implementation PR when active rules must change
→ Base Registry change only when that implementation is separately authorized
→ Base tests / freshness / adversarial review
→ merge
```

### 36.1 프로젝트 출처형 BCP 규칙

수정제안서를 작성할 때 **Base 활성 규칙을 proposal 단계에서 직접 건드리지 않는다.**

권장 구조:

```text
[수정제안서]/
└─ BCP - [프로젝트명] - [개선주제]/
   ├─ PROPOSAL.md
   └─ evidence/
      ├─ PROJECT_VALIDATION.md
      ├─ BEFORE_AFTER.md
      ├─ COUNTEREXAMPLES.md
      └─ TRACEABILITY.md
```

```yaml
bcp_project_source:
  source_project:
  source_decision_ids: []
  source_commits_or_prs: []
  problem_observed:
  validated_improvement:
  evidence:
  reusable_boundary:
  project_specific_values_removed:
  existing_base_owner:
  conflict_analysis:
  proposed_absorption:
  rollback:
```

### 36.2 “Registry 등록”의 충돌 방지 해석

`Base 활성 규칙은 건드리지 않는다`와 `Registry 등록 → PR → 검증 → 병합`을 동시에 만족시키기 위해 다음을 구분한다.

```text
PROPOSAL PHASE
→ BCP proposal/index/registry 성격의 등록
→ [수정제안서] 범위
→ active Skill/Rule Registry 변경 금지

APPROVED IMPLEMENTATION PHASE
→ 별도 승인 reference
→ 필요한 경우 active skills/SKILL_REGISTRY.json 또는 owner 변경
→ 별도 implementation PR
→ TDD/freshness/adversarial/ci-gate
→ merge
```

즉 proposal-only PR에서 active `skills/SKILL_REGISTRY.json`을 미리 바꾸지 않는다.
현재 Base의 BCP 프로토콜이 별도 proposal registry/index를 제공하면 그것을 사용한다.
그런 surface가 없으면 proposal 안에 registration metadata를 남기고 active Registry는 구현 PR까지 기다린다.

proposal 등록과 active Base 구현을 같은 단계로 합치지 않는다.

프로젝트 고유 값·경로·아트를 Base에 승격하지 않는다.

---

## 37. Skill 변화·부분 흡수

### 37.1 전체 Skill을 가져오지 않아도 부분 흡수

외부/프로젝트 Skill을 검토할 때 “전체 채택 또는 전체 거부” 이분법을 금지한다.

흡수 후보:

- 특정 mode
- review lens
- checklist
- test pattern
- failure classification
- prompt 구조
- reference 문서
- evidence schema
- debugging step
- tool integration pattern

```yaml
skill_absorption:
  source_skill_or_framework:
  feature_or_function:
  source_license_or_usage_boundary:
  classification:
  reusable_part:
  rejected_part:
  target_existing_base_skill_or_doc:
  why_partial_absorption_is_better:
  regression_needed:
```

기존 Base owner에 자연스럽게 흡수되면 새 Skill을 만들지 않는다.

### 37.2 기능 단위 분해·상태 분류

Skill·기능·규칙·문서·workflow를 다음처럼 **기능 단위**로 쪼갠다.

```text
ALREADY_INTEGRATED
CURRENTLY_VALID
CONFLICTING_OR_OUTDATED
PARTIALLY_REUSABLE
MISSING_AND_NEEDED
DEFERRED_WITH_REASON
```

| 기능 단위 | 현재 Base/프로젝트 위치 | 상태 | 충돌/구형 이유 | 흡수/유지/제거 권장 | 증거 |
|---|---|---|---|---|---|
|  |  |  |  |  |  |

### 37.3 새 Skill 후보

```text
existing Skill mode/ref로 해결 가능
→ 통합/부분 흡수

독립 reusable input/output/authority/validation boundary 존재
→ 새 Skill 후보
```

Skill 숫자 목표는 없다.

---

### 37.4 최적 작업에 필요한 요소가 없을 때

최적 작업에 필요한 핵심 요소가 없으면 **해당 의존 단계는 중단**한다.
그러나 독립적으로 진행 가능한 조사·기획·검토까지 불필요하게 멈추지 않는다.

```yaml
missing_requirement:
  item:
  why_needed:
  benefit_if_available:
  can_gpt_resolve_directly:
  safe_auto_install_or_config_possible:
  dependent_stage_blocked:
  independent_work_can_continue:
  user_action_required:
  exact_steps:
  verification_after_action:
```

원칙:

1. GPT가 현재 권한·도구로 안전하게 해결 가능하면 직접 해결한다.
2. 사용자만 할 수 있는 설치·로그인·권한·로컬 UI 조작이면 dependent stage를 `BLOCKED_USER_ACTION`으로 둔다.
3. 사용자 요청은 가능하면 현재 응답의 **마지막 `User Action Required`**에 모은다.
4. 보안·데이터 손실·과금·법률 위험 때문에 즉시 확인이 필요한 경우만 즉시 중단·질문한다.
5. 예: GitHub CLI가 없으면 왜 필요한지, 설치 시 장점, 공식 설치 방법, `gh --version` / `gh auth status` 확인법을 제공한다.
6. 설치가 “있으면 좋은 것”인지 “없으면 진행 불가”인지 구분한다.

## 38. 증거 Manifest

```yaml
evidence_manifest:
  base:
    current_main_sha:
    registry_read:
    selected_skills: []
    executed_skill_modes: []
    external_process_overlay:

  project:
    repository:
    base_sha:
    head_sha:
    approval_reference:
    decisions: []
    protected_items: []

  planning:
    core_game_model:
    requirement_traceability:
    benchmark_sources: []
    professional_comparisons: []
    existing_solution_disposition:
    grill_me_decisions: []
    grill_me_batch_checkpoint:
    planning_complete_user_declaration:
    final_planning_review:

  implementation:
    phase: GPT_PLANNING | FINAL_REVIEW | POWERSHELL_CODEX_BUILD
    powershell_codex_command:
    powershell_approval_prompts_used:
    fresh_execution_identity:
    changed_files: []
    tests_red:
    tests_green:
    runtime:

  player_experience:
    TECH_EVIDENCE:
    UI_EVIDENCE:
    HUMAN_USABILITY_EVIDENCE: NOT_RUN
    PLAYER_EXPERIENCE_EVIDENCE: NOT_RUN
    first_session:
    decision_screen:
    minigame_gate:

  assets:
    images:
    audio:
    provenance:
    asset_vault:
    local_reference_library:

  godot:
    version:
    higodot:
    gut:
    hera:
    clean_import:
    application_run_main_scene:
    project_play:
    tracked_source_delta_after_qa:

  platforms:
    windows:
    android:
    build_size:

  github:
    open_draft_pr_inventory:
    pr:
    review_head_sha:
    base_sha:
    ci_validation_target_sha:
    required_check:
    unresolved_threads:
    strict_up_to_date:
    merge_commit:
    new_main_sha:
    branch_cleanup:

  sheet:
    decision_sync:
    reread:

  skill_absorption:
    function_classification:
    partial_absorptions: []

  blockers:
    user_action_required: []

  local_delivery:
    fetch:
    pull:
    local_main_sha:
    godot_run:
```

---

## 39. 완료 판정

최상위 성공은 다음처럼 단계별 증거가 있어야 한다.

```text
BASE_CURRENT_AUTHORITY_RECOVERED
→ PROJECT_STATE_RECONCILED
→ PLANNING_COMPLETE
→ DECISIONS_SYNCED
→ IMPLEMENTATION_COMPLETE
→ TECH_EVIDENCE_RECORDED
→ UI_EVIDENCE_RECORDED_WHEN_APPLICABLE
→ HUMAN/PLAYER_EVIDENCE_RECORDED_OR_EXPLICIT_NOT_RUN
→ ADVERSARIAL_REVIEW_COMPLETE
→ EXACT_CURRENT_VALIDATION_TARGET_PASSED
→ CI_GATE_PASSED
→ MERGED_MAIN_VERIFIED
→ POST_MERGE_RECHECK_COMPLETE
→ LOCAL_SYNCED_OR_EXPLICIT_BLOCKED
→ PROJECT_PLAY_VALIDATED_OR_EXPLICIT_BLOCKED
```

`NOT_RUN`을 숨기지 않는다.

---

## 40. 실패 조건

다음 중 하나라도 있으면 완료를 선언하지 않는다.

### Base·권위

- instruction 작성 요청인데 실제 Base/프로젝트 작업까지 실행
- Base current main 재조회 없음
- recursive inventory 또는 미검증 범위 표시 없음
- Registry 없이 임의 Skill 선택
- v4.5의 snapshot을 영구 current authority로 사용
- v4.5의 Base 절차 복사본을 current Base보다 우선

### External Process

- 외부 process overlay가 project/Base canon을 덮어씀
- overlay가 안전 Gate를 약화
- 같은 승인 범위를 재승인 요구
- Skill을 읽기만 했는데 실행했다고 보고
- `OVERLAY_CONFLICT`를 숨김

### 프로젝트·기획

- PHASE A/B 완료 전에 PowerShell/Codex/Godot BUILD 시작
- 사용자 “기획 완료” 선언 없이 구현 단계 진입
- 핵심 요구 추적 누락
- 프로젝트 코어/핵심 재미 복원 없음
- benchmark 없이 중요한 권장안 확정
- 출처 사실과 추론 혼합
- Planning conflict를 사용자 승인 없이 결정
- 10개 Decision 최대 배치/early checkpoint 무시
- Grill Me에 벤치마킹·현업 비교가 필요한데 근거 없이 선택지 제시
- 승인 Decision을 GitHub 정본·계획 데이터·연결 Sheet에 가능한 즉시 동기화하지 않음
- 같은 Decision ID 연결 누락

### BCP-020 경험

- 자동 test/UI render로 HUMAN_USABILITY PASS 주장
- 사람 관찰 없이 PLAYER_EXPERIENCE PASS 주장
- 첫 세션에 대표 문제/행동/선택/결과/다음 질문 없음
- decision screen에서 비용·위험·결과가 읽히지 않음
- 코어 퍼즐/전투를 부당하게 minigame으로 강등

### PowerShell·Codex·Godot

- 사용자 지정 기본 Codex command 검증 없이 임의 변형
- PowerShell 사용자 승인 프롬프트를 불필요하게 2개 초과 생성
- `-a never` 운영인데 Codex 내부 approval 의존 workflow 설계
- 이전 PowerShell/Codex/Godot session/PID를 다음 블록의 current truth로 사용
- Godot 버전 추측
- HiGodot 채택 계약을 우회한 persistent authoring
- GUT 0 test discovery를 성공 처리
- Hera QA 후 tracked source delta 존재
- clean import 미검증
- actual main scene 실행 없음

### 자산

- Draft/placeholder 최종화
- provenance/license 미검증
- shared audio 원본 무단 변경
- 외부 절대 경로 production dependency
- local-only asset 후보가 tracked production 참조

### CI·PR

- 작업 시작/배치 종료/병합 후 모든 Open/Draft PR 감사 누락
- proposal-only/reference-only/DO_NOT_MERGE PR 자동 병합
- stale/duplicate PR 후속 정리 누락
- mutable Action tag/branch를 고위험 workflow에서 사용
- 과도한 `GITHUB_TOKEN` 권한
- Required Check 실패/미실행
- wrong SHA 검증
- strict up-to-date 우회
- unresolved thread
- Draft 상태인데 merge ready 주장
- `main` 이동 후 이전 GREEN으로 병합
- 승인 범위 밖 diff
- adversarial finding 미해결

### 병합 후

- 새 main readback 없음
- affected canon/consumer 재검토 없음
- 안전조건 없는 branch 삭제
- dirty/diverged local을 force/reset
- 사용자가 받을 수 없는 로컬 상태를 “전달 완료”로 주장

---

## 41. 최종 보고 형식

```markdown
# 최종 작업 보고

## 1. 작업 대상
- Base main:
- Project:
- Approved scope:
- Approval reference:
- Work Mode:

## 2. Base 라우팅
- Registry:
- Selected Skills:
- Executed modes:
- External process overlay:
- Read-only vs actually executed:

## 3. 프로젝트 복원
- Current decisions:
- Actual implementation:
- Sheet:
- Entry reconciliation:

## 4. 기획
- Planning phase:
- User planning-complete declaration:
- Requirement traceability:
- Goal:
- Pointed fun:
- Core loop:
- Core/support systems:
- Benchmark:
- Existing Solution First:
- Grill Me decisions:
- Grill Me batch checkpoint:
- Canon/Sheet Decision sync:
- Final planning review:

## 5. 플레이어 경험
- TECH_EVIDENCE:
- UI_EVIDENCE:
- HUMAN_USABILITY_EVIDENCE:
- PLAYER_EXPERIENCE_EVIDENCE:
- First session:
- Decision screen:
- Minigame narrative function:

## 6. Visual / Asset / Audio
- Visual Requirement:
- Asset Vault:
- Reference Library:
- Shared Audio:
- Provenance:

## 7. Godot
- Version:
- HiGodot:
- GUT:
- Hera:
- Clean import:
- Main scene:
- Project Play:

## 8. Windows / Android
- Shared core:
- Platform adapters:
- Size:
- Performance:

## 9. 변경
- PowerShell/Codex execution command:
- Manual approval prompts used:
- Fresh execution identity:
- Files:
- Protected items preserved:

## 10. TDD / 검증
- RED:
- GREEN:
- Static:
- Runtime:
- Accessibility:
- Performance:
- Regression:
- NOT_RUN:

## 11. 적대적 검토
- Attack findings:
- Validated:
- Rejected critiques:
- Fixed:
- Remaining:

## 12. GitHub
- All Open/Draft PR audit:
- PR:
- Review head:
- Base:
- CI target:
- ci-gate:
- Threads:
- Merge:
- New main:
- Branch cleanup:

## 13. Sheet / 정본
- Decision sync:
- Canon readback:
- Sheet readback:

## 14. 로컬 전달
- Fetch:
- Pull:
- Local main:
- Godot Run:

## 15. Base 승격·Skill 변화
- Project-source BCP:
- Proposal registry/index:
- Active Registry mutation:
- Feature-level classification:
- Partial Skill absorptions:
- Skill consolidation/new Skill:
- Follow-up:

## 16. User Action Required
- 사용자만 가능한 작업:
- 왜 필요한가:
- 정확한 단계/명령:
- 기대 결과:
- 완료 후 제공할 증거:

## 17. 최종 판정
PASS | PASS_WITH_FOLLOWUP | BLOCKED_UNVERIFIED | REVISE
```

---

## 42. Base 정본 링크

이 파일은 아래 내용을 복제하지 않고 current Base를 직접 읽는다.

```text
https://github.com/alsdmlals4-eng/Base/blob/main/START_HERE.md
https://github.com/alsdmlals4-eng/Base/blob/main/AGENTS.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/OPERATING_MODEL.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/WORK_MODE_AND_SKILL_ROUTING.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/DOCUMENTATION_MAP.md
https://github.com/alsdmlals4-eng/Base/blob/main/skills/SKILL_REGISTRY.json
https://github.com/alsdmlals4-eng/Base/blob/main/docs/generated/BASE_ACTIVE_SKILLS.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/CAPABILITY_COMPOSITION_MAP.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/knowledge/game-development/GAME_DESIGN_AND_PLAYER_EXPERIENCE_GUIDE.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/CONFIRMED_DECISION_SYNC_POLICY.md
https://github.com/alsdmlals4-eng/Base/blob/main/docs/GITHUB_PRO_OPERATING_POLICY.md
```

필요 Skill은 Registry로 찾는다.

주요 역할 예:

```text
managing-project-intake-and-work-contract
running-adversarial-review-and-refinement
auditing-canonical-reference-freshness
reviewing-and-validating-project-changes
evaluating-godot-assets-and-plugins-before-creation
diagnosing-game-engine-runtime-failures
maintaining-project-context-and-handoff
managing-base-change-proposals
```

목록은 예시일 뿐 current Registry를 대체하지 않는다.

---

## 43. v4.4 → v4.5 Migration

v4.5가 의도적으로 제거한 것:

```text
Base Skill별 세부 절차의 대량 복제
Base current Action SHA 복제
Base 현재 Skill 수를 설계 계약으로 고정
Base 정책 문서의 장문 재서술
과거 Base snapshot을 current truth로 사용
```

v4.5가 보존한 것:

```text
프로젝트 입력/경로
Windows/Android 공용 코어
HiGodot/GUT/Hera 역할
Asset/Reference/Audio Vault
Planning First
Existing Solution First
Grill Me conflict approval
10 Decision batch
TDD
on-demand Codex
exact validation target
merge authority inheritance
main readback
Fetch/Pull local handoff
Project Play
adversarial review
Base BCP promotion
```

v4.5가 추가한 것:

```text
GPT_CHAT_PLANNING_COMPLETE_BEFORE_POWERSHELL_CODEX_GODOT_BUILD
GRILL_ME_10_MAX_BATCH_CLOSE_AND_PLANNING_PR
CURRENT_CONVERSATION_AUTO_MERGE_APPROVAL
OPEN_DRAFT_PR_FULL_INVENTORY
POWERSHELL_CODEX_FULL_AUTO_WITH_MAX_2_MANUAL_APPROVAL_GATES
PROJECT_SOURCE_BCP_PROPOSAL
PARTIAL_SKILL_ABSORPTION
FUNCTION_LEVEL_VALIDITY_CLASSIFICATION
USER_ACTION_REQUIRED_AT_END
EXTERNAL_PROCESS_OVERLAY
BCP-020 evidence separation
FIRST SESSION representative experience
DECISION SCREEN comprehension
MINIGAME narrative function gate
Base repository-setting drift Issue #277 visibility
thin-adapter authority rule
```

### 43.1 v4.4 대비 명시 복원 확인

v4.4에서 독립 섹션이었으나 초기 v4.5 Thin Adapter에서 축약됐던 다음 프로젝트 고유 계약을 다시 명시했다.

```text
핵심 요구 추적표
구현 원칙·작업 유형별 TDD
완성형 Vertical Slice 기준
GPT/Codex/객관 증거 역할 분리
로컬 접근 불가 시 행동
```

이 복원은 Base current canon을 복제하기 위한 것이 아니라 프로젝트의 실행·증거·전달 경계를 보존하기 위한 것이다.

### 43.2 이번 v4.5 revision 반영 검증표

| 요청/보호 항목 | 반영 위치 | 상태 |
|---|---|---|
| 기획 우선 | 0.2, 8.1 | `PASS` |
| 상세 수치 GPT 권장안 | 8.2 | `PASS` |
| 기획 충돌 Grill Me 승인 | 8.2, 11 | `PASS` |
| Grill Me 최대 10건 + 조기 체크포인트 | 11.3 | `PASS` |
| 10건 배치마다 정본/Sheet/PR/적대적 검토 | 11.2~11.3 | `PASS` |
| Grill Me·작업 시 벤치마킹/현업 비교 | 9, 11.1 | `PASS` |
| 작업마다 TDD | 25 | `PASS` |
| 현재 대화 승인 범위 자동 병합 | 12.0 | `PASS` |
| GitHub 정본·계획 데이터·Google Sheet 같은 Decision ID | 11.2 | `PASS` |
| 브레인스토밍·Superpowers·적대적 검토 | 3, 28.1 | `PASS` |
| 사용자 행동 전용 blocker를 마지막에 요청 | 37.4, 최종 보고 | `PASS` |
| GPT가 직접 해결 가능하면 직접 해결 | 26.3, 37.4 | `PASS` |
| PowerShell Codex 기본 command | 26.1 | `PASS` |
| 사용자 수동 승인 최대 2회 | 26.2 | `PASS` |
| PowerShell/Codex/Godot fresh-session 재시작 | 26.4 | `PASS` |
| 프로젝트 출처형 BCP | 36.1 | `PASS` |
| proposal 단계 Base 활성 규칙 미변경 | 36.1~36.2 | `PASS` |
| Open/Draft PR 전체 감사 | 32 | `PASS` |
| proposal/reference/DO_NOT_MERGE 보호 | 12.0, 32.3 | `PASS` |
| Skill 부분 흡수 | 37.1 | `PASS` |
| 기능 단위 상태 분류 | 37.2 | `PASS` |
| 최적 작업 요소 누락 시 blocker | 37.4 | `PASS` |
| GPT 기획 완료 선언 후에만 local BUILD | 0.2, 26 | `PASS` |
| v4.4 핵심 요구 추적표 | 7.1 | `PASS` |
| v4.4 작업 유형별 TDD/구현 원칙 | 25 | `PASS` |
| v4.4 Vertical Slice 완료 기준 | 35.1 | `PASS` |
| v4.4 GPT 역할 분리·객관 증거 | 28.2 | `PASS` |
| v4.4 로컬 접근 불가 행동 | 35.2 | `PASS` |

의도적으로 복원하지 않은 것은 Base current canon의 장문 복제·과거 Action SHA·고정 Skill 수처럼 Thin Adapter 원칙과 충돌하는 내용뿐이다.
그 항목들은 **누락이 아니라 current Base 재조회로 대체**한다.

---

## 44. 최종 원칙

```text
이 지시문을 업데이트하는 요청에서는 지시 범위를 넘어 실제 프로젝트 작업을 실행하지 않는다.
Base는 매번 current main에서 다시 읽는다.
이 파일은 Base의 복제 정본이 아니라 프로젝트 Thin Adapter다.
GPT 채팅에서 기획을 모두 닫고 사용자가 “기획 완료”를 선언한 뒤 최종 검수를 끝내기 전에는 PowerShell/Codex/Godot BUILD를 시작하지 않는다.
상세 데이터 수치는 GPT 권장안+범위+벤치마킹으로 진행하되 기획 충돌은 Grill Me 승인 없이는 확정하지 않는다.
Grill Me는 10건을 최대 배치로 하고 고위험·세션 종료·정본 영향이 크면 조기 체크포인트를 허용한다.
각 승인 배치의 Decision은 같은 ID로 GitHub 정본·계획 데이터·연결 Sheet에 즉시 동기화하고 planning PR 검수·적대적 검토까지 닫는다.
모든 작업은 TDD/test-first로 진행한다.
현재 대화에서 이미 승인된 동일 범위 PR은 모든 Gate 통과 후 별도 병합 승인 없이 자동 병합한다.
모든 Open/Draft PR을 작업 시작·배치 종료·병합 후 재감사한다.
PowerShell/Codex 기본은 `codex.cmd -a never -s workspace-write`이며 사용자 수동 승인 프롬프트는 최대 2개로 억제한다.
PowerShell/Codex/Godot 실행 블록이 끝나면 세션을 닫고 다음 블록은 fresh-read부터 다시 시작한다.
수정제안서는 Base 활성 규칙을 proposal 단계에서 건드리지 않고 `[수정제안서]/BCP - [프로젝트명]` 출처형 evidence proposal로 시작한다.
Skill은 전체 채택만 보지 않고 기능·mode·checklist·reference 단위의 부분 흡수를 적극 검토한다.
모든 기능은 이미 반영됨 / 현재에도 유효 / 충돌·구형 / 부분 재사용 / 누락 필요로 분해해 판정한다.
최적 작업에 필요한 요소가 없으면 GPT가 직접 해결 가능한지 먼저 판단하고, 사용자만 가능한 blocker는 마지막 User Action Required에 정확한 조치로 모은다.
Registry로 필요한 Skill만 선택하고, 읽은 Skill과 실행한 Skill을 구분한다.
외부 process framework는 EXECUTION_PROCESS_ONLY이며 project/Base canon을 소유하지 않는다.
같은 승인 범위는 REUSED_APPROVAL로 진행하고 기술 재검증 때문에 재승인받지 않는다.
Planning은 구현보다 먼저 닫고 중요한 충돌만 Grill Me로 올린다.
벤치마킹은 공식·현업 근거를 사용하되 프로젝트 정본을 대체하지 않는다.
기존 해법을 먼저 조사하고 BUILD_NEW를 기본값으로 두지 않는다.
TECH, UI, HUMAN_USABILITY, PLAYER_EXPERIENCE 증거는 서로 대체하지 않는다.
사람을 관찰하지 않았으면 HUMAN/PLAYER evidence는 NOT_RUN이다.
첫 세션은 대표 문제→행동→선택→결과→다음 질문의 압축판이다.
핵심 결정 화면은 상황·선택·필요정보·비용/위험/결과를 읽을 수 있어야 한다.
코어 인터랙션을 미니게임으로 강등하지 않는다.
Visual Requirement와 Asset Vault 승인은 분리한다.
HiGodot은 채택된 프로젝트에서 persistent Godot authoring의 단일 권위다.
GUT은 deterministic GDScript test 권위이며 production을 저작하지 않는다.
Hera는 live QA/observability만 수행하고 tracked source delta를 남기지 않는다.
Windows와 Android는 하나의 게임 로직·데이터 코어를 공유한다.
public repo의 standard GitHub-hosted Actions는 예산 0이어도 REMOTE_CI 기본이다.
Actions는 reviewed full-length SHA와 least privilege를 사용한다.
검증 중 main이 움직이면 이전 GREEN을 재사용하지 않고 current base에서 재검증한다.
Required ci-gate와 unresolved thread, strict up-to-date를 우회하지 않는다.
병합 성공은 new main readback으로 확인한다.
사용자 로컬 전달은 Fetch origin→Pull origin 중심으로 유지한다.
실행하지 않은 조사·Skill·test·Godot·기기·사람 검증을 실행했다고 말하지 않는다.
```
