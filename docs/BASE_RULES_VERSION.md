# Base Rules Version

## 프로젝트에 마지막으로 명시 동기화된 기준

- 공용 원본: `alsdmlals4-eng/Base`
- 기준 브랜치: `main`
- 프로젝트에 마지막으로 명시 동기화된 과거 기준 커밋: `499c20eb9b449241864f5ada0c915fba8a7806ac`
- 해당 과거 sync 확인 날짜: `2026-07-10`

이 SHA는 현재 Base 원격 HEAD가 아니다. 과거 full/local rule sync의 역사 기준만 보존한다.

## 최신 원격 관찰

```yaml
latest_base_main_observed: 2828a74f60c1ed09546171040f4178c8848ea686
observed_at: 2026-08-24 KST
observation_reason: T01_SPATIAL_DATA_IMPLEMENTATION_AND_POSTMERGE_SYNC
full_base_rule_sync: NOT_RUN
selective_current_rule_read: PASS
```

이 관찰값은 T01 실행에서 읽은 값이며, T02 후속 작업에서 Base 원격 전체를 다시 동기화했다고 해석하지 않는다. 이번 T02는 현재 프로젝트 AGENTS/Decision/Phase-B와 설치된 Superpowers TDD/debugging/verification 규칙을 적용했다.

- latest user instruction -> project AGENTS/security/engine/data -> project Active Context/approved contract -> actual code/data/assets/tests -> adopted Base -> Base remote 순서.
- L1 이상에서 current main / current decisions / open+recent merged PR / actual implementation을 먼저 대조.
- `OPEN_PR_READ_ONLY_BY_DEFAULT`: 열린 PR은 기본 read-only; current-task PR만 승인 범위와 exact-head gate 뒤 정상 병합.
- 중요한 판단은 최소 3개 실질 대안 비교와 장기 적합성 비교.
- evidence가 `NOT_RUN`이면 완료 증거로 승격하지 않음.
- 적대적 검토는 최소 5회 full loop 후 clean exit.
- 코드/계약 변경은 RED failure reason -> minimal GREEN -> regression.
- 실패한 더 엄격한 후보를 고집하지 않고 실제 실행 증거에 따라 복구/기각.
- 중간보고 생략은 실제 조사/검증 축소가 아님.
- 추가 비용 없는 경로를 기본으로 사용.
- repository/Notion connected state를 실제 tool로 읽을 수 있으면 추정 대신 직접 검증.
- required work 0은 completion candidate이며 correction rescan과 final clean review 뒤에만 완료로 판정.

최신 Base 일부 규칙을 읽고 사용한 사실을 **프로젝트 전체 Base 동기화 완료**로 해석하지 않는다.

## 현재 프로젝트-local authority

1. 최신 사용자 지시
2. `AGENTS.md`
3. 현재 작업에 명시된 사용자 제공 실행 계약/overlay
4. `docs/CURRENT_CONFIRMED_DECISIONS.md`
5. `docs/canon/2026-08-21-dec014-025-product-canon.md`
6. `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
7. `docs/ACTIVE_CONTEXT.md` for mutable resume state
8. current traceability/Phase-B/plan
9. actual code/Scene/data/tests
10. adopted project-local Base patterns
11. Base remote / external benchmark evidence

기존 byte-exact `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`는 저장소 안의 역사적 adapter로 보존한다. 현재 채팅처럼 사용자가 더 최신 실행 계약을 직접 제공하면 **latest user instruction이 우선**하며, 그 사실만으로 r2 source bytes를 임의 수정하지 않는다.

## 현재 프로젝트 상태

```yaml
mvp0_to_mvp3_runtime: INTEGRATED
mvp4_spatial_production: T01_T02_INTEGRATED
backpack_state_runtime: INTEGRATED
backpack_resolver_runtime: NOT_STARTED
latest_product_canon: DEC014_025
latest_encounter_canon: DEC026_APPROVED
phase_b: PASS
t01_merge_sha: 7c9206702526f99dfadf44a617cd150853ec733f
t01_final_evidence: GODOT_IMPORT_PASS_MAIN_SMOKE_PASS_GUT_263_OF_263_1829_ASSERTIONS
t02_merge_sha: 126e6c942d74f97166ef0c881afc5d79cae3d274
t02_final_evidence: GODOT_IMPORT_PASS_MAIN_SMOKE_PASS_GUT_274_OF_274_1915_ASSERTIONS_T02_11_OF_11
school_circuit_runtime: NOT_STARTED
dec026_encounter_runtime: NOT_STARTED
next_implementation_gate: T03_BACKPACK_RESOLVER
new_canon_human_qa: NOT_RUN
```

세부 구현/검증 상태는 `docs/ACTIVE_CONTEXT.md`가 책임진다.

## T01 실행 교훈

T01 적대적 검토 중 exported typed `Dictionary[StringName, float]` 후보를 실제로 시험했으나 현재 Godot 4.7.1 프로젝트 import를 회귀시켰다. 해당 후보는 force 없이 되돌렸고, 코드 저작 `Dictionary` + 단일 catalog validator + RED/GREEN tests가 현재 검증된 경로다.

```text
문서상 더 강한 타입 표기
!= 현재 프로젝트의 실제 import-compatible 최선

실행 가능한 contract
= runtime-compatible representation + explicit validation + regression evidence
```

## T02 실행 교훈

T02의 첫 GREEN은 기능 테스트를 통과했지만 적대적 검토에서 `BackpackState.items` / `bags`가 live instance object를 노출해 외부 consumer가 `move_*` / `rotate_*` validation을 우회할 수 있는 authority leak가 발견됐다.

새 RED 반례로 이 우회를 고정한 뒤 public collection view를 defensive snapshot으로 바꿨고, final GREEN `274/274 · 1915 assertions`로 닫았다.

재사용 가능한 최소 원리:

```text
single source of truth
!= mutation function을 한 파일에 모아두는 것만으로 충분

single source of truth
= validated mutation path + 외부에 live mutable interior를 노출하지 않음 + copy/snapshot isolation test
```

이 역시 새 광역 Base 규칙을 만들기보다 기존 state ownership / adversarial review / TDD / evidence-first 원칙의 프로젝트 검증 사례로 유지한다. Base 승격이 필요하면 별도 collision/freshness 검토를 한다.

## 사용 규칙

- Base remote가 변했다고 project canon을 자동 덮어쓰지 않는다.
- 작업에 필요한 최신 Base rule은 fresh read 후 project constraint에 맞게 선택 적용한다.
- full Base migration/sync가 실제 필요해지면 별도 audit/migration/verification 범위로 수행하고 그때만 `full_base_rule_sync: PASS`를 기록한다.
- Base의 일반 원칙과 프로젝트 고유 product rule을 같은 문서 owner로 합치지 않는다.
- reusable lesson이 생겨도 먼저 project에서 검증하고, Base 승격은 별도 collision/freshness 검토 뒤 진행한다.
