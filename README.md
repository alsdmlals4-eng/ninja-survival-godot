# Ninja Survival Godot — 닌자의 신

Godot 4.x / GDScript로 재구성 중인 `닌자 서바이벌 (닌자의 신)` 저장소다. Unity 버전은 별도 아카이브 참고자료이며, 현재 구현 정본은 이 Godot 저장소다.

## 제품 약속

> 네 유파 전장을 돌며 전승 접근권을 복구하고, 공간·회전·인접 기반 백팩 빌드를 완성해 난세 재앙핵을 평정하는 2D 서바이벌 로그라이크.

플레이어 감정 목표:

`살아남는다 -> 강해진다 -> 자기 방식을 만든다 -> 네 유파를 다시 잇는다 -> 이번 전선을 평정한다 -> 전설이 된다`.

## 현재 구현 상태

| 영역 | 상태 |
|---|---|
| MVP-0 기본 전투 | integrated |
| MVP-1 전투 DDD | integrated |
| MVP-2 4유파 얕은 runtime | integrated |
| MVP-3 결과/GOLD/상점/운명/3세그먼트 runtime | integrated rollback/regression baseline |
| MVP-4 공간 백팩/조합 production | **not started** |
| DEC-014~025 4유파 순회 migration | **documented / not implemented** |
| DEC-026 encounter/pattern budget | **approved / not implemented** |
| Fresh Phase-B | **PASS** |
| Next implementation | **T01 Spatial Data Contracts** |
| release-near Vertical Slice human QA | **NOT_RUN** |
| Android device/export | **NOT_RUN / NOT_READY** |

마지막 관찰된 자동 회귀 기준선은 Godot 4.7.1 import + main-scene smoke + GUT `34 scripts / 250 tests / 1624 assertions PASS`다. 이것은 기존 MVP-0~3이 깨지지 않았다는 증거이지 DEC-014~026 구현 완료 증거가 아니다.

## 최신 Run 목표

```text
시작 유파
-> 미방문 유파 전장 선택
-> Core Monster + Stage 기믹
-> 약 3분 유파 Elite
-> 상자 토큰 + 유파 흔적
-> 흔적 회수
-> Boss 접근 경고/이중 Gate
-> 약 5분 유파 Boss
-> RESULT / Boss Reward
-> 4유파 공동 지부 귀환
-> 흔적 STABILIZED / 전승 접근 package OPEN
-> Persistent Workbench
-> 다음 미방문 유파 provisional 선택
-> Shop / Chest / Backpack / Combination
-> Fate가 build + Fate + next route atomic commit
-> 네 유파를 정확히 한 번씩 반복
-> Final Binding Workbench
-> 별도 최종전 `난세 재앙핵`
-> 최종 결과 / Ninja Soul
```

`약 20분`은 네 번째 유파 Boss까지의 active-combat 목표치다. 전체 Run 종료 시점이 아니다.

## 핵심 시스템

### 자동 생존 전투 + DDD

- 8방향 이동
- 자동 공격
- 처치 콤보 / MAX COMBO
- stylish score
- 보상 흡수 피드백
- 결과 기여도 추적

### 4유파

- **봉마:** 이동형 진지 · 식신/결계로 공간을 준비하고 대신 싸우게 한다.
- **천술:** 상태를 만들고 순서/조합으로 원소 반응을 일으킨다.
- **귀인:** 위험한 근접 체류를 유지해 난전 지속력과 폭발력을 얻는다.
- **흑영:** 위험한 적을 표식/우선순위/처형으로 먼저 제거한다.

현재 MVP-2 runtime은 이 장기 정체성을 위한 검증된 baseline으로 유지한다. 봉마의 고정 ward, 귀인의 low-HP 보정, 흑영의 최근접 규칙은 향후 Vertical Slice에서 조정 후보지만 지금 즉시 폐기하지 않는다.

### 공간 백팩 / Persistent Workbench

보호된 MVP-4 규칙:

- 6x6 전체 보드
- 4x3 시작 사용 영역
- 가방 구매로 사용 영역 확장
- 아이템/가방 90도 회전
- 직교 인접 시너지
- 일부 L/T형 가방
- 6-slot REST 작업 버퍼
- explicit atomic 1차 조합
- Boss / Shop / Chest 획득 역할 분리
- preview와 실제 combat commit 분리

Architecture direction:

`definitions -> BackpackState -> BackpackResolver -> RestBackpackSession/CombinationResolver -> committed RunBuildState -> combat`.

### 흔적 / 전승 접근

흔적은 자동 유파 버프가 아니다.

`Elite -> trace AVAILABLE -> RECOVERED -> Boss -> branch return -> STABILIZED`

`STABILIZED`는 해당 유파 인법/장비가 Boss Reward / Shop / Chest 후보 pool에 등장할 수 있게 하는 **Run 전승 접근권**이다. 실제 전투력은 플레이어가 획득하고 백팩에 배치·인접·조합한 결과가 결정한다.

## 현재 개발 경계

DEC-026은 승인됐고 fresh Phase-B가 PASS했다. 현재 production은 **T01부터 시작**한다.

기존 2026-08-11 MVP-4 계획 중 **T01~T07 저수준 domain 방향은 재사용**한다. 과거 T08~T12 immediate-Boss/3세그먼트 조립 계획은 실행하지 않고, current post-DEC-026 traceability/plan을 사용한다.

```text
T01 -> T02 -> T03 -> T04 -> T05 -> T06 -> T07
-> T08 -> T09 -> T10 -> T11 -> T12 -> T13 -> T14
-> T15 Human QA gate
```

현재 T01은 6x6/4x3 shape, rotation, bag, tag, combination data contract를 추가하되 기존 ItemDefinition identity를 가능한 한 확장 재사용하고 중복 item authority를 만들지 않는 package다.

## 역사 실행 경로 주의

- PR #17은 **closed / unmerged** 역사 자료다. 재오픈·병합하거나 prerequisite로 사용하지 않는다.
- `impl/mvp4-t01-spatial-data-contracts`는 오래된 prepared baseline이며 현재 구현 branch가 아니다.
- 새 production package는 최신 canon/plan/Phase-B readback 뒤 fresh merged `main`에서 만든다.

## 읽기 순서

1. `AGENTS.md`
2. `docs/CURRENT_CONFIRMED_DECISIONS.md`
3. `docs/ACTIVE_CONTEXT.md`
4. `docs/canon/2026-08-21-dec014-025-product-canon.md`
5. `docs/canon/2026-08-22-dec026-encounter-pattern-budget.md`
6. `docs/traceability/2026-08-22-dec026-post-gate-traceability.md`
7. `docs/planning/2026-08-22-dec026-phase-b-definition-of-ready.md`
8. MVP-4 spatial detail이 필요하면 `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md` + `docs/planning/2026-08-11-mvp4-content-data-contract.md`
9. 실제 코드 / Scene / Test / CI

문서와 실제 구현이 다르면 구현 사실은 코드/테스트로 확인하되, 앞으로 구현해야 할 제품 행동은 최신 Decision/Canon을 따른다.

## Human play evidence

placeholder/card UI는 기술 Spike와 자동 테스트에 사용할 수 있다. 최종 player-experience PASS에는 사용할 수 없다.

4유파 전체를 한 번에 제작하기 전에 천술류를 대상으로 다음 release-near Vertical Slice를 먼저 검증한다:

`30초 내 유파 시그니처 -> Core 전투 -> ~3분 Elite -> trace -> ~5분 Boss -> 보상 -> Workbench -> 다음 route preview`.

실제 사용 후보 UI/UX, 닌자/적 시각, animation/VFX, audio feedback을 연결해 재미·가독성·정비 피로를 확인한 뒤 콘텐츠를 4유파로 확장한다.
