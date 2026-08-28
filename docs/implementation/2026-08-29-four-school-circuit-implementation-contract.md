# 네 유파 Circuit 구현계약

```yaml
contract_id: NINJA_FOUR_SCHOOL_CIRCUIT_V1
status: PROPOSED_FOR_USER_IMPLEMENTATION_CONTRACT_APPROVAL
issue: 126
base_main_read: 50fbf203ec3f71af1633a5b6cc74e7167c0604c8
engine: Godot_4.x_GDScript
implementation_entry: fresh_completed_main_only
human_usability: DEFERRED_BY_DEC036_NOT_RUN
player_experience: DEFERRED_BY_DEC036_NOT_RUN
device_export: NOT_RUN
out_of_scope:
  - Final_Binding_Workbench_scene
  - final_calamity_Boss
  - final_result_and_legend
  - true_Run_end_Ninja_Soul_credit
  - production_asset_batch
  - PR_49_mutation
```

## 1. 목표와 플레이어 경험

한 명의 고정 닌자가 네 유파를 한 번씩 선택하고, 전장에서 각 유파의 위험 처리법을 배운 뒤, 보상·6×6 백팩·Fate·다음 학교를 한 번에 확정한다. 각 선택은 다음 전장의 위험 처리 방식으로 되돌아와야 한다.

```text
위협과 위치를 읽는다
-> 유파 자동 행동이 기회를 드러낸다
-> Core / Elite / Trace / Boss를 통과한다
-> 보상과 공간 배치를 선택한다
-> Fate와 다음 미방문 학교를 함께 확정한다
-> 더 어려운 유파에서 선택의 결과를 감당한다
```

자동 공격은 유지한다. 플레이어의 대표 행동은 조준 연타가 아니라 이동·군집 유도·위험 거리 유지·위협 우선순위·공간 배치·route/Fate 선택이다.

## 2. 현재 사실과 교체 범위

| ID | 현재 main 사실 | 구현계약의 처리 |
| --- | --- | --- |
| `C-01` | 완결 lifecycle adapter는 `CheonsulVerticalSliceController`에만 연결돼 있다. | shared lifecycle로 추출하고 네 유파 data composition이 소비한다. |
| `C-02` | `R`/HUD 버튼이 Trace를 즉시 회수한다. | Elite가 만든 in-world Trace pickup의 settle → 근거리 homing → 자동 회수로 교체한다. `RewardOrb`와 합치지 않는다. |
| `C-03` | `EnemyEffectBadge`가 `BURN`/`WET`/`SHOCK`/`MARK` 텍스트를 표시하고, 적 HP UI가 없다. | 형태·색이 구분되는 아이콘과 최근 피격 적 하나의 임시 HP 바로 교체한다. |
| `C-04` | Workbench는 Boss 보상 후보를 읽기만 하고, 보상 선택·6×6 배치·회전·조합을 입력받지 못한다. | Boss reward → REST buffer → spatial placement/rotation/combination → route/Fate → atomic commit 경로를 완성한다. |
| `C-05` | `RunBuildState`는 일반 적 처치마다 1G, Boss마다 25G를 준다. | normal 20% × 1G / Elite 5G / school Boss 10G의 data policy로 바꾼다. |
| `C-06` | Ninja Soul wallet, retry checkpoint, Boss eligibility ledger, Result settlement owner가 없다. | retry에 필요한 최소 persistent wallet·checkpoint·idempotent eligibility ledger를 추가한다. 실제 Soul credit은 true Run end package까지 보류한다. |

## 3. 보호 경계

- **한 chassis:** `EncounterCatalog`의 shared attack primitive와 Stage profile을 재사용한다. 유파별로 별도 전투 엔진, 별도 route owner 또는 별도 Backpack owner를 만들지 않는다.
- **도메인 소유:** UI는 snapshot을 그려 intents만 낸다. legality, economy, route, Fate, reward 및 atomic commit은 기존 domain owner 또는 이 계약의 새 domain owner가 소유한다.
- **기존 백팩 규칙:** 6×6, 시작 4×3, 90도 회전, 직교 인접, overlap special-bag activation, 6-slot REST buffer, 명시적 first-tier combination, preview combat power 0, committed modifier snapshot만 combat authority라는 규칙을 지킨다.
- **한 캐릭터:** 유파는 서로 다른 주인공/코스튬이 아니다. 시작 유파 Trace Stage 3만 가장 강하고 다른 Trace는 보조 layer다.
- **최종 package 분리:** 네 번째 Boss는 `final_binding_eligible`만 만든다. Final Binding Scene·final boss·결산을 임시 결말로 만들지 않는다.

## 4. 공유 lifecycle 계약

### 4.1 새 shared owner

`SchoolCircuitController`는 현재 Cheonsul adapter의 학교 중립 lifecycle 역할을 분리해 소유한다. `StageEncounterState`는 Core/Elite/Trace/Boss gate 상태를 계속 소유하고, `RunRouteState`는 active/provisional/cleared school과 네 번째 clear의 `final_binding_eligible`을 계속 소유한다.

`SchoolCircuitController`의 입력은 `school_id`, `EncounterCatalog` definition, `StageEncounterState`, `RunRouteState`, `RestBackpackSession`, `RestCommitCoordinator`, `RunBuildState`다. 출력은 lifecycle snapshot, required combat spawn intent, Trace spawn intent, Boss reward candidates, Workbench snapshot이다. UI나 school runtime이 route/Fate/backpack을 직접 변경하지 않는다.

### 4.2 공통 흐름

| 단계 | domain rule | 화면/플레이어 피드백 | machine acceptance |
| --- | --- | --- | --- |
| 선택 | 미방문 학교만 active route가 된다. | 학교 위험 처리 문장과 도움말 진입점 | 재방문/중복 active 거부 |
| signature | 시작 후 30초 안에 학교 고유 기회가 한 번 보인다. | 봉마 방어선, 천술 준비 결계, 귀인 근접 창, 흑영 우선 표식 | 각 school definition의 signature spawn/assertion |
| Core | school-owned Core 3종을 Stage budget 안에서 조합한다. | 무엇을 피하고 무엇을 이용할지가 다르게 읽힌다. | generic-only spawn 금지, composition ID 기록 |
| Elite | 180초에 Elite 1종이 나온다. | Elite name/telegraph와 다음 Trace 목적 | Elite clear만 Trace AVAILABLE 전이 |
| Trace | Elite clear가 Trace 1개를 생성한다. | 전장 내 Trace 방향/거리 cue, 근거리 자동 회수 | ORB/Gold/power 없이 Trace gate만 전이 |
| Boss | Elite + recovered Trace + 300초 + Boss warning가 모두 필요하다. | warning 후 Boss entry | 하나라도 빠지면 Boss spawn 거부 |
| Result | Boss clear가 school을 stabilize하고 보상 후보를 만든다. | 보상과 Workbench 진입 이유 | 보상 선택 전 combat build/route/Fate 변경 0 |
| Workbench | 보상·backpack·Fate·provisional route를 검증하고 atomic commit한다. | 다음 학교와 대가를 명확히 보여 준다. | incomplete/reentrant commit은 전체 무변경 |

### 4.3 유파별 composition

각 school은 Core 3 / Elite 1 / Boss 1을 갖되, 공격 primitive budget은 DEC-026을 지킨다. Stage 1은 major hazard 1개, Stage 2는 advanced gimmick 1개, Stage 3/4와 Boss는 advanced gimmick 동시 2개를 넘지 않는다.

| 유파 | signature와 Core 판단 | Elite/Boss capstone | 금지 |
| --- | --- | --- | --- |
| 봉마 | 이동 경로에 식신/결계가 유지되는 공간을 만든다. | 방어선 밖으로 끌어내는 압박 후 안전지대 재구축 | 정지형 tower defense |
| 천술 | 적 무리를 고정 청색 준비 결계로 유도한다. | `WET` 준비군을 우선 `SHOCK`해 호박/주황 반응으로 전환 | 수동 조준 주문 |
| 귀인 | 위험 근접에 더 머물 가치와 이탈 시점을 판단한다. | 근접 유지력과 탈출 창의 교대 | 저체력만 강요 |
| 흑영 | 가장 위험한 적을 표식/처형 순서로 줄인다. | 위협 우선순위가 보스 압박과 상호작용 | 수동 표적 클릭 게임 |

### 4.4 천술 초기 data 값

이 계약은 계산 가능한 초기값을 고정한다. 이후 값 변경은 Resource/data 변경과 focused regression을 동반한다.

```yaml
wet_cast_interval_s: 1.8
setup_seal_duration_s: 2.4
setup_seal_radius_px: 128
prepared_group_minimum: 2
prepared_shock_damage_multiplier: 1.5
prepared_shock_priority: largest_valid_group_then_nearest_group_center
color_language:
  setup: blue
  reaction: amber_orange
```

이 값은 `TUNE_RECOMMENDED`다. machine test는 값 자체와 priority tie-break를 고정하고, 사람/밸런스 evidence 없이 stealth tuning하지 않는다.

## 5. Trace와 전투 정보 계약

### Trace

- Elite만 `TracePickup` 하나를 만든다. Trace는 chest token과 함께 lifecycle progression을 열지만 ORB, style, Gold, combat modifier가 아니다.
- Spawn 뒤 0.35초간 settle한 후 Player가 96px 이내에 들어오면 0.40초 homing하고 자동 회수한다.
- 유효 Trace 회수만 `StageEncounterState`를 `TRACE_RECOVERED`로 바꾼다. `R`/HUD 즉시 회수 control과 test jump는 player-facing path에서 제거하거나 debug-only harness로 분리한다.
- same-school retry는 실패한 학교의 active Trace를 삭제한다. 직전 성공 Workbench checkpoint 이전의 stabilized school state와 eligibility ledger만 보존한다.

### 상태와 HP

- 상태는 `StatusIconPresenter`가 school-neutral semantic status를 아이콘으로 바꾼다. icon은 color만으로 구별하지 않으며, HUD/도움말에서 Korean description을 제공한다.
- `EnemyEffectBadge`의 지속 텍스트는 제거한다. 어떤 상태도 화면을 가리는 긴 label을 쓰지 않는다.
- `RecentHitHpPresenter`는 damage signal을 받은 적 하나만 1.25초 HP bar를 보인다. 새 피격은 기존 표시를 즉시 숨기고 새 대상의 timer를 다시 시작한다. 사망·queue_free·비가시 대상은 bar를 즉시 정리한다.
- 천술은 blue + amber/orange, 흑영 reserved purple/black을 유지한다. VFX가 status icon 또는 telegraph보다 먼저 읽히면 안 된다.

## 6. Boss reward와 spatial Workbench 계약

1. Boss clear는 lane-first candidate 3개를 `RestRewardController`에 만들고 `boss_reward_pending`을 true로 둔다.
2. 플레이어는 정확히 한 보상만 선택해 6-slot REST buffer로 획득한다. 선택 전 route/Fate/commit은 disabled다.
3. buffer item/bag은 pointer, keyboard/gamepad focus, touch 각각으로 6×6 board에 place/remove/90도 rotate한다. 모든 legal/illegal result는 domain snapshot에서 온 Korean reason으로 표시한다.
4. explicit first-tier combination은 `CombinationResolver`만 실행한다. preview/buffer/pending item의 combat contribution은 0이다.
5. player가 하나의 provisional unvisited route와 하나의 pending Fate를 고른다. `RestCommitCoordinator`가 final layout snapshot + Fate + route를 all-or-none으로 commit한다.
6. 실패, duplicate input, stale session, invalid layout, pending reward/chest/bag/combination은 committed backpack/Fate/route를 하나도 바꾸지 않는다.

Boss reward selection, board legality, economy, Fate 및 route 판단을 `RestFlowUI`에 넣지 않는다.

## 7. Economy, retry, persistence 계약

### 7.1 transient G

`RunEconomyPolicy` Resource는 아래 값의 유일한 source다.

```yaml
normal_kill_gold:
  chance: 0.20
  amount: 1
elite_clear_gold: 5
school_boss_clear_gold: 10
```

난수는 Run-local seeded policy로 처리하고 GUT에서 seed를 고정한다. 기존 `NORMAL_KILL_GOLD = 1` 누적 방식과 `BOSS_KILL_GOLD = 25`는 제거한다. reward source는 normal/Elite/Boss를 구분한 receipt를 Result snapshot에 남긴다.

### 7.2 Ninja Soul와 retry

- `NinjaSoulWallet`은 영구 balance를 읽고, retry를 위해서만 `spend(1)` 한다. wallet만 persistent balance를 write한다.
- `RunSettlementLedger`는 distinct school Boss eligibility를 idempotently 기록한다. 같은 school Boss나 retry 재시작은 entry를 중복 추가하지 않는다.
- 성공 Workbench commit 직후 `RunCheckpoint`가 committed backpack modifier snapshot, Fate, active/provisional/cleared route, transient G, eligible Boss IDs를 저장한다.
- death의 기본 동작은 Run end다. 단, Run당 아직 retry하지 않았고, valid checkpoint가 있고, wallet에서 1 Soul을 성공적으로 debit하면 현재 학교를 0:00에서 한 번 재시작한다.
- retry는 실패한 학교의 G/RewardOrb/chest token/Trace/미확정 보상/진행을 제거한다. checkpoint 이전 state와 already-eligible Boss IDs만 복원한다.
- 진짜 Run end의 Soul credit은 Final Binding/final calamity package가 소유한다. 네 번째 Boss `final_binding_eligible`은 credit을 만들지 않는다.

## 8. 구현 순서와 완료 단위

| 순서 | 단위 | player value / dependency | 완료 기준 |
| --- | --- | --- | --- |
| `I-01` | shared circuit + school composition data | 네 학교를 선택할 수 있다는 약속을 실제 route와 맞춘다. | all-four lifecycle domain/integration GUT, no generic-only route |
| `I-02` | Trace pickup + telegraph + information grammar | Elite 이후의 목적과 위험을 읽는다. | Trace object/auto-recovery, icon/last-hit HP focused GUT |
| `I-03` | Boss reward → spatial Workbench input | 배치 선택이 실제 build가 된다. | reward select/place/rotate/combine/commit full intent tests |
| `I-04` | economy + checkpoint + retry ledger | 실패와 재도전의 대가를 명확히 한다. | deterministic economy, one-retry, idempotency, save boundary tests |
| `I-05` | four-school machine circuit | 네 유파의 차이가 함께 유지된다. | deterministic four-school end-to-end test through `final_binding_eligible` |
| `I-06` | exact-head evidence + adversarial review | scope/regression을 증명한다. | import/parse/smoke/full GUT/Windows internal build/5 clean review loops |

`I-01`~`I-06`은 이 contract의 한 package다. Final Binding/final calamity/result settlement는 다음 package로 분리한다.

## 9. 검증 계약

### 필수 machine evidence

1. 새/변경 domain owner의 TDD red → green focused GUT.
2. `EncounterCatalog` school composition 및 Stage budget unit tests.
3. Trace, status icon, last-hit HP, Workbench atomicity, economy/retry/ledger failure cases의 focused GUT.
4. 네 유파를 deterministic harness로 순서 다르게 모두 clear하고 `final_binding_eligible`까지 도달하는 integration test.
5. Godot import, editor parse, headless main-scene smoke, full GUT, exact PR-head GitHub GUT, Windows internal build artifact.
6. 각 material change 뒤 five whole-state adversarial loops. 확인된 finding만 수정하고 affected scope를 회귀한다.

### 명시적으로 이번 gate에서 제외하는 evidence

- Human Usability, Player Experience, device/Android export, live visual target-resolution readability, release readiness는 DEC-036에 따라 `NOT_RUN`이다.
- headless/import/GUT pass를 위 evidence의 대체물로 쓰지 않는다.
- 새 raster batch나 generated visual board는 runtime asset completion으로 계산하지 않는다.

## 10. Benchmark disposition

| reference | contract use | disposition | do not copy |
| --- | --- | --- | --- |
| [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors/) | time survival의 빠른 위협 escalation과 Run별 G의 의미 | `ADAPT` | 무기 진화·메타 surface |
| [Brotato](https://store.steampowered.com/app/1942280/Brotato/) | 자동 발사와 짧은 생존/상점 cadence | `ADAPT` | wave-only 구조와 캐릭터/무기 표현 |
| [Backpack Battles](https://store.steampowered.com/app/2427700/Backpack_Battles/) | 구매한 물건의 위치가 실제 전투력으로 이어지는 명확성 | `ADAPT` | PvP/rank, 아이템 표현, UI trade dress |
| [Hades II](https://www.supergiantgames.com/games/hades-ii/) | authored encounter와 어두운 판타지의 일관된 tone | `REFERENCE_ONLY` | 수동 전투·서사 production 규모 |

## 11. 승인 기준

이 계약이 승인되면 Codex implementation은 fresh completed `main`에서 새 Issue/branch로만 시작한다. 구현자는 이 문서, DEC-014~036, current code/tests, `AGENTS.md`를 먼저 읽고 각 `I-*` 단위를 독립 PR/acceptance package로 수행한다.

다음 중 하나라도 발생하면 새 product review가 필요하다.

- Final Binding/final calamity를 네 유파 circuit에 포함하려는 경우
- 수동 조준·별도 유파 주인공·four independent engines를 추가하려는 경우
- persistent wallet가 retry 외 영구 능력치/meta-power를 쓰려는 경우
- `TUNE_RECOMMENDED` 값을 바꾸면서 player promise, boss gate, economy 의미를 바꾸는 경우
