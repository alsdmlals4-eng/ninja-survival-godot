# DEC-030 — 네 유파 Human 검증의 종점은 Final Binding 진입 자격

```yaml
decision_id: DEC_030
status: APPROVED_PRODUCT_SCOPE_IMPLEMENTATION_DEFERRED
approved_by: USER
approved_at: 2026-08-28 KST
owner: docs/canon/2026-08-28-dec030-four-school-validation-endpoint-before-final-package.md
depends_on:
  - DEC_029
implementation_reality: FINAL_BINDING_ELIGIBILITY_DOMAIN_ONLY
human_player_evidence: NOT_RUN
```

## 1. 결정

DEC-029의 네 유파 공통 lifecycle 구현과 첫 Human/Player validation은 **네 번째 학교 Boss 뒤 `Final Binding` 진입 자격이 확정되는 지점**에서 끝난다.

이번 단일 구현계약에는 다음을 넣지 않는다.

- `Final Binding Workbench` 전용 화면/flow의 production implementation.
- 최종 재앙 Boss, 네 유파 자동 지원 callback, final result, Ninja Soul/legend ending.
- 임시 "완료" 엔딩, 가짜 마지막 Boss, 또는 final package처럼 보이지만 실제 선택/전투가 없는 placeholder.

이는 최종 결전 제품 약속을 폐기하는 결정이 아니다. 네 유파 circuit이 정직하게 읽히는지 먼저 검증한 뒤, 별도 최종 결전 package에서 DEC-018, DEC-020, DEC-022를 함께 구현·검증하는 순서다.

## 2. 첫 Human 검증의 정확한 종료 상태

검증 대상은 어떤 시작 유파와 clear order에서도 다음 상태까지 도달하는 것이다.

```text
fourth school Boss clear
-> fourth trace STABILIZED / all four schools cleared exactly once
-> route state final_binding_eligible = true
-> fourth-school Result/Reward boundary confirms that the Final Binding is now available
-> first Human/Player validation ends
```

이 상태는 새 Final Binding Scene을 뜻하지 않는다. 네 번째 Boss 결과의 기존 Result/Reward 소비처는 진입 자격을 분명히 알리되, 최종 build/Fate 확정이나 final Boss launch를 수행하지 않는다.

## 3. Player value와 trade-off

플레이어는 한 판 안에서 시작 유파, 네 가지 위험 처리 방식, 보상·공간 Build, 미방문 경로 선택이 서로 영향을 주는지를 경험한다. 그 경험이 이해·가독성·선택 가치 관점에서 성립하는지를 먼저 검증한다.

대신 첫 검증에는 최종 재앙을 이겨 전설이 되는 결산 감정이 없다. 해당 결산은 별도 package에서 4유파 지원 순서, 최종 Workbench, 재앙의 두 phase와 함께 검증해야 한다.

## 4. 보호 규칙

- DEC-029의 shared combat/encounter/route/Backpack/Workbench authority를 유지한다. Final package를 미룬다는 이유로 네 번째 학교의 route·Trace·Boss·Result를 예외 처리하지 않는다.
- 네 번째 clear의 `final_binding_eligible`은 Final Binding 진입 자격일 뿐, 일반 Workbench route/Fate atomic commit을 우회하거나 자동 final build를 만들지 않는다.
- 첫 Human script가 final package까지 간 것처럼 해석될 수 있는 fake ending, final-style reward, 승리 선언을 만들지 않는다.
- Final package는 첫 Human evidence와 four-school machine evidence를 다시 읽고, DEC-018/020/022의 반복 위험과 support-order 의미를 독립적으로 review한 뒤 새 계약으로 연다.

## 5. Definition of Ready 영향

Phase 2 implementation contract는 다음을 명시해야 한다.

1. fourth Boss Result/Reward에서 Final Binding availability를 어떻게 정확히 알리는지.
2. final eligibility가 기존 route/Workbench atomic transaction과 충돌하지 않는 regression contract.
3. first Human/Player test script의 종료 조건과, final Boss/final ending을 평가하지 않는 evidence boundary.
4. 이후 final package가 DEC-018/020/022를 소유하는 명시적 handoff.

## 6. 적대적 검토 — 전체 범위 5회

1. **제품 약속:** final 결산을 삭제하지 않고 별도 구현 package로 보존했다. 첫 Human test의 missing payoff를 PASS로 오인하지 않는다.
2. **범위:** Final Binding Scene·Boss·ending을 억지로 축소하거나 placeholder로 흡수하지 않아, DEC-029의 이미 큰 four-school scope를 보호한다.
3. **상태 일관성:** `final_binding_eligible`은 이미 `RunRouteState`가 소유한다. 새 UI가 route/Fate/build authority를 가져가지 않도록 고정했다.
4. **플레이어 이해:** 네 번째 Boss 결과에서 final availability를 알려야 하며, 비상호작용 final screen을 완결 엔딩처럼 제시하지 않는다.
5. **검증:** four-school machine evidence, Human/Player, live render/input, touch/device/export는 서로 다른 evidence다. 이번 문서가 어느 것을 PASS로 만들지 않는다.
