# DEC-036 — Human/Player 검수의 현 구현 게이트 제외

```yaml
decision_id: DEC_036
status: APPROVED_CURRENT_PACKAGE_SCOPE
approved_by: USER
approved_at: 2026-08-29 KST
owner: docs/canon/2026-08-29-dec036-human-player-validation-deferred-from-current-build-gate.md
overrides:
  - DEC_029_AND_DEC_030_HUMAN_PLAYER_VALIDATION_AS_A_BLOCKING_CURRENT_BUILD_GATE_ONLY
human_usability: NOT_RUN
player_experience: NOT_RUN
release_readiness: NOT_PROVEN
```

## 1. 결정

사용자는 이번 작업에서 **사람 플레이 검수 없이** 통합 구현계약과 이후 Godot machine 구현을 진행하도록 승인했다.

따라서 Human Usability와 Player Experience 세션은 다음을 막지 않는다.

```text
Phase 1 통합 구현계약 작성
-> Phase 2 Definition of Ready 검토
-> 네 유파 shared-chassis 구현
-> machine 검증
```

이 결정은 사람 검수를 통과로 바꾸거나 삭제하지 않는다. 두 증거 클래스는 계속 `NOT_RUN`이며, 배포·출시·재미·실제 읽기 쉬움의 증거로 사용하지 않는다.

## 2. DEC-029/030과의 관계

- **유지:** 네 유파는 공유 lifecycle로 구현한다. 첫 번째 네 유파 circuit의 범위는 네 번째 Boss Result/Reward가 `final_binding_eligible`을 분명히 알리는 지점까지다.
- **유지:** Final Binding Workbench, final calamity, 최종 결과와 진짜 Run-end Ninja Soul 정산은 별도 package다.
- **교체:** 네 유파 machine 구현을 시작하거나 현재 package를 완료하기 위해 사람 플레이 세션을 선행 조건으로 요구하지 않는다.
- **보존:** 향후 player-facing milestone 또는 출시 검토가 필요해질 때 DEC-029/030의 Human 검수 항목을 다시 일정화한다. 그때까지 `PASS`라는 표기는 금지한다.

## 3. 검증 경계

이번 package의 필수 증거는 source/contract review, deterministic GUT, Godot import/parse, headless main-scene smoke, exact PR-head checks, Windows internal-build check 및 적대적 검토다.

사람이 실제로 이해했는지, 전투가 공정하게 느껴지는지, 목표 해상도에서 읽기 쉬운지는 이 증거들로 판정하지 않는다. 이 결정은 검수의 종류를 바꾸지 않고 **현재 구현 순서만** 바꾼다.

## 4. Incident / Lesson

```yaml
incident_id: INC_DEC036_01
problem: Historical Cheonsul-only Human QA issue could be mistaken for an active implementation blocker after DEC-029 expanded the product slice to four schools.
solution: Record the user-approved deferment as a current build-gate override while retaining NOT_RUN evidence labels.
lesson: A deferred validation gate must be recorded as sequencing, never as a silent PASS or deletion of the quality question.
base_promotion: NO_BASE_PROMOTION
reason: This decision depends on Ninja Survival's four-school and Final-Binding scope.
```
