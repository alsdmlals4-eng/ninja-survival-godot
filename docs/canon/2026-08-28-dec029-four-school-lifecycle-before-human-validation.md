# DEC-029 — 네 유파 완결 lifecycle 선구현 후 Human 검증

```yaml
decision_id: DEC_029
status: APPROVED_PRODUCT_SCOPE_IMPLEMENTATION_DEFERRED
approved_by: USER
approved_at: 2026-08-28 KST
owner: docs/canon/2026-08-28-dec029-four-school-lifecycle-before-human-validation.md
overrides_for_current_package:
  - CHEONSUL_ONLY_HUMAN_VERTICAL_SLICE_GATE
implementation_reality: FOUR_SCHOOL_COMPLETED_LIFECYCLE_NOT_IMPLEMENTED
human_player_evidence: NOT_RUN
```

## 1. 결정

첫 Human/Player vertical-slice 검증은 천술류 한 유파만이 아니라 **네 유파 모두가 동일한 Run lifecycle을 실제로 통과할 수 있을 때** 시작한다.

각 유파는 선택 가능한 하나의 전장이며, 현재 승인된 공통 프레임 안에서 다음을 완결해야 한다.

```text
school selection
-> <=30s signature proof
-> school Core pressure
-> ~3m Elite
-> chest token + Trace AVAILABLE
-> trace recovery + Boss dual gate
-> ~5m school Boss
-> Result / Boss reward
-> Persistent Workbench
-> provisional next-school selection + Fate + atomic commit
-> next unvisited school
```

이는 **네 개의 독립 전투 엔진**을 승인하는 결정이 아니다. DEC-026의 shared attack primitives, 하나의 combat/route/Backpack/Workbench authority, 유파별 encounter composition을 유지한다.

## 2. 범위와 제외

### 포함

- 봉마·천술·귀인·흑영 각각의 Core x3 / Elite x1 / Boss x1과 승인된 pattern composition이 실제 run lifecycle에 연결된다.
- 어떤 시작 유파를 골라도 네 유파를 한 번씩 방문하고, Boss 결과 뒤 Workbench에서 다음 미방문 유파를 임시 선택·Fate와 함께 atomic commit할 수 있다.
- 첫 Human/Player 검증은 네 유파 모두의 초기 signature, 위험 처리 방식, Trace-to-Boss 흐름, Workbench 선택, 한국어 가독성, mouse/keyboard-gamepad/touch core path를 표본으로 삼는다.

### 이번 결정만으로 포함하지 않음

- `Final Binding Workbench`, final calamity Boss, final result/Ninja Soul/legend의 production implementation.
- 새 영구 메타, 새 wave system, 유파별 독립 입력/경제/공간 알고리즘.
- 새 raster asset batch 또는 이미지 생성. visual consumer gap은 Phase 2 asset gate에서 별도로 확정한다.

fourth-school clear 뒤 Final Binding eligibility가 열리는 기존 route authority는 보존한다. 최종 결산 package는 DEC-030에 따라 이번 확장 범위에서 제외되며, first Human validation 뒤 별도 package로 다시 review한다.

## 3. Player Promise와 trade-off

플레이어는 “유파를 고르면 그 유파의 위험 처리 방식이 실제 Run의 한 구간을 바꾸고, 다음 Workbench 선택이 남은 전장과 빌드를 다시 바꾼다”를 한 complete four-school circuit에서 경험해야 한다.

대신 가장 이른 Human evidence는 늦어진다. 이 결정은 천술류 단독 가설을 빨리 좁히는 대신, 실제 제품의 시작 선택·route·Workbench 약속을 한 표본에서 검증하는 데 우선순위를 둔다.

## 4. 보호 규칙

- school identity와 Stage 1..4는 분리한다. 각 유파가 선택 가능한 순간에 Stage profile은 current route state가 소유한다.
- 동일한 Boss/Elite/Trace/Workbench transaction이 네 유파에서 중복되거나 UI에 복사되지 않아야 한다.
- 각 유파의 Core/Elite/Boss는 DEC-026의 role/telegraph/concurrency budget을 지켜야 한다. 색만 바꾼 generic chaser/stat scaling은 기각한다.
- 천술류 DEC-027/028, icon-first status, recently-hit-enemy-only HP rule은 네 유파 확장으로 약화되지 않는다. 다른 유파도 공통 presentation grammar와 제한된 고유 variation을 따른다.
- final Binding/final calamity를 조용히 이번 contract에 포함하지 않는다.

## 5. Definition of Ready 영향

Phase 2 review는 아래가 하나의 단일 구현계약에서 traceable할 때만 열린다.

1. 공통 encounter primitive runtime boundary와 네 유파 composition 표.
2. shared Trace object/auto-recovery, Boss gate, Result/Reward, 6×6 Workbench input, provisional route/Fate commit contract.
3. 네 유파별 first-30-second proof, Elite/Boss test, accessibility/visual information contract.
4. exact automated, runtime, Human and Player evidence를 서로 승격하지 않는 validation matrix.
5. DEC-030의 Final Binding/final calamity 제외 이유와 별도 package revisit gate.

## 6. Revisit conditions

- 네 유파 completion이 공통 primitive 재사용을 깨고 네 개의 독립 subsystem으로 변질된다.
- Workbench/route가 유파 확장보다 먼저 player value와 accessibility 위험의 병목이 된다.
- production cost 또는 Human-ready delay가 현재 사용자 목표와 맞지 않아, 사용자에게 천술류-only validation으로 범위를 되돌릴 이유가 생긴다.
- final Binding/final calamity를 이 계약에 포함해야만 four-school circuit의 failure/reward meaning이 성립한다는 새 Human evidence가 생겨 DEC-030을 재검토해야 한다.

## 7. 적대적 검토 — 전체 범위 5회

1. **Scope:** C안은 네 유파 lifecycle 범위만 확장한다. final package, meta, asset batch가 자동 포함되지 않게 분리했다.
2. **Identity:** 네 유파가 같은 generic enemy/stat ladder가 되지 않도록 DEC-026 composition과 유파별 player test를 보호했다.
3. **Architecture:** 공통 primitive/route/Workbench owner를 재사용해 유파별 독립 engine·UI·경제 중복을 금지했다.
4. **Validation:** automation만으로 네 유파 재미/가독성 PASS를 주장하지 않고, Human/Player gate를 모든 lifecycle 구현 뒤에 별도 유지했다.
5. **Reversibility:** completion cost가 제품 목표를 훼손하면 user approval로 Cheonsul-only Human validation으로 되돌릴 수 있으나, 현재는 C안이 제품 선택 약속을 우선한다.
