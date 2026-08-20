# 닌자의 신 · 4유파 자유 경로 / 스테이지 보정 기획

상태: `APPROVED_BY_USER_2026-08-20`
기준 branch: `docs/world-core-planning-20260820`
선행 owner: `docs/planning/2026-08-20-four-school-circuit-final-boss-amendment.md`

제품 코드·Scene·Resource·runtime은 사용자가 `기획 완료`를 선언하기 전 수정하지 않는다.

## DEC-2026-08-20-015 · 다음 유파 자유 선택 + 스테이지 번호 기반 공통 보정

상태: `APPROVED_BY_USER_2026-08-20`

DEC-014로 모든 Run은 봉마·천술·귀인·흑영 4유파 전장을 모두 한 번씩 방문하고, 각 전장에서 흔적을 회수한 뒤 해당 유파 보스를 상대하는 구조로 확정됐다.

최신 승인으로 방문 순서를 고정하지 않는다. **각 유파 보스 격파 후 공동 지부의 휴식/Workbench/Fate에서 아직 방문하지 않은 유파 중 다음 전장을 플레이어가 자유롭게 선택한다.**

```text
공동 지부 / 시작 유파 선택
→ 남은 4유파 중 첫 전장 선택
→ Stage 1 보정으로 전투 / 흔적 / 유파 Boss
→ RESULT / Workbench / Fate
→ 남은 3유파 중 다음 전장 자유 선택
→ Stage 2 보정
→ 남은 2유파 중 자유 선택
→ Stage 3 보정
→ 마지막 유파
→ Stage 4 보정
→ 4유파 순회 완료 / 마지막 휴식
→ 별도 최종보스
```

### 핵심 분리 원칙

**유파 콘텐츠와 난이도를 분리한다.**

- `school_id`는 **무엇을 상대하는가**를 결정한다.
  - 전장 비주얼/분위기
  - 유파 흔적
  - 유파 특화 적 조합 가중치
  - 유파 Boss 패턴/연출
- `stage_index`는 **얼마나 강하게 상대하는가**를 결정한다.
  - 적 체력 예산
  - 적 피해 예산
  - spawn/encounter pressure
  - Elite/Boss 압박 빈도
  - 필요 시 보스 HP/위험 시간 점유율

따라서 같은 천술 전장이라도 첫 번째로 가면 Stage 1 난이도, 네 번째로 가면 Stage 4 난이도를 적용한다. 천술 자체에 `항상 3번째 난이도` 같은 고정값을 두지 않는다.

## StageDifficultyProfile · 초기 권장값

아래 수치는 **RECOMMENDED_DEFAULT**이며 플레이테스트로 조정한다. 구조 결정은 `스테이지 번호 기반 공통 보정`이고 정확한 수치는 불변 코어가 아니다.

| stage | enemy HP | enemy damage | spawn/pressure | Elite/Boss cadence pressure |
|---:|---:|---:|---:|---:|
| 1 | `1.00x` | `1.00x` | `1.00x` | `1.00x` |
| 2 | `1.12x` | `1.05x` | `1.10x` | `1.05x` |
| 3 | `1.25x` | `1.10x` | `1.20x` | `1.08x` |
| 4 | `1.40x` | `1.15x` | `1.30x` | `1.12x` |

### 보정 원칙

- 이동속도를 큰 폭으로 올려 난이도를 만드는 방식은 우선하지 않는다. telegraph 가독성과 근접/원거리 유파 공정성을 해칠 수 있다.
- Stage 3/4라고 완전히 새로운 보스 기믹을 추가해 같은 유파 보스가 다른 보스로 변하지 않게 한다.
- 우선 `HP / damage / spawn pressure / existing pattern cadence`를 조정하고, 패턴 수 증가는 기존 패턴 조합만으로 부족하다는 증거가 있을 때 검토한다.
- 모든 유파 보스는 1~4번째 어느 위치에서도 같은 핵심 철학을 유지해야 한다.
- Stage 4가 단순 체력 스펀지가 되지 않도록 HP 증가보다 spawn/패턴 압박을 함께 분산한다.
- 5분대 보스 결산 + soft overtime 원칙은 DEC-013/014에서 유지한다.

## 자유 선택이 만드는 전략

경로 선택은 단순 취향 선택이 아니라 현재 Run 빌드 판단이 된다.

예:

- 현재 빌드가 원소/광역 처리에 강하면 천술 전장을 늦게 남겨 Stage 3~4의 강화된 원소 압박을 감수할 수 있다.
- 특정 유파 Boss가 현재 빌드에 까다롭다면 Stage 1~2에 먼저 처리해 위험을 줄일 수 있다.
- 반대로 특정 유파 흔적/보상 방향이 현재 빌드에 중요하면 그 유파를 먼저 선택해 이후 2~4번째 전장의 빌드 기반으로 활용할 수 있다.

단, `어느 유파를 몇 번째로 가야만 정답`이 되는 숨은 고정 루트가 생기면 실패다.

## 경로 선택 UX 원칙

각 Workbench/Fate 종료 직전 또는 다음 출격 선택 단계에서 **미방문 유파만 선택 후보**로 표시한다.

각 후보가 최소한 보여줄 정보:

- 유파 이름/문양
- 전장 핵심 위험 한 줄
- 해당 유파 Boss 철학 한 줄
- 회수 가능한 `유파 흔적` 표시
- 현재 적용될 `Stage 1/2/3/4` 위험 단계

처음부터 모든 세부 Boss 패턴을 공개하지는 않되, 플레이어가 정보 없는 랜덤 버튼을 누르는 수준으로 숨기지 않는다.

방문 완료 유파는 `흔적 회수 완료 / Boss 격파` 상태로 잠기며 같은 Run에서 재선택하지 않는다.

## 밸런스 / 기술 구조 원칙

향후 구현에서는 유파와 stage를 서로 독립된 데이터 축으로 유지한다.

```text
SchoolEncounterDefinition
  + StageDifficultyProfile(stage_index)
  + RunBuildState
  → EncounterSnapshot
```

금지:

- `if school == bongma and stage == 3` 식의 조합별 하드코딩을 기본 운영 방식으로 만드는 것.
- 24개 방문 순열마다 별도 enemy stat table을 만드는 것.
- 유파 Boss의 패턴 의미를 stage마다 교체하는 것.

권장:

- 유파별 `base threat budget`을 먼저 정규화한다.
- stage_index가 공통 scalar/profile을 적용한다.
- 예외가 필요한 경우에도 유파별 1~4 stage 조합을 개별 튜닝하기보다 `boss_hp_scale`, `spawn_pressure_scale`, `cadence_scale` 같은 공통 축으로 해결한다.

## 보상과 stage 보정

모든 Run에서 네 유파를 결국 전부 클리어하므로 Stage 4라는 이유만으로 별도의 새 보상 체계를 만들지 않는다.

- 기존 Boss reward `3 choose 1`, 최소 1개 유파 관련 보장 유지.
- 흔적은 방문 유파마다 1회 회수하는 진행 핵심으로 유지.
- stage 보정은 우선 **난이도 정상화** 역할이다.
- later-stage 추가 보상이 필요하다는 플레이테스트 증거가 생기면 reward weighting을 조정할 수 있으나 새 희귀도/통화 축을 만들지 않는다.

## 벤치마크 적용 원리

- Darkest Dungeon II는 공식 업데이트에서 Region 번호에 따라 적 Max HP와 Damage 보정을 단계적으로 높이는 방식을 사용한 사례가 있다. `콘텐츠 정체성`과 `진행 단계 난이도`를 분리하는 원리만 참고한다.
- Slay the Spire 계열의 경로 선택처럼 플레이어가 향후 위험/보상 순서를 판단하는 재미를 참고하되, 닌자의 신에서는 4유파를 모두 방문해야 하므로 `경로 누락`이 아니라 **순서 최적화**에 초점을 둔다.

## 5회 적대적 검토

### Loop 1 · 24순열 QA 폭증

문제: 자유 순서면 24개 route가 생긴다.

대응:
- 24개 route마다 수치를 제작하지 않는다.
- 유파 base definition 4개 + StageDifficultyProfile 4단계만 검증한다.
- 핵심 조합 검증은 `각 유파 × stage 1~4 = 16 encounter configurations`로 축소하고 route 순열은 state transition/duplicate prevention 테스트로 별도 검증한다.

### Loop 2 · 쉬운 유파를 4번째에 두는 정답 루트

문제: 기본 보스 강도가 다르면 항상 같은 유파를 마지막에 두는 메타가 생길 수 있다.

대응:
- 네 유파 Boss의 base threat budget을 동일 범위로 정규화한다.
- TTK, 피격 위험 시간, 화면 점유율, spawn pressure를 함께 본다.
- 승률/선택 순서 데이터에서 특정 유파가 Stage 4로 과도하게 몰리면 해당 유파의 base budget을 조정한다.

### Loop 3 · Stage 4 체력 스펀지

문제: HP만 +40%하면 전투가 늘어질 수 있다.

대응:
- HP/피해/spawn/cadence를 분산 적용한다.
- Boss TTK P50/P90과 overtime 비율을 측정해 HP부터 낮춘다.

### Loop 4 · 초보자의 정보 없는 선택

문제: 다른 유파 전장을 모르면 자유 선택이 무의미하다.

대응:
- 선택 UI에 위험 철학/흔적/현재 Stage 위험단계를 짧게 공개한다.
- 첫 Run에서도 최소한 `이 전장은 어떤 문제를 주는가`를 한 문장으로 보여준다.

### Loop 5 · 플레이어 성장보다 stage 보정이 더 빨리 증가

문제: Workbench 성장보다 적 보정이 과하면 후반이 억지로 어려워진다.

대응:
- stage scalar는 예상 Run power curve와 함께 측정한다.
- Stage 1→4 승률 하락이 지나치면 multiplier를 낮추고, 영구 Meta 수치로 메우지 않는다.
- DEC-008의 `Run의 힘은 Run에서 만든다` 원칙을 보호한다.

## 장기 재검토 조건

- 자유 순서가 실제로 빌드/보스 상성에 따른 의미 있는 판단을 만들지 못하면 흔적/보상 정보의 차이를 강화한다.
- 특정 유파를 항상 먼저/마지막에 두는 선택률이 과도하면 해당 유파 base threat budget과 reward timing을 재검토한다.
- Stage 4 overtime이 과도하면 HP/pressure scalar를 재튜닝한다.
- stage별 완전히 다른 보스 패턴 세트를 추가하는 것은 공통 scaling만으로 난이도와 반복성을 확보할 수 없다는 evidence가 있을 때만 재검토한다.

## DEC-015 최종 한 줄

**`각 휴식마다 아직 방문하지 않은 유파 중 다음 전장을 자유롭게 선택한다. 유파는 encounter의 정체성을 결정하고, 몇 번째로 방문했는지는 공통 StageDifficultyProfile로 HP·피해·spawn/패턴 압박을 보정한다. 4유파는 한 Run에서 모두 한 번씩 방문한다.`**

## 다음 미확정 핵심

`DEC-PENDING-WORLD-016`: **각 유파에서 회수하는 '흔적'의 정확한 정체와 기능**. 흔적이 단순 진행 열쇠인지, 즉시 Run 빌드에 영향을 주는지, 마지막 휴식/최종보스에서 4개를 어떻게 사용하는지 결정한다.
