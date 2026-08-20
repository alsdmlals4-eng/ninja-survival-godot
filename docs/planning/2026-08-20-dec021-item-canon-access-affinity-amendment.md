# 닌자의 신 · DEC-021 아이템 정본 / 접근 / 친화도 보정

상태: `APPROVED_BY_USER_2026-08-20`
기준 branch: `docs/world-core-planning-20260820`

선행 정본:
- `docs/superpowers/specs/2026-08-09-mvp2-four-schools-design.md`
- `docs/superpowers/specs/2026-08-09-mvp2-manual-tuning.md`
- `docs/planning/2026-08-11-mvp4-content-balance-v1.md`
- `docs/planning/2026-08-20-school-access-reward-pool-planning.md`

제품 코드·Scene·Resource·runtime은 이 문서로 수정하지 않는다.

---

## DEC-2026-08-20-021A · 기존 기술·아이템 정본과 접근 레이어를 분리한다

이 보정은 DEC-021의 `Universal 7 + 유파별 3`을 **아이템의 소속/정체성 분류**로 읽는 해석을 폐기한다.

### 1. 네 계층을 섞지 않는다

```text
A. 시작 유파 기술 정본
   = 대표 전투 인법 / 대표 보조 인법 / 고유 자원 / 오의 / 대표 시너지

B. 아이템 정본
   = 이름 / 효과 / footprint / 가격 / 태그 / 친화 유파 / 조합식

C. Run 접근 상태
   = 지금 획득 가능한가 / 어느 흔적으로 열렸는가

D. 보상 lane
   = 이번 후보에서 현재 빌드·신규 유파·가교 중 어떤 의미로 제시되는가
```

실제 전투력은 끝까지 `획득 → 백팩 배치 → 인접 → 조합`으로 결정한다.

### 2. 시작 유파 기술과 백팩 인법은 다른 계층이다

시작 유파 기술은 기존 MVP-2 정본을 보호한다.

| 유파 | 전투 인법 | 보조 인법 | 고유 축 | 오의 |
|---|---|---|---|---|
| 봉마 | 공격형 식신 | 영력 순환 | 영력 | 백귀야행 |
| 천술 | 화둔·염옥진 | 오행순환 | 오행 반응 | 오행폭주 |
| 귀인 | 혈난무 | 광전사 | 귀혈 | 귀인화 |
| 흑영 | 만천화우 | 암살교범 | 암영표식 | 암영처형 |

- 흔적을 안정화해도 시작 유파 runtime은 교체되지 않는다.
- 예를 들어 천술 흔적을 얻었다고 봉마 플레이어가 `CheonsulRuntime`으로 전환되지 않는다.
- 다른 유파의 힘을 사용하려면 해당 인법/장비를 실제로 획득해 백팩에 채용해야 한다.

### 3. 기존 19종 아이템 정본을 보호한다

`2026-08-11-mvp4-content-balance-v1.md`의 다음 항목은 계속 정본이다.

- 기본 획득 아이템 19종
- 각 아이템의 이름, 가격, footprint, 효과, strong-spatial 여부, 태그
- 기존 유파 affinity 그룹
- 조합 결과 3종과 조합식
- 가방 5종

DEC-021/021A는 위 데이터를 재작성하거나 아이템 이름을 새로 만들지 않는다.

### 4. `7 + 3 + 3 + 3 + 3`은 접근 패키지 기본값이다

아래는 **첫 Vertical Slice의 획득 가능 시점**을 정하는 `RECOMMENDED_DEFAULT`이며 소속 분류가 아니다.

| 접근 패키지 | 아이템 |
|---|---|
| `always_open_access` | 행운 부적, 인법단련, 재생의 두루마리, 오의 비전서, 유파 증표, 금기의 부적, 폭탄 |
| `bongma_signature_unlock` | 깨달음, 결계술, 대형 소환진 |
| `cheonsul_signature_unlock` | 수둔, 뇌둔, 화둔 |
| `guiin_signature_unlock` | 체술단련, 호신 부적, 일본도 |
| `heukyeong_signature_unlock` | 수리검, 은신술, 독침술 |

- 시작 유파의 signature unlock package는 Run 시작부터 열린다.
- 다른 유파 package는 해당 유파 Boss 격파와 흔적 안정화 후 열린다.
- 장기 콘텐츠가 늘어날 때 이 3종은 영구 상한이 아니라 첫 signature/core package다.

### 5. 접근 패키지와 affinity는 독립이다

아이템은 접근 패키지 하나로 획득 시점을 정할 수 있지만, 친화 유파는 0개 이상을 유지한다.

예:

| 아이템 | 첫 Vertical Slice 접근 | 기존 친화도/활용 |
|---|---|---|
| 뇌둔 | 천술 signature package | 천술 + 귀인 친화, 일본도와 뇌명도 조합 |
| 폭탄 | always-open | 천술 친화, 화둔과 폭렬탄 조합 |
| 오의 비전서 | always-open | 봉마 친화 |
| 행운 부적 | always-open | 흑영 친화 |
| 유파 증표 | always-open | 선택 유파에 따라 조건부 payload가 바뀌는 공통 아이템 |

따라서 `always-open`은 무속성이라는 뜻이 아니며, `천술 signature`도 천술만 사용할 수 있다는 뜻이 아니다.

### 6. 한 아이템은 여러 보상 lane에 들어갈 수 있다

후보 생성 순서:

```text
1. access filter
   현재 Run에서 열렸는가?

2. lane qualification
   현재 빌드 연속성 / 방금 해방한 유파 / 기존 해방 유파 / 가교·조합 / 범용

3. weighting
   affinity, active tag, recipe completion, duplicate penalty 등

4. canonical item-id dedupe
   같은 아이템이 여러 lane에서 자격을 얻어도 최종 후보에는 한 번만 표시
```

예를 들어 뇌둔이 열린 뒤에는:
- 천술 해방 후보,
- 귀인 active-build 연속성 후보,
- 일본도 보유 시 조합 완성 후보

세 lane에 동시에 자격을 얻을 수 있지만 카드가 세 장 복제되지는 않는다.

### 7. DEC-021의 pool-first 원칙은 유지한다

유지:
- flat global draw 금지
- Boss Reward의 `현재 빌드 / 신규 전승 / 가교` 의미 보호
- Shop/Chest의 pool-first two-stage sampling
- 유파별 카탈로그 크기가 확률을 자동 독점하지 않도록 school/pool을 먼저 선택

보정:
- `Universal 7 + 유파별 3`은 아이템 소속표가 아니다.
- 기존 affinity를 삭제·단일화하지 않는다.
- 흔적이 자동 스탯 버프나 기술 자동 장착을 제공하지 않는다.

---

## 검증 계약

향후 데이터/보상 구현에서 확인할 것:

1. 기존 19개 ID, 효과, footprint, 가격, 조합식이 변경되지 않았는가.
2. `unlock_package`와 `affinity_school_ids`가 별도 데이터인가.
3. multi-affinity 아이템이 한 유파로 강제 축소되지 않았는가.
4. 한 아이템이 여러 lane 자격을 얻어도 ID 기준으로 중복 제거되는가.
5. 흔적만 보유하고 백팩에 채용하지 않은 유파 효과가 전투에 자동 적용되지 않는가.
6. 시작 유파 기본 runtime이 다른 흔적 획득으로 교체되지 않는가.

## 명시적 보호

- 독무·번개걸음은 후속 후보이며 MVP-4 조합으로 승격하지 않는다.
- 흑영 표식의 `최초 설계상 무기한`과 `현행 runtime 8초` 불일치는 이 문서에서 임의 해결하지 않는다. 별도 플레이 규칙 결정 대상으로 유지한다.
- 이 보정은 제품 구현 완료나 테스트 PASS를 의미하지 않는다.

## 최종 한 줄

**기술과 아이템의 기존 정본은 유지한다. 흔적은 접근권만 열고, affinity는 다대다로 보존하며, 실제 사용과 강화는 백팩 배치·인접·조합이 결정한다.**