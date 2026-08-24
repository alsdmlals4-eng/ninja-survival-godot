# Ninja Survival · AI Indie Pattern Adoption — 2026-08-24

```yaml
status: USER_DIRECTED_ADAPTATION
work_mode: PLAN
runtime_mutation: NONE
balance_mutation: NONE
source_base_merge: dff09d83c3892a70ba5fee86a59d36086889a6c5
source_radar: AI_GAME_AND_AI_ASSISTED_INDIE_RADAR
source_pattern_pack: AI_ASSISTED_INDIE_PATTERN_PACK_2026-08-24
current_project_evidence: docs/research/2026-08-11-mvp4-backpack-survivors-benchmark.md
human_validation: NOT_RUN
```

## 1. 목적

AI-assisted indie 사례에서 확인한 `Human-directed production`, `breadth control`, `player-feedback rebuild`, `RNG agency/recovery`를 현재 Ninja Survival의 5분 전투 → REST Workbench → 백팩 공간·인접·조합 루프에 맞게 적용한다.

외부 게임의 슬롯/룰렛/아이템을 복사하지 않는다. 현재 승인된 `6x6`, 시작 `4x3`, 회전, 직교 인접, Persistent Workbench, 6-slot REST buffer, 19 base items, 3 combo results, 전투 중 편집 금지 계약을 우선한다.

## 2. 판정표

| Base pattern | 판정 | Ninja Survival 적용 |
|---|---|---|
| HUMAN_DIRECTED_AI_BUILD_LOOP | ADOPT | AI가 item/recipe 후보를 늘려도 인간이 빌드 언어·가독성·재미를 승인 |
| SILENT_OMISSION_GATE | ADOPT | 아이템 추가 시 단독 효용/공간 의미/태그/recipe/UI/보상 consumer 누락 검사 |
| CONTEXT_SCOPE_AND_ARCHITECTURE_BUDGET | ADOPT | Inventory/Reward/Recipe/Combat 계산 owner 분리 유지 |
| BREADTH_AFTER_CORE_IDENTITY_LOCK | ADOPT | 현재 19+3 구조의 Human evidence 전 대량 item/recipe 증식 금지 |
| PLAYER_FEEDBACK_REBUILD_LOOP | ADOPT | REST가 정리 노동인지 선택인지 Human evidence로 판정 |
| AI_VISIBLE_OUTPUT_QUALITY_GATE | ADOPT | 향후 생성 시각물도 기존 visual/rights/readability bar 적용 |
| RNG_AGENCY_AND_RECOVERY | ADAPT_HIGH | `LOW_VALUE_REWARD_RECOVERY`로 변형 |
| runtime generative AI | REJECT_CURRENT | 현재 코어에 불필요 |

## 3. 핵심 변형 · LOW_VALUE_REWARD_RECOVERY

목표는 모든 랜덤 보상을 강하게 만드는 것이 아니다. **낮은 가치 결과도 플레이어에게 최소 하나의 의미 있는 판단을 남기게 한다.**

```text
reward candidate
→ 현재 유파/태그/recipe/공간 상태와 비교
→ 선택
→ 배치 / 회전 / 인접 / recipe 보류 / Workbench 보관
→ 다음 전투
→ 결과를 보고 재배치/조합
```

### Base item 최소 의미 계약

기존 `모든 base item은 standalone utility 보유`를 유지하고, 보상으로 등장한 아이템은 다음 중 최소 하나가 명확해야 한다.

```text
STANDALONE_VALUE
SPATIAL_VALUE
TAG_BUILD_VALUE
RECIPE_PATH_VALUE
FUTURE_REARRANGEMENT_VALUE
```

현재 MVP-3에는 `sell_item()` 기반 판매/환금 경로가 이미 존재하므로 그것을 없는 기능처럼 취급하지 않는다. 다만 LOW_VALUE_REWARD_RECOVERY를 이유로 **별도 자동 분해, 신규 변환 화폐, 두 번째 sell/convert 경제 시스템**을 추가하지 않는다. 기존 판매 기능은 향후 Workbench/acquisition migration에서 명시적으로 supersede되지 않는 한 호환 대상으로 보존한다.

## 4. 보상 Agency

현재 승인된 weak weighted bias를 강화하되 자동 정답 추천으로 만들지 않는다.

```text
현재 유파/태그/recipe 상태
→ 약한 offer weighting
→ 서로 다른 이유가 있는 후보 제시
→ 플레이어가 공간/조합 기회비용으로 선택
```

검사 질문:

- 후보 세 개가 사실상 하나의 정답과 두 개의 쓰레기로 갈리는가?
- 같은 학교/recipe가 반복되어 매 Run이 동일해지는가?
- footprint 때문에 강한 아이템을 포기하는 실제 고민이 있는가?
- standalone item이 recipe 재료가 되기 전에도 정상 기능하는가?

## 5. REST decision-quality Gate

REST는 전투 사이의 **생각하는 시간**이어야 하며 정리 노동이 되어서는 안 된다.

Human QA에서 다음을 구분한다.

```text
GOOD_DEPTH
= 배치/회전/인접/조합 중 무엇을 포기할지 고민

BAD_FRICTION
= 원하는 행동은 이미 정했는데 조작·정리 때문에 시간이 듦
```

응답 순서:

```text
readability / cue
→ UI friction
→ individual item tuning
→ offer weighting
→ footprint
→ core board rule은 마지막
```

## 6. Breadth Gate

19 base items + 3 combo results가 아래를 통과하기 전에 AI로 50/100종을 생성하지 않는다.

- 강한 공간 아이템 8종이 실제로 서로 다른 배치 고민을 만드는가.
- 단순 11종이 filler가 아니라 읽기 쉬운 기반 조각인가.
- 3 combo result가 숫자 합산 이상의 플레이 스타일 변화를 만드는가.
- 유파/tag vocabulary를 플레이어가 이해하는가.
- first REST가 과도하게 길어지지 않는가.

## 7. 다음 Codex 구현 후보

이 문서는 런타임 변경 자체를 수행하지 않는다. 향후 승인된 Phase-C 범위에서:

1. Reward candidate마다 위 `minimum meaning`을 기존 data/test로 파생 검증할 수 있는지 검사하고, 별도 의미 taxonomy를 새 authority로 만들지 않는다.
2. 동일 seed reward sequence를 replay하여 dead-offer 비율과 repeated-build 비율을 측정.
3. Balance Scenario에서 school/tag/recipe weighting의 과적합을 탐지.
4. REST telemetry에 decision time과 invalid placement retry를 분리해 기록.
5. Human play에서 “정리하느라 바빴다”와 “고민하느라 오래 걸렸다”를 구분.

## 8. 성공/폐기 조건

유지:
- 낮은 tier/비선호 아이템도 배치·recipe·태그 판단을 만든다.
- 보상 후보 사이에 실제 기회비용이 있다.
- REST 시간이 늘어도 이유가 조작이 아니라 의사결정이다.

재검토:
- dead item이 반복된다.
- 약한 weighting이 사실상 빌드 자동완성이 된다.
- 같은 recipe가 대부분의 Run을 지배한다.
- 공간 시스템이 inventory capacity로만 인식된다.

## 9. Implementation Reality Gate

현재 주장 가능:
- 기존 백팩 정본과 모순 없이 RNG agency/recovery가 프로젝트용 계약으로 변형됨.
- 기존 판매 기능을 보존하면서 새 화폐/자동 분해/두 번째 변환 경제/런타임 AI 없이 standalone/spatial/tag/recipe 구조를 활용하도록 경계를 정리함.

현재 주장 불가:
- 보상 체감이 개선됨.
- REST pacing이 적절함.
- 최종 weighting 수치가 승인됨.
- Human/device 플레이 검증 통과.

## 10. 적대적 검토 5회

1. **기능 팽창** — 기존 sell은 보존하고 새 currency/자동 분해/두 번째 convert 경제는 만들지 않음: PASS.
2. **자동빌드** — weighting은 weak bias, 정답 추천 금지: PASS.
3. **죽은 보상** — standalone 가치 + 복수 의미 경로 요구: PASS.
4. **인지부하** — breadth는 Human evidence 뒤에만 확장: PASS.
5. **실행 과장** — runtime/Human evidence는 NOT_RUN 유지: PASS.

`CLEAN_REVIEW_EXIT`.
