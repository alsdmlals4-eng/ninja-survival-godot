# Base Rules Version

## 프로젝트에 마지막으로 명시 동기화된 기준

- 공용 원본: `alsdmlals4-eng/Base`
- 기준 브랜치: `main`
- 프로젝트에 마지막으로 명시 동기화된 과거 기준 커밋: `499c20eb9b449241864f5ada0c915fba8a7806ac`
- 해당 과거 sync 확인 날짜: `2026-07-10`

이 SHA는 현재 Base 원격 HEAD가 아니다. 과거 full/local rule sync의 역사 기준만 보존한다.

## 최신 원격 관찰

```yaml
latest_base_main_observed: aa9a0d823db9c7373751d35d341489f64c62f7b9
observed_at: 2026-08-21 KST
observation_reason: DEC014_025_CANON_REBASELINE
full_base_rule_sync: NOT_RUN
selective_current_rule_read: PASS
```

이번 canon rebaseline에서 최신 Base의 현재 `AGENTS.md`를 다시 읽고 다음 원칙을 적용했다.

- latest user instruction -> project AGENTS/security/engine/data -> project Active Context/approved contract -> actual code/data/assets/tests -> adopted Base -> Base remote 순서.
- L1 이상에서 current main / current decisions / open+recent merged PR / actual implementation을 먼저 대조.
- `OPEN_PR_READ_ONLY_BY_DEFAULT`: 열린 PR은 기본 read-only; 후속 수정 target은 merged main.
- 중요한 판단은 최소 3개 실질 대안 비교와 장기 적합성 비교.
- evidence가 `NOT_RUN`이면 완료 증거로 승격하지 않음.
- 적대적 검토는 최소 5회 full loop 후 clean exit.
- 중간보고 생략은 실제 조사/검증 축소가 아님.
- 추가 비용 없는 경로를 기본으로 사용.
- repository/Notion connected state를 실제 tool로 읽을 수 있으면 추정 대신 직접 검증.

최신 Base 일부 규칙을 읽고 사용한 사실을 **프로젝트 전체 Base 동기화 완료**로 해석하지 않는다.

## 현재 프로젝트-local authority

1. 최신 사용자 지시
2. `AGENTS.md`
3. 현재 작업에 명시된 사용자 제공 실행 계약/overlay
4. `docs/CURRENT_CONFIRMED_DECISIONS.md`
5. `docs/canon/2026-08-21-dec014-025-product-canon.md`
6. `docs/ACTIVE_CONTEXT.md` for mutable resume state
7. current traceability/plan
8. actual code/Scene/data/tests
9. adopted project-local Base patterns
10. Base remote / external benchmark evidence

기존 byte-exact `PROJECT_TOTAL_PLANNING_IMPLEMENTATION_AND_DELIVERY_INSTRUCTION_v4.5_r2.md`는 저장소 안의 역사적 active adapter로 보존한다. 현재 채팅처럼 사용자가 더 최신 실행 계약을 직접 제공하면 **latest user instruction이 우선**하며, 그 사실만으로 r2 source bytes를 임의 수정하지 않는다.

## 현재 프로젝트 상태

```yaml
mvp0_to_mvp3_runtime: INTEGRATED
mvp4_spatial_production: NOT_STARTED
latest_product_canon: DEC014_025
school_circuit_runtime: NOT_STARTED
next_material_product_gate: DEC026
new_canon_human_qa: NOT_RUN
```

세부 구현/검증 상태는 `docs/ACTIVE_CONTEXT.md`가 책임진다.

## 사용 규칙

- Base remote가 변했다고 project canon을 자동 덮어쓰지 않는다.
- 작업에 필요한 최신 Base rule은 fresh read 후 project constraint에 맞게 선택 적용한다.
- full Base migration/sync가 실제 필요해지면 별도 audit/migration/verification 범위로 수행하고 그때만 `full_base_rule_sync: PASS`를 기록한다.
- Base의 일반 원칙과 프로젝트 고유 product rule을 같은 문서 owner로 합치지 않는다.
- reusable lesson이 생겨도 먼저 project에서 검증하고, Base 승격은 별도 collision/freshness 검토 뒤 진행한다.
