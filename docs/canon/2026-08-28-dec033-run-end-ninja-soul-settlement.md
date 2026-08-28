# DEC-033 — Run 종료 닌자소울 정산과 재도전/전투 GOLD 경계

```yaml
decision_id: DEC-033
status: APPROVED_PRODUCT_SCOPE_IMPLEMENTATION_DEFERRED
approved_by: USER
approved_at: 2026-08-28 KST
owner: docs/canon/2026-08-28-dec033-run-end-ninja-soul-settlement.md
supersedes: DEC-031 retry-currency-and-no-persistent-currency scope only
implementation_reality: NO_RANK_OR_NINJA_SOUL_OWNER_OR_ELITE_REWARD_RUNTIME
human_player_evidence: NOT_RUN
```

## 1. 결정

`GOLD`는 Run 안에서 Shop·Chest·Backpack 선택에 쓰는 **일시 재화**로 남긴다. 재도전 비용에는 사용하지 않는다.

`닌자소울`은 영구 재화다. Boss를 처치할 때 즉시 지갑에 저장하지 않고, Run이 끝나는 Result 정산에서 한 번만 다음을 합산해 지급한다.

```text
Run-end NinjaSoul settlement
= distinct school Boss clears × 2
+ progress rank bonus
```

여기서 Run 종료는 player death/명시적 포기 또는 Final Binding·final calamity까지 마친 **실제 Run 결론**이다. DEC-030의 첫 Human Slice 끝인 네 번째 학교 Boss 뒤 `final_binding_eligible`은 Run 종료가 아니며 닌자소울을 지급하지 않는다.

- Elite는 `5G`만 지급하며 닌자소울을 지급하지 않는다.
- 학교 Boss는 `10G`와 닌자소울 집계 자격을 준다.
- 일반 몬스터는 권장 기본값 `20%` 확률로 `1G`를 준다. 이 값은 Human balance 검증 전 `TUNE_RECOMMENDED`이며 data-config로 조정 가능해야 한다.
- 닌자소울은 시작 보유량 `0`에서 시작한다. 별도 시작 보너스는 승인하지 않는다.
- 한 Run의 Boss 식별자는 한 번만 집계한다. retry 뒤 같은 Boss를 다시 처치해도 닌자소울 자격은 중복되지 않는다.

## 2. 랭크와 권장 수치

랭크는 전투 점수·콤보가 아니라 **서로 다른 학교 Boss 격파 수**로 결정한다. Boss 처치 보상이 이미 위험한 전투 성공을 직접 보상하므로, 유파별 score 편차를 랭크에 섞지 않는다.

| Boss 격파 수 | Result 랭크 | 랭크 닌자소울 | Boss 처치 소울 | 해당 시점 총 정산 |
| --- | --- | ---: | ---: | ---: |
| 0 | C | 0 | 0 | 0 |
| 1 | B | 1 | 2 | 3 |
| 2–3 | A | 2 | 4–6 | 6–8 |
| 4 | S | 4 | 8 | 12 |

이 표의 수치는 **첫 Human Slice용 권장값**이다. 재도전 비용 `1`은 고정하고, 정산값은 Human/Player balance evidence 뒤에만 조정한다. Final Binding/final calamity는 DEC-030의 별도 package이므로 이 표에 포함하지 않는다.

## 3. 패배와 재도전

기본 패배는 계속 Run 종료다. 단, 유효한 성공 Workbench checkpoint가 있고 아직 쓰지 않았다면, 플레이어는 보유 닌자소울 `1`을 명시적으로 소비하여 같은 활성 학교 `0:00`부터 한 Run에 한 번 재도전할 수 있다.

```text
player death
-> retry unused + valid Workbench checkpoint + persistent NinjaSoul >= 1?
   -> explicitly spend 1 NinjaSoul atomically
   -> retry_used = true
   -> restore last committed Backpack / Fate / route checkpoint
   -> restart same active school at 0:00
otherwise
   -> settle Run-end NinjaSoul once
   -> Run ends -> new Run
```

`GOLD`, ORB, Chest token, Trace, 현재 학교의 미확정 보상/진척은 DEC-031의 원칙대로 실패 학교에서 잃는다. 다만 **이미 유효하게 처치한 서로 다른 학교 Boss의 닌자소울 자격 ledger는 Run 종료 정산 전까지 보존**한다. 이 ledger는 retry restore의 대상인 transient Run build가 아니라, 중복 지급을 막는 Run-end settlement owner가 소유한다.

## 4. 보호 경계

- `NinjaSoulWallet`은 영구 지갑의 단일 owner다. UI, `RunBuildState`, Shop 또는 Workbench가 지갑을 직접 변경하지 않는다.
- `RunSettlementLedger`는 distinct Boss-clear 자격과 Result 정산 idempotency를 소유한다. Boss GOLD 지급·route stabilization·reward selection과 같은 이벤트에서 UI가 별도 누적하지 않는다.
- retry 소비와 persistent wallet write, Run-end settlement와 persistent wallet write는 각각 all-or-none이며 중복 callback/scene reload/재시작에서 두 번 적용될 수 없다.
- 기존 `normal_kill_gold_pct` item modifier는 일반 몬스터 drop chance의 **기대값을 +25%씩** 높이는 의미로 보존하되, 정확한 RNG/seed와 표기 방식은 Phase 2 contract에서 deterministic test owner와 함께 정의한다. Boss/Elite 고정 GOLD에는 적용하지 않는다.
- Result 화면은 랭크, Boss 격파 수, Boss 처치 소울, 랭크 보너스, 합계를 분리해 보여야 한다. 점수·콤보는 기존 결과 telemetry로 남되 랭크 근거로 오인시키지 않는다.

## 5. DEC-031과의 관계

DEC-031의 다음 범위는 이 결정으로 **SUPERSEDED**다.

- checkpoint `GOLD` 재도전 비용
- 새 영구 재화/저장 지갑을 금지한 제한
- retry 후 기존 Boss 자격을 모두 잃는 해석

DEC-031의 기본 Run 종료, 한 Run 한 번, valid Workbench checkpoint, same-school restart, atomic restore, retry 뒤 재충전 없음, transient reward 손실은 계속 **CURRENT**다.

## 6. Implementation contract 필수 항목

1. persistent `NinjaSoulWallet`과 `RunSettlementLedger`의 data/save/load/idempotency contract.
2. Boss/Elite/normal enemy role을 runtime reward event에서 구분하는 data/Scene contract.
3. 20% normal drop chance와 modifier 기대값을 seeded/검증 가능한 방식으로 처리하는 test contract.
4. retry consume / retry restore / run-end settlement의 순서, 실패·중단·중복 신호 경계.
5. Result/Game Over UI의 한국어, mouse, keyboard/gamepad focus, touch path와 no-balance visibility states.
6. rank/kill reward table, first-run zero wallet, retry 후 duplicate Boss, 0/1/2/3/4 Boss 종료, no-checkpoint/insufficient-soul regression tests.

## 7. Incident / Solution / Lesson

- **Incident:** DEC-031은 `GOLD`를 Shop 선택과 재도전 비용에 동시에 묶었고, 실제 runtime에는 Elite reward·랭크·영구 닌자소울 owner가 전혀 없었다.
- **Solution:** GOLD를 Run economy로 되돌리고, 영구 닌자소울은 Boss-clear eligibility와 Result settlement를 분리한 owner로 제한한다.
- **Lesson:** 동일한 재화가 Run 내 선택과 Run 밖 회복권을 동시에 결정하면, 플레이어의 Shop 선택이 실패 보험으로 전환될 수 있다. 재화의 lifetime·자격 이벤트·지급 시점을 별도로 정본화해야 한다.

## 8. Base 승격 판정

`NO_BASE_PROMOTION`: Boss 수, GOLD 수치, rank table, checkpoint 조건, Ninja Soul의 획득 의미는 이 프로젝트 고유 product balance다. “eligibility event와 durable settlement를 구분한다”는 일반 원칙은 현재 Base의 transaction/evidence ownership 범위에 이미 속하므로 프로젝트 수치와 함께 복제·승격하지 않는다.

## 9. 적대적 검토 — 전체 범위 5회

1. **중복 farm:** distinct school Boss ID와 one-time Result settlement를 분리해 retry/중복 signal로 Boss 소울을 다시 받을 수 없게 한다.
2. **첫 Run 공정성:** 시작 지갑은 0이므로 첫 Run에 공짜 재도전이 생기지 않는다. 이후 Boss 성공이 다음 Run의 유한한 학습 기회를 연다.
3. **Shop 긴장:** GOLD retry를 제거해 Bag/아이템/리롤 선택이 실패 보험에 잠식되지 않게 한다.
4. **유파 공정성:** 랭크를 raw score에서 분리해 적 밀도·유파 damage profile이 permanent payout을 왜곡하지 않게 한다.
5. **증거 과장:** 현재 runtime에는 rank, persistent wallet, elite payout, chance drop, retry checkpoint가 없다. 이 문서는 승인된 contract이며 구현·Human/Player PASS가 아니다.
