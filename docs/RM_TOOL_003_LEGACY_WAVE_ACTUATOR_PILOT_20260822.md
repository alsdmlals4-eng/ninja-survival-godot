# RM-TOOL-003 Legacy Wave Actuator Pilot — 2026-08-22

## 목적과 경계

이 문서는 현재 `main`에 실제 존재하는 legacy `WaveSpawner` actuator의 좁은 수치 계약을 Base `RM-TOOL-003 BALANCE_SCENARIO_BATCH_SIMULATOR` 형식으로 읽기 전용 검증한 sidecar evidence다.

- Source commit: `77f7e4dc1d0a5946acaa006b35d7003dc91cd718`
- Source runtime: `scripts/spawning/wave_spawner.gd`
- Source regression: `tests/unit/test_wave_spawner.gd`
- Product/runtime mutation: **NONE**
- `data/stages/`의 현재 상태: `.gitkeep`만 존재
- DEC-014~026 신규 runtime/stage balance: **NOT STARTED / NOT EVALUATED**

이 Pilot은 T01~T14 승인 실행순서를 건너뛰거나 DEC-026 스테이지 밸런스를 발명하지 않는다.

## 현재 legacy 계약

현행 기본값은 다음과 같다.

```text
batch_size = 2
max_active_enemies = 8
enabled = true
spawn_count = min(max(batch_size, 0), max(max_active_enemies - active_count, 0))
```

`enabled = false`이면 spawn count는 0이다.

## Exhaustive cap-state scan

초기 active enemy를 `0..8` 전부 대입했다. 난수가 없는 순수 actuator 계약이라 Monte Carlo 대신 전체 상태 열거가 더 정확하다.

| initial active | enabled spawn | enabled final active | disabled spawn |
|---:|---:|---:|---:|
| 0 | 2 | 2 | 0 |
| 1 | 2 | 3 | 0 |
| 2 | 2 | 4 | 0 |
| 3 | 2 | 5 | 0 |
| 4 | 2 | 6 | 0 |
| 5 | 2 | 7 | 0 |
| 6 | 2 | 8 | 0 |
| 7 | 1 | 8 | 0 |
| 8 | 0 | 8 | 0 |

Enabled variant:
- mean spawn count: `1.6666666667`
- median spawn count: `2`
- mean final active: `5.6666666667`
- median final active: `6`
- mean cap fill ratio: `0.7083333333`
- cap violation: `0 / 9`

Disabled variant:
- spawn count: 항상 `0`
- cap violation: `0 / 9`

## 공용 분석 계약 적합성

이 actuator는 Base 공통 run-record로 다음처럼 표현 가능하다.

```text
seed/run identity := initial_active (deterministic exhaustive case id)
variant := enabled_default_actuator | disabled_actuator
metrics := spawn_count, final_active, cap_fill_ratio
failure tags := CAP_VIOLATION when final_active > 8
choices := not applicable
```

즉 공통 analyzer가 게임별 spawn 규칙을 다시 소유할 필요 없이 **project-owned deterministic records**를 후처리할 수 있다.

## 중요한 비적용 범위

현재 `data/stages/`에는 신규 stage definition이 없으므로 다음은 이 Pilot의 증거가 아니다.

- DEC-026 encounter budget
- 새 wave pressure curve
- boss timing
- enemy composition balance
- reward/build interaction
- 실제 player difficulty/fun

향후 T01 이후 승인 순서에 따라 stage data와 runtime owner가 생긴 뒤 해당 project adapter가 deterministic record를 내보낼 수 있다. 그 전에는 Base가 임의 수치를 만들지 않는다.

## 판정

1. legacy actuator의 cap/disabled invariant는 **현재 runtime + GUT 계약과 정합**.
2. Base shared analyzer의 run-record 인터페이스는 deterministic actuator에도 적용 가능.
3. 신규 Ninja-specific balance simulator는 **DEFER** — DEC-026 data/runtime가 아직 없다.
4. Tool Hub GUI는 **DEFER** — 현재는 CLI/machine report 이상의 반복 human burden이 증명되지 않았다.

## Evidence ceiling

- `LEGACY_MVP3_ACTUATOR_CONTRACT_ONLY`
- `DEC014_026_RUNTIME_NOT_STARTED`
- `PRODUCT_BALANCE_NOT_EVALUATED`
- `PRODUCT_RUNTIME_UNCHANGED`
- `HUMAN_PLAYER_EVIDENCE_NOT_RUN`

Machine-readable evidence: `docs/rm_tool_003_legacy_wave_actuator_pilot_20260822.json`.
