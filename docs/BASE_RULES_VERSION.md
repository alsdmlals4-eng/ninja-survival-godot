# Base Rules Version

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

## 3. 현재 project-local authority order

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

## 4. 현재 프로젝트 상태 · 2026-08-27 fresh readback

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

## 5. 현재 선택 적용하는 Base 작업 원칙

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
