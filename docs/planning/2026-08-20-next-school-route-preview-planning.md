# 닌자의 신 · 다음 유파 경로 Preview / 선택 Commit 기획

상태: `APPROVED_BY_USER_CONTINUATION_2026-08-20`
결정 ID: `DEC-2026-08-20-025`
기준 branch: `docs/world-core-planning-20260820`

관련 정본:

- `docs/planning/2026-08-20-current-canon-checkpoint-dec014-025.md`
- `docs/planning/2026-08-20-four-school-route-order-planning.md`
- `docs/planning/2026-08-20-school-traces-ecosystems-progressive-gimmicks.md`
- `docs/planning/2026-08-20-school-trace-acquisition-encounter-flow.md`
- `docs/planning/2026-08-20-school-access-reward-pool-planning.md`
- `docs/planning/2026-08-20-dec021-item-canon-access-affinity-amendment.md`
- `docs/superpowers/specs/2026-08-11-mvp4-backpack-combination-design.md`
- `scripts/ui/school_selection_ui.gd`
- `scripts/ui/rest_flow_ui.gd`

이 문서는 planning-only다. 제품 코드·Scene·Resource·runtime은 수정하지 않는다.

---

## DEC-2026-08-20-025 · 위험·보상 Preview 카드 + Workbench 안의 가변 경로 선택

### 최종 한 줄

**다음 전장은 미방문 유파의 `위험·보상 Preview 카드`를 비교해 선택한다. 카드에는 현재 Stage의 유파 기믹, Monster/Elite/Boss 핵심 위험, 흔적 안정화 후 열리는 전승, 현재 백팩과의 태그·조합 연결, 최종전 지원 순서를 보여주되 정확한 HP·spawn표·보상 RNG는 숨긴다. 첫 전장은 별도 확인으로 확정하고, 이후 전장은 Persistent Workbench에서 임시 선택·변경할 수 있으며 Fate가 백팩과 다음 경로를 함께 commit한다.**

---

## 목표

- 자유 경로를 정보 없는 취향 버튼이 아니라 현재 빌드와 미래 전승을 비교하는 전략 선택으로 만든다.
- 경로를 고른 뒤 백팩을 대응 조정할 수 있게 한다.
- 모든 상세 수치를 공개해 전투가 정답 계산표가 되지 않게 한다.
- 시작 유파 심화, 다른 유파 개방, 교차 조합, 어려운 유파 선처리 등 여러 합법적 이유를 카드에서 읽게 한다.
- Windows, keyboard/gamepad, touch에서 같은 정보와 완료 경로를 제공한다.
- UI가 encounter, reward, backpack 규칙을 재계산하지 않고 domain snapshot만 표시하게 한다.

## 비목표

- 정확한 적 HP·피해·spawn 시각표 공개.
- 보스 공격별 프레임·쿨다운·피해 수치 공개.
- 향후 Shop/Chest 결과 예측.
- AI가 정답 경로 하나를 `추천`하는 점수 시스템.
- 승률·예상 DPS·예상 TTK 계산.
- 한 번 정한 전체 4유파 순서를 Run 시작에 미리 고정.
- 경로 변경에 GOLD나 별도 화폐를 요구.
- Route 선택 전용 메타 해금 또는 별도 지도 경영 시스템.

---

# 비교 대안

## A · 유파 문양 + 위험 한 줄만 표시

카드 정보:

- 유파 이름/문양.
- 현재 Stage 번호.
- 위험 한 줄.

장점:

- 빠르고 제작비가 작다.
- 첫 화면이 간결하다.

문제:

- 왜 지금 이 유파를 먼저 가야 하는지 빌드·전승·조합 관점에서 판단하기 어렵다.
- 흔적 접근권과 자유 경로의 전략성이 UI에 드러나지 않는다.
- 결국 익숙한 유파나 외형만 보고 선택할 가능성이 높다.

비채택.

## B · 요약 카드 + 상세 패널 + 현재 빌드 연결 · **채택**

항상 보이는 카드:

- 유파/문양.
- 전장 위험 철학.
- 현재 Stage에서 추가되는 기믹.
- 흔적/전승 접근 결과.
- 현재 빌드의 태그·조합 연결.

선택/포커스 시 상세 패널:

- Core Monster 역할 3종.
- Elite/Boss 핵심 위험.
- 현재 Stage 공통 압박.
- 안정화 뒤 열리는 대표 전승.
- 최종전 지원 순서.

장점:

- 첫눈에는 간결하고 필요할 때 충분한 정보를 제공한다.
- 현재 빌드와 미래 선택을 함께 비교할 수 있다.
- 정확한 수치를 공개하지 않아 발견·전투 읽기를 보존한다.
- 4→3→2→1 후보 감소에 자연스럽게 대응한다.

채택.

## C · 전체 전술 Dossier

공개 내용:

- 정확한 적 roster와 spawn 시각.
- HP·피해 multiplier.
- Elite/Boss 공격 cooldown.
- 예상 reward weight.

장점:

- 계산 가능한 전략 선택.
- 고난도 플레이어에게 명확하다.

문제:

- 선택 화면이 전투 데이터 표로 변한다.
- 튜닝 변경마다 UI 문구와 수치를 함께 유지해야 한다.
- 첫 플레이의 발견과 위험 읽기를 약화한다.
- 초보자에게 정보량이 과하다.

비채택.

## D · 첫 방문은 대부분 비공개, 재방문부터 공개

장점:

- 탐험과 발견이 강하다.
- 도감 메타와 연결하기 쉽다.

문제:

- 첫 Run 자유 선택이 정보 없는 버튼이 된다.
- Stage 3/4의 새로운 기믹을 모른 채 선택하면 불공정하다.

부분 흡수:

- 행동에 필요한 최소 위험·Stage 기믹·전승 보상은 첫 방문부터 항상 공개한다.
- 세부 lore, 과거 전투 기록, 정확한 Monster 설명은 발견 후 도감에서 확장할 수 있다.

---

# 선택 시점과 Commit 경계

## 첫 전장

```text
시작 유파 선택
→ Stage 1 경로 Preview
→ 미방문 4유파 카드 비교
→ 유파 선택
→ `이 전장으로 출격` 명시 확인
→ Initial Preview
→ COMBAT
```

- 시작 유파 선택과 첫 전장 선택은 서로 다른 결정이다.
- 봉마로 시작해 천술 전장을 먼저 선택할 수 있다.
- 첫 전장에는 아직 Persistent Workbench/Fate가 없으므로 명시적 출격 확인이 경로 commit이다.
- 시작 유파 signature access package는 이미 OPEN이며 카드에 `이미 개방`으로 정확히 표시한다.

## Stage 2~4

```text
Boss 격파
→ RESULT
→ 강제 Boss Reward 3택
→ 공동 지부 귀환
→ 흔적 STABILIZED / 전승 package OPEN
→ Persistent Workbench
   ├─ Shop / Chest / Backpack / Combination
   └─ 다음 출격 패널에서 미방문 유파 Preview 비교
→ pending_next_school_id 임시 선택
→ 필요하면 백팩·구매·조합을 다시 조정
→ Fate 진입 Gate
→ Fate 선택
→ 백팩 + Fate + 다음 유파를 하나의 commit으로 확정
→ Final Preview
→ 다음 COMBAT
```

### 왜 Fate 전에 보여주는가

Fate 이후에 처음 경로를 보여주면 플레이어가:

- 다음 전장의 위험에 맞춰 아이템을 바꾸거나,
- 새 조합을 완성하거나,
- 상점 리롤을 판단하거나,
- 가방 공간을 재구성할

기회를 잃는다.

따라서 다음 유파 선택은 Workbench 안에서 provisional state로 유지하고 Fate가 최종 commit한다.

### 변경 가능 범위

Fate 전:

- 카드 간 선택 변경 가능.
- 선택 변경 비용 없음.
- Shop/Chest RNG를 다시 굴리지 않음.
- 선택 변경만으로 경제·백팩 canonical state를 변경하지 않음.

Fate 후:

- 다음 유파 변경 불가.
- Preview 취소로 Workbench에 되돌아가는 새 rollback 경로를 첫 Vertical Slice에 추가하지 않는다.
- 잘못된 입력을 막기 위해 Fate 선택 직전에 `Stage N · 유파명`을 다시 표시한다.

## Stage 4

- 미방문 유파가 1개면 자동으로 provisional selection한다.
- 선택 화면을 완전히 생략하지 않고 마지막 유파 카드와 Stage 4 추가 기믹을 Workbench에서 자동 확장한다.
- 별도 `선택` 클릭은 요구하지 않지만 Fate commit 전 정보를 읽을 수 있다.

## 4유파 완료 후

- 다음 유파 패널은 선택 UI가 아니라 `4흔적 결속 / 난세 재앙핵 준비` 상태로 전환한다.
- Final Boss는 유파 route 후보로 취급하지 않는다.

---

# 화면 정보 구조

## 공통 상단 Header

모든 후보에 같은 Stage 보정을 카드마다 반복하지 않는다.

```text
다음 출격 3 / 4
공통 Stage 위험 III · 연계
적 내구 ↑↑ · 피해 ↑ · spawn 압박 ↑↑
최종전 지원 순서: 이번 선택은 3번째
```

- 정확한 multiplier 대신 상대 압박을 text+icon으로 표시한다.
- `위험 I/II/III/IV`만 색으로 구분하지 않고 숫자·문자·도형을 함께 사용한다.
- Stage 기믹 단계 이름은 `기본 / 상호작용 / 연계 / 숙련`을 사용한다.

## Route History Strip

```text
1 흑영 ✓ → 2 봉마 ✓ → 3 [선택 중] → 4 ?
```

- 평정 순서를 기억시킨다.
- Final Boss의 4유파 지원 순서와 연결한다.
- 완료 유파는 다시 선택할 수 없다.
- 완료 유파의 문양에는 `흔적 안정화 / Boss 평정` 상태를 함께 표시한다.

## 후보 카드 · 항상 보이는 정보

1. **유파 이름·문양**
2. **전투 철학 한 줄**
3. **현재 Stage 추가 기믹**
4. **Elite/Boss 위험 한 줄**
5. **흔적·전승 결과**
6. **현재 빌드 연결 요약**
7. **최종전 지원 순서 슬롯**

예시:

```text
천술류
상태를 겹쳐 연쇄 반응을 만든다

Stage 3 추가: 반응 연쇄
Elite/Boss: 원소 영역이 지연 연쇄

평정 직후 Boss Reward: 천술 전승 후보 1개 보장
지부 안정화: 수둔 / 뇌둔 / 화둔 package OPEN

현재 빌드 연결
- 일본도 보유 → 뇌명도 재료 1/2
- 근접 태그 2개와 뇌둔 affinity 연결

최종전: 3번째 천술 지원
```

## 상세 패널

포커스/선택한 카드의 아래 정보를 표시한다.

### 1. Monster 문법

- Swarm 역할/working name.
- Priority Threat 역할/working name.
- Anchor 역할/working name.

정확한 spawn 수·시각은 표시하지 않는다.

### 2. Elite / Boss

- Elite의 핵심 행동 1~2개.
- Boss의 핵심 철학과 현재 Stage에서 강화되는 패턴.
- 표식/상태/소환 면역 같은 하드카운터가 없다는 것을 별도 문장으로 반복하지는 않는다. 이는 시스템 보호 규칙이다.

### 3. 전승 접근

두 시점을 분리한다.

```text
Boss 평정 직후
→ 강제 Boss Reward에서 해당 유파 signature 후보 1개 보장

지부 귀환 / 흔적 STABILIZED
→ 해당 유파 package가 이후 Shop / Chest / Boss Reward pool에 OPEN
```

### 4. 현재 빌드 연결

표시 가능한 연결:

- 활성 백팩 tag와 해당 유파 affinity의 교집합.
- 보유 중인 조합 재료와 해방 유파 package의 recipe bridge.
- 이미 개방된 package 여부.
- 해당 package 대표 3종 중 현재 메타에서 실제 사용 가능한 수.

표시하지 않는 것:

- 예상 DPS.
- 예상 승률.
- `추천도 92점`.
- 현재 빈칸에 들어갈 확률처럼 불안정한 자동 예측.

## 숨기는 정보

- 정확한 HP / 피해 multiplier.
- 정확한 spawn 순서·시각표.
- 공격별 cooldown과 프레임.
- Shop/Chest/Boss Reward의 실제 다음 결과.
- Final Boss ally trigger의 정확한 HP threshold.
- 아직 만나지 않은 story reveal.

---

# 유파별 Player-facing 요약 문구

아래 문구는 working copy다. 최종 네이밍/톤은 Writing·Visual 단계에서 다듬는다.

| 유파 | 위험 철학 | Elite/Boss 요약 | 대표 전승 |
|---|---|---|---|
| 봉마 | 식신·봉인·결계가 공간을 점유한다 | 결계와 식신의 연결을 읽고 이동 동선을 다시 만든다 | 깨달음 / 결계술 / 대형 소환진 |
| 천술 | 원소 영역이 겹치면 반응과 연쇄가 발생한다 | 반응 순서와 겹침 지점을 읽어 연쇄를 피한다 | 수둔 / 뇌둔 / 화둔 |
| 귀인 | 근접 압박이 오래 이어질수록 적의 귀혈이 고조된다 | 붙어 싸울 때와 큰 마무리 전에 빠질 때를 구분한다 | 체술단련 / 호신 부적 / 일본도 |
| 흑영 | 표식·연막·재배치가 위험 표적을 만든다 | 표식 누적과 예고 처형의 우선순위를 읽는다 | 수리검 / 은신술 / 독침술 |

## Stage별 추가 기믹 문구

| Stage | 봉마 | 천술 | 귀인 | 흑영 |
|---:|---|---|---|---|
| 1 | 단일 봉인진 | 단일 원소 영역 | 기본 근접 압박 | 기본 표식 |
| 2 | 결계 공명 | 2원소 반응 | 귀혈 임계 | 연막 재배치 |
| 3 | 연결 봉인 | 반응 연쇄 | 혈기 공명 | 표식 연계 |
| 4 | 이동 봉진 | 오행 순환 | 광전 연계 | 암영 척살 연계 |

- Stage 4 카드에서도 동시에 읽어야 하는 고급 기믹은 최대 2개다.
- 카드 문구는 현재 실제 `StageDifficultyProfile.gimmick_tier`와 일치해야 한다.

---

# 현재 빌드 연결 규칙

## 목적

`현재 빌드와 연결됨`은 정답 추천이 아니라 플레이어가 이미 가진 재료와 미래 전승의 관계를 설명한다.

## 입력

```text
starting_school_id
active_backpack_item_ids
active_backpack_tags
owned_recipe_components
opened_signature_packages
meta_available_item_ids
candidate_school_id
```

## 출력 예

```text
연결 2
- 원거리 tag 2개
- 수둔 보유 → 은신술 개방 시 물안개 가능
```

또는:

```text
직접 연결 없음
- 해당 유파를 선택해도 현재 빌드를 유지할 수 있음
- 해방 유파 사용은 강제되지 않음
```

## 보호 규칙

- 연결 개수가 많다고 자동 추천 테두리를 주지 않는다.
- 교차 유파 조합을 가진 후보만 항상 우위로 표시하지 않는다.
- 시작 유파 package가 이미 열려 있으면 `이미 개방`으로 표시한다.
- 같은 item이 여러 affinity/recipe 연결을 가져도 canonical ID 기준으로 중복 계산하지 않는다.
- item access package와 affinity를 혼동하지 않는다.

---

# Boss Reward 선행 접근 보정

DEC-024의 순서는:

```text
Boss 격파
→ RESULT
→ 강제 Boss Reward
→ 지부 귀환
→ 흔적 STABILIZED
→ package OPEN
```

이때 Boss Reward가 `방금 해방한 유파 후보 1개`를 보여주려면 전체 package OPEN보다 앞선 제한적 접근이 필요하다.

따라서 다음을 명시한다.

```text
BOSS_REWARD_PROVISIONAL_ACCESS
= Boss 격파가 검증된 해당 강제 Boss Reward 1회에 한해
  그 유파 signature package에서 Slot B 후보를 만들 수 있음

STABILIZED_ACCESS
= Boss Reward 처리 후 공동 지부 귀환에서 흔적이 안정화되면
  이후 Shop / Chest / Boss Reward pool에 package가 정식 OPEN
```

- provisional access는 다른 Shop/Chest roll에 사용하지 않는다.
- Boss Reward를 받았다는 이유만으로 흔적 안정화 전에 전투 modifier가 생기지 않는다.
- 선택하지 않은 후보는 보유 아이템이 아니다.
- 이 보정은 DEC-021의 `방금 해방한 유파 후보 보장`과 DEC-024의 `지부 안정화 후 package OPEN`을 동시에 만족시킨다.

Route Preview의 보상 설명도 두 시점을 분리해서 표시한다.

---

# Windows / Android / 입력 계약

## Windows

- 후보 4개: 2×2 grid 또는 충분한 폭에서 4열.
- 후보 3개: 3열.
- 후보 2개: 2열.
- 후보 1개: 중앙 단일 카드 + 상세 패널 자동 확장.
- 공통 Stage header와 Route History는 카드 위에 고정.
- 포커스 카드의 상세는 오른쪽 또는 하단 panel에 표시.
- 카드 글자가 작아지는 4열을 강제하지 않는다.

## Android

- 한 화면에 카드 1개를 충분한 크기로 표시하는 pager/carousel을 기본으로 한다.
- swipe는 보조 입력이며 이전/다음 명시 버튼을 제공한다.
- 하단에 고정된 `선택` 또는 `이 전장으로 출격` 버튼을 둔다.
- 핵심 정보는 접힌 tooltip, hover, long-press에만 숨기지 않는다.
- 최소 interactive target은 기존 기준대로 약 `48dp × 48dp` 이상.

## Mouse

- 카드 클릭으로 provisional select.
- 상세 열기/닫기는 별도 affordance 제공.
- hover는 보조 강조일 뿐 필수 정보 경로가 아니다.

## Keyboard / Gamepad

- 방향 입력으로 카드 focus 이동.
- Confirm으로 provisional select.
- 별도 Details action 또는 focus한 카드에서 하단 상세를 항상 읽을 수 있음.
- Cancel은 카드 선택을 삭제하지 않고 Workbench 주 surface로 focus를 돌려준다.
- Fate commit 전 다시 route panel에 들어와 변경 가능.

## Touch

- tap 1회로 카드 선택·상세 표시.
- 고정 Confirm 버튼으로 확정 의도를 명시.
- precision swipe 또는 double tap을 필수로 하지 않는다.

## 접근성

- 유파/위험/완료 상태를 색만으로 표시하지 않는다.
- 문양 + 이름 + 상태 text + outline을 병행한다.
- focus/selected/completed/locked가 서로 다른 shape·icon을 갖는다.
- Stage 압박 화살표에는 text label을 함께 둔다.

---

# 데이터와 책임 경계

## `SchoolRoutePreviewDefinition`

Authoring data:

```text
school_id
school_display_name
emblem_ref
battle_philosophy_summary
monster_role_summaries
elite_summary
boss_summary
stage_gimmick_summary[1..4]
signature_access_item_ids
ally_support_summary
```

## `RoutePreviewResolver`

입력:

```text
SchoolRoutePreviewDefinition[4]
StageDifficultyProfile
RunTraceState
BackpackBuildSnapshot
MetaAvailabilitySnapshot
```

출력:

```text
RouteSelectionSnapshot
├─ stage_header
├─ route_history
├─ candidate_cards[]
├─ provisional_selected_school_id
└─ commit_requirements
```

### `RouteCandidateSnapshot`

```text
school_id
visited / selectable / auto_selected
risk_summary
current_stage_gimmick
monster_role_summary
elite_summary
boss_summary
provisional_boss_reward_items
stabilized_package_items
build_tag_links
recipe_links
package_already_open
ally_support_order
```

## `RestBackpackSession`

- `pending_next_school_id`를 provisional state로 소유한다.
- 선택 변경은 edit/session state이며 Run route order를 즉시 바꾸지 않는다.
- Stage 4 한 후보는 자동 provisional select한다.

## Commit owner

Fate 선택 transaction이 다음을 하나의 경계로 확정한다.

```text
committed backpack snapshot
selected Fate
next_school_id
next_stage_index
```

부분 commit을 허용하지 않는다.

## UI

- snapshot을 렌더링한다.
- `route_candidate_selected(school_id)` intent를 emit한다.
- tag/recipe/위험/방문 가능 여부를 재계산하지 않는다.
- 정답 추천 점수를 만들지 않는다.

---

# 오류와 회복

## 선택 후보 0개인데 4유파 미완료

- Final Boss로 자동 진행하지 않는다.
- `경로 상태를 복구하지 못했습니다` 오류와 재시도/지부 복귀 경로를 제공한다.
- telemetry/debug snapshot에 visited/stabilized/route order를 기록한다.

## 방문 완료 유파 재선택

- domain이 intent를 거절한다.
- 이전 합법 provisional selection을 유지한다.
- UI card는 완료 상태로 selectable=false여야 한다.

## package 정보 누락

- school identity와 위험 정보는 계속 표시한다.
- 보상 영역은 `전승 정보를 불러오지 못했습니다`로 표시한다.
- 존재하지 않는 item 이름을 추정해서 채우지 않는다.

## current-build 분석 불가

- `현재 빌드 연결 정보 없음`으로 표시한다.
- 경로 선택 자체를 막지 않는다.

## Fate를 route 미선택 상태에서 시도

- Fate commit을 거절한다.
- route panel로 focus/scroll을 이동한다.
- 메시지는 `다음 유파를 선택한 뒤 운명을 확정하세요`처럼 다음 행동을 포함한다.

## 빠른 반복 입력

- route commit은 action-level guard를 사용한다.
- 같은 school id가 route order에 중복 append되지 않는다.

---

# 벤치마크 적용

## Slay the Spire 2 · Mega Crit 공식 Map 변경

Mega Crit는 모바일에서 작은 map icon을 누르기 어렵고 room type 구분도 어려웠다는 이유로 icon을 키우고 색을 추가했다고 설명했다. 또한 경로 위에 직접 표시하는 map drawing을 소개했다.

적용:

- 카드와 문양을 작은 지도 점으로 축소하지 않는다.
- color 외에 text·icon·outline을 함께 사용한다.
- Route History Strip으로 선택 순서를 시각화한다.

비적용:

- Slay the Spire의 room node 구조를 복사하지 않는다.

공식 근거:
- https://www.megacrit.com/news/2024-11-07-neowsletter-issue-4/

## Dead Cells · Motion Twin 공식 Press Kit / Patch Notes

Motion Twin은 플레이어가 현재 build, play style, mood에 맞는 경로를 고를 수 있다고 설명한다. World Map은 발견한 biome과 경로, 현재 Run에서 이동한 길을 보여준다. Cursed Biome은 출구 위 skull icon으로 위험을 알리고 추가 loot 이득을 함께 제공한다.

적용:

- 현재 백팩 tag/recipe와 후보 유파 전승의 연결을 표시한다.
- 위험만 보여주지 않고 평정 후 열리는 전승과 Boss Reward를 함께 표시한다.
- 완료 경로와 현재 순서를 History Strip에 남긴다.

비적용:

- biome를 건너뛰는 구조나 cursed reward 수치를 복사하지 않는다.
- 닌자의 신은 4유파를 모두 방문하며 순서만 자유 선택한다.

공식 근거:
- https://motiontwin.com/presskit/
- https://dead-cells.com/patchnotes/25
- https://dead-cells.com/patchnotes

---

# 적대적 검토

## Loop 1 · 정보 과부하

위험:

4개 카드에 Monster·Elite·Boss·전승·빌드 정보를 모두 펼치면 Workbench보다 더 복잡한 화면이 된다.

보호:

- 카드에는 요약 6~7항목만 표시.
- Monster 3역할과 세부 연결은 focus 상세 패널에 둔다.
- 정확한 수치·spawn표를 숨긴다.

## Loop 2 · UI가 정답 경로를 대신 선택

위험:

`현재 빌드 연결 3` 같은 숫자가 추천 점수처럼 읽힐 수 있다.

보호:

- 연결 수치만 강조하지 않고 실제 이유 문구를 표시한다.
- `추천`, `최적`, 승률, 점수를 사용하지 않는다.
- 직접 연결 없음도 정상 선택으로 설명한다.

## Loop 3 · 경로를 고른 뒤 대응할 수 없음

위험:

Fate 이후 경로를 선택하면 백팩 조정이 불가능하다.

보호:

- Workbench에서 provisional select.
- Fate가 route와 build를 함께 commit.
- 선택 전후로 Shop/Backpack/Combination을 자유 왕복.

## Loop 4 · starting school first가 무조건 손해

위험:

시작 유파 package가 이미 열려 있어 같은 유파를 먼저 평정하면 새 package 이득이 없다.

보호:

- 카드에 `이미 개방`을 투명하게 표시한다.
- 같은 유파를 먼저 가는 이점은 익숙한 전투 철학과 현재 build continuity이며 별도 숨은 보너스를 만들지 않는다.
- 특정 route 선택률이 지나치게 낮으면 route UI가 아니라 encounter/reward budget을 플레이테스트로 재검토한다.

## Loop 5 · Boss Reward와 안정화 순서 충돌

위험:

Boss Reward는 안정화 전인데 방금 평정한 유파 후보를 보여줘야 한다.

보호:

- forced Boss Reward 1회에만 provisional access를 허용.
- 지부 귀환 후에만 full package를 Shop/Chest에 OPEN.
- 카드에서 두 시점을 분리해 설명.

## Loop 6 · 모바일 카드 축소

위험:

4개 후보를 한 화면에 강제로 넣으면 읽을 수 없다.

보호:

- Android는 한 카드 pager + 명시 이전/다음 버튼.
- 핵심 선택 버튼 고정.
- hover/swipe-only 금지.

## Loop 7 · 마지막 Stage의 무의미한 화면

위험:

후보가 하나뿐인데 선택 화면을 반복하면 피로하다.

보호:

- Stage 4는 자동 provisional select.
- 카드/상세는 읽을 수 있게 자동 확장.
- Fate가 최종 commit하므로 별도 confirm click은 생략.

---

# 검증 계약

## Domain / deterministic tests

1. 첫 전장에는 미방문 4유파 후보가 정확히 한 번씩 나온다.
2. Stage 2/3/4 후보 수는 3/2/1이다.
3. 방문 완료 유파는 selectable=false 또는 후보에서 제외된다.
4. 모든 후보는 같은 현재 stage_index를 사용한다.
5. 카드 순서는 canonical school order로 deterministic하다.
6. package access와 affinity가 별도 데이터로 유지된다.
7. starting school package는 `already_open=true`다.
8. Boss Reward provisional access는 해당 1회에만 적용된다.
9. 지부 안정화 전 Shop/Chest에는 package가 열리지 않는다.
10. route selection 변경은 RunTraceState route order를 즉시 변경하지 않는다.
11. Fate commit 성공 시 selected Fate, backpack snapshot, next school이 atomic하게 확정된다.
12. commit 실패 시 세 상태가 모두 이전 값으로 유지된다.
13. Stage 4 한 후보는 자동 provisional select된다.
14. same item이 여러 affinity/recipe link에 걸려도 ID 기준 중복 제거된다.
15. route order에 같은 school이 두 번 append되지 않는다.
16. 4유파 완료 후 school candidate가 아니라 Final Boss context로 전환된다.

## UI / input tests

1. Windows 4/3/2/1 카드 배치에서 text clipping이 없다.
2. Android pager는 swipe 없이도 모든 후보 접근 가능하다.
3. mouse, keyboard/gamepad, touch 모두 route select와 완료가 가능하다.
4. hover/long-press 없이 핵심 정보가 보인다.
5. focus, selected, completed, locked가 색 외 요소로 구분된다.
6. route 미선택 Fate 시 route panel로 focus가 복귀한다.
7. Stage 4 자동 선택 상태가 screen reader/text label로 전달된다.
8. Preview에 확정된 school, Stage, 추가 gimmick, ally order가 표시된다.

## Human usability questions

- 첫 플레이어가 10~30초 안에 후보 간 차이를 설명할 수 있는가.
- 선택 이유를 `외형`이 아니라 위험·전승·현재 빌드 중 하나로 말할 수 있는가.
- 카드 정보가 너무 많아 Workbench 흐름을 끊지 않는가.
- route 선택 후 백팩을 다시 조정하는 행동이 자연스럽게 일어나는가.
- Stage 4 자동 선택이 생략처럼 느껴지지 않고 마지막 위험을 예고하는가.

## Player Experience questions

- 자유 순서가 실제 Run 기억을 만드는가.
- 특정 유파가 항상 먼저/마지막에 고정되지 않는가.
- 새 유파 전승 개방과 기존 빌드 심화가 모두 매력적인가.
- 최종전 지원 순서가 경로 여정의 기억으로 남는가.
- 정보가 충분하지만 전투를 하기 전에 이미 다 안다는 느낌은 피하는가.

---

# 현행 runtime 차이 · 구현 전 MUST_RECONCILE

현재 `SchoolSelectionUI`는 시작 유파 4버튼을 한 번 선택하면 바로 숨고 `school_selected`만 emit한다. 시작 유파와 첫 전장 route를 분리하지 않는다.

현재 `RestFlowUI`는:

```text
RESULT → SHOP → FATE → PREVIEW / COMPLETE
```

의 선형 view만 가지며 Persistent Workbench와 다음 유파 route panel이 없다.

현재 `MainController`와 `StageFlowController`는:

- 3 segment 고정.
- timer 0에서 즉시 BOSS.
- 다음 school route state 없음.
- Fate 후 next segment는 tier index만 증가.

따라서 DEC-025는 현재 구현 완료 상태가 아니며, 향후 최신 전체 Run migration에서 구현해야 한다.

---

# 명시적 보호 / Supersede

- DEC-015의 `유파 이름/문양 + 위험/Boss/흔적/Stage 표시` 최소 원칙을 이 문서가 상세화한다.
- `Fate 종료 뒤 처음 route 선택` 해석은 `SUPERSEDED_BY_DEC-025_WORKBENCH_PROVISIONAL_ROUTE`다.
- 다음 4유파 전체 순서를 Run 시작에 고정하지 않는다.
- 정확한 HP·spawn표 공개를 요구하지 않는다.
- route score/recommendation AI를 추가하지 않는다.
- 기존 19종 아이템, 3조합, 5가방, affinity, pool-first reward를 유지한다.
- 유파 흔적은 자동 전투 버프가 아니라 전승 접근권이다.
- 제품 코드·Scene·Resource·runtime은 이번 기획으로 수정하지 않는다.

## 다음 미확정 핵심

`DEC-PENDING-WORLD-026`: **4유파 Elite/Boss의 실제 공격 세트와 Stage 1~4 패턴 조합 budget**. 현재 working name과 전투 철학을 바탕으로 각 유파의 `Core Monster 3 + Elite 1 + Boss 1`이 정확히 어떤 공격을 몇 개 소유하고, Stage별로 어떤 기존 패턴을 활성화/조합할지 잠가야 한다.
