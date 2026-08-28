# 2026-08-28 Run Economy Settlement Ownership — Incident / Solution / Lesson

## Status

- Project: NINJA_SURVIVAL / 닌자의 신
- Scope: Run 재화, 재도전 비용, Boss 자격, 영구 재화 Result 정산
- Evidence: current canon/actual source comparison + user-approved DEC-033
- Runtime/Human evidence: `NOT_RUN`

## Incident

기존 DEC-031은 `GOLD`를 Workbench/Shop의 Run 선택과 같은 학교 재도전 비용에 함께 사용했다. 실제 코드에는 Elite reward, Rank, Ninja Soul 지갑, Run-end settlement owner가 없었다.

## Solution

DEC-033은 `GOLD`를 Run economy에 한정하고, Boss 처치 자격과 Result 시점의 영구 Ninja Soul 지급을 `RunSettlementLedger`와 `NinjaSoulWallet`으로 분리하는 계약을 승인했다. retry는 persistent Ninja Soul 1을 명시적으로 소비하며, 같은 학교 Boss는 한 Run에 한 번만 집계한다. 2026-08-28 Master GDD fresh-read에서 발견한 Notion Home의 `GOLD` 재도전 문구도 같은 의미로 교정했고, Human Home destination readback으로 영구 `닌자소울` 1 비용과 transient-loss/committed-state 복구 경계를 확인했다.

## Lesson

재화 설계에서는 다음 세 가지를 분리해 정본화한다.

```text
resource lifetime (Run / persistent)
!= eligibility event (what earns entitlement)
!= settlement time (when durable balance changes)
```

그렇지 않으면 플레이어가 build 선택 재화를 실패 보험으로 보관하게 되거나 retry/reload 중복 지급 경계가 흐려진다.

## Base promotion

`NO_BASE_PROMOTION`: 원칙 자체는 일반적이지만 현재 Base의 transaction/evidence owner 규칙으로 충분하며, 이 사건의 Boss/Rank/GOLD/Ninja Soul 값은 프로젝트 전용이다.
