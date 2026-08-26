# T14 천술류 릴리스 근접 세로 슬라이스 설계

## 목표

이미 병합된 T09~T13 도메인 소유자를 실제 한 번의 천술류 플레이 흐름으로 연결한다. 플레이어는 천술류를 선택한 뒤 전투 압박을 읽고, Elite 처치 뒤 Trace를 회수하고, Boss를 처치한 뒤 영속 Workbench에서 다음 유파를 **미리 선택**할 수 있어야 한다.

이 패키지는 아직 네 유파 전체 제작이나 사람 대상 플레이 검증이 아니다. T15가 그 검증을 맡는다.

## 확정된 입력과 경계

- `StageEncounterState`가 Core → Elite → Trace → Boss의 시간·게이트·생명주기 단일 소유자다.
- `RunRouteState`가 선택 가능한 유파·방문 이력·임시 다음 유파의 단일 소유자다.
- `RestBackpackSession`과 `BackpackResolver`가 Workbench 배치·조합·커밋 가능성의 단일 소유자다.
- `RestCommitCoordinator`가 배낭 스냅샷·Fate·다음 유파의 원자적 커밋 단일 소유자다.
- `RestRewardController`가 Boss/Shop/Chest 보상을 세션 버퍼에 넣는 소유자다.
- T13 `RestFlowUI`는 경로/Fate 카드와 의도를 표시한다. 보드 편집, 버퍼 아이템 배치, Boss 보상 선택 화면은 아직 제공하지 않는다.
- 새 이미지·스프라이트 가공·새 전투 원시기·저장 시스템은 이번 범위 밖이다.

## 검토한 접근

| 접근 | 판단 | 이유 |
| --- | --- | --- |
| 기존 MainController의 3구간 루프를 T09~T13으로 전면 교체 | REJECT | 기존 MVP-3 회귀 위험이 크고, 각 도메인 소유권을 UI/컨트롤러로 끌어올린다. |
| 실제 상태와 분리된 천술류 데모 장면 | REJECT | Trace/경로/Workbench가 가짜가 되어 T14의 통합 증거가 되지 않는다. |
| 천술류 선택 때만 얇은 통합 어댑터로 기존 도메인을 조립 | ADOPT | 기존 소유자는 그대로 두고, 하나의 실제 플레이 경로와 회귀 가능한 계약을 만든다. |

## 권장 설계

`MainController`는 천술류 선택에 한해 `CheonsulVerticalSliceController`를 구성한다. 이 컨트롤러는 규칙을 재구현하지 않고 아래 소유자의 신호와 명령을 연결하는 조정자다.

```text
학교 선택(천술류)
  -> RunRouteState: 첫 학교 임시 선택/확정
  -> StageEncounterState: 실제 전투 생명주기
  -> WaveSpawner + 기존 적/Boss 표현: Core/Elite/Boss 전환
  -> Trace 회수 입력/상호작용
  -> RestRewardController + RestBackpackSession: Boss 보상 대기 상태
  -> RestFlowUI: Workbench 카드, Fate/경로 미리보기, 준비도 사유
```

### 첫 학교와 T12 경계

첫 학교 진입은 아직 `cleared_school_ids()`가 비어 있으므로 T12 원자 트랜잭션의 대상이 아니다. 선택한 천술류를 `RunRouteState`의 정상적인 임시 선택 후 확정으로 한 번만 시작하고, 이후 Boss 클리어 뒤의 다음 유파·Fate·배낭 최종본만 T12 커밋 후보가 된다.

### Workbench 경계

Boss 보상은 실제 `RestRewardController`를 통해 `RestBackpackSession` 버퍼에 들어가야 한다. 하지만 현재 UI에는 그 보상을 고르고 보드에 배치·회전·조합하는 조작면이 없다. 따라서 T14 런타임은 다음을 반드시 한다.

- Boss 클리어 후 실제 세션과 Boss 보상 대기 상태를 만든다.
- Workbench에서 다음 유파와 Fate를 **임시로 선택**하고, Boss 보상 후보와 현재 준비도·차단 사유를 읽게 한다.
- 배치되지 않은 보상이 있으면 커밋을 활성화하거나 자동 커밋하지 않는다.

즉, T14의 끝은 “실제 Workbench에 진입해 다음 경로를 미리 볼 수 있음”이며, 자동 보상 배치로 플레이어의 빌드 선택을 훼손하지 않는다. 보상 선택·보드 편집·원자 커밋을 플레이어가 완결하는 표면은 후속 Workbench 조작 패키지로 분리한다. T12의 원자성은 유지되고, 테스트에서는 유효한 이미 해결된 세션 fixture로만 검증한다.

## 천술류 전투 표현

기존 `CheonsulRuntime`과 `EncounterCatalog`의 정의를 사용한다. T14는 정의를 새 전투 시스템으로 복제하지 않는다.

- Core: 불의 부채형 압박, 물의 느려짐 구역, 번개의 연결 위협을 현재 적/투사체 표현으로 순차적으로 읽게 한다.
- Elite: 두 원소 준비 뒤 반응이라는 순서를 명확한 HUD 단계 텍스트와 기존 전투 효과로 드러낸다.
- Trace: Elite 처치 뒤 일반 스폰을 멈추고 Trace 회수 안내를 표시한다.
- Boss: Trace, 시간, 경고 게이트가 모두 충족되기 전에는 Boss를 생성하지 않는다.

정확한 난이도 수치, 신규 패턴 원시기, Stage 4 보스 캡스톤은 T14에서 주장하거나 추가하지 않는다.

## 수용 기준

1. 천술류 선택은 첫 학교를 정상적으로 확정하고 기존 선택 흐름을 회귀시키지 않는다.
2. `StageEncounterState`의 Elite → Trace → Boss 게이트가 실제 런타임 전환을 제어하며, 우회 호출로 Boss가 나오지 않는다.
3. Elite 처치 뒤 chest token과 Trace 회수 경로가 실제 상태로 기록되고, Trace 회수 전에는 Boss가 생성되지 않는다.
4. Boss 클리어 뒤 활성 학교가 클리어/안정화되고, 실제 `RestBackpackSession`/`RestRewardController` 기반 Workbench가 열린다.
5. Workbench는 선택 전 Boss 보상이 남아 있어 커밋할 수 없는 경우 후보와 차단 사유를 사용자에게 읽을 수 있게 보인다. 자동 보상 배치·자동 Fate·자동 다음 학교 확정은 없다.
6. 천술류 경로가 아닌 기존 MVP-3 경로는 기존 테스트와 동작을 유지한다.
7. 단위/통합 GUT, Godot import, main-scene headless smoke가 통과한다. 사람 플레이·입력 품질·렌더·기기/export 평가는 `NOT_RUN`으로 남긴다.

## 제외와 후속 게이트

- 네 유파 전체 전개, 신규 래스터 자산, 이미지 생성, 새 저장/메타 성장, 신규 Wave 시스템
- Workbench 보드 조작·Boss 보상 선택 UI·배낭 배치/회전 UI의 전체 구현
- 인간 사용성·재미·접근성·기기/export 판정 (T15)

후속 구현은 실제 Boss 보상과 배낭 버퍼를 사람이 해결하는 Workbench 조작면을 추가한 뒤, 이미 보호된 `RestCommitCoordinator` 커밋 경로를 노출한다.
