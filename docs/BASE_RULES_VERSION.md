# Base Rules Version

## 현재 선택 채택 — 2026-09-20

사용자가 승인한 프로젝트 네이티브 경량화 및 같은 작업의 재미 검증 추가 요청을 적용한다.
실행 절차의 단일 owner는 [프로젝트 작업 계약](operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md),
읽기 경로는 [AGENTS](../AGENTS.md)와 [문서 지도](DOCUMENTATION_MAP.md)다.

| 구분 | 관찰·판정 |
|---|---|
| 이번 조사 시 Base main | `23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef`, #883 및 #885 포함 |
| 승인안 작성 때 Base main | `ebfc6c807a0d1582a2df27c518ef60398bf8486c`, #883 병합 확인 |
| 프로젝트 출발 main | `b5c2dd61cd589ebd218d1b4da3f016fb94a02126`; 과거 SHA는 관찰/검증 증거이지 향후 실행 기준이 아님 |
| ADAPT | 최소 조건부 읽기, 승인·조사 근거 재사용, 한 계약의 전체 검토 2회, 허용된 정상 PR 병합·readback, 경험 가설→규칙/표현→consumer→검증 |
| KEEP | 저장소 정본, 사용자/게임 결정 우선, 증거 구분, 자산 LOCK, 엔진/저장/권리/비용/PR 보호 |
| NOT_ADOPTED | 전체 Base adapter·Registry·생성 대시보드, 신규 플러그인·전역 설정, 자동 엔진 업데이트, 새 재미 감독/분석 서버 |

### 적용 source와 발견 경로

Base의 실제 원격 main을 다시 발견한 뒤 변경된 관련 owner만 비교한다. 아래 exact
commit 링크는 이번 적용 내용을 재현할 증거이며 이동하는 main이나 미래 version lock이 아니다.

- [#883 지침 경량화](https://github.com/alsdmlals4-eng/Base/pull/883)
- [#885 재미와 표현 명세 연결](https://github.com/alsdmlals4-eng/Base/pull/885)
- [Base AGENTS](https://github.com/alsdmlals4-eng/Base/blob/23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef/AGENTS.md), [START_HERE](https://github.com/alsdmlals4-eng/Base/blob/23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef/START_HERE.md)
- [통합 실행·경량화 §3](https://github.com/alsdmlals4-eng/Base/blob/23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef/docs/GPT_CODEX_WORKFLOW_POLICY.md), [전체 검토 예산](https://github.com/alsdmlals4-eng/Base/blob/23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef/docs/operations/FULL_ADVERSARIAL_REVIEW_LOOP_POLICY.md)
- [Intake](https://github.com/alsdmlals4-eng/Base/blob/23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef/skills/managing-project-intake-and-work-contract/SKILL.md), [운영체계 audit/reconcile/verify](https://github.com/alsdmlals4-eng/Base/blob/23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef/skills/managing-game-project-operating-system/SKILL.md)
- [재미 검증 생명주기](https://github.com/alsdmlals4-eng/Base/blob/23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef/skills/analyzing-and-refining-game-concepts/references/concept-evidence-and-gates.md#fun-verification-lifecycle)
- [경험→표현 가이드](https://github.com/alsdmlals4-eng/Base/blob/23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef/docs/knowledge/game-development/EXPERIENCE_TO_PRESENTATION_GUIDE.md), [프로젝트별 적용 §10–11](https://github.com/alsdmlals4-eng/Base/blob/23ecad5a3084f97c4e5d1e39a9a6d70d1eeb37ef/skills/auditing-and-refining-ui-art/references/project-adapter-contract.md)

### 호환성·검사 경계

- `docs/base-reuse-adoption.json`의 `8553678…`와 CI의 대응 검사는 과거 재사용 manifest 계약이다. 최신 Base 관찰 SHA로 바꾸지 않는다.
- `skills/PROJECT_BASE_ADAPTER.json`과 프로젝트 Skill Registry는 의도적으로 미도입이다. 외부 adapter validator가 없음을 실패로 보고해도 native 계약 검증 성공으로 포장하지 않으며 자동 설치하지 않는다.
- PR #147에는 9월 12일의 ‘5회 유지’ 선택과 별도 승인 게임 구현이 있다. 이번 사용자 승인은 운영 검토 예외를 대체하지만 그 PR을 변경·흡수·병합하지 않는다. 향후 해당 PR을 명시적으로 재개/통합할 때 최신 main의 운영 계약을 보존하고 게임 변경은 별도 비교한다.
- 기존 문구 고정 검사 대신 실제 정본 링크를 따라가며, 정적 경로 검사는 에이전트 준수·게임 실행·Human 재미 검증이 아니다.
- 전체 일괄 Base migration, 게임·자산 변경, 신규 재미 플레이테스트는 이번 채택의 완료 주장이 아니다.

이후 역사 절의 상태/규칙은 당시 기록이다. 현재 절과 충돌하면 이 절 및 프로젝트 작업
계약을 따른다. 상세 수행·검증·잔여 작업은 기존 [Active Context](ACTIVE_CONTEXT.md)에 누적한다.

## 목적

이 파일은 **Base 원격의 관찰/동기화 이력과 프로젝트가 선택 적용한 공용 작업 원칙**을 기록한다.

제품 규칙이나 현재 구현 상태의 1차 정본이 아니다.

- 제품 결정: `CURRENT_CONFIRMED_DECISIONS.md` + dated canon
- mutable resume state: `ACTIVE_CONTEXT.md`
- 문서/Notion authority: `DOCUMENTATION_MAP.md`
- implementation reality: actual code/data/Scene/tests + executed evidence

## 1. 프로젝트에 마지막으로 명시 동기화된 역사 기준

```yaml
base_repository: alsdmlals4-eng/Base
base_branch: main
historical_full_local_sync_commit: 499c20eb9b449241864f5ada0c915fba8a7806ac
historical_sync_date: 2026-07-10
```

위 SHA는 현재 Base 원격 HEAD가 아니다. 과거 full/local rule sync의 역사 기준만 보존한다.

## 2. Base remote observation history

### 2026-08-24 · T01 시기 관찰

```yaml
observed_base_main: 2828a74f60c1ed09546171040f4178c8848ea686
observation_scope: T01_SPATIAL_DATA_IMPLEMENTATION_AND_FOLLOWUP
full_base_rule_sync: NOT_RUN
selective_current_rule_read: PASS
```

이 관찰은 T01~T05 시기의 작업 provenance이며 현재 Base HEAD를 뜻하지 않는다.

### 2026-08-25 · Living GDD / Human Home 재정렬 시 fresh observation

```yaml
observed_base_main: 3c3376845b9a1b7921a4260aa6259cd61533ffc4
observed_at: 2026-08-25 KST
observation_reason: LIVING_GDD_VISUAL_DASHBOARD_AND_AI_WORKSPACE_ALIGNMENT
full_base_rule_sync: NOT_RUN
selective_current_rule_read: PASS
```

관찰한 Base HEAD의 merge message:

`fix: guard current Human Home contract in dashboard skill (#664)`

해당 current Base 변경은 프로젝트 Home을 **Human Home / Visual GDD / AI Workspace 계약**에 맞게 보호하는 방향이며, 이번 닌자 서바이벌 Home 재구성과 충돌하지 않는다.

중요:

- `selective_current_rule_read: PASS`는 프로젝트 전체 Base 규칙이 full migration/sync되었다는 뜻이 아니다.
- Base remote가 바뀌었다고 project canon을 자동 덮어쓰지 않는다.
- 실제 작업에 필요한 Base owner를 fresh read하고, 프로젝트 최신 AGENTS/Decision/Canon/implementation reality와 충돌 여부를 확인한 뒤 선택 적용한다.

### 2026-08-27 · 5단계 artifact gate fresh observation

```yaml
observed_base_main: 986ac32113958c501f11cd1ec4e38e65eb29f746
observation_reason: FIVE_PHASE_MACHINE_CLOSEOUT_ARTIFACT_AUDIT
selective_current_rule_read: PASS
base_promotion_judgement: REJECT_REFERENCE_ONLY_DUPLICATE_OF_EXISTING_FIVE_PHASE_ARTIFACT_CONTRACT
```

Base의 BCP-2026-040과 현재 5단계 실행 계약은 이미 다운로드 가능한 internal build, exact build identity, post-merge smoke, Human evidence 분리와 player-facing placeholder 금지를 공용 규칙으로 소유한다. 이 프로젝트의 preset 이름, Windows 경로, artifact 크기, Godot pin은 project-local evidence로만 남기며 별도 Base 변경 제안/구현 PR은 만들지 않았다.

### 2026-09-01 · 프로젝트 네이티브 Base 적응 계약 fresh observation

Current Base observation: `19355b7ef065a21d0f2b685c7d9be64a4a3970f8`.
Observation reason: `PROJECT_WORK_ORDER_STRUCTURE_AND_CONTRACT_ADAPTATION`.
Selective current-owner read: `PASS`; full Base rule sync: `NOT_RUN`.

Adoption disposition: `ADAPT`. The project preserves the existing
`AGENTS.md → Decision/Canon → ACTIVE_CONTEXT → actual Godot implementation`
authority order and connects Base work ordering, reuse/benchmark, approval,
dependency, rollback, evidence, and cleanup rules through
`docs/operations/NINJA_SURVIVAL_PROJECT_WORK_CONTRACT.md`.

Deferred by this package: `skills/PROJECT_BASE_ADAPTER.json`, a project Skill
Registry, generated operating dashboard/compatibility views, automatic merge,
continuous operations, and Base promotion. They lack the required current
consumer, committed baseline, or separate approval.

Protected and excluded: product rules, GDD, visual manifests, actual
code/scene/data/test owners, open PR #135, historical PR #49, and unknown
Godot-generated material. This is a documentation-only workstream.

Earlier Base observation SHAs remain their original work provenance. This
current observation does not replace project canon or automatically change a
Base release pin.

## 3. 역사적 project-local authority order — 2026-09-01

1. 최신 사용자 지시
2. `../AGENTS.md`
3. 현재 작업의 명시적 사용자 실행 계약/overlay
4. `CURRENT_CONFIRMED_DECISIONS.md`
5. `canon/2026-08-21-dec014-025-product-canon.md`
6. `canon/2026-08-22-dec026-encounter-pattern-budget.md`
7. `ACTIVE_CONTEXT.md`
8. current traceability / implementation plan
9. actual code / Scene / data / tests / executed evidence
10. project-adopted Base patterns
11. current Base remote / external benchmark evidence

Repository의 byte-exact historical adapter `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`는 역사 자료로 유지한다. 현재 사용자가 더 최신 작업 계약을 제공하면 **latest user instruction이 우선**한다.

## 4. 역사적 프로젝트 상태 · 2026-08-27 fresh readback

이 블록은 historical T01 state를 반복하지 않고 현재 router를 요약한다. 상세 상태는 `ACTIVE_CONTEXT.md`가 책임진다.

```yaml
mvp0_to_mvp3_runtime: INTEGRATED_BASELINE
mvp4_t01_to_t05_spatial_chain: INTEGRATED
committed_spatial_combat_integration_t06: INTEGRATED
acquisition_transaction_t07: INTEGRATED
run_route_state_t08: INTEGRATED
encounter_data_t09: INTEGRATED
elite_trace_boss_gate_t10: INTEGRATED
tradition_access_reward_lanes_t11: INTEGRATED
atomic_workbench_fate_route_t12: INTEGRATED
persistent_workbench_route_ui_input_t13: INTEGRATED
cheonsul_lifecycle_workbench_machine_slice_t14: INTEGRATED
starting_school_function_help_machine_slice_t15: INTEGRATED
combat_current_school_help_machine_slice_t16: INTEGRATED
windows_internal_build_artifact: INTEGRATED_MACHINE_EVIDENCE_ONLY_MAIN_0F085FC4FEFF25353C049749BF34236A89C01BE4
windows_internal_build_boundary: INTERNAL_VALIDATION_ONLY_NOT_PUBLIC_RELEASE_OR_DEVICE_EXPORT
next_product_gate: USER_VERTICAL_SLICE_VALIDATION_DEFERRED
last_product_implementation_merge: 63fcf81fdf4b5d1bbff14b5721a13f7c1afe1497
github_main_read_before_router_reconciliation: f77a1c86660784c1a20c9f2a9abfee7b774ba911
human_qa: DEFERRED_BY_CURRENT_USER_NOT_RUN
human_usability: NOT_RUN
player_experience: NOT_RUN
device_android_export: NOT_RUN
current_human_home_contract: LIVING_GDD_PLUS_VISUAL_DASHBOARD
current_visual_style: USER_APPROVED_FIRST_IMAGE_2026_08_25
```

Repository `main`은 docs-only alignment/correction으로 제품 구현 merge 이후 더 앞선 SHA일 수 있다. **repository current SHA와 latest product implementation package는 별도 축**이다.

Closed PR #43/#44와 open draft PR #49는 historical/read-only이며 현행 resume baseline이 아니다.

## 5. 당시 선택 적용한 Base 작업 원칙 — 현재 실행 지침 아님

- 최신 user instruction과 project authority를 먼저 읽는다.
- Existing Solution First: current internal solution과 current Base owner를 먼저 비교한다.
- L1+ 판단은 실질 대안, 성공/실패·혼합 사례, 장기 비용과 rollback을 비교한다.
- 적대적 검토는 최소 5회 whole-state loop 뒤 clean exit한다.
- implementation/evidence class를 분리하고 `NOT_RUN`을 PASS로 승격하지 않는다.
- current-task branch / exact-head CI / merge / post-merge readback을 사용한다.
- 열린 unrelated PR을 임의 takeover하지 않는다.
- force push / direct-main / admin-ruleset bypass를 기본 경로로 사용하지 않는다.
- Project Human Home은 사람이 게임과 제작 방향을 판단하는 Living GDD + Visual Dashboard로 유지한다.
- AI용 schema / ID / PR / test / provenance / runtime binding은 AI/System workspace에 보존한다.
- Home의 대량 사람용 데이터는 Master DB Linked View를 우선해 duplicate canon을 만들지 않는다.
- 추가 비용 없는 현재 연결 도구/로컬 경로를 기본으로 한다.

## 6. 프로젝트에서 검증된 재사용 교훈

아래는 Base-wide 새 규칙이 아니라 닌자 서바이벌 T01~T05에서 실제 검증된 project-local lessons다. 자세한 RED/GREEN/PR evidence는 Git history와 Production Handoff를 따른다.

### T01 · runtime-compatible representation

```text
문서상 더 강한 타입 표기
!= 현재 엔진에서 실행 가능한 최선

검증된 contract
= runtime-compatible representation
+ explicit validation
+ regression evidence
```

Godot 4.7.1 import를 깨뜨린 더 엄격한 typed-Dictionary 후보는 기각했고, runtime-compatible `Dictionary` + catalog validation을 유지했다.

### T02 · single source of truth는 mutation path까지 포함

```text
single source of truth
= owning object의 validated mutation path
+ live mutable interior 비노출
+ defensive snapshot/copy isolation
```

public live item/bag collection mutation bypass를 adversarial RED로 발견해 defensive snapshots로 교정했다.

### T03 · pure derived resolver

```text
derived resolver
= source snapshot을 읽음
+ 결정론적 파생 결과만 반환
+ content rule data-driven
+ corrupt input fail-closed
```

T02 state를 복제 소유하지 않고 T03가 legality/adjacency/modifier 결과만 계산한다.

### T04 · bounded edit session

```text
bounded edit session
= committed source copy
+ defensive preview
+ atomic edit history
+ irreversible transition history boundary
+ preview/input mode도 commit invariant에 포함
```

### T05 · atomic domain transaction

```text
domain transaction
= current rule authority validates
+ owner가 candidate copy에서 mutation
+ full validation 성공 뒤에만 swap
+ failure consumes/mutates nothing
+ stale memory가 current definition authority보다 앞서지 않음
```

GDScript underscore method는 language-private가 아니므로 naming/ownership/test contract 이상으로 과장하지 않는다.

## 7. 사용 규칙

- full Base migration/sync가 실제 필요할 때만 별도 audit/migration/verification 범위를 만들고 그때만 `full_base_rule_sync: PASS`를 기록한다.
- Base의 일반 작업 원칙과 프로젝트 고유 제품 규칙을 같은 owner로 합치지 않는다.
- reusable lesson이 생겨도 먼저 프로젝트에서 검증하고, Base 승격은 별도 freshness/collision 검토 후 진행한다.
- 현재 상태가 필요하면 이 파일의 오래된 history가 아니라 `ACTIVE_CONTEXT.md`와 실제 main을 다시 읽는다.
